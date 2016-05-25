@isTest(seeAllData = false)
  public with sharing class TestControllerInvoiceRun {
      
        public static  list<Job__c> create_Orders() {
         // ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
        //  ControllerInsertCustomSettings.insertValues();
          
          Date validtodate = Date.today();   
          Product__c product;
          list<Product_Rate_Plan__c> listProductRatePlans = new list<Product_Rate_Plan__c>();
          Product_Rate_Plan__c productRatePlan;
          list<Product_Rate_Plan_Charge__c> listProductRatePlanCharges = new list<Product_Rate_Plan_Charge__c>();
          
          Currency__c currency1 = new Currency__c(name = 'GBP', Currency_Symbol__c = '£12', Symbol__c = '£12');
          insert currency1;
          
          product = new  Product__c(Name = 'Hosting Services',
                                    Valid_From_Date__c = validtodate,
                                    Product_Family__c = 'Default',
                                    Product_Code__c = 'HS1',
                                    Description__c = 'Product'
                                    );
          insert product;
          
          Product__c product1 = [SELECT Name FROM Product__c WHERE id=:product.id];
          System.assertEquals('Hosting Services', product1.Name);

          productRatePlan = new  Product_Rate_Plan__c(Name = 'Default',
                                                        Product__c = product.Id,
                                                        Valid_From_Date__c = validtodate,
                                                        Description__c = 'Product RatePlan'
                                                        );
          insert productRatePlan;    
          
          Product_Rate_Plan_Charge__c productRatePlanCharge_SetUp = new Product_Rate_Plan_Charge__c(Name = 'Setup Charges',
                                                                    CurrencyL__c = currency1.Id,
                                                                    Product_Rate_Plan__c = productRatePlan.Id,
                                                                    Unit_price__c = 1000,
                                                                    Cost_Price__c = 500,
                                                                    Product_Charge_Category__c = 'Taxable',
                                                                    Price_Type__c = 'One Time'
                                                                    );
          
          Product_Rate_Plan_Charge__c productRatePlanCharge_Monthly = new Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                                                                    CurrencyL__c = currency1.Id,
                                                                    Product_Rate_Plan__c = productRatePlan.Id,
                                                                    Unit_price__c = 500,
                                                                    Cost_Price__c = 250,
                                                                    Product_Charge_Category__c = 'Taxable',
                                                                    Price_Type__c = 'Monthly'
                                                                    );
          
          
                                                                                                                                                                                                                                                  
          Product_Rate_Plan_Charge__c productRatePlanCharge_Usage = new Product_Rate_Plan_Charge__c(Name = 'Usage Charges',
                                                                    CurrencyL__c = currency1.Id,
                                                                    Product_Rate_Plan__c = productRatePlan.Id,
                                                                    Unit_price__c = 0,
                                                                    Cost_Price__c = 0,
                                                                    Product_Charge_Category__c = 'Taxable',
                                                                    Price_Type__c = 'Usage',
                                                                    Price_Format__c = CommonUtilClass.PRICE_FORMAT_VOLUME
                                                                    ); 
                                                                                                                             
          Product_Rate_Plan_Charge__c productRatePlanCharge_Usage_Tier = new Product_Rate_Plan_Charge__c(Name = 'Usage Charges',
                                                                    CurrencyL__c = currency1.Id,
                                                                    Product_Rate_Plan__c = productRatePlan.Id,
                                                                    Unit_price__c = 0,
                                                                    Cost_Price__c = 0,
                                                                    Product_Charge_Category__c = 'Taxable',
                                                                    Price_Type__c = 'Usage',
                                                                    Price_Format__c = CommonUtilClass.PRICE_FORMAT_TIERED
                                                                    );
                                                                    
          Product_Rate_Plan_Charge__c productRatePlanCharge_OptionAnnual = new Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                                                                    CurrencyL__c = currency1.Id,
                                                                    Product_Rate_Plan__c = productRatePlan.Id,
                                                                    Unit_price__c = 500,
                                                                    Cost_Price__c = 250,
                                                                    Product_Charge_Category__c = 'Taxable',
                                                                    Price_Type__c = System.Label.OptionAnnual
                                                                    );
                                                                    
          Product_Rate_Plan_Charge__c productRatePlanCharge_HalfYearly = new Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                                                                    CurrencyL__c = currency1.Id,
                                                                    Product_Rate_Plan__c = productRatePlan.Id,
                                                                    Unit_price__c = 500,
                                                                    Cost_Price__c = 250,
                                                                    Product_Charge_Category__c = 'Taxable',
                                                                    Price_Type__c = System.Label.OptionHalfYearly
                                                                    );
          
          Product_Rate_Plan_Charge__c productRatePlanCharge_Weekly = new Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                                                                    CurrencyL__c = currency1.Id,
                                                                    Product_Rate_Plan__c = productRatePlan.Id,
                                                                    Unit_price__c = 500,
                                                                    Cost_Price__c = 250,
                                                                    Product_Charge_Category__c = 'Taxable',
                                                                    Price_Type__c = System.Label.OptionWeekly
                                                                    );
                                                                                                                              
          Product_Rate_Plan_Charge__c productRatePlanCharge_Quarterly = new Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                                                                    CurrencyL__c = currency1.Id,
                                                                    Product_Rate_Plan__c = productRatePlan.Id,
                                                                    Unit_price__c = 500,
                                                                    Cost_Price__c = 250,
                                                                    Product_Charge_Category__c = 'Taxable',
                                                                    Price_Type__c = System.Label.OptionQuarterly
                                                                    );
                                                                    
          listProductRatePlanCharges.add(productRatePlanCharge_SetUp);
          listProductRatePlanCharges.add(productRatePlanCharge_Monthly);
          listProductRatePlanCharges.add(productRatePlanCharge_Usage);
          listProductRatePlanCharges.add(productRatePlanCharge_Usage_Tier);
          listProductRatePlanCharges.add(productRatePlanCharge_OptionAnnual);
          listProductRatePlanCharges.add(productRatePlanCharge_HalfYearly);
          listProductRatePlanCharges.add(productRatePlanCharge_Weekly);
          listProductRatePlanCharges.add(productRatePlanCharge_Quarterly);
          insert listProductRatePlanCharges;
          
          list<Product_Rate_Plan_Charge_Tier__c> tiers = new list<Product_Rate_Plan_Charge_Tier__c>();
          Product_Rate_Plan_Charge_Tier__c tier1 = new Product_Rate_Plan_Charge_Tier__c(Start_Unit__c = 1,
                                                   End_Unit__c = 500,
                                                   Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(2).Id,
                                                   Unit_Cost_Price__c = 0.20,
                                                   Unit_Price__c = 2);
                                                   
          Product_Rate_Plan_Charge_Tier__c tier2 = new Product_Rate_Plan_Charge_Tier__c(Start_Unit__c = 501,
                                                   End_Unit__c = 1000,
                                                   Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(2).Id,
                                                   Unit_Cost_Price__c = 0.20,
                                                   Unit_Price__c = 1);
                                                   
          Product_Rate_Plan_Charge_Tier__c tier3 = new Product_Rate_Plan_Charge_Tier__c(Start_Unit__c = 1001,
                                                   End_Unit__c = 300000,
                                                   Product_Rate_Plan_Charge__c = listProductRatePlanCharges.get(2).Id,
                                                   Unit_Cost_Price__c = 0.10,
                                                   Unit_Price__c = 0.50);
          tiers.add(tier1);
          tiers.add(tier2);
          tiers.add(tier3);
          insert tiers;   
          
          integer m = system.today().day();
          string s = string.ValueOf(m);
          
          Account account = new Account(name = 'Test Account',Preferred_Billing_Day__c = s);
          insert account;
          //ClassPopulateTestData.createPayment(account, currency1);
          list<Contact> listContacts = new list<Contact>();
          listContacts.add(new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK'));
          listContacts.add(new Contact(LastName = 'Manoj GanPathy',accountId = account.Id, MailingCountry = 'USA',MailingPostalCode = '60001'));
          listContacts.add(new Contact(LastName = 'Anil',accountId = account.Id, MailingCountry = 'USA',MailingPostalCode = '60001'));
          listContacts.add(new Contact(LastName = 'Vinod',accountId = account.Id, MailingCountry = 'USA', MailingPostalCode = '60001'));
          
          insert listContacts;
          
          list<Job__c> listOfJobs = new list<Job__c>();
          list<Usage_Charge__c> listOfUsageChargesToBeInserted = new list<Usage_Charge__c>();
          Usage_Charge__c usageChargeObj;
          for(integer i = 0;i < 3;i++) {
              String pbd = string.ValueOf(system.today().day());
              Job__c job1 = new Job__c(Name = 'Test job' + i,CurrencyL__c = currency1.Id, Status__c = 'Ready to be Invoiced', 
                                       Service_Activation_Date__c = system.today(), Preferred_Billing_Day__c = pbd,Auto_Renew__c =true,
                                       Number_Of_Terms__c = 10, Account__c = account.Id, Billing_Contact__c = listContacts.get(1).Id, Shipping_Contact__c = listContacts.get(1).Id);
             
              //Test.setCurrentPageReference(new PageReference('Page.createAmendments'));
              ApexPages.Standardcontroller controller = new Apexpages.Standardcontroller(job1);
              CreateJobController createJobController = new CreateJobController(controller);
              
              
              //Move to the first page
              createJobController.step1();
              
              //Move to the second page
              createJobController.step2();

              //Set the Product id and name,so that we can fetch Product Rate Plans
              System.currentPageReference().getParameters().put('productId', product.Id);
              System.currentPageReference().getParameters().put('productName', product.name);
              createJobController.getRatePlansForProduct();
              
              //Save the Job
              createJobController.addJobCharges();
              createJobController.saveJob();
              
              for(JobProductClass qpc : createJobController.jobClass.jobProducts)
              {
                  for(JobRatePlanClass qrc : qpc.jobRatePlans)
                  {
                      for(JobRatePlanChargeClass qrpc :qrc.jobRatePlanCharges)
                      {
                          if(qrpc.jobrateplancharge.Price_Type__c == 'Usage') 
                          {
                             
                              usageChargeObj = new Usage_Charge__c(Order_Rate_Plan_Charge__c = qrpc.jobrateplancharge.Id, Quantity__c = 6000, Status__c = 'Un-billed', Start_Date__c = system.today(), End_Date__c = system.today());
                              listOfUsageChargesToBeInserted.add(usageChargeObj);
                          }
                          
                          qrpc.jobrateplancharge.Service_Activation_Date__c = system.today();
                      }
                  }
              }
              
              listOfJobs.add(createJobController.job);
            
          }
          
          insert listOfUsageChargesToBeInserted;                          
          
          ApexPages.Standardcontroller controllerJob = new Apexpages.Standardcontroller(listOfJobs.get(0));
          ControllerGenerateInvoice controllerGenerateInvoice = new ControllerGenerateInvoice(controllerJob);
          controllerGenerateInvoice.job = listOfJobs.get(0);
          controllerGenerateInvoice.generateInvoice();
          controllerGenerateInvoice.generateInvoiceAPI();
          
          return listOfJobs;                                                                                       
      }
      
       public static testMethod void testBatchClassGroupByAccount() {
          ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
          ControllerInsertCustomSettings.insertValues();
        
          list<Job__c> listOfJobs = create_Orders();
          
          Currency__c currency1 = [SELECT Id, Name, Currency_Symbol__c
                                   FROM Currency__c
                                   WHERE Name = 'GBP' 
                                   AND Currency_Symbol__c = '£12'
                                   AND Symbol__c = '£12'
                                   LIMIT 1];
          
          Invoice_RunScheduler__c invoiceRunScheduler = new Invoice_RunScheduler__c();
          invoiceRunScheduler.Type__c = 'Once';
          invoiceRunScheduler.Invoice_Date__c = system.today();
          invoiceRunScheduler.Target_Date__c = system.today();
          invoiceRunScheduler.Start_date_and_time__c = system.now().addMinutes(20);
          invoiceRunScheduler.Invoice_Currency__c = currency1.Id;
          invoiceRunScheduler.Automatically_Post_Invoices__c = true;
          insert invoiceRunScheduler;
          Invoice_RunScheduler__c invoiceRunScheduler1 = [SELECT Type__c FROM Invoice_RunScheduler__c WHERE id=:invoiceRunScheduler.id];
          System.assertEquals('Once', invoiceRunScheduler1.Type__c);

          system.Test.startTest();
          String orderStatusForInvoicing = (Configuration__c.getValues('ORDER_STATUS_FOR_INVOICING').String_Value__c);
          String groupBy = CommonUtilClass.INVOICING_GROUP_BY_ACCOUNT;
          String query;

          query = 'select id,Account__c from Job__c'; 
          
          query +=' where Account__c != null' +
                  ' and Service_Activation_Date__c <= '+ system.today() +
                  ' and(Charges_without_a_Charge_Date__c > 0' +  
                  ' or Minimum_Next_Charge_Date_For_Product__c <= '+ system.today()+')';
          
          //If the order's status field for invoicing is mentioned then use that in the where clause 
          if(orderStatusForInvoicing != null && orderStatusForInvoicing.trim().length() > 0){
              query += ' and Status__c = \''+orderStatusForInvoicing+'\'';
          }       
          
          query = query.replace(' 00:00:00','');
          query = query + 'LIMIT 2';
          
          BatchInvoiceGeneration1 batch1 = new BatchInvoiceGeneration1(query, 
                                                                      groupBy, 
                                                                      system.today(), 
                                                                      system.today(),
                                                                      invoiceRunScheduler.Invoice_Currency__c,
                                                                      invoiceRunScheduler.Name,
                                                                      invoiceRunScheduler.Id);
          ID batchprocessid2 = Database.executeBatch(batch1);
          //System.abortJob(batchprocessid2);
          system.Test.stopTest();
          
          list<Invoice_Run__c> listOfInvoiceRuns = [SELECT  Id,(Select Id,Invoice_Status__c From Invoices__r)
                                                     FROM  Invoice_Run__c 
                                                     WHERE Invoice_Run_Scheduler__c =: invoiceRunScheduler.Id];
          Invoice__c invoiceObj = new Invoice__c(Account__c = listOfJobs[0].Account__c,
                                              Billing_Contact__c = listOfJobs[0].Billing_Contact__c,
                                              Shipping_Contact__c = listOfJobs[0].Billing_Contact__c,
                                              CurrencyL__c = currency1.Id, 
                                              Target_Date__c = Date.today(),
                                              Delivery_Type__c = 'Both',
                                              Invoice_Status__c = CommonUtilClass.STATUS_DRAFT,
                                              Payment_Request_Amount__c = 20                                          
                                              );
          insert invoiceObj;
          ClassPopulateTestData.createListOfInvoiceLines(invoiceObj, listOfJobs[0]);
          Invoice_Run__c invoiceRun1 = new Invoice_Run__c(Invoice_Run_Scheduler__c = invoiceRunScheduler.Id, Start_Time__c = system.today(), Invoice_Date__c = date.today());
          insert invoiceRun1;                                      
          list<Invoice__c> listOfInvoices = new list<Invoice__c>();
          for(Invoice_Run__c invoiceRun : listOfInvoiceRuns) {
              for(Invoice__c invoice : invoiceRun.Invoices__r) {
                  listOfInvoices.add(new Invoice__c(Id = invoice.Id, Invoice_Status__c = CommonUtilClass.STATUS_POSTED));
              }
          }  
          invoiceObj.Invoice_Status__c = CommonUtilClass.STATUS_POSTED;
          listOfInvoices.add(invoiceObj); 
          upsert listOfInvoices;
          
          
          ApexPages.Standardcontroller standardController1 = new Apexpages.Standardcontroller(listOfInvoiceRuns[0]);
          ControllerInvoiceRun ControllerInvoiceRun = new ControllerInvoiceRun(standardController1);
          //ControllerInvoiceRun.emailAllInvoicesForInvoiceRun();
          ControllerInvoiceRun.backToInvoiceRun();

      }

  }