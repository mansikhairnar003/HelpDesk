public with sharing class ServiceRequestController {

        @AuraEnabled(cacheable=true)
    public static List<Service_Request__c> getAllRequests() {
        try {
            return [
                SELECT Id,
                       Name,
                       Subject__c,
                       Category__c,
                       Priority__c,
                       Status__c,
                       Request_Date__c,
                       SLA_Deadline__c
                FROM Service_Request__c
                ORDER BY Request_Date__c DESC
            ];
        } catch (Exception e) {
            throw new AuraHandledException(
                'Unable to load service requests: ' + e.getMessage()
            );
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getRequestCounts() {
        try {
            Map<String, Integer> counts = new Map<String, Integer>{
                'New' => 0,
                'Assigned' => 0,
                'In Progress' => 0,
                'Resolved' => 0
            };

            for (AggregateResult result : [
                SELECT Status__c status, COUNT(Id) total
                FROM Service_Request__c
                GROUP BY Status__c
            ]) {
                counts.put((String) result.get('status'), (Integer) result.get('total'));
            }
            return counts;
        } catch (Exception e) {
            throw new AuraHandledException('Unable to load request counts: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Integer> getPriorityCounts() {
        try {
            Map<String, Integer> counts = new Map<String, Integer>{
                'Critical' => 0,
                'High' => 0,
                'Medium' => 0,
                'Low' => 0
            };

            for (AggregateResult result : [
                SELECT Priority__c priority, COUNT(Id) total
                FROM Service_Request__c
                GROUP BY Priority__c
            ]) {
                counts.put((String) result.get('priority'), (Integer) result.get('total'));
            }
            return counts;
        } catch (Exception e) {
            throw new AuraHandledException('Unable to load priority counts: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Service_Request__c getRequestDetails(Id requestId) {
        return [
            SELECT Id, Name, Subject__c, Employee__r.Name, Category__c,
                   Priority__c, Status__c, SLA_Deadline__c, Description__c,
                   Resolution_Date__c, Resolution_Notes__c
            FROM Service_Request__c
            WHERE Id = :requestId
        ];
    }
    @AuraEnabled(cacheable=true)
    public static Integer getSLARiskCount() {
        return [
            SELECT COUNT()
            FROM Service_Request__c
            WHERE SLA_Breached__c = true
        ];
    }
    @AuraEnabled
    public static Id createServiceRequest(String subject, String description, String category, String priority) {
        Service_Request__c newRequest = new Service_Request__c(
            Subject__c = subject,
            Description__c = description,
            Category__c = category,
            Priority__c = priority
        );

        insert newRequest;
        return newRequest.Id;
    }
}