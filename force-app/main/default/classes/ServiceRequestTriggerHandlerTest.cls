@IsTest
private class ServiceRequestTriggerHandlerTest {

    @IsTest
    static void testBulkPriorityAssignment() {

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

        for (Service_Request__c request : insertedRequests) {

            if (request.Category__c == 'Hardware') {

                System.assertEquals(
                    'High',
                    request.Priority__c,
                    'Hardware requests should receive High priority when Priority is blank.'
                );

            } else if (request.Category__c == 'Software') {

                System.assertEquals(
                    'Medium',
                    request.Priority__c,
                    'Software requests should receive Medium priority when Priority is blank.'
                );
            }
        }
    }
    @IsTest
    static void testUserSelectedPriorityIsNotOverwritten() {

    Service_Request__c request = new Service_Request__c(
        Subject__c = 'Priority Override Test',
        Description__c = 'Testing user selected priority',
        Category__c = 'Hardware',
        Priority__c = 'Critical',
        Status__c = 'New',
        Request_Date__c = System.now()
    );

    Test.startTest();

    insert request;

    System.assertEquals(
        'Critical',
        request.Priority__c,
        'User-selected Critical priority should not be overwritten by category default.'
    );

    request.Priority__c = 'Low';
    update request;

    Test.stopTest();

    Service_Request__c savedRequest = [
        SELECT Id, Category__c, Priority__c
        FROM Service_Request__c
        WHERE Id = :request.Id
    ];

    System.assertEquals(
        'Low',
        savedRequest.Priority__c,
        'User-selected Low priority should remain Low after update.'
    );
}
}
