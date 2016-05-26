//This class contains unit tests for validating the behavior of QuoteChargesCalculator classes and triggers.
         // Created By Asish
    @isTest(oninstall = false)
    private class TestQuoteChargesCalculator {

        static testMethod void ChargesCalculator() {
            map<string, Configuration__c> Configuration = Configuration__c.getAll();
            delete Configuration.values();
            ControllerInsertCustomSettings controllerInsertCustomSettings = new ControllerInsertCustomSettings();
            controllerInsertCustomSettings.insertValues();
            
            Account account = ClassPopulateTestData.createAccount();
            list<Contact> listOfContacts = ClassPopulateTestData.createContacts(account);
            list<Currency__c> listOfCurrencies = ClassPopulateTestData.currencies();
            
             ClassPopulateTestData.createTaxAndVatRates();
            
            list<Product__c> listOfProducts = ClassPopulateTestData.createProduct(); 
            Product__c product = listOfProducts[0];
            
            list<Product_Rate_Plan__c> listOfPlans = ClassPopulateTestData.createProductRatePlan(product);
            list<Product_Rate_Plan_Charge__c>  listOfProductCharges = ClassPopulateTestData.createProductRatePlanCharge(listOfPlans[0],listOfCurrencies[1]);
            ClassPopulateTestData.createTaxAndVatRates();
            
            Quote__c quote = ClassPopulateTestData.createQuote(account,listOfContacts[2],listOfCurrencies[1]);
            
            Quote_Product__c quoteProduct =  new Quote_Product__c(Name = 'Test' , Quote__c = quote.Id,Product__c = product.id);
            insert quoteProduct;

            Quote_Product__c quoteProduct1 = [select Name From Quote_Product__c where id=:quoteProduct.id];
            System.assertEquals('Test', quoteProduct1.Name);
            
            Quote_Rate_Plan__c quotePlan = new Quote_Rate_Plan__c(Name = 'plan test',Quote_Product__c = quoteProduct.id);
            insert quotePlan;
            
            Quote_Rate_Plan_Charge__c quoteCharge = new Quote_Rate_Plan_Charge__c(Name='test Charges',Discount_Value__c  = 10,Quote_Rate_Plan__c = quotePlan.id,Quantity__c = 2,Unit_Price__c = 200,Price_Format__c = 'Percentage Pricing', Discount_Type__c = CommonUtilClass.DISCOUNT_TYPE_VALUE);
            quoteCharge.Percentage_of_other_Charges__c = 1.25;
            insert quoteCharge;
            
            Quote_Rate_Plan_Charge__c quoteCharge1 = new Quote_Rate_Plan_Charge__c(Name='test Charges',Discount_Value__c  = 15,Quote_Rate_Plan__c = quotePlan.id,Quantity__c = 1,Unit_Price__c = 200,Price_Format__c = 'Tiered Pricing');
            //quoteCharge1.Percentage_of_other_Charges__c = 1.25;
            insert quoteCharge1;
            
            Quote_Rate_Plan_Charge__c quoteCharge2 = new Quote_Rate_Plan_Charge__c(Name='test Charges',Discount_Value__c  = 12,Quote_Rate_Plan__c = quotePlan.id,Quantity__c = 1,Unit_Price__c = 200,Price_Format__c = 'Flat Fee Pricing');
            //quoteCharge1.Percentage_of_other_Charges__c = 1.25;
            insert quoteCharge2;
            
            Quote_Rate_Plan_Charge__c quoteCharge3 = new Quote_Rate_Plan_Charge__c(Name='test Charges',Discount_Value__c  = null,Quote_Rate_Plan__c = quotePlan.id,Quantity__c = 1,Unit_Price__c = 200,Price_Format__c = 'Per Unit Pricing');
            //quoteCharge1.Percentage_of_other_Charges__c = 1.25;
            insert quoteCharge3;
            
            Quote_Rate_Plan_Charge_Tier__c tier = new Quote_Rate_Plan_Charge_Tier__c(Start_Unit__c = 1,End_Unit__c=5,Unit_Price__c = 100,Quote_Rate_Plan_Charge__c = quoteCharge.id);
            insert tier;
            
            
            QuoteRatePlanChargeTierClass tierClsObj = new QuoteRatePlanChargeTierClass();
            tierClsObj.quoteRatePlanChargeTier = tier;
            list<QuoteRatePlanChargeTierClass> listofTierClass = new list<QuoteRatePlanChargeTierClass>();
            listofTierClass.add(tierClsObj);
            
            QuoteRatePlanChargeClass chargeClsObj = new QuoteRatePlanChargeClass();
            chargeClsObj.quoterateplancharge = quoteCharge;
            QuoteRatePlanChargeClass chargeClsObj1 = new QuoteRatePlanChargeClass();
            chargeClsObj1.quoterateplancharge = quoteCharge1;
            QuoteRatePlanChargeClass chargeClsObj2 = new QuoteRatePlanChargeClass();
            chargeClsObj2.quoterateplancharge = quoteCharge2;
            QuoteRatePlanChargeClass chargeClsObj3 = new QuoteRatePlanChargeClass();
            chargeClsObj3.quoterateplancharge = quoteCharge3;
            list<QuoteRatePlanChargeClass> listofCharges = new list<QuoteRatePlanChargeClass>();
            listofCharges.add(chargeClsObj);
            listofCharges.add(chargeClsObj1);
            listofCharges.add(chargeClsObj2);
            listofCharges.add(chargeClsObj3);
            chargeClsObj.quoteRatePlanChargeTiers = listofTierClass;
            
            QuoteRatePlanClass planClsObj = new QuoteRatePlanClass();
            planClsObj.quoterateplan = quotePlan;
            list<QuoteRatePlanClass> listOfPlansCls = new list<QuoteRatePlanClass>();
            listOfPlansCls.add(planClsObj);
            planClsObj.quoteRatePlanCharges = listofCharges;
            
            
            QuoteProductClass quoteproductClsObj = new QuoteProductClass();
            quoteproductClsObj.quoteproduct = quoteProduct;
            list<QuoteProductClass> listofProductsCls = new list<QuoteProductClass>();
            listofProductsCls.add(quoteproductClsObj);
            quoteproductClsObj.quoteRatePlans = listOfPlansCls;
            
            
            QuoteClass quoteClsObj = new QuoteClass();
            quoteClsObj.quote = quote;
            quoteClsObj.quoteProducts = listofProductsCls;
            
            QuoteChargesCalculator.calculateCharges(quoteClsObj);
            QuoteChargesCalculator.Charges quoteChargCalObj = new QuoteChargesCalculator.Charges();
            QuoteChargesCalculator.calculateSubtotal(quoteClsObj ,quoteChargCalObj);
            
            Configuration__c automatedCS = Configuration__c.getValues('TAX_CALCULATION_BASED_ON'); 
            automatedCS.String_Value__c = 'Billing Contact';
            update automatedCS;
            
            QuoteChargesCalculator.calculateCharges(quoteClsObj);
            QuoteChargesCalculator.calculateSubtotal(quoteClsObj ,quoteChargCalObj);
            
            //when custom setting It is Shipping Contact
            
            automatedCS.String_Value__c = 'Shipping Contact';
            update automatedCS;
            QuoteChargesCalculator.calculateCharges(quoteClsObj);
            QuoteChargesCalculator.calculateSubtotal(quoteClsObj ,quoteChargCalObj);
            
            Configuration__c automatedCS1 = Configuration__c.getValues('ACCOUNT_LEGAL_ENTITY_FIELD_NAME'); 
            automatedCS1.String_Value__c = 'Name';
            update automatedCS1;
            QuoteChargesCalculator.calculateCharges(quoteClsObj);
            QuoteChargesCalculator.calculateSubtotal(quoteClsObj ,quoteChargCalObj);
            
            Configuration__c automatedCS2 = Configuration__c.getValues('QUOTE_LEGAL_ENTITY_FIELD_NAME'); 
            automatedCS2.String_Value__c = 'Name';
            automatedCS1.String_Value__c = null;
            update automatedCS2;
            update automatedCS1;
            QuoteChargesCalculator.calculateCharges(quoteClsObj);
            QuoteChargesCalculator.calculateSubtotal(quoteClsObj ,quoteChargCalObj);
            
            automatedCS2.String_Value__c = null;
            update automatedCS2;
            QuoteChargesCalculator.calculateCharges(quoteClsObj);
            QuoteChargesCalculator.calculateSubtotal(quoteClsObj ,quoteChargCalObj);
            
            Configuration__c automatedCS3 = Configuration__c.getValues('CALCULATION_PRECISION');
            automatedCS3.String_Value__c = 'ROUND_UP';
            update automatedCS3;
            QuoteChargesCalculator.calculateCharges(quoteClsObj);
            QuoteChargesCalculator.calculateSubtotal(quoteClsObj ,quoteChargCalObj);
            
            Configuration__c automatedCS4 = Configuration__c.getValues('CALCULATION_PRECISION');
            automatedCS4.String_Value__c = 'ROUND_DOWN';
            update automatedCS4;
            QuoteChargesCalculator.calculateCharges(quoteClsObj);
            QuoteChargesCalculator.calculateSubtotal(quoteClsObj ,quoteChargCalObj);
        }
    }