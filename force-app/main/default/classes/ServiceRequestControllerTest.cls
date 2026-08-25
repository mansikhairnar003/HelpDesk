@IsTest
private class ServiceRequestControllerTest {

    @TestSetup
    static void createTestData() {

        Employee__c employee = new Employee__c(
            Name = 'Test Employee'
        );
        insert employee;

        Service_Request__c request1 = new Service_Request__c(
            Subject__c = 'Test New Request',
            Employee__c = employee.Id,
            Category__c = 'Hardware',
            Priority__c = 'High',
            Status__c = 'New',
            Request_Date__c = System.now()
        );

        Service_Request__c request2 = new Service_Request__c(
            Subject__c = 'Test Resolved Request',
            Employee__c = employee.Id,
            Category__c = 'Network',
            Priority__c = 'Critical',
            Status__c = 'Resolved',
            Description__c = 'Test critical request description',
            Request_Date__c = System.now()
        );

        insert new List<Service_Request__c>{request1, request2};
    }

    @IsTest
    static void testGetOpenRequests() {

    Test.startTest();

    List<Service_Request__c> requests =
        ServiceRequestController.getOpenRequests();

    Test.stopTest();

    System.assertNotEquals(null, requests);

    for (Service_Request__c request : requests) {
        System.assertNotEquals('Resolved', request.Status__c);
    }
}

    @IsTest
    static void testGetRequestCounts() {

    Test.startTest();

    Map<String, Integer> counts =
        ServiceRequestController.getRequestCounts();

    Test.stopTest();

    System.assertNotEquals(null, counts);

    System.assert(counts.containsKey('New'));
    System.assert(counts.containsKey('Assigned'));
    System.assert(counts.containsKey('In Progress'));
    System.assert(counts.containsKey('Resolved'));

    System.assert(counts.get('New') >= 0);
    System.assert(counts.get('Assigned') >= 0);
    System.assert(counts.get('In Progress') >= 0);
    System.assert(counts.get('Resolved') >= 0);
}

    @IsTest
    static void testGetPriorityCounts() {

        Test.startTest();

        Map<String, Integer> counts =
            ServiceRequestController.getPriorityCounts();

        Test.stopTest();

        System.assertEquals(1, counts.get('High'));
        System.assertEquals(1, counts.get('Critical'));
        System.assertEquals(0, counts.get('Medium'));
        System.assertEquals(0, counts.get('Low'));
    }
}