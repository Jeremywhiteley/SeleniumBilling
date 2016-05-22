global with sharing class BatchForCalculatingMRR implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts {

    global String query;
    global String errorLog;
    global Batch_Jobs__c batchJobsObj;
    global string sSelectedBatches;
    global boolean isBatchJobsExecuting = false;
    map<Id, decimal> mapOfIdNMRR = new map<Id, decimal>();
    map<Id, decimal> mapOfIdNMRRWithTax = new map<Id, decimal>();
    list<MRR__c> listOfMRR = new list<MRR__c>();
    MRR__c mrrObj;
    map<Id, String> mapOfCurrencyIdISOCode = new map<Id, String>();
    global set<Id> setOfAccIdsToUpdateMRR = new set<Id>();

    global BatchForCalculatingMRR(String query) {
        this.query = query;
    }
    //Added by Shruthi:INVOICEIT-399,This invokes when the batch is called from InvoiceIt Batch Jobs scheduler 
    global BatchForCalculatingMRR(String query, boolean isExecuting) {
        
        this.isBatchJobsExecuting = isExecuting;
        sSelectedBatches = Configuration__c.getValues('INVOICEIT_BATCH_JOBS_TO_PROCESS').String_Value__c;
        if(sSelectedBatches != null && sSelectedBatches.contains('MRR Calculation'))        
            this.query = query;
        else
            this.query='SELECT Name FROM Job__c WHERE Name = null';
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        errorLog = '';
        //Added by Shruthi:INVOICEIT-399,This inserts the record for MRR batch in the InvoiceIt Batch Jobs object
        if(isBatchJobsExecuting && sSelectedBatches != null && sSelectedBatches.contains('MRR Calculation')){
            batchJobsObj = new Batch_Jobs__c(name = DateTime.now().format('yyyy-MM-dd'),Start_Date_and_Time__c = system.now(),Status__c = 'Started',Type__c = 'MRR Calculation');
            insert batchJobsObj;    
        }
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<sObject> scope) {
        // Vinod KR INVOICEIT-327 MRR object with dated values
        map<Id, Job__c> mapOfJobsToUpdate = new map<Id, Job__c>();
        Job__c job;
        Account account;
        set<Id> setOfAccountsOfInterest = new set<Id>();
        list<Account> listOfAccountsToUpdate = new list<Account>();
        list<Job_Rate_Plan_Charge__c> listOfJobRateplanCharges = new list<Job_Rate_Plan_Charge__c>();
        list<Job_Rate_Plan_Charge__c> listOfChargesToBeUpdated = new list<Job_Rate_Plan_Charge__c>();
        
        for(sObject s : scope) {
            job = (Job__c)s;
            job.Todays_MRR__c = 0;
            job.Todays_MRR_With_Tax__c = 0;
            mapOfJobsToUpdate.put(s.Id, job);
            setOfAccountsOfInterest.add(job.Account__c);
            mapOfCurrencyIdISOCode.put(job.CurrencyL__c, job.CurrencyL__r.Name);
            
        }

        Id currentJobId;
        try {
            //Added By shruthi: INVOICEIT-441
            listOfJobRateplanCharges =[SELECT id,Price_Type__c,Service_Activation_Date__c,Service_End_Date__c,Charge_Date__c 
                                       From Job_Rate_Plan_Charge__c
                                       WHERE Job_Rate_Plan__r.Job_Product__r.Job__c IN: mapOfJobsToUpdate.keyset()];
            
            // Aggregate query for Monthly Charges
            AggregateResult[] groupedResultsMonthly = [SELECT sum(Net_Total__c) priceSum,sum(Tax__c) taxSum, sum(Vat__c) vatSum, Job_Rate_Plan__r.Job_Product__r.Job__c jobId
                                                       FROM Job_Rate_Plan_Charge__c 
                                                       WHERE Job_Rate_Plan__r.Job_Product__r.Job__c IN: mapOfJobsToUpdate.keyset()
                                                       AND
                                                       Service_Activation_Date__c <=: system.today()
                                                       AND
                                                       (
                                                               Service_End_Date__c = null
                                                               OR
                                                               Service_End_Date__c >=: system.today()
                                                       )
                                                       AND
                                                       Price_Type__c =: system.Label.OptionMonthly
                                                       GROUP BY Job_Rate_Plan__r.Job_Product__r.Job__c
                                                       ];
            // Vinod KR INVOICEIT-325 MRR object with dated values
            // Aggregate query for Quarterly Charges
            AggregateResult[] groupedResultsQuarterly = [SELECT sum(Net_Total__c) priceSum,sum(Tax__c) taxSum, sum(Vat__c) vatSum, Job_Rate_Plan__r.Job_Product__r.Job__c jobId
                                                         FROM Job_Rate_Plan_Charge__c 
                                                         WHERE Job_Rate_Plan__r.Job_Product__r.Job__c IN: mapOfJobsToUpdate.keyset()
                                                         AND
                                                         Service_Activation_Date__c <=: system.today()
                                                         AND
                                                         (
                                                                 Service_End_Date__c = null
                                                                 OR
                                                                 Service_End_Date__c >=: system.today()
                                                         )
                                                         AND
                                                         Price_Type__c =: system.Label.OptionQuarterly
                                                         GROUP BY Job_Rate_Plan__r.Job_Product__r.Job__c
                                                         ];

            // Aggregate query for HalfYearly Charges
            AggregateResult[] groupedResultsHalfYearly = [SELECT sum(Net_Total__c) priceSum,sum(Tax__c) taxSum, sum(Vat__c) vatSum, Job_Rate_Plan__r.Job_Product__r.Job__c jobId
                                                          FROM Job_Rate_Plan_Charge__c 
                                                          WHERE Job_Rate_Plan__r.Job_Product__r.Job__c IN: mapOfJobsToUpdate.keyset()
                                                          AND
                                                          Service_Activation_Date__c <=: system.today()
                                                          AND
                                                          (
                                                                  Service_End_Date__c = null
                                                                  OR
                                                                  Service_End_Date__c >=: system.today()
                                                          )
                                                          AND
                                                          Price_Type__c =: system.Label.OptionHalfYearly
                                                          GROUP BY Job_Rate_Plan__r.Job_Product__r.Job__c
                                                          ];

            // Aggregate query for Annual Charges
            AggregateResult[] groupedResultsAnnual = [SELECT sum(Net_Total__c) priceSum,sum(Tax__c) taxSum, sum(Vat__c) vatSum, Job_Rate_Plan__r.Job_Product__r.Job__c jobId
                                                      FROM Job_Rate_Plan_Charge__c 
                                                      WHERE Job_Rate_Plan__r.Job_Product__r.Job__c IN: mapOfJobsToUpdate.keyset()
                                                      AND
                                                      Service_Activation_Date__c <=: system.today()
                                                      AND
                                                      (
                                                              Service_End_Date__c = null
                                                              OR
                                                              Service_End_Date__c >=: system.today()
                                                      )
                                                      AND
                                                      Price_Type__c =: system.Label.OptionAnnual
                                                      GROUP BY Job_Rate_Plan__r.Job_Product__r.Job__c
                                                      ];                                                                                                          


            Id currencyId;  
            decimal sumOfPrices;
            decimal sumOfVat;
            decimal sumOfTax;
            decimal MRR;
            decimal MRRWithTax;

            for(AggregateResult aggResult : groupedResultsMonthly) {
                currentJobId = (Id) aggResult.get('jobId');
                currencyId = mapOfJobsToUpdate.get(currentJobId).CurrencyL__c;
                sumOfPrices = (decimal) aggResult.get('priceSum');
                sumOfVat = (decimal) aggResult.get('taxSum');
                sumOfTax = (decimal) aggResult.get('vatSum');

                job = mapOfJobsToUpdate.get(currentJobId);
                job.Todays_MRR__c = job.Todays_MRR__c + sumOfPrices;
                job.Todays_MRR_With_Tax__c = job.Todays_MRR_With_Tax__c + sumOfPrices + sumOfVat + sumOfTax;
                //Added by MG: INVOICEIT-543
                job.Annual_Contract_Value_ACV__c = job.Todays_MRR__c * 12;

                if(mapOfIdNMRR.containsKey(currencyId)){
                    MRR = mapOfIdNMRR.get(currencyId);
                    MRR = MRR + sumOfPrices;
                    mapOfIdNMRR.put(currencyId,MRR);
                }else{
                    mapOfIdNMRR.put(currencyId,sumOfPrices);
                }

                if(mapOfIdNMRRWithTax.containsKey(currencyId)){
                    MRRWithTax = mapOfIdNMRRWithTax.get(currencyId);
                    MRRWithTax = MRRWithTax + sumOfPrices + sumOfVat + sumOfTax;
                    mapOfIdNMRRWithTax.put(currencyId,MRRWithTax);
                }else{
                    mapOfIdNMRRWithTax.put(currencyId,sumOfPrices + sumOfVat + sumOfTax);
                }  
            }

            for(AggregateResult aggResult : groupedResultsQuarterly) {
                currentJobId = (Id) aggResult.get('jobId');
                currencyId = mapOfJobsToUpdate.get(currentJobId).CurrencyL__c;
                sumOfPrices = (decimal) aggResult.get('priceSum')/3;
                sumOfVat = (decimal) aggResult.get('taxSum')/3;
                sumOfTax = (decimal) aggResult.get('vatSum')/3;

                job = mapOfJobsToUpdate.get(currentJobId);
                job.Todays_MRR__c = job.Todays_MRR__c + sumOfPrices;
                job.Todays_MRR_With_Tax__c = job.Todays_MRR_With_Tax__c + sumOfPrices + sumOfVat + sumOfTax;
                //Added by MG: INVOICEIT-543
                job.Annual_Contract_Value_ACV__c = job.Todays_MRR__c * 12;

                if(mapOfIdNMRR.containsKey(currencyId)){
                    MRR = mapOfIdNMRR.get(currencyId);
                    MRR = MRR + sumOfPrices;
                    mapOfIdNMRR.put(currencyId,MRR);
                }else{
                    mapOfIdNMRR.put(currencyId,sumOfPrices);
                }

                if(mapOfIdNMRRWithTax.containsKey(currencyId)){
                    MRRWithTax = mapOfIdNMRRWithTax.get(currencyId);
                    MRRWithTax = MRRWithTax + sumOfPrices + sumOfVat + sumOfTax;
                    mapOfIdNMRRWithTax.put(currencyId,MRRWithTax);
                }else{
                    mapOfIdNMRRWithTax.put(currencyId,sumOfPrices + sumOfVat + sumOfTax);
                }  
            }

            for(AggregateResult aggResult : groupedResultsHalfYearly) {
                currentJobId = (Id) aggResult.get('jobId');
                currencyId = mapOfJobsToUpdate.get(currentJobId).CurrencyL__c;
                sumOfPrices = (decimal) aggResult.get('priceSum')/6;
                sumOfVat = (decimal) aggResult.get('taxSum')/6;
                sumOfTax = (decimal) aggResult.get('vatSum')/6;

                job = mapOfJobsToUpdate.get(currentJobId);
                job.Todays_MRR__c = job.Todays_MRR__c + sumOfPrices;
                job.Todays_MRR_With_Tax__c = job.Todays_MRR_With_Tax__c + sumOfPrices + sumOfVat + sumOfTax;
                //Added by MG INVOICEIT-543
                job.Annual_Contract_Value_ACV__c = job.Todays_MRR__c * 12;

                if(mapOfIdNMRR.containsKey(currencyId)){
                    MRR = mapOfIdNMRR.get(currencyId);
                    MRR = MRR + sumOfPrices;
                    mapOfIdNMRR.put(currencyId,MRR);
                }else{
                    mapOfIdNMRR.put(currencyId,sumOfPrices);
                }

                if(mapOfIdNMRRWithTax.containsKey(currencyId)){
                    MRRWithTax = mapOfIdNMRRWithTax.get(currencyId);
                    MRRWithTax = MRRWithTax + sumOfPrices + sumOfVat + sumOfTax;
                    mapOfIdNMRRWithTax.put(currencyId,MRRWithTax);
                }else{
                    mapOfIdNMRRWithTax.put(currencyId,sumOfPrices + sumOfVat + sumOfTax);
                }  
            } 

            for(AggregateResult aggResult : groupedResultsAnnual) {
                currentJobId = (Id) aggResult.get('jobId');
                currencyId = mapOfJobsToUpdate.get(currentJobId).CurrencyL__c;
                sumOfPrices = (decimal) aggResult.get('priceSum')/12;
                sumOfVat = (decimal) aggResult.get('taxSum')/12;
                sumOfTax = (decimal) aggResult.get('vatSum')/12;

                job = mapOfJobsToUpdate.get(currentJobId);
                job.Todays_MRR__c = job.Todays_MRR__c + sumOfPrices;
                job.Todays_MRR_With_Tax__c = job.Todays_MRR_With_Tax__c + sumOfPrices + sumOfVat + sumOfTax;
                //Added by MG for JIRA task INVOICEIT-543
                job.Annual_Contract_Value_ACV__c = job.Todays_MRR__c * 12;

                if(mapOfIdNMRR.containsKey(currencyId)){
                    MRR = mapOfIdNMRR.get(currencyId);
                    MRR = MRR + sumOfPrices;
                    mapOfIdNMRR.put(currencyId,MRR);
                }else{
                    mapOfIdNMRR.put(currencyId,sumOfPrices);
                }

                if(mapOfIdNMRRWithTax.containsKey(currencyId)){
                    MRRWithTax = mapOfIdNMRRWithTax.get(currencyId);
                    MRRWithTax = MRRWithTax + sumOfPrices + sumOfVat + sumOfTax;
                    mapOfIdNMRRWithTax.put(currencyId,MRRWithTax);
                }else{
                    mapOfIdNMRRWithTax.put(currencyId,sumOfPrices + sumOfVat + sumOfTax);
                }  
            } 

            update mapOfJobsToUpdate.values(); 
            
            //Added By shruthi INVOICEIT-441 to update subscription status field
            for(Job_Rate_Plan_Charge__c jrpc:listOfJobRateplanCharges){
                if(jrpc.Price_Type__c !=system.Label.OptionOneTime){                
                    if(jrpc.Service_Activation_Date__c <= system.today() && (jrpc.Service_End_Date__c == null ||jrpc.Service_End_Date__c >= system.today())){
                        jrpc.Subscription_Status__c = 'Active';
                    }
                }else if(jrpc.Price_Type__c == system.Label.OptionOneTime && jrpc.Charge_Date__c == null){
                        jrpc.Subscription_Status__c = 'Active';
                }
                else{                   
                        jrpc.Subscription_Status__c = 'Inactive';
                }
                listOfChargesToBeUpdated.add(jrpc);
                
            }
            if(!listOfChargesToBeUpdated.isEmpty()){                
                update listOfChargesToBeUpdated;
            } 
            
            Id accountId;
            Double todaysMRR;
            Double todaysMRRWithTax;

            //Query the sum(total) for all jobs pertaining to these accounts
            AggregateResult[] groupedResults_MRR = [SELECT Account__c accountId, SUM(Todays_MRR__c) todaysMRR, SUM(Todays_MRR_With_Tax__c) todaysMRRWithTax
                                                    FROM Job__c 
                                                    WHERE Account__c IN : setOfAccountsOfInterest
                                                    GROUP BY Account__c];

            for(AggregateResult result : groupedResults_MRR) {
                accountId = (Id) result.get('accountId');
                todaysMRR = (Double) result.get('todaysMRR');
                todaysMRRWithTax = (Double) result.get('todaysMRRWithTax');
                account = new Account(Id = accountId, Todays_MRR__c = todaysMRR, Todays_MRR_With_Tax__c = todaysMRRWithTax);
                listOfAccountsToUpdate.add(account);
                // RamaKrishna.V en-96 add account ids
                setOfAccIdsToUpdateMRR.add(accountId);
            }
            
            if(!listOfAccountsToUpdate.isEmpty()){
                update listOfAccountsToUpdate;
            }       

        }   
        catch(Exception ex) {
            errorLog += system.Label.ExceptionMessage + ex.getTypeName() + ':'+ex.getMessage() + ':'  + ex.getLineNumber() + ':' + ex.getStackTraceString() + '\n';
            errorLog += ': ' + currentJobId; 
        } 
    }

    global void finish(Database.BatchableContext BC) {
        // Here we are inserting the new records for MRR object MRR_With_Tax__c, MRR_WithOut_Tax__c and related currency
        try {
            // Ram en-96 update the accounts which doesnot have valid mrr values
            list<Account> lstAcctoUpdate = [SELECT Todays_MRR__c,Todays_MRR_With_Tax__c 
                                            FROM Account
                                            WHERE ID NOT IN: setOfAccIdsToUpdateMRR
                                            AND Todays_MRR__c != null AND Todays_MRR__c != 0
                                            ];
            if(lstAcctoUpdate.size() > 0 ){
                for(Account acc : lstAcctoUpdate){
                    acc.Todays_MRR__c = 0;
                    acc.Todays_MRR_With_Tax__c = 0;
                }
                update lstAcctoUpdate;
            }                               
            
                                            
            for(Id currencyIdMRR : mapOfIdNMRR.keyset()) {
                mrrObj = new MRR__c();
                mrrObj.Date__c = system.today();
                mrrObj.Name = DateTime.now().format('yyyy-MM-dd');
                mrrObj.Currency__c = currencyIdMRR;
                mrrObj.MRR_Without_Tax__c = mapOfIdNMRR.get(currencyIdMRR);
                mrrObj.MRR_With_Tax__c = mapOfIdNMRRWithTax.get(currencyIdMRR);
                mrrObj.MRR_Without_Tax_Currency__c = mapOfIdNMRR.get(currencyIdMRR);
                mrrObj.MRR_With_Tax_Currency__c = mapOfIdNMRRWithTax.get(currencyIdMRR);
                // Laxman INVOICEIT-327 Major work was completed by Vinod. I have populated the "CurrencyIsoCode" field if it is a multi currency org.
                if(UserInfo.isMultiCurrencyOrganization()) {
                    Sobject sObjectMRRObj = mrrObj;
                    sObjectMRRObj.put('CurrencyIsoCode', (string) mapOfCurrencyIdISOCode.get(currencyIdMRR));
                }
                listOfMRR.add(mrrObj);
            } 

            if(!listOfMRR.isEmpty()){
                insert listOfMRR;
            }
        }   
        catch(Exception ex) {
            errorLog += system.Label.ExceptionMessage + ex.getTypeName() + ':'+ex.getMessage() + ':'  + ex.getLineNumber() + ':' + ex.getStackTraceString() + '\n';
        }  
        //Added by Shruthi INVOICEIT-399,This updates status and completed time for the InvoiceIt batch Jobs object record-MRR
        if(isBatchJobsExecuting){
            if(sSelectedBatches != null && sSelectedBatches.contains('MRR Calculation')){
                batchJobsObj.Completed_Date_and_Time__c = system.now();
                batchJobsObj.Status__c = CommonUtilClass.STATUS_COMPLETED;
                if(errorLog != ''){
                    batchJobsObj.Status__c = CommonUtilClass.STATUS_COMPLETED_WITH_ERRORS;
                    
                    // the maximum size of Long Text Area is 32768. If error log is more than this then create the attachment with error log 
                    if(errorLog.Length() < 32768) {
                        batchJobsObj.Exception_Log__c = errorLog; 
                    } else {
                        Attachment attachment = new Attachment(Body = Blob.valueOf(errorLog), Name = 'ErrorLog.txt', ParentId = batchJobsObj.Id );
                        insert attachment;  
                        batchJobsObj.Exception_Log__c = 'Error log is attached as an attachment, you can find the attachment in releated list';
                    }
                } 
             upsert batchJobsObj;
            }    
            //Added by Shruthi INVOICEIT-399,This will invoke another batch 
            BatchRenewOrders batchRenewOrdersObj = new BatchRenewOrders(true);  
            Database.executeBatch(batchRenewOrdersObj,1);
        }   
    }
  }