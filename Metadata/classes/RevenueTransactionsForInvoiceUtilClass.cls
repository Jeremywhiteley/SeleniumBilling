global with sharing class RevenueTransactionsForInvoiceUtilClass {

      WebService static string createRevenueTransactionForInvoice(list<Id> invoiceIds) {
          return processRevenueTransaction(invoiceIds, null, null);
      }

      WebService static string createRevenueTransactionForInvoiceLine(Id invoiceLineId) {
          return processRevenueTransaction(null, invoiceLineId, null);
      }

      //added by ram,21-8-2015, to process revenue transaction from batch class : BatchProcessRevenueForPostedInvoiceRun
      public static string processRevenueTransactionFromBatch(list<Id> listOfinvoiceLineIds) {
          return processRevenueTransaction(null, null, listOfinvoiceLineIds);
      }

      // modified by ram 8-21-2015, added one more parameter i.e, list<Id> listOfinvoiceLineIds
      // this new param would useful when we process via bacth classs
      public static string processRevenueTransaction(list<Id> invoiceId, Id invoiceLineId, list<Id> listOfinvoiceLineIds) {
          savepoint sp = database.setsavepoint();
          list<Invoice_Lines__c> listofInvoiceLines = new list<Invoice_Lines__c>();

          if((listOfinvoiceLineIds == null || listOfinvoiceLineIds.isEmpty()) && invoiceLineId != null){
              listOfinvoiceLineIds = new list<Id>();
              listOfinvoiceLineIds.add(invoiceLineId);
          }

          try {

              list<Revenue_Transaction__c> revenueTransactions = new list<Revenue_Transaction__c>();
              Date dCompare;
              Decimal recognisedRevenue;
              Decimal deferredRevenue;
              Revenue_Transaction__c revenueTransaction;

              //Get the list of all revenue periods in the org
              list<Revenue_Period__c> revenuePeriods;
              revenuePeriods = [select Id, Name, Revenue_Period_Start_Date__c, Revenue_Period_End_Date__c, Revenue_Period_Closed__c
                                FROM Revenue_Period__c
                                ORDER BY Revenue_Period_Start_Date__c LIMIT 10000];

              //This would store all the revenue transactions to delete
              //Everytime the revenue transaction are created for an order/charge, the older ones are deleted.
              list<Revenue_Transaction__c> revenueTransactionsToDelete;

              //If there are any rev rec rules that are of type Manual, we need to get all their schedules in a map
              map<Id,list<Revenue_Recognition_Schedule__c>> mapOfManualSchedules = new map<Id, list<Revenue_Recognition_Schedule__c>>();

              if (invoiceId != null) {
                  listofInvoiceLines = [SELECT Id, Total_Line_Amount__c, Tax__c, VAT__c, Revenue_Recognition_Rule__c, Price_Type__c, Calculated_Quantity__c,
                                        Revenue_Recognition_Rule__r.Recognition_Type__c, Revenue_Recognition_Rule__r.Recognition_Date__c, Revenue_Recognition_Rule__r.Name, 
                                        Revenue_Recognition_Rule__r.No_of_Manual_Schedules__c,Revenue_Recognition_Rule__r.First_Manual_Schedule_Month__c,
                                        Revenue_Recognition_Rule__r.First_Manual_Schedule_Date__c,Revenue_Recognition_Rule__r.Revenue_Recognition_Schedule_Total__c,
                                        Invoice__r.Account__c, Revenue_Recognition_Start_Date__c, Revenue_Recognition_End_Date__c,
                                        Service_Start_Date__c, Service_End_Date__c, Invoice_Lines__c.Job__c, Invoice__r.Order__r.Account__c,
                                        Invoice__r.Invoice_Date__c, Quantity__c, Unit_Price__c, Job_Rate_Plan_Charge__r.Row_Total__c,
                                        CurrencyL__c, CurrencyL__r.Name, Accounting_Code__c, Deferred_Revenue_Accounting_Code__c,Job_Rate_Plan_Charge__r.VSOE_Package_Total__c,
                                        Job_Rate_Plan_Charge__r.Bundle__c, Job_Rate_Plan_Charge__r.Package__c, Job_Rate_Plan_Charge__r.Required_By__c, 
                                        Job_Rate_Plan_Charge__r.VSOE_Pricing__c, Job_Rate_Plan_Charge__r.VSOE_Total__c, Job_Rate_Plan_Charge__r.Required_By__r.Unit_Price__c,
                                        Job_Rate_Plan_Charge__r.Required_By__r.Row_Total__c, Job_Rate_Plan_Charge__r.Required_By__r.VAT__c, Job_Rate_Plan_Charge__r.Required_By__r.Tax__c
                                        FROM Invoice_Lines__c
                                        WHERE Invoice__c IN: invoiceId
                                        AND Revenue_Recognition_Rule__c != null
                                        AND Invoice__r.Invoice_Status__c = 'Posted'
                                        AND Job_Rate_Plan_Charge__r.Package__c = false];
              } // modified by ram 8-21-2015, added if condition to check whether invoiceline id empty or not.
              else if (invoicelineId != null) {
                  listofInvoiceLines = [SELECT Id, Total_Line_Amount__c, Tax__c, VAT__c, Revenue_Recognition_Rule__c, Price_Type__c, Calculated_Quantity__c,
                                        Revenue_Recognition_Rule__r.Recognition_Type__c, Revenue_Recognition_Rule__r.Recognition_Date__c, Revenue_Recognition_Rule__r.Name,
                                        Revenue_Recognition_Rule__r.No_of_Manual_Schedules__c,Revenue_Recognition_Rule__r.First_Manual_Schedule_Month__c,
                                        Revenue_Recognition_Rule__r.First_Manual_Schedule_Date__c,Revenue_Recognition_Rule__r.Revenue_Recognition_Schedule_Total__c,
                                        Invoice__r.Account__c, Revenue_Recognition_Start_Date__c, Revenue_Recognition_End_Date__c,
                                        Service_Start_Date__c, Service_End_Date__c, Invoice_Lines__c.Job__c, Invoice__r.Order__r.Account__c,
                                        Invoice__r.Invoice_Date__c, Quantity__c, Unit_Price__c, Job_Rate_Plan_Charge__r.Row_Total__c,
                                        CurrencyL__c, CurrencyL__r.Name, Accounting_Code__c, Deferred_Revenue_Accounting_Code__c,Job_Rate_Plan_Charge__r.VSOE_Package_Total__c,
                                        Job_Rate_Plan_Charge__r.Bundle__c, Job_Rate_Plan_Charge__r.Package__c, Job_Rate_Plan_Charge__r.Required_By__c, 
                                        Job_Rate_Plan_Charge__r.VSOE_Pricing__c, Job_Rate_Plan_Charge__r.VSOE_Total__c, Job_Rate_Plan_Charge__r.Required_By__r.Unit_Price__c,
                                        Job_Rate_Plan_Charge__r.Required_By__r.Row_Total__c, Job_Rate_Plan_Charge__r.Required_By__r.VAT__c, Job_Rate_Plan_Charge__r.Required_By__r.Tax__c
                                        FROM Invoice_Lines__c
                                        WHERE Id = : invoicelineId
                                        AND Revenue_Recognition_Rule__c != null
                                        AND Invoice__r.Invoice_Status__c = 'Posted'
                                        AND Job_Rate_Plan_Charge__r.Package__c = false];
              }
              // modified by ram 8-21-2015, added else loop to identify revenue for multiple invoice line
              else {
                  listofInvoiceLines = [SELECT Id, Total_Line_Amount__c, Tax__c, VAT__c, Revenue_Recognition_Rule__c, Price_Type__c, Calculated_Quantity__c,
                                        Revenue_Recognition_Rule__r.Recognition_Type__c, Revenue_Recognition_Rule__r.Recognition_Date__c, Revenue_Recognition_Rule__r.Name,
                                        Revenue_Recognition_Rule__r.No_of_Manual_Schedules__c,Revenue_Recognition_Rule__r.First_Manual_Schedule_Month__c,
                                        Revenue_Recognition_Rule__r.First_Manual_Schedule_Date__c,Revenue_Recognition_Rule__r.Revenue_Recognition_Schedule_Total__c,
                                        Invoice__r.Account__c, Revenue_Recognition_Start_Date__c, Revenue_Recognition_End_Date__c,
                                        Service_Start_Date__c, Service_End_Date__c, Invoice_Lines__c.Job__c, Invoice__r.Order__r.Account__c,
                                        Invoice__r.Invoice_Date__c, Quantity__c, Unit_Price__c, Job_Rate_Plan_Charge__r.Row_Total__c,
                                        CurrencyL__c, CurrencyL__r.Name, Accounting_Code__c, Deferred_Revenue_Accounting_Code__c,Job_Rate_Plan_Charge__r.VSOE_Package_Total__c,
                                        Job_Rate_Plan_Charge__r.Bundle__c, Job_Rate_Plan_Charge__r.Package__c, Job_Rate_Plan_Charge__r.Required_By__c, 
                                        Job_Rate_Plan_Charge__r.VSOE_Pricing__c, Job_Rate_Plan_Charge__r.VSOE_Total__c, Job_Rate_Plan_Charge__r.Required_By__r.Unit_Price__c,
                                        Job_Rate_Plan_Charge__r.Required_By__r.Row_Total__c, Job_Rate_Plan_Charge__r.Required_By__r.VAT__c, Job_Rate_Plan_Charge__r.Required_By__r.Tax__c
                                        FROM Invoice_Lines__c
                                        WHERE Id = : listOfinvoiceLineIds
                                                   AND Revenue_Recognition_Rule__c != null
                                                   AND Invoice__r.Invoice_Status__c = 'Posted'];

              }

              revenueTransactionsToDelete = [SELECT Id
                                             FROM Revenue_Transaction__c
                                             WHERE Invoice_Line__c IN: listofInvoiceLines];

              list<Id> listOfManualRuleIds = new list<Id>();

              for (Invoice_Lines__c invoiceline : listofInvoiceLines) {
                  
                  if( invoiceline.Revenue_Recognition_Rule__c != null
                      &&
                      invoiceline.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Manual Recognition' 
                      &&
                      invoiceline.Revenue_Recognition_Rule__r.No_of_Manual_Schedules__c > 0)
                  {
                      listOfManualRuleIds.add(invoiceline.Revenue_Recognition_Rule__c);
                  }
              }

              for(Revenue_Recognition_Schedule__c schedule : [SELECT Name, Revenue_Recognition_Rule__c, Month__c, Revenue_Percent__c, Schedule_Date__c, Schedule_for_Sorting__c
                                                              FROM Revenue_Recognition_Schedule__c
                                                              WHERE Revenue_Recognition_Rule__c IN :listOfManualRuleIds
                                                              ORDER BY Revenue_Recognition_Rule__c, Schedule_for_Sorting__c])
              {

                  if(!mapOfManualSchedules.containsKey(schedule.Revenue_Recognition_Rule__c))
                  {
                      list<Revenue_Recognition_Schedule__c> schedules = new list<Revenue_Recognition_Schedule__c>();
                      schedules.add(schedule);
                      mapOfManualSchedules.put(schedule.Revenue_Recognition_Rule__c, schedules);
                  }
                  else
                  {
                      mapOfManualSchedules.get(schedule.Revenue_Recognition_Rule__c).add(schedule);
                  }
              }


              for (Invoice_Lines__c invoiceline : listofInvoiceLines) {
                  deferredRevenue = null;
                  //added by Dev M if the start or end date are null then throw error message
                  if (invoiceline.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Manual Recognition' && invoiceline.Revenue_Recognition_Rule__r.Revenue_Recognition_Schedule_Total__c != 100  ) {
                      throw new CustomException('Schedule Total should be 100% for selected Revenue Recognition Rule');
                  }
                      
                  try {
                      Date calculationStartDate = invoiceline.Service_Start_Date__c;
                      Date calculationEndDate = invoiceline.Service_End_Date__c;
                      //Find the date from which the revenue has to be recognised
                      if (invoiceline.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Service Activation Date' || invoiceline.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Service Start Date') {
                          dCompare = invoiceline.Service_Start_Date__c;
                      } else if (invoiceline.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Revenue Recognition Start Date') {
                          dCompare = invoiceline.Revenue_Recognition_Start_Date__c;
                          calculationStartDate = invoiceline.Revenue_Recognition_Start_Date__c;
                          calculationEndDate = invoiceline.Revenue_Recognition_End_Date__c;
                      } else if (invoiceline.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Revenue Recognition End Date') {
                          dCompare = invoiceline.Revenue_Recognition_End_Date__c;
                          calculationStartDate = invoiceline.Revenue_Recognition_Start_Date__c;
                          calculationEndDate = invoiceline.Revenue_Recognition_End_Date__c;
                      } else if (invoiceline.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Service End Date') {
                          dCompare = invoiceline.Service_End_Date__c;
                          //added by Dev M if the end date are null then add start date as end date
                          if (invoiceline.Price_Type__c == 'One Time' && invoiceline.Service_End_Date__c == null) {
                              dCompare = invoiceline.Service_Start_Date__c;
                          }
                      } else if (invoiceline.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Invoice Date') {
                          dCompare = invoiceline.Invoice__r.Invoice_Date__c;
                      }

                      //For manual schedules, the recognition starts either based on a manual date, or based on the manual month #
                      if(invoiceline.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Manual Recognition'){
                          if(invoiceline.Revenue_Recognition_Rule__r.First_Manual_Schedule_Date__c != null){
                              dCompare = invoiceline.Revenue_Recognition_Rule__r.First_Manual_Schedule_Date__c;
                          }else if(invoiceline.Revenue_Recognition_Rule__r.First_Manual_Schedule_Month__c != null && dCompare != null){
                              Integer noOfMonthsToAdd = (invoiceline.Revenue_Recognition_Rule__r.First_Manual_Schedule_Month__c).intvalue();
                              dCompare = dCompare.addMonths(noOfMonthsToAdd);
                          }
                      }
                      
                      //added by Dev M if the end date is null the add start date as end date
                      if (calculationEndDate == null && invoiceline.Price_Type__c == 'One Time')
                          calculationEndDate = invoiceline.Service_Start_Date__c;

                      if(calculationEndDate == null && (invoiceline.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Manual Recognition' || invoiceline.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Full Recognition on Specific Date'))
                          calculationEndDate = dCompare;

                      //added by Dev M if the start or end date are null then throw error message
                      if (calculationStartDate == null || dCompare == null || calculationEndDate == null) {
                          throw new CustomException('Please populate Start date or End date accordingly for selected Revenue Recognition Rule');
                      }

                      Decimal calculatedTotal;
                      Decimal absCalculatedTotal;
                      boolean isNegativeValue = false;
                      Decimal calculatedNetTotalForVSOE;

                      //Added by Lopa for INVOICEIT-613 to exclude vat and tax in rev recognition record
                      calculatedTotal = invoiceline.Total_Line_Amount__c - invoiceline.VAT__c - invoiceline.Tax__c;
                      // VSOE Calcaulations Ticket No : INVOICEIT-658 added by Dev M
                      if(invoiceline.Job_Rate_Plan_Charge__r.VSOE_Pricing__c != null && invoiceline.Job_Rate_Plan_Charge__r.VSOE_Total__c != null && invoiceline.Job_Rate_Plan_Charge__r.VSOE_Package_Total__c != null  && invoiceline.Job_Rate_Plan_Charge__r.Required_By__c != null) {
                          calculatedNetTotalForVSOE = invoiceline.Job_Rate_Plan_Charge__r.Required_By__r.Row_Total__c - invoiceline.Job_Rate_Plan_Charge__r.Required_By__r.VAT__c - invoiceline.Job_Rate_Plan_Charge__r.Required_By__r.Tax__c;
                          calculatedTotal = ((invoiceline.Job_Rate_Plan_Charge__r.VSOE_Total__c / invoiceline.Job_Rate_Plan_Charge__r.VSOE_Package_Total__c) * calculatedNetTotalForVSOE) * invoiceline.Calculated_Quantity__c;
                      }
                  
                      absCalculatedTotal = Math.abs(calculatedTotal);
                      if (absCalculatedTotal != calculatedTotal) {
                          isNegativeValue = true;
                          calculatedTotal = absCalculatedTotal;
                      }
                          
                      if (invoiceline.Price_Type__c == 'One Time' || invoiceline.Price_Type__c == 'Usage') {
                          deferredRevenue = calculatedTotal;
                      } else if (calculationEndDate != null) {
                          calculationEndDate = calculationEndDate.addDays(1);
                          deferredRevenue = Math.abs(calculatedTotal);
                      }

                      //Get the chargeTerms
                      Decimal chargeTerms = 1.0;
                      if (invoiceline.Price_Type__c == 'Annual') {
                          chargeTerms = 12.0;
                      } else if (invoiceline.Price_Type__c == 'Half Yearly') {
                          chargeTerms = 6.0;
                      } else if (invoiceline.Price_Type__c == 'Quarterly') {
                          chargeTerms = 3.0;
                      }

                      Integer noOfIterations;
                      Integer noOfDays;
                     
                      //The no of iterations is 1 if the recognition type is 'Full Recognition on Specific Date'
                      Decimal dNoOfIterations;
                      if (invoiceline.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Full Recognition on Specific Date') {
                          dNoOfIterations = 1;
                      } else {
                          dNoOfIterations = RevenueTransactionsForOrderUtilClass.calculateDiffBetweenDatesInMonths(calculationStartDate, calculationEndDate);
                      }
                      Long lNoOfIterations = dNoOfIterations.round(System.RoundingMode.UP);

                      Double noOfMonths;

                      if (calculationEndDate != null) {
                          //There has been an extra 1 days added to calculationEndDate for calculation purposes
                          //Reset that day
                          Date tempCalculationEndDate = calculationEndDate.addDays(-1);

                          noOfDays = calculationStartDate.daysBetween(tempCalculationEndDate);
                      }

                      // Ticket : SUP-544 , Second condition added by Dev M, reason when ever both the values for dNoOfIterations & lNoOfIterations is zero it was throwing exception
                      if (dNoOfIterations < lNoOfIterations || (dNoOfIterations == 0 && lNoOfIterations == 0)) {
                          noOfMonths = noOfIterations = dNoOfIterations.intValue() + 1;
                      } else {
                          noOfMonths = noOfIterations = dNoOfIterations.intValue();
                      }

                      //This would be the monthly amount we would recognize for a monthly rule
                      Decimal monthlyAmount;
                      if ((invoiceline.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Monthly Recognition Over Time'
                              ||
                              invoiceline.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Weighted Monthly Recognition Over Time')
                              &&
                              (invoiceline.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Service Activation Date' || invoiceline.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Service Start Date')) {
                          
                          calculatedTotal = invoiceline.Total_Line_Amount__c - invoiceline.VAT__c - invoiceline.Tax__c;
                          // VSOE Calcaulations Ticket No : INVOICEIT-658 added by Dev M
                          if(invoiceline.Job_Rate_Plan_Charge__r.VSOE_Pricing__c != null && invoiceline.Job_Rate_Plan_Charge__r.VSOE_Total__c != null && invoiceline.Job_Rate_Plan_Charge__r.VSOE_Package_Total__c != null && invoiceline.Job_Rate_Plan_Charge__r.Required_By__c != null) {
                              calculatedNetTotalForVSOE = invoiceline.Job_Rate_Plan_Charge__r.Required_By__r.Row_Total__c - invoiceline.Job_Rate_Plan_Charge__r.Required_By__r.VAT__c - invoiceline.Job_Rate_Plan_Charge__r.Required_By__r.Tax__c;
                              calculatedTotal = ((invoiceline.Job_Rate_Plan_Charge__r.VSOE_Total__c / invoiceline.Job_Rate_Plan_Charge__r.VSOE_Package_Total__c) * calculatedNetTotalForVSOE) * invoiceline.Calculated_Quantity__c;
                          }
                          
                          //added by Dev for usages
                          if (invoiceline.Price_Type__c == 'Usage') {
                              monthlyAmount = calculatedTotal / (RevenueTransactionsForOrderUtilClass.calculateDiffBetweenDates(invoiceline.Service_Start_Date__c, invoiceline.Service_End_Date__c, invoiceline.Price_Type__c) * chargeTerms);
                          } else {
                              monthlyAmount = calculatedTotal / (invoiceline.Calculated_Quantity__c * chargeTerms);
                          }

                          //monthlyAmount = invoiceline.Total_Line_Amount__c / (invoiceline.Calculated_Quantity__c * chargeTerms);
                          monthlyAmount = monthlyAmount.setScale(2, System.RoundingMode.HALF_UP);
                      } else if ((invoiceline.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Monthly Recognition Over Time'
                                  ||
                                  invoiceline.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Weighted Monthly Recognition Over Time')
                                 &&
                                 invoiceline.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Revenue Recognition Start Date') {
                          monthlyAmount = calculatedTotal / noOfMonths;
                          monthlyAmount = monthlyAmount.setScale(2, System.RoundingMode.HALF_UP);
                      }

                      //We need to add 1 to the iterations only if the endday < startday
                      Integer calculationStartDay = calculationStartDate.day();
                      //Subtract 1 day from the enddate to reset this
                      Integer calculationEndDay;
                      if (calculationEndDate != null) {
                          calculationEndDay = calculationEndDate.addDays(-1).day();
                      }



                      //If the revenue recognition
                      if ((invoiceline.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Weighted Monthly Recognition Over Time'
                              ||
                              invoiceline.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Daily Recognition Over Time')
                              && calculationEndDay < calculationStartDay) {
                          noOfIterations++;

                      } else if (invoiceline.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Full Recognition on Specific Date') {
                          noOfIterations = 1;
                      }else if (invoiceline.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Manual Recognition') {
                          noOfIterations = invoiceline.Revenue_Recognition_Rule__r.No_of_manual_schedules__c.intvalue();
                      }

                      recognisedRevenue = 0;

                      if (invoiceline.Revenue_Recognition_Rule__c != null) {
                          for (Integer i = 0; i < noOfIterations; i++) {
                              Revenue_Period__c tempClosedMatchingRevenuePeriod;
                              Revenue_Period__c tempOpenMatchingRevenuePeriod;
                              Revenue_Period__c tempClosedMatchingRevenuePeriodForAuditReasons;
                              Boolean isOriginalAccountingPeriodClosed = false;
                              for (Revenue_Period__c revenuePeriod : revenuePeriods) {
                                  //Find the right revenue period where the dCompare falls into
                                  //If that revenue period is closed, then automatically choose the next open revenue period
                                  //First check if the revenue period that matches dCompare is open. If yes then use that
                                  //Else use the next open revenue period
                                  if ( (revenuePeriod.Revenue_Period_Start_Date__c <= dCompare
                                          && revenuePeriod.Revenue_Period_End_Date__c >= dCompare
                                          && !revenuePeriod.Revenue_Period_Closed__c)
                                          ||
                                          (tempClosedMatchingRevenuePeriod != null
                                           && !revenuePeriod.Revenue_Period_Closed__c)) {
                                      tempOpenMatchingRevenuePeriod = revenuePeriod;
                                      tempClosedMatchingRevenuePeriod = null;
                                  }

                                  if ( revenuePeriod.Revenue_Period_Start_Date__c <= dCompare
                                          && revenuePeriod.Revenue_Period_End_Date__c >= dCompare
                                          && revenuePeriod.Revenue_Period_Closed__c) {
                                      tempClosedMatchingRevenuePeriod = revenuePeriod;
                                      //Copy that same value for audit reasons
                                      tempClosedMatchingRevenuePeriodForAuditReasons = tempClosedMatchingRevenuePeriod;
                                      isOriginalAccountingPeriodClosed = true;
                                  }

                                  if ( tempOpenMatchingRevenuePeriod != null) {
                                      revenueTransaction = new Revenue_Transaction__c();
                                      revenueTransaction.Revenue_Period__c = tempOpenMatchingRevenuePeriod.Id;
                                      revenueTransaction.Account__c = invoiceline.Invoice__r.Account__c;
                                      revenueTransaction.Order__c = invoiceline.Job__c;
                                      revenueTransaction.Order_Rate_Plan_Charge__c = invoiceline.Job_Rate_Plan_Charge__c;
                                      revenueTransaction.Invoice__c = invoiceline.Invoice__c;
                                      revenueTransaction.Invoice_Line__c = invoiceline.Id;
                                      revenueTransaction.CurrencyL__c = invoiceline.CurrencyL__c;
                                      revenueTransaction.Accounting_Code1__c = invoiceline.Accounting_Code__c;
                                      revenueTransaction.Deferred_Revenue_Accounting_Code__c = invoiceline.Deferred_Revenue_Accounting_Code__c;
                                      revenueTransaction.Applied_Revenue_Recognition_Rule__c = invoiceline.Revenue_Recognition_Rule__c;
                                      revenueTransaction.Applied_Recognition_Date_Name__c = invoiceline.Revenue_Recognition_Rule__r.Recognition_Date__c;
                                      revenueTransaction.Applied_Recognition_Type__c = invoiceline.Revenue_Recognition_Rule__r.Recognition_Type__c;
                                      revenueTransaction.Applied_Recognition_Date_Value__c = dCompare;
                                      if (tempClosedMatchingRevenuePeriodForAuditReasons != null) {
                                          revenueTransaction.Original_Closed_Revenue_Period__c = tempClosedMatchingRevenuePeriodForAuditReasons.Id;
                                      }
                                      if (isOriginalAccountingPeriodClosed) {
                                          revenueTransaction.Comments__c = 'Revenue recognized in the next open revenue period as the original revenue period was closed';
                                      }
                                      if (UserInfo.isMultiCurrencyOrganization()) {
                                          CommonUtilClass.populateCurrencyIsoCodeOnSobject(revenueTransaction, invoiceline.CurrencyL__r.Name);
                                      }
                                      // added by ram 8-21-2015, if the revenue period matches then break the loop to avoid iteration
                                      break;
                                  }
                              }

                              if (invoiceline.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Monthly Recognition Over Time') {
                                  //For the last iteration, recognize all of the deferred revenue
                                  if (i == noOfIterations - 1) {
                                      revenueTransaction.Revenue_Amount__c = deferredRevenue;
                                      recognisedRevenue += revenueTransaction.Revenue_Amount__c;
                                      revenueTransaction.Recognised_Revenue__c = recognisedRevenue;
                                      deferredRevenue = deferredRevenue - revenueTransaction.Revenue_Amount__c;
                                      revenueTransaction.Deferred_Balance__c = deferredRevenue;
                                  } else {
                                      revenueTransaction.Revenue_Amount__c = monthlyAmount;
                                      recognisedRevenue += revenueTransaction.Revenue_Amount__c;
                                      revenueTransaction.Recognised_Revenue__c = recognisedRevenue;
                                      deferredRevenue = deferredRevenue - revenueTransaction.Revenue_Amount__c;
                                      revenueTransaction.Deferred_Balance__c = deferredRevenue;
                                  }

                                  //Before adding the revenueTransaction we need to offset for negative values
                                  if (isNegativeValue) {
                                      revenueTransaction =    RevenueTransactionsForCreditUtilClass.offSetNegativeValues(revenueTransaction);
                                  }
                                  revenueTransactions.add(revenueTransaction);
                              }

                              if (invoiceline.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Weighted Monthly Recognition Over Time') {
                                  if (i == 0) {
                                      Date lastDayOfThisMonth = Date.newInstance(dCompare.year(), dCompare.month(), Date.daysInMonth(dCompare.year(), dCompare.month()));
                                      //Add 1 day to this to make sure the days in between also includes the end date
                                      lastDayOfThisMonth = lastDayOfThisMonth.addDays(1);
                                      Decimal noOfTimesForCalculation = RevenueTransactionsForOrderUtilClass.calculateDiffBetweenDatesInMonths(dCompare, lastDayOfThisMonth);

                                      revenueTransaction.Revenue_Amount__c = noOfTimesForCalculation * monthlyAmount;
                                      recognisedRevenue += revenueTransaction.Revenue_Amount__c;
                                      revenueTransaction.Recognised_Revenue__c = recognisedRevenue;
                                      deferredRevenue = deferredRevenue - revenueTransaction.Revenue_Amount__c;
                                      revenueTransaction.Deferred_Balance__c = deferredRevenue;
                                  } else if (i == noOfIterations - 1) {
                                      revenueTransaction.Revenue_Amount__c = deferredRevenue;
                                      recognisedRevenue += revenueTransaction.Revenue_Amount__c;
                                      revenueTransaction.Recognised_Revenue__c = recognisedRevenue;
                                      deferredRevenue = deferredRevenue - revenueTransaction.Revenue_Amount__c;
                                      revenueTransaction.Deferred_Balance__c = deferredRevenue;
                                  } else {
                                      revenueTransaction.Revenue_Amount__c = monthlyAmount;
                                      recognisedRevenue += revenueTransaction.Revenue_Amount__c;
                                      revenueTransaction.Recognised_Revenue__c = recognisedRevenue;
                                      deferredRevenue = deferredRevenue - revenueTransaction.Revenue_Amount__c;
                                      revenueTransaction.Deferred_Balance__c = deferredRevenue;
                                  }

                                  //Before adding the revenueTransaction we need to offset for negative values
                                  if (isNegativeValue) {
                                      revenueTransaction =    RevenueTransactionsForCreditUtilClass.offSetNegativeValues(revenueTransaction);
                                  }
                                  revenueTransactions.add(revenueTransaction);
                              }

                              if (invoiceline.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Daily Recognition Over Time') {
                                  if (i == 0) {
                                      Decimal daysInMonth = Date.daysInMonth(dCompare.year(), dCompare.month());
                                      Decimal proratedDays = daysInMonth - dCompare.day() + 1;
                                      revenueTransaction.Revenue_Amount__c = (proratedDays / noOfDays) * calculatedTotal;
                                      recognisedRevenue += revenueTransaction.Revenue_Amount__c;
                                      revenueTransaction.Recognised_Revenue__c = recognisedRevenue;
                                      deferredRevenue = deferredRevenue - revenueTransaction.Revenue_Amount__c;
                                      revenueTransaction.Deferred_Balance__c = deferredRevenue;
                                      //Before adding the revenueTransaction we need to offset for negative values
                                      if (isNegativeValue) {
                                          revenueTransaction =    RevenueTransactionsForCreditUtilClass.offSetNegativeValues(revenueTransaction);
                                      }
                                      revenueTransactions.add(revenueTransaction);
                                  } else if (i == noOfIterations - 1) {
                                      revenueTransaction.Revenue_Amount__c = deferredRevenue;
                                      recognisedRevenue += revenueTransaction.Revenue_Amount__c;
                                      revenueTransaction.Recognised_Revenue__c = recognisedRevenue;
                                      deferredRevenue = deferredRevenue - revenueTransaction.Revenue_Amount__c;
                                      revenueTransaction.Deferred_Balance__c = deferredRevenue;
                                      //Before adding the revenueTransaction we need to offset for negative values
                                      if (isNegativeValue) {
                                          revenueTransaction =    RevenueTransactionsForCreditUtilClass.offSetNegativeValues(revenueTransaction);
                                      }
                                      revenueTransactions.add(revenueTransaction);
                                  } else {
                                      Decimal daysInMonth = Date.daysInMonth(dCompare.year(), dCompare.month());
                                      revenueTransaction.Revenue_Amount__c = (daysInMonth / noOfDays) * calculatedTotal;
                                      recognisedRevenue += revenueTransaction.Revenue_Amount__c;
                                      revenueTransaction.Recognised_Revenue__c = recognisedRevenue;
                                      deferredRevenue = deferredRevenue - revenueTransaction.Revenue_Amount__c;
                                      revenueTransaction.Deferred_Balance__c = deferredRevenue;
                                      //Before adding the revenueTransaction we need to offset for negative values
                                      if (isNegativeValue) {
                                          revenueTransaction =    RevenueTransactionsForCreditUtilClass.offSetNegativeValues(revenueTransaction);
                                      }
                                      revenueTransactions.add(revenueTransaction);
                                  }
                              }

                              if (invoiceline.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Full Recognition on Specific Date') {
                                  revenueTransaction.Revenue_Amount__c = deferredRevenue;
                                  recognisedRevenue += revenueTransaction.Revenue_Amount__c;
                                  revenueTransaction.Recognised_Revenue__c = recognisedRevenue;
                                  deferredRevenue = deferredRevenue - revenueTransaction.Revenue_Amount__c;
                                  revenueTransaction.Deferred_Balance__c = deferredRevenue;
                                  //Before adding the revenueTransaction we need to offset for negative values
                                  if (isNegativeValue) {
                                      revenueTransaction =    RevenueTransactionsForCreditUtilClass.offSetNegativeValues(revenueTransaction);
                                  }
                                  revenueTransactions.add(revenueTransaction);
                              }

                              if(invoiceline.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Manual Recognition' && mapOfManualSchedules.containsKey(invoiceline.Revenue_Recognition_Rule__c)){
                                  //Get the manual schedule from the map with the index i
                                  list<Revenue_Recognition_Schedule__c> schedules = mapOfManualSchedules.get(invoiceline.Revenue_Recognition_Rule__c);
                                  Revenue_Recognition_Schedule__c schedule = schedules.get(i);
                                  Decimal amount = calculatedTotal * schedule.Revenue_Percent__c/100;
                                  revenueTransaction.Revenue_Amount__c = amount;
                                  recognisedRevenue += revenueTransaction.Revenue_Amount__c;
                                  revenueTransaction.Recognised_Revenue__c = recognisedRevenue;
                                  deferredRevenue = deferredRevenue - revenueTransaction.Revenue_Amount__c;
                                  revenueTransaction.Deferred_Balance__c = deferredRevenue;

                                  //Before adding the revenueTransaction we need to offset for negative values
                                  if (isNegativeValue) {
                                      revenueTransaction = RevenueTransactionsForCreditUtilClass.offSetNegativeValues(revenueTransaction);
                                  }
                                  revenueTransactions.add(revenueTransaction);


                                  //Get the next schedule and use that date to populate the dCompare value
                                  if(i != noOfIterations - 1){
                                      Revenue_Recognition_Schedule__c nextschedule = schedules.get(i+1);
                                      if(nextschedule.Schedule_Date__c != null){
                                          dCompare = nextschedule.Schedule_Date__c;
                                      }else if(nextschedule.Month__c != null){
                                          Integer noOfMonthsToAdd = (nextschedule.Month__c - schedule.Month__c).intvalue();
                                          dCompare = dCompare.addMonths(noOfMonthsToAdd);
                                      }
                                  }
                                  
                              }

                              //Increment the dcompare value only if the recognition type is not Manual Recognition. If it was Manual, this would have been done based on the recognition schedule dates. 
                              if (invoiceline.Revenue_Recognition_Rule__r.Recognition_Type__c != 'Manual Recognition') {
                                  dCompare = dCompare.addMonths(1);
                              }
                          }
                      }

                      invoiceline.Revenue_Recognition_Status__c = CommonUtilClass.STATUS_COMPLETED;
                      invoiceline.Error_Reason_for_Revenue_Recognition__c = '';
                  } catch (Exception ex) {
                      invoiceline.Error_Reason_for_Revenue_Recognition__c = ex.getMessage();
                      invoiceline.Revenue_Recognition_Status__c = 'Error';
                  }

              }

              //Delete revenue schedules for that order if any
              delete revenueTransactionsToDelete;

              insert revenueTransactions;

              //Update the charges which are processed
              update listofInvoiceLines;


          } catch (DMLException dMlEx) {
              database.rollback(sp);
              string sException;
              for (Integer i = 0; i < dMlEx.getNumDml(); i++) {
                  sException = system.Label.ExceptionMessage + ' ' + dMlEx.getDmlMessage(i);
              }

              for (Invoice_Lines__c invoiceline : listofInvoiceLines) {
                  invoiceline.Error_Reason_for_Revenue_Recognition__c = sException;
                  invoiceline.Revenue_Recognition_Status__c = 'Error';
              }
              update listofInvoiceLines;

              return sException;
          }  catch (Exception ex) {
              database.rollback(sp);
              string sException;
              sException = system.Label.ExceptionMessage + ex.getTypeName() + ':' + ex.getMessage() + ':LINE ' + ex.getLineNumber();

              for (Invoice_Lines__c invoiceline : listofInvoiceLines) {
                  invoiceline.Error_Reason_for_Revenue_Recognition__c = ex.getMessage();
                  invoiceline.Revenue_Recognition_Status__c = 'Error';
              }
              update listofInvoiceLines;

              return sException;
          }
          return 'Success';
      }
  }