trigger TriggerOnJobRatePlanCharges on Job_Rate_Plan_Charge__c (before insert, after update, before update) {
    
            /*
                Modified By     : Devender M, 07 Jan 2014, INVOICEIT-297
                Comments        : Look from Order rate plan charge to Order and Quote rate plan charge to Quote.
             */
    ClassAfterOnJobRatePlanCharges classAfterOnJobRatePlanCharges = new ClassAfterOnJobRatePlanCharges();
    if(trigger.isBefore) {
        classAfterOnJobRatePlanCharges.handleBeforeOnJobCharge();
    } else {
        classAfterOnJobRatePlanCharges.handleAfterUpdateOnJobCharge();
    }  
}