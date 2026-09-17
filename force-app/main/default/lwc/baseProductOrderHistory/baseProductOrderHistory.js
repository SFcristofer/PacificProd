import { LightningElement, api, wire, track } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import getOrderHistory from '@salesforce/apex/BaseProductOrderHistoryController.getOrderHistory';
import RT_NAME_FIELD from '@salesforce/schema/Product2.RecordType.DeveloperName';

const COLUMNS = [
    { label: 'Order Name', fieldName: 'orderUrl', type: 'url', typeAttributes: { label: { fieldName: 'orderName' }, target: '_blank' } },
    { label: 'Factory Product', fieldName: 'productUrl', type: 'url', typeAttributes: { label: { fieldName: 'productName' }, target: '_blank' } },
    { label: 'Factory', fieldName: 'factoryName', type: 'text' },
    { label: 'Quantity', fieldName: 'quantity', type: 'number' },
    { label: 'Unit Price', fieldName: 'unitPrice', type: 'currency' }
];

export default class BaseProductOrderHistory extends LightningElement {
    @api recordId;
    columns = COLUMNS;
    @track orders = [];
    hasOrders = false;
    isBaseProduct = false;
    totalQuantity = 0;
    totalRevenue = 0;

    summaryColumns = [
        { label: 'Factory', fieldName: 'factoryName', type: 'text' },
        { label: 'Total Units', fieldName: 'totalQuantity', type: 'number' },
        { label: 'Total Revenue', fieldName: 'totalRevenue', type: 'currency' }
    ];
    @track factorySummaries = [];

    @wire(getRecord, { recordId: '$recordId', fields: [RT_NAME_FIELD] })
    wiredRecord({ error, data }) {
        if (data) {
            const rtName = getFieldValue(data, RT_NAME_FIELD);
            this.isBaseProduct = (rtName === 'Producto');
            if (this.isBaseProduct) {
                this.fetchOrders();
            }
        } else if (error) {
            console.error('Error fetching record type:', error);
        }
    }

    fetchOrders() {
        getOrderHistory({ baseProductId: this.recordId })
            .then(result => {
                let tQty = 0;
                let tRev = 0;
                let factoryMap = {};

                this.orders = result.map(item => {
                    let q = item.Unidades__c ? item.Unidades__c : 0;
                    let r = (item.Unidades__c && item.PrecioDeVenta__c) ? (item.Unidades__c * item.PrecioDeVenta__c) : 0;
                    let fname = item.Producto__r && item.Producto__r.Fabrica__r ? item.Producto__r.Fabrica__r.Name : 'Unknown Factory';

                    tQty += q;
                    tRev += r;

                    if(!factoryMap[fname]) {
                        factoryMap[fname] = { id: fname, factoryName: fname, totalQuantity: 0, totalRevenue: 0 };
                    }
                    factoryMap[fname].totalQuantity += q;
                    factoryMap[fname].totalRevenue += r;

                    return {
                        Id: item.Id,
                        orderUrl: item.PedidoDeCompra__c ? `/${item.PedidoDeCompra__c}` : '',
                        orderName: item.PedidoDeCompra__r ? item.PedidoDeCompra__r.Name : 'Order',
                        productUrl: item.Producto__c ? `/${item.Producto__c}` : '',
                        productName: item.Producto__r ? item.Producto__r.Name : '',
                        factoryName: fname,
                        quantity: q,
                        unitPrice: item.PrecioDeVenta__c
                    };
                });
                this.totalQuantity = tQty;
                this.totalRevenue = tRev;
                this.factorySummaries = Object.values(factoryMap);
                this.hasOrders = this.orders.length > 0;
            })
            .catch(error => {
                console.error('Error fetching orders:', error);
            });
    }

    get cardTitle() {
        return `Factory Order History (${this.orders.length})`;
    }
}
