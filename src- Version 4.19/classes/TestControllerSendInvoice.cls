@isTest(oninstall = false)
    public with sharing class TestControllerSendInvoice {
         public static testMethod void testBatchClassGroupByAccount() {
            ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
            ControllerInsertCustomSettings.insertValues();

            Currency__c currency2 = new Currency__c(name = 'GBP', Symbol__c = '£1',Currency_Symbol__c='£');
            insert currency2;
            
            integer m = system.today().day();
            string s = string.ValueOf(m);
            
            Account account = new Account(name = 'Test Account',Preferred_Billing_Day__c = s);
            insert account;
            
            Account account1 = [SELECT Name From Account WHERE id=: account.id];
            System.assertEquals('Test Account', account1.Name);

            Contact contact =  new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email = 'abc@gmail.com');
            insert contact ;
            
            Currency__c currency1 = [SELECT Id, Name, Currency_Symbol__c
                                     FROM Currency__c
                                     WHERE Name = 'GBP' 
                                     AND Currency_Symbol__c = '£'
                                     LIMIT 1];
            

            Invoice__c invoiceObj = new Invoice__c(Account__c = account.Id,
                                                Billing_Contact__c = contact.Id,
                                                Shipping_Contact__c = contact.Id,
                                                CurrencyL__c = currency1.Id, 
                                                Target_Date__c = Date.today(),
                                                Delivery_Type__c = 'Both',
                                                Invoice_Status__c = CommonUtilClass.STATUS_DRAFT
                                               
                                                );
            insert invoiceObj;

            Invoice__c invoiceObj1 = new Invoice__c(Account__c = account.Id,
                                                Billing_Contact__c = contact.Id,
                                                Shipping_Contact__c = contact.Id,
                                                CurrencyL__c = currency1.Id, 
                                                Target_Date__c = Date.today(),
                                                Delivery_Type__c = 'Both',
                                                Email_Sent__c = true,
                                                Invoice_Status__c = CommonUtilClass.STATUS_DRAFT
                                               
                                                );
            insert invoiceObj1;

            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(invoiceObj);
            ControllerSendInvoice  controllerSendInvoice1 = new ControllerSendInvoice(standardController);
            controllerSendInvoice1.emailInvoice();
            
            Configuration__c configuration = Configuration__c.getValues('INVOICE_EMAIL_TEMPLATE');
            configuration.String_Value__c = '00XU0000000IXSF';
            update configuration;
            
            ApexPages.Standardcontroller standardController1 = new Apexpages.Standardcontroller(invoiceObj);
            ControllerSendInvoice  controllerSendInvoice = new ControllerSendInvoice(standardController1);
            controllerSendInvoice.emailInvoice();
            controllerSendInvoice.backToInvoice();

            ApexPages.Standardcontroller standardController2 = new Apexpages.Standardcontroller(invoiceObj1);
            ControllerSendInvoice  controllerSendInvoice2 = new ControllerSendInvoice(standardController2);
            controllerSendInvoice2.emailInvoice();
           
        }

    }