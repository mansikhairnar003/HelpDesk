public with sharing class SLARequestBatch
    implements Database.Batchable<SObject> {

    public Database.QueryLocator start(
        Database.BatchableContext context
    ) {
        return Database.getQueryLocator([
            SELECT Id, Name, Priority__c, Status__c,
                   SLA_Deadline__c, SLA_Breached__c
            FROM Service_Request__c
            WHERE Status__c NOT IN ('Resolved', 'Closed')
        ]);
    }

    public void execute(
        Database.BatchableContext context,
        List<Service_Request__c> requests
    ) {
        List<Service_Request__c> toUpdate = new List<Service_Request__c>();

        for (Service_Request__c request : requests) {

            Boolean shouldBeBreached = request.SLA_Deadline__c != null
                && request.SLA_Deadline__c <= System.now();

            if (request.SLA_Breached__c != shouldBeBreached) {
                request.SLA_Breached__c = shouldBeBreached;
                toUpdate.add(request);
            }
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    public void finish(
        Database.BatchableContext context
    ) {
        System.debug('SLA monitoring batch completed.');
    }
}