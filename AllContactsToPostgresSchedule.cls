global class AllContactsToPostgresSchedule implements schedulable
{
    global void execute(SchedulableContext sc)
    {
        Id batchJobId = Database.executeBatch(new AllContactsToPostgresJob(), 2000);
        
    }
}