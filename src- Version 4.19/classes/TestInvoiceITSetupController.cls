@isTest
    private class TestInvoiceITSetupController {
       public static String sPrefix = CommonUtilClass.getPrefix();
        static testMethod void testInvoiceItSetup() {
            list<Custom_Mappings__c> listCustomMapping = new list<Custom_Mappings__c>();
            listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = 'Name',Destination_Object__c = 'Job_Rate_Plan_Charge__c',Source_Field__c = 'Name',Source_Object__c = 'Quote_Rate_Plan_Charge__c', Name = 'q1',Category__c = 'Quote2Order'));
            listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = sPrefix+'Product_Code__c',Destination_Object__c = 'Job_Product__c',Source_Field__c = sPrefix+'Status__c',Source_Object__c = 'Product__c', Name = 'q4',Category__c = 'General'));
            listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = 'Name',Destination_Object__c = 'Quote__c',Source_Field__c = 'Name',Source_Object__c = 'Opportunity', Name = 'a3',Category__c = 'Opp2Quote'));
            listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = 'Name',Destination_Object__c = 'job__c',Source_Field__c = 'Name',Source_Object__c = 'Opportunity', Name = 'a309',Category__c = 'Opp2Order'));
            listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = 'Name',Destination_Object__c = 'Opportunity',Source_Field__c = 'Name',Source_Object__c = 'Quote__c', Name = 'a31',Category__c = 'Quote2Opportunity'));
            listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = 'Name',Destination_Object__c = 'Opportunity',Source_Field__c = 'Name',Source_Object__c = 'job__c', Name = 'a3091',Category__c = 'Order2Opportunity'));
            insert listCustomMapping;

            Custom_Mappings__c customMappings = [select Destination_Field__c From Custom_Mappings__c where id=:listCustomMapping[0].id];
            System.assertEquals('Name', customMappings.Destination_Field__c);
            
            Configuration__c configuration = new Configuration__c(Field_Type__c = 'String',Name = 'testing12',Category__c = 'General',Picklist_Indicator__c = 'listAccountFields');
            Configuration__c configuration1 = new Configuration__c(Field_Type__c = 'String',Name = 'testing23',Category__c = 'Opportunity');
            Configuration__c configuration2 = new Configuration__c(Field_Type__c = 'String',Name = 'testing234',Category__c = 'Quote',Picklist_Indicator__c = 'listQuoteFields');
            Configuration__c configuration3 = new Configuration__c(Field_Type__c = 'String',Name = 'testing567',Category__c = 'Order',Picklist_Indicator__c = 'listOrderFields');
            Configuration__c configuration4 = new Configuration__c(Field_Type__c = 'String',Name = 'testing7654321',Category__c = 'Invoice',Picklist_Indicator__c = 'listInvoiceGeneration');
            
            list<Configuration__c> lstConfig = new list<Configuration__c>();
            lstConfig.add(configuration);
            lstConfig.add(configuration1);
            lstConfig.add(configuration2);
            lstConfig.add(configuration3);
            lstConfig.add(configuration4);
            
            insert lstConfig;
            
            list<Product_Catalog_Filter_Criteria__c> listFilters = new list<Product_Catalog_Filter_Criteria__c>();
            listFilters.add(new Product_Catalog_Filter_Criteria__c(Destination_Field__c = 'CurrencyL__c',Destination_Object__c = 'Product_Rate_Plan_Charge__c',Source_Field__c = 'CurrencyL__c',Source_Object__c = 'Job__c', Name = 'a1'));
            listFilters.add(new Product_Catalog_Filter_Criteria__c(Destination_Field__c = 'CurrencyL__c',Destination_Object__c = 'Product_Rate_Plan_Charge__c',Source_Field__c = 'CurrencyL__c',Source_Object__c = 'Quote__c', Name = 'a2'));
            listFilters.add(new Product_Catalog_Filter_Criteria__c(Destination_Field__c = 'Name',Destination_Object__c = 'Product__c',Source_Field__c = 'Name',Source_Object__c = 'Job__c', Name = 'a3'));
            listFilters.add(new Product_Catalog_Filter_Criteria__c(Destination_Field__c = 'Name',Destination_Object__c = 'Product__c',Source_Field__c = 'Name',Source_Object__c = 'Quote__c', Name = 'a4'));
            listFilters.add(new Product_Catalog_Filter_Criteria__c(Destination_Field__c = 'CurrencyL__c',Destination_Object__c = 'Product_Rate_Plan_Charge__c',Source_Field__c = 'CurrencyL__c',Source_Object__c = 'Job__c', Name = 'a19013'));
            insert listFilters; 
            
            System.URL.getCurrentRequestUrl().toExternalForm();
            InvoiceITSetupController invSetup = new InvoiceITSetupController();
            
            invSetup.configurations = lstConfig;
            invSetup.saveInvoiceITSettings();
            
            System.currentPageReference().getParameters().put('category', 'General');
            invSetup.getCategory();
            
            System.currentPageReference().getParameters().put('category','Opportunity');
            invSetup.getCategory();
            System.currentPageReference().getParameters().put('category','Quote');
            invSetup.getCategory();
            System.currentPageReference().getParameters().put('category','Order');
            invSetup.getCategory();
            System.currentPageReference().getParameters().put('category','Invoice');
            invSetup.getCategory();
            //invSetup.filters = listFilters;
            invSetup.saveProductFilter_old();
            System.currentPageReference().getParameters().put('id', listFilters.get(0).id);
            invSetup.deleteFilterRow_old();
            
            invSetup.mappings = listCustomMapping;
            invSetup.addMappingRow_old();
            Custom_Mappings__c mapping = new Custom_Mappings__c();
            listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = sPrefix+'Product_Code__c',Destination_Object__c = 'Job_Product__c',Source_Field__c = sPrefix+'Status__c',Source_Object__c = 'Product__c', Name = 'q409876',Category__c = 'General'));
            //invSetup.saveCustomMapping_old();
            System.currentPageReference().getParameters().put('id', listCustomMapping.get(0).id);
            invSetup.deleteMappingRow_old();
            
            string s = 'Job_Product__c';
            List<SelectOption> selOpts = invSetup.ObjectFieldsGet(s);
            
            invSetup.initProductFilterObjNames();
            invSetup.initObjNames();
            
            List<SelectOption> selOpts1 = invSetup.ObjectFieldsGetCustomMapping(s,'');
            string s1 = 'Opportunity_Product__c';
            List<SelectOption> selOpts2 = invSetup.ObjectFieldsGetCustomMapping(s1,'');
            
            System.currentPageReference().getParameters().put('objectCounter', 'productFilter-0-Source-Job__c');
            invSetup.ObjectFields();
            System.currentPageReference().getParameters().put('objectCounter', 'productFilter-0-Destination-Job__c');
            invSetup.destinationFields();
            System.currentPageReference().getParameters().put('objectCounter', 'productFilter-0-Source-Opportunity');
            invSetup.ObjectFields();
            System.currentPageReference().getParameters().put('objectCounter', 'productFilter-0-Destination-Opportunity');
            invSetup.destinationFields();
            System.currentPageReference().getParameters().put('objectCounter', 'customMapping-1-Source-General-Product_Rate_Plan__c');
            invSetup.ObjectFields();
            System.currentPageReference().getParameters().put('objectCounter', 'customMapping-1-Destination-General-Job_Rate_Plan__c');
            invSetup.destinationFields(); 
            
            PageReference pageRef9 = invSetup.refreshProductFilter();
            PageReference pageRef8 = invSetup.refreshCustomMapping();
            PageReference pageRef7 = invSetup.editPicklistSetupRecord();
            PageReference pageRef5 = invSetup.saveSelectedSetupValues();
            PageReference pageRef6 = invSetup.cancelPicklistSetUp();
            
            invSetup.addNewFilter();
            
            invSetup.addMappingRowGeneral();
            invSetup.addMappingRowQuote2Order();
            invSetup.addMappingRowOpp2Order();
            invSetup.addMappingRowOpp2Quote();
            invSetup.addMappingRowQuote2Opportunity();
            invSetup.addMappingRowOrder2Opportunity();
            PageReference pageRef = invSetup.saveCustomMappingGeneral();
            PageReference pageRef1 = invSetup.saveCustomMappingQuote2Order();
            PageReference pageRef2 = invSetup.saveCustomMappingOpp2Order();
            PageReference pageRef3 = invSetup.saveCustomMappingOpp2Quote();
            PageReference pageRef4 = invSetup.saveProductFilter();
            PageReference pageRef51 = invSetup.saveCustomMappingQuote2Opportunity();
            PageReference pageRef61 = invSetup.saveCustomMappingOrder2Opportunity();

            
            System.currentPageReference().getParameters().put('counter', '0');
            System.currentPageReference().getParameters().put('id', listFilters.get(1).id);
            
            System.currentPageReference().getParameters().put('counter', '0');
            System.currentPageReference().getParameters().put('id', listCustomMapping.get(2).id);
            PageReference pageRef11 = invSetup.deleteMappingRowOpp2Quote();
            
            System.currentPageReference().getParameters().put('counter', '0');
            System.currentPageReference().getParameters().put('id', listCustomMapping.get(1).id);
            PageReference pageRef12 = invSetup.deleteMappingRowGeneral();
            
            System.currentPageReference().getParameters().put('counter', '0');
            System.currentPageReference().getParameters().put('id', listCustomMapping.get(0).id);
            
            System.currentPageReference().getParameters().put('counter', '0');
            System.currentPageReference().getParameters().put('id', listCustomMapping.get(3).id);
            PageReference pageRef14 = invSetup.deleteMappingRowOpp2Order();

            System.currentPageReference().getParameters().put('counter', '0');
            System.currentPageReference().getParameters().put('id', listCustomMapping.get(4).id);
            PageReference pageRef15 = invSetup.deleteMappingRowQuote2Opportunity();

            System.currentPageReference().getParameters().put('counter', '0');
            System.currentPageReference().getParameters().put('id', listCustomMapping.get(5).id);
            PageReference pageRef16 = invSetup.deleteMappingRowOrder2Opportunity();

        } 
        
        static testMethod void testQuickStartWizardController() {
            Configuration__c configuration = new Configuration__c(Field_Type__c = 'String',String_Value__c = 'status__c',Name = 'testing12',Category__c = 'General',Picklist_Indicator__c = 'listAccountFields',Quick_Screen_Id__c ='1');
            Configuration__c configuration1 = new Configuration__c(Field_Type__c = 'String',Name = 'testing23',String_Value__c = 'status__c',Category__c = 'Opportunity',Quick_Screen_Id__c ='2');
            Configuration__c configuration2 = new Configuration__c(Field_Type__c = 'String',Name = 'testing234',String_Value__c = 'status__c',Category__c = 'Quote',Picklist_Indicator__c = 'listQuoteFields',Quick_Screen_Id__c ='3');
            Configuration__c configuration3 = new Configuration__c(Field_Type__c = 'String',Name = 'testing567',String_Value__c = 'status__c',Category__c = 'Order',Picklist_Indicator__c = 'listOrderFields',Quick_Screen_Id__c ='4');
            Configuration__c configuration4 = new Configuration__c(Field_Type__c = 'String',Name = 'testing7654321',String_Value__c = 'status__c',Category__c = 'Invoice',Picklist_Indicator__c = 'listInvoiceGeneration',Quick_Screen_Id__c ='5');
            Configuration__c configuration5 = new Configuration__c(Field_Type__c = 'String',Name = 'INVOICEIT_HOME_POPUP');
            list<Configuration__c> lstConfig = new list<Configuration__c>();
            lstConfig.add(configuration);
            lstConfig.add(configuration1);
            lstConfig.add(configuration2);
            lstConfig.add(configuration3);
            lstConfig.add(configuration4);
            lstConfig.add(configuration5);
            
            insert lstConfig;
            
            Configuration__c config = [select Field_Type__c, Name from Configuration__c where id=:lstConfig[0].id];
            System.assertEquals('testing12', config.Name);
            
            QuickStartWizardController startWizardController = new QuickStartWizardController();
            System.currentPageReference().getParameters().put('QuickScreenId', '1');
            System.currentPageReference().getParameters().put('picklistIndicator', '1');
            PageReference pageRef = startWizardController.editPicklistSetupRecord();
            
            //modified by lopa
            startWizardController.getQuickScreen();
            
            System.currentPageReference().getParameters().put('QuickScreenId', '2');
            System.currentPageReference().getParameters().put('picklistIndicator', '2');
            PageReference pageRef1 = startWizardController.editPicklistSetupRecord();
            
            System.currentPageReference().getParameters().put('QuickScreenId', '3');
            System.currentPageReference().getParameters().put('picklistIndicator', '3');
            PageReference pageRef2 = startWizardController.editPicklistSetupRecord();
            
            System.currentPageReference().getParameters().put('QuickScreenId', '4');
            System.currentPageReference().getParameters().put('picklistIndicator', '4');
            PageReference pageRef3 = startWizardController.editPicklistSetupRecord();
            
            System.currentPageReference().getParameters().put('QuickScreenId', '5');
            System.currentPageReference().getParameters().put('picklistIndicator', '5');
            //startWizardController.isInstalled = true;
            PageReference pageRef4 = startWizardController.editPicklistSetupRecord();
            
            PageReference pageRef5 = startWizardController.saveInvoiceITSettings();
            PageReference pageRef6 = startWizardController.quickSaveInvoiceITSettings();
            
            PageReference pageRef7 = startWizardController.saveSelectedSetupValues();
            
            PageReference pageRef8 = startWizardController.cancelPicklistSetUp();
            PageReference pageRef9 = startWizardController.refreshPrevious();
            PageReference pageRef11 = startWizardController.cancelQuickStartWizard(); 
            
            PageReference pageRef12 = startWizardController.quickSaveStep2();
            PageReference pageRef13 = startWizardController.quickSaveStep3();
            PageReference pageRef14 = startWizardController.quickSaveStep4();
            
            startWizardController.constructFinalPicklist(lstConfig);
            startWizardController.showingOpptMessage();
            startWizardController.onLoadQuickStartWizard();
            startWizardController.exitQuickStartWizard();
            
            startWizardController.sQuickScreenId = '1';
            PageReference pageRef15 = startWizardController.saveSelectedSetupValues();
            
            startWizardController.sQuickScreenId = '2';
            PageReference pageRef16 = startWizardController.saveSelectedSetupValues();
            
            startWizardController.sQuickScreenId = '3';
            PageReference pageRef17 = startWizardController.saveSelectedSetupValues();
            
            startWizardController.sQuickScreenId = '4';
            PageReference pageRef18 = startWizardController.saveSelectedSetupValues();
            
        }
    }