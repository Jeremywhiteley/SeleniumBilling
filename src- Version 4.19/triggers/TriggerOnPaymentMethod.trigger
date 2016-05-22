trigger TriggerOnPaymentMethod on Payment_Method__c (after insert, after update, before insert, before update) {
        
        if(trigger.isAfter) {
            ClassAfterOnPaymentMethod classAfterOnPaymentMethod = new ClassAfterOnPaymentMethod();
            if(!classAfterOnPaymentMethod.getPaymentMethodAfterProcessingComplete()) {
                classAfterOnPaymentMethod.setPaymentMethodAfterProcessingComplete();
                classAfterOnPaymentMethod.handleAfterOnPaymentMethod(Trigger.newMap, Trigger.oldMap);
            }
        } else {
            ClassAfterOnPaymentMethod classAfterOnPaymentMethod = new ClassAfterOnPaymentMethod();
            
                classAfterOnPaymentMethod.handleBeforeOnPaymentMethod(Trigger.New, Trigger.newMap, Trigger.oldMap);
            
        }
    }