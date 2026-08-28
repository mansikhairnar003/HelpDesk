@IsTest
private class ServiceRequestTriggerHandlerTest {

    @IsTest
    static void testBulkPriorityAssignment() {

        // Create test service categories
        List<Service_Category__c> categories = new List<Service_Category__c>{
            new Service_Category__c(
                Name = 'Hardware',
                Default_Priority__c = 'High'
            ),
            new Service_Category__c(
                Name = 'Software',
                Default_Priority__c = 'Medium'
            )
        };

        insert categories;

        // Create 200 Service Requests
        List<Service_Request__c> requests =
            new List<Service_Request__c>();

        for (Integer i = 0; i < 200; i++) {

            String category =
                (Math.mod(i, 2) == 0)
                ? 'Hardware'
                : 'Software';

            requests.add(
                new Service_Request__c(
                    Subject__c = 'Bulk Test Request ' + i,
                    Description__c = 'Bulk test request',
                    Category__c = category,
                    Status__c = 'New',
                    Request_Date__c = System.now()
                )
            );
        }

        Test.startTest();

        insert requests;

        Test.stopTest();

        // Verify all 200 records were processed
        List<Service_Request__c> insertedRequests = [
            SELECT Id, Category__c, Priority__c
            FROM Service_Request__c
            WHERE Subject__c LIKE 'Bulk Test Request%'
        ];

        System.assertEquals(
            200,
            insertedRequests.size(),
            'Expected all 200 Service Requests to be inserted.'
        );

        // Verify priority assignment
        for (Service_Request__c request : insertedRequests) {

            if (request.Category__c == 'Hardware') {

                System.assertEquals(
                    'High',
                    request.Priority__c,
                    'Hardware requests should receive High priority.'
                );

            } else if (request.Category__c == 'Software') {

                System.assertEquals(
                    'Medium',
                    request.Priority__c,
                    'Software requests should receive Medium priority.'
                );
            }
        }
    }
}