//This Class is created by Sagarika for ControllerCancelInvoice. Created Date- 24/09/2013
    @isTest(seeAllData = true)
    public with sharing class TestClassforControllerCancelInvoice {

        static testMethod void ControllerCancelInvoice() {

            //ControllerInsertCustomSettings controllerInsertCustomSettings = new ControllerInsertCustomSettings();
            //controllerInsertCustomSettings.insertValues();

            Account account = new Account(Name = 'Test Account',Preferred_Billing_Day__c = '10');
            insert account;

            Account account1 = [select Name From Account Where Id =: account.id];
            System.assertEquals('Test Account', account1.Name);
           
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
            ControllerCancelInvoice.isButtonClicked = true;

            Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = listofCurrency[0].Id);
            insert job;
            Invoice__c invoice = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                    CurrencyL__c = listofCurrency[0].Id,Invoice_Status__c = CommonUtilClass.STATUS_POSTED, Target_Date__c = Date.today(),Delivery_Type__c = 'Both');
                    
            insert invoice;
            Test.StartTest();
            ApexPages.Standardcontroller stdController = new Apexpages.Standardcontroller(invoice);        
            ControllerCancelInvoice controllerCancelInvoiceObj = new ControllerCancelInvoice(stdController);

            //to cover the else part
            controllerCancelInvoiceObj.cancelInvoice();
            controllerCancelInvoiceObj.cancelPost();
            controllerCancelInvoiceObj.backToInvoice();
            
            invoice.Invoice_Status__c = CommonUtilClass.STATUS_DRAFT;
            update invoice;
            ApexPages.Standardcontroller stdController1 = new Apexpages.Standardcontroller(invoice);        
            ControllerCancelInvoice controllerCancelInvoiceObj1 = new ControllerCancelInvoice(stdController1);
            controllerCancelInvoiceObj1.cancelInvoice();
            controllerCancelInvoiceObj1.cancelPost();
            controllerCancelInvoiceObj1.backToInvoice();
            list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,Job__c = job.Id));
            insert listInvoiceLines;
            ApexPages.Standardcontroller stdController2 = new Apexpages.Standardcontroller(invoice);        
            ControllerCancelInvoice controllerCancelInvoiceObj2 = new ControllerCancelInvoice(stdController2);
            controllerCancelInvoiceObj2.cancelInvoice();
            controllerCancelInvoiceObj2.bDisplayNoteMessage = true;
            controllerCancelInvoiceObj2.cancelPost();

            //if invoice is cancelled
            invoice.Invoice_Status__c = CommonUtilClass.STATUS_CANCELLED;
            update invoice;
             ApexPages.Standardcontroller stdController3 = new Apexpages.Standardcontroller(invoice);        
            ControllerCancelInvoice controllerCancelInvoiceObj3 = new ControllerCancelInvoice(stdController3);
            controllerCancelInvoiceObj3.cancelInvoice();

            //if no of invoice lines>0 and status = Draft
            invoice.Invoice_Status__c = CommonUtilClass.STATUS_DRAFT;
            update invoice;
             ApexPages.Standardcontroller stdController4 = new Apexpages.Standardcontroller(invoice);        
            ControllerCancelInvoice controllerCancelInvoiceObj4 = new ControllerCancelInvoice(stdController4);
            controllerCancelInvoiceObj4.cancelInvoice();
            controllerCancelInvoiceObj4.cancelPost();
            controllerCancelInvoiceObj4.backToInvoice();

            Test.StopTest();
             
        }
        static testMethod void ControllerGenerateInvoice() { 
             //ControllerInsertCustomSettings controllerInsertCustomSettings = new ControllerInsertCustomSettings();
             //controllerInsertCustomSettings.insertValues();
             Account account = new Account(Name = 'India',Payment_Terms__c = 'Net 30',Preferred_Billing_Day__c = '10');
             insert account;

             Account account1 = [select Name From Account Where Id =: account.id];
             System.assertEquals('India', account1.Name);

             list<Contact> listOfContacts = ClassPopulateTestData.createContacts(account);
             list<Currency__c> listOfCurrencies = ClassPopulateTestData.currencies();
             //inserting order
             Job__c job = new Job__c(Account__c = account.id,Status__c = 'Draft',Billing_Contact__c = listOfContacts.get(0).Id,Shipping_Contact__c = listOfContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = listOfCurrencies[0].Id,Start_Date__c = system.today(), Service_Activation_Date__c = system.today(), Service_End_Date__c = system.today().addMonths(10),Preferred_Billing_Day__c = '01');
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
             Job_Rate_Plan_Charge__c charge2 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Next_Charge_Date__c = system.TODAY(),Service_Activation_Date__c = system.TODAY()+13,Job_Rate_Plan__c =jobRP.Id,Status__c='Draft',Quantity__c = 12,Price_Type__c =System.Label.OptionQuarterly,Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c = 35);
             listofcharges.add(charge2);
             Job_Rate_Plan_Charge__c charge3 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Next_Charge_Date__c = system.TODAY(),Service_Activation_Date__c = system.TODAY()+13,Job_Rate_Plan__c =jobRP.Id,Status__c='Draft',Quantity__c = 12,Price_Type__c = System.Label.OptionMonthly,Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c = 35);
             listofcharges.add(charge3);
             Job_Rate_Plan_Charge__c charge4 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Next_Charge_Date__c = system.TODAY(),Service_Activation_Date__c = system.TODAY()+13,Job_Rate_Plan__c =jobRP.Id,Status__c='Draft',Quantity__c = 12,Price_Type__c = System.label.OptionUsage,Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c = 35,Price_Format__c = 'Volume Pricing', Committed_Quantity__c = 6, VAT_Percentage__c = 2, Tax_Percentage__c = 1, Min_Customer_Spend__c = 150, Discount_Value__c = 1);
             listofcharges.add(charge4);
             Job_Rate_Plan_Charge__c charge5 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Next_Charge_Date__c = system.TODAY(),Service_Activation_Date__c = system.TODAY()+13,Job_Rate_Plan__c =jobRP.Id,Status__c='Draft',Quantity__c = 12,Price_Type__c = System.Label.OptionWeekly,Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c = 35);
             listofcharges.add(charge5);
             Job_Rate_Plan_Charge__c charge6 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Next_Charge_Date__c = system.TODAY(),Service_Activation_Date__c = system.TODAY()+13,Job_Rate_Plan__c =jobRP.Id,Status__c='Draft',Quantity__c = 12,Price_Type__c = System.Label.OptionQuarterly,Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c = 35);
             listofcharges.add(charge6);
             Job_Rate_Plan_Charge__c charge7 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Next_Charge_Date__c = system.TODAY(),Service_Activation_Date__c = system.TODAY()+13,Job_Rate_Plan__c =jobRP.Id,Status__c='Draft',Quantity__c = 12,Price_Type__c = System.Label.OptionHalfYearly,Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c = 35);
             listofcharges.add(charge7);
             Job_Rate_Plan_Charge__c charge8 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Next_Charge_Date__c = system.TODAY(),Service_Activation_Date__c = system.TODAY()+13,Job_Rate_Plan__c =jobRP.Id,Status__c='Draft',Quantity__c = 12,Price_Type__c = System.Label.OptionAnnual,Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c = 35);
             listofcharges.add(charge8);
             Job_Rate_Plan_Charge__c charge9 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Next_Charge_Date__c = system.TODAY(),Service_Activation_Date__c = system.TODAY()+13,Job_Rate_Plan__c =jobRP.Id,Status__c='Draft',Quantity__c = 12,Price_Type__c = System.label.OptionUsage,Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c = 35,Price_Format__c = 'Flat Fee Pricing', Committed_Quantity__c = 6,VAT_Percentage__c = 2, Tax_Percentage__c = 1, Discount_Value__c = 1, Max_Customer_Spend__c = 5);
             listofcharges.add(charge9);
             Job_Rate_Plan_Charge__c charge10 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Next_Charge_Date__c = system.TODAY(),Service_Activation_Date__c = system.TODAY()+13,Job_Rate_Plan__c =jobRP.Id,Status__c='Draft',Quantity__c = 12,Price_Type__c = System.label.OptionUsage,Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c = 35,Price_Format__c = 'Tiered Pricing', Committed_Quantity__c = 6,VAT_Percentage__c = 2, Tax_Percentage__c = 1, Discount_Value__c = 1);
             listofcharges.add(charge10);
             Job_Rate_Plan_Charge__c charge11 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Next_Charge_Date__c = system.TODAY(),Service_Activation_Date__c = system.TODAY()+13,Job_Rate_Plan__c =jobRP.Id,Status__c='Draft',Quantity__c = 12,Price_Type__c = System.label.OptionUsage,Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c = 35,Committed_Quantity__c = 6,VAT_Percentage__c = 2, Tax_Percentage__c = 1);
             listofcharges.add(charge11);
             Job_Rate_Plan_Charge__c charge12 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Next_Charge_Date__c = system.TODAY(),Service_Activation_Date__c = system.TODAY()+13,Job_Rate_Plan__c =jobRP.Id,Status__c='Draft',Quantity__c = 12,Price_Type__c = System.label.OptionUsage,Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c = 35);
             listofcharges.add(charge12);
             
             insert listofcharges;

             Usage_Charge__c objUsageCharge= new Usage_Charge__c(Order__c = job.Id, Order_Rate_Plan_Charge__c = listofcharges[0].id, End_Date__c = system.today().addMonths(-1), Status__c = 'Un-billed',Quantity__c = 5);
             insert objUsageCharge; 

             Job_Rate_Plan_Charge_Tier__c objJobRPCT = new Job_Rate_Plan_Charge_Tier__c(Job_Rate_Plan_Charge__c = listofcharges[4].id, Start_Unit__c = 6, End_Unit__c = 6, Unit_Price__c = 20);
             insert objJobRPCT;
             Job_Rate_Plan_Charge_Tier__c objJobRPCT1 = new Job_Rate_Plan_Charge_Tier__c(Job_Rate_Plan_Charge__c = listofcharges[9].id, Start_Unit__c = 6, End_Unit__c = 6, Unit_Price__c = 20);
             insert objJobRPCT1;
             Job_Rate_Plan_Charge_Tier__c objJobRPCT2 = new Job_Rate_Plan_Charge_Tier__c(Job_Rate_Plan_Charge__c = listofcharges[10].id, Start_Unit__c = 6, End_Unit__c = 6, Unit_Price__c = 20);
             insert objJobRPCT2;
             Configuration__c customsett3 = Configuration__c.getValues('ACCOUNT_LEGAL_ENTITY_FIELD_NAME');
             customsett3.String_Value__c = 'Name';
             update customsett3;
             Configuration__c customsett2 = Configuration__c.getValues('INVOICE_GROUP_CRITERIA');
             customsett2.String_Value__c = 'ONE_INVOICE_PER_ACCOUNT';
             update customsett2;
              test.startTest(); 
             ApexPages.Standardcontroller controllerObj6 = new Apexpages.Standardcontroller(job);
             ControllerGenerateInvoice controllerGenerateInvoiceObj6 = new ControllerGenerateInvoice(controllerObj6);
             controllerGenerateInvoiceObj6.generateInvoiceAPI();
             controllerGenerateInvoiceObj6.generateInvoice();
             //update custom setting as DEFAULT_PAYMENT_TERMS_TO_BE_USED_FROM = ACCOUNT
             Configuration__c customsett  = Configuration__c.getValues('DEFAULT_PAYMENT_TERMS_TO_BE_USED_FROM');
             customsett.String_Value__c = 'ACCOUNT';
             update customsett;
             Configuration__c customsett4  = Configuration__c.getValues('DEFAULT_PAYMENT_TERMS_TO_BE_USED_FROM');
             customsett.String_Value__c = 'ACCOUNT';
             update customsett4;
            
             ApexPages.Standardcontroller controllerObj = new Apexpages.Standardcontroller(job);
             ControllerGenerateInvoice controllerGenerateInvoiceObj = new ControllerGenerateInvoice(controllerObj);
             controllerGenerateInvoiceObj.generateInvoiceAPI();
             controllerGenerateInvoiceObj.generateInvoice();
             //update custom setting as DEFAULT_PAYMENT_TERMS_TO_BE_USED_FROM = ORDER
             Configuration__c customsett1  = Configuration__c.getValues('DEFAULT_PAYMENT_TERMS_TO_BE_USED_FROM');
             customsett1.String_Value__c = 'ORDER';
             update customsett1;
             ApexPages.Standardcontroller controllerObj5 = new Apexpages.Standardcontroller(job);
             ControllerGenerateInvoice controllerGenerateInvoiceObj5 = new ControllerGenerateInvoice(controllerObj5);
             controllerGenerateInvoiceObj5.isAPIRequest = true;
             controllerGenerateInvoiceObj5.generateInvoiceAPI();
             controllerGenerateInvoiceObj5.generateInvoice();
             //Updating service Activation Date
             job.Service_Activation_Date__c  = system.today();
             update job;
             ApexPages.Standardcontroller controllerObj2 = new Apexpages.Standardcontroller(job);
             ControllerGenerateInvoice controllerGenerateInvoiceObj2 = new ControllerGenerateInvoice(controllerObj2);
             controllerGenerateInvoiceObj2.generateInvoiceAPI();
             controllerGenerateInvoiceObj2.generateInvoice();
             job.Service_Activation_Date__c  = system.today()+13;
             update job;
             ApexPages.Standardcontroller controllerObj4 = new Apexpages.Standardcontroller(job);
             ControllerGenerateInvoice controllerGenerateInvoiceObj4 = new ControllerGenerateInvoice(controllerObj4);
             controllerGenerateInvoiceObj4.generateInvoiceAPI();
             controllerGenerateInvoiceObj4.generateInvoice();
             //updating custom settings
             Configuration__c automatedCS = Configuration__c.getValues('CHARGE_STATUS_FOR_INVOICING'); 
             automatedCS.String_Value__c = 'Draft';
             update automatedCS;
             
             ApexPages.Standardcontroller controllerObj3 = new Apexpages.Standardcontroller(job);
             ControllerGenerateInvoice controllerGenerateInvoiceObj3 = new ControllerGenerateInvoice(controllerObj3);
             controllerGenerateInvoiceObj3.isAPIRequest = true;
             controllerGenerateInvoiceObj3.generateInvoiceAPI();
             controllerGenerateInvoiceObj3.generateInvoice();
             
             Configuration__c automatedCS1 = Configuration__c.getValues('MANUAL_INVOICE_GENERATION_STATUS'); 
             automatedCS1.String_Value__c = 'Posted';
             update automatedCS1;
             ApexPages.Standardcontroller controllerObj9 = new Apexpages.Standardcontroller(job);
             ControllerGenerateInvoice controllerGenerateInvoiceObj9 = new ControllerGenerateInvoice(controllerObj9);
             controllerGenerateInvoiceObj9.isAPIRequest = true;
             controllerGenerateInvoiceObj9.generateInvoiceAPI();
             controllerGenerateInvoiceObj9.generateInvoice(); 
             test.stopTest(); 
        }
        static testMethod void ClassAfterOnInvoiceLIne() {
            
            ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
            ControllerInsertCustomSettings.insertValues();
            Account account = new Account(Name = 'Test Account',Preferred_Billing_Day__c = '10');
            insert account;

            Account account1 = [select Name From Account Where Id =: account.id];
            System.assertEquals('Test Account', account1.Name);

            list<Contact> listContacts = new list<Contact>();
            listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com'));
            listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com'));
            insert listContacts;
            list<Currency__c> listOfCurrencies = new list<Currency__c>();
            Currency__c currency2 = new Currency__c(Name = 'USD',Symbol__c = '$');
            listOfCurrencies.add(currency2); 
            Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
            listOfCurrencies.add(currency1);
            insert listOfCurrencies;


            Job__c job = new Job__c(Account__c = account.id,Status__c = 'Draft',Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = listOfCurrencies[0].Id);
             insert job;
             Job_Product__c  jobProduct= new Job_Product__c(Name = 'jobProduct',Job__c = job.Id);
             insert jobProduct;

             Job_Rate_Plan__c jobRP = new Job_Rate_Plan__c(Name = 'JobRP',Job_Product__c =jobProduct.Id);
             insert jobRP;

             Job_Rate_Plan_Charge__c charge = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Job_Rate_Plan__c =jobRP.Id,Status__c='Draft',Quantity__c = 12,Price_Type__c = System.Label.OptionUsage,Accounting_Code__c = '12345',Unit_Price__c = 12);
             insert charge;
             Job_Rate_Plan_Charge__c charge1 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Service_Activation_Date__c = system.TODAY(),Service_End_Date__c=system.TODAY().addMonths(4),Job_Rate_Plan__c =jobRP.Id,Status__c='Draft',Quantity__c = 12,Price_Type__c = System.Label.OptionUsage,Accounting_Code__c = '12345',Unit_Price__c = 12);
             insert charge1;
             Job_Rate_Plan_Charge__c charge2 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Next_Charge_Date__c = system.TODAY(),Service_End_Date__c=system.TODAY().addMonths(4),Job_Rate_Plan__c =jobRP.Id,Status__c='Draft',Quantity__c = 12,Price_Type__c =System.Label.OptionOneTime,Accounting_Code__c = '12345',Unit_Price__c = 12);
             insert charge2;
             List< Invoice__c> listinvoice= new List< Invoice__c>();
             Invoice__c invoice = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                    CurrencyL__c = listOfCurrencies[0].Id,Invoice_Status__c = CommonUtilClass.STATUS_POSTED,Order__c = job.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both');
                    
            insert invoice;
            listinvoice.add(invoice);
            list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id,Status__c=CommonUtilClass.STATUS_POSTED,Job_Rate_Plan_Charge__c = charge.ID,Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,Job__c = job.Id,Tax__c=10,Vat__c=20,Discount_Value__c=1,Line_Amount__c=10,Credit_Line_Amount__c=1));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id,Status__c=CommonUtilClass.STATUS_POSTED,Job_Rate_Plan_Charge__c = charge1.ID,Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,Job__c = job.Id,Tax__c=10,Vat__c=20,Discount_Value__c=1,Line_Amount__c=10,Credit_Line_Amount__c=null));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id,Status__c=CommonUtilClass.STATUS_POSTED,Job_Rate_Plan_Charge__c = charge2.ID,Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,Job__c = job.Id,Tax__c=10,Vat__c=20,Discount_Value__c=1,Line_Amount__c=10,Credit_Line_Amount__c=1));
            insert listInvoiceLines;
            list<Usage_Charge__c> listOfUsageCharge = new list<Usage_Charge__c>();
            listOfUsageCharge.add(new Usage_Charge__c(Invoice_Line__c = listInvoiceLines[0].Id,Order_Rate_Plan_Charge__c = charge.Id,Start_Date__c=system.TODAY(),End_Date__c = system.TODAY().addMonths(4),Invoice__c = invoice.Id, Quantity__c = 10));
            listOfUsageCharge.add(new Usage_Charge__c(Invoice_Line__c = listInvoiceLines[1].Id,Order_Rate_Plan_Charge__c = charge1.Id,Start_Date__c=system.TODAY(),End_Date__c = system.TODAY().addMonths(4),Invoice__c = invoice.Id, Quantity__c = 10));
            insert listOfUsageCharge;

            Credit_Note__c creditnote=new Credit_Note__c(Account__c=account.id,Billing_Contact__c=listContacts.get(0).id,Credit_Note_Date__c=system.today(),Credit_Note_Status__c='Posted',CurrencyL__c=listOfCurrencies.get(0).id,Order__c=job.id,Related_Invoice__c=invoice.id);
            insert creditnote;

            Credit_Line__c creditline=new Credit_Line__c(Calculated_Quantity__c=10,Charge_Start_Date__c=system.today(),Charge_End_Date__c=system.today()+30,Credit_Note__c=creditnote.id,CurrencyL__c=listOfCurrencies.get(0).id,Invoice__c=invoice.id,Invoice_Line__c=listInvoiceLines.get(0).id,Order__c=job.id,Order_Rate_Plan_Charge__c=charge.id,Quantity__c=10,Line_Amount__c=100, Credit_Type_Applied__c = 'Date');
            insert creditline;
              
              ApexPages.StandardController invoiceobj = new ApexPages.StandardController(invoice);
              ControllerCreateCreditNote  ControllerCreateCreditNoteobj = new ControllerCreateCreditNote(invoiceobj);

              
              for(ControllerCreateCreditNote.InvoiceLineWrapper wrapClass : ControllerCreateCreditNoteobj.ListOfInvoiceLineWrapper){
                 wrapClass.isSelected = true;
                 wrapClass.creditAmount = 5;
              }
              
              ControllerCreateCreditNoteobj.calculateCreditLineAmount();
              ControllerCreateCreditNoteobj.backToCreditNote();

              ControllerCreateCreditNoteobj.createCreditNote();
              ControllerCreateCreditNoteobj.displayCreditLines();
              ControllerCreateCreditNoteobj.closePopup();

              ApexPages.StandardController invoiceobj2 = new ApexPages.StandardController(invoice);
              ControllerCreateCreditNote  ControllerCreateCreditNoteobj1 = new ControllerCreateCreditNote(invoiceobj2);

              for(ControllerCreateCreditNote.InvoiceLineWrapper wrapClass : ControllerCreateCreditNoteobj1.ListOfInvoiceLineWrapper){
                 wrapClass.isSelected = false;
                 wrapClass.creditAmount = -10;
              }
            
              ControllerCreateCreditNoteobj1.createCreditNote();
              
            //cancelling invoice
            invoice.Invoice_Status__c = CommonUtilClass.STATUS_CANCELLED;
            update invoice;

            ApexPages.StandardController invoiceobj1 = new ApexPages.StandardController(invoice);
            ControllerCreateCreditNote  ControllerCreateCreditNoteobj2 = new ControllerCreateCreditNote(invoiceobj1);

            listInvoiceLines[0].Status__c = CommonUtilClass.STATUS_CANCELLED;
            update listInvoiceLines[0];
            ClassAfterOnInvoiceLine.INVOICELINE_AFTER_PROCESSING_COMPLETE = false;
            listInvoiceLines[1].Status__c = CommonUtilClass.STATUS_CANCELLED;
            update listInvoiceLines[1];
            ClassAfterOnInvoiceLine.INVOICELINE_AFTER_PROCESSING_COMPLETE = false;
            listInvoiceLines[2].Status__c = CommonUtilClass.STATUS_CANCELLED;
            update listInvoiceLines[2];
            
        }
        static testMethod void ClassForAfterOnInvoice() {
            Account account = new Account(Name = 'Test Account',Preferred_Billing_Day__c = '10');
            insert account;

            Account account1 = [select Name From Account Where Id =: account.id];
            System.assertEquals('Test Account', account1.Name);

            list<Contact> listContacts = new list<Contact>();
            listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com'));
            listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com'));
            insert listContacts;
            list<Currency__c> listOfCurrencies = new list<Currency__c>();
            Currency__c currency2 = new Currency__c(Name = 'USD',Symbol__c = '$');
            listOfCurrencies.add(currency2); 
            Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
            listOfCurrencies.add(currency1);
            insert listOfCurrencies;
            Job__c job = new Job__c(Account__c = account.id,Status__c = 'Draft',Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = listOfCurrencies[0].Id);
             insert job;
             Job_Product__c  jobProduct= new Job_Product__c(Name = 'jobProduct',Job__c = job.Id);
             insert jobProduct;

             Job_Rate_Plan__c jobRP = new Job_Rate_Plan__c(Name = 'JobRP',Job_Product__c =jobProduct.Id);
             insert jobRP;

             Job_Rate_Plan_Charge__c charge = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Job_Rate_Plan__c =jobRP.Id,Status__c='Draft',Quantity__c = 12,Price_Type__c = System.Label.OptionUsage,Accounting_Code__c = '12345',Unit_Price__c = 12);
             insert charge;
             Job_Rate_Plan_Charge__c charge1 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Service_Activation_Date__c = system.TODAY(),Service_End_Date__c=system.TODAY().addMonths(4),Job_Rate_Plan__c =jobRP.Id,Status__c='Draft',Quantity__c = 12,Price_Type__c = System.Label.OptionUsage,Accounting_Code__c = '12345',Unit_Price__c = 12);
             insert charge1;
             Job_Rate_Plan_Charge__c charge2 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Next_Charge_Date__c = system.TODAY(),Service_End_Date__c=system.TODAY().addMonths(4),Job_Rate_Plan__c =jobRP.Id,Status__c='Draft',Quantity__c = 12,Price_Type__c =System.Label.OptionOneTime,Accounting_Code__c = '12345',Unit_Price__c = 12);
             insert charge2;
             Invoice__c invoice = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                    CurrencyL__c = listOfCurrencies[0].Id,Invoice_Status__c = CommonUtilClass.STATUS_POSTED,Order__c = job.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both');
                
            insert invoice;
            //cancelling the invoice
            invoice.Invoice_Status__c = CommonUtilClass.STATUS_CANCELLED;
            update invoice;
            list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id,Status__c=CommonUtilClass.STATUS_POSTED,Job_Rate_Plan_Charge__c = charge.ID,Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id,Status__c=CommonUtilClass.STATUS_POSTED,Job_Rate_Plan_Charge__c = charge1.ID,Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id,Status__c=CommonUtilClass.STATUS_POSTED,Job_Rate_Plan_Charge__c = charge2.ID,Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,Job__c = job.Id));
            insert listInvoiceLines;
            ClassAfterOnInvoice.INVOICE_AFTER_PROCESSING_COMPLETE = false;
            ControllerCancelInvoice.isButtonClicked = true;
            //cancelling the invoice
            invoice.Invoice_Status__c = CommonUtilClass.STATUS_CANCELLED;
            update invoice;
            
            ClassAfterOnInvoice.INVOICE_AFTER_PROCESSING_COMPLETE = false;
            delete invoice;
            Invoice__c invoiceNew = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                    CurrencyL__c = listOfCurrencies[0].Id,Invoice_Status__c = CommonUtilClass.STATUS_POSTED,Order__c = job.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both');
                
            insert invoiceNew;
            ClassAfterOnInvoice.INVOICE_AFTER_PROCESSING_COMPLETE = false;
            ControllerCancelInvoice.isButtonClicked = true;
            /*invoiceNew.Invoice_Status__c = CommonUtilClass.STATUS_DRAFT;
            update invoiceNew;*/
            ClassAfterOnInvoice.INVOICE_AFTER_PROCESSING_COMPLETE = false;
            ControllerCancelInvoice.isButtonClicked = true; 
            invoiceNew.Invoice_Status__c = CommonUtilClass.STATUS_CANCELLED;
            update invoiceNew;
        }
        static testMethod void customInvoiceGenerator() {
            ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
            ControllerInsertCustomSettings.insertValues();

            Configuration__c c1 = Configuration__c.getValues('ORDER_LEGAL_ENTITY_FIELD_NAME');
            c1.String_Value__c = 'Name';
            update c1;

            Sequence_Number__c sequenceNumber = new Sequence_Number__c(Name='Test Order', Invoice_Prefix__c='IND-',Invoice_Suffix__c='-GRT',Invoice_Next_Number__c=17);
            insert sequenceNumber;

         
            Account account = new Account(Name = 'Test Account');
            insert account;

            Account account1 = [select Name From Account Where Id =: account.id];
            System.assertEquals('Test Account', account1.Name);
             
            contact c = new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com');
            insert c;

            Currency__c currency1 = new Currency__c(name = 'USD', Symbol__c = '$');
            insert currency1;
            Account masterAccount = new Account(Name = 'Test Master Account');
            insert masterAccount;
    List<Job__c> listjob= new List<Job__c>();
            Job__c masterOrder = new Job__c(Account__c = account.id,Billing_Contact__c = c.Id,
                        Shipping_Contact__c = c.Id, Sub_Total__c = 100, Discount_Value__c = 0,
                        Service_End_Date__c =  System.today(),
                        Service_Activation_Date__c = System.today(),
                        Name='Test master Order',
                        Is_Billing_Master_Order__c = true,
                        CurrencyL__c = currency1.Id); 
            insert masterOrder;
            listjob.add(masterOrder);
            Job_Product__c  masterOrdeProduct= new Job_Product__c(Name = 'jobProduct',Job__c = masterOrder.Id);
            insert masterOrdeProduct;

           Job_Rate_Plan__c masterOrdeRP = new Job_Rate_Plan__c(Name = 'JobRP',Job_Product__c =masterOrdeProduct.Id);
           insert masterOrdeRP;

           Job_Rate_Plan_Charge__c masterOrdecharge = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Service_End_Date__c =  System.today(),Service_Activation_Date__c=system.TODAY(), Job_Rate_Plan__c = masterOrdeRP.Id,Status__c = 'Ready to be Invoiced',Min_Customer_Spend__c = 230,Quantity__c = 12,Price_Type__c = 'One Time',Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c=144,VAT_Percentage__c=1,Tax_Percentage__c=1);
           insert masterOrdecharge;
                
            Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = c.Id,
                        Shipping_Contact__c = c.Id, Sub_Total__c = 100, Discount_Value__c = 0,
                        Service_End_Date__c =  System.today(),
                        Service_Activation_Date__c = System.today(),
                        Name='Test Order',
                        Billing_Master_Order__c = masterOrder.id,
                        Billing_Master_Account__c = account.id,
                        CurrencyL__c = currency1.Id); 
            insert job;
            listjob.add(job);
            Job_Product__c  jobProduct= new Job_Product__c(Name = 'jobProduct',Job__c = job.Id);
            insert jobProduct;

           Job_Rate_Plan__c jobRP = new Job_Rate_Plan__c(Name = 'JobRP',Job_Product__c =jobProduct.Id);
           insert jobRP;

           Job_Rate_Plan_Charge__c charge = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Service_End_Date__c =  System.today(),Service_Activation_Date__c=system.TODAY(), Job_Rate_Plan__c =jobRP.Id,Status__c = 'Ready to be Invoiced',Min_Customer_Spend__c = 230,Quantity__c = 12,Price_Type__c = 'One Time',Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c=144,VAT_Percentage__c=1,Tax_Percentage__c=1);
           insert charge;
           
           Job_Rate_Plan_Charge__c charge2 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC2',Service_End_Date__c =  System.today(),Service_Activation_Date__c=system.TODAY(), Job_Rate_Plan__c =jobRP.Id,Status__c = 'Ready to be Invoiced',Quantity__c = 12,Min_Customer_Spend__c = 230,Price_Type__c = 'Monthly',Accounting_Code__c = '12345',Unit_Price__c = 30,Price__c=360,VAT_Percentage__c=1,Tax_Percentage__c=1);
           insert charge2;
           
           Job_Rate_Plan_Charge__c charge3 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC3',Service_End_Date__c =  System.today(),Committed_Quantity__c= 8,Service_Activation_Date__c=system.TODAY(),Price_Format__c= CommonUtilClass.PRICE_FORMAT_VOLUME, Job_Rate_Plan__c =jobRP.Id,Status__c = 'Ready to be Invoiced',Quantity__c = 12,Price_Type__c = System.Label.OptionUsage,Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c=144,VAT_Percentage__c=1,Tax_Percentage__c=1);
           insert charge3;
           
           Job_Rate_Plan_Charge__c charge4 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC4',Service_End_Date__c =  System.today(),Service_Activation_Date__c=system.TODAY(),Price_Format__c= 'Volume Pricing', Job_Rate_Plan__c =jobRP.Id,Status__c = 'Ready to be Invoiced',Quantity__c = 12,Price_Type__c = 'Annual',Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c=144,VAT_Percentage__c=1,Tax_Percentage__c=1, Billing_Master_Order_Rate_Plan_Charge__c = masterOrdecharge.id);
           insert charge4;
           
           Job_Rate_Plan_Charge__c charge5 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC5',Service_End_Date__c =  System.today(),Service_Activation_Date__c=system.TODAY(),Price_Format__c= 'Volume Pricing', Job_Rate_Plan__c =jobRP.Id,Status__c = 'In Progress',Quantity__c = 12,Price_Type__c = System.Label.OptionUsage,Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c=144,VAT_Percentage__c=1,Tax_Percentage__c=1);
           insert charge5;
           
           Job_Rate_Plan_Charge__c charge6 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC6',Service_End_Date__c =  System.today(),Service_Activation_Date__c=system.TODAY(),Price_Format__c= 'Volume Pricing', Job_Rate_Plan__c =jobRP.Id,Status__c = 'In Progress',Quantity__c = 12,Price_Type__c = 'Weekly',Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c=144,VAT_Percentage__c=1,Tax_Percentage__c=1);
           insert charge6;
           Job_Rate_Plan_Charge__c charge7 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC4',Service_End_Date__c =  System.today(),Service_Activation_Date__c=system.TODAY(),Price_Format__c= 'Tiered Pricing', Job_Rate_Plan__c =jobRP.Id,Status__c = 'Ready to be Invoiced',Quantity__c = 12,Price_Type__c = 'Annual',Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c=144,VAT_Percentage__c=1,Tax_Percentage__c=1, Billing_Master_Order_Rate_Plan_Charge__c = masterOrdecharge.id);
           insert charge7;
            Job_Rate_Plan_Charge__c charge8 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC4',Service_End_Date__c =  System.today(),Service_Activation_Date__c=system.TODAY(),Price_Format__c= 'Flat Fee Pricing', Job_Rate_Plan__c =jobRP.Id,Status__c = 'Ready to be Invoiced',Quantity__c = 12,Price_Type__c = 'Annual',Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c=144,VAT_Percentage__c=1,Tax_Percentage__c=1, Billing_Master_Order_Rate_Plan_Charge__c = masterOrdecharge.id);
           insert charge8;
           Job_Rate_Plan_Charge_Tier__c tier = new Job_Rate_Plan_Charge_Tier__c();
           tier.Start_Unit__c = 1;
           tier.Start_Unit__c = 16;
           tier.Job_Rate_Plan_Charge__c = charge3.id;
           tier.Unit_Price__c = 55;
           tier.Unit_Cost_Price__c = 66;
           
           insert tier;
           
           Job_Rate_Plan_Charge_Tier__c tier1 = new Job_Rate_Plan_Charge_Tier__c();
           tier1.Start_Unit__c = 17;
           tier1.Start_Unit__c = 100;
           tier1.Job_Rate_Plan_Charge__c = charge3.id;
           tier1.Unit_Price__c = 250;
           tier1.Unit_Cost_Price__c = 500;
           
           insert tier1;
           
           Usage_Charge__c usage = new Usage_Charge__c();
           usage.Order_Rate_Plan_Charge__c = charge3.id;
           usage.End_Date__c = System.today()-2;
           usage.Start_Date__c = System.today()-2;
           usage.Quantity__c = 5;
           insert usage;
           
           Usage_Charge__c usage1 = new Usage_Charge__c();
           usage1.Order_Rate_Plan_Charge__c = charge3.id;
           usage1.End_Date__c = System.today()-6;
           usage1.Start_Date__c = System.today()-6;
           usage1.Quantity__c = 20;
           insert usage1;

           Payment_Plan_Installment__c paymentPlanInstallments = new Payment_Plan_Installment__c(Account__c = account.id, No_of_tries__c = 0, Order__c = job.id, Payment_Amount__c = 70);
           insert paymentPlanInstallments;
            Job__c job1 = new Job__c(Account__c = account.id,Billing_Contact__c = c.Id,
                        Shipping_Contact__c = c.Id, Sub_Total__c = 100, Discount_Value__c = 0,
                        Service_End_Date__c =  System.today(),
                        Service_Activation_Date__c = System.today(),
                        Name='Test Order',
                        Billing_Master_Order__c = masterOrder.id,
                        Billing_Master_Account__c = account.id,
                        CurrencyL__c = currency1.Id); 
            insert job1;
            listjob.add(job1);
            Job_Product__c  jobProduct1= new Job_Product__c(Name = 'jobProduct1',Job__c = job1.Id);
            insert jobProduct1;

           Job_Rate_Plan__c jobRP1 = new Job_Rate_Plan__c(Name = 'JobRP1',Job_Product__c =jobProduct1.Id);
           insert jobRP1;

           Job_Rate_Plan_Charge__c charge9 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC41',Service_End_Date__c =  System.today(),Service_Activation_Date__c=system.TODAY(),Price_Format__c= 'Flat Fee Pricing', Job_Rate_Plan__c =jobRP1.Id,Status__c = 'Ready to be Invoiced',Quantity__c = 12,Price_Type__c = 'Annual',Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c=144,VAT_Percentage__c=1,Tax_Percentage__c=1, Billing_Master_Order_Rate_Plan_Charge__c = masterOrdecharge.id);
           insert charge9;
           
           CustomInvoiceGenerator customGenerator = new CustomInvoiceGenerator();
           customGenerator.generateInvoiceForOrder(masterOrder.Id, System.today(), null, true, false, true);
           customGenerator.generateInvoiceForOrder(job.Id, System.today(), System.today(), true, false, true);
           customGenerator.generateInvoiceForOrder(job1.Id, System.today(), System.today(), true, false, true);
           
           // cover catch block of CustomInvoiceGenerator
           //customGenerator.generateInvoiceForOrder(null,null,null,null,null,null);
           
           CustomInvoiceGenerator.MethodParameters methodPram = new CustomInvoiceGenerator.MethodParameters();
           
           methodPram.orderId = job.Id;
           methodPram.invoiceDate = System.today();
           methodPram.targetDate = System.today();
           methodPram.cutoffDate = System.today();
           methodPram.shouldBillUsages = true;
           methodPram.simulateInvoiceGeneration = false;
           methodPram.autoPostInvoice = true;
           
           string sReponse = customGenerator.generateInvoiceForOrder(methodPram);
           
       }

    }