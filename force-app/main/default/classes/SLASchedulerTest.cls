@IsTest
private class SLASchedulerTest {

    @IsTest
    static void testSchedulerExecution() {

        Test.startTest();

        String cronExpression = '0 0 0 1 1 ? 2099';

        String jobId = System.schedule(
            'HelpDesk SLA Scheduler Test',
            cronExpression,
            new SLAScheduler()
        );

        Test.stopTest();

        CronTrigger scheduledJob = [
            SELECT Id,
                   CronJobDetail.Name,
                   State,
                   TimesTriggered
            FROM CronTrigger
            WHERE Id = :jobId
        ];

        System.assertEquals(
            'HelpDesk SLA Scheduler Test',
            scheduledJob.CronJobDetail.Name,
            'The scheduler should be created with the expected name.'
        );

        System.assertNotEquals(
            null,
            scheduledJob.Id,
            'A scheduled job ID should be created.'
        );
    }
}