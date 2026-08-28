global with sharing class SLAScheduler implements Schedulable {

    global void execute(SchedulableContext context) {

        Database.executeBatch(
            new SLARequestBatch(),
            50
        );

    }
}