@isTest
public class AllContactsToPostgresSchedule_Test {
    
     @isTest static void executeTest(){
        
        SchedulableContext sc = null;
        AllContactsToPostgresSchedule test = new AllContactsToPostgresSchedule();
        test.execute(sc);  
    }  
}