/*
  This Class is created by Devender for RevenueTransactionsUtilClass,
  RevenueRecognitionUtilClass, RevenueForecastsUtilClass and RevenueTransactionsForCreditLines.
  Created Date- 02/06/2015
   */
  @isTest(seealldata=false)
  public with sharing class TestClassforRevenueRecognition {

    static testMethod void testrevenueRecognition() {
      ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
      ControllerInsertCustomSettings.insertValues();
   
      Account account = new Account(Name = 'Test Account');
      insert account;

      Account account1 = [select Name From Account Where Id =: account.id];
      System.assertEquals('Test Account', account1.Name);
       
      contact c = new Contact(LastName = 'Sandeep',accountId = account.Id,MailingCountry = 'UK',Email ='laxmanrao.564@gmail.com');
      insert c;

      Currency__c currency1 = new Currency__c(name = 'USD', Symbol__c = '$');
      insert currency1;
      
      Revenue_Recognition_Rule__c revenuerule1=new Revenue_Recognition_Rule__c(Recognition_Date__c='Service Activation Date',Recognition_Type__c='Daily Recognition Over Time');
      insert revenuerule1;
      
      Revenue_Recognition_Rule__c revenuerule2=new Revenue_Recognition_Rule__c(Recognition_Date__c='Revenue Recognition Start Date',Recognition_Type__c='Monthly Recognition Over Time');
      insert revenuerule2;
      
      Revenue_Recognition_Rule__c revenuerule3=new Revenue_Recognition_Rule__c(Recognition_Date__c='Service End Date',Recognition_Type__c='Full Recognition on Specific Date');
      insert revenuerule3;
      
      Revenue_Recognition_Rule__c revenuerule4=new Revenue_Recognition_Rule__c(Recognition_Date__c='Revenue Recognition End Date',Recognition_Type__c='Monthly Recognition Over Time');
      insert revenuerule4;

      list<Revenue_Period__c> revenuePeriods = new list<Revenue_Period__c>();
      Revenue_Period__c revenuePeriod;
      Date myDateTime; 
      map<integer, string> mapDate = new map<integer, string>();
      mapDate.put(1, 'January');
      mapDate.put(2, 'February');
      mapDate.put(3, 'March');
      mapDate.put(4, 'April');
      mapDate.put(5, 'May');
      mapDate.put(6, 'June');
      mapDate.put(7, 'July');
      mapDate.put(8, 'August');
      mapDate.put(9, 'September');
      mapDate.put(10, 'October');
      mapDate.put(11, 'November');
      mapDate.put(12, 'December');

      integer year = system.today().year()-1;
      for(integer j=1; j<=3; j++) {
        for(integer i=1; i<=12; i++) {
          myDateTime = Date.newInstance(year+j, i, 1);    
          revenuePeriod = new  Revenue_Period__c(Revenue_Period_Start_Date__c = myDateTime);
          revenuePeriod.Revenue_Period_End_Date__c = myDateTime.addMonths(1);
          revenuePeriod.Revenue_Period_End_Date__c = revenuePeriod.Revenue_Period_End_Date__c.addDays(-1);
          revenuePeriod.Name = mapDate.get(i) + '-' + string.valueOf(myDateTime.year());
          revenuePeriods.add(revenuePeriod);
        }
      }

      insert revenuePeriods;
       
      Job__c job = new Job__c(Account__c = account.id,Billing_Contact__c = c.Id,
                Shipping_Contact__c = c.Id, Sub_Total__c = 100, Discount_Value__c = 0,
                Service_End_Date__c =  System.today().addDays(365),
                Number_Of_Terms__c = 10,
                Service_Activation_Date__c = System.today(),
                CurrencyL__c = currency1.Id,
                Status__c = 'In Progress');
      insert job;
    
      Job_Product__c  jobProduct= new Job_Product__c(Name = 'jobProduct',Job__c = job.Id);
      insert jobProduct;

      Job_Rate_Plan__c jobRP = new Job_Rate_Plan__c(Name = 'JobRP',Job_Product__c =jobProduct.Id);
      insert jobRP;

      list<Job_Rate_Plan_Charge__c> listofCharge = new list<Job_Rate_Plan_Charge__c>();

      Job_Rate_Plan_Charge__c charge = new Job_Rate_Plan_Charge__c(Status__c = 'In Progress', Name = 'jobRPC',Service_End_Date__c =  System.today().addDays(365),Service_Activation_Date__c=system.TODAY(),Revenue_Recognition_Rule__c=revenuerule1.Id,Price_Type__c='Annual',Job_Rate_Plan__c =jobRP.Id,Min_Customer_Spend__c = 230,Quantity__c = 12,Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c = 50, Net_Total__c = 200);
      listofCharge.add(charge);
     
      Job_Rate_Plan_Charge__c charge2 = new Job_Rate_Plan_Charge__c(Revenue_Recognition_Start_Date__c = System.today(), Revenue_Recognition_End_Date__c = System.today().addDays(365), Status__c = 'In Progress', Name = 'jobRPC2',Service_End_Date__c =  System.today().addDays(365),Service_Activation_Date__c=system.TODAY(),Revenue_Recognition_Rule__c=revenuerule2.Id,Price_Type__c='Half Yearly', Job_Rate_Plan__c =jobRP.Id,Quantity__c = 12,Min_Customer_Spend__c = 230,Accounting_Code__c = '12345',Unit_Price__c = 30,Price__c = 50, Net_Total__c = 200);
      listofCharge.add(charge2);
     
      Job_Rate_Plan_Charge__c charge3 = new Job_Rate_Plan_Charge__c(Status__c = 'In Progress', Name = 'jobRPC3',Service_End_Date__c =  System.today().addDays(365),Committed_Quantity__c= 8,Service_Activation_Date__c=system.TODAY(),Revenue_Recognition_Rule__c=revenuerule3.Id,Price_Type__c='Quarterly', Job_Rate_Plan__c =jobRP.Id,Quantity__c = 12,Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c = 50, Net_Total__c = 200,VSOE_Pricing__c = 30,VSOE_Total__c = 30,VSOE_Package_Total__c = 30,Required_By__c = charge.id);
      listofCharge.add(charge3);
     
      Job_Rate_Plan_Charge__c charge4 = new Job_Rate_Plan_Charge__c(Revenue_Recognition_Start_Date__c = System.today(), Revenue_Recognition_End_Date__c = System.today().addDays(90),Status__c = 'In Progress', Name = 'jobRPC4',Service_End_Date__c =  System.today().addDays(365),Service_Activation_Date__c=system.TODAY(),Revenue_Recognition_Rule__c=revenuerule4.Id,Price_Type__c='Quarterly', Job_Rate_Plan__c =jobRP.Id,Quantity__c = 12,Accounting_Code__c = '12345',Unit_Price__c = 663,Price__c = 50, Net_Total__c = 200);
      listofCharge.add(charge4);

      Job_Rate_Plan_Charge__c charge5 = new Job_Rate_Plan_Charge__c(Status__c = 'In Progress', Name = 'jobRPC',Service_End_Date__c =  System.today().addDays(365),Service_Activation_Date__c=system.TODAY(),Revenue_Recognition_Rule__c=revenuerule1.Id,Price_Type__c='One Time',Job_Rate_Plan__c =jobRP.Id,Min_Customer_Spend__c = 230,Quantity__c = 12,Accounting_Code__c = '12345',Unit_Price__c = 12,Price__c = 50, Net_Total__c = 200);
      listofCharge.add(charge5);

      insert listofCharge;

      // This is used to call depricated class
      RevenueRecognitionUtilClass RevenueRecognitionUtilClassobj = new RevenueRecognitionUtilClass();
    
      RevenueRecognitionUtilClassobj.createRevenueForecastForOrder(job.id);
      RevenueRecognitionUtilClassobj.createRevenueForecastForOrderCharge(charge.id);

      list<Job_Rate_Plan_Charge__c> listofChargeNew = new list<Job_Rate_Plan_Charge__c>();

      for(Job_Rate_Plan_Charge__c charges : listofCharge) {
        listofChargeNew.add( new Job_Rate_Plan_Charge__c(Id = charges.Id, Recalculate_Revenue_Forecasts__c = true));
      }

      update listofChargeNew;
          
      test.startTest();
           
      ApexPages.Standardcontroller controllerJob = new Apexpages.Standardcontroller(job);
      ControllerGenerateInvoice controllerGenerateInvoice = new ControllerGenerateInvoice(controllerJob);
      controllerGenerateInvoice.job = job;
      controllerGenerateInvoice.generateInvoice();    
       
      Invoice_RunScheduler__c invoiceRunScheduler = new Invoice_RunScheduler__c(Type__c = 'Once',Invoice_Date__c = system.today(),Target_Date__c = system.today(),Start_date_and_time__c = system.now().addMinutes(20),Invoice_Currency__c = currency1.Id);
      insert invoiceRunScheduler;
         
      Invoice_Run__c invoiceRun = new Invoice_Run__c(Status__c = 'Completed', Name = 'Run');
      insert invoiceRun;
         
      // This is call the RevenueTransactionsUtilClass
         
      ClassAfterOnInvoice.INVOICE_AFTER_PROCESSING_COMPLETE = false;    
      Invoice__c invoiceObj = new Invoice__c ();
      invoiceObj.Invoice_Status__c = 'Posted';
      invoiceObj.Invoice_Run_Created_By__c = invoiceRun .Id;
      invoiceObj.Account__c=account.id;
      insert invoiceObj;

      list<Revenue_Recognition_Rule__c> listRevenueRecognitionRules = new list<Revenue_Recognition_Rule__c>();
      Revenue_Recognition_Rule__c rRRule = new Revenue_Recognition_Rule__c(Name='Test',Recognition_Type__c='Manual Recognition',Recognition_Date__c='Revenue Recognition Start Date');
      Revenue_Recognition_Rule__c rRRule1 = new Revenue_Recognition_Rule__c(Name='Test',Recognition_Type__c='Monthly Recognition Over Time',Recognition_Date__c='Revenue Recognition Start Date');
      Revenue_Recognition_Rule__c rRRule2 = new Revenue_Recognition_Rule__c(Name='Test',Recognition_Type__c='Daily Recognition Over Time',Recognition_Date__c='Revenue Recognition Start Date');
       Revenue_Recognition_Rule__c rRRule3 = new Revenue_Recognition_Rule__c(Name='Test',Recognition_Type__c='Weighted Monthly Recognition Over Time',Recognition_Date__c='Revenue Recognition Start Date');
       Revenue_Recognition_Rule__c rRRule4 = new Revenue_Recognition_Rule__c(Name='Test',Recognition_Type__c='Full Recognition on Specific Date',Recognition_Date__c='Revenue Recognition Start Date');
       listRevenueRecognitionRules.add(rRRule);
       listRevenueRecognitionRules.add(rRRule1);
       listRevenueRecognitionRules.add(rRRule2);
       listRevenueRecognitionRules.add(rRRule3);
       listRevenueRecognitionRules.add(rRRule4);
       insert listRevenueRecognitionRules;
       Revenue_Recognition_Schedule__c rRevenueSchedule = new Revenue_Recognition_Schedule__c(Name = '123', Revenue_Recognition_Rule__c = listRevenueRecognitionRules[0].id,Revenue_Percent__c = 100  , Schedule_Date__c = system.today());
       insert rRevenueSchedule;
             
          list<Invoice_Lines__c> listOfInvoiceLines= new list<Invoice_Lines__c>();
          Invoice_Lines__c invoiceline= new Invoice_Lines__c ();
          invoiceline.Invoice__c=invoiceObj.id;
          invoiceline.Job__c=job.id;
          invoiceline.Line_Amount__c = 100;
          invoiceline.Tax__c = 1;
          invoiceline.VAT__c = 1;
          invoiceline.Price_Type__c = 'One Time';
          invoiceline.Revenue_Recognition_Rule__c = listRevenueRecognitionRules[0].id;
          invoiceline.Revenue_Recognition_Start_Date__c = system.today();
          invoiceline.Revenue_Recognition_End_Date__c = system.today() + 1;
          invoiceline.Job_Rate_Plan_Charge__c = charge3.id;
          insert invoiceline; 

          Invoice_Lines__c invoiceline1= new Invoice_Lines__c ();
          invoiceline1.Invoice__c=invoiceObj.id;
          invoiceline1.Job__c=job.id;
          invoiceline1.Line_Amount__c = 100;
          invoiceline1.Tax__c = 1;
          invoiceline1.VAT__c = 1;
          invoiceline.Price_Type__c = 'Annual';
          invoiceline1.Revenue_Recognition_Rule__c = listRevenueRecognitionRules[1].id;
          invoiceline1.Revenue_Recognition_Start_Date__c = system.today();
          invoiceline1.Revenue_Recognition_End_Date__c = system.today() + 1;
          invoiceline1.Job_Rate_Plan_Charge__c = charge3.id;
          insert invoiceline1;
          Invoice_Lines__c invoiceline2= new Invoice_Lines__c ();
          invoiceline2.Invoice__c=invoiceObj.id;
          invoiceline2.Job__c=job.id;
          invoiceline2.Line_Amount__c = 100;
          invoiceline2.Tax__c = 1;
          invoiceline2.VAT__c = 1;
          invoiceline.Price_Type__c = 'Half Yearly';
          invoiceline2.Revenue_Recognition_Rule__c = listRevenueRecognitionRules[2].id;
          invoiceline2.Revenue_Recognition_Start_Date__c = system.today();
          invoiceline2.Revenue_Recognition_End_Date__c = system.today() + 1;
          invoiceline2.Job_Rate_Plan_Charge__c = charge3.id;
          insert invoiceline2;
          Invoice_Lines__c invoiceline3= new Invoice_Lines__c ();
          invoiceline3.Invoice__c=invoiceObj.id;
          invoiceline3.Job__c=job.id;
          invoiceline3.Line_Amount__c = 100;
          invoiceline3.Tax__c = 1;
          invoiceline3.VAT__c = 1;
          invoiceline.Price_Type__c = 'Quarterly';
          invoiceline3.Revenue_Recognition_Rule__c = listRevenueRecognitionRules[3].id;
          invoiceline3.Revenue_Recognition_Start_Date__c = system.today();
          invoiceline3.Revenue_Recognition_End_Date__c = system.today() + 1;
          invoiceline3.Job_Rate_Plan_Charge__c = charge3.id;
          insert invoiceline3;
          Invoice_Lines__c invoiceline4= new Invoice_Lines__c ();
          invoiceline4.Invoice__c=invoiceObj.id;
          invoiceline4.Job__c=job.id;
          invoiceline4.Line_Amount__c = 100;
          invoiceline4.Tax__c = 1;
          invoiceline4.VAT__c = 1;
          invoiceline4.Revenue_Recognition_Rule__c = listRevenueRecognitionRules[4].id;
          invoiceline4.Revenue_Recognition_Start_Date__c = system.today();
          invoiceline4.Revenue_Recognition_End_Date__c = system.today() + 1;
          invoiceline4.Job_Rate_Plan_Charge__c = charge3.id;
          insert invoiceline4;
           listOfInvoiceLines.add(invoiceline);
           listOfInvoiceLines.add(invoiceline1);
           listOfInvoiceLines.add(invoiceline2);
           listOfInvoiceLines.add(invoiceline3);
           listOfInvoiceLines.add(invoiceline4);
           list<id> listOfInvoiceLinesIds= new list<id>();
            Map<Id,Invoice_Lines__c> mapinvoice =  new Map<Id,Invoice_Lines__c>(listOfInvoiceLines);
           Set<Id> setOfRecordIds = (mapinvoice).keySet();
           listOfInvoiceLinesIds.addall(setOfRecordIds);
          BatchProcessRevenueForInvoiceLines batch1=new BatchProcessRevenueForInvoiceLines(listOfInvoiceLinesIds);
          database.executebatch(batch1, 30);

          RunSchedulerForRevenueTransactions sh1 = new RunSchedulerForRevenueTransactions();
           
          String sch = '0 0 23 * * ?';
          system.schedule('RunSchedulerRenewOrders', sch, sh1);
              
         ApexPages.Standardcontroller stdController = new Apexpages.Standardcontroller(invoiceObj);        
         ControllerCancelInvoice controllerCancelInvoiceObj = new ControllerCancelInvoice(stdController);
         ClassAfterOnInvoice.INVOICE_AFTER_PROCESSING_COMPLETE = false; 
         ControllerCancelInvoice.isButtonClicked = true;
         controllerCancelInvoiceObj.cancelInvoice(); 

         Credit_Note__c creditNote = new Credit_Note__c(Account__c = account.id, Related_Invoice__c = invoiceObj.id, Order__c = job.id, CurrencyL__c = currency1.id, Credit_Note_Status__c = 'Posted');
         insert creditNote;

         Credit_Line__c creditLines = new Credit_Line__c(Credit_Note__c = creditNote.id, Invoice__c = invoiceObj.id, Order__c = job.id, CurrencyL__c = currency1.id, Quantity__c = 5,Unit_Price__c = 10,Line_Amount__c = 50, Revenue_Recognition_Status__c = 'Queued',Revenue_Recognition_Rule__c = listRevenueRecognitionRules[0].id,Revenue_Recognition_Start_Date__c = system.today(),Revenue_Recognition_End_Date__c = system.today()+1, VAT__c = 1, Tax__c = 1,Order_Rate_Plan_Charge__c = charge3.id,Price_Type__c = 'One Time'); 
         insert creditLines; 
         Credit_Line__c creditLines1 = new Credit_Line__c(Credit_Note__c = creditNote.id, Invoice__c = invoiceObj.id, Order__c = job.id, CurrencyL__c = currency1.id, Quantity__c = 5,Unit_Price__c = 10,Line_Amount__c = 50, Revenue_Recognition_Status__c = 'Queued',Revenue_Recognition_Rule__c = listRevenueRecognitionRules[1].id,Revenue_Recognition_Start_Date__c = system.today(),Revenue_Recognition_End_Date__c = system.today()+1, VAT__c = 1, Tax__c = 1,Order_Rate_Plan_Charge__c = charge3.id); 
         insert creditLines1; 
         Credit_Line__c creditLines2 = new Credit_Line__c(Credit_Note__c = creditNote.id, Invoice__c = invoiceObj.id, Order__c = job.id, CurrencyL__c = currency1.id, Quantity__c = 5,Unit_Price__c = 10,Line_Amount__c = 50, Revenue_Recognition_Status__c = 'Queued',Revenue_Recognition_Rule__c = listRevenueRecognitionRules[2].id,Revenue_Recognition_Start_Date__c = system.today(),Revenue_Recognition_End_Date__c = system.today()+1, VAT__c = 1, Tax__c = 1,Order_Rate_Plan_Charge__c = charge3.id); 
         insert creditLines2; 
         Credit_Line__c creditLines3 = new Credit_Line__c(Credit_Note__c = creditNote.id, Invoice__c = invoiceObj.id, Order__c = job.id, CurrencyL__c = currency1.id, Quantity__c = 5,Unit_Price__c = 10,Line_Amount__c = 50, Revenue_Recognition_Status__c = 'Queued',Revenue_Recognition_Rule__c = listRevenueRecognitionRules[3].id,Revenue_Recognition_Start_Date__c = system.today(),Revenue_Recognition_End_Date__c = system.today()+1, VAT__c = 1, Tax__c = 1,Order_Rate_Plan_Charge__c = charge3.id); 
         insert creditLines3; 
         Credit_Line__c creditLines4 = new Credit_Line__c(Credit_Note__c = creditNote.id, Invoice__c = invoiceObj.id, Order__c = job.id, CurrencyL__c = currency1.id, Quantity__c = 5,Unit_Price__c = 10,Line_Amount__c = 50, Revenue_Recognition_Status__c = 'Queued',Revenue_Recognition_Rule__c = listRevenueRecognitionRules[4].id,Revenue_Recognition_Start_Date__c = system.today(),Revenue_Recognition_End_Date__c = system.today()+1, VAT__c = 1, Tax__c = 1,Order_Rate_Plan_Charge__c = charge3.id); 
         insert creditLines4; 

         RunSchedulerForRevenueTransactions sh12 = new RunSchedulerForRevenueTransactions();
         String sch1 = '0 0 23 * * ?';
         system.schedule('RunSchedulerRenewOrders2', sch1, sh12);
            
      test.stopTest();  
    }
  }