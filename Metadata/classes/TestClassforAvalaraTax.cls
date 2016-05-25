@isTest
public with sharing class TestClassforAvalaraTax {

     static testMethod void AvalaraTax() {
         Configuration__c c1 = new Configuration__c(Name='TAX_CALCULATION_BASED_ON',String_Value__c = 'Account Billing Address',Field_Type__c = 'String');
         insert c1;
         Configuration__c c2 = new Configuration__c(Name='TYPE_OF_PACKAGE',String_Value__c = 'STANDALONE',Field_Type__c = 'String');
         insert c2; 
         Configuration__c c3 = new Configuration__c(Name='ORDER_STATUS_VALUES_TO_ROLLUP',String_Value__c = 'In Progress',Field_Type__c = 'String');
         insert c3;
         Configuration__c c4 = new Configuration__c(Name='AUTOMATIC_ALLOCATEDTOFUTURE_INVOICES',Boolean_Value__c = false,Field_Type__c = 'String');
         insert c4;      
         Account account = new Account(Name = 'Test Account',Preferred_Billing_Day__c = '10',BillingStreet = '118 N Clark St',BillingCity = 'Chicago',BillingState = 'IL',BillingPostalCode='60602-1304',BillingCountry='US',ShippingStreet = '118 N Clark St',ShippingCity = 'Chicago',ShippingState = 'IL',ShippingPostalCode='60602-1304',ShippingCountry='US');
         insert account;
         
         Account account1 = [select Name From Account Where Id =: account.id];
         System.assertEquals('Test Account', account1.Name);
           
         list<Contact> listContacts = new list<Contact>();
         listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,Email ='laxmanrao.564@gmail.com',MailingStreet= '118 N Clark St',MailingCity = 'Chicago',MailingState = 'IL',MailingPostalCode='60602-1304',MailingCountry='US'));
         listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com'));
         insert listContacts;
         list<Currency__c> listofCurrency = new list<Currency__c>();
         Currency__c currency2 = new Currency__c(Name = 'USD',Symbol__c = '$');
         listofCurrency.add(currency2); 
         Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
         listofCurrency.add(currency1);
         insert listofCurrency;
         Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = listofCurrency[0].Id,Tax_Engine__c='Avalara',Service_Activation_Date__c = date.today());
         insert job;
         Job_Product__c  jobProduct= new Job_Product__c(Name = 'jobProduct',Job__c = job.Id);
         insert jobProduct;

         Job_Rate_Plan__c jobRP = new Job_Rate_Plan__c(Name = 'JobRP',Job_Product__c =jobProduct.Id);
         insert jobRP;
         list<Job_Rate_Plan_Charge__c> listofcharges = new list<Job_Rate_Plan_Charge__c>(); 
         Job_Rate_Plan_Charge__c charge = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Next_Charge_Date__c = system.TODAY(),Service_Activation_Date__c = system.TODAY()+13,Job_Rate_Plan__c =jobRP.Id,Status__c='Draft',Quantity__c = 12,Price_Type__c = System.Label.OptionOneTime,Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c = 35,Price_Format__c = 'Volume Pricing', Committed_Quantity__c = 6);
         listofcharges.add(charge);
         Job_Rate_Plan_Charge__c charge1 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Next_Charge_Date__c = system.TODAY(),Service_Activation_Date__c = system.TODAY(),Job_Rate_Plan__c =jobRP.Id,Status__c='Draft',Quantity__c = 12,Price_Type__c = System.Label.OptionMonthly,Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c = 35,Price_Format__c = 'Volume Pricing', Committed_Quantity__c = 6);
         listofcharges.add(charge1);
         insert listofcharges;
         Invoice__c invoice = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
         CurrencyL__c = listofCurrency[0].Id,Invoice_Status__c = CommonUtilClass.STATUS_POSTED, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Tax_Engine__c='Avalara',Invoice_Date__c = date.today());
         insert invoice;
         list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
         listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,Job__c = job.Id,Line_Amount__c = 100));
         listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,Job__c = job.Id,Line_Amount__c = 50));
         listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,Job__c = job.Id,Line_Amount__c = 70));
         insert listInvoiceLines;
         invoice.Invoice_Status__c = 'Posted';
         update invoice;
         Tax_Integration__c taxIntegration = new Tax_Integration__c(Name='Avalara',AvaTax_Account_Number__c='2000001248',Tax_Engine__c='Avalara AvaTax',AvaTax_Organization__c='Infinity Solutions',AvaTax_Adapter__c='customAdapter',AvaTax_Client_Name__c='Infinity Solutions',AvaTax_Company_Code__c='infinity',AvaTax_Environment_Name__c='Production',AvaTax_License_Key__c='ABEB4CCBBBBA98D5',Active__c=true,Default__c=true);
         insert taxIntegration;
         
         ClassforCalculatingTax.getTaxForInvoice(taxIntegration,invoice.id);
         ClassforCalculatingTax.postTaxForInvoice(taxIntegration,invoice,100);
         ClassforCalculatingTax.cancelTaxForInvoice(taxIntegration,invoice);
         ClassforCalculatingTax.getTaxForOrder(taxIntegration,job.id);

         Configuration__c config = new Configuration__c(Name='ORDER_LEGAL_ENTITY_FIELD_NAME',String_Value__c = 'Name',Field_Type__c = 'String');
         insert config; 

         Configuration__c config1 = new Configuration__c(Name='ACCOUNT_LEGAL_ENTITY_FIELD_NAME',String_Value__c = 'Name',Field_Type__c = 'String');
         insert config1; 

         ClassforCalculatingAvaTax.voidTaxInvoice(account.id,job.id,invoice.id);
         ClassforCalculatingAvaTax.calculateTaxInvoice(account.id,job.id,invoice.id);
         ClassforCalculatingAvaTax.calculateTaxOrder(job.id);

         Configuration__c c5 = Configuration__c.getValues('TAX_CALCULATION_BASED_ON');
         c5.String_Value__c = 'Account Shipping Address';
         update c5; 
         ClassforCalculatingTax.getTaxForInvoice(taxIntegration,invoice.id);
         ClassforCalculatingTax.getTaxForOrder(taxIntegration,job.id);
         
         Configuration__c c6 = Configuration__c.getValues('TAX_CALCULATION_BASED_ON');
         c6.String_Value__c = 'Billing Contact';
         update c6; 
         ClassforCalculatingTax.getTaxForInvoice(taxIntegration,invoice.id);
         ClassforCalculatingTax.getTaxForOrder(taxIntegration,job.id);
         
         Configuration__c c7 = Configuration__c.getValues('TAX_CALCULATION_BASED_ON');
         c7.String_Value__c = 'Shipping Contact';
         update c7; 
         ClassforCalculatingTax.getTaxForInvoice(taxIntegration,invoice.id);
         ClassforCalculatingTax.getTaxForOrder(taxIntegration,job.id);
         
     }
}