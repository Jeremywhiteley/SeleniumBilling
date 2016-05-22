trigger TriggerOnQuoteRatePlanCharges on Quote_Rate_Plan_Charge__c (before insert, before update) {
    /*
        Modified By     : Devender M; 07 Jan 2014, INVOICEIT-297
        Comments        : Look from Order rate plan charge to Order and Quote rate plan charge to Quote.
    */
    ClassAfterOnQuoteRatePlanCharges classAfterOnQuoteRatePlanCharges = new ClassAfterOnQuoteRatePlanCharges();
    if(Trigger.isBefore) {
        classAfterOnQuoteRatePlanCharges.handleBeforeOnQuoteCharge();
    }
}