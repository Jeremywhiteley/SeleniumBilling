public with sharing class ClassAfterOnJob {
        // 1) Populating the service end date when (service activation and terms are present) OR (either service activation date is changed or terms)
        private static boolean JOB_AFTER_PROCESSING_COMPLETE = false;

        public void setJobAfterProcessingComplete() {
            JOB_AFTER_PROCESSING_COMPLETE = true;
        }

        public Boolean getJobAfterProcessingComplete() {
            return JOB_AFTER_PROCESSING_COMPLETE;
        }

        public void handleBeforerOnJob(list<Job__c> triggerNew, map<Id,Job__c> newMap, map<Id,Job__c> oldMap) 
        {
            if(Trigger.isInsert) {
                //calculate the ServiceEndDate
                for(Job__c newJob : triggerNew) {
                    if(newJob.Service_Activation_Date__c != null && newJob.Number_Of_Terms__c != null) {
                        Integer iNumberOfMonths = integer.ValueOf(newJob.Number_Of_Terms__c);
                        newJob.Service_End_Date__c = newJob.Service_Activation_Date__c.addmonths(iNumberOfMonths);
                        //Adjust the date so the service ends 1 day before the date of start (14 is start date and 13 is end date)
                        newJob.Service_End_Date__c = newJob.Service_End_Date__c.addDays(-1);
                    }
                }
            }

            if(Trigger.isUpdate) {
                for(Job__c newJob : newMap.values()) {
                    //check here whether the service activation date is changed or no of months is changed
                    //if it is changed then service end date = service activation date.addmonths(no of months)
                    Job__c oldJob = oldMap.get(newJob.Id);

                    if((newJob.Service_Activation_Date__c != oldJob.Service_Activation_Date__c) 
                            || (newJob.Number_Of_Terms__c != oldJob.Number_Of_Terms__c)) 
                    {
                        if(newJob.Service_Activation_Date__c != null && newJob.Number_Of_Terms__c != null) {
                            Integer iNumberOfMonths = integer.ValueOf(newJob.Number_Of_Terms__c);
                            newJob.Service_End_Date__c = newJob.Service_Activation_Date__c.addmonths(iNumberOfMonths);
                            newJob.Service_End_Date__c = newJob.Service_End_Date__c.addDays(-1);
                        } else {
                            newJob.Service_End_Date__c = null;
                        }
                    }
                }
            }
        }

        public void handleAfterOnJob(map<Id,Job__c> newMap, map<Id,Job__c> oldMap)
        {
            String sStatusToMapOrderToAmount = Configuration__c.getValues('ORDER_STATUS_VALUES_TO_ROLLUP').String_Value__c;
            set<Id> setOfAccountIds = new set<Id>();

            //check if it is deleted or not
            if(Trigger.isDelete)
            {
                for(Job__c job : oldMap.values())
                {
                    if(job.Account__c != null && !setOfAccountIds.contains(job.Account__c) && sStatusToMapOrderToAmount != null) {
                        setOfAccountIds.add(job.Account__c);
                    }
                }
            }
            //it is a insert or update or undelete operation
            else
            {
                if(Trigger.isInsert || Trigger.isUndelete) {
                    for(Job__c newJob : (list<Job__c>) trigger.New)
                    {
                        if(newJob.Account__c != null && !setOfAccountIds.contains(newJob.Account__c) && sStatusToMapOrderToAmount != null) {
                            setOfAccountIds.add(newJob.Account__c);
                        }
                    }
                }

                if(Trigger.isUpdate) {
                    for(Job__c newJob : newMap.values())
                    {
                        Job__c oldJob = oldMap.get(newJob.Id);
                        if( oldJob.Total_Contract_Value__c != newJob.Total_Contract_Value__c ||
                                oldJob.Service_Activation_Date__c != newJob.Service_Activation_Date__c || 
                                oldJob.Number_Of_Terms__c != newJob.Number_Of_Terms__c ||
                                oldJob.Service_End_Date__c != newJob.Service_End_Date__c ||
                                oldJob.Account__c != newJob.Account__c || 
                                oldJob.Status__c != newJob.Status__c) 
                        {
                            if(newJob.Account__c != null && !setOfAccountIds.contains(newJob.Account__c) && sStatusToMapOrderToAmount != null) {
                                setOfAccountIds.add(newJob.Account__c);
                            }
                            if(oldJob.Account__c != null && !setOfAccountIds.contains(oldJob.Account__c) && sStatusToMapOrderToAmount != null) {
                                setOfAccountIds.add(oldJob.Account__c);
                            }
                        }
                    }

                    //populate the subtotal, nettotal and tax
                    Job__c job = null;
                    for(Job__c newJob : newMap.values()) {
                        Job__c oldJob = oldMap.get(newJob.Id);
                        try {
                            
                            if( newJob.Recalculate__c 
                                    && newJob.Recalculate__c != oldJob.Recalculate__c && newJob.Recalculate__c) 
                            {
                                JobClass jobClass = ClassAfterOnJob.populateJobClass(newJob.Id , false);   

                                JobChargesCalculator.calculateCharges(jobClass);

                                ClassAfterOnJob.saveJob(jobClass);

                                break;
                            }
                        } catch(Exception ex) {
                            newJob.addError(ex.getMessage());  
                        }
                    }

                    //create the invoice automatically
                    job = null;
                    for(Job__c newJob : newMap.values()) {
                        Job__c oldJob = oldMap.get(newJob.Id);
                        try {
                            if( newJob.Create_Invoice_Automatically__c 
                                    && newJob.Create_Invoice_Automatically__c != oldJob.Create_Invoice_Automatically__c) 
                            {
                                
                                // Modified by Laxman Rao M, INVOICEIT-380
                                CustomInvoiceGenerator invoiceGenerator = new CustomInvoiceGenerator();
                                string responseMessage = invoiceGenerator.generateInvoiceForOrder(newJob.Id, system.today(), system.today(), true, false, false);
                                if( responseMessage != null && responseMessage.length() > 0 && !responseMessage.contains('null')) {
                                    if(responseMessage.contains('ERROR') || responseMessage.contains('null')) {
                                        newJob.addError(responseMessage);
                                    }
                                }

                                job = new Job__c(Id = newJob.Id, Create_Invoice_Automatically__c = false);
                                update job;

                                break;
                            }
                        } catch(Exception ex) {
                            newJob.addError(ex.getMessage());  
                        }
                    }
                }
            }
            
            // Ref : INVOICEIT-317, Modified by : Laxman Rao M
            // here we are checking, if the current user has access to account record
            // if the user does not have access then we will remove from the set(some account and opportunity will be have access as private)
            // the reason why I am creating the listOfAccountIds is, query is not being executed if we use setOfAccountIds
            list<Id> listOfAccountIds = new list<Id>();
            listOfAccountIds.addAll(setOfAccountIds);
            list<UserRecordAccess> listOfRecordAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =: UserInfo.getUserId() AND RecordId IN: listOfAccountIds];
            for(UserRecordAccess userRecordAccess : listOfRecordAccess) {
                if(!userRecordAccess.HasEditAccess) {
                    setOfAccountIds.remove(userRecordAccess.RecordId);      
                }   
            }
            
            //logic for calculating the total contract value on account
            if(setOfAccountIds.size() > 0) {
                ClassAfterOnJob.rollupTotalContractValueOnAccount(setOfAccountIds);
            }
        }

        public static void rollupTotalContractValueOnAccount(set<Id> setOfAccountIds) {
            String sStatusToMapOrderToAmount = Configuration__c.getValues('ORDER_STATUS_VALUES_TO_ROLLUP').String_Value__c;
            list<Account> listOfAccountsToUpdate = new list<Account>();
            list<String> listOfStatus;
            if(sStatusToMapOrderToAmount != null) {
                listOfStatus = sStatusToMapOrderToAmount.split(',');
            }

            //Query the sum(total) for all jobs pertaining to these accounts
            AggregateResult[] groupedResults = [SELECT Account__c accountId, SUM(Total_Contract_Value__c) totalContractValue
                                                FROM Job__c 
                                                WHERE Account__c IN : setOfAccountIds
                                                AND 
                                                Status__c IN : listOfStatus
                                                GROUP BY Account__c];
            for(AggregateResult result : groupedResults) {
                Id accountId = (Id)result.get('accountId');
                Double dTotalContractValue = (Double)result.get('totalContractValue');
                Account account = new Account(Id = accountId, TotalOrderValue__c = dTotalContractValue);
                listOfAccountsToUpdate.add(account);
                //Once this account is added for updation, remove them from the set
                setOfAccountIds.remove(accountId);
            }   

            //Now the setofAccountIds will have only those accounts that have been missed and they should be updated with zero value
            for(Id accountId : setOfAccountIds) {
                Account account = new Account(Id = accountId, TotalOrderValue__c = 0);
                listOfAccountsToUpdate.add(account);
            } 

            if(listOfAccountsToUpdate.size() > 0) {
                update listOfAccountsToUpdate;
            }
        }

        public static void saveJob(JobClass jobClass) {
            List<Job_Rate_Plan_Charge__c> listJobRatePlanCharges = new List<Job_Rate_Plan_Charge__c>();
            List<Job_Rate_Plan_Charge__c> listJobRatePlanChargesToDelete = new  List<Job_Rate_Plan_Charge__c>();
            List<Job_Rate_Plan_Charge_Tier__c> listJobTiersToDelete = new List<Job_Rate_Plan_Charge_Tier__c>();
            Map<Integer,Job_Product__c> mapJobProducts = new Map<Integer, Job_Product__c>();
            map<String, Configuration__c> mapConfiguration = Configuration__c.getAll();
            boolean Align_Dates_Of_Order_To_Products = mapConfiguration.get('ALIGN_DATES_OF_ORDER_TO_PRODUCTS').Boolean_Value__c;
            List<Job_Rate_Plan__c> jobRatePlansToDelete = new List<Job_Rate_Plan__c>();
            List<Job_Product__c> jobProductsToDelete = new List<Job_Product__c>();
            
            decimal totalContractValue = 0;
            decimal totalChargeContract = 0;
            decimal totalContractedMRR = 0;

            Currency__c currencyObj = CommonUtilClass.getCurrencyObjectForId(jobClass.job.CurrencyL__c);
            string currecyISOCode = currencyObj.Name;

            //If they dont use service activation date for invoice generation, set the value to start date
            if(jobClass.job.Service_Activation_Date__c == null && 
                    mapConfiguration.get(CommonUtilClass.USE_SERVICE_START_DATE_FOR_INVOICE).Boolean_Value__c)
            {
                jobClass.job.Service_Activation_Date__c = jobClass.job.Start_Date__c;
            }

            //populate the exchange rate
            if(UserInfo.isMultiCurrencyOrganization() && jobClass.job.Start_Date__c != null) 
            {
                JobCreationUtil.populateExchangeRateOnOrder(jobClass.job, currecyISOCode);
            }
            
            map<Id, Integer> mapProductBundleId_sequenceNumber = new map<Id, Integer>();
            integer jobBundleSequenceNo = 1;
            for(JobProductClass qpc : jobClass.jobProducts) {
                if(qpc.jobproduct.Job__c == null) {
                    qpc.jobproduct.Job__c = jobClass.job.Id;  
                }
                
                if(qpc.jobproduct.Product_Bundle__c != null && qpc.jobproduct.Bundle_SequenceNumber__c == null) {
                    if(mapProductBundleId_sequenceNumber.containskey(qpc.jobproduct.Product_Bundle__c)) {
                        qpc.jobproduct.Bundle_SequenceNumber__c = mapProductBundleId_sequenceNumber.get(qpc.jobproduct.Product_Bundle__c);
                    }else {
                        mapProductBundleId_sequenceNumber.put(qpc.jobproduct.Product_Bundle__c ,jobBundleSequenceNo);
                        qpc.jobproduct.Bundle_SequenceNumber__c = jobBundleSequenceNo;
                        jobBundleSequenceNo++;
                    }
                }
                mapJobProducts.put(qpc.jobProductCounter, qpc.jobproduct);
            }
            upsert mapJobProducts.values();  

            for(JobProductClass qpc: jobClass.jobProducts)
            {
                qpc.jobproduct = mapJobProducts.get(qpc.jobProductCounter);   
            }

            Map<Integer,Job_Rate_Plan__c> mapJobRatePlan = new Map<Integer,Job_Rate_Plan__c>();
            for(JobProductClass qpc : jobClass.jobProducts) {
                qpc.jobproduct = mapjobProducts.get(qpc.jobProductcounter);
                for(JobRatePlanClass qrc : qpc.jobRatePlans) {
                    if(qrc.jobrateplan.Job_Product__c == null) {
                        qrc.jobrateplan.Job_Product__c = qpc.jobproduct.id;
                    }
                    mapJobRatePlan.put(qrc.jobRatePlanCounter,qrc.jobrateplan);
                }
            }
            upsert mapJobRatePlan.values();  
            
            /*
                Modified By     : Devender M  04 June 2013  INVOICEIT-175
                Comments        : Previously discount was included in Total Contract Value, so i have subtracted the discount value.
                                  Used nettotal for calculating the Total Contract Value
            */
            Map<Integer,Job_Rate_Plan_Charge__c> mapJobRatePlanCharges = new Map<Integer,Job_Rate_Plan_Charge__c>();
            for(JobProductClass qpc :jobClass.jobProducts)
            {
                for(JobRatePlanClass qrc : qpc.jobRatePlans)
                {
                    integer i = 0;
                    for(JobRatePlanChargeClass qrpc :qrc.jobRatePlanCharges)
                    {
                        totalChargeContract = 0;
                        if(qrpc.jobrateplancharge.Job_Rate_Plan__c == null) {
                            qrpc.jobrateplancharge.Job_Rate_Plan__c = qrc.jobrateplan.id;
                        }
                        //if Align_Dates_Of_Order_To_Products is true then assign the order activation date to charge activation date
                        if(Align_Dates_Of_Order_To_Products) {
                            if(qrpc.jobrateplancharge.Service_Activation_Date__c == null) {
                                qrpc.jobrateplancharge.Service_Activation_Date__c = jobClass.job.Service_Activation_Date__c;
                            }
                            if(qrpc.jobrateplancharge.Service_End_Date__c == null) {
                                qrpc.jobrateplancharge.Service_End_Date__c = jobClass.job.Service_End_Date__c;
                            }
                        }

                        //If Quantity__c is greather than 0,then add to the map.Else do not add to the map.
                        // If Package__c or Bundle__c is true we are allowing to add product if quantity is 0
                        if(qrpc.jobrateplancharge.Quantity__c > 0 || qrpc.jobrateplancharge.Price_Type__c == system.Label.OptionUsage || qrpc.jobrateplancharge.Package__c || qrpc.jobrateplancharge.Bundle__c || qrpc.jobrateplancharge.Required_By__c != null) {
                            qrpc.jobrateplancharge.Sequence_No__c = ++i; 
                            mapJobRatePlanCharges.put(qrpc.jobRatePlanChargeCounter,qrpc.jobrateplancharge); 

                            // If it is one time then calcualte quantity * price
                            // If the charge start and end dates are present use that, else use the job start and end dates to calculate TCV
                            if(qrpc.jobrateplancharge.Price_Type__c == system.Label.OptionOneTime) {
                                totalChargeContract = qrpc.jobrateplancharge.Net_Total__c;
                            } else if(qrpc.jobrateplancharge.Service_Activation_Date__c != null && qrpc.jobrateplancharge.Service_End_Date__c != null) {
                                totalChargeContract = JobCreationUtil.calculateJobChargeLineAmount(qrpc.jobrateplancharge, qrpc.jobrateplancharge.Service_Activation_Date__c, qrpc.jobrateplancharge.Service_End_Date__c);
                            } else if(jobClass.job.Number_Of_Terms__c != null && jobClass.job.Service_Activation_Date__c != null) {
                                totalChargeContract = JobCreationUtil.calculateJobChargeLineAmount(qrpc.jobrateplancharge, jobClass.job.Service_Activation_Date__c, jobClass.job.Service_Activation_Date__c.addMonths((Integer)jobClass.job.Number_Of_Terms__c).addDays(-1));
                            }  
                            
                            /*
                                Modified By     : ramakrishna.v 03-12-13 SUP-147
                                Comments        : caluclating the toatl contract value
                            */
                            //calculate the ContractedMRR only if the type is not equal to one time
                             if(qrpc.jobrateplancharge.Price_Type__c != system.Label.OptionOneTime) {
                                     totalContractValue += totalChargeContract;
                                     totalContractedMRR += totalChargeContract;
                             } else {
                                     totalContractValue += totalChargeContract;
                             }
                        }
                        else if(qrpc.jobrateplancharge.Id != null) {
                            listJobRatePlanChargesToDelete.add(new Job_Rate_Plan_Charge__c(Id = qrpc.jobrateplancharge.Id));
                            //Add the corresponding quoterateplanchargetiers to a delete list and delete those tiers to remove orphaned records
                            for(JobRatePlanChargeTierClass jobTierClass : qrpc.jobRatePlanChargeTiers) {
                                if(jobTierClass.jobRatePlanChargeTier.Id != null) {
                                    listJobTiersToDelete.add(jobTierClass.jobRatePlanChargeTier);   
                                }
                            }
                        }
                    }
                }
            }

            //This change was done for the new feature Roll-Up usage charges to the master order
            //When the order record has the master order field populated, associate each Order Charge of type Usage to the corresponding charge record from the master order
            //The only criteria here is if the master order has an Order Charge for the same product charge id
            CommonUtilClass.relateChargeRecordsToMasterChargeRecords(jobClass);

            upsert mapJobRatePlanCharges.values();  

            Map<Integer,Job_Rate_Plan_Charge_Tier__c> mapJobRatePlanChargeTiers = new Map<Integer,Job_Rate_Plan_Charge_Tier__c>();
            for(JobProductClass qpc :jobClass.jobProducts)
            {
                for(JobRatePlanClass qrc : qpc.jobRatePlans)
                { 
                    for(JobRatePlanChargeClass qrpc :qrc.jobRatePlanCharges)
                    {
                        if(qrpc.jobrateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME 
                                || qrpc.jobrateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE 
                                || qrpc.jobrateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_TIERED)
                        {
                            for(JobRatePlanChargeTierClass jobTierClass : qrpc.jobRatePlanChargeTiers)
                            {
                                if(jobTierClass.jobRatePlanChargeTier.Job_Rate_Plan_Charge__c == null) {
                                    if(mapJobRatePlanCharges.containsKey(qrpc.jobRatePlanChargeCounter)) {
                                        jobTierClass.jobRatePlanChargeTier.Job_Rate_Plan_Charge__c = mapJobRatePlanCharges.get(qrpc.jobRatePlanChargeCounter).Id;
                                        mapJobRatePlanChargeTiers.put(jobTierClass.jobRatePlanChargeTierCounter, jobTierClass.jobRatePlanChargeTier);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            upsert mapJobRatePlanChargeTiers.Values();

            if(jobRatePlansToDelete != null && jobRatePlansToDelete.size() > 0) {
                delete jobRatePlansToDelete;    
            }

            //Here we are quering and deleting the Job_Products which has no rate Plan charges
            for(JobProductClass qpc : jobClass.jobProducts) {
                if(qpc.jobproduct.Total_Job_Rate_Plans__c == 0) {
                    jobProductsToDelete.add(qpc.jobproduct);
                }
            }

            if(jobProductsToDelete != null && jobProductsToDelete.size() > 0) {
                delete jobProductsToDelete;
            }

            if(listJobRatePlanChargesToDelete.size() > 0) {
                delete listJobRatePlanChargesToDelete;
            }

            if(listJobTiersToDelete.size() > 0) {
                delete listJobTiersToDelete;
            }

            Job__c job = new Job__c(Id = jobClass.job.Id);
            job.VAT__c = jobClass.job.VAT__c;
            job.Tax__c = jobClass.job.Tax__c;
            job.Discount_Value__c = jobClass.job.Discount_Value__c;
            job.Sub_Total__c = jobClass.job.Sub_Total__c;
            job.Total__c = jobClass.job.Total__c;
            job.Total_Cost__c = jobClass.job.Total_Cost__c;
            job.Net_Total__c = jobClass.job.Net_Total__c;
            job.Total_Profit__c = jobClass.job.Total_Profit__c;
            job.TotalProfitPercent__c = jobClass.job.TotalProfitPercent__c;
            job.Recalculate__c = false;
            /*
                Modified By     : ramakrishna.v 03-12-13 SUP-147
                Comments        : assign the calulated Tcv to Order tcv
            */
            if(totalContractValue > 0){
              job.Total_Contract_Value__c = totalContractValue; 
            }else{
                job.Total_Contract_Value__c = 0;
            }

            if(totalContractedMRR > 0 && jobClass.job.Number_Of_Terms__c != null && jobClass.job.Number_Of_Terms__c >= 1) {
                job.Contracted_MRR__c = (totalContractedMRR/jobClass.job.Number_Of_Terms__c); 
            }else{
                job.Contracted_MRR__c = 0;
            }
            
            update job;
        }

        public static JobClass populateJobClass(Id jobId, boolean isRenewal) {
            Map<Id,JobProductClass> mapJobProducts = new  Map<Id,JobProductClass>();
            JobClass jobClass = new JobClass();
            Integer jobProductCounter = 0;
            Integer jobRatePlanCounter = 0;
            Integer jobRateplanChargeCounter = 0;
            Integer jobRatePlanChargeTierCounter = 0;
            Integer iJobProductSequenceNo = 1;
            Integer iJobRatePlanSequenceNo = 1;
            List<Job_Product__c> listJobProducts = new List<Job_Product__c>();
            List<Job_Rate_Plan__c> listJobRatePlans = new List<Job_Rate_Plan__c>();
            JobProductClass jobProductClass;
            JobRatePlanClass jobRatePlanClass;
            JobRatePlanChargeClass jobRatePlanChargeClass;
            JobRatePlanChargeTierClass jobTierClass;

            Job__c job = JobCreationUtil.getJob(jobId);
            jobClass.job = job;
            listJobProducts = JobCreationUtil.getListJobProducts(jobid);
            //add listJobProducts to jobProductClass
            for(Job_Product__c qp : listJobProducts) {
                jobProductClass = new JobProductClass();
                jobProductClass.jobProductCounter = ++jobProductCounter;
                jobProductClass.jobproduct = qp;
                jobClass.jobProducts.add(jobProductClass);
            }
            //get the list of jobProduct Ids in to Map
            mapJobProducts = JobCreationUtil.getMapJobProducts(listJobProducts);
            Set<Id> mapJobProductKeyset = new Set<Id>();
            mapJobProductKeyset = mapJobProducts.keySet();
            List<Id> jobProductIds = new List<Id>();
            Integer mapJobProductKeysetSize = mapJobProductKeyset.size();

            //Add all the ids to list jobProductIds
            jobProductIds.addAll(mapJobProductKeyset);

            map<Id, list<Job_Rate_Plan_Charge_Tier__c>> map_JobChargeId_JobTiers = JobCreationUtil.queryTiersBasedOnJobId(job.Id);
            //getListJobRatePlans returns listJobRatePlans 
            if(!isRenewal) {
                listJobRatePlans = JobCreationUtil.getListJobRatePlans(jobProductIds);
            } else {
                listJobRatePlans = JobCreationUtil.getListJobRatePlansForRenew(jobProductIds);
            }

            //added by ram,INVOICEIT-535
            decimal chargeQuantity = 0;
            // ended by ram        

            if(listJobRatePlans != null) {
                //get the listJobRatePlanCharges from the listJobRatePlans 
                for(Job_Rate_Plan__c qr:listJobRatePlans ) {
                    jobProductClass = mapJobProducts.get(qr.Job_Product__c);
                    jobRatePlanClass = new JobRatePlanClass();
                    jobRatePlanClass.jobrateplan = qr;

                    for(Job_Rate_Plan_Charge__c qrpc : qr.Job_Rate_Plan_Charge__r) {
                        jobRatePlanChargeClass = new JobRatePlanChargeClass();
                        jobRatePlanChargeClass.jobrateplancharge = qrpc;
                        jobRatePlanChargeClass.jobRatePlanChargeCounter = ++jobRateplanChargeCounter;

                        //add the tiers
                        if(map_JobChargeId_JobTiers.containsKey(qrpc.Id)) {
                            
                            // started by ram,INVOICEIT-535,
                            if(jobRatePlanChargeClass.jobrateplancharge.Quantity__c > 0 && (jobRatePlanChargeClass.jobrateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME || jobRatePlanChargeClass.jobrateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE)) 
                              chargeQuantity = jobRatePlanChargeClass.jobrateplancharge.Quantity__c;
                            // ended by ram    
                                
                            for(Job_Rate_Plan_Charge_Tier__c orderTier : map_JobChargeId_JobTiers.get(qrpc.Id)) {                                                    
                                // started by ram INVOICEIT-535, to populate the unit price
                                if(((orderTier.Start_Unit__c <= chargeQuantity && orderTier.End_Unit__c >= chargeQuantity)
                                     ||
                                    (orderTier.Start_Unit__c <= chargeQuantity && orderTier.End_Unit__c == null)) 
                                    && jobRatePlanChargeClass.jobrateplancharge.Quantity__c > 0 
                                    && (jobRatePlanChargeClass.jobrateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME
                                         || jobRatePlanChargeClass.jobrateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE))
                                    {
                                                    
                                        jobRatePlanChargeClass.jobrateplancharge.Unit_Price__c = orderTier.Unit_Price__c;
                                        jobRatePlanChargeClass.jobrateplancharge.Cost_Price__c = orderTier.Unit_Cost_Price__c;
                                  }
                                  // ended by ram   

                                jobTierClass = new jobRatePlanChargeTierClass(); 
                                jobTierClass.jobRatePlanChargeTier = orderTier;
                                jobTierClass.jobRatePlanChargeTierCounter = ++jobRatePlanChargeTierCounter;
                                jobRatePlanChargeClass.jobRatePlanChargeTiers.add(jobTierClass);
                            }
                        }
                        jobRatePlanClass.jobRatePlanCharges.add(jobRatePlanChargeClass);
                    }

                    jobRatePlanClass.jobRatePlanCounter = ++jobRatePlanCounter;
                    jobProductClass.jobRatePlans.add(jobRatePlanClass);

                    mapJobProducts.put(qr.Job_Product__c,jobProductClass);
                }

                jobClass = new JobClass();
                jobClass.job = job;
                Integer iJobProductSize = listJobProducts.size();
                for(integer i = 0; i < iJobProductSize; i++) {
                    Id jobProductId = listJobProducts.get(i).Id;
                    JobProductClass qpc = mapJobProducts.get(jobProductId); 
                    qpc.jobProductCounter = ++jobProductCounter;
                    jobClass.jobProducts.add(qpc);
                }                   

                iJobProductSequenceNo = 1;
                
                for(JobProductClass jobProductClas : jobClass.jobProducts) {
                    jobProductClas.jobproduct.SequenceNumber__c = iJobProductSequenceNo;
                    iJobProductSequenceNo ++;
                }

                iJobRatePlanSequenceNo = 1;
                for(JobProductClass jobProductClas : jobClass.jobProducts) {
                    for(JobRatePlanClass jobrateplan : jobProductClas.jobRatePlans) {
                        jobrateplan.jobrateplan.SequenceNumber__c = iJobRatePlanSequenceNo;
                        iJobRatePlanSequenceNo ++;
                    }
                }
            }

            return jobClass;   
        }
    }