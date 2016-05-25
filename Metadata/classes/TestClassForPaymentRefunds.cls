@isTest
private with sharing class TestClassForPaymentRefunds{
    static testMethod void testPaymentRefunds() {
        ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
        ControllerInsertCustomSettings.insertValues();
        list<Currency__c> listCurrencys = new list<Currency__c>();
        listCurrencys.add(new Currency__c(Name = 'GBP', Symbol__c = '£1'));
        listCurrencys.add(new Currency__c(Name = 'USD', Symbol__c = '$2'));
        listCurrencys.add(new Currency__c(Name = 'EUR', Symbol__c = '€3'));    
        insert listCurrencys;
        Account account = new Account(name = 'Test Account');
        insert account;
        Job__c job = new Job__c(Account__c = account.id,Status__c = 'Draft',Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = listCurrencys[1].Id);
        insert job;
        Invoice__c invoice = new Invoice__c(Account__c = account.id,CurrencyL__c = listCurrencys[1].Id,Invoice_Status__c = CommonUtilClass.STATUS_POSTED,Order__c = job.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both');                    
        insert invoice;
        Payment__c payment = new Payment__c(Account__c = account.id,Amount__c = 100, Currency__c = listCurrencys[1].id);
        insert payment;
        Payment_Allocation__c paymentAllocation = new Payment_Allocation__c(Amount__c = 100,Payment__c = payment.id,Invoice__c = invoice.id);
        Refund__c refund = new Refund__c(Account__c = account.id,Currency__c = listCurrencys[1].id,Refund_Date__c = date.today(),Refund_Description__c = 'Test');
        insert refund;
        ApexPages.Standardcontroller stdController = new Apexpages.Standardcontroller(payment);
        ControllerPaymentRefund objControllerPaymentRefund = new ControllerPaymentRefund(stdController);
        for(ControllerPaymentRefund.payments wrapClass : objControllerPaymentRefund.listOfPaymentsClass){
            wrapClass.isChecked = true;
            wrapClass.refundAmount = 10;
        }
        objControllerPaymentRefund.createRefunds();

        Payment__c payment1 = new Payment__c(Account__c = account.id,Amount__c = 100, Currency__c = listCurrencys[1].id);
        insert payment1;

        System.assertEquals(100, payment1.Amount__c);

        ApexPages.Standardcontroller stdController1 = new Apexpages.Standardcontroller(payment1);
        ControllerPaymentRefund objControllerPaymentRefund1 = new ControllerPaymentRefund(stdController1);
        objControllerPaymentRefund1.createRefunds();
    }
    static testMethod void testPaymentRefundsForAccount() {
        ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
        ControllerInsertCustomSettings.insertValues();
        list<Currency__c> listCurrencys = new list<Currency__c>();
        listCurrencys.add(new Currency__c(Name = 'GBP', Symbol__c = '£1'));
        listCurrencys.add(new Currency__c(Name = 'USD', Symbol__c = '$2'));
        listCurrencys.add(new Currency__c(Name = 'EUR', Symbol__c = '€3'));    
        insert listCurrencys;
        Account account = new Account(name = 'Test Account');
        insert account;
        Job__c job = new Job__c(Account__c = account.id,Status__c = 'Draft',Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = listCurrencys[1].Id);
        insert job;
        Invoice__c invoice = new Invoice__c(Account__c = account.id,CurrencyL__c = listCurrencys[1].Id,Invoice_Status__c = CommonUtilClass.STATUS_POSTED,Order__c = job.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both');                    
        insert invoice;
        Payment__c payment = new Payment__c(Account__c = account.id,Amount__c = 100, Currency__c = listCurrencys[1].id);
        insert payment;
        System.assertEquals(100, payment.Amount__c);
        Payment_Allocation__c paymentAllocation = new Payment_Allocation__c(Amount__c = 100,Payment__c = payment.id,Invoice__c = invoice.id);
        Refund__c refundObj = new Refund__c(Currency__c = listCurrencys[1].id,Refund_Date__c = date.today(),Refund_Description__c = 'Test');
        //insert refundObj;
        ApexPages.Standardcontroller stdController = new Apexpages.Standardcontroller(account);
        ControllerPaymentRefundForAccount objControllerPaymentRefundForAccount = new ControllerPaymentRefundForAccount(stdController);
        objControllerPaymentRefundForAccount.refund = refundObj;
        objControllerPaymentRefundForAccount.displayPayments();
        for(ControllerPaymentRefundForAccount.payments wrapClass : objControllerPaymentRefundForAccount.listOfPaymentsClass){
            wrapClass.isChecked = true;
            wrapClass.refundAmount = 10;
        }
        objControllerPaymentRefundForAccount.createRefunds(); 

        Account account1 = new Account(name = 'Test Account');
        insert account1;
        ApexPages.Standardcontroller stdController1 = new Apexpages.Standardcontroller(account1);
        ControllerPaymentRefundForAccount objControllerPaymentRefundForAccount1 = new ControllerPaymentRefundForAccount(stdController1);
        objControllerPaymentRefundForAccount1.refund = refundObj;
        objControllerPaymentRefundForAccount1.displayPayments();
        objControllerPaymentRefundForAccount1.createRefunds();
    }
}