public with sharing class ClassAfterOnQuoteRatePlanCharges { 
        /*  Modified By       : Devender M: 07 Jan 2014: INVOICEIT-297
            Comments        : Look from Order rate plan charge to Order and Quote rate plan charge to Quote.
        */
        public void handleBeforeOnQuoteCharge() {
            set<Id> setOfQuoteRatePlanIds = new set<Id>();
            Quote_Rate_Plan_Charge__c newQuoteRatePlanCharge;
            list<Quote_Rate_Plan_Charge__c> quoteChargesToPopulate = new list<Quote_Rate_Plan_Charge__c>(); 
            // we need to populate the QuoteId in Quote rate plan charge
            for(SObject quoteChargeSobject : Trigger.new) {
                newQuoteRatePlanCharge = (Quote_Rate_Plan_Charge__c) quoteChargeSobject;
                
                if(trigger.isInsert) {
                    setOfQuoteRatePlanIds.add(newQuoteRatePlanCharge.Quote_Rate_Plan__c);
                    quoteChargesToPopulate.add(newQuoteRatePlanCharge);
                } else {
                    if(newQuoteRatePlanCharge.Quote__c == null) {
                        setOfQuoteRatePlanIds.add(newQuoteRatePlanCharge.Quote_Rate_Plan__c);
                        quoteChargesToPopulate.add(newQuoteRatePlanCharge); 
                    }
                }
            }       
            if(!setOfQuoteRatePlanIds.isEmpty()) {
                map<Id, Quote_Rate_Plan__c> map_QuoteRatePlanId_QuoteRatePlan = new map<Id, Quote_Rate_Plan__c>([SELECT Quote_Product__r.Quote__c  
                                                                                                                 FROM Quote_Rate_Plan__c 
                                                                                                                 WHERE Id IN: setOfQuoteRatePlanIds]
                                                                                                                );        
                // here we are populating the QuoteId in QRPC for only necessary ones. No need of iterating again the trigger.new                                                                                               
                for(Quote_Rate_Plan_Charge__c quoteCharge : quoteChargesToPopulate) {
                    quoteCharge.Quote__c = map_QuoteRatePlanId_QuoteRatePlan.get(quoteCharge.Quote_Rate_Plan__c).Quote_Product__r.Quote__c;
                }   
            }
        }
    }