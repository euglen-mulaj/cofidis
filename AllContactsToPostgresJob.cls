public class AllContactsToPostgresJob implements Database.AllowsCallouts, Database.Batchable<sObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        String query = 'select id,firstname,lastname,iban__c,email,page_block__c,data_richiesta_o__c,data_esito_ok_o__c,esito_scarto_o__c,cod_camp__c,dt_end__c,dt_end_eleg__c, flag_eleggibile_pp_preacc__c,flag_eleggibile_rev_preacc__c from contact';
        
        return Database.getQueryLocator(query);
        
        
    }
    
    public void execute(Database.BatchableContext BC, List<Contact> scope) {
   
        ContactService.allContactsToPostgres(scope);
        
        
    }
    
    
    public void finish(Database.BatchableContext BC){
        System.debug('### BATCH JOB FINISHED ### ');
    }
    
    
}