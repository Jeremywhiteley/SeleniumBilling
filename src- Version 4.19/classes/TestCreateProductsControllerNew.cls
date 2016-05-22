@isTest(SeeALLData = false)
private with sharing class TestCreateProductsControllerNew {   
    public static String sPrefix = CommonUtilClass.getPrefix();
    static testMethod void createProductsController() {
        ControllerInsertCustomSettings c = new ControllerInsertCustomSettings();
        c.insertValues();
        list<Configuration__c> objects = new list<Configuration__c>();
        Configuration__c c1 = new Configuration__c(Name = 'NAVIGATION_FOR_PRODUCTRATEPLAN', Field_Type__c = 'Number', Description__c = 'This is used for product rate plan navigation in product page', NUMBER_VALUE__C = 2);
        Configuration__c c2 = new Configuration__c(Name = 'NAVIGATION_FOR_PRODUCTCHARGE', Field_Type__c = 'Number', Description__c = 'This is used for product rate plan charge navigation in product page', NUMBER_VALUE__C = 2);
        
        objects.add(c1);
        objects.add(c2);
        upsert objects;
        
        Currency__c currencyObj = new Currency__c(name = 'GBP', Currency_Symbol__c = '£1');
        insert currencyObj;

        Product__c product1 = new Product__c(Name = 'Default');
        ApexPages.Standardcontroller controller = new Apexpages.Standardcontroller(product1);
        CreateProductsController createProductsController1 = new CreateProductsController(controller);
        createProductsController1.saveProduct();
    
        Layout_Fields__c layoutFieldsProduct = new  Layout_Fields__c(Name=sPrefix+'Product__c',Selected_Fields__c ='Name-115');
        Layout_Fields__c layoutFieldsProductRateplan = new  Layout_Fields__c(Name=sPrefix+'Product_Rate_Plan__c',Selected_Fields__c ='Name-115');
        Layout_Fields__c layoutFieldsProductCharge = new  Layout_Fields__c(Name=sPrefix+'Product_Rate_Plan_Charge__c',Selected_Fields__c ='Name-115');
        
        insert layoutFieldsProduct;
        insert layoutFieldsProductRateplan;
        insert layoutFieldsProductCharge;
        
        Product__c product = new  Product__c(Name = 'Test Product',Valid_From_Date__c = Date.today(),Valid_To_Date__c = Date.today()+90,
                                          Product_Family__c = 'Default',Product_Code__c = 'Code1', Description__c = 'Product');
        insert  product;

        Product__c productNew = [SELECT Name FROM Product__c WHERE id =: product.id];
        System.assertEquals('Test Product', productNew.Name);
        
        list<Product_Rate_Plan__c> listofProductRatePlan = new list<Product_Rate_Plan__c>();
        Product_Rate_Plan__c productRatePlan1 = new  Product_Rate_Plan__c(Name = 'Test ProductRatePlan 1',
                Product__c = product.Id,
                Valid_From_Date__c = Date.today(),
                Valid_To_Date__c = Date.today()+90
        );
        Product_Rate_Plan__c productRatePlan2 = new  Product_Rate_Plan__c(Name = 'Test ProductRatePlan 2',
                Product__c = product.Id,
                Valid_From_Date__c = Date.today(),
                Valid_To_Date__c = Date.today()+90
        );
        Product_Rate_Plan__c productRatePlan3 = new  Product_Rate_Plan__c(Name = 'Test ProductRatePlan 3',
                Product__c = product.Id,
                Valid_From_Date__c = Date.today(),
                Valid_To_Date__c = Date.today()+90
        );
        Product_Rate_Plan__c productRatePlan4 = new  Product_Rate_Plan__c(Name = 'Test ProductRatePlan 4',
                Product__c = product.Id,
                Valid_From_Date__c = Date.today(),
                Valid_To_Date__c = Date.today()+90
        );
        listofProductRatePlan.add(productRatePlan1);
        listofProductRatePlan.add(productRatePlan2);
        listofProductRatePlan.add(productRatePlan3);
        listofProductRatePlan.add(productRatePlan4);
        insert listofProductRatePlan;

        list<Product_Rate_Plan_Charge__c> listProductRatePlanCharges = new list<Product_Rate_Plan_Charge__c>();       
        Product_Rate_Plan_Charge__c productRatePlanCharge1 = new Product_Rate_Plan_Charge__c(Name = 'Setup Charges',
                CurrencyL__c = currencyObj.Id,
                Product_Rate_Plan__c = listofProductRatePlan[0].Id,
                Unit_Price__c = 1000,
                Cost_Price__c = 500,                                                                  
                Price_Type__c = 'One Time'      
        );

        Product_Rate_Plan_Charge__c productRatePlanCharge2 = new Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                CurrencyL__c = currencyObj.Id,
                Product_Rate_Plan__c = listofProductRatePlan[0].Id,
                Unit_Price__c = 1000,
                Cost_Price__c = 500,                                                                  
                Price_Type__c = 'Monthly'       
        );
        Product_Rate_Plan_Charge__c productRatePlanCharge3 = new Product_Rate_Plan_Charge__c(Name = 'Setup Charges',
                CurrencyL__c = currencyObj.Id,
                Product_Rate_Plan__c = listofProductRatePlan[0].Id,
                Unit_Price__c = 1000,
                Cost_Price__c = 500,                                                                  
                Price_Type__c = 'One Time'      
        );

        Product_Rate_Plan_Charge__c productRatePlanCharge4 = new Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                CurrencyL__c = currencyObj.Id,
                Product_Rate_Plan__c = listofProductRatePlan[0].Id,
                Unit_Price__c = 1000,
                Cost_Price__c = 500,                                                                  
                Price_Type__c = 'Monthly'       
        );
        listProductRatePlanCharges.add(productRatePlanCharge1);
        listProductRatePlanCharges.add(productRatePlanCharge2);
        listProductRatePlanCharges.add(productRatePlanCharge3);
        listProductRatePlanCharges.add(productRatePlanCharge4);
        insert listProductRatePlanCharges;

        list<Product_Rate_Plan_Charge_Tier__c> listProductRatePlanChargesTiers = new list<Product_Rate_Plan_Charge_Tier__c>(); 
        Product_Rate_Plan_Charge_Tier__c productrateplanchargetier = new Product_Rate_Plan_Charge_Tier__c(End_Unit__c = 10,Start_Unit__c= 1,Unit_Price__c = 100, Product_Rate_Plan_Charge__c = listProductRatePlanCharges[0].Id);
        Product_Rate_Plan_Charge_Tier__c productrateplanchargetier1 = new Product_Rate_Plan_Charge_Tier__c(End_Unit__c = 20,Start_Unit__c= 11,Unit_Price__c = 50, Product_Rate_Plan_Charge__c = listProductRatePlanCharges[0].Id);
        Product_Rate_Plan_Charge_Tier__c productrateplanchargetier2 = new Product_Rate_Plan_Charge_Tier__c(End_Unit__c = 30,Start_Unit__c= 21,Unit_Price__c = 90, Product_Rate_Plan_Charge__c = listProductRatePlanCharges[1].Id);
        Product_Rate_Plan_Charge_Tier__c productrateplanchargetier4 = new Product_Rate_Plan_Charge_Tier__c(End_Unit__c =1 ,Start_Unit__c= 10,Unit_Price__c = 30, Product_Rate_Plan_Charge__c = listProductRatePlanCharges[1].Id);
        Product_Rate_Plan_Charge_Tier__c productrateplanchargetier3 = new Product_Rate_Plan_Charge_Tier__c(End_Unit__c = 20,Start_Unit__c= -1,Unit_Price__c = 30, Product_Rate_Plan_Charge__c = listProductRatePlanCharges[2].Id);
        Product_Rate_Plan_Charge_Tier__c productrateplanchargetier5 = new Product_Rate_Plan_Charge_Tier__c(End_Unit__c =1 ,Start_Unit__c= 10,Unit_Price__c = 30, Product_Rate_Plan_Charge__c = listProductRatePlanCharges[2].Id);
        
        listProductRatePlanChargesTiers.add(productrateplanchargetier);
        listProductRatePlanChargesTiers.add(productrateplanchargetier1);
        listProductRatePlanChargesTiers.add(productrateplanchargetier2);
        listProductRatePlanChargesTiers.add(productrateplanchargetier3);
        listProductRatePlanChargesTiers.add(productrateplanchargetier4);
        listProductRatePlanChargesTiers.add(productrateplanchargetier5);
        insert listProductRatePlanChargesTiers;

        ApexPages.Standardcontroller controller1 = new Apexpages.Standardcontroller(product);
        CreateProductsController createProductsController = new CreateProductsController(controller1);
        createProductsController.newRatePlanCharge();

        system.currentPageReference().getParameters().put('productrateplanchargeCounterfortier','1');
        createProductsController.addTier();
        createProductsController.newTier(); 
        createProductsController.saveAndClosePopup();

        system.currentPageReference().getParameters().put('productrateplanidtodelete',listofProductRatePlan[3].id);
        system.currentPageReference().getParameters().put('productrateplancountertodelete','1');
        createProductsController.removeRatePlan();

        system.currentPageReference().getParameters().put('productrateplanchargeidtodelete',listProductRatePlanCharges[3].id);
        system.currentPageReference().getParameters().put('productrateplanchargecountertodelete','1');
        createProductsController.saveProduct();
        createProductsController.saveAndClosePopup();
        createProductsController1.newTier();     
        
        system.currentPageReference().getParameters().put('ratePlanCounter','1');
        createProductsController.onClickRatePlan();
        createProductsController.newRatePlan();
        createProductsController.newRatePlanCharge();
        createProductsController.newRatePlan();
        createProductsController.newRatePlanCharge();
        createProductsController.newRatePlan();
        system.currentPageReference().getParameters().put('rateplanchargecounterfromcharges','10');
        createProductsController.removeRatePlanCharges(); 

        system.currentPageReference().getParameters().put('tieridtodelete',listProductRatePlanChargesTiers[0].id);
        system.currentPageReference().getParameters().put('tiercountertodelete','1');
        system.currentPageReference().getParameters().put('productRatePlanChargeCounterfromtier','5');
        createProductsController.removeTiers();

        list<ProductRatePlanClass> listOfProductRatePlanClass = createProductsController.productClass.getProductRatePlans();
        createProductsController.saveProduct();
        createProductsController.closePopup();
        createProductsController.cloneProduct();
        createProductsController.saveAndClosePopup();
        
        ApexPages.Standardcontroller controller2 = new Apexpages.Standardcontroller(product);
        CreateProductsController createProductsController2 = new CreateProductsController(controller2);        
        createProductsController2.newTier(); 
        createProductsController2.viewProductNewScreen();
        createProductsController2.saveAndClosePopup();
        createProductsController2.deleteProduct();
             
    }

    static testMethod void createProductsControllerNew() {
        ControllerInsertCustomSettings c = new ControllerInsertCustomSettings();
        c.insertValues();
        list<Configuration__c> objects = new list<Configuration__c>();
        Configuration__c c1 = new Configuration__c(Name = 'NAVIGATION_FOR_PRODUCTRATEPLAN', Field_Type__c = 'Number', Description__c = 'This is used for product rate plan navigation in product page', NUMBER_VALUE__C = 2);
        Configuration__c c2 = new Configuration__c(Name = 'NAVIGATION_FOR_PRODUCTCHARGE', Field_Type__c = 'Number', Description__c = 'This is used for product rate plan charge navigation in product page', NUMBER_VALUE__C = 2);
        
        objects.add(c1);
        objects.add(c2);
        upsert objects;
        
        Currency__c currencyObj = new Currency__c(name = 'GBP', Currency_Symbol__c = '£1');
        insert currencyObj;
        
        Layout_Fields__c layoutFieldsProduct = new  Layout_Fields__c(Name=sPrefix+'Product__c',Selected_Fields__c ='Name-115');
        Layout_Fields__c layoutFieldsProductRateplan = new  Layout_Fields__c(Name=sPrefix+'Product_Rate_Plan__c',Selected_Fields__c ='Name-115');
        Layout_Fields__c layoutFieldsProductCharge = new  Layout_Fields__c(Name=sPrefix+'Product_Rate_Plan_Charge__c',Selected_Fields__c ='Name-115');
        
        insert layoutFieldsProduct;
        insert layoutFieldsProductRateplan;
        insert layoutFieldsProductCharge;
        
        Product__c product = new  Product__c(Name = 'Test Product',Valid_From_Date__c = Date.today(),Valid_To_Date__c = Date.today()+90,
                                          Product_Family__c = 'Default',Product_Code__c = 'Code1', Description__c = 'Product');
        insert  product;

        Product__c product2 = [SELECT Name FROM Product__c WHERE id=:product.id];
        System.assertEquals('Test Product', product2.Name);
        
        list<Product_Rate_Plan__c> listofProductRatePlan = new list<Product_Rate_Plan__c>();
        Product_Rate_Plan__c productRatePlan1 = new  Product_Rate_Plan__c(Name = 'Test ProductRatePlan 1',
                Product__c = product.Id,
                Valid_From_Date__c = Date.today(),
                Valid_To_Date__c = Date.today()+90
        );
        Product_Rate_Plan__c productRatePlan2 = new  Product_Rate_Plan__c(Name = 'Test ProductRatePlan 2',
                Product__c = product.Id,
                Valid_From_Date__c = Date.today(),
                Valid_To_Date__c = Date.today()+90
        );
        Product_Rate_Plan__c productRatePlan3 = new  Product_Rate_Plan__c(Name = 'Test ProductRatePlan 3',
                Product__c = product.Id,
                Valid_From_Date__c = Date.today(),
                Valid_To_Date__c = Date.today()+90
        );
        Product_Rate_Plan__c productRatePlan4 = new  Product_Rate_Plan__c(Name = 'Test ProductRatePlan 4',
                Product__c = product.Id,
                Valid_From_Date__c = Date.today(),
                Valid_To_Date__c = Date.today()+90
        );
        listofProductRatePlan.add(productRatePlan1);
        listofProductRatePlan.add(productRatePlan2);
        listofProductRatePlan.add(productRatePlan3);
        listofProductRatePlan.add(productRatePlan4);
        insert listofProductRatePlan;

        list<Product_Rate_Plan_Charge__c> listProductRatePlanCharges = new list<Product_Rate_Plan_Charge__c>();       
        Product_Rate_Plan_Charge__c productRatePlanCharge1 = new Product_Rate_Plan_Charge__c(Name = 'Setup Charges',
                CurrencyL__c = currencyObj.Id,
                Product_Rate_Plan__c = listofProductRatePlan[0].Id,
                Unit_Price__c = 1000,
                Cost_Price__c = 500,                                                                  
                Price_Type__c = 'One Time',
                Price_Format__c = 'Flat Fee Pricing'       
        );

        Product_Rate_Plan_Charge__c productRatePlanCharge2 = new Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                CurrencyL__c = currencyObj.Id,
                Product_Rate_Plan__c = listofProductRatePlan[0].Id,
                Unit_Price__c = 1000,
                Cost_Price__c = 500,                                                                  
                Price_Type__c = 'Monthly' ,
                Price_Format__c = 'Flat Fee Pricing'      
        );
        Product_Rate_Plan_Charge__c productRatePlanCharge3 = new Product_Rate_Plan_Charge__c(Name = 'Setup Charges',
                CurrencyL__c = currencyObj.Id,
                Product_Rate_Plan__c = listofProductRatePlan[0].Id,
                Unit_Price__c = 1000,
                Cost_Price__c = 500,                                                                  
                Price_Type__c = 'One Time',
                Price_Format__c = 'Flat Fee Pricing'     
        );

        Product_Rate_Plan_Charge__c productRatePlanCharge4 = new Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                CurrencyL__c = currencyObj.Id,
                Product_Rate_Plan__c = listofProductRatePlan[0].Id,
                Unit_Price__c = 1000,
                Cost_Price__c = 500,                                                                  
                Price_Type__c = 'Monthly',
                Price_Format__c = 'Flat Fee Pricing'       
        );
        listProductRatePlanCharges.add(productRatePlanCharge1);
        listProductRatePlanCharges.add(productRatePlanCharge2);
        listProductRatePlanCharges.add(productRatePlanCharge3);
        listProductRatePlanCharges.add(productRatePlanCharge4);
        insert listProductRatePlanCharges;

        list<Product_Rate_Plan_Charge_Tier__c> listProductRatePlanChargesTiers = new list<Product_Rate_Plan_Charge_Tier__c>(); 
        Product_Rate_Plan_Charge_Tier__c productrateplanchargetier = new Product_Rate_Plan_Charge_Tier__c(End_Unit__c = 10,Start_Unit__c= 1,Unit_Price__c = 100, Product_Rate_Plan_Charge__c = listProductRatePlanCharges[0].Id);
        Product_Rate_Plan_Charge_Tier__c productrateplanchargetier1 = new Product_Rate_Plan_Charge_Tier__c(End_Unit__c = 20,Start_Unit__c= 11,Unit_Price__c = 50, Product_Rate_Plan_Charge__c = listProductRatePlanCharges[0].Id);
        Product_Rate_Plan_Charge_Tier__c productrateplanchargetier2 = new Product_Rate_Plan_Charge_Tier__c(End_Unit__c = 30,Start_Unit__c= 21,Unit_Price__c = 90, Product_Rate_Plan_Charge__c = listProductRatePlanCharges[1].Id);
        Product_Rate_Plan_Charge_Tier__c productrateplanchargetier4 = new Product_Rate_Plan_Charge_Tier__c(End_Unit__c =1 ,Start_Unit__c= 10,Unit_Price__c = 30, Product_Rate_Plan_Charge__c = listProductRatePlanCharges[1].Id);
        Product_Rate_Plan_Charge_Tier__c productrateplanchargetier3 = new Product_Rate_Plan_Charge_Tier__c(End_Unit__c = 20,Start_Unit__c= -1,Unit_Price__c = 30, Product_Rate_Plan_Charge__c = listProductRatePlanCharges[2].Id);
        Product_Rate_Plan_Charge_Tier__c productrateplanchargetier5 = new Product_Rate_Plan_Charge_Tier__c(End_Unit__c =1 ,Start_Unit__c= 10,Unit_Price__c = 30, Product_Rate_Plan_Charge__c = listProductRatePlanCharges[2].Id);
        
        listProductRatePlanChargesTiers.add(productrateplanchargetier);
        listProductRatePlanChargesTiers.add(productrateplanchargetier1);
        listProductRatePlanChargesTiers.add(productrateplanchargetier2);
        listProductRatePlanChargesTiers.add(productrateplanchargetier3);
        listProductRatePlanChargesTiers.add(productrateplanchargetier4);
        listProductRatePlanChargesTiers.add(productrateplanchargetier5);
        insert listProductRatePlanChargesTiers;

        ApexPages.Standardcontroller stdController = new Apexpages.Standardcontroller(product);
        CreateProductsControllerNew createProductsController = new CreateProductsControllerNew(stdController); 
        
        createProductsController.firstCharges();
        createProductsController.nextCharges();
        createProductsController.previousCharges();
        createProductsController.lastCharges();
        
        createProductsController.first();
        createProductsController.next();
        createProductsController.previous();
        createProductsController.last(); 
        
        createProductsController.editProduct();
        createProductsController.closeProductPopup();
        createProductsController.updateProduct();
        createProductsController.saveProduct();

        createProductsController.newRatePlan();
        createProductsController.saveClonedRatePlan();
        
        system.currentPageReference().getParameters().put('ratePlanCounter', '1');
        createProductsController.editRatePlan();
        createProductsController.saveRatePlan();
        
        system.currentPageReference().getParameters().put('cloneRatePlan',ProductCreationUtil.CLONE_RATEPLAN);
        createProductsController.cloneRatePlan();
        createProductsController.cloneRatePlanPopup();
        createProductsController.saveClonedRatePlan();
        createProductsController.closeRatePlanPopup();
        system.currentPageReference().getParameters().put('cloneRatePlan',ProductCreationUtil.CLONE_WITH_CHARGES);
        createProductsController.cloneRatePlan();
        createProductsController.cloneProduct();
        createProductsController.saveClonedProduct();
        createProductsController.saveClonedRatePlan();
        
        createProductsController.newCharge();
        createProductsController.saveCharge();
        createProductsController.closeChargePopup();
        
        system.currentPageReference().getParameters().put('chargeCounter','15');
        createProductsController.editCharges();
        createProductsController.saveCharge();
        
        createProductsController.closeOptionPopup();
        createProductsController.closeChargeOptionPopup();
        createProductsController.updateRateplan();

        system.currentPageReference().getParameters().put('tieridtodelete',listProductRatePlanChargesTiers[1].id);
        system.currentPageReference().getParameters().put('tiercountertodelete','1');
        system.currentPageReference().getParameters().put('productRatePlanChargeCounterfromtier','5');
        createProductsController.removeTiers();
        
        Id productrateplanidtodelete;
        Id chargeidtodelete;
        ProductClass productClass = createProductsController.productClass ;
        for(ProductRatePlanClass prpclass : productClass.productRatePlans) {   
            if(prpclass.productRatePlanCounter == 1) {
                productrateplanidtodelete = prpclass.productRatePlan.Id;
            }
            for(ProductRatePlanChargeClass  prpChargeClass : prpclass.productRatePlanChargeClass) {
                   if(chargeidtodelete == null) {
                    chargeidtodelete = prpChargeClass.productRatePlancharge.Id;
                    break;
                   }
                }        
        } 
        
        system.currentPageReference().getParameters().put('cloneCharge','CloneCharge');
        createProductsController.cloneCharge();

        system.currentPageReference().getParameters().put('chargeName','Monthly Charges');
        system.currentPageReference().getParameters().put('chargeCloneCounter','15');
        createProductsController.cloneChargesPopup();
        createProductsController.newTier(); 
        createProductsController.cloneCharge();
        createProductsController.saveClonedCharge();

        system.currentPageReference().getParameters().put('cloneCharge','CloneWithTiers');
        createProductsController.cloneCharge();
        createProductsController.saveClonedCharge();
        
        createProductsController.closeCloneChargePopup();
        createProductsController.closeSelectedChargesPopup();
        system.currentPageReference().getParameters().put('editSelected','editSelected');
        createProductsController.editSelectedCharges();
        createProductsController.onChangePriceFormat();
        
         system.currentPageReference().getParameters().put('chargeCounter','1');
        createProductsController.editCharges();
        
        createProductsController.newTier();
        createProductsController.onSelectAll();
        
        system.currentPageReference().getParameters().put('chargeidtodelete',listProductRatePlanCharges[3].id);
        system.currentPageReference().getParameters().put('chargecountertodelete','1');
        system.currentPageReference().getParameters().put('rateplancountertodelete','3');
        createProductsController.removeRatePlanCharges();
           
        system.currentPageReference().getParameters().put('ratePlanId',productrateplanidtodelete);
        system.currentPageReference().getParameters().put('counterForRatePlan','1');
        createProductsController.onClickRatePlan();
        
        system.currentPageReference().getParameters().put('Name','Charge1');
        system.currentPageReference().getParameters().put('selectedCurrency','GBP');
        system.currentPageReference().getParameters().put('selectedPriceType',ProductCreationUtil.PRICE_FORMAT_VOLUME);
        createProductsController.filterCharges();
        
        system.currentPageReference().getParameters().put('Name','');
        createProductsController.filterCharges();
        
        system.currentPageReference().getParameters().put('RatePlanName','Charge1');
        createProductsController.filterRatePlan();
        
        system.currentPageReference().getParameters().put('RatePlanName','');
        createProductsController.filterRatePlan();
        
        createProductsController.saveProductLayout();
        createProductsController.saveRatePlanLayout();
        createProductsController.saveChargesLayout();
        
        system.Test.StartTest();
        
        ApexPages.Standardcontroller stdController1 = new Apexpages.Standardcontroller(product);
        CreateProductsControllerNew createProductsController1 = new CreateProductsControllerNew(stdController1);
        
        productClass = createProductsController1.productClass ;
        for(ProductRatePlanClass prpclass : productClass.productRatePlans) {   
            if(prpclass.productRatePlanCounter == 1) {
                productrateplanidtodelete = prpclass.productRatePlan.Id;
            } 
            for(ProductRatePlanChargeClass  prpChargeClass : prpclass.productRatePlanChargeClass) {
               if(chargeidtodelete == null) {
                chargeidtodelete = prpChargeClass.productRatePlancharge.Id;
                break;
               }
            }   
        }
        system.currentPageReference().getParameters().put('ratePlanId',productrateplanidtodelete);
        system.currentPageReference().getParameters().put('counterForRatePlan','1');
        createProductsController.onClickRatePlan();
        
        system.currentPageReference().getParameters().put('productrateplanidtodelete',productrateplanidtodelete);
        system.currentPageReference().getParameters().put('productrateplancountertodelete','1');
        createProductsController.removeRatePlan();
        
        Product__c productObj = new  Product__c(Name = 'Test Product',Valid_From_Date__c = Date.today(),Valid_To_Date__c = Date.today()+90,
                                          Product_Family__c = 'Default',Product_Code__c = 'Code1', Description__c = 'Product');
        insert  productObj;
        
        // exception coverage
        ApexPages.Standardcontroller stdController2 = new Apexpages.Standardcontroller(productObj);
        CreateProductsControllerNew createProductsController2 = new CreateProductsControllerNew(stdController1);
        
        createProductsController2.filterCharges();
        createProductsController2.filterRatePlan();
        createProductsController2.saveClonedRatePlan();
        createProductsController2.saveClonedProduct();
        createProductsController2.saveRatePlan();
        createProductsController2.saveCharge();
        createProductsController2.saveProductLayout();
        createProductsController2.saveRatePlanLayout();
        createProductsController2.saveChargesLayout();
        createProductsController2.saveClonedCharge();
        createProductsController2.intilizeRatePlans();
        createProductsController2.intilizeCharges();
        createProductsController2.editChargesLayout();
        createProductsController2.closeRatePlanLayout();
        createProductsController2.editRatePlanLayout();
        createProductsController2.closeChargesLayout();
        createProductsController2.closeProductLayout();
        createProductsController2.editProductLayout();
        
        system.Test.stopTest(); 
        
        createProductsController.deleteProduct();
        
        CreateProductsControllerNew.getProductDetails(product.id);
        CreateProductsControllerNew.getProductRatePlan(listofProductRatePlan.get(0).id);
        CreateProductsControllerNew.getChargeTiers(listProductRatePlanCharges.get(0).id);

    }
    
}