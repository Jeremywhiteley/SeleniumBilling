@isTest(oninstall = false)
    private with sharing class TestControllerVirtualTerminal {
        static testMethod void controllerVirtualTerminal() {
            ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
            ControllerInsertCustomSettings.insertValues();
            
            Configuration__c c13 = new Configuration__c(Name = 'DEFAULT_CURRENCY', STRING_VALUE__C = 'GBP', Field_Type__c = 'String', Description__c = 'Mention the ISO code of your default currency here. Say GBP');
            upsert c13;
            

            Account account = new Account(Name = 'Test Account');
            insert account;

            Account account1 = [Select Name From Account Where id=: account.id];
            System.assertEquals('Test Account', account1.Name);

            list<Contact> listContacts = new list<Contact>();
            listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com'));
            listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com'));
            insert listContacts;

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
            insert mapOfCurrencyValuesToInserted.values();

            Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = mapOfCurrencyValuesToInserted.get('USD').Id);
          
            insert job;

            Invoice__c invoice1 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
            CurrencyL__c = mapOfCurrencyValuesToInserted.get('USD').Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED);

            Invoice__c invoice2 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
            CurrencyL__c = mapOfCurrencyValuesToInserted.get('USD').Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED);

            Invoice__c invoice3 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
            CurrencyL__c = mapOfCurrencyValuesToInserted.get('USD').Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED);

            list<Invoice__c> invoices = new list<Invoice__c>();
            invoices.add(invoice1);
            invoices.add(invoice2);
            invoices.add(invoice3);
            insert invoices;

            list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));

            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(1).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));

            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(2).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(2).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(2).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            insert listInvoiceLines;

            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(account);
            system.currentPageReference().getParameters().put('Id', account.Id);
            ControllerVirtualTerminal controllerVirtualTerminal1 = new ControllerVirtualTerminal(standardController);

            //insert Gateway 
            Gateway__c gateway = new Gateway__c(Active__c = true, Default__c = true, Gateway_Type__c = 'PayPal', Test_Mode__c = true, Merchant_ID__c = '22LbQ9b7', Security_Key__c = '8Fh7VnPV3e6h4b4S', Merchant_Seal_User_Id__c = '8Fh7VnPV3e6h4b4S...');
            insert gateway;        

            Payment_Method__c paymentMethod = new Payment_Method__c(Card_Expiration_Month__c = '12', Card_Expiration_Year__c = '2016', Billing_First_Name__c = 'Sandeep', Billing_Last_Name__c = 'M', CVV__c = '123', Card_Type__c = 'Master',Card_Number__c = '420000000000000', Account__c = account.Id);
            insert paymentMethod;
            
            
            list<Payment_Method__c> paymentMethods = new list<Payment_Method__c>();
            Payment_Method__c paymentMethod1 = new Payment_Method__c(Card_Expiration_Month__c = '12', Card_Expiration_Year__c = '2016', Billing_First_Name__c = 'Sandeep', Billing_Last_Name__c = 'M', CVV__c = '123', Card_Type__c = 'Master',Card_Number__c = '420000000000000', Account__c = account.Id);
            paymentMethods.add(paymentMethod1);
            Payment_Method__c paymentMethod2 = new Payment_Method__c(Card_Expiration_Month__c = '12', Card_Expiration_Year__c = '2016', Billing_First_Name__c = 'Sandeep1', Billing_Last_Name__c = 'M', CVV__c = '123', Card_Type__c = 'Master',Card_Number__c = '420000000000000', Account__c = account.Id);
            paymentMethods.add(paymentMethod2);
            insert paymentMethods;
            
            ControllerVirtualTerminal controllerVirtualTerminal = new ControllerVirtualTerminal(standardController);

            controllerVirtualTerminal.processPaymentRedirect();  
            controllerVirtualTerminal.selectedValue = paymentMethod.Id;  
            controllerVirtualTerminal.isNone = false;               
            controllerVirtualTerminal.paymentMethod.Billing_First_Name__c = 'Sandeep';
            controllerVirtualTerminal.paymentMethod.Billing_Last_Name__c = 'M';
            controllerVirtualTerminal.paymentMethod.Card_Type__c = 'Master';
            controllerVirtualTerminal.paymentMethod.Card_Number__c = '420000000000000';
            controllerVirtualTerminal.paymentMethod.CVV__c = '123';
            controllerVirtualTerminal.paymentMethod.Card_Expiration_Month__c = '12';
            controllerVirtualTerminal.paymentMethod.Card_Expiration_Year__c = '2016';
            controllerVirtualTerminal.sSaveCardDetails = 'yes';
            controllerVirtualTerminal.paymentMethod.Account__c = account.Id;
            controllerVirtualTerminal.processPayment();

            gateway.Default__c = false;
            update gateway;
            Gateway__c gatewayWireCard = new Gateway__c(Active__c = true, Default__c = true, Gateway_Type__c = CommonUtilClass.GATEWAY_TYPE_WIRECARD, Test_Mode__c = true, Merchant_ID__c = '22LbQ9b7', Security_Key__c = '8Fh7VnPV3e6h4b4S');
            insert gatewayWireCard;
       
            // For Invoice
            ApexPages.Standardcontroller standardControllerInvoice = new Apexpages.Standardcontroller(invoices.get(0));
            system.currentPageReference().getParameters().put('Id', invoices.get(0).id);
            ControllerVirtualTerminal controllerVirtualTerminalInvoice = new ControllerVirtualTerminal(standardControllerInvoice);
            controllerVirtualTerminalInvoice.selectedValue = '';  
            controllerVirtualTerminalInvoice.isNone = true;    
            controllerVirtualTerminalInvoice.dAmount = 10.00;

            controllerVirtualTerminalInvoice.paymentMethod.Billing_First_Name__c = 'Sandeep';
            controllerVirtualTerminalInvoice.paymentMethod.Billing_Last_Name__c = 'M';
            controllerVirtualTerminalInvoice.paymentMethod.Card_Type__c = 'Master';
            controllerVirtualTerminalInvoice.paymentMethod.Card_Number__c = '420000000000000';
            controllerVirtualTerminalInvoice.paymentMethod.CVV__c = '123';
            controllerVirtualTerminalInvoice.paymentMethod.Card_Expiration_Month__c = null;
            controllerVirtualTerminalInvoice.paymentMethod.Card_Expiration_Year__c = null;
            controllerVirtualTerminalInvoice.sSaveCardDetails = 'yes';
            controllerVirtualTerminal.paymentMethod.Account__c = account.Id;
            controllerVirtualTerminalInvoice.processPayment();

            controllerVirtualTerminalInvoice.paymentMethod.Billing_First_Name__c = 'Sandeep';
            controllerVirtualTerminalInvoice.paymentMethod.Billing_Last_Name__c = 'M';
            controllerVirtualTerminalInvoice.paymentMethod.Card_Type__c = 'Master';
            controllerVirtualTerminalInvoice.paymentMethod.Card_Number__c = '420000000000000';
            controllerVirtualTerminalInvoice.paymentMethod.CVV__c = '123';
            controllerVirtualTerminalInvoice.paymentMethod.Card_Expiration_Month__c = '12';
            controllerVirtualTerminalInvoice.paymentMethod.Card_Expiration_Year__c = '2016';
            controllerVirtualTerminalInvoice.sSaveCardDetails = 'yes';
            controllerVirtualTerminal.paymentMethod.Account__c = account.Id;
            controllerVirtualTerminalInvoice.processPayment();

            system.currentPageReference().getParameters().put('Id', account.Id);
            ControllerVirtualTerminal controllerVirtualTerminalAccount = new ControllerVirtualTerminal(standardController);
            c13.STRING_VALUE__C ='';
            upsert c13;
            ControllerVirtualTerminal controllerVirtualTerminalAccount1 = new ControllerVirtualTerminal(standardController);
            
            // cover catch blocks
            Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(invoices.get(0));
            ControllerVirtualTerminal controllerVirtualTerminalObj = new ControllerVirtualTerminal(stdController);
            controllerVirtualTerminalObj.processPaymentRedirect();
            controllerVirtualTerminalObj.processPayment();
            ControllerSitePaymentProcess controllerSitePaymentProcessObj = new ControllerSitePaymentProcess();
             
        }
       
    }