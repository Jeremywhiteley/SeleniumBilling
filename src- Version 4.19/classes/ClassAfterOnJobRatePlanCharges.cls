public with sharing class ClassAfterOnJobRatePlanCharges {
        
        /*
            Modified By     : Devender M 07 Jan 2014 INVOICEIT-297
            Comments        : Look from Order rate plan charge to Order and Quote rate plan charge to Quote.
        */

        public void handleBeforeOnJobCharge() {
            set<Id> setOforderRatePlanIds = new set<Id>();
            Job_Rate_Plan_Charge__c newJobRatePlanCharge;
            list<Job_Rate_Plan_Charge__c> orderChargesToPopulate = new list<Job_Rate_Plan_Charge__c>();
            set<Id> setOfProductChargeIds = new set<Id>();
            map<Id, Product_Rate_Plan_Charge__c> map_ProductChargeId_ProductCharge = new map<Id, Product_Rate_Plan_Charge__c>();
            
            // we need to populate the QuoteId in Quote rate plan charge
            for(SObject orderChargeSobject : Trigger.new) {
                newJobRatePlanCharge = (Job_Rate_Plan_Charge__c) orderChargeSobject;
                if(trigger.isInsert) {
                    setOforderRatePlanIds.add(newJobRatePlanCharge.Job_Rate_Plan__c);
                    if(newJobRatePlanCharge.Product_Rate_Plan_Charge__c != null && newJobRatePlanCharge.Revenue_Recognition_Rule__c == null)
                        setOfProductChargeIds.add(newJobRatePlanCharge.Product_Rate_Plan_Charge__c);
                    orderChargesToPopulate.add(newJobRatePlanCharge);
                } else {
                    if(newJobRatePlanCharge.order__c == null) {
                        setOforderRatePlanIds.add(newJobRatePlanCharge.Job_Rate_Plan__c);   
                        orderChargesToPopulate.add(newJobRatePlanCharge);
                    }
                }
            }
            
            if(trigger.isInsert && !setOfProductChargeIds.isEmpty()) {
                map_ProductChargeId_ProductCharge = new  map<Id, Product_Rate_Plan_Charge__c>([SELECT Revenue_Recognition_Rule__c
                                                                                                 FROM Product_Rate_Plan_Charge__c
                                                                                                 WHERE Id IN: setOfProductChargeIds]);
            } 
            if(!setOforderRatePlanIds.isEmpty()) {
                map<Id, Job_Rate_Plan__c> map_OrderRatePlanId_OrderRatePlan = new map<Id, Job_Rate_Plan__c>([SELECT Job_Product__r.Job__c
                                                                                                             FROM Job_Rate_Plan__c
                                                                                                             WHERE Id IN: setOforderRatePlanIds]);
                
                
                                                                                                            
                // here we are populating the QuoteId in QRPC for only necessary ones. No need of iterating again the trigger.new
                for(Job_Rate_Plan_Charge__c jobCharge : orderChargesToPopulate) {
                    if(map_OrderRatePlanId_OrderRatePlan != null && map_OrderRatePlanId_OrderRatePlan.containskey(jobCharge.Job_Rate_Plan__c))
                        jobCharge.Order__c = map_OrderRatePlanId_OrderRatePlan.get(jobCharge.Job_Rate_Plan__c).Job_Product__r.Job__c;
                    if(trigger.isInsert && jobCharge.Product_Rate_Plan_Charge__c != null && jobCharge.Revenue_Recognition_Rule__c == null && map_ProductChargeId_ProductCharge.containskey(jobCharge.Product_Rate_Plan_Charge__c))
                        jobCharge.Revenue_Recognition_Rule__c = map_ProductChargeId_ProductCharge.get(jobCharge.Product_Rate_Plan_Charge__c).Revenue_Recognition_Rule__c;
                }
            }                                                                                                   
        }
        
        public void handleAfterUpdateOnJobCharge(){
            list<Job__c> listOfJobsToUpdate = new list<Job__c>();
            set<Id> setOfJobIds;
            list<AggregateResult> listOfAggregateResult;
            list<Job_Rate_Plan_Charge__c> listOfJobChargesOfInterest = new list<Job_Rate_Plan_Charge__c>();
            
            list<Id> listofChargeIds = new list<Id>();

            for(SObject s : Trigger.newMap.Values()) {
                Job_Rate_Plan_Charge__c newJobRatePlanCharge = (Job_Rate_Plan_Charge__c)s; 
                Job_Rate_Plan_Charge__c oldJobRatePlanCharge = (Job_Rate_Plan_Charge__c)Trigger.oldMap.get(newJobRatePlanCharge.Id);
                //charges intrested for Minimum_Next_Charge_Date_For_Product__c
                if(newJobRatePlanCharge.Next_Charge_Date__c != oldJobRatePlanCharge.Next_Charge_Date__c) 
                {
                    listOfJobChargesOfInterest.add(newJobRatePlanCharge);
                }

                // Modified by Dev M INVOICEIT-549 : Recalculate Revenue Forecasts when ever the check box is true
                 if(newJobRatePlanCharge.Recalculate_Revenue_Forecasts__c != oldJobRatePlanCharge.Recalculate_Revenue_Forecasts__c
                    && newJobRatePlanCharge.Recalculate_Revenue_Forecasts__c) 
                {
                    listofChargeIds.add(newJobRatePlanCharge.Id);
                } 
            }
            
                
            if(!listOfJobChargesOfInterest.isEmpty()) {
                setOfJobIds = new set<Id>();
                for(Job_Rate_Plan_Charge__c jobRatePlanCharge : [SELECT Job_Rate_Plan__r.Job_Product__r.Job__r.Id 
                                                                  FROM Job_Rate_Plan_Charge__c 
                                                                  WHERE Id IN: listOfJobChargesOfInterest]) 
                {
                    setOfJobIds.add(jobRatePlanCharge.Job_Rate_Plan__r.Job_Product__r.Job__r.Id);
                }
            
                listOfAggregateResult = [SELECT Job_Rate_Plan__r.Job_Product__r.Job__r.Id, min(Next_Charge_Date__c) minCharge
                                         FROM Job_Rate_Plan_Charge__c
                                         WHERE Job_Rate_Plan__r.Job_Product__r.Job__r.Id IN: setOfJobIds
                                         GROUP BY Job_Rate_Plan__r.Job_Product__r.Job__r.Id];
                
                for(AggregateResult aggResult : listOfAggregateResult) {
                    listOfJobsToUpdate.add(new Job__c(Id = (Id)aggResult.get('Id'), Minimum_Next_Charge_Date_For_Product__c = (Date)aggResult.get('minCharge')));
                }
                
                //update the jobs with the min next charge date
                if(!listOfJobsToUpdate.isEmpty()) {
                    update listOfJobsToUpdate;
                }   
            }

            // Here were are processing the records for Revenue Forecasts
             if(!listofChargeIds.isEmpty()) {
                RevenueTransactionsForOrderUtilClass.createRevenueForecastForOrderCharge(listofChargeIds);
            }
        }
    }