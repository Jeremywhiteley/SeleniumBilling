public with sharing class ClassAfterOnUsageCharge {
        
        public void handleBeforeOnUsageCharge(list<Usage_Charge__c> newUsages, map<Id, Usage_Charge__c> newMap, map<Id, Usage_Charge__c> oldMap)
        {
            for(Usage_Charge__c usageCharge : newUsages) {
                
                if(usageCharge.Order_Rate_Plan_Charge__c != null) {
                    // Since ORPC is present, do nothing it goes in a standard way  
                } else {
                    if(usageCharge.Account__c != null) {
                        if(usageCharge.Order__c != null) {
                            // account is not null and order is not null, then pick up only the related order based on the UOM[ORPC Usage charges]
                        } else {
                            // account is not null and order is null, then pick up only All related orders present for the account based on the UOM[ORPC Usage charges]
                        }   
                    } else {
                        // account is null
                        if(usageCharge.Order__c != null) {
                            // account is null and order is not null, then pick up only the related order's ORPC Usage charges based on the UOM 
                        }
                    }
                }
            }       
        }
        
        public void handleAfterOnUsageCharge(map<Id, Usage_Charge__c> newMap, map<Id, Usage_Charge__c> oldMap)
        {   
            map<Id, Job_Rate_Plan_Charge__c> mapOfChargesToUpdate = new map<Id, Job_Rate_Plan_Charge__c>();
            
            Date usageEndDate;
            Id chargeId;
            list<Id> listOfChargeIds = new list<Id>();
            list<Usage_Charge__c> usageChargesToRollUp = new list<Usage_Charge__c>();
            map<Id,Usage_Charge__c> map_ChildUsageChargeId_usageChargesToInsertAgainstMasterOrderCharge = new map<Id,Usage_Charge__c>();
            
            for(Usage_Charge__c usageCharge : newMap.values()) {
                listOfChargeIds.add(usageCharge.Order_Rate_Plan_Charge__c);
            }
            //We need to check if the corresponding charge's next charge date is null
            //If it is then update that to the end date of the usage charge
            //Else update that to take the minimum of both dates
            
            Job_Rate_Plan_Charge__c[] charges = [   SELECT Id, Next_Charge_Date__c, Master_Order_Rate_Plan_Charge__c 
                                                    FROM Job_Rate_Plan_Charge__c
                                                    WHERE Id IN :listOfChargeIds];
            for(Job_Rate_Plan_Charge__c charge : charges){
                mapOfChargesToUpdate.put(charge.Id,charge);
            }
            
            for(Usage_Charge__c usageCharge : newMap.values()) {
                Job_Rate_Plan_Charge__c charge = mapOfChargesToUpdate.get(usageCharge.Order_Rate_Plan_Charge__c);
                
                //If there is charge has the master order charge field populated, then ignore that from the date update. 
                //We need to update the usage charges to Rolled-Up and insert the same usage charges against the master order charge record
                if(charge.Master_Order_Rate_Plan_Charge__c != null){
                    Usage_Charge__c newUsageCharge = usageCharge.clone(false,true);
                    newUsageCharge.Order_Rate_Plan_Charge__c = charge.Master_Order_Rate_Plan_Charge__c;
                    
                    map_ChildUsageChargeId_usageChargesToInsertAgainstMasterOrderCharge.put(usageCharge.Id, newUsageCharge);
                }else if( charge.Next_Charge_Date__c == null 
                    || charge.Next_Charge_Date__c > usageCharge.End_Date__c)
                {
                    charge.Next_Charge_Date__c = usageCharge.End_Date__c;       
                }
            }
            
            update mapOfChargesToUpdate.values();
            insert map_ChildUsageChargeId_usageChargesToInsertAgainstMasterOrderCharge.values();
            
            //Now that the master usage records are inserted, update the child usage records with that id
            for(Id childUsageId : map_ChildUsageChargeId_usageChargesToInsertAgainstMasterOrderCharge.keySet()){
                Usage_Charge__c usageCopy = new Usage_Charge__c(Id = childUsageId);
                Usage_Charge__c masterUsage = map_ChildUsageChargeId_usageChargesToInsertAgainstMasterOrderCharge.get(childUsageId);
                usageCopy.Status__c = CommonUtilClass.STATUS_ROLLED_UP;
                usageCopy.Master_Usage__c = masterUsage.Id;
                
                usageChargesToRollUp.add(usageCopy);
            }
            
            update usageChargesToRollUp;
        } 
    }