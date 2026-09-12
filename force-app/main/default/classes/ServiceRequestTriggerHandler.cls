public with sharing class ServiceRequestTriggerHandler {

    public static void handleBefore(
        List<Service_Request__c> newRequests,
        Map<Id, Service_Request__c> oldMap
    ) {
        Set<String> categoryNames = new Set<String>();

        for (Service_Request__c request : newRequests) {
            if (request.Category__c != null &&
                request.Priority__c == null) {

                categoryNames.add(request.Category__c);
            }
        }

        if (categoryNames.isEmpty()) {
            return;
        }

        Map<String, Service_Category__c> categoryByName =
            new Map<String, Service_Category__c>();

        for (Service_Category__c cat : [
            SELECT Name, Default_Priority__c
            FROM Service_Category__c
            WHERE Name IN :categoryNames
        ]) {
            categoryByName.put(cat.Name, cat);
        }

        for (Service_Request__c request : newRequests) {

            if (request.Category__c != null &&
                request.Priority__c == null &&
                categoryByName.containsKey(request.Category__c)) {

                Service_Category__c cat =
                    categoryByName.get(request.Category__c);

                if (cat.Default_Priority__c != null) {
                    request.Priority__c = cat.Default_Priority__c;
                }
            }
        }
    }
}