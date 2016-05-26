global with sharing class RevenueTransactionsForCreditUtilClass{

    WebService static string createRevenueTransactionForCreditNote(Id creditNoteId) {
      return processRevenueTransaction(creditNoteId, null);
    }

    WebService static string createRevenueTransactionForCreditLine(list<Id> creditLineId) {
      return processRevenueTransaction(null, creditLineId);
    }

    public static string processRevenueTransaction(Id creditNoteId, list<Id> creditLineId) {
      savepoint sp = database.setsavepoint();
      list<Credit_Line__c> listofCreditLines = new list<Credit_Line__c>();
      try {

        list<Revenue_Transaction__c> revenueTransactions = new list<Revenue_Transaction__c>();
        Date dCompare;
        Decimal recognisedRevenue;
        Decimal deferredRevenue;
        Revenue_Transaction__c revenueTransaction;
        Date dCompareForManualRec;

        //Get the list of all revenue periods in the org
        list<Revenue_Period__c> revenuePeriods;
        revenuePeriods = [select Id, Name, Revenue_Period_Start_Date__c, Revenue_Period_End_Date__c, Revenue_Period_Closed__c
                          FROM Revenue_Period__c
                          ORDER BY Revenue_Period_Start_Date__c LIMIT 10000];

        //This would store all the revenue forecasts to delete
        //Everytime the revenue forecasts are created for an order/charge, the older ones are deleted.
        list<Revenue_Transaction__c> revenueTransactionsToDelete;
        

        if (creditNoteId != null) {
          listofCreditLines = [SELECT Id, Credit_Note__c, Total_Line_Value__c,Tax__c,VAT__c,Revenue_Recognition_Rule__c, Price_Type__c, Calculated_Quantity__c,
                                Revenue_Recognition_Rule__r.Recognition_Type__c, Revenue_Recognition_Rule__r.Recognition_Date__c, Revenue_Recognition_Rule__r.Name,
                                Invoice__r.Account__c, Revenue_Recognition_Start_Date__c, Revenue_Recognition_End_Date__c,
                                Charge_Start_Date__c, Charge_End_Date__c, Credit_Line__c.Order__c, Invoice__r.Order__r.Account__c,
                                Invoice__r.Invoice_Date__c, Quantity__c, Unit_Price__c,Order_Rate_Plan_Charge__c, 
                                CurrencyL__c, CurrencyL__r.Name, Accounting_Code__c, Deferred_Revenue_Accounting_Code__c,Order_Rate_Plan_Charge__r.VSOE_Package_Total__c,
                                Order_Rate_Plan_Charge__r.Bundle__c, Order_Rate_Plan_Charge__r.Package__c, Order_Rate_Plan_Charge__r.Required_By__c, 
                                Order_Rate_Plan_Charge__r.VSOE_Pricing__c, Order_Rate_Plan_Charge__r.VSOE_Total__c, Order_Rate_Plan_Charge__r.Required_By__r.Unit_Price__c,
                                Order_Rate_Plan_Charge__r.Required_By__r.Row_Total__c,Order_Rate_Plan_Charge__r.Required_By__r.VAT__c,Order_Rate_Plan_Charge__r.Required_By__r.Tax__c,
                                Revenue_Recognition_Rule__r.No_of_Manual_Schedules__c,Revenue_Recognition_Rule__r.First_Manual_Schedule_Date__c, 
                                Revenue_Recognition_Rule__r.First_Manual_Schedule_Month__c, Revenue_Recognition_Rule__r.Revenue_Recognition_Schedule_Total__c
                                FROM Credit_Line__c
                                WHERE Credit_Note__c = : creditNoteId
                                AND Revenue_Recognition_Rule__c != null
                                AND Order_Rate_Plan_Charge__r.Package__c = false];
        } else {
          listofCreditLines = [SELECT Id, Credit_Note__c, Total_Line_Value__c,Tax__c,VAT__c,Revenue_Recognition_Rule__c, Price_Type__c, Calculated_Quantity__c,
                                Revenue_Recognition_Rule__r.Recognition_Type__c, Revenue_Recognition_Rule__r.Recognition_Date__c, Revenue_Recognition_Rule__r.Name,
                                Invoice__r.Account__c, Revenue_Recognition_Start_Date__c, Revenue_Recognition_End_Date__c,
                                Charge_Start_Date__c, Charge_End_Date__c, Credit_Line__c.Order__c, Invoice__r.Order__r.Account__c,
                                Invoice__r.Invoice_Date__c, Quantity__c, Unit_Price__c,Order_Rate_Plan_Charge__c,
                                CurrencyL__c, CurrencyL__r.Name, Accounting_Code__c, Deferred_Revenue_Accounting_Code__c,Order_Rate_Plan_Charge__r.VSOE_Package_Total__c,
                                Order_Rate_Plan_Charge__r.Bundle__c, Order_Rate_Plan_Charge__r.Package__c, Order_Rate_Plan_Charge__r.Required_By__c, 
                                Order_Rate_Plan_Charge__r.VSOE_Pricing__c, Order_Rate_Plan_Charge__r.VSOE_Total__c, Order_Rate_Plan_Charge__r.Required_By__r.Unit_Price__c,
                                Order_Rate_Plan_Charge__r.Required_By__r.Row_Total__c,Order_Rate_Plan_Charge__r.Required_By__r.VAT__c,Order_Rate_Plan_Charge__r.Required_By__r.Tax__c,
                                Revenue_Recognition_Rule__r.No_of_Manual_Schedules__c,Revenue_Recognition_Rule__r.First_Manual_Schedule_Date__c, 
                                Revenue_Recognition_Rule__r.First_Manual_Schedule_Month__c, Revenue_Recognition_Rule__r.Revenue_Recognition_Schedule_Total__c
                                FROM Credit_Line__c
                                WHERE Id in : creditLineId
                                AND Revenue_Recognition_Rule__c != null
                                AND Order_Rate_Plan_Charge__r.Package__c = false];
        }
        revenueTransactionsToDelete = [SELECT Id
                                       FROM Revenue_Transaction__c
                                       WHERE Credit_Line__c IN: listofCreditLines];

        list<Id> listOfManualRuleIds = new list<Id>();
        map<Id,list<Revenue_Recognition_Schedule__c>> mapOfManualSchedules = new map<Id, list<Revenue_Recognition_Schedule__c>>();

        for (Credit_Line__c creditLine : listofCreditLines) {
            
            if( creditLine.Revenue_Recognition_Rule__c != null
                &&
                creditLine.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Manual Recognition' 
                &&
                creditLine.Revenue_Recognition_Rule__r.No_of_Manual_Schedules__c > 0)
            {
                listOfManualRuleIds.add(creditLine.Revenue_Recognition_Rule__c);
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

        for (Credit_Line__c creditLine : listofCreditLines) {
          deferredRevenue = null;
          //added by Dev M if the start or end date are null then throw error message
          if (creditLine.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Manual Recognition' && creditLine.Revenue_Recognition_Rule__r.Revenue_Recognition_Schedule_Total__c != 100  ) {
              throw new CustomException('Schedule Total should be 100% for selected Revenue Recognition Rule');
          }
                  
          try{
                  Date calculationStartDate = creditLine.Charge_Start_Date__c;
                  Date calculationEndDate = creditLine.Charge_End_Date__c;
                  
                  //Find the date from which the revenue has to be recognised
                  if (creditLine.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Service Activation Date' || creditLine.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Service Start Date') {
                    dCompare = creditLine.Charge_Start_Date__c;
                  } else if (creditLine.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Revenue Recognition Start Date') {
                    dCompare = creditLine.Revenue_Recognition_Start_Date__c;
                    calculationStartDate = creditLine.Revenue_Recognition_Start_Date__c;
                    calculationEndDate = creditLine.Revenue_Recognition_End_Date__c;
                  } else if (creditLine.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Revenue Recognition End Date') {
                    dCompare = creditLine.Revenue_Recognition_End_Date__c;
                    calculationStartDate = creditLine.Revenue_Recognition_Start_Date__c;
                    calculationEndDate = creditLine.Revenue_Recognition_End_Date__c;
                  } else if (creditLine.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Service End Date') {
                    dCompare = creditLine.Charge_End_Date__c;
                      //added by Dev M if the end date are null then add start date as end date
                      if(creditLine.Price_Type__c == 'One Time' && creditLine.Charge_End_Date__c == null) {
                          dCompare = creditLine.Charge_End_Date__c;
                      }
                  } else if (creditLine.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Invoice Date') {
                    dCompare = creditLine.Invoice__r.Invoice_Date__c;
                  }
          
                  //added by Dev M if the end date is null the add start date as end date
                  if(calculationEndDate == null && creditLine.Price_Type__c == 'One Time')
                      calculationEndDate = creditLine.Charge_Start_Date__c;

                  //For manual schedules, the recognition starts either based on a manual date, or based on the manual month #
                  if(creditLine.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Manual Recognition'){
                      if(creditLine.Revenue_Recognition_Rule__r.First_Manual_Schedule_Date__c != null){
                          dCompare = creditLine.Revenue_Recognition_Rule__r.First_Manual_Schedule_Date__c;
                      }else if(creditLine.Revenue_Recognition_Rule__r.First_Manual_Schedule_Month__c != null && dCompare != null){
                          Integer noOfMonthsToAdd = (creditLine.Revenue_Recognition_Rule__r.First_Manual_Schedule_Month__c).intvalue();
                          dCompare = dCompare.addMonths(noOfMonthsToAdd);
                      }
                  }

                  if(calculationEndDate == null && (creditLine.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Manual Recognition' || creditLine.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Full Recognition on Specific Date'))
                      calculationEndDate = dCompare;

                  //added by Dev M if the start or end date are null then throw error message
                  if (calculationStartDate == null || dCompare == null || calculationEndDate == null) {
                      throw new CustomException('Please populate Start date or End date accordingly for selected Revenue Recognition Rule');
                  }
                      
                  Decimal calculatedTotal;
                  Decimal absCalculatedTotal;
                  Decimal calculatedNetTotal;
                  Decimal calculatedNetTotalForVSOE;
                  // By default if the value is positive create negative values
                  boolean isNegativeValue = true;
                  
                  //Added by Lopa :INVOICEIT-613 to exclude Vat and Tax from Revenue forecast records
                  calculatedNetTotal = creditLine.Total_Line_Value__c - creditLine.VAT__c - creditLine.Tax__c ;
                  // VSOE Calcaulations: INVOICEIT-658 added by Dev M
                  if(creditLine.Order_Rate_Plan_Charge__r.VSOE_Pricing__c != null && creditLine.Order_Rate_Plan_Charge__r.VSOE_Total__c != null && creditLine.Order_Rate_Plan_Charge__r.VSOE_Package_Total__c != null && creditLine.Order_Rate_Plan_Charge__r.Required_By__c != null) {
                      calculatedNetTotalForVSOE = creditLine.Order_Rate_Plan_Charge__r.Required_By__r.Row_Total__c - creditLine.Order_Rate_Plan_Charge__r.Required_By__r.VAT__c - creditLine.Order_Rate_Plan_Charge__r.Required_By__r.Tax__c;
                      calculatedNetTotal = ((creditLine.Order_Rate_Plan_Charge__r.VSOE_Total__c/creditLine.Order_Rate_Plan_Charge__r.VSOE_Package_Total__c) * calculatedNetTotalForVSOE) * creditLine.Calculated_Quantity__c;
                  }
                      
                  absCalculatedTotal = Math.abs(calculatedNetTotal);
                  if (absCalculatedTotal != calculatedNetTotal) {
                    isNegativeValue = false;
                    calculatedNetTotal = absCalculatedTotal;
                  }
                    
                  if (creditLine.Price_Type__c == 'One Time' || creditLine.Price_Type__c == 'Usage') {
                      deferredRevenue = calculatedNetTotal;
                  } else if (calculationEndDate != null) {
                     calculationEndDate = calculationEndDate.addDays(1);
                     deferredRevenue = Math.abs(calculatedNetTotal);
                  }
          
                  //Get the chargeTerms
                  Decimal chargeTerms = 1.0;
                  if (creditLine.Price_Type__c == 'Annual') {
                    chargeTerms = 12.0;
                  } else if (creditLine.Price_Type__c == 'Half Yearly') {
                    chargeTerms = 6.0;
                  } else if (creditLine.Price_Type__c == 'Quarterly') {
                    chargeTerms = 3.0;
                  }
          
                  Integer noOfIterations;
                  Integer noOfDays;
          
                  //The no of iterations is 1 if the recognition type is 'Full Recognition on Specific Date'
                  Decimal dNoOfIterations;
                  if (creditLine.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Full Recognition on Specific Date') {
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
                  
                  //SUP-544: Second condition added by Dev M: reason when ever both the values for dNoOfIterations & lNoOfIterations is zero it was throwing exception
                  
                  if (dNoOfIterations < lNoOfIterations  || (dNoOfIterations == 0 && lNoOfIterations == 0)) {
                    noOfMonths = noOfIterations = dNoOfIterations.intValue() + 1;
                  } else {
                    noOfMonths = noOfIterations = dNoOfIterations.intValue();
                  }
          
                  //This would be the monthly amount we would recognize for a monthly rule
                  Decimal monthlyAmount;
                  calculatedNetTotal = creditLine.Total_Line_Value__c - creditLine.VAT__c - creditLine.Tax__c ;
                  // VSOE Calcaulations: INVOICEIT-658 added by Dev M
                  if(creditLine.Order_Rate_Plan_Charge__r.VSOE_Pricing__c != null && creditLine.Order_Rate_Plan_Charge__r.VSOE_Total__c != null && creditLine.Order_Rate_Plan_Charge__r.VSOE_Package_Total__c != null && creditLine.Order_Rate_Plan_Charge__r.Required_By__c != null) {
                      calculatedNetTotalForVSOE = creditLine.Order_Rate_Plan_Charge__r.Required_By__r.Row_Total__c - creditLine.Order_Rate_Plan_Charge__r.Required_By__r.VAT__c - creditLine.Order_Rate_Plan_Charge__r.Required_By__r.Tax__c;
                      calculatedNetTotal = ((creditLine.Order_Rate_Plan_Charge__r.VSOE_Total__c/creditLine.Order_Rate_Plan_Charge__r.VSOE_Package_Total__c) * calculatedNetTotalForVSOE) * creditLine.Calculated_Quantity__c;
                  }
                  
                  if ((creditLine.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Monthly Recognition Over Time'
                          ||
                          creditLine.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Weighted Monthly Recognition Over Time')
                          &&
                          (creditLine.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Service Activation Date' || creditLine.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Service Start Date')) {
                        //added by Dev for usages
                      if(creditLine.Price_Type__c == 'Usage') {
                          monthlyAmount = calculatedNetTotal / (RevenueTransactionsForOrderUtilClass.calculateDiffBetweenDates(creditLine.Charge_Start_Date__c,creditLine.Charge_End_Date__c,creditLine.Price_Type__c) * chargeTerms);
                      } else {
                          monthlyAmount = calculatedNetTotal / (creditLine.Calculated_Quantity__c * chargeTerms);
                      }
                    monthlyAmount = calculatedNetTotal / (creditLine.Calculated_Quantity__c * chargeTerms);
                    monthlyAmount = monthlyAmount.setScale(2, System.RoundingMode.HALF_UP);
                  } else if ((creditLine.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Monthly Recognition Over Time'
                              ||
                              creditLine.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Weighted Monthly Recognition Over Time')
                             &&
                             creditLine.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Revenue Recognition Start Date') {
                    monthlyAmount = calculatedNetTotal / noOfMonths;
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
                  if ((creditLine.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Weighted Monthly Recognition Over Time'
                          ||
                          creditLine.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Daily Recognition Over Time')
                          && calculationEndDay < calculationStartDay) {
                    noOfIterations++;
          
                  } else if (creditLine.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Full Recognition on Specific Date') {
                    noOfIterations = 1;
                  } else if (creditLine.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Manual Recognition') {
                      noOfIterations = creditLine.Revenue_Recognition_Rule__r.No_of_manual_schedules__c.intvalue();
                  }
          
                  recognisedRevenue = 0;
          
                  if (creditLine.Revenue_Recognition_Rule__c != null) {
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
                          revenueTransaction.Account__c = creditLine.Invoice__r.Account__c;
                          revenueTransaction.Order__c = creditLine.Order__c;
                          revenueTransaction.Order_Rate_Plan_Charge__c = creditLine.Order_Rate_Plan_Charge__c;
                          revenueTransaction.Credit_Line__c = creditLine.Id;
                          revenueTransaction.Credit_Note__c = creditLine.Credit_Note__c;
                          revenueTransaction.CurrencyL__c = creditLine.CurrencyL__c;
                          revenueTransaction.Accounting_Code1__c = creditLine.Accounting_Code__c;
                          revenueTransaction.Deferred_Revenue_Accounting_Code__c = creditLine.Deferred_Revenue_Accounting_Code__c;
                          revenueTransaction.Applied_Revenue_Recognition_Rule__c = creditLine.Revenue_Recognition_Rule__c;
                          revenueTransaction.Applied_Recognition_Date_Name__c = creditLine.Revenue_Recognition_Rule__r.Recognition_Date__c;
                          revenueTransaction.Applied_Recognition_Type__c = creditLine.Revenue_Recognition_Rule__r.Recognition_Type__c;
                          revenueTransaction.Applied_Recognition_Date_Value__c = dCompare;
                          if (tempClosedMatchingRevenuePeriodForAuditReasons != null) {
                            revenueTransaction.Original_Closed_Revenue_Period__c = tempClosedMatchingRevenuePeriodForAuditReasons.Id;
                          }
                          if (isOriginalAccountingPeriodClosed) {
                            revenueTransaction.Comments__c = 'Revenue recognized in the next open revenue period as the original revenue period was closed';
                          }
                          if (UserInfo.isMultiCurrencyOrganization()) {
                            CommonUtilClass.populateCurrencyIsoCodeOnSobject(revenueTransaction, creditLine.CurrencyL__r.Name);
                          }
                          break;
                        }
                        
                      }
          
                      if (creditLine.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Monthly Recognition Over Time') {
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
                          revenueTransaction = offSetNegativeValues(revenueTransaction);
                        }
                        revenueTransactions.add(revenueTransaction);
                      }
          
                      if (creditLine.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Weighted Monthly Recognition Over Time') {
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
                          revenueTransaction = offSetNegativeValues(revenueTransaction);
                        }
                        revenueTransactions.add(revenueTransaction);
                      }
                      if (creditLine.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Daily Recognition Over Time') {
                        if (i == 0) {
                          Decimal daysInMonth = Date.daysInMonth(dCompare.year(), dCompare.month());
                          Decimal proratedDays = daysInMonth - dCompare.day() + 1;
                          revenueTransaction.Revenue_Amount__c = (proratedDays / noOfDays) * calculatedNetTotal;
                          recognisedRevenue += revenueTransaction.Revenue_Amount__c;
                          revenueTransaction.Recognised_Revenue__c = recognisedRevenue;
                          deferredRevenue = deferredRevenue - revenueTransaction.Revenue_Amount__c;
                          revenueTransaction.Deferred_Balance__c = deferredRevenue;
                          //Before adding the revenueTransaction we need to offset for negative values
                          if (isNegativeValue) {
                            revenueTransaction = offSetNegativeValues(revenueTransaction);
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
                            revenueTransaction = offSetNegativeValues(revenueTransaction);
                          }
                          revenueTransactions.add(revenueTransaction);
                        } else {
                          Decimal daysInMonth = Date.daysInMonth(dCompare.year(), dCompare.month());
                          revenueTransaction.Revenue_Amount__c = (daysInMonth / noOfDays) * calculatedNetTotal;
                          recognisedRevenue += revenueTransaction.Revenue_Amount__c;
                          revenueTransaction.Recognised_Revenue__c = recognisedRevenue;
                          deferredRevenue = deferredRevenue - revenueTransaction.Revenue_Amount__c;
                          revenueTransaction.Deferred_Balance__c = deferredRevenue;
                          //Before adding the revenueTransaction we need to offset for negative values
                          if (isNegativeValue) {
                            revenueTransaction = offSetNegativeValues(revenueTransaction);
                          }
                          revenueTransactions.add(revenueTransaction);
                        }
                      }
          
                      if (creditLine.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Full Recognition on Specific Date') {
                        revenueTransaction.Revenue_Amount__c = deferredRevenue;
                        recognisedRevenue += revenueTransaction.Revenue_Amount__c;
                        revenueTransaction.Recognised_Revenue__c = recognisedRevenue;
                        deferredRevenue = deferredRevenue - revenueTransaction.Revenue_Amount__c;
                        revenueTransaction.Deferred_Balance__c = deferredRevenue;
                        //Before adding the revenueTransaction we need to offset for negative values
                        if (isNegativeValue) {
                          revenueTransaction = offSetNegativeValues(revenueTransaction);
                        }
                        revenueTransactions.add(revenueTransaction);
                      }
                      

                      if(creditLine.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Manual Recognition' && mapOfManualSchedules.containsKey(creditLine.Revenue_Recognition_Rule__c)){
                          //Get the manual schedule from the map with the index i
                          list<Revenue_Recognition_Schedule__c> schedules = mapOfManualSchedules.get(creditLine.Revenue_Recognition_Rule__c);
                          Revenue_Recognition_Schedule__c schedule = schedules.get(i);
                          Decimal amount = calculatedNetTotal * schedule.Revenue_Percent__c/100;
                          revenueTransaction.Revenue_Amount__c = amount;

                          recognisedRevenue += revenueTransaction.Revenue_Amount__c;
                          revenueTransaction.Recognised_Revenue__c = recognisedRevenue;
                          deferredRevenue = deferredRevenue - revenueTransaction.Revenue_Amount__c;
                          revenueTransaction.Deferred_Balance__c = deferredRevenue;

                          //Before adding the revenueTransaction we need to offset for negative values
                          if (isNegativeValue) {
                              revenueTransaction = offSetNegativeValues(revenueTransaction);
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
                      if (creditLine.Revenue_Recognition_Rule__r.Recognition_Type__c != 'Manual Recognition') {
                          dCompare = dCompare.addMonths(1);
                      }
                    }
                  }
                  
                  creditLine.Revenue_Recognition_Status__c =  CommonUtilClass.STATUS_COMPLETED;
                  creditLine.Error_Reason_for_Revenue_Recognition__c = '';
                     
                  }catch (Exception ex) {
                      creditLine.Error_Reason_for_Revenue_Recognition__c = ex.getMessage();
                      creditLine.Revenue_Recognition_Status__c = 'Error';
                  }
                }

        //Delete revenue schedules for that order if any
        delete revenueTransactionsToDelete;

        insert revenueTransactions;

        //Update the charges which are processed
        update listofCreditLines;


      } catch (DMLException dMlEx) {
        database.rollback(sp);
        string sException;
        for (Integer i = 0; i < dMlEx.getNumDml(); i++) {
          sException = system.Label.ExceptionMessage + ' ' + dMlEx.getDmlMessage(i);
        }
          for (Credit_Line__c creditLine : listofCreditLines) {
              creditLine.Error_Reason_for_Revenue_Recognition__c = sException;
              creditLine.Revenue_Recognition_Status__c = 'Error';
          }
          update listofCreditLines;
        return sException;
      }  catch (Exception ex) {
        database.rollback(sp);
        string sException;
        sException = system.Label.ExceptionMessage + ex.getTypeName() + ':' + ex.getMessage() + ':LINE ' + ex.getLineNumber();
        for (Credit_Line__c creditLine : listofCreditLines) {
              creditLine.Error_Reason_for_Revenue_Recognition__c = ex.getMessage();
              creditLine.Revenue_Recognition_Status__c = 'Error';
          }
        update listofCreditLines;
        return sException;
      }
      return 'Success';
    }

    public static Revenue_Transaction__c offSetNegativeValues(Revenue_Transaction__c revenueTransaction) {

      revenueTransaction.Revenue_Amount__c = -1 * revenueTransaction.Revenue_Amount__c;
      revenueTransaction.Recognised_Revenue__c = -1 * revenueTransaction.Recognised_Revenue__c;
      revenueTransaction.Deferred_Balance__c = -1 * revenueTransaction.Deferred_Balance__c;


      return revenueTransaction;
    }
  }