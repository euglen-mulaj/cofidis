public with sharing class ContactService {
    
    public static void syncContactToInteraction(List<Interaction__c> newInteractions) {
        system.debug('calling syncContactToInteraction');
        List<Field_Mapping__c> fieldMapping = [SELECT Category__c, Destination_Field__c, Destination_Object__c, Source_Field__c, Source_Object__c, Value__c FROM Field_Mapping__c WHERE Category__c = 'Interaction Contact'];
        List<Contact> contactsToUpdate = new List<Contact>();
        Map<Id, Interaction__c> mappedInteractionToCnt = new Map<Id, Interaction__c>();
        for(Interaction__c interaction: newInteractions) {
        //    system.debug('ContactService : '+interaction.Contact_Id__c);
            if(interaction.Contact_Id__c != null){
                Contact cnt = new Contact(Id=interaction.Contact_Id__c);
                mappedInteractionToCnt.put(interaction.Contact_Id__c, interaction);
                system.debug('All interation data : '+interaction);
                for(Field_Mapping__c fldmap : fieldMapping) {
                  //  system.debug('interaction.get(fldmap.Source_Field__c) '+interaction.get(fldmap.Source_Field__c));
                    if(interaction.get(fldmap.Source_Field__c) != null){ 
                        cnt.put(fldmap.Destination_Field__c, interaction.get(fldmap.Source_Field__c));
                    }
                }
                
                contactsToUpdate.add(cnt);
               // update contactsToUpdate;
            }
        }
       List<Database.SaveResult> updateResultsCnt = new List<Database.SaveResult>();
        try {
            updateResultsCnt = Database.update(contactsToUpdate, false);
        } catch(Exception exc) {
            System.debug('contact update failed ' + exc.getMessage());
        }

        List<Id> interactionToDelte = new List<Id>();
        List<Id> failedInteractions = new List<Id>();
    /*    system.debug('Size of updateResultsCnt:'+updateResultsCnt);
        for(Integer i=0; i<updateResultsCnt.size(); i++) {
            if(updateResultsCnt.get(i).isSuccess()) {
                system.debug('Update passed');
                interactionToDelte.add(mappedInteractionToCnt.get(updateResultsCnt.get(i).getId()).Id);
            } else {
                //Create an workflow to send email to admin
                system.debug('Error occured : '+updateResultsCnt.get(i).getErrors());
                Interaction__c failedInteraction = mappedInteractionToCnt.get(updateResultsCnt.get(i).getId());
                failedInteractions.add(failedInteraction.Id);
            }
        }
   //     proceedDMLWithInteraction(interactionToDelte, failedInteractions);*/
    }

    //Future annotation to mark the method as async.
    @Future(callout=true)
    public static void sendContactsToPostgress(String newContacts) {
        system.debug('calling sendContactsToPostgress');
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:HerokuConnection');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(newContacts);
        request.setTimeout(2000);
        HttpResponse response = http.send(request);
        // Parse the JSON response
         if (response.getStatusCode() != 201 && response.getStatusCode() != 200) {
			System.debug('Callout failed: ' + response.getStatusCode() + ' ' + response.getStatus());
			 System.debug(response.getBody());
        } else {
			System.debug('Accounts updated succesfullly on postgress');
            System.debug(response.getBody());
        }
        
    }
    
    public static void allContactsToPostgres(List<Contact> newContacts){
       
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:HerokuAllContact');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(JSON.serialize(newContacts));
        request.setTimeout(2000);
        HttpResponse response = http.send(request);
        
        
        
        system.debug('RESPONSE: '+response);
        system.debug('BODY: '+response.getBody());
    }

    @future
    private static void proceedDMLWithInteraction(List<Id> interactionToDelte, List<Id> failedInteractions) {
        system.debug('calling proceedDMLWithInteraction');
        List<Interaction__c> intrToUpdate = [SELECT Id,Is_Failed__c FROM Interaction__c WHERE Id IN :failedInteractions];
        for(Interaction__c interact : intrToUpdate) {
            interact.Is_Failed__c = true;
        }

        List<Interaction__c> intrToDelete = [SELECT Id FROM Interaction__c WHERE Id IN :interactionToDelte];
        try {
            delete intrToDelete;
            update intrToUpdate;
        } catch(Exception excp) {
            System.debug('Could not delete interaction ' + excp.getMessage());
        }
    }
    
     public static void ActionBeforeInsert(List<Contact> newContacts) {
     // List<string> AccountDefault = new List<string>();
     System.debug('ContactService - ActionBeforeInsert');
     System.debug(newContacts);
     account AccountDefault = [SELECT Id FROM Account WHERE Name ='Cofidis'];    
     
     System.debug('AccountDefault - ActionBeforeInsert');
     System.debug(AccountDefault);
     string sAccountId  = AccountDefault.Id;
     if(sAccountId <> null) 
        
        for (Contact newContact : newContacts) {
            newContact.AccountId = sAccountId;
        }       
     }
}