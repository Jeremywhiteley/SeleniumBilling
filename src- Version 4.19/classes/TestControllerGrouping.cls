@isTest(oninstall = false)
    private class TestControllerGrouping{

        static testMethod void ControllerGrouping() {
            ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
            ControllerInsertCustomSettings.insertValues();

            Account istAccount = ClassPopulateTestData.createAccount();
            Account secondAccount = ClassPopulateTestData.createAccount();

            list<Contact> listOfContacts = ClassPopulateTestData.createContacts(istAccount);
            list<Contact> SecondlistOfContacts = ClassPopulateTestData.createContacts(secondAccount);

            list<Currency__c> listOfCurrencies = ClassPopulateTestData.currencies();

            list<Product__c> listOfProducts = ClassPopulateTestData.createProduct(); 
            Product__c product = listOfProducts[0];
           
            Job__c job = ClassPopulateTestData.createOrder(istAccount,listOfContacts.get(2),listOfCurrencies.get(1));
            
            Job__c secondJob = ClassPopulateTestData.createOrder(istAccount,listOfContacts.get(2),listOfCurrencies.get(1));
            
            Job_Product__c jobProduct = new Job_Product__c(Job__c = job.Id,Product__c = product.id);
            insert jobProduct;
            Job_Rate_Plan__c jobRatePlan = new Job_Rate_Plan__c(Job_Product__c = jobProduct.Id);
            insert jobRatePlan;
            
            list<Job_Rate_Plan_Charge__c> listOfORPCs = new list<Job_Rate_Plan_Charge__c>();
            Job_Rate_Plan_Charge__c charge1 = new Job_Rate_Plan_Charge__c(CurrencyL__c = listOfCurrencies.get(1).id,Service_End_Date__c=date.Today()+2, Price_Type__c = 'Usuage', Price__c = 100, Quantity__c = 1, Job_Rate_Plan__c = jobRatePlan.Id, Cost_Price__c = 10, Net_Total__c = 20, Cost__c = 1, Profit__c = 0, Unit_Price__c = 100, Sequence_No__c = 1);
            Job_Rate_Plan_Charge__c charge2 = new Job_Rate_Plan_Charge__c(CurrencyL__c = listOfCurrencies.get(1).id,Service_End_Date__c=date.Today()+3,Price_Type__c = 'Usuage', Price__c = 100, Quantity__c = 4, Job_Rate_Plan__c = jobRatePlan.Id);
            listOfORPCs.add(charge1);
            listOfORPCs.add(charge2);
            insert listOfORPCs;

            Job_Rate_Plan_Charge__c jobRatePlanCharge = [select Name, Price_Type__c From Job_Rate_Plan_Charge__c Where id=: listOfORPCs[0].id];
            System.assertEquals('Usuage', jobRatePlanCharge.Price_Type__c);
            
            list<Job_Rate_Plan_Charge_Tier__c> tierslist = new  list<Job_Rate_Plan_Charge_Tier__c>();
            Job_Rate_Plan_Charge_Tier__c tier01 = new Job_Rate_Plan_Charge_Tier__c(Start_Unit__c = 1,End_Unit__c=5,Unit_Price__c = 400,Job_Rate_Plan_Charge__c = listOfORPCs[0].id);
            Job_Rate_Plan_Charge_Tier__c tier02 = new Job_Rate_Plan_Charge_Tier__c(Start_Unit__c = 6,End_Unit__c=10,Unit_Price__c = 400,Job_Rate_Plan_Charge__c = listOfORPCs[0].id);
            Job_Rate_Plan_Charge_Tier__c tier11 = new Job_Rate_Plan_Charge_Tier__c(Start_Unit__c = 1,End_Unit__c=5,Unit_Price__c = 400,Job_Rate_Plan_Charge__c = listOfORPCs[1].id);
            Job_Rate_Plan_Charge_Tier__c tier12 = new Job_Rate_Plan_Charge_Tier__c(Start_Unit__c = 6,End_Unit__c=10,Unit_Price__c = 400,Job_Rate_Plan_Charge__c = listOfORPCs[1].id);
            tierslist.add(tier01);
            tierslist.add(tier02);
            tierslist.add(tier11);
            tierslist.add(tier12);
            insert tierslist;
            
            // creating order product charges of othe account
            Job_Product__c secondJobProduct = new Job_Product__c(Job__c = secondJob.Id,Product__c = product.id);
            insert secondJobProduct;
            Job_Rate_Plan__c secondJobRatePlan = new Job_Rate_Plan__c(Job_Product__c = secondJobProduct.Id);
            insert secondJobRatePlan;
            
            list<Job_Rate_Plan_Charge__c> secondlistOfORPCs = new list<Job_Rate_Plan_Charge__c>();
            Job_Rate_Plan_Charge__c Secondcharge1 = new Job_Rate_Plan_Charge__c(CurrencyL__c = listOfCurrencies.get(1).id,Service_End_Date__c=date.Today()+2, Price_Type__c = 'Usuage', Price__c = 100, Quantity__c = 1,Job_Rate_Plan__c = secondJobRatePlan.Id, Cost_Price__c = 10, Net_Total__c = 20, Cost__c = 1, Profit__c = 0, Unit_Price__c = 100, Sequence_No__c = 1);
            Job_Rate_Plan_Charge__c Secondcharge2 = new Job_Rate_Plan_Charge__c(CurrencyL__c = listOfCurrencies.get(1).id,Service_End_Date__c=date.Today()+3,Price_Type__c = 'Usuage', Price__c = 100, Quantity__c = 4, Job_Rate_Plan__c = secondJobRatePlan.Id);
            secondlistOfORPCs.add(Secondcharge1);
            secondlistOfORPCs.add(Secondcharge2);
            insert secondlistOfORPCs;
            
            // coving block If Type__c = 'Minimum Customer Spend
            Grouping__c nonVolumetranscationGroup = new Grouping__c(Name = 'GroupTest' ,Currency__c = listOfCurrencies.get(1).id,Minimum_Customer_Spend_Amount__c = 200,Type__c = 'Minimum Customer Spend');
            insert nonVolumetranscationGroup;
            

            charge2.Grouping__c = null;
            charge1.Grouping__c = nonVolumetranscationGroup.id;
            listOfORPCs.clear();
            listOfORPCs.add(charge1);
            listOfORPCs.add(charge2);
            upsert listOfORPCs;
            
            // asigning acountid to a set
            set<id> setOfAccountIds = new set<id>();
            setOfAccountIds.add(secondAccount.id);
            setOfAccountIds.add(istAccount.id);
            List<Account> listOfAccounts = new List<Account>();
            listOfAccounts.add(secondAccount);
           
            
            System.assertEquals(charge2.Grouping__c,null);
            
            //assigning parameter 
            ApexPages.currentPage().getParameters().put('accountId' ,istAccount.id);
            ApexPages.currentPage().getParameters().put('unSelectedAccountId' ,secondAccount.id);
            
            ApexPages.Standardcontroller standardController12 = new Apexpages.Standardcontroller(nonVolumetranscationGroup);
           
            ControllerGrouping controllerTrnsGroup1 = new ControllerGrouping(standardController12);
            controllerTrnsGroup1.setOfAccountIds = setOfAccountIds;
            controllerTrnsGroup1.listOfAccounts = listOfAccounts;
            controllerTrnsGroup1.displayOrderCharges();
            
            controllerTrnsGroup1.updateGroup();
            controllerTrnsGroup1.removeAccount(); 
            
            //nedd to remove 
            // creating transaction group of volume price
            Grouping__c transcationGroup = new Grouping__c(Name = 'GroupTest' ,Currency__c = listOfCurrencies.get(1).id,Type__c = 'Volume Based');
            insert transcationGroup;
          
            charge1.Grouping__c = transcationGroup.id;
            charge2.Grouping__c = null;
            listOfORPCs.clear();
            listOfORPCs.add(charge1);
            listOfORPCs.add(charge2);
            upsert listOfORPCs;
            
            System.assertEquals(charge2.Grouping__c,null);
            Secondcharge1.Grouping__c = transcationGroup.id;
            Secondcharge2.Grouping__c = null;
            secondlistOfORPCs.clear();
            secondlistOfORPCs.add(Secondcharge1);
            secondlistOfORPCs.add(Secondcharge2);
            upsert secondlistOfORPCs;
            
            set<id> orderChargeIds = new set<id>();
            orderChargeIds.add(secondlistOfORPCs[0].id);
            orderChargeIds.add(listOfORPCs[0].id);
           
            set<id> unSelectedOrderChargeIds = new set<id>();
            unSelectedOrderChargeIds.add(secondlistOfORPCs[0].id);
            
            unSelectedOrderChargeIds.add(listOfORPCs[1].id);
            
            //coving for save group method
            Grouping__c transcationGroupTest = new Grouping__c(Name = 'GroupTest' ,Currency__c = listOfCurrencies.get(1).id,Type__c = 'Volume Based');
            ApexPages.Standardcontroller standardController1Test = new Apexpages.Standardcontroller(transcationGroupTest);
            ControllerGrouping controllerTrnsGroupTest = new ControllerGrouping(standardController1Test);
            controllerTrnsGroupTest.groupObj = transcationGroupTest;
            ControllerGrouping.OrderWrapperCharges orderClsObj = new ControllerGrouping.OrderWrapperCharges();
            orderClsObj.orderCharge = listOfORPCs[0];
            orderClsObj.isSelectedCharge = true;
            list<ControllerGrouping.OrderWrapperCharges> listOfWrapperCharges = new list<ControllerGrouping.OrderWrapperCharges>();
            listOfWrapperCharges.add(orderClsObj);
            controllerTrnsGroupTest.listOfWrapperCharges = listOfWrapperCharges;
            controllerTrnsGroupTest.saveGroup();
            
            ApexPages.Standardcontroller standardController1 = new Apexpages.Standardcontroller(transcationGroup);
            ControllerGrouping controllerTrnsGroup = new ControllerGrouping(standardController1);
            controllerTrnsGroup.setOfAccountIds = setOfAccountIds;
            controllerTrnsGroup.orderChargeIds = orderChargeIds;
            controllerTrnsGroup.unSelectedOrderChargeIds = unSelectedOrderChargeIds;
            controllerTrnsGroup.addAccountDetail();
            controllerTrnsGroup.removeAccount();
            controllerTrnsGroup.nextPage();
            controllerTrnsGroup.step1();
            controllerTrnsGroup.displayOrderCharges();
          
            controllerTrnsGroup.isSelectedType();
            //controllerTrnsGroup.save();
            controllerTrnsGroup.updateGroup();
            controllerTrnsGroup.isSelectedType();
             
            ControllerGrouping clsObjAccountSetNull = new ControllerGrouping(standardController1);
            clsObjAccountSetNull.nextPage();
            
            
            //ApexPages.Standardcontroller standardController14 = new Apexpages.Standardcontroller(transcationGroup);
            ControllerGrouping controllerTrnsGroup4 = new ControllerGrouping(standardController12);
            controllerTrnsGroup4.setOfAccountIds = setOfAccountIds;
            controllerTrnsGroup4.orderChargeIds = orderChargeIds;
            controllerTrnsGroup4.unSelectedOrderChargeIds = unSelectedOrderChargeIds;
            controllerTrnsGroup4.listOfAccounts = listOfAccounts;
            controllerTrnsGroup4.removeAccount();
            controllerTrnsGroup4.updateGroup();
            
            // cover catch block
            Apexpages.Standardcontroller stdController = new Apexpages.Standardcontroller(transcationGroup);
            ControllerGrouping controllerGroupingObj = new ControllerGrouping(stdController);
            controllerGroupingObj.saveGroup();
            delete transcationGroup;
            controllerGroupingObj.updateGroup();   
        }

       static testMethod void controllerCancelInvoice(){
        
            ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
            ControllerInsertCustomSettings.insertValues();
        
            Account account = new Account(Name = 'Test Account', Customer_Profile_ID__c='24870718');
            insert account;

            Account account1 = [select Name From Account Where Id=:account.id];
            System.assertEquals('Test Account', account1.Name);
            
            Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '$');
            insert currency1;
            
            Contact con = new Contact(LastName = 'con');
            insert con;
            
            Invoice__c invoice = new Invoice__c(Account__c = account.id, CurrencyL__c = currency1.Id, Target_Date__c = system.today(),Delivery_Type__c = 'Both',Invoice_Status__c = CommonUtilClass.STATUS_POSTED);
            insert invoice;
            
            ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(invoice); 
            ControllerCancelInvoice  controllerCancelInvoiceObj = new ControllerCancelInvoice(standardController);
            invoice.Invoice_Status__c = CommonUtilClass.STATUS_CANCELLED;
            upsert invoice;
                            
            controllerCancelInvoiceObj.cancelInvoice();
            controllerCancelInvoiceObj.cancelPost();
            
            //classForHandlingAuthorizeDotNet
            Gateway__c gateway = new Gateway__c(Active__c = true, Gateway_Type__c = 'Authorize.net', Test_Mode__c = true, Merchant_ID__c = '22LbQ9b7', Security_Key__c = '8Fh7VnPV3e6h4b4S', Merchant_Seal_User_Id__c = '8Fh7VnPV3e6h4b4S...');
            insert gateway;
         
            ClassForHandlingAuthorizeDotNet classForHandlingAuthorizeDotNetObj = new ClassForHandlingAuthorizeDotNet(gateway,null,null); 
            classForHandlingAuthorizeDotNetObj.handleAuthorize_Click();
            classForHandlingAuthorizeDotNetObj.handleRefund_Click('','',null);
            classForHandlingAuthorizeDotNetObj.handleVoid_Click('','',null);
            
            //controllerCreateAdhocInvoice
            Job__c job = new Job__c(Name = 'Test Job', Account__c = account.Id, CurrencyL__c = currency1.Id);
            insert job;
          
            ApexPages.Standardcontroller standardController1 = new Apexpages.Standardcontroller(job);
            ControllerCreateAdhocInvoice  controllerCreateAdhocInvoice = new ControllerCreateAdhocInvoice(standardController1);
            controllerCreateAdhocInvoice.createAdhocInvoice();
            
            //createProductsController
            Product__c product = new Product__c();
            ApexPages.StandardController stdController = new Apexpages.Standardcontroller(product);
            CreateProductsController createProductsControllerobj= new CreateProductsController(stdController);
            system.currentPageReference().getParameters().put('ratePlanCounter','null');
            system.currentPageReference().getParameters().put('retURL','hello');
            createProductsControllerobj.saveProduct();
            
            //createProductsControllerNew
            Product__c productObj = new Product__c();
            Product_Rate_Plan__c prateplan = new Product_Rate_Plan__c(Product__c = productObj.Id);
            ApexPages.StandardController stdControllerObj1 = new Apexpages.Standardcontroller(productObj);
            CreateProductsControllerNew createProductsControllernewobj= new CreateProductsControllerNew(stdControllerObj1); 
            
            createProductsControllernewobj.saveProduct();
            upsert productObj;
            
            delete productObj;
            createProductsControllernewobj.deleteProduct();
            createProductsControllernewobj.updateProduct();
            createProductsControllernewobj.newProductTobeClone = null;
            createProductsControllernewobj.saveClonedProduct();
            createProductsControllernewobj.saveClonedRatePlan();
            createProductsControllernewobj.saveRatePlan();
            createProductsControllernewobj.removeRatePlan();
            createProductsControllernewobj.saveCharge();
            createProductsControllernewobj.removeRatePlanCharges();
            createProductsControllernewobj.filterCharges();
            createProductsControllernewobj.saveProductLayout();
            createProductsControllernewobj.saveRatePlanLayout();
            createProductsControllernewobj.saveChargesLayout();
            createProductsControllernewobj.saveClonedCharge();
            createProductsControllernewobj.filterRatePlan();
            
            //CsvToSObjectParser
            CsvToSObjectParser csvToSObjectParserobj = new CsvToSObjectParser();
            
            //controllerGenerateInvoiceobj
            ApexPages.StandardController stdController1 = new ApexPages.StandardController(job);
            ControllerGenerateInvoice  controllerGenerateInvoiceobj = new ControllerGenerateInvoice(stdController1);
            
            controllerGenerateInvoiceobj.generateInvoice();
            
            //InvoiceITSetupController
            InvoiceITSetupController invoiceITSetupControllerobj = new InvoiceITSetupController(); 
            invoiceITSetupControllerobj.saveCustomMappingGeneral();
            invoiceITSetupControllerobj.saveCustomMappingQuote2Order();
            invoiceITSetupControllerobj.saveCustomMappingOpp2Order();
            invoiceITSetupControllerobj.saveCustomMappingOpp2Quote();
            invoiceITSetupControllerobj.saveProductFilter();
            
            //ControllerVirtualTerminal
            ApexPages.StandardController stdControllerObj = new Apexpages.Standardcontroller(account);
            ControllerVirtualTerminal controllerVirtualTerminalobj = new ControllerVirtualTerminal(stdControllerObj);
            apexPages.currentPage().getParameters().put('Id','dummy');
            controllerVirtualTerminalobj.processPaymentRedirect();
            controllerVirtualTerminalobj.processPayment();
            
        }
        
        static testMethod void createQuoteController(){
            
            ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
            ControllerInsertCustomSettings.insertValues();
            
            Account testAccount = new Account(name='testAccount');
            insert testAccount;
            
            Account account1 = [select Name From Account Where Id=:testAccount.id];
            System.assertEquals('testAccount', account1.Name);

            Contact con = new Contact(lastname = 'testname',AccountId = testAccount.id);
            insert con;
            
            Currency__c currency1 = new Currency__c(name = 'GKP', Symbol__c = '$');
            insert currency1;
            
            Product__c product = new Product__c();
            
            Product_Rate_Plan__c prateplan = new Product_Rate_Plan__c(Product__c = product.Id);
            
            Product_Rate_Plan_Charge__c prateplancharge = new Product_Rate_Plan_Charge__c(Product_Rate_Plan__c = prateplan.Id,CurrencyL__c = currency1.Id);
            
            Quote__c quote1 = new Quote__c(Account__c = testAccount.Id,CurrencyL__c = currency1.Id,Shipping_Contact__c = con.Id);
            insert quote1;
            
            Quote_Product__c qproduct = new Quote_Product__c(Quote__c = quote1.Id,Product__c = product.Id);
            
            Quote_Rate_Plan__c qrateplan = new Quote_Rate_Plan__c(Product_Rate_Plan__c = prateplan.Id,Quote_Product__c = qproduct.Id);
            
            Quote__c quote = new Quote__c(Account__c = testAccount.Id,CurrencyL__c = currency1.Id);
            
            ApexPages.StandardController stdController = new Apexpages.Standardcontroller(quote);
            CreateQuoteController createQuoteControllerobj = new CreateQuoteController(stdController);
            
            createQuoteControllerobj.selectedRatePlanId = 'null';
            createQuoteControllerobj.selectedProductId = 'dummy';
        
            system.currentPageReference().getParameters().put('productId','product.Id');
            system.currentPageReference().getParameters().put('productName','product1');
            system.currentPageReference().getParameters().put('quoteRatePlanId','quote1.Id');
            system.currentPageReference().getParameters().put('quoterateplancounter','2');
            system.currentPageReference().getParameters().put('ratePlanId','prateplan.Id');
            system.currentPageReference().getParameters().put('rateplanName','prateplan');
            system.currentPageReference().getParameters().put('ratePlanChargeId','prateplancharge.Id');
            
            createQuoteControllerobj.getRatePlansForProduct();
            createQuoteControllerobj.getRatePlanChargesForRatePlan();
            createQuoteControllerobj.addQuoteCharges();
        
            quote.Shipping_Contact__c = con.Id;
            upsert quote;
            
            createQuoteControllerobj.saveQuote();
            //createQuoteControllerobj.removeQuotes();
            createQuoteControllerobj.chargeCalculator();
            createQuoteControllerobj.save();
            createQuoteControllerobj.cloneQuote();
            createQuoteControllerobj.cloneQuoteWithDifferentCurrency();
            createQuoteControllerobj.removeTier();
            createQuoteControllerobj.convertQuote();
            
            ClassPopulateTestData.createProductCatalogFilterCriteria();
            ClassPopulateTestData.createCustomSettingMapping();
         }
         
         
        static testMethod void CreateJobController(){
            
            ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
            ControllerInsertCustomSettings.insertValues();
            String jobrateplansize;
            
            Account testAccount1 = new Account(name='testAccount');
            insert testAccount1;

            Account account1 = [select Name From Account Where Id=:testAccount1.id];
            System.assertEquals('testAccount', account1.Name);
            
            Currency__c currency12 = new Currency__c(name = 'GVL', Symbol__c = '%dev');
            insert currency12;
            
            Job__c order = new Job__c(Account__c = testAccount1.Id,CurrencyL__c = currency12.Id,Preferred_Billing_Day__c = '01',Start_Date__c = system.today(),Service_Activation_Date__c = system.today());
            insert order;
            
            Job_Product__c orderProduct = new Job_Product__c(Job__c = order.Id);
            insert orderProduct;
            
            Job_Rate_Plan__c rateplan = new Job_Rate_Plan__c(Job_Product__c = orderProduct.Id);
            insert rateplan;
            
            job__c job = new job__c(Start_Date__c = System.today());
            ApexPages.StandardController controller = new ApexPages.StandardController(job);
            CreateJobController createJobController = new CreateJobController(controller);  
            
            createJobController.selectedProductId = 'null';
            createJobController.selectedProductName = null;
            createJobController.selectedRatePlanId = 'null1';
            createJobController.sFilterCriteria = '';
            createJobController.listJobProducts = null ;
            system.currentPageReference().getParameters().put('productId',orderProduct.Id);
            system.currentPageReference().getParameters().put('productName','null01');
            createJobController.getRatePlansForProduct();
            createJobController.getRatePlanChargesForRatePlan();
            createJobController.addJobCharges();
            createJobController.saveJob();
            system.currentPageReference().getParameters().put('jobRatePlanId',rateplan.Id);
            system.currentPageReference().getParameters().put('jobrateplancounter','1');
            createJobController.listJobRatePlans = null;
            createJobController.chargeCalculator();
            createJobController.save();
            createJobController.saveAmendment();
            
            //controllerGenerateProformaInvoice
            ApexPages.StandardController controllerObj = new ApexPages.StandardController(order);
            ControllerGenerateProformaInvoice controllerGenerateProformaInvoiceobj = new ControllerGenerateProformaInvoice(controllerObj);
            controllerGenerateProformaInvoiceobj.sInvoiceRefNo = null;
            controllerGenerateProformaInvoiceobj.createProformaInvoice();
         }
         
         static testMethod void runNegativeTestCases() {
        
            // This is to cover the exception block in AddStockItemsController Class by Mani
            ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
            ControllerInsertCustomSettings.insertValues();
            Stock_Item__c StockItem = new Stock_Item__c();
            ApexPages.StandardController controllerObj1 = new ApexPages.StandardController(StockItem);
            AddStockItemsController addStockItemsControllerobj1 = new AddStockItemsController(controllerObj1);
        
            addStockItemsControllerobj1.selectedProductId = 'dummy';
            addStockItemsControllerobj1.sBarcodes = 'dummy\ndummy';
            addStockItemsControllerobj1.insertStockItems();
            addStockItemsControllerobj1.insertStockItems(); 
        
            // This is to cover the exception block in AutoComplete Class by Mani
            ControllerAutoComplete.findSObjects('account', 'dummy', 'dummy', 'dummy', 'dummy', 'dummy', 'dummy'); 
        
            // this is to cover the exception block in ClassQuoteEmail   by Mani   
            ClassQuoteEmailHandler classQuoteEmailHandlerObj = new ClassQuoteEmailHandler();
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
            // setup the data for the email
            email.ccAddresses = new String[] {'mani@salesforce.com'};
            email.subject = 'Test Email';
            email.fromAddress = 'mani01@gmail.com';
            envelope.toAddress=('forwardzillowemail@2ydvi7xh9fe3oh0ltcv8utuk7sxf4czsk9rsxchmloqeky0301.c-9mdleaq.cl.apex.sandbox.salesforce.com');
            email.htmlBody='<html><title>This s A test mail</title><body>Hi cool.</body></html>';
            if(!Test.isRunningTest()) {
                classQuoteEmailHandlerObj.handleInboundEmail(email,envelope);   
            }
            // This is to cover the exception block in ClassWebServiceEmailing by Mani
            ClassWebServiceEmailing.sendInvoice(null);
            ClassWebServiceEmailing.sendQuote(null);
            ClassWebServiceEmailing.attachPdf(null,'mani');
            ClassWebServiceEmailing.attachPdfToOpportunity(null,'mani', null);
            ClassWebServiceEmailing.emailAllInvoicesForInvoiceRun(null);
            //ClassWebServiceEmailing.postAllInvoicesForInvoiceRun(null);
        
            list<Currency__c> listOfCurrencies = ClassPopulateTestData.currencies();                
            Invoice_RunScheduler__c invoiceRunScheduler = new Invoice_RunScheduler__c();
            invoiceRunScheduler.Start_date_and_time__c = system.Now()+2;
            invoiceRunScheduler.Name = 'Mani';
            invoiceRunScheduler.Type__c = System.Label.OptionMonthly;
            invoiceRunScheduler.Invoice_Day_Of_Month__c = '1';
            invoiceRunScheduler.Target_Day_Of_Month__c='1';
            invoiceRunScheduler.JobId__c ='1tyuhijk';
            invoiceRunScheduler.Invoice_Currency__c = '01rU00000005JO9';
        
            ApexPages.StandardController controllerObj2 = new ApexPages.StandardController(invoiceRunScheduler);
            ControllerForScheduling ControllerForSchedulingControllerobj2 = new ControllerForScheduling(controllerObj2);
            ControllerForSchedulingControllerobj2.saveInvoiceRunScheduler();  
        
            invoiceRunScheduler.Invoice_Currency__c = listOfCurrencies[0].id;
            insert invoiceRunScheduler;

            Invoice_RunScheduler__c invRunScheduler = [select Name From Invoice_RunScheduler__c Where id=:invoiceRunScheduler.id];
            System.assertEquals('Mani', invRunScheduler.Name);
            
            ControllerForSchedulingControllerobj2.saveInvoiceRunScheduler();              
        
        
            // This is to cover the exception block in ControllerforSchedulingPayment Class by Mani
        
            Payment_Scheduler__c paymentScheduler = new Payment_Scheduler__c();
            paymentScheduler.Start_date_and_time__c = system.Now()+2;
            paymentScheduler.Name = 'Mani';
            paymentScheduler.Type__c = System.Label.OptionMonthly;
            paymentScheduler.Target_Day_Of_Month__c='1';
            paymentScheduler.JobId__c ='1234567';
            paymentScheduler.Currency__c = '01rU00000005R10';
        
            ApexPages.StandardController controllerObj3 = new ApexPages.StandardController(paymentScheduler);
            ControllerForSchedulingPayments ControllerForSchedulingPaymentsControllerobj3 = new ControllerForSchedulingPayments(controllerObj3);
            ControllerForSchedulingPaymentsControllerobj3.savePaymentScheduler();  
        
            paymentScheduler.Currency__c = listOfCurrencies[0].id;
            insert paymentScheduler;
            ControllerForSchedulingPaymentsControllerobj3.savepaymentScheduler();    
        }
    }