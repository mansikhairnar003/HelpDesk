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
            SLA_Deadline__c = System.now().addHours(-1)
        );

        insert request;

        // Force correct values after insert (Flow may override Status__c on insert)
        request.Status__c = 'In Progress';
        request.SLA_Deadline__c = System.now().addHours(-1);
        update request;

        Test.startTest();

        Id batchJobId = Database.executeBatch(
            new SLARequestBatch(),
            50
        );

        Test.stopTest();

        AsyncApexJob job = [
            SELECT Id, Status, JobType, NumberOfErrors
            FROM AsyncApexJob
            WHERE Id = :batchJobId
        ];

        System.assertEquals('Completed', job.Status, 'Batch should complete successfully.');
        System.assertEquals(0, job.NumberOfErrors, 'Batch should complete without errors.');

        Service_Request__c updated = [
            SELECT Status__c, SLA_Breached__c
            FROM Service_Request__c
            WHERE Id = :request.Id
        ];

        System.assertEquals(
            true,
            updated.SLA_Breached__c,
            'SLA_Breached__c should be true when deadline has passed.'
        );

        System.assertEquals(
            'In Progress',
            updated.Status__c,
            'Status should remain unchanged when SLA breaches.'
        );
    }
}