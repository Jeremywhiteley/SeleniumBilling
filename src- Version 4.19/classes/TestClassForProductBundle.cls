@isTest
    private class TestClassForProductBundle {

        static testMethod void methodControllerProductBundle() {
            ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
            ControllerInsertCustomSettings.insertValues();
        
            Date validtodate = Date.today()-100;   
            list<Product__c> listProducts = new list<Product__c>();
            Product__c product;
            for(Integer x = 0;x < 1;x++){
              product = new  Product__c(Name = 'Test Product' + x,Valid_From_Date__c = validtodate,Valid_To_Date__c = validtodate,Product_Family__c = 'Default',Product_Code__c = 'Code1',Description__c = 'Product');
              listProducts.add(product);
            }  
            
            Product__c productTiers = new  Product__c(Name = 'Test Product for tiers',Valid_From_Date__c = validtodate,Valid_To_Date__c = validtodate,Product_Family__c = 'Default',Product_Code__c = 'Code1',Description__c = 'Product');  
            listProducts.add(productTiers);
            insert listProducts;

            System.assertEquals('GBP', 'GBP');
            
            list<Product_Rate_Plan__c> listProductRatePlans = new list<Product_Rate_Plan__c>();
            Product_Rate_Plan__c productRatePlan;
            for(Integer x = 0;x< 1;x++){
              productRatePlan = new  Product_Rate_Plan__c(  Name = 'Test ProductRatePlan' + x,
                                                            Product__c = listProducts.get(x).Id,
                                                            Valid_From_Date__c = validtodate);
              listProductRatePlans.add(productRatePlan);
            }
            
            Product_Rate_Plan__c productRatePlanTiers = new Product_Rate_Plan__c(Name = 'Test ProductRatePlan tiers',
                                                            Product__c = listProducts.get(1).Id,
                                                            Valid_From_Date__c = validtodate);
                                                            
            Product_Rate_Plan__c productRatePlanTier = new Product_Rate_Plan__c(Name = 'Test ProductRatePlan tiers',
                                                            Product__c = listProducts.get(1).Id,
                                                            Valid_From_Date__c = validtodate);                                                
            
            listProductRatePlans.add(productRatePlanTier);
            listProductRatePlans.add(productRatePlanTiers);
            insert listProductRatePlans;
            
            list<Currency__c> listCurrencys = new list<Currency__c>();
            listCurrencys.add(new Currency__c(Name = 'GBP', Symbol__c = '£1'));
            listCurrencys.add(new Currency__c(Name = 'USD', Symbol__c = '$2'));
            listCurrencys.add(new Currency__c(Name = 'EUR', Symbol__c = '€3'));    
            insert listCurrencys;
            
            list<Product_Rate_Plan_Charge__c> listProductRatePlanCharges = new list< Product_Rate_Plan_Charge__c>();
            Product_Rate_Plan_Charge__c productRatePlanCharge;
            Product_Rate_Plan_Charge__c productRatePlanCharge2;
            for(Integer x = 0;x <= 5;x++){
              productRatePlanCharge = new  Product_Rate_Plan_Charge__c(Name = 'Test ProductRatePlan Charge' + x,CurrencyL__c = listCurrencys.get(0).Id,Price_Type__c = system.Label.OptionOneTime,
                                                                       Product_Rate_Plan__c = listProductRatePlans.get(0).Id,
                                                                       Unit_price__c = 200,Cost_Price__c = 160, Product_Charge_Category__c = 'Taxable');
              
              productRatePlanCharge2 = new  Product_Rate_Plan_Charge__c(Name = 'Test ProductRatePlan Charge' + x,CurrencyL__c = listCurrencys.get(0).Id,
                                                                       Product_Rate_Plan__c = listProductRatePlans.get(0).Id,
                                                                       Unit_price__c = 200,Cost_Price__c = 160, Product_Charge_Category__c = 'Taxable');                                                         
              
              listProductRatePlanCharges.add(productRatePlanCharge);
              listProductRatePlanCharges.add(productRatePlanCharge2);
                  
            }
            
            Product_Rate_Plan_Charge__c tierCharge = new Product_Rate_Plan_Charge__c(Name = 'Test ProductRatePlan Charge Tiers',CurrencyL__c = listCurrencys.get(0).Id,Price_Type__c = system.Label.OptionOneTime,
                                                                       Product_Rate_Plan__c = productRatePlanTiers.Id,
                                                                       Unit_price__c = 0,Cost_Price__c = 0, Product_Charge_Category__c = 'Taxable', Price_Format__c = CommonUtilClass.PRICE_FORMAT_VOLUME);
            listProductRatePlanCharges.add(tierCharge);
            insert listProductRatePlanCharges;
            
            list<Product_Rate_Plan_Charge_Tier__c> tiers = new list<Product_Rate_Plan_Charge_Tier__c>();
            tiers.add(new Product_Rate_Plan_Charge_Tier__c(Start_Unit__c = 1, End_Unit__c = 10, Unit_Cost_Price__c = 90, Unit_Price__c = 120, Product_Rate_Plan_Charge__c = tierCharge.Id));
            tiers.add(new Product_Rate_Plan_Charge_Tier__c(Start_Unit__c = 11, End_Unit__c = 20, Unit_Cost_Price__c = 90, Unit_Price__c = 110, Product_Rate_Plan_Charge__c = tierCharge.Id));
            tiers.add(new Product_Rate_Plan_Charge_Tier__c(Start_Unit__c = 21, End_Unit__c = 30, Unit_Cost_Price__c = 90, Unit_Price__c = 100, Product_Rate_Plan_Charge__c = tierCharge.Id));
            insert tiers;
            
            Product_Bundle__c productBundle = new Product_Bundle__c(Name = 'Devender', Bundle_Type__c = 'Line', Start_Date__c = system.today() - 1,Currency__c = listCurrencys.get(0).Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(productBundle);
            ControllerProductBundle controllerProductBundleObj = new ControllerProductBundle(controller);
            
            controllerProductBundleObj.onChangeType();
            
            controllerProductBundleObj.step2();
            controllerProductBundleObj.step1();
            controllerProductBundleObj.step2();
            controllerProductBundleObj.cloneProductBundle();
            
            //Adding the product and charges
            system.currentPageReference().getParameters().put('productId',listProducts[0].Id);
            controllerProductBundleObj.addProductDetail();
            
            for(ControllerProductBundle.ClassProductRatePlan cprp : controllerProductBundleObj.listOfClassProductRatePlan) {
                cprp.isSelected = true;
            } 
            
            controllerProductBundleObj.saveAndCloseProductRPPopup();
            
            system.currentPageReference().getParameters().put('productId',listProducts[1].Id);
            controllerProductBundleObj.addProductDetail();
            
            for(ControllerProductBundle.ClassProductRatePlan cprp : controllerProductBundleObj.listOfClassProductRatePlan) {
                cprp.isSelected = true;
            } 
            
            controllerProductBundleObj.saveAndCloseProductRPPopup();
            
            // Removing the product
            system.currentPageReference().getParameters().put('productId',listProducts[1].Id);
            controllerProductBundleObj.removeProduct();
            
            map<string,list<ControllerProductBundle.ProductChargeWrapperCharges>> locMapProduct_Charges;
            list<ControllerProductBundle.ProductChargeWrapperCharges> listOfWrapperChargesLoc;
            
            for(string productId : controllerProductBundleObj.map_Product_mapRate_Charges.keySet()) {
                locMapProduct_Charges = controllerProductBundleObj.map_Product_mapRate_Charges.get(productId);
                    for(string productRatePlanId : locMapProduct_Charges.keySet()) {
                        listOfWrapperChargesLoc = locMapProduct_Charges.get(productRatePlanId);
                            for(ControllerProductBundle.ProductChargeWrapperCharges productChargeWrapperCharges : listOfWrapperChargesLoc) {
                                productChargeWrapperCharges.isSelectedCharge = true;
                            }
                    }
            }     
            controllerProductBundleObj.save();
            
            system.currentPageReference().getParameters().put('productId',listProducts[1].Id);
            controllerProductBundleObj.addProductDetail();
            
            for(ControllerProductBundle.ClassProductRatePlan cprp : controllerProductBundleObj.listOfClassProductRatePlan) {
                cprp.isSelected = true;
            } 
            
            controllerProductBundleObj.saveAndCloseProductRPPopup();
            
            ApexPages.StandardController controllerObj = new ApexPages.StandardController(controllerProductBundleObj.productBundle);
            ControllerProductBundle controllerProductBundleObjInst = new ControllerProductBundle(controllerObj);
            
            Product_Bundle__c productBundleObj = new Product_Bundle__c(Name = 'Devender', Bundle_Type__c = 'Bundle', Start_Date__c = system.today() - 1,Currency__c = listCurrencys.get(0).Id,
                                                                    Bundle_Price__c = 100, Is_Price_Editable__c = true, Is_Quantity_Editable__c = false,Price_Type__c = 'One Time',
                                                                    Quantity__c = 1.0, Unit_Of_Measurement__c = 'One', Pricing_Model__c = 'Default');
            insert productBundleObj; 
            // For Order
            
            Account account = ClassPopulateTestData.createAccount();
            
            list<Contact> contact = ClassPopulateTestData.createContacts(account);
            Job__c job1 = new Job__c(Name = 'Test Job',Account__c = account.Id,Billing_Contact__c = contact[0].Id,Shipping_Contact__c = contact[0].Id,Number_Of_Terms__c = 24,
                                     Start_Date__c = system.today(),Service_Activation_Date__c = system.today(),Service_End_Date__c = system.today().addMonths(10));
                                   
            ApexPages.Standardcontroller stdController = new Apexpages.Standardcontroller(job1);
            CreateJobController createJobController = new CreateJobController(stdController);
            
            //Move to the first page
            createJobController.step2();
            
            system.currentPageReference().getParameters().put('productId', controllerProductBundleObj.productBundle.Id);
            system.currentPageReference().getParameters().put('productName', controllerProductBundleObj.productBundle.name);
            createJobController.getRatePlansForProduct();
            
            system.currentPageReference().getParameters().put('productId', controllerProductBundleObj.productBundle.Id);
            system.currentPageReference().getParameters().put('productName', controllerProductBundleObj.productBundle.name);
            createJobController.getRatePlansForProduct();
            
            for(JobProductClass qpc : createJobController.jobClass.jobProducts)
            {
                system.currentPageReference().getParameters().put('jobrateplancounter', '0');
                system.currentPageReference().getParameters().put('jobRatePlanId', createJobController.jobRatePlanClass.jobrateplan.Id);
                system.currentPageReference().getParameters().put('productBundleId', string.valueOf(qpc.jobproduct.Bundle_SequenceNumber__c));
                createJobController.removeCharges();
                break;
            }
            
            system.currentPageReference().getParameters().put('productId', productBundleObj.Id);
            system.currentPageReference().getParameters().put('productName', productBundleObj.name);
            createJobController.getRatePlansForProduct();
            
            createJobController.saveJob();
            
            ApexPages.Standardcontroller stdControllerObj = new Apexpages.Standardcontroller(createJobController.job);
            CreateJobController createJobControllerObj = new CreateJobController(stdControllerObj);
            
            Quote__c quote = new Quote__c(Name = 'Test quote1',Account__c = account.Id, CurrencyL__c = listCurrencys.get(0).Id,Number_Of_Terms__c = 24,
                                       Start_Date__c = system.today(), Billing_Contact__c = contact[0].Id,Shipping_Contact__c = contact[0].Id);
                                       
            ApexPages.Standardcontroller controllerQuote = new Apexpages.Standardcontroller(quote);
            CreateQuoteController createQuoteController = new CreateQuoteController(controllerQuote);
            
            createQuoteController.step1();
            
            system.currentPageReference().getParameters().put('productId',productBundleObj.Id);
            system.currentPageReference().getParameters().put('productName',productBundleObj.name);
            createQuoteController.getRatePlansForProduct();    
            
            system.currentPageReference().getParameters().put('productId',productBundleObj.Id);
            system.currentPageReference().getParameters().put('productName',productBundleObj.name);
            createQuoteController.getRatePlansForProduct();   
            
            system.currentPageReference().getParameters().put('productId', controllerProductBundleObj.productBundle.Id);
            system.currentPageReference().getParameters().put('productName', controllerProductBundleObj.productBundle.name);
            createQuoteController.getRatePlansForProduct();
            
            for(QuoteProductClass qpc : createQuoteController.quoteClass.quoteProducts)
            {
                system.currentPageReference().getParameters().put('quoterateplancounter','0');
                system.currentPageReference().getParameters().put('quoteRatePlanId',CreateQuoteController.quoteRatePlanClass.quoterateplan.id);
                system.currentPageReference().getParameters().put('productBundleId', string.valueOf(qpc.quoteproduct.Bundle_SequenceNumber__c));
                CreateQuoteController.removeQuotes();  
                break;
            }    
             
            createQuoteController.saveQuote();
            
            ApexPages.Standardcontroller controllerQuote1 = new Apexpages.Standardcontroller(createJobController.job);
            CreateJobController createJobController1 = new CreateJobController(controllerQuote1);         
        }
    }