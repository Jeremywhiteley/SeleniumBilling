public with sharing class ControllerSendOrder 
    {
        public Job__c job {get;set;}
        public List<Job_Product__c> listJobProducts = new List<Job_Product__c>();
        public list<Job_Rate_Plan_Charge__c> listJobRatePlanCharge {get;set;}
        public string sLogo {set; get;}
        private map<Id,JobProductClass> mapJobProducts = new  map<Id,JobProductClass>();
        public list<Job_Rate_Plan__c> listJobRatePlans = new  list<Job_Rate_Plan__c>();
        public Boolean isOtherCharge{get;set;}
        public Boolean isOneTimeCharge{get;set;}
        public Boolean isMonthlyCharge{get;set;}
        public JobClass jobClass {get;set;}
        public JobProductClass jobProductClass {get;set;}
        public JobRatePlanClass jobRatePlanClass {get;set;}
        public JobRatePlanChargeClass jobRatePlanChargeClass = new JobRatePlanChargeClass();
        public decimal sumOfNetTotalOneTime {get;set;}
        public decimal sumOfSubTotalOneTime {get;set;}
        public decimal sumOfNetTotalMonthly {get;set;}
        public decimal sumOfSubTotalMonthly {get;set;}
        public decimal sumOfNetTotalOther {get;set;}
        public decimal sumOfSubTotalOther {get;set;}
        public String sPrefix {get; set;}
        
        public ControllerSendOrder(ApexPages.StandardController stdController) { 
            sPrefix = CommonUtilClass.getPrefix();
            this.job = (Job__c)stdController.getRecord();
            isOtherCharge = false;
            isOneTimeCharge = false;
            isMonthlyCharge = false;
            jobClass = new JobClass();
            jobClass.job = job;
            if(job.id != null) {
                this.job = JobCreationUtil.getJob(job.id);           
                listJobProducts = JobCreationUtil.getListJobProducts(job.id);
                
                //add listJobProducts to jobProductClass
                for(Job_Product__c jp : listJobProducts) {
                    jobProductClass = new JobProductClass();
                    jobProductClass.jobproduct = jp;
                    jobClass.jobProducts.add(jobProductClass);
                }
                
                //get the list of jobProduct Ids in to Map
                mapJobProducts = JobCreationUtil.getMapJobProducts(listJobProducts);
                Set<Id> mapJobProductKeyset = new Set<Id>();
                mapJobProductKeyset = mapJobProducts.keySet();
                List<Id> jobProductIds = new List<Id>();
                Integer mapJobProductKeysetSize = mapJobProductKeyset.size();
                jobProductIds.addAll(mapJobProductKeyset);
                listJobRatePlans = JobCreationUtil.getListJobRatePlans(jobProductIds);
                if(listJobRatePlans != null ){
                    for(Job_Rate_Plan__c jr : listJobRatePlans ) {
                        jobProductClass = mapJobProducts.get(jr.Job_Product__c);
                        jobRatePlanClass = new JobRatePlanClass();
                        jobRatePlanClass.jobrateplan = jr;
                        for(Job_Rate_Plan_Charge__c jrpc : jr.Job_Rate_Plan_Charge__r) {
                            jobRatePlanChargeClass = new JobRatePlanChargeClass();
                            jobRatePlanChargeClass.jobrateplancharge = jrpc;
                            jobRatePlanClass.jobRatePlanCharges.add(jobRatePlanChargeClass);
                        }
                        jobProductClass.jobRatePlans.add(jobRatePlanClass);
                        mapJobProducts.remove(jr.Job_Product__c);
                        mapJobProducts.put(jr.Job_Product__c,jobProductClass);
                    }
                    JobClass = new JobClass();
                    jobClass.job = job;
                    for(JobProductClass jpc : mapJobProducts.values()) {
                        jobClass.jobProducts.add(jpc);
                    }                
                } 
            }
            
            list<StaticResource> listOfStaticResources = [SELECT Id,SystemModstamp FROM StaticResource WHERE Name = 'logo'];
            if(!listOfStaticResources.isEmpty()) {
                
               sLogo = '/resource/'+listOfStaticResources[0].SystemModStamp.getTime()+'/logo';
            } else {
                sLogo = (Configuration__c.getValues('COMPANY_LOGO').String_Value__c);
            }
            
            listJobProducts = JobCreationUtil.getListJobProducts(job.id);

            string sQuery = 'SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Job_Rate_Plan_Charge__c') + ',' 
                            + 'Job_Rate_Plan__r.Job_Product__r.name,Job_Rate_Plan__r.SequenceNumber__c,Job_Rate_Plan__r.Job_Product__r.SequenceNumber__c,Job_Rate_Plan__r.Job_Product__r.Product_Code__c'
                            + ' FROM Job_Rate_Plan_Charge__c where Job_Rate_Plan__r.Job_Product__c IN:listJobProducts  Order By Job_Rate_Plan__r.Job_Product__r.SequenceNumber__c,Sequence_No__c,Job_Rate_Plan__r.SequenceNumber__c';
                             
            sQuery = String.escapeSingleQuotes(sQuery);
            listJobRatePlanCharge = Database.query(sQuery);
            
            //checking is there any other charge except one time or monthly
            list<Job_Rate_Plan_Charge__c> listofOtherChargesExceptMonthandOne;
            listofOtherChargesExceptMonthandOne = [SELECT id,Name, Job_Rate_Plan__c,Price_Type__c, Job_Rate_Plan__r.Job_Product__r.Job__c
                                                   FROM Job_Rate_Plan_Charge__c
                                                   WHERE Job_Rate_Plan__r.Job_Product__r.Job__r.Id = :job.id AND (Price_Type__c !='One Time' AND Price_Type__c !='Monthly')];
            
            //checking for One time Charge
            list<Job_Rate_Plan_Charge__c> listofOtherChargesOneTime;
            listofOtherChargesOneTime = [SELECT id,Name, Job_Rate_Plan__c,Price_Type__c, Job_Rate_Plan__r.Job_Product__r.Job__c
                                                   FROM Job_Rate_Plan_Charge__c
                                                   WHERE Job_Rate_Plan__r.Job_Product__r.Job__c = :job.id AND Price_Type__c = 'One Time'];
            
            //checking for Monthly Charge
            list<Job_Rate_Plan_Charge__c> listofOtherChargesExceptMonthly;
            listofOtherChargesExceptMonthly = [SELECT id,Name, Job_Rate_Plan__c,Price_Type__c, Job_Rate_Plan__r.Job_Product__r.Job__c
                                               FROM Job_Rate_Plan_Charge__c
                                               WHERE Job_Rate_Plan__r.Job_Product__r.Job__c = :Job.id AND Price_Type__c ='Monthly'];
                                                   
             AggregateResult[] groupedResultsOfChargeOneTime = [SELECT sum(Net_Total__c) priceSum,sum(Price__c) subtotalSum,Job_Rate_Plan__r.Job_Product__r.Job__c JobId 
                                                                FROM Job_Rate_Plan_Charge__c 
                                                                WHERE Job_Rate_Plan__r.Job_Product__r.Job__c = :job.id
                                                                AND Price_Type__c = 'One Time'
                                                                GROUP BY Job_Rate_Plan__r.Job_Product__r.Job__c
                                                                ];
             AggregateResult[] groupedResultsOfChargeMonthly = [SELECT sum(Net_Total__c) priceSum,sum(Price__c) subtotalSum,Job_Rate_Plan__r.Job_Product__r.Job__c JobId 
                                                                FROM Job_Rate_Plan_Charge__c 
                                                                WHERE Job_Rate_Plan__r.Job_Product__r.Job__c = :job.id
                                                                AND Price_Type__c ='Monthly'
                                                                GROUP BY Job_Rate_Plan__r.Job_Product__r.Job__c
                                                                ];
             AggregateResult[] groupedResultsOfChargeOthers = [SELECT sum(Net_Total__c) priceSum,sum(Price__c) subtotalSum,Job_Rate_Plan__r.Job_Product__r.Job__c JobId 
                                                               FROM Job_Rate_Plan_Charge__c 
                                                               WHERE Job_Rate_Plan__r.Job_Product__r.Job__c = :job.id
                                                               AND (Price_Type__c !='One Time' AND Price_Type__c !='Monthly')
                                                               GROUP BY Job_Rate_Plan__r.Job_Product__r.Job__c
                                                               ];    
             for(AggregateResult aggResult : groupedResultsOfChargeOneTime) {
                 sumOfNetTotalOneTime = (decimal) aggResult.get('priceSum');
                 sumOfSubTotalOneTime = (decimal) aggResult.get('subtotalSum');
             }  
             
             for(AggregateResult aggResult : groupedResultsOfChargeMonthly) {
                    sumOfNetTotalMonthly = (decimal) aggResult.get('priceSum');
                    sumOfSubTotalMonthly = (decimal) aggResult.get('subtotalSum');
             }
           
             for(AggregateResult aggResult : groupedResultsOfChargeOthers) {
                    sumOfNetTotalOther = (decimal) aggResult.get('priceSum');
                    sumOfSubTotalOther = (decimal) aggResult.get('subtotalSum');
             } 
             if(listofOtherChargesExceptMonthandOne.size() == 0){
                isOtherCharge = true;
             }
           
             if(listofOtherChargesOneTime.size() > 0){
                isOneTimeCharge = true;
             }
           
             if(listofOtherChargesExceptMonthly.size() > 0){
                isMonthlyCharge = true;
             }
            
        }
    }