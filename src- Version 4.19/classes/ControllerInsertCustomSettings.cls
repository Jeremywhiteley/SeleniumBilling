public with sharing class ControllerInsertCustomSettings {


        public String sPrefix = CommonUtilClass.getPrefix();
        public void runPostInstallScript(){
            TestClassForHandlingAuthorizeDotNetCIM.installScript();
        }
        
        public void populateLoopDocs() {
        }
        
        List<SObject> objects = new List<SObject>();
        public PageReference insertValues() {
            populateConfigurations();
            populatePaymentTerms();
            insertCountryCodes();
                
            Configuration__c invoiceEmailTemplate = new Configuration__c(Name = 'INVOICE_EMAIL_TEMPLATE', String_Value__c = 'Enter Template Id', Field_Type__c = 'String', Description__c = 'Mention Email Template ID.',Picklist_Indicator__c ='listInvoiceTemplate',Category__c ='Invoice',Sequence__c = 1);
            Configuration__c quoteEmailTemplate = new Configuration__c(Name = 'QUOTE_EMAIL_TEMPLATE', String_Value__c = 'Enter Template Id', Field_Type__c = 'String', Description__c = 'Mention Email Template ID.',Picklist_Indicator__c ='listQuoteEmailTemplate',Category__c ='Quote',Sequence__c = 1);
            objects.add((SObject)quoteEmailTemplate);
            objects.add((SObject)invoiceEmailTemplate);
            
            Configuration__c companyLogo = new Configuration__c(Name = 'COMPANY_LOGO' ,String_Value__c = 'https://c.na12.content.force.com/servlet/servlet.ImageServer?id=015U00000000fGG&oid=00DU0000000HSiW', Field_Type__c = 'String', Description__c = 'Image location for Quote and Invoice templates.',Picklist_Indicator__c ='listCompanyLogo',Category__c ='Quote',Sequence__c = 3);                                                                 
            objects.add((SObject)companyLogo);
            objects.add((SObject)new Configuration__c(Name = 'PRODUCT_SEARCHFIELDS' ,String_Value__c = 'Name,'+sPrefix+'Product_Code__c', Field_Type__c = 'String', Description__c = 'Select Product fields to be searched in instant product search',Picklist_Indicator__c ='listProductFields',Category__c ='General',Quick_Screen_Id__c ='3',Sequence__c = 20));
            objects.add((SObject)new Configuration__c(Name = 'SUPPORT_PAGE_URL' ,String_Value__c = 'http://www.weinvoiceit.com/support/'));
            objects.add((SObject)new Configuration__c(Name = 'ORDER_STATUS_VALUES_TO_ROLLUP', STRING_VALUE__c = 'In Progress,Ready to be Invoiced,Invoiced', Field_Type__c = 'String', Description__c = 'Select status to be picked up for roll-up sum at account/oppurtunity level.',Picklist_Indicator__c ='listOrderStatusfields1',Category__c ='Order',Quick_Screen_Id__c ='4',Sequence__c = 8));
            objects.add((SObject)new Configuration__c(Name = 'QUOTE_STATUS_VALUES_TO_ROLLUP', STRING_VALUE__c = 'Active,Converted', Field_Type__c = 'String', Description__c = 'Select status to be picked up for roll-up sum at account/oppurtunity level.',Picklist_Indicator__c ='listQuoteStatusfields1',Category__c ='Quote',Quick_Screen_Id__c ='4',Sequence__c = 6));
            objects.add((SObject)new Configuration__c(Name = 'UPDATE_AMOUNT_FIELD_IN_OPPORTUNITY', Field_Type__c = 'Boolean', Description__c = 'Should Amount field on opportunities be updated with total quote value?',Category__c ='Opportunity',Quick_Screen_Id__c ='5',Sequence__c = 2));
                
            map<string,Configuration__c> mapOfConfigurationValuesToInserted = new  map<string,Configuration__c>();
            map<string,Payment_Terms__c> mapOfPaymentTermValuesToInserted = new  map<string,Payment_Terms__c>();

            for(SObject sobjectVar : objects) {
                if(string.valueOf(sobjectVar.getSObjectType()) == sPrefix+'Configuration__c') {
                    Configuration__c configuration = (Configuration__c)sobjectVar;
                    mapOfConfigurationValuesToInserted.put(configuration.Name,configuration);
                } if(string.valueOf(sobjectVar.getSObjectType()) == sPrefix+'Payment_Terms__c') {
                    Payment_Terms__c paymentTerm = (Payment_Terms__c)sobjectVar;
                    mapOfPaymentTermValuesToInserted.put(paymentTerm.Name,paymentTerm);
                }
            }

            map<string,Configuration__c> mapOfclientConfigurationValues = Configuration__c.getAll();
            map<string,Payment_Terms__c> mapOfclientPaymentTermValues = Payment_Terms__c.getAll();
                
            //here we are checking against client configuration values,if match is found remove from the map mapOfConfigurationValuesToInserted
            for(string mainString : mapOfclientConfigurationValues.keySet()) {
                if(mapOfConfigurationValuesToInserted.containsKey(mainString)) {
                    //assign the orginal description
                    mapOfclientConfigurationValues.get(mainString).Description__c = mapOfConfigurationValuesToInserted.get(mainString).Description__c;
                    
                    // assign the categories values for anil
                    
                    mapOfclientConfigurationValues.get(mainString).Category__c = mapOfConfigurationValuesToInserted.get(mainString).Category__c;
                    mapOfclientConfigurationValues.get(mainString).Picklist_Indicator__c = mapOfConfigurationValuesToInserted.get(mainString).Picklist_Indicator__c;
                    mapOfclientConfigurationValues.get(mainString).Quick_Screen_Id__c = mapOfConfigurationValuesToInserted.get(mainString).Quick_Screen_Id__c;
                    mapOfclientConfigurationValues.get(mainString).Sequence__c = mapOfConfigurationValuesToInserted.get(mainString).Sequence__c;
                    
                    //By Dev Relates for Version 30 Changes
                    if(mapOfclientConfigurationValues.get(mainString).Name == 'PRODUCT_OBJECTNAME') {
                        mapOfclientConfigurationValues.get(mainString).String_Value__c = sPrefix+'Product__c';
                    }
                    
                    //remove the configuration
                    mapOfConfigurationValuesToInserted.remove(mainString);
                }
            }
                
            //here we are checking against client configuration values,if match is found remove from the map mapOfPaymentTermValuesToInserted
            for(string mainString : mapOfclientPaymentTermValues.keySet()) {
                if(mapOfPaymentTermValuesToInserted.containsKey(mainString)) {
                    mapOfPaymentTermValuesToInserted.remove(mainString);
                }
            }
                
            //this will insert the only custom settings which are not present in client
            insert mapOfConfigurationValuesToInserted.Values();
            
            //this will update the custom settings which are present in client(only description is updated, but values are not changed)
            update mapOfclientConfigurationValues.Values();
            
            //this will insert the only custom settings which are not present in client
            insert mapOfPaymentTermValuesToInserted.Values();
            
            //this will update the customMapping records category, if the category values are null
            
            list<Custom_Mappings__c> listofCustomMappingToUpdate = new list<Custom_Mappings__c>();
            list<Custom_Mappings__c> listofCustomMapping = Custom_Mappings__c.getAll().values();
            
            if(!listofCustomMapping.isEmpty()) {
                for(Custom_Mappings__c customMapping : listofCustomMapping) {
                
                    if(customMapping.Category__c == null || customMapping.Category__c == '') {
                        if(customMapping.Source_Object__c.containsIgnoreCase('Quote') ) {
                            customMapping.Category__c = 'Quote2Order';
                        } else if(customMapping.Source_Object__c.containsIgnoreCase('Opportunity') && customMapping.Destination_Object__c.containsIgnoreCase('Job')) {
                            customMapping.Category__c = 'Opp2Order';
                        } else if(customMapping.Source_Object__c.containsIgnoreCase('Opportunity') && customMapping.Destination_Object__c.containsIgnoreCase('Quote')) {
                            customMapping.Category__c = 'Opp2Quote';
                        } else {
                            customMapping.Category__c = 'General';
                        } 
                        listofCustomMappingToUpdate.add(customMapping);
                    }
                }
                if(!listofCustomMappingToUpdate.isEmpty()) {
                    update listofCustomMappingToUpdate;
                }
            }
            return null;
        }
        
        public void populateConfigurations() {
            // Last Modify by Naveen M 24-Mar for realted changes in new setup page
            Configuration__c c1 =  new Configuration__c(Name = 'QUOTE_PAGE_3', STRING_VALUE__C = 'createquotestep3'); 
            Configuration__c c2 =  new Configuration__c(Name = 'QUOTE_PAGE_2', STRING_VALUE__C = 'createquotestep2'); 
            Configuration__c c3 =  new Configuration__c(Name = 'PRODUCT_OBJECTNAME', STRING_VALUE__C = sPrefix+'Product__c', Description__c = 'The name of the object that has to be searched for ');
            Configuration__c c4 =  new Configuration__c(Name = 'NO_OF_DECIMALS_FOR_CURRENCY_VALUES', NUMBER_VALUE__C = 3, Field_Type__c = 'Number', Description__c = 'Set # decimal points for currency to round it off .',Category__c ='General',Sequence__c = 7);
            Configuration__c c5 =  new Configuration__c(Name = 'CALCULATION_PRECISION', Field_Type__c = 'String', Description__c = 'Mention ROUND_UP to change 46.70 to 47, ROUND_DOWN to make it 46 and leave it BLANK for no change.',Picklist_Indicator__c ='listCalculatePrecision',Category__c ='Quote',Sequence__c = 7);
            Configuration__c c6 =  new Configuration__c(Name = 'PRODUCT_SEARCH_LIMIT', NUMBER_VALUE__C = 20, Field_Type__c = 'Number', Description__c = 'Set MAX # products to be returned in instant search.',Category__c ='General',Quick_Screen_Id__c ='3',Sequence__c = 8);
            Configuration__c c7 =  new Configuration__c(Name = 'PRODUCT_ORDERFIELD', STRING_VALUE__C = 'Name', Field_Type__c = 'String', Description__c = 'Set order of Product fields to be displayed in instant product search ',Picklist_Indicator__c ='listProductFields1',Category__c ='General',Quick_Screen_Id__c ='3',Sequence__c = 9);
            Configuration__c c8 =  new Configuration__c(Name = 'TYPE_OF_PACKAGE', STRING_VALUE__C = 'STANDALONE');
            Configuration__c c9 =  new Configuration__c(Name = 'PRODUCT_DISPLAYFIELDS', Field_Type__c = 'String', Description__c = 'Select Product fields to be displayed in instant product search',Picklist_Indicator__c ='listProductFields2',Category__c ='General',Quick_Screen_Id__c ='3',Sequence__c = 21);
            Configuration__c c10 = new Configuration__c(Name = 'INVOICE_GROUP_CRITERIA', STRING_VALUE__C = 'ONE_INVOICE_PER_ORDER', Field_Type__c = 'String', Description__c = 'Set the Invoice Grouping criteria',Picklist_Indicator__c ='listInvoiceGeneration',Category__c ='Invoice',Quick_Screen_Id__c ='4',Sequence__c = 7);
            Configuration__c c11 = new Configuration__c(Name = 'ORDER_PAGE_3', STRING_VALUE__C = 'createjobstep3');
            Configuration__c c12 = new Configuration__c(Name = 'ORDER_STATUS_FOR_INVOICING', Field_Type__c = 'String', Description__c = 'Select status of the order to be picked up for invoicing.',Picklist_Indicator__c ='listOrderStatusfields',Category__c ='Order',Quick_Screen_Id__c ='4',Sequence__c = 6);
            /* commented by Asish
             * DEFAULT_CURRENCY is areday created from PostInstallation class so please don't uncomment this line.
            */
            Configuration__c c14 = new Configuration__c(Name = 'QUOTE_VALIDITY_PERIOD', NUMBER_VALUE__C = 15, Field_Type__c = 'Number', Description__c = 'Set the default # of days the quote will be valid for',Category__c ='Quote',Quick_Screen_Id__c ='4',Sequence__c = 2);
            Configuration__c c15 = new Configuration__c(Name = 'ORDER_PAGE_2', STRING_VALUE__C = 'createjobstep2');
            Configuration__c c16 = new Configuration__c(Name = 'CHARGE_STATUS_FOR_INVOICING', Field_Type__c = 'String', Description__c = 'Select status of the line item to be picked up for invocing.',Picklist_Indicator__c ='listORPCStatus' ,Category__c ='Order', Quick_Screen_Id__c ='4',Sequence__c = 7);
            Configuration__c c17 = new Configuration__c(Name = 'INVOICE_NO_OF_DAYS_TILL_DUE_DATE', NUMBER_VALUE__C = 15, Field_Type__c = 'Number', Description__c = 'Set # days for Invoice to be due from the invoice date.',Category__c ='Invoice',Sequence__c = 4);
            Configuration__c c18 = new Configuration__c(Name = 'TAX_CALCULATION_BASED_ON', STRING_VALUE__C = 'Account Billing Address', Field_Type__c = 'String', Description__c = 'VAT / Tax calculation is based on?',Picklist_Indicator__c ='listTaxCalculationBasedOn',Category__c ='General',Quick_Screen_Id__c ='3',Sequence__c = 15);
            Configuration__c c19 = new Configuration__c(Name = 'USE_SERVICE_START_DATE_FOR_INVOICE', Field_Type__c = 'Boolean', Description__c = 'Align the Order service start date to Order date. Leave this as off if normally your Order service start dates are different to the order date', Boolean_Value__c = True,Category__c ='Order',Quick_Screen_Id__c ='4',Sequence__c = 2);
            Configuration__c c20 = new Configuration__c(Name = 'DISCOUNT_BY_VALUE_OR_PERCENTAGE', Field_Type__c = 'String', Description__c = 'Discount(s) should be enabled by?', STRING_VALUE__C = 'APPLY_DISCOUNT_BY_PERCENTAGE',Picklist_Indicator__c ='listApplyDiscounts',Category__c ='General',Quick_Screen_Id__c ='3',Sequence__c = 14);
            Configuration__c c21 = new Configuration__c(Name = 'AUTOMATE_PAYMENT_ALLOCATION', Field_Type__c = 'Boolean', Description__c = 'Allocate payments to pending invoices.', Boolean_Value__c = False,Category__c ='Invoice',Quick_Screen_Id__c ='4',Sequence__c = 5);
            Configuration__c c22 = new Configuration__c(Name = 'ORDER_DISCOUNT_CODE_FIELD', Field_Type__c = 'String', Description__c = 'Select Order field that holds the Discount Code', STRING_VALUE__C = 'Discount_Code__c',Picklist_Indicator__c = 'listOrderFieldsForDiscountCode' , Category__c ='Order',Sequence__c = 4);
            Configuration__c c23 = new Configuration__c(Name = 'QUOTE_DISCOUNT_CODE_FIELD', Field_Type__c = 'String', Description__c = 'Select Quote field that holds the Discount Code', STRING_VALUE__C = 'Discount_Code__c',Picklist_Indicator__c ='listQuoteFieldsForDiscountCode',Category__c ='Quote',Sequence__c = 4);
            Configuration__c c24 = new Configuration__c(Name = 'DEFAULT_PAYMENT_TERMS', Field_Type__c = 'String', STRING_VALUE__C = 'Due On Receipt', Description__c = 'Set default Payment Terms for your company',Picklist_Indicator__c ='listDefaultPaymentTerms',Category__c ='General',Quick_Screen_Id__c ='3',Sequence__c = 18);
            Configuration__c c25 = new Configuration__c(Name = 'ALIGN_DATES_OF_ORDER_TO_PRODUCTS', Description__c = 'Should service start date of line item align with Order service start date?', Field_Type__c = 'Boolean', Boolean_Value__c = True,Category__c ='Order',Quick_Screen_Id__c ='4',Sequence__c = 3);
            Configuration__c c26 = new Configuration__c(Name = 'CAN_REFUND_CHARGES_DURING_ADJUSTMENTS', Field_Type__c = 'Boolean', Description__c = 'Refund services that are paid but cancelled during Mid-Term.', Boolean_Value__c = False,Category__c ='Invoice',Quick_Screen_Id__c ='4',Sequence__c = 11);
            /*
                    Modified By              : Anil Pinto     :14 June 2013   :INVOICEIT-81
                    Comments               : changed the description as asked by Chris
            */
            Configuration__c c27 = new Configuration__c(Name = 'DEFAULT_QUANTITY_IN_WIZARDS', Field_Type__c = 'Number', Description__c = 'Set global default quantity of product line items if not specified in catalogue', NUMBER_VALUE__C = 1,Category__c ='General',Sequence__c = 11);
            // below are used in CRM Ext package
            Configuration__c c28 = new Configuration__c(Name = 'IS_ORDER_FROM_CLOSED_WON_OPP', Field_Type__c = 'Boolean', Description__c = 'Generate Order when Opportunity is set to Closed Won', Boolean_Value__c = True,Category__c ='Opportunity',Quick_Screen_Id__c ='5',Sequence__c = 1);
            Configuration__c c29 = new Configuration__c(Name = 'POPULATE_OPPORTUNITY_AMOUNT_FROM', Field_Type__c = 'String', Description__c = 'Opportunity "Amount" field should be automatically populated with?', STRING_VALUE__C = 'NETTOTAL',Picklist_Indicator__c ='listProductValueToRollUp',Category__c ='Opportunity',Quick_Screen_Id__c ='5',Sequence__c = 3);
            Configuration__c c30 = new Configuration__c(Name = 'OPPLINE_STATUS_FOR_ORDER_CONVERSION', Field_Type__c = 'String', Description__c = 'Define the status of the Opportunity line items that determines whether they should be selected for auto-conversion into an Order', STRING_VALUE__C ='Active',Picklist_Indicator__c ='listOpportunityCharges1',Category__c ='Opportunity',Quick_Screen_Id__c ='5',Sequence__c = 5);
            Configuration__c c31 = new Configuration__c(Name = 'OPPLINE_STATUS_AFTER_ORDER_CONVERSION', Field_Type__c = 'String', Description__c = 'What should be the status of opportunity lines after they are converted to order lines', STRING_VALUE__C ='Converted',Picklist_Indicator__c ='listOpportunityCharges',Category__c ='Opportunity',Quick_Screen_Id__c ='5',Sequence__c = 6);  
            // below are used from 1.17
            Configuration__c c32 = new Configuration__c(Name = 'QUOTE_LEGAL_ENTITY_FIELD_NAME', Field_Type__c = 'String', Description__c = 'Select Quote field that holds the Legal Entity (This will override the Account Legal Entity field)',Picklist_Indicator__c ='listQuoteFields',Category__c ='Quote',Sequence__c = 5);
            Configuration__c c33 = new Configuration__c(Name = 'ORDER_LEGAL_ENTITY_FIELD_NAME', Field_Type__c = 'String', Description__c = 'Select Order field that holds the Legal Entity (This will override the Account Legal Entity field)',Picklist_Indicator__c ='listOrderFields',Category__c ='Order',Sequence__c = 5);
            Configuration__c c34 = new Configuration__c(Name = 'ACCOUNT_LEGAL_ENTITY_FIELD_NAME', Field_Type__c = 'String', Description__c = 'Select Account field that holds the legal entity information',Picklist_Indicator__c ='listAccountFields',Category__c ='General',Sequence__c = 19);
            // below are used from 2.5
            Configuration__c c35 = new Configuration__c(Name = 'SAVE_CREDIT_CARD_ON_PAYMENT_PAGE', Field_Type__c = 'Boolean', Description__c = 'Prompt to save Credit Card information in Payment page.',Category__c ='Invoice',Sequence__c = 9);
            //below are used from 2.7
            Configuration__c C36 = new Configuration__c(Name = 'INVOICE_RUN_BATCH_SIZE', Field_Type__c = 'Number', Description__c = 'Set # of records to be processed in batch run', NUMBER_VALUE__C = 10,Category__c ='Invoice',Sequence__c = 3);
            //below are used from 2.9
            Configuration__c c37 = new Configuration__c(Name = 'BILL_ONETIME_CHARGES_BASED_ON_DATES', Field_Type__c = 'Boolean', Description__c = 'Bill one-time charges on OR after the Service Start Date?', Boolean_Value__c = false,Category__c ='Invoice',Sequence__c = 10);
            //below are used from 2.11
            Configuration__c c38 = new Configuration__c(Name = 'CLONEED_OPPORTUNITY_STAGE', Field_Type__c = 'String', Description__c = 'Select stage of opportunity when it is cloned.',Picklist_Indicator__c ='listOpportunityStage',Category__c ='Opportunity',Quick_Screen_Id__c ='5',Sequence__c = 4);
            //below are used from 2.13
            Configuration__c c39 = new Configuration__c(Name = 'INVOICE_TO_BE_CHARGED_ON', Field_Type__c = 'String', Description__c = 'Payment Scheduler to pickup unpaid invoices on OR after.',Category__c ='Invoice',Quick_Screen_Id__c ='4',Sequence__c = 8,Picklist_Indicator__c = 'listPaymentSchedulerDates');
            //below are used from 2.16
            Configuration__c c40 = new Configuration__c(Name = 'DEFAULT_PAYMENT_TERMS_TO_BE_USED_FROM', Field_Type__c = 'String', Description__c = 'Should payment terms override global payment terms on?', STRING_VALUE__C = 'ACCOUNT',Picklist_Indicator__c ='listPaymentTerms',Category__c ='General',Quick_Screen_Id__c ='3',Sequence__c = 16);
            /*
                    Modified By     : RamaKrishna V      :08 July 2013   :INVOICEIT-212/194
            */

            Configuration__c c42 = new Configuration__c(Name = 'AUTOMATIC_ALLOCATEDTOFUTURE_INVOICES', Field_Type__c = 'Boolean', Description__c = 'Allocate excess payments to invoices automatically.', Boolean_Value__c = false,Category__c ='Invoice',Quick_Screen_Id__c ='4',Sequence__c = 6);
            /*
                    Modified By     : Devender M     :03 Sept 2013     :INVOICEIT-228/SUP-72
            */
            Configuration__c c43 = new Configuration__c(Name = 'MANUAL_INVOICE_GENERATION_STATUS', Field_Type__c = 'String', Description__c = 'Set the default status for Invoices when generated manually', STRING_VALUE__C = 'Draft',Picklist_Indicator__c ='listInvoiceStatus',Category__c ='Invoice',Quick_Screen_Id__c ='4',Sequence__c = 2);
            Configuration__c c44 = new Configuration__c(Name = 'NAVIGATION_FOR_PRODUCTRATEPLAN', Field_Type__c = 'Number', Description__c = 'Select # Rate Plans to be displayed on Invoice IT Product page as default', NUMBER_VALUE__C = 40,Category__c ='General',Sequence__c = 24);
            Configuration__c c45 = new Configuration__c(Name = 'NAVIGATION_FOR_PRODUCTCHARGE', Field_Type__c = 'Number', Description__c = 'Set # Rate Plan Charges to be displayed on Invoice IT Product page as default.', NUMBER_VALUE__C = 40,Category__c ='General',Sequence__c = 25);
            /*
                    Modified By             : RamaKrishna V    :4-4-104   :INVOICEIT-320
                    Comments             : added below two custom settings
            */
            Configuration__c c46 = new Configuration__c(Name = 'CHARGENAME_TEXTBOX_WIDTH', Field_Type__c = 'String', Description__c = 'Set width of Charge Name text box while creating quote,order and opportunity Products (ex :- width:200px)', STRING_VALUE__C = 'width:150px',Picklist_Indicator__c ='listChargeNameWidth',Category__c ='General',Sequence__c = 13);
            Configuration__c c47 = new Configuration__c(Name = 'PRODUCTNAME_TEXTBOX_WIDTH', Field_Type__c = 'String', Description__c = 'Set width of Product Name text box while creating quote,order and opportunity Products (ex :- width:200px)', STRING_VALUE__C = 'width:150px',Picklist_Indicator__c ='listProductNameWidth',Category__c ='General',Sequence__c = 12);
            Configuration__c c48 = new Configuration__c(Name = 'INVOICEIT_HOME_POPUP' ,Boolean_Value__c = false, Field_Type__c = 'Boolean', Description__c = 'This is for Invoice IT home Pop up');
            Configuration__c c49 = new Configuration__c(Name = 'DISPLAY_PRODUCT_CHARGE_POP_UP' ,Boolean_Value__c = false, Field_Type__c = 'Boolean', Description__c = 'Enhanced advance Product Charge selection in the wizards',Category__c ='General',Quick_Screen_Id__c ='3',Sequence__c = 16);
            Configuration__c c50 = new Configuration__c(Name = 'DISPLAY_PRODUCT_RELATED_LIST' ,Boolean_Value__c = false, Field_Type__c = 'Boolean', Description__c = 'This is for displaying product realted list(New Product Page)');
            // Realtes to product bundle
            Configuration__c c51 = new Configuration__c(Name = 'DISPLAY_PRODUCT_BUNDLES_SEARCH' ,Boolean_Value__c = false, Field_Type__c = 'Boolean', Description__c = 'Enable Product Bundle search option in wizards',Category__c ='General',Quick_Screen_Id__c ='3',Sequence__c = 1);
            Configuration__c c52 = new Configuration__c(Name = 'PRODUCTBUNDLE_SEARCHFIELDS' ,String_Value__c = 'Name', Field_Type__c = 'String', Description__c = 'Select Product Bundle fields to be searched in instant product bundle search',Picklist_Indicator__c ='listProductBundleFields',Category__c ='General',Sequence__c = 22);
            Configuration__c c53 = new Configuration__c(Name = 'PRODUCTBUNDLE_ORDERFIELD', String_Value__c = 'Name', Field_Type__c = 'String', Description__c = 'Set order of Product Bundle fields to be displayed in instant product bundle search.',Picklist_Indicator__c ='listProductBundleFields2',Category__c ='General',Sequence__c = 10);
            Configuration__c c54 = new Configuration__c(Name = 'PRODUCTBUNDLE_DISPLAYFIELDS', String_Value__c = '', Field_Type__c = 'String', Description__c = 'Select Product Bundle fields to be displayed in instant product bundle search.',Picklist_Indicator__c ='listProductBundleFields1',Category__c ='General',Sequence__c = 23);
            Configuration__c c55 = new Configuration__c(Name = 'ENABLE_STATE_AND_COUNTRY_PICKLIST' ,Boolean_Value__c = false, Field_Type__c = 'Boolean', Description__c = 'Enable state and country picklist in Site Page and Virtual Terminal(works when state and country feature is enabled in Salesforce).',Category__c ='General',Quick_Screen_Id__c ='3',Sequence__c = 2);
            // INVOICEIT-395 added by Naveen M
            Configuration__c c56 = new Configuration__c(Name = 'NO_OF_DAYS_FOR_AUTO_RENEWAL' ,Field_Type__c = 'Number', Description__c = 'Set # days for auto renewal of Order before expiry.',Category__c ='Order',Sequence__c = 1, Number_Value__c = 30);
            // INVOICEIT-399 added by Shruthi Bomma
            Configuration__c c57 = new Configuration__c(Name = 'INVOICEIT_BATCH_JOBS_TO_PROCESS', STRING_VALUE__C = '', Field_Type__c = 'String', Description__c = 'Select Invoice IT housekeeping tasks to be processed daily',Picklist_Indicator__c ='listBatchJobs',Category__c ='General',Sequence__c = 17);
            Configuration__c c58 = new Configuration__c(Name = 'DISPLAY_DISCOUNT', Boolean_Value__c = true, Field_Type__c = 'Boolean', Description__c = 'Show Discount in Quote/Order/Opportunity Wizard', Category__c ='General',Sequence__c = 6);
            Configuration__c c59 = new Configuration__c(Name = 'DISPLAY_TAX', Boolean_Value__c = true, Field_Type__c = 'Boolean', Description__c = 'Show TAX in Quote/Order/Opportunity Wizard', Category__c ='General',Sequence__c = 4);
            Configuration__c c60 = new Configuration__c(Name = 'DISPLAY_VAT', Boolean_Value__c = true, Field_Type__c = 'Boolean', Description__c = 'Show VAT in Quote/Order/Opportunity Wizard', Category__c ='General',Sequence__c = 5);
            
            /*
                    Modified By             : RamaKrishna V         :10-11-2015           :INVOICEIT-624
                    Comments              : added below two custom settings
            */
            Configuration__c c61 = new Configuration__c(Name = 'PAYMENT_NO_OF_DAYS_BETWEEN_RETRIES', NUMBER_VALUE__C = 3, Field_Type__c = 'Number', Description__c = ' Number of days between retries for failed credit card / ACH transactions', Category__c ='Invoice',Sequence__c = 21);
            Configuration__c c62 = new Configuration__c(Name = 'PAYMENT_NO_OF_RETRIES', NUMBER_VALUE__C = 3, Field_Type__c = 'Number', Description__c = 'Number of times to retry failed credit card / ACH transactions', Category__c ='Invoice',Sequence__c = 20);
            // Added by Dev M INVOICEIT-617
            Configuration__c c63 = new Configuration__c(Name = 'ORDER_PAGE_1', STRING_VALUE__C = 'createjobstep1');
            
            objects.add((Configuration__c) c1);
            objects.add((Configuration__c) c2);
            objects.add((Configuration__c) c3);
            objects.add((Configuration__c) c4);
            objects.add((Configuration__c) c5);
            objects.add((Configuration__c) c6);
            objects.add((Configuration__c) c7);
            objects.add((Configuration__c) c8);
            objects.add((Configuration__c) c9);
            objects.add((Configuration__c) c10);
            objects.add((Configuration__c) c11);
            objects.add((Configuration__c) c12);
            //objects.add((Configuration__c) c13);
            objects.add((Configuration__c) c14);
            objects.add((Configuration__c) c15);
            objects.add((Configuration__c) c16);
            objects.add((Configuration__c) c17);
            objects.add((Configuration__c) c18);
            objects.add((Configuration__c) c19);
            objects.add((Configuration__c) c20);
            objects.add((Configuration__c) c21);
            objects.add((Configuration__c) c22);
            objects.add((Configuration__c) c23);
            objects.add((Configuration__c) c24);
            objects.add((Configuration__c) c25);
            objects.add((Configuration__c) c26);
            objects.add((Configuration__c) c27);
            objects.add((Configuration__c) c28);
            objects.add((Configuration__c) c29);
            objects.add((Configuration__c) c30);
            objects.add((Configuration__c) c31);
            objects.add((Configuration__c) c32);
            objects.add((Configuration__c) c33);
            objects.add((Configuration__c) c34);
            objects.add((Configuration__c) c35);
            objects.add((Configuration__c) c36);
            objects.add((Configuration__c) c37);
            objects.add((Configuration__c) c38);
            objects.add((Configuration__c) c39);
            objects.add((Configuration__c) c40);
            //objects.add((Configuration__c) c41);
            objects.add((Configuration__c) c42);
            objects.add((Configuration__c) c43);
            objects.add((Configuration__c) c44);
            objects.add((Configuration__c) c45);
            /*
                    Modified By             : RamaKrishna V        :4-4-104    :INVOICEIT-320
                    Comments             : adding to list
            */
            objects.add((Configuration__c) c46);
            objects.add((Configuration__c) c47);
            objects.add((Configuration__c) c48);
            objects.add((Configuration__c) c49);
            objects.add((Configuration__c) c50);
            objects.add((Configuration__c) c51);
            objects.add((Configuration__c) c52);
            objects.add((Configuration__c) c53);
            objects.add((Configuration__c) c54);
            objects.add((Configuration__c) c55);
            objects.add((Configuration__c) c56);
            objects.add((Configuration__c) c57);
            objects.add((Configuration__c) c58);
            objects.add((Configuration__c) c59);
            objects.add((Configuration__c) c60);
            
            /*
                    Modified By         : RamaKrishna V   :10-11-2015  :INVOICEIT-624
                    Comments          : added below two custom settings
            */
            objects.add((Configuration__c) c61);
            objects.add((Configuration__c) c62);
            // Added by Dev M INVOICEIT-617
            objects.add((Configuration__c) c63);
        }
        
        public void populatePaymentTerms() {
            Payment_Terms__c p1 = new Payment_Terms__c(Name = 'Due On Receipt', Number_Of_Days__c = 0);
            Payment_Terms__c p2 = new Payment_Terms__c(Name = 'Net 30', Number_Of_Days__c = 30);
            Payment_Terms__c p3 = new Payment_Terms__c(Name = 'Net 45', Number_Of_Days__c = 45);
            Payment_Terms__c p4 = new Payment_Terms__c(Name = 'Net 60', Number_Of_Days__c = 60);
            
            objects.add((Payment_Terms__c) p1);
            objects.add((Payment_Terms__c) p2);
            objects.add((Payment_Terms__c) p3);
            objects.add((Payment_Terms__c) p4);
        }
        
        public void insertCountryCodes() {
            list<Country_Codes__c> listOfCountryCodes = new list<Country_Codes__c>();
            Country_Codes__c code1 = new Country_Codes__c(Country_Code__c = 'AD', Name = 'Andorra');
            Country_Codes__c code2 = new Country_Codes__c(Country_Code__c = 'AE', Name = 'United Arab Emirates');
            Country_Codes__c code3 = new Country_Codes__c(Country_Code__c = 'AF', Name = 'Afghanistan');
            Country_Codes__c code4 = new Country_Codes__c(Country_Code__c = 'AG', Name = 'Antigua and Barbuda');
            Country_Codes__c code5 = new Country_Codes__c(Country_Code__c = 'AI', Name = 'Anguilla');
            Country_Codes__c code6 = new Country_Codes__c(Country_Code__c = 'AL', Name = 'Albania');
            Country_Codes__c code7 = new Country_Codes__c(Country_Code__c = 'AM', Name = 'Armenia');
            Country_Codes__c code8 = new Country_Codes__c(Country_Code__c = 'AN', Name = 'Netherlands Antilles');
            Country_Codes__c code9 = new Country_Codes__c(Country_Code__c = 'AO', Name = 'Angola');
            Country_Codes__c code10 = new Country_Codes__c(Country_Code__c = 'AQ', Name = 'Antarctica');
            Country_Codes__c code11 = new Country_Codes__c(Country_Code__c = 'AR', Name = 'Argentina');
            Country_Codes__c code12 = new Country_Codes__c(Country_Code__c = 'ARPA', Name = 'Old style Arpanet');
            Country_Codes__c code13 = new Country_Codes__c(Country_Code__c = 'AS', Name = 'American Samoa');
            Country_Codes__c code14 = new Country_Codes__c(Country_Code__c = 'AT', Name = 'Austria');
            Country_Codes__c code15 = new Country_Codes__c(Country_Code__c = 'AU', Name = 'Australia');
            Country_Codes__c code16 = new Country_Codes__c(Country_Code__c = 'AW', Name = 'Aruba');
            Country_Codes__c code17 = new Country_Codes__c(Country_Code__c = 'AZ', Name = 'Azerbaidjan');
            Country_Codes__c code18 = new Country_Codes__c(Country_Code__c = 'BA', Name = 'Bosnia-Herzegovina');
            Country_Codes__c code19 = new Country_Codes__c(Country_Code__c = 'BB', Name = 'Barbados');
            Country_Codes__c code20 = new Country_Codes__c(Country_Code__c = 'BD', Name = 'Bangladesh');
            Country_Codes__c code21 = new Country_Codes__c(Country_Code__c = 'BE', Name = 'Belgium');
            Country_Codes__c code22 = new Country_Codes__c(Country_Code__c = 'BF', Name = 'BurkinaFaso');
            Country_Codes__c code23 = new Country_Codes__c(Country_Code__c = 'BG', Name = 'Bulgaria');
            Country_Codes__c code24 = new Country_Codes__c(Country_Code__c = 'BH', Name = 'Bahrain');
            Country_Codes__c code25 = new Country_Codes__c(Country_Code__c = 'BI', Name = 'Burundi');
            Country_Codes__c code26 = new Country_Codes__c(Country_Code__c = 'BJ', Name = 'Benin');
            Country_Codes__c code27 = new Country_Codes__c(Country_Code__c = 'BM', Name = 'Bermuda');
            Country_Codes__c code28 = new Country_Codes__c(Country_Code__c = 'BN', Name = 'Brunei Darussalam');
            Country_Codes__c code29 = new Country_Codes__c(Country_Code__c = 'BO', Name = 'Bolivia');
            Country_Codes__c code30 = new Country_Codes__c(Country_Code__c = 'BR', Name = 'Brazil');
            Country_Codes__c code31 = new Country_Codes__c(Country_Code__c = 'BS', Name = 'Bahamas');
            Country_Codes__c code32 = new Country_Codes__c(Country_Code__c = 'BT', Name = 'Bhutan');
            Country_Codes__c code33 = new Country_Codes__c(Country_Code__c = 'BV', Name = 'Bouvet Island');
            Country_Codes__c code34 = new Country_Codes__c(Country_Code__c = 'BW', Name = 'Botswana');
            Country_Codes__c code35 = new Country_Codes__c(Country_Code__c = 'BY', Name = 'Belarus');
            Country_Codes__c code36 = new Country_Codes__c(Country_Code__c = 'BZ', Name = 'Belize');
            Country_Codes__c code37 = new Country_Codes__c(Country_Code__c = 'CA', Name = 'Canada');
            Country_Codes__c code38 = new Country_Codes__c(Country_Code__c = 'CC', Name = 'Cocos(Keeling) Islands');
            Country_Codes__c code39 = new Country_Codes__c(Country_Code__c = 'CF', Name = 'Central African Republic');
            Country_Codes__c code40 = new Country_Codes__c(Country_Code__c = 'CG', Name = 'Congo');
            Country_Codes__c code41 = new Country_Codes__c(Country_Code__c = 'CH', Name = 'Switzerland');
            Country_Codes__c code42 = new Country_Codes__c(Country_Code__c = 'CI', Name = 'Ivory Coast(Cote D Ivoire)');
            Country_Codes__c code43 = new Country_Codes__c(Country_Code__c = 'CK', Name = 'Cook Islands');
            Country_Codes__c code44 = new Country_Codes__c(Country_Code__c = 'CL', Name = 'Chile');
            Country_Codes__c code45 = new Country_Codes__c(Country_Code__c = 'CM', Name = 'Cameroon');
            Country_Codes__c code46 = new Country_Codes__c(Country_Code__c = 'CN', Name = 'China');
            Country_Codes__c code47 = new Country_Codes__c(Country_Code__c = 'CO', Name = 'Colombia');
            Country_Codes__c code48 = new Country_Codes__c(Country_Code__c = 'COM', Name = 'Commercial');
            Country_Codes__c code49 = new Country_Codes__c(Country_Code__c = 'CR', Name = 'CostaRica');
            Country_Codes__c code50 = new Country_Codes__c(Country_Code__c = 'CS', Name = 'Former Czechoslovakia');
            Country_Codes__c code51 = new Country_Codes__c(Country_Code__c = 'CU', Name = 'Cuba');
            Country_Codes__c code52 = new Country_Codes__c(Country_Code__c = 'CV', Name = 'Cape Verde');
            Country_Codes__c code53 = new Country_Codes__c(Country_Code__c = 'CX', Name = 'Christmas Island');
            Country_Codes__c code54 = new Country_Codes__c(Country_Code__c = 'CY', Name = 'Cyprus');
            Country_Codes__c code55 = new Country_Codes__c(Country_Code__c = 'CZ', Name = 'Czech Republic');
            Country_Codes__c code56 = new Country_Codes__c(Country_Code__c = 'DE', Name = 'Germany');
            Country_Codes__c code57 = new Country_Codes__c(Country_Code__c = 'DJ', Name = 'Djibouti');
            Country_Codes__c code58 = new Country_Codes__c(Country_Code__c = 'DK', Name = 'Denmark');
            Country_Codes__c code59 = new Country_Codes__c(Country_Code__c = 'DM', Name = 'Dominica');
            Country_Codes__c code60 = new Country_Codes__c(Country_Code__c = 'DO', Name = 'Dominican Republic');
            Country_Codes__c code61 = new Country_Codes__c(Country_Code__c = 'DZ', Name = 'Algeria');
            Country_Codes__c code62 = new Country_Codes__c(Country_Code__c = 'EC', Name = 'Ecuador');
            Country_Codes__c code63 = new Country_Codes__c(Country_Code__c = 'EDU', Name = 'USA Educational');
            Country_Codes__c code64 = new Country_Codes__c(Country_Code__c = 'EE', Name = 'Estonia');
            Country_Codes__c code65 = new Country_Codes__c(Country_Code__c = 'EG', Name = 'Egypt');
            Country_Codes__c code66 = new Country_Codes__c(Country_Code__c = 'EH', Name = 'Western Sahara');
            Country_Codes__c code67 = new Country_Codes__c(Country_Code__c = 'ER', Name = 'Eritrea');
            Country_Codes__c code68 = new Country_Codes__c(Country_Code__c = 'ES', Name = 'Spain');
            Country_Codes__c code69 = new Country_Codes__c(Country_Code__c = 'ET', Name = 'Ethiopia');
            Country_Codes__c code70 = new Country_Codes__c(Country_Code__c = 'FI', Name = 'Finland');
            Country_Codes__c code71 = new Country_Codes__c(Country_Code__c = 'FJ', Name = 'Fiji');
            Country_Codes__c code72 = new Country_Codes__c(Country_Code__c = 'FK', Name = 'Falkland Islands');
            Country_Codes__c code73 = new Country_Codes__c(Country_Code__c = 'FM', Name = 'Micronesia');
            Country_Codes__c code74 = new Country_Codes__c(Country_Code__c = 'FO', Name = 'Faroe Islands');
            Country_Codes__c code75 = new Country_Codes__c(Country_Code__c = 'FR', Name = 'France');
            Country_Codes__c code76 = new Country_Codes__c(Country_Code__c = 'FX', Name = 'France(EuropeanTerritory)');
            Country_Codes__c code77 = new Country_Codes__c(Country_Code__c = 'ZW', Name = 'Zimbabwe');
            Country_Codes__c code78 = new Country_Codes__c(Country_Code__c = 'GA', Name = 'Gabon');
            Country_Codes__c code79 = new Country_Codes__c(Country_Code__c = 'GB', Name = 'Great Britain');
            Country_Codes__c code80 = new Country_Codes__c(Country_Code__c = 'GD', Name = 'Grenada');
            Country_Codes__c code81 = new Country_Codes__c(Country_Code__c = 'GE', Name = 'Georgia');
            Country_Codes__c code82 = new Country_Codes__c(Country_Code__c = 'GF', Name = 'French Guyana');
            Country_Codes__c code83 = new Country_Codes__c(Country_Code__c = 'GH', Name = 'Ghana');
            Country_Codes__c code84 = new Country_Codes__c(Country_Code__c = 'GI', Name = 'Gibraltar');
            Country_Codes__c code85 = new Country_Codes__c(Country_Code__c = 'GL', Name = 'Greenland');
            Country_Codes__c code86 = new Country_Codes__c(Country_Code__c = 'GM', Name = 'Gambia');
            Country_Codes__c code87 = new Country_Codes__c(Country_Code__c = 'GN', Name = 'Guinea');
            Country_Codes__c code88 = new Country_Codes__c(Country_Code__c = 'GOV', Name = 'USAGovernment');
            Country_Codes__c code89 = new Country_Codes__c(Country_Code__c = 'GP', Name = 'Guadeloupe(French)');
            Country_Codes__c code90 = new Country_Codes__c(Country_Code__c = 'GQ', Name = 'EquatorialGuinea');
            Country_Codes__c code91 = new Country_Codes__c(Country_Code__c = 'GR', Name = 'Greece');
            Country_Codes__c code92 = new Country_Codes__c(Country_Code__c = 'GS', Name = 'S.Georgia & S.SandwichIsls');
            Country_Codes__c code93 = new Country_Codes__c(Country_Code__c = 'GT', Name = 'Guatemala');
            Country_Codes__c code94 = new Country_Codes__c(Country_Code__c = 'GU', Name = 'Guam(USA)');
            Country_Codes__c code95 = new Country_Codes__c(Country_Code__c = 'GW', Name = 'Guinea Bissau');
            Country_Codes__c code96 = new Country_Codes__c(Country_Code__c = 'GY', Name = 'Guyana');
            Country_Codes__c code97 = new Country_Codes__c(Country_Code__c = 'HK', Name = 'Hong Kong');
            Country_Codes__c code98 = new Country_Codes__c(Country_Code__c = 'HM', Name = 'Heard and McDonald Islands');
            Country_Codes__c code99 = new Country_Codes__c(Country_Code__c = 'HN', Name = 'Honduras');
            Country_Codes__c code100 = new Country_Codes__c(Country_Code__c = 'HT', Name = 'Haiti');
            Country_Codes__c code101 = new Country_Codes__c(Country_Code__c = 'HU', Name = 'Hungary');
            Country_Codes__c code102 = new Country_Codes__c(Country_Code__c = 'ID', Name = 'Indonesia');
            Country_Codes__c code103 = new Country_Codes__c(Country_Code__c = 'IE', Name = 'Ireland');
            Country_Codes__c code104 = new Country_Codes__c(Country_Code__c = 'IL', Name = 'Israel');
            Country_Codes__c code105 = new Country_Codes__c(Country_Code__c = 'IN', Name = 'India');
            Country_Codes__c code106 = new Country_Codes__c(Country_Code__c = 'INT', Name = 'International');
            Country_Codes__c code107 = new Country_Codes__c(Country_Code__c = 'IO', Name = 'British Indian Ocean Territory');
            Country_Codes__c code108 = new Country_Codes__c(Country_Code__c = 'IQ', Name = 'Iraq');
            Country_Codes__c code109 = new Country_Codes__c(Country_Code__c = 'IR', Name = 'Iran');
            Country_Codes__c code110 = new Country_Codes__c(Country_Code__c = 'IS', Name = 'Iceland');
            Country_Codes__c code111 = new Country_Codes__c(Country_Code__c = 'IT', Name = 'Italy');
            Country_Codes__c code112 = new Country_Codes__c(Country_Code__c = 'JM', Name = 'Jamaica');
            Country_Codes__c code113 = new Country_Codes__c(Country_Code__c = 'JO', Name = 'Jordan');
            Country_Codes__c code114 = new Country_Codes__c(Country_Code__c = 'JP', Name = 'Japan');
            Country_Codes__c code115 = new Country_Codes__c(Country_Code__c = 'KE', Name = 'Kenya');
            Country_Codes__c code116 = new Country_Codes__c(Country_Code__c = 'KG', Name = 'Kyrgyzstan');
            Country_Codes__c code117 = new Country_Codes__c(Country_Code__c = 'KH', Name = 'Cambodia');
            Country_Codes__c code118 = new Country_Codes__c(Country_Code__c = 'KI', Name = 'Kiribati');
            Country_Codes__c code119 = new Country_Codes__c(Country_Code__c = 'KM', Name = 'Comoros');
            Country_Codes__c code120 = new Country_Codes__c(Country_Code__c = 'KN', Name = 'Saint Kitts & Nevis Anguilla');
            Country_Codes__c code121 = new Country_Codes__c(Country_Code__c = 'KP', Name = 'North Korea');
            Country_Codes__c code122 = new Country_Codes__c(Country_Code__c = 'KR', Name = 'South Korea');
            Country_Codes__c code123 = new Country_Codes__c(Country_Code__c = 'KW', Name = 'Kuwait');
            Country_Codes__c code124 = new Country_Codes__c(Country_Code__c = 'KY', Name = 'Cayman Islands');
            Country_Codes__c code125 = new Country_Codes__c(Country_Code__c = 'KZ', Name = 'Kazakhstan');
            Country_Codes__c code126 = new Country_Codes__c(Country_Code__c = 'LA', Name = 'Laos');
            Country_Codes__c code127 = new Country_Codes__c(Country_Code__c = 'LB', Name = 'Lebanon');
            Country_Codes__c code128 = new Country_Codes__c(Country_Code__c = 'LC', Name = 'Saint Lucia');
            Country_Codes__c code129 = new Country_Codes__c(Country_Code__c = 'LI', Name = 'Liechtenstein');
            Country_Codes__c code130 = new Country_Codes__c(Country_Code__c = 'LK', Name = 'Sri Lanka');
            Country_Codes__c code131 = new Country_Codes__c(Country_Code__c = 'LR', Name = 'Liberia');
            Country_Codes__c code132 = new Country_Codes__c(Country_Code__c = 'LS', Name = 'Lesotho');
            Country_Codes__c code133 = new Country_Codes__c(Country_Code__c = 'LT', Name = 'Lithuania');
            Country_Codes__c code134 = new Country_Codes__c(Country_Code__c = 'LU', Name = 'Luxembourg');
            Country_Codes__c code135 = new Country_Codes__c(Country_Code__c = 'LV', Name = 'Latvia');
            Country_Codes__c code136 = new Country_Codes__c(Country_Code__c = 'LY', Name = 'Libya');
            Country_Codes__c code137 = new Country_Codes__c(Country_Code__c = 'MA', Name = 'Morocco');
            Country_Codes__c code138 = new Country_Codes__c(Country_Code__c = 'MC', Name = 'Monaco');
            Country_Codes__c code139 = new Country_Codes__c(Country_Code__c = 'MD', Name = 'Moldavia');
            Country_Codes__c code140 = new Country_Codes__c(Country_Code__c = 'MG', Name = 'Madagascar');
            Country_Codes__c code141 = new Country_Codes__c(Country_Code__c = 'MH', Name = 'Marshall Islands');
            Country_Codes__c code142 = new Country_Codes__c(Country_Code__c = 'MIL', Name = 'USA Military');
            Country_Codes__c code143 = new Country_Codes__c(Country_Code__c = 'MK', Name = 'Macedonia');
            Country_Codes__c code144 = new Country_Codes__c(Country_Code__c = 'ML', Name = 'Mali');
            Country_Codes__c code145 = new Country_Codes__c(Country_Code__c = 'MM', Name = 'Myanmar');
            Country_Codes__c code146 = new Country_Codes__c(Country_Code__c = 'MN', Name = 'Mongolia');
            Country_Codes__c code147 = new Country_Codes__c(Country_Code__c = 'MO', Name = 'Macau');
            Country_Codes__c code148 = new Country_Codes__c(Country_Code__c = 'MP', Name = 'Northern Mariana Islands');
            Country_Codes__c code149 = new Country_Codes__c(Country_Code__c = 'MQ', Name = 'Martinique(French)');
            Country_Codes__c code150 = new Country_Codes__c(Country_Code__c = 'MR', Name = 'Mauritania');
            Country_Codes__c code151 = new Country_Codes__c(Country_Code__c = 'MS', Name = 'Montserrat');
            Country_Codes__c code152 = new Country_Codes__c(Country_Code__c = 'MT', Name = 'Malta');
            Country_Codes__c code153 = new Country_Codes__c(Country_Code__c = 'MU', Name = 'Mauritius');
            Country_Codes__c code154 = new Country_Codes__c(Country_Code__c = 'MV', Name = 'Maldives');
            Country_Codes__c code155 = new Country_Codes__c(Country_Code__c = 'MW', Name = 'Malawi');
            Country_Codes__c code156 = new Country_Codes__c(Country_Code__c = 'MX', Name = 'Mexico');
            Country_Codes__c code157 = new Country_Codes__c(Country_Code__c = 'MY', Name = 'Malaysia');
            Country_Codes__c code158 = new Country_Codes__c(Country_Code__c = 'MZ', Name = 'Mozambique');
            Country_Codes__c code159 = new Country_Codes__c(Country_Code__c = 'NA', Name = 'Namibia');
            Country_Codes__c code160 = new Country_Codes__c(Country_Code__c = 'NATO', Name = 'NATO');
            Country_Codes__c code161 = new Country_Codes__c(Country_Code__c = 'NC', Name = 'New Caledonia(French)');
            Country_Codes__c code162 = new Country_Codes__c(Country_Code__c = 'NE', Name = 'Niger');
            Country_Codes__c code163 = new Country_Codes__c(Country_Code__c = 'NET', Name = 'Network');
            Country_Codes__c code164 = new Country_Codes__c(Country_Code__c = 'NF', Name = 'Norfolk Island');
            Country_Codes__c code165 = new Country_Codes__c(Country_Code__c = 'NG', Name = 'Nigeria');
            Country_Codes__c code166 = new Country_Codes__c(Country_Code__c = 'NI', Name = 'Nicaragua');
            Country_Codes__c code167 = new Country_Codes__c(Country_Code__c = 'NL', Name = 'Netherlands');
            Country_Codes__c code168 = new Country_Codes__c(Country_Code__c = 'NO', Name = 'Norway');
            Country_Codes__c code169 = new Country_Codes__c(Country_Code__c = 'NP', Name = 'Nepal');
            Country_Codes__c code170 = new Country_Codes__c(Country_Code__c = 'NR', Name = 'Nauru');
            Country_Codes__c code171 = new Country_Codes__c(Country_Code__c = 'NT', Name = 'NeutralZone');
            Country_Codes__c code172 = new Country_Codes__c(Country_Code__c = 'NU', Name = 'Niue');
            Country_Codes__c code173 = new Country_Codes__c(Country_Code__c = 'NZ', Name = 'New Zealand');
            Country_Codes__c code174 = new Country_Codes__c(Country_Code__c = 'OM', Name = 'Oman');
            Country_Codes__c code175 = new Country_Codes__c(Country_Code__c = 'ORG', Name = 'Non-Profit Making Organisations');
            Country_Codes__c code176 = new Country_Codes__c(Country_Code__c = 'PA', Name = 'Panama');
            Country_Codes__c code177 = new Country_Codes__c(Country_Code__c = 'PE', Name = 'Peru');
            Country_Codes__c code178 = new Country_Codes__c(Country_Code__c = 'PF', Name = 'Polynesia(French)');
            Country_Codes__c code179 = new Country_Codes__c(Country_Code__c = 'PG', Name = 'Papua New Guinea');
            Country_Codes__c code180 = new Country_Codes__c(Country_Code__c = 'PH', Name = 'Philippines');
            Country_Codes__c code181 = new Country_Codes__c(Country_Code__c = 'PK', Name = 'Pakistan');
            Country_Codes__c code182 = new Country_Codes__c(Country_Code__c = 'PL', Name = 'Poland');
            Country_Codes__c code183 = new Country_Codes__c(Country_Code__c = 'PM', Name = 'Saint Pierre and Miquelon');
            Country_Codes__c code184 = new Country_Codes__c(Country_Code__c = 'PN', Name = 'Pitcairn Island');
            Country_Codes__c code185 = new Country_Codes__c(Country_Code__c = 'PR', Name = 'Puerto Rico');
            Country_Codes__c code186 = new Country_Codes__c(Country_Code__c = 'PT', Name = 'Portugal');
            Country_Codes__c code187 = new Country_Codes__c(Country_Code__c = 'PW', Name = 'Palau');
            Country_Codes__c code188 = new Country_Codes__c(Country_Code__c = 'PY', Name = 'Paraguay');
            Country_Codes__c code189 = new Country_Codes__c(Country_Code__c = 'QA', Name = 'Qatar');
            Country_Codes__c code190 = new Country_Codes__c(Country_Code__c = 'RE', Name = 'Reunion(French)');
            Country_Codes__c code191 = new Country_Codes__c(Country_Code__c = 'RO', Name = 'Romania');
            Country_Codes__c code192 = new Country_Codes__c(Country_Code__c = 'RU', Name = 'Russian Federation');
            Country_Codes__c code193 = new Country_Codes__c(Country_Code__c = 'RW', Name = 'Rwanda');
            Country_Codes__c code194 = new Country_Codes__c(Country_Code__c = 'SA', Name = 'Saudi Arabia');
            Country_Codes__c code195 = new Country_Codes__c(Country_Code__c = 'SB', Name = 'Solomon Islands');
            Country_Codes__c code196 = new Country_Codes__c(Country_Code__c = 'SC', Name = 'Seychelles');
            Country_Codes__c code197 = new Country_Codes__c(Country_Code__c = 'SD', Name = 'Sudan');
            Country_Codes__c code198 = new Country_Codes__c(Country_Code__c = 'SE', Name = 'Sweden');
            Country_Codes__c code199 = new Country_Codes__c(Country_Code__c = 'SG', Name = 'Singapore');
            Country_Codes__c code200 = new Country_Codes__c(Country_Code__c = 'SH', Name = 'Saint Helena');
            Country_Codes__c code201 = new Country_Codes__c(Country_Code__c = 'SI', Name = 'Slovenia');
            Country_Codes__c code202 = new Country_Codes__c(Country_Code__c = 'SJ', Name = 'Svalbard and Jan Mayen Islands');
            Country_Codes__c code203 = new Country_Codes__c(Country_Code__c = 'SK', Name = 'Slovak Republic');
            Country_Codes__c code204 = new Country_Codes__c(Country_Code__c = 'SL', Name = 'Sierra Leone');
            Country_Codes__c code205 = new Country_Codes__c(Country_Code__c = 'SM', Name = 'San Marino');
            Country_Codes__c code206 = new Country_Codes__c(Country_Code__c = 'SN', Name = 'Senegal');
            Country_Codes__c code207 = new Country_Codes__c(Country_Code__c = 'SO', Name = 'Somalia');
            Country_Codes__c code208 = new Country_Codes__c(Country_Code__c = 'SR', Name = 'Suriname');
            Country_Codes__c code209 = new Country_Codes__c(Country_Code__c = 'ST', Name = 'Saint Tome(Sao Tome) and Principe');
            Country_Codes__c code210 = new Country_Codes__c(Country_Code__c = 'SU', Name = 'Former USSR');
            Country_Codes__c code211 = new Country_Codes__c(Country_Code__c = 'SV', Name = 'El Salvador');
            Country_Codes__c code212 = new Country_Codes__c(Country_Code__c = 'SY', Name = 'Syria');
            Country_Codes__c code213 = new Country_Codes__c(Country_Code__c = 'SZ', Name = 'Swaziland');
            Country_Codes__c code214 = new Country_Codes__c(Country_Code__c = 'TC', Name = 'Turks and Caicos Islands');
            Country_Codes__c code215 = new Country_Codes__c(Country_Code__c = 'TD', Name = 'Chad');
            Country_Codes__c code216 = new Country_Codes__c(Country_Code__c = 'TF', Name = 'French Southern Territories');
            Country_Codes__c code217 = new Country_Codes__c(Country_Code__c = 'TG', Name = 'Togo');
            Country_Codes__c code218 = new Country_Codes__c(Country_Code__c = 'TH', Name = 'Thailand');
            Country_Codes__c code219 = new Country_Codes__c(Country_Code__c = 'TJ', Name = 'Tadjikistan');
            Country_Codes__c code220 = new Country_Codes__c(Country_Code__c = 'TK', Name = 'Tokelau');
            Country_Codes__c code221 = new Country_Codes__c(Country_Code__c = 'TM', Name = 'Turkmenistan');
            Country_Codes__c code222 = new Country_Codes__c(Country_Code__c = 'TN', Name = 'Tunisia');
            Country_Codes__c code223 = new Country_Codes__c(Country_Code__c = 'TO', Name = 'Tonga');
            Country_Codes__c code224 = new Country_Codes__c(Country_Code__c = 'TP', Name = 'EastTimor');
            Country_Codes__c code225 = new Country_Codes__c(Country_Code__c = 'TR', Name = 'Turkey');
            Country_Codes__c code226 = new Country_Codes__c(Country_Code__c = 'TT', Name = 'Trinidad and Tobago');
            Country_Codes__c code227 = new Country_Codes__c(Country_Code__c = 'TV', Name = 'Tuvalu');
            Country_Codes__c code228 = new Country_Codes__c(Country_Code__c = 'TW', Name = 'Taiwan');
            Country_Codes__c code229 = new Country_Codes__c(Country_Code__c = 'TZ', Name = 'Tanzania');
            Country_Codes__c code230 = new Country_Codes__c(Country_Code__c = 'UA', Name = 'Ukraine');
            Country_Codes__c code231 = new Country_Codes__c(Country_Code__c = 'UG', Name = 'Uganda');
            Country_Codes__c code232 = new Country_Codes__c(Country_Code__c = 'UK', Name = 'United Kingdom');
            Country_Codes__c code233 = new Country_Codes__c(Country_Code__c = 'UM', Name = 'USA Minor Outlying Islands');
            Country_Codes__c code234 = new Country_Codes__c(Country_Code__c = 'US', Name = 'United States');
            Country_Codes__c code235 = new Country_Codes__c(Country_Code__c = 'UY', Name = 'Uruguay');
            Country_Codes__c code236 = new Country_Codes__c(Country_Code__c = 'UZ', Name = 'Uzbekistan');
            Country_Codes__c code237 = new Country_Codes__c(Country_Code__c = 'VA', Name = 'Vatican City State');
            Country_Codes__c code238 = new Country_Codes__c(Country_Code__c = 'VC', Name = 'Saint Vincent & Grenadines');
            Country_Codes__c code239 = new Country_Codes__c(Country_Code__c = 'VE', Name = 'Venezuela');
            Country_Codes__c code240 = new Country_Codes__c(Country_Code__c = 'VG', Name = 'Virgin Islands(British)');
            Country_Codes__c code241 = new Country_Codes__c(Country_Code__c = 'VI', Name = 'Virgin Islands(USA)');
            Country_Codes__c code242 = new Country_Codes__c(Country_Code__c = 'VN', Name = 'Vietnam');
            Country_Codes__c code243 = new Country_Codes__c(Country_Code__c = 'VU', Name = 'Vanuatu');
            Country_Codes__c code244 = new Country_Codes__c(Country_Code__c = 'WF', Name = 'Wallis and FutunaIslands');
            Country_Codes__c code245 = new Country_Codes__c(Country_Code__c = 'WS', Name = 'Samoa');
            Country_Codes__c code246 = new Country_Codes__c(Country_Code__c = 'YE', Name = 'Yemen');
            Country_Codes__c code247 = new Country_Codes__c(Country_Code__c = 'YT', Name = 'Mayotte');
            Country_Codes__c code248 = new Country_Codes__c(Country_Code__c = 'YU', Name = 'Yugoslavia');
            Country_Codes__c code249 = new Country_Codes__c(Country_Code__c = 'ZA', Name = 'South Africa');
            Country_Codes__c code250 = new Country_Codes__c(Country_Code__c = 'ZM', Name = 'Zambia');
            Country_Codes__c code251 = new Country_Codes__c(Country_Code__c = 'ZR', Name = 'Zaire');
            Country_Codes__c code252 = new Country_Codes__c(Country_Code__c = 'HR', Name = 'Croatia');
            
            listOfCountryCodes.add( code1 );
            listOfCountryCodes.add( code2 );
            listOfCountryCodes.add( code3 );
            listOfCountryCodes.add( code4 );
            listOfCountryCodes.add( code5 );
            listOfCountryCodes.add( code6 );
            listOfCountryCodes.add( code7 );
            listOfCountryCodes.add( code8 );
            listOfCountryCodes.add( code9 );
            listOfCountryCodes.add( code10 );
            listOfCountryCodes.add( code11 );
            listOfCountryCodes.add( code12 );
            listOfCountryCodes.add( code13 );
            listOfCountryCodes.add( code14 );
            listOfCountryCodes.add( code15 );
            listOfCountryCodes.add( code16 );
            listOfCountryCodes.add( code17 );
            listOfCountryCodes.add( code18 );
            listOfCountryCodes.add( code19 );
            listOfCountryCodes.add( code20 );
            listOfCountryCodes.add( code21 );
            listOfCountryCodes.add( code22 );
            listOfCountryCodes.add( code23 );
            listOfCountryCodes.add( code24 );
            listOfCountryCodes.add( code25 );
            listOfCountryCodes.add( code26 );
            listOfCountryCodes.add( code27 );
            listOfCountryCodes.add( code28 );
            listOfCountryCodes.add( code29 );
            listOfCountryCodes.add( code30 );
            listOfCountryCodes.add( code31 );
            listOfCountryCodes.add( code32 );
            listOfCountryCodes.add( code33 );
            listOfCountryCodes.add( code34 );
            listOfCountryCodes.add( code35 );
            listOfCountryCodes.add( code36 );
            listOfCountryCodes.add( code37 );
            listOfCountryCodes.add( code38 );
            listOfCountryCodes.add( code39 );
            listOfCountryCodes.add( code40 );
            listOfCountryCodes.add( code41 );
            listOfCountryCodes.add( code42 );
            listOfCountryCodes.add( code43 );
            listOfCountryCodes.add( code44 );
            listOfCountryCodes.add( code45 );
            listOfCountryCodes.add( code46 );
            listOfCountryCodes.add( code47 );
            listOfCountryCodes.add( code48 );
            listOfCountryCodes.add( code49 );
            listOfCountryCodes.add( code50 );
            listOfCountryCodes.add( code51 );
            listOfCountryCodes.add( code52 );
            listOfCountryCodes.add( code53 );
            listOfCountryCodes.add( code54 );
            listOfCountryCodes.add( code55 );
            listOfCountryCodes.add( code56 );
            listOfCountryCodes.add( code57 );
            listOfCountryCodes.add( code58 );
            listOfCountryCodes.add( code59 );
            listOfCountryCodes.add( code60 );
            listOfCountryCodes.add( code61 );
            listOfCountryCodes.add( code62 );
            listOfCountryCodes.add( code63 );
            listOfCountryCodes.add( code64 );
            listOfCountryCodes.add( code65 );
            listOfCountryCodes.add( code66 );
            listOfCountryCodes.add( code67 );
            listOfCountryCodes.add( code68 );
            listOfCountryCodes.add( code69 );
            listOfCountryCodes.add( code70 );
            listOfCountryCodes.add( code71 );
            listOfCountryCodes.add( code72 );
            listOfCountryCodes.add( code73 );
            listOfCountryCodes.add( code74 );
            listOfCountryCodes.add( code75 );
            listOfCountryCodes.add( code76 );
            listOfCountryCodes.add( code77 );
            listOfCountryCodes.add( code78 );
            listOfCountryCodes.add( code79 );
            listOfCountryCodes.add( code80 );
            listOfCountryCodes.add( code81 );
            listOfCountryCodes.add( code82 );
            listOfCountryCodes.add( code83 );
            listOfCountryCodes.add( code84 );
            listOfCountryCodes.add( code85 );
            listOfCountryCodes.add( code86 );
            listOfCountryCodes.add( code87 );
            listOfCountryCodes.add( code88 );
            listOfCountryCodes.add( code89 );
            listOfCountryCodes.add( code90 );
            listOfCountryCodes.add( code91 );
            listOfCountryCodes.add( code92 );
            listOfCountryCodes.add( code93 );
            listOfCountryCodes.add( code94 );
            listOfCountryCodes.add( code95 );
            listOfCountryCodes.add( code96 );
            listOfCountryCodes.add( code97 );
            listOfCountryCodes.add( code98 );
            listOfCountryCodes.add( code99 );
            listOfCountryCodes.add( code100);
            listOfCountryCodes.add( code101);
            listOfCountryCodes.add( code102);
            listOfCountryCodes.add( code103);
            listOfCountryCodes.add( code104);
            listOfCountryCodes.add( code105);
            listOfCountryCodes.add( code106);
            listOfCountryCodes.add( code107);
            listOfCountryCodes.add( code108);
            listOfCountryCodes.add( code109);
            listOfCountryCodes.add( code110);
            listOfCountryCodes.add( code111);
            listOfCountryCodes.add( code112);
            listOfCountryCodes.add( code113);
            listOfCountryCodes.add( code114);
            listOfCountryCodes.add( code115);
            listOfCountryCodes.add( code116);
            listOfCountryCodes.add( code117);
            listOfCountryCodes.add( code118);
            listOfCountryCodes.add( code119);
            listOfCountryCodes.add( code120);
            listOfCountryCodes.add( code121);
            listOfCountryCodes.add( code122);
            listOfCountryCodes.add( code123);
            listOfCountryCodes.add( code124);
            listOfCountryCodes.add( code125);
            listOfCountryCodes.add( code126);
            listOfCountryCodes.add( code127);
            listOfCountryCodes.add( code128);
            listOfCountryCodes.add( code129);
            listOfCountryCodes.add( code130);
            listOfCountryCodes.add( code131);
            listOfCountryCodes.add( code132);
            listOfCountryCodes.add( code133);
            listOfCountryCodes.add( code134);
            listOfCountryCodes.add( code135);
            listOfCountryCodes.add( code136);
            listOfCountryCodes.add( code137);
            listOfCountryCodes.add( code138);
            listOfCountryCodes.add( code139);
            listOfCountryCodes.add( code140);
            listOfCountryCodes.add( code141);
            listOfCountryCodes.add( code142);
            listOfCountryCodes.add( code143);
            listOfCountryCodes.add( code144);
            listOfCountryCodes.add( code145);
            listOfCountryCodes.add( code146);
            listOfCountryCodes.add( code147);
            listOfCountryCodes.add( code148);
            listOfCountryCodes.add( code149);
            listOfCountryCodes.add( code150);
            listOfCountryCodes.add( code151);
            listOfCountryCodes.add( code152);
            listOfCountryCodes.add( code153);
            listOfCountryCodes.add( code154);
            listOfCountryCodes.add( code155);
            listOfCountryCodes.add( code156);
            listOfCountryCodes.add( code157);
            listOfCountryCodes.add( code158);
            listOfCountryCodes.add( code159);
            listOfCountryCodes.add( code160);
            listOfCountryCodes.add( code161);
            listOfCountryCodes.add( code162);
            listOfCountryCodes.add( code163);
            listOfCountryCodes.add( code164);
            listOfCountryCodes.add( code165);
            listOfCountryCodes.add( code166);
            listOfCountryCodes.add( code167);
            listOfCountryCodes.add( code168);
            listOfCountryCodes.add( code169);
            listOfCountryCodes.add( code170);
            listOfCountryCodes.add( code171);
            listOfCountryCodes.add( code172);
            listOfCountryCodes.add( code173);
            listOfCountryCodes.add( code174);
            listOfCountryCodes.add( code175);
            listOfCountryCodes.add( code176);
            listOfCountryCodes.add( code177);
            listOfCountryCodes.add( code178);
            listOfCountryCodes.add( code179);
            listOfCountryCodes.add( code180);
            listOfCountryCodes.add( code181);
            listOfCountryCodes.add( code182);
            listOfCountryCodes.add( code183);
            listOfCountryCodes.add( code184);
            listOfCountryCodes.add( code185);
            listOfCountryCodes.add( code186);
            listOfCountryCodes.add( code187);
            listOfCountryCodes.add( code188);
            listOfCountryCodes.add( code189);
            listOfCountryCodes.add( code190);
            listOfCountryCodes.add( code191);
            listOfCountryCodes.add( code192);
            listOfCountryCodes.add( code193);
            listOfCountryCodes.add( code194);
            listOfCountryCodes.add( code195);
            listOfCountryCodes.add( code196);
            listOfCountryCodes.add( code197);
            listOfCountryCodes.add( code198);
            listOfCountryCodes.add( code199);
            listOfCountryCodes.add( code200);
            listOfCountryCodes.add( code201);
            listOfCountryCodes.add( code202);
            listOfCountryCodes.add( code203);
            listOfCountryCodes.add( code204);
            listOfCountryCodes.add( code205);
            listOfCountryCodes.add( code206);
            listOfCountryCodes.add( code207);
            listOfCountryCodes.add( code208);
            listOfCountryCodes.add( code209);
            listOfCountryCodes.add( code210);
            listOfCountryCodes.add( code211);
            listOfCountryCodes.add( code212);
            listOfCountryCodes.add( code213);
            listOfCountryCodes.add( code214);
            listOfCountryCodes.add( code215);
            listOfCountryCodes.add( code216);
            listOfCountryCodes.add( code217);
            listOfCountryCodes.add( code218);
            listOfCountryCodes.add( code219);
            listOfCountryCodes.add( code220);
            listOfCountryCodes.add( code221);
            listOfCountryCodes.add( code222);
            listOfCountryCodes.add( code223);
            listOfCountryCodes.add( code224);
            listOfCountryCodes.add( code225);
            listOfCountryCodes.add( code226);
            listOfCountryCodes.add( code227);
            listOfCountryCodes.add( code228);
            listOfCountryCodes.add( code229);
            listOfCountryCodes.add( code230);
            listOfCountryCodes.add( code231);
            listOfCountryCodes.add( code232);
            listOfCountryCodes.add( code233);
            listOfCountryCodes.add( code234);
            listOfCountryCodes.add( code235);
            listOfCountryCodes.add( code236);
            listOfCountryCodes.add( code237);
            listOfCountryCodes.add( code238);
            listOfCountryCodes.add( code239);
            listOfCountryCodes.add( code240);
            listOfCountryCodes.add( code241);
            listOfCountryCodes.add( code242);
            listOfCountryCodes.add( code243);
            listOfCountryCodes.add( code244);
            listOfCountryCodes.add( code245);
            listOfCountryCodes.add( code246);
            listOfCountryCodes.add( code247);
            listOfCountryCodes.add( code248);
            listOfCountryCodes.add( code249);
            listOfCountryCodes.add( code250);
            listOfCountryCodes.add( code251);
            listOfCountryCodes.add( code252);

            map<string,Country_Codes__c> mapOfclientCountryCodes = Country_Codes__c.getAll();
            if(mapOfclientCountryCodes.size() == 0) {
                insert listOfCountryCodes;
            }
        }
    }