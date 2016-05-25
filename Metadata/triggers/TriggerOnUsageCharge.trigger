trigger TriggerOnUsageCharge on Usage_Charge__c (after insert) {
    ClassAfterOnUsageCharge classAfterOnUsageCharge = new ClassAfterOnUsageCharge();
    if(Trigger.isAfter) {
        classAfterOnUsageCharge.handleAfterOnUsageCharge(Trigger.newMap, Trigger.oldMap);
    }
}