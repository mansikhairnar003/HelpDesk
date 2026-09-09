public with sharing class AIAssistService {

    public class AIResponse {

        @AuraEnabled
        public String suggestedSubject;

        @AuraEnabled
        public String suggestedCategory;

        @AuraEnabled
        public String responseMessage;

        @AuraEnabled
        public Boolean success;
    }


    @AuraEnabled
    public static AIResponse getAISuggestion(String employeeIssue) {

        AIResponse result = new AIResponse();

        try {

            API_Key__mdt keyRecord = [
                SELECT Key_Value__c
                FROM API_Key__mdt
                WHERE DeveloperName = 'Groq_Key'
                LIMIT 1
            ];


            HttpRequest req = new HttpRequest();

            req.setEndpoint(
                'https://api.groq.com/openai/v1/chat/completions'
            );

            req.setMethod('POST');

            req.setHeader(
                'Content-Type',
                'application/json'
            );

            req.setHeader(
                'Authorization',
                'Bearer ' + keyRecord.Key_Value__c
            );

            req.setTimeout(15000);


            String promptText =
                'You are an IT helpdesk assistant. ' +
                'Analyze the following employee issue: "' +
                employeeIssue +
                '". ' +

                'Reply with ONLY a JSON object with exactly three keys: ' +

                '"subject" - a short professional subject of maximum 80 characters, ' +

                '"category" - exactly one of: Hardware, Software, Network, Access, Email, Other, ' +

                '"response" - a short 1-2 sentence helpful suggestion for the employee. ' +

                'Do not include markdown or any extra text.';


            Map<String, Object> bodyMap =
                new Map<String, Object>();

            bodyMap.put(
                'model',
                'openai/gpt-oss-20b'
            );


            List<Map<String, String>> messages =
                new List<Map<String, String>>();

            Map<String, String> messageObj =
                new Map<String, String>();

            messageObj.put(
                'role',
                'user'
            );

            messageObj.put(
                'content',
                promptText
            );

            messages.add(messageObj);


            bodyMap.put(
                'messages',
                messages
            );

            bodyMap.put(
                'temperature',
                0.3
            );


            req.setBody(
                JSON.serialize(bodyMap)
            );


            Http http = new Http();

            HttpResponse res = http.send(req);


            if (res.getStatusCode() == 200) {

                Map<String, Object> responseBody =
                    (Map<String, Object>)
                    JSON.deserializeUntyped(
                        res.getBody()
                    );


                List<Object> choices =
                    (List<Object>)
                    responseBody.get('choices');


                Map<String, Object> firstChoice =
                    (Map<String, Object>)
                    choices[0];


                Map<String, Object> message =
                    (Map<String, Object>)
                    firstChoice.get('message');


                String aiContent =
                    (String)
                    message.get('content');


                Map<String, Object> parsedContent =
                    (Map<String, Object>)
                    JSON.deserializeUntyped(
                        aiContent
                    );


                result.suggestedSubject =
                    (String)
                    parsedContent.get('subject');


                result.suggestedCategory =
                    (String)
                    parsedContent.get('category');


                result.responseMessage =
                    (String)
                    parsedContent.get('response');


                result.success = true;


            } else {

                result.success = false;

                result.responseMessage =
                    'AI service returned an error. Please create a request manually.';

                System.debug(
                    'AI Service HTTP Error: ' +
                    res.getStatusCode() +
                    ' - ' +
                    res.getBody()
                );
            }


        } catch (Exception e) {

            result.success = false;

            result.responseMessage =
                'Unable to reach AI assistant right now. Please create a request manually.';

            System.debug(
                'AI Service Error: ' +
                e.getMessage()
            );
        }


        return result;
    }
}