global with sharing class RevenueTransactionsForOrderUtilClass {
       
        WebService static string createRevenueForecastForOrder(Id orderId) {
            return processRevenueForecast(orderId, null);
        }
        
        // Webservice will not accept set or map.
        WebService static string createRevenueForecastForOrderCharge(list<Id> chargeId) {
            return processRevenueForecast(null, chargeId);
        }

        public static string processRevenueForecast(Id orderId, list<Id> chargeId) {
            savepoint sp = database.setsavepoint();
            try {
                list<Revenue_Forecast__c> listofrevenueForecast = new list<Revenue_Forecast__c>();
                // We need to write the code in trigger on what use cases the check box must be true.
                Date dCompare;
                Decimal recognisedRevenue;
                Decimal deferredRevenue;
                Revenue_Forecast__c revenueForecast;
                list<Revenue_Forecast__c> revenueForecasts = new list<Revenue_Forecast__c>();

                //Get the list of all revenue periods in the org
                list<Revenue_Period__c> revenuePeriods = [select Id, Name, Revenue_Period_Start_Date__c, Revenue_Period_End_Date__c,
                                                            Revenue_Period_Closed__c
                                                            FROM Revenue_Period__c
                                                            ORDER BY Revenue_Period_Start_Date__c LIMIT 10000];

                //This would store all the revenue forecasts to delete
                //Everytime the revenue forecasts are created for an order/charge, the older ones are deleted.
                list<Revenue_Forecast__c> revenueForecastsToDelete;

                //If there are any rev rec rules that are of type Manual, we need to get all their schedules in a map
                map<Id,list<Revenue_Recognition_Schedule__c>> mapOfManualSchedules = new map<Id, list<Revenue_Recognition_Schedule__c>>();

                list<Job_Rate_Plan_Charge__c> listOfCharges = new list<Job_Rate_Plan_Charge__c>();

                if (orderId != null) {
                    listOfCharges = [SELECT Id, Row_Total__c,Tax__c,VAT__c, Order__r.Number_Of_Terms__c, Revenue_Recognition_Rule__c, Revenue_Recognition_Rule__r.Name,
                                        Revenue_Recognition_Rule__r.No_of_Manual_Schedules__c,Revenue_Recognition_Rule__r.First_Manual_Schedule_Month__c,
                                        Revenue_Recognition_Rule__r.First_Manual_Schedule_Date__c, Revenue_Recognition_Rule__r.Revenue_Recognition_Schedule_Total__c,
                                        Revenue_Recognition_Rule__r.Recognition_Type__c, Revenue_Recognition_Rule__r.Recognition_Date__c,
                                        Order__r.Account__c, Service_Activation_Date__c, Service_End_Date__c,
                                        Uplift__c, Uplift_Frequency__c, Price_Type__c, Revenue_Recognition_Start_Date__c,VSOE_Package_Total__c,
                                        Revenue_Recognition_End_Date__c, CurrencyL__c, Accounting_Code__c, Deferred_Revenue_Accounting_Code__c,
                                        Bundle__c, Package__c, Required_By__c, VSOE_Pricing__c, VSOE_Total__c, Required_By__r.Unit_Price__c, Quantity__c,
                                        Required_By__r.Row_Total__c, Required_By__r.VAT__c, Required_By__r.Tax__c 
                                        FROM Job_Rate_Plan_Charge__c
                                        WHERE Order__c = : orderId
                                        AND Revenue_Recognition_Rule__c != null
                                        AND Package__c = false];

                    revenueForecastsToDelete = [SELECT Id from Revenue_Forecast__c
                                                WHERE Order__c = :orderId];
                } else {
                    listOfCharges = [SELECT Id, Row_Total__c,Tax__c,VAT__c, Order__r.Number_Of_Terms__c, Revenue_Recognition_Rule__c, Revenue_Recognition_Rule__r.Name,
                                        Revenue_Recognition_Rule__r.No_of_Manual_Schedules__c,Revenue_Recognition_Rule__r.First_Manual_Schedule_Month__c,
                                        Revenue_Recognition_Rule__r.First_Manual_Schedule_Date__c, Revenue_Recognition_Rule__r.Revenue_Recognition_Schedule_Total__c,
                                        Revenue_Recognition_Rule__r.Recognition_Type__c, Revenue_Recognition_Rule__r.Recognition_Date__c,
                                        Order__r.Account__c, Service_Activation_Date__c, Service_End_Date__c,
                                        Uplift__c, Uplift_Frequency__c, Price_Type__c, Revenue_Recognition_Start_Date__c,VSOE_Package_Total__c,
                                        Revenue_Recognition_End_Date__c, CurrencyL__c, Accounting_Code__c, Deferred_Revenue_Accounting_Code__c,
                                        Bundle__c, Package__c, Required_By__c, VSOE_Pricing__c, VSOE_Total__c, Required_By__r.Unit_Price__c, Quantity__c,
                                        Required_By__r.Row_Total__c, Required_By__r.VAT__c, Required_By__r.Tax__c 
                                        FROM Job_Rate_Plan_Charge__c
                                        WHERE Id In: chargeId
                                        AND Revenue_Recognition_Rule__c != null
                                        AND Package__c = false];

                    revenueForecastsToDelete = [SELECT Id from Revenue_Forecast__c
                                                WHERE Order_Rate_Plan_Charge__c = : chargeId];
                }

                list<Id> listOfManualRuleIds = new list<Id>();

                for (Job_Rate_Plan_Charge__c charge : listOfCharges) {
                    
                    if( charge.Revenue_Recognition_Rule__c != null
                        &&
                        charge.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Manual Recognition' 
                        &&
                        charge.Revenue_Recognition_Rule__r.No_of_Manual_Schedules__c > 0)
                    {
                        listOfManualRuleIds.add(charge.Revenue_Recognition_Rule__c);
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

                for (Job_Rate_Plan_Charge__c charge : listOfCharges) {
                    deferredRevenue = null;
                    
                    if (charge.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Manual Recognition' && charge.Revenue_Recognition_Rule__r.Revenue_Recognition_Schedule_Total__c != 100  ) {
                          throw new CustomException('Schedule Total should be 100% for selected Revenue Recognition Rule');
                    }
          
                    Date calculationStartDate;
                    Date calculationEndDate;

                    //Find the date from which the revenue has to be recognised
                    if (charge.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Service Activation Date' || charge.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Service Start Date') {
                        dCompare = charge.Service_Activation_Date__c;
                        calculationStartDate = charge.Service_Activation_Date__c;
                        calculationEndDate = charge.Service_End_Date__c;
                    } else if (charge.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Revenue Recognition Start Date') {
                        dCompare = charge.Revenue_Recognition_Start_Date__c;
                        calculationStartDate = charge.Revenue_Recognition_Start_Date__c;
                        calculationEndDate = charge.Revenue_Recognition_End_Date__c;
                    } else if (charge.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Revenue Recognition End Date') {
                        dCompare = charge.Revenue_Recognition_End_Date__c;
                        calculationStartDate = charge.Service_Activation_Date__c;
                        calculationEndDate = charge.Service_End_Date__c;
                    } else if (charge.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Service End Date') {
                        dCompare = charge.Service_End_Date__c;
                        calculationStartDate = charge.Service_Activation_Date__c;
                        calculationEndDate = charge.Service_End_Date__c;
                    } else if (charge.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Invoice Date') {
                        //Need to change this later to incorporate invoice date
                        
                    }

                    //For manual schedules, the recognition starts either based on a manual date, or based on the manual month #
                    if(charge.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Manual Recognition'){
                        if(charge.Revenue_Recognition_Rule__r.First_Manual_Schedule_Date__c != null){
                            dCompare = charge.Revenue_Recognition_Rule__r.First_Manual_Schedule_Date__c;
                        }else if(charge.Revenue_Recognition_Rule__r.First_Manual_Schedule_Month__c != null){
                            Integer noOfMonthsToAdd = (charge.Revenue_Recognition_Rule__r.First_Manual_Schedule_Month__c).intvalue();
                            dCompare = dCompare.addMonths(noOfMonthsToAdd);
                        }
                    }
                    
                    if(calculationEndDate == null && charge.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Manual Recognition')
                          calculationEndDate = dCompare;

                    Decimal noOfTimesCharge;
                    Decimal noOfTimesChargeForCalculatingTotal;
                    Decimal calculatedTotal;
                    Decimal calculatedNetTotal;
                    Decimal calculatedNetTotalForVSOE;

                    if (calculationEndDate != null) {
                        calculationEndDate = calculationEndDate.addDays(1);
                        noOfTimesCharge = calculateDiffBetweenDates(calculationStartDate, calculationEndDate, charge.Price_Type__c);
                    }
                    if (charge.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Full Recognition on Specific Date'
                        ||
                        charge.Price_Type__c == 'One Time'
                        ||
                        charge.Price_Type__c == 'Usage') 
                    {
                        noOfTimesChargeForCalculatingTotal = 1;
                    } 
                    else if(calculationEndDate != null)
                    {
                        noOfTimesChargeForCalculatingTotal = calculateDiffBetweenDates(charge.Service_Activation_Date__c, charge.Service_End_Date__c.addDays(1), charge.Price_Type__c);
                    }
                    //Added by Lopa for INVOICEIT-613 to exclude Vat and Tax from Revenue forecast records
                    calculatedNetTotal = charge.Row_Total__c - charge.VAT__c - charge.Tax__c ;
                    
                    // VSOE calculations Ticket No : INVOICEIT-658 added by Dev M
                    if(charge.VSOE_Pricing__c != null && charge.VSOE_Total__c != null && charge.VSOE_Package_Total__c != null && charge.Required_By__c != null) {
                        calculatedNetTotalForVSOE = charge.Required_By__r.Row_Total__c - charge.Required_By__r.VAT__c - charge.Required_By__r.Tax__c;
                        calculatedNetTotal = (charge.VSOE_Total__c / charge.VSOE_Package_Total__c ) * calculatedNetTotalForVSOE;
                    }

                    calculatedTotal = noOfTimesChargeForCalculatingTotal * calculatedNetTotal;
                    deferredRevenue = calculatedTotal;

                    //Get the chargeTerms
                    Decimal chargeTerms = 1.0;
                    if (charge.Price_Type__c == 'Annual') {
                        chargeTerms = 12.0;
                    } else if (charge.Price_Type__c == 'Half Yearly') {
                        chargeTerms = 6.0;
                    } else if (charge.Price_Type__c == 'Quarterly') {
                        chargeTerms = 3.0;
                    }

                    //The no of iterations is 1 if the recognition type is 'Full Recognition on Specific Date'
                    Decimal dNoOfIterations;
                    if(charge.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Full Recognition on Specific Date')
                    {   
                        dNoOfIterations = 1;
                    }else{
                        dNoOfIterations = calculateDiffBetweenDatesInMonths(calculationStartDate, calculationEndDate);
                    }

                    Long lNoOfIterations = dNoOfIterations.round(System.RoundingMode.UP);

                    Double noOfMonths;
                    Integer noOfIterations;
                    Integer noOfDays;

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
                    if ((charge.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Monthly Recognition Over Time'
                            ||
                            charge.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Weighted Monthly Recognition Over Time')
                            &&
                            (charge.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Service Activation Date' || charge.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Service Start Date')) 
                    {
                        monthlyAmount = calculatedNetTotal / chargeTerms;
                        monthlyAmount = monthlyAmount.setScale(2, System.RoundingMode.HALF_UP);
                    }
                    else if ((charge.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Monthly Recognition Over Time'
                                ||
                                charge.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Weighted Monthly Recognition Over Time')
                                &&
                                charge.Revenue_Recognition_Rule__r.Recognition_Date__c == 'Revenue Recognition Start Date') 
                    {
                        monthlyAmount = calculatedTotal / noOfMonths;
                        monthlyAmount = monthlyAmount.setScale(2, System.RoundingMode.HALF_UP);
                    }

                    //We need to add 1 to the iterations only if the endday < startday
                    Integer calculationStartDay = calculationStartDate.day();
                    //Subtract 1 day from the enddate to reset this
                    Integer calculationEndDay;
                    if(calculationEndDate != null)
                    {
                        calculationEndDay = calculationEndDate.addDays(-1).day();
                    }

                    //If the revenue recognition
                    if ((charge.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Weighted Monthly Recognition Over Time'
                            ||
                            charge.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Daily Recognition Over Time')
                            && calculationEndDay < calculationStartDay) 
                    {
                        noOfIterations++;

                    } else if (charge.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Full Recognition on Specific Date') 
                    {
                        noOfIterations = 1;
                    }
                    else if (charge.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Manual Recognition') 
                    {
                        noOfIterations = charge.Revenue_Recognition_Rule__r.No_of_manual_schedules__c.intvalue();
                    }

                    recognisedRevenue = 0;
                    charge.Recalculate_Revenue_Forecasts__c = false;

                    if (charge.Revenue_Recognition_Rule__c != null) {
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
                                        && !revenuePeriod.Revenue_Period_Closed__c))
                                {
                                    tempOpenMatchingRevenuePeriod = revenuePeriod;
                                    tempClosedMatchingRevenuePeriod = null;
                                }

                                if ( revenuePeriod.Revenue_Period_Start_Date__c <= dCompare
                                        && revenuePeriod.Revenue_Period_End_Date__c >= dCompare
                                        && revenuePeriod.Revenue_Period_Closed__c) 
                                {
                                    tempClosedMatchingRevenuePeriod = revenuePeriod;
                                    //Copy that same value for audit reasons
                                    tempClosedMatchingRevenuePeriodForAuditReasons = tempClosedMatchingRevenuePeriod;
                                    isOriginalAccountingPeriodClosed = true;
                                }


                                if ( tempOpenMatchingRevenuePeriod != null) 
                                {
                                    revenueForecast = new Revenue_Forecast__c();
                                    revenueForecast.Revenue_Period__c = tempOpenMatchingRevenuePeriod.Id;
                                    revenueForecast.Account__c = charge.Order__r.Account__c;
                                    revenueForecast.Order__c = charge.Order__c;
                                    revenueForecast.Order_Rate_Plan_Charge__c = charge.Id;
                                    revenueForecast.CurrencyL__c = charge.CurrencyL__c;
                                    revenueForecast.Accounting_Code1__c = charge.Accounting_Code__c;
                                    revenueForecast.Deferred_Revenue_Accounting_Code__c = charge.Deferred_Revenue_Accounting_Code__c;
                                    revenueForecast.Applied_Revenue_Recognition_Rule__c = charge.Revenue_Recognition_Rule__c;
                                    revenueForecast.Applied_Recognition_Date_Name__c = charge.Revenue_Recognition_Rule__r.Recognition_Date__c;
                                    revenueForecast.Applied_Recognition_Type__c = charge.Revenue_Recognition_Rule__r.Recognition_Type__c;
                                    revenueForecast.Applied_Recognition_Date_Value__c = dCompare;
                                    if(tempClosedMatchingRevenuePeriodForAuditReasons != null){
                                        revenueForecast.Original_Closed_Revenue_Period__c = tempClosedMatchingRevenuePeriodForAuditReasons.Id;  
                                    }
                                    if(isOriginalAccountingPeriodClosed){
                                        revenueForecast.Comments__c = 'Revenue recognized in the next open revenue period as the original revenue period was closed';
                                    }
                                    if(UserInfo.isMultiCurrencyOrganization()){
                                        CommonUtilClass.populateCurrencyIsoCodeOnSobject(revenueForecast, charge.CurrencyL__r.Name);
                                    }
                                }
                            }
                            if (charge.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Monthly Recognition Over Time') {
                                //For the last iteration, recognize all of the deferred revenue
                                if (i == noOfIterations - 1) {
                                    revenueForecast.Revenue_Amount__c = deferredRevenue;
                                    recognisedRevenue += revenueForecast.Revenue_Amount__c;
                                    revenueForecast.Recognised_Revenue__c = recognisedRevenue;
                                    deferredRevenue = deferredRevenue - revenueForecast.Revenue_Amount__c;
                                    revenueForecast.Deferred_Balance__c = deferredRevenue;
                                } else {
                                    revenueForecast.Revenue_Amount__c = monthlyAmount;
                                    recognisedRevenue += revenueForecast.Revenue_Amount__c;
                                    revenueForecast.Recognised_Revenue__c = recognisedRevenue;
                                    deferredRevenue = deferredRevenue - revenueForecast.Revenue_Amount__c;
                                    revenueForecast.Deferred_Balance__c = deferredRevenue;
                                }

                                revenueForecasts.add(revenueForecast);
                            }
                            if (charge.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Weighted Monthly Recognition Over Time') {
                                if (i == 0) {
                                    Date lastDayOfThisMonth = Date.newInstance(dCompare.year(), dCompare.month(), Date.daysInMonth(dCompare.year(), dCompare.month()));
                                    //Add 1 day to this to make sure the days in between also includes the end date
                                    lastDayOfThisMonth = lastDayOfThisMonth.addDays(1);
                                    Decimal noOfTimesForCalculation = calculateDiffBetweenDatesInMonths(dCompare, lastDayOfThisMonth);

                                    revenueForecast.Revenue_Amount__c = noOfTimesForCalculation * monthlyAmount;
                                    recognisedRevenue += revenueForecast.Revenue_Amount__c;
                                    revenueForecast.Recognised_Revenue__c = recognisedRevenue;
                                    deferredRevenue = deferredRevenue - revenueForecast.Revenue_Amount__c;
                                    revenueForecast.Deferred_Balance__c = deferredRevenue;
                                    revenueForecasts.add(revenueForecast);
                                } else if (i == noOfIterations - 1) {
                                    revenueForecast.Revenue_Amount__c = deferredRevenue;
                                    recognisedRevenue += revenueForecast.Revenue_Amount__c;
                                    revenueForecast.Recognised_Revenue__c = recognisedRevenue;
                                    deferredRevenue = deferredRevenue - revenueForecast.Revenue_Amount__c;
                                    revenueForecast.Deferred_Balance__c = deferredRevenue;
                                    revenueForecasts.add(revenueForecast);
                                } else {
                                    revenueForecast.Revenue_Amount__c = monthlyAmount;
                                    recognisedRevenue += revenueForecast.Revenue_Amount__c;
                                    revenueForecast.Recognised_Revenue__c = recognisedRevenue;
                                    deferredRevenue = deferredRevenue - revenueForecast.Revenue_Amount__c;
                                    revenueForecast.Deferred_Balance__c = deferredRevenue;
                                    revenueForecasts.add(revenueForecast);
                                }
                            }
                            if (charge.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Daily Recognition Over Time') {
                                if (i == 0) {
                                    Decimal daysInMonth = Date.daysInMonth(dCompare.year(), dCompare.month());
                                    Decimal proratedDays = daysInMonth - dCompare.day() + 1;
                                    revenueForecast.Revenue_Amount__c = (proratedDays / noOfDays) * noOfTimesCharge * calculatedNetTotal;
                                    recognisedRevenue += revenueForecast.Revenue_Amount__c;
                                    revenueForecast.Recognised_Revenue__c = recognisedRevenue;
                                    deferredRevenue = deferredRevenue - revenueForecast.Revenue_Amount__c;
                                    revenueForecast.Deferred_Balance__c = deferredRevenue;
                                    revenueForecasts.add(revenueForecast);
                                } else if (i == noOfIterations - 1) {
                                    revenueForecast.Revenue_Amount__c = deferredRevenue;
                                    recognisedRevenue += revenueForecast.Revenue_Amount__c;
                                    revenueForecast.Recognised_Revenue__c = recognisedRevenue;
                                    deferredRevenue = deferredRevenue - revenueForecast.Revenue_Amount__c;
                                    revenueForecast.Deferred_Balance__c = deferredRevenue;
                                    revenueForecasts.add(revenueForecast);
                                } else {
                                    Decimal daysInMonth = Date.daysInMonth(dCompare.year(), dCompare.month());
                                    revenueForecast.Revenue_Amount__c = (daysInMonth / noOfDays) * noOfTimesCharge * calculatedNetTotal;
                                    recognisedRevenue += revenueForecast.Revenue_Amount__c;
                                    revenueForecast.Recognised_Revenue__c = recognisedRevenue;
                                    deferredRevenue = deferredRevenue - revenueForecast.Revenue_Amount__c;
                                    revenueForecast.Deferred_Balance__c = deferredRevenue;
                                    revenueForecasts.add(revenueForecast);
                                }
                            }
                            if (charge.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Full Recognition on Specific Date') {
                                revenueForecast.Revenue_Amount__c = deferredRevenue;
                                recognisedRevenue += revenueForecast.Revenue_Amount__c;
                                revenueForecast.Recognised_Revenue__c = recognisedRevenue;
                                deferredRevenue = deferredRevenue - revenueForecast.Revenue_Amount__c;
                                revenueForecast.Deferred_Balance__c = deferredRevenue;
                                revenueForecasts.add(revenueForecast);
                            }

                            if(charge.Revenue_Recognition_Rule__r.Recognition_Type__c == 'Manual Recognition' && mapOfManualSchedules.containsKey(charge.Revenue_Recognition_Rule__c)){
                                    //Get the manual schedule from the map with the index i
                                    list<Revenue_Recognition_Schedule__c> schedules = mapOfManualSchedules.get(charge.Revenue_Recognition_Rule__c);
                                    Revenue_Recognition_Schedule__c schedule = schedules.get(i);
                                    
                                    Decimal amount = calculatedTotal * schedule.Revenue_Percent__c/100;
                                    revenueForecast.Revenue_Amount__c = amount;
                                    recognisedRevenue += revenueForecast.Revenue_Amount__c;
                                    revenueForecast.Recognised_Revenue__c = recognisedRevenue;
                                    deferredRevenue = deferredRevenue - revenueForecast.Revenue_Amount__c;
                                    revenueForecast.Deferred_Balance__c = deferredRevenue;

                                    revenueForecasts.add(revenueForecast);


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
                            if (charge.Revenue_Recognition_Rule__r.Recognition_Type__c != 'Manual Recognition') {
                                dCompare = dCompare.addMonths(1);
                            }
                        }

                        charge.Recalculate_Revenue_Forecasts__c = false;
                    }
                }

                //Delete revenue schedules for that order if any
                delete revenueForecastsToDelete;

                insert revenueForecasts;
                //Update the charges which are processed
                update listOfCharges;

            } catch (DMLException dMlEx) {
                database.rollback(sp);
                string sException;
                for (Integer i = 0; i < dMlEx.getNumDml(); i++) {
                    sException = system.Label.ExceptionMessage + ' ' + dMlEx.getDmlMessage(i);
                }

                return sException;

            }  catch (Exception ex) {
                database.rollback(sp);
                string sException;
                sException = system.Label.ExceptionMessage + ex.getTypeName() + ':' + ex.getMessage() + ':LINE ' + ex.getLineNumber();
                return sException;
            }
            return 'Success';
        }

        public static double calculateDiffBetweenDates(date calculationStartDate, date calculationEndDate, String priceType) {
            double noOfMonthsComputed = 0;
            double noOfDaysComputed = 0;
            double noOfTimesCharge = 0;

            double noOfMonths = calculationStartDate.monthsBetween(calculationEndDate);
            // as a industry standard, we need to bill prorated days as days/30 days
            double daysInAMonth = 30.0;

            // just verify the dates by adding the noOfMonths
            // If dates are equal then 100%, we need to charges for noOfMonths
            // If dates are not equal then we need to calculate for how many extra days we need to compute i.e (noOfMonths - 1) + ExtraDays
            if (calculationStartDate.addMonths(Integer.ValueOf(noOfMonths)) == calculationEndDate) {
                noOfMonthsComputed = noOfMonths;
                noOfDaysComputed = 0;

                noOfTimesCharge = noOfMonths;
            } else {
                noOfMonthsComputed = noOfMonths - 1;
                date removedComputedMonths = calculationStartDate.addMonths(integer.ValueOf(noOfMonthsComputed));
                double remainingDays = removedComputedMonths.daysBetween(calculationEndDate);
                noOfDaysComputed = remainingDays;

                // Some time remaning day might be greather than 30+ when noOfMonths is not calculated properly
                if (remainingDays > 28) {
                    date oneMonthFront = removedComputedMonths.addMonths(1);
                    ++noOfMonthsComputed;
                    remainingDays = oneMonthFront.daysBetween(calculationEndDate);
                }

                if (noOfMonthsComputed <= 0) {
                    // this is for calculations like : (five days) or (three days)
                    noOfMonths = (remainingDays / daysInAMonth);

                } else {
                    // use the endDate Month for calculating the remanining days
                    // subtract one day since both days are included
                    noOfMonths = noOfMonthsComputed + (remainingDays / daysInAMonth);
                }
            }

            if (priceType == 'Monthly') {
                noOfTimesCharge = noOfMonths;
            } else if (priceType == 'Quarterly') {
                noOfTimesCharge = noOfMonths / 3;
            } else if (priceType == 'Half Yearly') {
                noOfTimesCharge = noOfMonths / 6;
            } else if (priceType == 'Annual') {
                noOfTimesCharge = noOfMonths / 12;
            } else if (priceType == 'One Time' || priceType == 'Usage') {
                noOfTimesCharge = noOfMonths;
            }

            return noOfTimesCharge;
        }

        public static double calculateDiffBetweenDatesInMonths(date calculationStartDate, date calculationEndDate) {
            double noOfMonthsComputed = 0;
            double noOfDaysComputed = 0;
            double noOfTimesCharge = 0;

            double noOfMonths = calculationStartDate.monthsBetween(calculationEndDate);
            // as a industry standard, we need to bill prorated days as days/30 days
            double daysInAMonth = 30.0;

            // just verify the dates by adding the noOfMonths
            // If dates are equal then 100%, we need to charges for noOfMonths
            // If dates are not equal then we need to calculate for how many extra days we need to compute i.e (noOfMonths - 1) + ExtraDays
            if (calculationStartDate.addMonths(Integer.ValueOf(noOfMonths)) == calculationEndDate) {
                noOfMonthsComputed = noOfMonths;
                noOfDaysComputed = 0;

                noOfTimesCharge = noOfMonths;
            } else {
                noOfMonthsComputed = noOfMonths - 1;
                date removedComputedMonths = calculationStartDate.addMonths(integer.ValueOf(noOfMonthsComputed));
                double remainingDays = removedComputedMonths.daysBetween(calculationEndDate);
                noOfDaysComputed = remainingDays;

                // Some time remaning day might be greather than 30+ when noOfMonths is not calculated properly
                if (remainingDays > 28) {
                    date oneMonthFront = removedComputedMonths.addMonths(1);
                    ++noOfMonthsComputed;
                    remainingDays = oneMonthFront.daysBetween(calculationEndDate);
                }

                if (noOfMonthsComputed <= 0) {
                    // this is for calculations like : (five days) or (three days)
                    noOfMonths = (remainingDays / daysInAMonth);

                } else {
                    // use the endDate Month for calculating the remanining days
                    // subtract one day since both days are included
                    noOfMonths = noOfMonthsComputed + (remainingDays / daysInAMonth);
                }
            }

            return noOfMonths;
        }
    }