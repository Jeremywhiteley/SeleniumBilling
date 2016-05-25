// This util class consists all the Util methods used for the new product page 
    public with sharing class ProductCreationUtil {

        public static final String PRICE_FORMAT_TIERED = 'Tiered Pricing';
        public static final String PRICE_FORMAT_VOLUME = 'Volume Pricing';
        public static final String PRICE_FORMAT_PER_UNIT = 'Per Unit Pricing';
        public static final String PRICE_FORMAT_FLAT_FEE = 'Flat Fee Pricing';
        public static final String PRICE_FORMAT_PERCENTAGE_PRICING = 'Percentage Pricing';
        public static final String CLONE_WITH_CHARGES = 'CloneWithCharges';
        public static final String CLONE_RATEPLAN = 'CloneRatePlan';
        public static final String CLONE_CHARGE = 'CloneCharge';
        public static final String CLONE_WITH_TIERS = 'CloneWithTiers';
        public static final String SAVE_AND_NEW_RATEPLAN = 'SaveandNewRateplan';
        public static final String SAVE_AND_NEW = 'SaveandNew';
        public static final String ERROR = 'error';
        public static string sPrefix = CommonUtilClass.getPrefix();
        public static final String PRODUCT_OBJECT_NAME = sPrefix+'Product__c';
        public static final String RATEPLAN_OBJECT_NAME = sPrefix+'Product_Rate_Plan__c';
        public static final String CHARGE_OBJECT_NAME = sPrefix+'Product_Rate_Plan_Charge__c';
        public static final String VALID_FROM_DATE = sPrefix+'Valid_From_Date__c';
        public static final String VALID_TO_DATE = sPrefix+'Valid_To_Date__c';
        public static Boolean isExtensionInstalled = false;
        public static map<String,list<SelectOption>> mapInvoiceITSettings;

        //This method returns a select query string that contains all the standard fields of the object
        public static String getObjectSelectQuery(String objectName) {
            String sQuery = 'SELECT ';
            sQuery += getObjectFields(objectName);
            sQuery += ' FROM '+ objectName + ' ';
            return sQuery;
        }

        //This method returns a comma seperated string of all the standard fields of the object
        public static String getObjectFields(String objectName) {
            String sQuery = '';
            Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            for(Schema.SObjectField column: objectFieldMap.values()) {
                sQuery += column+', ';
            }
            sQuery = sQuery.substring(0, sQuery.length()-2);
            sQuery += ' ';
            return sQuery;
        }

        //This method returns a comma seperated string of all the standard fields of the object
        public static list<map<String,String>> getObjectLabelNFields(String objectName) {
            map<String,String>  mapLabel_Field = new  map<String,String>();
            map<String,String>  mapField_Label = new  map<String,String>();
            list<map<String,String>> listMaps = new list<map<String,String>>();
            Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            for(Schema.SObjectField column: objectFieldMap.values()) {
                if(column.getDescribe().getName() != 'LastViewedDate') {
                    mapLabel_Field.put(column.getDescribe().getLabel(),column.getDescribe().getName());
                    mapField_Label.put(column.getDescribe().getName(),column.getDescribe().getLabel());     
                }
            }
            listMaps.add(mapLabel_Field);
            listMaps.add(mapField_Label);
            return listMaps;
        }

        // This method returns the product object for the matching product id
        public static Product__c getProduct(string selectedProductId) {
            String sQuery = ProductCreationUtil.getObjectSelectQuery(sPrefix+'Product__c') + ' where Id =' + '\'' + String.escapeSingleQuotes(selectedProductId) + '\'';
            Product__c product = Database.query(sQuery);
            return product;
        }

        // This method returns the list of Rateplans  for the matching product id
        public static list<Product_Rate_Plan__c> getListOfRatePlans(Id productId) {
            String sQuery =  'SELECT ' + ProductCreationUtil.getObjectFields(sPrefix+'Product_Rate_Plan__c') + ',' 
            + '(SELECT ' + ProductCreationUtil.getObjectFields(sPrefix+'Product_Rate_Plan_Charge__c') +  'from ProductRatePlanCharge__r Order by Charge_Sequence_Number__c)'
            + 'from Product_Rate_Plan__c where Product__c =\'' + String.escapeSingleQuotes(productId) + '\''
            + ' Order by createdDate ';      
            return Database.query(sQuery);
        }

        /*
           Modified By:Rama krishna.v:10-2-2014:IT-91
           Comments : This is ussed in the new product controller and method returns the list of Rateplans for the matching product id
         */
        public static list<Product_Rate_Plan__c> getListOfRatePlansNew(Id productId) {
            String sQuery =  'SELECT ' + ProductCreationUtil.getObjectFields(sPrefix+'Product_Rate_Plan__c') +
            + 'from Product_Rate_Plan__c where Product__c =\'' + String.escapeSingleQuotes(productId) + '\''
            + ' Order by createdDate ';      
            return Database.query(sQuery);
        }

        // This method returns the list of Tiers  for the matching set of charge ids
        public static list<Product_Rate_Plan_Charge_Tier__c> getListOfTiers(set<Id> setOfRatePlanChargesIds) {
            // Modified by Dev:INVOICEIT-546
            String sQuery = ProductCreationUtil.getObjectSelectQuery(sPrefix+'Product_Rate_Plan_Charge_Tier__c') + ' where ';
            sQuery = sQuery + ' Product_Rate_Plan_Charge__c IN : setOfRatePlanChargesIds ORDER BY Start_Unit__c' ;
            sQuery = String.escapeSingleQuotes(sQuery);
            list<Product_Rate_Plan_Charge_Tier__c> listOfTiers= Database.query(sQuery);
            return listOfTiers;
        }

        // This method returns the list of charges  for the matching rateplan id
        public static list<Product_Rate_Plan_Charge__c> getProductRatePlanCharges(string selectedRatePlanId) {
            String sQuery = ProductCreationUtil.getObjectSelectQuery(sPrefix+'Product_Rate_Plan_Charge__c') + ' where   Product_Rate_Plan__c =' + '\'' + String.escapeSingleQuotes(selectedRatePlanId) + '\'';
            sQuery = sQuery + ' Order by Charge_Sequence_Number__c';
            list<Product_Rate_Plan_Charge__c> listcharges = Database.query(sQuery);
            return listcharges;
        }

        // This method returns the map of ProductRatePLan object for the matching product id
        public static map<Id,Product_Rate_Plan__c> getProductRatePlans(string productId) {
            map<Id,Product_Rate_Plan__c> mapId_ProductRatePlan = new map<Id,Product_Rate_Plan__c>();
            String sQuery = ProductCreationUtil.getObjectSelectQuery(sPrefix+'Product_Rate_Plan__c') + ' where Product__c =' + '\'' + String.escapeSingleQuotes(productId) + '\'';
            list<Product_Rate_Plan__c> listProductRatePlan = Database.query(sQuery);
            for(Product_Rate_Plan__c productRatePlan : listProductRatePlan) {
                mapId_ProductRatePlan.put(productRatePlan.Id,productRatePlan);
            }
            return mapId_ProductRatePlan;
        }

        public static list<Product_Rate_Plan_Charge_Tier__c> getTiers(String sChargeId) {
            list<Product_Rate_Plan_Charge_Tier__c> listTiers = [select Start_Unit__c,End_Unit__c,Unit_Price__c,Unit_Cost_Price__c from Product_Rate_Plan_Charge_Tier__c where Product_Rate_Plan_Charge__c =:sChargeId  ORDER BY Start_Unit__c];
            return listTiers;
        }

        public static map<Id,list<Product_Rate_Plan_Charge_Tier__c>>   getMapId_Tiers(list<Id> listChargeIds) {
            map<Id,list<Product_Rate_Plan_Charge_Tier__c>> mapId_Tiers = new map<Id,list<Product_Rate_Plan_Charge_Tier__c>>();
            list<Product_Rate_Plan_Charge_Tier__c> listTiersForMap;
            list<Product_Rate_Plan_Charge_Tier__c> listTiers = [select Product_Rate_Plan_Charge__c,Start_Unit__c,End_Unit__c,Unit_Price__c,Unit_Cost_Price__c from Product_Rate_Plan_Charge_Tier__c where Product_Rate_Plan_Charge__c in: listChargeIds ORDER BY Start_Unit__c];
            for(Product_Rate_Plan_Charge_Tier__c tier :listTiers) {
                if(mapId_Tiers.ContainsKey(tier.Product_Rate_Plan_Charge__c)) {
                    listTiersForMap = mapId_Tiers.get(tier.Product_Rate_Plan_Charge__c);
                }
                else {
                    listTiersForMap = new list<Product_Rate_Plan_Charge_Tier__c>();
                }
                listTiersForMap.add(tier);
                mapId_Tiers.put(tier.Product_Rate_Plan_Charge__c,listTiersForMap);
            }

            return mapId_Tiers;
        }

        public static map<Id,list<Product_Rate_Plan_Charge__c>>   getMapId_Charges(Id productId) {
            map<Id,list<Product_Rate_Plan_Charge__c>> mapId_Charges = new map<Id,list<Product_Rate_Plan_Charge__c>>();
            list<Product_Rate_Plan_Charge__c>  listChargeForMap;
            list<Product_Rate_Plan_Charge__c> listCharge =  [select  Product_Rate_Plan__c, Charge_Sequence_Number__c from Product_Rate_Plan_Charge__c  where Product_Rate_Plan__r.product__r.Id =: productId  and Charge_Sequence_Number__c != null order by Charge_Sequence_Number__c desc];

            for(Product_Rate_Plan_Charge__c  charge :listCharge) {
                if(mapId_Charges.ContainsKey(charge.Product_Rate_Plan__c)) {
                    listChargeForMap = mapId_Charges.get(charge.Product_Rate_Plan__c);
                }
                else {
                    listChargeForMap = new list<Product_Rate_Plan_Charge__c>();
                }
                listChargeForMap.add(charge);
                mapId_Charges.put(charge.Product_Rate_Plan__c,listChargeForMap);
            }

            return mapId_Charges;
        }

        /*
           Modified By:Asish Kumar Behera:03-03-2014:INV-323
           Comments:This is ussed in the InvoiceITSetupController controller and method returns 
         */

        /**
         *@purpose : Method refered in InvoiceITSetupController for set up page
         *created By:Asish Behera:INVOICEIT-323,@Return:Pagereference
         **/
        public static map<String,list<SelectOption>> getMapSource_listDestinations() {
            map<String,list<SelectOption>> mapSource_listDestinations = new map<String,list<SelectOption>>();
            list<SelectOption> listDestinations = new list<SelectOption>();
            listDestinations.add(new SelectOption( '' , '--None--'));
            listDestinations.add(new SelectOption( 'Job__c' , 'Order'));
            listDestinations.add(new SelectOption( 'Opportunity' , 'Opportunity'));
            mapSource_listDestinations.put('Quote__c',listDestinations);

            listDestinations = new list<SelectOption>();
            listDestinations.add(new SelectOption( '' , '--None--'));
            listDestinations.add(new SelectOption( 'Job_Product__c' , 'Order Product'));
            listDestinations.add(new SelectOption( 'Opportunity_Product__c' , 'Opportunity Product'));
            mapSource_listDestinations.put('Quote_Product__c',listDestinations);

            listDestinations = new list<SelectOption>();
            listDestinations.add(new SelectOption( '' , '--None--'));
            listDestinations.add(new SelectOption( 'Job_Rate_Plan__c' , 'Order Rate Plan'));
            listDestinations.add(new SelectOption( 'Opportunity_Rate_Plan__c' , 'Opportunity Rate Plan'));
            mapSource_listDestinations.put('Quote_Rate_Plan__c',listDestinations);

            listDestinations = new list<SelectOption>();
            listDestinations.add(new SelectOption( '' , '--None--'));
            listDestinations.add(new SelectOption( 'Job_Rate_Plan_Charge__c' , 'Order Rate Plan Charge'));
            listDestinations.add(new SelectOption( 'Opportunity_Rate_Plan_Charge__c' , 'Opportunity Rate Plan Charge'));
            mapSource_listDestinations.put('Quote_Rate_Plan_Charge__c',listDestinations);

            listDestinations = new list<SelectOption>();
            listDestinations.add(new SelectOption( '' , '--None--'));
            listDestinations.add(new SelectOption( 'Job__c' , 'Order'));
            listDestinations.add(new SelectOption( 'Quote__c' , 'Quote'));
            mapSource_listDestinations.put('Opportunity',listDestinations);

            listDestinations = new list<SelectOption>();
            listDestinations.add(new SelectOption( '' , '--None--'));
            listDestinations.add(new SelectOption( 'Job_Product__c' , 'Order Product'));
            listDestinations.add(new SelectOption( 'Quote_Product__c' , 'Quote Product'));
            mapSource_listDestinations.put('Opportunity_Product__c',listDestinations);

            listDestinations = new list<SelectOption>();
            listDestinations.add(new SelectOption( '' , '--None--'));
            listDestinations.add(new SelectOption( 'Job_Rate_Plan__c' , 'Order Rate Plan'));
            listDestinations.add(new SelectOption( 'Quote_Rate_Plan__c' , 'Quote Rate Plan'));
            mapSource_listDestinations.put('Opportunity_Rate_Plan__c',listDestinations);

            listDestinations = new list<SelectOption>();
            listDestinations.add(new SelectOption( '' , '--None--'));
            listDestinations.add(new SelectOption( 'Job_Rate_Plan_Charge__c' , 'Order Rate Plan Charge'));
            listDestinations.add(new SelectOption( 'Quote_Rate_Plan_Charge__c' , 'Quote Rate Plan Charge'));
            mapSource_listDestinations.put('Opportunity_Rate_Plan_Charge__c',listDestinations);

            listDestinations = new list<SelectOption>();
            listDestinations.add(new SelectOption( '' , '--None--'));
            listDestinations.add(new SelectOption( 'Job_Product__c' , 'Order Product'));
            listDestinations.add(new SelectOption( 'Quote_Product__c' , 'Quote Product'));
            listDestinations.add(new SelectOption( 'Opportunity_Product__c' , 'Opportunity Product'));
            mapSource_listDestinations.put('Product__c',listDestinations);

            listDestinations = new list<SelectOption>();
            listDestinations.add(new SelectOption( '' , '--None--'));
            listDestinations.add(new SelectOption( 'Job_Rate_Plan__c' , 'Order Rate Plan'));
            listDestinations.add(new SelectOption( 'Quote_Rate_Plan__c' , 'Quote Rate Plan'));
            listDestinations.add(new SelectOption( 'Opportunity_Rate_Plan__c' , 'Opportunity Rate Plan' ));
            mapSource_listDestinations.put('Product_Rate_Plan__c',listDestinations);

            listDestinations = new list<SelectOption>();
            listDestinations.add(new SelectOption( '' , '--None--'));
            listDestinations.add(new SelectOption( 'Job_Rate_Plan_Charge__c' , 'Order Rate Plan Charge'));
            listDestinations.add(new SelectOption( 'Quote_Rate_Plan_Charge__c' , 'Quote Rate Plan Charge'));
            listDestinations.add(new SelectOption( 'Opportunity_Rate_Plan_Charge__c' , 'Opportunity Rate Plan Charge' ));
            mapSource_listDestinations.put('Product_Rate_Plan_charge__c',listDestinations);
            
            //Added for INVOICEIT-573
            listDestinations = new list<SelectOption>();
            listDestinations.add(new SelectOption( '' , '--None--'));        
            listDestinations.add(new SelectOption( 'Opportunity' , 'Opportunity'));
            listDestinations.add(new SelectOption( 'Quote__c' , 'Quote'));
            mapSource_listDestinations.put('Job__c',listDestinations);

            listDestinations = new list<SelectOption>();
            listDestinations.add(new SelectOption( '' , '--None--'));        
            listDestinations.add(new SelectOption( 'Opportunity_Product__c' , 'Opportunity Product'));
            listDestinations.add(new SelectOption( 'Quote_Product__c' , 'Quote Product'));
            mapSource_listDestinations.put('Job_Product__c',listDestinations);

            listDestinations = new list<SelectOption>();
            listDestinations.add(new SelectOption( '' , '--None--'));        
            listDestinations.add(new SelectOption( 'Opportunity_Rate_Plan__c' , 'Opportunity Rate Plan'));
            listDestinations.add(new SelectOption( 'Quote_Rate_Plan__c' , 'Quote Rate Plan'));
            mapSource_listDestinations.put('Job_Rate_Plan__c',listDestinations);

            listDestinations = new list<SelectOption>();
            listDestinations.add(new SelectOption( '' , '--None--'));        
            listDestinations.add(new SelectOption( 'Opportunity_Rate_Plan_Charge__c' , 'Opportunity Rate Plan Charge'));
            listDestinations.add(new SelectOption( 'Quote_Rate_Plan_Charge__c' , 'Quote Rate Plan Charge'));
            mapSource_listDestinations.put('Job_Rate_Plan_Charge__c',listDestinations);

            return mapSource_listDestinations;
        }

        /**
         *@purpose : Method refered in InvoiceITSetupController for product filtration
         *created By :Asish Behera:INVOICEIT-323
         *@Return : Pagereference
         **/
        public static map<String,list<SelectOption>> getMapSource_listDestinationsForFilters() {
            map<String,list<SelectOption>> mapSource_listDestinations = new map<String,list<SelectOption>>();
            list<SelectOption> listDestinations = new list<SelectOption>();
            listDestinations.add(new SelectOption( '' , '--None--'));
            listDestinations.add(new SelectOption( 'Product__c' , 'Invoice IT Product'));
            listDestinations.add(new SelectOption( 'Product_Rate_Plan__c' , 'Product Rate Plan' ));
            listDestinations.add(new SelectOption( 'Product_Rate_Plan_charge__c' , 'Product Rate Plan Charge'));
            mapSource_listDestinations.put('Quote__c',listDestinations);

            listDestinations = new list<SelectOption>();
            listDestinations.add(new SelectOption( '' , '--None--'));
            listDestinations.add(new SelectOption( 'Product__c' , 'Invoice IT Product'));
            listDestinations.add(new SelectOption( 'Product_Rate_Plan__c' , 'Product Rate Plan' ));
            listDestinations.add(new SelectOption( 'Product_Rate_Plan_charge__c' , 'Product Rate Plan Charge'));
            mapSource_listDestinations.put('Opportunity',listDestinations);

            listDestinations = new list<SelectOption>();
            listDestinations.add(new SelectOption( '' , '--None--'));
            listDestinations.add(new SelectOption( 'Product__c' , 'Invoice IT Product'));
            listDestinations.add(new SelectOption( 'Product_Rate_Plan__c' , 'Product Rate Plan' ));
            listDestinations.add(new SelectOption( 'Product_Rate_Plan_charge__c' , 'Product Rate Plan Charge'));
            mapSource_listDestinations.put('Job__c',listDestinations);

            listDestinations = new list<SelectOption>();
            listDestinations.add(new SelectOption( '' , '--None--'));
            listDestinations.add(new SelectOption( 'Product__c' , 'Invoice IT Product'));
            listDestinations.add(new SelectOption( 'Product_Rate_Plan__c' , 'Product Rate Plan' ));
            listDestinations.add(new SelectOption( 'Product_Rate_Plan_charge__c' , 'Product Rate Plan Charge'));
            mapSource_listDestinations.put('Account',listDestinations);

            return mapSource_listDestinations;
        }
        /**
         *@purpose : Method responsible for getting all the fields of choosen sobject in the mapping section
         *created By :Asish Behera:INVOICEIT-323
         *@Return : Pagereference
         **/
        public static list<SelectOption> getObjectFieldsFromMapForSettings(String sObjectName) {
            list<SelectOption> listField_labelOptions = new list<SelectOption>();
            Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();
            for(Schema.SObjectField column: objectFieldMap.values()) {
                if(column.getDescribe().getLocalName().contains('__c') || column.getDescribe().getLocalName()=='Name') {
                    listField_labelOptions.add(new SelectOption( column.getDescribe().getLocalName(),column.getDescribe().getLabel()));
                }

            }
            return listField_labelOptions;
        }

        /**
         *@purpose : Method refered in InvoiceITSetupController to construct data
         *created By :Asish Behera:INVOICEIT-323
         *@Return : Pagereference
         **/
        public static map<String,list<SelectOption>> getMapInvoiceITSettings() {
            mapInvoiceITSettings = new map<String,list<SelectOption>>();
            list<SelectOption> listGeneral = new list<SelectOption>();
            list<SelectOption> listPaymentTerms = new list<SelectOption>();
            listPaymentTerms.add(new SelectOption( '' , '--None--'));
            listPaymentTerms.add(new SelectOption( 'ACCOUNT' , 'Account'));
            listPaymentTerms.add(new SelectOption( 'ORDER' , 'Order'));
            mapInvoiceITSettings.put('listPaymentTerms',listPaymentTerms);

            list<SelectOption> listRecordsPage2 = new list<SelectOption>();
            listRecordsPage2.add(new SelectOption( '10.00' , '10'));
            listRecordsPage2.add(new SelectOption( '20.00' , '20'));
            listRecordsPage2.add(new SelectOption( '30.00' , '30'));
            listRecordsPage2.add(new SelectOption( '40.00' , '40'));
            mapInvoiceITSettings.put('listRecordsPage2',listRecordsPage2);

            list<SelectOption> listOrderFieldsForDiscountCode = new list<SelectOption>();
            listGeneral = getObjectFieldsFromMapForSettings(sPrefix+'Job__c');
            listOrderFieldsForDiscountCode.add(new SelectOption( '' , '--None--'));
            for(SelectOption selectOptionGeneral : listGeneral) {
                listOrderFieldsForDiscountCode.add(new SelectOption(selectOptionGeneral.getValue() , selectOptionGeneral.getLabel()));
            }
            mapInvoiceITSettings.put('listOrderFieldsForDiscountCode',listOrderFieldsForDiscountCode);

            list<SelectOption> listQuoteFieldsForDiscountCode = new list<SelectOption>();
            listGeneral = getObjectFieldsFromMapForSettings(sPrefix+'Quote__c');
            listQuoteFieldsForDiscountCode.add(new SelectOption( '' , '--None--'));
            for(SelectOption selectOptionGeneral : listGeneral) {
                listQuoteFieldsForDiscountCode.add(new SelectOption(selectOptionGeneral.getValue() , selectOptionGeneral.getLabel()));
            }
            mapInvoiceITSettings.put('listQuoteFieldsForDiscountCode',listQuoteFieldsForDiscountCode);

            list<SelectOption> listProductValueToRollUp = new list<SelectOption>();
            listProductValueToRollUp.add(new SelectOption( '' , '--None--'));
            listProductValueToRollUp.add(new SelectOption( 'SUBTOTAL' , 'Subtotal'));
            listProductValueToRollUp.add(new SelectOption( 'NETTOTAL' , 'Nettotal'));
            listProductValueToRollUp.add(new SelectOption( 'TCV' , 'TCV'));
            listProductValueToRollUp.add(new SelectOption( 'GRANDTOTAL' , 'Grandtotal'));
            mapInvoiceITSettings.put('listProductValueToRollUp',listProductValueToRollUp);

            list<SelectOption> listPaymentSchedulerDates = new list<SelectOption>();
            listPaymentSchedulerDates.add(new SelectOption( '' , '--None--'));
            listPaymentSchedulerDates.add(new SelectOption( 'Due Date' , 'Due Date'));
            listPaymentSchedulerDates.add(new SelectOption( 'Invoice Date' , 'Invoice Date'));
            listPaymentSchedulerDates.add(new SelectOption( 'Preferred Payment Date' , 'Preferred Payment Date'));
            mapInvoiceITSettings.put('listPaymentSchedulerDates',listPaymentSchedulerDates);

            list<SelectOption> listInvoiceGeneration = new list<SelectOption>();
            listInvoiceGeneration.add(new SelectOption( '' , '--None--'));
            listInvoiceGeneration.add(new SelectOption( 'ONE_INVOICE_PER_ACCOUNT' , 'Per Account'));
            listInvoiceGeneration.add(new SelectOption( 'ONE_INVOICE_PER_ORDER' , 'Per Order'));
            mapInvoiceITSettings.put('listInvoiceGeneration',listInvoiceGeneration);
            list<SelectOption> listOrderStatusfields = new list<SelectOption>();
            Schema.DescribeFieldResult fieldResult = Job__c.Status__c.getDescribe();
            list<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            listOrderStatusfields.add(new SelectOption( '' , '--None--'));
            for( Schema.PicklistEntry f : ple){
                listOrderStatusfields.add(new SelectOption(f.getValue(),f.getValue()));
            }  
            mapInvoiceITSettings.put('listOrderStatusfields',listOrderStatusfields);


            list<SelectOption> listApplyDiscounts = new list<SelectOption>();
            listApplyDiscounts.add(new SelectOption( '' , '--None--'));
            //INVOICEIT-430, Dhanalaxmi, replaced by 'by percentage' to '%'
            listApplyDiscounts.add(new SelectOption(CommonUtilClass.APPLY_DISCOUNT_BY_PERCENTAGE , '%'));
            listApplyDiscounts.add(new SelectOption(CommonUtilClass.APPLY_DISCOUNT_BY_VALUE , 'Value'));
            //Added by dhanalakshmi for INVOICEIT-430
            listApplyDiscounts.add(new SelectOption(CommonUtilClass.APPLY_DISCOUNT_BY_BOTH , 'Both'));
            mapInvoiceITSettings.put('listApplyDiscounts',listApplyDiscounts);

            list<SelectOption> listInvoiceStatus = new list<SelectOption>();
            listInvoiceStatus.add(new SelectOption( '' , '--None--'));
            listInvoiceStatus.add(new SelectOption('Draft' , 'Draft'));
            listInvoiceStatus.add(new SelectOption('Posted' , 'Posted'));
            mapInvoiceITSettings.put('listInvoiceStatus',listInvoiceStatus);

            list<SelectOption> listAccountFields = new list<SelectOption>();
            listGeneral = getObjectFieldsFromMapForSettings('Account');
            listAccountFields.add(new SelectOption( '' , '--None--'));

            for(SelectOption selectOptionGeneral : listGeneral) {
                listAccountFields.add(new SelectOption(selectOptionGeneral.getValue() , selectOptionGeneral.getLabel()));
            }
            mapInvoiceITSettings.put('listAccountFields',listAccountFields);

            list<SelectOption> listORPCStatus = new list<SelectOption>();
            Schema.DescribeFieldResult fieldResult1 = Job_Rate_Plan_Charge__c.Status__c.getDescribe();
            list<Schema.PicklistEntry> ple1 = fieldResult1.getPicklistValues();
            listORPCStatus.add(new SelectOption( '' , '--None--'));
            for( Schema.PicklistEntry f : ple1){
                listORPCStatus.add(new SelectOption(f.getValue(),f.getValue()));
            }  
            mapInvoiceITSettings.put('listORPCStatus',listORPCStatus);

            //for Order
            list<SelectOption> listOrderFields = new list<SelectOption>();
            listGeneral = getObjectFieldsFromMapForSettings(sPrefix+'Job__c');
            listOrderFields.add(new SelectOption( '' , '--None--'));
            for(SelectOption selectOptionGeneral : listGeneral) {
                listOrderFields.add(new SelectOption(selectOptionGeneral.getValue() , selectOptionGeneral.getLabel()));
            }
            mapInvoiceITSettings.put('listOrderFields',listOrderFields);

            //for Quote
            list<SelectOption> listQuoteFields = new list<SelectOption>();
            listGeneral = getObjectFieldsFromMapForSettings(sPrefix+'Quote__c');
            listQuoteFields.add(new SelectOption( '' , '--None--'));
            for(SelectOption selectOptionGeneral : listGeneral) {
                listQuoteFields.add(new SelectOption(selectOptionGeneral.getValue() , selectOptionGeneral.getLabel()));
            }
            mapInvoiceITSettings.put('listQuoteFields',listQuoteFields);

            //order status field picklist value
            list<SelectOption> listOrderStatusfields1 = new list<SelectOption>();
            listOrderStatusfields1 = gettingAllPicklistvalueofSobject(sPrefix+'Job__c',sPrefix+'Status__c');
            mapInvoiceITSettings.put('listOrderStatusfields1',listOrderStatusfields1);

            //quote status field
            list<SelectOption> listQuoteStatusfields1 = new list<SelectOption>();
            listQuoteStatusfields1 = gettingAllPicklistvalueofSobject(sPrefix+'Quote__c',sPrefix+'Status__c');
            mapInvoiceITSettings.put('listQuoteStatusfields1',listQuoteStatusfields1);
            //product informations
            list<SelectOption> listProductFields = new list<SelectOption>();
            listGeneral = getObjectFieldsFromMapForSettings(sPrefix+'Product__c');
            
            for(SelectOption selectOptionGeneral : listGeneral) {
                listProductFields.add(new SelectOption(selectOptionGeneral.getValue() , selectOptionGeneral.getLabel()));
            }
            mapInvoiceITSettings.put('listProductFields',listProductFields);

            list<SelectOption> listProductFields1 = new list<SelectOption>();
            listGeneral = getObjectFieldsFromMapForSettings(sPrefix+'Product__c');
            
            for(SelectOption selectOptionGeneral : listGeneral) {
                listProductFields1.add(new SelectOption(selectOptionGeneral.getValue() , selectOptionGeneral.getLabel()));
            }
            mapInvoiceITSettings.put('listProductFields1',listProductFields1);

            list<SelectOption> listProductFields2 = new list<SelectOption>();
            listGeneral = getObjectFieldsFromMapForSettings(sPrefix+'Product__c');
            
            for(SelectOption selectOptionGeneral : listGeneral) {
                listProductFields2.add(new SelectOption(selectOptionGeneral.getValue() , selectOptionGeneral.getLabel()));
            }
            mapInvoiceITSettings.put('listProductFields2',listProductFields2);
            
            list<SelectOption> listProductBundleFields = new list<SelectOption>();
            listGeneral = getObjectFieldsFromMapForSettings(sPrefix+'Product_Bundle__c');
            for(SelectOption selectOptionGeneral : listGeneral) {
                listProductBundleFields.add(new SelectOption(selectOptionGeneral.getValue() , selectOptionGeneral.getLabel()));
            }
            mapInvoiceITSettings.put('listProductBundleFields',listProductBundleFields);
            
            list<SelectOption> listProductBundleFields1 = new list<SelectOption>();
            listGeneral = getObjectFieldsFromMapForSettings(sPrefix+'Product_Bundle__c');
            for(SelectOption selectOptionGeneral : listGeneral) {
                listProductBundleFields1.add(new SelectOption(selectOptionGeneral.getValue() , selectOptionGeneral.getLabel()));
            }
            mapInvoiceITSettings.put('listProductBundleFields1',listProductBundleFields1);
            
            list<SelectOption> listProductBundleFields2 = new list<SelectOption>();
            listGeneral = getObjectFieldsFromMapForSettings(sPrefix+'Product_Bundle__c');
            for(SelectOption selectOptionGeneral : listGeneral) {
                listProductBundleFields2.add(new SelectOption(selectOptionGeneral.getValue() , selectOptionGeneral.getLabel()));
            }
            mapInvoiceITSettings.put('listProductBundleFields2',listProductBundleFields2);

            list<SelectOption> listTaxCalculationBasedOn = new list<SelectOption>();
            listTaxCalculationBasedOn.add(new SelectOption( '' , '--None--'));
            listTaxCalculationBasedOn.add(new SelectOption('Account Billing Address' , 'Account Billing Address'));
            listTaxCalculationBasedOn.add(new SelectOption('Account Shipping Address' , 'Account Shipping Address'));
            listTaxCalculationBasedOn.add(new SelectOption('Billing Contact' , 'Billing Contact'));
            listTaxCalculationBasedOn.add(new SelectOption('Shipping Contact' , 'Shipping Contact'));
            mapInvoiceITSettings.put('listTaxCalculationBasedOn',listTaxCalculationBasedOn);

            //account default payment terms
            list<SelectOption> listDefaultPaymentTerms = new list<SelectOption>();
            //Added prefix by DL, INVOICEIT-663
            listDefaultPaymentTerms = gettingAllPicklistvalueofSobject('Account',sPrefix+'Payment_Terms__c');
            mapInvoiceITSettings.put('listDefaultPaymentTerms',listDefaultPaymentTerms);
            
            //house keeping batches 
            list<SelectOption> listBatchJobs = new list<SelectOption>();
            listBatchJobs.add(new SelectOption('Auto Renewals' , 'Auto Renewals'));
            listBatchJobs.add(new SelectOption('MRR Calculation' , 'MRR Calculation'));
            mapInvoiceITSettings.put('listBatchJobs',listBatchJobs);


            return mapInvoiceITSettings;
        }

        
        // @purpose : Method get picklist value of Sobject:Asish Behera
     
        public static list<SelectOption> gettingAllPicklistvalueofSobject(String aPI_Name_Of_SObject, String aPI_Name_Of_Field){
            list<SelectOption> listSobjectPicklistValues = new list<SelectOption>();
            Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
            Schema.SObjectType s = m.get(aPI_Name_Of_SObject) ;
            Schema.DescribeSObjectResult r = s.getDescribe() ;
            Map<String,Schema.SObjectField> fieldsMap = r.fields.getMap() ;
            //iteraing all the fields of sobject
            for(String field : fieldsMap.keyset()){
                if(field == aPI_Name_Of_Field){
                    Schema.DescribeFieldResult fieldResult3 = fieldsMap.get(field).getDescribe();   
                    list<Schema.PicklistEntry> ple3 = fieldResult3.getPicklistValues();
                    listSobjectPicklistValues.add(new SelectOption( '' , '--None--'));
                    for( Schema.PicklistEntry f : ple3){
                        listSobjectPicklistValues.add(new SelectOption(f.getValue(),f.getValue()));
                    }  
                    break;
                }
            }
            return  listSobjectPicklistValues;
        }

        /**
         *@purpose : Method get Opportunity and its child related information from custom settings
         *@Param : Sobject Name==Opportunity: @Return : map<String,list<SelectOption>>:Asish Behera
         **/


        public static map<String,list<SelectOption>>  gettingOpportunityMapping(){
            list<SelectOption> listOpportunityStage = new list<SelectOption>();

            list<SelectOption> listOpportunityCharges = new list<SelectOption>();
            list<SelectOption> listOpportunityCharges1 = new list<SelectOption>();
            String sfieldName = 'invoiceit_crmx__Status__c';
            String sObjectName = 'invoiceit_crmx__Opportunity_Rate_Plan_Charge__c';
            
            listOpportunityCharges = gettingAllPicklistvalueofSobject(sObjectName,sfieldName);
            listOpportunityCharges.add(new SelectOption( '' , '--None--'));
            mapInvoiceITSettings = new map<String,list<SelectOption>>();
            mapInvoiceITSettings.put('listOpportunityCharges',listOpportunityCharges);

            
            listOpportunityCharges1 = gettingAllPicklistvalueofSobject(sObjectName,sfieldName);
            listOpportunityCharges1.add(new SelectOption( '' , '--None--'));
            mapInvoiceITSettings.put('listOpportunityCharges1',listOpportunityCharges1);

            
            listOpportunityStage = gettingAllPicklistvalueofSobject('Opportunity','StageName');
            listOpportunityStage.add(new SelectOption( '' , '--None--'));
            mapInvoiceITSettings.put('listOpportunityStage',listOpportunityStage);

            return  mapInvoiceITSettings;
        }

        /**
         *@purpose : Method to check wheather extension package is installed or not
         *@Return : Boolean:By Asish Behera
         **/

        public Static Boolean checkingExtensionInstalled(){
            String sExtensionNameSpace = 'invoiceit_crmx';  
            Boolean isInstalled = false;
            try{
                if(UserInfo.isCurrentUserLicensed(sExtensionNameSpace)){
                    isInstalled = true; 
                }


            }catch(System.TypeException e){
                isInstalled = false;
                //Added by Shruthi:INVOICEIT-200
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,system.Label.InstallCRMextension);
                ApexPages.addMessage(myMsg); 
            }
            catch(Exception ex){
                isInstalled = false;

            }
            return isInstalled;
        }

        /**
         *@purpose : Method to check wheather extension package is installed or not referred in the constructor.we will only check and wont disply message
         *@Param : None,@Return:Boolean,By Asish Behera
         *this method called from constructor
         **/ 
        public Static Boolean IsOppInstalled(){
            String sExtensionNameSpace = 'invoiceit_crmx';  
            Boolean isInstalled;
            try{
                if(UserInfo.isCurrentUserLicensed(sExtensionNameSpace)){
                    isInstalled = true; 
                }
            }catch(System.TypeException e){
                isInstalled = false;
            }
            return isInstalled;
        }
    }