trigger ServiceRequestTrigger on Service_Request__c (
    before insert,
    before update
) {
    ServiceRequestTriggerHandler.handleBefore(
        Trigger.new,
        Trigger.oldMap
    );
}