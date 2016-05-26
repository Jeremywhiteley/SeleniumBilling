/**
     * This class contains unit tests for validating the behavior of ControllerProformaInvToRegularInv classes
     * Created By Asish
     */
    @isTest
    private class TestControllerProformaInvToRegularInv {

        static testMethod void ProformaInvToRegularInv() {
            
             ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
             ControllerInsertCustomSettings.insertValues();
             
             Account account = ClassPopulateTestData.createAccount();
             list<Contact> listOfContacts = ClassPopulateTestData.createContacts(account);
             list<Currency__c> listOfCurrencies = ClassPopulateTestData.currencies();
             Job__c job = ClassPopulateTestData.createOrder(account,listOfContacts.get(0),listOfCurrencies.get(0));
            
             Job_Product__c  jobProduct= new Job_Product__c(Name = 'jobProduct',Job__c = job.Id);
             insert jobProduct;

             Job_Product__c  jobProduct1= [select Name From Job_Product__c Where Id =:jobProduct.id];
             System.assertEquals('jobProduct', jobProduct1.Name);

             Job_Rate_Plan__c jobRP = new Job_Rate_Plan__c(Name = 'JobRP',Job_Product__c =jobProduct.Id);
             insert jobRP;

             Job_Rate_Plan_Charge__c charge = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Service_End_Date__c = system.today().addMonths(10),Job_Rate_Plan__c =jobRP.Id,Quantity__c = 12,Price_Type__c = 'One Time',Accounting_Code__c = '12345',Unit_Price__c = 12);
             insert charge;
             
             ApexPages.Standardcontroller controller = new Apexpages.Standardcontroller(job);
             ControllerGenerateProformaInvoice controllerGenerateProforma = new ControllerGenerateProformaInvoice(controller);
             //this will say "Please enter the Invoice Reference for the proforma invoice"
             controllerGenerateProforma.sInvoiceRefNo = null;
             for(ControllerGenerateProformaInvoice.orderRPChargeWrapper orderLineClassLocal : controllerGenerateProforma.listOfOrderRPChargeWrapper) {
                orderLineClassLocal.isChecked = false;
             } 
             controllerGenerateProforma.createProformaInvoice();
             
             //this will say "Select atleast one order linee"
             controllerGenerateProforma.sInvoiceRefNo = 'ABC';
             for(ControllerGenerateProformaInvoice.orderRPChargeWrapper orderLineClassLocal : controllerGenerateProforma.listOfOrderRPChargeWrapper) {
                orderLineClassLocal.isChecked = false;
             } 
             controllerGenerateProforma.createProformaInvoice();
             
             //select all the lines
             controllerGenerateProforma.sInvoiceRefNo = 'IndiaABC';
             for(ControllerGenerateProformaInvoice.orderRPChargeWrapper orderLineClassLocal : controllerGenerateProforma.listOfOrderRPChargeWrapper) {
                orderLineClassLocal.isChecked = true;
             } 
             controllerGenerateProforma.isOrderRPChargeSelected = true;
             PageReference pg = controllerGenerateProforma.createProformaInvoice();
             string invoiceId = pg.getUrl();
             
             //dis select all
             for(ControllerGenerateProformaInvoice.orderRPChargeWrapper orderLineClassLocal : controllerGenerateProforma.listOfOrderRPChargeWrapper) {
                orderLineClassLocal.isChecked = false;
             } 
             controllerGenerateProforma.createProformaInvoice();
             
             //this will say no charges present
             ApexPages.Standardcontroller controller2 = new Apexpages.Standardcontroller(job);
             ControllerGenerateProformaInvoice controllerGenerateProforma1 = new ControllerGenerateProformaInvoice(controller2);
            
             invoiceId = invoiceId.substring(1, invoiceId.length());
             
             Invoice__c invoice = [Select Invoice_Status__c, Account__c, CurrencyL__c, Invoice_State__c From Invoice__c Where Id =:invoiceId];
             
             Payment__c payment = new Payment__c(Account__c = invoice.Account__c, 
                                                Amount__c = 100, 
                                                Status__c = CommonUtilClass.STATUS_COMPLETED, 
                                                Payment_Type__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                                                Payment_Date__c = system.today(),
                                                Currency__c = invoice.CurrencyL__c);
            
            insert payment;
            
            Payment_Allocation__c paymentAllocation = new Payment_Allocation__c(Payment__c = payment.Id,
                                                                                Amount__c = payment.Amount__c,
                                                                                Invoice__c = invoiceId,
                                                                                Status__c = CommonUtilClass.STATUS_COMPLETED);   
            
            insert paymentAllocation;
             
             invoice = new Invoice__c(Id = invoiceId, Invoice_State__c = CommonUtilClass.STATUS_PROFORMA);
             ApexPages.Standardcontroller controllerInv = new Apexpages.Standardcontroller(invoice);
             ControllerProformaInvToRegularInv createRegInvoice = new ControllerProformaInvToRegularInv(controllerInv);
             createRegInvoice.createRegularInvoice();
             
             createRegInvoice.createRegularInvoice();
             
             Invoice__c invoice1 = new Invoice__c(Id = invoiceId, Invoice_State__c = CommonUtilClass.STATUS_CANCELLED);
             ApexPages.Standardcontroller controllerInv1 = new Apexpages.Standardcontroller(invoice1);
             ControllerProformaInvToRegularInv createRegInvoice1 = new ControllerProformaInvToRegularInv(controllerInv1);
             createRegInvoice1.createRegularInvoice();
             
             invoice.Invoice_State__c = CommonUtilClass.STATUS_PROFORMA;
             invoice.Regular_Invoice__c = null;
             delete [Select Id From Invoice_Lines__c Where Invoice__c =: invoiceId];
             
             ApexPages.Standardcontroller controllerInv2 = new Apexpages.Standardcontroller(invoice);
             ControllerProformaInvToRegularInv createRegInvoice2 = new ControllerProformaInvToRegularInv(controllerInv2);
             createRegInvoice2.createRegularInvoice(); 
            
             createRegInvoice.createRegularInvoice();
             
        } 
        
        //test data created by sagarika 
        static testMethod void ControllerProformaInvToRegularInv() {
            
             ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
             ControllerInsertCustomSettings.insertValues();

             Configuration__c c = Configuration__c.getValues('INVOICE_GROUP_CRITERIA');
             c.String_Value__c = 'ONE_INVOICE_PER_ACCOUNT';
             update c;

             Configuration__c c1 = Configuration__c.getValues('ACCOUNT_LEGAL_ENTITY_FIELD_NAME');
             c1.String_Value__c = 'BillingCountry';
             update c1;

             Sequence_Number__c sequenceNumber = new Sequence_Number__c(Name='India', Invoice_Prefix__c='IND-',Invoice_Suffix__c='-GRT',Invoice_Next_Number__c=17);
             insert sequenceNumber;

             Account account = ClassPopulateTestData.createAccount();
             list<Contact> listOfContacts = ClassPopulateTestData.createContacts(account);
             list<Currency__c> listOfCurrencies = ClassPopulateTestData.currencies();
              Job__c job = ClassPopulateTestData.createOrder(account,listOfContacts.get(0),listOfCurrencies.get(0));
              Job__c jobCancel = ClassPopulateTestData.createOrder(account,listOfContacts.get(0),listOfCurrencies.get(0));
              
              //modified by asish
             
             Invoice__c invoiceCancel = new Invoice__c(Account__c = account.id,Billing_Contact__c = listOfContacts.get(0).Id,Order__c = jobCancel.ID,Shipping_Contact__c = listOfContacts.get(1).Id,
                                    CurrencyL__c = listOfCurrencies[0].Id,Invoice_Status__c = CommonUtilClass.STATUS_POSTED,Invoice_State__c = CommonUtilClass.STATUS_PROFORMA, Target_Date__c = Date.today(),Delivery_Type__c = 'Both');
             insert invoiceCancel;

             Invoice__c invoice = [select Name,Delivery_Type__c From Invoice__c where id=:invoiceCancel.id];
             System.assertEquals('Both', invoice.Delivery_Type__c);

             //creating instance of class
             ApexPages.Standardcontroller controllerInvcancel = new Apexpages.Standardcontroller(invoiceCancel);
             ControllerProformaInvToRegularInv createRegInvoiceCancel = new ControllerProformaInvToRegularInv(controllerInvcancel);
      
             createRegInvoiceCancel.createRegularInvoice();
             
             invoiceCancel.Invoice_Status__c = CommonUtilClass.STATUS_CANCELLED;
             upsert invoiceCancel;
             ControllerProformaInvToRegularInv createRegInvoiceCancel1 = new ControllerProformaInvToRegularInv(controllerInvcancel);
             createRegInvoiceCancel1.createRegularInvoice();
             
             Invoice__c invoiceTest = new Invoice__c(Account__c = account.id,Billing_Contact__c = listOfContacts.get(0).Id,Order__c =job.ID,Shipping_Contact__c = listOfContacts.get(1).Id,
                                    CurrencyL__c = listOfCurrencies[0].Id,Invoice_Status__c = CommonUtilClass.STATUS_POSTED,Invoice_State__c =CommonUtilClass.STATUS_PROFORMA, Target_Date__c = Date.today(),Delivery_Type__c = 'Both');
             insert invoiceTest;
             //creating instance of class
             ApexPages.Standardcontroller controllerInv2 = new Apexpages.Standardcontroller(invoiceTest);
             ControllerProformaInvToRegularInv createRegInvoice2 = new ControllerProformaInvToRegularInv(controllerInv2);
          
             createRegInvoice2.createRegularInvoice();

              //insert invoice lines
            list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoiceTest.id, Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoiceTest.id, Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoiceTest.id, Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,Job__c = job.Id));
            insert listInvoiceLines;
            //inserting payment
            Payment__c payment = new Payment__c(Account__c = invoiceTest.Account__c, 
                                                Amount__c = 100, 
                                                Status__c = CommonUtilClass.STATUS_COMPLETED, 
                                                Payment_Type__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                                                Payment_Date__c = system.today(),
                                                Currency__c = invoiceTest.CurrencyL__c);
            
            insert payment;
            
            //insert payment allocation
            Payment_Allocation__c paymentAllocation = new Payment_Allocation__c(Payment__c = payment.Id,
                                                                                Amount__c = payment.Amount__c,
                                                                                Invoice__c = invoiceTest.ID,
                                                                                Status__c = CommonUtilClass.STATUS_COMPLETED);   
            
            insert paymentAllocation;
            
            ApexPages.Standardcontroller controllerInv4 = new Apexpages.Standardcontroller(invoiceTest);
            ControllerProformaInvToRegularInv createRegInvoice4 = new ControllerProformaInvToRegularInv(controllerInv4);
             createRegInvoice4.createRegularInvoice();
             
             //updating invoice state as cancelled
             invoiceTest.Invoice_State__c = CommonUtilClass.STATUS_CANCELLED;
             update invoiceTest;
             ApexPages.Standardcontroller controllerInv3 = new Apexpages.Standardcontroller(invoiceTest);
             ControllerProformaInvToRegularInv createRegInvoice3 = new ControllerProformaInvToRegularInv(controllerInv3);
             createRegInvoice3.createRegularInvoice();
            
            
        }
        
    }