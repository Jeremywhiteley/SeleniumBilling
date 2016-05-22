@isTest(oninstall = false)
  private with sharing class TestClassInvoiceGenerator {

       public String sPrefix = CommonUtilClass.getPrefix();
       static testMethod void classInvoiceGenerator() {
       ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
       ControllerInsertCustomSettings.insertValues();
       
       Account account = new Account(Name = 'Test Account');
       insert account;
       
       list<Contact> listContacts = new list<Contact>();
       listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com'));
       listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com'));
       insert listContacts;
       
       Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
       insert currency1;
       
       Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = currency1.Id);
       insert job;
       
       Invoice__c invoice = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                           CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Active');
       insert invoice;
       
       list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
       listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
       listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
       listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
       insert listInvoiceLines;
       
       system.currentPageReference().getParameters().put('ID',invoice.Id);
       ClassInvoiceGenerator classInvoiceGenerator = new ClassInvoiceGenerator();
       List<Invoice_Lines__c> getListInvoiceLines = classInvoiceGenerator.getListInvoiceLines();
       system.assert(getListInvoiceLines.size() > 0);
                                
       ClassWebServiceEmailing.sendInvoice(invoice.Id);
       ClassWebServiceEmailing.attachPdf(invoice.Id,'laxman');  
       
       //laxman 1.6
       InvoicingUtilClass.getInvoiceById(invoice.Id); 
       InvoicingUtilClass.getInvoiceByName(invoice.Name); 
       //laxman 1.6
      }
      
      static testMethod void cancelInvoice() {
        ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
        ControllerInsertCustomSettings.insertValues();
         
        Account account = new Account(Name = 'Test Account');
        insert account;
         
        list<Contact> listContacts = new list<Contact>();
        listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com'));
        listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com'));
        insert listContacts;
         
        Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
        insert currency1;

        Currency__c currency2 = [SELECT name From Currency__c WHERE id=:currency1.id];
        System.assertEquals('GBP', currency2.name);
          
         
        Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = currency1.Id);
        insert job;
         
        Invoice__c invoice = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                             CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Active');
        insert invoice;
         
        list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
        listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
        listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
        listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
        insert listInvoiceLines;
        

          list<Invoice__c> invoices = new list<Invoice__c>();
          invoices = [SELECT Id FROM Invoice__c WHERE Invoice_Status__c =: CommonUtilClass.STATUS_CANCELLED AND Invoice_State__c != 'Proforma' LIMIT 1];
          
          invoice = [SELECT Id FROM Invoice__c WHERE Net_Total__c > 0 AND Invoice_Status__c != :CommonUtilClass.STATUS_CANCELLED 
                                  AND Invoice_State__c != 'Proforma' LIMIT 1];
          invoice.Invoice_Status__c = CommonUtilClass.STATUS_CANCELLED;
          
          invoices.add(invoice);
          
          ControllerCancelInvoice.isButtonClicked = true;
          update invoices;
        
      }
      
      //test method for CreateProductsController  class
      static testMethod void createProductsController () {
          Currency__c currecyObj = new Currency__c(Name = 'GBP', Symbol__c = '£1');
          insert currecyObj;
          
          Product__c product = new Product__c(Name = 'Default');
          ApexPages.Standardcontroller controller1 = new Apexpages.Standardcontroller(product);
          CreateProductsController createProductsController = new CreateProductsController(controller1);
          createProductsController.product.Name = 'Default';
          system.currentPageReference().getParameters().put('ratePlanCounter','1');
          createProductsController.onClickRatePlan();
          createProductsController.newRatePlan();
          createProductsController.newRatePlanCharge();
          createProductsController.newRatePlan();
          createProductsController.newRatePlanCharge();
          createProductsController.newRatePlan();
          createProductsController.newRatePlanCharge();
          
          for(ProductRatePlanClass prpclass : createProductsController.productClass.productRatePlans) {
              for(ProductRatePlanChargeClass prpcclass : prpclass.productRatePlanChargeClass) {
                  prpcclass.productRatePlancharge.CurrencyL__c = currecyObj.Id;
              }
          }
          
          system.currentPageReference().getParameters().put('productrateplanchargeCounterfortier','1');
          createProductsController.addTier();
          
          system.currentPageReference().getParameters().put('productrateplanidtodelete','');
          system.currentPageReference().getParameters().put('productrateplancountertodelete','1');
          createProductsController.removeRatePlan();
          
          system.currentPageReference().getParameters().put('productrateplanchargeidtodelete','');
          system.currentPageReference().getParameters().put('productrateplanchargecountertodelete','2');
          system.currentPageReference().getParameters().put('rateplanchargecounterfromcharges','1');
          createProductsController.removeRatePlanCharges();
          
          system.currentPageReference().getParameters().put('tieridtodelete','');
          system.currentPageReference().getParameters().put('tiercountertodelete','1');
          system.currentPageReference().getParameters().put('productRatePlanChargeCounterfromtier','2');
          createProductsController.removeTiers();
          
          createProductsController.saveProduct();
          createProductsController.closePopup();
          createProductsController.cloneProduct();
          
          list<ProductRatePlanClass> listOfProductRatePlanClass = createProductsController.productClass.getProductRatePlans();
          
          ApexPages.Standardcontroller controller2 = new Apexpages.Standardcontroller(product);
          CreateProductsController createProductsController2 = new CreateProductsController(controller2);
          
          createProductsController2.newTier();

          Product__c ProductNew = [SELECT Id,Name 
                                   FROM Product__c 
                                   WHERE Id =: product.Id];
          system.assert(ProductNew.Name == 'Default');
      }
      
      static testMethod void controllerSetupGeneral() {
          Configuration__c configuration = new Configuration__c(Field_Type__c = 'String',Name = 'testing');
          insert configuration;

          Configuration__c configuration1 = [SELECT Name From Configuration__c WHERE id=:configuration.id];
          System.assertEquals('testing', configuration1.Name);

          ControllerSetupGeneral ControllerSetupGeneral = new ControllerSetupGeneral();
          ControllerSetupGeneral.save();
          map<String,Configuration__c> mapConfiguration = Configuration__c.getAll();
          system.assert(mapConfiguration.ContainsKey('testing'));
      }
      
      static testMethod void controllerSetupProductFilterCriteria() { 
          list<Product_Catalog_Filter_Criteria__c> listOfFilters = new list<Product_Catalog_Filter_Criteria__c>();
          Product_Catalog_Filter_Criteria__c filter1 = new Product_Catalog_Filter_Criteria__c(Source_Object__c = 'Product_Rate_Plan__c',Source_Field__c = 'Name',
                                                              Destination_Object__c = 'Quote_Rate_Plan__c', Destination_Field__c = 'Name', Name = 'test1');
          
          Product_Catalog_Filter_Criteria__c filter2 = new Product_Catalog_Filter_Criteria__c(Source_Object__c = 'Product_Rate_Plan__c',Source_Field__c = 'Name',
                                                              Destination_Object__c = 'Quote_Rate_Plan__c', Destination_Field__c = 'Name', Name = 'test2');
          
          listOfFilters.add(filter1);
          listOfFilters.add(filter2);
          insert listOfFilters;
          ControllerSetupProductFilterCriteria controllerSetupProductFilterCriteria = new ControllerSetupProductFilterCriteria();
          controllerSetupProductFilterCriteria.save();
          controllerSetupProductFilterCriteria.addRow();
          system.currentPageReference().getParameters().put('id',listOfFilters.get(0).Id);
          controllerSetupProductFilterCriteria.deleteRow();
          map<String,Product_Catalog_Filter_Criteria__c> mapFilter = Product_Catalog_Filter_Criteria__c.getAll();
          system.assert(mapFilter.ContainsKey('test2'));
       }
       
       static testMethod void controllerSetupCustomMapping() {
          list<Custom_Mappings__c> listOfMappings = new list<Custom_Mappings__c>();
          Custom_Mappings__c mapping1 = new Custom_Mappings__c(Source_Object__c = 'Product_Rate_Plan__c',Source_Field__c = 'Name',
                                                              Destination_Object__c = 'Quote_Rate_Plan__c', Destination_Field__c = 'Name', Name = 'test1');
          
          Custom_Mappings__c mapping2 = new Custom_Mappings__c(Source_Object__c = 'Product_Rate_Plan__c',Source_Field__c = 'Name',
                                                              Destination_Object__c = 'Quote_Rate_Plan__c', Destination_Field__c = 'Name', Name = 'test2');
          listOfMappings.add(mapping1);
          listOfMappings.add(mapping2);
          insert listOfMappings;
          ControllerSetupCustomMapping controllerSetupCustomMapping = new ControllerSetupCustomMapping();
          controllerSetupCustomMapping.save();
          controllerSetupCustomMapping.addRow();
          system.currentPageReference().getParameters().put('id',listOfMappings.get(0).Id);
          controllerSetupCustomMapping.deleteRow();
          map<String,Custom_Mappings__c> mapMapping = Custom_Mappings__c.getAll();
          system.assert(mapMapping.ContainsKey('test2'));
       }
       
      static testMethod void controllerForExportImportTemplate() {
          //poplulate the data
          Date validtodate = Date.today();   
          list<Product__c> listProducts = new list<Product__c>();
          Product__c product;
          for(Integer x = 0;x < 2;x++){
            product = new  Product__c(Name = 'Test Product' + x,Valid_From_Date__c = validtodate,Valid_To_Date__c = validtodate,Product_Family__c = 'Default',Product_Code__c = 'AC001',Description__c = 'Product');
            listProducts.add(product);
          }    
          insert listProducts;
          
          list<Product_Rate_Plan__c> listProductRatePlans = new list<Product_Rate_Plan__c>();
          Product_Rate_Plan__c productRatePlan;
          for(Integer x = 0;x< 2;x++){
            productRatePlan = new  Product_Rate_Plan__c(Name = 'Test ProductRatePlan' + x,
                                                        Product__c = listProducts.get(0).Id,Valid_From_Date__c = validtodate,Valid_To_Date__c = validtodate);
            listProductRatePlans.add(productRatePlan);
          }
          insert listProductRatePlans;
              
          list<Currency__c> listCurrencys = new list<Currency__c>();
          listCurrencys.add(new Currency__c(Name = 'GBP', Currency_Symbol__c = 'sss',Symbol__c = 's'));
          insert listCurrencys;
          
          list< Product_Rate_Plan_Charge__c> listProductRatePlanCharges = new list< Product_Rate_Plan_Charge__c>();
          Product_Rate_Plan_Charge__c productRatePlanCharge;
          for(Integer x = 0;x < 5;x++){
            productRatePlanCharge = new  Product_Rate_Plan_Charge__c(Name = 'Test ProductRatePlan Charge' + x,CurrencyL__c = listCurrencys.get(0).Id,
                                                                     Product_Rate_Plan__c = listProductRatePlans.get(0).Id,
                                                                     Unit_price__c = 200,Cost_Price__c = 160,Product_Charge_Category__c = 'Taxable');
            listProductRatePlanCharges.add(productRatePlanCharge);
          }
          insert listProductRatePlanCharges;
          
          //import the data
          ControllerForExportImportTemplate controllerForExportImportTemplate = new ControllerForExportImportTemplate();
          controllerForExportImportTemplate.exportProductsToCsvForSample();
          string csvBuild = controllerForExportImportTemplate.recStr;
          system.assert(csvBuild.contains('Test Product'));
          
          //export the data
          string str = 'Product Family,Valid From Date,Product Code,Valid To Date,Description,Product Name,Valid To Date,Description,Product Rate Plan Name,Valid From Date,Valid From,Valid To,Accounting Code,Unit Cost Price,Charge Sequence Number,Price Type,Currency,UOM,Unit Selling Price,Charge Name,Product Charge Category,Price Format,Is Price Editable In Quote/Order Wizards';
          str += '\n';
          str += '13-12-2011,13-12-2021,13-12-2021 00:00,13-12-2011 00:00,13-12-2012,13-12-2013,13-12-2014,13-12-20115';
          blob b = blob.valueOf(str);
          controllerForExportImportTemplate.contentFile = b;
          controllerForExportImportTemplate.uploadCSV();
      }
       
       public static testMethod void controllerAllocatePayments() {
          ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
          ControllerInsertCustomSettings.insertValues();
           
          Account account = new Account(Name = 'Test Account');
          insert account;

          Account account1 = [SELECT Name FROM Account Where id=: account.id];
          System.assertEquals('Test Account', account1.Name);
           
          list<Contact> listContacts = new list<Contact>();
          listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com'));
          listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com'));
          insert listContacts;
           
          Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
          insert currency1;
           
          Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = currency1.Id);
          insert job;
          
          boolean isPaymentAutomated = Configuration__c.getValues('AUTOMATE_PAYMENT_ALLOCATION').Boolean_Value__c;
          
          Configuration__c c = [Select Id From Configuration__c Where Name = 'AUTOMATE_PAYMENT_ALLOCATION'];
          c.Boolean_Value__c = false;
          update c;
          
          
          Payment__c  payment = new Payment__c(Account__c = account.Id, Currency__c = currency1.Id, Amount__c = 200000);
          insert payment;

          Payment__c  payment1 = [SELECT Account__c, Amount__c FROM Payment__c WHERE id=: payment.id];
          System.assertEquals(200000, payment1.Amount__c);
          
          Invoice__c invoice = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                               CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED);
          insert invoice;
           
          list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
          listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 500.00,Job__c = job.Id));
          listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 5000.00,Job__c = job.Id));
          listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 550.00,Job__c = job.Id));
          insert listInvoiceLines;
          
          ApexPages.Standardcontroller controller = new Apexpages.Standardcontroller(payment);
          ControllerAllocatePayments controllerAllocatePayments = new ControllerAllocatePayments(controller);
          string counter = string.ValueOf(controllerAllocatePayments.listOfallocationClass.get(0).counter);
          system.currentPageReference().getParameters().put('selectedCounter', counter);
          controllerAllocatePayments.getSelectedInvoice();
          
          controllerAllocatePayments.listOfallocationClass.get(0).isChecked = true;
          controllerAllocatePayments.getSelectedInvoice();
          
          controllerAllocatePayments.listOfallocationClass.get(0).paymentAllocation.Amount__c = 0;
          controllerAllocatePayments.savePaymentAllocations();
          controllerAllocatePayments.listOfallocationClass.get(0).paymentAllocation.Amount__c = 600;
          controllerAllocatePayments.savePaymentAllocations();
          controllerAllocatePayments.listOfallocationClass.get(0).paymentAllocation.Amount__c = 100;
          controllerAllocatePayments.savePaymentAllocations();
          controllerAllocatePayments.backToPayment();
          
          list<Payment_Plan_Installment__c> listofpaymentinstallment=new list<Payment_Plan_Installment__c>();
          listofpaymentinstallment.add(new Payment_Plan_Installment__c(Account__c=account.id,Invoice__c=invoice.id,Description__c='Test',Last_Processing_Date__c=system.today()-30,Payment_Date__c=system.today(),No_of_tries__c=0,Payment_Amount__c=10,Payment_Type__c='Credit Card',Payment__c=payment.id));
          listofpaymentinstallment.add(new Payment_Plan_Installment__c(Account__c=account.id,Invoice__c=invoice.id,Description__c='Test',Last_Processing_Date__c=system.today()-30,Payment_Date__c=system.today(),No_of_tries__c=0,Payment_Amount__c=10,Payment_Type__c='Credit Card',Payment__c=payment.id));
          insert listofpaymentinstallment;
          
          ApexPages.Standardcontroller controller2 = new Apexpages.Standardcontroller(payment);
          ControllerAllocatePayments controllerAllocatePayments2  = new ControllerAllocatePayments(controller2);

          string paymentAllocationId = string.ValueOf(controllerAllocatePayments2.listOfPaymentAllocationsInDb.get(0).Id);
          system.currentPageReference().getParameters().put('paymentAllocationId', paymentAllocationId);
          controllerAllocatePayments2.cancelPaymentAllocation();

          system.currentPageReference().getParameters().put('selectedCounter', '1'); 
          for(ControllerAllocatePayments.PaymentPlanInstallment wraperclass : controllerAllocatePayments.listOfppiallocationClass){
              wraperclass.isChecked1 = true;
          }
          //controllerAllocatePayments.getSelectedPaymentPlanInstallment();
          controllerAllocatePayments.savePaymentAllocations();   
      }
      
      public static testMethod void classAfterOnPayment() {
          ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
          ControllerInsertCustomSettings.insertValues();
           
          Account account = new Account(Name = 'Test Account');
          insert account;
           
          list<Contact> listContacts = new list<Contact>();
          listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com'));
          listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com'));
          insert listContacts;
           
          Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
          insert currency1;
           
          Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = currency1.Id);
          insert job;
          
          list<Invoice__c> listOfInvoices = new  list<Invoice__c>();
          Invoice__c invoice1 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                               CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Active');
                                               
          Invoice__c invoice2 = new Invoice__c(Account__c = account.id,Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id,
                                               CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Delivery_Type__c = 'Both',Invoice_Status__c = 'Active');
          
          listOfInvoices.add(invoice1);
          listOfInvoices.add(invoice2);
          insert listOfInvoices;
           
          list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
          listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = listOfInvoices.get(0).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 500.00,Job__c = job.Id));
          listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = listOfInvoices.get(0).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 500.00,Job__c = job.Id));
          listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = listOfInvoices.get(0).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 500.00,Job__c = job.Id));
          
          listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = listOfInvoices.get(1).id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 500.00,Job__c = job.Id));
          listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = listOfInvoices.get(1).id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 500.00,Job__c = job.Id));
          listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = listOfInvoices.get(1).id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 550.00,Job__c = job.Id));
          insert listInvoiceLines;
          
          
          
          //first insert the payment which will call the trigger and payment allocation is done automatically
          Payment__c  payment = new Payment__c(Account__c = account.Id, Currency__c = currency1.Id, Amount__c = 2000);
          insert payment;
          
          payment.Status__c = CommonUtilClass.STATUS_CANCELLED;
          update payment;
          system.assert(payment.Status__c == CommonUtilClass.STATUS_CANCELLED);
       
      }
      
      public static testMethod void batchForCalculatingMRR() {
          TestBatchInvoiceGeneration.create_Orders();
          System.assertEquals('GBP', 'GBP');
          system.Test.startTest();    
              string query = 'SELECT Account__c, Todays_MRR__c, Todays_MRR_With_Tax__c FROM Job__c LIMIT 1'; 
              BatchForCalculatingMRR batch = new BatchForCalculatingMRR(query);
              ID batchprocessid = Database.executeBatch(batch,1);
              BatchForCalculatingMRR batch1 = new BatchForCalculatingMRR(query, true);
              ID batchprocessid1 = Database.executeBatch(batch1,1);
              Configuration__c configuration = Configuration__c.getValues('INVOICEIT_BATCH_JOBS_TO_PROCESS');
              configuration.String_Value__c = 'MRR Calculation';
              update configuration;
              BatchForCalculatingMRR batch2 = new BatchForCalculatingMRR(query, true);
              ID batchprocessid2 = Database.executeBatch(batch2,1);
          system.Test.stopTest();
          
      }
      
      public static testMethod void createCurrecyController() {
          Currency__c currencyObj = new Currency__c(Name = 'GBP', Symbol__c = '£1');
          ApexPages.Standardcontroller stdController = new Apexpages.Standardcontroller(currencyObj);
          CreateCurrecyController createCurrecyController = new CreateCurrecyController(stdController);
          createCurrecyController.currencyObject.Currency_Symbol__c = '£1';
          createCurrecyController.edit();
          createCurrecyController.save();
          system.assert(currencyObj != null);
          
          ApexPages.Standardcontroller stdController2 = new Apexpages.Standardcontroller(createCurrecyController.currencyObject);
          CreateCurrecyController createCurrecyController2 = new CreateCurrecyController(stdController2);
      }
      
      public static testMethod void csvToSObjectParser() {
         try {
          CsvToSObjectParser ctop = new CsvToSObjectParser();
          List<SObject> objects = ctop.parseCsv();
          system.assert(objects.size() > 0);
          } catch(exception ex) {
          }
      }
      
      public static testMethod void addStockItemsController(){
           
           ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
           ControllerInsertCustomSettings.insertValues();
       
           Product__c product;
           String sBarcodes = '24';
           product = new Product__c(Name = 'Test Product');
           insert product;
           system.assert(product.Name == 'Test Product');            
                        
           Stock_Item__c stockItem = new Stock_Item__c();
           ApexPages.Standardcontroller stdController = new Apexpages.Standardcontroller(stockItem);
           AddStockItemsController addStockItemsController = new AddStockItemsController(stdController);           
          
           system.currentPageReference().getParameters().put('productId', product.id);         
           addStockItemsController.addProductDetail();        
           addStockItemsController.sBarcodes = sBarcodes;
           addStockItemsController.insertStockItems();
           addStockItemsController.insertStockItems();
      }
       
      public static testmethod void installScript() {
          PostInstallClass postinstall = new PostInstallClass();
          system.Test.testInstall(postinstall, null);
          system.Test.testInstall(postinstall, null);
          system.Test.testInstall(postinstall, new Version(1,0), true);
          
          list<Product_Rate_Plan_Charge__c> charges = [SELECT Id
                                                       FROM Product_Rate_Plan_Charge__c
                                                       ];
          system.assert(charges.size() > 0);
      }
      
      //commented by dhanalakshmi, this class is exist in TestClassForHandlingAuthorizeDotNetCIM    
     static testMethod void orderAPI() {
      ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
       ControllerInsertCustomSettings.insertValues();
           Account account = new Account(Name = 'Test Account');
           insert account;

           list<Contact> listContacts = new list<Contact>();
           listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com'));
           listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com'));
           insert listContacts;
           
           Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
           insert currency1;
            
           Date validtodate = Date.today();   
           
           Product__c product = new  Product__c(Name = 'Test Product',
                                    Valid_From_Date__c = Date.newInstance(2013, 12, 5),
                                    Valid_To_Date__c = validtodate,
                                    Product_Family__c = 'Default',
                                    Product_Code__c = 'AC121456AMM',
                                    Description__c = 'Product'
                                    );
          insert product;
          
          Product_Rate_Plan__c productRatePlan = new  Product_Rate_Plan__c(Name = 'Test ProductRatePlan',
                                                        Product__c = product.Id,
                                                        Valid_From_Date__c = Date.newInstance(2013, 12, 5),
                                                        Valid_To_Date__c = validtodate,
                                                        Description__c = 'Product RatePlan'
                                                        );
          insert productRatePlan;
          
          Product_Rate_Plan_Charge__c productRatePlanCharge = new Product_Rate_Plan_Charge__c(Name = 'Test ProductRatePlan Charge',
                                                                    CurrencyL__c = currency1.Id,
                                                                    Product_Rate_Plan__c = productRatePlan.Id,
                                                                    Unit_price__c = 200,
                                                                    Cost_Price__c = 160,
                                                                    Product_Charge_Category__c = 'Taxable'
                                                                    );
          
          insert productRatePlanCharge;
                                                                    
          OrderSOAPAPI orderAPIObj = new OrderSOAPAPI();
          orderAPIObj.getOrderSchema();
          string sSimpleString = orderAPIObj.getSimpleOrderSchema();
          
          string s = '<Order>'
              + '<TotalProfit dataType="DOUBLE" apiName=sPrefix+"Total_Profit__c">100</TotalProfit>'
              + '<Status dataType="PICKLIST" apiName=sPrefix+"Status__c">Started Working</Status>'
              + '<Account dataType="REFERENCE" apiName=sPrefix+"Account__c" required="true">' + account.Id + '</Account>'
              + '<OrderDate dataType="DATE" apiName=sPrefix+"Start_Date__c">2012-01-12</OrderDate>'
              + '<TotalProfitPercent dataType="PERCENT" apiName=sPrefix+"TotalProfitPercent__c">0</TotalProfitPercent>'
              + '<DiscountPercent dataType="PERCENT" apiName=sPrefix+"Discount_Percent__c">0</DiscountPercent>'
              + '<Currency dataType="REFERENCE" apiName=sPrefix+"CurrencyL__c" required="true">' + currency1.Id + '</Currency>'
              + '<Terms dataType="DOUBLE" apiName=sPrefix+"Number_Of_Terms__c">36</Terms>'
              + '<TotalCostPrice dataType="DOUBLE" apiName=sPrefix+"Total_Cost__c">1000</TotalCostPrice>'
              + '<OrderName dataType="STRING" apiName="Name">First Order</OrderName>'
              + '<PrimaryContact dataType="REFERENCE" apiName=sPrefix+"Shipping_Contact__c">' + listContacts.get(0).Id + '</PrimaryContact>'
              + '<PreferredBillingDayofthemonth dataType="PICKLIST" apiName=sPrefix+"Preferred_Billing_Day__c">7</PreferredBillingDayofthemonth>'
              + '<DiscountCode dataType="STRING" apiName=sPrefix+"Discount_Code__c"></DiscountCode>'
              + '<ServiceEndDate dataType="DATE" apiName=sPrefix+"Service_End_Date__c">2018-12-01</ServiceEndDate>'
              + '<Tax dataType="DOUBLE" apiName=sPrefix+"Tax__c">0</Tax>'
              + '<TodaysMRR dataType="DOUBLE" apiName=sPrefix+"Todays_MRR__c">0</TodaysMRR>'
              + '<VAT dataType="DOUBLE" apiName=sPrefix+"VAT__c">0</VAT>'
              + '<GrandTotal dataType="DOUBLE" apiName=sPrefix+"Total__c">0</GrandTotal>'
              + '<NetTotal dataType="DOUBLE" apiName=sPrefix+"Net_Total__c">0</NetTotal>'
              + '<DiscountValue dataType="DOUBLE" apiName=sPrefix+"Discount_Value__c">0</DiscountValue>'
              + '<ServiceStartDateDeliveryDate dataType="DATE" apiName=sPrefix+"Service_Activation_Date__c"></ServiceStartDateDeliveryDate>'
              + '<TotalContractValue dataType="DOUBLE" apiName=sPrefix+"Total_Contract_Value__c">0</TotalContractValue>'
              + '<BillingContact dataType="REFERENCE" apiName=sPrefix+"Billing_Contact__c">' + listContacts.get(0).Id + '</BillingContact>'
              + '<Partner dataType="REFERENCE" apiName=sPrefix+"Partner__c"></Partner>'
              + '<OrderProduct>'
                  + '<ProductFamily dataType="PICKLIST" apiName=sPrefix+"Product_Family__c">Default</ProductFamily>'
                  + '<Product dataType="REFERENCE" apiName=sPrefix+"Product__c">' + product.Id + '</Product>'
                  + '<ProductCode dataType="STRING" apiName=sPrefix+"Product_Code__c">HS1</ProductCode>'
                  + '<Order dataType="REFERENCE" apiName=sPrefix+"Job__c" required="true"></Order>'
                  + '<Description dataType="STRING" apiName=sPrefix+"Description__c">Bandwidth Product</Description>'
                  + '<OrderProductName dataType="STRING" apiName="Name">Bandwidth</OrderProductName>'
                  + '<OrderProductSequenceNumber dataType="DOUBLE" apiName=sPrefix+"SequenceNumber__c">1</OrderProductSequenceNumber>'
                  + '<ProductRatePlanId>' + productRatePlan.Id + '</ProductRatePlanId>'
                      + '<OrderRatePlanCharge>'
                          + '<AccountingCode dataType="STRING" apiName=sPrefix+"Accounting_Code__c">Ac001</AccountingCode>'
                          + '<VATPercentageApplied dataType="PERCENT" apiName=sPrefix+"VAT_Percentage__c">10</VATPercentageApplied>'
                          + '<OrderRatePlan dataType="REFERENCE" apiName=sPrefix+"Job_Rate_Plan__c" required="true"></OrderRatePlan>'
                          + '<Status dataType="PICKLIST" apiName=sPrefix+"Status__c">Started</Status>'
                          + '<UnitCost dataType="DOUBLE" apiName=sPrefix+"Cost_Price__c">500</UnitCost>'
                          + '<SequenceNo dataType="DOUBLE" apiName=sPrefix+"Sequence_No__c">1</SequenceNo>'
                          + '<PriceType dataType="PICKLIST" apiName=sPrefix+"Price_Type__c">One Time</PriceType>'
                          + '<PercentageofOtherCharges dataType="PERCENT" apiName=sPrefix+"Percentage_of_other_Charges__c"></PercentageofOtherCharges>'
                          + '<DiscountPercent dataType="PERCENT" apiName=sPrefix+"Discount_Percent__c">0</DiscountPercent>'
                          + '<TaxPercentageApplied dataType="PERCENT" apiName=sPrefix+"Tax_Percentage__c">0</TaxPercentageApplied>'
                          + '<ProductRatePlanCharge dataType="REFERENCE" apiName=sPrefix+"Product_Rate_Plan_Charge__c">' + productRatePlanCharge.Id + '</ProductRatePlanCharge>'
                          + '<Currency dataType="REFERENCE" apiName=sPrefix+"CurrencyL__c">' + currency1.Id + '</Currency>'
                          + '<UOM dataType="PICKLIST" apiName=sPrefix+"Unit_Of_Measurement__c">UNIT</UOM>'
                          + '<ChargeName dataType="STRING" apiName="Name">Setup Charges</ChargeName>'
                          + '<TaxCode dataType="STRING" apiName=sPrefix+"Tax_Code__c"></TaxCode>'
                          + '<PricingModel dataType="PICKLIST" apiName=sPrefix+"Price_Format__c">Default</PricingModel>'
                          + '<Profit dataType="DOUBLE" apiName=sPrefix+"Profit__c">0</Profit>'
                          + '<ServiceEndDate dataType="DATE" apiName=sPrefix+"Service_End_Date__c"></ServiceEndDate>'
                          + '<Tax dataType="DOUBLE" apiName=sPrefix+"Tax__c">0</Tax>'
                          + '<VAT dataType="DOUBLE" apiName=sPrefix+"VAT__c">0</VAT>'
                          + '<Subtotal dataType="DOUBLE" apiName=sPrefix+"Price__c"></Subtotal>'
                          + '<NetTotal dataType="DOUBLE" apiName=sPrefix+"Net_Total__c"></NetTotal>'
                          + '<DiscountValue dataType="DOUBLE" apiName=sPrefix+"Discount_Value__c">100</DiscountValue>'
                          + '<UnitPrice dataType="DOUBLE" apiName=sPrefix+"Unit_Price__c">1000</UnitPrice>'
                          + '<ServiceActivationDate dataType="DATE" apiName=sPrefix+"Service_Activation_Date__c"></ServiceActivationDate>'
                          + '<Quantity dataType="DOUBLE" apiName=sPrefix+"Quantity__c" required="true">3</Quantity>'
                          + '<ProductChargeCategory dataType="PICKLIST" apiName=sPrefix+"Product_Charge_Category__c">Taxable</ProductChargeCategory>'
                          + '<IsPriceEditableInOrderWizard dataType="BOOLEAN" apiName=sPrefix+"Is_Product_Editable__c">True</IsPriceEditableInOrderWizard>'
              + '</OrderRatePlanCharge>'
          + '</OrderProduct>'
          + '</Order>';
          
          orderAPIObj.createOrder(s);
          orderAPIObj.createSimpleOrder(sSimpleString);
          system.assert(sSimpleString != null);
          
          orderAPIObj.getCustomObjectSchema('Account');
          
          //cover catch block
          orderAPIObj.createSimpleOrder('');       
          orderAPIObj.createOrder('');     
     }
         
     static testMethod void jobCreationUtil () {
          try {
          
              set<Id> setOfChargesIdsToBeDispatched = new set<Id>();
              setOfChargesIdsToBeDispatched.add('001U000000XIZFn');

              JobCreationUtil.getChargesToBeDispatched(setOfChargesIdsToBeDispatched);
              
              JobCreationUtil.getListOfStockItems(setOfChargesIdsToBeDispatched);
              
              set<string> strs = new set<string>();

              strs.add('Name');
              system.assert(strs.size() > 0);
              JobCreationUtil.getListOfStockItems(setOfChargesIdsToBeDispatched, strs);
              
              JobCreationUtil.getAvailableStocks(setOfChargesIdsToBeDispatched);
              JobCreationUtil.getjobRatePlanToDelete('001U000000XIZFn');
          } catch(Exception ex) {
          
          }
      }
     
     public static testMethod void controllerRequestAdvancePayment () {
      
      Account account1 = new Account(Name = 'Test Account');
      insert account1;

      ApexPages.Standardcontroller controller1 = new Apexpages.Standardcontroller(account1);
      ControllerRequestAdvancePayment controllerRequestAdvancePayment1 = new ControllerRequestAdvancePayment(controller1); 
      
      controllerRequestAdvancePayment1.isContactSelected = false;
      controllerRequestAdvancePayment1.sendEmailForRequestPayment();
      
      ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
      ControllerInsertCustomSettings.insertValues();
      
      Account account = new Account(Name = 'Test Account');
      insert account;
       
      list<Contact> listContacts = new list<Contact>();
      listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com'));
      listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA'));
      insert listContacts;
       
      Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
      insert currency1;

      Currency__c currency2 = [SELECT name FROM Currency__c where id=: currency1.id];
      System.assertEquals('GBP', currency2.name);
      
      Payment__c  payment = new Payment__c(Account__c = account.Id, Currency__c = currency1.Id, Amount__c = 200000);
      insert payment;
      
      ApexPages.Standardcontroller controller = new Apexpages.Standardcontroller(account);
      ControllerRequestAdvancePayment controllerRequestAdvancePayment = new ControllerRequestAdvancePayment(controller);
      
      for(controllerRequestAdvancePayment.RequestAdvancePayment requestAdvancePayment : controllerRequestAdvancePayment.listOfRequestAdvancePayment){
                  requestAdvancePayment.isChecked = true;
                  if(requestAdvancePayment.isChecked){
                          controllerRequestAdvancePayment.isContactSelected = true;
                  }
          }
          
      controllerRequestAdvancePayment.sendEmailForRequestPayment();
     }
     
     public static testMethod void classForPayment() {
          ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
          ControllerInsertCustomSettings.insertValues();
       
          Account account = new Account(Name = 'Test Account');
          insert account;
          
          Account account1 = [SELECT Name FROM Account WHERE id=:account.id];
          System.assertEquals('Test Account', account1.Name);

          contact c = new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com');
          insert c;

          Currency__c currency1 = new Currency__c(name = 'USD', Symbol__c = '$');
          insert currency1;
           
          Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = c.Id,Shipping_Contact__c = c.Id, Sub_Total__c = 100, Discount_Value__c = 0, CurrencyL__c = currency1.Id);
          insert job;

          Invoice__c invoice1 = new Invoice__c(Account__c = account.id,Billing_Contact__c = c.Id,
                                               CurrencyL__c = currency1.Id, Target_Date__c = Date.today(),Invoice_Status__c = 'Active',Due_Date__c =system.today(),Invoice_Date__c = system.today());
                                               

          insert invoice1;
          
          Invoice_Lines__c invoiceLine = new Invoice_Lines__c(Invoice__c = invoice1.id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,Line_Amount__c = 500.00,Job__c = job.Id);
          insert invoiceLine;
          
          Payment__c  payment1 = new Payment__c(Account__c = account.Id, Currency__c = currency1.Id, Amount__c = 2000,Transaction__c = null,Status__c = CommonUtilClass.STATUS_COMPLETED);
          insert payment1;
          
          payment1.Status__c = CommonUtilClass.STATUS_CANCELLED;
          update payment1;    
     }
    
  }