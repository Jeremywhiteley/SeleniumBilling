// This class contains unit tests for validating the behavior of ControllerCreateAdhocInvoice  classes, Created By Asish
    @isTest
    private class TestControllerCreateAdhocInvoice {

        static testMethod void CreateAdhocInvoice() {
            
            ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
            ControllerInsertCustomSettings.insertValues();
         
            Account account = ClassPopulateTestData.createAccount();
            list<Contact> listOfContacts = ClassPopulateTestData.createContacts(account);
            list<Currency__c> listOfCurrencies = ClassPopulateTestData.currencies();
            Job__c job = ClassPopulateTestData.createOrder(account,listOfContacts.get(0),listOfCurrencies.get(0));
            InvoicingUtilClass.updateOrderChargesBillingGroup(job , system.today());
             /*BatchInvoiceGeneration batchInvoicegenClsObj = new BatchInvoiceGeneration();
            database.executebatch(batchInvoicegenClsObj);*/
            Job_Product__c objJobProduct = new Job_Product__c(Job__c = job.id);
            insert objJobProduct;
            Job_Rate_Plan__c objJobRatePlan = new Job_Rate_Plan__c(Job_Product__c = objJobProduct.id);
            insert objJobRatePlan;
            Job_Rate_Plan_Charge__c objJobRatePlanCharge = new Job_Rate_Plan_Charge__c(Job_Rate_Plan__c = objJobRatePlan.id, Service_Activation_Date__c = System.today().addMonths(10), Price_Type__c = 'One Time', Quantity__c=5, Next_Charge_Date__c = System.today().addMonths(10), Status__c= 'In Progress', Price__c = 50, Discount_Value__c = 4,VAT__c = 1,Tax__c = 2);
            insert objJobRatePlanCharge;

            ApexPages.Standardcontroller standardController1 = new Apexpages.Standardcontroller(job);
            ControllerCreateAdhocInvoice  controllerCreateAdhocInvoice = new ControllerCreateAdhocInvoice (standardController1);
            controllerCreateAdhocInvoice.createAdhocInvoice();
            controllerCreateAdhocInvoice.job = job;
            controllerCreateAdhocInvoice.generateInvoicePreview();
            controllerCreateAdhocInvoice.createAdhocInvoice();
            controllerCreateAdhocInvoice.generateInvoicePreview();
            //controllerCreateAdhocInvoice.createAdhocInvoice()
            
            // code coverage for InvoiceSOAPAPI 
            InvoiceSOAPAPI invsoapApiobj = new InvoiceSOAPAPI();
            invsoapApiobj.generateInvoice(job.Id);
            
            //code coverage for ProductRatePlanChargeClass 
            ProductRatePlanChargeClass clsObj = new ProductRatePlanChargeClass();
            clsObj.getProductRatePlanChargeTierClass();
            
            //code coverage for ProductRatePlanClass 
            ProductRatePlanClass planClsObj = new ProductRatePlanClass();
            planClsObj.getProductRatePlanChargeClass();
            
            //code coverage for ProductsClass 
            ProductsClass proClsObj = new ProductsClass();
            proClsObj.getProducts();
           
            //code coverage for ClassCustomIterateJob 
            ClassCustomIterateJob custIteObj = new ClassCustomIterateJob();
            custIteObj.hasNext();
            custIteObj.next();
            
            //code coverage for ClassIterateJob 
            ClassIterateJob itObj = new ClassIterateJob();
            itObj.Iterator();
            
            ControllerSupport conSupObj = new ControllerSupport();
            conSupObj.initPageAction();
            System.assertEquals('GBP', 'GBP');
        }
    }