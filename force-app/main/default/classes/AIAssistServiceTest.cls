@IsTest
private class AIAssistServiceTest {

    private class GroqMockSuccess implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);

            String aiContent = '{"category": "Network", "response": "Please restart your VPN client and check your internet connection."}';

            Map<String, Object> messageObj = new Map<String, Object>();
            messageObj.put('content', aiContent);

            Map<String, Object> choiceObj = new Map<String, Object>();
            choiceObj.put('message', messageObj);

            Map<String, Object> responseBody = new Map<String, Object>();
            responseBody.put('choices', new List<Object>{ choiceObj });

            res.setBody(JSON.serialize(responseBody));
            return res;
        }
    }

    private class GroqMockFailure implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(500);
            res.setBody('{"error": "Internal Server Error"}');
            return res;
        }
    }

    @IsTest
    static void testGetAISuggestion_Success() {
        Test.setMock(HttpCalloutMock.class, new GroqMockSuccess());

        Test.startTest();
        AIAssistService.AIResponse result = AIAssistService.getAISuggestion('My VPN is not working');
        Test.stopTest();

        System.assertEquals(true, result.success, 'Should succeed with valid mock response.');
        System.assertEquals('Network', result.suggestedCategory, 'Category should match mock response.');
        System.assertNotEquals(null, result.responseMessage, 'Response message should not be null.');
    }

    @IsTest
    static void testGetAISuggestion_Failure() {
        Test.setMock(HttpCalloutMock.class, new GroqMockFailure());

        Test.startTest();
        AIAssistService.AIResponse result = AIAssistService.getAISuggestion('My VPN is not working');
        Test.stopTest();

        System.assertEquals(false, result.success, 'Should fail gracefully on server error.');
        System.assertEquals(
            'AI service returned an error. Please create a request manually.',
            result.responseMessage,
            'Should return graceful fallback message.'
        );
    }
}