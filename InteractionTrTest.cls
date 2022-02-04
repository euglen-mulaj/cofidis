@isTest
private class InteractionTrTest {

    private static final String TEST_EMAIL = 'cofidididifi@fidi.com';
    private static Interaction__c  intr = new Interaction__c();
    private static Contact testCnt = new Contact();
    private static Account testAcn = new Account();
    

    static {
       
        
        testAcn.Name = 'Cofidis';
        insert testAcn;
        
        testCnt.LastName = 'test Last Name';
        testCnt.FirstName = 'Test first name';
        testCnt.EMAIL_O__c	= TEST_EMAIL;
        insert testCnt;

        intr.Contact__c = testCnt.Id;
        intr.EMAIL_O__c	= TEST_EMAIL;
        intr.Contact_Id__c = testCnt.Id;

        Field_Mapping__c fieldMapping = new Field_Mapping__c();
        fieldMapping.Destination_Field__c = 'EMAIL_O__c';
        fieldMapping.Category__c = 'Interaction Contact';
        fieldMapping.Destination_Object__c = 'Contact';
        fieldMapping.Source_Field__c = 'EMAIL_O__c';
        fieldMapping.Source_Object__c = 'Interaction__c';
        insert fieldMapping;
    }

    @isTest
    private static void testInteractionInsert() {
        Test.setMock(HttpCalloutMock.class, new PostgressUpdateContactsMock());
        Test.startTest();
            insert intr;
        Test.stopTest();

        List<Contact> resultCnt = [SELECT EMAIL_O__c FROM Contact WHERE Id = :testCnt.Id];

        System.assertEquals(TEST_EMAIL, resultCnt[0].EMAIL_O__c, 'We expect the contact email to be changed to email of interaction.');
    }
    
    @isTest
    private static void allContactsToPostgresTest(){
        
        List<Contact> resultCnt = [SELECT EMAIL_O__c FROM Contact WHERE Id = :testCnt.Id];
        test.startTest();
        test.setMock(HttpCalloutMock.class, new PostgressUpdateContactsMock());
        ContactService.allContactsToPostgres(resultCnt);
        test.stopTest();
    }
}