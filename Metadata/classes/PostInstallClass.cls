global class PostInstallClass implements InstallHandler {
      global void onInstall(InstallContext context) {
            try {
                ControllerInsertCustomSettings c = new ControllerInsertCustomSettings();
                c.insertValues();
                if(context.previousVersion() == null) {
                    map<string,Currency__c> mapOfCurrencyValuesToInserted = new map<string,Currency__c>();
                    mapOfCurrencyValuesToInserted.put('EUR', new Currency__c(Name = 'EUR',  Currency_Symbol__c = '€', Currency_Name__c = 'Euro'));
                    mapOfCurrencyValuesToInserted.put('GBP', new Currency__c(Name = 'GBP',  Currency_Symbol__c = '£', Currency_Name__c = 'United Kingdom Pound'));
                    mapOfCurrencyValuesToInserted.put('USD', new Currency__c(Name = 'USD',  Currency_Symbol__c = '$', Currency_Name__c = 'United States Dollar'));
                    mapOfCurrencyValuesToInserted.put('AUD', new Currency__c(Name = 'AUD',  Currency_Symbol__c = '$', Currency_Name__c = 'Australia Dollar'));
                    mapOfCurrencyValuesToInserted.put('CAD', new Currency__c(Name = 'CAD',  Currency_Symbol__c = '$', Currency_Name__c = 'Canada Dollar'));
                    mapOfCurrencyValuesToInserted.put('JPY', new Currency__c(Name = 'JPY',  Currency_Symbol__c = '¥', Currency_Name__c = 'Japan Yen'));
                    mapOfCurrencyValuesToInserted.put('INR', new Currency__c(Name = 'INR',  Currency_Symbol__c = 'Rs', Currency_Name__c = 'India Rupee'));
                    mapOfCurrencyValuesToInserted.put('CHF', new Currency__c(Name = 'CHF',  Currency_Symbol__c = 'CHF', Currency_Name__c = 'Switzerland Franc'));
                    mapOfCurrencyValuesToInserted.put('NZD', new Currency__c(Name = 'NZD',  Currency_Symbol__c = '$', Currency_Name__c = 'New Zealand Dollar'));
                    mapOfCurrencyValuesToInserted.put('CNY', new Currency__c(Name = 'CNY',  Currency_Symbol__c = '¥', Currency_Name__c = 'Chinese Yuan'));
            
                    Currency__c defaultCurrencyObjOrg;
                    string defaultCurrency = userInfo.getDefaultCurrency();
                    Boolean isCurrencyValuesInMap = false;
                        
                    if(mapOfCurrencyValuesToInserted.containsKey(defaultCurrency)) {
                        isCurrencyValuesInMap = true;
                    }
                    
                    insert mapOfCurrencyValuesToInserted.Values();         
             
                    if(isCurrencyValuesInMap) {
                        defaultCurrencyObjOrg = mapOfCurrencyValuesToInserted.get(defaultCurrency);
                    } else {
                        defaultCurrencyObjOrg = mapOfCurrencyValuesToInserted.get('USD');
                    }
            

                    
                    //Configuration__c defaultCurrecyForOrg = new Configuration__c(Name = 'DEFAULT_CURRENCY', Field_Type__c = 'String', Description__c = 'Mention the ISO code of your default currency here. Say GBP');
                    Configuration__c defaultCurrecyForOrg = new Configuration__c(Name = 'DEFAULT_CURRENCY', STRING_VALUE__C = 'GBP', Field_Type__c = 'String', Description__c = 'Mention the ISO code of your default currency here. Say GBP',Category__c ='General',Picklist_Indicator__c ='listDefaultCurrency',Quick_Screen_Id__c ='3',Sequence__c = 1);
                    defaultCurrecyForOrg.String_Value__c = defaultCurrencyObjOrg.Name;
                    insert defaultCurrecyForOrg;
            
                    map<Integer,Product__c> mapCounterAndProduct = new map<Integer,Product__c>();
                    mapCounterAndProduct.put(1,new Product__c(Name = 'GenWatt Diesel 200kW',Product_Family__c = 'Default', Description__c = 'GenWatt Diesel 200kW',Product_Code__c = 'AC001',Valid_From_Date__c = system.today(),Valid_To_Date__c = system.today().addYears(10)));
                    mapCounterAndProduct.put(2,new Product__c(Name = 'Heavy Duty Power Backup Kit',Product_Family__c = 'Default' ,Description__c = 'Installation: Portable',Product_Code__c = 'AC002',Valid_From_Date__c = system.today(),Valid_To_Date__c = system.today().addYears(10)));
                    mapCounterAndProduct.put(3,new Product__c(Name = 'GenWatt Propane 500kW',Description__c = 'GenWatt Propane 500kW',Product_Family__c = 'Default',Product_Code__c = 'AC003',Valid_From_Date__c = system.today(),Valid_To_Date__c = system.today().addYears(10)));
                    insert mapCounterAndProduct.Values();
            
                    list<Product_Rate_Plan__c> listOfRatePlansToInsert = new list<Product_Rate_Plan__c>();
                    listOfRatePlansToInsert.add(new Product_Rate_Plan__c(Name = 'Members',Product__c = mapCounterAndProduct.get(1).Id,Description__c = 'Members',Valid_From_Date__c = system.today(),Valid_To_Date__c = system.today().addYears(10)));
                    listOfRatePlansToInsert.add(new Product_Rate_Plan__c(Name = 'Non - Members', Product__c = mapCounterAndProduct.get(1).Id ,Description__c = 'Non - Members',Valid_From_Date__c = system.today(),Valid_To_Date__c = system.today().addYears(10)));
                    listOfRatePlansToInsert.add(new Product_Rate_Plan__c(Name = 'Bronze',Product__c = mapCounterAndProduct.get(2).Id, Description__c = 'Bronze',Valid_From_Date__c = system.today(),Valid_To_Date__c = system.today().addYears(10)));
                    listOfRatePlansToInsert.add(new Product_Rate_Plan__c(Name = 'Silver',Product__c = mapCounterAndProduct.get(2).Id, Description__c = 'Silver',Valid_From_Date__c = system.today(),Valid_To_Date__c = system.today().addYears(10)));
                    listOfRatePlansToInsert.add(new Product_Rate_Plan__c(Name = 'Gold',Product__c = mapCounterAndProduct.get(2).Id, Description__c = 'Gold',Valid_From_Date__c = system.today(),Valid_To_Date__c = system.today().addYears(10)));
                    listOfRatePlansToInsert.add(new Product_Rate_Plan__c(Name = 'Default',Product__c = mapCounterAndProduct.get(3).Id, Description__c = 'Default',Valid_From_Date__c = system.today(),Valid_To_Date__c = system.today().addYears(10)));
                    insert listOfRatePlansToInsert;
            
            
                    list<Product_Rate_Plan_Charge__c> listOfPrpcs = new list<Product_Rate_Plan_Charge__c>();
                    listOfPrpcs.add(new Product_Rate_Plan_Charge__c(Name = 'Supply Price', Product_Rate_Plan__c = listOfRatePlansToInsert.get(0).Id, Charge_Sequence_Number__c = 1,CurrencyL__c = defaultCurrencyObjOrg.Id,Price_Type__c = 'One Time',Cost_Price__c = 180,Unit_Price__c = 200,Accounting_Code__c = 'AC'));
                    listOfPrpcs.add(new Product_Rate_Plan_Charge__c(Name = 'Install Price', Product_Rate_Plan__c = listOfRatePlansToInsert.get(0).Id, Charge_Sequence_Number__c = 2,CurrencyL__c = defaultCurrencyObjOrg.Id,Price_Type__c = 'One Time',Cost_Price__c = 90,Unit_Price__c = 100,Accounting_Code__c = 'AC'));
                    listOfPrpcs.add(new Product_Rate_Plan_Charge__c(Name = 'Maintenance Charges', Product_Rate_Plan__c = listOfRatePlansToInsert.get(0).Id, Charge_Sequence_Number__c = 3,CurrencyL__c = defaultCurrencyObjOrg.Id,Price_Type__c = 'Monthly',Cost_Price__c = 1800,Unit_Price__c = 2000,Accounting_Code__c = 'AC'));
            
                    listOfPrpcs.add(new Product_Rate_Plan_Charge__c(Name = 'Supply Price',Product_Rate_Plan__c = listOfRatePlansToInsert.get(1).Id, Charge_Sequence_Number__c = 1,CurrencyL__c = defaultCurrencyObjOrg.Id,Price_Type__c = 'One Time',Cost_Price__c = 180,Unit_Price__c = 220,Accounting_Code__c = 'AC'));
                    listOfPrpcs.add(new Product_Rate_Plan_Charge__c(Name = 'Install Price', Product_Rate_Plan__c = listOfRatePlansToInsert.get(1).Id, Charge_Sequence_Number__c = 2,CurrencyL__c = defaultCurrencyObjOrg.Id,Price_Type__c = 'One Time',Cost_Price__c = 90,Unit_Price__c = 110,Accounting_Code__c = 'AC'));
                    listOfPrpcs.add(new Product_Rate_Plan_Charge__c(Name = 'Maintenance Charges', Product_Rate_Plan__c = listOfRatePlansToInsert.get(1).Id, Charge_Sequence_Number__c = 3,CurrencyL__c = defaultCurrencyObjOrg.Id,Price_Type__c = 'Monthly',Cost_Price__c = 1800,Unit_Price__c = 2200,Accounting_Code__c = 'AC'));
            
                    listOfPrpcs.add(new Product_Rate_Plan_Charge__c(Name = 'Supply Price', Product_Rate_Plan__c = listOfRatePlansToInsert.get(2).Id, Charge_Sequence_Number__c = 1,CurrencyL__c = defaultCurrencyObjOrg.Id,Price_Type__c = 'One Time',Cost_Price__c = 140,Unit_Price__c = 150,Accounting_Code__c = 'AC'));
                    listOfPrpcs.add(new Product_Rate_Plan_Charge__c(Name = 'Install Price', Product_Rate_Plan__c = listOfRatePlansToInsert.get(2).Id, Charge_Sequence_Number__c = 2,CurrencyL__c = defaultCurrencyObjOrg.Id,Price_Type__c = 'One Time',Cost_Price__c = 200,Unit_Price__c = 300,Accounting_Code__c = 'AC'));
                    listOfPrpcs.add(new Product_Rate_Plan_Charge__c(Name = 'Maintenance Charges', Product_Rate_Plan__c = listOfRatePlansToInsert.get(2).Id, Charge_Sequence_Number__c = 3,CurrencyL__c = defaultCurrencyObjOrg.Id,Price_Type__c = 'Monthly',Cost_Price__c = 2800,Unit_Price__c = 3000,Accounting_Code__c = 'AC'));
            
                    listOfPrpcs.add(new Product_Rate_Plan_Charge__c(Name = 'Supply Price', Product_Rate_Plan__c = listOfRatePlansToInsert.get(3).Id, Charge_Sequence_Number__c = 1,CurrencyL__c = defaultCurrencyObjOrg.Id,Price_Type__c = 'One Time',Cost_Price__c = 140,Unit_Price__c = 160,Accounting_Code__c = 'AC'));
                    listOfPrpcs.add(new Product_Rate_Plan_Charge__c(Name = 'Install Price', Product_Rate_Plan__c = listOfRatePlansToInsert.get(3).Id, Charge_Sequence_Number__c = 2,CurrencyL__c = defaultCurrencyObjOrg.Id,Price_Type__c = 'One Time',Cost_Price__c = 200,Unit_Price__c = 320,Accounting_Code__c = 'AC'));
                    listOfPrpcs.add(new Product_Rate_Plan_Charge__c(Name = 'Maintenance Charges', Product_Rate_Plan__c = listOfRatePlansToInsert.get(3).Id, Charge_Sequence_Number__c = 3,CurrencyL__c = defaultCurrencyObjOrg.Id,Price_Type__c = 'Monthly',Cost_Price__c = 2800,Unit_Price__c = 3200,Accounting_Code__c = 'AC'));
            
                    listOfPrpcs.add(new Product_Rate_Plan_Charge__c(Name = 'Supply Price', Product_Rate_Plan__c = listOfRatePlansToInsert.get(4).Id, Charge_Sequence_Number__c = 1,CurrencyL__c = defaultCurrencyObjOrg.Id,Price_Type__c = 'One Time',Cost_Price__c = 140,Unit_Price__c = 170 ,Accounting_Code__c = 'AC'));
                    listOfPrpcs.add(new Product_Rate_Plan_Charge__c(Name = 'Install Price', Product_Rate_Plan__c = listOfRatePlansToInsert.get(4).Id, Charge_Sequence_Number__c = 2,CurrencyL__c = defaultCurrencyObjOrg.Id,Price_Type__c = 'One Time',Cost_Price__c = 200,Unit_Price__c = 340 ,Accounting_Code__c = 'AC'));
                    listOfPrpcs.add(new Product_Rate_Plan_Charge__c(Name = 'Maintenance Charges', Product_Rate_Plan__c = listOfRatePlansToInsert.get(4).Id, Charge_Sequence_Number__c = 3,CurrencyL__c = defaultCurrencyObjOrg.Id,Price_Type__c = 'Monthly',Cost_Price__c = 2800,Unit_Price__c = 3400 ,Accounting_Code__c = 'AC'));
            
                    listOfPrpcs.add(new Product_Rate_Plan_Charge__c(Name = 'Supply Price', Product_Rate_Plan__c = listOfRatePlansToInsert.get(5).Id, Charge_Sequence_Number__c = 1,CurrencyL__c = defaultCurrencyObjOrg.Id,Price_Type__c = 'One Time',Cost_Price__c = 240,Unit_Price__c = 250 ,Accounting_Code__c = 'AC'));
                    listOfPrpcs.add(new Product_Rate_Plan_Charge__c(Name = 'Install Price', Product_Rate_Plan__c = listOfRatePlansToInsert.get(5).Id, Charge_Sequence_Number__c = 2,CurrencyL__c = defaultCurrencyObjOrg.Id,Price_Type__c = 'One Time',Cost_Price__c = 480,Unit_Price__c = 500 ,Accounting_Code__c = 'AC'));
                    listOfPrpcs.add(new Product_Rate_Plan_Charge__c(Name = 'Maintenance Charges', Product_Rate_Plan__c = listOfRatePlansToInsert.get(5).Id, Charge_Sequence_Number__c = 3,CurrencyL__c = defaultCurrencyObjOrg.Id,Price_Type__c = 'Monthly',Cost_Price__c = 4800,Unit_Price__c = 5000 ,Accounting_Code__c = 'AC'));
                    insert listOfPrpcs;
                }else {
                    // This will update the currency, now it is dplayed in the setUp Page By Dev Mis
                    Configuration__c defaultCurrecy = Configuration__c.getValues('DEFAULT_CURRENCY');
                    if(defaultCurrecy != null && (defaultCurrecy.Category__c == null || defaultCurrecy.Category__c == '')) {
                        defaultCurrecy.Category__c ='General';
                        defaultCurrecy.Quick_Screen_Id__c ='3';
                        defaultCurrecy.Sequence__c = 4;
                        defaultCurrecy.Picklist_Indicator__c ='listDefaultCurrency';
                        update defaultCurrecy;
                    }//Addeb by dhanalakshmi,INVOICEIT-523, Insert currency if default currency is not there while installing the package
                    else if(defaultCurrecy == null) {
                        string defaultCurrency = userInfo.getDefaultCurrency();
                        Configuration__c defaultCurrecyForOrg = new Configuration__c(Name = 'DEFAULT_CURRENCY', STRING_VALUE__C = 'GBP', Field_Type__c = 'String', Description__c = 'Mention the ISO code of your default currency here. Say GBP',Category__c ='General',Picklist_Indicator__c ='listDefaultCurrency',Quick_Screen_Id__c ='3',Sequence__c = 4);
                        defaultCurrecyForOrg.STRING_VALUE__C = defaultCurrency;
                        insert defaultCurrecyForOrg;
                    }
                }
                
                // this will insert the layout records for new product page
                /*
                        Modified By     : Anil Pinto 19 Sept 2013 INVOICEIT-234
                */
            
                list<Layout_Fields__c> listOfLayoutFieldsPresent = [Select Id FROM Layout_Fields__c LIMIT 1];
                if(listOfLayoutFieldsPresent.size() == 0) {
                    string sPrefix = CommonUtilClass.getPrefix();
                    list<Layout_Fields__c> listOfLayoutFields = new list<Layout_Fields__c>();
                    
                    string sSelectField1 = 'Name-171,'+sPrefix+'Description__c-321,'+sPrefix+'Product_Code__c-156,'+sPrefix+'No_of_Rate_Plans__c-133,'+sPrefix+'Effective_Period__c-228,'+sPrefix+'Status__c-166';
                    string sSelectField2 = 'Name-264,'+sPrefix+'Description__c-362,'+sPrefix+'No_of_Charges__c-133,'+sPrefix+'Effective_Period__c-271,'+sPrefix+'Status__c-135';
                    string sSelectField3 = 'Name-159,'+sPrefix+'Price_Format__c-140,'+sPrefix+'Unit_Of_Measurement__c-76,'+sPrefix+'Default_Quantity__c-125,'+sPrefix+'Unit_Price__c-125,'+sPrefix+'Cost_Price__c-125'+sPrefix+'CurrencyL__c-125,'+sPrefix+'Price_Type__c-126,'+sPrefix+'Accounting_Code__c-126';
                    
                    string sName1 = sPrefix+'Product__c';
                    string sName2 = sPrefix+'Product_Rate_Plan__c';
                    string sName3 = sPrefix+'Product_Rate_Plan_Charge__c';
                    
                    Layout_Fields__c layoutFieldsProduct = new Layout_Fields__c(Name = sName1 , Selected_Fields__c = sSelectField1);
                    Layout_Fields__c layoutFieldsProductRateplan = new Layout_Fields__c(Name= sName2 ,Selected_Fields__c = sSelectField2);
                    Layout_Fields__c layoutFieldsProductCharge = new Layout_Fields__c(Name= sName3 ,Selected_Fields__c = sSelectField3); 
                      
                    listOfLayoutFields.add(layoutFieldsProduct);
                    listOfLayoutFields.add(layoutFieldsProductRateplan);
                    listOfLayoutFields.add(layoutFieldsProductCharge);
                    insert listOfLayoutFields;
                }
            } catch(Exception ex) {
                Messaging.SingleEmailMessage emailTobeSent = new Messaging.SingleEmailMessage();
                list<String> listEmailMembers = new list<String>();
                listEmailMembers.add('praveen@weinvoiceit.com');
                listEmailMembers.add('laxman.rao@weinvoiceit.com');
                listEmailMembers.add('devender@weinvoiceit.com');
                emailTobeSent.setToAddresses(listEmailMembers);
                emailTobeSent.setSubject('Invoice IT Post Install: Exception');
                /*
                        Modified By     : Asish Behera 28 May 2014 INVOICEIT-350
                */
                emailTobeSent.setHtmlBody('Message : ' + ex.getMessage() + 'Line no : ' + ex.getLineNumber() + ' getStackTraceString ' + ex.getStackTraceString() + '' + ex.getCause()+',  Org Id '+UserInfo.getOrganizationId()+
                                         ',  Orginastation Company name ' + UserInfo.getOrganizationName()+ ',  Current User Name   '+UserInfo.getUserName() +',  Current User Email Address  '+UserInfo.getUserEmail()+', Previousversion Number '+context.previousVersion());
                if(!Test.isRunningTest()) {
                    Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailTobeSent});
                }
                //Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {emailTobeSent});
            }
       } 
    }