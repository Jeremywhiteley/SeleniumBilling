/**
         *@purpose : Apex Controller resposible for new set up wizard pages
         *@author  : Asish Kumar Behera INVOICEIT-326
         **/
        public with sharing class QuickStartWizardController {

                //All variable declaration
                public list<Configuration__c> configurations {get; set;}
                public list<Configuration__c> configurations1 {get; set;}
                public list<Configuration__c> configurations2 {get; set;}
                public list<Configuration__c> configurations3 {get; set;}
                public list<Configuration__c> configurations4 {get; set;}
                public list<Configuration__c> configurations5 {get; set;}
                public String sQuickScreenId {get; set;}
                public boolean displaySettings {get; set;}
                public String sBaseURL {get; set;}
                public String sCategory {get; set;}

                // added new code Filters
                public boolean isSelectAll {get; set;}
                public list<ClassMultipicklistForSetup>  listClassMultiPicklist {get;set;}
                public String sIndicator ;
                public list<Selectoption>  listAvailableFields {get;set;}
                public list<Selectoption>  listSelectedFields {get;set;}
                
                public boolean displayPicklistPopUp {get; set;}
                public list<SelectOption> listPaymentTerms {get; set;}
                public list<SelectOption> listRecordsPage2  {get; set;}
                public list<SelectOption> listOrderFieldsForDiscountCode {get; set;}
                public list<SelectOption> listQuoteFieldsForDiscountCode {get; set;}
                public list<SelectOption> listProductValueToRollUp {get; set;}
                public list<SelectOption> listPaymentSchedulerDates {get; set;}
                public list<SelectOption> listInvoiceGeneration {get; set;}
                public list<SelectOption> listOrderStatusfields {get; set;}
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
                public map<String,list<SelectOption>> mapInvoiceITSettings;
                private map<String, Configuration__c> mapConfiguration;
                
                //boolean variable to set in page to renrder opptblock
                public Boolean isExtensionInstalled{get;set;}
                
                //boolean variable to identify extension package is installed or not
                public Boolean isInstalled;
                
                //constructor
                public QuickStartWizardController() {
                    isInstalled = false;
                        configurations1 = [select Name,Description__c ,Field_Type__c,Percentage_Value__c,Number_Value__c,Category__c,Sequence__c,Boolean_Value__c,Date_Value__c,String_Value__c,Picklist_Indicator__c  from Configuration__c where Quick_Screen_Id__c =:'1' order by Sequence__c ];    
                        configurations2 = [select Name,Description__c ,Field_Type__c,Percentage_Value__c,Number_Value__c,Category__c,Sequence__c,Boolean_Value__c,Date_Value__c,String_Value__c,Picklist_Indicator__c  from Configuration__c where Quick_Screen_Id__c =:'2' order by Sequence__c ];
                        configurations3 = [select Name,Description__c ,Field_Type__c,Percentage_Value__c,Number_Value__c,Category__c,Sequence__c,Boolean_Value__c,Date_Value__c,String_Value__c,Picklist_Indicator__c  from Configuration__c where Quick_Screen_Id__c =:'3' order by Sequence__c ];
                        configurations4 = [select Name,Description__c ,Field_Type__c,Percentage_Value__c,Number_Value__c,Category__c,Sequence__c,Boolean_Value__c,Date_Value__c,String_Value__c,Picklist_Indicator__c  from Configuration__c where Quick_Screen_Id__c =:'4' order by Sequence__c ];
                        //checking extension package is installed or not then only quering opportunity related information
                        
                        //invoking method to get constructed data which are related to Quote ,order ang general
                        mapInvoiceITSettings = ProductCreationUtil.getMapInvoiceITSettings();
                        
                        //getting all the configuration record which will be used to make modal popup display only one time
                        mapConfiguration = Configuration__c.getAll();
                        
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
                        isExtensionInstalled = true;
                        
                        //checking extension package is installed or not then only quering opportunity related information and constructing map
                        isInstalled = ProductCreationUtil.IsOppInstalled();
                        if(isInstalled){
                            mapInvoiceITSettings.putAll(ProductCreationUtil.gettingOpportunityMapping());    
                            configurations5 = [select Name,Description__c ,Field_Type__c,Percentage_Value__c,Number_Value__c,Category__c,Sequence__c,Boolean_Value__c,Date_Value__c,String_Value__c,Picklist_Indicator__c  from Configuration__c where Quick_Screen_Id__c =:'5' order by Sequence__c ];
                            listOpportunityCharges =  mapInvoiceITSettings.get('listOpportunityCharges');
                            listOpportunityStage =  mapInvoiceITSettings.get('listOpportunityStage');
                            listOpportunityCharges1 =  mapInvoiceITSettings.get('listOpportunityCharges1');
                        }

                }
                
                
                public void getQuickScreen() {
                        sQuickScreenId =   system.currentPageReference().getParameters().get('QuickScreenId');
                }
               //method called when we click on edit link of quickwizard page.
                public Pagereference editPicklistSetupRecord(){
                        displayPicklistPopUp = true;
                        sIndicator = system.currentPageReference().getParameters().get('picklistIndicator');
                        sQuickScreenId =   system.currentPageReference().getParameters().get('QuickScreenId');
                        if(sQuickScreenId =='1'){
                                loadValuesToMultipicklist(configurations1,sIndicator);  
                        }
                        else if(sQuickScreenId =='2'){
                                loadValuesToMultipicklist(configurations2,sIndicator);  
                        }
                        else if(sQuickScreenId =='3'){
                                loadValuesToMultipicklist(configurations3,sIndicator);  
                        }
                        else if(sQuickScreenId =='4'){
                                loadValuesToMultipicklist(configurations4,sIndicator);  
                        }
                        else if(sQuickScreenId =='5'  && isInstalled){
                                loadValuesToMultipicklist(configurations5,sIndicator);  
                        }
                        return null;
                }

                // method to construct picklist 
                public void loadValuesToMultipicklist(list<Configuration__c> configurations,String sIndicator){
                        mapInvoiceITSettings = ProductCreationUtil.getMapInvoiceITSettings(); 
                        set<String>  setExistingFields = new set<String>();
                        listClassMultiPicklist = new list<ClassMultipicklistForSetup>();
                        map<String,String>  mapFieldValue_Label = new map<String,String>();
                        list<String> listExistingFields;
                        listExistingFields = new list<String>();
                        for(Configuration__c config :configurations) {
                            if(config.Picklist_Indicator__c != null && sIndicator == config.Picklist_Indicator__c && mapInvoiceITSettings.containsKey(config.Picklist_Indicator__c)) {         
                                listAvailableFields = new list<Selectoption>();
                                listSelectedFields = new list<Selectoption>();
                                list<Selectoption>  listAllValues = mapInvoiceITSettings.get(config.Picklist_Indicator__c);
                                 
                                /* Solving null pointer Excepttions and showing some message If there is no field to edit.
                                         * Modified Asish Behera INV-323 Anil's comments
                                         */    
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
                                
                            }               
                        }       
                }
                
                /**
                 *@purpose : Method to save custom setting records invoked by clicking on Save and Exit button 
                 *@author  : Asish Kumar Behera.@Return :   Pagereference
                 **/
                public PageReference saveInvoiceITSettings(){
                        list<Configuration__c>  listConfigurations = new  list<Configuration__c>();
                        for(Configuration__c config1 : configurations1) {
                                listConfigurations.add(config1);        
                        }
                        for(Configuration__c config2 : configurations2) {
                                listConfigurations.add(config2);        
                        }
                        for(Configuration__c config3 : configurations3) {
                                listConfigurations.add(config3);        
                        }
                        for(Configuration__c config4 : configurations4) {
                                listConfigurations.add(config4);        
                        }
                        if(isInstalled){
                            for(Configuration__c config5 : configurations5) {
                                listConfigurations.add(config5);        
                            }   
                        }
                        update listConfigurations;

                        PageReference  pageReference = new PageReference('/apex/invoiceITHome');
                        pageReference.setRedirect(true);
                        return pageReference ;
                }
                
                /**
                 *@purpose : Method to save custom setting records invoked by clicking on Qucik Save button 
                 *@author  : Asish Kumar Behera.@Return :   Pagereference
                 **/
                
                 public PageReference quickSaveInvoiceITSettings(){
                        list<Configuration__c>  listConfigurations = new  list<Configuration__c>();
                        for(Configuration__c config1 : configurations1) {
                                listConfigurations.add(config1);        
                        }
                        for(Configuration__c config2 : configurations2) {
                                listConfigurations.add(config2);        
                        }
                        for(Configuration__c config3 : configurations3) {
                                listConfigurations.add(config3);        
                        }
                        for(Configuration__c config4 : configurations4) {
                                listConfigurations.add(config4);        
                        }
                        if(isInstalled){
                            for(Configuration__c config5 : configurations5) {
                                    listConfigurations.add(config5);        
                            }
                        }
                        update listConfigurations;

                        //Added by Shruthi related to INVOICEIT-200
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info,system.Label.Records_Saved);
                        Apexpages.addMessage(infoMessage);
                        return null;
                }
                
                
               /**
                 *@purpose : Method to update selcted values in the fields 
                 *@author  : Asish Kumar Behera.@Return :   Pagereference
                 **/
                public Pagereference saveSelectedSetupValues() {
                        displayPicklistPopUp = false;
                        if(sQuickScreenId =='1'){
                                constructFinalPicklist(configurations1);        
                        }
                        else if(sQuickScreenId =='2'){
                                constructFinalPicklist(configurations2);        
                        }
                        else if(sQuickScreenId =='3'){
                                constructFinalPicklist(configurations3);        
                        }
                        else if(sQuickScreenId =='4'){
                                constructFinalPicklist(configurations4);        
                        }
                        else if(sQuickScreenId =='5' && isInstalled){
                                constructFinalPicklist(configurations5);        
                        }

                        return null;    
                }

                public void constructFinalPicklist(list<Configuration__c>  configurations){
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
                }

                public Pagereference cancelPicklistSetUp() {
                        displayPicklistPopUp = false;
                        return null;
                }
                
                public Pagereference refreshPrevious() {
                        return null;        
                }
                public void showingOpptMessage() {
                    
                    Boolean isInstalledCheck = ProductCreationUtil.checkingExtensionInstalled();
                    if(!isInstalledCheck){
                        isExtensionInstalled = false;        
                    }
                }
                
                public Pagereference cancelQuickStartWizard() {
                       PageReference  pageReference = new PageReference('/apex/invoiceITHome');
                       pageReference.setRedirect(true);
                       return pageReference ;
                }
                
                public Pagereference quickSaveStep2() {
                        update configurations2;
                        //Added by Shruthi related to INVOICEIT-200
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info,system.Label.Records_Saved);
                    Apexpages.addMessage(infoMessage);
                        return null;
                }
                
                public Pagereference quickSaveStep3() {
                        update configurations3;
                        //Added by Shruthi related to INVOICEIT-200
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info,system.Label.Records_Saved);
                    Apexpages.addMessage(infoMessage);
                        return null;
                }
                
                public Pagereference quickSaveStep4() {
                        update configurations4;
                        //Added by Shruthi related to INVOICEIT-200
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Info,system.Label.Records_Saved);
                    Apexpages.addMessage(infoMessage);
                        return null;
                }
                
                 //commented by ram AH-212, we are updaing value in invoiceit home tab page
                public void onLoadQuickStartWizard(){
                        Id popupRecordId = mapConfiguration.get('INVOICEIT_HOME_POPUP').Id ;
                        Configuration__c invoiceIThome = new Configuration__c(Id= popupRecordId ,Name = 'INVOICEIT_HOME_POPUP' ,Boolean_Value__c = true);       
                        update invoiceIThome;   
                } 
                        
                public PageReference exitQuickStartWizard() {
                    PageReference  pageReference = new PageReference('/apex/invoiceITHome');
                    pageReference.setRedirect(true);
                    return pageReference ;
                }
                        
        }