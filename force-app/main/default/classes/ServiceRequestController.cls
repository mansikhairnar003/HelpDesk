public with sharing class ServiceRequestController {

    @AuraEnabled(cacheable=true)
    public static List<Service_Request__c> getOpenRequests() {
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
                WHERE Status__c != 'Resolved'
                ORDER BY Request_Date__c DESC
            ];
        } catch (Exception e) {
            throw new AuraHandledException(
                'Unable to load open service requests: ' + e.getMessage()
            );
        }
    }

    @AuraEnabled(cacheable=true)
public static Map<String, Integer> getRequestCounts() {
    try {
        Map<String, Integer> counts = new Map<String, Integer>();
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
        Map<String, Integer> counts = new Map<String, Integer>();
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
    public static Map<String, Integer> getDashboardSummary() {
        try {
            Map<String, Integer> summary = new Map<String, Integer>{
                'openRequests' => 0,
                'criticalRequests' => 0,
                'resolvedCount' => 0,
                'slaRisk' => 0
            };

            summary.put(
                'openRequests',
                [
                    SELECT COUNT()
                    FROM Service_Request__c
                    WHERE Status__c != 'Resolved'
                ]
            );

            summary.put(
                'criticalRequests',
                [
                    SELECT COUNT()
                    FROM Service_Request__c
                    WHERE Priority__c = 'Critical'
                ]
            );

            summary.put(
                'resolvedCount',
                [
                    SELECT COUNT()
                    FROM Service_Request__c
                    WHERE Status__c = 'Resolved'
                ]
            );

            summary.put(
                'slaRisk',
                [
                    SELECT COUNT()
                    FROM Service_Request__c
                    WHERE Status__c != 'Resolved'
                    AND SLA_Deadline__c < :System.now()
                ]
            );

            return summary;

        } catch (Exception e) {
            throw new AuraHandledException(
                'Unable to load dashboard summary: ' + e.getMessage()
            );
        }
    }
} 
