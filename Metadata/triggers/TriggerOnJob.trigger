trigger TriggerOnJob on Job__c (after insert, after update, after delete, before insert, before update, after undelete) {
    
    Map<String,Configuration__c> mapConfiguration = Configuration__c.getAll();
    String sTypeOfPackage = mapConfiguration.get('TYPE_OF_PACKAGE').String_Value__c;
    if(sTypeOfPackage.equals('STANDALONE') || sTypeOfPackage.equals(''))
    {
        ClassAfterOnJob classAfterOnJob = new ClassAfterOnJob();
        if(Trigger.isAfter)
        {
                classAfterOnJob.handleAfterOnJob(Trigger.newMap, Trigger.oldMap);
        } else {
            classAfterOnJob.handleBeforerOnJob(Trigger.New, Trigger.newMap, Trigger.oldMap);
        }
    }
}