public with sharing class ControllerGenerateInvoice {

            public Job__c job {get; set;}
            string sMessage;
            public boolean isAPIRequest = false;

            public ControllerGenerateInvoice(ApexPages.StandardController stdController) {
                this.job = (Job__c)stdController.getRecord();
                job = [select Id, Name, Account__c,Is_Billing_Master_Order__c From Job__c where id=:job.Id];
                
                if(job.Is_Billing_Master_Order__c) 
                 Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.Label.InvoicecannotbegeneratedFOrBillingMasterOrder));
            }

            public string generateInvoiceAPI() { 
                generateInvoice();
                return sMessage;
            }

            public PageReference generateInvoice() {
                string sOrderLegalEntity = Configuration__c.getValues('ORDER_LEGAL_ENTITY_FIELD_NAME').String_Value__c;
                string sAccountLegalEntity = Configuration__c.getValues('ACCOUNT_LEGAL_ENTITY_FIELD_NAME').String_Value__c;
                string sDefaultPaymentTerm = Configuration__c.getValues('DEFAULT_PAYMENT_TERMS_TO_BE_USED_FROM').String_Value__c;
                map<String, Sequence_Number__c> mapOfSequenceNumbersToUpdate = Sequence_Number__c.getAll().deepClone();
                map<Id, Sobject> map_Id_Sobject;
                String INVOICING_GROUP_BY = Configuration__c.getValues('INVOICE_GROUP_CRITERIA').String_Value__c;
                set<Id> listOfIds = new set<Id>();

                if(sOrderLegalEntity != null || sAccountLegalEntity != null) {
                    if(INVOICING_GROUP_BY == CommonUtilClass.INVOICING_GROUP_BY_ACCOUNT) {
                        listOfIds.add(job.Account__c);
                        map_Id_Sobject = InvoicingUtilClass.getSobjects(listOfIds, 'Account');
                    } else {
                        listOfIds.add(job.Id);
                        map_Id_Sobject = InvoicingUtilClass.getSobjects(listOfIds, 'Job__c');
                    }
                }

                SavePoint sp;
                try { 
                    
                    map<string,Payment_Terms__c> mapPaymentTerms = Payment_Terms__c.getAll();
                    String currentChargeDetails = '';
                    integer noOfDaysToDueDate;
                    Date invoiceDate = system.today();
                    Date targetDate = system.today();
                    Id currencyId;
                    String chargeStatusForInvoicing = (Configuration__c.getValues('CHARGE_STATUS_FOR_INVOICING').String_Value__c);           
                    map<Id,Job_Rate_Plan_Charge__c> mapOfChargesToUpdate = new map<Id,Job_Rate_Plan_Charge__c>();
                    sp = Database.setSavepoint();
                    job = [SELECT Is_Billing_Master_Order__c,Billing_Master_Order__c,Account__c,CurrencyL__c,Status__c,Service_End_Date__c,Service_Activation_Date__c,Number_Of_Terms__c,CurrencyL__r.Name,Payment_Plan__c
                           FROM Job__c 
                           WHERE Id =: job.Id];
                    
                    String orderStatusForInvoicing = (Configuration__c.getValues('ORDER_STATUS_FOR_INVOICING').String_Value__c);
                    if(orderStatusForInvoicing != null && orderStatusForInvoicing.trim().length() > 0 && orderStatusForInvoicing != job.Status__c) {
                        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.Label.Order_Status));
                        return null; 
                    }
                    
                    if(job.CurrencyL__c == null) {
                        if(!isAPIRequest) {
                            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.CurrencyNotAssociated);
                            Apexpages.addMessage(errorMessage);
                        } else {
                            sMessage = 'ERROR:' + system.Label.CurrencyNotAssociated;
                        }
                        return null;    
                    }

                     if(isAPIRequest && job.Is_Billing_Master_Order__c) {
                        sMessage = 'ERROR:' + 'Invoice cannot be generated for Billing Master Order';
                        return null;
                     }

                    //If the service activation date is null then throw a warning with that message
                    if(job.Service_Activation_Date__c == null) {
                        if(!isAPIRequest) {
                            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ServiceDateRequired);
                            Apexpages.addMessage(errorMessage);
                        } else {
                            sMessage = 'ERROR:' + system.Label.ServiceDateRequired;
                        }
                        return null; 
                    }else{
                        //Generate the invoices as of the service start date in that particular order.
                        targetDate = job.Service_Activation_Date__c;
                    }


                    currencyId = job.CurrencyL__c;  

                    if(job.Billing_Master_Order__c != null) {
                        InvoicingUtilClass.updateOrderChargesBillingGroup(job, targetDate);
                    }

                    Job_Rate_Plan_Charge__c[] charges;

                    //If the order has a valid payment plan then all the charges should be invoiced
                    //Check to make sure the charge.status is the same as the status field for invoicing that is taken from the custom settings

                    if(job.Payment_Plan__c == null){
                       //Filter the results based on the charge status if mentioned in the custom settings
                      if(chargeStatusForInvoicing != null && chargeStatusForInvoicing.trim().length() > 0){

                          charges = [SELECT Id,Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c,Job_Rate_Plan__r.Job_Product__r.Job__c,
                                     Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Invoice_Delivery_Type__c,Deferred_Revenue_Accounting_Code__c,
                                     Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Contact__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Shipping_Contact__c,
                                     Job_Rate_Plan__r.Job_Product__r.Product__c,Job_Rate_Plan__r.Job_Product__r.Name,Product_Rate_Plan_Charge__c,
                                     Accounting_Code__c,Name,Quantity__c,Unit_Of_Measurement__c,Charge_Date__c,Previous_Charge_Date__c,
                                     Discount_Value__c,Service_Activation_Date__c,Service_End_Date__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Service_Activation_Date__c,
                                     Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c,
                                     Job_Rate_Plan__r.Job_Product__r.Job__r.Service_End_Date__c,Price_Type__c,Price__c,Unit_Price__c,VAT__c,Tax__c, Next_Charge_Date__c,
                                     Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Payment_Terms__c,Price_Format__c, Discount_Percent__c, VAT_Percentage__c, Tax_Percentage__c,
                                     Committed_Quantity__c, Min_Customer_Spend__c, Max_Customer_Spend__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Terms__c,CurrencyL__c,
                                     Billing_Master_Order_Rate_Plan_Charge__r.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Order__c,
                                     Billing_Master_Order_Rate_Plan_Charge__r.Job_Rate_Plan__r.Job_Product__r.Job__r.Is_Billing_Master_Order__c,
                                     Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Order__c,
                                     Billing_Master_Order_Rate_Plan_Charge__r.Billing_Master_Grouped_Quantity__c,Billing_Master_Order_Rate_Plan_Charge__c,
                                     Revenue_Recognition_Rule__c, Revenue_Recognition_Start_Date__c, Revenue_Recognition_End_Date__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Plan__c,
                                     Bundle__c, Package__c, Required_By__c,Mid_Term_Adjustment__c, Is_Cumulative_Usage__c, Used_Quantity_for_Usage__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Tax_Engine__c
                                     FROM  Job_Rate_Plan_Charge__c
                                     WHERE Job_Rate_Plan__r.Job_Product__r.Job__c = :job.Id
                                     AND Job_Rate_Plan__r.Job_Product__r.Job__r.CurrencyL__c = :currencyId
                                     AND Status__c = :chargeStatusForInvoicing
                                     AND Job_Rate_Plan__r.Job_Product__r.Job__r.Service_Activation_Date__c <= :targetDate
                                     AND
                                     (
                                             (Price_Type__c = :System.Label.OptionOneTime AND Charge_Date__c = null)
                                             OR
                                             (
                                                     (   Price_Type__c = :System.Label.OptionWeekly 
                                                     OR Price_Type__c = :System.Label.OptionMonthly 
                                                     OR Price_Type__c = :System.Label.OptionQuarterly 
                                                     OR Price_Type__c = :System.Label.OptionHalfYearly 
                                                     OR Price_Type__c = :System.Label.OptionAnnual
                                                     OR Price_Type__c = :System.Label.OptionUsage
                                                             ) 
                                                             AND (Charge_Date__c = null OR Next_Charge_Date__c <= :targetDate)
                                                     )
                                             )
                          ORDER BY Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c,Job_Rate_Plan__r.Job_Product__r.Job__c,
                          Job_Rate_Plan__r.Job_Product__c,CreatedDate,Sequence_No__c];
                          
                      } else {
                          charges = [SELECT Id,Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c,Job_Rate_Plan__r.Job_Product__r.Job__c,
                                     Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Invoice_Delivery_Type__c,Deferred_Revenue_Accounting_Code__c,
                                     Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Contact__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Shipping_Contact__c,
                                     Job_Rate_Plan__r.Job_Product__r.Product__c,Job_Rate_Plan__r.Job_Product__r.Name,Product_Rate_Plan_Charge__c,
                                     Accounting_Code__c,Name,Quantity__c,Unit_Of_Measurement__c,Charge_Date__c,Previous_Charge_Date__c,
                                     Discount_Value__c,Service_Activation_Date__c,Service_End_Date__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Service_Activation_Date__c,
                                     Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c,
                                     Job_Rate_Plan__r.Job_Product__r.Job__r.Service_End_Date__c,Price_Type__c,Price__c,Unit_Price__c,VAT__c,Tax__c, Next_Charge_Date__c,
                                     Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Payment_Terms__c,Price_Format__c, Discount_Percent__c, VAT_Percentage__c, Tax_Percentage__c,
                                     Committed_Quantity__c, Min_Customer_Spend__c, Max_Customer_Spend__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Terms__c,CurrencyL__c,
                                     Billing_Master_Order_Rate_Plan_Charge__r.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Order__c,
                                     Billing_Master_Order_Rate_Plan_Charge__r.Job_Rate_Plan__r.Job_Product__r.Job__r.Is_Billing_Master_Order__c,
                                     Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Order__c,
                                     Billing_Master_Order_Rate_Plan_Charge__r.Billing_Master_Grouped_Quantity__c,Billing_Master_Order_Rate_Plan_Charge__c,
                                     Revenue_Recognition_Rule__c, Revenue_Recognition_Start_Date__c, Revenue_Recognition_End_Date__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Plan__c,
                                     Bundle__c, Package__c, Required_By__c,Mid_Term_Adjustment__c, Is_Cumulative_Usage__c, Used_Quantity_for_Usage__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Tax_Engine__c
                                     FROM  Job_Rate_Plan_Charge__c
                                     WHERE Job_Rate_Plan__r.Job_Product__r.Job__c = :job.Id
                                     AND Job_Rate_Plan__r.Job_Product__r.Job__r.CurrencyL__c = :currencyId
                                     AND Job_Rate_Plan__r.Job_Product__r.Job__r.Service_Activation_Date__c <= :targetDate
                                     AND(
                                             (Price_Type__c = :System.Label.OptionOneTime and Charge_Date__c = null)
                                             OR
                                             (   (   Price_Type__c = :System.Label.OptionWeekly 
                                             OR Price_Type__c = :System.Label.OptionMonthly 
                                             OR Price_Type__c = :System.Label.OptionQuarterly 
                                             OR Price_Type__c = :System.Label.OptionHalfYearly 
                                             OR Price_Type__c = :System.Label.OptionAnnual
                                             OR Price_Type__c = :System.Label.OptionUsage
                                                     ) 
                                                     AND (Charge_Date__c = null OR Next_Charge_Date__c <= :targetDate)
                                                     )
                                             )
                          ORDER BY Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c,Job_Rate_Plan__r.Job_Product__r.Job__c,
                          Job_Rate_Plan__r.Job_Product__c,CreatedDate,Sequence_No__c];
                                          
                      }
                    }
                    //Start - Added by DL, INVOICEIT-630, when order has payment plan, query all onetime charges - the payment plan is applicable for orders with one time charges only
                    else if(job.Payment_Plan__c != null){
                        charges = [SELECT Id,Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c,Job_Rate_Plan__r.Job_Product__r.Job__c,Status__c,
                                    Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Invoice_Delivery_Type__c,Deferred_Revenue_Accounting_Code__c,
                                    Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Contact__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Shipping_Contact__c,
                                    Job_Rate_Plan__r.Job_Product__r.Product__c,Job_Rate_Plan__r.Job_Product__r.Name,Product_Rate_Plan_Charge__c,
                                    Accounting_Code__c,Name,Quantity__c,Unit_Of_Measurement__c,Charge_Date__c,Previous_Charge_Date__c,Next_Charge_Date__c,
                                    Discount_Value__c,Service_Activation_Date__c, Service_End_Date__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Service_Activation_Date__c,
                                    Job_Rate_Plan__r.Job_Product__r.Job__r.Service_End_Date__c,Price_Type__c,Price__c,Unit_Price__c,VAT__c,Tax__c,
                                    Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c,
                                    Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Payment_Terms__c,Price_Format__c, Discount_Percent__c, VAT_Percentage__c, Tax_Percentage__c,
                                    Committed_Quantity__c, Min_Customer_Spend__c, Max_Customer_Spend__c,CurrencyL__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Terms__c,
                                    Billing_Master_Order_Rate_Plan_Charge__r.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Order__c,
                                    Billing_Master_Order_Rate_Plan_Charge__r.Job_Rate_Plan__r.Job_Product__r.Job__r.Is_Billing_Master_Order__c,
                                    Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Order__c,
                                    Billing_Master_Order_Rate_Plan_Charge__r.Billing_Master_Grouped_Quantity__c,Billing_Master_Order_Rate_Plan_Charge__c,
                                    Revenue_Recognition_Rule__c, Revenue_Recognition_Start_Date__c, Revenue_Recognition_End_Date__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Plan__c,
                                    Bundle__c, Package__c, Required_By__c,Mid_Term_Adjustment__c, Is_Cumulative_Usage__c, Used_Quantity_for_Usage__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Tax_Engine__c
                                    FROM Job_Rate_Plan_Charge__c
                                    WHERE Job_Rate_Plan__r.Job_Product__r.Job__c = : job.Id
                                    AND Price_Type__c = :System.Label.OptionOneTime 
                                    AND Charge_Date__c = null
                                    ORDER BY Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c,Job_Rate_Plan__r.Job_Product__r.Job__c,
                                    Job_Rate_Plan__r.Job_Product__c,CreatedDate,Sequence_No__c]; 

                    }
                    //For payment plan order all charges should have the same status As specified in configuration, else give message
                    if(chargeStatusForInvoicing != null && chargeStatusForInvoicing.trim().length() > 0 && job.Payment_Plan__c != null){
                        for(Job_Rate_Plan_Charge__c charge : charges){
                            if(charge.Status__c != chargeStatusForInvoicing){
                                if(!isAPIRequest) {
                                  Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.chargeStatusForInvoicing );
                                  Apexpages.addMessage(errorMessage);  
                                }
                                return null;
                            }
                        }
                    }
                    //End

                    string defaultPaymentTerms = Configuration__c.getValues('DEFAULT_PAYMENT_TERMS').String_Value__c;
                    if(charges != null && !charges.isEmpty()) {
                        
                        //Modified By : Laxman Rao M, Jira No: INVOICEIT-316        
                        map<Id, list<Usage_Charge__c>> mapOfChargeId_UnBilledUsages = new map<Id, list<Usage_Charge__c>>();
                        map<Id, decimal> mapOfChargeId_UnBilledQuantity = new map<Id, decimal>();

                        list<Usage_Charge__c> usagesLocal;
                        decimal existingUnBilledAmount;
                        for(Usage_Charge__c usageCharge : [SELECT Quantity__c, Order_Rate_Plan_Charge__c 
                                                           FROM Usage_Charge__c
                                                           WHERE End_Date__c < :targetDate
                                                           AND Status__c = :CommonUtilClass.STATUS_UNBILLED
                                                           AND Order_Rate_Plan_Charge__c IN: charges
                                                           AND Quantity__c != null]) 
                        {
                            if(mapOfChargeId_UnBilledUsages.containsKey(usageCharge.Order_Rate_Plan_Charge__c)) {
                                usagesLocal = mapOfChargeId_UnBilledUsages.get(usageCharge.Order_Rate_Plan_Charge__c);  
                                existingUnBilledAmount = mapOfChargeId_UnBilledQuantity.get(usageCharge.Order_Rate_Plan_Charge__c);     
                            } else {
                                usagesLocal = new list<Usage_Charge__c>();
                                existingUnBilledAmount = 0;
                            }       

                            // add to the existing list and put in the map
                            usagesLocal.add(usageCharge);   
                            mapOfChargeId_UnBilledUsages.put(usageCharge.Order_Rate_Plan_Charge__c, usagesLocal);   

                            // add to the existing amount and put in the map
                            existingUnBilledAmount = existingUnBilledAmount + usageCharge.Quantity__c; 
                            mapOfChargeId_UnBilledQuantity.put(usageCharge.Order_Rate_Plan_Charge__c, existingUnBilledAmount);
                        }

                       
                        //We need to create one invoice and multiple lines for each group of order/account
                        map<Id, InvoiceClass> map_Id_InvoiceClass = new map<Id, InvoiceClass>();

                        //This list holds all the usage charges to be updated
                        list<Usage_Charge__c> listOfUsageChargesToUpdate = new list<Usage_Charge__c>();

                        //INVOICEIT_630, Collecting orderIds which If it has payment plan, Added by DL
                        set<Id> setOfOrderIds = new set<Id>();
                        //Added for INVOICEIT_630
                        set<Id> setOfMidtermAdjestments = new set<Id>();

                        for(Job_Rate_Plan_Charge__c charge : charges) {

                            if(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Plan__c != null){
                                setOfOrderIds.add(charge.Job_Rate_Plan__r.Job_Product__r.Job__c);
                            }

                            if(charge.Mid_Term_Adjustment__c != null){
                                setOfMidtermAdjestments.add(charge.Mid_Term_Adjustment__c);
                            }
                            //Calculate the charge dates
                            Date calculationStartDate;
                            Date calculationEndDate;
                            boolean dateAdjusted = false;

                            //If the price type is anything apart from usage then process them straight away
                                    if( charge.Price_Type__c == System.Label.OptionWeekly || 
                                    charge.Price_Type__c == System.Label.OptionMonthly ||
                                    charge.Price_Type__c == System.Label.OptionQuarterly ||
                                    charge.Price_Type__c == System.Label.OptionHalfYearly ||
                                    charge.Price_Type__c == System.Label.OptionAnnual){
                                if(charge.Next_Charge_Date__c != null){
                                    calculationStartDate = charge.Next_Charge_Date__c;
                                }else if(charge.Service_Activation_Date__c != null){
                                    calculationStartDate = charge.Service_Activation_Date__c;
                                }else{
                                    calculationStartDate = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Service_Activation_Date__c;
                                }

                                //If calculation start date is not on the same date as the preferred billing day
                                //Then add the difference in the days to the invoicedate
                                Integer tempNoOfDays = 0;
                                Integer targetDay = targetDate.Day();
                                Integer preferredDay = 0;

                                if(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c != null){
                                    preferredDay = Integer.valueOf(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c);
                                }else if(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c != null){ 
                                    preferredDay = Integer.valueOf(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c);
                                }

                                
                                if(preferredDay != 0 && targetDay > preferredDay){
                                    //invoicedate will be next month same preferredday
                                    Integer tempDate = preferredDay;
                                    Integer tempMonth;
                                    Integer tempYear;
                                    if(targetDate.month() == 12){
                                        tempMonth = 1;
                                        tempYear = targetDate.year() + 1;
                                    }else{
                                        tempMonth = targetDate.month() + 1;
                                        tempYear = targetDate.year();
                                    }
                                    invoiceDate = date.newInstance(tempYear, tempMonth, preferredDay);
                                }else if(preferredDay != 0 && targetDay < preferredDay){
                                    //invoicedate will be this month same preferredday
                                    invoiceDate = date.newInstance(targetDate.year(), targetDate.month(), preferredDay);
                                }

                                if(preferredDay != 0 && targetDay > preferredDay){
                                    Decimal daysInInvoiceMonth = date.daysInMonth(invoiceDate.Year(), invoiceDate.Month());
                                    tempNoOfDays = Integer.valueOf(daysInInvoiceMonth) - targetDay + preferredDay;
                                   
                                }else if(preferredDay != 0 && targetDay < preferredDay){
                                    tempNoOfDays = preferredDay - targetDay;
                                   
                                }

                                //Amended on 28 Apr 2012 by MG
                  
                                if(charge.Price_Type__c == System.Label.OptionWeekly){
                                    calculationEndDate = invoiceDate.addMonths(1);
                                }
                                else if(charge.Price_Type__c == System.Label.OptionMonthly){
                                    calculationEndDate = invoiceDate.addMonths(1);
                                }
                                else if(charge.Price_Type__c == System.Label.OptionQuarterly){
                                    calculationEndDate = invoiceDate.addMonths(3);
                                }
                                else if(charge.Price_Type__c == System.Label.OptionHalfYearly){
                                    calculationEndDate = invoiceDate.addMonths(6);
                                }
                                else if(charge.Price_Type__c == System.Label.OptionAnnual){
                                    calculationEndDate = invoiceDate.addYears(1);
                                }   

                                //If the service ends before the calculation end date we would be billing only till the service end date and not the target date
                                if(charge.Service_End_Date__c != null 
                                        && charge.Service_End_Date__c < calculationEndDate){
                                    //The service end date will be one day before the actual end date... say the service starts on 14th mar and ends on 13th apr
                                    //So add 1 day to this to ensure the calculation is correct
                                    calculationEndDate = charge.Service_End_Date__c;
                                    calculationEndDate = calculationEndDate.addDays(1);
                                    dateAdjusted = true;        
                                }else if(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Service_End_Date__c != null  
                                        && charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Service_End_Date__c < calculationEndDate){
                                    //The service end date will be one day before the actual end date... say the service starts on 14th mar and ends on 13th apr
                                    //So add 1 day to this to ensure the calculation is correct
                                    calculationEndDate = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Service_End_Date__c;
                                    calculationEndDate = calculationEndDate.addDays(1);
                                    dateAdjusted = true; 
                                }               
                            }

                          
                            //To manage refunds during mid-term adjustements etc need to add another condition similar to
                            //if the partrefund config parameter is true and the next charge date is null then the calculationstartdate < calculationenddate condition can be ignored
                            boolean canRefundChargesDuringAdjustments = (Configuration__c.getValues('CAN_REFUND_CHARGES_DURING_ADJUSTMENTS').Boolean_Value__c);             
                            if( (charge.Price_Type__c == System.label.OptionOneTime)
                                    ||
                                    (charge.Price_Type__c == System.label.OptionUsage)
                                    ||
                                    (   charge.Price_Type__c != System.label.OptionOneTime
                                    && 
                                    charge.Price_Type__c != System.label.OptionUsage
                                    &&
                                    calculationStartDate < calculationEndDate
                                            )
                                            ||
                                            (   charge.Price_Type__c != System.label.OptionOneTime
                                            && 
                                            charge.Price_Type__c != System.label.OptionUsage
                                            &&
                                            canRefundChargesDuringAdjustments
                                            &&
                                            charge.Next_Charge_Date__c != null
                                                    ) )
                            {
                                
                                currentChargeDetails = '\n CurrenCharge Id : ' + charge.Id + ' \n Order Id : ' + charge.Job_Rate_Plan__r.Job_Product__r.Job__c + ' \n Account Id : ' + charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c;
                                InvoiceClass invoiceClass;
                                Invoice__c invoice;
                                list<Invoice_Lines__c> listOfInvoiceLines;

                                //If you group by orders, then use order id as the key for the map else account id
                                Id idForComparison = charge.Job_Rate_Plan__r.Job_Product__r.Job__c;

                                if(map_Id_InvoiceClass.containsKey(idForComparison)) {
                                    invoiceClass = map_Id_InvoiceClass.get(idForComparison);
                                    invoice = InvoiceClass.invoice;
                                    listOfInvoiceLines = invoiceClass.invoiceLines;
                                } else {
                                    invoiceClass = new InvoiceClass();
                                    map_Id_InvoiceClass.put(idForComparison, invoiceClass);
                                    invoice = new Invoice__c();
                                    listOfInvoiceLines = new list<Invoice_Lines__c>();

                                    invoice = new Invoice__c();
                                    invoice.account__c = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c;
                                    
                                    invoice.Invoice_Date__c = invoiceDate;
                                   
                                    /*Laxman has modified because we should calculate based on account payment terms*/
                                    /*Anil has modified because we should calculate the due DATE based on payment terms configured- Issue 80*/
                                    if(sDefaultPaymentTerm!=null && sDefaultPaymentTerm==CommonUtilClass.PAYMENT_TERM_ACCOUNT && charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Payment_Terms__c != null && mapPaymentTerms.containsKey(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Payment_Terms__c)) {
                                        noOfDaysToDueDate = (integer) mapPaymentTerms.get(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Payment_Terms__c).Number_Of_Days__c; 
                                        invoice.Due_Date__c = invoiceDate.addDays(noOfDaysToDueDate);
                                    }
                                    else if(sDefaultPaymentTerm!=null && sDefaultPaymentTerm==CommonUtilClass.PAYMENT_TERM_ORDER && charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Terms__c != null && mapPaymentTerms.containsKey(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Terms__c)) {
                                        noOfDaysToDueDate = (integer) mapPaymentTerms.get(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Terms__c).Number_Of_Days__c;
                                        invoice.Due_Date__c = invoiceDate.addDays(noOfDaysToDueDate);
                                    }
                                    else {
                                        // Dev M if defaultPaymentTerms are null the assign due date INVOICEIT-356
                                        if(mapPaymentTerms.containskey(defaultPaymentTerms)) {
                                            noOfDaysToDueDate = (integer) mapPaymentTerms.get(defaultPaymentTerms).Number_Of_Days__c;
                                            invoice.Due_Date__c = invoiceDate.addDays(noOfDaysToDueDate);   
                                        }else {
                                            invoice.Due_Date__c = invoice.Invoice_Date__c;
                                        }
                                    }
                                    invoice.Invoice_Status__c = CommonUtilClass.STATUS_DRAFT;
                                    invoice.Target_Date__c = targetDate;
                                    invoice.CurrencyL__c = currencyId;
                                    invoice.Delivery_Type__c = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Invoice_Delivery_Type__c;
                                    invoice.Billing_Contact__c = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Contact__c;
                                    invoice.Shipping_Contact__c = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Shipping_Contact__c;
                                    //Link this invoice to the order if the group by is order
                                    invoice.Order__c = idForComparison;
                                    //mapping order Tax Engine to invoice Tax Engine
                                    invoice.Tax_Engine__c = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Tax_Engine__c;

                                    //Populate the custom Invoice number based on the custom setttings
                                    sobject sObjectBasedOnGroupBy = null;
                                    string legalEnitiyName = null;
                                    if(INVOICING_GROUP_BY == CommonUtilClass.INVOICING_GROUP_BY_ACCOUNT && sAccountLegalEntity != null) {
                                        sObjectBasedOnGroupBy = map_Id_Sobject.get(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c);
                                        legalEnitiyName = (string) sObjectBasedOnGroupBy.get(sAccountLegalEntity);
                                    } else if(sOrderLegalEntity != null) {
                                        sObjectBasedOnGroupBy = map_Id_Sobject.get(charge.Job_Rate_Plan__r.Job_Product__r.Job__c);
                                        legalEnitiyName = (string) sObjectBasedOnGroupBy.get(sOrderLegalEntity);
                                    }

                                    if(sObjectBasedOnGroupBy != null && legalEnitiyName != null) {
                                        string invoiceNumber = '';
                                        if(mapOfSequenceNumbersToUpdate.containsKey(legalEnitiyName)) { 
                                            Sequence_Number__c sequenceNumber = mapOfSequenceNumbersToUpdate.get(legalEnitiyName);    
                                            // enter only if the next inoice number is not null
                                            if(sequenceNumber.Invoice_Next_Number__c != null) {
                                                // get the prefix if it not null
                                                if(sequenceNumber.Invoice_Prefix__c != null) {
                                                    invoiceNumber = sequenceNumber.Invoice_Prefix__c;
                                                }
                                                // get the Invoice_Next_Number__c
                                                invoiceNumber = invoiceNumber + string.ValueOf(Integer.ValueOf(sequenceNumber.Invoice_Next_Number__c));
                                                // get the suffix if it not null
                                                if(sequenceNumber.Invoice_Suffix__c != null) {
                                                    invoiceNumber = invoiceNumber + sequenceNumber.Invoice_Suffix__c;
                                                }
                                                // increment the Invoice_Next_Number__c and put back in map
                                                ++sequenceNumber.Invoice_Next_Number__c;
                                                mapOfSequenceNumbersToUpdate.put(legalEnitiyName, sequenceNumber);
                                                //populate the custom invoice number
                                                invoice.Invoice_Reference__c = invoiceNumber;
                                            }
                                        }
                                    }

                                    if(UserInfo.isMultiCurrencyOrganization()
                                            && job.CurrencyL__r.Name != null) 
                                    {
                                        InvoicingUtilClass.populateExchangeRateOnInvoice(invoice, job.CurrencyL__r.Name);
                                    } else {
                                        invoice.Exchange_Rate_Applied__c = 1;
                                    }
                                    invoiceClass.invoice = invoice;
                                }
                                
                                //Add the invoice lines to the list if it exists
                                Invoice_Lines__c invoiceLine = new Invoice_Lines__c();
                                invoiceLine.Job_Rate_Plan_Charge__c = charge.Id;
                                invoiceLine.Job__c = charge.Job_Rate_Plan__r.Job_Product__r.Job__c ;
                                invoiceLine.Product__c = charge.Job_Rate_Plan__r.Job_Product__r.Product__c;
                                invoiceLine.Product_Name__c = charge.Job_Rate_Plan__r.Job_Product__r.Name;
                                invoiceLine.Product_Rate_Plan_Charge__c = charge.Product_Rate_Plan_Charge__c;
                                invoiceLine.Accounting_Code__c = charge.Accounting_Code__c;
                                invoiceLine.Quantity__c = charge.Quantity__c;
                                invoiceLine.Unit_of_Measurement__c = charge.Unit_Of_Measurement__c;
                                invoiceLine.Price_Type__c = charge.Price_Type__c;
                                invoiceLine.Pricing_Model__c = charge.Price_Format__c;
                                invoiceLine.Charge_Date__c = invoiceDate;
                                //Add the revrec details
                                invoiceLine.Revenue_Recognition_Rule__c = charge.Revenue_Recognition_Rule__c;
                                invoiceLine.Revenue_Recognition_Start_Date__c = charge.Revenue_Recognition_Start_Date__c;
                                invoiceLine.Revenue_Recognition_End_Date__c = charge.Revenue_Recognition_End_Date__c;
                                // Modified By Dev.M INVOICEIT-548
                                invoiceLine.Deferred_Revenue_Accounting_Code__c = charge.Deferred_Revenue_Accounting_Code__c;
                                // Modified By Dev.M INVOICEIT-596
                                if(invoiceLine.Revenue_Recognition_Rule__c != null) {
                                    invoiceLine.Revenue_Recognition_Status__c = CommonUtilClass.STATUS_QUEUED ;
                                }
                                /*
                                                    Modified By         : Ankit Sharma  :28 Feb 2014   :INVOICEIT-322
                                                    Comments         : Populating the standard field currency (CurrencyIsoCode) only for multi currency org.
                                 */
                                if(UserInfo.isMultiCurrencyOrganization()){
                                    CommonUtilClass.populateCurrencyIsoCodeOnSobject(invoiceLine, job.CurrencyL__r.Name);
                                }

                                /*
                                                    Modified By         : Ankit Sharma  :27 Feb 2014  :INVOICEIT-319
                                                    Comments         : Look up to currency for invoice line object
                                 */
                                invoiceLine.CurrencyL__c = charge.CurrencyL__c;

                                //All the other fields for the invoiceline are different for onetime and recurring
                               if( charge.Price_Type__c == System.Label.OptionOneTime ||
                                        charge.Price_Type__c == system.Label.OptionWeekly || 
                                        charge.Price_Type__c == system.Label.OptionMonthly ||
                                        charge.Price_Type__c == system.Label.OptionQuarterly ||
                                        charge.Price_Type__c == system.Label.OptionHalfYearly ||
                                        charge.Price_Type__c == system.Label.OptionAnnual) {

                                    //These store the no of days and months inbetween both the dates
                                    Decimal noOfDays = 0;
                                    Decimal noOfMonths = 0;
                                    //This determines how many times the actual charge price to be applied
                                    Decimal noOfTimesCharge = 0;

                                    
                                    //noOfMonths = calculationStartDate.monthsBetween(calculationEndDate);

                                    if(charge.Price_Type__c == System.Label.OptionOneTime) {
                                      noOfTimesCharge = 1;
                                    }else if(charge.Price_Type__c == System.Label.OptionWeekly) {
                                        //noOfMonths = calculationStartDate.monthsBetween(calculationEndDate);
                                        noOfDays = calculationStartDate.daysBetween(calculationEndDate);
                                        noOfTimesCharge = noOfDays.Divide(7,3,System.RoundingMode.UP);
                                    }else{
                                        noOfTimesCharge = InvoicingUtilClass.calculateDiffBetweenDatesInMonths(calculationStartDate, calculationEndDate, charge.Price_Type__c);
                                    }

                                    invoiceLine.Line_Amount__c = charge.Price__c * noOfTimesCharge;
                                    invoiceLine.Discount_Value__c = charge.Discount_Value__c * noOfTimesCharge;
                                    //Naveen M added below line INVOICEIT-421
                                    invoiceLine.Calculated_Quantity__c = noOfTimesCharge;
                                    invoiceLine.Unit_Price__c = charge.Unit_Price__c;
                                    invoiceLine.Line_Name__c = charge.Name;
                                    invoiceLine.VAT__c = charge.VAT__c * noOfTimesCharge;
                                    if(invoice.Tax_Engine__c == System.Label.Standard || invoice.Tax_Engine__c == '' || invoice.Tax_Engine__c == null){
                                        invoiceLine.Tax__c = charge.Tax__c * noOfTimesCharge;
                                    }else{
                                        invoiceLine.Tax__c = 0.0;
                                    }
                                    
                                    

                                    if(charge.Price_Type__c == System.Label.OptionOneTime) {
                                        charge.Charge_Date__c = targetDate;
                                        invoiceLine.Service_Start_Date__c = targetDate;
                                    } else {
                                        invoiceLine.Service_Start_Date__c = calculationStartDate;
                                        //Modified to make sure the date shown is correct - 14mar to 13 apr instead of 14mar to 14 apr
                                        invoiceLine.Service_End_Date__c = calculationEndDate.addDays(-1);
                                    }

                                    // Code starts for Consortium Billing Here INVOICEIT-556
                                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.UsageQuantityDoesNotExist+' ' +charge.Name);
                                if(charge.Billing_Master_Order_Rate_Plan_Charge__c != null &&
                                    charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Order__c != null &&
                                    charge.Billing_Master_Order_Rate_Plan_Charge__r.Job_Rate_Plan__r.Job_Product__r.Job__r.Is_Billing_Master_Order__c
                                    && (charge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE 
                                            || charge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME )) {
                                    Decimal tempQuantity = charge.Billing_Master_Order_Rate_Plan_Charge__r.Billing_Master_Grouped_Quantity__c;
                                    invoiceLine.Quantity__c = charge.Quantity__c;
                                    if(charge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE) {

                                        Job_Rate_Plan_Charge_Tier__c[] tiers = [SELECT Unit_Price__c
                                                                                FROM Job_Rate_Plan_Charge_Tier__c
                                                                                WHERE Job_Rate_Plan_Charge__c = :charge.Billing_Master_Order_Rate_Plan_Charge__c
                                                                                        AND
                                                                                        (
                                                                                                (
                                                                                                        Start_Unit__c <= :tempQuantity
                                                                                                        AND
                                                                                                        End_Unit__c >= :tempQuantity
                                                                                                )
                                                                                                OR
                                                                                                (
                                                                                                        Start_Unit__c <= :tempQuantity
                                                                                                        AND
                                                                                                        End_Unit__c = NULL
                                                                                                )
                                                                                        )
                                                                               ];
                                        if (!tiers.isEmpty()) {
                                            invoiceLine.Unit_Price__c = tiers.get(0).Unit_Price__c ;
                                            invoiceLine.Line_Amount__c = invoiceLine.Unit_Price__c * 1 * noOfTimesCharge;
                                            invoiceLine.Discount_Value__c = (charge.Discount_Percent__c * invoiceLine.Line_Amount__c) / 100;
                                            invoiceLine.VAT__c = (charge.VAT_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c)) / 100;
                                            if(invoice.Tax_Engine__c == System.Label.Standard || invoice.Tax_Engine__c == '' || invoice.Tax_Engine__c == null){
                                                invoiceLine.Tax__c = (charge.Tax_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c)) / 100;
                                            }else{
                                                invoiceLine.Tax__c = 0.0;
                                            }
                                            
                                        } else {
                                            Apexpages.addMessage(errorMessage);
                                            return null;
                                        }

                                    } else if(charge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME) {

                                        Job_Rate_Plan_Charge_Tier__c[] tiers = [SELECT Unit_Price__c
                                                     FROM Job_Rate_Plan_Charge_Tier__c
                                                     WHERE Job_Rate_Plan_Charge__c = :charge.Billing_Master_Order_Rate_Plan_Charge__c
                                                             AND
                                                             (
                                                                 (
                                                                     Start_Unit__c <= :tempQuantity
                                                                     AND
                                                                     End_Unit__c >= :tempQuantity
                                                                 )
                                                                 OR
                                                                 (
                                                                     Start_Unit__c <= :tempQuantity
                                                                     AND
                                                                     End_Unit__c = NULL
                                                                 )
                                                             )
                                                    ];

                                        if (!tiers.isEmpty()) {
                                            invoiceLine.Unit_Price__c = tiers.get(0).Unit_Price__c;
                                            invoiceLine.Line_Amount__c = charge.Quantity__c * invoiceLine.Unit_Price__c * noOfTimesCharge;
                                            invoiceLine.Discount_Value__c = (charge.Discount_Percent__c * invoiceLine.Line_Amount__c) / 100;
                                            invoiceLine.VAT__c = (charge.VAT_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c)) / 100;
                                            if(invoice.Tax_Engine__c == System.Label.Standard || invoice.Tax_Engine__c == '' || invoice.Tax_Engine__c == null){
                                                invoiceLine.Tax__c = (charge.Tax_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c)) / 100;
                                            }else{
                                                invoiceLine.Tax__c = 0.0;
                                            }
                                            
                                        } else {
                                            Apexpages.addMessage(errorMessage);
                                            return null;
                                        }           
                                    
                                    }

                                }

                                // Code ends for Consortium Billing Here
                               if(charge.Price_Type__c != System.Label.OptionOneTime) {
                                      //Update the charge date to the target date as that is till what the charges have been calculated for
                                      charge.Previous_Charge_Date__c = charge.Charge_Date__c; 
                                      charge.Charge_Date__c = invoiceDate;

                                      //In this case the next charge date should not be populated as there is no next charge date
                                      //If during this run the charges have been calculated till the service end date, then dont populate the next charge date
                                      if(calculationEndDate >= charge.Service_End_Date__c){
                                          charge.Next_Charge_Date__c = null;
                                      }else if(calculationEndDate >= charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Service_End_Date__c){
                                          charge.Next_Charge_Date__c = null;
                                      }else{
                                          if(dateAdjusted){
                                              calculationEndDate = calculationEndDate.addDays(-1);
                                          }
                                          charge.Next_Charge_Date__c = calculationEndDate;
                                      }
                                  }    
                                }else if( charge.Price_Type__c == System.label.OptionUsage){

                                    // Modified By : Laxman Rao M, Jira No: INVOICEIT-316
                                    // get the unbilled charges from the map. if usageCharges does not contain in the map then initialize it because it will give null pointer exception
                                    Usage_Charge__c[] usageCharges;
                                    if(mapOfChargeId_UnBilledUsages.containsKey(charge.Id)) {
                                        usageCharges = mapOfChargeId_UnBilledUsages.get(charge.Id);
                                    } else {
                                        usageCharges = new list<Usage_Charge__c>();
                                    }

                                    listOfUsageChargesToUpdate.addAll(usageCharges);

                                    //Calculate the usage charges based on this quantity
                                    //Calculate the tax/vat percentage from the Tax_Percentage__c and VAT_Percentage__c fields
                                    //Perform the calculation
                                    Decimal tempQuantity = 0;
                                    Decimal chargetempQuantity = 0;
                                    // get the unbilled amount from the map. if amount does not contain then we are making the value as zero(0)
                                    if(mapOfChargeId_UnBilledQuantity.containsKey(charge.Id)) {
                                        tempQuantity = mapOfChargeId_UnBilledQuantity.get(charge.Id);

                                        // some times the quantity might be null
                                        if(tempQuantity == null) {
                                            tempQuantity = 0;       
                                        }       
                                    }

                                    //If the order charge has committed quantity populated then compare this quantity with that
                                    //If usage quantity is < committed quantity then use the committed quantity
                                    //If usage quantity >= committed quantity then use the usage quantity
                                    if( charge.Committed_Quantity__c != null 
                                            && charge.Committed_Quantity__c != 0
                                            && tempQuantity < charge.Committed_Quantity__c)
                                    {
                                        tempQuantity = charge.Committed_Quantity__c;
                                    }

                                    invoiceLine.Quantity__c = tempQuantity;
                                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.UsageQuantityDoesNotExist+' ' +charge.Name);
                                    
                                    chargetempQuantity = tempQuantity;

                                    if(charge.Used_Quantity_for_Usage__c != null && charge.Is_Cumulative_Usage__c)
                                         tempQuantity = tempQuantity + charge.Used_Quantity_for_Usage__c;

                                    if(tempQuantity > 0){
                                        //If the price model is volume pricing
                                        if(charge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME){
                                            Job_Rate_Plan_Charge_Tier__c[] tiers = [SELECT Unit_Price__c 
                                                                                    FROM Job_Rate_Plan_Charge_Tier__c
                                                                                    WHERE Job_Rate_Plan_Charge__c = :charge.Id 
                                                                                    AND 
                                                                                    (
                                                                                            (
                                                                                                    Start_Unit__c <= :tempQuantity
                                                                                                    AND 
                                                                                                    End_Unit__c >= :tempQuantity
                                                                                                    )
                                                                                                    OR
                                                                                                    (
                                                                                                            Start_Unit__c <= :tempQuantity
                                                                                                            AND 
                                                                                                            End_Unit__c = NULL
                                                                                                            )
                                                                                            )
                                            ];
                                            if(!tiers.isEmpty()) {
                                                invoiceLine.Unit_Price__c = tiers.get(0).Unit_Price__c;
                                                invoiceLine.Line_Amount__c = invoiceLine.Unit_Price__c * chargetempQuantity;
                                                invoiceLine.Discount_Value__c = (charge.Discount_Percent__c * invoiceLine.Line_Amount__c)/100;
                                                invoiceLine.Line_Name__c = charge.Name;
                                                invoiceLine.VAT__c = (charge.VAT_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c))/100;
                                                if(invoice.Tax_Engine__c == System.Label.Standard || invoice.Tax_Engine__c == '' || invoice.Tax_Engine__c == null){
                                                    invoiceLine.Tax__c = (charge.Tax_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c))/100;
                                                }else{
                                                    invoiceLine.Tax__c = 0.0;
                                                }
                                                 
                                            }else {
                                                Apexpages.addMessage(errorMessage);
                                                return null;
                                            }
                                        }else if(charge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE){
                                            Job_Rate_Plan_Charge_Tier__c[] tiers = [SELECT Unit_Price__c 
                                                                                    FROM Job_Rate_Plan_Charge_Tier__c
                                                                                    WHERE Job_Rate_Plan_Charge__c = :charge.Id  
                                                                                    AND 
                                                                                    (
                                                                                           (
                                                                                                Start_Unit__c <= :tempQuantity
                                                                                                AND 
                                                                                                End_Unit__c >= :tempQuantity
                                                                                                )
                                                                                                OR
                                                                                                (
                                                                                                Start_Unit__c <= :tempQuantity
                                                                                                AND 
                                                                                                End_Unit__c = NULL
                                                                                            )
                                                                                    )
                                            ];
                                            if(!tiers.isEmpty()) {
                                                invoiceLine.Unit_Price__c = tiers.get(0).Unit_Price__c;
                                                invoiceLine.Line_Amount__c = invoiceLine.Unit_Price__c * 1;
                                                invoiceLine.Discount_Value__c = (charge.Discount_Percent__c * invoiceLine.Line_Amount__c)/100;
                                                invoiceLine.Line_Name__c = charge.Name;
                                                invoiceLine.VAT__c = (charge.VAT_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c))/100;
                                                if(invoice.Tax_Engine__c == System.Label.Standard || invoice.Tax_Engine__c == '' || invoice.Tax_Engine__c == null){
                                                    invoiceLine.Tax__c = (charge.Tax_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c))/100; 
                                                }else{
                                                    invoiceLine.Tax__c = 0.0; 
                                                }
                                                
                                            }else {
                                                Apexpages.addMessage(errorMessage);
                                                return null;
                                            }
                                        }else if(charge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_TIERED) {
                                            list<Job_Rate_Plan_Charge_Tier__c> tempTiers = [SELECT Id, Start_Unit__c, Unit_Price__c, End_Unit__c
                                                                                            FROM Job_Rate_Plan_Charge_Tier__c
                                                                                            WHERE Job_Rate_Plan_Charge__c =: charge.Id 
                                                                                            order BY Start_Unit__c];
                                            if(tempTiers.size() == 0) {
                                                Apexpages.addMessage(errorMessage);
                                                return null; 
                                            }       
                                                                                      
                                            decimal usageAmount = 0;
                                            boolean isTierQtyExists = false;
                                            decimal remaningUsage = integer.valueof(tempQuantity);
                                            decimal usageQuantity = integer.valueof(tempQuantity);

                                            boolean hasbilledOld = false;
                                            decimal remaningCumulativeUsage = tempQuantity - chargetempQuantity;

                                            for(integer i = 0; i < tempTiers.Size(); i++) {
                                                Job_Rate_Plan_Charge_Tier__c productChargeTier = tempTiers[i];

                                                if(usageQuantity >=  productChargeTier.Start_Unit__c) {
                                                    decimal diff;
                                                    isTierQtyExists = true;
                                                    if(productChargeTier.End_Unit__c != null){
                                                        diff = integer.ValueOf(productChargeTier.End_Unit__c - productChargeTier.Start_Unit__c + 1);
                                                    }else{
                                                        diff = remaningUsage;
                                                    }

                                                    // below code for Cumulative Usage
                                                    if(charge.Is_Cumulative_Usage__c && !hasbilledOld && charge.Used_Quantity_for_Usage__c != null && charge.Used_Quantity_for_Usage__c > 0 ) {
                                                        if(remaningCumulativeUsage - diff > 0) {
                                                            productChargeTier.Unit_Price__c = 0;
                                                            remaningCumulativeUsage = remaningCumulativeUsage - diff;
                                                        } else {
                                                            hasbilledOld = true;
                                                            remaningUsage = remaningUsage - remaningCumulativeUsage;
                                                            diff = -1 * (remaningCumulativeUsage - diff);
                                                        }
                                                    }

                                                    if(remaningUsage <= diff) {
                                                        //calculate the sp
                                                        usageAmount +=  (decimal) (remaningUsage * productChargeTier.Unit_Price__c);
                                                    } else {
                                                        //calculate the sp
                                                        usageAmount +=  (decimal) (diff * productChargeTier.Unit_Price__c); 
                                                    }
                                                    remaningUsage = remaningUsage - diff;

                                                    //this means it has reached end tier and remaning Usage is still present
                                                    if(i == tempTiers.Size() - 1 && remaningUsage > 0) {
                                                        //calculate the sp
                                                        usageAmount += (remaningUsage * productChargeTier.Unit_Price__c);
                                                    }
                                                }
                                            }
                                            
                                            if(!isTierQtyExists) {
                                                Apexpages.addMessage(errorMessage); 
                                                return null;
                                            }
                                            
                                            invoiceLine.Line_Amount__c = usageAmount;
                                            invoiceLine.Unit_Price__c = usageAmount/chargetempQuantity;
                                            invoiceLine.Discount_Value__c = (charge.Discount_Percent__c * invoiceLine.Line_Amount__c)/100;
                                            invoiceLine.Line_Name__c = charge.Name;
                                            invoiceLine.VAT__c = (charge.VAT_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c))/100;
                                            if(invoice.Tax_Engine__c == System.Label.Standard || invoice.Tax_Engine__c == '' || invoice.Tax_Engine__c == null){
                                                invoiceLine.Tax__c = (charge.Tax_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c))/100; 
                                            }else{
                                                invoiceLine.Tax__c = 0.0; 
                                            }
                                            
                                        }else{
                                            invoiceLine.Unit_Price__c = charge.Unit_Price__c;
                                            invoiceLine.Line_Amount__c = invoiceLine.Unit_Price__c * tempQuantity;
                                            invoiceLine.Discount_Value__c = (charge.Discount_Percent__c * invoiceLine.Line_Amount__c)/100;
                                            invoiceLine.Line_Name__c = charge.Name;
                                            invoiceLine.VAT__c = (charge.VAT_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c))/100;
                                            if(invoice.Tax_Engine__c == System.Label.Standard || invoice.Tax_Engine__c == '' || invoice.Tax_Engine__c == null){
                                                invoiceLine.Tax__c = (charge.Tax_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c))/100; 
                                            }else{
                                                invoiceLine.Tax__c = 0.0; 
                                            }
                                            
                                        }
                                        //reset the next charge date of that charge
                                        charge.Charge_Date__c = invoiceDate;
                                        charge.Next_Charge_Date__c = null;
                                    }else{
                                        invoiceLine.Line_Amount__c = 0;
                                        invoiceLine.Discount_Value__c = 0;
                                        invoiceLine.Unit_Price__c = 0;
                                        invoiceLine.Line_Name__c = charge.Name;
                                        invoiceLine.VAT__c = 0;
                                        invoiceLine.Tax__c = 0;
                                    }

                                    //Added by MG on 06 Mar 2013 to introduce the ability to cap the invoice line amounts based on a couple of order charge fields       
                                    if(charge.Min_Customer_Spend__c > 0 
                                            && invoiceLine.Line_Amount__c < charge.Min_Customer_Spend__c)
                                    {
                                        invoiceLine.Line_Amount__c = charge.Min_Customer_Spend__c;
                                        invoiceLine.Discount_Value__c = (charge.Discount_Percent__c * invoiceLine.Line_Amount__c)/100;
                                        invoiceLine.VAT__c = (charge.VAT_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c))/100;
                                        if(invoice.Tax_Engine__c == System.Label.Standard || invoice.Tax_Engine__c == '' || invoice.Tax_Engine__c == null){
                                            invoiceLine.Tax__c = (charge.Tax_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c))/100;
                                        }else{
                                            invoiceLine.Tax__c = 0.0;
                                        }
                                        
                                    }
                                    else 
                                        if( charge.Max_Customer_Spend__c > 0
                                                && invoiceLine.Line_Amount__c > charge.Max_Customer_Spend__c)
                                        {
                                            //We are capping the customer spend here
                                            invoiceLine.Line_Amount__c = charge.Max_Customer_Spend__c;
                                            invoiceLine.Discount_Value__c = (charge.Discount_Percent__c * invoiceLine.Line_Amount__c)/100;
                                            invoiceLine.VAT__c = (charge.VAT_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c))/100;
                                            if(invoice.Tax_Engine__c == System.Label.Standard || invoice.Tax_Engine__c == '' || invoice.Tax_Engine__c == null){
                                                invoiceLine.Tax__c = (charge.Tax_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c))/100;
                                            }else{
                                                invoiceLine.Tax__c = 0.0;
                                            }
                                            
                                        }

                                    //Update the charge date to the target date as that is till what the charges have been calculated for
                                    //Update the previous charge date with the charge date
                                    if(charge.Used_Quantity_for_Usage__c == null && charge.Is_Cumulative_Usage__c)
                                        charge.Used_Quantity_for_Usage__c = chargetempQuantity;
                                    else if(charge.Is_Cumulative_Usage__c)
                                        charge.Used_Quantity_for_Usage__c = charge.Used_Quantity_for_Usage__c + chargetempQuantity;
                                    charge.Previous_Charge_Date__c = charge.Charge_Date__c; 
                                    charge.Charge_Date__c = invoiceDate;
                                    mapOfChargesToUpdate.put(charge.Id, charge);
                                }

                                //added in 1.9.1(Laxman : Partially paid invoice that is paid in full)
                                if(invoiceLine.Line_Amount__c != null && invoiceLine.Line_Amount__c > 0) {
                                    invoiceLine.Line_Amount__c = invoiceLine.Line_Amount__c.setScale(2);
                                }
                                if(invoiceLine.Discount_Value__c != null && invoiceLine.Discount_Value__c > 0) {
                                    invoiceLine.Discount_Value__c = invoiceLine.Discount_Value__c.setScale(2);
                                }
                                if(invoiceLine.VAT__c != null && invoiceLine.VAT__c > 0) {
                                    invoiceLine.VAT__c = invoiceLine.VAT__c.setScale(2);
                                }
                                if(invoiceLine.Tax__c != null && invoiceLine.Tax__c > 0) {
                                    invoiceLine.Tax__c = invoiceLine.Tax__c.setScale(2);
                                }

                                //Add the invoiceline to be created only if the quantity is > 0. This will avoid duplicate lines being created for Usage Amended BY Naveen Mallela  
                                if((invoiceline.Quantity__c > 0) || (charge.Bundle__c || charge.Package__c || charge.Required_By__c != null)) {
                                    listOfInvoiceLines.add(invoiceLine);
                                    invoiceClass.invoiceLines = listOfInvoiceLines;
                                } 
                            }
                        }

                        //Insert the invoices, invoice lines and update the charges to reflect the date changes
                        InvoicingUtilClass.insertInvoicesAndLines(map_Id_InvoiceClass, listOfUsageChargesToUpdate);

                        //modified by Devender InvoiceIT-72
                        string sInvoiceStatus = Configuration__c.getValues('MANUAL_INVOICE_GENERATION_STATUS').String_Value__c;
                        if(sInvoiceStatus != null && sInvoiceStatus == CommonUtilClass.STATUS_POSTED) {
                            Invoice__c invoiceToUpdate;
                            for(InvoiceClass invoiceClass : map_Id_InvoiceClass.values()){
                                invoiceClass.invoice.Invoice_Status__c = CommonUtilClass.STATUS_POSTED;
                                invoiceToUpdate = invoiceClass.invoice;
                            }
                            if(invoiceToUpdate != null && invoiceToUpdate.Id != null){
                                update invoiceToUpdate;
                            }
                        }  
                        //Added By Blachary InvoiceIT-685                      
                        list<AggregateResult> results = [select min(End_Date__c) enddate,  Order_Rate_Plan_Charge__c ord from Usage_Charge__c where  Status__c = 'Un-billed' And Order_Rate_Plan_Charge__c IN: charges group by Order_Rate_Plan_Charge__c];
                        Job_Rate_Plan_Charge__c charge;
                        If(results!=null){
                            for(AggregateResult result: results ){
                                id chargeid = (id)result.get('ord');
                                date nextchargedate = (date)result.get('enddate');
                                    if(mapOfChargesToUpdate.containsKey(chargeid)) {
                                        charge = mapOfChargesToUpdate.get(chargeId);
                                        charge.Next_Charge_Date__c= nextchargedate;
                                    }    
                            }
                       }
                        //Update the charges
                       update charges;                     

                        //Added by Dev M for Debit Invoice
                        if(map_Id_InvoiceClass.get(job.Id).invoice.Id != null){
                            list<Invoice__c> invoiceToUpdate = [SELECT Id, Total_Invoice_Value__c FROM Invoice__c WHERE Id =: map_Id_InvoiceClass.get(job.Id).invoice.Id];
                            if(!invoiceToUpdate.isEmpty() && invoiceToUpdate[0].Total_Invoice_Value__c < 0) {
                                Invoice__c invoiceDebit = new Invoice__c(Id = invoiceToUpdate[0].Id);
                                invoiceDebit.Debit_Invoice__c = true;
                                update invoiceDebit;
                            }
                        }
                        //INVOICEIT-630, Linking Invoice and Payment installment records Once inoice is generated. Added by DL
                        //Start
                        if(job.Payment_Plan__c != null) {
                            map<Id, list<Payment_Plan_Installment__c>> mapOfororderIdToPaymentPlanInstllment = new map<Id, list<Payment_Plan_Installment__c>>();
                            list<Payment_Plan_Installment__c> lstOfPaymentInstallmentsToUpdate = new list<Payment_Plan_Installment__c>();
                            list<Payment_Plan_Installment__c> lstOfPaymentInstallments= new list<Payment_Plan_Installment__c>();

                            Invoice__c invoiceObj; 
                            //If order has Amendments then map only related PPI to invoice, INVOICEIT-680
                                if(!setOfOrderIds.isEmpty() && !setOfMidtermAdjestments.isEmpty()){
                                for(Job__c orders : [select Id, Name, (select Id, Invoice__c, Order__c,Mid_Term_Adjustment__c From Payment_Plan_Installments__r where Mid_Term_Adjustment__c IN:setOfMidtermAdjestments) From Job__c Where Id IN:setOfOrderIds]){
                                    mapOfororderIdToPaymentPlanInstllment.put(orders.Id, orders.Payment_Plan_Installments__r);
                                }
                            }else if(!setOfOrderIds.isEmpty()){
                                for(Job__c orders : [select Id, Name, (select Id, Invoice__c, Order__c,Mid_Term_Adjustment__c From Payment_Plan_Installments__r) From Job__c Where Id IN:setOfOrderIds]){
                                    mapOfororderIdToPaymentPlanInstllment.put(orders.Id, orders.Payment_Plan_Installments__r);
                                }
                            }
                            for(InvoiceClass ic : map_Id_InvoiceClass.values()){
                                invoiceObj = ic.invoice; 
                                if(mapOfororderIdToPaymentPlanInstllment.containskey(invoiceObj.Order__c)){
                                    lstOfPaymentInstallments = mapOfororderIdToPaymentPlanInstllment.get(invoiceObj.Order__c);
                                    for(Payment_Plan_Installment__c pInstallments: lstOfPaymentInstallments){
                                        pInstallments.Invoice__c = invoiceObj.Id;
                                        lstOfPaymentInstallmentsToUpdate.add(pInstallments);
                                    }  
                                } 
                            }
                            if(!lstOfPaymentInstallmentsToUpdate.isEmpty()){
                                update lstOfPaymentInstallmentsToUpdate;
                            }
                        }
                       // End 

                        //update the custom settings
                        if(!mapOfSequenceNumbersToUpdate.isEmpty()) {
                            update mapOfSequenceNumbersToUpdate.Values();
                        }

                        string key = job.Id;
                        if(!map_Id_InvoiceClass.containsKey(key)) {
                            Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO,system.Label.NoInvoicesGenerated);
                            Apexpages.addMessage(infoMessage);
                            return null;
                        }
                        sMessage = 'SUCCESS:' + map_Id_InvoiceClass.get(key).invoice.Id;
                        return new PageReference('/' + map_Id_InvoiceClass.get(key).invoice.Id);
                    }
                    else {
                        if(!isAPIRequest) {
                            Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO,system.Label.NoInvoicesGenerated);
                            Apexpages.addMessage(infoMessage);
                        } else {
                            sMessage = 'WARNING:'+system.Label.NoInvoicesGenerated;
                        }
                    }
                } catch(DMLException dMlEx){
                    //Added by DL,NVOICEIT-665, 
                    //previously Invoice is creating without INVlines if exception comes, Now we are rollbacking all changes if exception is there 
                    Database.rollback(sp);
                    // Added by Mani ticket : INVOICEIT-310
                    Apexpages.Message errorMessage; 
                    for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                    { 
                        errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, dMlEx.getDmlMessage(i));
                        Apexpages.addMessage(errorMessage);      
                    } 
                    return null; 
                }   catch(Exception ex) {
                    Database.rollback(sp);
                    if(!isAPIRequest) {
                        Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName() + ':'+ex.getMessage() + ':'  + ex.getLineNumber());
                        Apexpages.addMessage(errorMessage);
                    } else {
                        sMessage = 'ERROR:' + ex;
                    }  
                } 
                return null; 
            }
        }