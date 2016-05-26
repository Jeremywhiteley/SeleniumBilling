@isTest(oninstall = false)
    /*
    This Class is created by Sagarika for ClassAfterOnPayment.
    Created Date- 24/09/2013
     */
    public with sharing class TestClassForAfterOnPayment {

        public static testMethod void classAfterOnPayment() {
            ControllerInsertCustomSettings controllerInsertCustomSettings = new ControllerInsertCustomSettings();
            controllerInsertCustomSettings.insertValues();

            Configuration__c automatedCS = Configuration__c.getValues('AUTOMATE_PAYMENT_ALLOCATION'); 
            automatedCS.Boolean_Value__c = true;
            update automatedCS;

            Account account = new Account(Name = 'Test Account');
            insert account;
            
            list<Contact> listContacts = new list<Contact>();
            listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com'));
            listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com'));
            insert listContacts;
            list<Currency__c> listofCurrency = new list<Currency__c>();
            Currency__c currency2 = new Currency__c(Name = 'USD',Symbol__c = '$');
            listofCurrency.add(currency2); 
            Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
            listofCurrency.add(currency1);
            insert listofCurrency;

            Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = listofCurrency[0].Id);
            insert job;

            Invoice__c invoice = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                    CurrencyL__c = listofCurrency[0].Id,Invoice_Status__c = CommonUtilClass.STATUS_POSTED, Target_Date__c = Date.today(),Delivery_Type__c = 'Both');
            insert invoice;

            list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Line_Amount__c = 50,Unit_Price__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Line_Amount__c = 50,Unit_Price__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Line_Amount__c = 50,Unit_Price__c = 40.00,Job__c = job.Id));
            insert listInvoiceLines;

            //first insert the payment which will call the trigger and payment allocation is done automatically
            
            ClassAfterOnPayment classAfterOnPaymentobj = new ClassAfterOnPayment();
            list<Payment__c> listofpayment = new list<Payment__c>();
            //if un allocated amount < un paid amount
            Payment__c payment1 = new Payment__c(Account__c = invoice.Account__c, 
                    Amount__c = 6, 
                    Status__c = CommonUtilClass.STATUS_COMPLETED, 
                    Payment_Type__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                    Payment_Date__c = system.today(),
                    Currency__c = listofCurrency[0].Id);
            insert payment1;
            listofpayment.add(payment1);
            ClassAfterOnPayment.PAYMENT_AFTER_PROCESSING_COMPLETE = false;
            //if un allocated amount > un paid amount
            Payment__c payment = new Payment__c(Account__c = invoice.Account__c, 
                    Amount__c = 60000, 
                    Status__c = CommonUtilClass.STATUS_COMPLETED, 
                    Payment_Type__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                    Payment_Date__c = system.today(),
                    Currency__c = listofCurrency[0].Id);
            insert payment;
            listofpayment.add(payment);
            ApexPages.Standardcontroller stdController = new Apexpages.Standardcontroller(payment); 
            ControllerAllocatePayments controllerAllocatePaymentsObj = new ControllerAllocatePayments(stdController);
            
            update automatedCS;
            ClassAfterOnPayment.PAYMENT_AFTER_PROCESSING_COMPLETE = false;
            automatedCS.Boolean_Value__c = false;
            Payment_Allocation__c paymentAllocation = new Payment_Allocation__c(Payment__c = payment.Id,
                    Amount__c = payment.Amount__c,
                    Invoice__c = invoice.Id,
                    Status__c = CommonUtilClass.STATUS_COMPLETED);   

            insert paymentAllocation;
            payment.Status__c = CommonUtilClass.STATUS_CANCELLED;
            update payment;
            listofpayment.add(payment);
            system.assert(payment.Status__c == CommonUtilClass.STATUS_CANCELLED);
           classAfterOnPaymentobj.handleBeforeOnPayments(listofpayment);

            //Added for AH-307
            Invoice__c invoiceposted = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                    CurrencyL__c = listofCurrency[0].Id,Invoice_Status__c = CommonUtilClass.STATUS_POSTED, Target_Date__c = Date.today(),Delivery_Type__c = 'Both');
            insert invoiceposted;  
            Payment__c paymentTest = new Payment__c(Account__c = invoiceposted.Account__c, 
                    Amount__c = 1, 
                    Status__c = CommonUtilClass.STATUS_COMPLETED, 
                    Payment_Type__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                    Payment_Date__c = system.today(),
                    Transaction__c = null,
                    Currency__c = listofCurrency[0].Id);
            insert paymentTest;
        }
        
    }