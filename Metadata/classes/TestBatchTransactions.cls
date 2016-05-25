@isTest
   public with sharing class TestBatchTransactions {
       public static testMethod void testBatchClass() {
            ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
            ControllerInsertCustomSettings.insertValues();
            Currency__c currency1 = new Currency__c(name = 'GBP', Currency_Symbol__c = '£1', Symbol__c = '£12');
            insert currency1;  
            Payment_Scheduler__c paymenRunScheduler = new Payment_Scheduler__c();
            paymenRunScheduler.Type__c = 'Once';
            paymenRunScheduler.Target_Date__c = system.today();
            paymenRunScheduler.Start_date_and_time__c = system.now().addMinutes(20);
            paymenRunScheduler.Currency__c = currency1.Id;
            insert paymenRunScheduler;
            list<Gateway__c> listOfGateway = [Select Id From Gateway__c];
            delete listOfGateway;
            Gateway__c gateway = new Gateway__c(Active__c = true, Default__c = true, Gateway_Type__c = CommonUtilClass.GATEWAY_TYPE_PAYPAL, Test_Mode__c = true, Merchant_ID__c = '22LbQ9b7', Security_Key__c = '8Fh7VnPV3e6h4b4S');
            insert gateway;
            
            Account account = new Account(Name = 'Test Account');
            insert account;
            
            Payment_Method__c paymentMethod = new Payment_Method__c(Active__c = true, Default__c = true, Account__c = account.Id, CVV__c = '123', Card_Number__c = '4007000000027', Card_Expiration_Year__c = '2023', Card_Expiration_Month__c = '10');
            insert paymentMethod;
            
            list<Contact> listContacts = new list<Contact>();
            listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com'));
            listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com'));
            insert listContacts;
            
            Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = currency1.Id);
            insert job;
            system.assert(job.Id != null);
            
            Invoice__c invoice1 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED,No_of_tries__c=0);
                                                
            Invoice__c invoice2 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                                CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED,No_of_tries__c=0);
            
            list<Invoice__c> invoices = new list<Invoice__c>();
            invoices.add(invoice1);
            insert invoices;
            
            list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoices.get(0).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            insert listInvoiceLines;
               string q = 'SELECT Id, Name, Last_Processing_Date__c, No_of_tries__c From Invoice__c WHERE Invoice_Status__c = \'' + CommonUtilClass.STATUS_POSTED + '\'' + ' LIMIT 1';
               BatchTransactions b = new BatchTransactions(q, paymenRunScheduler);
               Id batchInstanceId = Database.executeBatch(b, 1); 
       }
   }