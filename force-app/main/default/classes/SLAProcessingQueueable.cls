public with sharing class SLAProcessingQueueable implements Queueable {

    private Set<Id> requestIds;

    public SLAProcessingQueueable(Set<Id> requestIds) {
        this.requestIds = requestIds;
    }

    public void execute(QueueableContext context) {

        List<Service_Request__c> requests = [
            SELECT Id, Name, Priority__c, Status__c,
                   SLA_Deadline__c
            FROM Service_Request__c
            WHERE Id IN :requestIds
        ];

        for (Service_Request__c request : requests) {

            System.debug(
                'SLA Queueable Processing → ' +
                request.Name +
                ' | Priority=' + request.Priority__c +
                ' | Status=' + request.Status__c +
                ' | SLA Deadline=' + request.SLA_Deadline__c
            );
        }
    }
}