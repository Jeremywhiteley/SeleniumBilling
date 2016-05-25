@isTest
    private with sharing class TestCreateQuoteController {

        static testMethod void testCreateQuoteController() {
        
        ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
        ControllerInsertCustomSettings.insertValues();
        
        list<Tax_Rate__c> listOfTaxAndVatRates = new list<Tax_Rate__c>();
        listOfTaxAndVatRates.add(new Tax_Rate__c(Tax_VAT__c = 'Tax', Country__c = 'Canada', State__c = 'Prince Edward Island',City__c = '*', Product_Charge_Category__c = 'Taxable', Rate__c = 10, Priority__c = '1'));
        listOfTaxAndVatRates.add(new Tax_Rate__c(Tax_VAT__c = 'Tax', Country__c = 'Canada', State__c = 'Prince Edward Island',City__c = '*', Product_Charge_Category__c = 'Taxable', Rate__c = 5, Priority__c = '2'));
        listOfTaxAndVatRates.add(new Tax_Rate__c(Tax_VAT__c = 'VAT', Country__c = 'Canada', State__c = 'Prince Edward Island',City__c = '*', Product_Charge_Category__c = 'Taxable', Rate__c = 10));
        listOfTaxAndVatRates.add(new Tax_Rate__c(Tax_VAT__c = 'VAT', Country__c = 'Canada', State__c = 'Prince Edward Island',City__c = '*', Product_Charge_Category__c = 'Taxable', Rate__c = 10));
        listOfTaxAndVatRates.add(new Tax_Rate__c(Tax_VAT__c = 'VAT', Country__c = 'Canada', State__c = 'Prince Edward Island',City__c = '*', Product_Charge_Category__c = 'Taxable', Rate__c = 10, Priority__c = '1'));
        listOfTaxAndVatRates.add(new Tax_Rate__c(Tax_VAT__c = 'VAT', Country__c = 'Canada', State__c = 'Prince Edward Island',City__c = '*', Product_Charge_Category__c = 'Taxable', Rate__c = 10, Priority__c = '2'));
        insert listOfTaxAndVatRates;
                                                
        list<Product_Catalog_Filter_Criteria__c> listFilters = new list<Product_Catalog_Filter_Criteria__c>();
        listFilters.add(new Product_Catalog_Filter_Criteria__c(Destination_Field__c = 'CurrencyL__c',Destination_Object__c = 'Product_Rate_Plan_Charge__c',Source_Field__c = 'CurrencyL__c',Source_Object__c = 'Job__c', Name = 'a1'));
        listFilters.add(new Product_Catalog_Filter_Criteria__c(Destination_Field__c = 'CurrencyL__c',Destination_Object__c = 'Product_Rate_Plan_Charge__c',Source_Field__c = 'CurrencyL__c',Source_Object__c = 'Quote__c', Name = 'a2'));
        listFilters.add(new Product_Catalog_Filter_Criteria__c(Destination_Field__c = 'Name',Destination_Object__c = 'Product__c',Source_Field__c = 'Name',Source_Object__c = 'Job__c', Name = 'a3'));
        listFilters.add(new Product_Catalog_Filter_Criteria__c(Destination_Field__c = 'Name',Destination_Object__c = 'Product__c',Source_Field__c = 'Name',Source_Object__c = 'Quote__c', Name = 'a4'));
        insert listFilters;
        
        list<Custom_Mappings__c> listCustomMapping = new list<Custom_Mappings__c>();
        listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = 'Name',Destination_Object__c = 'Quote_Rate_Plan__c',Source_Field__c = 'Name',Source_Object__c = 'Product_Rate_Plan__c', Name = 'q1'));
        listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = 'Name',Destination_Object__c = 'Quote_Rate_Plan_Charge__c',Source_Field__c = 'Name',Source_Object__c = 'Product_Rate_Plan_Charge__c', Name = 'q2'));
        listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = 'Name',Destination_Object__c = 'Quote_Product__c',Source_Field__c = 'Name',Source_Object__c = 'Product__c', Name = 'q3'));
        listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = 'Name',Destination_Object__c = 'Job_Rate_Plan__c',Source_Field__c = 'Name',Source_Object__c = 'Product_Rate_Plan__c', Name = 'a1'));
        listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = 'Name',Destination_Object__c = 'Job_Rate_Plan_Charge__c',Source_Field__c = 'Name',Source_Object__c = 'Product_Rate_Plan_Charge__c', Name = 'a2'));
        listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = 'Name',Destination_Object__c = 'Job_Product__c',Source_Field__c = 'Name',Source_Object__c = 'Product__c', Name = 'a3'));
        insert listCustomMapping;
        
        Date validtodate = Date.today();   
        list<Product__c> listProducts = new list<Product__c>();
        Product__c product;
        for(Integer x = 0;x < 1;x++){
          product = new  Product__c(Name = 'Test Product' + x,Valid_From_Date__c = validtodate,Valid_To_Date__c = validtodate,Product_Family__c = 'Default',Product_Code__c = 'Code1',Description__c = 'Product');
          listProducts.add(product);
        }  
        
        Product__c productTiers = new  Product__c(Name = 'Test Product for tiers',Valid_From_Date__c = validtodate,Valid_To_Date__c = validtodate,Product_Family__c = 'Default',Product_Code__c = 'Code1',Description__c = 'Product');  
        listProducts.add(productTiers);
        insert listProducts;
        
        list<Product_Rate_Plan__c> listProductRatePlans = new list<Product_Rate_Plan__c>();
        Product_Rate_Plan__c productRatePlan;
        for(Integer x = 0;x< 1;x++){
          productRatePlan = new  Product_Rate_Plan__c(  Name = 'Test ProductRatePlan' + x,
                                                        Product__c = listProducts.get(x).Id,
                                                        Valid_From_Date__c = validtodate,Valid_To_Date__c = validtodate);
          listProductRatePlans.add(productRatePlan);
        }
        
        Product_Rate_Plan__c productRatePlanTiers = new Product_Rate_Plan__c(Name = 'Test ProductRatePlan tiers',
                                                        Product__c = listProducts.get(1).Id,
                                                        Valid_From_Date__c = validtodate,Valid_To_Date__c = validtodate);
        
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
        
        Account account = new Account(name = 'Test Account');
        insert account;
        
        list<Contact> listContacts = new list<Contact>();
        listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK'));
        listContacts.add(new Contact(LastName = 'Manoj GanPathy',accountId = account.Id, MailingCountry = 'Canada',MailingState = 'Prince Edward Island'));
        listContacts.add(new Contact(LastName = 'Anil',accountId = account.Id, MailingCountry = 'USA',MailingPostalCode = '60001'));
        listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA', MailingPostalCode = '60001'));  
        insert listContacts;
        
        Quote__c quote1 = new Quote__c(Name = 'Test quote1',CurrencyL__c = listCurrencys.get(0).Id,Number_Of_Terms__c = 24,
                                       Start_Date__c = validtodate);
        
        quote1.Account__c = account.Id;
        ApexPages.Standardcontroller controller = new Apexpages.Standardcontroller(quote1);
        CreateQuoteController createQuoteController = new CreateQuoteController(controller);
        
        quote1.Start_Date__c = validtodate;
        quote1.Valid_To__c = validtodate;
        quote1.Billing_Contact__c = listContacts.get(1).Id;
        quote1.Shipping_Contact__c = listContacts.get(1).Id;
        
        createQuoteController.changeCurrencySelection();
        
        //Move to the first page
        createQuoteController.step1();
        
        //Move to the second page
        createQuoteController.step2();
        
        //Assign default currency
        quote1.CurrencyL__c =  listCurrencys.get(0).Id;
        
        //Set the Product id and name,so that we can fetch Product Rate Plans
        system.currentPageReference().getParameters().put('productId',listProducts.get(0).Id);
        system.currentPageReference().getParameters().put('productName',listProducts.get(0).name);
        createQuoteController.getRatePlansForProduct();
        
        system.currentPageReference().getParameters().put('ratePlanId',listProductRatePlans.get(0).Id);
        system.currentPageReference().getParameters().put('rateplanName',listProductRatePlans.get(0).name);
        createQuoteController.getRatePlanChargesForRatePlan();
        
        //tiers logic
        system.currentPageReference().getParameters().put('productId',listProducts.get(1).Id);
        system.currentPageReference().getParameters().put('productName',listProducts.get(1).name);
        createQuoteController.getRatePlansForProduct();
        
        system.currentPageReference().getParameters().put('ratePlanId',productRatePlanTiers.Id);
        system.currentPageReference().getParameters().put('rateplanName',productRatePlanTiers.name);
        createQuoteController.getRatePlanChargesForRatePlan();
        Quote__c q = createQuoteController.quoteClass.getquote();
        list<QuoteProductClass> quoteProducts = createQuoteController.quoteClass.getQuoteProducts();
        list<QuoteRatePlanClass> quoteRatePlans = createQuoteController.quoteProductClass.getQuoteRatePlans();
        list<QuoteRatePlanChargeClass> quoteRatePlanCharges = createQuoteController.QuoteRatePlanClass.getQuoteRatePlanCharges();
        list<QuoteRatePlanChargeTierClass> quoteTiers = quoteRatePlanCharges[0].getQuoteRatePlanChargeTiers();
        
        //Remove the Product rate plan charge
        system.currentPageReference().getParameters().put('quoterateplancounter','0');
        system.currentPageReference().getParameters().put('quoteRatePlanId',CreateQuoteController.quoteRatePlanClass.quoterateplan.id);
        system.currentPageReference().getParameters().put('productBundleId', '');
        CreateQuoteController.removeQuotes();
       
        createQuoteController.step3();
        
        createQuoteController.quoteClass.quote.Discount_Value__c = 100;
        createQuoteController.chargeCalculator();
        
        createQuoteController.quoteClass.quote.Discount_Value__c = 100;
        createQuoteController.chargeCalculator();
        
        createQuoteController.quoteClass.quote.Discount_Value__c = 100;
        createQuoteController.chargeCalculator();
        
        //createQuoteController.quoteClass.quote.Discount_Value__c = 100;
        //createQuoteController.applyDiscountValueToCharges();
        
        createQuoteController.quoteClass.quote.Discount_Percent__c = 10;
        createQuoteController.applyDiscountPercentToCharges();
        
        createQuoteController.quote.Discount_Code__c = 'man';
        createQuoteController.applyDiscountCode();
        
        list<Discount_Code__c> discounts = new  list<Discount_Code__c>();
        Discount_Code__c d = new Discount_Code__c(Name = 'san', Valid_From__c = system.today(), Price_Type__c = '*', Discount_Value__c = 20, Apply_to__c = 'Charge level',
                                                  Currency__c = createQuoteController.quote.CurrencyL__c, Product_Family__c = '*');
        discounts.add(d);       
        
        Discount_Code__c d2 = new Discount_Code__c(Name = 'san2', Valid_From__c = system.today(), Price_Type__c = '*', Discount_Percent__c = 10, Apply_to__c = 'Charge level',
                                                  Currency__c = createQuoteController.quote.CurrencyL__c, Product_Family__c = '*');                               
        discounts.add(d2);  
        
        Discount_Code__c d3 = new Discount_Code__c(Name = 'san3', Valid_From__c = system.today(), Price_Type__c = '*', Discount_Value__c = 10, Apply_to__c = 'Quote/Order level',
                                                  Currency__c = createQuoteController.quote.CurrencyL__c, Product_Family__c = '*');                               
        discounts.add(d3);
        
        Discount_Code__c d4 = new Discount_Code__c(Name = 'san4', Valid_From__c = system.today(), Price_Type__c = '*', Discount_Percent__c = 10, Apply_to__c = 'Quote/Order level',
                                                  Currency__c = createQuoteController.quote.CurrencyL__c, Product_Family__c = '*');                               
        discounts.add(d4);
        
        insert discounts;
        
        createQuoteController.quote.Discount_Code__c = 'san';
        createQuoteController.applyDiscountCode();
        
        createQuoteController.quote.Discount_Code__c = 'san2';
        createQuoteController.applyDiscountCode();
        
        createQuoteController.quote.Discount_Code__c = 'san3';
        createQuoteController.applyDiscountCode();
        
        createQuoteController.quote.Discount_Code__c = 'san4';
        createQuoteController.applyDiscountCode();
        
        //Save the quote
        createQuoteController.addQuoteCharges();
        createQuoteController.saveQuote();
        createQuoteController.getCurreciesOptions();
        
        for(QuoteProductClass qpc : createQuoteController.quoteClass.quoteProducts) {
            for(QuoteRatePlanClass qrc : qpc.quoteRatePlans) { 
                for(QuoteRatePlanChargeClass qrpc :qrc.quoteRatePlanCharges) {
                    if(qrpc.quoteRatePlanCharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME) {
                        system.currentPageReference().getParameters().put('quoteRatePlanChargeCounterForTier', string.ValueOf(qrpc.quoteRatePlanChargeCounter));
                        createQuoteController.showPopup();
                        createQuoteController.newTier();
                        string tierId = qrpc.quoteRatePlanChargeTiers[0].quoteRatePlanChargeTier.Id;
                        system.currentPageReference().getParameters().put('quoteTierIdToDelete', tierId);
                        system.currentPageReference().getParameters().put('quoteTierCountertoDelete', '1');
                        system.currentPageReference().getParameters().put('quoteRatePlanChargeCounterForTier', string.ValueOf(qrpc.quoteRatePlanChargeCounter));
                        createQuoteController.removeTier();
                        createQuoteController.closePopup();
                        
                        qrpc.quoteRatePlanCharge.Quantity__c = 60;
                        QuoteCreationUtil.tieredPricing(qrpc);
                        qrpc.quoteRatePlanCharge.Quantity__c = 0;
                        QuoteCreationUtil.tieredPricing(qrpc);
                        break;
                    }
                }
            }
        }
            
        //clone the quote
        createQuoteController.cloneQuote();
        createQuoteController.cloneQuoteWithDifferentCurrency();
        
        Quote_Product__c jobprod = new Quote_Product__c(Name = 'QuoteProduct',Quote__c = quote1.id,Product_Code__c = 'code1',Product_Family__c = 'Default',Description__c = 'Quote Product');
        insert jobprod;    
        Quote_Rate_Plan__c jobRatePlan = new Quote_Rate_Plan__c(Quote_Product__c = jobprod.id);
        insert jobRatePlan;   
        QuoteCreationUtil.getquoteRatePlanToDelete(jobRatePlan.Id);
        
        //Used for calling in edit mode
        quote1.CurrencyL__c = null;
        ApexPages.Standardcontroller controller3 = new Apexpages.Standardcontroller(quote1);
        createQuoteController CreateQuoteController3 = new CreateQuoteController(controller3);
        createQuoteController3.convertQuote();
        createQuoteController3.convertQuote();
        createQuoteController3.save();
        
         ClassQuoteProductsInlineAJS classQuoteProductsInlineAJSobj = new ClassQuoteProductsInlineAJS(controller3);
         
        Quote__c quote2 = [SELECT Id, Name, Account__c, CurrencyL__c
                            FROM Quote__c
                            WHERE  Name = 'Test quote1' LIMIT 1];
        quote2.Number_Of_Terms__c = 45;
        update quote2;                     
        system.assert(quote2.Name == 'Test quote1');           
        
        //this code is for testing the quote clone functionality
        ApexPages.Standardcontroller stdControllerCloneQuote = new Apexpages.Standardcontroller(quote1);
        createQuoteController createQuoteControllerCloneQuote = new CreateQuoteController(stdControllerCloneQuote);
        createQuoteControllerCloneQuote.cloneQuote();
        
        //This code is for testing the email service class
        ClassQuoteEmailHandler classQuoteEmailHandler = new ClassQuoteEmailHandler();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'Your quote (' + quote2.id + ')';
        email.fromAddress = 'laxmanrao.564@gmail.com';
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        classQuoteEmailHandler.handleInboundEmail(email, envelope);
        
        Quote__c newQuoteToClone = quote2.clone(false);
        insert newQuoteToClone;
        email.subject = 'Your quote (' + newQuoteToClone.id + ')';
        classQuoteEmailHandler.handleInboundEmail(email, envelope);
        
        //this is the code for testing the webservice
        ClassWebServiceEmailing.sendQuote(quote2.Id);
        
        //this is the code for testing the ControllerInsertOptionalExtra
        ApexPages.Standardcontroller standardController = new Apexpages.Standardcontroller(quote1);
        ControllerInsertOptionalExtra controllerInsertOptional = new ControllerInsertOptionalExtra(standardController);
        
        system.currentPageReference().getParameters().put('productId',listProducts.get(0).Id);
        system.currentPageReference().getParameters().put('productName',listProducts.get(0).name);
        createQuoteController.getRatePlansForProduct();
        controllerInsertOptional.getRatePlansForProduct();
        
        system.currentPageReference().getParameters().put('ratePlanId',listProductRatePlans.get(0).Id);
        system.currentPageReference().getParameters().put('rateplanName',listProductRatePlans.get(0).name);
        controllerInsertOptional.getRatePlanChargesForRatePlan();
        
        system.currentPageReference().getParameters().put('ratePlanId',listProductRatePlans.get(0).Id);
        system.currentPageReference().getParameters().put('rateplanName',listProductRatePlans.get(0).name);
        controllerInsertOptional.getRatePlanChargesForRatePlan();
        
        system.currentPageReference().getParameters().put('ratePlanChargeId',listProductRatePlans.get(0).Id);
        controllerInsertOptional.removeCharges();
        
        controllerInsertOptional.insertOptionalExtras();
        controllerInsertOptional.listSelectedProductRatePlanCharges = listProductRatePlanCharges; 
        controllerInsertOptional.insertOptionalExtras();
        
        system.Test.startTest();
        ControllerSendQuote controllerSendQuote = new ControllerSendQuote(standardController);
        
        
        //cover the util methods
        QuoteCreationUtil.getProductRatePlanCharges(null,null, null);
        QuoteCreationUtil.getListOfOptionalExtrasForQuote(quote2.Id);
        QuoteCreationUtil.getProductRatePlanFromList(null, null);
        
        //below lines will cover  calculateQuoteChargeLineAmount
        Quote_Rate_Plan_Charge__c charge1 = new Quote_Rate_Plan_Charge__c(Price_Type__c = system.Label.OptionWeekly, Unit_Price__c = 100, Quantity__c = 1, Net_Total__c = 1000);
        //QuoteCreationUtil.calculateQuoteChargeLineAmount(charge1, 12);   
        charge1.Price_Type__c = system.Label.OptionOneTime;
        QuoteCreationUtil.calculateQuoteChargeLineAmount(charge1, system.today(), system.today().addMonths(24));
        charge1.Price_Type__c = system.Label.OptionMonthly;
        QuoteCreationUtil.calculateQuoteChargeLineAmount(charge1, system.today(), system.today().addMonths(36));
        charge1.Price_Type__c = system.Label.OptionQuarterly;
        QuoteCreationUtil.calculateQuoteChargeLineAmount(charge1, system.today(), system.today().addMonths(36));
        charge1.Price_Type__c = system.Label.OptionHalfYearly;
        QuoteCreationUtil.calculateQuoteChargeLineAmount(charge1, system.today(), system.today().addMonths(36));
        charge1.Price_Type__c = system.Label.OptionAnnual;
        
        QuoteCreationUtil.calculateQuoteChargeLineAmount(charge1, system.today(), system.today().addMonths(36));
        
        Quote__c quoteObj = new Quote__c();
        quoteObj = [SELECT Id FROM Quote__c  where id =: quote2.Id];
        quoteObj.Recalculate__c = false;
        upsert quoteObj;
        system.Test.stopTest();
        
        
        } 
        
        static testMethod void testCreateQuoteController1() {
        
        ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
        ControllerInsertCustomSettings.insertValues();
        // Negative Test Class
        
            Account testAccount = new Account(name='testAccount');
            insert testAccount;
            
            system.assert(testAccount.Name == 'testAccount'); 
            
            Contact con = new Contact(lastname = 'testname',AccountId = testAccount.id);
            insert con;
            
            Currency__c currency1 = new Currency__c(name = 'GKP', Symbol__c = '$');
            insert currency1;
            
            Product__c productObj = new Product__c();
            Product_Rate_Plan__c prateplan = new Product_Rate_Plan__c(Product__c = productObj.Id);
            Product_Rate_Plan_Charge__c prateplancharge = new Product_Rate_Plan_Charge__c(Product_Rate_Plan__c = prateplan.Id,CurrencyL__c = currency1.Id);
            
            Quote__c quote = new Quote__c(Account__c = testAccount.Id,CurrencyL__c = currency1.Id);
            
            ApexPages.StandardController stdController = new Apexpages.Standardcontroller(quote);
            CreateQuoteController createQuoteControllerobj = new CreateQuoteController(stdController);
            
            createQuoteControllerobj.selectedRatePlanId = 'null';
            system.currentPageReference().getParameters().put('productId','product.Id');
            system.currentPageReference().getParameters().put('productName','product1');
            system.currentPageReference().getParameters().put('quoteRatePlanId',quote.Id);
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
            createQuoteControllerobj.chargeCalculator();
            createQuoteControllerobj.save();
            createQuoteControllerobj.cloneQuote();
            createQuoteControllerobj.cloneQuoteWithDifferentCurrency();
            createQuoteControllerobj.convertQuote();
            
            // this code to cover the catch block of ControllerInsertOptionalExtra
            Apexpages.Standardcontroller stdControllerObj = new Apexpages.Standardcontroller(quote);  
            ControllerInsertOptionalExtra controllerInsertOptionalExtraObj = new ControllerInsertOptionalExtra(stdControllerObj);
            controllerInsertOptionalExtraObj.getRatePlansForProduct();
            controllerInsertOptionalExtraObj.getRatePlanChargesForRatePlan();
            controllerInsertOptionalExtraObj.InsertOptionalExtras();
         }   
    }