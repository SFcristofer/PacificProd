import { LightningElement, api, wire, track } from 'lwc';
import { getRecordUi } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class TechProductSmartDetail extends LightningElement {
    @api recordId;
    @track sections = [];
    @track allSections = [];
    @track activeSections = [];
    @track isEditMode = false;
    @track hasVisibleCards = false;

    toggleEditMode() {
        this.isEditMode = !this.isEditMode;
    }

    handleSuccess(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Éxito',
                message: 'El registro ha sido actualizado correctamente.',
                variant: 'success'
            })
        );
        this.isEditMode = false;
    }

    handleError(event) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error al Guardar',
                message: event.detail.detail || 'Revisa los campos para asegurar que cumplen con las reglas de validación.',
                variant: 'error'
            })
        );
    }

    @wire(getRecordUi, { recordIds: '$recordId', layoutTypes: 'Full', modes: 'View' })
    wiredRecordUi({ error, data }) {
        if (data) {
            const layouts = data.layouts.Product2;
            const layoutIds = Object.keys(layouts);
            const objectInfo = data.objectInfos && data.objectInfos.Product2;
            const recordInfo = data.records && data.records[this.recordId];
            
            if (layoutIds.length > 0) {
                const layoutData = layouts[layoutIds[0]].Full.View;
                
                if (layoutData && layoutData.sections) {
                    let generatedSections = [];
                    
                    layoutData.sections.forEach((sec, index) => {
                        let fields = [];
                        
                        sec.layoutRows.forEach(row => {
                            row.layoutItems.forEach(item => {
                                item.layoutComponents.forEach(comp => {
                                    if (comp.apiName) {
                                        const apiName = comp.apiName;
                                        let isCustomLookup = false;
                                        let displayValue = '';
                                        let recordLink = '';
                                        let label = apiName;
                                        let isEmpty = true;
                                        
                                        if (objectInfo && objectInfo.fields[apiName]) {
                                            label = objectInfo.fields[apiName].label;
                                        }

                                        if (recordInfo && recordInfo.fields[apiName]) {
                                            const rawVal = recordInfo.fields[apiName].value;
                                            const dispVal = recordInfo.fields[apiName].displayValue;
                                            
                                            if (rawVal !== null && rawVal !== undefined && rawVal !== false && rawVal !== '' && rawVal !== 0) {
                                                isEmpty = false;
                                            }

                                            if (rawVal && typeof rawVal === 'string' && rawVal.startsWith('00') && rawVal.length >= 15 && dispVal) {
                                                isCustomLookup = true;
                                                displayValue = dispVal;
                                                recordLink = `/${rawVal}`;
                                            }
                                        }

                                        fields.push({
                                            name: apiName,
                                            label: label,
                                            isCustomLookup: isCustomLookup,
                                            displayValue: displayValue,
                                            recordLink: recordLink,
                                            isEmpty: isEmpty,
                                            cssClass: apiName.toLowerCase().includes('recordtype') ? 'tech-no-click' : ''
                                        });
                                    }
                                });
                            });
                        });
                        
                        const heading = sec.heading || `Sección ${index}`;
                        const headingLower = heading.toLowerCase();
                        
                        const isMasterbox = headingLower.includes('masterbox') || headingLower.includes('caja');
                        const isProduct = !isMasterbox && (headingLower.includes('dimension') || headingLower.includes('variante') || headingLower.includes('producto'));
                        const isCard = isMasterbox || isProduct;
                        
                        let icon = '';
                        if (isMasterbox) {
                            icon = '📦 ';
                        } else if (isProduct) {
                            icon = '🏷️ ';
                        }

                        // Función auxiliar para determinar si debemos mostrar la tarjeta
                        const createSectionObj = (id, label, secFields, isCardFlag, iconFlag, groupNum) => {
                            const isSectionEmpty = secFields.every(f => f.isEmpty);
                            let isDel = isCardFlag && isSectionEmpty;
                            if (groupNum === null) isDel = false; // NUNCA ocultar la base (los que no tienen número)
                            
                            return {
                                id: id,
                                label: label,
                                fields: secFields,
                                isCard: isCardFlag,
                                icon: iconFlag,
                                isDeleted: isDel
                            };
                        };

                        // LOGICA PARA DIVIDIR LAS CAJAS MASTERBOX Y PRODUCTOS
                        if (isCard && fields.length > 5) {
                            let groups = {};
                            let otherFields = [];
                            
                            fields.forEach(f => {
                                let match = f.label.match(/(?:Master\s*Box|Masterbox|Product|Producto)[\s_]*(\d+)/i) || f.name.match(/(?:Master\s*Box|Masterbox|Product|Producto)[\s_]*(\d+)/i);
                                if (match) {
                                    let num = match[1];
                                    if (!groups[num]) groups[num] = [];
                                    groups[num].push(f);
                                } else {
                                    otherFields.push(f);
                                }
                            });
                            
                            if (otherFields.length > 0) {
                                generatedSections.push(createSectionObj(`sec-${index}-others`, heading, otherFields, isCard, icon, null));
                            }
                            
                            Object.keys(groups).sort((a,b) => parseInt(a) - parseInt(b)).forEach(num => {
                                if (num === '1') return; // El grupo sin número actúa como el principal, omitimos el 1 para no duplicar
                                let cardLabel = isMasterbox ? `Master Box ${num}` : `Producto ${num}`;
                                generatedSections.push(createSectionObj(`sec-${index}-grp${num}`, cardLabel, groups[num], true, icon, num));
                            });
                        } else {
                            generatedSections.push(createSectionObj(`sec-${index}`, heading, fields, isCard, icon, null));
                        }
                    });
                    
                    this.allSections = generatedSections;
                    
                    // Filtrar las que están marcadas como eliminadas/vacías para que no se rendericen
                    this.sections = this.allSections.filter(s => !s.isDeleted);
                    this.activeSections = this.sections.map(s => s.id);
                    this.updateLastCardFlag();
                }
            }
        } else if (error) {
            console.error('Error fetching Layout via UI API', error);
        }
    }

    handleSubmit(event) {
        event.preventDefault();
        
        // Mutar directamente el objeto original de LWC para no perder propiedades internas
        const fields = event.detail.fields;
        
        // BUGFIX: LWC a veces no registra los lightning-input-field agregados dinámicamente al DOM.
        // Recolectamos manualmente los valores visibles y los inyectamos al objeto fields.
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields) {
            inputFields.forEach(field => {
                if (field.fieldName && field.value !== undefined) {
                    fields[field.fieldName] = field.value;
                }
            });
        }
        
        // Una tarjeta agregada debe tener al menos un valor, si no desaparece al recargar
        const emptyAdded = this.allSections.find(sec => sec.isAdded && !sec.isDeleted &&
            ![...this.template.querySelectorAll(`lightning-input-field[data-section-id="${sec.id}"]`)]
                .some(f => f.value !== null && f.value !== undefined && f.value !== '' && f.value !== false && f.value !== 0));
        if (emptyAdded) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Faltan datos',
                    message: `Completa al menos un campo en "${emptyAdded.label}" o elimínala antes de guardar.`,
                    variant: 'warning'
                })
            );
            return;
        }

        // Forzar nulo solo en las secciones que el usuario eliminó (no en las ocultas por estar vacías/en 0)
        if (this.allSections) {
            this.allSections.forEach(sec => {
                if (sec.isDeleted && sec.isCard && sec.userDeleted) {
                    sec.fields.forEach(f => {
                        fields[f.name] = null;
                    });
                }
            });
        }
        
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    updateLastCardFlag() {
        this.sections.forEach(s => {
            s.isLastProductCard = false;
            s.isLastMasterboxCard = false;
        });
        
        const visibleProducts = this.sections.filter(s => s.isCard && s.icon.includes('🏷️'));
        const visibleMasterboxes = this.sections.filter(s => s.isCard && s.icon.includes('📦'));
        
        if (visibleProducts.length > 0) {
            visibleProducts[visibleProducts.length - 1].isLastProductCard = true;
        }
        if (visibleMasterboxes.length > 0) {
            visibleMasterboxes[visibleMasterboxes.length - 1].isLastMasterboxCard = true;
        }
    }

    get hiddenProducts() {
        return this.allSections ? this.allSections.filter(s => s.isDeleted && s.icon.includes('🏷️')) : [];
    }
    
    get hiddenMasterboxes() {
        return this.allSections ? this.allSections.filter(s => s.isDeleted && s.icon.includes('📦')) : [];
    }

    get hasHiddenProducts() {
        return this.hiddenProducts.length > 0;
    }
    
    get hasHiddenMasterboxes() {
        return this.hiddenMasterboxes.length > 0;
    }

    handleAddSection(event) {
        const sectionId = event.detail.value;
        const sec = this.allSections.find(s => s.id === sectionId);
        if (sec) {
            sec.isDeleted = false;
            sec.userDeleted = false;
            sec.isAdded = true;
        }
        
        this.sections = this.allSections.filter(s => !s.isDeleted);
        this.updateLastCardFlag();
        
        if (!this.activeSections.includes(sectionId)) {
            this.activeSections = [...this.activeSections, sectionId];
        }
    }

    handleDeleteSection(event) {
        const sectionId = event.target.dataset.sectionId;
        
        const inputFields = this.template.querySelectorAll(`lightning-input-field[data-section-id="${sectionId}"]`);
        if (inputFields) {
            inputFields.forEach(field => {
                field.value = null;
            });
        }

        const sec = this.allSections.find(s => s.id === sectionId);
        if (sec) {
            sec.isDeleted = true;
            sec.userDeleted = true;
            sec.isAdded = false;
        }

        this.sections = this.allSections.filter(s => !s.isDeleted);
        this.updateLastCardFlag();
        
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Sección eliminada',
                message: 'Los campos se guardarán vacíos al presionar Guardar Cambios.',
                variant: 'info'
            })
        );
    }
}