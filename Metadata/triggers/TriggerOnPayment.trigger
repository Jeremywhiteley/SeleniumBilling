trigger TriggerOnPayment on Payment__c (before insert, after insert, after update) {
  
    ClassAfterOnPayment classAfterOnPayment = new ClassAfterOnPayment();
    if(Trigger.isAfter) {
        if(!classAfterOnPayment.getPaymentsAfterProcessingComplete()) {
          classAfterOnPayment.setPaymentsAfterProcessingComplete();
          classAfterOnPayment.handleAfterOnPayments(Trigger.newMap, Trigger.oldMap);
        } 
    } else {
          classAfterOnPayment.handleBeforeOnPayments(trigger.new);
    }
}