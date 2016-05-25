public with sharing class ClassAfterOnInvoiceLine {
        public static boolean INVOICELINE_AFTER_PROCESSING_COMPLETE = false;

        public void setInvoiceLineAfterProcessingComplete() {
            INVOICELINE_AFTER_PROCESSING_COMPLETE = true;
        }

        public Boolean getInvoiceLineAfterProcessingComplete() {
            return INVOICELINE_AFTER_PROCESSING_COMPLETE;
        }

        public void handleAfterOnInvoiceLine(map<Id,Invoice_Lines__c> newMap, map<Id,Invoice_Lines__c> oldMap)
        {
            list<Job_Rate_Plan_Charge__c> listJobRatePlanChargesToUpdate = new list<Job_Rate_Plan_Charge__c>();
            list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
            list<Usage_Charge__c> listOfUsageChargesToRollback = new list<Usage_Charge__c>();
            list<AggregateResult> listOfAggregateResult;
            set<ID> setInvoiceLineIdsToCancel = new set<ID>();
            set<ID> setOfChargesIdsToRollback = new set<ID>();
            map<Id,Date> mapOfChargeIdAndMaximumChargeDate = new map<Id,Date>();
            Invoice_Lines__c oldInvoiceLine;
            
            /* Modified By       : Ankit  :27-05-2014  :SUP-254
               Comments        : update job charges only when the invoicelines status changed from "Post to Cancel" or "Draft to Cancel" */

            //populate the set of invoiceId's and set of charges
            for(Invoice_Lines__c newInvoiceLine : newMap.values()) {
                oldInvoiceLine = oldMap.get(newInvoiceLine.Id);
                if(newInvoiceLine.Status__c == CommonUtilClass.STATUS_CANCELLED && newInvoiceLine.Status__c != oldInvoiceLine.Status__c && newInvoiceLine.Job_Rate_Plan_Charge__c != null) {
                    setInvoiceLineIdsToCancel.add(newInvoiceLine.Id);
                    setOfChargesIdsToRollback.add(newInvoiceLine.Job_Rate_Plan_Charge__c);
                }
            }
            if(setInvoiceLineIdsToCancel.size() > 0) {
                listInvoiceLines = [SELECT Service_End_Date__c, Service_Start_Date__c, Invoice__c, Job_Rate_Plan_Charge__r.Charge_Date__c, Job_Rate_Plan_Charge__r.Id, 
                                    Job_Rate_Plan_Charge__r.Price_Type__c, Job_Rate_Plan_Charge__r.Previous_Charge_Date__c,  Job_Rate_Plan_Charge__r.Is_Cumulative_Usage__c,
                                    Job_Rate_Plan_Charge__r.Used_Quantity_for_Usage__c
                                    FROM Invoice_Lines__c
                                    WHERE Id IN : setInvoiceLineIdsToCancel];
                
                //Added by MG on 02 April 2013
                //Get the list of usage charges associated with these invoice lines to rollback
                listOfUsageChargesToRollback = [SELECT Id, Status__c, Invoice_Line__c, End_Date__c, Order_Rate_Plan_Charge__c, Quantity__c
                                                FROM Usage_Charge__c
                                                WHERE Invoice_Line__c IN : setInvoiceLineIdsToCancel];
                
                // Ref : INVOICEIT-257 
                // Start Laxman changing on 17th oct, when the usageInvoiceLine is cancelled we need to populate the nextChargeDate as MIN(EndDate) of all the usage charges corresponding to the cancelled invoiceLine
                map<Id, date> mapORPCId_MinimumUsageDate = new map<Id, date>();
                map<Id, decimal> mapOfChargeId_UnBilledQuantity = new map<Id, decimal>();
                Date existingMinDate;
                decimal existingUnBilledAmount;
                // loop over the charges to find construct the map of ORPCId and MIN(EndDate)
                for(Usage_Charge__c usageCharge : listOfUsageChargesToRollback) {
                    if(usageCharge.Order_Rate_Plan_Charge__c != null && usageCharge.End_Date__c != null) {
                        // if it contains in the map then do a comparison and take the minimum one, else put in a map
                        if(mapORPCId_MinimumUsageDate.containsKey(usageCharge.Order_Rate_Plan_Charge__c)) {
                            existingMinDate = mapORPCId_MinimumUsageDate.get(usageCharge.Order_Rate_Plan_Charge__c);
                            if(usageCharge.End_Date__c < existingMinDate) {
                                mapORPCId_MinimumUsageDate.put(usageCharge.Order_Rate_Plan_Charge__c, usageCharge.End_Date__c); 
                            } 
                            existingUnBilledAmount = mapOfChargeId_UnBilledQuantity.get(usageCharge.Order_Rate_Plan_Charge__c);  
                        } else {
                            mapORPCId_MinimumUsageDate.put(usageCharge.Order_Rate_Plan_Charge__c, usageCharge.End_Date__c);
                            existingUnBilledAmount = 0;
                        }

                        existingUnBilledAmount = existingUnBilledAmount + usageCharge.Quantity__c; 
                        mapOfChargeId_UnBilledQuantity.put(usageCharge.Order_Rate_Plan_Charge__c, existingUnBilledAmount);
                    }   
                }
                // End of changing on 17th oct
                // Ref : INVOICEIT-257 
                
                //here we are quering for maximum charge date,so that we can assign to the job rate plan previous charge date
                listOfAggregateResult = [SELECT Job_Rate_Plan_Charge__c chargeId ,max(Service_Start_Date__c) maxCharge
                                         FROM Invoice_Lines__c
                                         WHERE Job_Rate_Plan_Charge__c IN: setOfChargesIdsToRollback 
                                         AND Id NOT IN : newMap.KeySet() 
                                         AND Status__c !=: CommonUtilClass.STATUS_CANCELLED
                                         GROUP BY Job_Rate_Plan_Charge__c];
                
                for(AggregateResult aggResult : listOfAggregateResult) {
                    mapOfChargeIdAndMaximumChargeDate.put((Id)aggResult.get('chargeId'),(Date)aggResult.get('maxCharge'));
                }       
                
                set<Id> orderChargeIds = new set<Id>();                 
                //once the invoice line is cancelled,then 
                //related jobratePlan Next_Charge_Date__c,Charge_Date__c,Previous_Charge_Date__c should be changed
                for(Invoice_Lines__c invoiceLine : listInvoiceLines) {
                    if(!orderChargeIds.contains(invoiceLine.Job_Rate_Plan_Charge__c)) {
                        Job_Rate_Plan_Charge__c jobRatePlanCharge = new Job_Rate_Plan_Charge__c(Id = invoiceLine.Job_Rate_Plan_Charge__r.Id);
                        if(invoiceLine.Job_Rate_Plan_Charge__r.Price_Type__c == System.Label.OptionOneTime) {
                            jobRatePlanCharge.Charge_Date__c = null;
                        } else {
                            jobRatePlanCharge.Next_Charge_Date__c = invoiceLine.Service_Start_Date__c;
                            jobRatePlanCharge.Charge_Date__c = invoiceLine.Job_Rate_Plan_Charge__r.Previous_Charge_Date__c;
                            Date maximumChargeDate = null;
                            if(mapOfChargeIdAndMaximumChargeDate.containsKey(invoiceLine.Job_Rate_Plan_Charge__c)) {
                                maximumChargeDate = mapOfChargeIdAndMaximumChargeDate.get(invoiceLine.Job_Rate_Plan_Charge__c);
                            }
                            jobRatePlanCharge.Previous_Charge_Date__c = maximumChargeDate;
                        
                            if(invoiceLine.Job_Rate_Plan_Charge__r.Is_Cumulative_Usage__c && invoiceLine.Job_Rate_Plan_Charge__r.Used_Quantity_for_Usage__c != null) {
                               jobRatePlanCharge.Used_Quantity_for_Usage__c = invoiceLine.Job_Rate_Plan_Charge__r.Used_Quantity_for_Usage__c - mapOfChargeId_UnBilledQuantity.get(invoiceLine.Job_Rate_Plan_Charge__r.Id);
                            } else if(invoiceLine.Job_Rate_Plan_Charge__r.Is_Cumulative_Usage__c) {
                               jobRatePlanCharge.Used_Quantity_for_Usage__c = mapOfChargeId_UnBilledQuantity.get(invoiceLine.Job_Rate_Plan_Charge__r.Id); 
                            }
                            // Ref : INVOICEIT-257, if it is a usage charge then we need to populate the minimum of usageCharge.EndDate 
                            if(invoiceLine.Job_Rate_Plan_Charge__r.Price_Type__c == System.Label.OptionUsage && mapORPCId_MinimumUsageDate.containsKey(invoiceLine.Job_Rate_Plan_Charge__c)) {
                                jobRatePlanCharge.Next_Charge_Date__c = mapORPCId_MinimumUsageDate.get(invoiceLine.Job_Rate_Plan_Charge__c);
                            }
                     
                        }
                        listJobRatePlanChargesToUpdate.add(jobRatePlanCharge);
                        
                        //add the charge Id to the set, so that if two inv line have the same charge id then it will throw ex
                        orderChargeIds.add(invoiceLine.Job_Rate_Plan_Charge__c);
                        mapOfChargeIdAndMaximumChargeDate.remove(invoiceLine.Job_Rate_Plan_Charge__c);
                    }
                }
                
                for(Usage_Charge__c usage : listOfUsageChargesToRollback){
                    usage.Status__c = CommonUtilClass.STATUS_UNBILLED;
                }
            }

            if(listJobRatePlanChargesToUpdate.size() > 0) {
                update listJobRatePlanChargesToUpdate;
            }
            
            if(listOfUsageChargesToRollback.size() > 0) {
                update listOfUsageChargesToRollback;
            }
        }
    }