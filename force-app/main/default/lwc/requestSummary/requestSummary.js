import { LightningElement, api } from 'lwc';

export default class RequestSummary extends LightningElement {
    @api openCount = 0;
    @api criticalCount = 0;
    @api resolvedCount = 0;
    @api slaRisk = 0;
}