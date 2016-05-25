public with sharing class CreateJobController{
            private ApexPages.StandardController controller {get;set;}
            public Job__c job{get;set;}
            public Map<Id,JobProductClass> mapJobProducts = new  Map<Id,JobProductClass>();
            public JobProductClass jobProductClass {get;set;}
            public JobClass jobClass {get;set;}
            public JobRatePlanClass jobRatePlanClass {get;set;}
            public JobRatePlanChargeClass jobRatePlanChargeClass = new JobRatePlanChargeClass();
            JobRatePlanChargeTierClass jobTierClass;
            Job_Rate_Plan_Charge_Tier__c jobTier;
            set<string> setOfOrderRatePlan = new set<string>();
            private map<String, Product_Catalog_Filter_Criteria__c> mapProductCatalogFilterCriteria;
            private map<String, Configuration__c> mapConfiguration;
            private map<String, Custom_Mappings__c> mapCustomMappings;
            public List<Product_Rate_Plan__c> listProductRatePlans {get;set;}
            public List<Product_Rate_Plan_Charge__c> listProductRatePlanCharges {get;set;}  
            public List<Job_Rate_Plan__c> jobRatePlansToDelete = new List<Job_Rate_Plan__c>();
            public List<Job_Product__c> jobProductsToDelete = new List<Job_Product__c>();
            public List<Job_Product__c> listJobProducts = new List<Job_Product__c>();
            public List<Job_Rate_Plan__c> listJobRatePlans = new  List<Job_Rate_Plan__c>();
            public static boolean isRenewalOrder = false;
            //these variables are used for counting the job products,rateplans etc 
            private Integer jobProductCounter = 0;
            private Integer jobRatePlanCounter = 0;
            private Integer jobRateplanChargeCounter = 0;
            Integer jobRatePlanChargeTierCounter = 0;

            //these variables are used in createJobStep2 page only
            public string searchstring {get;set;}
            public String selectedProductId {get;set;}
            public transient String selectedProductName {get;set;}
            public String selectedRatePlanId {get; set;}
            public boolean isMultipleRatePlans {get; set;}
            public String sPrefix {get; set;}
            private String sPage1Name = 'createJobStep1';
            private String sPage2Name = 'createJobStep2';
            private String sPage3Name = 'createJobStep3';
            private Integer iSequenceNo = 1;
            private Integer jobBundleSequenceNo = 1;
            private Integer iJobProductSequenceNo = 1;
            private Integer iJobRatePlanSequenceNo = 1;
            public String sFilterCriteria {get;set;}
            public String sProductsLimit {get; set;}
            public String sCurrencyName {get; set;}

            public String displayfields {get; set;}
            public String objectname {get; set;}
            public String orderfield {get; set;}
            public String searchfields {get; set;}
            //The following objects hold the describe results 
            map<String, Schema.SObjectField> mapDescribeJobProduct = Schema.SObjectType.Job_Product__c.fields.getMap();
            map<String, Schema.SObjectField> mapDescribeJobRatePlan = Schema.SObjectType.Job_Rate_Plan__c.fields.getMap();
            map<String, Schema.SObjectField> mapDescribeJobRatePlanCharge = Schema.SObjectType.Job_Rate_Plan_Charge__c.fields.getMap();

            public string job_LevelDiscount_By {get;set;}
            public string discountCode {get;set;}
            public string discountCodeCoupen = '';
            string currecyISOCode = null;
            Currency__c currencyObjNew;

            public string widthOfChargeNameText {get;set;}
            public string widthOfProductNameText {get;set;}

            public boolean displayProductBundle {get; set;}
            public String displayfieldsForProductBundle {get; set;}
            public String objectnameForProductBundle {get; set;}
            public String orderfieldForProductBundle {get; set;}
            public String searchfieldsForProductBundle {get; set;}
            public String sFilterCriteriaForProductBundle {get; set;}

            boolean isProductBundle = false;
            integer productBundleCount = 0;
            set<Id> setofChargeIds = new set<Id>();
            string productBundle = '';
            map<Id,Product_Bundle_Line__c> mapChargeId_Bundle = new map<Id,Product_Bundle_Line__c>(); 
            string productBundleId;
            public boolean isDisableDiscount {get;set;}
            public boolean isDisableCloneButtons {get;set;} 
            public String sButtonName {get;set;}
            public boolean displayDiscountRowinOrderPage3 {get; set;}
            public boolean displayVATRowinOrderPage3 {get; set;}
            public boolean displayTAXRowinOrderPage3 {get; set;}
            
            // Dhanalakshmi, INVOICEIT-430, To assign the default value of the discount type field at charge level
            public String sDefaultValueOfDiscountType;

            // Constructor for CreateJobController
            public CreateJobController(ApexPages.StandardController stdController) {
            
                        sPrefix = CommonUtilClass.getPrefix();
                    try {   
                            isDisableDiscount = true;
                            this.controller = stdController;
                            this.job = (Job__c)stdController.getRecord();
                            //Get the custom settings for the product catalog filter criteria
                            mapProductCatalogFilterCriteria = Product_Catalog_Filter_Criteria__c.getAll();
                            mapConfiguration = Configuration__c.getAll();
                            mapCustomMappings = Custom_Mappings__c.getAll();
                                                    displayDiscountRowinOrderPage3 = false;
                            //Populating the width for the product and charge names text box.
                           displayDiscountRowinOrderPage3 = mapConfiguration.get('DISPLAY_DISCOUNT').Boolean_Value__c;
                           displayVATRowinOrderPage3 = mapConfiguration.get('DISPLAY_VAT').Boolean_Value__c;
                           displayTAXRowinOrderPage3 = mapConfiguration.get('DISPLAY_TAX').Boolean_Value__c;
                            widthOfChargeNameText  = mapConfiguration.get('CHARGENAME_TEXTBOX_WIDTH').String_Value__c;
                            widthOfProductNameText = mapConfiguration.get('PRODUCTNAME_TEXTBOX_WIDTH').String_Value__c;
                            displayProductBundle = mapConfiguration.get('DISPLAY_PRODUCT_BUNDLES_SEARCH').Boolean_Value__c;

                            //intialize the vat percentage from custom settings                  
                            sPage1Name = mapConfiguration.get('ORDER_PAGE_1').String_Value__c;
                            sPage2Name = mapConfiguration.get('ORDER_PAGE_2').String_Value__c;
                            sPage3Name = mapConfiguration.get('ORDER_PAGE_3').String_Value__c;
                            displayfields = mapConfiguration.get('PRODUCT_DISPLAYFIELDS').String_Value__c; 
                            objectname = mapConfiguration.get('PRODUCT_OBJECTNAME').String_Value__c;
                            orderfield = mapConfiguration.get('PRODUCT_ORDERFIELD').String_Value__c;
                            searchfields = mapConfiguration.get('PRODUCT_SEARCHFIELDS').String_Value__c;

                            displayfieldsForProductBundle = mapConfiguration.get('PRODUCTBUNDLE_DISPLAYFIELDS').String_Value__c;
                            objectnameForProductBundle = sPrefix+'Product_Bundle__c'; 
                            orderfieldForProductBundle = mapConfiguration.get('PRODUCTBUNDLE_ORDERFIELD').String_Value__c; 
                            searchfieldsForProductBundle = mapConfiguration.get('PRODUCTBUNDLE_SEARCHFIELDS').String_Value__c; 
                            sFilterCriteriaForProductBundle = '';

                            integer iNoOfDecimalPlaces = integer.valueOf(mapConfiguration.get('NO_OF_DECIMALS_FOR_CURRENCY_VALUES').Number_Value__c);
                            sProductsLimit = '' + (mapConfiguration.get('PRODUCT_SEARCH_LIMIT').Number_Value__c).intValue();
                            //change this into commom util
                            job_LevelDiscount_By = mapConfiguration.get('DISCOUNT_BY_VALUE_OR_PERCENTAGE').String_Value__c;
                            discountCode = mapConfiguration.get('ORDER_DISCOUNT_CODE_FIELD').String_Value__c;

                            jobClass = new JobClass();
                            jobClass.job = job;
                            if(job.id != null) {
                                    this.job = JobCreationUtil.getJob(job.id);
                                    jobClass.job = job;
                                    listJobProducts = JobCreationUtil.getListJobProducts(job.id);
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
                                    listJobRatePlans = JobCreationUtil.getListJobRatePlans(jobProductIds);
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

                                                            //Disabling the remove button for Product bundle
                                                            if(setOfOrderRatePlan.contains(string.valueOf(jobProductClass.jobproduct.Bundle_SequenceNumber__c)))
                                                                    jobRatePlanChargeClass.displayRemove = false;
                                                            else
                                                                    jobRatePlanChargeClass.displayRemove = true; 

                                                            //Check wheather the quantity is editable or not
                                                            if(qr.Job_Product__r.Product_Bundle__r.Bundle_Type__c != null && qr.Job_Product__r.Product_Bundle__r.Bundle_Type__c == 'Bundle' && qr.Product_Rate_Plan__c == null)     
                                                                    jobRatePlanChargeClass.isQuantityEditable = qr.Job_Product__r.Product_Bundle__r.Is_Quantity_Editable__c; 
                                                            else if(qrpc.Product_Bundle_Line__c != null)
                                                                    jobRatePlanChargeClass.isQuantityEditable = qrpc.Product_Bundle_Line__r.Is_Quantity_Editable__c;


                                                            //add the tiers
                                                            if(map_JobChargeId_JobTiers.containsKey(qrpc.Id)) {
                                                                    for(Job_Rate_Plan_Charge_Tier__c quoteTier : map_JobChargeId_JobTiers.get(qrpc.Id)) {
                                                                            jobTierClass = new jobRatePlanChargeTierClass(); 
                                                                            jobTierClass.jobRatePlanChargeTier = quoteTier;
                                                                            jobTierClass.jobRatePlanChargeTierCounter = ++jobRatePlanChargeTierCounter;
                                                                            jobRatePlanChargeClass.jobRatePlanChargeTiers.add(jobTierClass);
                                                                    }
                                                            }
                                                            jobRatePlanClass.jobRatePlanCharges.add(jobRatePlanChargeClass);
                                                    }
                                                    jobRatePlanClass.jobRatePlanCounter = ++jobRatePlanCounter;

                                                    jobProductClass.jobRatePlans.add(jobRatePlanClass);

                                                    mapJobProducts.put(qr.Job_Product__c,jobProductClass);

                                                    if(jobProductClass.jobproduct.Bundle_SequenceNumber__c != null)
                                                            setOfOrderRatePlan.add(string.valueOf(jobProductClass.jobproduct.Bundle_SequenceNumber__c));
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

                                            Currency__c currencyObj = CommonUtilClass.getCurrencyObjectForId(job.CurrencyL__c);
                                            sCurrencyName = currencyObj.Currency_Symbol__c + ' ';
                                            currecyISOCode = currencyObj.Name;

                                            iJobProductSequenceNo = 1;
                                            for(JobProductClass jobProductClass : jobClass.jobProducts) {
                                                    jobProductClass.jobproduct.SequenceNumber__c = iJobProductSequenceNo;
                                                    iJobProductSequenceNo ++;
                                            }

                                            iJobRatePlanSequenceNo = 1;
                                            for(JobProductClass jobProductClass : jobClass.jobProducts) {
                                                    for(JobRatePlanClass jobrateplan : jobProductClass.jobRatePlans) {
                                                            jobrateplan.jobrateplan.SequenceNumber__c = iJobRatePlanSequenceNo;
                                                            iJobRatePlanSequenceNo ++;
                                                    }
                                            }
                                            jobBundleSequenceNo = setOfOrderRatePlan.size()+1; 
                                    }
                            }
                            //If the currency is null then fill in the default currency
                            if(job.CurrencyL__c == null) {
                                    fillDefaultCurrencyValue();
                            }
                            // Ankit Sharma - INVOICEIT-377 - Enable disable Discount buttons in vf page based on login user permission.

                            if(job_LevelDiscount_By == CommonUtilClass.APPLY_DISCOUNT_BY_VALUE) {
                                    if (!Schema.sObjectType.Job_Rate_Plan_Charge__c.fields.Discount_Value__c.isUpdateable() || !Schema.sObjectType.Job_Rate_Plan_Charge__c.fields.Discount_Value__c.isCreateable()){                        
                                            isDisableDiscount = false;
                                    }       
                            }

                            if(job_LevelDiscount_By == CommonUtilClass.APPLY_DISCOUNT_BY_PERCENTAGE) {
                                    if (!Schema.sObjectType.Job_Rate_Plan_Charge__c.fields.Discount_Percent__c.isUpdateable() || !Schema.sObjectType.Job_Rate_Plan_Charge__c.fields.Discount_Percent__c.isCreateable()){                    
                                            isDisableDiscount = false;
                                    }       
                            }
                            //Added by dhanalakshmi for INVOICEIT-430 - display the discount type picklist default value if it has  
                            if(job_LevelDiscount_By == CommonUtilClass.APPLY_DISCOUNT_BY_BOTH) {
                                Schema.DescribeFieldResult descrideRessult = Job_Rate_Plan_Charge__c.Discount_Type__c.getDescribe();
                                List <Schema.PicklistEntry> picklistValues = descrideRessult.getPicklistValues();        
                                for (Schema.PicklistEntry pv: picklistValues) {
                                    if (pv.isDefaultValue()) {
                                        sDefaultValueOfDiscountType = pv.getValue();
                                    }
                                }
                            }
                            
                            if(!isRenewalOrder) {
                                    string sURL = ApexPages.currentPage().getURL();
                                    if(sURL.contains('createAmendments')) {
                                            isMidTerm = true;
                                            step2();
                                    }
                            }
                    }catch(Exception ex) {
                            CustomException.populateApexMessage(CustomException.handleError('CreateJobController', '', null, ex), 'ERROR');
                    }
            }

            public PageReference changeCurrencySelection() {
                    Currency__c currencyObj = CommonUtilClass.getCurrencyObjectForId(job.CurrencyL__c);
                    sCurrencyName = currencyObj.Currency_Symbol__c  + ' ';
                    currecyISOCode = currencyObj.Name;
                    return null;
            }

            // The next 3methods from to step3 results in pagenavigation @return PageReference
             
            public PageReference step1() {
                    //return Page.createJobStep1; // Added by Dev M INVOICEIT-617
                    return new PageReference('/apex/' + sPage1Name); 
            }

            Account account;
            public PageReference step2() {        
                    sFilterCriteria = '';
                    sFilterCriteriaForProductBundle = '';
                    account = (Account) CommonUtilClass.getSobjectById(CommonUtilClass.OBJECT_NAME_ACCOUNT, job.Account__c);
                    //sFilterCriteria is used for dynamic filtering criteria 
                    //Add the valid from and to dates to the query searchstring
                    if(job.Start_Date__c != null) {   

                            sFilterCriteria = ' and Valid_From_Date__c <= ' + CommonUtilClass.convertDateToString(job.Start_Date__c)
                            + ' and (Valid_To_Date__c >= ' + CommonUtilClass.convertDateToString(job.Start_Date__c)
                            + ' Or Valid_To_Date__c = null )'; 

                            sFilterCriteriaForProductBundle = ' and Start_Date__c <= ' + CommonUtilClass.convertDateToString(job.Start_Date__c)
                            + ' and (End_Date__c >= ' + CommonUtilClass.convertDateToString(job.Start_Date__c)
                            + ' Or End_Date__c = null )';
                    }

                    sFilterCriteriaForProductBundle = sFilterCriteriaForProductBundle + ' and Currency__c =\'' + job.CurrencyL__c+ '\'' ;
                    for(Product_Catalog_Filter_Criteria__c criteria : mapProductCatalogFilterCriteria.values()) {
                            if(criteria.Destination_Object__c == CommonUtilClass.OBJECT_NAME_PRODUCT
                                            && (criteria.Source_Object__c == CommonUtilClass.OBJECT_NAME_JOB || criteria.Source_Object__c == CommonUtilClass.OBJECT_NAME_ACCOUNT)) { 
                                    //Add these to the map
                                    //We need both the fieldname and the value to query
                                    String value; 

                                    if(criteria.Source_Object__c == CommonUtilClass.OBJECT_NAME_JOB) {
                                            value = (String)job.get((String)criteria.get('Source_Field__c'));
                                    } else {
                                            value = (String)account.get((String)criteria.get('Source_Field__c'));
                                    }
                                    if(value != null) {
                                            String key = (String)criteria.get('Destination_Field__c');
                                            sFilterCriteria += ' and ' + key +' = \'' + value + '\'';       
                                    }        
                            }
                    }
                    return new PageReference('/apex/' + sPage2Name);
            }

            public PageReference step3() {
                    chargeCalculator();
                    return new PageReference('/apex/' + sPage3Name);        
            }

            public PageReference fillDefaultCurrencyValue() {
                    //Use the default currency of the logged in user
                    //If that is null then pickk the default currency from the custom settings
                // Added by Dev M Ticekt : INVOICEIT-604    
                try {
                    String tempString;

                    if(UserInfo.getDefaultCurrency() != null){
                            tempString = UserInfo.getDefaultCurrency(); 
                    }else{
                            tempString = mapConfiguration.get('DEFAULT_CURRENCY').String_Value__c;
                    }

                    Currency__c currencyObj = CommonUtilClass.getCurrencyObject(tempString);
                    job.CurrencyL__c = currencyObj.Id;
                    sCurrencyName = currencyObj.Currency_Symbol__c + ' ';   
                    currecyISOCode = currencyObj.Name;   
                 } catch(Exception ex) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.Label.PleaseCreateCurrency_s));
                 }                                                                
                    return null;
            }

            //Boolean for know midterm if it is 'New' and make as true
            boolean isMidTerm = false;
            public void getRatePlansForProductMidTerm() {
                    isMidTerm = true;
                    getRatePlansForProduct();
                    chargeCalculator();
            }

            //Dev M INVOICEIT-270 Previously for Midterm Adjustement - user have to enter service start date for every charge even if quantity is zero for charge
            public void quantityChanged() {}  

            public void getRatePlanChargesForRatePlanMidTerm() {
                    getRatePlanChargesForRatePlan();
                    chargeCalculator();
            }

             // This method returns ProductRatePlans of the SelectedProduct @return PageReference
             
            public PageReference getRatePlansForProduct() {
                    try{
                            selectedProductId = system.currentPageReference().getParameters().get('productId');
                            selectedProductName = system.currentPageReference().getParameters().get('productName');
                            list<Product__c>  listofProduct = [SELECT Id FROM Product__c WHERE ID =: selectedProductId];
                            if(!listofProduct.isEmpty()) {
                                    //if(selectedProductId != null){
                                    map<String,String> searchMap = new map<String,String>();
                                    //Check the custom settings map if there are any criteria for Product_RatePlan__c
                                    for(Product_Catalog_Filter_Criteria__c criteria : mapProductCatalogFilterCriteria.values()) {
                                            if(criteria.Destination_Object__c == CommonUtilClass.OBJECT_NAME_PRODUCT_RATE_PLAN
                                                            && (criteria.Source_Object__c == CommonUtilClass.OBJECT_NAME_JOB || criteria.Source_Object__c == CommonUtilClass.OBJECT_NAME_ACCOUNT)){
                                                    //Add these to the map
                                                    //We need both the fieldname and the value to query
                                                    String value;

                                                    if(criteria.Source_Object__c == CommonUtilClass.OBJECT_NAME_JOB) {
                                                            value = (String)job.get((String)criteria.get('Source_Field__c'));
                                                    } else {
                                                            value = (String)account.get((String)criteria.get('Source_Field__c'));
                                                    }
                                                    if(value != null) {
                                                            String key = (String)criteria.get('Destination_Field__c');
                                                            searchMap.put(key, value);    
                                                    }                
                                            }
                                    }                              
                                    listProductRatePlans = JobCreationUtil.getProductRatePlans(selectedProductId,job.Start_Date__c,searchMap,isMidTerm);

                                    if(listProductRatePlans.size() == 1) { 
                                            isMultipleRatePlans = false;
                                            selectedRatePlanId = listProductRatePlans.get(0).id;

                                            system.currentPageReference().getParameters().put('ratePlanId',selectedRatePlanId);
                                            getRatePlanChargesForRatePlan();
                                    }
                                    else if(listProductRatePlans.size() > 1) {
                                            isMultipleRatePlans = true;
                                    }
                                    else {
                                            //this means listProductRatePlans.size() == 0,So display a message
                                            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.INFO,system.Label.Product_ProductRatePlan);
                                            Apexpages.addMessage(errorMessage);
                                    }                      
                            } else {
                                    getProductBundle(selectedProductId);
                            }


                    } catch(Exception ex) {
                            CustomException.populateApexMessage(CustomException.handleError('CreateJobController', '', null, ex), 'ERROR');
                    }

                    return null;
            }

             // This method is used for the product bundles
             // It will seperate the InvoiceIt Product, ratePlans, Charges from the Product Bundle line and it will add in step wizard @return PageReference
              
            public PageReference getProductBundle(string locProductBundleId) {
                    productBundleId = locProductBundleId;

                    Product_Bundle__c refProductBundle = CommonUtilClass.getProductBundle(locProductBundleId);
                    list<Product_Bundle_Line__c> listofProductBundleLine = CommonUtilClass.getProductBundleLine(locProductBundleId);

                    map<Id, map<Id, map<Id,Product_Bundle_Line__c>>> map_ProductId_mapRateId_SetofChargeIds = new map<Id, map<Id,  map<Id,Product_Bundle_Line__c>>>();
                    map<Id, map<Id,Product_Bundle_Line__c>> localMapRate;
                    map<Id,Product_Bundle_Line__c> localMapCharge;
                    // Separting the InvoiceIt Product, ratePlans, Charges
                    for(Product_Bundle_Line__c productLine : listofProductBundleLine) {

                            if(map_ProductId_mapRateId_SetofChargeIds.containsKey(productLine.Product__c)) {
                                    localMapRate =  map_ProductId_mapRateId_SetofChargeIds.get(productLine.Product__c);
                                    if(localMapRate.containsKey(productLine.Product_Rate_Plan__c)) {
                                            localMapCharge = localMapRate.get(productLine.Product_Rate_Plan__c);
                                    } else {
                                            localMapCharge = new map<Id,Product_Bundle_Line__c>();
                                    }
                            } else {
                                    localMapRate = new map<Id, map<Id,Product_Bundle_Line__c>>();
                                    localMapCharge = new map<Id,Product_Bundle_Line__c>();
                            }
                            localMapCharge.put(productLine.Product_Rate_Plan_Charge__c, productLine);
                            localMapRate.put(productLine.Product_Rate_Plan__c, localMapCharge);
                            map_ProductId_mapRateId_SetofChargeIds.put(productLine.Product__c, localMapRate);
                    }
                    // Add one Order Product, ratePlan, charge
                    if(refProductBundle.Bundle_Type__c == 'Bundle') {
                            Job_Product__c  jobproduct = new Job_Product__c();
                            jobproduct.Name = refProductBundle.Name;
                            jobproduct.SequenceNumber__c = iJobProductSequenceNo;
                            iJobProductSequenceNo ++;   
                            jobproduct.Product_Bundle__c = productBundleId;
                            jobproduct.Bundle_SequenceNumber__c = jobBundleSequenceNo;
                            jobproduct.Product_Code__c = refProductBundle.Product_Bundle_Code__c;
                            //Add SelectedJobproduct to jobProductClass
                            jobProductClass = new JobProductClass();
                            jobProductClass.jobProductCounter = ++jobProductCounter;
                            jobProductClass.jobproduct = jobproduct;

                            Job_Rate_Plan__c jobRatePlan = new Job_Rate_Plan__c();
                            jobRatePlan.Name = refProductBundle.Name;
                            jobRatePlan.SequenceNumber__c = iJobRatePlanSequenceNo;
                            iJobRatePlanSequenceNo ++;

                            //Add jobRatePlan of SelectedProduct to jobRatePlanClass
                            jobRatePlanClass = new JobRatePlanClass();
                            jobRatePlanClass.jobRatePlanCounter = ++jobRatePlanCounter;
                            jobRatePlanClass.jobrateplan = jobRatePlan;

                            //Add all productrateplancharges to jobrateplancharges list
                            Job_Rate_Plan_Charge__c jobRatePlanCharge = new Job_Rate_Plan_Charge__c(); 
                            jobRatePlanCharge.Unit_Price__c = refProductBundle.Bundle_Price__c;  
                            jobRatePlanCharge.Unit_Of_Measurement__c = refProductBundle.Unit_Of_Measurement__c;
                            jobRatePlanCharge.Price_Format__c = refProductBundle.Pricing_Model__c;
                            jobRatePlanCharge.Quantity__c = refProductBundle.Quantity__c;
                            jobRatePlanCharge.Price_Type__c = refProductBundle.Price_Type__c;
                            jobRatePlanCharge.CurrencyL__c = refProductBundle.Currency__c;
                            jobRatePlanCharge.Product_Charge_Category__c = refProductBundle.Product_Charge_Category__c;
                            jobRatePlanCharge.Name = refProductBundle.Name;
                            //jobRatePlanCharge.Auto_Renew__c = true;
                            jobRatePlanCharge.Uplift__c = refProductBundle.Uplift__c;
                            jobRatePlanCharge.Uplift_Frequency__c = refProductBundle.Uplift_Frequency__c;
                            jobRatePlanCharge.Revenue_Recognition_Rule__c = refProductBundle.Revenue_Recognition_Rule__c;
                            jobRatePlanCharge.Sequence_No__c = iSequenceNo;
                            jobRatePlanCharge.Is_Product_Editable__c = refProductBundle.Is_Price_Editable__c;
                            jobrateplancharge.VAT__c = 0;
                            jobrateplancharge.Tax__c = 0;

                            if(isMidTerm)
                                    jobRatePlanCharge.Mid_Term_Status__c = 'New'; 

                            iSequenceNo++;                           
                            jobRatePlanChargeClass  = new JobRatePlanChargeClass();
                            jobRatePlanChargeClass.jobRatePlanChargeCounter = ++jobRateplanChargeCounter;
                            jobRatePlanChargeClass.jobrateplancharge = jobRatePlanCharge;
                            jobRatePlanChargeClass.isQuantityEditable = refProductBundle.Is_Quantity_Editable__c;
                            jobRatePlanChargeClass.displayRemove = true;
                            jobRatePlanClass.jobRatePlanCharges.add(jobRatePlanChargeClass);        
                            jobProductClass.jobRatePlans.add(jobRatePlanClass);
                            jobClass.jobProducts.add(jobProductClass);
                            productBundleCount++;
                            iSequenceNo = 1; 
                    }
                    // This will populate the Order Product, ratePlan, charge
                    for(Id productId : map_ProductId_mapRateId_SetofChargeIds.keySet()) {
                            selectedProductId = productId;
                            localMapRate =  map_ProductId_mapRateId_SetofChargeIds.get(productId);
                            for(Id ratePlanId :localMapRate.keySet()) {
                                    localMapCharge = localMapRate.get(ratePlanId);
                                    system.currentPageReference().getParameters().put('ratePlanId',ratePlanId);
                                    isProductBundle = true; 
                                    setofChargeIds.addAll(localMapCharge.keySet());
                                    selectedRatePlanId = ratePlanId;
                                    mapChargeId_Bundle = localMapCharge;
                                    addJobCharges();
                            } 
                    }

                    mapChargeId_Bundle = new map<Id,Product_Bundle_Line__c>();
                    productBundleCount = 0;
                    productBundleId = '';
                    jobBundleSequenceNo++;
                    return null;
            }

             // This method returns ProductRatePlanCharges of the SelectedRatePlan @return PageReference
               
            public PageReference getRatePlanChargesForRatePlan() {
                    try {
                            isMultipleRatePlans = false;
                            selectedRatePlanId = system.currentPageReference().getParameters().get('ratePlanId');
                            //updating the most used product rateplan
                            Product_Rate_Plan__c productRatePlan;
                            UserRecordAccess userRecordAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =: UserInfo.getUserId() AND RecordId =: selectedRatePlanId ];
                            // if the selected rate plan matches, update the count and break the loop.
                            if(userRecordAccess.HasEditAccess) {
                                    for(Product_Rate_Plan__c ratePlan :listProductRatePlans){
                                            if(ratePlan.id == selectedRatePlanId){

                                                    if(ratePlan.Occurrence__c == null){
                                                            productRatePlan = new Product_Rate_Plan__c(Id = ratePlan.id, Occurrence__c = 1);
                                                            update productRatePlan;
                                                            break;
                                                    } else {
                                                            productRatePlan = new Product_Rate_Plan__c(Id = ratePlan.id, Occurrence__c = ratePlan.Occurrence__c + 1);
                                                            update productRatePlan;
                                                            break;
                                                    }
                                            }
                                    }
                            }
                            if(selectedRatePlanId != null) {
                                    map<String,String> searchMap = new map<String,String>();
                                    //Check the custom settings map if there are any criteria for Product_Rate_Plan_Charge__c
                                    for(Product_Catalog_Filter_Criteria__c criteria : mapProductCatalogFilterCriteria.values()) {
                                            if(criteria.Destination_Object__c == CommonUtilClass.OBJECT_NAME_PRODUCT_RATE_PLAN_CHARGE
                                                            && (criteria.Source_Object__c == CommonUtilClass.OBJECT_NAME_JOB || criteria.Source_Object__c == CommonUtilClass.OBJECT_NAME_ACCOUNT)) {
                                                    //Add these to the map
                                                    //We need both the fieldname and the value to query
                                                    String value ;

                                                    if(criteria.Source_Object__c == CommonUtilClass.OBJECT_NAME_JOB) {
                                                            value = (String)job.get((String)criteria.get('Source_Field__c'));
                                                    } else {
                                                            value = (String)account.get((String)criteria.get('Source_Field__c'));
                                                    }
                                                    if(value != null) {
                                                            String key = (String)criteria.get('Destination_Field__c');
                                                            searchMap.put(key, value);   
                                                    }                 
                                            }
                                    }                              
                                    listProductRatePlanCharges = JobCreationUtil.getProductRatePlanCharges(selectedRatePlanId, job.CurrencyL__c, searchMap);
                            }
                            if(listProductRatePlanCharges != null && !listProductRatePlanCharges.isEmpty()) {
                                    boolean displayPopUp = mapConfiguration.get('DISPLAY_PRODUCT_CHARGE_POP_UP').Boolean_Value__c;
                                    //Amended by Shruthi relates to INVOICEIT-379
                                    if((displayPopUp == null || !displayPopUp) || listProductRatePlanCharges.size() == 1) {
                                            addJobCharges(); 
                                    } else {
                                            showPopupForProductRPC();
                                    }              
                            } else {
                                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.WARNING,system.Label.Product_Rateplan_Currency);
                                    Apexpages.addMessage(errorMessage);
                            }
                    } catch(DMLException dMlEx){
                            // Added by Mani ticket : INVOICEIT-310
                            Apexpages.Message errorMessage; 
                            for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                            { 
                                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                                    Apexpages.addMessage(errorMessage);      
                            } 
                            return null; 
                    }  catch(Exception ex) {
                            CustomException.populateApexMessage(CustomException.handleError('CreateJobController', '', null, ex), 'ERROR');
                    }
                    return null;
            }

             // This method adds job to jobProductClass @return PageReference
             
            public PageReference addJobCharges() {
                    boolean isJobProductExists = false;
                    boolean isTierProductExists = false;
                    try {
                            Product_Bundle_Line__c productLine;
                            Product_Rate_Plan__c selectedrateplan = new Product_Rate_Plan__c();
                            //Get the selectedrateplan 
                            if(!isProductBundle) {
                                    selectedrateplan = JobCreationUtil.getProductRatePlanFromList(listProductRatePlans,selectedRatePlanId);
                            }else {
                                    selectedrateplan = JobCreationUtil.getProductRatePlan(selectedRatePlanId);
                                    listProductRatePlanCharges = JobCreationUtil.getProductRatePlanCharges(selectedrateplan.Id, job.CurrencyL__c, setofChargeIds);
                            }

                            Job_Product__c  jobproduct = new Job_Product__c();
                            Product__c selectedproduct = JobCreationUtil.getProduct(selectedProductId);
                            jobproduct.Product_Code__c = selectedproduct.Product_Code__c;
                            jobproduct.Product__c = selectedproduct.Id;
                            jobproduct.Name = selectedproduct.Name;
                            jobproduct.Product_Family__c = selectedproduct.Product_Family__c;
                            jobproduct.Description__c = selectedproduct.Description__c;
                            jobproduct.SequenceNumber__c = iJobProductSequenceNo;
                            iJobProductSequenceNo ++;   
                            if(productBundleId != '' && productBundleId != null) {
                                    jobproduct.Product_Bundle__c = productBundleId;
                                    jobproduct.Bundle_SequenceNumber__c = jobBundleSequenceNo;
                            }               
                            //dynamic field mapping starts here
                            SObject s = (SObject)selectedproduct;
                            SObject sObjectJobProduct = (SObject)jobproduct;

                            for(Custom_Mappings__c custom : mapCustomMappings.values()) {
                                    if(custom.Destination_Object__c == CommonUtilClass.OBJECT_NAME_JOB_Product
                                                    && custom.Source_Object__c == CommonUtilClass.OBJECT_NAME_PRODUCT) {
                                            String destinationField = (String)custom.get('Destination_Field__c');
                                            String sourceField = (String)custom.get('Source_Field__c');

                                            Schema.SObjectField f = mapDescribeJobProduct.get(destinationField);
                                            if(s.get(sourceField) != null){
                                                    sObjectJobProduct.put(f, s.get(sourceField));
                                            }
                                    }
                            }
                            jobproduct = (Job_Product__c)sObjectJobProduct;

                            //Add SelectedJobproduct to jobProductClass
                            jobProductClass = new JobProductClass();
                            jobProductClass.jobProductCounter = ++jobProductCounter;
                            jobProductClass.jobproduct = jobproduct;

                            //check for DuplicateJobRatePlans
                            Job_Rate_Plan__c jobRatePlan = new Job_Rate_Plan__c();
                            jobRatePlan.Description__c = selectedrateplan.Description__c;
                            jobRatePlan.Product_Rate_Plan__c = selectedrateplan.Id;
                            jobRatePlan.Name = selectedrateplan.Name;
                            jobRatePlan.SequenceNumber__c = iJobRatePlanSequenceNo;
                            iJobRatePlanSequenceNo ++;
                            //dynamic field mapping starts here
                            s = (SObject)selectedrateplan;
                            SObject sObjectJobRatePlan = (SObject)jobRatePlan;

                            for(Custom_Mappings__c custom : mapCustomMappings.values()) {
                                    if(custom.Destination_Object__c == CommonUtilClass.OBJECT_NAME_JOB_RATE_PLAN
                                                    && custom.Source_Object__c == CommonUtilClass.OBJECT_NAME_PRODUCT_RATE_PLAN) {
                                            String destinationField = (String)custom.get('Destination_Field__c');
                                            String sourceField = (String)custom.get('Source_Field__c');

                                            Schema.SObjectField f = mapDescribeJobRatePlan.get(destinationField);
                                            if(s.get(sourceField) != null) {
                                                    sObjectJobRatePlan.put(f, s.get(sourceField));
                                            }
                                    }
                            }
                            jobRatePlan = (Job_Rate_Plan__c)sObjectJobRatePlan;

                            //Add jobRatePlan of SelectedProduct to jobRatePlanClass
                            jobRatePlanClass = new JobRatePlanClass();
                            jobRatePlanClass.jobRatePlanCounter = ++jobRatePlanCounter;
                            jobRatePlanClass.jobrateplan = jobRatePlan;
                            //Add all productrateplancharges to jobrateplancharges list
                            Job_Rate_Plan_Charge__c jobRatePlanCharge;
                            for(Product_Rate_Plan_Charge__c selectedProductratePlanCharge : listProductRatePlanCharges) { 
                                    jobRatePlanCharge = new Job_Rate_Plan_Charge__c(); 

                                    //if the charge is tiered then dont populate the price
                                    if(selectedProductratePlanCharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_TIERED) {
                                            jobRatePlanCharge.Unit_Price__c = 0;
                                            isTierProductExists = true;
                                    } else {
                                            jobRatePlanCharge.Unit_Price__c = selectedProductratePlanCharge.Unit_Price__c;  
                                    }                                      
                                    jobRatePlanCharge.Unit_Of_Measurement__c = selectedProductratePlanCharge.Unit_Of_Measurement__c;
                                    jobRatePlanCharge.Price_Format__c = selectedProductratePlanCharge.Price_Format__c;
                                    if(selectedProductratePlanCharge.Default_Quantity__c != null) {
                                            jobRatePlanCharge.Quantity__c = selectedProductratePlanCharge.Default_Quantity__c;
                                    }else if(mapConfiguration.get('DEFAULT_QUANTITY_IN_WIZARDS').Number_Value__c != null){
                                            jobRatePlanCharge.Quantity__c = Integer.valueOf(mapConfiguration.get('DEFAULT_QUANTITY_IN_WIZARDS').Number_Value__c);
                                    }else {
                                            jobRatePlanCharge.Quantity__c = 1;
                                    }
                                    jobRatePlanCharge.Charge_Code__c = selectedProductratePlanCharge.Charge_Code__c;
                                    jobRatePlanCharge.Price__c = null;
                                    jobRatePlanCharge.Cost__c = null;                                 
                                    jobRatePlanCharge.Price_Type__c = selectedProductratePlanCharge.Price_Type__c;
                                    jobRatePlanCharge.CurrencyL__c = selectedProductratePlanCharge.CurrencyL__c;
                                    jobRatePlanCharge.Accounting_Code__c = selectedProductratePlanCharge.Accounting_Code__c;
                                    jobRatePlanCharge.Product_Rate_Plan_Charge__c = selectedProductratePlanCharge.id;
                                    jobRatePlanCharge.Name = selectedProductratePlanCharge.Name;
                                    jobRatePlanCharge.Cost_Price__c = selectedProductratePlanCharge.Cost_Price__c;
                                    jobRatePlanCharge.Sequence_No__c = iSequenceNo;
                                    jobRatePlanCharge.Is_Product_Editable__c = selectedProductratePlanCharge.Is_Product_Editable__c;
                                    jobRatePlanCharge.Product_Charge_Category__c = selectedProductratePlanCharge.Product_Charge_Category__c;
                                    jobRatePlanCharge.Percentage_of_other_Charges__c = selectedProductratePlanCharge.Percentage_of_other_Charges__c;
                                    jobRatePlanCharge.Uplift__c = selectedProductratePlanCharge.Uplift__c;
                                    jobRatePlanCharge.Uplift_Frequency__c = selectedProductratePlanCharge.Uplift_Frequency__c;
                                    jobRatePlanCharge.Revenue_Recognition_Rule__c = selectedProductratePlanCharge.Revenue_Recognition_Rule__c;
                                    // Modified By Dev.M INVOICEIT-548
                                    jobRatePlanCharge.Deferred_Revenue_Accounting_Code__c = selectedProductratePlanCharge.Deferred_Revenue_Accounting_Code__c;
                                    jobrateplancharge.VAT__c = 0;
                                    jobrateplancharge.Tax__c = 0;
                                    // added by Ram, INVOICEIT-430 
                                    jobrateplancharge.Discount_Percent__c = 0;
                                    jobrateplancharge.Discount_Value__c = 0;
                                    //If discount type picklist field has any default value then display,else display default value as 'None', INVOICEIT-430, Dhanalakshmi
                                    if(sDefaultValueOfDiscountType != null){
                                        jobrateplancharge.Discount_Type__c = sDefaultValueOfDiscountType;
                                    }
                                    
                                    //jobRatePlanCharge.Auto_Renew__c = true;
                                    if(mapChargeId_Bundle.containskey(selectedProductratePlanCharge.Id)) {
                                            productLine = mapChargeId_Bundle.get(selectedProductratePlanCharge.Id);
                                            jobRatePlanCharge.Product_Bundle_Line__c = productLine.Id;
                                            jobRatePlanCharge.Is_Product_Editable__c = productLine.Is_Price_Editable__c;
                                            jobRatePlanCharge.Unit_Price__c = productLine.Unit_Price__c;
                                            jobRatePlanCharge.Quantity__c = productLine.Quantity__c;
                                            jobRatePlanCharge.Cost_Price__c = 0;
                                    }      
                                    // Added by Jositha for tkt : SUP-702 
                                    if(UserInfo.isMultiCurrencyOrganization()){
                                        CommonUtilClass.populateCurrencyIsoCodeOnSobject(jobrateplancharge, currecyISOCode);
                                    }
                                    //dynamic field mapping starts here
                                    SObject sObj = (SObject)selectedProductratePlanCharge;
                                    SObject sObjectJobRatePlanCharge = (SObject)jobRatePlanCharge;

                                    for(Custom_Mappings__c custom : mapCustomMappings.values()) {
                                            if(custom.Destination_Object__c == CommonUtilClass.OBJECT_NAME_JOB_RATE_PLAN_CHARGE 
                                                            && custom.Source_Object__c == CommonUtilClass.OBJECT_NAME_PRODUCT_RATE_PLAN_CHARGE) {
                                                    String destinationField = (String)custom.get('Destination_Field__c');
                                                    String sourceField = (String)custom.get('Source_Field__c');

                                                    Schema.SObjectField f = mapDescribeJobRatePlanCharge.get(destinationField);
                                                    if(sObj.get(sourceField) != null) {
                                                            sObjectJobRatePlanCharge.put(f, sObj.get(sourceField));
                                                    }
                                            }
                                    }
                                    jobRatePlanCharge = (Job_Rate_Plan_Charge__c)sObjectJobRatePlanCharge;                          

                                    //add to the new midterm rows
                                    if(isMidTerm) {
                                            jobRatePlanCharge.Mid_Term_Status__c = 'New'; 
                                            chargesToUpdateForMidTerm.add(jobRatePlanCharge);
                                    }

                                    iSequenceNo++;                           
                                    jobRatePlanChargeClass  = new JobRatePlanChargeClass();
                                    if(productLine != null)
                                            jobRatePlanChargeClass.isQuantityEditable = productLine.Is_Quantity_Editable__c;

                                    jobRatePlanChargeClass.jobRatePlanChargeCounter = ++jobRateplanChargeCounter;
                                    jobRatePlanChargeClass.jobrateplancharge = jobRatePlanCharge;
                                    jobRatePlanChargeClass.displayRemove = true;

                                    if(productBundleCount != 0) {
                                            jobRatePlanChargeClass.displayRemove = false;
                                    }
                                    //loop over the tiers if format is volume
                                    if(selectedProductratePlanCharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME 
                                                    || selectedProductratePlanCharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE 
                                                    || selectedProductratePlanCharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_TIERED) {
                                            for(Product_Rate_Plan_Charge_Tier__c productTier : selectedProductratePlanCharge.Product_Rate_Plan_Charge_Tiers__r) {
                                                    jobTierClass = new JobRatePlanChargeTierClass();
                                                    jobTier = new Job_Rate_Plan_Charge_Tier__c();
                                                    jobTier.Start_Unit__c = productTier.Start_Unit__c;
                                                    jobTier.End_Unit__c = productTier.End_Unit__c;
                                                    jobTier.Unit_Cost_Price__c = productTier.Unit_Cost_Price__c;
                                                    jobTier.Unit_Price__c = productTier.Unit_Price__c;
                                                    jobTierClass.jobRatePlanChargeTier = jobTier;
                                                    jobTierClass.jobRatePlanChargeTierCounter = ++jobRatePlanChargeTierCounter;
                                                    jobRatePlanChargeClass.jobRatePlanChargeTiers.add(jobTierClass);
                                            }
                                    }
                                    jobRatePlanClass.jobRatePlanCharges.add(jobRatePlanChargeClass);
                            }

                            jobProductClass.jobRatePlans.add(jobRatePlanClass);
                            iSequenceNo = 1; 
                            if(!isJobProductExists) {
                                    jobClass.jobProducts.add(jobProductClass);
                            }
                            // Amend by Shruthi Bomma relates to SUP-302
                            if(isTierProductExists) {
                                    JobChargesCalculator.calculateSubtotal(jobClass, new JobChargesCalculator.Charges());
                            }

                            if(isProductBundle) {
                                    productBundleCount++;
                            }

                            isProductBundle = false;
                            setofChargeIds.clear();
                            mapChargeId_Bundle = new map<Id,Product_Bundle_Line__c>();
                    }  
                    catch(Exception ex) {
                            CustomException.populateApexMessage(CustomException.handleError('CreateJobController', '', null, ex), 'ERROR');
                    }
                    return null;
            }

             // This method saves job @return PageReference
             
            public PageReference saveJob() {
                    decimal totalContractValue = 0;
                    decimal totalChargeContract = 0;
                    decimal totalContractedMRR = 0;
                    chargeCalculator();
                    String jobId;
                    boolean Align_Dates_Of_Order_To_Products = mapConfiguration.get('ALIGN_DATES_OF_ORDER_TO_PRODUCTS').Boolean_Value__c;
                    savepoint sp = database.setsavepoint();
                    try {
                            List<Job_Rate_Plan_Charge__c> listJobRatePlanCharges = new List<Job_Rate_Plan_Charge__c>();
                            List<Job_Rate_Plan_Charge__c> listJobRatePlanChargesToDelete = new  List<Job_Rate_Plan_Charge__c>();
                            List<Job_Rate_Plan_Charge_Tier__c> listJobTiersToDelete = new List<Job_Rate_Plan_Charge_Tier__c>();
                            Map<Integer,Job_Product__c> mapJobProducts = new Map<Integer, Job_Product__c>();
                            //Currency__c currencyObjNew;
                            if(job != null) {
                                    //if(isMidTerm) {
                                            for(JobProductClass qpc :jobClass.jobProducts)
                                            {
                                                    for(JobRatePlanClass qrc : qpc.jobRatePlans)
                                                    { 
                                                            for(JobRatePlanChargeClass qrpc :qrc.jobRatePlanCharges)
                                                            {
                                                                    // below if should excute only for mid term
                                                                    if ((qrpc.jobrateplancharge.Id == null) && ((qrpc.jobrateplancharge.Quantity__c > 0 && qrpc.jobrateplancharge.Service_Activation_Date__c == null && isMidTerm) || (isMidTerm && qrpc.jobrateplancharge.Price_Type__c == 'Usage' && qrpc.jobrateplancharge.Service_Activation_Date__c == null) ) ) {
                                                                            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.ServiceStartDateIsRequiredForCharge +qrpc.jobrateplancharge.Name);
                                                                            ApexPages.addMessage(errorMsg);
                                                                            return null;
                                                                    }
                                                                    
                                                                    //if Align_Dates_Of_Order_To_Products is true then assign the order activation date to charge activation date
                                                                    if(Align_Dates_Of_Order_To_Products) {
                                                                            if(qrpc.jobrateplancharge.Service_Activation_Date__c == null) {
                                                                                    qrpc.jobrateplancharge.Service_Activation_Date__c = job.Service_Activation_Date__c;
                                                                            }
                                                                            if(qrpc.jobrateplancharge.Service_End_Date__c == null) {
                                                                                    qrpc.jobrateplancharge.Service_End_Date__c = job.Service_End_Date__c;
                                                                            }
                                                                    }
                                                                    //Added By Naveen M INVOICEIT-499
                                                                    If(qrpc.jobrateplancharge.Service_Activation_Date__c != null && (qrpc.jobrateplancharge.Service_Activation_Date__c < jobClass.job.Service_Activation_Date__c) && jobClass.job.Service_Activation_Date__c != null){  
                                                                        ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.ChargeServiceStartDate  +qrpc.jobrateplancharge.Name);
                                                                        ApexPages.addMessage(errorMsg);
                                                                        return null;
                                                                    }                  
                                                                    //Added by Shruthi,This validates charge end date
                                                                            if((qrpc.jobrateplancharge.Service_End_Date__c > jobClass.job.Service_End_Date__c) && (qrpc.jobrateplancharge.Service_End_Date__c != null) && jobClass.job.Service_End_Date__c !=null){
                                                                                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.ChargeServiceEndDate  +qrpc.jobrateplancharge.Name);
                                                                                ApexPages.addMessage(errorMsg);
                                                                                return null;
                                                                            }
                                                                    //}
                                                            }
                                                    }
                                            }
                                    //}
                                    job.Contracted_MRR__c = 0;
                                    job.Total_Contract_Value__c = 0;

                                    //If they dont use service activation date for invoice generation, set the value to start date
                                    if(jobClass.job.Service_Activation_Date__c == null && 
                                                    mapConfiguration.get(CommonUtilClass.USE_SERVICE_START_DATE_FOR_INVOICE).Boolean_Value__c)
                                    {
                                            jobClass.job.Service_Activation_Date__c = jobClass.job.Start_Date__c;
                                    }

                                    //populate the exchange rate Modified by INVOICEIT-522 Dev M make sure exchange rate populates only once 
                                    if(UserInfo.isMultiCurrencyOrganization()) 
                                    {
                                            currencyObjNew = [select name from Currency__c where id =: jobClass.job.CurrencyL__c]; 
                                            if(jobClass.job.Start_Date__c != null && jobClass.job.Exchange_Rate_Applied__c == null)
                                                JobCreationUtil.populateExchangeRateOnOrder(jobClass.job, currencyObjNew.Name);
                                    }
                                    upsert jobClass.job;
                            }
                            jobId = jobClass.job.id;
                            //Query for the job details again to retrieve the job number

                            jobClass.job = JobCreationUtil.getJob(jobId);
                            job = jobClass.job;

                            for(JobProductClass qpc : jobClass.jobProducts) {
                                    if(qpc.jobproduct.Job__c == null) {
                                            qpc.jobproduct.Job__c = jobClass.job.Id;  
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
                            if(jobProductClass != null) {
                                    for(JobRatePlanClass qrc: jobProductClass.jobRatePlans) {
                                            qrc.jobrateplan = mapJobRatePlan.get(qrc.jobRatePlanCounter);
                                    }
                            }
                            // Dev M INVOICEIT-175 Previously discount was included in Total Contract Value, so i have subtracted the discount value.Used nettotal for calculating the Total Contract Value
                            Map<Integer,Job_Rate_Plan_Charge__c> mapJobRatePlanCharges = new Map<Integer,Job_Rate_Plan_Charge__c>();
                            for(JobProductClass qpc :jobClass.jobProducts)
                            {
                                    for(JobRatePlanClass qrc : qpc.jobRatePlans)
                                    {
                                            integer i = 0;
                                            for(JobRatePlanChargeClass qrpc :qrc.jobRatePlanCharges)
                                            {
                                                    // Ankit Sharma INVOICEIT-322 Populating the standard field currency (CurrencyIsoCode) only for multi currency org.

                                                    if(UserInfo.isMultiCurrencyOrganization()){
                                                            CommonUtilClass.populateCurrencyIsoCodeOnSobject(qrpc.jobrateplancharge, currencyObjNew.Name);
                                                    }
                                                    totalChargeContract = 0;
                                                    if(qrpc.jobrateplancharge.Job_Rate_Plan__c == null) {
                                                            qrpc.jobrateplancharge.Job_Rate_Plan__c = qrc.jobrateplan.id;
                                                    }
                                                    //If Quantity__c is greather than 0,then add to the map.Else do not add to the map.
                                                    // If Package__c or Bundle__c is true at jobcharge level then we are allowing to add product if quantity is 0
                                                    if(qrpc.jobrateplancharge.Quantity__c > 0 || qrpc.jobrateplancharge.Price_Type__c == system.Label.OptionUsage || qrpc.jobrateplancharge.Package__c || qrpc.jobrateplancharge.Bundle__c || qrpc.jobrateplancharge.Required_By__c != null) {


                                                            qrpc.jobrateplancharge.Sequence_No__c = ++i; 
                                                            mapJobRatePlanCharges.put(qrpc.jobRatePlanChargeCounter,qrpc.jobrateplancharge); 

                                                            // If it is one time then calcualte quantity * price
                                                            // If the charge start and end dates are present use that, else use the job start and end dates to calculate TCV
                                                            if(qrpc.jobrateplancharge.Price_Type__c == system.Label.OptionOneTime) {
                                                                    totalChargeContract = qrpc.jobrateplancharge.Net_Total__c;
                                                            } else if(qrpc.jobrateplancharge.Service_Activation_Date__c != null && qrpc.jobrateplancharge.Service_End_Date__c != null) {
                                                                    totalChargeContract = JobCreationUtil.calculateJobChargeLineAmount(qrpc.jobrateplancharge, qrpc.jobrateplancharge.Service_Activation_Date__c, qrpc.jobrateplancharge.Service_End_Date__c);
                                                            } else if(job.Number_Of_Terms__c != null && job.Service_Activation_Date__c != null) {
                                                                    totalChargeContract = JobCreationUtil.calculateJobChargeLineAmount(qrpc.jobrateplancharge, job.Service_Activation_Date__c, job.Service_Activation_Date__c.addMonths((Integer)job.Number_Of_Terms__c).addDays(-1));
                                                            }  

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

                            //This change was done for the new feature Billing Master Order
                            //When the order record has the billing master order field populated, associate each Order Charge to the corresponding charge record from the master order
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
                                                                    // Devender M INVOICEIT-214
                                                                    if(jobTierClass.jobRatePlanChargeTier.Job_Rate_Plan_Charge__c == null) {
                                                                            if(mapJobRatePlanCharges.containsKey(qrpc.jobRatePlanChargeCounter)) {
                                                                                    jobTierClass.jobRatePlanChargeTier.Job_Rate_Plan_Charge__c = mapJobRatePlanCharges.get(qrpc.jobRatePlanChargeCounter).Id;
                                                                                    mapJobRatePlanChargeTiers.put(jobTierClass.jobRatePlanChargeTierCounter, jobTierClass.jobRatePlanChargeTier);
                                                                            }
                                                                    }else {
                                                                            if(mapJobRatePlanCharges.containsKey(qrpc.jobRatePlanChargeCounter)) {
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

                            job.Total_Contract_Value__c = totalContractValue;
                            if(totalContractedMRR > 0 && job.Number_Of_Terms__c != null && job.Number_Of_Terms__c >= 1) {
                                    job.Contracted_MRR__c = (totalContractedMRR/job.Number_Of_Terms__c);
                            }

                            update job;
                            // Devender M INVOICEIT-267 Delete Order Rate Plan and Order Product while Quantity is zero and Order Rate Plan does not has any charges

                            list<Job_Rate_Plan__c> listOfJobRatePlanTodelete = new list<Job_Rate_Plan__c>();            
                            list<Job_Rate_Plan__c> listOfJobRatePlanLoc = new list<Job_Rate_Plan__c>();

                            if(!mapJobRatePlan.values().isEmpty()){
                                    listOfJobRatePlanLoc = [SELECT Id,(SELECT Id From Job_Rate_Plan_Charge__r) 
                                                            From Job_Rate_Plan__c 
                                                            WHERE Id IN : mapJobRatePlan.values()];
                                    for(Job_Rate_Plan__c jobRatePlan : listOfJobRatePlanLoc){
                                            if(jobRatePlan.Job_Rate_Plan_Charge__r.size() == 0){
                                                    listOfJobRatePlanTodelete.add(jobRatePlan);
                                            }
                                    }
                            }           

                            if(!listOfJobRatePlanTodelete.isEmpty()){
                                    delete listOfJobRatePlanTodelete;
                            } 

                            // This is to delete the jobProduct which does not have quote Product rate plan
                            list<Job_Product__c> listOfJobProductTodelete = new list<Job_Product__c>();
                            list<Job_Product__c> listOfJobProductLoc = new list<Job_Product__c>();

                            if(!mapJobProducts.values().isEmpty()) {
                                    listOfJobProductLoc = [SELECT Id, (SELECT Id From Job_Rate_Plan__r) 
                                                           FROM Job_Product__c 
                                                           WHERE Id IN : mapJobProducts.values()];
                                    for(Job_Product__c jobProduct : listOfJobProductLoc) {
                                            if(jobProduct.Job_Rate_Plan__r.size() == 0){
                                                    listOfJobProductTodelete.add(jobProduct);
                                            }
                                    }                               
                            }

                            if(!listOfJobProductTodelete.isEmpty()){
                                    delete listOfJobProductTodelete;
                            } 
                            

                    } catch(DMLException dMlEx){
                            // Added by Mani ticket : INVOICEIT-310
                            Apexpages.Message errorMessage; 
                            for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                            { 
                                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                                    Apexpages.addMessage(errorMessage);      
                            } 
                            return null; 
                    }  catch(Exception ex) {
                            database.rollback(sp);
                            CustomException.populateApexMessage(CustomException.handleError('CreateJobController', '', null, ex), 'ERROR');
                            return null;
                    }

                    return new PageReference('/' + jobId);
            }
            
            public PageReference quickSave() {
                saveJob();
                return null;
            }
            
             // This method removeJobRatePlan @return PageReference
             
            public PageReference removeCharges() {   
                    String jobRatePlanId = system.currentPageReference().getParameters().get('jobRatePlanId');
                    string sProductBundleId = system.currentPageReference().getParameters().get('productBundleId');
                    Integer jobrateplancounterval = Integer.valueOf(system.currentPageReference().getParameters().get('jobrateplancounter'));
                    if(sProductBundleId == null || sProductBundleId == '') {
                            Job_Rate_Plan__c jobRatePlanToDelete = new Job_Rate_Plan__c();
                            if(jobRatePlanId != null && jobRatePlanId.length() > 0) {
                                jobRatePlanToDelete = JobCreationUtil.getjobRatePlanToDelete(jobRatePlanId);
                                jobRatePlansToDelete.add(new Job_Rate_Plan__c(Id = jobRatePlanId));
                                jobProductsToDelete.add(new Job_Product__c (Id = jobRatePlanToDelete.Job_Product__c)) ;//check later
                            } 

                            Integer jobrateplansize = jobProductClass.jobRatePlans.size();
                            for(jobProductClass qpc : jobClass.jobProducts)
                            {
                                    for(Integer i = 0;i < jobrateplancounterval;i++)
                                    {
                                            try
                                            {
                                                    if(qpc.jobRatePlans[i].jobRatePlanCounter == jobrateplancounterval)
                                                    {
                                                            qpc.jobRatePlans.remove(i);                                   
                                                            qpc.jobproduct.clear();
                                                            jobProductsToDelete.add(qpc.jobproduct);
                                                    }
                                            }
                                            catch(Exception ex){}
                                    }
                            } 
                    } else {
                            Integer iProductBundleSequenceNo = Integer.valueOf(sProductBundleId);
                            Integer iSize = jobClass.jobProducts.size();
                            for(integer i=0; i<iSize ; i++)
                            {
                                    try
                                    {
                                            if(jobClass.jobProducts[i].jobproduct.Bundle_SequenceNumber__c == iProductBundleSequenceNo) {
                                                    if(jobClass.jobProducts[i].jobproduct.Id != null)
                                                            jobProductsToDelete.add(new Job_Product__c (Id = jobClass.jobProducts[i].jobproduct.Id)) ;
                                                    jobClass.jobProducts.remove(i);
                                                    --i;
                                            }
                                    }
                                    catch(Exception ex){}
                            }
                    }

                    iJobProductSequenceNo = 1;
                    jobBundleSequenceNo = 1;
                    map<String, Integer> mapProductBundleSequence_OldRef_NewRef = new map<String, Integer>();

                    for(JobProductClass jobProductClass : jobClass.jobProducts)
                    {
                            jobProductClass.jobproduct.SequenceNumber__c = iJobProductSequenceNo;
                            iJobProductSequenceNo ++;
                            // This is used to rearrange the quote Bundle Sequence No
                            if(jobProductClass.jobproduct.Bundle_SequenceNumber__c != null) {
                                    if(mapProductBundleSequence_OldRef_NewRef.containskey(string.valueOf(jobProductClass.jobproduct.Bundle_SequenceNumber__c))) {
                                            jobProductClass.jobproduct.Bundle_SequenceNumber__c = mapProductBundleSequence_OldRef_NewRef.get(string.valueOf(jobProductClass.jobproduct.Bundle_SequenceNumber__c));
                                    }else {
                                            mapProductBundleSequence_OldRef_NewRef.put(string.valueOf(jobProductClass.jobproduct.Bundle_SequenceNumber__c) ,jobBundleSequenceNo);
                                            jobProductClass.jobproduct.Bundle_SequenceNumber__c = jobBundleSequenceNo;
                                            jobBundleSequenceNo++;
                                    }
                            }
                    }  
                    return null;    
            }

             // This method calls calculateCharges() of the JobChargesCalculator class @return PageReference
             
            public PageReference chargeCalculator()
            {
                    try { 
                               
                           populateTierVlaues();
                           JobChargesCalculator.calculateCharges(jobClass);
                           
                    }
                    catch(Exception ex) {
                            CustomException.populateApexMessage(CustomException.handleError('CreateJobController', '', null, ex), 'ERROR');
                            return null;
                    }
                    return null;
            }

            public PageReference populateTierVlaues() {
                    decimal chargeQuantity = 0;
                    integer iSize;
                    boolean isTierExists;
                    JobRatePlanChargeTierClass jobTierClass;
                    for(JobProductClass qp : jobClass.jobProducts) {
                            for(JobRatePlanClass qrp : qp.jobRatePlans) {
                                    for(JobRatePlanChargeClass qrpc : qrp.jobRatePlanCharges) {
                                            if(qrpc.jobrateplancharge.Quantity__c > 0 && (qrpc.jobrateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME || qrpc.jobrateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE)) {
                                                    chargeQuantity = qrpc.jobrateplancharge.Quantity__c;
                                                    iSize = qrpc.jobrateplanchargeTiers.size();
                                                    isTierExists = false;
                                                    for(integer i = 0; i < iSize; i++) {
                                                            jobTierClass = qrpc.jobrateplanchargeTiers[i];
                                                            if((jobTierClass.jobRatePlanChargeTier.Start_Unit__c <= chargeQuantity && jobTierClass.jobRatePlanChargeTier.End_Unit__c >= chargeQuantity)
                                                                            ||
                                                                            (jobTierClass.jobRatePlanChargeTier.Start_Unit__c <= chargeQuantity && jobTierClass.jobRatePlanChargeTier.End_Unit__c == null)) 
                                                            {
                                                                    isTierExists = true;
                                                                    qrpc.jobrateplancharge.Unit_Price__c = jobTierClass.jobRatePlanChargeTier.Unit_Price__c;
                                                                    qrpc.jobrateplancharge.Cost_Price__c = jobTierClass.jobRatePlanChargeTier.Unit_Cost_Price__c;
                                                            }

                                                            if(i == (iSize - 1) && !isTierExists) {
                                                                    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.WARNING,system.Label.Tieredlimit + ' for "' + qp.jobProduct.Name + '"'));
                                                                    return null;
                                                            }
                                                    }
                                            }
                                    }   
                            }
                    }
                    return null;
            }

            public PageReference save() {
                    // Ankit Sharma INVOICEIT-230 handle the exception in step1 of order wizard while saving the order.

                    try {
                            decimal totalContractValue = 0;
                            decimal totalChargeContract = 0;
                            decimal totalContractedMRR = 0;

                            job.Contracted_MRR__c = 0;
                            job.Total_Contract_Value__c = 0;

                            if(jobClass.job.Service_Activation_Date__c == null && 
                                            mapConfiguration.get(CommonUtilClass.USE_SERVICE_START_DATE_FOR_INVOICE).Boolean_Value__c)
                            {
                                    jobClass.job.Service_Activation_Date__c = jobClass.job.Start_Date__c;
                            }
                            // Devender M INVOICEIT-175 Previously discount was included in Total Contract Value, so i have subtracted the discount value. Used nettotal for calculating the Total Contract Value

                            for(JobProductClass qpc : jobClass.jobProducts)
                            {
                                    for(JobRatePlanClass qrc : qpc.jobRatePlans)
                                    {
                                            for(JobRatePlanChargeClass qrpc : qrc.jobRatePlanCharges)
                                            {
                                                    totalChargeContract = 0;
                                                    //If the charge start and end dates are present use that, else use the job start and end dates to calculate TCV
                                                    if(qrpc.jobrateplancharge.Price_Type__c == system.Label.OptionOneTime) {
                                                            totalChargeContract = qrpc.jobrateplancharge.Net_Total__c;
                                                    } else if(qrpc.jobrateplancharge.Service_Activation_Date__c != null && qrpc.jobrateplancharge.Service_End_Date__c != null) {
                                                            totalChargeContract = JobCreationUtil.calculateJobChargeLineAmount(qrpc.jobrateplancharge, qrpc.jobrateplancharge.Service_Activation_Date__c, qrpc.jobrateplancharge.Service_End_Date__c);
                                                    } else if(job.Number_Of_Terms__c != null && job.Service_Activation_Date__c != null) {
                                                            totalChargeContract = JobCreationUtil.calculateJobChargeLineAmount(qrpc.jobrateplancharge, job.Service_Activation_Date__c, job.Service_Activation_Date__c.addMonths((Integer)job.Number_Of_Terms__c).addDays(-1));
                                                    }  

                                                    //calculate the ContractedMRR only if the type is not equal to one time
                                                    if(qrpc.jobrateplancharge.Price_Type__c != system.Label.OptionOneTime) {
                                                            totalContractValue += totalChargeContract;
                                                            totalContractedMRR += totalChargeContract;
                                                    } else {
                                                            totalContractValue += totalChargeContract;
                                                    }  
                                            }
                                    }
                            }

                            job.Total_Contract_Value__c = totalContractValue;
                            if(totalContractedMRR > 0 && job.Number_Of_Terms__c != null && job.Number_Of_Terms__c >= 1) {
                                    job.Contracted_MRR__c = (totalContractedMRR/job.Number_Of_Terms__c);
                            }

                            //populate the exchange rate Modified by INVOICEIT-522 Dev M make sure exchange rate populates only once 
                            if(UserInfo.isMultiCurrencyOrganization() && jobClass.job.Start_Date__c != null && jobClass.job.Exchange_Rate_Applied__c == null) 
                            {
                                    currencyObjNew = [select name from Currency__c where id =: jobClass.job.CurrencyL__c]; 
                                    JobCreationUtil.populateExchangeRateOnOrder(jobClass.job, currencyObjNew.Name);
                            }
                            upsert jobClass.job;

                            return new PageReference('/' + job.Id);
                    } catch(DMLException dMlEx){
                            // Added by Mani ticket : INVOICEIT-310
                            Apexpages.Message errorMessage; 
                            for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                            { 
                                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                                    Apexpages.addMessage(errorMessage);      
                            } 
                            return null; 
                    }  catch(Exception ex) {                                         
                            CustomException.populateApexMessage(CustomException.handleError('CreateJobController', '', null, ex), 'ERROR');
                            return null;    
                    }
            }

            //this is code is for discount
            public void applyDiscountValueToCharges() {
                    sobject sobjectJob = (sobject) jobClass.job;
                    sobjectJob.put(discountCode , '');
                    sobjectJob.put('Discount_Code__c', discountCodeCoupen);
                    jobClass.job = (Job__c) sobjectJob;

                    boolean doesHaveRecurringCharges = false;
                    JobChargesCalculator.Charges tempCharges = new JobChargesCalculator.Charges();
                    JobChargesCalculator.calculateSubtotal(jobClass, tempCharges);
                    jobClass.job.Sub_Total__c = tempCharges.subTotal;

                    for(JobProductClass jpc : jobClass.jobProducts)
                    {
                            for(JobRatePlanClass jrc : jpc.jobRatePlans)
                            {
                                    for(JobRatePlanChargeClass jrpc : jrc.jobRatePlanCharges)
                                    {
                                            if(jrpc.jobrateplancharge.Price_Type__c != system.Label.OptionOneTime) {
                                                    doesHaveRecurringCharges = true;
                                                    break;
                                            } 
                                    }
                            }
                    }

                    //Cannot apply quote/order level discount on subscription charges
                    if(doesHaveRecurringCharges){
                            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.DiscountByValueCannotbeAppliedForSubscription);
                            Apexpages.addMessage(errorMessage);
                            return;
                    }

                    decimal totalDiscount = 0.0;
                    integer noOfProducts = jobClass.jobProducts.size();
                    for(integer i = 0; i < noOfProducts; i++)
                    {
                            JobProductClass jpc = jobClass.jobProducts[i];
                            for(integer j = 0; j < jpc.jobRatePlans.size(); j++)
                            {
                                    JobRatePlanClass jrc = jpc.jobRatePlans[j];
                                    for(integer k = 0; k < jrc.jobRatePlanCharges.size(); k++)
                                    {
                                            JobRatePlanChargeClass jrpc = jrc.jobRatePlanCharges[k];
                                            if(i == (noOfProducts - 1) && k == (jrc.jobRatePlanCharges.size() - 1)) {
                                                    jrpc.jobrateplancharge.Discount_Value__c = jobClass.job.Discount_Value__c - totalDiscount;
                                                    jrpc.jobrateplancharge.Discount_Percent__c = (jrpc.jobrateplancharge.Discount_Value__c/jrpc.jobrateplancharge.Price__c) * 100;
                                            }
                                            else {
                                                    jrpc.jobrateplancharge.Discount_Value__c = ((jrpc.jobrateplancharge.Quantity__c * jrpc.jobrateplancharge.Unit_Price__c)/jobClass.job.Sub_Total__c) * jobClass.job.Discount_Value__c;
                                                    totalDiscount += jrpc.jobrateplancharge.Discount_Value__c;
                                                    jrpc.jobrateplancharge.Discount_Percent__c = (jrpc.jobrateplancharge.Discount_Value__c/jrpc.jobrateplancharge.Price__c) * 100;
                                            }
                                    }
                            }
                    }

                    JobChargesCalculator.calculateCharges(jobClass);
            }  

            public void applyDiscountPercentToCharges() {
                    sobject sobjectJob = (sobject) jobClass.job;
                    sobjectJob.put(discountCode , '');
                    sobjectJob.put('Discount_Code__c', discountCodeCoupen);
                    jobClass.job = (Job__c) sobjectJob;
                    if(jobClass.job.Discount_Percent__c != null) {    
                            JobChargesCalculator.Charges tempCharges = new JobChargesCalculator.Charges();
                            JobChargesCalculator.calculateSubtotal(jobClass, tempCharges);
                            jobClass.job.Sub_Total__c = tempCharges.subTotal;

                            for(JobProductClass jpc : jobClass.jobProducts)
                            {
                                    for(JobRatePlanClass jrc : jpc.jobRatePlans)
                                    {
                                            for(JobRatePlanChargeClass jrpc : jrc.jobRatePlanCharges)
                                            {
                                                    jrpc.jobrateplancharge.Discount_Percent__c = jobClass.job.Discount_Percent__c;
                                                    jrpc.jobrateplancharge.Discount_Value__c = (jrpc.jobrateplancharge.Quantity__c * jrpc.jobrateplancharge.Unit_Price__c) * jobClass.job.Discount_Percent__c/100;
                                            }
                                    }
                            }

                            JobChargesCalculator.calculateCharges(jobClass);
                    }
            }   

            public void applyDiscountCode() {
                    if(jobClass.job.Account__c == null) {
                            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.CannotApplyDiscountCodeWithOutSelectingAccountOnOrder);
                            Apexpages.addMessage(errorMessage);
                    } else {
                            sobject sobjectJob = (sobject) jobClass.job;                    
                            list<Discount_Code__c> listOfDiscounts = JobCreationUtil.getListOfDiscounts((string)sobjectJob.get(discountCode),jobClass);
                            if(listOfDiscounts.size() > 0) {
                                    boolean quoteLevel = false;

                                    for(Discount_Code__c discountCode : listOfDiscounts) 
                                    {
                                            if(discountCode.Apply_to__c == CommonUtilClass.APPLY_TO_QUOTEORORDER_LEVEL) {
                                                    discountCodeCoupen = discountCode.Name;
                                                    if(discountCode.Discount_Value__c > 0) {
                                                            jobClass.job.Discount_Value__c = discountCode.Discount_Value__c;
                                                            applyDiscountValueToCharges();
                                                    } else {
                                                            jobClass.job.Discount_Percent__c = discountCode.Discount_Percent__c;
                                                            applyDiscountPercentToCharges();
                                                    }
                                                    quoteLevel = true;
                                                    break;
                                            }
                                    }

                                    if(!quoteLevel) 
                                    {
                                            JobChargesCalculator.Charges tempCharges = new JobChargesCalculator.Charges();
                                            JobChargesCalculator.calculateSubtotal(jobClass, tempCharges);
                                            jobClass.job.Sub_Total__c = tempCharges.subTotal;

                                            for(JobProductClass jpc : jobClass.jobProducts)
                                            {
                                                    for(JobRatePlanClass jrc : jpc.jobRatePlans)
                                                    {
                                                            for(JobRatePlanChargeClass jrpc : jrc.jobRatePlanCharges)
                                                            {
                                                                    jrpc.jobrateplancharge.Discount_Value__c = 0;
                                                                    jrpc.jobrateplancharge.Discount_Percent__c = 0;

                                                                    for(Discount_Code__c discountCode : listOfDiscounts) 
                                                                    {
                                                                            discountCodeCoupen = discountCode.Name;
                                                                            if(discountCode.Apply_to__c == CommonUtilClass.APPLY_TO_CHARGE_LEVEL && 
                                                                                            (discountCode.Product_Family__c == jpc.jobproduct.Product_Family__c || discountCode.Product_Family__c == CommonUtilClass.MATCHING_ALL_STAR) &&
                                                                                            (discountCode.Price_Type__c.Contains(jrpc.jobrateplancharge.Price_Type__c) || discountCode.Price_Type__c == CommonUtilClass.MATCHING_ALL_STAR)) 
                                                                            {
                                                                                    if(discountCode.Discount_Value__c > 0) {
                                                                                            jrpc.jobrateplancharge.Discount_Value__c = discountCode.Discount_Value__c;
                                                                                            //if condition Added by Dhanalakshmi to avoid 'divided by 0'
                                                                                            if(jrpc.jobrateplancharge.Price__c > 0)
                                                                                            {
                                                                                                jrpc.jobrateplancharge.Discount_Percent__c = (jrpc.jobrateplancharge.Discount_Value__c/jrpc.jobrateplancharge.Price__c) * 100;
                                                                                                //Added by ram, INVOICEIT-430, when setting as both we need to set the discount type value
                                                                                                jrpc.jobrateplancharge.Discount_Type__c = CommonUtilClass.DISCOUNT_TYPE_VALUE;
                                                                                            }
                                                                                    } else {
                                                                                            jrpc.jobrateplancharge.Discount_Percent__c = discountCode.Discount_Percent__c;
                                                                                            jrpc.jobrateplancharge.Discount_Value__c = (jrpc.jobrateplancharge.Quantity__c * jrpc.jobrateplancharge.Unit_Price__c) * jrpc.jobrateplancharge.Discount_Percent__c/100;
                                                                                            //Added by ram, INVOICEIT-430, when setting as both we need to set the discount type value
                                                                                            jrpc.jobrateplancharge.Discount_Type__c = CommonUtilClass.DISCOUNT_TYPE_PERCENTAGE;
                                                                                    }
                                                                            }
                                                                    }
                                                            }
                                                    }
                                            }

                                            JobChargesCalculator.calculateCharges(jobClass);
                                    }
                            } else {
                                    Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.WARNING, system.Label.DiscountCodeIsNotValid);
                                    Apexpages.addMessage(infoMessage);
                            }
                    }
            }

            //start : this is code for createAmendments
            list<Job_Rate_Plan_Charge__c> chargesToUpdateForMidTerm = new list<Job_Rate_Plan_Charge__c>();
            public string chargeIdToBeModified {get;set;}
            public string chargeIdToBeCancelled  {get;set;}
            public PageReference modifyQuantity() {
                    chargeIdToBeModified = system.currentPageReference().getParameters().get('chargeIdToBeModified');
                    integer iSequenceNumber = 50;
                    for(integer i = 0; i < jobClass.jobProducts.size(); i++) {
                            for(integer j = 0; j < jobClass.jobProducts[i].jobRatePlans.size(); j++) {
                                    for(integer k = 0; k < jobClass.jobProducts[i].jobRatePlans[j].jobRatePlanCharges.size(); k++) {
                                            JobRatePlanChargeClass qrpc = jobClass.jobProducts[i].jobRatePlans[j].jobRatePlanCharges[k];
                                            if(qrpc.jobrateplancharge.Id == chargeIdToBeModified) {
                                                    if(qrpc.jobrateplancharge.Mid_Term_Adjustment__c != null) {
                                                            qrpc.jobrateplancharge.Previous_Mid_Term_Adjustment__c = qrpc.jobrateplancharge.Mid_Term_Adjustment__c;
                                                    }
                                                    // This below line added by Anil on May 23 on the task 181 in jira for Mid term adjustment to make out difference of Old & New 
                                                    qrpc.jobrateplancharge.Mid_Term_Status__c = 'Old';
                                                    chargesToUpdateForMidTerm.add(qrpc.jobrateplancharge);

                                                    JobRatePlanChargeClass jobRatePlanChargeClassTemp = new JobRatePlanChargeClass();
                                                    jobRatePlanChargeClassTemp.jobrateplancharge =  qrpc.jobrateplancharge.clone(false); 
                                                    if(jobRatePlanChargeClassTemp.jobrateplancharge.Sequence_No__c == 1.0) {
                                                            jobRatePlanChargeClassTemp.jobrateplancharge.Sequence_No__c = ++iSequenceNumber;
                                                    }
                                                    jobRatePlanChargeClassTemp.jobRatePlanChargeCounter = 10;
                                                    // This below line added by Anil on May 23 on the task 181 in jira  for Mid term adjustment to make out difference of Old & New 
                                                    jobRatePlanChargeClassTemp.jobrateplancharge.Mid_Term_Status__c = 'New';
                                                    //once the charge is cloned make next charge date, charge date and previous charged date as null
                                                    jobRatePlanChargeClassTemp.jobrateplancharge.Next_Charge_Date__c = null;
                                                    jobRatePlanChargeClassTemp.jobrateplancharge.Previous_Charge_Date__c = null;
                                                    jobRatePlanChargeClassTemp.jobrateplancharge.Charge_Date__c = null;
                                                    jobRatePlanChargeClassTemp.jobrateplancharge.Previous_Mid_Term_Adjustment__c = null;
                                                    //Added by Shruthi related to INVOICEIT-398 for populating old chrge id on one field of new charge
                                                    jobRatePlanChargeClassTemp.jobrateplancharge.Charge_adjusted_from__c = qrpc.jobrateplancharge.Id;
                                                    if(jobRatePlanChargeClassTemp.jobrateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_TIERED 
                                                                    || 
                                                                    jobRatePlanChargeClassTemp.jobrateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME
                                                                    ||
                                                                    jobRatePlanChargeClassTemp.jobrateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE
                                                    ) 
                                                    {
                                                            jobRatePlanChargeClassTemp.jobRatePlanChargeTiers = new list<JobRatePlanChargeTierClass>();
                                                            integer tierCounter = 0;
                                                            for(JobRatePlanChargeTierClass jobTierClass : qrpc.jobRatePlanChargeTiers) {
                                                                    JobRatePlanChargeTierClass clonedJobTierClass = new JobRatePlanChargeTierClass();
                                                                    clonedJobTierClass.jobRatePlanChargeTier = jobTierClass.jobRatePlanChargeTier.clone(false);
                                                                    clonedJobTierClass.jobRatePlanChargeTier.job_Rate_Plan_Charge__c = null;
                                                                    clonedJobTierClass.jobRatePlanChargeTier.OwnerId = Userinfo.getuserId();        
                                                                    clonedJobTierClass.jobRatePlanChargeTierCounter = ++tierCounter;
                                                                    jobRatePlanChargeClassTemp.jobRatePlanChargeTiers.add(clonedJobTierClass);
                                                            }
                                                    }

                                                    jobClass.jobProducts[i].jobRatePlans[j].jobRatePlanCharges.add(jobRatePlanChargeClassTemp);
                                                    chargesToUpdateForMidTerm.add(jobRatePlanChargeClassTemp.jobrateplancharge);
                                            } 
                                    }
                            }
                    }
                    return null;
            }

            public PageReference cancelQuantity() {
                    chargeIdToBeCancelled  = system.currentPageReference().getParameters().get('chargeIdToBeCancelled');
                    for(integer i = 0; i < jobClass.jobProducts.size(); i++) {
                            for(integer j = 0; j < jobClass.jobProducts[i].jobRatePlans.size(); j++) {
                                    for(integer k = 0; k < jobClass.jobProducts[i].jobRatePlans[j].jobRatePlanCharges.size(); k++) {
                                            JobRatePlanChargeClass qrpc = jobClass.jobProducts[i].jobRatePlans[j].jobRatePlanCharges[k];
                                            if(qrpc.jobrateplancharge.Id == chargeIdToBeCancelled) {
                                                    if(qrpc.jobrateplancharge.Mid_Term_Adjustment__c != null) {
                                                            qrpc.jobrateplancharge.Previous_Mid_Term_Adjustment__c = qrpc.jobrateplancharge.Mid_Term_Adjustment__c;
                                                    }
                                                    qrpc.jobrateplancharge.Mid_Term_Status__c = 'Old';
                                                    chargesToUpdateForMidTerm.add(qrpc.jobrateplancharge);
                                            } 
                                    }
                            }
                    }
                    return null;
            }

            public PageReference saveAmendment() {
                    // sometimes while calling the saveJob method, their might be some validations(like they have not entered start date etc) at the point of time we should not call the mid term code
                    // if the PageReference return's null do not execute the mid term code else call the midterm code
                    PageReference pg = saveJob();
                    
                    if(pg == null) { 
                        return null;  
                    }
                    if(!chargesToUpdateForMidTerm.isEmpty()) { 
                            AggregateResult[] groupedResults = [SELECT max(Version__c) maxversion
                                                                FROM Mid_Term_Adjustment__c 
                                                                WHERE Order__c =: job.Id
                                                                GROUP BY Order__c];

                            Mid_Term_Adjustment__c midTermAdjustment = new Mid_Term_Adjustment__c(Order__c = job.Id);
                            if(groupedResults.isEmpty()) {
                                    midTermAdjustment.Version__c = 1;
                                    midTermAdjustment.Name = 'Adjustment Version 1';
                            } else {
                                    decimal maxversion = (decimal) groupedResults.get(0).get('maxversion');
                                    midTermAdjustment.Version__c = ++maxversion;
                                    midTermAdjustment.Name = 'Adjustment Version ' + string.valueOf(midTermAdjustment.Version__c);
                            }

                            SavePoint sp = Database.setSavepoint(); 
                            try {
                                    insert midTermAdjustment;
                                    Job_Rate_Plan_Charge__c charge;
                                    list<Job_Rate_Plan_Charge__c> chargesToUpdateMidTerm = new list<Job_Rate_Plan_Charge__c>();
                                    // Devender M 06 Nov 2013 When adding a mid-term adjustment, if Quantity is 0, Order Line is still displayed in Products Related List. We should add the products only when the quantity is > 0 and if the type is not usage
                                    for(integer i = 0; i < chargesToUpdateForMidTerm.size(); i++) {
                                            charge = chargesToUpdateForMidTerm[i];
                                            if(charge.Quantity__c > 0 || charge.Price_Type__c == system.Label.OptionUsage) {
                                                    charge.Mid_Term_Adjustment__c = midTermAdjustment.Id;
                                                    chargesToUpdateMidTerm.add(chargesToUpdateForMidTerm[i]);
                                            } 
                                    }

                                    upsert chargesToUpdateMidTerm;
                            } catch(DMLException dMlEx){
                                    // Added by Mani ticket : INVOICEIT-310
                                    Apexpages.Message errorMessage; 
                                    for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                                    { 
                                            errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                                            Apexpages.addMessage(errorMessage);      
                                    } 
                                    return null; 
                            }  catch(Exception ex) {
                                    Database.rollback(sp);
                                    CustomException.populateApexMessage(CustomException.handleError('CreateJobController', '', null, ex), 'ERROR');
                                    return null;
                            }
                    }
                    return new PageReference('/' + job.Id);
            }
            // end of createAmendments code

            //start of dispatch code
            map<string, list<Stock_Item__c>> map_ProductId_listOfStockItems;
            map<string, decimal> map_ProductId_Quantity;
            set<Id> setOfProductIds;
            set<Id> setOfChargesIdsToBeDispatched;
            list<Job_Rate_Plan_Charge__c> chargesToBeDispatched;
            list<Dispatched_Item__c> listOfDispatchedToInsert;
            Dispatched_Item__c dispatchedItem;
            boolean isChargeQtyExistsInStock;
            list<Stock_Item__c> listOfStocksForMap;
            decimal dAvailableQuantity = 0;
            set<string> setOfScannedBarCodes; 
            public string sBarCodes {get; set;}
            list<Stock_Item__c> listOfStocks;
            public Dispatch__c dispatch {get;set;}
            map<Id, Job_Rate_Plan_Charge__c> map_ChargeId_Charge;
            public Boolean isDispatchSuccess  {get;set;}
            public map<Id, decimal> map_ProductId_AvailableQuantity {get;set;}

            public void initializeDispatch() {
                    dispatch = new Dispatch__c(Order__c = job.Id);
                    isDispatchSuccess = false;
                    setOfProductIds = new set<Id>();
                    for(JobProductClass jpc : jobClass.jobProducts)
                    {
                            setOfProductIds.add(jpc.jobProduct.Product__c);
                    }

                    // query the AvailableStock present in the warehouse
                    list<AggregateResult> aggRes = JobCreationUtil.getAvailableStocks(setOfProductIds);

                    Id productId;
                    decimal availableQty;
                    map_ProductId_AvailableQuantity = new map<Id, decimal>();
                    for(AggregateResult agg : aggRes) {
                            productId = (Id) agg.get('productId');
                            availableQty = (decimal) agg.get('availableQty');
                            map_ProductId_AvailableQuantity.put(productId, availableQty);
                            setOfProductIds.remove(productId);
                    }

                    for(Id prodId : setOfProductIds) {
                            map_ProductId_AvailableQuantity.put(prodId, 0);
                            setOfProductIds.remove(prodId);
                    }
            }

            public PageReference createDispatchLineItems_UsingScanner() {
                    map_ProductId_listOfStockItems = new map<string, list<Stock_Item__c>>();
                    map_ProductId_Quantity = new map<string, decimal>();
                    setOfProductIds = new set<Id>();
                    setOfChargesIdsToBeDispatched = new set<Id>();
                    isChargeQtyExistsInStock = true;
                    map_ChargeId_Charge = new map<Id, Job_Rate_Plan_Charge__c>();
                    for(JobProductClass jpc : jobClass.jobProducts)
                    {
                            for(JobRatePlanClass jrc : jpc.jobRatePlans)
                            {
                                    for(JobRatePlanChargeClass jrpc : jrc.jobRatePlanCharges)
                                    {
                                            if(jrpc.jobrateplancharge.Price_Type__c == system.Label.OptionOneTime && jrpc.jobrateplancharge.Dispatch__c && jrpc.jobrateplancharge.Remaining_Quantity__c > 0) {
                                                    if(jrpc.jobrateplancharge.Quantity_to_Dispatch__c == null) {
                                                            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.EnterQuantityToDispatch + + jpc.jobProduct.Name);
                                                            Apexpages.addMessage(errorMessage);  
                                                            return null; 
                                                    }
                                                    else if(jrpc.jobrateplancharge.Quantity_to_Dispatch__c > jrpc.jobrateplancharge.Remaining_Quantity__c) {     
                                                            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.QuantityToDispatch + jpc.jobProduct.Name);
                                                            Apexpages.addMessage(errorMessage);  
                                                            return null; 
                                                    } else { 
                                                            setOfChargesIdsToBeDispatched.add(jrpc.jobrateplancharge.Id);
                                                            //add to the map
                                                            map_ChargeId_Charge.put(jrpc.jobrateplancharge.Id, jrpc.jobrateplancharge);
                                                            //intrested product ids
                                                            setOfProductIds.add(jpc.jobProduct.Product__c);
                                                    }
                                            }
                                    }
                            }
                    }
                    sBarCodes = sBarCodes.trim();
                    list<string> listOfScannedBarCodes = sBarCodes.split('\n');
                    setOfScannedBarCodes = new set<string>();
                    for(string s : listOfScannedBarCodes) {
                            if(s != null && s.trim()!='') {
                                    setOfScannedBarCodes.add(s.trim()); 
                            }
                    }

                    if(setOfChargesIdsToBeDispatched.size() > 0) {
                            listOfStocks = JobCreationUtil.getListOfStockItems(setOfProductIds, setOfScannedBarCodes);
                            if(listOfStocks.isEmpty()) {
                                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.DispatchProducts_Scanned_items_does_not_exists);
                                    Apexpages.addMessage(errorMessage);
                                    return null;
                            } else {
                                    for(Stock_Item__c si : listOfStocks) {
                                            if(!setOfProductIds.Contains(si.Product__c)) {
                                                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.ProductYouScanned + si.Product__r.Name + ' - ' + si.Bar_code__c  + '" is not in the ordered product(s)');
                                                    Apexpages.addMessage(errorMessage);
                                                    return null;
                                            }
                                    }
                            }
                            createDispatchLineItems_Logic();
                            if(isDispatchSuccess) {
                                    return new PageReference('/' + job.Id);
                            }
                    } else {
                            Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO, system.Label.NoProductsAreSelectedToDispatch);
                            Apexpages.addMessage(infoMessage);
                    }
                    return null;
            }

            public PageReference createDispatchLineItems() {
                    chargesToBeDispatched = new list<Job_Rate_Plan_Charge__c>();
                    map_ProductId_listOfStockItems = new map<string, list<Stock_Item__c>>();
                    map_ProductId_Quantity = new map<string, decimal>();
                    setOfProductIds = new set<Id>();
                    setOfChargesIdsToBeDispatched = new set<Id>();
                    isChargeQtyExistsInStock = true;
                    map_ChargeId_Charge = new map<Id, Job_Rate_Plan_Charge__c>();

                    //select the charges whose Status is Dispatched
                    for(JobProductClass jpc : jobClass.jobProducts)
                    {
                            for(JobRatePlanClass jrc : jpc.jobRatePlans)
                            {
                                    for(JobRatePlanChargeClass jrpc : jrc.jobRatePlanCharges)
                                    {
                                            if(jrpc.jobrateplancharge.Price_Type__c == system.Label.OptionOneTime && jrpc.jobrateplancharge.Dispatch__c && jrpc.jobrateplancharge.Remaining_Quantity__c > 0) {
                                                    if(jrpc.jobrateplancharge.Quantity_to_Dispatch__c == null) {
                                                            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.EnterQuantityToDispatch + + jpc.jobProduct.Name);
                                                            Apexpages.addMessage(errorMessage);  
                                                            return null; 
                                                    }
                                                    else if(jrpc.jobrateplancharge.Quantity_to_Dispatch__c > jrpc.jobrateplancharge.Remaining_Quantity__c) {     
                                                            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.QuantityToDispatch + jpc.jobProduct.Name);
                                                            Apexpages.addMessage(errorMessage);  
                                                            return null; 
                                                    } else { 
                                                            setOfChargesIdsToBeDispatched.add(jrpc.jobrateplancharge.Id);
                                                            //add to the map
                                                            map_ChargeId_Charge.put(jrpc.jobrateplancharge.Id, jrpc.jobrateplancharge);
                                                    }
                                            }
                                    }
                            }
                    }
                    if(setOfChargesIdsToBeDispatched.size() > 0) {
                            createDispatchLineItems_Logic();
                            if(isDispatchSuccess) {
                                    return new PageReference('/' + job.Id);
                            }
                    } else {
                            Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO, system.Label.NoProductsAreSelectedToDispatch);
                            Apexpages.addMessage(infoMessage);
                    }

                    return null; 
            }

            public PageReference createDispatchLineItems_Logic() {
                    listOfDispatchedToInsert = new list<Dispatched_Item__c>();
                    //query all the above charges whose status is Dispatched
                    chargesToBeDispatched = JobCreationUtil.getChargesToBeDispatched(setOfChargesIdsToBeDispatched);
                    SavePoint sp;
                    try { 
                            sp = Database.SetSavePoint();
                            if(chargesToBeDispatched.size() > 0) {
                                    //query the Stock Items based on selected products
                                    if(setOfScannedBarCodes == null || setOfScannedBarCodes.isEmpty()) {
                                            //construct a set of InvoiceIT Product, so that we can query all the StockItems
                                            for(Job_Rate_Plan_Charge__c  charge : chargesToBeDispatched) {
                                                    setOfProductIds.add(charge.Job_Rate_Plan__r.Job_Product__r.Product__c);
                                            }

                                            listOfStocks = JobCreationUtil.getListOfStockItems(setOfProductIds);
                                            if(listOfStocks.isEmpty()) {
                                                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, System.Label.dispatchScanItems_Product_Does_not_exists);
                                                    Apexpages.addMessage(errorMessage);
                                                    return null;
                                            }
                                    } 

                                    //based on product id, consolidate the stocks present
                                    for(Stock_Item__c stockItem : listOfStocks) {
                                            if(map_ProductId_listOfStockItems.containsKey(stockItem.Product__c)) {
                                                    listOfStocksForMap = map_ProductId_listOfStockItems.get(stockItem.Product__c);
                                                    dAvailableQuantity += stockItem.Available_Quantity__c;
                                            } else {
                                                    listOfStocksForMap = new list<Stock_Item__c>();
                                                    dAvailableQuantity = stockItem.Available_Quantity__c;
                                            }

                                            listOfStocksForMap.add(stockItem);
                                            map_ProductId_listOfStockItems.put(stockItem.Product__c, listOfStocksForMap);
                                            map_ProductId_Quantity.put(stockItem.Product__c, dAvailableQuantity);
                                    }

                                    decimal chargeQuantityToDispatch = 0;
                                    for(Job_Rate_Plan_Charge__c charge : chargesToBeDispatched) {
                                            dAvailableQuantity = 0;
                                            chargeQuantityToDispatch = map_ChargeId_Charge.get(charge.Id).Quantity_to_Dispatch__c;
                                            if(map_ProductId_Quantity.containsKey(charge.Job_Rate_Plan__r.Job_Product__r.Product__c)) {
                                                    dAvailableQuantity = map_ProductId_Quantity.get(charge.Job_Rate_Plan__r.Job_Product__r.Product__c);
                                                    if(chargeQuantityToDispatch > dAvailableQuantity) {
                                                            isChargeQtyExistsInStock  = false;
                                                            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.DispatchProducts_Insufficient_stock);
                                                            Apexpages.addMessage(errorMessage);
                                                            return null;
                                                    }
                                                    map_ProductId_Quantity.put(charge.Job_Rate_Plan__r.Job_Product__r.Product__c, (dAvailableQuantity - chargeQuantityToDispatch));
                                                    if(charge.Quantity_Already_Dispatched__c == null) {
                                                            charge.Quantity_Already_Dispatched__c = 0;
                                                    }
                                                    charge.Quantity_Already_Dispatched__c = charge.Quantity_Already_Dispatched__c + chargeQuantityToDispatch;
                                            } else {
                                                    isChargeQtyExistsInStock  = false;
                                                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.DispatchProducts_Insufficient_stock);
                                                    Apexpages.addMessage(errorMessage);
                                                    return null;
                                            }
                                    }

                                    if(isChargeQtyExistsInStock) {
                                            insert dispatch;
                                            for(Job_Rate_Plan_Charge__c charge : chargesToBeDispatched) {
                                                    charge.Dispatch__c = false;
                                                    listOfStocksForMap = map_ProductId_listOfStockItems.get(charge.Job_Rate_Plan__r.Job_Product__r.Product__c);
                                                    decimal remaningUsage = map_ChargeId_Charge.get(charge.Id).Quantity_to_Dispatch__c;
                                                    integer usageQuantity = integer.ValueOf(remaningUsage);

                                                    if(charge.Quantity_Already_Dispatched__c == charge.Quantity__c) {
                                                            charge.Dispatch__c = true;  
                                                    }

                                                    for(Stock_Item__c stockItem : listOfStocksForMap) {
                                                            if(remaningUsage > 0 && stockItem.Available_Quantity__c > 0) {
                                                                    if(remaningUsage < stockItem.Available_Quantity__c) {

                                                                            dispatchedItem = new Dispatched_Item__c(Account__c = job.Account__c,
                                                                                            Order__c = job.Id,
                                                                                            Order_Rate_Plan_Charge__c = charge.Id,
                                                                                            Quantity__c = remaningUsage,
                                                                                            Stock_Item__c = stockItem.Id,
                                                                                            Name = charge.Job_Rate_Plan__r.Job_Product__r.Product__r.Name,
                                                                                            Dispatch__c = dispatch.Id
                                                                            );

                                                                            listOfDispatchedToInsert.add(dispatchedItem);
                                                                            stockItem.Available_Quantity__c = stockItem.Available_Quantity__c - remaningUsage;
                                                                            remaningUsage = 0;
                                                                            break;
                                                                    } else {

                                                                            remaningUsage = remaningUsage - stockItem.Available_Quantity__c;
                                                                            dispatchedItem = new Dispatched_Item__c(Account__c = job.Account__c,
                                                                                            Order__c = job.Id,
                                                                                            Order_Rate_Plan_Charge__c = charge.Id,
                                                                                            Quantity__c = stockItem.Available_Quantity__c,
                                                                                            Stock_Item__c = stockItem.Id,
                                                                                            Name = charge.Job_Rate_Plan__r.Job_Product__r.Product__r.Name,
                                                                                            Dispatch__c = dispatch.Id
                                                                            );

                                                                            listOfDispatchedToInsert.add(dispatchedItem);   
                                                                            stockItem.Available_Quantity__c = 0;    
                                                                    }
                                                            }
                                                    }   

                                                    map_ProductId_listOfStockItems.put(charge.Job_Rate_Plan__r.Job_Product__r.Product__c, listOfStocksForMap);
                                            }

                                            insert listOfDispatchedToInsert;

                                            list<Stock_Item__c> listOfStocksToUpdate = new list<Stock_Item__c>();
                                            for(list<Stock_Item__c> listOfStocksLocal :  map_ProductId_listOfStockItems.Values()) {
                                                    listOfStocksToUpdate.addAll(listOfStocksLocal);
                                            }

                                            //update the stocks
                                            update listOfStocksToUpdate;

                                            map<Integer,Job_Rate_Plan_Charge__c> mapJobRatePlanCharges = new map<Integer,Job_Rate_Plan_Charge__c>();
                                            for(JobProductClass jpc : jobClass.jobProducts)
                                            {
                                                    for(JobRatePlanClass jrc : jpc.jobRatePlans)
                                                    {
                                                            for(JobRatePlanChargeClass jrpc : jrc.jobRatePlanCharges)
                                                            {
                                                                    if(jrpc.jobrateplancharge.Dispatch__c) {
                                                                            jrpc.jobrateplancharge.Status__c = CommonUtilClass.STATUS_DELIVERED;
                                                                    }                                 
                                                            }
                                                    }
                                            }

                                            //update the job charges
                                            update chargesToBeDispatched;

                                            Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO, system.Label.DispatchProducts_Delivery_Confirmation);
                                            Apexpages.addMessage(infoMessage);

                                            isDispatchSuccess = true;
                                            return null;
                                    }
                            } else {
                                    Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO, system.Label.DispatchProducts_NoProducts);
                                    Apexpages.addMessage(infoMessage);
                                    return null;
                            }
                    } catch(DMLException dMlEx){
                            // Added by Mani ticket : INVOICEIT-310
                            Apexpages.Message errorMessage; 
                            for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                            { 
                                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                                    Apexpages.addMessage(errorMessage);      
                            } 
                            return null; 
                    }  catch(Exception ex) {
                            Database.rollback(sp);
                            CustomException.populateApexMessage(CustomException.handleError('CreateJobController', '', null, ex), 'ERROR');
                    }

                    return null;       
            }         
            //end of dispatch code

            public boolean displayPopup {get; set;}
            public string jobRatePlanChargeCounterForTier {get; set;}
            public void closePopup() {            
                    displayPopup = false;   
            } 

            // Anil Pinto INVOICEIT-61 This new method is created as a validations required while saving the tiers
            // S.A.Manigandan SUP-278 This method has been modified to check the VR on Start & End Unit 
            public Pagereference saveAndClosePopup(){
                    integer i=1;
                    for(JobProductClass  qpc : jobClass.jobProducts) {
                            for(JobRatePlanClass  qrc : qpc.jobRatePlans) { 
                                    for(JobRatePlanChargeClass  qrpc : qrc.jobRatePlanCharges) {
                                            Job_Rate_Plan_Charge_Tier__c jobRatePlanChargeTier = null;
                                            if(qrpc.jobRatePlanChargeTiers.size() > 1){
                                                    for(JobRatePlanChargeTierClass jobRatePlanChargeTierClass : qrpc.jobRatePlanChargeTiers){

                                                            if(jobRatePlanChargeTier == null){
                                                                    jobRatePlanChargeTier = jobRatePlanChargeTierClass.jobRatePlanChargeTier;
                                                            } 
                                                            else{
                                                                    if(!qrpc.jobRatePlanChargeTiers.isEmpty() && qrpc.jobRatePlanChargeTiers.get(0).jobRatePlanChargeTier.Start_Unit__c < 0){
                                                                            // the start unit should start from 1
                                                                            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.StartUnitCannotHaveNegativeValue);
                                                                            Apexpages.addMessage(errorMessage);
                                                                            return null;
                                                                    } else if(!qrpc.jobRatePlanChargeTiers.isEmpty() && (qrpc.jobRatePlanChargeTiers.get(0).jobRatePlanChargeTier.End_Unit__c!=null && qrpc.jobRatePlanChargeTiers.get(0).jobRatePlanChargeTier.End_Unit__c < qrpc.jobRatePlanChargeTiers.get(0).jobRatePlanChargeTier.Start_Unit__c)){
                                                                            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.EndUnitShouldNotBeLessThanStartUnit));  
                                                                            //displayPopup = false; 
                                                                            return null;
                                                                    } else if(jobRatePlanChargeTierClass.jobRatePlanChargeTier.Start_Unit__c < 0){
                                                                            // the start unit should start from 1
                                                                            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.StartUnitCannotHaveNegativeValue);
                                                                            Apexpages.addMessage(errorMessage);
                                                                            return null;
                                                                    } else if(jobRatePlanChargeTierClass.jobRatePlanChargeTier.End_Unit__c!=null && jobRatePlanChargeTierClass.jobRatePlanChargeTier.End_Unit__c < jobRatePlanChargeTierClass.jobRatePlanChargeTier.Start_Unit__c){
                                                                            // throw error msg
                                                                            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.EndUnitShouldNotBeLessThanStartUnit);
                                                                            Apexpages.addMessage(errorMessage);
                                                                            return null; 
                                                                    } else if(jobRatePlanChargeTier.End_Unit__c != null){
                                                                            decimal iEndUnitValue = jobRatePlanChargeTier.End_Unit__c;
                                                                            if(jobRatePlanChargeTierClass.jobRatePlanChargeTier.Start_Unit__c <= iEndUnitValue){
                                                                                    Apexpages.Message errorMessage1 = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.TierStartUnit);
                                                                                    Apexpages.addMessage(errorMessage1);
                                                                                    return null;
                                                                            }
                                                                    }
                                                                    jobRatePlanChargeTier = jobRatePlanChargeTierClass.jobRatePlanChargeTier;
                                                            }
                                                            i=i+1;
                                                    }
                                            }
                                            else{
                                                    if(!qrpc.jobRatePlanChargeTiers.isEmpty() && qrpc.jobRatePlanChargeTiers.get(0).jobRatePlanChargeTier.Start_Unit__c < 0){
                                                            // the start unit should start from 1
                                                            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.StartUnitCannotHaveNegativeValue);
                                                            Apexpages.addMessage(errorMessage);
                                                            return null;
                                                    }else if(!qrpc.jobRatePlanChargeTiers.isEmpty() && (qrpc.jobRatePlanChargeTiers.get(0).jobRatePlanChargeTier.End_Unit__c!=null && qrpc.jobRatePlanChargeTiers.get(0).jobRatePlanChargeTier.End_Unit__c < qrpc.jobRatePlanChargeTiers.get(0).jobRatePlanChargeTier.Start_Unit__c)){
                                                            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.EndUnitShouldNotBeLessThanStartUnit));  
                                                            //displayPopup = false; 
                                                            return null;
                                                    }
                                            }              
                                    }
                            }
                    }
                    displayPopup = false;  
                    return null;    
            }
            public void showPopup() {              
                    jobRatePlanChargeCounterForTier = system.currentPageReference().getParameters().get('jobRatePlanChargeCounterForTier');
                    displayPopup = true;    
            }


            public void newTier() {
                    //integer jobRatePlanChargeCounterForTier = integer.ValueOf(system.currentPageReference().getParameters().get('jobRatePlanChargeCounterForTier'));
                    for(JobProductClass qpc :jobClass.jobProducts) {
                            for(JobRatePlanClass qrc : qpc.jobRatePlans) { 
                                    for(JobRatePlanChargeClass qrpc :qrc.jobRatePlanCharges) {
                                            if(qrpc.jobRatePlanChargeCounter == integer.ValueOf(jobRatePlanChargeCounterForTier)) {
                                                    JobRatePlanChargeTierClass quoteTierClass = new JobRatePlanChargeTierClass();
                                                    quoteTierClass.jobRatePlanChargeTier = new Job_Rate_Plan_Charge_Tier__c();
                                                    quoteTierClass.jobRatePlanChargeTierCounter = ++jobRatePlanChargeTierCounter;
                                                    qrpc.jobRatePlanChargeTiers.add(quoteTierClass);
                                            }
                                    }
                            }
                    }
            }

            public void removeTier() {            
                    string jobTierIdToDelete = system.currentPageReference().getParameters().get('jobTierIdToDelete');
                    Integer jobTierCounterToDelete = Integer.valueOf(system.currentPageReference().getParameters().get('jobTierCountertoDelete'));
                    Integer jobRatePlanChargeCounterForTier = Integer.valueOf(system.currentPageReference().getParameters().get('jobRatePlanChargeCounterForTier'));

                    if(jobTierIdToDelete != null && jobTierIdToDelete.Length() > 0) {
                            Job_Rate_Plan_Charge_Tier__c jobTierToDelete = new Job_Rate_Plan_Charge_Tier__c(Id = jobTierIdToDelete);
                            delete jobTierToDelete;
                    }

                    for(JobProductClass  qpc : jobClass.jobProducts) {
                            for(JobRatePlanClass  qrc : qpc.jobRatePlans) { 
                                    for(JobRatePlanChargeClass  qrpc : qrc.jobRatePlanCharges) {
                                            if(qrpc.jobRatePlanChargeCounter == jobRatePlanChargeCounterForTier) {
                                                    for(integer i = 0; i < qrpc.jobRatePlanChargeTiers.size(); i++) {
                                                            JobRatePlanChargeTierClass quoteTierClass = qrpc.jobRatePlanChargeTiers[i];
                                                            if(quoteTierClass.jobRatePlanChargeTierCounter == jobTierCounterToDelete) {
                                                                    qrpc.jobRatePlanChargeTiers.remove(i);
                                                            }
                                                    }
                                            }
                                    }
                            }
                    }
            }

            /* code for displaying the product charges in a popup for selecting INVOICEIT-348 */
            public boolean displayPopupForProductRPC {get; set;}
            public list<ClassSelectProductCharge> listOfClassSelectProductCharge {get; set;}

            public void showPopupForProductRPC() {   
                    displayPopupForProductRPC = true;    
                    ClassSelectProductCharge innerClassSelectProductCharge;
                    listOfClassSelectProductCharge = new list<ClassSelectProductCharge>();

                    for(Product_Rate_Plan_Charge__c productCharge : listProductRatePlanCharges) {
                            innerClassSelectProductCharge = new ClassSelectProductCharge(false, productCharge); 
                            listOfClassSelectProductCharge.add(innerClassSelectProductCharge);
                    }
            }

            public void closePopupForProductRPC() {        
                    displayPopupForProductRPC = false;    
                    listProductRatePlanCharges.clear();
                    listOfClassSelectProductCharge.clear();
                    //saveAndCloseProductRPCPopup();
            } 

            public Pagereference saveAndCloseProductRPCPopup() { 
                    displayPopupForProductRPC = false;    
                    listProductRatePlanCharges.clear();

                    for(ClassSelectProductCharge innerClassSelectProductCharge : listOfClassSelectProductCharge) {
                            if(innerClassSelectProductCharge.isSelected) {
                                    listProductRatePlanCharges.add(innerClassSelectProductCharge.productCharge);        
                            }   
                    }
                    listOfClassSelectProductCharge.clear();
                    addJobCharges();
                    return null;    
            }
            /* code for displaying the product charges in a popup for selecting INVOICEIT-348 */ 
            
            //Added by dhanalakshmi for INVOICEIT-345
            string clonedCurrecyId = null;
            decimal conversionRate = 1;
            public PageReference cloneOrder() {
                String JobId;
                savepoint sp = Database.setSavepoint();
                try{
                        boolean Align_Dates_Of_Order_To_Products = mapConfiguration.get('ALIGN_DATES_OF_ORDER_TO_PRODUCTS').Boolean_Value__c;
                        boolean Use_Service_Start_Date_For_Invoice = mapConfiguration.get('USE_SERVICE_START_DATE_FOR_INVOICE').Boolean_Value__c;
                        isDisableCloneButtons = true;
                        Job__c newJobToClone= jobClass.job.clone(false);
                        if(clonedCurrecyId != null) {
                            newJobToClone.CurrencyL__c = clonedCurrecyId;
                        }
                        newJobToClone.OwnerId = UserInfo.getUserId();
                        // Added by Dev M ticket INVOICEIT-522
                        newJobToClone.Exchange_Rate_Applied__c = null;
                        jobClass.job = newJobToClone;
                        if(!Use_Service_Start_Date_For_Invoice && sButtonName == 'quickSave')
                        {
                            jobClass.job.Service_Activation_Date__c = null;
                            jobClass.job.Start_Date__c = null;
                            jobClass.job.Service_End_Date__c = null;

                            
                            
                        }
                        jobClass.job.Payment_Plan__c = null;
                        jobClass.job.Status__c = null;
                        jobClass.job.Renewed_From__c = null;
                        job = jobClass.job;
                        
                        Job_Product__c newJobProduct;
                        Job_Rate_Plan__c newJobRatePlan;
                        Job_Rate_Plan_Charge__c newJobRatePlanCharge;
                        Job_Rate_Plan_Charge_Tier__c newJobRatePlanChargeTier;
                        for(JobProductClass jpc: jobClass.jobProducts)
                        {
                            newJobProduct = jpc.jobproduct.clone(false);
                            newJobProduct.Renewed_From__c = null;
                            newJobProduct.Job__c = null;
                            jpc.jobproduct = newJobProduct;
                            for(JobRatePlanClass jrc: jpc.jobRatePlans)
                            {
                                newJobRatePlan = jrc.jobrateplan.clone(false);
                                newJobRatePlan.Job_Product__c = null;
                                newJobRatePlan.Renewed_From__c = null;
                                jrc.jobrateplan = newJobRatePlan;
                                for(JobRatePlanChargeClass jrpc : jrc.jobRatePlanCharges)
                                {
                                    newJobRatePlanCharge = jrpc.jobrateplancharge.clone(false);
                                    newJobRatePlanCharge.Job_Rate_Plan__c = null;
                                    // added by Dev M INVOICEIT-571
                                    newJobRatePlanCharge.Order__c = null;
                                    newJobRatePlanCharge.Revenue_Recognition_Start_Date__c = null;
                                    newJobRatePlanCharge.Revenue_Recognition_End_Date__c = null;
                                    newJobRatePlanCharge.Billing_Master_Grouped_Quantity__c = null;
                                    newJobRatePlanCharge.Renewed_From__c = null;
                                    if(!Use_Service_Start_Date_For_Invoice || !Align_Dates_Of_Order_To_Products && sButtonName == 'quickSave')
                                    {
                                        newJobRatePlanCharge.Service_Activation_Date__c = null;
                                        newJobRatePlanCharge.Service_End_Date__c = null;
                                    }
                                    newJobRatePlanCharge.Previous_Charge_Date__c = null;
                                    newJobRatePlanCharge.Next_Charge_Date__c = null;
                                    newJobRatePlanCharge.Charge_Date__c = null;
                                    newJobRatePlanCharge.Status__c = null;
                                    newJobRatePlanCharge.Unit_Of_Measurement__c = jrpc.jobrateplancharge.Unit_Of_Measurement__c;
                                    //added by Lopa 09/10/15 for INVOICEIT-614 
                                    if(newJobRatePlanCharge.VAT__c != null) {
                                        newJobRatePlanCharge.VAT__c = newJobRatePlanCharge.VAT__c * conversionRate;
                                    }
                                    if(newJobRatePlanCharge.Tax__c != null) {
                                        newJobRatePlanCharge.Tax__c = newJobRatePlanCharge.Tax__c * conversionRate;
                                    }
                                    newJobRatePlanCharge.Unit_Price__c = newJobRatePlanCharge.Unit_Price__c * conversionRate;
                                    if(newJobRatePlanCharge.Cost_Price__c != null) {
                                        newJobRatePlanCharge.Cost_Price__c = newJobRatePlanCharge.Cost_Price__c * conversionRate;
                                    }
                                    newJobRatePlanCharge.Profit__c = newJobRatePlanCharge.Profit__c * conversionRate;
                                    newJobRatePlanCharge.Discount_Value__c = newJobRatePlanCharge.Discount_Value__c * conversionRate;
                                    if(clonedCurrecyId != null) {
                                        newJobRatePlanCharge.CurrencyL__c = clonedCurrecyId;
                                    }
                                    jrpc.jobrateplancharge = newJobRatePlanCharge;
                                    for(JobRatePlanChargeTierClass JobTierClass : jrpc.JobRatePlanChargeTiers) {
                                        newJobRatePlanChargeTier = JobTierClass.JobRatePlanChargeTier.clone(false);
                                        newJobRatePlanChargeTier.Job_Rate_Plan_Charge__c = null;
                                        newJobRatePlanChargeTier.OwnerId = UserInfo.getUserId();
                                        if(newJobRatePlanChargeTier.Unit_Cost_Price__c != null) {
                                            newJobRatePlanChargeTier.Unit_Cost_Price__c = newJobRatePlanChargeTier.Unit_Cost_Price__c * conversionRate;
                                        }
                                        newJobRatePlanChargeTier.Unit_Price__c = newJobRatePlanChargeTier.Unit_Price__c * conversionRate;
                                        jobTierClass.jobRatePlanChargeTier = newJobRatePlanChargeTier;
                                            
                                    }
                                }
                            }
                        }
                        if(sButtonName == 'quickSave')
                        {
                            saveJob();
                            JobId = jobClass.job.Id;
                            return new PageReference('/' + JobId);
                        }
                        else
                        {
                            PageReference pageRef = page.createJobStep1;
                            //pageRef.setRedirect(true);
                            return pageRef; 
                        }
                    }
                    catch(Exception ex){
                        isDisableCloneButtons = false;
                        Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
                        Apexpages.addMessage(errorMessage);
                        DataBase.RollBack(sp); 
                        return null;
                    }
            }
            
            //end  
                
    }