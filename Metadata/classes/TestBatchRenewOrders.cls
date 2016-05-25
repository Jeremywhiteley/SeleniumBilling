@isTest
  private class TestBatchRenewOrders {

      static testMethod void myUnitTest() {
          // TO DO: implement unit test
          
          ControllerInsertCustomSettings controllerInsertCustomSettings = new ControllerInsertCustomSettings();
          controllerInsertCustomSettings.insertValues();
          
          Account accountObj = new Account(Name='TestAccount');
          insert accountObj;
          
          Account account = [SELECT Name FROM Account WHERE Id = :accountObj.Id];
          System.assertEquals('TestAccount', account.Name);
          
          Date validtodate = Date.today();
          Contact contact = new Contact(lastname = 'testCon1',AccountId=accountObj.Id);
          insert contact;
          
          Currency__c currencyObj = new Currency__c(Currency_Symbol__c='USD');
          insert currencyObj;
          
          Product__c product = new Product__c(Name = 'Test Product for tiers',Valid_From_Date__c = validtodate-1,Valid_To_Date__c = validtodate.addMonths(2),Product_Family__c = 'Default',Product_Code__c = 'Code1',Description__c = 'Product');
          insert product;
          
          list<Product_Rate_Plan__c> listProductRatePlans = new list<Product_Rate_Plan__c>();
          Product_Rate_Plan__c productRatePlan;
          for(Integer x = 0;x< 2;x++){
              productRatePlan = new  Product_Rate_Plan__c(  Name = 'Test ProductRatePlan' + x,Product__c = product.Id,Valid_From_Date__c = validtodate,Valid_To_Date__c = validtodate.addMonths(2));
              listProductRatePlans.add(productRatePlan);
          }
          insert listProductRatePlans;
          
          list<Product_Rate_Plan_Charge__c> listProductRatePlanCharges = new list<Product_Rate_Plan_Charge__c>();
          Product_Rate_Plan_Charge__c productRatePlanCharge_SetUp = new Product_Rate_Plan_Charge__c(Name = 'Setup Charges',
                                                                CurrencyL__c = currencyObj.Id,
                                                                Product_Rate_Plan__c = listProductRatePlans[0].Id,
                                                                Unit_price__c = 1000,
                                                                Cost_Price__c = 500,
                                                                Product_Charge_Category__c = 'Taxable',
                                                                
                                                                Price_Type__c = 'One Time'
                                                                );
          listProductRatePlanCharges.add(productRatePlanCharge_SetUp);
          
          Product_Rate_Plan_Charge__c productRatePlanCharge_Usage = new Product_Rate_Plan_Charge__c(Name = 'Usage Charges',
                                                                CurrencyL__c = currencyObj.ID,
                                                                Product_Rate_Plan__c = listProductRatePlans[0].Id,
                                                                Unit_price__c = 500,
                                                                Cost_Price__c = 250,
                                                                Product_Charge_Category__c = 'Taxable',
                                                                Price_Type__c = 'Usage',
                                                                Price_Format__c = 'Volume Pricing'                                                              
                                                                );   
          listProductRatePlanCharges.add(productRatePlanCharge_Usage);                                
          insert listProductRatePlanCharges;
          
          list<Product_Rate_Plan_Charge_Tier__c> listProductRatePlanChargesTiers = new list<Product_Rate_Plan_Charge_Tier__c>();
          Product_Rate_Plan_Charge_Tier__c productRatePlanChargeTier = new Product_Rate_Plan_Charge_Tier__c(Start_Unit__c = 1,
                                                                                    End_Unit__c = 10,
                                                                                    Unit_Price__c =100,
                                                                                    Product_Rate_Plan_Charge__c =listProductRatePlanCharges[1].Id
                                                                                    );
          listProductRatePlanChargesTiers.add(productRatePlanChargeTier);
          insert listProductRatePlanChargesTiers; 
          
          Product_Bundle__c productBundle = new Product_Bundle__c(Name ='Budle Test',
                                                      Start_Date__c=validtodate,
                                                      Currency__c = currencyObj.Id,
                                                      Bundle_Type__c='Bundle',
                                                      Bundle_Price__c=100,
                                                      Quantity__c = 1,
                                                      Price_Type__c='Monthly',
                                                      Pricing_Model__c='Default'
                                                      ); 
          insert productBundle;
          
          Product_Bundle_Line__c productBundleLine = new Product_Bundle_Line__c(Product_Bundle__r = productBundle,
                                                  Product__c = product.Id,
                                                  Product_Rate_Plan__c = listProductRatePlans[0].Id,
                                                  Product_Rate_Plan_Charge__c = listProductRatePlanCharges[0].Id);
                                                                                        
          Job__c orderObj = new Job__c(Auto_Renew__c = true,Auto_Renewal_Complete__c=false, Renewal_Terms_Months__c=12, Name = 'TestOrder',Account__c=accountObj.Id,CurrencyL__c=currencyObj.Id,Billing_Contact__c=contact.id,Service_Activation_Date__c=validtodate,Start_Date__c=validtodate,Service_End_Date__c=validtodate);
          insert orderObj;
          
          list<Job_Product__c> listOfJobProducts = new list<Job_Product__c>();        
        
          Job_Product__c  jobProduct = new Job_Product__c(Name = 'JobProduct',Product__c=product.Id,Job__c = orderObj.Id);
          listOfJobProducts.add(jobProduct);
          
          Job_Product__c jobProductBundle = new Job_Product__c(Name = 'JobProductBundle',Job__c = orderObj.Id,Bundle_SequenceNumber__c =1,Product_Bundle__c=productBundle.Id);
          listOfJobProducts.add(jobProductBundle);
          
          Job_Product__c jobProductBundle2 = new Job_Product__c(Name = 'JobProductBundle2',Job__c = orderObj.Id,Bundle_SequenceNumber__c =1,Product__c=product.Id,Product_Bundle__c=productBundle.Id);
          listOfJobProducts.add(jobProductBundle2);        
          insert listOfJobProducts;
          
          list<Job_Rate_Plan__c> listOfJobRatePlans = new list<Job_Rate_Plan__c>();
          Job_Rate_Plan__c jobRP = new Job_Rate_Plan__c(Name = 'JobRP',Product_Rate_Plan__c = productRatePlan.Id,Job_Product__c = listOfJobProducts[0].Id);
          listOfJobRatePlans.add(jobRP);
          
          Job_Rate_Plan__c jobRPBundle = new Job_Rate_Plan__c(Name = 'JobRPBundle',Job_Product__c =listOfJobProducts[1].Id);
          listOfJobRatePlans.add(jobRPBundle);
          
          Job_Rate_Plan__c jobRPBundle2 = new Job_Rate_Plan__c(Name = 'JobRPBundle2',Job_Product__c =listOfJobProducts[2].Id,Product_Rate_Plan__c = productRatePlan.Id);
          listOfJobRatePlans.add(jobRPBundle2);
          insert listOfJobRatePlans;
                   
          list<Job_Rate_Plan_Charge__c> listOfJobChrges = new list<Job_Rate_Plan_Charge__c>();
          Job_Rate_Plan_Charge__c jobCharge = new Job_Rate_Plan_Charge__c(Order__c=orderObj.Id,Name = 'JobRPC',Product_Rate_Plan_Charge__c = productRatePlanCharge_Usage.id, Job_Rate_Plan__c =listOfJobRatePlans[0].Id,Status__c = 'Draft',Quantity__c = 12,Unit_Price__c = 12,Service_Activation_Date__c=validtodate,Service_End_Date__c=validtodate,Auto_Renew__c=true,Uplift__c=10);
          listOfJobChrges.add(jobCharge);
           
          Job_Rate_Plan_Charge__c jobBundleCharge = new Job_Rate_Plan_Charge__c(Order__c=orderObj.Id, Name = 'JobRPBundleCharge',Job_Rate_Plan__c =listOfJobRatePlans[1].Id, Status__c = 'Draft',Quantity__c = 1,Unit_Price__c = 100,Service_Activation_Date__c = validtodate,Service_End_Date__c = validtodate,Auto_Renew__c = true,Uplift__c=10);
          listOfJobChrges.add(jobBundleCharge);
          
          Job_Rate_Plan_Charge__c jobBundlelLineCharge = new Job_Rate_Plan_Charge__c(Order__c=orderObj.Id, Name = 'JobRPBundleLineCharge',Product_Rate_Plan_Charge__c = productRatePlanCharge_SetUp.id, Job_Rate_Plan__c =listOfJobRatePlans[2].Id,Status__c = 'Draft',Quantity__c = 1,Unit_Price__c = 0,Service_Activation_Date__c=validtodate,Service_End_Date__c=validtodate,Auto_Renew__c=true,Uplift__c=10,Product_Bundle_Line__c = productBundleLine.id);
          listOfJobChrges.add(jobBundlelLineCharge);
          insert listOfJobChrges;
                    
          Job_Rate_Plan_Charge_Tier__c tier = new Job_Rate_Plan_Charge_Tier__c(Start_Unit__c=1,End_Unit__c=100, Unit_Price__c=10,Job_Rate_Plan_Charge__c=listOfJobChrges[0].id);
          insert tier;
          
          ApexPages.StandardController controller = new ApexPages.StandardController(orderObj);
          ClassOrderProductsInlineAJS ClassOrderProductsInlineAJS = new ClassOrderProductsInlineAJS(controller ); 
          Configuration__c config = Configuration__c.getValues('INVOICEIT_BATCH_JOBS_TO_PROCESS');
          config.String_Value__c = 'Auto Renewals';
          update config;
          
          System.Test.StartTest();
              RunSchedulerRenewOrders sh1 = new RunSchedulerRenewOrders();
              String sch = '0 0 23 * * ?';
              system.schedule('RunSchedulerRenewOrders', sch, sh1);

              BatchRenewOrders batch = new BatchRenewOrders(true);
             ID batchprocessid = Database.executeBatch(batch, 1);
          System.Test.stopTest();

      }
      
      static testMethod void quoteRenewals() {
          // TO DO: implement unit test
          
          ControllerInsertCustomSettings controllerInsertCustomSettings = new ControllerInsertCustomSettings();
          controllerInsertCustomSettings.insertValues();
          
          Account accountObj = new Account(Name='TestAccount');
          insert accountObj;
          
          Account account = [SELECT Name FROM Account WHERE Id = :accountObj.Id];
          System.assertEquals('TestAccount', account.Name);
          
          Date validtodate = Date.today();
          Contact contact = new Contact(lastname = 'testCon1',AccountId=accountObj.Id);
          insert contact;
          
          Currency__c currencyObj = new Currency__c(Currency_Symbol__c='USD');
          insert currencyObj;
          
          Product__c product = new Product__c(Name = 'Test Product for tiers',Valid_From_Date__c = validtodate-1,Valid_To_Date__c = validtodate.addMonths(2),Product_Family__c = 'Default',Product_Code__c = 'Code1',Description__c = 'Product');
          insert product;
          
          list<Product_Rate_Plan__c> listProductRatePlans = new list<Product_Rate_Plan__c>();
          Product_Rate_Plan__c productRatePlan;
          for(Integer x = 0;x< 2;x++){
              productRatePlan = new  Product_Rate_Plan__c(  Name = 'Test ProductRatePlan' + x,Product__c = product.Id,Valid_From_Date__c = validtodate,Valid_To_Date__c = validtodate.addMonths(2));
              listProductRatePlans.add(productRatePlan);
          }
          insert listProductRatePlans;
          
          list<Product_Rate_Plan_Charge__c> listProductRatePlanCharges = new list<Product_Rate_Plan_Charge__c>();
          Product_Rate_Plan_Charge__c productRatePlanCharge_SetUp = new Product_Rate_Plan_Charge__c(Name = 'Setup Charges',
                                                                CurrencyL__c = currencyObj.Id,
                                                                Product_Rate_Plan__c = listProductRatePlans[0].Id,
                                                                Unit_price__c = 1000,
                                                                Cost_Price__c = 500,
                                                                Product_Charge_Category__c = 'Taxable',
                                                                
                                                                Price_Type__c = 'One Time'
                                                                );
          listProductRatePlanCharges.add(productRatePlanCharge_SetUp);
          
          Product_Rate_Plan_Charge__c productRatePlanCharge_Usage = new Product_Rate_Plan_Charge__c(Name = 'Usage Charges',
                                                                CurrencyL__c = currencyObj.ID,
                                                                Product_Rate_Plan__c = listProductRatePlans[0].Id,
                                                                Unit_price__c = 500,
                                                                Cost_Price__c = 250,
                                                                Product_Charge_Category__c = 'Taxable',
                                                                Price_Type__c = 'Usage',
                                                                Price_Format__c = 'Volume Pricing'                                                              
                                                                );   
          listProductRatePlanCharges.add(productRatePlanCharge_Usage);                                
          insert listProductRatePlanCharges;
          
          list<Product_Rate_Plan_Charge_Tier__c> listProductRatePlanChargesTiers = new list<Product_Rate_Plan_Charge_Tier__c>();
          Product_Rate_Plan_Charge_Tier__c productRatePlanChargeTier = new Product_Rate_Plan_Charge_Tier__c(Start_Unit__c = 1,
                                                                                    End_Unit__c = 10,
                                                                                    Unit_Price__c =100,
                                                                                    Product_Rate_Plan_Charge__c =listProductRatePlanCharges[1].Id
                                                                                    );
          listProductRatePlanChargesTiers.add(productRatePlanChargeTier);
          insert listProductRatePlanChargesTiers; 
          
          Product_Bundle__c productBundle = new Product_Bundle__c(Name ='Budle Test',
                                                      Start_Date__c=validtodate,
                                                      Currency__c = currencyObj.Id,
                                                      Bundle_Type__c='Bundle',
                                                      Bundle_Price__c=100,
                                                      Quantity__c = 1,
                                                      Price_Type__c='Monthly',
                                                      Pricing_Model__c='Default'
                                                      ); 
          insert productBundle;
          
          Product_Bundle_Line__c productBundleLine = new Product_Bundle_Line__c(Product_Bundle__r = productBundle,
                                                  Product__c = product.Id,
                                                  Product_Rate_Plan__c = listProductRatePlans[0].Id,
                                                  Product_Rate_Plan_Charge__c = listProductRatePlanCharges[0].Id);
                                                                                        
          Job__c orderObj = new Job__c(Renew_to__c = 'Quote', Auto_Renew__c = true,Auto_Renewal_Complete__c=false, Renewal_Terms_Months__c=12, Name = 'TestOrder',Account__c=accountObj.Id,CurrencyL__c=currencyObj.Id,Billing_Contact__c=contact.id,Service_Activation_Date__c=validtodate,Start_Date__c=validtodate,Service_End_Date__c=validtodate);
          insert orderObj;
          
          list<Job_Product__c> listOfJobProducts = new list<Job_Product__c>();        
        
          Job_Product__c  jobProduct = new Job_Product__c(Name = 'JobProduct',Product__c=product.Id,Job__c = orderObj.Id);
          listOfJobProducts.add(jobProduct);
          
          Job_Product__c jobProductBundle = new Job_Product__c(Name = 'JobProductBundle',Job__c = orderObj.Id,Bundle_SequenceNumber__c =1,Product_Bundle__c=productBundle.Id);
          listOfJobProducts.add(jobProductBundle);
          
          Job_Product__c jobProductBundle2 = new Job_Product__c(Name = 'JobProductBundle2',Job__c = orderObj.Id,Bundle_SequenceNumber__c =1,Product__c=product.Id,Product_Bundle__c=productBundle.Id);
          listOfJobProducts.add(jobProductBundle2);        
          insert listOfJobProducts;
          
          list<Job_Rate_Plan__c> listOfJobRatePlans = new list<Job_Rate_Plan__c>();
          Job_Rate_Plan__c jobRP = new Job_Rate_Plan__c(Name = 'JobRP',Product_Rate_Plan__c = productRatePlan.Id,Job_Product__c = listOfJobProducts[0].Id);
          listOfJobRatePlans.add(jobRP);
          
          Job_Rate_Plan__c jobRPBundle = new Job_Rate_Plan__c(Name = 'JobRPBundle',Job_Product__c =listOfJobProducts[1].Id);
          listOfJobRatePlans.add(jobRPBundle);
          
          Job_Rate_Plan__c jobRPBundle2 = new Job_Rate_Plan__c(Name = 'JobRPBundle2',Job_Product__c =listOfJobProducts[2].Id,Product_Rate_Plan__c = productRatePlan.Id);
          listOfJobRatePlans.add(jobRPBundle2);
          insert listOfJobRatePlans;
                   
          list<Job_Rate_Plan_Charge__c> listOfJobChrges = new list<Job_Rate_Plan_Charge__c>();
          Job_Rate_Plan_Charge__c jobCharge = new Job_Rate_Plan_Charge__c(Order__c=orderObj.Id,Name = 'JobRPC',Product_Rate_Plan_Charge__c = productRatePlanCharge_Usage.id, Job_Rate_Plan__c =listOfJobRatePlans[0].Id,Status__c = 'Draft',Quantity__c = 12,Unit_Price__c = 12,Service_Activation_Date__c=validtodate,Service_End_Date__c=validtodate,Auto_Renew__c=true,Uplift__c=10);
          listOfJobChrges.add(jobCharge);
           
          Job_Rate_Plan_Charge__c jobBundleCharge = new Job_Rate_Plan_Charge__c(Order__c=orderObj.Id, Name = 'JobRPBundleCharge',Job_Rate_Plan__c =listOfJobRatePlans[1].Id, Status__c = 'Draft',Quantity__c = 1,Unit_Price__c = 100,Service_Activation_Date__c = validtodate,Service_End_Date__c = validtodate,Auto_Renew__c = true,Uplift__c=10);
          listOfJobChrges.add(jobBundleCharge);
          
          Job_Rate_Plan_Charge__c jobBundlelLineCharge = new Job_Rate_Plan_Charge__c(Order__c=orderObj.Id, Name = 'JobRPBundleLineCharge',Product_Rate_Plan_Charge__c = productRatePlanCharge_SetUp.id, Job_Rate_Plan__c =listOfJobRatePlans[2].Id,Status__c = 'Draft',Quantity__c = 1,Unit_Price__c = 0,Service_Activation_Date__c=validtodate,Service_End_Date__c=validtodate,Auto_Renew__c=true,Uplift__c=10,Product_Bundle_Line__c = productBundleLine.id);
          listOfJobChrges.add(jobBundlelLineCharge);
          insert listOfJobChrges;
                    
          Job_Rate_Plan_Charge_Tier__c tier = new Job_Rate_Plan_Charge_Tier__c(Start_Unit__c=1,End_Unit__c=100, Unit_Price__c=10,Job_Rate_Plan_Charge__c=listOfJobChrges[0].id);
          insert tier;
          
          ApexPages.StandardController controller = new ApexPages.StandardController(orderObj);
          ClassOrderProductsInlineAJS ClassOrderProductsInlineAJS = new ClassOrderProductsInlineAJS(controller ); 
          Configuration__c config = Configuration__c.getValues('INVOICEIT_BATCH_JOBS_TO_PROCESS');
          config.String_Value__c = 'Auto Renewals';
          update config;
          
          System.Test.StartTest();
              RunSchedulerRenewOrders sh1 = new RunSchedulerRenewOrders();
              String sch = '0 0 23 * * ?';
              system.schedule('RunSchedulerRenewOrders', sch, sh1);

              BatchRenewOrders batch = new BatchRenewOrders(true);
             ID batchprocessid = Database.executeBatch(batch, 1);
          System.Test.stopTest();

      }
  }