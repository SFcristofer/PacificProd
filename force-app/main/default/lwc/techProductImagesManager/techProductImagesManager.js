import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveImages from '@salesforce/apex/TechProductImagesController.saveImages';
import saveSingleImage from '@salesforce/apex/TechProductImagesController.saveSingleImage';
import getFolderThumbnails from '@salesforce/apex/TechOneDriveService.getFolderThumbnails';

const FIELDS = [
    'Product2.Tech_Enlace_OneDrive__c',
    'Product2.Imagen1__c',
    'Product2.Imagen2__c',
    'Product2.Imagen3__c',
    'Product2.Imagen4__c'
];

export default class TechProductImagesManager extends LightningElement {
    @api recordId;
    @api hideSaveButton = false;

    @track onedriveLink = '';
    @track image1Preview = null;
    @track image2Preview = null;
    @track image3Preview = null;
    @track image4Preview = null;
    @track onedriveThumbnails = [];
    @track isLoadingThumbnails = false;
    @track isEditMode = false;
    isLinkLocked = false;
    
    // Store files to upload
    filesToUpload = { 1: null, 2: null, 3: null, 4: null };
    
    isSaving = false;

    extractImageSrc(htmlString) {
        if (!htmlString) return null;
        // Las fórmulas de Imagen en Salesforce devuelven un string HTML: <img src="URL" ...>
        // Si ya es una URL base64 o ruta limpia (por si acaso), se devuelve tal cual
        if (htmlString.startsWith('data:') || htmlString.startsWith('/')) {
            return htmlString;
        }
        const match = htmlString.match(/src\s*=\s*["']([^"']+)["']/i);
        return match ? match[1] : null;
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            const currentLink = data.fields.Tech_Enlace_OneDrive__c?.value || '';
            if (this.onedriveLink !== currentLink) {
                this.onedriveLink = currentLink;
                if (this.onedriveLink) {
                    this.isLinkLocked = true;
                    this.loadThumbnails();
                } else {
                    this.isLinkLocked = false;
                }
            }
            // Parseamos el HTML devuelto por la fórmula para extraer solo el enlace real de la imagen
            this.image1Preview = this.extractImageSrc(data.fields.Imagen1__c?.value) || null;
            this.image2Preview = this.extractImageSrc(data.fields.Imagen2__c?.value) || null;
            this.image3Preview = this.extractImageSrc(data.fields.Imagen3__c?.value) || null;
            this.image4Preview = this.extractImageSrc(data.fields.Imagen4__c?.value) || null;
        }
    }

    handleLinkChange(event) {
        this.onedriveLink = event.target.value;
        this.loadThumbnails();
    }

    unlockLink() {
        this.isLinkLocked = false;
    }

    toggleEditMode() {
        this.isEditMode = !this.isEditMode;
        // Si cancela edición, podríamos recargar los datos originales, 
        // pero por ahora solo ocultamos los controles.
    }

    loadThumbnails() {
        if (!this.onedriveLink) {
            this.onedriveThumbnails = [];
            return;
        }
        this.isLoadingThumbnails = true;
        getFolderThumbnails({ sharedLink: this.onedriveLink })
            .then(result => {
                this.onedriveThumbnails = result || [];
            })
            .catch(error => {
                console.error('Error fetching OneDrive thumbnails', error);
                this.onedriveThumbnails = [];
            })
            .finally(() => {
                this.isLoadingThumbnails = false;
            });
    }

    handleFileChange(event) {
        const index = event.target.dataset.index;
        const file = event.target.files[0];
        if (!file) return;

        // Preview in UI immediately
        const reader = new FileReader();
        reader.onload = (e) => {
            this[`image${index}Preview`] = e.target.result;
        };
        reader.readAsDataURL(file);

        // Store file for later processing
        this.filesToUpload[index] = file;
    }

    @api
    async saveImagesForRecord(newRecordId) {
        if (newRecordId) {
            this.recordId = newRecordId;
        }
        await this.handleSave(true);
    }

    async handleSave(hideToast = false) {
        this.isSaving = true;
        try {
            // 1. Guardar primero solo el enlace OneDrive (llamando a la función original, pero sin pasar imágenes)
            await saveImages({
                recordId: this.recordId,
                onedriveLink: this.onedriveLink,
                img1: null,
                img2: null,
                img3: null,
                img4: null
            });

            // 2. Procesar y guardar imágenes de una en una de manera secuencial
            for (let i = 1; i <= 4; i++) {
                const file = this.filesToUpload[i];
                if (file) {
                    const inputsForIndex = this.template.querySelectorAll(`lightning-input[data-index="${i}"]`);
                    let checkbox = null;
                    inputsForIndex.forEach(inp => { if (inp.type === 'checkbox') checkbox = inp; });
                    const shouldResize = checkbox ? checkbox.checked : false;

                    let finalImage;
                    if (shouldResize) {
                        // Intentamos procesarla buscando que no exceda 490,000 bytes (~490KB, límite es 500KB)
                        // empezando con 2048px y 90% de calidad.
                        finalImage = await this.resizeImageToFitLimit(file, 2048, 0.9, 490000);
                    } else {
                        finalImage = await this.fileToBase64(file);
                    }
                    
                    // Llamada al backend para procesar una sola imagen, creando el Document y el enlace AWS
                    await saveSingleImage({
                        recordId: this.recordId,
                        imageIndex: i,
                        base64Data: finalImage
                    });
                }
            }

            if (hideToast !== true) {
                this.showToast('Éxito', 'Imágenes y enlace guardados correctamente', 'success');
            }
            // Clear file buffer (keep previews)
            this.filesToUpload = { 1: null, 2: null, 3: null, 4: null };
            // Volver a modo lectura
            this.isEditMode = false;
            
        } catch (error) {
            this.showToast('Error', error.body?.message || error.message, 'error');
            // Ya no re-lanzamos el error con "throw error" para evitar el "Uncaught (in promise)"
            // a menos que sea invocado silenciosamente por el Wizard
            if (hideToast === true) {
                throw error;
            }
        } finally {
            this.isSaving = false;
        }
    }

    fileToBase64(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => resolve(reader.result);
            reader.onerror = error => reject(error);
            reader.readAsDataURL(file);
        });
    }

    async resizeImageToFitLimit(file, initialMaxDimension, initialQuality, maxBytes) {
        let quality = initialQuality;
        let dimension = initialMaxDimension;
        
        while (dimension >= 400) {
            let base64 = await this.resizeImage(file, dimension, quality);
            
            // Calcular el peso real en bytes a partir del base64
            let base64Data = base64.includes(',') ? base64.split(',')[1] : base64;
            let sizeInBytes = Math.floor(base64Data.length * 0.75);
            if (base64Data.endsWith('==')) sizeInBytes -= 2;
            else if (base64Data.endsWith('=')) sizeInBytes -= 1;
            
            if (sizeInBytes <= maxBytes) {
                return base64;
            }
            
            // Si supera el límite, reducimos primero un poco la calidad
            if (quality > 0.7) {
                quality -= 0.1;
            } else {
                // Si la calidad ya bajó a 0.7, reducimos el tamaño y restauramos calidad
                dimension = Math.floor(dimension * 0.8);
                quality = 0.9;
            }
        }
        // Retorno seguro si llega a un tamaño mínimo
        return await this.resizeImage(file, 400, 0.7);
    }

    resizeImage(file, maxDimension, quality) {
        return new Promise((resolve, reject) => {
            const img = new Image();
            img.onload = () => {
                let width = img.width;
                let height = img.height;

                if (width > maxDimension || height > maxDimension) {
                    if (width > height) {
                        height = Math.round((height *= maxDimension / width));
                        width = maxDimension;
                    } else {
                        width = Math.round((width *= maxDimension / height));
                        height = maxDimension;
                    }
                }

                const canvas = document.createElement('canvas');
                canvas.width = width;
                canvas.height = height;

                const ctx = canvas.getContext('2d');
                ctx.drawImage(img, 0, 0, width, height);

                resolve(canvas.toDataURL('image/jpeg', quality));
            };
            img.onerror = (e) => reject(e);
            
            const reader = new FileReader();
            reader.onload = (e) => {
                img.src = e.target.result;
            };
            reader.readAsDataURL(file);
        });
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({
            title, message, variant
        }));
    }
}