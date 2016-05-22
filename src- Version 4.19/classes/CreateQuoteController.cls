public with sharing class CreateQuoteController {
        ApexPages.StandardController controller{get;set;}
        public Quote__c quote {set; get;}
        public String sPrefix {get; set;}
        private map<Id,QuoteProductClass> mapQuoteProducts = new  map<Id,QuoteProductClass>();
        private map<String, Product_Catalog_Filter_Criteria__c> mapProductCatalogFilterCriteria{get;set;}
        private map<String,Configuration__c> mapConfiguration{get;set;}
        private map<String, Custom_Mappings__c> mapCustomMappings;
        public List<Quote_Product__c> listQuoteProducts = new List<Quote_Product__c>();
        public List<Quote_Rate_Plan__c> listQuoteRatePlans = new  List<Quote_Rate_Plan__c>();
        public List<Quote_Rate_Plan__c> quoteRatePlansToDelete = new List<Quote_Rate_Plan__c>();
        public List<Quote_Product__c> quoteProductsToDelete = new List<Quote_Product__c>();
        public QuoteClass quoteClass {get;set;}
        public QuoteProductClass quoteProductClass {get;set;}
        public QuoteRatePlanClass quoteRatePlanClass {get;set;}
        public QuoteRatePlanChargeClass quoteRatePlanChargeClass = new QuoteRatePlanChargeClass();
        QuoteRatePlanChargeTierClass quoteTierClass;
        public List<Quote_Rate_Plan_Charge__c> listQuoteRatePlanCharges{get;set;}   
        public List<Product_Rate_Plan__c> listProductRatePlans{get;set;}
        public List<Product_Rate_Plan_Charge__c> listProductRatePlanCharges{get;set;}
        public String quoteRatePlanId {get;set;}
        private Integer quoteProductCounter = 0;
        private Integer quoteRatePlanCounter = 0;
        public Integer quoteRateplanChargeCounter = 0;
        public Integer quoteRatePlanChargeTierCounter = 0;
        public boolean isMultipleRatePlans {get;set;}
        public String selectedProductId {get;set;}
        public transient String selectedProductName {get;set;}
        public String selectedRatePlanId {get; set;}
        public String searchstring {get; set;}
        //these variables are used in createQuoteStep3 page only
        public String sCurrencyName{get; set;}
        public String sPage2Name = 'createQuoteStep2';
        public String sPage3Name = 'createQuoteStep3';
        public Integer iSequenceNo = 1;
        private Integer quoteBundleSequenceNo = 1;
        private Integer iQuoteProductSequenceNo = 1;
        private Integer iQuoteRatePlanSequenceNo = 1;
        public String sFilterCriteria {get; set;}
        public String sProductsLimit {get; set;}
        public String displayfields {get; set;}
        public String objectname {get; set;}
        public String orderfield {get; set;}
        public String searchfields {get; set;}
        //The following objects hold the describe results 
        map<String, Schema.SObjectField> mapDescribeQuoteProduct = Schema.SObjectType.Quote_Product__c.fields.getMap();
        map<String, Schema.SObjectField> mapDescribeQuoteRatePlan = Schema.SObjectType.Quote_Rate_Plan__c.fields.getMap();
        map<String, Schema.SObjectField> mapDescribeQuoteRatePlanCharge = Schema.SObjectType.Quote_Rate_Plan_Charge__c.fields.getMap();
        //public String sNoOfDecimalForCurrencyValues {get;set;}
        public string quote_LevelDiscount_By {get;set;}
        public string discountCode {get;set;}
        public string discountCodeCoupen = '';
        Quote_Rate_Plan_Charge_Tier__c quoteTier;
        public map<string, string> quoteTierApiNames {get;set;}
        string currecyISOCode = null;
        public boolean isDisableCloneButtons {get;set;} 
        public string widthOfChargeNameText {get;set;}
        public string widthOfProductNameText {get;set;}
        //Adds extension to Quote standard controller
        public string displayChargePopUp {get;set;}
        //This is used for ProductBundle
        set<string> setOfQuoteRatePlan = new set<string>();
        public boolean displayProductBundle {get; set;}
        public String displayfieldsForProductBundle {get; set;}
        public String objectnameForProductBundle {get; set;}
        public String orderfieldForProductBundle {get; set;}
        public String searchfieldsForProductBundle {get; set;}
        public String sFilterCriteriaForProductBundle {get; set;}
        public boolean displayDiscountRowinPage3 {get; set;}
        public boolean displayVATRowinPage3 {get; set;}
        public boolean displayTAXRowinPage3 {get; set;} 
        boolean isProductBundle = false;
        integer productBundleCount = 0;
        set<Id> setofChargeIds = new set<Id>();
        string productBundle = '';
        map<Id,Product_Bundle_Line__c> mapChargeId_Bundle = new map<Id,Product_Bundle_Line__c>(); 
        string productBundleId;
        public boolean isDisableDiscount {get;set;}   
        // Dhanalakshmi, INVOICEIT-430, To assign the default value of the discount type field at charge level
        public String sDefaultValueOfDiscountType;    
        public CreateQuoteController(ApexPages.StandardController stdController) {
            sPrefix = CommonUtilClass.getPrefix();
            try {
                isDisableDiscount = true;
                //widthOfChargeNameText  =  'width: 10px';
                isDisableCloneButtons = false;
                controller = stdController;
                this.quote = (Quote__c)stdController.getRecord();
                quoteClass = new QuoteClass();
                quoteClass.quote = quote;
                mapConfiguration = Configuration__c.getAll();            
                 /* Modified By     : Rama Krishna.v: 4-4-2014: INVOICEIT-336
                    Comments      : Populating the width for the product and charge names text box.
                 */
                widthOfChargeNameText  = mapConfiguration.get('CHARGENAME_TEXTBOX_WIDTH').String_Value__c;
                widthOfProductNameText = mapConfiguration.get('PRODUCTNAME_TEXTBOX_WIDTH').String_Value__c;
                displayChargePopUp = mapConfiguration.get('DISPLAY_PRODUCT_CHARGE_POP_UP').String_Value__c;
                displayProductBundle = mapConfiguration.get('DISPLAY_PRODUCT_BUNDLES_SEARCH').Boolean_Value__c;
                displayDiscountRowinPage3 = mapConfiguration.get('DISPLAY_DISCOUNT').Boolean_Value__c;
                displayVATRowinPage3 = mapConfiguration.get('DISPLAY_VAT').Boolean_Value__c;
                displayTAXRowinPage3 = mapConfiguration.get('DISPLAY_TAX').Boolean_Value__c;
                mapProductCatalogFilterCriteria = Product_Catalog_Filter_Criteria__c.getAll();
                mapCustomMappings = Custom_Mappings__c.getAll();
                //Initalize the custom settings values
                sPage2Name = mapConfiguration.get('QUOTE_PAGE_2').String_Value__c;
                sPage3Name = mapConfiguration.get('QUOTE_PAGE_3').String_Value__c;
                //This string holds the columnswidth parameter to be specified in page2 pageblocktable
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
                quote_LevelDiscount_By = mapConfiguration.get('DISCOUNT_BY_VALUE_OR_PERCENTAGE').String_Value__c;
                discountCode = mapConfiguration.get('QUOTE_DISCOUNT_CODE_FIELD').String_Value__c;
                // get tier api names
                quoteTierApiNames = QuoteCreationUtil.getObjectApis(sPrefix+'Quote_Rate_Plan_Charge_Tier__c');
                if(quote.id != null) {
                    this.quote = QuoteCreationUtil.getQuote(quote.id);   
                    quoteClass.quote = quote;    
                    listQuoteProducts = QuoteCreationUtil.getListQuoteProducts(quote.id);
                    Currency__c currencyObj = CommonUtilClass.getCurrencyObjectForId(quote.CurrencyL__c);
                    sCurrencyName = currencyObj.Currency_Symbol__c + ' ';
                    currecyISOCode = currencyObj.Name;
                    //add listQuoteProducts to quoteProductClass
                    for(Quote_Product__c qp : listQuoteProducts) {
                        quoteProductClass = new QuoteProductClass();
                        quoteProductClass.quoteProductCounter = ++quoteProductCounter;
                        quoteProductClass.quoteproduct = qp;
                        quoteClass.quoteProducts.add(quoteProductClass);
                    }
                    //get the list of quoteProduct Ids in to Map
                    mapQuoteProducts = QuoteCreationUtil.getMapQuoteProducts(listQuoteProducts);
                    Set<Id> mapQuoteProductKeyset = new Set<Id>();
                    mapQuoteProductKeyset = mapQuoteProducts.keySet();
                    List<Id> quoteProductIds = new List<Id>();
                    Integer mapQuoteProductKeysetSize = mapQuoteProductKeyset.size();
                    //Add all the Ids to list quoteProductIds
                    quoteProductIds.addAll(mapQuoteProductKeyset);
                    //getListQuoteRatePlans returns list of Quote RatePlans and quoteRatePlan Charges
                    listQuoteRatePlans = QuoteCreationUtil.getListQuoteRatePlans(quoteProductIds);
                    map<Id, list<Quote_Rate_Plan_Charge_Tier__c>> map_QuoteChargeId_QuoteTiers = QuoteCreationUtil.queryTiersBasedOnQuoteId(quote.Id);
                    //get the listQuoteRatePlanCharges from the listQuoteRatePlans 
                    if(listQuoteRatePlans != null) {
                        for(Quote_Rate_Plan__c qr : listQuoteRatePlans ) {
                            quoteProductClass = mapQuoteProducts.get(qr.Quote_Product__c);
                            quoteRatePlanClass = new QuoteRatePlanClass();
                            quoteRatePlanClass.quoterateplan = qr;
                            for(Quote_Rate_Plan_Charge__c qrpc : qr.Quote_Rate_Plan_Charge__r) {
                                quoteRatePlanChargeClass = new QuoteRatePlanChargeClass();
                                quoteRatePlanChargeClass.quoterateplancharge = qrpc;
                                quoteRatePlanChargeClass.quoteRatePlanChargeCounter = ++quoteRateplanChargeCounter;                       
                                //Disabling the remove button for Product bundle
                                 if(setOfQuoteRatePlan.contains(string.valueOf(quoteProductClass.quoteproduct.Bundle_SequenceNumber__c)))
                                    quoteRatePlanChargeClass.displayRemove = false;
                                 else
                                    quoteRatePlanChargeClass.displayRemove = true; 

                                //Check wheather the quantity is editable or not
                                if(qr.Quote_Product__r.Product_Bundle__r.Bundle_Type__c != null && qr.Quote_Product__r.Product_Bundle__r.Bundle_Type__c == 'Bundle' && qr.Product_Rate_Plan__c == null)     
                                    quoteRatePlanChargeClass.isQuantityEditable = qr.Quote_Product__r.Product_Bundle__r.Is_Quantity_Editable__c; 
                                else if(qrpc.Product_Bundle_Line__c != null)
                                    quoteRatePlanChargeClass.isQuantityEditable = qrpc.Product_Bundle_Line__r.Is_Quantity_Editable__c;
                                //add the tiers
                                if(map_QuoteChargeId_QuoteTiers.containsKey(qrpc.Id)) {
                                    for(Quote_Rate_Plan_Charge_Tier__c quoteTier : map_QuoteChargeId_QuoteTiers.get(qrpc.Id)) {
                                        quoteTierClass = new QuoteRatePlanChargeTierClass(); 
                                        quoteTierClass.quoteRatePlanChargeTier = quoteTier;
                                        quoteTierClass.quoteRatePlanChargeTierCounter = ++quoteRatePlanChargeTierCounter;
                                        quoteRatePlanChargeClass.quoteRatePlanChargeTiers.add(quoteTierClass);
                                    }
                                }
                                quoteRatePlanClass.quoteRatePlanCharges.add(quoteRatePlanChargeClass);
                            }
                            quoteRatePlanClass.quoteRatePlanCounter = ++quoteRatePlanCounter;
                            quoteProductClass.quoteRatePlans.add(quoteRatePlanClass);
                            mapQuoteProducts.remove(qr.Quote_Product__c);
                            mapQuoteProducts.put(qr.Quote_Product__c,quoteProductClass);
                            if(quoteProductClass.quoteproduct.Bundle_SequenceNumber__c != null)
                                setOfQuoteRatePlan.add(string.valueOf(quoteProductClass.quoteproduct.Bundle_SequenceNumber__c)); 
                        }
                        quoteClass = new QuoteClass();
                        quoteClass.quote = quote;
                        Integer iQuoteProductSize = listQuoteProducts.size();
                        for(integer i = 0; i < iQuoteProductSize; i++) {
                            Id quoteProductId = listQuoteProducts.get(i).Id;
                            QuoteProductClass qpc = mapQuoteProducts.get(quoteProductId); 
                            qpc.quoteProductCounter = ++quoteProductCounter;
                            quoteClass.quoteProducts.add(qpc);
                        }                        
                        iQuoteProductSequenceNo = 1;
                        for(QuoteProductClass quoteProductClass : quoteClass.quoteProducts) {
                            quoteProductClass.quoteproduct.SequenceNumber__c = iQuoteProductSequenceNo;
                            iQuoteProductSequenceNo ++;
                        }
                        iQuoteRatePlanSequenceNo = 1;
                        for(QuoteProductClass quoteProductClass : quoteClass.quoteProducts) {
                            for(QuoteRatePlanClass quoterateplan : quoteProductClass.quoteRatePlans) {
                                quoterateplan.quoterateplan.SequenceNumber__c = iQuoteRatePlanSequenceNo;
                                iQuoteRatePlanSequenceNo ++;
                            }
                        } 
                        quoteBundleSequenceNo = setOfQuoteRatePlan.size()+1;               
                    } 
                }

                //If the currency is null then fill in the default currency
                //If the valid to is null then fill the defualt valid to
                if(quote.CurrencyL__c == null) {
                    fillDefaultCurrencyValue();                                     
                }
                if(quote.Valid_To__c == null) {
                    quote.Valid_To__c = system.today() + Integer.valueOf(mapConfiguration.get('QUOTE_VALIDITY_PERIOD').NUMBER_VALUE__C);                
                } 
                 /* Modified By       : Ankit Sharma: 07-08-2014: INVOICEIT-377
                    Comments        : Enable disable Discount buttons in vf page based on login user permission.
                 */
                if(quote_LevelDiscount_By == CommonUtilClass.APPLY_DISCOUNT_BY_VALUE) {
                    if (!Schema.sObjectType.Quote_Rate_Plan_Charge__c.fields.Discount_Value__c.isUpdateable() || !Schema.sObjectType.Quote_Rate_Plan_Charge__c.fields.Discount_Value__c.isCreateable()){                
                        isDisableDiscount = false;
                    }   
                }     
                if(quote_LevelDiscount_By == CommonUtilClass.APPLY_DISCOUNT_BY_PERCENTAGE) {
                    if (!Schema.sObjectType.Quote_Rate_Plan_Charge__c.fields.Discount_Percent__c.isUpdateable() || !Schema.sObjectType.Quote_Rate_Plan_Charge__c.fields.Discount_Percent__c.isCreateable()){                
                        isDisableDiscount = false;
                    }   
                }            
                //Added by dhanalakshmi for INVOICEIT-430 - display the discount type picklist default value if it has 
                if(quote_LevelDiscount_By == CommonUtilClass.APPLY_DISCOUNT_BY_BOTH) {
                    Schema.DescribeFieldResult descrideRessult = Job_Rate_Plan_Charge__c.Discount_Type__c.getDescribe();
                    List <Schema.PicklistEntry> picklistValues = descrideRessult.getPicklistValues();        
                    for (Schema.PicklistEntry pv: picklistValues) {
                        if (pv.isDefaultValue()) {
                            sDefaultValueOfDiscountType = pv.getValue();
                        }
                    }
                }
                
            } catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
                Apexpages.addMessage(errorMessage);
            }
        }  
        public PageReference fillDefaultCurrencyValue() {
            // Added by Dev M Ticket : INVOICEIT-604
            try {
                //Use the default currency of the logged in user
                //If that is null then pickk the default currency from the custom settings
                String tempString;
                if(UserInfo.getDefaultCurrency() != null){
                    tempString = UserInfo.getDefaultCurrency(); 
                }else{
                    tempString = mapConfiguration.get('DEFAULT_CURRENCY').String_Value__c;
                }
                Currency__c currencyObj = CommonUtilClass.getCurrencyObject(tempString);
                quote.CurrencyL__c = currencyObj.Id;
                sCurrencyName = currencyObj.Currency_Symbol__c + ' '; 
                currecyISOCode = currencyObj.Name;  
             } catch(Exception ex) {
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.Label.PleaseCreateCurrency_s));
             }                                                                
                return null;
        }      
        public PageReference changeCurrencySelection() {
            Currency__c currencyObj = CommonUtilClass.getCurrencyObjectForId(quote.CurrencyL__c);
            sCurrencyName = currencyObj.Currency_Symbol__c + ' ';
            currecyISOCode = currencyObj.Name;
            return null;
        }
         //The methods from Step1 to Step3 are for PageNavigation @return PageReference
        public PageReference step1() {
            return Page.createquotestep1;
        }
        Account account;
        public PageReference step2() {
            sFilterCriteria = '';
            sFilterCriteriaForProductBundle = ''; 
            sProductsLimit = '' + (mapConfiguration.get('PRODUCT_SEARCH_LIMIT').Number_Value__c).intValue();     
            account = (Account) CommonUtilClass.getSobjectById(CommonUtilClass.OBJECT_NAME_ACCOUNT, quote.Account__c);
            //Add the valid from and to dates to the query searchstring
            if(quote.Start_Date__c != null) {
                sFilterCriteria = ' and Valid_From_Date__c <= ' + CommonUtilClass.convertDateToString(quote.Start_Date__c)
                        + ' and (Valid_To_Date__c >= ' + CommonUtilClass.convertDateToString(quote.Start_Date__c)
                        + ' Or Valid_To_Date__c = null )';                    
                sFilterCriteriaForProductBundle = ' and Start_Date__c <= ' + CommonUtilClass.convertDateToString(quote.Start_Date__c)
                + ' and (End_Date__c >= ' + CommonUtilClass.convertDateToString(quote.Start_Date__c)
                + ' Or End_Date__c = null )';        
            }          
            sFilterCriteriaForProductBundle = sFilterCriteriaForProductBundle + ' and Currency__c =\'' + quote.CurrencyL__c+ '\'' ;
            for(Product_Catalog_Filter_Criteria__c criteria : mapProductCatalogFilterCriteria.values()) {
                if(criteria.Destination_Object__c == CommonUtilClass.OBJECT_NAME_PRODUCT
                        && (criteria.Source_Object__c == CommonUtilClass.OBJECT_NAME_QUOTE || criteria.Source_Object__c == CommonUtilClass.OBJECT_NAME_ACCOUNT)
                        ) 
                {
                    //Add these to the map
                    //We need both the fieldname and the value to query
                    String value;

                    if(criteria.Source_Object__c == CommonUtilClass.OBJECT_NAME_QUOTE) {
                        value = (String)quote.get((String)criteria.get('Source_Field__c'));
                    } else {
                        value = (String)account.get((String)criteria.get('Source_Field__c'));
                    }

                    if(value != null) {
                        String key = (String)criteria.get('Destination_Field__c');
                        sFilterCriteria += ' AND ' + key +' = \'' + value + '\'';      
                    }     
                }
            }

            return new PageReference('/apex/' + sPage2Name);
        }

        public PageReference step3() {        
            chargeCalculator();
            return new PageReference('/apex/' + sPage3Name);
        }
         //This method get the rateplans for the selectedProduct @return PageReference
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
                                && (criteria.Source_Object__c == CommonUtilClass.OBJECT_NAME_QUOTE || criteria.Source_Object__c == CommonUtilClass.OBJECT_NAME_ACCOUNT)) 
                        {
                            string value;
                            if(criteria.Source_Object__c == CommonUtilClass.OBJECT_NAME_QUOTE) {
                                value = (String)quote.get((String)criteria.get('Source_Field__c'));
                            } else {
                                value = (String)account.get((String)criteria.get('Source_Field__c'));
                            }

                            if(value != null) {
                                String key = (String)criteria.get('Destination_Field__c');
                                searchMap.put(key, value);  
                            }            
                        }
                    }
                    listProductRatePlans = QuoteCreationUtil.getProductRatePlans(selectedProductId,quote.Valid_To__c,searchMap);
                //}
                if(listProductRatePlans.size() == 1) {
                    isMultipleRatePlans = false;
                    selectedRatePlanId = listProductRatePlans.get(0).id;

                    system.currentPageReference().getParameters().put('ratePlanId',selectedRatePlanId);
                    getRatePlanChargesForRatePlan();
                } else if(listProductRatePlans.size() > 1) {
                    isMultipleRatePlans = true;
                } else{
                    //this means listProductRatePlans.size() == 0
                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.INFO,system.Label.Product_ProductRatePlan);
                    Apexpages.addMessage(errorMessage);
                }
               } else {
                    getProductBundle(selectedProductId);
              }
            }
            catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage());
                Apexpages.addMessage(errorMessage);
                return null;
            }
            return null;
        }

         //This method is used for the product bundles @return PageReference
        public PageReference getProductBundle(string locProductBundleId) {
            productBundleId = locProductBundleId;

            Product_Bundle__c refProductBundle = CommonUtilClass.getProductBundle(locProductBundleId);

            list<Product_Bundle_Line__c> listofProductBundleLine = CommonUtilClass.getProductBundleLine(locProductBundleId);

            map<Id, map<Id, map<Id,Product_Bundle_Line__c>>> map_ProductId_mapRateId_SetofChargeIds = new map<Id, map<Id,  map<Id,Product_Bundle_Line__c>>>();
            map<Id, map<Id,Product_Bundle_Line__c>> localMapRate;
            map<Id,Product_Bundle_Line__c> localMapCharge;

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

            if(refProductBundle.Bundle_Type__c == 'Bundle') {
                Quote_Product__c  quoteproduct = new Quote_Product__c();
                quoteproduct.Name = refProductBundle.Name;
                quoteproduct.SequenceNumber__c = iQuoteProductSequenceNo;
                iQuoteProductSequenceNo ++;   
                quoteproduct.Product_Bundle__c = productBundleId;
                quoteproduct.Bundle_SequenceNumber__c = quoteBundleSequenceNo;
                quoteproduct.Product_Code__c = refProductBundle.Product_Bundle_Code__c;
                //Add SelectedJobproduct to jobProductClass
                quoteProductClass = new QuoteProductClass();
                quoteProductClass.quoteProductCounter = ++quoteProductCounter;
                quoteProductClass.quoteproduct = quoteproduct;

                Quote_Rate_Plan__c quoteRatePlan = new Quote_Rate_Plan__c();
                quoteRatePlan.Name = refProductBundle.Name;
                quoteRatePlan.SequenceNumber__c = iQuoteRatePlanSequenceNo;
                iQuoteRatePlanSequenceNo ++;

                //Add jobRatePlan of SelectedProduct to jobRatePlanClass
                quoteRatePlanClass = new QuoteRatePlanClass();
                quoteRatePlanClass.quoteRatePlanCounter = ++quoteRatePlanCounter;
                quoteRatePlanClass.quoterateplan = quoteRatePlan;
                //Add all productrateplancharges to jobrateplancharges list
                Quote_Rate_Plan_Charge__c quoteRatePlanCharge = new Quote_Rate_Plan_Charge__c(); 
                quoteRatePlanCharge.Unit_Price__c = refProductBundle.Bundle_Price__c;  
                quoteRatePlanCharge.Unit_Of_Measurement__c = refProductBundle.Unit_Of_Measurement__c;
                quoteRatePlanCharge.Price_Format__c = refProductBundle.Pricing_Model__c;
                quoteRatePlanCharge.Quantity__c = refProductBundle.Quantity__c;
                quoteRatePlanCharge.Price_Type__c = refProductBundle.Price_Type__c;
                quoteRatePlanCharge.CurrencyL__c = refProductBundle.Currency__c;
                quoteRatePlanCharge.VAT__c = 0;
                quoteRatePlanCharge.Tax__c = 0;
                quoteRatePlanCharge.Name = refProductBundle.Name;
                quoteRatePlanCharge.Sequence_No__c = iSequenceNo;
                quoteRatePlanCharge.Is_Product_Editable__c = refProductBundle.Is_Price_Editable__c;

                iSequenceNo++;                           
                quoteRatePlanChargeClass = new QuoteRatePlanChargeClass();
                quoteRatePlanChargeClass.quoteRatePlanChargeCounter = ++quoteRateplanChargeCounter;
                quoteRatePlanChargeClass.quoterateplancharge = quoteRatePlanCharge;
                quoteRatePlanChargeClass.isQuantityEditable = refProductBundle.Is_Quantity_Editable__c;
                quoteRatePlanChargeClass.displayRemove = true;
                
                quoteRatePlanClass.quoteRatePlanCharges.add(quoteRatePlanChargeClass);
                quoteProductClass.quoteRatePlans.add(quoteRatePlanClass);
                quoteClass.quoteProducts.add(quoteProductClass);
                productBundleCount++;
                iSequenceNo = 1; 
            }

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
                    addQuoteCharges();
                } 
            }

            mapChargeId_Bundle = new map<Id,Product_Bundle_Line__c>();
            productBundleCount = 0;
            productBundleId = '';
            quoteBundleSequenceNo++;
            return null;
        }
     
         // This method get the RatePlancharges  for the selectedProduct @return PageReference
        public PageReference getRatePlanChargesForRatePlan() {
            try {
                isMultipleRatePlans = false;
                selectedRatePlanId = system.currentPageReference().getParameters().get('ratePlanId');
                if(selectedRatePlanId != null) {
                    map<String,String> searchMap = new map<String,String>();
                    //Check the custom settings map if there are any criteria for Product_Rate_Plan_Charge__c
                    for(Product_Catalog_Filter_Criteria__c criteria : mapProductCatalogFilterCriteria.values()) {
                        if(criteria.Destination_Object__c == CommonUtilClass.OBJECT_NAME_PRODUCT_RATE_PLAN_CHARGE
                                && (criteria.Source_Object__c == CommonUtilClass.OBJECT_NAME_QUOTE || criteria.Source_Object__c == CommonUtilClass.OBJECT_NAME_ACCOUNT)) {
                            //Add these to the map
                            //We need both the fieldname and the value to query
                            String value;

                            if(criteria.Source_Object__c == CommonUtilClass.OBJECT_NAME_QUOTE) {
                                value = (String)quote.get((String)criteria.get('Source_Field__c'));
                            } else {
                                value = (String)account.get((String)criteria.get('Source_Field__c'));
                            }
                            if(value != null) {
                                String key = (String)criteria.get('Destination_Field__c');
                                searchMap.put(key, value);  
                            }              
                        }
                    }
                    listProductRatePlanCharges = QuoteCreationUtil.getProductRatePlanCharges(selectedRatePlanId, quote.CurrencyL__c, searchMap);
                }

                if(listProductRatePlanCharges != null && !listProductRatePlanCharges.isEmpty()) {
                      
                    //INVOICEIT-348
                    boolean displayPopUp = mapConfiguration.get('DISPLAY_PRODUCT_CHARGE_POP_UP').Boolean_Value__c;
                    //Amended by Shruthi relates to INVOICEIT-379
                    if((displayPopUp == null || !displayPopUp)|| listProductRatePlanCharges.size() == 1) {
                        addQuoteCharges(); 
                    } else {
                        showPopupForProductRPC();
                    }    
                } else {
                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.WARNING, system.Label.Product_Rateplan_Currency);
                    Apexpages.addMessage(errorMessage);
                }
            }
            catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage());
                Apexpages.addMessage(errorMessage);
                return null;
            }
            return null;
        }
         //This method Add QuoteCharges to  QuoteRatePlanCharges Class @return charges
        public PageReference addQuoteCharges() {
            boolean isQuoteProductExists = false;
            boolean isQuoteRatePlanExists = false;
            boolean isQuoteRatePlanChargeExists = false;
            boolean isTierProductExists = false;
            try {
                Map<String,String> searchMap = new Map<String,String>();
                Product_Bundle_Line__c productLine;
                Product_Rate_Plan__c selectedrateplan = new Product_Rate_Plan__c();
                
                if(!isProductBundle) {
                    selectedrateplan = QuoteCreationUtil.getProductRatePlanFromList(listProductRatePlans,selectedRatePlanId);
                }else {
                    selectedrateplan = JobCreationUtil.getProductRatePlan(selectedRatePlanId);
                    listProductRatePlanCharges = JobCreationUtil.getProductRatePlanCharges(selectedrateplan.Id, quote.CurrencyL__c, setofChargeIds);
                }
                
                Quote_Product__c  quoteproduct = new Quote_Product__c();
                Product__c selectedproduct = QuoteCreationUtil.getProduct(selectedProductId);        
                quoteproduct.Product__c = selectedproduct.Id;
                quoteproduct.Name = selectedproduct.Name;
                quoteproduct.Product_Family__c = selectedproduct.Product_Family__c;
                quoteproduct.Product_Code__c = selectedproduct.Product_Code__c;
                quoteproduct.Description__c = selectedproduct.Description__c;
                quoteproduct.SequenceNumber__c = iQuoteProductSequenceNo;
                iQuoteProductSequenceNo ++;
                if(productBundleId != '' && productBundleId != null) {
                    quoteproduct.Product_Bundle__c = productBundleId;
                    quoteproduct.Bundle_SequenceNumber__c = quoteBundleSequenceNo;
                    //quoteBundleSequenceNo++;
                }  
                //dynamic field mapping starts here
                SObject s = (SObject)selectedproduct;
                SObject sObjectQuoteProduct = (SObject)quoteproduct;
                for(Custom_Mappings__c custom : mapCustomMappings.values()) {
                    if(custom.Destination_Object__c == CommonUtilClass.OBJECT_NAME_QUOTE_PRODUCT
                            && custom.Source_Object__c == CommonUtilClass.OBJECT_NAME_PRODUCT) {
                        String destinationField = (String)custom.get('Destination_Field__c');
                        String sourceField = (String)custom.get('Source_Field__c');

                        Schema.SObjectField f = mapDescribeQuoteProduct.get(destinationField);
                        if(s.get(sourceField) != null) {
                            sObjectQuoteProduct.put(f, s.get(sourceField));
                        }
                    }
                }
                quoteproduct = (Quote_Product__c)sObjectQuoteProduct;

                quoteProductClass = new QuoteProductClass();
                quoteProductClass.quoteProductCounter = ++quoteProductCounter;
                quoteProductClass.quoteproduct = quoteproduct; 

                //quoteRatePlanClass = QuoteCreationUtil.checkForDuplicateRatePlans(selectedRatePlanId, quoteProductClass.quoteRatePlans);

                Quote_Rate_Plan__c quoteRatePlan = new Quote_Rate_Plan__c();
                quoteRatePlan.Name = selectedrateplan.Name;
                quoteRatePlan.Description__c = selectedrateplan.Description__c;
                quoteRatePlan.Product_Rate_Plan__c = selectedrateplan.Id;
                quoteRatePlan.SequenceNumber__c = iQuoteRatePlanSequenceNo;
                iQuoteRatePlanSequenceNo ++;
                //dynamic field mapping starts here
                s = (SObject)selectedrateplan;
                SObject sObjectQuoteRatePlan = (SObject)quoteRatePlan;

                for(Custom_Mappings__c custom : mapCustomMappings.values()) {
                    if(custom.Destination_Object__c == CommonUtilClass.OBJECT_NAME_QUOTE_RATE_PLAN
                            && custom.Source_Object__c == CommonUtilClass.OBJECT_NAME_PRODUCT_RATE_PLAN) {
                        String destinationField = (String)custom.get('Destination_Field__c');
                        String sourceField = (String)custom.get('Source_Field__c');

                        Schema.SObjectField f = mapDescribeQuoteRatePlan.get(destinationField);
                        if(s.get(sourceField) != null) {
                            sObjectQuoteRatePlan.put(f, s.get(sourceField)); 
                        }
                    }
                }
                quoteRatePlan = (Quote_Rate_Plan__c)sObjectQuoteRatePlan;

                quoteRatePlanClass = new QuoteRatePlanClass();
                quoteRatePlanClass.quoteRatePlanCounter = ++quoteRatePlanCounter;
                quoteRatePlanClass.quoterateplan = quoteRatePlan;
                for(Product_Rate_Plan_Charge__c selectedProductratePlanCharge : listProductRatePlanCharges){
                    Quote_Rate_Plan_Charge__c quoteRatePlanCharge = new Quote_Rate_Plan_Charge__c(); 
                    quoteRatePlanCharge.Unit_Of_Measurement__c = selectedProductratePlanCharge.Unit_Of_Measurement__c;
                    //if the charge is tiered then dont populate the price
                    if(selectedProductratePlanCharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_TIERED) {
                        isTierProductExists = true;
                        quoteRatePlanCharge.Unit_Price__c = 0;
                    }else {
                        quoteRatePlanCharge.Unit_Price__c = selectedProductratePlanCharge.Unit_Price__c;  
                    }
                    quoteRatePlanCharge.Name = selectedProductratePlanCharge.Name;
                    quoteRatePlanCharge.Price_Format__c = selectedProductratePlanCharge.Price_Format__c;
                    if(selectedProductratePlanCharge.Default_Quantity__c != null) {
                        quoteRatePlanCharge.Quantity__c = selectedProductratePlanCharge.Default_Quantity__c;
                    }else if(mapConfiguration.get('DEFAULT_QUANTITY_IN_WIZARDS').Number_Value__c != null){
                        quoteRatePlanCharge.Quantity__c = Integer.valueOf(mapConfiguration.get('DEFAULT_QUANTITY_IN_WIZARDS').Number_Value__c);
                    } else {
                        quoteRatePlanCharge.Quantity__c = 1;
                    }
                    quoteRatePlanCharge.Charge_Code__c = selectedProductratePlanCharge.Charge_Code__c;
                    quoteRatePlanCharge.Price__c = null;
                    quoteRatePlanCharge.Cost__c = null;
                    quoteRatePlanCharge.Price_Type__c = selectedProductratePlanCharge.Price_Type__c;
                    quoteRatePlanCharge.CurrencyL__c = selectedProductratePlanCharge.CurrencyL__c;
                    quoteRatePlanCharge.Accounting_Code__c = selectedProductratePlanCharge.Accounting_Code__c;
                    quoteRatePlanCharge.Product_Rate_Plan_Charge__c = selectedProductratePlanCharge.id;
                    quoteRatePlanCharge.Product_Charge_Category__c = selectedProductratePlanCharge.Product_Charge_Category__c;
                    // Modified By Dev.M INVOICEIT-548
                    quoteRatePlanCharge.Deferred_Revenue_Accounting_Code__c = selectedProductratePlanCharge.Deferred_Revenue_Accounting_Code__c;
                    // Modified By Naveen M INVOICEIT-539
                    quoteRatePlanCharge.Uplift__c = selectedProductratePlanCharge.Uplift__c;
                    quoteRatePlanCharge.Name = selectedProductratePlanCharge.Name;
                    quoteRatePlanCharge.Sequence_No__c = iSequenceNo;
                    iSequenceNo++;
                    quoteRatePlanCharge.Cost_Price__c = selectedProductratePlanCharge.Cost_Price__c;
                    quoteRatePlanCharge.Is_Product_Editable__c = selectedProductratePlanCharge.Is_Product_Editable__c;
                    quoteRatePlanCharge.Percentage_of_other_Charges__c = selectedProductratePlanCharge.Percentage_of_other_Charges__c;
                    quoteRatePlanCharge.VAT__c = 0;
                    quoteRatePlanCharge.Tax__c = 0;
                    
                    // added by Ram, INVOICEIT-430 
                    quoteRatePlanCharge.Discount_Percent__c = 0;
                    quoteRatePlanCharge.Discount_Value__c = 0;
                    //If discount type picklist field has any default value then display,else display default value as 'None', INVOICEIT-430, Dhanalakshmi
                    if(sDefaultValueOfDiscountType != null){
                        quoteRatePlanCharge.Discount_Type__c = sDefaultValueOfDiscountType;
                    }
                    
                    if(mapChargeId_Bundle.containskey(selectedProductratePlanCharge.Id)) {
                        productLine = mapChargeId_Bundle.get(selectedProductratePlanCharge.Id);
                        quoteRatePlanCharge.Product_Bundle_Line__c = productLine.Id;
                        quoteRatePlanCharge.Is_Product_Editable__c = productLine.Is_Price_Editable__c;
                        quoteRatePlanCharge.Unit_Price__c = productLine.Unit_Price__c;
                        quoteRatePlanCharge.Quantity__c = productLine.Quantity__c;
                        quoteRatePlanCharge.Cost_Price__c = 0;
                    }   
                    
                    if(UserInfo.isMultiCurrencyOrganization()){
                        CommonUtilClass.populateCurrencyIsoCodeOnSobject(quoteRatePlanCharge, currecyISOCode);
                    }
                                    
                    //dynamic field mapping starts here                  
                    SObject sObj = (SObject)selectedProductratePlanCharge;
                    SObject sObjectQuoteRatePlanCharge = (SObject)quoteRatePlanCharge;

                    for(Custom_Mappings__c custom : mapCustomMappings.values()) {
                        if(custom.Destination_Object__c == CommonUtilClass.OBJECT_NAME_QUOTE_RATE_PLAN_CHARGE 
                                && custom.Source_Object__c == CommonUtilClass.OBJECT_NAME_PRODUCT_RATE_PLAN_CHARGE) {
                            String destinationField = (String)custom.get('Destination_Field__c');
                            String sourceField = (String)custom.get('Source_Field__c');
                            Schema.SObjectField f = mapDescribeQuoteRatePlanCharge.get(destinationField);
                            if(sObj.get(sourceField) != null) {
                                sObjectQuoteRatePlanCharge.put(f, sObj.get(sourceField)); 
                            }
                        }
                    }
                    quoteRatePlanCharge = (Quote_Rate_Plan_Charge__c)sObjectQuoteRatePlanCharge;                    

                    quoteRatePlanChargeClass = new QuoteRatePlanChargeClass();
                    if(productLine != null)
                        quoteRatePlanChargeClass.isQuantityEditable = productLine.Is_Quantity_Editable__c;
                    
                    quoteRatePlanChargeClass.quoteRatePlanChargeCounter = ++quoteRateplanChargeCounter;
                    quoteRatePlanChargeClass.quoterateplancharge = quoteRatePlanCharge;
                    quoteRatePlanChargeClass.displayRemove = true;

                    if(productBundleCount != 0) {
                        quoteRatePlanChargeClass.displayRemove = false;
                    }
                    //loop over the tiers if format is volume
                    if(selectedProductratePlanCharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME 
                            || selectedProductratePlanCharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE 
                            || selectedProductratePlanCharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_TIERED) {
                        for(Product_Rate_Plan_Charge_Tier__c productTier : selectedProductratePlanCharge.Product_Rate_Plan_Charge_Tiers__r) {
                            quoteTierClass = new QuoteRatePlanChargeTierClass();
                            quoteTier = new Quote_Rate_Plan_Charge_Tier__c();
                            quoteTier.Start_Unit__c = productTier.Start_Unit__c;
                            quoteTier.End_Unit__c = productTier.End_Unit__c;
                            quoteTier.Unit_Cost_Price__c = productTier.Unit_Cost_Price__c;
                            quoteTier.Unit_Price__c = productTier.Unit_Price__c;
                            quoteTierClass.quoteRatePlanChargeTier = quoteTier;
                            quoteTierClass.quoteRatePlanChargeTierCounter = ++quoteRatePlanChargeTierCounter;
                            quoteRatePlanChargeClass.quoteRatePlanChargeTiers.add(quoteTierClass);
                        }
                    }
                    quoteRatePlanClass.quoteRatePlanCharges.add(quoteRatePlanChargeClass);
                }
                iSequenceNo = 1; 

                if(!isQuoteRatePlanExists) {
                    quoteProductClass.quoteRatePlans.add(quoteRatePlanClass);
                }
                if(!isQuoteProductExists) {
                    quoteClass.quoteProducts.add(quoteProductClass);
                }
                
                if(isTierProductExists) {
                    QuoteChargesCalculator.calculateSubtotal(quoteClass, new QuoteChargesCalculator.Charges());
                }
                
                if(isProductBundle) {
                    productBundleCount++;
                }

                isProductBundle = false;
                setofChargeIds.clear();
                mapChargeId_Bundle = new map<Id,Product_Bundle_Line__c>();
            } 
            catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage());
                Apexpages.addMessage(errorMessage);
                return null;
            }
            return null;
        }

        //Save the Quote
        public PageReference saveQuote() {
            chargeCalculator();
            decimal totalContractValue = 0;
            decimal totalChargeContract = 0;
            decimal totalContractedMRR = 0;
            String quoteId;
            SavePoint savePoint;
            try{
                savePoint = Database.setSavepoint();
                List<Quote_Rate_Plan_Charge__c> listQuoteRatePlanCharges = new List<Quote_Rate_Plan_Charge__c>();
                List<Quote_Rate_Plan_Charge__c> listQuoteRatePlanChargesToDelete = new List<Quote_Rate_Plan_Charge__c>();
                List<Quote_Rate_Plan_Charge_Tier__c> listQuoteTiersToDelete = new List<Quote_Rate_Plan_Charge_Tier__c>();
                Map<Integer,Quote_Product__c> mapQuoteProducts = new Map<Integer, Quote_Product__c>();
                Currency__c currencyObjNew;
                //Modified by INVOICEIT-522 Dev M make sure exchange rate populates only once 
                if(quote != null) {
                    if(UserInfo.isMultiCurrencyOrganization()) {  
                        //To populate currencyIso Code in multi currency org related to invoiceIT-464
                        currencyObjNew = [select name from Currency__c where id =: quoteClass.quote.CurrencyL__c];                 
                        if(quoteClass.quote.Valid_To__c != null && quoteClass.quote.Exchange_Rate_Applied__c == null)
                            QuoteCreationUtil.populateExchangeRateOnQuote(quoteClass.quote, currencyObjNew.Name);
                    }
                    //Added by Joshitha For INVOICEIT-670,To display the error message when valid to date less than todays date and create automatic order =true
                    if(quote.Valid_To__c < system.Today() && quote.Create_Automatic_Order__c == true) {
                       Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.QuotehasExpired);
                       Apexpages.addMessage(errorMessage);
                       return null;
                    }
                    upsert quoteClass.quote;
                }

                quote.Contracted_MRR__c = 0;
                quote.Total_Contract_Value__c = 0;
                quoteId = quoteClass.quote.id;
                for(QuoteProductClass qpc : quoteClass.quoteProducts) {
                    if(qpc.quoteproduct.Quote__c == null) {
                        qpc.quoteproduct.Quote__c = quoteClass.quote.Id;  
                    }
                    mapQuoteProducts.put(qpc.quoteProductCounter, qpc.quoteproduct);
                }
                upsert mapQuoteProducts.values();
                for(QuoteProductClass qpc: quoteClass.quoteProducts) {
                    qpc.quoteproduct = mapQuoteProducts.get(qpc.quoteProductCounter);   
                }

                Map<Integer,Quote_Rate_Plan__c> mapQuoteRatePlan = new Map<Integer,Quote_Rate_Plan__c>();
                for(QuoteProductClass qpc : quoteClass.quoteProducts) {
                    qpc.quoteproduct = mapQuoteProducts.get(qpc.quoteProductcounter);
                    for(QuoteRatePlanClass qrc : qpc.quoteRatePlans ) {
                        if( qrc.quoterateplan.Quote_Product__c == null) {
                            qrc.quoterateplan.Quote_Product__c = qpc.quoteproduct.id;
                        }
                        mapQuoteRatePlan.put(qrc.quoteRatePlanCounter,qrc.quoterateplan);
                    }
                }
                upsert mapQuoteRatePlan.values();
                if(QuoteRatePlanClass != null) {
                    for(QuoteRatePlanClass qrc : quoteProductClass.quoteRatePlans) {
                        qrc.quoterateplan = mapQuoteRatePlan.get(qrc.quoteRatePlanCounter);
                    }
                }

               
                /*  Modified By       : Devender M: 04 June 2013:  INVOICEIT-175
                    Comments        : Previously discount was included in Total Contract Value, so i have subtracted the discount value.  Used nettotal for calculating the Total Contract Value
                 */
                //upsert QuoteRatePlancharges
                Map<Integer,Quote_Rate_Plan_Charge__c> mapQuoteRatePlanCharges = new Map<Integer,Quote_Rate_Plan_Charge__c>();
                for(QuoteProductClass qpc :quoteClass.quoteProducts)
                {
                    for(QuoteRatePlanClass qrc : qpc.quoteRatePlans)
                    { 
                        integer i = 0;
                        for(QuoteRatePlanChargeClass qrpc :qrc.quoteRatePlanCharges)
                        { 

                            
                           /*   Modified By       : Ankit Sharma: 28 Feb 2014: INVOICEIT-322
                                Comments        : Populating the standard field currency (CurrencyIsoCode) only for multi currency org.
                             */

                            if(UserInfo.isMultiCurrencyOrganization()){
                                CommonUtilClass.populateCurrencyIsoCodeOnSobject(qrpc.quoterateplancharge, currencyObjNew.Name);
                            } 

                            totalChargeContract = 0;
                            //qrpc.quoterateplancharge.Quote__c = quoteClass.quote.Id;
                            if(qrpc.quoterateplancharge.Quote_Rate_Plan__c == null){
                                qrpc.quoterateplancharge.Quote_Rate_Plan__c = qrc.quoterateplan.id;
                            }        
                            //If Quantity__c is greather than 0,then add to the map.Else do not add to the map.
                            if(qrpc.quoterateplancharge.Quantity__c > 0 || qrpc.quoterateplancharge.Price_Type__c == system.Label.OptionUsage) {
                                qrpc.quoterateplancharge.Sequence_No__c = ++i; 
                                mapQuoteRatePlanCharges.put(qrpc.quoteRatePlanChargeCounter,qrpc.quoterateplancharge);

                                //If the Number_Of_Terms__c are present use that and calculate TCV
                                if(qrpc.quoterateplancharge.Price_Type__c == system.Label.OptionOneTime) {
                                    totalChargeContract = qrpc.quoterateplancharge.Net_Total__c;
                                } //Anil has added the below lines on July 2nd 2015 to get the pro ration with the proposed dates (ticket no INVOICEIT-584)
                                else if(quote.Proposed_Start_Date__c != null && quote.Proposed_End_Date__c != null) {
                                    totalChargeContract = QuoteCreationUtil.calculateQuoteChargeLineAmount(qrpc.quoterateplancharge, quote.Proposed_Start_Date__c, quote.Proposed_End_Date__c);
                                } else if(quote.Number_Of_Terms__c > 0) {
                                    totalChargeContract = QuoteCreationUtil.calculateQuoteChargeLineAmount(qrpc.quoterateplancharge, system.today(), system.today().addMonths((Integer)quote.Number_Of_Terms__c).addDays(-1));  
                                } 

                                //calculate the ContractedMRR only if the type is not equal to one time
                                if(qrpc.quoterateplancharge.Price_Type__c != system.Label.OptionOneTime) {
                                    totalContractValue += totalChargeContract;
                                    totalContractedMRR += totalChargeContract;
                                } else {
                                    totalContractValue += totalChargeContract;
                                }    
                            }
                            else if(qrpc.quoterateplancharge.Id != null) {
                                listQuoteRatePlanChargesToDelete.add(new Quote_Rate_Plan_Charge__c(Id = qrpc.quoterateplancharge.Id));
                                //Add the corresponding quoterateplanchargetiers to a delete list and delete those tiers to remove orphaned records
                                for(QuoteRatePlanChargeTierClass quoteTierClass : qrpc.quoteRatePlanChargeTiers) {
                                    if(quoteTierClass.quoteRatePlanChargeTier.Id != null) {
                                        listQuoteTiersToDelete.add(quoteTierClass.quoteRatePlanChargeTier);    
                                    }
                                }
                            }
                        }
                    }
                }
                upsert mapQuoteRatePlanCharges.values();

                Map<Integer,Quote_Rate_Plan_Charge_Tier__c> mapQuoteRatePlanChargeTiers = new Map<Integer,Quote_Rate_Plan_Charge_Tier__c>();
                for(QuoteProductClass qpc :quoteClass.quoteProducts)
                {
                    for(QuoteRatePlanClass qrc : qpc.quoteRatePlans)
                    { 
                        for(QuoteRatePlanChargeClass qrpc :qrc.quoteRatePlanCharges)
                        {
                            if(qrpc.quoterateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME 
                                    || qrpc.quoterateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE 
                                    || qrpc.quoterateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_TIERED)
                            {
                                for(QuoteRatePlanChargeTierClass quoteTierClass : qrpc.quoteRatePlanChargeTiers)
                                {
                                    /*
                                        Modified By        : Devender M: 17 July 2013: INVOICEIT-214
                                        Comments        : When we edit a Rate Plan Charge Tier through the Wizard, the last screen of the wizard shows the correct row total and after saving, 
                                                                     the Opportunity/Order/Quote detail page shows the correct row total. However, if I go back into the Wizard again, the tiered unit price reverts back to the original value.
                                     */
                                    if(quoteTierClass.quoteRatePlanChargeTier.Quote_Rate_Plan_Charge__c == null) {
                                        if(mapQuoteRatePlanCharges.containsKey(qrpc.quoteRatePlanChargeCounter)) {
                                            quoteTierClass.quoteRatePlanChargeTier.Quote_Rate_Plan_Charge__c = mapQuoteRatePlanCharges.get(qrpc.quoteRatePlanChargeCounter).Id;
                                            mapQuoteRatePlanChargeTiers.put(quoteTierClass.quoteRatePlanChargeTierCounter, quoteTierClass.quoteRatePlanChargeTier); 
                                        }
                                    }else {
                                        if(mapQuoteRatePlanCharges.containsKey(qrpc.quoteRatePlanChargeCounter)) {
                                            mapQuoteRatePlanChargeTiers.put(quoteTierClass.quoteRatePlanChargeTierCounter, quoteTierClass.quoteRatePlanChargeTier); 
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                upsert mapQuoteRatePlanChargeTiers.Values();

                if(quoteRatePlansToDelete != null && quoteRatePlansToDelete.size() > 0) {
                    delete quoteRatePlansToDelete;    
                }
                //Here we are deleting the Quote_Products which has no rate Plan charges
                for(QuoteProductClass qpc : quoteClass.quoteProducts) {
                    if(qpc.quoteproduct.Total_Quote_Rate_Plans__c == 0) {
                        quoteProductsToDelete.add(qpc.quoteproduct);  
                    }
                    mapQuoteProducts.put(qpc.quoteProductCounter, qpc.quoteproduct);
                }
                if(quoteProductsToDelete != null && quoteProductsToDelete.size() > 0) {
                    delete quoteProductsToDelete;
                }
                if(listQuoteRatePlanChargesToDelete.size() > 0) {
                    delete listQuoteRatePlanChargesToDelete;
                }
                if(listQuoteTiersToDelete.size() > 0) {
                    delete listQuoteTiersToDelete;
                }

                quote.Total_Contract_Value__c = totalContractValue;
                if(totalContractedMRR > 0 && quote.Number_Of_Terms__c != null && quote.Number_Of_Terms__c >= 1) {
                    quote.Contracted_MRR__c = (totalContractedMRR/quote.Number_Of_Terms__c);
                }

                upsert quote;

                /*
                                Modified By        : Devender M: 29 Nov 2013: INVOICEIT-267
                                Comments        : Delete Quote Rate Plan and Quote Product while Quantity is zero and Quote Rate Plan does not has any charges
                 */

                // This is to delete the quote Product rate plan which does not have charge
                list<Quote_Rate_Plan__c> listOfQuoteRatePlanTodelete = new list<Quote_Rate_Plan__c>();            
                list<Quote_Rate_Plan__c> listOfQuoteRatePlanLoc = new list<Quote_Rate_Plan__c>();

                if(!mapQuoteRatePlan.values().isEmpty()){
                    listOfQuoteRatePlanLoc = [SELECT Id,(SELECT Id From Quote_Rate_Plan_Charge__r) 
                                              From Quote_Rate_Plan__c 
                                              WHERE Id IN : mapQuoteRatePlan.values()];
                    for(Quote_Rate_Plan__c quoteRatePlan : listOfQuoteRatePlanLoc){
                        if(quoteRatePlan.Quote_Rate_Plan_Charge__r.size() == 0){
                            listOfQuoteRatePlanTodelete.add(quoteRatePlan);
                        }
                    }
                }           

                if(!listOfQuoteRatePlanTodelete.isEmpty()){
                    delete listOfQuoteRatePlanTodelete;
                } 

                // This is to delete the quoteProduct which does not have quote Product rate plan
                list<Quote_Product__c> listOfQuoteProductTodelete = new list<Quote_Product__c>();
                list<Quote_Product__c> listOfQuoteProductLoc = new list<Quote_Product__c>();

                if(!mapQuoteProducts.values().isEmpty()) {
                    listOfQuoteProductLoc = [SELECT Id, (SELECT Id From Quote_Rate_Plan__r) 
                                             FROM Quote_Product__c 
                                             WHERE Id IN : mapQuoteProducts.values()];
                    for(Quote_Product__c quoteProduct : listOfQuoteProductLoc) {
                        if(quoteProduct.Quote_Rate_Plan__r.size() == 0){
                            listOfQuoteProductTodelete.add(quoteProduct);
                        }
                    }                               
                }

                if(!listOfQuoteProductTodelete.isEmpty()){
                    delete listOfQuoteProductTodelete;
                } 

            }catch(DMLException dMlEx){
                // Added by Naveen M ticket : INVOICEIT-310 
                Apexpages.Message errorMessage; 
                for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                { 
                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                    Apexpages.addMessage(errorMessage);      
                } 
                return null; 
            }catch(Exception ex) {
                Database.rollback(savePoint);
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage());
                Apexpages.addMessages(ex);
                return null;
            }
            return new PageReference('/' + quoteId);
        }
        
         public PageReference quickSaveQuote() {
             saveQuote();
             return null;
         }
        //getListProducts from the productUtilClass
        //Method  removeQuoteRatePlan
        public PageReference removeQuotes() {
            quoteRatePlanId = system.currentPageReference().getParameters().get('quoteRatePlanId');
            string sProductBundleId = system.currentPageReference().getParameters().get('productBundleId');
            Integer quoterateplancounterval = Integer.valueOf(system.currentPageReference().getParameters().get('quoterateplancounter'));
            
            
            if(sProductBundleId == null || sProductBundleId == '') {
                Quote_Rate_Plan__c quoteRatePlanToDelete = new Quote_Rate_Plan__c();
                if(quoteRatePlanId != null && quoteRatePlanId.length() > 0){
                    quoteRatePlanToDelete = QuoteCreationUtil.getquoteRatePlanToDelete(quoteRatePlanId);
                    quoteRatePlansToDelete.add(new Quote_Rate_Plan__c(Id = quoteRatePlanId));
                    quoteProductsToDelete.add(new Quote_Product__c(Id = quoteRatePlanToDelete.Quote_Product__c)) ;
                }
        
                Integer quoterateplansize = quoteProductClass.quoteRatePlans.size();
                for(QuoteProductClass qpc : quoteClass.quoteProducts)
                {
                    for(Integer i = 0;i < quoterateplancounterval;i++)
                    {
                        try
                        {
                            if(qpc.quoteRatePlans[i].quoteRatePlanCounter == quoterateplancounterval)
                            {
                                qpc.quoteRatePlans.remove(i);
                                qpc.quoteproduct.clear();
                                quoteProductsToDelete.add(qpc.quoteproduct);
                            }
                        }
                        catch(Exception ex){}
                    }
                }
            } else {
                Integer iProductBundleSequenceNo = Integer.valueOf(sProductBundleId);
                integer iSize = quoteClass.quoteProducts.size();
                for(integer i=0; i<iSize ; i++)
                {
                    try
                    {
                         if(quoteClass.quoteProducts[i].quoteproduct.Bundle_SequenceNumber__c == iProductBundleSequenceNo) {
                            if(quoteClass.quoteProducts[i].quoteproduct.Id != null)
                                quoteProductsToDelete.add(new Quote_Product__c (Id = quoteClass.quoteProducts[i].quoteproduct.Id));
                            quoteClass.quoteProducts.remove(i);
                            --i;
                        }
                    }
                    catch(Exception ex){}
                }
            }   
            
            iQuoteProductSequenceNo = 1;
            quoteBundleSequenceNo = 1;
            map<String, Integer> mapProductBundleSequence_OldRef_NewRef = new map<String, Integer>();
            
            for(QuoteProductClass quoteProductClass : quoteClass.quoteProducts)
            {
                quoteProductClass.quoteproduct.SequenceNumber__c = iQuoteProductSequenceNo;
                iQuoteProductSequenceNo ++;
                // This is used to rearrange the quote Bundle Sequence No
                 if(quoteProductClass.quoteproduct.Bundle_SequenceNumber__c != null) {
                    if(mapProductBundleSequence_OldRef_NewRef.containskey(string.valueOf(quoteProductClass.quoteproduct.Bundle_SequenceNumber__c))) {
                        quoteProductClass.quoteproduct.Bundle_SequenceNumber__c = mapProductBundleSequence_OldRef_NewRef.get(string.valueOf(quoteProductClass.quoteproduct.Bundle_SequenceNumber__c));
                    }else {
                        mapProductBundleSequence_OldRef_NewRef.put(string.valueOf(quoteProductClass.quoteproduct.Bundle_SequenceNumber__c) ,quoteBundleSequenceNo);
                        quoteProductClass.quoteproduct.Bundle_SequenceNumber__c = quoteBundleSequenceNo;
                        quoteBundleSequenceNo++;
                    }
                } 
            } 
            return null;    
        }

        //Convert Quote to Job
        public PageReference convertQuote() {
            Job__c job;
            JobClass jobClass;
            JobProductClass jobProductClass;
            JobRatePlanClass jobRatePlanClass;
            JobRatePlanChargeClass jobRatePlanChargeClass;
            Integer jobProductCounter = 0;
            Integer jobRatePlanCounter = 0;
            transient Integer jobRateplanChargeCounter = 0;
            Savepoint savePoint; 
            try {
                
                if(quote == null || quote.Id == null || string.ValueOf(quote.id).trim() == '') {
                    return null;
                }
                Job__c jobSatus = CommonUtilClass.getJob(quote.id);
                if(jobSatus != null) {
                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.QuoteConvertedToOrder);
                    Apexpages.addMessage(errorMessage);
                    return null;
                } 
                if(!(quote.Valid_To__c < system.Today())) {     
                    savePoint = Database.setSavepoint();
                    map<String, Schema.SObjectField> mapDescribeJobProduct = Schema.SObjectType.Job_Product__c.fields.getMap();
                    map<String, Schema.SObjectField> mapDescribeJobRatePlan = Schema.SObjectType.Job_Rate_Plan__c.fields.getMap();
                    map<String, Schema.SObjectField> mapDescribeJobRatePlanCharge = Schema.SObjectType.Job_Rate_Plan_Charge__c.fields.getMap();
                    map<String, Schema.SObjectField> mapDescribeJob = Schema.SObjectType.Job__c.fields.getMap();

                    job = new Job__c();
                    job.Account__c = quote.Account__c;
                    job.Billing_Contact__c = quote.Billing_Contact__c;
                    job.CurrencyL__c = quote.CurrencyL__c;  
                    job.Discount_Value__c = quote.Discount_Value__c;
                    job.Number_Of_Terms__c = quote.Number_Of_Terms__c;
                    job.Start_Date__c = system.today();
                    //If they dont use service activation date for invoice generation, set the value to start date
                    if(mapConfiguration.get(CommonUtilClass.USE_SERVICE_START_DATE_FOR_INVOICE).Boolean_Value__c){
                        job.Service_Activation_Date__c = job.Start_Date__c;
                    }
                    /*
                    Modified By     : Sagarika Rout: 27-03-2014: INVOICEIT-335
                    Comments        : populating Service_Activation_Date__c,Service_End_Date__c on order and orpc if ALIGN_DATES_OF_ORDER_TO_PRODUCTS is true
                    Laxman Comments : INVOICEIT-335
                    Below is the logic for populating the dates :
                    if USE_SERVICE_START_DATE_FOR_INVOICE is true then we should assign the StartDate of order to ServiceActivationDate
                    i.e order.Service_Activation_Date = order.Start_Date;
                    if ALIGN_DATES_OF_ORDER_TO_PRODUCTS is true then we should assign the ServiceActivationDate for order rate plan charges
                    i.e orderCharge.ServiceActivationDate = order.Service_Activation_Date
                            orderCharge.ServiceEndDate = order.ServiceEndDate
                    Laxman has changed the logic accordingly.       
                     */
                    if(mapConfiguration.get(CommonUtilClass.ALIGN_DATES_OF_ORDER_TO_PRODUCTS).Boolean_Value__c) {
                        if(job.Service_Activation_Date__c != null && quote.Number_Of_Terms__c != null) {
                            job.Service_End_Date__c = job.Service_Activation_Date__c.addMonths((Integer)quote.Number_Of_Terms__c) - 1;
                        }
                    }
                    job.Partner__c = quote.Partner__c;
                    job.Quote__c = quote.id;
                    job.Shipping_Contact__c = quote.Shipping_Contact__c;
                    job.Sub_Total__c = quote.Sub_Total__c;
                    job.Tax__c = quote.Tax__c;
                    job.Total_Cost__c = quote.Total_Cost__c;
                    job.Total_Profit__c = quote.Total_Profit__c;
                    job.TotalProfitPercent__c = quote.TotalProfitPercent__c;
                    job.Total__c = quote.Total__c;
                    job.VAT__c = quote.VAT__c;
                    job.Name = quote.Name;
                    job.Net_Total__c = quote.Net_Total__c;
                    /*
                    Modified By       : Ramakrishna.v: 03-12-2013: INVOICEIT-290/281
                    Comments       : mapping quote discount code to order discount code
                     */
                    job.Discount_Code__c = quote.Discount_Code__c;
                    job.Discount_percent__c = quote.Discount_percent__c;
                    job.Discount_percent__c = quote.Discount_percent__c;
                    job.Total_Contract_Value__c = quote.Total_Contract_Value__c;
                    job.Contracted_MRR__c = quote.Contracted_MRR__c;
                    job.Override_Vat_Tax__c = quote.Override_Vat_Tax__c;
                    
                    //Modified by  : Kesav Madhu, on 11-03-2015, JIRA : INVOICEIT-518
                   if(Quote.Proposed_Start_Date__c != null){
                        Job.Service_Activation_Date__c = Quote.Proposed_Start_Date__c;
                        if(Quote.Proposed_End_Date__c == null && Job.Number_Of_Terms__c != null){
                            Job.Service_End_Date__c = Quote.Proposed_Start_Date__c.addMonths((Integer)Job.Number_Of_Terms__c) - 1;
                        }
                     }
                     if(Quote.Proposed_End_Date__c != null){
                        Job.Service_End_Date__c = Quote.Proposed_End_Date__c;
                     }  
                    
                    jobClass = new JobClass();
                    jobClass.job = job;

                    SObject sObjectQuote = (SObject)quote;
                    SObject sObjectJob = (SObject)job;                
                    for(Custom_Mappings__c custom : mapCustomMappings.values()) {
                        if(custom.Destination_Object__c == CommonUtilClass.OBJECT_NAME_JOB
                                && custom.Source_Object__c == CommonUtilClass.OBJECT_NAME_QUOTE) {
                            String destinationField = (String)custom.get('Destination_Field__c');
                            String sourceField = (String)custom.get('Source_Field__c');

                            Schema.SObjectField f = mapDescribeJob.get(destinationField);
                            if(sObjectQuote.get(sourceField) != null){
                                sObjectJob.put(f, sObjectQuote.get(sourceField));
                            }        
                        }
                    }
                    job = (Job__c)sObjectJob;

                    //populate the exchange rate
                    if(UserInfo.isMultiCurrencyOrganization()) 
                    {
                        JobCreationUtil.populateExchangeRateOnOrder(jobClass.job, currecyISOCode);
                    }

                    upsert jobClass.job;
                    String jobId = jobClass.job.Id;    

                    Map<Integer,Job_Product__c> mapJobProducts = new Map<Integer,Job_Product__c>();               
                    for(QuoteProductClass qp: quoteClass.quoteProducts)
                    {
                        Job_Product__c jobProduct = new Job_Product__c();
                        jobProduct.Job__c = jobClass.job.Id;
                        jobProduct.Name = qp.quoteproduct.Name;
                        jobProduct.Product__c = qp.quoteproduct.Product__c;
                        jobProduct.SequenceNumber__c = qp.quoteproduct.SequenceNumber__c;
                        jobProduct.Product_Code__c = qp.quoteproduct.Product_Code__c; 
                        jobProduct.Description__c = qp.quoteproduct.Description__c; 
                        jobProduct.Product_Family__c = qp.quoteproduct.Product_Family__c;
                        jobProduct.Bundle_SequenceNumber__c = qp.quoteproduct.Bundle_SequenceNumber__c;
                        jobProduct.Product_Bundle__c = qp.quoteproduct.Product_Bundle__c;
                        //dynamic field mapping starts here
                        SObject s = (SObject)qp.quoteproduct;
                        SObject sObjectJobProduct = (SObject)jobProduct;

                        for(Custom_Mappings__c custom : mapCustomMappings.values()) {
                            if(custom.Destination_Object__c == CommonUtilClass.OBJECT_NAME_JOB_PRODUCT
                                    && custom.Source_Object__c == CommonUtilClass.OBJECT_NAME_QUOTE_PRODUCT) {

                                String destinationField = (String)custom.get('Destination_Field__c');
                                String sourceField = (String)custom.get('Source_Field__c');

                                Schema.SObjectField f = mapDescribeJobProduct.get(destinationField);
                                if(s.get(sourceField) != null){
                                    sObjectJobProduct.put(f, s.get(sourceField));
                                }
                            }
                        }
                        jobProduct = (Job_Product__c)sObjectJobProduct;
                        jobProductClass = new JobProductClass();
                        jobProductClass.jobProductCounter = ++jobProductCounter;
                        jobProductClass.jobproduct = jobProduct;
                        jobClass.jobProducts.add(jobProductClass);
                        mapJobProducts.put(jobProductClass.jobProductCounter,jobProduct);
                    }
                    upsert  mapJobProducts.values();

                    for(JobProductClass jp : jobClass.jobProducts) {
                        jp.jobproduct = mapJobProducts.get(jp.jobProductCounter);
                    }

                    set<Id> setJobProductIds = new set<Id>();
                    Map<Integer,Job_Rate_Plan__c> mapJobRatePlans = new Map<Integer,Job_Rate_Plan__c>();
                    for(JobProductClass jp: jobClass.jobProducts)
                    {
                        jp.jobproduct = mapJobProducts.get(jp.jobProductCounter);
                        for(QuoteProductClass qp:quoteClass.quoteProducts)
                        {
                            if(qp.quoteproduct.Product__c == jp.jobproduct.Product__c && !setJobProductIds.contains(jp.jobproduct.Id))
                            {
                                setJobProductIds.add(jp.jobproduct.Id);
                                for(QuoteRatePlanClass qrp : qp.quoteRatePlans) 
                                {
                                    Job_Rate_Plan__c jobRatePlan = new Job_Rate_Plan__c();
                                    jobRatePlan.Job_Product__c = jp.jobproduct.Id;
                                    jobRatePlan.Name = qrp.quoterateplan.Name;
                                    jobRatePlan.Description__c = qrp.quoterateplan.Description__c;
                                    jobRatePlan.Product_Rate_Plan__c = qrp.quoterateplan.Product_Rate_Plan__c;
                                    jobRatePlan.SequenceNumber__c = qrp.quoterateplan.SequenceNumber__c;
                                    //dynamic field mapping starts here
                                    SObject s = (SObject)qrp.quoterateplan;
                                    SObject sObjectJobRatePlan = (SObject)jobRatePlan;

                                    for(Custom_Mappings__c custom : mapCustomMappings.values()) {
                                        if(custom.Destination_Object__c == CommonUtilClass.OBJECT_NAME_JOB_RATE_PLAN
                                                && custom.Source_Object__c == CommonUtilClass.OBJECT_NAME_QUOTE_RATE_PLAN) {
                                            String destinationField = (String)custom.get('Destination_Field__c');
                                            String sourceField = (String)custom.get('Source_Field__c');

                                            Schema.SObjectField f = mapDescribeJobRatePlan.get(destinationField);
                                            if(s.get(sourceField) != null) {
                                                sObjectJobRatePlan.put(f, s.get(sourceField));
                                            }
                                        }
                                    }
                                    jobRatePlan = (Job_Rate_Plan__c)sObjectJobRatePlan;
                                    //dynamic field mapping ends here
                                    jobRatePlanClass = new JobRatePlanClass();
                                    jobRatePlanClass.jobRatePlanCounter = ++jobRatePlanCounter;
                                    jobRatePlanClass.jobrateplan = jobRatePlan;
                                    jobProductClass.jobRatePlans.add(jobRatePlanClass);
                                    mapJobRatePlans.put(jobRatePlanClass.jobRatePlanCounter,jobRatePlan);
                                }
                            }
                        }
                    }
                    upsert mapJobRatePlans.values();

                    Map<Integer,Job_Rate_Plan_Charge__c> mapJobRatePlanCharge = new Map<Integer,Job_Rate_Plan_Charge__c>();
                    for(QuoteProductClass qp : quoteClass.quoteProducts) {
                        for(QuoteRatePlanClass qrp : qp.quoteRatePlans) {
                            id jobRatePlanID  = mapJobRatePlans.get(qrp.quoteRatePlanCounter).Id;
                            for(QuoteRatePlanChargeClass qrpc :qrp.quoteRatePlanCharges) {
                                Job_Rate_Plan_Charge__c jobRatePlanCharge = new Job_Rate_Plan_Charge__c();
                                jobRatePlanCharge.Job_Rate_Plan__c = jobRatePlanID;
                                jobRatePlanCharge.Name = qrpc.quoterateplancharge.Name;
                                jobRatePlanCharge.Accounting_Code__c = qrpc.quoterateplancharge.Accounting_Code__c;
                                jobRatePlanCharge.Discount_Value__c = qrpc.quoterateplancharge.Discount_Value__c;
                                jobRatePlanCharge.Price_Format__c = qrpc.quoterateplancharge.Price_Format__c;
                                jobRatePlanCharge.Profit__c = qrpc.quoterateplancharge.Profit__c;
                                jobRatePlanCharge.Sequence_No__c = qrpc.quoterateplancharge.Sequence_No__c;
                                jobRatePlanCharge.Unit_Of_Measurement__c = qrpc.quoterateplancharge.Unit_Of_Measurement__c;
                                jobRatePlanCharge.Price__c = qrpc.quoterateplancharge.Price__c;
                                jobRatePlanCharge.Unit_Price__c = qrpc.quoterateplancharge.Unit_Price__c;
                                jobRatePlanCharge.Price_Type__c = qrpc.quoterateplancharge.Price_Type__c;
                                jobRatePlanCharge.CurrencyL__c = qrpc.quoterateplancharge.CurrencyL__c;
                                jobRatePlanCharge.Quantity__c = qrpc.quoterateplancharge.Quantity__c;
                                jobRatePlanCharge.Sequence_No__c = qrpc.quoterateplancharge.Sequence_No__c;                                   
                                jobRatePlanCharge.Tax__c = qrpc.quoterateplancharge.Tax__c;
                                jobRatePlanCharge.Vat__c = qrpc.quoterateplancharge.Vat__c;
                                jobRatePlanCharge.Tax_Code__c = qrpc.quoterateplancharge.Tax_Code__c;                                   
                                jobRatePlanCharge.Cost__c = qrpc.quoterateplancharge.Cost__c;
                                jobRatePlanCharge.Cost_Price__c = qrpc.quoterateplancharge.Cost_Price__c;
                                jobRatePlanCharge.Is_Product_Editable__c = qrpc.quoterateplancharge.Is_Product_Editable__c;
                                jobRatePlanCharge.Product_Rate_Plan_Charge__c = qrpc.quoterateplancharge.Product_Rate_Plan_Charge__c;
                                jobRatePlanCharge.Product_Charge_Category__c = qrpc.quoterateplancharge.Product_Charge_Category__c;
                                jobRatePlanCharge.VAT_Percentage__c = qrpc.quoterateplancharge.VAT_Percentage__c;
                                jobRatePlanCharge.Tax_Percentage__c = qrpc.quoterateplancharge.Tax_Percentage__c;
                                jobRatePlanCharge.Net_Total__c =  qrpc.quoterateplancharge.Net_Total__c;
                                jobRatePlanCharge.Discount_percent__c = qrpc.quoterateplancharge.Discount_percent__c;
                                jobRatePlanCharge.VAT_Percentage__c =  qrpc.quoterateplancharge.VAT_Percentage__c;
                                jobRatePlanCharge.Tax_Percentage__c =  qrpc.quoterateplancharge.Tax_Percentage__c;
                                jobRatePlanCharge.Percentage_of_other_Charges__c = qrpc.quoterateplancharge.Percentage_of_other_Charges__c;
                                jobRatePlanCharge.Product_Bundle_Line__c =  qrpc.quoterateplancharge.Product_Bundle_Line__c;
                                // Modified By Dev.M INVOICEIT-548
                                jobRatePlanCharge.Deferred_Revenue_Accounting_Code__c = qrpc.quoterateplancharge.Deferred_Revenue_Accounting_Code__c;
                                //Modified By Naveen M INVOICEIT-539
                                jobRatePlanCharge.Uplift__c = qrpc.quoterateplancharge.Uplift__c;

                                //Added by dhanalakshmi, INVOICEIT-609
                                if(qrp.quoterateplan.Quote_Product__r.Product_Bundle__r.Bundle_Type__c != null && qrp.quoterateplan.Quote_Product__r.Product_Bundle__r.Bundle_Type__c == 'Bundle'){
                                     jobRatePlanCharge.Revenue_Recognition_Rule__c = qrp.quoterateplan.Quote_Product__r.Product_Bundle__r.Revenue_Recognition_Rule__c;
                                } 
                                /*
                                    Modified By     : Ankit Sharma: 28 Feb 2014: INVOICEIT-322
                                    Comments        : Populating the standard field currency (CurrencyIsoCode) only for multi currency org.
                                 */
                                 if(UserInfo.isMultiCurrencyOrganization()){
                                     CommonUtilClass.populateCurrencyIsoCodeOnSobject(jobRatePlanCharge, currecyISOCode);
                                 }


                                /*
                                Modified By     : Rama Krishna.V: 24-6-2013: INVOICEIT-145
                                Comments        : below Fields added to mapping Quote charges (Fields :- Committed Quantity,Min Customer Spend,Max Customer Spend) to the order charges.
                                 */
                                 jobRatePlanCharge.Committed_Quantity__c = qrpc.quoterateplancharge.Committed_Quantity__c;
                                 jobRatePlanCharge.Min_Customer_Spend__c = qrpc.quoterateplancharge.Min_Customer_Spend__c;
                                 jobRatePlanCharge.Max_Customer_Spend__c = qrpc.quoterateplancharge.Max_Customer_Spend__c;
                                 jobRatePlanCharge.Charge_Code__c = qrpc.quoterateplancharge.Charge_Code__c;
                                 jobRatePlanCharge.Discount_Type__c = qrpc.quoterateplancharge.Discount_Type__c;
                                 jobRatePlanCharge.Order__c = jobClass.job.id;
                                 //If the config boolean value is true align the charge start date to that of the order
                                 if(mapConfiguration.get('ALIGN_DATES_OF_ORDER_TO_PRODUCTS').Boolean_Value__c) {
                                     jobRatePlanCharge.Service_Activation_Date__c = job.Service_Activation_Date__c;
                                     jobRatePlanCharge.Service_End_Date__c = job.Service_End_Date__c;
                                 }
                                 //dynamic field mapping starts here                  
                                 SObject sObj = (SObject)qrpc.quoterateplancharge;
                                 SObject sObjectJobRatePlanCharge = (SObject)jobRatePlanCharge;

                                 for(Custom_Mappings__c custom : mapCustomMappings.values()) {
                                     if(custom.Destination_Object__c == CommonUtilClass.OBJECT_NAME_JOB_RATE_PLAN_CHARGE 
                                             && custom.Source_Object__c == CommonUtilClass.OBJECT_NAME_QUOTE_RATE_PLAN_CHARGE){
                                         String destinationField = (String)custom.get('Destination_Field__c');
                                         String sourceField = (String)custom.get('Source_Field__c');

                                         Schema.SObjectField f = mapDescribeJobRatePlanCharge.get(destinationField);
                                         if(sObj.get(sourceField) != null) {
                                             sObjectJobRatePlanCharge.put(f, sObj.get(sourceField));
                                         }
                                     }
                                 }
                                 jobRatePlanCharge = (Job_Rate_Plan_Charge__c)sObjectJobRatePlanCharge;                  

                                 jobRatePlanChargeClass = new JobRatePlanChargeClass();
                                 jobRatePlanChargeClass.jobRatePlanChargeCounter = ++jobRateplanChargeCounter;
                                 jobRatePlanChargeClass.jobrateplancharge = jobRatePlanCharge;
                                 jobRatePlanClass.jobRatePlanCharges.add(jobRatePlanChargeClass);
                                 mapJobRatePlanCharge.put(qrpc.quoteRatePlanChargeCounter,jobRatePlanCharge);    
                            }
                        }
                    }

                    upsert mapJobRatePlanCharge.values();

                    Map<Integer,Job_Rate_Plan_Charge_Tier__c> mapJobRatePlanChargeTiers = new Map<Integer,Job_Rate_Plan_Charge_Tier__c>();
                    Job_Rate_Plan_Charge_Tier__c jobTier;
                    for(QuoteProductClass qp : quoteClass.quoteProducts) {
                        for(QuoteRatePlanClass qrp : qp.quoteRatePlans) {
                            for(QuoteRatePlanChargeClass qrpc :qrp.quoteRatePlanCharges) {
                                Id jobRatePlanID  = mapJobRatePlanCharge.get(qrpc.quoteRatePlanChargeCounter).Id;
                                for(QuoteRatePlanChargeTierClass quoteTierClass : qrpc.quoteRatePlanChargeTiers) {
                                    jobTier = new Job_Rate_Plan_Charge_Tier__c();
                                    jobTier.Start_Unit__c = quoteTierClass.quoteRatePlanChargeTier.Start_Unit__c;
                                    jobTier.End_Unit__c = quoteTierClass.quoteRatePlanChargeTier.End_Unit__c;
                                    jobTier.Unit_Cost_Price__c = quoteTierClass.quoteRatePlanChargeTier.Unit_Cost_Price__c;
                                    jobTier.Unit_Price__c = quoteTierClass.quoteRatePlanChargeTier.Unit_Price__c;
                                    jobTier.Job_Rate_Plan_Charge__c = jobRatePlanID;
                                    mapJobRatePlanChargeTiers.put(quoteTierClass.quoteRatePlanChargeTierCounter, jobTier);  
                                }
                            }   
                        }
                    }
                    // insert tiers
                    upsert mapJobRatePlanChargeTiers.Values();             
                    //this represents quote is converted to order/Job
                    quote.Status__c = CommonUtilClass.STATUS_CONVERTED;
                    upsert quote;

                    //by updating the job, tcv and mrr will be calculates in trigger
                    update job;
                    return new PageReference('/' + jobId);
                    
                    
                }  
                 if(ApexPages.currentPage() != null){
                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.Thisquotehasexpired);
                    Apexpages.addMessage(errorMessage );
                    return null;
                } else {
                    throw new CustomException(system.Label.Thisquotehasexpired);
                    return null;
                }

                } catch(DMLException dMlEx){
                // Added by Naveen M ticket : INVOICEIT-310
                    Apexpages.Message errorMessage; 
                    for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                    { 
                        errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                        Apexpages.addMessage(errorMessage);      
                    } 
                    return null; 
               }
               catch(Exception ex) {
                   if(savepoint!=null){
                   Database.rollback(savePoint);
                   Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ThequotehasnotbeenconvertedintoOrder + system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':' + + ex.getLineNumber());
                   Apexpages.addMessage(errorMessage);
                   }
               }  
               
                
           return null;
          
        }

        // This method calculates all the charges related to the product 
        public PageReference chargeCalculator() {
            try {
                populateTierVlaues();
                QuoteChargesCalculator.calculateCharges(quoteClass);
            }
            catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName() + ':'+ex.getMessage() + ':'  + ex.getLineNumber());
                Apexpages.addMessage(errorMessage);
                return null;
            }
            return null;
        }  

        public PageReference populateTierVlaues() {
            decimal chargeQuantity = 0;
            integer iSize;
            boolean isTierExists;
            QuoteRatePlanChargeTierClass quoteTierClass;
            for(QuoteProductClass qp : quoteClass.quoteProducts) 
            {
                for(QuoteRatePlanClass qrp : qp.quoteRatePlans) 
                {
                    for(QuoteRatePlanChargeClass qrpc : qrp.quoteRatePlanCharges) {
                        if( qrpc.quoterateplancharge.Quantity__c > 0 && (qrpc.quoterateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME 
                                || qrpc.quoterateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE)) 
                        {
                            chargeQuantity = qrpc.quoterateplancharge.Quantity__c; 
                            iSize = qrpc.quoteRatePlanChargeTiers.size();
                            isTierExists = false;
                            for(integer i = 0; i < iSize; i++) 
                            {
                                quoteTierClass = qrpc.quoteRatePlanChargeTiers[i];
                                if((quoteTierClass.quoteRatePlanChargeTier.Start_Unit__c <= chargeQuantity && quoteTierClass.quoteRatePlanChargeTier.End_Unit__c >= chargeQuantity)
                                        ||
                                        (quoteTierClass.quoteRatePlanChargeTier.Start_Unit__c <= chargeQuantity && quoteTierClass.quoteRatePlanChargeTier.End_Unit__c == null)) 
                                {
                                    isTierExists = true;
                                    qrpc.quoterateplancharge.Unit_Price__c = quoteTierClass.quoteRatePlanChargeTier.Unit_Price__c;
                                    qrpc.quoterateplancharge.Cost_Price__c = quoteTierClass.quoteRatePlanChargeTier.Unit_Cost_Price__c;
                                }

                                if(i == (iSize - 1) && !isTierExists) 
                                {
                                    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.WARNING,system.Label.Tieredlimit + ' for "' + qp.quoteProduct.Name + '"'));
                                            return null;
                                }
                            }
                        }
                    }   
                }
            }
            return null;
        }

        //this is code is for discount
        public void applyDiscountValueToCharges() {
            sobject sobjectQuote = (sobject) quoteClass.quote;
            sobjectQuote.put(discountCode , '');
            sobjectQuote.put('Discount_Code__c', discountCodeCoupen);
            quoteClass.quote = (Quote__c) sobjectQuote;

            boolean doesHaveRecurringCharges = false;
            QuoteChargesCalculator.Charges tempCharges = new QuoteChargesCalculator.Charges();
            QuoteChargesCalculator.calculateSubtotal(quoteClass, tempCharges);
            quoteClass.quote.Sub_Total__c = tempCharges.subTotal;

            for(quoteProductClass qpc : quoteClass.quoteProducts)
            {
                for(quoteRatePlanClass qrc : qpc.quoteRatePlans)
                {
                    for(QuoteRatePlanChargeClass qrpc : qrc.quoteRatePlanCharges)
                    {
                        if(qrpc.quoterateplancharge.Price_Type__c != system.Label.OptionOneTime) {
                            doesHaveRecurringCharges = true;
                            break;
                        } 
                    }
                }
            }

            //Cannot apply quote/order level discount on subscription charges
            if(doesHaveRecurringCharges) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.DiscountByValueCannotbeAppliedForSubscription);
                Apexpages.addMessage(errorMessage);
                return;
            }

            decimal totalDiscount = 0.0;
            integer noOfProducts = quoteClass.quoteProducts.size();
            for(integer i = 0; i < noOfProducts; i++)
            {
                QuoteProductClass qpc = quoteClass.quoteProducts[i];
                for(integer j = 0; j < qpc.quoteRatePlans.size(); j++)
                {
                    QuoteRatePlanClass qrc = qpc.quoteRatePlans[j];
                    for(integer k = 0; k < qrc.quoteRatePlanCharges.size(); k++)
                    {
                        QuoteRatePlanChargeClass qrpc = qrc.quoteRatePlanCharges[k];
                        if(i == (noOfProducts - 1) && k == (qrc.quoteRatePlanCharges.size() - 1)) {
                            qrpc.quoterateplancharge.Discount_Value__c = quoteClass.quote.Discount_Value__c - totalDiscount;
                            qrpc.quoterateplancharge.Discount_Percent__c = (qrpc.quoterateplancharge.Discount_Value__c/qrpc.quoterateplancharge.Price__c) * 100;
                        }
                        else {
                            qrpc.quoterateplancharge.Discount_Value__c = ((qrpc.quoterateplancharge.Quantity__c * qrpc.quoterateplancharge.Unit_Price__c)/quoteClass.quote.Sub_Total__c) * quoteClass.quote.Discount_Value__c;
                            totalDiscount += qrpc.quoterateplancharge.Discount_Value__c;
                            qrpc.quoterateplancharge.Discount_Percent__c = (qrpc.quoterateplancharge.Discount_Value__c/qrpc.quoterateplancharge.Price__c) * 100;
                        }
                    }
                }
            }

            QuoteChargesCalculator.calculateCharges(quoteClass);
        }  

        public void applyDiscountPercentToCharges() {
            sobject sobjectQuote = (sobject) quoteClass.quote;
            sobjectQuote.put(discountCode , '');
            sobjectQuote.put('Discount_Code__c', discountCodeCoupen);
            quoteClass.quote = (Quote__c) sobjectQuote;
            if(quoteClass.quote.Discount_Percent__c != null) {
                QuoteChargesCalculator.Charges tempCharges = new QuoteChargesCalculator.Charges();
                QuoteChargesCalculator.calculateSubtotal(quoteClass, tempCharges);
                quoteClass.quote.Sub_Total__c = tempCharges.subTotal;
        
                for(quoteProductClass qpc : quoteClass.quoteProducts)
                {
                    for(quoteRatePlanClass qrc : qpc.quoteRatePlans)
                    {
                        for(QuoteRatePlanChargeClass qrpc : qrc.quoteRatePlanCharges)
                        {
                            qrpc.quoterateplancharge.Discount_Percent__c = quoteClass.quote.Discount_Percent__c;
                            qrpc.quoterateplancharge.Discount_Value__c = (qrpc.quoterateplancharge.Quantity__c * qrpc.quoterateplancharge.Unit_Price__c) * quoteClass.quote.Discount_Percent__c/100;
                        }
                    }
                }
                 QuoteChargesCalculator.calculateCharges(quoteClass);
            }
           
        }

        public void applyDiscountCode() {
            // we have to filter discount code at quote level by 
            // 1.Currency__c   2.Valid_From__c   3.Valid_To__c   4.Discount code name   5.Customer Class
            // we have to filter discount code at charge level by 
            // 1.Product_Family__c   2.Price_Type__c
            if(quoteClass.quote.Account__c == null) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.CannotApplyDiscountCodeWithOutSelectingAccountOnQuote);
                Apexpages.addMessage(errorMessage);
            } else {
                sobject sobjectQuote = (sobject) quoteClass.quote;      
                list<Discount_Code__c> listOfDiscounts = QuoteCreationUtil.getListOfDiscounts((string)sobjectQuote.get(discountCode),quoteClass);      
                if(listOfDiscounts.size() > 0) {
                    boolean quoteLevel = false;
                    sobjectQuote.put('Discount_Code__c', (string)sobjectQuote.get(discountCode));
                    for(Discount_Code__c discountCode : listOfDiscounts) 
                    {
                        if(discountCode.Apply_to__c == CommonUtilClass.APPLY_TO_QUOTEORORDER_LEVEL) {
                            discountCodeCoupen = discountCode.Name;
                            if(discountCode.Discount_Value__c > 0) {
                                quoteClass.quote.Discount_Value__c = discountCode.Discount_Value__c;
                                applyDiscountValueToCharges();
                            } else {
                                quoteClass.quote.Discount_Percent__c = discountCode.Discount_Percent__c;
                                applyDiscountPercentToCharges();
                            }
                            quoteLevel = true;
                            break;
                        }
                    }

                    if(!quoteLevel) 
                    {
                        QuoteChargesCalculator.Charges tempCharges = new QuoteChargesCalculator.Charges();
                        QuoteChargesCalculator.calculateSubtotal(quoteClass, tempCharges);
                        quoteClass.quote.Sub_Total__c = tempCharges.subTotal;

                        for(quoteProductClass qpc : quoteClass.quoteProducts)
                        {
                            for(quoteRatePlanClass qrc : qpc.quoteRatePlans)
                            {
                                for(QuoteRatePlanChargeClass qrpc : qrc.quoteRatePlanCharges)
                                {
                                    qrpc.quoterateplancharge.Discount_Value__c = 0;
                                    qrpc.quoterateplancharge.Discount_Percent__c = 0;

                                    for(Discount_Code__c discountCode : listOfDiscounts) 
                                    {
                                        discountCodeCoupen = discountCode.Name;
                                        if(discountCode.Apply_to__c == CommonUtilClass.APPLY_TO_CHARGE_LEVEL && 
                                                (discountCode.Product_Family__c == qpc.quoteProduct.Product_Family__c || discountCode.Product_Family__c == CommonUtilClass.MATCHING_ALL_STAR) &&
                                                (discountCode.Price_Type__c.Contains(qrpc.quoterateplancharge.Price_Type__c) || discountCode.Price_Type__c == CommonUtilClass.MATCHING_ALL_STAR)) 
                                        {
                                            if(discountCode.Discount_Value__c > 0) {
                                                qrpc.quoterateplancharge.Discount_Value__c = discountCode.Discount_Value__c;
                                                //if condition Added by Dhanalakshmi to avoid 'divided by 0'
                                                if(qrpc.quoterateplancharge.Price__c > 0 )
                                                {
                                                    qrpc.quoterateplancharge.Discount_Percent__c = (qrpc.quoterateplancharge.Discount_Value__c/qrpc.quoterateplancharge.Price__c) * 100;
                                                    //Added by ram, INVOICEIT-430, when setting as both we need to set the discount type value
                                                    qrpc.quoterateplancharge.Discount_Type__c = CommonUtilClass.DISCOUNT_TYPE_VALUE;
                                                }
                                            } else {
                                                qrpc.quoterateplancharge.Discount_Percent__c = discountCode.Discount_Percent__c;
                                                qrpc.quoterateplancharge.Discount_Value__c = (qrpc.quoterateplancharge.Quantity__c * qrpc.quoterateplancharge.Unit_Price__c) * qrpc.quoterateplancharge.Discount_Percent__c/100;
                                                //Added by ram, INVOICEIT-430, when setting as both we need to set the discount type value
                                                qrpc.quoterateplancharge.Discount_Type__c = CommonUtilClass.DISCOUNT_TYPE_PERCENTAGE;
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        QuoteChargesCalculator.calculateCharges(quoteClass);
                    }
                } else {
                    Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.WARNING, system.Label.DiscountCodeIsNotValid);
                    Apexpages.addMessage(infoMessage);
                }
            }
        }

        public PageReference save() {
            /*
                    Modified By     : Ankit Sharma: 12 SEPT 2013:  INVOICEIT-230
                    Comments        : handle the exception in step1 of Quote wizard while saving the Quote.
             */
            try {       
                decimal totalContractValue = 0;
                decimal totalChargeContract = 0;
                decimal totalContractedMRR = 0;
                quote.Total_Contract_Value__c = 0;
                quote.Contracted_MRR__c = 0;

                /*
                    Modified By        : Devender M:  04 June 2013:  INVOICEIT-175
                    Comments        : Previously discount was included in Total Contract Value, so i have subtracted the discount value.
                                                Used nettotal for calculating the Total Contract Value
                 */
                 //Added by Joshitha For INVOICEIT-670,To display the error message when valid to date less than todays date and create automatic order =true
                if(quote.Valid_To__c < system.Today() && quote.Create_Automatic_Order__c == true) {
                   Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.QuotehasExpired);
                   Apexpages.addMessage(errorMessage);
                   return null;
                }
                for(QuoteProductClass qpc : quoteClass.quoteProducts)
                {
                    for(QuoteRatePlanClass qrc : qpc.quoteRatePlans)
                    { 
                        for(QuoteRatePlanChargeClass qrpc : qrc.quoteRatePlanCharges)
                        {
                            totalChargeContract = 0;

                            //If the Number_Of_Terms__c are present use that and calculate TCV
                            if(qrpc.quoterateplancharge.Price_Type__c == system.Label.OptionOneTime) {
                                totalChargeContract = qrpc.quoterateplancharge.Net_Total__c;
                            } //Anil has added the below lines on July 2nd 2015 to get the pro ration with the proposed dates (ticket no INVOICEIT-584)
                            else if(quote.Proposed_Start_Date__c != null && quote.Proposed_End_Date__c != null) {
                                totalChargeContract = QuoteCreationUtil.calculateQuoteChargeLineAmount(qrpc.quoterateplancharge, quote.Proposed_Start_Date__c, quote.Proposed_End_Date__c);
                            } else if(quote.Number_Of_Terms__c > 0) {
                                
                                totalChargeContract = QuoteCreationUtil.calculateQuoteChargeLineAmount(qrpc.quoterateplancharge, system.today(), system.today().addMonths((Integer)quote.Number_Of_Terms__c).addDays(-1));  
                            } 

                            //calculate the ContractedMRR only if the type is not equal to one time
                            if(qrpc.quoterateplancharge.Price_Type__c != system.Label.OptionOneTime) {
                                totalContractValue += totalChargeContract;
                                totalContractedMRR += totalChargeContract;
                            } else {
                                totalContractValue += totalChargeContract;
                            }   
                        }
                    }
                }

                quote.Total_Contract_Value__c = totalContractValue;
                if(totalContractedMRR > 0 && quote.Number_Of_Terms__c != null && quote.Number_Of_Terms__c >= 1) {
                    quote.Contracted_MRR__c = (totalContractedMRR/quote.Number_Of_Terms__c);
                }

                //populate the exchange rate Modified by INVOICEIT-522 Dev M make sure exchange rate populates only once 
                if(UserInfo.isMultiCurrencyOrganization() && quoteClass.quote.Valid_To__c != null  && quoteClass.quote.Exchange_Rate_Applied__c == null) {
                    QuoteCreationUtil.populateExchangeRateOnQuote(quoteClass.quote, currecyISOCode);
                }

                upsert quoteClass.quote;
                return new PageReference('/' + quote.Id);
            } catch(DMLException dMlEx){
                // Added by Naveen M ticket : INVOICEIT-310 
                Apexpages.Message errorMessage; 
                for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                { 
                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                    Apexpages.addMessage(errorMessage);      
                } 
                return null; 
            } catch (Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
                Apexpages.addMessage(errorMessage);             
                return null;            
            }
        }  

        decimal conversionRate = 1;
        string clonedCurrecyId = null;
        public string currecyIdAndName {get;set;} 
        public PageReference cloneQuote() {
            savepoint sp = Database.setSavepoint();
            try { 
                isDisableCloneButtons = true;
                Quote__c newQuoteToClone = quoteClass.quote.clone(false);
                if(clonedCurrecyId != null) {
                    newQuoteToClone.CurrencyL__c = clonedCurrecyId;
                } else {
                    newQuoteToClone.Exchange_Rate_Applied__c = null;
                }
                newQuoteToClone.Quote__c = quoteClass.quote.Id;
                newQuoteToClone.OwnerId = UserInfo.getUserId();
                quoteClass.quote = newQuoteToClone;
                quote = quoteClass.quote;

                Quote_Product__c newQuoteProduct;
                Quote_Rate_Plan__c newQuoteRatePlan;
                Quote_Rate_Plan_Charge__c newQuoteRatePlanCharge;
                Quote_Rate_Plan_Charge_Tier__c newQuoteRatePlanChargeTier;

                for(QuoteProductClass qpc : quoteClass.quoteProducts) {
                    newQuoteProduct = qpc.quoteproduct.clone(false);
                    newQuoteProduct.Quote__c = null;
                    qpc.quoteproduct = newQuoteProduct;

                    for(QuoteRatePlanClass qrc : qpc.quoteRatePlans) {
                        newQuoteRatePlan = qrc.quoterateplan.clone(false);
                        newQuoteRatePlan.Quote_Product__c = null;
                        qrc.quoterateplan = newQuoteRatePlan;

                        for(QuoteRatePlanChargeClass qrpc : qrc.quoteRatePlanCharges) {
                            newQuoteRatePlanCharge = qrpc.quoterateplancharge.clone(false);
                            newQuoteRatePlanCharge.Quote_Rate_Plan__c = null;
                            //added by Lopa 09/10/15 for INVOICEIT-614
                            if(newQuoteRatePlanCharge.VAT__c != null){
                                newQuoteRatePlanCharge.VAT__c = newQuoteRatePlanCharge.VAT__c * conversionRate;
                            }
                            if(newQuoteRatePlanCharge.Tax__c != null){
                                newQuoteRatePlanCharge.Tax__c = newQuoteRatePlanCharge.Tax__c * conversionRate;
                            }
                            newQuoteRatePlanCharge.Unit_Price__c = newQuoteRatePlanCharge.Unit_Price__c * conversionRate;
                            if(newQuoteRatePlanCharge.Cost_Price__c != null) {
                                newQuoteRatePlanCharge.Cost_Price__c = newQuoteRatePlanCharge.Cost_Price__c * conversionRate;
                            }
                            newQuoteRatePlanCharge.Profit__c = newQuoteRatePlanCharge.Profit__c * conversionRate;
                            newQuoteRatePlanCharge.Discount_Value__c = newQuoteRatePlanCharge.Discount_Value__c * conversionRate;
                            if(clonedCurrecyId != null) {
                                newQuoteRatePlanCharge.CurrencyL__c = clonedCurrecyId;
                            }
                            qrpc.quoterateplancharge = newQuoteRatePlanCharge;

                            for(QuoteRatePlanChargeTierClass quoteTierClass : qrpc.quoteRatePlanChargeTiers) {
                                newQuoteRatePlanChargeTier = quoteTierClass.quoteRatePlanChargeTier.clone(false);
                                newQuoteRatePlanChargeTier.Quote_Rate_Plan_Charge__c = null;
                                /*
                                    Modified By     : Rama Krishna.v: 02 september 2013: SUP-67 & INVOICEIT-227
                                    Comments      : prevoiusly we are not assigning owner id when we clone Quote that was Cloned by another user, now mapped.
                                 */ 
                                 newQuoteRatePlanChargeTier.OwnerId = UserInfo.getUserId();
                                if(newQuoteRatePlanChargeTier.Unit_Cost_Price__c != null) {
                                    newQuoteRatePlanChargeTier.Unit_Cost_Price__c = newQuoteRatePlanChargeTier.Unit_Cost_Price__c * conversionRate;
                                }
                                newQuoteRatePlanChargeTier.Unit_Price__c = newQuoteRatePlanChargeTier.Unit_Price__c * conversionRate;
                                quoteTierClass.quoteRatePlanChargeTier = newQuoteRatePlanChargeTier;
                            }
                        }
                    }
                }
                return new PageReference('/apex/createQuoteStep1');          
            }
            catch(Exception ex) {
                isDisableCloneButtons = false;
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
                Apexpages.addMessage(errorMessage);
                DataBase.RollBack(sp);  
                return null;
            }
        }

        public list<SelectOption> getCurreciesOptions() {
            return QuoteCreationUtil.getListOfCurreciesOptions(quote.CurrencyL__c);
        }

        public PageReference cloneQuoteWithDifferentCurrency() {
            try {
                list<string> listOfCurrecyIdAndName = currecyIdAndName.split(':');
                clonedCurrecyId = listOfCurrecyIdAndName[0];
                sCurrencyName = listOfCurrecyIdAndName[2] + ' ';
                Date startDate = Date.newInstance(quote.Start_Date__c.Year(), quote.Start_Date__c.Month(), quote.Start_Date__c.Day());
                String quoteDateInString = string.ValueOf(startDate);
                // Modified by Dev M INVOICEIT-409 : Exchange Rate Not Properly Applied
                // Query is for new changed currency
                string sQuery =   'SELECT ISOCode, ConversionRate, StartDate, NextStartDate FROM DatedConversionRate '
                        + 'WHERE ISOCode = \'' + listOfCurrecyIdAndName[1] + '\''
                        + ' AND StartDate <= ' + quoteDateInString + ' AND NextStartDate > ' +  quoteDateInString + ' LIMIT 1';
                sQuery = String.escapeSingleQuotes(sQuery);    
                list<sobject> sobjectDatedConversionRates = Database.query(sQuery);       
                // Query is for old currency
                string sQueryOld =   'SELECT ISOCode, ConversionRate, StartDate, NextStartDate FROM DatedConversionRate '
                        + 'WHERE ISOCode = \'' + quote.CurrencyL__r.Name + '\' '
                        + 'AND StartDate <= ' + quoteDateInString + ' AND NextStartDate > ' +  quoteDateInString + ' LIMIT 1';
                sQueryOld = String.escapeSingleQuotes(sQueryOld); 
                list<sobject> sobjectDatedConversionRatesForOldCurrency = Database.query(sQueryOld); 
                        
                list<sobject> listofCurrencyType = Database.query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true');
                
                if(sobjectDatedConversionRates.size() > 0) {
                    
                    if(listofCurrencyType[0].get('IsoCode') == quote.CurrencyL__r.Name) {
                        //When the old currency is base currency and coverted to new currency
                        conversionRate = (decimal) sobjectDatedConversionRates[0].get('ConversionRate');
                        //populate the exchange rate
                        if(quoteClass.quote.Valid_To__c != null) 
                            QuoteCreationUtil.populateExchangeRateOnQuote(quoteClass.quote, currecyISOCode);
                    } else {
                        // When both the currencies are not base currency we need to coverted both according to base currency
                        // When the old currency is coverted to base currency
                        conversionRate = ((decimal) sobjectDatedConversionRates[0].get('ConversionRate')/(decimal) sobjectDatedConversionRatesForOldCurrency[0].get('ConversionRate'));
                        quoteClass.quote.put(sPrefix+'Exchange_Rate_Applied__c',conversionRate);
                        quoteClass.quote.put('CurrencyIsoCode',listOfCurrecyIdAndName[1]);
                    }
                    
                    cloneQuote();
                    return new PageReference('/apex/createQuoteStep1');
                } else {
                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.NoConversionDate);
                    Apexpages.addMessage(errorMessage);
                } 
            } catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
                Apexpages.addMessage(errorMessage);
            }   

            return null;   
        }

        /* code for tiers */
        public boolean displayPopup {get; set;}
        public string quoteRatePlanChargeCounterForTier {get; set;}
        public void closePopup() {        
            displayPopup = false;    
        } 

        /*
                Modified By          : Anil Pinto:  13 June 2013:   INVOICEIT-61
                Comments          : This new method is created as a validations required while saving the tiers
                Modified BY         : S.A.Manigandan: 25 June 2014:  SUP-278
                Comments          : This method has been modified to check the VR on Start & End Unit  */
           
        public Pagereference saveAndClosePopup(){ 

            for(QuoteProductClass qpc :quoteClass.quoteProducts) {
                for(QuoteRatePlanClass qrc : qpc.quoteRatePlans) { 
                    for(QuoteRatePlanChargeClass qrpc :qrc.quoteRatePlanCharges) {
                        Quote_Rate_Plan_Charge_Tier__c quoteRatePlanChargeTier = null;
                        if(qrpc.quoteRatePlanChargeTiers.size() > 1){
                            for(QuoteRatePlanChargeTierClass quoteRatePlanChargeTierClass : qrpc.quoteRatePlanChargeTiers){
                                 
                                if(quoteRatePlanChargeTier == null){
                                    quoteRatePlanChargeTier = quoteRatePlanChargeTierClass.quoteRatePlanChargeTier;
                                }
                                else{
                                    if(!qrpc.quoteRatePlanChargeTiers.isEmpty() && qrpc.quoteRatePlanChargeTiers.get(0).quoteRatePlanChargeTier.Start_Unit__c < 0){
                                // the start unit should start from 1
                                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.StartUnitCannotHaveNegativeValue);
                                Apexpages.addMessage(errorMessage);
                                return null;
                            } else if(!qrpc.quoteRatePlanChargeTiers.isEmpty() && (qrpc.quoteRatePlanChargeTiers.get(0).quoteRatePlanChargeTier.End_Unit__c!=null && qrpc.quoteRatePlanChargeTiers.get(0).quoteRatePlanChargeTier.End_Unit__c < qrpc.quoteRatePlanChargeTiers.get(0).quoteRatePlanChargeTier.Start_Unit__c)){
                                //Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'End unit should not be less than Start Unit'));
                                //Added by Shruthi related to INVOICEIT-200
                                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.EndUnitShouldNotBeLessThanStartUnit));   
                                //displayPopup = false; 
                                return null;
                            } else
                            if(quoteRatePlanChargeTierClass.quoteRatePlanChargeTier.Start_Unit__c < 0){
                                
                                // the start unit should start from 1
                                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.StartUnitCannotHaveNegativeValue);
                                Apexpages.addMessage(errorMessage);
                                return null;
                            }
                            
                                    /*
                                        Modified By         : Rama Krishna.v :  06-11-13:  SUP-134
                                        Comments          : If an End Unit is entered, it must be less than the subsequent Start Unit. If an End Unit is not entered,
                                                                      there will be no validation and the tier will be determined up to the subsequent Start Unit.
                                     */
                                    //decimal iExactValue = quoteRatePlanChargeTier.Start_Unit__c;
                                    else if(quoteRatePlanChargeTierClass.quoteRatePlanChargeTier.End_Unit__c!=null && quoteRatePlanChargeTierClass.quoteRatePlanChargeTier.End_Unit__c < quoteRatePlanChargeTierClass.quoteRatePlanChargeTier.Start_Unit__c){
                                        // throw error msg
                                        //Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,'End unit should not be less than Start Unit');
                                        //Added by Shruthi related to INVOICEIT-200
                                        Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.EndUnitShouldNotBeLessThanStartUnit);
                                        Apexpages.addMessage(errorMessage);
                                        return null;
                                    }
                                     else if(quoteRatePlanChargeTier.End_Unit__c != null){
                                        decimal iEndUnitValue = quoteRatePlanChargeTier.End_Unit__c;
                                        if(quoteRatePlanChargeTierClass.quoteRatePlanChargeTier.Start_Unit__c <= iEndUnitValue){
                                            Apexpages.Message errorMessage1 = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.TierStartUnit);
                                            Apexpages.addMessage(errorMessage1);
                                            return null;
                                        }
                                    }
                                quoteRatePlanChargeTier = quoteRatePlanChargeTierClass.quoteRatePlanChargeTier; 
                               
                            }
                           
                        } 
                            }
                        else{
                            if(!qrpc.quoteRatePlanChargeTiers.isEmpty() && qrpc.quoteRatePlanChargeTiers.get(0).quoteRatePlanChargeTier.Start_Unit__c < 0){
                                // the start unit should start from 1
                                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.StartUnitCannotHaveNegativeValue);
                                Apexpages.addMessage(errorMessage);
                                return null;
                            }else if(!qrpc.quoteRatePlanChargeTiers.isEmpty() && (qrpc.quoteRatePlanChargeTiers.get(0).quoteRatePlanChargeTier.End_Unit__c!=null && qrpc.quoteRatePlanChargeTiers.get(0).quoteRatePlanChargeTier.End_Unit__c < qrpc.quoteRatePlanChargeTiers.get(0).quoteRatePlanChargeTier.Start_Unit__c)){
                                //Added by Shruthi related to INVOICEIT-200
                                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.EndUnitShouldNotBeLessThanStartUnit));   
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
            quoteRatePlanChargeCounterForTier = system.currentPageReference().getParameters().get('quoteRatePlanChargeCounterForTier');
            displayPopup = true;    
        }


        public void newTier() {
            //integer quoteRatePlanChargeCounterForTier = integer.ValueOf(system.currentPageReference().getParameters().get('quoteRatePlanChargeCounterForTier'));
            for(QuoteProductClass qpc :quoteClass.quoteProducts) {
                for(QuoteRatePlanClass qrc : qpc.quoteRatePlans) { 
                    for(QuoteRatePlanChargeClass qrpc :qrc.quoteRatePlanCharges) {
                        if(qrpc.quoteRatePlanChargeCounter == integer.ValueOf(quoteRatePlanChargeCounterForTier)) {
                            QuoteRatePlanChargeTierClass quoteTierClass = new QuoteRatePlanChargeTierClass();
                            quoteTierClass.quoteRatePlanChargeTier = new Quote_Rate_Plan_Charge_Tier__c();
                            quoteTierClass.quoteRatePlanChargeTierCounter = ++quoteRatePlanChargeTierCounter;
                            qrpc.quoteRatePlanChargeTiers.add(quoteTierClass);
                        }
                    }
                }
            }
        }

        public void removeTier() { 
            try{       
                string quoteTierIdToDelete = system.currentPageReference().getParameters().get('quoteTierIdToDelete');
                Integer quoteTierCounterToDelete = Integer.valueOf(system.currentPageReference().getParameters().get('quoteTierCountertoDelete'));
                Integer quoteRatePlanChargeCounterForTier = Integer.valueOf(system.currentPageReference().getParameters().get('quoteRatePlanChargeCounterForTier'));

                if(quoteTierIdToDelete != null && quoteTierIdToDelete.Length() > 0) {
                    Quote_Rate_Plan_Charge_Tier__c quoteTierToDelete = new Quote_Rate_Plan_Charge_Tier__c(Id = quoteTierIdToDelete);
                    delete quoteTierToDelete;
                }

                for(QuoteProductClass qpc : quoteClass.quoteProducts) {
                    for(QuoteRatePlanClass qrc : qpc.quoteRatePlans) { 
                        for(QuoteRatePlanChargeClass qrpc : qrc.quoteRatePlanCharges) {
                            if(qrpc.quoteRatePlanChargeCounter == quoteRatePlanChargeCounterForTier) {
                                for(integer i = 0; i < qrpc.quoteRatePlanChargeTiers.size(); i++) {
                                    QuoteRatePlanChargeTierClass quoteTierClass = qrpc.quoteRatePlanChargeTiers[i];
                                    if(quoteTierClass.quoteRatePlanChargeTierCounter == quoteTierCounterToDelete) {
                                        qrpc.quoteRatePlanChargeTiers.remove(i);
                                    }
                                }
                            }
                        }
                    }
                }
            }catch(DMLException dMlEx){
                // Added by Naveen M ticket : INVOICEIT-310 
                Apexpages.Message errorMessage; 
                for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                { 
                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                    Apexpages.addMessage(errorMessage);      
                } 

            } catch (Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
                Apexpages.addMessage(errorMessage);             

            }
        }
        /* code for tiers */
        
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
            addQuoteCharges();
            return null;    
        }
        /* code for displaying the product charges in a popup for selecting INVOICEIT-348 */
    }