@IsTest
private class SLARequestBatchTest {

    @IsTest
    static void testBatchExecution() {

        Service_Request__c request = new Service_Request__c(
            Subject__c = 'Batch SLA Test',
            Description__c = 'Testing SLA Batch processing',
            Category__c = 'Hardware',
            Priority__c = 'Critical',
            Status__c = 'In Progress',
            Request_Date__c = System.now(),
            SLA_Deadline__c = System.now().addHours(1)
        );

        insert request;

        Test.startTest();

        Id batchJobId = Database.executeBatch(
            new SLARequestBatch(),
            50
        );

        Test.stopTest();

        AsyncApexJob job = [
            SELECT Id,
                   Status,
                   JobType,
                   NumberOfErrors,
                   JobItemsProcessed,
                   TotalJobItems
            FROM AsyncApexJob
            WHERE Id = :batchJobId
        ];

        System.assertEquals(
            'Completed',
            job.Status,
            'Batch should complete successfully.'
        );

        System.assertEquals(
            'BatchApex',
            job.JobType,
            'Job type should be BatchApex.'
        );

        System.assertEquals(
            0,
            job.NumberOfErrors,
            'Batch should complete without errors.'
        );
    }
}