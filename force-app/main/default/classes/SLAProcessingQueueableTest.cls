@IsTest
private class SLAProcessingQueueableTest {

    @IsTest
    static void testQueueableExecution() {

        Service_Request__c request = new Service_Request__c(
            Subject__c = 'Queueable SLA Test',
            Description__c = 'Testing SLA Queueable processing',
            Category__c = 'Hardware',
            Priority__c = 'High',
            Status__c = 'New',
            Request_Date__c = System.now(),
            SLA_Deadline__c = System.now().addHours(2)
        );

        insert request;

        Set<Id> requestIds = new Set<Id>{ request.Id };

        Test.startTest();

        Id jobId = System.enqueueJob(
            new SLAProcessingQueueable(requestIds)
        );

        Test.stopTest();

        System.assertNotEquals(
            null,
            jobId,
            'Queueable job should return a Job ID.'
        );

        AsyncApexJob job = [
            SELECT Id, Status, NumberOfErrors
            FROM AsyncApexJob
            WHERE Id = :jobId
        ];

        System.assertEquals(
            'Completed',
            job.Status,
            'Queueable job should complete successfully.'
        );

        System.assertEquals(
            0,
            job.NumberOfErrors,
            'Queueable job should complete without errors.'
        );
    }
}