public with sharing class SLARequestBatch
    implements Database.Batchable<SObject> {

    public Database.QueryLocator start(
        Database.BatchableContext context
    ) {
        return Database.getQueryLocator([
            SELECT Id, Name, Priority__c, Status__c,
                   SLA_Deadline__c
            FROM Service_Request__c
            WHERE Status__c NOT IN ('Resolved', 'Closed')
            AND SLA_Deadline__c != null
        ]);
    }

    public void execute(
        Database.BatchableContext context,
        List<Service_Request__c> requests
    ) {
        for (Service_Request__c request : requests) {

            if (request.SLA_Deadline__c <= System.now()) {

                System.debug(
                    'SLA BREACHED → ' +
                    request.Name +
                    ' | Priority=' + request.Priority__c +
                    ' | Deadline=' + request.SLA_Deadline__c
                );
            }
        }
    }

    public void finish(
        Database.BatchableContext context
    ) {
        System.debug('SLA monitoring batch completed.');
    }
}