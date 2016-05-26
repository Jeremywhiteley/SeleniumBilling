@isTest(oninstall = false)
    //created by Ankit for test CreateProductsController:31/08/2013
    private with sharing class TestClassCreateProducts {
        public static String sPrefix = CommonUtilClass.getPrefix();
        
        static testMethod void controllerInsertOptionalExtra() {
            //this is the code for testing the ControllerInsertOptionalExtra
            ClassPopulateTestData.createCustomSettings(); 
            Account account = ClassPopulateTestData.createAccount();
            list<Contact> listOfContacts = ClassPopulateTestData.createContacts(account);
            list<Currency__c> listOfCurrencies = ClassPopulateTestData.currencies();
            Quote__c quote = ClassPopulateTestData.createQuote(account,listOfContacts[0],listOfCurrencies[0]);
            list<Product__c> listProducts = ClassPopulateTestData.createProduct();
            list<Product_Rate_Plan__c> listProductRatePlans = ClassPopulateTestData.createProductRatePlan(listProducts[0]);
            list<Product_Rate_Plan_Charge__c> listProductRatePlanCharges = ClassPopulateTestData.createProductRatePlanCharge(listProductRatePlans[0],listOfCurrencies[0]);      
            list<Product_Rate_Plan_Charge_Tier__c> tiers  = ClassPopulateTestData.createProductRatePlanChargeTier(listProductRatePlanCharges[0]);
            Optional_Extra__c optionalExtraObj = new Optional_Extra__c(Name='Optional Extra',                                                                 
                                                                    Invoice_IT_Product__c = listProducts[0].id,
                                                                        Product_Rate_Plan__c = listProductRatePlans[0].id,
                                                                        Product_Rate_Plan_Charge__c = listProductRatePlanCharges[0].id,
                                                                        Quantity__c = 3,
                                                                        Quote__c = quote.id,
                                                                        Subtotal__c = 10000,
                                                                        Total_Cost__c =  100000,
                                                                        Unit_Cost_Price__c = 100,
                                                                        Unit_Selling_Price2__c = 500);
            insert optionalExtraObj;

            Optional_Extra__c optionalExtra = [SELECT Name FROM Optional_Extra__c WHERE id =: optionalExtraObj.id];
            System.assertEquals('Optional Extra', optionalExtra.Name);

            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(quote);
            ControllerInsertOptionalExtra controllerInsertOptional = new ControllerInsertOptionalExtra(standardController);
            
            controllerInsertOptional.getRatePlansForProduct();
            system.currentPageReference().getParameters().put('productId',listProducts.get(0).Id);
            system.currentPageReference().getParameters().put('productName',listProducts.get(0).name);      
            controllerInsertOptional.getRatePlansForProduct();
            
            controllerInsertOptional.getRatePlanChargesForRatePlan();
            system.currentPageReference().getParameters().put('ratePlanId',listProductRatePlans.get(0).Id);
            system.currentPageReference().getParameters().put('rateplanName',listProductRatePlans.get(0).name);
            controllerInsertOptional.getRatePlanChargesForRatePlan();
            
            controllerInsertOptional.getRatePlanChargesForRatePlan();
            system.currentPageReference().getParameters().put('ratePlanId',listProductRatePlans.get(0).Id);
            system.currentPageReference().getParameters().put('rateplanName',listProductRatePlans.get(0).name);
            controllerInsertOptional.getRatePlanChargesForRatePlan();
            
            system.currentPageReference().getParameters().put('ratePlanChargeId',listProductRatePlans.get(0).Id);
            controllerInsertOptional.removeCharges();
            
            controllerInsertOptional.insertOptionalExtras();
            list<Product_Rate_Plan_Charge__c> listProductRatePlanCharge = new list<Product_Rate_Plan_Charge__c>();
            controllerInsertOptional.listSelectedProductRatePlanCharges = listProductRatePlanCharge;         
            controllerInsertOptional.insertOptionalExtras();
            controllerInsertOptional.listSelectedProductRatePlanCharges = listProductRatePlanCharges;
            listProductRatePlanCharges.get(0).Price_Format__c = 'Tiered Pricing'; 
            controllerInsertOptional.insertOptionalExtras();
            Product_Rate_Plan_Charge__c prpc = listProductRatePlanCharges.get(0);
            prpc = [SELECT Id,Price_Format__c, 
                    (SELECT End_Unit__c,Product_Rate_Plan_Charge__c,Start_Unit__c,Unit_Cost_Price__c,Unit_Price__c,Name FROM Product_Rate_Plan_Charge_Tiers__r)
                    FROM Product_Rate_Plan_Charge__c 
                    WHERE Id =: prpc.Id];
            prpc.Price_Format__c = 'Volume Pricing';        
            ControllerInsertOptionalExtra.populateOptionalExtraForVolumeOrFlatFeePricing(prpc,optionalExtraObj);
            prpc.Price_Format__c = 'Flat Fee Pricing';      
            ControllerInsertOptionalExtra.populateOptionalExtraForVolumeOrFlatFeePricing(prpc,optionalExtraObj);
            ControllerInsertOptionalExtra.populateOptionalExtraForTieredPricing(prpc,optionalExtraObj);
            optionalExtraObj.Quantity__c = 12;
            ControllerInsertOptionalExtra.populateOptionalExtraForTieredPricing(prpc,optionalExtraObj);
            optionalExtraObj.Quantity__c = 0;
            ControllerInsertOptionalExtra.populateOptionalExtraForTieredPricing(prpc,optionalExtraObj); 
        } 
        
        static testMethod void controllerCancelInvoice() {
            ClassPopulateTestData.createCustomSettings(); 
            Account account = ClassPopulateTestData.createAccount();
            list<Contact> listOfContacts = ClassPopulateTestData.createContacts(account);
            list<Currency__c> listOfCurrencies = ClassPopulateTestData.currencies();
            Job__c job = ClassPopulateTestData.createOrder(account,listOfContacts.get(0),listOfCurrencies.get(0));
            Invoice__c invoice = ClassPopulateTestData.createInvoice(account,listOfContacts.get(0),listOfCurrencies.get(0));
            list<Invoice_Lines__c> listOfInvoiceLines = ClassPopulateTestData.createListOfInvoiceLines(invoice,job);
            invoice.Invoice_Status__c = 'Cancelled';
            update invoice;
            Invoice__c invoice1 = [SELECT Number_Of_Invoice_Lines__c, Invoice_Status__c from Invoice__c where id =:invoice.id];     
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(invoice1);
            ControllerCancelInvoice controllerCancelInvoice = new ControllerCancelInvoice(standardController);
                    
            controllerCancelInvoice.cancelInvoice();
                    
            invoice1.Invoice_Status__c = 'Draft';          
            upsert invoice1;        
            controllerCancelInvoice.cancelInvoice();        
            controllerCancelInvoice.cancelPost();
                    
            invoice1.Invoice_Status__c = 'Posted';
            upsert invoice1;        
            controllerCancelInvoice.cancelInvoice();
            controllerCancelInvoice.cancelPost();       
            controllerCancelInvoice.backToInvoice();
            
            Invoice__c invoice2 = ClassPopulateTestData.createInvoice(account,listOfContacts.get(0),listOfCurrencies.get(0));
            Invoice__c invoice3 = [SELECT Number_Of_Invoice_Lines__c, Invoice_Status__c from Invoice__c where id =:invoice2.id];
            ApexPages.Standardcontroller standardController1 = new Apexpages.Standardcontroller(invoice3);
            ControllerCancelInvoice controllerCancelInvoice1 = new ControllerCancelInvoice(standardController1);
 
            invoice3.Invoice_Status__c = 'Draft';          
            upsert invoice3;        
            controllerCancelInvoice1.cancelInvoice();
            invoice3.Invoice_Status__c = 'Posted';
            upsert invoice3;  
            Invoice__c invoice4 = [SELECT Invoice_Status__c FROM Invoice__c WHERE id=:invoice3.id];
            System.assertEquals('Posted', invoice4.Invoice_Status__c);      
            controllerCancelInvoice1.cancelInvoice();               
        }
        
        static testMethod void controllerForScheduling() {
            ControllerInsertCustomSettings controllerInsertCustomSettings = new ControllerInsertCustomSettings();
            controllerInsertCustomSettings.insertValues(); 
         
            list<Currency__c> listOfCurrencies = ClassPopulateTestData.currencies();
            Currency__c currency1 = listOfCurrencies.get(0);
            
            Invoice_RunScheduler__c invoiceRunScheduler = new Invoice_RunScheduler__c();
            ApexPages.Standardcontroller controller1 = new Apexpages.Standardcontroller(invoiceRunScheduler);
            ControllerForScheduling controllerForScheduling = new ControllerForScheduling(controller1);     
            controllerForScheduling.invoiceRunScheduler.Name = 'testing@1';
            controllerForScheduling.invoiceRunScheduler.Type__c = 'Daily';
            controllerForScheduling.onChangeOfType();
            controllerForScheduling.onChangeStartDate();
            controllerForScheduling.invoiceRunScheduler.Type__c = 'Once';
            controllerForScheduling.invoiceRunScheduler.Invoice_Currency__c = currency1.Id;
            controllerForScheduling.invoiceRunScheduler.Invoice_Date__c = system.today();
            controllerForScheduling.invoiceRunScheduler.Target_Date__c = system.today();
            controllerForScheduling.saveInvoiceRunScheduler();
            //perform validations
            
            controllerForScheduling.invoiceRunScheduler.Start_date_and_time__c = null;
            controllerForScheduling.saveInvoiceRunScheduler();
            controllerForScheduling.invoiceRunScheduler.Start_date_and_time__c = system.now().addMinutes(10);
            controllerForScheduling.invoiceRunScheduler.Name = null;
            controllerForScheduling.saveInvoiceRunScheduler();
            controllerForScheduling.invoiceRunScheduler.Name = 'testing@1';
            controllerForScheduling.saveInvoiceRunScheduler();
            controllerForScheduling.invoiceRunScheduler.Invoice_Currency__c = null;
            controllerForScheduling.saveInvoiceRunScheduler();
            controllerForScheduling.invoiceRunScheduler.Invoice_Currency__c = currency1.Id;
            controllerForScheduling.invoiceRunScheduler.Type__c = 'Weekly';
            controllerForScheduling.invoiceRunScheduler.Invoice_Day_of_week__c = null;
            controllerForScheduling.saveInvoiceRunScheduler();
            controllerForScheduling.invoiceRunScheduler.Invoice_Day_of_week__c = '1';
            controllerForScheduling.invoiceRunScheduler.Target_Day_of_week__c = null;
            controllerForScheduling.saveInvoiceRunScheduler();
            controllerForScheduling.invoiceRunScheduler.Type__c = 'Monthly';
            controllerForScheduling.invoiceRunScheduler.Invoice_Day_Of_Month__c = null;
            controllerForScheduling.saveInvoiceRunScheduler(); 
            controllerForScheduling.invoiceRunScheduler.Invoice_Day_Of_Month__c = '10';        
            controllerForScheduling.invoiceRunScheduler.Target_Day_Of_Month__c = null;
            controllerForScheduling.saveInvoiceRunScheduler();
         
            ApexPages.Standardcontroller controller2 = new Apexpages.Standardcontroller(invoiceRunScheduler);
            ControllerForScheduling controllerForScheduling2 = new ControllerForScheduling(controller2);
            controllerForScheduling2.saveInvoiceRunScheduler();
            Invoice_RunScheduler__c invoiceRunSchedulerNew = [SELECT Id,Name 
                                                              FROM Invoice_RunScheduler__c 
                                                              WHERE Name = 'testing@1'];
            system.assert(invoiceRunSchedulerNew.Name == 'testing@1');
        } 
        
        static testMethod void classAfterOnInvoice() {
          ClassPopulateTestData.createCustomSettings(); 
            Account account = ClassPopulateTestData.createAccount();
            list<Contact> listOfContacts = ClassPopulateTestData.createContacts(account);
            list<Currency__c> listOfCurrencies = ClassPopulateTestData.currencies();
            Job__c job = ClassPopulateTestData.createOrder(account,listOfContacts.get(0),listOfCurrencies.get(0));
                    
            Job_Product__c jobProduct = new Job_Product__c(Job__c = job.Id);
            insert jobProduct;
            Job_Rate_Plan__c jobRatePlan = new Job_Rate_Plan__c(Job_Product__c = jobProduct.Id);
            insert jobRatePlan;
            
            list<Job_Rate_Plan_Charge__c> listOfORPCs = new list<Job_Rate_Plan_Charge__c>();
            Job_Rate_Plan_Charge__c charge1 = new Job_Rate_Plan_Charge__c(CurrencyL__c = listOfCurrencies.get(0).id,Service_End_Date__c=date.Today()+2, Price_Type__c = 'Monthly', Price__c = 100, Quantity__c = 1, Job_Rate_Plan__c = jobRatePlan.Id, Cost_Price__c = 10, Net_Total__c = 20, Cost__c = 1, Profit__c = 0, Unit_Price__c = 1, Sequence_No__c = 1);
            Job_Rate_Plan_Charge__c charge2 = new Job_Rate_Plan_Charge__c(CurrencyL__c = listOfCurrencies.get(0).id,Service_End_Date__c=date.Today()+3,Price_Type__c = 'One Time', Price__c = 100, Quantity__c = 0, Job_Rate_Plan__c = jobRatePlan.Id);
            listOfORPCs.add(charge1);
            listOfORPCs.add(charge2);
            insert listOfORPCs;
            
            Invoice__c invoice = ClassPopulateTestData.createInvoice(account,listOfContacts.get(0),listOfCurrencies.get(0));        
            list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Charge_Date__c = system.today(), Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id, Job_Rate_Plan_Charge__c = listOfORPCs.get(0).id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Charge_Date__c = system.today()-3,Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id, Job_Rate_Plan_Charge__c = listOfORPCs.get(1).id));
            upsert listInvoiceLines;
            
            list<Payment__c> listOfPayment = new list<Payment__c>();
            Payment__c payment = new Payment__c(Account__c = invoice.Account__c, 
                                                Amount__c = 60000, 
                                                Status__c = CommonUtilClass.STATUS_COMPLETED, 
                                                Payment_Type__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                                                Payment_Date__c = system.today(),
                                                Currency__c = listOfCurrencies.get(0).Id);
            
            Payment__c payment1 = new Payment__c(Account__c = invoice.Account__c, 
                                                Amount__c = 50, 
                                                Status__c = CommonUtilClass.STATUS_COMPLETED, 
                                                Payment_Type__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                                                Payment_Date__c = system.today(),
                                                Currency__c = listOfCurrencies.get(0).Id);
            listOfPayment.add(payment);
            listOfPayment.add(payment1);                                                                        
            upsert listOfPayment; 
                    
            Invoice__c invoice1 = [SELECT id, Name, Account__c, Billing_Contact__c, Shipping_Contact__c,
                                    Number_Of_Invoice_Lines__c, CurrencyL__c, Target_Date__c, Delivery_Type__c,
                                    Invoice_Status__c, Unpaid_Amount__c FROM Invoice__c WHERE id =: invoice.id];
            
            ApexPages.Standardcontroller standardController1 = new Apexpages.Standardcontroller(invoice1);
            ControllerCancelInvoice controllerCancelInvoice1 = new ControllerCancelInvoice(standardController1);        
            ClassAfterOnInvoice.INVOICE_AFTER_PROCESSING_COMPLETE = false;      
            controllerCancelInvoice1.cancelPost();   
            
            ClassAfterOnInvoice.INVOICE_AFTER_PROCESSING_COMPLETE = false;      
            controllerCancelInvoice1.cancelPost();
            invoice1.Delivery_Type__c ='Print';
            update invoice1; 
            
            Invoice__c invoice2 = [SELECT Name,Delivery_Type__c FROM Invoice__c WHERE id=: invoice1.id];
            System.assertEquals('Print', invoice2.Delivery_Type__c);

            ApexPages.Standardcontroller standardController2 = new Apexpages.Standardcontroller(invoice1);
            ControllerCancelInvoice controllerCancelInvoice2 = new ControllerCancelInvoice(standardController1);        
            ClassAfterOnInvoice.INVOICE_AFTER_PROCESSING_COMPLETE = false;      
            controllerCancelInvoice2.cancelInvoice();
                
        }  
        
        static testmethod void classWebServiceEmailing() {

            Configuration__c c1 = new Configuration__c(Name = 'INVOICE_EMAIL_TEMPLATE', Field_Type__c = 'String', Description__c = 'Mention Email Template ID', String_Value__C = '00XU0000000IXSF');
            insert c1;
            
            ClassPopulateTestData.createCustomSettings(); 
            Account account = ClassPopulateTestData.createAccount();
            list<Contact> listOfContacts = ClassPopulateTestData.createContacts(account);
            list<Currency__c> listOfCurrencies = ClassPopulateTestData.currencies();
            Opportunity opp = ClassPopulateTestData.createOpportunity(account);
            Quote__c quote = ClassPopulateTestData.createQuote(account,listOfContacts.get(0),listOfCurrencies.get(0));
            
            Job__c job = ClassPopulateTestData.createOrder(account,listOfContacts.get(0),listOfCurrencies.get(0));
            Invoice__c invoice = ClassPopulateTestData.createInvoice(account,listOfContacts.get(0),listOfCurrencies.get(0));
            list<Invoice_Lines__c> listInvoiceLines = ClassPopulateTestData.createListOfInvoiceLines(invoice,job);
                
            ClassWebServiceEmailing.sendInvoice(invoice.id);        
            ClassWebServiceEmailing.sendInvoice('001U000000dMRJX');
                    
            ClassWebServiceEmailing.sendQuote(quote.id);
            
            ClassWebServiceEmailing.attachPdf(invoice.Id, 'Invoice Name');
            
            ClassWebServiceEmailing.attachPdfToOpportunity(opp.id, quote.Name, quote.Id);
            
            Invoice_Run__c invoiceRun = new Invoice_Run__c(Name = 'Invoice Run', Completed_Time__c = system.today(),
                                                            Invoice_Date__c = system.today(),
                                                            Start_Time__c = system.today(),
                                                            Status__c = 'Completed',
                                                            Target_Run_Date__c = system.today(),
                                                            Total_Invoice_Value__c = 10000
                                                            );
            upsert invoiceRun;      
            invoice.Invoice_Run_Created_By__c = invoiceRun.id;
            update invoice; 

            Invoice_Run__c invoiceRun1 = [SELECT Name, Status__c FROM Invoice_Run__c WHERE id=: invoiceRun.id];
            System.assertEquals('Completed', invoiceRun1.Status__c);    
                        
            ClassWebServiceEmailing.emailAllInvoicesForInvoiceRun(invoice.Invoice_Run_Created_By__c);
                    
            ApexPages.Standardcontroller standardController1 = new Apexpages.Standardcontroller(invoice);
            ControllerCancelInvoice controllerCancelInvoice1 = new ControllerCancelInvoice(standardController1);        
            controllerCancelInvoice1.cancelPost();
            ClassWebServiceEmailing.postAllInvoicesForInvoiceRun(invoice.Invoice_Run_Created_By__c);
                    
        }
        
        static testmethod void invoicingUtilClass(){   
            ClassPopulateTestData.createCustomSettings(); 
            Account account = ClassPopulateTestData.createAccount();
            account.Invoice_Delivery_Type__c = 'Email & Print';
            update account;
            list<Contact> listOfContacts = ClassPopulateTestData.createContacts(account);
            list<Currency__c> listOfCurrencies = ClassPopulateTestData.currencies();
            list<Product__c> listOfProducts = ClassPopulateTestData.createProduct();
            list<Product_Rate_Plan__c> listOfProductsRatePlans = ClassPopulateTestData.createProductRatePlan(listOfProducts.get(0));
            list<Product_Rate_Plan_Charge__c> listOfProductsRatePlanCharges = ClassPopulateTestData.createProductRatePlanCharge(listOfProductsRatePlans.get(0),listOfCurrencies.get(0));
            
            list<Id> listOfOrdersId = new list<Id>();
            Job__c job = ClassPopulateTestData.createOrder(account,listOfContacts.get(0),listOfCurrencies.get(0));
            listOfOrdersId.add(job.id);
            
            Job_Product__c  jobProduct= new Job_Product__c(Name = 'jobProduct',Job__c = job.Id, Product__c = listOfProducts.get(0).id);
            insert jobProduct;

            Job_Product__c  jobProduct1 = [SELECT Name FROM Job_Product__c WHERE id =: jobProduct.id];
            System.assertEquals('jobProduct', jobProduct1.Name);

            Job_Rate_Plan__c jobRP = new Job_Rate_Plan__c(Name = 'JobRP',Job_Product__c =jobProduct.Id);
            insert jobRP;
            
            Quote__c quote = ClassPopulateTestData.createQuote(account,listOfContacts[0],listOfCurrencies[0]);
            
            Quote_Product__c quoteProduct =  new Quote_Product__c(Name = 'Test' , Quote__c = quote.Id,Product__c = listOfProducts.get(0).id);
            insert quoteProduct;
            
            Quote_Rate_Plan__c quotePlan = new Quote_Rate_Plan__c(Name = 'plan test',Quote_Product__c = quoteProduct.id);
            insert quotePlan;
            
            list<Quote_Rate_Plan_Charge__c> listQuoteRatePlanCharges = new list<Quote_Rate_Plan_Charge__c>();
            Quote_Rate_Plan_Charge__c quoteRatePlanCharge = new Quote_Rate_Plan_Charge__c(Name = 'jobRPC',Quote_Rate_Plan__c =quotePlan.Id,
                                                                            Quantity__c = 12,Price_Type__c = 'One Time',
                                                                            Accounting_Code__c = '12345',Unit_Price__c = 12                             
                                                                            );
            Quote_Rate_Plan_Charge__c quoteRatePlanCharge1 = new Quote_Rate_Plan_Charge__c(Name = 'jobRPC',Quote_Rate_Plan__c =quotePlan.Id,
                                                                            Quantity__c = 12,Price_Type__c = 'Monthly',
                                                                            Accounting_Code__c = '12345',Unit_Price__c = 12                                                         
                                                                            );
           Quote_Rate_Plan_Charge__c quoteRatePlanCharge2 = new Quote_Rate_Plan_Charge__c(Name = 'jobRPC',Quote_Rate_Plan__c =quotePlan.Id,
                                                                            Quantity__c = 12,Price_Type__c = 'Weekly',
                                                                            Accounting_Code__c = '12345',Unit_Price__c = 12                                                                 
                                                                            );
           Quote_Rate_Plan_Charge__c quoteRatePlanCharge3 = new Quote_Rate_Plan_Charge__c(Name = 'jobRPC',Quote_Rate_Plan__c =quotePlan.Id,
                                                                            Quantity__c = 12,Price_Type__c = 'Quarterly',
                                                                            Accounting_Code__c = '12345',Unit_Price__c = 12                                                             
                                                                            );
           Quote_Rate_Plan_Charge__c quoteRatePlanCharge4 = new Quote_Rate_Plan_Charge__c(Name = 'jobRPC',Quote_Rate_Plan__c =quotePlan.Id,
                                                                            Quantity__c = 12,Price_Type__c = 'Half Yearly',
                                                                            Accounting_Code__c = '12345',Unit_Price__c = 12                                                                     
                                                                            
                                                                            );                                                                                                                                                                                                                                                                                                  
           Quote_Rate_Plan_Charge__c quoteRatePlanCharge5 = new Quote_Rate_Plan_Charge__c(Name = 'jobRPC',Quote_Rate_Plan__c =quotePlan.Id,
                                                                            Quantity__c = 12,Price_Type__c = 'Annual',
                                                                            Accounting_Code__c = '12345',Unit_Price__c = 12                                                         
                                                                            );
                                                                                                                                                                                                                                                                                                                                                                                
            listQuoteRatePlanCharges.add(quoteRatePlanCharge);
            listQuoteRatePlanCharges.add(quoteRatePlanCharge1);
            listQuoteRatePlanCharges.add(quoteRatePlanCharge2);
            listQuoteRatePlanCharges.add(quoteRatePlanCharge3);
            listQuoteRatePlanCharges.add(quoteRatePlanCharge4);
            listQuoteRatePlanCharges.add(quoteRatePlanCharge5);                                                                                                                         
            insert listQuoteRatePlanCharges;
            
            list<Job_Rate_Plan_Charge__c> listOrderRatePlanCharges = new list<Job_Rate_Plan_Charge__c>();
            
            Job_Rate_Plan_Charge__c charge = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Job_Rate_Plan__c =jobRP.Id,
                                                                            Quantity__c = 12,Price_Type__c = 'One Time',
                                                                            Accounting_Code__c = '12345',Unit_Price__c = 12,
                                                                            Status__c = 'Test',
                                                                            Next_Charge_Date__c = system.today(),
                                                                            Service_Activation_Date__c = system.today(),
                                                                            Service_End_Date__c = system.today()+60                                                                     
                                                                            );
            Job_Rate_Plan_Charge__c charge1 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Job_Rate_Plan__c =jobRP.Id,
                                                                            Quantity__c = 12,Price_Type__c = 'Monthly',
                                                                            Accounting_Code__c = '12345',Unit_Price__c = 12,
                                                                            Status__c = 'Test',
                                                                            Next_Charge_Date__c = system.today(),
                                                                            Service_Activation_Date__c = system.today(),
                                                                            Service_End_Date__c = system.today()+60                                                                     
                                                                            );
            Job_Rate_Plan_Charge__c charge2 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Job_Rate_Plan__c =jobRP.Id,
                                                                            Quantity__c = 12,Price_Type__c = 'Weekly',
                                                                            Accounting_Code__c = '12345',Unit_Price__c = 12,
                                                                            Status__c = 'Test',
                                                                            Next_Charge_Date__c = system.today(),
                                                                            Service_Activation_Date__c = system.today(),
                                                                            Service_End_Date__c = system.today()+60                                                                     
                                                                            );
            Job_Rate_Plan_Charge__c charge3 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Job_Rate_Plan__c =jobRP.Id,
                                                                            Quantity__c = 12,Price_Type__c = 'Quarterly',
                                                                            Accounting_Code__c = '12345',Unit_Price__c = 12,
                                                                            Status__c = 'Test',
                                                                            Next_Charge_Date__c = system.today(),
                                                                            Service_Activation_Date__c = system.today(),
                                                                            Service_End_Date__c = system.today()+60                                                                     
                                                                            );
            Job_Rate_Plan_Charge__c charge4 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Job_Rate_Plan__c =jobRP.Id,
                                                                            Quantity__c = 12,Price_Type__c = 'Half Yearly',
                                                                            Accounting_Code__c = '12345',Unit_Price__c = 12,
                                                                            Status__c = 'Test',
                                                                            Next_Charge_Date__c = system.today(),
                                                                            Service_Activation_Date__c = system.today(),
                                                                            Service_End_Date__c = system.today()+60                                                                     
                                                                            );                                                                                                                                                                                                                                                                                                  
            Job_Rate_Plan_Charge__c charge5 = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Job_Rate_Plan__c =jobRP.Id,
                                                                            Quantity__c = 12,Price_Type__c = 'Annual',
                                                                            Accounting_Code__c = '12345',Unit_Price__c = 12,
                                                                            Status__c = 'Test',
                                                                            Next_Charge_Date__c = system.today(),
                                                                            Service_Activation_Date__c = system.today(),
                                                                            Service_End_Date__c = system.today()+60                                                                     
                                                                            );                                                                                                                                                                                                                                                                                                  
            
            listOrderRatePlanCharges.add(charge);
            listOrderRatePlanCharges.add(charge1);
            listOrderRatePlanCharges.add(charge2);
            listOrderRatePlanCharges.add(charge3);
            listOrderRatePlanCharges.add(charge4);
            listOrderRatePlanCharges.add(charge5);                                                                                                                          
            insert listOrderRatePlanCharges;
            
            Invoice__c invoice = new Invoice__c(Account__c = account.id,
                                                Billing_Contact__c = listOfContacts.get(0).id,
                                                Shipping_Contact__c = listOfContacts.get(0).id,
                                                CurrencyL__c = listOfCurrencies.get(0).id, 
                                                Target_Date__c = Date.today(),
                                                Delivery_Type__c = 'Both',
                                                Invoice_Status__c = 'Posted',
                                                Payment_Request_Amount__c = 20                                          
                                                );
            
            list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Charge_Date__c = system.today(), Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id,Job_Rate_Plan_Charge__c = listOrderRatePlanCharges.get(0).id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Charge_Date__c = system.today(), Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Charge_Date__c = system.today(), Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
            
            InvoiceClass invoiceClass =  new InvoiceClass();
            invoiceClass.invoice = invoice;
            invoiceClass.invoiceLines = listInvoiceLines;
            
            map<Id, InvoiceClass> mapInvoiceClass = new map<Id, InvoiceClass>();
            mapInvoiceClass.put(invoice.id,invoiceClass);
            
            list<Usage_Charge__c> listOfUsage = new list<Usage_Charge__c>();
            Usage_Charge__c usage = new Usage_Charge__c(End_Date__c = system.today(),
                                                        Invoice__c = invoice.id,
                                                        Invoice_Line__c = listInvoiceLines.get(0).id,
                                                        Order_Rate_Plan_Charge__c = charge.id,
                                                        Quantity__c = 1,
                                                        Start_Date__c = system.today(),
                                                        Status__c = 'Un-billed'
                                                        );
            insert usage;                                           
            listOfUsage.add(usage);                                         
            
            InvoicingUtilClass.getJobProductRatePlanCharges(listOfOrdersId);
            InvoicingUtilClass.insertInvoicesAndLines(mapInvoiceClass, listOfUsage);
            InvoicingUtilClass.calculateLineAmount(listOrderRatePlanCharges.get(0),system.today(),null);
            InvoicingUtilClass.calculateLineAmount(listOrderRatePlanCharges.get(0),system.today(),system.today()+60);
            InvoicingUtilClass.calculateLineAmount(listOrderRatePlanCharges.get(1),system.today(),system.today()+60);
            InvoicingUtilClass.calculateLineAmount(listOrderRatePlanCharges.get(2),system.today(),system.today()+60);
            InvoicingUtilClass.calculateLineAmount(listOrderRatePlanCharges.get(3),system.today(),system.today()+60);
            InvoicingUtilClass.calculateLineAmount(listOrderRatePlanCharges.get(4),system.today(),system.today()+60);
            InvoicingUtilClass.calculateLineAmount(listOrderRatePlanCharges.get(5),system.today(),system.today()+60);
        
            InvoicingUtilClass.calculateQuoteLineAmount(listQuoteRatePlanCharges.get(0),3);
            InvoicingUtilClass.calculateQuoteLineAmount(listQuoteRatePlanCharges.get(1),3);
            InvoicingUtilClass.calculateQuoteLineAmount(listQuoteRatePlanCharges.get(2),3);
            InvoicingUtilClass.calculateQuoteLineAmount(listQuoteRatePlanCharges.get(3),3);
            InvoicingUtilClass.calculateQuoteLineAmount(listQuoteRatePlanCharges.get(4),3);
            InvoicingUtilClass.calculateQuoteLineAmount(listQuoteRatePlanCharges.get(5),3);
            
                                                        
            Payment_Method__c paymentMethod = classpopulatetestdata.createPaymentMethod(account);
            Gateway__c gateway = ClassPopulateTestData.createGateway();
            Transaction__c transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                                                  Type__c = 'Authorization',                                               
                                                  Amount__c = 20.00, 
                                                  Currency__c = listOfCurrencies.get(0).id, 
                                                  Payment_Gateway__c = gateway.Id,
                                                  Response_Status__c = 'APPROVED',                                                
                                                  Request_Invoice__c = invoice.id
                                                  );
            insert transactionObj;
            
            Payment__c payment = classpopulatetestdata.createPayment(account,listOfCurrencies.get(0));
            payment.Transaction__c  =  transactionObj.id;
            update payment;                 
            InvoicingUtilClass.getInvoiceByName(invoice.Name);
            InvoicingUtilClass.getInvoiceById(invoice.id);
            InvoicingUtilClass.getGateway(gateway.id);
            InvoicingUtilClass.getTransaction(transactionObj.id);
            gateway.Default__c = true;
            update gateway;
            InvoicingUtilClass.getDefaultGateway();
            InvoicingUtilClass.sendResponse('Test',true);
            
            // these two lines added by Asish for covering getHTTPResponse method
            InvoicingUtilClass.getHTTPResponse('https://test.authorize.net/gateway/transact.dll', 'str');
            InvoicingUtilClass.getHTTPResponse('https://pilot-payflowpro.paypal.com', 'str');
                    
            InvoicingUtilClass.getDefaultMethodForAccount(account.id);
            paymentMethod.Default__c = false;
            paymentMethod.Active__c = false;
            paymentMethod.Is_Dummy__c = true;
            update paymentMethod;
            InvoicingUtilClass.getDummyPaymentMethodForAccount(account.id);
            InvoicingUtilClass.getAccountById(account.id);
            
            InvoicingUtilClass.createPaymentAndPaymentAllocation(invoice, transactionObj);
            InvoicingUtilClass.cancelPayment(transactionObj.id);
            
            Set<ID> setOfAccount = new Set<ID>();
            setOfAccount.add(account.id);
            InvoicingUtilClass.getSobjects(setOfAccount,'account');
            InvoicingUtilClass.calculateDiffBetweenDatesInMonths(system.today(),system.today()+60,'Monthly');
            InvoicingUtilClass.calculateDiffBetweenDatesInMonths(system.today(),system.today()+60,'Quarterly');
            InvoicingUtilClass.calculateDiffBetweenDatesInMonths(system.today(),system.today()+60,'Half Yearly');
            InvoicingUtilClass.calculateDiffBetweenDatesInMonths(system.today(),system.today()+60,'Annual');
            
            paymentMethod.Card_Number__c = null;
            update paymentMethod;
            InvoicingUtilClass.validatePaymentCardDetails(paymentMethod);
            
            paymentMethod.Card_Number__c = '4007000000027';
            paymentMethod.Card_Expiration_Month__c = null;
            update paymentMethod;
            InvoicingUtilClass.validatePaymentCardDetails(paymentMethod);
            
            
            paymentMethod.Card_Number__c = '4007000000027';
            paymentMethod.Card_Expiration_Month__c = '10';
            paymentMethod.Card_Expiration_Year__c = null;
            update paymentMethod;
            InvoicingUtilClass.validatePaymentCardDetails(paymentMethod);
            
            paymentMethod.Card_Expiration_Year__c = '2023';        
            update paymentMethod;
            InvoicingUtilClass.validatePaymentBankDetails(paymentMethod);
            
            paymentMethod.Bank_Routing_Code__c = 'Bank Routing Code';        
            update paymentMethod;
            InvoicingUtilClass.validatePaymentBankDetails(paymentMethod);
            
            paymentMethod.Bank_Account_Number__c = '3838383838383';        
            update paymentMethod;
            InvoicingUtilClass.validatePaymentBankDetails(paymentMethod);
            
            paymentMethod.Bank_Account_Type__c = 'CHECKING';        
            update paymentMethod;
            InvoicingUtilClass.validatePaymentBankDetails(paymentMethod);
            
            paymentMethod.Bank_Name__c = 'HDFC';        
            update paymentMethod;
            InvoicingUtilClass.validatePaymentBankDetails(paymentMethod);
        }
    }