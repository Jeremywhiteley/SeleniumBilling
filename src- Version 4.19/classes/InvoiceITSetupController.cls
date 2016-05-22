//@purpose : Apex Controller resposible for new set up page
    //@author  : Asish Kumar BeheraI:  NVOICEIT-323

    public with sharing class InvoiceITSetupController {

        //All Required variable Declarations 
        public list<Configuration__c> configurations {get; set;}
        public list<Custom_Mappings__c> mappings {get; set;}
        public boolean displayMappings  {get; set;}
        public boolean displayFilters {get; set;}
        public boolean displaySettings {get; set;}
        public map<String,list<SelectOption>> mapSource_listDestinations ; 
        public map<String,list<SelectOption>> mapSource_listDestinationsForFilter ;
        public String sBaseURL {get; set;}
        public String sCategory {get; set;}
        public String sPrefix {get; set;}
        //Added for INVOICEIT-561
        public String customMappingButtonValue;

        // added new code Custom Mappings
        map<integer,Pair> mapCounter_MappingPair = new map<integer,Pair>();
        public List<Pair> listCustomMappingPairGeneral{get;set;}
        public List<Pair> listCustomMappingPairQuote2Order{get;set;}
        public List<Pair> listCustomMappingPairOpp2Order{get;set;}
        public List<Pair> listCustomMappingPairOpp2Quote{get;set;}
         //Added for INVOICEIT-561
        public List<Pair> listCustomMappingPairQuote2Opportunity{get;set;}
        //Added for INVOICEIT-573
        public List<Pair> listCustomMappingPairOrder2Opportunity{get;set;}
        //Added for INVOICEIT-541
        public List<Pair> listCustomMappingPairOrder2Quote{get;set;}
        public integer iMappingCounter{get;set;}   
        public list<Custom_Mappings__c> listCustomMapping {get; set;}
        public Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        public List<SelectOption> objectNamesGeneral {get; set;}
        public List<SelectOption> objectNamesQuote2Order {get; set;}
        public List<SelectOption> objectNamesOpp2Order {get; set;}
        public List<SelectOption> objectNamesOpp2Quote {get; set;}
        public List<SelectOption> objectProductFilterNames {get; set;}
        public List<SelectOption> destinationObjectNames {get; set;}
        
        //Added for INVOICEIT-561
        public List<SelectOption> objectNamesQuote2Opportunity {get; set;}
        //Added for INVOICEIT-573
        public List<SelectOption> objectNamesOrder2Opportunity {get; set;}
        //Added for INVOICEIT-541
        public List<SelectOption> objectNamesOrder2Quote {get; set;}

        // added new code Filters
        map<integer,Pair> mapCounter_FilterPair = new map<integer,Pair>();
        public List<Pair> listFilterPair{get;set;}
        public integer iFilterCounter{get;set;}   
        public list<Product_Catalog_Filter_Criteria__c> filters {get; set;}
        public boolean displayPicklistPopUp {get; set;}
        public boolean isSelectAll {get; set;}
        public list<ClassMultipicklistForSetup>  listClassMultiPicklist {get;set;}
        public String sIndicator;
        public list<Selectoption>  listAvailableFields {get;set;}
        public list<Selectoption>  listSelectedFields {get;set;}
        public list<SelectOption> listPaymentTerms {get; set;}
        public list<SelectOption> listRecordsPage2  {get; set;}
        public list<SelectOption> listOrderFieldsForDiscountCode {get; set;}
        public list<SelectOption> listQuoteFieldsForDiscountCode {get; set;}
        public list<SelectOption> listProductValueToRollUp {get; set;}
        public list<SelectOption> listPaymentSchedulerDates {get; set;}
        public list<SelectOption> listInvoiceGeneration {get; set;}
        public list<SelectOption> listOrderStatusfields {get; set;}
        public list<SelectOption> listORPCStatus {get; set;}
        public list<SelectOption> listApplyDiscounts {get; set;}
        public list<SelectOption> listInvoiceStatus {get; set;}
        public list<SelectOption> listOrderFields {get; set;}
        public list<SelectOption> listQuoteFields {get; set;}
        public list<SelectOption> listDefaultPaymentTerms {get; set;}
        public list<SelectOption> listAccountFields {get; set;}
        public list<SelectOption> listOpportunityStage {get; set;}
        public list<SelectOption> listOpportunityCharges1 {get; set;}
        public list<SelectOption> listOpportunityCharges {get; set;}
        public list<SelectOption> listTaxCalculationBasedOn {get; set;}
        private map<String, Configuration__c> mapConfiguration;
        public list<Selectoption>  listAllOrderStatusValues {get; set;}
        public list<Selectoption>  listAllOrderRPCStatusValues {get; set;}

        //string variable for getting object key prefix
        public String sVat_Tax_TabUrl{get;set;}
        public String sInvProductTabUrl{get;set;}
        public String sDiscountTabUrl{get;set;}
        public String sInvSchedulerTabUrl{get;set;}
        public String sPaymentSchedulerTabUrl{get;set;}
        public String sPaymentGetwayTabUrl{get;set;}
        public Boolean isExtensionInstalled{get;set;}
        public map<String,list<SelectOption>> mapInvoiceITSettings;
        public String sObjectName{get;set;}
        public boolean isModelpopUp {get;set;}

        //Constructor 
        public InvoiceITSetupController() {
            sPrefix = CommonUtilClass.getPrefix();
            isExtensionInstalled = true;
            mapInvoiceITSettings = new map<String,list<SelectOption>>();
            initObjNames(); 
            initProductFilterObjNames();
            sBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
            mapConfiguration = Configuration__c.getAll();
            mapSource_listDestinations = ProductCreationUtil.getMapSource_listDestinations();
            mapSource_listDestinationsForFilter = ProductCreationUtil.getMapSource_listDestinationsForFilters();
            mapInvoiceITSettings = ProductCreationUtil.getMapInvoiceITSettings();
            listOrderFieldsForDiscountCode = mapInvoiceITSettings.get('listOrderFieldsForDiscountCode');
            listQuoteFieldsForDiscountCode = mapInvoiceITSettings.get('listQuoteFieldsForDiscountCode');
            listOrderFields = mapInvoiceITSettings.get('listOrderFields');
            listQuoteFields = mapInvoiceITSettings.get('listQuoteFields');
            listDefaultPaymentTerms = mapInvoiceITSettings.get('listDefaultPaymentTerms');
            listAccountFields =  mapInvoiceITSettings.get('listAccountFields');
            listTaxCalculationBasedOn = mapInvoiceITSettings.get('listTaxCalculationBasedOn');
            listApplyDiscounts = mapInvoiceITSettings.get('listApplyDiscounts');
            listPaymentTerms = mapInvoiceITSettings.get('listPaymentTerms');
            listProductValueToRollUp = mapInvoiceITSettings.get('listProductValueToRollUp');
            listPaymentSchedulerDates = mapInvoiceITSettings.get('listPaymentSchedulerDates');
            listInvoiceStatus = mapInvoiceITSettings.get('listInvoiceStatus'); 
            listInvoiceGeneration = mapInvoiceITSettings.get('listInvoiceGeneration');
            listCustomMappingPairGeneral = new List<Pair>();
            listCustomMappingPairQuote2Order = new List<Pair>();
            listCustomMappingPairOpp2Quote = new List<Pair>();
            listCustomMappingPairOpp2Order = new List<Pair>();
            //Added INVOICEIT-561
            listCustomMappingPairQuote2Opportunity = new List<Pair>();
             //Added INVOICEIT-573
            listCustomMappingPairOrder2Opportunity = new List<Pair>();
             //Added INVOICEIT-541
            listCustomMappingPairOrder2Quote = new List<Pair>();
            iMappingCounter = -1;
            listCustomMapping = Custom_Mappings__c.getAll().values();
            // Added by Lopamudra ticket number INVOICEIT-425
            listAllOrderStatusValues = mapInvoiceITSettings.get('listOrderStatusfields');
            listAllOrderRPCStatusValues = mapInvoiceITSettings.get('listORPCStatus');

            filters = Product_Catalog_Filter_Criteria__c.getAll().values();
            iFilterCounter = -1;
            listFilterPair = new List<Pair>();
            
            //constructing all the mapping record if previoulsy present.
            for(Custom_Mappings__c customMapping : listCustomMapping ) {
                Pair classproductFilterObj = new Pair();
                classproductFilterObj.destinationObjectNames = mapSource_listDestinations.get(customMapping.Source_Object__c);
                classproductFilterObj.sourcefieldNames= ObjectFieldsGetCustomMapping(customMapping.Source_Object__c ,''+customMapping.Category__c);
                classproductFilterObj.destinationfieldNames = ObjectFieldsGetCustomMapping(customMapping.Destination_Object__c , '');
                classproductFilterObj.iMappingCounter = ++iMappingCounter;
                classproductFilterObj.customMapping = customMapping;
                if(customMapping.Category__c =='General') {
                    classproductFilterObj.SourceObjectNames = objectNamesGeneral;
                    listCustomMappingPairGeneral.add(classproductFilterObj);        
                }
                if(customMapping.Category__c =='Quote2Order') {
                    classproductFilterObj.SourceObjectNames = objectNamesQuote2Order;
                    listCustomMappingPairQuote2Order.add(classproductFilterObj);  
                }
                if(customMapping.Category__c =='Opp2Quote') {
                    classproductFilterObj.SourceObjectNames = objectNamesOpp2Quote;
                    
                    listCustomMappingPairOpp2Quote.add(classproductFilterObj);      
                }
                if(customMapping.Category__c =='Opp2Order') {
                    classproductFilterObj.SourceObjectNames = objectNamesOpp2Order;
                    listCustomMappingPairOpp2Order.add(classproductFilterObj);      
                }if(customMapping.Category__c =='Quote2Opportunity'){
                    classproductFilterObj.SourceObjectNames = objectNamesQuote2Opportunity;
                    listCustomMappingPairQuote2Opportunity.add(classproductFilterObj); 
                }if(customMapping.Category__c =='Order2Opportunity'){
                    classproductFilterObj.SourceObjectNames = objectNamesOrder2Opportunity;
                    listCustomMappingPairOrder2Opportunity.add(classproductFilterObj); 
                }if(customMapping.Category__c =='Order2Quote'){
                    classproductFilterObj.SourceObjectNames = objectNamesOrder2Quote;
                    listCustomMappingPairOrder2Quote.add(classproductFilterObj); 
                }
                mapCounter_MappingPair.put(classproductFilterObj.iMappingCounter , classproductFilterObj);
            } 
            //constructing all all the product filters record if previoulsy present.
            for(Product_Catalog_Filter_Criteria__c productCatalogFilter : filters ) {
                Pair classproductFilterObj = new Pair();
                classproductFilterObj.iFilterCounter = ++iFilterCounter;
                classproductFilterObj.productFilterCriteria = productCatalogFilter;
                classproductFilterObj.SourceObjectNames = objectProductFilterNames;
                classproductFilterObj.destinationObjectNames = mapSource_listDestinationsForFilter.get(productCatalogFilter.Source_Object__c);

                classproductFilterObj.sourcefieldNames= ObjectFieldsGet(productCatalogFilter.Source_Object__c);
                classproductFilterObj.destinationfieldNames = ObjectFieldsGet(productCatalogFilter.Destination_Object__c);
                listFilterPair.add(classproductFilterObj);
                mapCounter_FilterPair.put(classproductFilterObj.iFilterCounter , classproductFilterObj);
            } 

            //invoking methods to get key prefix
            sVat_Tax_TabUrl = getObjetTabUrl(sPrefix+'Tax_Rate__c');
            sInvProductTabUrl = getObjetTabUrl(sPrefix+'Product__c');
            sDiscountTabUrl =   getObjetTabUrl(sPrefix+'Discount_Code__c');
            sInvSchedulerTabUrl = getObjetTabUrl(sPrefix+'Invoice_RunScheduler__c');
            sPaymentSchedulerTabUrl = getObjetTabUrl(sPrefix+'Payment_Scheduler__c');
            sPaymentGetwayTabUrl = getObjetTabUrl(sPrefix+'Gateway__c');


        }   

       //@purpose : Method responsible for to get objectkey prefix,  @Param : String (aPI_Name_Of_SObject),   @Return : String,  @created By: Asish Behera
        //method to get Object key prefix
        public String getObjetTabUrl(String aPI_Name_Of_SObject){
            String sKeyPrefix ;
            Map<String, Schema.SObjectType> m  = Schema.getGlobalDescribe() ;
            Schema.SObjectType s = m.get(aPI_Name_Of_SObject) ;
            Schema.DescribeSObjectResult r = s.getDescribe() ;
            sKeyPrefix = r.getKeyPrefix();
            sKeyPrefix = sBaseURL+'/'+sKeyPrefix+'/o';
            return sKeyPrefix;
        }

      //@purpose : Method to save,  @Param : None,  @Return : Pagereference
        public PageReference saveInvoiceITSettings(){
            update configurations;

            //Added by Shruthi related to INVOICEIT-200
            Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info,system.Label.Saved);
            Apexpages.addMessage(infoMessage);
            return null;
        }
        public boolean isRenderTable{get;set;}

      /**@purpose : Method responsible to display custom setting information based on category(General/quote/oppt/invoice)
                         inovked when we click on link of Configure Advance Setting
        @Param : String (aPI_Name_Of_SObject),  @Return : String,  @created By: Asish Behera
         **/
        public void getCategory() { 
            sCategory =   system.currentPageReference().getParameters().get('category');
            map<String,list<SelectOption>> mapInvoiceITSettingsForOppt;
            mapInvoiceITSettingsForOppt = new map<String,list<SelectOption>>();
            configurations = new list<Configuration__c>();
            listOpportunityCharges = new list<SelectOption>();
            listOpportunityStage = new list<SelectOption>();
            listOpportunityCharges1 = new list<SelectOption>();
            //for opportunity details 
            isRenderTable = true;

            //if category is in oppt then checking extension is installed or not
            if(sCategory == 'Opportunity'){
                Boolean isInstalledCheck = ProductCreationUtil.checkingExtensionInstalled();
                if(isInstalledCheck){
                    //calling method to get oppt related information
                    mapInvoiceITSettingsForOppt = ProductCreationUtil.gettingOpportunityMapping();  
                    mapInvoiceITSettings.putAll(mapInvoiceITSettingsForOppt);
                    listOpportunityCharges =  mapInvoiceITSettings.get('listOpportunityCharges');
                    listOpportunityStage =  mapInvoiceITSettings.get('listOpportunityStage');
                    listOpportunityCharges1 =  mapInvoiceITSettings.get('listOpportunityCharges1');

                }
                else{
                    isExtensionInstalled = false;
                    isRenderTable = false;
                }   
            }  
            //making explicitely true as It might come from custom mapping or product filter  
            else{
                isExtensionInstalled = true;
            }    
            // if extension is installed then only we will make query

            if(isRenderTable) {
                configurations = [select Name,Description__c ,Field_Type__c,Percentage_Value__c,Number_Value__c,Category__c,Sequence__c,Boolean_Value__c,Date_Value__c,String_Value__c,Picklist_Indicator__c  from Configuration__c where Category__c =:sCategory order by Sequence__c ];
                sCategory = sCategory + ' Settings';
            }
        }

        // saving product filter
        public PageReference saveProductFilter_old(){
            upsert filters;

            Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info,system.Label.Records_Saved);
            Apexpages.addMessage(infoMessage);

            return null;
        }

        //delete product filter row
        public PageReference deleteFilterRow_old(){
            String id = System.currentPageReference().getParameters().get('id');
            if(id != null){
                Product_Catalog_Filter_Criteria__c filter = new Product_Catalog_Filter_Criteria__c(id = id);
                delete filter;
                //Added by Shruthi related to INVOICEIT-200
                Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info,system.Label.PurgedSuccessfully);
                Apexpages.addMessage(infoMessage);
                filters = Product_Catalog_Filter_Criteria__c.getAll().values();
            }

            return null;
        }


        public PageReference addMappingRow_old() {
            upsert mappings;

            Custom_Mappings__c mapping = new Custom_Mappings__c();
            mappings.add(mapping);

            return null;
        }

        //saving custom mapping record
        public PageReference saveCustomMapping_old(){
            upsert mappings;

            Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info,system.Label.Records_Saved);
            Apexpages.addMessage(infoMessage);

            return null;
        }
        // delete mapping record
        public PageReference deleteMappingRow_old(){
            String id = System.currentPageReference().getParameters().get('id');
            if(id != null){
                Custom_Mappings__c mapping = new Custom_Mappings__c(id = id);
                delete mapping;
                //Added by Shruthi related to INVOICEIT-200
                Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info,system.Label.PurgedSuccessfully);
                Apexpages.addMessage(infoMessage);
                mappings = Custom_Mappings__c.getAll().values();
            }

            return null;
        }
        /*
         *@purpose : Method responsible to return all the custom fields this method is only invoked for filter block
         *@Param : String (aPI_Name_Of_SObject),  @Return : String, @created By: Asish Behera
         **/
        public List<SelectOption> ObjectFieldsGet(string s) {
            //appending base org prefix to the custom Object
            if(s != 'Account' && s != 'Opportunity'){
                            s = sPrefix+s;  
                }

            list<SelectOption> objectFields = new list<SelectOption>();

            objectFields.add(new SelectOption( '' , '--None--'));
            if(schemaMap.ContainsKey(s)) {
                Map <String, Schema.SObjectField> fieldMap = schemaMap.get(s).getDescribe().fields.getMap();    
                //Creating picklist of fields  
                string sType = '';
                for(Schema.SObjectField fieldAPI :fieldMap.values())  {
                    sType = ''+fieldAPI.getDescribe().getType();
                    if(sType=='STRING' || sType=='PICKLIST' ||  sType=='TEXTAREA'){
                        objectFields.add(new SelectOption(fieldAPI.getDescribe().getLocalName() , fieldAPI.getDescribe().getLabel())) ;  
                    } 
                } 
            }
            return objectFields;

        }

       //@purpose : Method to display all source object name list in product filter section,  @Param : None,  @Return : Pagereference

        public void initProductFilterObjNames() {

            Boolean isOppInstalledCheck = ProductCreationUtil.IsOppInstalled();
            objectProductFilterNames = new List<SelectOption>();
            objectProductFilterNames.add(new SelectOption( '' , '--None--' ));
            objectProductFilterNames.add(new SelectOption( 'Account' , 'Account' ));
            objectProductFilterNames.add(new SelectOption( 'Job__c' , 'Order'));
            objectProductFilterNames.add(new SelectOption( 'Quote__c' , 'Quote'));

            if(isOppInstalledCheck){
                objectProductFilterNames.add(new SelectOption( 'Opportunity' , 'Opportunity' ));        
            }

        }

        //@purpose : Method to respnsible to retrun all object names,  @Param : None,  @Return : Pagereference

        public void initObjNames() {
            objectNamesGeneral = new List<SelectOption>();
            objectNamesGeneral.add(new SelectOption( '' , '--None--' ));
            objectNamesGeneral.add(new SelectOption( 'Product__c' , 'Invoice IT Product'));
            objectNamesGeneral.add(new SelectOption( 'Product_Rate_Plan__c' , 'Product Rate Plan' ));
            objectNamesGeneral.add(new SelectOption( 'Product_Rate_Plan_charge__c' , 'Product Rate Plan Charge'));
            objectNamesQuote2Order = new List<SelectOption>();
            objectNamesQuote2Order.add(new SelectOption( '' , '--None--' ));
            objectNamesQuote2Order.add(new SelectOption( 'Quote__c' , 'Quote'));
            objectNamesQuote2Order.add(new SelectOption( 'Quote_Product__c' , 'Quote Product'));
            objectNamesQuote2Order.add(new SelectOption( 'Quote_Rate_Plan_Charge__c' , 'Quote Rate Plan Charge'));
            objectNamesQuote2Order.add(new SelectOption( 'Quote_Rate_Plan__c' , 'Quote Rate Plan'));


            objectNamesOpp2Order = new List<SelectOption>();
            objectNamesOpp2Order.add(new SelectOption( '' , '--None--' ));
            objectNamesOpp2Order.add(new SelectOption( 'Opportunity' , 'Opportunity' ));

            //below are crm ext package objects
            objectNamesOpp2Order.add(new SelectOption( 'Opportunity_Product__c' , 'Opportunity Product'));
            objectNamesOpp2Order.add(new SelectOption( 'Opportunity_Rate_Plan__c' , 'Opportunity Rate Plan' ));
            objectNamesOpp2Order.add(new SelectOption( 'Opportunity_Rate_Plan_Charge__c' , 'Opportunity Rate Plan Charge' ));
            objectNamesOpp2Quote = new List<SelectOption>();
            objectNamesOpp2Quote.add(new SelectOption( '' , '--None--' ));
            objectNamesOpp2Quote.add(new SelectOption( 'Opportunity' , 'Opportunity' ));
            objectNamesOpp2Quote.add(new SelectOption( 'Opportunity_Product__c' , 'Opportunity Product'));
            objectNamesOpp2Quote.add(new SelectOption( 'Opportunity_Rate_Plan__c' , 'Opportunity Rate Plan' ));
            objectNamesOpp2Quote.add(new SelectOption( 'Opportunity_Rate_Plan_Charge__c' , 'Opportunity Rate Plan Charge' ));
            
            // Added INVOICEIT-561
            objectNamesQuote2Opportunity = new List<SelectOption>();
            objectNamesQuote2Opportunity.add(new SelectOption('','--None--'));
            objectNamesQuote2Opportunity.add(new SelectOption('Quote__c','Quote'));
            objectNamesQuote2Opportunity.add(new SelectOption('Quote_Product__c','Quote Product'));
            objectNamesQuote2Opportunity.add(new SelectOption('Quote_Rate_Plan__c','Quote Rate Plan'));
            objectNamesQuote2Opportunity.add(new SelectOption('Quote_Rate_Plan_Charge__c','Quote Rate Plan Charge'));
             // Added INVOICEIT-573
            objectNamesOrder2Opportunity = new List<SelectOption>();
            objectNamesOrder2Opportunity.add(new SelectOption('','--None--'));
            objectNamesOrder2Opportunity.add(new SelectOption('Job__c','Order'));
            objectNamesOrder2Opportunity.add(new SelectOption('Job_Product__c','Order Product'));
            objectNamesOrder2Opportunity.add(new SelectOption('Job_Rate_Plan__c','Order Rate Plan'));
            objectNamesOrder2Opportunity.add(new SelectOption('Job_Rate_Plan_Charge__c','Order Rate Plan Charge'));
            // Added INVOICEIT-541
            objectNamesOrder2Quote = new List<SelectOption>();
            objectNamesOrder2Quote.add(new SelectOption('','--None--'));
            objectNamesOrder2Quote.add(new SelectOption('Job__c','Order'));
            objectNamesOrder2Quote.add(new SelectOption('Job_Product__c','Order Product'));
            objectNamesOrder2Quote.add(new SelectOption('Job_Rate_Plan__c','Order Rate Plan'));
            objectNamesOrder2Quote.add(new SelectOption('Job_Rate_Plan_Charge__c','Order Rate Plan Charge'));
            
        }
    //@purpose : Method responsible to return all the custom fields this method is only invoked for mapping block          
    //@Param : String (aPI_Name_Of_SObject) , @Return : String, @created By: Asish Behera
        public List<SelectOption> ObjectFieldsGetCustomMapping(string s ,String categoryvalue) {
            //appending base org prefix to the Custom Object

            ///if appenidng invoiceit_crmx__ prefix for opportunity modified by Asish

            //for Opportunity related object we are appending invoiceit_crmx__ prefix.
            if( s == 'Opportunity_Product__c' || s == 'Opportunity_Rate_Plan__c' || s == 'Opportunity_Rate_Plan_Charge__c' ){
                s = 'invoiceit_crmx__'+s;       
            }
            else if(s!='Opportunity'){
                            s = sPrefix+s;
            }

            List<SelectOption> objectFields = new List<SelectOption>();
            objectFields.add(new SelectOption( '' , '--None--'));
            if(schemaMap.ContainsKey(s)) {
                Map <String, Schema.SObjectField> fieldMap = schemaMap.get(s).getDescribe().fields.getMap();        
                //Creating picklist of fields  
                string sType = '';

                for(Schema.SObjectField fieldAPI : fieldMap.values())  {
                    if((fieldAPI.getDescribe().getLocalName().contains('__c') || fieldAPI.getDescribe().getLocalName()=='Name')&& customMappingButtonValue =='' && (categoryvalue != 'Quote2Opportunity' && categoryvalue != 'Order2Opportunity' && categoryvalue == 'Order2Quote')){
                        objectFields.add(new SelectOption(fieldAPI.getDescribe().getLocalName() , fieldAPI.getDescribe().getLabel())) ;     
                    }else if((fieldAPI.getDescribe().getName().contains('__c') || fieldAPI.getDescribe().getName()=='Name') && ( customMappingButtonValue !='' || categoryvalue == 'Quote2Opportunity'|| categoryvalue == 'Order2Opportunity' || categoryvalue == 'Order2Quote')){
                        objectFields.add(new SelectOption(fieldAPI.getDescribe().getName() , fieldAPI.getDescribe().getLabel())) ;     
                    }
                } 
            }
            // Modified by Lopa ticket : INVOICEIT-557
            objectFields.sort();
            return objectFields;
        }
        //invoked when we change source object in the product filter section
        public PageReference ObjectFields() {
            Pair selectedClass;
            String sObject_Counter = System.currentPageReference().getParameters().get('objectCounter');
            getSelectedClass(sObject_Counter);
            return null;
        }
        // method invoked from ObjectFields and destinationfields methods
        public void getSelectedClass(String sObject_Counter) {
            Pair selectedClass;
            String sOpp2QuoteOrOrder;
            list<String>  listObjectCounter = new list<String>();
            listObjectCounter = sObject_Counter.split('-');
            String sObjectName = listObjectCounter[0];
            String sCounter = listObjectCounter[1];
            String sSource_Destination = listObjectCounter[2];
            String sObjectNameFrompage;

            //if we changed something on custom mapping settings 
            if(sObjectName == 'customMapping'){
                if(listObjectCounter.size()>=5){
                    sObjectNameFrompage = listObjectCounter[4];             
                }

            }
            //if we changed something on product filter 
            else if(sObjectName == 'productFilter'){
                if(listObjectCounter.size()>=4){
                    sObjectNameFrompage = listObjectCounter[3];
                }

            } 

            //sowing error message when oppt is choosen
            if(sObjectNameFrompage == 'Opportunity' || sObjectNameFrompage == 'Opportunity_Rate_Plan_Charge__c' || sObjectNameFrompage == 'Opportunity_Product__c' || sObjectNameFrompage == 'Opportunity_Rate_Plan__c'){
                //checking wheather extension is installed or not
                Boolean isInstalled = ProductCreationUtil.checkingExtensionInstalled();
                if(isInstalled){
                    mapInvoiceITSettings = ProductCreationUtil.gettingOpportunityMapping();
                    isExtensionInstalled = true;
                }
                //if extension is installed then we need to call some method which will return all the values related to Oppt.
                else{
                    isExtensionInstalled = false;
                }
            }

            // for product filter section ,getting selected pair class from page mapping with counter value
            if(sObjectName == 'productFilter') {

                if(mapCounter_FilterPair.ContainsKey(Integer.valueOf(sCounter))) {
                    selectedClass = mapCounter_FilterPair.get(Integer.valueOf(sCounter));   
                }
            }

            // for custom mapping section ,getting selected pair class from page mapping with counter value
            else if(sObjectName == 'customMapping') {
                sOpp2QuoteOrOrder = listObjectCounter[3];


                if(mapCounter_MappingPair.ContainsKey(Integer.valueOf(sCounter))) {
                    selectedClass = mapCounter_MappingPair.get(Integer.valueOf(sCounter));  
                }
            }
            //if we do onchange event on Source object
            if(sSource_Destination == 'Source') {
                mappingSourceObjectFields(selectedClass,sObjectName,sOpp2QuoteOrOrder);   
            }
            //if we do onchange event on destination object
            else if(sSource_Destination == 'Destination') {
                mappingDestinationObjectFields(selectedClass,sObjectName); 
            }
        }
        //method to consolidated sourcefields.
        public void mappingSourceObjectFields(Pair selectedClass,String sObjectName,String sOpp2QuoteOrOrder) {
            selectedClass.destinationfieldNames = new List<SelectOption>();
            selectedClass.destinationObjectNames = new List<SelectOption>();

            //product filter block to construct select options list for source fields and destination object names
            if(sObjectName == 'productFilter') {

                selectedClass.productFilterCriteria.Source_Field__c = '';
                selectedClass.productFilterCriteria.Destination_Object__c = '';
                selectedClass.sourcefieldNames =  ObjectFieldsGet(selectedClass.productFilterCriteria.Source_Object__c);

                selectedClass.destinationObjectNames = mapSource_listDestinationsForFilter.get(selectedClass.productFilterCriteria.Source_Object__c);

             }

            //custom mapping block to construct select options list for source fields and destination object names
            else if(sObjectName == 'customMapping') {
                selectedClass.customMapping.Source_Field__c = '';
                selectedClass.customMapping.Destination_Field__c = '';
                selectedClass.sourcefieldNames =  ObjectFieldsGetCustomMapping(selectedClass.customMapping.Source_Object__c,'');
                list<SelectOption> listDestinationsJob = new list<SelectOption>();
                list<SelectOption> listDestinationsJobProduct = new list<SelectOption>();
                list<SelectOption> listDestinationsJobRatePlan = new list<SelectOption>();
                list<SelectOption> listDestinationsJRPC = new list<SelectOption>();
                list<SelectOption> listDestinationsQuote = new list<SelectOption>();
                list<SelectOption> listDestinationsQuoteProduct = new list<SelectOption>();
                list<SelectOption> listDestinationsQuoteRatePlan = new list<SelectOption>();
                list<SelectOption> listDestinationsQRPC = new list<SelectOption>();
                listDestinationsJob.add(new SelectOption( '' , '--None--'));
                listDestinationsJob.add(new SelectOption( 'Job__c' , 'Order'));
                listDestinationsJobProduct.add(new SelectOption( '' , '--None--'));
                listDestinationsJobProduct.add(new SelectOption( 'Job_Product__c' , 'Order Product'));
                listDestinationsJobRatePlan.add(new SelectOption( '' , '--None--'));
                listDestinationsJobRatePlan.add(new SelectOption( 'Job_Rate_Plan__c' , 'Order Rate Plan'));
                listDestinationsJRPC.add(new SelectOption( '' , '--None--'));
                listDestinationsJRPC.add(new SelectOption( 'Job_Rate_Plan_Charge__c' , 'Order Rate Plan Charge'));
                listDestinationsQuoteProduct.add(new SelectOption( '' , '--None--'));
                listDestinationsQuoteProduct.add(new SelectOption( 'Quote_Product__c' , 'Quote Product'));
                listDestinationsQuoteRatePlan.add(new SelectOption( '' , '--None--'));
                listDestinationsQuoteRatePlan.add(new SelectOption( 'Quote_Rate_Plan__c' , 'Quote Rate Plan'));
                listDestinationsQRPC.add(new SelectOption( '' , '--None--'));
                listDestinationsQRPC.add(new SelectOption( 'Quote_Rate_Plan_Charge__c' , 'Quote Rate Plan Charge'));
                listDestinationsQuote.add(new SelectOption( '' , '--None--'));
                listDestinationsQuote.add(new SelectOption( 'Quote__c' , 'Quote'));

                // for Opportunity to Order page block
                if(sOpp2QuoteOrOrder=='Opp2Order'){
                    if(selectedClass.customMapping.Source_Object__c =='Opportunity'){
                        selectedClass.destinationObjectNames = listDestinationsJob;               
                    }
                    else if(selectedClass.customMapping.Source_Object__c =='Opportunity_Product__c'){
                        selectedClass.destinationObjectNames = listDestinationsJobProduct;                
                    }
                    else if(selectedClass.customMapping.Source_Object__c =='Opportunity_Rate_Plan__c'){
                        selectedClass.destinationObjectNames = listDestinationsJobRatePlan;               
                    }
                    else if(selectedClass.customMapping.Source_Object__c =='Opportunity_Rate_Plan_Charge__c'){
                        selectedClass.destinationObjectNames = listDestinationsJRPC;              
                    }
                }

                // for Opportunity to Quote page block
                else if(sOpp2QuoteOrOrder=='Opp2Quote'){
                    if(selectedClass.customMapping.Source_Object__c =='Opportunity'){
                        selectedClass.destinationObjectNames = listDestinationsQuote;             
                    }
                    else if(selectedClass.customMapping.Source_Object__c =='Opportunity_Product__c'){
                        selectedClass.destinationObjectNames = listDestinationsQuoteProduct;              
                    }
                    else if(selectedClass.customMapping.Source_Object__c =='Opportunity_Rate_Plan__c'){
                        selectedClass.destinationObjectNames = listDestinationsQuoteRatePlan;             
                    }
                    else if(selectedClass.customMapping.Source_Object__c =='Opportunity_Rate_Plan_Charge__c'){
                        selectedClass.destinationObjectNames = listDestinationsQRPC;              
                    }     
                }
                //rest for others
                else{

                    selectedClass.destinationObjectNames = mapSource_listDestinations.get(selectedClass.customMapping.Source_Object__c);    
                } 
            }
        }

        //method to consolidate destination fields.
        public void mappingDestinationObjectFields(Pair selectedClass,String sObjectName) {
            if(sObjectName == 'productFilter') {
                    selectedClass.productFilterCriteria.Destination_Field__c = '';
                selectedClass.destinationfieldNames =  ObjectFieldsGet(selectedClass.productFilterCriteria.Destination_Object__c);
            }
            else if(sObjectName == 'customMapping') {
                    selectedClass.customMapping.Destination_Field__c = '';
                selectedClass.destinationfieldNames =  ObjectFieldsGetCustomMapping(selectedClass.customMapping.Destination_Object__c,'');
            }
        }

        // method invoked to create new row when we click on New button on General block
        public void addMappingRowGeneral() {
            destinationObjectNames = new  list<SelectOption>();
            destinationObjectNames.add(new SelectOption( '' , '--None--'));
            Pair obj = new Pair();
            obj.customMapping = new Custom_Mappings__c();
            obj.iMappingCounter = ++iMappingCounter;
            obj.SourceObjectNames = objectNamesGeneral;
            obj.destinationObjectNames = destinationObjectNames;  
            listCustomMappingPairGeneral.add(obj);      
            mapCounter_MappingPair.put(obj.iMappingCounter,obj);
        } 

        // method invoked to create new row when we click on New button on Quote to Order block
        public void addMappingRowQuote2Order() {
            destinationObjectNames = new  list<SelectOption>();
            destinationObjectNames.add(new SelectOption( '' , '--None--'));
            Pair obj = new Pair();
            obj.customMapping = new Custom_Mappings__c();
            obj.iMappingCounter = ++iMappingCounter;
            obj.SourceObjectNames = objectNamesQuote2Order;
            obj.destinationObjectNames = destinationObjectNames;  
            listCustomMappingPairQuote2Order.add(obj);      
            mapCounter_MappingPair.put(obj.iMappingCounter,obj);
        } 

        // method invoked to create new row when we click on New button on Opportunity to order block
        public void addMappingRowOpp2Order() {
            destinationObjectNames = new  list<SelectOption>();
            destinationObjectNames.add(new SelectOption( '' , '--None--'));
            Pair obj = new Pair();
            obj.customMapping = new Custom_Mappings__c();
            obj.iMappingCounter = ++iMappingCounter;
            obj.SourceObjectNames = objectNamesOpp2Order;
            obj.destinationObjectNames = destinationObjectNames;  
            listCustomMappingPairOpp2Order.add(obj);      
            mapCounter_MappingPair.put(obj.iMappingCounter,obj);
        }

        // method invoked to create new row when we click on New button on Opportunity to Quote block
        public void addMappingRowOpp2Quote() {
            destinationObjectNames = new  list<SelectOption>();
            destinationObjectNames.add(new SelectOption( '' , '--None--'));
            Pair obj = new Pair();
            obj.customMapping = new Custom_Mappings__c();
            obj.iMappingCounter = ++iMappingCounter;
            obj.SourceObjectNames = objectNamesOpp2Quote;
            obj.destinationObjectNames = destinationObjectNames;  
            listCustomMappingPairOpp2Quote.add(obj);      
            mapCounter_MappingPair.put(obj.iMappingCounter,obj);
        } 

        // method invoked to delete row when we click on delete link on Opportunity to order block
        public PageReference deleteMappingRowGeneral(){
            String sCounter = System.currentPageReference().getParameters().get('counter');
            String id = System.currentPageReference().getParameters().get('id');

            for(integer i=0;i<listCustomMappingPairGeneral.size();i++) {                 
                if(sCounter == String.valueOf(listCustomMappingPairGeneral[i].iMappingCounter)) {
                    Pair pair = new pair();
                    pair = listCustomMappingPairGeneral.get(i);
                    if(Pair.customMapping.Id != null) {
                        delete pair.customMapping;
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info, system.Label.RecordDeleted);
                        Apexpages.addMessage(infoMessage);
                    }
                    listCustomMappingPairGeneral.remove(i);
                    break;
                }
            }
            return null;
        }

        // method invoked to delete row when we click on delete link on Quote to order block
        public PageReference deleteMappingRowQuote2Order(){
            String sCounter = System.currentPageReference().getParameters().get('counter');
            String id = System.currentPageReference().getParameters().get('id');

            for(integer i=0;i<listCustomMappingPairQuote2Order.size();i++) {                 
                if(sCounter == String.valueOf(listCustomMappingPairQuote2Order[i].iMappingCounter)) {
                    Pair pair = new pair();
                    pair = listCustomMappingPairQuote2Order.get(i);
                    if(Pair.customMapping.Id != null) {
                        delete pair.customMapping;
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info, system.Label.RecordDeleted);
                        Apexpages.addMessage(infoMessage);
                    }
                    listCustomMappingPairQuote2Order.remove(i);
                    break;
                }
            }
            return null;
        }

        // method invoked to delete row when we click on delete link on Opportunity to order block
        public PageReference deleteMappingRowOpp2Order(){
            String sCounter = System.currentPageReference().getParameters().get('counter');
            String id = System.currentPageReference().getParameters().get('id');

            for(integer i=0;i<listCustomMappingPairOpp2Order.size();i++) {                 
                if(sCounter == String.valueOf(listCustomMappingPairOpp2Order[i].iMappingCounter)) {
                    Pair pair = new pair();
                    pair = listCustomMappingPairOpp2Order.get(i);
                    if(Pair.customMapping.Id != null) {
                        delete pair.customMapping;
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info, system.Label.RecordDeleted);
                        Apexpages.addMessage(infoMessage);
                    }
                    listCustomMappingPairOpp2Order.remove(i);
                    break;
                }
            }
            return null;
        }

        // method invoked to delete row when we click on delete link on Opportunity to quote block
        public PageReference deleteMappingRowOpp2Quote(){
            String sCounter = System.currentPageReference().getParameters().get('counter');
            String id = System.currentPageReference().getParameters().get('id');

            for(integer i=0;i<listCustomMappingPairOpp2Quote.size();i++) {                 
                if(sCounter == String.valueOf(listCustomMappingPairOpp2Quote[i].iMappingCounter)) {
                    Pair pair = new pair();
                    pair = listCustomMappingPairOpp2Quote.get(i);
                    if(Pair.customMapping.Id != null) {
                        delete pair.customMapping;
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info, system.Label.RecordDeleted);
                        Apexpages.addMessage(infoMessage);
                    }
                    listCustomMappingPairOpp2Quote.remove(i);
                    break;
                }
            }
            return null;
        }
        
         //=========Start INVOICEIT-561 =====================
        //method invoked to create new row when we click on New button on Quote to Opportunity block
        public void addMappingRowQuote2Opportunity() {
            customMappingButtonValue = System.currentPageReference().getParameters().get('Quote2Opp');
            destinationObjectNames = new  list<SelectOption>();
            destinationObjectNames.add(new SelectOption( '' , '--None--'));
            Pair obj = new Pair();
            obj.customMapping = new Custom_Mappings__c();
            obj.iMappingCounter = ++iMappingCounter;
            obj.SourceObjectNames = objectNamesQuote2Opportunity;
            obj.destinationObjectNames = destinationObjectNames;
            listCustomMappingPairQuote2Opportunity.add(obj); 
            mapCounter_MappingPair.put(obj.iMappingCounter,obj);
        }
        public PageReference saveCustomMappingQuote2Opportunity(){
            Savepoint savePoint;
            integer i=0;
            try {    
                savePoint = Database.setSavepoint();
                list<Custom_Mappings__c> listOfcustomMapping = new list<Custom_Mappings__c>();       
                for(Pair pair : listCustomMappingPairQuote2Opportunity) {
                    pair.customMapping.Name = System.now() +' ' +pair.iMappingCounter ; 
                    pair.customMapping.Category__c = 'Quote2Opportunity';
                    listOfcustomMapping.add(pair.customMapping);
                }
                upsert listOfcustomMapping ;
                Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info, system.Label.RecordsSavedSuccessfully);
                Apexpages.addMessage(infoMessage);
            } catch(DMLException dMlEx){
                            // Added by Lopamudra ticket : INVOICEIT-310 
                            Apexpages.Message errorMessage; 
                            for (Integer exp = 0; exp < dMlEx.getNumDml(); exp++)
                            { 
                              errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(exp));
                              Apexpages.addMessage(errorMessage);      
                            } 
                            return null; 
                    } catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.Error);
                Apexpages.addMessage(errorMessage);
                Database.rollback(savePoint);
            }
            return null;
        }
        // method invoked to delete row when we click on delete link on Quote to Opportunity block
        public PageReference deleteMappingRowQuote2Opportunity(){
            String sCounter = System.currentPageReference().getParameters().get('counter');
            String id = System.currentPageReference().getParameters().get('id');
            for(integer i=0;i<listCustomMappingPairQuote2Opportunity.size();i++) {                 
                if(sCounter == String.valueOf(listCustomMappingPairQuote2Opportunity[i].iMappingCounter)) {
                    Pair pair = new pair();
                    pair = listCustomMappingPairQuote2Opportunity.get(i);
                    if(Pair.customMapping.Id != null) {
                        delete pair.customMapping;
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info, system.Label.RecordDeletedSuccessfully);
                        Apexpages.addMessage(infoMessage);
                    }
                    listCustomMappingPairQuote2Opportunity.remove(i);
                    break;
                }
            }
            return null;
        }
        //=========END   INVOICEIT-561 =====================
        //=========Start INVOICEIT-573 =====================
        //method invoked to create new row when we click on New button on Quote to Opportunity block
        public void addMappingRowOrder2Opportunity() {
            customMappingButtonValue = System.currentPageReference().getParameters().get('Order2Opp');
            destinationObjectNames = new  list<SelectOption>();
            destinationObjectNames.add(new SelectOption( '' , '--None--'));
            Pair obj = new Pair();
            obj.customMapping = new Custom_Mappings__c();
            obj.iMappingCounter = ++iMappingCounter;
            obj.SourceObjectNames = objectNamesOrder2Opportunity;
            obj.destinationObjectNames = destinationObjectNames;
            listCustomMappingPairOrder2Opportunity.add(obj); 
            mapCounter_MappingPair.put(obj.iMappingCounter,obj);
        }
        public PageReference saveCustomMappingOrder2Opportunity(){
            Savepoint savePoint;
            integer i=0;
            try {    
                savePoint = Database.setSavepoint();
                list<Custom_Mappings__c> listOfcustomMapping = new list<Custom_Mappings__c>();       
                for(Pair pair : listCustomMappingPairOrder2Opportunity) {
                    pair.customMapping.Name = System.now() +' ' +pair.iMappingCounter ; 
                    pair.customMapping.Category__c = 'Order2Opportunity';
                    listOfcustomMapping.add(pair.customMapping);
                }
                upsert listOfcustomMapping ;
                Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info, system.Label.RecordsSavedSuccessfully);
                Apexpages.addMessage(infoMessage);
            } catch(DMLException dMlEx){
                            // Added by Lopamudra ticket : INVOICEIT-310 
                            Apexpages.Message errorMessage; 
                            for (Integer exp = 0; exp < dMlEx.getNumDml(); exp++)
                            { 
                              errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(exp));
                              Apexpages.addMessage(errorMessage);      
                            } 
                            return null; 
                    } catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.Error);
                Apexpages.addMessage(errorMessage);
                Database.rollback(savePoint);
            }
            return null;
        }
        // method invoked to delete row when we click on delete link on Quote to Opportunity block
        public PageReference deleteMappingRowOrder2Opportunity(){
            String sCounter = System.currentPageReference().getParameters().get('counter');
            String id = System.currentPageReference().getParameters().get('id');
            for(integer i=0;i<listCustomMappingPairOrder2Opportunity.size();i++) {                 
                if(sCounter == String.valueOf(listCustomMappingPairOrder2Opportunity[i].iMappingCounter)) {
                    Pair pair = new pair();
                    pair = listCustomMappingPairOrder2Opportunity.get(i);
                    if(Pair.customMapping.Id != null) {
                        delete pair.customMapping;
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info, system.Label.RecordDeletedSuccessfully);
                        Apexpages.addMessage(infoMessage);
                    }
                    listCustomMappingPairOrder2Opportunity.remove(i);
                    break;
                }
            }
            return null;
        }
        //=========END   INVOICEIT-573 ===================== 
        //=========Start   INVOICEIT-541 ===================== 
        //method invoked to create new row when we click on New button on Quote to Opportunity block
        public void addMappingRowOrder2Quote() {
            customMappingButtonValue = System.currentPageReference().getParameters().get('Order2Quote');
            destinationObjectNames = new  list<SelectOption>();
            destinationObjectNames.add(new SelectOption( '' , '--None--'));
            Pair obj = new Pair();
            obj.customMapping = new Custom_Mappings__c();
            obj.iMappingCounter = ++iMappingCounter;
            obj.SourceObjectNames = objectNamesOrder2Quote;
            obj.destinationObjectNames = destinationObjectNames;
            listCustomMappingPairOrder2Quote.add(obj); 
            mapCounter_MappingPair.put(obj.iMappingCounter,obj);
        }
        public PageReference saveCustomMappingOrder2Quote(){
            Savepoint savePoint;
            integer i=0;
            try {    
                savePoint = Database.setSavepoint();
                list<Custom_Mappings__c> listOfcustomMapping = new list<Custom_Mappings__c>();       
                for(Pair pair : listCustomMappingPairOrder2Quote) {
                    pair.customMapping.Name = System.now() +' ' +pair.iMappingCounter ; 
                    pair.customMapping.Category__c = 'Order2Quote';
                    listOfcustomMapping.add(pair.customMapping);
                }
                upsert listOfcustomMapping ;
                Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info, system.Label.RecordsSavedSuccessfully);
                Apexpages.addMessage(infoMessage);
            } catch(DMLException dMlEx){
                            // Added by Lopamudra ticket : INVOICEIT-310 
                            Apexpages.Message errorMessage; 
                            for (Integer exp = 0; exp < dMlEx.getNumDml(); exp++)
                            { 
                              errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(exp));
                              Apexpages.addMessage(errorMessage);      
                            } 
                            return null; 
                    } catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.Error);
                Apexpages.addMessage(errorMessage);
                Database.rollback(savePoint);
            }
            return null;
        }
        // method invoked to delete row when we click on delete link on Quote to Opportunity block
        public PageReference deleteMappingRowOrder2Quote(){
            String sCounter = System.currentPageReference().getParameters().get('counter');
            String id = System.currentPageReference().getParameters().get('id');
            for(integer i=0;i<listCustomMappingPairOrder2Quote.size();i++) {                 
                if(sCounter == String.valueOf(listCustomMappingPairOrder2Quote[i].iMappingCounter)) {
                    Pair pair = new pair();
                    pair = listCustomMappingPairOrder2Quote.get(i);
                    if(Pair.customMapping.Id != null) {
                        delete pair.customMapping;
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info, system.Label.RecordDeletedSuccessfully);
                        Apexpages.addMessage(infoMessage);
                    }
                    listCustomMappingPairOrder2Quote.remove(i);
                    break;
                }
            }
            return null;
        }
         
        //=========END   INVOICEIT-541 ===================== 
        // method invoked to save general mapping records when we click on Save button on General block
        public PageReference saveCustomMappingGeneral() {
            Savepoint savePoint;
            integer i=0;
            try {    
                savePoint = Database.setSavepoint();
                list<Custom_Mappings__c> listOfcustomMapping = new list<Custom_Mappings__c>();       
                for(Pair pair : listCustomMappingPairGeneral) {
                    pair.customMapping.Name = System.now() +' ' +pair.iMappingCounter ; 
                    pair.customMapping.Category__c = 'General';
                    listOfcustomMapping.add(pair.customMapping);
                }
                upsert listOfcustomMapping ;
                Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info, system.Label.Records_Saved);
                Apexpages.addMessage(infoMessage);
            } catch(DMLException dMlEx){
                            // Added by Lopamudra ticket : INVOICEIT-310
                            Apexpages.Message errorMessage; 
                            for (Integer exp = 0; exp < dMlEx.getNumDml(); exp++)
                            { 
                              errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(exp));
                              Apexpages.addMessage(errorMessage);      
                            } 
                            return null; 
                    } catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.Error);
                Apexpages.addMessage(errorMessage);
                Database.rollback(savePoint);
            }

            return null;
        }

        // method invoked to save general mapping records when we click on Save button on Quote to order
        public PageReference saveCustomMappingQuote2Order() {
            Savepoint savePoint;
            integer i=0;
            try {    
                savePoint = Database.setSavepoint();
                list<Custom_Mappings__c> listOfcustomMapping = new list<Custom_Mappings__c>();       
                for(Pair pair : listCustomMappingPairQuote2Order) {
                    pair.customMapping.Name = System.now() +' ' +pair.iMappingCounter ; 
                    pair.customMapping.Category__c = 'Quote2Order';
                    listOfcustomMapping.add(pair.customMapping);
                }
                upsert listOfcustomMapping ;
                Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info, system.Label.Records_Saved);
                Apexpages.addMessage(infoMessage);
            } catch(DMLException dMlEx){
                            // Added by Lopamudra ticket : INVOICEIT-310 
                            Apexpages.Message errorMessage; 
                            for (Integer exp = 0; exp < dMlEx.getNumDml(); exp++)
                            { 
                              errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(exp));
                              Apexpages.addMessage(errorMessage);      
                            } 
                            return null; 
                    } catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.Error);
                Apexpages.addMessage(errorMessage);
                Database.rollback(savePoint);
            }

            return null;
        }

        // method invoked to save general mapping records when we click on Save button on Opportuinty to order
        public PageReference saveCustomMappingOpp2Order() {
            Savepoint savePoint;
            integer i=0;
            try {    
                savePoint = Database.setSavepoint();
                list<Custom_Mappings__c> listOfcustomMapping = new list<Custom_Mappings__c>();       
                for(Pair pair : listCustomMappingPairOpp2Order) {
                    pair.customMapping.Name = System.now() +' ' +pair.iMappingCounter ; 
                    pair.customMapping.Category__c = 'Opp2Order';
                    listOfcustomMapping.add(pair.customMapping);
                }
                upsert listOfcustomMapping ;
                Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info, system.Label.Records_Saved);
                Apexpages.addMessage(infoMessage);
            } catch(DMLException dMlEx){
                    // Added by Lopamudra ticket : INVOICEIT-310
                    Apexpages.Message errorMessage; 
                    for (Integer exp = 0; exp < dMlEx.getNumDml(); exp++)
                    { 
                      errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(exp));
                      Apexpages.addMessage(errorMessage);      
                    } 
                    return null; 
            } catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.Error);
                Apexpages.addMessage(errorMessage);
                Database.rollback(savePoint);
            }

            return null;
        }

        // method invoked to save general mapping records when we click on Save button on Opportunity to Quote block
        public PageReference saveCustomMappingOpp2Quote() {
            Savepoint savePoint;
            integer i=0;
            try {    
                savePoint = Database.setSavepoint();
                list<Custom_Mappings__c> listOfcustomMapping = new list<Custom_Mappings__c>();       
                for(Pair pair : listCustomMappingPairOpp2Quote) {
                    pair.customMapping.Name = System.now() +' ' +pair.iMappingCounter ; 
                    pair.customMapping.Category__c = 'Opp2Quote';
                    listOfcustomMapping.add(pair.customMapping);
                }
                upsert listOfcustomMapping ;
                Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info, system.Label.Records_Saved);
                Apexpages.addMessage(infoMessage);
            } catch(DMLException dMlEx){
                            // Added by Lopamudra ticket : INVOICEIT-310
                            Apexpages.Message errorMessage; 
                            for (Integer exp = 0; exp < dMlEx.getNumDml(); exp++)
                            { 
                              errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(exp));
                              Apexpages.addMessage(errorMessage);      
                            } 
                            return null; 
                    } catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.Error);
                Apexpages.addMessage(errorMessage);
                Database.rollback(savePoint);
            }

            return null;
        }

        // method invoked to create new row on product filter section when we click on new button of the product filter section
        public void addNewFilter() {

            destinationObjectNames = new  list<SelectOption>();
            destinationObjectNames.add(new SelectOption( '' , '--None--'));
            Pair obj = new Pair();
            obj.productFilterCriteria = new Product_Catalog_Filter_Criteria__c();
            obj.iFilterCounter = ++iFilterCounter;
            obj.SourceObjectNames = objectProductFilterNames;
            obj.destinationObjectNames = destinationObjectNames;  
            listFilterPair.add(obj);      
            mapCounter_FilterPair.put(obj.iFilterCounter,obj);
        } 

        // method invoked to delete row on product filter section when we click on delete link of the product filter section
        public PageReference deleteFilterRow(){
            String sCounter = System.currentPageReference().getParameters().get('counter');
            String id = System.currentPageReference().getParameters().get('id');

            for(integer i=0;i<listFilterPair.size();i++) {

                if(sCounter == String.valueOf(listFilterPair[i].iFilterCounter)) {
                    Pair pair = new pair();
                    pair = listFilterPair.get(i);
                    //removing message when we delete opportnity mapping.
                    //if(Pair.productFilterCriteria.Source_Object__c == 'Opportunity'){
                    if(Pair.productFilterCriteria.Source_Object__c == 'Opportunity'){
                        isExtensionInstalled = false;   
                    }
                    if(Pair.productFilterCriteria.Id != null ) {
                        delete pair.productFilterCriteria;
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info, system.Label.RecordDeleted);
                        Apexpages.addMessage(infoMessage);
                    }
                    listFilterPair.remove(i);
                    break;
                }
            }
            return null;
        }

        //method invoked to save new record in  product filter section when we click on Save button of the product filter section
        public PageReference saveProductFilter() {
            Savepoint savePoint;
            integer i=0;
            try {    
                savePoint = Database.setSavepoint();
                list<Product_Catalog_Filter_Criteria__c> listOfProductFilterCriteria = new list<Product_Catalog_Filter_Criteria__c>();       
                for(Pair pair : listFilterPair) {
                    pair.productFilterCriteria.Name = System.now() +' ' +pair.iFilterCounter ; 
                    listOfProductFilterCriteria.add(pair.productFilterCriteria);
                }
                upsert listOfProductFilterCriteria ;
                Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info, system.Label.Records_Saved);
                Apexpages.addMessage(infoMessage);
            } catch(DMLException dMlEx){
                            // Added by Lopamudra ticket : INVOICEIT-310
                            Apexpages.Message errorMessage; 
                            for (Integer exp = 0; exp < dMlEx.getNumDml(); exp++)
                            { 
                              errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(exp));
                              Apexpages.addMessage(errorMessage);      
                            } 
                            return null; 
                    } catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.Error);
                Apexpages.addMessage(errorMessage);
                Database.rollback(savePoint);
            }

            return null;
        }

      //@purpose : Inner Class resposible holding all the required information for set up page.  @author  : Asish Kumar Behera.

        public class Pair {  
            public Custom_Mappings__c customMapping{get; set;}
            public Product_Catalog_Filter_Criteria__c productFilterCriteria{get; set;}
            public integer iMappingCounter {get; set;}
            public integer iFilterCounter {get; set;}
            public List<SelectOption> sourcefieldNames{get;set;}
            public List<SelectOption> destinationfieldNames{get;set;}
            public List<SelectOption> SourceObjectNames{get;set;}
            public List<SelectOption> destinationObjectNames{get;set;}     
        }   
        //method invoked when we click on product filter link on left side
        public Pagereference refreshProductFilter() {
            return null;
        }    

        //method invoked when we click on custom mapping link on left side and checking whether extension is installed or not.
        public Pagereference refreshCustomMapping() {
            Boolean isInstalled = ProductCreationUtil.checkingExtensionInstalled();
            // if not installed then we are hiding two block related to oppt.
            if(!isInstalled){
                isExtensionInstalled = false;           
            } 
            else{
                isExtensionInstalled = true; 
            }        
            return null;
        } 

        public Pagereference selectOrderSelectALL(){
            if(isSelectAll){
                for(ClassMultipicklistForSetup classSetup : listClassMultiPicklist){
                    classSetup.isSelected = true;
                }
            }
            else{
                for(ClassMultipicklistForSetup classSetup : listClassMultiPicklist){
                    classSetup.isSelected = false;
                }
            }

            return null;
        }
        //method invoked when we change destination object
        public PageReference destinationFields() {
            Pair selectedClass;
            List<SelectOption> objectFields = new List<SelectOption>();
            String sObject_Counter = System.currentPageReference().getParameters().get('objectCounter');
            getSelectedClass(sObject_Counter);
            return null;
        }
        //method invoked when we click on edit link of custom setting record to edit some value 
        public Pagereference editPicklistSetupRecord(){
            displayPicklistPopUp = true;
            mapInvoiceITSettings = ProductCreationUtil.getMapInvoiceITSettings();
            map<String,String>  mapFieldValue_Label = new map<String,String>();
            list<String> listExistingFields;
            listExistingFields = new list<String>();
            set<String>  setExistingFields = new set<String>();
            listClassMultiPicklist = new list<ClassMultipicklistForSetup>();
            sIndicator = system.currentPageReference().getParameters().get('picklistIndicator');
            for(Configuration__c config :configurations) {

                if(config.Picklist_Indicator__c != null && sIndicator == config.Picklist_Indicator__c && mapInvoiceITSettings.containsKey(config.Picklist_Indicator__c)) {
                    listAvailableFields = new list<Selectoption>();
                    listSelectedFields = new list<Selectoption>();
                    list<Selectoption>  listAllValues = mapInvoiceITSettings.get(config.Picklist_Indicator__c);

                    String sExistingFields;
                    if(config.String_Value__c != null){
                        sExistingFields = config.String_Value__c;
                    }

                    if(sExistingFields != null && sExistingFields.trim().length() > 0) {
                        listExistingFields = sExistingFields.split(','); 
                        for(String fieldName : listExistingFields) {
                            setExistingFields.add(fieldName);       
                        }
                        for(Selectoption selectoptionValue : listAllValues) {
                            if(!setExistingFields.contains(selectoptionValue.getValue())) {
                                listAvailableFields.add(new SelectOption(selectoptionValue.getValue(),selectoptionValue.getLabel()));        
                            }
                            else {
                                mapFieldValue_Label.put(selectoptionValue.getValue(),selectoptionValue.getLabel());        
                            }
                        } 
                    }
                    else {
                        for(Selectoption selectoptionValue : listAllValues) {
                            listAvailableFields.add(new SelectOption(selectoptionValue.getValue(),selectoptionValue.getLabel()));
                        }       
                    }
                    if(!listExistingFields.isEmpty()){
                        for(String fieldName : listExistingFields) {
                            if(mapFieldValue_Label.containsKey(fieldName)){
                                listSelectedFields.add(new SelectOption(fieldName,mapFieldValue_Label.get(fieldName)));
                            }
                        }       
                    }
                    break;
                    
                    listAvailableFields = new list<Selectoption>();
                    listAvailableFields.addAll(listAllValues );
                }               
            }
            return null;
        }

        // adding selected values in the fields,invoked by clicking on OK button
        public Pagereference saveSelectedSetupValues() {
            displayPicklistPopUp = false;
            for(Configuration__c config :configurations) {
                if(sIndicator == config.Picklist_Indicator__c) {
                    String sFinalValue = '';
                    if(!listSelectedFields.isEmpty()){
                        for(Selectoption selectoptionValue : listSelectedFields) {
                            sFinalValue = sFinalValue +  selectoptionValue.getValue() + ',';                         
                        }
                        sFinalValue = sFinalValue.substring(0, sFinalValue.length() - 1);

                    }
                    config.String_Value__c = sFinalValue;   
                    break;
                }  
            }   
            return null;    
        }
        // method invoked by clicking on Cancel button
        public Pagereference cancelPicklistSetUp() {
            displayPicklistPopUp = false;
            return null;
        }
        // openong modal popoup and updating custom setting record as true so that popup up will appear only once.
        public Pagereference onLoadSetup(){
            boolean isHomepopup = mapConfiguration.get('INVOICEIT_HOME_POPUP').Boolean_value__c;
            if(isHomepopup){
                isModelpopUp = false;  
            }
            else{
                isModelpopUp = true;  
            }
            return null;
        }
        //closing the popup.
        public void closeSetup(){
            Id popupRecordId = mapConfiguration.get('INVOICEIT_HOME_POPUP').Id ;
            Configuration__c invoiceIThome = new Configuration__c(Id= popupRecordId ,Name = 'INVOICEIT_HOME_POPUP' ,Boolean_Value__c = true);       
            update invoiceIThome;   
            isModelpopUp = false;  
        }
    }