trigger TriggerOnQuote on Quote__c (after delete, after insert, after update, after undelete) {
    
    ClassAfterOnQuote classAfterOnQuote = new ClassAfterOnQuote();
    if(Trigger.isAfter)
    {
        classAfterOnQuote.handleAfterOnQuote(Trigger.newMap, Trigger.oldMap);
    }
}