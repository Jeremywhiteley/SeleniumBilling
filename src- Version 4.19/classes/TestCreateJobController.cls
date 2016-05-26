@isTest
  public with sharing class TestCreateJobController {


      public static void createCustomSettings() {
          ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
          ControllerInsertCustomSettings.insertValues();
          Configuration__c config = Configuration__c.getValues('TAX_CALCULATION_BASED_ON');
          config.String_Value__c = 'Account Billing Address';
          update config;

          Configuration__c config1 = Configuration__c.getValues('DISCOUNT_BY_VALUE_OR_PERCENTAGE');
          config1.String_Value__c = 'Both';
          update config1;

          Configuration__c config2 = Configuration__c.getValues('ACCOUNT_LEGAL_ENTITY_FIELD_NAME');
          config2.String_Value__c = 'Name';
          update config2;
      }
      
      public static void createAccount_Contact() {
          Account account = new Account(Name = 'Test Account', 
                                        Preferred_Billing_Day__c = string.ValueOf(system.Today().Day()),
                                        BillingCountry = 'India', BillingState='Karnataka', BillingCity='Banglore', BillingPostalCode='560068');
          insert account;
          
          Account account1 = [SELECT Name FROM Account WHERE id =: account.id];
          System.assertEquals('Test Account', account1.Name); 

          list<Contact> listContacts = new list<Contact>();
          listContacts.add(new Contact(LastName = 'Sandeep' ,
                                       AccountId = account.Id ,
                                       MailingCountry = 'UK')
                                       );
                                       
          listContacts.add(new Contact(LastName = 'Manoj GanPathy',
                                      AccountId = account.Id, 
                                      MailingCountry = 'Canada',
                                      MailingState = 'Prince Edward Island')
                                      );                                  
          insert listContacts;
      }
      
      public static void createTaxAndVatRates() {
          list<Tax_Rate__c> listOfTaxAndVatRates = new list<Tax_Rate__c>();
          listOfTaxAndVatRates.add(new Tax_Rate__c(Tax_VAT__c = 'Tax', 
                                                   Country__c = 'India', 
                                                   State__c = '*',
                                                   City__c = '*', 
                                                   Product_Charge_Category__c = 'Taxable', 
                                                   Rate__c = 10, Priority__c = '1',
                                                   Legal_Entity_Name__c  = 'Test Account')
                                                   );
                                                   
          listOfTaxAndVatRates.add(new Tax_Rate__c(Tax_VAT__c = 'Tax', 
                                                   Country__c = 'Canada', 
                                                   State__c = 'Prince Edward Island',
                                                   City__c = '*', 
                                                   Product_Charge_Category__c = 'Taxable', 
                                                   Rate__c = 5, Priority__c = '2')
                                                   );
          listOfTaxAndVatRates.add(new Tax_Rate__c(Tax_VAT__c = 'Test Account', 
                                                   Country__c = 'India', 
                                                   State__c = '*',
                                                   City__c = '*', 
                                                   Product_Charge_Category__c = 'Taxable', 
                                                   Rate__c = 5, Priority__c = '2',
                                                   Legal_Entity_Name__c = 'Test Account')
                                                   );
                                                   
          listOfTaxAndVatRates.add(new Tax_Rate__c(Tax_VAT__c = 'VAT', 
                                                   Country__c = 'India', 
                                                   State__c = '*',
                                                   City__c = '*', 
                                                   Product_Charge_Category__c = 'Taxable', 
                                                   Rate__c = 10,
                                                   Legal_Entity_Name__c  = 'Test Account')
                                                   );
                                                   
          listOfTaxAndVatRates.add(new Tax_Rate__c(Tax_VAT__c = 'VAT', 
                                                   Country__c = 'Canada', 
                                                   State__c = 'Prince Edward Island',
                                                   City__c = '*', 
                                                   Product_Charge_Category__c = 'Taxable', 
                                                   Rate__c = 10)
                                                   );
                                                   
          listOfTaxAndVatRates.add(new Tax_Rate__c(Tax_VAT__c = 'VAT', 
                                                   Country__c = 'Canada', 
                                                   State__c = 'Prince Edward Island',
                                                   City__c = '*', 
                                                   Product_Charge_Category__c = 'Taxable', 
                                                   Rate__c = 10, Priority__c = '1')
                                                   );
                                                   
          listOfTaxAndVatRates.add(new Tax_Rate__c(Tax_VAT__c = 'VAT', 
                                                   Country__c = 'Canada', 
                                                   State__c = 'Prince Edward Island',
                                                   City__c = '*', 
                                                   Product_Charge_Category__c = 'Taxable', 
                                                   Rate__c = 10, 
                                                   Priority__c = '2')
                                                   );
          insert listOfTaxAndVatRates;
      }
      
      public static void createDiscountCodes() {
          list<Discount_Code__c> discounts = new  list<Discount_Code__c>();
          Currency__c currencyObj;
          
          currencyObj = [SELECT Id
                          FROM Currency__c
                          WHERE Name = 'GBP' LIMIT 1];
          
          Discount_Code__c d = new Discount_Code__c(Name = 'san', 
                                                    Valid_From__c = system.today(), 
                                                    Price_Type__c = '*', 
                                                    Discount_Value__c = 20, 
                                                    Apply_to__c = 'Charge level',
                                                    Currency__c = currencyObj.Id, 
                                                    Product_Family__c = '*');
          discounts.add(d);       
          
          Discount_Code__c d2 = new Discount_Code__c(Name = 'san2', 
                                                     Valid_From__c = system.today(), 
                                                     Price_Type__c = '*', 
                                                     Discount_Percent__c = 10, 
                                                     Apply_to__c = 'Charge level',
                                                     Currency__c = currencyObj.Id, 
                                                     Product_Family__c = '*'
                                                     );                               
          discounts.add(d2);  
          
          Discount_Code__c d3 = new Discount_Code__c(Name = 'san3', 
                                                     Valid_From__c = system.today(), 
                                                     Price_Type__c = '*', 
                                                     Discount_Value__c = 10, 
                                                     Apply_to__c = 'Quote/Order level',
                                                     Currency__c = currencyObj.Id, 
                                                     Product_Family__c = '*'
                                                     );                               
          discounts.add(d3);
          
          Discount_Code__c d4 = new Discount_Code__c(Name = 'san4', 
                                                     Valid_From__c = system.today(), 
                                                     Price_Type__c = '*', 
                                                     Discount_Percent__c = 10, 
                                                     Apply_to__c = 'Quote/Order level',
                                                     Currency__c = currencyObj.Id, 
                                                     Product_Family__c = '*'
                                                     );                               
          discounts.add(d4);
          
          insert discounts;   
      }
      
      //this method creates Currencies
      public static list<Currency__c> createCurrecy() {
          list<Currency__c> listCurrencys = new list<Currency__c>();
          listCurrencys.add(new Currency__c(Name = 'GBP', 
                                            Symbol__c = '£1')
                                            );
                                            
          listCurrencys.add(new Currency__c(Name = 'USD', 
                                            Symbol__c = '$2')
                                            );
          
          listCurrencys.add(new Currency__c(Name = 'EUR', 
                                            Symbol__c = '€3')
                                            );    
          insert listCurrencys;   
          
          return listCurrencys;
      }
      
      //this method creates Product, Product Rate Plan and Product Rate Plan Charges
      public static void createProductCatalog() {
          Date validtodate = Date.today();   
          Product__c product;
          list<Product_Rate_Plan__c> listProductRatePlans = new list<Product_Rate_Plan__c>();
          Product_Rate_Plan__c productRatePlan;
          list<Product_Rate_Plan_Charge__c> listProductRatePlanCharges = new list<Product_Rate_Plan_Charge__c>();
          Product_Rate_Plan_Charge__c productRatePlanCharge;
          Currency__c currencyObj;
          
          currencyObj = [SELECT Id
                          FROM Currency__c
                          WHERE Name = 'GBP' LIMIT 1];
          
          product = new  Product__c(Name = 'Test Product',
                                    Valid_From_Date__c = validtodate,
                                    Valid_To_Date__c = validtodate,
                                    Product_Family__c = 'Default',
                                    Product_Code__c = 'Code1',
                                    Description__c = 'Product'
                                    );
          insert product;
          
          Stock_Item__c stockItem = new Stock_Item__c(Available_Quantity__c = 20,
                                                      Received_Quantity__c = 20,
                                                      Stock_Entry_Date__c = Date.today(),
                                                      Product__c = product.Id
                                                      );
          insert stockItem;
          
          for(Integer x = 0; x < 2; x++) {
            productRatePlan = new  Product_Rate_Plan__c(Name = 'Test ProductRatePlan' + x,
                                                        Product__c = product.Id,
                                                        Valid_From_Date__c = validtodate,
                                                        Valid_To_Date__c = validtodate,
                                                        Description__c = 'Product RatePlan'
                                                        );
            listProductRatePlans.add(productRatePlan);
          }
          insert listProductRatePlans;    
          
          for(Integer x = 0;x <= 5;x++) {
            productRatePlanCharge = new Product_Rate_Plan_Charge__c(Name = 'Test ProductRatePlan Charge' + x,
                                                                    CurrencyL__c = currencyObj.Id,
                                                                    Product_Rate_Plan__c = listProductRatePlans.get(0).Id,
                                                                    Unit_price__c = 200,
                                                                    Cost_Price__c = 160,
                                                                    Product_Charge_Category__c = 'Taxable'
                                                                    );
            if(x == 3) {
              productRatePlanCharge.Price_Format__c = CommonUtilClass.PRICE_FORMAT_VOLUME;
              productRatePlanCharge.Unit_price__c = 0;
              productRatePlanCharge.Cost_Price__c = 0;
            } else if(x == 4) {
              productRatePlanCharge.Price_Format__c = CommonUtilClass.PRICE_FORMAT_FLAT_FEE;
              productRatePlanCharge.Unit_price__c = 0;
              productRatePlanCharge.Cost_Price__c = 0;
            } else if(x == 5) {
              productRatePlanCharge.Price_Format__c = CommonUtilClass.PRICE_FORMAT_TIERED;
              productRatePlanCharge.Unit_price__c = 0;
              productRatePlanCharge.Cost_Price__c = 0;
            }
            
            listProductRatePlanCharges.add(productRatePlanCharge);
          }
          insert listProductRatePlanCharges;
          
          list<Product_Rate_Plan_Charge_Tier__c> tiers = new list<Product_Rate_Plan_Charge_Tier__c>();
          tiers.add(new Product_Rate_Plan_Charge_Tier__c(Start_Unit__c = 1, End_Unit__c = 10, Unit_Cost_Price__c = 90, Unit_Price__c = 120, Product_Rate_Plan_Charge__c = listProductRatePlanCharges[3].Id));
          tiers.add(new Product_Rate_Plan_Charge_Tier__c(Start_Unit__c = 11, End_Unit__c = 20, Unit_Cost_Price__c = 90, Unit_Price__c = 110, Product_Rate_Plan_Charge__c = listProductRatePlanCharges[3].Id));
          tiers.add(new Product_Rate_Plan_Charge_Tier__c(Start_Unit__c = 21, End_Unit__c = 30, Unit_Cost_Price__c = 90, Unit_Price__c = 100, Product_Rate_Plan_Charge__c = listProductRatePlanCharges[3].Id));
          
          tiers.add(new Product_Rate_Plan_Charge_Tier__c(Start_Unit__c = 1, End_Unit__c = 10, Unit_Cost_Price__c = 90, Unit_Price__c = 120, Product_Rate_Plan_Charge__c = listProductRatePlanCharges[4].Id));
          tiers.add(new Product_Rate_Plan_Charge_Tier__c(Start_Unit__c = 11, End_Unit__c = 20, Unit_Cost_Price__c = 90, Unit_Price__c = 110, Product_Rate_Plan_Charge__c = listProductRatePlanCharges[4].Id));
          tiers.add(new Product_Rate_Plan_Charge_Tier__c(Start_Unit__c = 21, End_Unit__c = 30, Unit_Cost_Price__c = 90, Unit_Price__c = 100, Product_Rate_Plan_Charge__c = listProductRatePlanCharges[4].Id));
          
          tiers.add(new Product_Rate_Plan_Charge_Tier__c(Start_Unit__c = 1, End_Unit__c = 10, Unit_Cost_Price__c = 90, Unit_Price__c = 120, Product_Rate_Plan_Charge__c = listProductRatePlanCharges[5].Id));
          tiers.add(new Product_Rate_Plan_Charge_Tier__c(Start_Unit__c = 11, End_Unit__c = 20, Unit_Cost_Price__c = 90, Unit_Price__c = 110, Product_Rate_Plan_Charge__c = listProductRatePlanCharges[5].Id));
          tiers.add(new Product_Rate_Plan_Charge_Tier__c(Start_Unit__c = 21, End_Unit__c = 30, Unit_Cost_Price__c = 90, Unit_Price__c = 100, Product_Rate_Plan_Charge__c = listProductRatePlanCharges[5].Id));
          insert tiers;
      }
      
      public static void create_CustomSettingFilters() {
          list<Product_Catalog_Filter_Criteria__c> listFilters = new list<Product_Catalog_Filter_Criteria__c>();
          listFilters.add(new Product_Catalog_Filter_Criteria__c(Destination_Field__c = 'CurrencyL__c',
                                                                 Destination_Object__c = 'Product_Rate_Plan_Charge__c',
                                                                 Source_Field__c = 'CurrencyL__c',
                                                                 Source_Object__c = 'Job__c', 
                                                                 Name = 'a1')
                                                                 );
                                                                 
          listFilters.add(new Product_Catalog_Filter_Criteria__c(Destination_Field__c = 'CurrencyL__c',
                                                                 Destination_Object__c = 'Product_Rate_Plan_Charge__c',
                                                                 Source_Field__c = 'CurrencyL__c',
                                                                 Source_Object__c = 'Quote__c', 
                                                                 Name = 'a2')
                                                                 );
                                                                 
          listFilters.add(new Product_Catalog_Filter_Criteria__c(Destination_Field__c = 'Name',
                                                                 Destination_Object__c = 'Product__c',
                                                                 Source_Field__c = 'Name',
                                                                 Source_Object__c = 'Job__c', 
                                                                 Name = 'a3')
                                                                 );
                                                                 
          listFilters.add(new Product_Catalog_Filter_Criteria__c(Destination_Field__c = 'Name',
                                                                 Destination_Object__c = 'Product__c',
                                                                 Source_Field__c = 'Name',
                                                                 Source_Object__c = 'Quote__c', 
                                                                 Name = 'a4')
                                                                 );
                                                                 
          listFilters.add(new Product_Catalog_Filter_Criteria__c(Destination_Field__c = 'Name',
                                                                 Destination_Object__c = 'Product_Rate_Plan__c',
                                                                 Source_Field__c = 'Account',
                                                                 Source_Object__c = 'Quote__c', 
                                                                 Name = 'a5')
                                                                 );
          insert listFilters;
      }
      
      public static void create_CustomSettingMapping() {
          list<Custom_Mappings__c> listCustomMapping = new list<Custom_Mappings__c>();
          listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = 'Name',
                                                       Destination_Object__c = 'Job_Rate_Plan__c',
                                                       Source_Field__c = 'Name',
                                                       Source_Object__c = 'Product_Rate_Plan__c', 
                                                       Name = 'Map_JobRatePlan_ProductRatePlan')
                                                       );
                                                       
          listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = 'Name',
                                                       Destination_Object__c = 'Job_Rate_Plan_Charge__c',
                                                       Source_Field__c = 'Name',
                                                       Source_Object__c = 'Product_Rate_Plan_Charge__c', 
                                                       Name = 'Map_JobRatePlanCharge_ProductCharge')
                                                       );
                                                       
          listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = 'Name',
                                                       Destination_Object__c = 'Job_Product__c',
                                                       Source_Field__c = 'Name',
                                                       Source_Object__c = 'Product__c', 
                                                       Name = 'Map_JobProduct_Product')
                                                       );
          insert listCustomMapping;
      }
      
      public static void create_Job() {
      
          list<SObject> SObjects;
          Product__c product;
          
          Account account = [SELECT Id,
                              (SELECT Id FROM Contacts)
                              FROM Account
                              WHERE Name = 'Test Account' LIMIT 1];
          
          Contact contact = account.Contacts.get(0);
          
          Currency__c currencyObj;
          currencyObj = [SELECT Id
                          FROM Currency__c
                          WHERE Name = 'GBP' LIMIT 1];
          
          Job__c job1 = new Job__c(Name = 'Test Job', 
                                   Account__c = account.Id,
                                   Billing_Contact__c = contact.Id,
                                   Shipping_Contact__c = contact.Id,
                                   Number_Of_Terms__c = 24,
                                   Start_Date__c = system.today(), 
                                   Service_Activation_Date__c = system.today(), 
                                   Service_End_Date__c = system.today().addMonths(10)
                                   );

          ApexPages.Standardcontroller stdController = new Apexpages.Standardcontroller(job1);
          CreateJobController createJobController = new CreateJobController(stdController);
      
          //Move to the first page
          createJobController.step1();
        
          //Move to the second page
          createJobController.step2();
          
          //Assign currency
          job1.CurrencyL__c = currencyObj.Id;
          
          createJobController.changeCurrencySelection();
          
          SObjects = ControllerAutoComplete.findSObjects('Product__c',
                                                         'est Produc' ,
                                                         'Name',
                                                         '', 
                                                         'Name',
                                                         '',
                                                         '20'
                                                         );
          
          product = [SELECT Id, Name, 
                      (SELECT Id, Name FROM ProductRatePlan__r)
                      FROM Product__c
                      WHERE Name = 'Test Product'];
          
          createJobController.getRatePlansForProduct();
          //Set the Product id and name,so that we can fetch Product Rate Plans
          system.currentPageReference().getParameters().put('productId', product.Id);
          system.currentPageReference().getParameters().put('productName', product.name);
          createJobController.getRatePlansForProduct();
          
          system.currentPageReference().getParameters().put('ratePlanId', product.ProductRatePlan__r.get(0).Id);
          system.currentPageReference().getParameters().put('rateplanName', product.ProductRatePlan__r.get(0).name);
          createJobController.getRatePlanChargesForRatePlan();
          
          system.currentPageReference().getParameters().put('ratePlanId', product.ProductRatePlan__r.get(1).Id);
          system.currentPageReference().getParameters().put('rateplanName', product.ProductRatePlan__r.get(1).name);
          createJobController.getRatePlanChargesForRatePlan();
          
          job1 = createJobController.jobClass.getJob();
          job1.Recalculate__c = true;

          list<JobProductClass> jobProducts = createJobController.jobClass.getJobProducts();
          list<JobRatePlanClass> jobRatePlans = createJobController.jobProductClass.getJobRatePlans();
          list<JobRatePlanChargeClass> jobRatePlanCharges = createJobController.JobRatePlanClass.getJobRatePlanCharges();
          list<JobRatePlanChargeTierClass> jobTiers = jobRatePlanCharges[0].getJobRatePlanChargeTiers();
          
          //Remove the Product rate plan charge
          system.currentPageReference().getParameters().put('jobrateplancounter', '0');
          system.currentPageReference().getParameters().put('jobRatePlanId',jobRatePlans[0].jobrateplan.Id);
          system.currentPageReference().getParameters().put('productBundleId', '');
          createJobController.removeCharges();
          
          createJobController.step3();
          
          createJobController.jobClass.job.Discount_Value__c = 100;
          createJobController.chargeCalculator();
          
          createJobController.jobClass.job.Discount_Value__c = 100;
          createJobController.chargeCalculator();
          
          createJobController.jobClass.job.Discount_Value__c = 100;
          createJobController.applyDiscountValueToCharges();
          
          createJobController.jobClass.job.Discount_Percent__c = 10;
          createJobController.applyDiscountPercentToCharges();
          
          createJobController.job.Discount_Code__c = 'man';
          createJobController.applyDiscountCode();
          
          createJobController.job.Discount_Code__c = 'san';
          createJobController.applyDiscountCode();
          
          createJobController.job.Discount_Code__c = 'san2';
          createJobController.applyDiscountCode();
          
          createJobController.job.Discount_Code__c = 'san3';
          createJobController.applyDiscountCode();
          
          createJobController.job.Discount_Code__c = 'san4';
          createJobController.applyDiscountCode();
          
          //Save the Job
          createJobController.addJobCharges();
          
          for(JobProductClass qpc : createJobController.jobClass.jobProducts) {
              for(JobRatePlanClass qrc : qpc.jobRatePlans) { 
                  for(JobRatePlanChargeClass qrpc :qrc.jobRatePlanCharges) {
                      qrpc.jobrateplancharge.Service_End_Date__c = system.today().addMonths(10);
                      qrpc.jobrateplancharge.Discount_Value__c = 1;
                      qrpc.jobrateplancharge.Discount_Type__c = 'By Value';
                      qrpc.jobrateplancharge.Discount_Percent__c = 0;
                  }
              }
          }
          
          createJobController.saveJob();
          createJobController.save();
          createJobController.saveAndClosePopup();
          product = new  Product__c(Name = 'Test Product',
                                    Valid_From_Date__c = Date.today(),
                                    Valid_To_Date__c = Date.today(),
                                    Product_Family__c = 'Default',
                                    Product_Code__c = 'Code1',
                                    Description__c = 'Product'
                                    );
          insert product;
      
          Product_Rate_Plan__c productRatePlan = new  Product_Rate_Plan__c(Name = 'Test ProductRatePlan',
                                                            Product__c = product.Id,
                                                            Valid_From_Date__c = Date.today(),
                                                            Valid_To_Date__c = Date.today(),
                                                            Description__c = 'Product RatePlan'
                                                            );
         
            
          insert productRatePlan;    
          
          Product_Rate_Plan_Charge__c productRatePlanCharge = new Product_Rate_Plan_Charge__c(Name = 'Test ProductRatePlan Charge',
                                                                        CurrencyL__c = currencyObj.Id,
                                                                        Product_Rate_Plan__c = productRatePlan.Id,
                                                                        Unit_price__c = 200,
                                                                        Cost_Price__c = 160,
                                                                        Product_Charge_Category__c = 'Taxable',
                                                                        Price_Format__c = CommonUtilClass.PRICE_FORMAT_VOLUME
                                                                        );
          insert productRatePlanCharge;

          Product_Bundle__c productBundleObj = new Product_Bundle__c(Name = 'Devender', Bundle_Type__c = 'Bundle', Start_Date__c = system.today() - 1,Currency__c = currencyObj.Id,
                                                                  Bundle_Price__c = 100, Is_Price_Editable__c = true, Is_Quantity_Editable__c = false,Price_Type__c = 'One Time',
                                                                  Quantity__c = 1.0, Unit_Of_Measurement__c = 'One', Pricing_Model__c = 'Default');
          insert productBundleObj; 

          Product_Bundle_Line__c productBundleLine = new Product_Bundle_Line__c(Product__c = product.id, Product_Bundle__c = productBundleObj.id,Product_Rate_Plan__c = productRatePlan.Id,Product_Rate_Plan_Charge__c = productRatePlanCharge.Id);
          insert productBundleLine; 
          createJobController.getProductBundle(productBundleObj.id);
          
          for(JobProductClass qpc : createJobController.jobClass.jobProducts) {
              for(JobRatePlanClass qrc : qpc.jobRatePlans) { 
                  for(JobRatePlanChargeClass qrpc :qrc.jobRatePlanCharges) {
                      if(qrpc.jobRatePlanCharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME) {
                          system.currentPageReference().getParameters().put('jobRatePlanChargeCounterForTier', string.ValueOf(qrpc.jobRatePlanChargeCounter));
                          createJobController.showPopup();
                          createJobController.newTier();
                          string tierId = qrpc.jobRatePlanChargeTiers[0].jobRatePlanChargeTier.Id;
                          system.currentPageReference().getParameters().put('jobTierIdToDelete', tierId);
                          system.currentPageReference().getParameters().put('jobTierCountertoDelete', '1');
                          system.currentPageReference().getParameters().put('jobRatePlanChargeCounterForTier', string.ValueOf(qrpc.jobRatePlanChargeCounter));
                          createJobController.removeTier();
                          createJobController.closePopup();
                          break;
                      }
                  }
              }
          }
          createJobController.saveAndClosePopup();
          createJobController.quantityChanged();
          createJobController.quickSave();
          createJobController.showPopupForProductRPC();
          createJobController.closePopupForProductRPC();
          createJobController.saveAndCloseProductRPCPopup();

           //select the charges whose Status is Dispatched
          for(JobProductClass jpc : createJobController.jobClass.jobProducts)
          {
              for(JobRatePlanClass jrc : jpc.jobRatePlans)
              {
                  for(JobRatePlanChargeClass jrpc : jrc.jobRatePlanCharges)
                  {
                      if(jrpc.jobrateplancharge.Price_Type__c == system.Label.OptionOneTime) {
                          jrpc.jobrateplancharge.Status__c = 'Dispatched';
                          jrpc.jobrateplancharge.Dispatch__c = true;
                          jrpc.jobrateplancharge.Quantity__c = 50;
                          jrpc.jobrateplancharge.Quantity_Already_Dispatched__c = 20;
                          jrpc.jobrateplancharge.Quantity_to_Dispatch__c = 5;
                      }
                  }
              }
          }
          createJobController.saveJob();
          createJobController.save();
          createJobController.sBarCodes = 'Code1, Code2';
          Stock_Item__c sI = new Stock_Item__c(Product__c = createJobController.jobClass.jobProducts[0].jobProduct.Product__c, Stock_Reference__c = 'eee', Received_Quantity__c = 10, Available_Quantity__c = 10, Bar_Code__c = 'Code1, Code2');
          insert sI;
          createJobController.createDispatchLineItems_UsingScanner();
          createJobController.createDispatchLineItems();
          createJobController.createDispatchLineItems_Logic();

      }
      
      public static void update_Job() {
          Job__c job;
          
          job = [SELECT Id
                  FROM Job__c
                  WHERE Name = 'Test Job' LIMIT 1];
                  
          job.Number_Of_Terms__c = 15.0;
          update job;
          
          //Used for calling in edit mode
          ApexPages.Standardcontroller stdController = new Apexpages.Standardcontroller(job);
          CreateJobController createJobController = new CreateJobController(stdController);
          //createJobController.saveJob();
          createJobController.createDispatchLineItems();
          
          //select the charges whose Status is Dispatched
          for(JobProductClass jpc : createJobController.jobClass.jobProducts)
          {
              for(JobRatePlanClass jrc : jpc.jobRatePlans)
              {
                  for(JobRatePlanChargeClass jrpc : jrc.jobRatePlanCharges)
                  {
                      if(jrpc.jobrateplancharge.Price_Type__c == system.Label.OptionOneTime) {
                          jrpc.jobrateplancharge.Status__c = 'Delivered';
                          jrpc.jobrateplancharge.Dispatch__c = true;
                      }
                  }
              }
          }
          createJobController.sBarCodes = 'Code1, Code2';
          createJobController.createDispatchLineItems_UsingScanner();
          
          //code for creating dispatch item's
          createJobController.createDispatchLineItems();
          for(JobProductClass jpc : createJobController.jobClass.jobProducts)
          {
              for(JobRatePlanClass jrc : jpc.jobRatePlans)
              {
                  for(JobRatePlanChargeClass jrpc : jrc.jobRatePlanCharges)
                  {
                      if(jrpc.jobrateplancharge.Price_Type__c == system.Label.OptionOneTime) {
                          jrpc.jobrateplancharge.Dispatch__c = true;
                          jrpc.jobrateplancharge.Status__c = 'Delivered';
                          jrpc.jobrateplancharge.Quantity__c = 50;
                          jrpc.jobrateplancharge.Quantity_Already_Dispatched__c = 40;
                          jrpc.jobrateplancharge.Quantity_to_Dispatch__c = 40;
                      }
                  }
              }
          }
          createJobController.initializeDispatch();
          createJobController.createDispatchLineItems();

          for(JobProductClass jpc : createJobController.jobClass.jobProducts)
          {
              for(JobRatePlanClass jrc : jpc.jobRatePlans)
              {
                  for(JobRatePlanChargeClass jrpc : jrc.jobRatePlanCharges)
                  {
                      if(jrpc.jobrateplancharge.Price_Type__c == system.Label.OptionOneTime) {
                          jrpc.jobrateplancharge.Status__c = 'Delivered';
                          jrpc.jobrateplancharge.Dispatch__c = true;
                          jrpc.jobrateplancharge.Quantity__c = 50;
                          jrpc.jobrateplancharge.Quantity_to_Dispatch__c = 10;
                      }
                  }
              }
          }
          createJobController.sBarCodes = 'Code1, Code2';
          createJobController.createDispatchLineItems_UsingScanner();
          
          Stock_Item__c sI = new Stock_Item__c(Product__c = createJobController.jobClass.jobProducts[0].jobProduct.Product__c, Stock_Reference__c = 'eee', Received_Quantity__c = 10, Available_Quantity__c = 10, Bar_Code__c = 'Code1');
          insert sI;
          
          createJobController.sBarCodes = 'Code1, Code2';
          createJobController.createDispatchLineItems_UsingScanner();
          
          ClassAfterOnJob.populateJobClass(createJobController.jobClass.job.Id, false);
          ClassAfterOnJob.saveJob(createJobController.jobClass);
          ClassAfterOnJob objClassAfterOnJob = new ClassAfterOnJob();
          objClassAfterOnJob.setJobAfterProcessingComplete();
          objClassAfterOnJob.getJobAfterProcessingComplete();
      }
      
      public static void amend_Job() {
          Job__c job;
          
          job = [SELECT Id
                  FROM Job__c
                  WHERE Name = 'Test Job' LIMIT 1];
                  
          list<Job_Rate_Plan_Charge__c> listOfJobRatePlanCharges = [SELECT Id
                                                                    FROM Job_Rate_Plan_Charge__c 
                                                                    WHERE Job_Rate_Plan__r.Job_Product__r.Job__r.Id =: job.Id];  
          for(Job_Rate_Plan_Charge__c charge : listOfJobRatePlanCharges) {
              charge.Product_Charge_Category__c = 'Taxable';
              charge.Price_Format__c = 'Volume Pricing';
              charge.Service_Activation_Date__c = system.today().addMonths(30);
              charge.Next_Charge_Date__c = system.today(); 
          }   
          
          //Used for calling in edit mode
          ApexPages.Standardcontroller stdController = new Apexpages.Standardcontroller(job);
          CreateJobController createJobController = new CreateJobController(stdController);  
          
          system.currentPageReference().getParameters().put('chargeIdToBeModified', listOfJobRatePlanCharges.get(0).Id);
          createJobController.modifyQuantity();
          
          //save the amendment
          createJobController.saveAmendment();
          
          system.currentPageReference().getParameters().put('chargeIdToBeCancelled', listOfJobRatePlanCharges.get(0).Id);  
          createJobController.cancelQuantity();
          
          //save the amendment
          createJobController.saveAmendment();
          
          //save the job
          createJobController.saveJob();
          
          //add the new product to the midterm
          createJobController.getRatePlansForProductMidTerm();
          createJobController.getRatePlanChargesForRatePlanMidTerm();
           CreateJobController.cloneOrder();
      }
         
      static testMethod void main() {
          //populate the data
          TestCreateJobController.createCustomSettings();
          TestCreateJobController.createCurrecy();
          TestCreateJobController.createDiscountCodes();
          TestCreateJobController.createTaxAndVatRates();
          TestCreateJobController.createAccount_Contact();
          TestCreateJobController.createTaxAndVatRates();
          TestCreateJobController.createProductCatalog();
          TestCreateJobController.create_CustomSettingMapping();
          TestCreateJobController.create_CustomSettingFilters();
          TestCreateJobController.create_Job();
          
          system.Test.startTest();    
              TestCreateJobController.update_Job();
          system.Test.stopTest();
      }
      
      static testMethod void amendJob() {
          //populate the data
          TestCreateJobController.createCustomSettings();
          TestCreateJobController.createCurrecy();
          TestCreateJobController.createDiscountCodes();
          TestCreateJobController.createTaxAndVatRates();
          TestCreateJobController.createAccount_Contact();
          TestCreateJobController.createTaxAndVatRates();
          TestCreateJobController.createProductCatalog();
          TestCreateJobController.create_Job();
          system.Test.startTest();
              TestCreateJobController.amend_Job();
          system.Test.stopTest();
      }   
       
      static testMethod void testCreateProformaInvoice() {
           createCustomSettings();
           
           Account account = new Account(Name = 'Test Account');
           insert account;

           Account account1 = [Select Name From Account WHERE id=:account.id];
           System.assertEquals('Test Account', account1.Name);
           
           list<Contact> listContacts = new list<Contact>();
           listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com'));
           listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA',Email = 'laxmanrao.564@gmail.com'));
           insert listContacts;
           
           Currency__c currency1 = new Currency__c(name = 'GBP', Symbol__c = '£1');
           insert currency1;
           
           Job__c job = new Job__c(Account__c = account.id, Billing_Contact__c = listContacts.get(0).Id,Shipping_Contact__c = listContacts.get(1).Id, Service_Activation_Date__c = system.today(),CurrencyL__c = currency1.Id);
           
           insert job;
           
           Job_Product__c  jobProduct= new Job_Product__c(Name = 'jobProduct',Job__c = job.Id);
           insert jobProduct;

           Job_Rate_Plan__c jobRP = new Job_Rate_Plan__c(Name = 'JobRP',Job_Product__c =jobProduct.Id);
           insert jobRP;

           Job_Rate_Plan_Charge__c charge = new Job_Rate_Plan_Charge__c(Name = 'jobRPC',Job_Rate_Plan__c =jobRP.Id,Quantity__c = 12,Price_Type__c = 'One Time',Accounting_Code__c = '12345',Unit_Price__c = 12);
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
           
           invoice.Invoice_State__c = CommonUtilClass.STATUS_PROFORMA;
           invoice.Regular_Invoice__c = null;
           delete [Select Id From Invoice_Lines__c Where Invoice__c =: invoiceId];
           
           ApexPages.Standardcontroller controllerInv2 = new Apexpages.Standardcontroller(invoice);
           ControllerProformaInvToRegularInv createRegInvoice2 = new ControllerProformaInvToRegularInv(controllerInv2);
           createRegInvoice2.createRegularInvoice();
      }
   }