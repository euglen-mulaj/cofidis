@isTest
public class AllContactsToPostgresJob_Test {

    public class MockResponse implements HttpCalloutMock {
        private Integer m_responseIndex;
        private String m_reponses;
        public MockResponse(String reponses,Integer code) {
            m_responseIndex = code;
            m_reponses = reponses;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            String reponse = m_reponses;
            res.setBody(reponse);
            res.setStatusCode(m_responseIndex);
            return res;
        }
    }
    
    @isTest
    public static void testing(){
        
        
        test.startTest();
        List<Contact> mylist = new List<Contact>();
        string jsonBody = JSON.serialize(mylist);
        
        Test.setMock(HttpCalloutMock.class, new MockResponse(jsonBody,201));        

        Database.BatchableContext BC;
        AllContactsToPostgresJob toPostGres = new AllContactsToPostgresJob();
        toPostGres.start(BC);
        List<Contact> cons = new List<Contact>();
        toPostGres.execute(BC, cons);
        toPostGres.finish(BC);
        
        
        test.stopTest();
    }
    
}