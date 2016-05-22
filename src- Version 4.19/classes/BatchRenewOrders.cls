/*
     * The Auto-Renewal Service is an easy and convenient way to ensure that orders are not cancelled/Expired. 
     * With Auto Renewal Service the Order date will be extended automatically before it expires, 
     * thereby providing you with seamless service. For More Information refer this Ticket : INVOICEIT-395
     * This class mainly consists of Renewing of Order,Quote and Opportunity
     * @author Dev M,Naveen Mallela,Shruthi Bomma,Invoice IT
     * Copyright (c) 2011, Invoice IT, Salesforce.com Inc.
     * All rights reserved.
     */

    global with sharing class BatchRenewOrders implements Database.Batchable<sObject>, Database.Stateful{
        global String sPrefix = '';
        global date advanceProcessDate ;  
        global date renewProcessDate ;
        global integer iAdvanceNotice;
        global String errorLog = '';
        global boolean isBatchJobsExecuting = false;
        global Batch_Jobs__c batchJobsObj;
        global String squery;
        global string sSelectedBatches;
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        map<String, Custom_Mappings__c> mapCustomMappings = Custom_Mappings__c.getAll();
        
        //Added by Shruthi for INVOICEIT-399,This invokes when the batch is called from BatchJobs scheduler
        global BatchRenewOrders(boolean isExecuting) {
            this.isBatchJobsExecuting = isExecuting;
            //retrieing the custom setting picklist values for Batch Jobs picklist
            sSelectedBatches = Configuration__c.getValues('INVOICEIT_BATCH_JOBS_TO_PROCESS').String_Value__c;
            if( (sSelectedBatches != null && sSelectedBatches.contains('Auto Renewals')) || !isExecuting)   
                squery='SELECT Id,Name,OwnerId,'+sPrefix+'CurrencyL__c,'+sPrefix+'Account__c,'+sPrefix+'Renewal_Terms_Months__c,Auto_Renew__c,Renew_to__c,Service_Activation_Date__c,Service_End_Date__c,Owner.Email FROM Job__c WHERE Auto_Renew__c = true AND Service_End_Date__c <=: renewProcessDate AND Auto_Renewal_Complete__c = false AND Is_Billing_Master_Order__c = false Order by CreatedDate ASC';
            else
                squery='SELECT Name FROM '+sPrefix+'Job__c WHERE Name = null';  
        }

        global Database.QueryLocator start(Database.BatchableContext BC){
            sPrefix = CommonUtilClass.getPrefix();
            iAdvanceNotice = (integer) Configuration__c.getValues('NO_OF_DAYS_FOR_AUTO_RENEWAL').Number_Value__c;
            //Dec 31 – (30)  clone order
            date myDate = system.today();
            advanceProcessDate= myDate.addDays(iAdvanceNotice);
            advanceProcessDate = advanceProcessDate.addDays(1);
            renewProcessDate = myDate.addDays(iAdvanceNotice);
            //Added by Shruthi:INVOICEIT-399,This inserts the record for Renew batch in the BatchJobs object
            batchJobsObj = new Batch_Jobs__c(name = DateTime.now().format('yyyy-MM-dd'),Start_Date_and_Time__c = system.now(),Status__c = 'Started',Type__c ='Auto Renewals');
            insert batchJobsObj; 
            return Database.getQueryLocator(squery);
        }
        global void execute(Database.BatchableContext BC, list<Job__c> scope){
            try{
                for(Job__c  orderObj : scope) {
                    //Here we are querying Grouping charges
                    list<Job_Rate_Plan_Charge__c> listofJobrateplancharge = new list<Job_Rate_Plan_Charge__c>();
                    listofJobrateplancharge=[select id,Order__c from Job_Rate_Plan_Charge__c where Auto_Renew__c = true and Grouping__c != null and Order__c =: orderObj.Id];
                    //checking grouping charges list is empty or not
                    if(listofJobrateplancharge.isempty()){
                        // Here we are cloning the job and related childs for renewing
                        Job__c  newRenewOrder = new Job__c();
                        // Here we are populating the class
                        JobClass jobClass = ClassAfterOnJob.populateJobClass(orderObj.Id, true );
                        if(orderObj.Renew_to__c == 'Order' || orderObj.Renew_to__c == null || orderObj.Renew_to__c == ''){                                          
                            // cloning the order
                            newRenewOrder = jobClass.job.clone(false);
                            newRenewOrder.Number_Of_Terms__c = newRenewOrder.Renewal_Terms_Months__c;
                            newRenewOrder.Service_Activation_Date__c = newRenewOrder.Service_End_Date__c.addDays(1);
                            newRenewOrder.Order_Type__c = 'Renewal';
                            
                            if(newRenewOrder.Renewal_Terms_Months__c !=null)
                                newRenewOrder.Service_End_Date__c = newRenewOrder.Service_Activation_Date__c.addMonths((integer)newRenewOrder.Renewal_Terms_Months__c)-1;
                            else
                                newRenewOrder.Service_End_Date__c =null;
                                
                            newRenewOrder.Renewed_From__c = jobClass.job.Id ;
                            newRenewOrder.OwnerId  = jobClass.job.OwnerId;
                            
                            if(isBatchJobsExecuting && sSelectedBatches != null && sSelectedBatches.contains('Auto Renewals')){
                                 newRenewOrder.Renew_Batch_Created_By__c = batchJobsObj.Id ;
                            }
                            newRenewOrder.Exchange_Rate_Applied__c = null;
                            jobClass.job = newRenewOrder;
                            Job_Product__c jobproduct;
                            Job_Rate_Plan__c jobrateplan;
                            Job_Rate_Plan_Charge__c jobrateplancharge;
                            Job_Rate_Plan_Charge_Tier__c jobRatePlanChargeTier;
            
                            list<Job_Product__c> listofJobproduct = new list<Job_Product__c>();
            
                            // Here we are cloning the ratePlan, charges etc
                            for(JobProductClass jpClass : jobClass.jobProducts){
                                jobproduct = jpClass.jobproduct.clone(false);
                                jobproduct.Job__c = null;
                                jobproduct.Renewed_From__c = jpClass.jobproduct.Id;
                                jpClass.jobproduct = jobproduct;
                                listofJobproduct.add(jpClass.jobproduct);
            
                                for(JobRatePlanClass jrpClass : jpClass.jobRatePlans){  
                                    jobrateplan = jrpClass.jobrateplan.clone(false);
                                    jobrateplan.Job_Product__c = null;
                                    jobrateplan.Renewed_From__c = jrpClass.jobrateplan.Id;
                                    jrpClass.jobrateplan = jobrateplan;
                                    
                                    for(JobRatePlanChargeClass  jrpcClass :  jrpClass.jobRatePlanCharges){
                                        jobrateplancharge = jrpcClass.jobrateplancharge.clone(false);
                                        jobrateplancharge.Job_Rate_Plan__c = null;
                                        jobrateplancharge.Charge_adjusted_from__c = null;
                                        jobrateplancharge.Mid_Term_Adjustment__c = null;
                                        jobrateplancharge.Previous_Mid_Term_Adjustment__c = null;
                                        jobrateplancharge.Order__c = null;
                                        jobrateplancharge.Mid_Term_Status__c =null;
                                        jobrateplancharge.Previous_Charge_Date__c =null;
                                        jobrateplancharge.Charge_Date__c = null;
                                        jobrateplancharge.Next_Charge_Date__c = null;
                                        jobrateplancharge.Quantity_to_Dispatch__c = null;
                                        jobrateplancharge.Quantity_Already_Dispatched__c = null;
                                        jobrateplancharge.Dispatch__c = false;
                                        jobrateplancharge.Service_Activation_Date__c = newRenewOrder.Service_Activation_Date__c;
                                        jobrateplancharge.Service_End_Date__c = newRenewOrder.Service_End_Date__c;
                                        jobrateplancharge.Renewed_From__c =  jrpcClass.jobrateplancharge.Id;
                                        
                                        if(jrpcClass.jobrateplancharge.Uplift__c != null){
                                            jobrateplancharge.Unit_Price__c = jrpcClass.jobrateplancharge.Unit_Price__c+(jrpcClass.jobrateplancharge.Unit_Price__c *jrpcClass.jobrateplancharge.Uplift__c /100);
                                        }  
                                        jrpcClass.jobrateplancharge = jobrateplancharge;
            
                                        for(JobRatePlanChargeTierClass tierClass : jrpcClass.jobRatePlanChargeTiers){
                                            jobRatePlanChargeTier = tierClass.jobRatePlanChargeTier.clone(false);
                                            jobRatePlanChargeTier.Job_Rate_Plan_Charge__c = null;
                                            if(jrpcClass.jobrateplancharge.Uplift__c != null){
                                                jobRatePlanChargeTier.Unit_Price__c = tierClass.jobRatePlanChargeTier.Unit_Price__c+(tierClass.jobRatePlanChargeTier.Unit_Price__c *jrpcClass.jobrateplancharge.Uplift__c /100);
                                            }
                                            tierClass.jobRatePlanChargeTier = jobRatePlanChargeTier;
                                        } 
                                    }
                                }
                            }
                            // Here we are invoking the controller method to save the order
                            CreateJobController.isRenewalOrder = true;
                            ApexPages.StandardController stdController = new ApexPages.StandardController(newRenewOrder);
                            CreateJobController createJobControllerObj = new CreateJobController(stdController);
                            createJobControllerObj.jobClass = jobClass;
                            createJobControllerObj.saveJob();
                        }
                        //Renewal Opportunity By Naveen M : INVOICEIT-539
                        else if(orderObj.Renew_to__c == 'Opportunity' && UserInfo.isCurrentUserLicensed('invoiceit_crmx')){                        

                            orderObj = JobCreationUtil.getJob(orderObj.id);
                            list<sobject> listOppProduct = new list<sobject>();
                            list<sobject> listOppRatePlan = new list<sobject>();
                            list<sobject> listOppCharge = new list<sobject>();
                            list<sobject> listOppTier = new list<sobject>();
                            
                            Schema.SobjectType oTypeOpportunity = gd.get('Opportunity');
                            Schema.SobjectType oTypeOpportunityProduct = gd.get('invoiceit_crmx__Opportunity_Product__c');
                            Schema.SobjectType oTypeOpportunityRatePlan = gd.get('invoiceit_crmx__Opportunity_Rate_Plan__c');
                            Schema.SobjectType oTypeOpportunityCharge = gd.get('invoiceit_crmx__Opportunity_Rate_Plan_Charge__c');
                            Schema.SobjectType oTypeOpportunityTier = gd.get('invoiceit_crmx__Opportunity_Rate_Plan_Charge_Tier__c');
                            
                            //Added INVOICEIT-573
                            map<String, Schema.SObjectField> mapDescribeOpportunity =  Schema.getGlobalDescribe().get(CommonUtilClass.OBJECT_NAME_OPPORTUNITY).getDescribe().fields.getMap();
                            map<String, Schema.SObjectField> mapDescribeOpportunityProduct = Schema.getGlobalDescribe().get('invoiceit_crmx__Opportunity_Product__c').getDescribe().fields.getMap();
                            map<String, Schema.SObjectField> mapDescribeOpportunityRatePlan = Schema.getGlobalDescribe().get('invoiceit_crmx__Opportunity_Rate_Plan__c').getDescribe().fields.getMap();
                            map<String, Schema.SObjectField> mapDescribeOpportunityRatePlanCharge = Schema.getGlobalDescribe().get('invoiceit_crmx__Opportunity_Rate_Plan_Charge__c').getDescribe().fields.getMap();
                            
                            sobject sObjectOpp = oTypeOpportunity.newSObject();
                            sobject sObjectOppProduct ;
                            sobject sObjectOppRateplan ;
                            sobject sObjectOppChare ;
                            sobject sObjectOppTier ;
                            
                            sObjectOpp.put('Name' ,  orderObj.Name);
                            sObjectOpp.put('CloseDate' ,  orderObj.Service_End_Date__c);
                            sObjectOpp.put('StageName' ,  Configuration__c.getValues('CLONEED_OPPORTUNITY_STAGE').String_Value__c);
                            sObjectOpp.put('OwnerId' ,  orderObj.OwnerId);
                            sObjectOpp.put('invoiceit_crmx__CurrencyL__c' ,  orderObj.CurrencyL__c);
                            sObjectOpp.put('AccountId' ,  orderObj.Account__c);
                            sObjectOpp.put('invoiceit_crmx__Number_Of_Terms__c' ,  orderObj.Renewal_Terms_Months__c);
                            sObjectOpp.put('invoiceit_crmx__Billing_Contact__c' ,  orderObj.Billing_Contact__c);
                            sObjectOpp.put('invoiceit_crmx__Discount_Value__c' ,  orderObj.Discount_Value__c);
                            sObjectOpp.put('invoiceit_crmx__Tax__c' ,  orderObj.Tax__c);
                            sObjectOpp.put('invoiceit_crmx__Total_Cost__c' ,  orderObj.Total_Cost__c);
                            sObjectOpp.put('invoiceit_crmx__Total_Profit__c' ,  orderObj.Total_Profit__c);
                            sObjectOpp.put('invoiceit_crmx__VAT__c' ,  orderObj.VAT__c);
                            sObjectOpp.put('invoiceit_crmx__Discount_Code__c' ,  orderObj.Discount_Code__c);
                            sObjectOpp.put('invoiceit_crmx__Discount_Percent__c' ,  orderObj.Discount_percent__c);
                            sObjectOpp.put('invoiceit_crmx__Renewed_From__c' ,  orderObj.id);
                            sObjectOpp.put('invoiceit_crmx__Opportunity_Type__c' ,  'Renewal');
                            sObjectOpp.put('invoiceit_crmx__Exchange_Rate_Applied__c' ,  null);
                            //Dynamic Binding Custom Mapping INVOICEIT-573
                            SObject sObjectOrder = (SObject)orderObj;
                            for(Custom_Mappings__c custom : mapCustomMappings.values()) {
                                if(custom.Destination_Object__c == CommonUtilClass.OBJECT_NAME_OPPORTUNITY
                                        && custom.Source_Object__c == CommonUtilClass.OBJECT_NAME_JOB) {
                                    String destinationField = (String)custom.get(sPrefix+'Destination_Field__c');
                                    String sourceField = (String)custom.get(sPrefix+'Source_Field__c');
                                    Schema.SObjectField f = mapDescribeOpportunity.get(destinationField);
                                    if(sObjectOrder.get(sourceField) != null){
                                        sObjectOpp.put(f, sObjectOrder.get(sourceField));
                                    }        
                                }
                            }
                            insert sObjectOpp;                          
                            for(JobProductClass jpClass : jobClass.jobProducts){
                                sObjectOppProduct = oTypeOpportunityProduct.newSObject();                                
                                sObjectOppProduct.put('invoiceit_crmx__Opportunity__c' , sObjectOpp.id);
                                sObjectOppProduct.put('Name' , jpClass.jobproduct.Name);
                                sObjectOppProduct.put('invoiceit_crmx__Product__c' , jpClass.jobproduct.Product__c);
                                sObjectOppProduct.put('invoiceit_crmx__Product_Family__c' , jpClass.jobproduct.Product_Family__c);
                                sObjectOppProduct.put('invoiceit_crmx__Description__c' , jpClass.jobproduct.Description__c);
                                sObjectOppProduct.put('invoiceit_crmx__Product_Code__c' , jpClass.jobproduct.Product_Code__c);
                                sObjectOppProduct.put('invoiceit_crmx__Renewed_From__c' , jpClass.jobproduct.id);
                                sObjectOppProduct.put('invoiceit_crmx__SequenceNumber__c' , jpClass.jobproduct.SequenceNumber__c);
                                sObjectOppProduct.put('invoiceit_crmx__Bundle_SequenceNumber__c' , jpClass.jobproduct.Bundle_SequenceNumber__c);
                                //Dynamic Binding Custom Mapping INVOICEIT-573
                                SObject sObjectOrderProd = (SObject)jpClass.jobproduct;
                                for(Custom_Mappings__c custom : mapCustomMappings.values()) {
                                    if(custom.Destination_Object__c == CommonUtilClass.OBJECT_NAME_OPPORTUNITY_PRODUCT
                                        && custom.Source_Object__c == CommonUtilClass.OBJECT_NAME_JOB_PRODUCT) {
                                        String destinationField = (String)custom.get(sPrefix+'Destination_Field__c');
                                        String sourceField = (String)custom.get(sPrefix+'Source_Field__c');

                                        Schema.SObjectField f = mapDescribeOpportunityProduct.get(destinationField);
                                        if(sObjectOrderProd.get(sourceField) != null){
                                            sObjectOppProduct.put(f, sObjectOrderProd.get(sourceField));
                                        }        
                                    }
                                }
                                listOppProduct.add(sObjectOppProduct);                          
                            }
                            insert listOppProduct;
                            for(integer i=0; i< jobClass.jobProducts.size(); i++){
                                for(JobRatePlanClass jrpClass : jobClass.jobProducts[i].jobRatePlans){
                                    sObjectOppRateplan = oTypeOpportunityRatePlan.newSObject();  
                                    sObjectOppRateplan.put('invoiceit_crmx__Opportunity_Product__c',listOppProduct[i].Id);
                                    sObjectOppRateplan.put('invoiceit_crmx__Description__c',jrpClass.jobrateplan.Description__c);
                                    sObjectOppRateplan.put('invoiceit_crmx__Product_Rate_Plan__c',jrpClass.jobrateplan.Product_Rate_Plan__c);
                                    sObjectOppRateplan.put('Name',jrpClass.jobrateplan.Name);
                                    sObjectOppRateplan.put('invoiceit_crmx__Renewed_From__c',jrpClass.jobrateplan.id);
                                    sObjectOppRateplan.put('invoiceit_crmx__SequenceNumber__c',jrpClass.jobrateplan.SequenceNumber__c);

                                    //Dynamic Binding Custom Mapping INVOICEIT-573
                                    SObject sObjectOrderRP = (SObject)jrpClass.jobrateplan;
                                    for(Custom_Mappings__c custom : mapCustomMappings.values()) {
                                        if(custom.Destination_Object__c == CommonUtilClass.OBJECT_NAME_OPPORTUNITY_RATE_PLAN
                                            && custom.Source_Object__c == CommonUtilClass.OBJECT_NAME_JOB_RATE_PLAN) {
                                            String destinationField = (String)custom.get(sPrefix+'Destination_Field__c');
                                            String sourceField = (String)custom.get(sPrefix+'Source_Field__c');

                                            Schema.SObjectField f = mapDescribeOpportunityRatePlan.get(destinationField);
                                            if(sObjectOrderRP.get(sourceField) != null){
                                                sObjectOppRateplan.put(f, sObjectOrderRP.get(sourceField));
                                            }        
                                        }
                                    }
                                    listOppRatePlan.add(sObjectOppRateplan);
                                 }
                            }    
                            insert listOppRatePlan;
                            integer jProductCount = 0; 
                            for(JobProductClass qpc :jobClass.jobProducts)
                            {
                                for(JobRatePlanClass qrc : qpc.jobRatePlans)
                                { 
                                        
                                    for(JobRatePlanChargeClass jrpcClass :qrc.jobRatePlanCharges)
                                    {
                                        sObjectOppChare = oTypeOpportunityCharge.newSObject();
                                        sObjectOppChare.put('invoiceit_crmx__Opportunity__c',sObjectOpp.id);
                                        sObjectOppChare.put('invoiceit_crmx__Opportunity_Rate_Plan__c',listOppRatePlan[jProductCount].id);
                                        sObjectOppChare.put('invoiceit_crmx__CurrencyL__c',jrpcClass.jobrateplancharge.CurrencyL__c);
                                        sObjectOppChare.put('invoiceit_crmx__Product_Rate_Plan_Charge__c',jrpcClass.jobrateplancharge.Product_Rate_Plan_Charge__c);
                                        if(jrpcClass.jobrateplancharge.Uplift__c != null){
                                            sObjectOppChare.put('invoiceit_crmx__Unit_Price__c',jrpcClass.jobrateplancharge.Unit_Price__c+(jrpcClass.jobrateplancharge.Unit_Price__c *jrpcClass.jobrateplancharge.Uplift__c /100));
                                        }else{
                                            sObjectOppChare.put('invoiceit_crmx__Unit_Price__c',jrpcClass.jobrateplancharge.Unit_Price__c);
                                        }
                                        sObjectOppChare.put('invoiceit_crmx__Status__c','Active');
                                        sObjectOppChare.put('invoiceit_crmx__Quantity__c',jrpcClass.jobrateplancharge.Quantity__c);   
                                        sObjectOppChare.put('invoiceit_crmx__Product_Charge_Category__c',jrpcClass.jobrateplancharge.Product_Charge_Category__c);
                                        sObjectOppChare.put('Name',jrpcClass.jobrateplancharge.Name);
                                        sObjectOppChare.put('invoiceit_crmx__Price_Type__c',jrpcClass.jobrateplancharge.Price_Type__c);
                                        sObjectOppChare.put('invoiceit_crmx__Price_Format__c',jrpcClass.jobrateplancharge.Price_Format__c);

                                        sObjectOppChare.put('invoiceit_crmx__Accounting_Code__c',jrpcClass.jobrateplancharge.Accounting_Code__c);
                                        sObjectOppChare.put('invoiceit_crmx__Charge_Code__c',jrpcClass.jobrateplancharge.Charge_Code__c);
                                        sObjectOppChare.put('invoiceit_crmx__Committed_Quantity__c',jrpcClass.jobrateplancharge.Committed_Quantity__c);
                                        sObjectOppChare.put('invoiceit_crmx__Discount_Percent__c',jrpcClass.jobrateplancharge.Discount_Percent__c);
                                        sObjectOppChare.put('invoiceit_crmx__Discount_Type__c',jrpcClass.jobrateplancharge.Discount_Type__c);
                                        sObjectOppChare.put('invoiceit_crmx__Discount_Value__c',jrpcClass.jobrateplancharge.Discount_Value__c);
                                        sObjectOppChare.put('invoiceit_crmx__Is_Product_Editable__c',jrpcClass.jobrateplancharge.Is_Product_Editable__c);
                                        sObjectOppChare.put('invoiceit_crmx__Max_Customer_Spend__c',jrpcClass.jobrateplancharge.Max_Customer_Spend__c);
                                        sObjectOppChare.put('invoiceit_crmx__Min_Customer_Spend__c',jrpcClass.jobrateplancharge.Min_Customer_Spend__c);
                                        sObjectOppChare.put('invoiceit_crmx__Product_Bundle_Line__c',jrpcClass.jobrateplancharge.Product_Bundle_Line__c);
                                        sObjectOppChare.put('invoiceit_crmx__Price__c',jrpcClass.jobrateplancharge.Price__c);
                                        sObjectOppChare.put('invoiceit_crmx__Tax__c',jrpcClass.jobrateplancharge.Tax__c);
                                        sObjectOppChare.put('invoiceit_crmx__Tax_Code__c',jrpcClass.jobrateplancharge.Tax_Code__c);
                                        sObjectOppChare.put('invoiceit_crmx__Tax_Percentage__c',jrpcClass.jobrateplancharge.Tax_Percentage__c);
                                        sObjectOppChare.put('invoiceit_crmx__Cost__c',jrpcClass.jobrateplancharge.Cost__c);
                                        sObjectOppChare.put('invoiceit_crmx__Cost_Price__c',jrpcClass.jobrateplancharge.Cost_Price__c);
                                        sObjectOppChare.put('invoiceit_crmx__VAT__c',jrpcClass.jobrateplancharge.VAT__c);
                                        sObjectOppChare.put('invoiceit_crmx__VAT_Percentage__c',jrpcClass.jobrateplancharge.VAT_Percentage__c);
                                        // Added By Dev M : Map field values : INVOICEIT-548
                                        sObjectOppChare.put('invoiceit_crmx__Deferred_Revenue_Accounting_Code__c',jrpcClass.jobrateplancharge.Deferred_Revenue_Accounting_Code__c);
                                        sObjectOppChare.put('invoiceit_crmx__Uplift__c',jrpcClass.jobrateplancharge.Uplift__c );
                                        sObjectOppChare.put('invoiceit_crmx__Renewed_From__c',jrpcClass.jobrateplancharge.id);
                                        sObjectOppChare.put('invoiceit_crmx__Sequence_No__c',jrpcClass.jobrateplancharge.Sequence_No__c);
                                        sObjectOppChare.put('invoiceit_crmx__Net_Total__c',jrpcClass.jobrateplancharge.Net_Total__c);
                                        sObjectOppChare.put('invoiceit_crmx__Profit__c',jrpcClass.jobrateplancharge.Profit__c);
                                        sObjectOppChare.put('invoiceit_crmx__Percentage_of_other_Charges__c',jrpcClass.jobrateplancharge.Percentage_of_other_Charges__c);
                                      
                                        //Dynamic Binding Custom Mapping INVOICEIT-573
                                        SObject sObjectOrderRPCharge = (SObject)jrpcClass.jobrateplancharge;
                                        for(Custom_Mappings__c custom : mapCustomMappings.values()) {
                                            if(custom.Destination_Object__c == CommonUtilClass.OBJECT_NAME_OPPORTUNITY_RATE_PLAN_CHARGE
                                                && custom.Source_Object__c == CommonUtilClass.OBJECT_NAME_JOB_RATE_PLAN_CHARGE) {
                                                String destinationField = (String)custom.get(sPrefix+'Destination_Field__c');
                                                String sourceField = (String)custom.get(sPrefix+'Source_Field__c');

                                                Schema.SObjectField f = mapDescribeOpportunityRatePlanCharge.get(destinationField);
                                                if(sObjectOrderRPCharge.get(sourceField) != null){
                                                    sObjectOppChare.put(f, sObjectOrderRPCharge.get(sourceField));
                                                }        
                                            }
                                        }
                                        listOppCharge.add(sObjectOppChare);

                                    }
                                    jProductCount++; 
                                 }
                            }                    

                            insert listOppCharge;
                            integer jProductChargeCount = 0;
                            for(JobProductClass qpc :jobClass.jobProducts)
                            {
                                for(JobRatePlanClass qrc : qpc.jobRatePlans)
                                { 
                                    for(JobRatePlanChargeClass qrpc :qrc.jobRatePlanCharges)
                                    {
                                        for(JobRatePlanChargeTierClass jobTierClass : qrpc.jobRatePlanChargeTiers)
                                        {
                                            sObjectOppTier = oTypeOpportunityTier.newSObject();                                         
                                            sObjectOppTier.put('invoiceit_crmx__Opportunity_Rate_Plan_Charge__c',listOppCharge[jProductChargeCount].id);
                                            sObjectOppTier.put('invoiceit_crmx__Start_Unit__c',jobTierClass.jobRatePlanChargeTier.Start_Unit__c);
                                            sObjectOppTier.put('invoiceit_crmx__End_Unit__c',jobTierClass.jobRatePlanChargeTier.End_Unit__c);
                                            if(qrpc.jobrateplancharge.Uplift__c!= null){
                                                sObjectOppTier.put('invoiceit_crmx__Unit_Price__c',jobTierClass.jobRatePlanChargeTier.Unit_Price__c+(jobTierClass.jobRatePlanChargeTier.Unit_Price__c *qrpc.jobrateplancharge.Uplift__c /100));
                                            }else{
                                                sObjectOppTier.put('invoiceit_crmx__Unit_Price__c',jobTierClass.jobRatePlanChargeTier.Unit_Price__c);
                                            }
                                            
                                            sObjectOppTier.put('invoiceit_crmx__Unit_Cost_Price__c',jobTierClass.jobRatePlanChargeTier.Unit_Cost_Price__c);
                                            listOppTier.add(sObjectOppTier);
                                        
                                        }
                                        jProductChargeCount++;
                                    }
                                }
                            }            

                            insert listOppTier;    
                            sObjectOpp.put ('invoiceit_crmx__Recalculate__c', true); 
                            update sObjectOpp;                  
                        } else if(orderObj.Renew_to__c == 'Quote'){ 
                            //Added By Dev M : Renewal of Quote : INVOICEIT-541
                            orderObj = JobCreationUtil.getJob(orderObj.id);
                            list<sobject> listofQuoteProduct = new list<sobject>();
                            list<sobject> listofQuoteRatePlan = new list<sobject>();
                            list<sobject> listofQuoteCharge = new list<sobject>();
                            list<sobject> listofQuoteTier = new list<sobject>();
                            
                            Schema.SobjectType oTypeQuote = gd.get(sPrefix+'Quote__c');
                            Schema.SobjectType oTypeQuoteProduct = gd.get(sPrefix+'Quote_Product__c');
                            Schema.SobjectType oTypeQuoteRatePlan = gd.get(sPrefix+'Quote_Rate_Plan__c');
                            Schema.SobjectType oTypeQuoteCharge = gd.get(sPrefix+'Quote_Rate_Plan_Charge__c');
                            Schema.SobjectType oTypeQuoteTier = gd.get(sPrefix+'Quote_Rate_Plan_Charge_Tier__c');

                            map<String, Schema.SObjectField> mapDescribeQuote =  Schema.getGlobalDescribe().get(sPrefix+'Quote__c').getDescribe().fields.getMap();
                            map<String, Schema.SObjectField> mapDescribeQuoteProduct = Schema.getGlobalDescribe().get(sPrefix+'Quote_Product__c').getDescribe().fields.getMap();
                            map<String, Schema.SObjectField> mapDescribeQuoteRatePlan = Schema.getGlobalDescribe().get(sPrefix+'Quote_Rate_Plan__c').getDescribe().fields.getMap();
                            map<String, Schema.SObjectField> mapDescribeQuoteRatePlanCharge = Schema.getGlobalDescribe().get(sPrefix+'Quote_Rate_Plan_Charge__c').getDescribe().fields.getMap();

                            sobject sObjectQuote = oTypeQuote.newSObject();
                            sobject sObjectQuoteProduct;
                            sobject sObjectQuoteRateplan;
                            sobject sObjectQuoteChare;
                            sobject sObjectQuoteTier;
                            
                            sObjectQuote.put('Name' ,  orderObj.Name);
                            sObjectQuote.put('Account__c' ,  orderObj.Account__c);
                            sObjectQuote.put('Billing_Contact__c' ,  orderObj.Billing_Contact__c);
                            sObjectQuote.put('CurrencyL__c' ,  orderObj.CurrencyL__c);
                            sObjectQuote.put('OwnerId' ,  orderObj.OwnerId);
                            sObjectQuote.put('Discount_Code__c' ,  orderObj.Discount_Code__c);
                            sObjectQuote.put('Discount_percent__c' ,  orderObj.Discount_percent__c);
                            sObjectQuote.put('Discount_Value__c' ,  orderObj.Discount_Value__c);
                            sObjectQuote.put('Exchange_Rate_Applied__c' ,  null);
                            sObjectQuote.put('Number_Of_Terms__c' ,  orderObj.Renewal_Terms_Months__c);
                            sObjectQuote.put('Start_Date__c' ,  system.today());
                            sObjectQuote.put('Valid_To__c' ,  system.today() + Integer.valueOf(Configuration__c.getValues('QUOTE_VALIDITY_PERIOD').NUMBER_VALUE__C));
                            sObjectQuote.put('Partner__c' ,  orderObj.Partner__c);
                            sObjectQuote.put('Shipping_Contact__c' ,  orderObj.Shipping_Contact__c);
                            sObjectQuote.put('Sub_Total__c' ,  orderObj.Sub_Total__c);
                            sObjectQuote.put('Tax__c' ,  orderObj.Tax__c);
                            sObjectQuote.put('Total_Cost__c' ,  orderObj.Total_Cost__c);
                            sObjectQuote.put('Total_Profit__c' ,  orderObj.Total_Profit__c);
                            sObjectQuote.put('TotalProfitPercent__c' ,  orderObj.TotalProfitPercent__c);
                            sObjectQuote.put('Total__c' ,  orderObj.Total__c);
                            sObjectQuote.put('VAT__c' ,  orderObj.VAT__c);
                            sObjectQuote.put('Net_Total__c' ,  orderObj.Net_Total__c);
                            sObjectQuote.put('Total_Contract_Value__c' ,  orderObj.Total_Contract_Value__c);
                            sObjectQuote.put('Contracted_MRR__c' ,  orderObj.Contracted_MRR__c);
                            sObjectQuote.put('Override_Vat_Tax__c' ,  orderObj.Override_Vat_Tax__c);
                            sObjectQuote.put('Renewed_From__c' , orderObj.id);
                            
                            //Dynamic Binding Custom Mapping INVOICEIT-541
                            SObject sObjectOrder = (SObject)orderObj;
                            for(Custom_Mappings__c custom : mapCustomMappings.values()) {
                                if(custom.Destination_Object__c == CommonUtilClass.OBJECT_NAME_QUOTE
                                        && custom.Source_Object__c == CommonUtilClass.OBJECT_NAME_JOB) {
                                    String destinationField = (String)custom.get(sPrefix+'Destination_Field__c');
                                    String sourceField = (String)custom.get(sPrefix+'Source_Field__c');

                                    Schema.SObjectField f = mapDescribeQuote.get(destinationField);
                                    if(sObjectOrder.get(sourceField) != null){
                                        sObjectQuote.put(f, sObjectOrder.get(sourceField));
                                    }        
                                }
                            }
                            insert sObjectQuote;
                              
                            for(JobProductClass jpClass : jobClass.jobProducts){
                                sObjectQuoteProduct = oTypeQuoteProduct.newSObject();                                
                                sObjectQuoteProduct.put('Quote__c' , sObjectQuote.id);
                                sObjectQuoteProduct.put('Name' , jpClass.jobproduct.Name);
                                sObjectQuoteProduct.put('Product__c' , jpClass.jobproduct.Product__c);
                                sObjectQuoteProduct.put('Product_Family__c' , jpClass.jobproduct.Product_Family__c);
                                sObjectQuoteProduct.put('Description__c' , jpClass.jobproduct.Description__c);
                                sObjectQuoteProduct.put('Product_Code__c' , jpClass.jobproduct.Product_Code__c);
                                sObjectQuoteProduct.put('Renewed_From__c' , jpClass.jobproduct.id);
                                sObjectQuoteProduct.put('SequenceNumber__c' , jpClass.jobproduct.SequenceNumber__c);
                                sObjectQuoteProduct.put('Bundle_SequenceNumber__c' , jpClass.jobproduct.Bundle_SequenceNumber__c);
                                sObjectQuoteProduct.put('Product_Bundle__c' , jpClass.jobproduct.Product_Bundle__c);
                                
                                //Dynamic Binding Custom Mapping INVOICEIT-541
                                SObject sObjectOrderProd = (SObject)jpClass.jobproduct;
                                for(Custom_Mappings__c custom : mapCustomMappings.values()) {
                                    if(custom.Destination_Object__c == CommonUtilClass.OBJECT_NAME_QUOTE_PRODUCT
                                        && custom.Source_Object__c == CommonUtilClass.OBJECT_NAME_JOB_PRODUCT) {
                                        String destinationField = (String)custom.get(sPrefix+'Destination_Field__c');
                                        String sourceField = (String)custom.get(sPrefix+'Source_Field__c');

                                        Schema.SObjectField f = mapDescribeQuoteProduct.get(destinationField);
                                        if(sObjectOrderProd.get(sourceField) != null){
                                            sObjectQuoteProduct.put(f, sObjectOrderProd.get(sourceField));
                                        }        
                                    }
                                }
                                listofQuoteProduct.add(sObjectQuoteProduct);                          
                             }
                             insert listofQuoteProduct;                 
                             
                             for(integer i=0; i< jobClass.jobProducts.size(); i++){
                                 for(JobRatePlanClass jrpClass : jobClass.jobProducts[i].jobRatePlans){
                                    sObjectQuoteRateplan = oTypeQuoteRatePlan.newSObject();  
                                    sObjectQuoteRateplan.put('Quote_Product__c',listofQuoteProduct[i].Id);
                                    sObjectQuoteRateplan.put('Description__c',jrpClass.jobrateplan.Description__c);
                                    sObjectQuoteRateplan.put('Product_Rate_Plan__c',jrpClass.jobrateplan.Product_Rate_Plan__c);
                                    sObjectQuoteRateplan.put('Name',jrpClass.jobrateplan.Name);
                                    sObjectQuoteRateplan.put('Renewed_From__c',jrpClass.jobrateplan.id);
                                    sObjectQuoteRateplan.put('SequenceNumber__c',jrpClass.jobrateplan.SequenceNumber__c);
                                    //Dynamic Binding Custom Mapping INVOICEIT-541
                                    SObject sObjectOrderRP = (SObject)jrpClass.jobrateplan;
                                    for(Custom_Mappings__c custom : mapCustomMappings.values()) {
                                        if(custom.Destination_Object__c == CommonUtilClass.OBJECT_NAME_QUOTE_RATE_PLAN
                                            && custom.Source_Object__c == CommonUtilClass.OBJECT_NAME_JOB_RATE_PLAN) {
                                            String destinationField = (String)custom.get(sPrefix+'Destination_Field__c');
                                            String sourceField = (String)custom.get(sPrefix+'Source_Field__c');

                                            Schema.SObjectField f = mapDescribeQuoteRatePlan.get(destinationField);
                                            if(sObjectOrderRP.get(sourceField) != null){
                                                sObjectQuoteRateplan.put(f, sObjectOrderRP.get(sourceField));
                                            }        
                                        }
                                    }
                                    listofQuoteRatePlan.add(sObjectQuoteRateplan);
                                 }
                             }    
                            insert listofQuoteRatePlan;
                            
                            integer jProductCount = 0; 
                            for(JobProductClass qpc :jobClass.jobProducts)
                            {   
                                for(JobRatePlanClass qrc : qpc.jobRatePlans)
                                { 
                                    for(JobRatePlanChargeClass jrpcClass :qrc.jobRatePlanCharges)
                                    {
                                        sObjectQuoteChare = oTypeQuoteCharge.newSObject();
                                        
                                        if(jrpcClass.jobrateplancharge.Uplift__c != null){
                                            sObjectQuoteChare.put('Unit_Price__c',jrpcClass.jobrateplancharge.Unit_Price__c+(jrpcClass.jobrateplancharge.Unit_Price__c *jrpcClass.jobrateplancharge.Uplift__c /100));
                                        }else{
                                            sObjectQuoteChare.put('Unit_Price__c',jrpcClass.jobrateplancharge.Unit_Price__c);
                                        }
                                        
                                        sObjectQuoteChare.put('Quote__c',sObjectQuote.id);
                                        sObjectQuoteChare.put('Quote_Rate_Plan__c',listofQuoteRatePlan[jProductCount].id);
                                        sObjectQuoteChare.put('Name',jrpcClass.jobrateplancharge.Name);
                                        sObjectQuoteChare.put('Accounting_Code__c',jrpcClass.jobrateplancharge.Accounting_Code__c);
                                        sObjectQuoteChare.put('Discount_Value__c',jrpcClass.jobrateplancharge.Discount_Value__c);
                                        sObjectQuoteChare.put('Price_Format__c',jrpcClass.jobrateplancharge.Price_Format__c);
                                        sObjectQuoteChare.put('Profit__c',jrpcClass.jobrateplancharge.Profit__c);
                                        sObjectQuoteChare.put('Sequence_No__c',jrpcClass.jobrateplancharge.Sequence_No__c);   
                                        sObjectQuoteChare.put('Unit_Of_Measurement__c',jrpcClass.jobrateplancharge.Unit_Of_Measurement__c);
                                        sObjectQuoteChare.put('Price__c',jrpcClass.jobrateplancharge.Price__c);
                                        sObjectQuoteChare.put('Price_Type__c',jrpcClass.jobrateplancharge.Price_Type__c);
                                        sObjectQuoteChare.put('CurrencyL__c',jrpcClass.jobrateplancharge.CurrencyL__c);
                                        sObjectQuoteChare.put('Quantity__c',jrpcClass.jobrateplancharge.Quantity__c);
                                        sObjectQuoteChare.put('Tax__c',jrpcClass.jobrateplancharge.Tax__c);
                                        sObjectQuoteChare.put('Vat__c',jrpcClass.jobrateplancharge.Vat__c);
                                        sObjectQuoteChare.put('Tax_Code__c',jrpcClass.jobrateplancharge.Tax_Code__c);
                                        sObjectQuoteChare.put('Cost__c',jrpcClass.jobrateplancharge.Cost__c);
                                        sObjectQuoteChare.put('Cost_Price__c',jrpcClass.jobrateplancharge.Cost_Price__c);
                                        sObjectQuoteChare.put('Is_Product_Editable__c',jrpcClass.jobrateplancharge.Is_Product_Editable__c);
                                        sObjectQuoteChare.put('Product_Rate_Plan_Charge__c',jrpcClass.jobrateplancharge.Product_Rate_Plan_Charge__c);
                                        sObjectQuoteChare.put('Product_Charge_Category__c',jrpcClass.jobrateplancharge.Product_Charge_Category__c);
                                        sObjectQuoteChare.put('VAT_Percentage__c',jrpcClass.jobrateplancharge.VAT_Percentage__c);
                                        sObjectQuoteChare.put('Tax_Percentage__c',jrpcClass.jobrateplancharge.Tax_Percentage__c);
                                        sObjectQuoteChare.put('Net_Total__c',jrpcClass.jobrateplancharge.Net_Total__c);
                                        sObjectQuoteChare.put('Discount_percent__c',jrpcClass.jobrateplancharge.Discount_percent__c);
                                        sObjectQuoteChare.put('Percentage_of_other_Charges__c',jrpcClass.jobrateplancharge.Percentage_of_other_Charges__c);
                                        sObjectQuoteChare.put('Product_Bundle_Line__c',jrpcClass.jobrateplancharge.Product_Bundle_Line__c);
                                        // Added By Dev M : Map field values : INVOICEIT-548
                                        sObjectQuoteChare.put('Deferred_Revenue_Accounting_Code__c',jrpcClass.jobrateplancharge.Deferred_Revenue_Accounting_Code__c);
                                        sObjectQuoteChare.put('Uplift__c',jrpcClass.jobrateplancharge.Uplift__c);
                                        sObjectQuoteChare.put('Committed_Quantity__c',jrpcClass.jobrateplancharge.Committed_Quantity__c );
                                        sObjectQuoteChare.put('Min_Customer_Spend__c',jrpcClass.jobrateplancharge.Min_Customer_Spend__c);
                                        sObjectQuoteChare.put('Max_Customer_Spend__c',jrpcClass.jobrateplancharge.Max_Customer_Spend__c);
                                        sObjectQuoteChare.put('Charge_Code__c',jrpcClass.jobrateplancharge.Charge_Code__c);
                                        sObjectQuoteChare.put('Discount_Type__c',jrpcClass.jobrateplancharge.Discount_Type__c);
                                        sObjectQuoteChare.put('Renewed_From__c',jrpcClass.jobrateplancharge.id);
                                        //Dynamic Binding Custom Mapping INVOICEIT-541
                                        SObject sObjectOrderRPCharge = (SObject)jrpcClass.jobrateplancharge;
                                        for(Custom_Mappings__c custom : mapCustomMappings.values()) {
                                            if(custom.Destination_Object__c == CommonUtilClass.OBJECT_NAME_QUOTE_RATE_PLAN_CHARGE
                                                && custom.Source_Object__c == CommonUtilClass.OBJECT_NAME_JOB_RATE_PLAN_CHARGE) {
                                                String destinationField = (String)custom.get(sPrefix+'Destination_Field__c');
                                                String sourceField = (String)custom.get(sPrefix+'Source_Field__c');

                                                Schema.SObjectField f = mapDescribeQuoteRatePlanCharge.get(destinationField);
                                                if(sObjectOrderRPCharge.get(sourceField) != null){
                                                    sObjectQuoteChare.put(f, sObjectOrderRPCharge.get(sourceField));
                                                }        
                                            }
                                        }
                                        listofQuoteCharge.add(sObjectQuoteChare);
                                    }
                                   jProductCount++; 
                                 }
                            }                    

                            insert listofQuoteCharge;

                            integer jProductChargeCount = 0;
                            for(JobProductClass qpc :jobClass.jobProducts)
                            {
                                for(JobRatePlanClass qrc : qpc.jobRatePlans)
                                { 
                                    for(JobRatePlanChargeClass qrpc :qrc.jobRatePlanCharges)
                                    {
                                        for(JobRatePlanChargeTierClass jobTierClass : qrpc.jobRatePlanChargeTiers)
                                        {
                                            sObjectQuoteTier = oTypeQuoteTier.newSObject();                                         
                                            sObjectQuoteTier.put('Quote_Rate_Plan_Charge__c',listofQuoteCharge[jProductChargeCount].id);
                                            sObjectQuoteTier.put('Start_Unit__c',jobTierClass.jobRatePlanChargeTier.Start_Unit__c);
                                            sObjectQuoteTier.put('End_Unit__c',jobTierClass.jobRatePlanChargeTier.End_Unit__c);
                                            if(qrpc.jobrateplancharge.Uplift__c!= null){
                                                sObjectQuoteTier.put('Unit_Price__c',jobTierClass.jobRatePlanChargeTier.Unit_Price__c+(jobTierClass.jobRatePlanChargeTier.Unit_Price__c *qrpc.jobrateplancharge.Uplift__c /100));
                                            }else{
                                                sObjectQuoteTier.put('Unit_Price__c',jobTierClass.jobRatePlanChargeTier.Unit_Price__c);
                                            }
                                            sObjectQuoteTier.put('Unit_Cost_Price__c',jobTierClass.jobRatePlanChargeTier.Unit_Cost_Price__c);
                                            listofQuoteTier.add(sObjectQuoteTier);
                                        }
                                        jProductChargeCount++;
                                    }
                                }
                            }            
                            insert listofQuoteTier;    
                            sObjectQuote.put('Recalculate__c', true); 
                            update sObjectQuote; 
                        }    
                        Job__c renewOrderFrom = new Job__c(Id = orderObj.Id, Auto_Renewal_Complete__c = true);
                        update renewOrderFrom;
                    }
                }
            }catch(Exception ex){
                errorLog +=  ex.getTypeName() + ':' + ex.getMessage() + ':'  + ex.getLineNumber() + ':' + ex.getStackTraceString() + '\n';
            }
        }

        global void finish(Database.BatchableContext BC){
            //Added by Shruthi:INVOICEIT-399:This updates status and completed time for the batch Jobs object record-Auto Renewals
            batchJobsObj.Completed_Date_and_Time__c = system.now();
            batchJobsObj.Status__c = CommonUtilClass.STATUS_COMPLETED;      
            if(errorLog != ''){
                batchJobsObj.Status__c = CommonUtilClass.STATUS_COMPLETED_WITH_ERRORS;
                //the maximum size of Long Text Area is 32768. If error log is more than this then create the attachment with error log 
                if(errorLog.Length() < 32768) {
                    batchJobsObj.Exception_Log__c = errorLog; 
                } else {
                    Attachment attachment = new Attachment(Body = Blob.valueOf(errorLog), Name = 'ErrorLog.txt', ParentId = batchJobsObj.Id);
                    insert attachment;  
                    batchJobsObj.Exception_Log__c = system.Label.ErrorLogIsAttatchedAsAnAttachment;
                }
            } 
            upsert batchJobsObj;
        }
    }