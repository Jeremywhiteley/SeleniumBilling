global with sharing class CustomInvoiceGenerator {
    /*Note : 1) Do not change the response messages, since we have done ad hoc invoices for many clients
             2) Based on this error message we are checking some conditions in ControllerCreateAdhocInvoice class
    */
    string sMessage = '';
    String currentChargeDetails;
    sobject datedConversionRate;
    boolean shouldBillOneTimeChargesBasedOnServiceActivation;
    string currencyIsoCode;
    list<Invoice__c> invoicesToPost = new list<Invoice__c>();
    boolean alignOrderDateToProducts;
    string sOrderLegalEntity;
    string sAccountLegalEntity;
    public String sPrefix = CommonUtilClass.getPrefix();
    
    public Invoice__c invoiceObj = new Invoice__c(); 
    public list<Invoice_Lines__c> listOfInvoiceLinesForPreview = new list<Invoice_Lines__c>();
    //variable for sDefaultPaymentTerm
    string sDefaultPaymentTerm = Configuration__c.getValues('DEFAULT_PAYMENT_TERMS_TO_BE_USED_FROM').String_Value__c;
    
    
    global String generateInvoiceForOrder(Id orderId, Date invoiceDate, Date targetDate, boolean shouldBillUsages, boolean simulateInvoiceGeneration, boolean autoPostInvoice) {
        if(targetDate == null){
            targetDate = invoiceDate;
        }

        SavePoint sp;
        try {
            sp = Database.setSavepoint();
            Job__c job = [  SELECT Billing_Master_Order__c,Account__c,CurrencyL__c,Service_End_Date__c,Service_Activation_Date__c,Number_Of_Terms__c,Payment_Terms__c,CurrencyL__r.Name, Is_Billing_Master_Order__c, Payment_Plan__c
                            FROM Job__c
                            WHERE Id =: orderId];
            
            
            
            sOrderLegalEntity = Configuration__c.getValues('ORDER_LEGAL_ENTITY_FIELD_NAME').String_Value__c;
            sAccountLegalEntity = Configuration__c.getValues('ACCOUNT_LEGAL_ENTITY_FIELD_NAME').String_Value__c;
            shouldBillOneTimeChargesBasedOnServiceActivation = Configuration__c.getValues('BILL_ONETIME_CHARGES_BASED_ON_DATES').Boolean_Value__c;
            alignOrderDateToProducts = Configuration__c.getValues('ALIGN_DATES_OF_ORDER_TO_PRODUCTS').Boolean_Value__c;
           
            if(UserInfo.isMultiCurrencyOrganization()) {
                datedConversionRate = CommonUtilClass.getExchangeRateByDate(invoiceDate, job.CurrencyL__r.Name);
                currencyIsoCode = job.CurrencyL__r.Name;
            }
           
            map<String, Sequence_Number__c> mapOfSequenceNumbersToUpdate = Sequence_Number__c.getAll().deepClone();
            //Get all the data for the order
            map<Id, Sobject> map_Id_Sobject = InvoicingUtilClass.getSobjects(new set<Id>{orderId}, 'Job__c');
       
            map<string,Payment_Terms__c> mapPaymentTerms = Payment_Terms__c.getAll();
            map<Id,Job_Rate_Plan_Charge__c> mapOfChargesToUpdate = new map<Id,Job_Rate_Plan_Charge__c>();
            Integer noOfDaysToDueDate;
            Id currencyId;
            String chargeStatusForInvoicing = (Configuration__c.getValues('CHARGE_STATUS_FOR_INVOICING').String_Value__c);     
           
            //If the service activation date is null then throw a warning with that message
            if(job.Service_Activation_Date__c == null) {
                sMessage = 'ERROR:' + system.Label.ServiceDateRequired;
                return sMessage;
            }
            
            if(job.Is_Billing_Master_Order__c){
                sMessage = 'ERROR:' + 'Invoice cannot be generated for Billing Master Order';
                return sMessage;
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
                if(chargeStatusForInvoicing != null && chargeStatusForInvoicing.trim().length() > 0)
                {
                    charges = [SELECT Id,Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c,Job_Rate_Plan__r.Job_Product__r.Job__c,
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
                                WHERE Job_Rate_Plan__r.Job_Product__r.Job__c = : orderId
                                AND Status__c = :chargeStatusForInvoicing
                                AND Service_Activation_Date__c <= :targetDate
                                AND
                                (
                                    (Price_Type__c = :System.Label.OptionOneTime AND Charge_Date__c = null)
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
                } else {
                    charges = [SELECT Id,Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c,Job_Rate_Plan__r.Job_Product__r.Job__c,
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
                                WHERE Job_Rate_Plan__r.Job_Product__r.Job__c = : orderId
                                AND Service_Activation_Date__c <= :targetDate
                                AND
                                (
                                    (Price_Type__c = :System.Label.OptionOneTime AND Charge_Date__c = null)
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
                            WHERE Job_Rate_Plan__r.Job_Product__r.Job__c = : orderId
                            AND Price_Type__c = :System.Label.OptionOneTime 
                            AND Charge_Date__c = null
                            ORDER BY Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c,Job_Rate_Plan__r.Job_Product__r.Job__c,
                            Job_Rate_Plan__r.Job_Product__c,CreatedDate,Sequence_No__c]; 

            }
            
            //For payment plan order all charges should have the same status As specified in configuration, else give message
            if(chargeStatusForInvoicing != null && chargeStatusForInvoicing.trim().length() > 0 && job.Payment_Plan__c != null){
                for(Job_Rate_Plan_Charge__c charge : charges){
                    if(charge.Status__c != chargeStatusForInvoicing){
                        sMessage = 'ERROR:'+ 'According to your configuration all charges for payment plan order should have the status as: '+chargeStatusForInvoicing;
                        return sMessage;
                    }
                }
            }
            //End
            
            
            string defaultPaymentTerms = Configuration__c.getValues('DEFAULT_PAYMENT_TERMS').String_Value__c;
            //This list holds all the usage charges to be updated
            list<Usage_Charge__c> listOfUsageChargesToUpdate = new list<Usage_Charge__c>();
           
            //We need to create one invoice and multiple lines for each group of order/account
            map<Id, InvoiceClass> map_Id_InvoiceClass = new map<Id, InvoiceClass>();
           
            /*
                Modified By : Laxman Rao M, Jira No: INVOICEIT-316
               
                Below are the changes done for optimizing the query results.
                Previous Problem : Previously we are querying the usageCharges inside the for loop it was hiting the governor limits
                Below will create a three maps, one will store the listOfUnBilledCharges and second one will store the UnBilled quantity
                mapOfChargeId_UnBilledUsages --> key is orderRatePlanChargeId and value is list of unbilled usage charges
                mapOfChargeId_UnBilledQuantity --> key is orderRatePlanChargeId and value is the unBilled sum
                mapOfGroupId_Group --> key is groupId and value is group object record
               
                What I have changed -->
                A) we get the unbilled quantity from the map
                B) we get the unbilled usage charge object from the map(i.e list)
                C) we get the number of charges present in the group based on the groupId
            */
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
            //INVOICEIT_630, Collecting orderIds which If it has payment plan, Added by DL
            set<Id> setOfOrderIds = new set<Id>();
            set<Id> setOfMidtermAdjestments = new set<Id>();
            for(Job_Rate_Plan_Charge__c charge : charges){

               if(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Plan__c != null){
                    setOfOrderIds.add(charge.Job_Rate_Plan__r.Job_Product__r.Job__c);
               }
               if(charge.Mid_Term_Adjustment__c != null){
                    setOfMidtermAdjestments.add(charge.Mid_Term_Adjustment__c);
               }
               // added by ram, for existing records if percentage or value is null then invoice is not generating
                if(charge.Discount_Percent__c == null){
                    charge.Discount_Percent__c = 0;
                 }
               
               if(charge.Discount_Value__c == null){
                   charge.Discount_Value__c = 0;
               }
                
                currentChargeDetails = '\n Current Charge Id : ' + charge.Id + ' \n Order Id : ' + charge.Job_Rate_Plan__r.Job_Product__r.Job__c + ' \n Account Id : ' + charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c;
               
                //Calculate the charge dates
                Date calculationStartDate;
                Date calculationEndDate;
                boolean dateAdjusted = false;
               
                //If the price type is anything apart from usage then process them straight away
                //If the price type is usage process them only if shouldBillUsages is true
                //Also there appears to be a bug with the billing process where the service start date for the line is greater than service end date
                //especially when the charge date is null, the calculated value is negative
                //To tackle this we need filter out the charges where the charge date is null and the calculationstartdate > targetdate
                //To handle this we need to calculate the calculationstartdate and calculationenddate here
                if( charge.Price_Type__c == System.Label.OptionWeekly ||
                    charge.Price_Type__c == System.Label.OptionMonthly ||
                    charge.Price_Type__c == System.Label.OptionQuarterly ||
                    charge.Price_Type__c == System.Label.OptionHalfYearly ||
                    charge.Price_Type__c == System.Label.OptionAnnual){
                   
                    
                    if(charge.Next_Charge_Date__c != null){
                        calculationStartDate = charge.Next_Charge_Date__c;
                    }
                    else if(charge.Service_Activation_Date__c != null)
                    {
                        calculationStartDate = charge.Service_Activation_Date__c;
                    }
                    //If the ALIGN_DATES_OF_ORDER_TO_PRODUCTS parameter is false, then the charge dates are separate from order
                    //So only if the parameter is true take the service activation date from the order
                    else if(alignOrderDateToProducts && charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Service_Activation_Date__c != null)
                    {
                        calculationStartDate = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Service_Activation_Date__c;
                    }
                   
                    //The invoice gets generated every month on the preferred billing day
                    //So align the end date to be invoice date + 1 month for weekly and monthly
                    //This ensures the charge is billed from the service activation date to invoice date in arrears and then 1 period in advance
                    //The charges for quarterly and above are not aligned as they need to be based on the service activation date always
                   
                    if(calculationStartDate != null){
                        if(charge.Price_Type__c == System.Label.OptionWeekly){
                            calculationEndDate = targetDate.addMonths(1);
                        }
                        else if(charge.Price_Type__c == System.Label.OptionMonthly){
                            calculationEndDate = targetDate.addMonths(1);
                        }
                        else if(charge.Price_Type__c == System.Label.OptionQuarterly){
                            calculationEndDate = targetDate.addMonths(3);
                        }
                        else if(charge.Price_Type__c == System.Label.OptionHalfYearly){
                            calculationEndDate = targetDate.addMonths(6);
                        }
                        else if(charge.Price_Type__c == System.Label.OptionAnnual){
                            calculationEndDate = targetDate.addYears(1);
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
                }
                else if(charge.Price_Type__c == System.Label.OptionOneTime || charge.Price_Type__c == System.Label.OptionUsage)
                {
                    
                    if(charge.Service_Activation_Date__c != null)
                    {
                        calculationStartDate = charge.Service_Activation_Date__c;
                    }
                    //If the ALIGN_DATES_OF_ORDER_TO_PRODUCTS parameter is false, then the charge dates are separate from order
                    //This would mean if the parameter is false the
                    else if(alignOrderDateToProducts && charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Service_Activation_Date__c != null)
                    {
                        calculationStartDate = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Service_Activation_Date__c;
                    }
                }

                //To manage refunds during mid-term adjustements etc need to add another condition similar to
                //if the partrefund config parameter is true and the next charge date is null then the calculationstartdate < calculationenddate condition can be ignored
               
                boolean canRefundChargesDuringAdjustments = (Configuration__c.getValues('CAN_REFUND_CHARGES_DURING_ADJUSTMENTS').Boolean_Value__c);
               
                //If the config parameter BILL_ONETIME_CHARGES_BASED_ON_DATES is true then pick up those one time charges
                //that have their Service_Activation_Date__c on or before the target date
               
                if( calculationStartDate != null
                    &&
                    ((charge.Price_Type__c == System.label.OptionOneTime && shouldBillOneTimeChargesBasedOnServiceActivation && charge.Service_Activation_Date__c <= targetDate)
                    ||
                    (charge.Price_Type__c == System.label.OptionOneTime && !shouldBillOneTimeChargesBasedOnServiceActivation)
                    ||
                    (charge.Price_Type__c == System.label.OptionUsage && shouldBillUsages)
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
                    ) ) )
                {
       
                    currentChargeDetails = '\n Current Charge Id : ' + charge.Id + ' \n Order Id : ' + charge.Job_Rate_Plan__r.Job_Product__r.Job__c + ' \n Account Id : ' + charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c;
                    InvoiceClass invoiceClass;
                    Invoice__c invoice;
                    list<Invoice_Lines__c> listOfInvoiceLines;
                   
                    if(map_Id_InvoiceClass.containsKey(job.Id)) {
                        invoiceClass = map_Id_InvoiceClass.get(job.Id);
                        invoice = InvoiceClass.invoice;
                        listOfInvoiceLines = invoiceClass.invoiceLines;
                     }else{
                        invoiceClass = new InvoiceClass();
                        map_Id_InvoiceClass.put(job.Id, invoiceClass);
                        invoice = new Invoice__c();
                        listOfInvoiceLines = new list<Invoice_Lines__c>();
                       
                        invoice.account__c = job.Account__c;
                        invoice.Invoice_Date__c = invoiceDate;
                       
                        /*
                            New code added for this ticket INVOICEIT-340
                        */
                       
                        if(sDefaultPaymentTerm != null && sDefaultPaymentTerm == CommonUtilClass.PAYMENT_TERM_ACCOUNT && charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Payment_Terms__c != null && mapPaymentTerms.containsKey(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Payment_Terms__c)) {
                            
                            noOfDaysToDueDate = (integer) mapPaymentTerms.get(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Payment_Terms__c).Number_Of_Days__c;
                            invoice.Due_Date__c = invoiceDate.addDays(noOfDaysToDueDate);
                        } else if(sDefaultPaymentTerm!=null && sDefaultPaymentTerm==CommonUtilClass.PAYMENT_TERM_ORDER && charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Terms__c != null && mapPaymentTerms.containsKey(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Terms__c)) {
                            
                            noOfDaysToDueDate = (integer) mapPaymentTerms.get(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Terms__c).Number_Of_Days__c;
                            invoice.Due_Date__c = invoiceDate.addDays(noOfDaysToDueDate);
                        } else {
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
                        invoice.Order__c = job.Id;
                        //mapping order Tax Engine to invoice Tax Engine
                        invoice.Tax_Engine__c = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Tax_Engine__c;
                       
                        /*//Populate the custom Invoice number based on the custom setttings - Legal Entity
                        String legalEntityName;
                        if(sOrderLegalEntity != null){
                            sObject jobSObject = map_Id_Sobject.get(charge.Job_Rate_Plan__r.Job_Product__r.Job__c);
                            legalEntityName = (string) jobSObject.get(sOrderLegalEntity);
                        }*/
                       
                        /*
                            Modified By : Laxman Rao M,
                            Reason : Invoice Reference number is not being populated when we use adHoc button
                            Ref : INVOICEIT-311, Date : [05/02/2014]
                        */
                        map<Id, Sobject> map_Id_Sobject_LE;
                        String INVOICING_GROUP_BY = (Configuration__c.getValues('INVOICE_GROUP_CRITERIA').String_Value__c);
                        set<Id> listOfIds = new set<Id>();
                        if(INVOICING_GROUP_BY == CommonUtilClass.INVOICING_GROUP_BY_ACCOUNT) {
                            listOfIds.add(job.Account__c);
                        } else {
                            listOfIds.add(job.Id);
                        }
               
                        if(sOrderLegalEntity != null || sAccountLegalEntity != null) {
                            if(INVOICING_GROUP_BY == CommonUtilClass.INVOICING_GROUP_BY_ACCOUNT) {
                                map_Id_Sobject_LE = InvoicingUtilClass.getSobjects(listOfIds, 'Account');
                            } else {
                                map_Id_Sobject_LE = InvoicingUtilClass.getSobjects(listOfIds, 'Job__c');
                            }
                        }
                        
                       
                        //Populate the custom Invoice number based on the custom setttings
                        sobject sObjectBasedOnGroupBy = null;
                        string legalEntityName = null;
                        if(INVOICING_GROUP_BY == CommonUtilClass.INVOICING_GROUP_BY_ACCOUNT && sAccountLegalEntity != null) {
                            sObjectBasedOnGroupBy = map_Id_Sobject_LE.get(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c);
                            legalEntityName = (string) sObjectBasedOnGroupBy.get(sAccountLegalEntity);
                        } else if(sOrderLegalEntity != null) {
                            sObjectBasedOnGroupBy = map_Id_Sobject_LE.get(charge.Job_Rate_Plan__r.Job_Product__r.Job__c);
                            legalEntityName = (string) sObjectBasedOnGroupBy.get(sOrderLegalEntity);
                        }
                        if(sObjectBasedOnGroupBy != null && legalEntityName != null) {
                            string invoiceNumber = '';
                            if(mapOfSequenceNumbersToUpdate.containsKey(legalEntityName)) {
                                Sequence_Number__c sequenceNumber = mapOfSequenceNumbersToUpdate.get(legalEntityName);
                                // enter only if the next invoice next number is not null
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
                                    mapOfSequenceNumbersToUpdate.put(legalEntityName, sequenceNumber);
                                    //populate the custom invoice number
                                    invoice.Invoice_Reference__c = invoiceNumber;
                                }
                            }
                        }
                       //If the user has multi-currency activated then populate the exchange rates
                        if(UserInfo.isMultiCurrencyOrganization()) {
                            if(datedConversionRate != null) {
                                sobject sobjectInvoice = (sobject)invoice;
                                sobjectInvoice.put(sPrefix+'Exchange_Rate_Applied__c',(decimal) datedConversionRate.get('ConversionRate'));
                                sobjectInvoice.put('CurrencyIsoCode',(string) currencyIsoCode);
                                invoice = (Invoice__c) sobjectInvoice;
                            } else {
                                invoice.Exchange_Rate_Applied__c = 1;
                            }  
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
                    if(UserInfo.isMultiCurrencyOrganization()){
                       CommonUtilClass.populateCurrencyIsoCodeOnSobject(invoiceLine, currencyIsoCode);
                    }
                    invoiceLine.CurrencyL__c = charge.CurrencyL__c;
                    
                     if(charge.Price_Type__c == System.Label.OptionOneTime || 
                                charge.Price_Type__c == System.Label.OptionWeekly ||
                                charge.Price_Type__c == System.Label.OptionMonthly ||
                                charge.Price_Type__c == System.Label.OptionQuarterly ||
                                charge.Price_Type__c == System.Label.OptionHalfYearly ||
                                charge.Price_Type__c == System.Label.OptionAnnual)
                    {
                        //These store the no of days and months inbetween both the dates
                        Decimal noOfDays = 0;
                        //Decimal noOfMonths = 0;
                        //This determines how many times the actual charge price to be applied
                        Decimal noOfTimesCharge = 0;
                        
                        if(charge.Price_Type__c == System.Label.OptionOneTime) {
                            noOfTimesCharge = 1;
                        }else if(charge.Price_Type__c == System.Label.OptionWeekly) {
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
                        // Change the values of the invoice Line accordingly to Consortium Billing or else old values will retained 
                        // Execute the code only if the Billing Master order is present and master order is true
                        // And the pricing type is Volume, Flat Fee, Tiered  pricing

                        // This code is for quick release we need to make generic methods pass the charge 
                        // calculate values accordingly since we have written same code for usages also
                        
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
                                    invoiceLine.Unit_Price__c = tiers.get(0).Unit_Price__c;
                                    invoiceLine.Line_Amount__c = invoiceLine.Unit_Price__c * 1 * noOfTimesCharge;
                                    invoiceLine.Discount_Value__c = (charge.Discount_Percent__c * invoiceLine.Line_Amount__c) / 100;
                                    invoiceLine.VAT__c = (charge.VAT_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c)) / 100;
                                    if(invoice.Tax_Engine__c == System.Label.Standard || invoice.Tax_Engine__c == '' || invoice.Tax_Engine__c == null){
                                        invoiceLine.Tax__c = (charge.Tax_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c)) / 100;
                                    }else{
                                        invoiceLine.Tax__c = 0.0;
                                    }
                                    
                                } else {
                                    sMessage = system.Label.UsageQuantityDoesNotExist+' ' +charge.Name;
                                    return sMessage;
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
                                    sMessage = system.Label.UsageQuantityDoesNotExist+' ' +charge.Name;
                                    return sMessage;
                                }           
                            
                            }

                        }

                        // Code ends for Consortium Billing Here
                       if(charge.Price_Type__c != System.Label.OptionOneTime) { 
                            //Update the charge date to the target date as that is till what the charges have been calculated for
                            //Update the previous charge date with the charge date
                            charge.Previous_Charge_Date__c = charge.Charge_Date__c;
                            charge.Charge_Date__c = targetDate;
           
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
                    }
                    //Now bill usages if the passed parameter is true
                    else if( charge.Price_Type__c == System.label.OptionUsage && shouldBillUsages)
                    {
                         /*//Query the usage for this charge from the Usage Charges object
                        AggregateResult[] results = [   SELECT SUM(Quantity__c) Quantity
                                                        FROM Usage_Charge__c
                                                        WHERE End_Date__c < :targetDate
                                                        AND Status__c = :CommonUtilClass.STATUS_UNBILLED
                                                        AND Order_Rate_Plan_Charge__c = :charge.Id
                                                        GROUP BY Order_Rate_Plan_Charge__c];
                       
                        //As soon as these charges are billed change the status to Billed
                        Usage_Charge__c[] usageCharges = [  SELECT Id, Order_Rate_Plan_Charge__c
                                                            FROM Usage_Charge__c
                                                            WHERE End_Date__c < :targetDate
                                                            AND Status__c = :CommonUtilClass.STATUS_UNBILLED
                                                            AND Order_Rate_Plan_Charge__c = :charge.Id];
                       
                        listOfUsageChargesToUpdate.addAll(usageCharges);

                        //Calculate the usage charges based on this quantity
                        //Calculate the tax/vat percentage from the Tax_Percentage__c and VAT_Percentage__c fields
                        //Perform the calculation
                       
                        Decimal tempQuantity = 0;
                        if(!results.isEmpty()){
                            tempQuantity = (decimal)(results.get(0).get('Quantity'));
                        }*/
                       
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
                        chargetempQuantity = tempQuantity;

                        if(charge.Used_Quantity_for_Usage__c != null && charge.Is_Cumulative_Usage__c)
                           tempQuantity = tempQuantity + charge.Used_Quantity_for_Usage__c;

                        if(tempQuantity > 0){
                            //If the price model is volume pricing
                            if(charge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME){
                                //previously querying we were querying from product charge, now changed to order Rate Plan charge tiers
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
                                    sMessage = system.Label.UsageQuantityDoesNotExist+' ' +charge.Name;
                                    return sMessage;
                                }
                            }else if(charge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE){
                                //previously querying from product charge tiers due to that after creation of inv line, amount is not caluclating, now changed to order charge tiers
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
                                    sMessage = system.Label.UsageQuantityDoesNotExist+' ' +charge.Name;
                                    return sMessage;
                                }
                            }else if(charge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_TIERED) {
                                //previously querying from product charge tiers due to that after creation of inv line, amount is not caluclating, now changed to order charge tiers
                                list<Job_Rate_Plan_Charge_Tier__c> tempTiers = [SELECT Id, Start_Unit__c, Unit_Price__c, End_Unit__c
                                                                                FROM Job_Rate_Plan_Charge_Tier__c
                                                                                WHERE Job_Rate_Plan_Charge__c =: charge.Id
                                                                                order BY Start_Unit__c];
                               
                                if(tempTiers.size() == 0) {
                                    sMessage = system.Label.TiersNotDefined+' '+charge.Name;
                                    return sMessage;
                                }                                                                                                   
                               
                                decimal usageAmount = 0;
                                boolean isTierQtyExists = false;
                                decimal remaningUsage = tempQuantity;
                                decimal usageQuantity = tempQuantity;
                                boolean hasbilledOld = false;
                                decimal remaningCumulativeUsage = tempQuantity - chargetempQuantity;   

                                for(integer i = 0;i < tempTiers.Size();i++) {
                                    Job_Rate_Plan_Charge_Tier__c productChargeTier = tempTiers[i];
                                    if(usageQuantity >= productChargeTier.Start_Unit__c) {
                                        isTierQtyExists = true;
                                        decimal diff;

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
                                            usageAmount += (decimal) (remaningUsage * productChargeTier.Unit_Price__c);
                                        } else {
                                            //calculate the sp
                                            usageAmount += (decimal) (diff * productChargeTier.Unit_Price__c);
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
                                    sMessage = system.Label.UsageQuantityDoesNotExist+' '+charge.Name;
                                    return sMessage;
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
                            if(charge.Used_Quantity_for_Usage__c == null && charge.Is_Cumulative_Usage__c)
                                charge.Used_Quantity_for_Usage__c = chargetempQuantity;
                            else if(charge.Is_Cumulative_Usage__c)
                                charge.Used_Quantity_for_Usage__c = charge.Used_Quantity_for_Usage__c + chargetempQuantity;
                            charge.Charge_Date__c = targetDate;
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
                        //Here is the logic for minimum customer spend and maximum customer spend
                        //When the order is created if the customer has agreed to a minimum spend or maximum spend,
                        //then the invoice line value will be compared with that and adjusted
                       
                        if( charge.Min_Customer_Spend__c > 0
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
                        charge.Previous_Charge_Date__c = charge.Charge_Date__c;
                        charge.Charge_Date__c = targetDate;
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
                   
                    /*listOfInvoiceLines.add(invoiceLine);
                    invoiceClass.invoiceLines = listOfInvoiceLines;*/
                    //Add the invoiceline to be created only if the quantity is > 0. This will avoid duplicate lines being created for Usage Amended BY Naveen Mallela 
                    if( (invoiceline.Quantity__c > 0) || (charge.Bundle__c || charge.Package__c || charge.Required_By__c != null) ){
                        listOfInvoiceLines.add(invoiceLine);
                        invoiceClass.invoiceLines = listOfInvoiceLines;
                    }
                }
            }
            
            //If the simulateInvoiceGeneration parameter is true then don't insert the invoices/update the charges. Else do that
            if(!simulateInvoiceGeneration){ 
                //Insert the invoices, invoice lines and update the charges to reflect the date changes
                InvoicingUtilClass.insertInvoicesAndLines(map_Id_InvoiceClass, listOfUsageChargesToUpdate);
                //Added By Balachary InvoiceIT-685
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

                //INVOICEIT-630, Linking Invoice and Payment installment records Once invoice is generated. Added by DL
                //Start
                if(job.Payment_Plan__c != null){
                    map<Id, list<Payment_Plan_Installment__c>> mapOfOrorderIdToPaymentPlanInstallments = new map<Id, list<Payment_Plan_Installment__c>>();
                    list<Payment_Plan_Installment__c> listOfPaymentInstallmentsToUpdate = new list<Payment_Plan_Installment__c>();
                    list<Payment_Plan_Installment__c> listOfPaymentInstallments= new list<Payment_Plan_Installment__c>();
                    //If order has Amendments then map only related PPI to invoice, INVOICEIT-680
                    //Else map all the PPI to invoice
                    if(!setOfOrderIds.isEmpty() && !setOfMidtermAdjestments.isEmpty()){
                        for(Job__c orders : [select Id, Name, (select Id, Invoice__c, Order__c,Mid_Term_Adjustment__c From Payment_Plan_Installments__r where Mid_Term_Adjustment__c IN:setOfMidtermAdjestments) From Job__c Where Id IN:setOfOrderIds]){
                            mapOfOrorderIdToPaymentPlanInstallments.put(orders.Id, orders.Payment_Plan_Installments__r);
                        }
                    }
                    else if(!setOfOrderIds.isEmpty()){
                        for(Job__c orders : [select Id, Name, (select Id, Invoice__c, Order__c From Payment_Plan_Installments__r) From Job__c Where Id IN:setOfOrderIds]){
                            mapOfOrorderIdToPaymentPlanInstallments.put(orders.Id, orders.Payment_Plan_Installments__r);
                        }
                    }
                    
                    for(InvoiceClass ic : map_Id_InvoiceClass.values()){
                        invoiceObj = ic.invoice;
                        if(mapOfOrorderIdToPaymentPlanInstallments.containskey(invoiceObj.Order__c)){
                            listOfPaymentInstallments = mapOfOrorderIdToPaymentPlanInstallments.get(invoiceObj.Order__c);
                            for(Payment_Plan_Installment__c pInstallments: listOfPaymentInstallments){
                                pInstallments.Invoice__c = invoiceObj.Id;
                                listOfPaymentInstallmentsToUpdate.add(pInstallments);
                            }
                        }
                    }
                  
                    if(!listOfPaymentInstallmentsToUpdate.isEmpty()){
                        update listOfPaymentInstallmentsToUpdate;
                    }
                }
               // End 
                //Post the invoice
                if(autoPostInvoice){
                    for(InvoiceClass ic : map_Id_InvoiceClass.values()){
                        ic.invoice.Invoice_Status__c = CommonUtilClass.STATUS_POSTED;
                        invoicesToPost.add(ic.invoice);
                    }
                   
                    update invoicesToPost;
                }else{
                    /*
                        Modified By     : Rama krishna.v
                        Modified Date   : 15-11-2013
                        JIRA Task       : INVOICEIT-283
                        Comments        : Added below for loop, redirect to created invoice detail page
                    */
                    // add the invoice id to the list with status as draft.
                    for(InvoiceClass ic : map_Id_InvoiceClass.values()){
                        invoicesToPost.add(ic.invoice);          
                    }
                    
                }
                //Added by Dev M for Debit Invoice
                if(!invoicesToPost.isEmpty()){
                    list<Invoice__c> invoiceToUpdate = [SELECT Id, Total_Invoice_Value__c FROM Invoice__c WHERE Id =: invoicesToPost[0].Id];
                    if(!invoiceToUpdate.isEmpty() && invoiceToUpdate[0].Total_Invoice_Value__c < 0) {
                        Invoice__c invoiceDebit = new Invoice__c(Id = invoiceToUpdate[0].Id);
                        invoiceDebit.Debit_Invoice__c = true;
                        update invoiceDebit;
                    }
                }
                
                // update the legal entity custom settings[05/02/2014]
                if(!mapOfSequenceNumbersToUpdate.isEmpty()) {
                    update mapOfSequenceNumbersToUpdate.Values();
                }
            }else{
                 
                for(InvoiceClass ic : map_Id_InvoiceClass.values()){
                    invoiceObj = ic.invoice;
                    listOfInvoiceLinesForPreview = ic.invoiceLines;
                }
                  
            }
            
 
        }catch(DMLException exDml) {
            //Added by DL,NVOICEIT-665, 
            //previously Invoice is creating without INVlines if exception comes, Now we are rollbacking all changes if exception is there 
            Database.rollback(sp);
            
            sMessage += 'ERROR: ' + system.Label.ExceptionMessage + ':' + exDml.getTypeName() + ':'+ exDml.getMessage() + ':' + exDml.getLineNumber() + ':' + exDml.getStackTraceString() + '\n';
            sMessage+= ': ' + currentChargeDetails;
            return sMessage;
        }
        catch(Exception ex) {
            //Added by DL,NVOICEIT-665, 
            //previously Invoice is creating without INVlines if exception comes, Now we are rollbacking all changes if exception is there 
            Database.rollback(sp);
            
            sMessage += 'ERROR: ' + system.Label.ExceptionMessage + ex.getTypeName() + ':'+ex.getMessage() + ':' + ex.getLineNumber() + ':' + ex.getStackTraceString() + '\n';
            sMessage += ': ' + currentChargeDetails;
            return sMessage;
        }
       
        //If the invoice was created return the id
        if(invoicesToPost.size() > 0){
            sMessage = ''+invoicesToPost[0].Id;
        }
       
        return sMessage;
    }

    //This is a new implementation of this method to make it more customizable
    global String generateInvoiceForOrder(MethodParameters methodParameters) {
        Id orderId = methodParameters.orderId;
        Date invoiceDate = methodParameters.invoiceDate;
        Date targetDate = methodParameters.targetDate;
        Date cutoffDate = methodParameters.cutoffDate;
        boolean shouldBillUsages = methodParameters.shouldBillUsages;
        boolean simulateInvoiceGeneration = methodParameters.simulateInvoiceGeneration;
        boolean autoPostInvoice = methodParameters.autoPostInvoice;
        
         if(targetDate == null){
            targetDate = invoiceDate;
        }
        Savepoint sp;
        try {
            sp = Database.setSavepoint();
            Job__c job = [  SELECT Billing_Master_Order__c,Account__c,CurrencyL__c,Service_End_Date__c,Service_Activation_Date__c,Number_Of_Terms__c,Payment_Terms__c,CurrencyL__r.Name,Is_Billing_Master_Order__c
                            FROM Job__c
                            WHERE Id =: orderId];

            sOrderLegalEntity = Configuration__c.getValues('ORDER_LEGAL_ENTITY_FIELD_NAME').String_Value__c;
            sAccountLegalEntity = Configuration__c.getValues('ACCOUNT_LEGAL_ENTITY_FIELD_NAME').String_Value__c;
            shouldBillOneTimeChargesBasedOnServiceActivation = Configuration__c.getValues('BILL_ONETIME_CHARGES_BASED_ON_DATES').Boolean_Value__c;
            alignOrderDateToProducts = Configuration__c.getValues('ALIGN_DATES_OF_ORDER_TO_PRODUCTS').Boolean_Value__c;
           
            if(UserInfo.isMultiCurrencyOrganization()) {
                datedConversionRate = CommonUtilClass.getExchangeRateByDate(invoiceDate, job.CurrencyL__r.Name);
                currencyIsoCode = job.CurrencyL__r.Name;
            }
           
            map<String, Sequence_Number__c> mapOfSequenceNumbersToUpdate = Sequence_Number__c.getAll().deepClone();
            //Get all the data for the order
            map<Id, Sobject> map_Id_Sobject = InvoicingUtilClass.getSobjects(new set<Id>{orderId}, 'Job__c');
       
            map<string,Payment_Terms__c> mapPaymentTerms = Payment_Terms__c.getAll();
            map<Id,Job_Rate_Plan_Charge__c> mapOfChargesToUpdate = new map<Id,Job_Rate_Plan_Charge__c>();
            Integer noOfDaysToDueDate;
            Id currencyId;
            String chargeStatusForInvoicing = (Configuration__c.getValues('CHARGE_STATUS_FOR_INVOICING').String_Value__c);     
            
            //If the service activation date is null then throw a warning with that message
            if(job.Service_Activation_Date__c == null) {
                sMessage = 'ERROR:' + system.Label.ServiceDateRequired;
                return sMessage;
            }
            
            if(job.Is_Billing_Master_Order__c){
                sMessage = 'ERROR:' + 'Invoice cannot be generated for Billing Master Order';
                return sMessage;
            }
            
            if(job.Billing_Master_Order__c != null) {
               InvoicingUtilClass.updateOrderChargesBillingGroup(job, targetDate);
            }
            
            currencyId = job.CurrencyL__c;

            Job_Rate_Plan_Charge__c[] charges;
            //Filter the results based on the charge status if mentioned in the custom settings
            if(chargeStatusForInvoicing != null && chargeStatusForInvoicing.trim().length() > 0)
            {
               
                charges = [SELECT Id,Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c,Job_Rate_Plan__r.Job_Product__r.Job__c,
                                Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Invoice_Delivery_Type__c, Deferred_Revenue_Accounting_Code__c,
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
                                Bundle__c, Package__c, Required_By__c, Is_Cumulative_Usage__c, Used_Quantity_for_Usage__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Tax_Engine__c
                                FROM Job_Rate_Plan_Charge__c
                                WHERE Job_Rate_Plan__r.Job_Product__r.Job__c = : orderId
                                AND Status__c = :chargeStatusForInvoicing
                                AND Service_Activation_Date__c <= :targetDate
                                AND
                                (
                                    (Price_Type__c = :System.Label.OptionOneTime AND Charge_Date__c = null)
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
            } else {
                charges = [SELECT Id,Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c,Job_Rate_Plan__r.Job_Product__r.Job__c,
                                Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Invoice_Delivery_Type__c, Deferred_Revenue_Accounting_Code__c,
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
                                Bundle__c, Package__c, Required_By__c, Is_Cumulative_Usage__c, Used_Quantity_for_Usage__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Tax_Engine__c
                                FROM Job_Rate_Plan_Charge__c
                                WHERE Job_Rate_Plan__r.Job_Product__r.Job__c = : orderId
                                AND Service_Activation_Date__c <= :targetDate
                                AND
                                (
                                    (Price_Type__c = :System.Label.OptionOneTime AND Charge_Date__c = null)
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
           
            string defaultPaymentTerms = Configuration__c.getValues('DEFAULT_PAYMENT_TERMS').String_Value__c;
            //This list holds all the usage charges to be updated
            list<Usage_Charge__c> listOfUsageChargesToUpdate = new list<Usage_Charge__c>();
           
            //We need to create one invoice and multiple lines for each group of order/account
            map<Id, InvoiceClass> map_Id_InvoiceClass = new map<Id, InvoiceClass>();
           
            /*
                Modified By : Laxman Rao M, Jira No: INVOICEIT-316
               
                Below are the changes done for optimizing the query results.
                Previous Problem : Previously we are querying the usageCharges inside the for loop it was hiting the governor limits
                Below will create a three maps, one will store the listOfUnBilledCharges and second one will store the UnBilled quantity
                mapOfChargeId_UnBilledUsages --> key is orderRatePlanChargeId and value is list of unbilled usage charges
                mapOfChargeId_UnBilledQuantity --> key is orderRatePlanChargeId and value is the unBilled sum
                mapOfGroupId_Group --> key is groupId and value is group object record
               
                What I have changed -->
                A) we get the unbilled quantity from the map
                B) we get the unbilled usage charge object from the map(i.e list)
                C) we get the number of charges present in the group based on the groupId
            */
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
            //INVOICEIT_630, Collecting orderIds which If it has payment plan, Added by DL
            set<Id> setOfOrderIds = new set<Id>();

            for(Job_Rate_Plan_Charge__c charge : charges){
               
                if(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Plan__c != null){
                    setOfOrderIds.add(charge.Job_Rate_Plan__r.Job_Product__r.Job__c);
                } 
                
                currentChargeDetails = '\n Current Charge Id : ' + charge.Id + ' \n Order Id : ' + charge.Job_Rate_Plan__r.Job_Product__r.Job__c + ' \n Account Id : ' + charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c;
               
                //Calculate the charge dates
                Date calculationStartDate;
                Date calculationEndDate;
                boolean dateAdjusted = false;
               
                //If the price type is anything apart from usage then process them straight away
                //If the price type is usage process them only if shouldBillUsages is true
                //Also there appears to be a bug with the billing process where the service start date for the line is greater than service end date
                //especially when the charge date is null, the calculated value is negative
                //To tackle this we need filter out the charges where the charge date is null and the calculationstartdate > targetdate
                //To handle this we need to calculate the calculationstartdate and calculationenddate here
                if( charge.Price_Type__c == System.Label.OptionWeekly ||
                    charge.Price_Type__c == System.Label.OptionMonthly ||
                    charge.Price_Type__c == System.Label.OptionQuarterly ||
                    charge.Price_Type__c == System.Label.OptionHalfYearly ||
                    charge.Price_Type__c == System.Label.OptionAnnual){
                   
                    
                    if(charge.Next_Charge_Date__c != null){
                        calculationStartDate = charge.Next_Charge_Date__c;
                    }
                    else if(charge.Service_Activation_Date__c != null)
                    {
                        calculationStartDate = charge.Service_Activation_Date__c;
                    }
                    //If the ALIGN_DATES_OF_ORDER_TO_PRODUCTS parameter is false, then the charge dates are separate from order
                    //So only if the parameter is true take the service activation date from the order
                    else if(alignOrderDateToProducts && charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Service_Activation_Date__c != null)
                    {
                        calculationStartDate = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Service_Activation_Date__c;
                    }
                   
                    //The invoice gets generated every month on the preferred billing day
                    //So align the end date to be invoice date + 1 month for weekly and monthly
                    //This ensures the charge is billed from the service activation date to invoice date in arrears and then 1 period in advance
                    //The charges for quarterly and above are not aligned as they need to be based on the service activation date always
                   
                    if(calculationStartDate != null){
                        //If the cutoffDate is available, we need to generate invoices from the start date to that date
                        if(cutoffDate != null)
                        {
                            calculationEndDate = cutoffDate;
                        }
                        else
                        {
                            if(charge.Price_Type__c == System.Label.OptionWeekly){
                                calculationEndDate = targetDate.addMonths(1);
                            }
                            else if(charge.Price_Type__c == System.Label.OptionMonthly){
                                calculationEndDate = targetDate.addMonths(1);
                            }
                            else if(charge.Price_Type__c == System.Label.OptionQuarterly){
                                calculationEndDate = targetDate.addMonths(3);
                            }
                            else if(charge.Price_Type__c == System.Label.OptionHalfYearly){
                                calculationEndDate = targetDate.addMonths(6);
                            }
                            else if(charge.Price_Type__c == System.Label.OptionAnnual){
                                calculationEndDate = targetDate.addYears(1);
                            }  
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
                }
                else if(charge.Price_Type__c == System.Label.OptionOneTime || charge.Price_Type__c == System.Label.OptionUsage)
                {
                    
                    if(charge.Service_Activation_Date__c != null)
                    {
                        calculationStartDate = charge.Service_Activation_Date__c;
                    }
                    //If the ALIGN_DATES_OF_ORDER_TO_PRODUCTS parameter is false, then the charge dates are separate from order
                    //This would mean if the parameter is false the
                    else if(alignOrderDateToProducts && charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Service_Activation_Date__c != null)
                    {
                        calculationStartDate = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Service_Activation_Date__c;
                    }
                }
                         
                //To manage refunds during mid-term adjustements etc need to add another condition similar to
                //if the partrefund config parameter is true and the next charge date is null then the calculationstartdate < calculationenddate condition can be ignored
               
                boolean canRefundChargesDuringAdjustments = (Configuration__c.getValues('CAN_REFUND_CHARGES_DURING_ADJUSTMENTS').Boolean_Value__c);
               
                //If the config parameter BILL_ONETIME_CHARGES_BASED_ON_DATES is true then pick up those one time charges
                //that have their Service_Activation_Date__c on or before the target date
               
                if( calculationStartDate != null
                    &&
                    ((charge.Price_Type__c == System.label.OptionOneTime && shouldBillOneTimeChargesBasedOnServiceActivation && charge.Service_Activation_Date__c <= targetDate)
                    ||
                    (charge.Price_Type__c == System.label.OptionOneTime && !shouldBillOneTimeChargesBasedOnServiceActivation)
                    ||
                    (charge.Price_Type__c == System.label.OptionUsage && shouldBillUsages)
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
                    ) ) )
                {
                    
                    currentChargeDetails = '\n Current Charge Id : ' + charge.Id + ' \n Order Id : ' + charge.Job_Rate_Plan__r.Job_Product__r.Job__c + ' \n Account Id : ' + charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c;
                    InvoiceClass invoiceClass;
                    Invoice__c invoice;
                    list<Invoice_Lines__c> listOfInvoiceLines;
                   
                    if(map_Id_InvoiceClass.containsKey(job.Id)) {
                        invoiceClass = map_Id_InvoiceClass.get(job.Id);
                        invoice = InvoiceClass.invoice;
                        listOfInvoiceLines = invoiceClass.invoiceLines;
                     }else{
                        invoiceClass = new InvoiceClass();
                        map_Id_InvoiceClass.put(job.Id, invoiceClass);
                        invoice = new Invoice__c();
                        listOfInvoiceLines = new list<Invoice_Lines__c>();
                       
                        invoice.account__c = job.Account__c;
                        invoice.Invoice_Date__c = invoiceDate;
                       
                        /*
                            New code added for this ticket INVOICEIT-340
                        */
                       
                        if(sDefaultPaymentTerm != null && sDefaultPaymentTerm == CommonUtilClass.PAYMENT_TERM_ACCOUNT && charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Payment_Terms__c != null && mapPaymentTerms.containsKey(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Payment_Terms__c)) {
                            
                            noOfDaysToDueDate = (integer) mapPaymentTerms.get(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Payment_Terms__c).Number_Of_Days__c;
                            invoice.Due_Date__c = invoiceDate.addDays(noOfDaysToDueDate);
                        } else if(sDefaultPaymentTerm!=null && sDefaultPaymentTerm==CommonUtilClass.PAYMENT_TERM_ORDER && charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Terms__c != null && mapPaymentTerms.containsKey(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Terms__c)) {
                            
                            noOfDaysToDueDate = (integer) mapPaymentTerms.get(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Terms__c).Number_Of_Days__c;
                            invoice.Due_Date__c = invoiceDate.addDays(noOfDaysToDueDate);
                        } else {
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
                        invoice.Order__c = job.Id;
                        //mapping order Tax Engine to invoice Tax Engine
                        invoice.Tax_Engine__c = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Tax_Engine__c;
                       
                        /*//Populate the custom Invoice number based on the custom setttings - Legal Entity
                        String legalEntityName;
                        if(sOrderLegalEntity != null){
                            sObject jobSObject = map_Id_Sobject.get(charge.Job_Rate_Plan__r.Job_Product__r.Job__c);
                            legalEntityName = (string) jobSObject.get(sOrderLegalEntity);
                        }*/
                       
                        /*
                            Modified By : Laxman Rao M,
                            Reason : Invoice Reference number is not being populated when we use adHoc button
                            Ref : INVOICEIT-311, Date : [05/02/2014]
                        */
                        map<Id, Sobject> map_Id_Sobject_LE;
                        String INVOICING_GROUP_BY = (Configuration__c.getValues('INVOICE_GROUP_CRITERIA').String_Value__c);
                        set<Id> listOfIds = new set<Id>();
                        if(INVOICING_GROUP_BY == CommonUtilClass.INVOICING_GROUP_BY_ACCOUNT) {
                            listOfIds.add(job.Account__c);
                        } else {
                            listOfIds.add(job.Id);
                        }
               
                        if(sOrderLegalEntity != null || sAccountLegalEntity != null) {
                            if(INVOICING_GROUP_BY == CommonUtilClass.INVOICING_GROUP_BY_ACCOUNT) {
                                map_Id_Sobject_LE = InvoicingUtilClass.getSobjects(listOfIds, 'Account');
                            } else {
                                map_Id_Sobject_LE = InvoicingUtilClass.getSobjects(listOfIds, 'Job__c');
                            }
                        }
                       
                        //Populate the custom Invoice number based on the custom setttings
                        sobject sObjectBasedOnGroupBy = null;
                        string legalEntityName = null;
                        if(INVOICING_GROUP_BY == CommonUtilClass.INVOICING_GROUP_BY_ACCOUNT && sAccountLegalEntity != null) {
                            sObjectBasedOnGroupBy = map_Id_Sobject_LE.get(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c);
                            legalEntityName = (string) sObjectBasedOnGroupBy.get(sAccountLegalEntity);
                        } else if(sOrderLegalEntity != null) {
                            sObjectBasedOnGroupBy = map_Id_Sobject_LE.get(charge.Job_Rate_Plan__r.Job_Product__r.Job__c);
                            legalEntityName = (string) sObjectBasedOnGroupBy.get(sOrderLegalEntity);
                        }

                        if(sObjectBasedOnGroupBy != null && legalEntityName != null) {
                            string invoiceNumber = '';
                            if(mapOfSequenceNumbersToUpdate.containsKey(legalEntityName)) {
                                Sequence_Number__c sequenceNumber = mapOfSequenceNumbersToUpdate.get(legalEntityName);
                                // enter only if the next invoice next number is not null
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
                                    mapOfSequenceNumbersToUpdate.put(legalEntityName, sequenceNumber);
                                    //populate the custom invoice number
                                    invoice.Invoice_Reference__c = invoiceNumber;
                                }
                            }
                        }

                        //If the user has multi-currency activated then populate the exchange rates
                        if(UserInfo.isMultiCurrencyOrganization()) {
                            if(datedConversionRate != null) {
                                sobject sobjectInvoice = (sobject)invoice;
                                sobjectInvoice.put(sPrefix+'Exchange_Rate_Applied__c',(decimal) datedConversionRate.get('ConversionRate'));
                                sobjectInvoice.put('CurrencyIsoCode',(string) currencyIsoCode);
                                invoice = (Invoice__c) sobjectInvoice;
                            } else {
                                invoice.Exchange_Rate_Applied__c = 1;
                            }  
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
                            Modified By     : Ankit Sharma
                            Modified Date   : 28 Feb 2014
                            JIRA Task       : INVOICEIT-322
                            Comments        : Populating the standard field currency (CurrencyIsoCode) only for multi currency org.
                        */
                     if(UserInfo.isMultiCurrencyOrganization()){
                        CommonUtilClass.populateCurrencyIsoCodeOnSobject(invoiceLine, currencyIsoCode);
                     }
                   
                        /*
                            Modified By     : Ankit Sharma
                            Modified Date   : 27 Feb 2014
                            JIRA Task       : INVOICEIT-319
                            Comments        : Look up to currency for invoice line object
                        */
                    invoiceLine.CurrencyL__c = charge.CurrencyL__c;
                   
                   
                    //All the other fields for the invoiceline are different for onetime and recurring
                    /* if(charge.Price_Type__c == System.Label.OptionOneTime){
                        invoiceLine.Line_Amount__c = charge.Price__c;
                        invoiceLine.Discount_Value__c = charge.Discount_Value__c;
                        invoiceLine.Unit_Price__c = charge.Unit_Price__c;
                        invoiceLine.Line_Name__c = charge.Name;
                        invoiceLine.VAT__c = charge.VAT__c;
                        invoiceLine.Tax__c = charge.Tax__c;
                        invoiceLine.Service_Start_Date__c = targetDate;
                       
                        //Update the charge date to the target date as that is till what the charges have been calculated for
                        charge.Charge_Date__c = targetDate;
       
                    }else*/ if( charge.Price_Type__c == System.Label.OptionOneTime ||
                                charge.Price_Type__c == System.Label.OptionWeekly ||
                                charge.Price_Type__c == System.Label.OptionMonthly ||
                                charge.Price_Type__c == System.Label.OptionQuarterly ||
                                charge.Price_Type__c == System.Label.OptionHalfYearly ||
                                charge.Price_Type__c == System.Label.OptionAnnual)
                    {
                        //These store the no of days and months inbetween both the dates
                        Decimal noOfDays = 0;
                        //Decimal noOfMonths = 0;
                        //This determines how many times the actual charge price to be applied
                        Decimal noOfTimesCharge = 0;
       
                       
                        //noOfMonths = calculationStartDate.monthsBetween(calculationEndDate);
                        
                        if(charge.Price_Type__c == System.Label.OptionOneTime) {
                            noOfTimesCharge = 1;
                        }else if(charge.Price_Type__c == System.Label.OptionWeekly) {
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
                        // Change the values of the invoice Line accordingly to Consortium Billing or else old values will retained 
                        // Execute the code only if the Billing Master order is present and master order is true
                        // And the pricing type is Volume, Flat Fee, Tiered  pricing

                        // This code is for quick release we need to make generic methods pass the charge 
                        // calculate values accordingly since we have written same code for usages also

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
                                    invoiceLine.Unit_Price__c = tiers.get(0).Unit_Price__c;
                                    invoiceLine.Line_Amount__c = invoiceLine.Unit_Price__c * 1 * noOfTimesCharge;
                                    invoiceLine.Discount_Value__c = (charge.Discount_Percent__c * invoiceLine.Line_Amount__c) / 100;
                                    invoiceLine.VAT__c = (charge.VAT_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c)) / 100;
                                    if(invoice.Tax_Engine__c == System.Label.Standard || invoice.Tax_Engine__c == '' || invoice.Tax_Engine__c == null){
                                        invoiceLine.Tax__c = (charge.Tax_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c)) / 100;
                                    }else{
                                        invoiceLine.Tax__c = 0.0;
                                    }
                                    
                                } else {
                                    sMessage = system.Label.UsageQuantityDoesNotExist+' ' +charge.Name;
                                    return sMessage;
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
                                    sMessage = system.Label.UsageQuantityDoesNotExist+' ' +charge.Name;
                                    return sMessage;
                                }           
                            
                            }

                        }

                        // Code ends for Consortium Billing Here
                         
                        if(charge.Price_Type__c != System.Label.OptionOneTime) {  
                            //Update the charge date to the target date as that is till what the charges have been calculated for
                            //Update the previous charge date with the charge date
                            charge.Previous_Charge_Date__c = charge.Charge_Date__c;
                            charge.Charge_Date__c = targetDate;
           
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
                    }
                    //Now bill usages if the passed parameter is true
                    else if( charge.Price_Type__c == System.label.OptionUsage && shouldBillUsages)
                    {
                        /*//Query the usage for this charge from the Usage Charges object
                        AggregateResult[] results = [   SELECT SUM(Quantity__c) Quantity
                                                        FROM Usage_Charge__c
                                                        WHERE End_Date__c < :targetDate
                                                        AND Status__c = :CommonUtilClass.STATUS_UNBILLED
                                                        AND Order_Rate_Plan_Charge__c = :charge.Id
                                                        GROUP BY Order_Rate_Plan_Charge__c];
                       
                        //As soon as these charges are billed change the status to Billed
                        Usage_Charge__c[] usageCharges = [  SELECT Id, Order_Rate_Plan_Charge__c
                                                            FROM Usage_Charge__c
                                                            WHERE End_Date__c < :targetDate
                                                            AND Status__c = :CommonUtilClass.STATUS_UNBILLED
                                                            AND Order_Rate_Plan_Charge__c = :charge.Id];
                       
                        listOfUsageChargesToUpdate.addAll(usageCharges);

                        //Calculate the usage charges based on this quantity
                        //Calculate the tax/vat percentage from the Tax_Percentage__c and VAT_Percentage__c fields
                        //Perform the calculation
                       
                        Decimal tempQuantity = 0;
                        if(!results.isEmpty()){
                            tempQuantity = (decimal)(results.get(0).get('Quantity'));
                        }*/
                       
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

                        chargetempQuantity = tempQuantity;

                        if(charge.Used_Quantity_for_Usage__c != null && charge.Is_Cumulative_Usage__c)
                             tempQuantity = tempQuantity + charge.Used_Quantity_for_Usage__c;


                        if(tempQuantity > 0){
                            //If the price model is volume pricing
                            if(charge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME){
                                //previously querying we were querying from product charge, now changed to order Rate Plan charge tiers
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
                                    sMessage = system.Label.UsageQuantityDoesNotExist+' '+charge.Name;
                                    return sMessage;
                                }
                            }else if(charge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE){
                                //previously querying from product charge tiers due to that after creation of inv line, amount is not caluclating, now changed to order charge tiers
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
                                    sMessage = system.Label.UsageQuantityDoesNotExist+ ' ' +charge.Name;
                                    return sMessage;
                                }
                            }else if(charge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_TIERED) {
                                //previously querying from product charge tiers due to that after creation of inv line, amount is not caluclating, now changed to order charge tiers
                                list<Job_Rate_Plan_Charge_Tier__c> tempTiers = [SELECT Id, Start_Unit__c, Unit_Price__c, End_Unit__c
                                                                                FROM Job_Rate_Plan_Charge_Tier__c
                                                                                WHERE Job_Rate_Plan_Charge__c =: charge.Id
                                                                                order BY Start_Unit__c];
                               
                                if(tempTiers.size() == 0) {
                                    sMessage = system.Label.TiersNotDefined+' '+charge.Name;
                                    return sMessage;
                                }                                                                                                   
                               
                                decimal usageAmount = 0;
                                boolean isTierQtyExists = false;
                                decimal remaningUsage = tempQuantity;
                                decimal usageQuantity = tempQuantity;
                                boolean hasbilledOld = false;
                                decimal remaningCumulativeUsage = tempQuantity - chargetempQuantity;

                                for(integer i = 0;i < tempTiers.Size();i++) {
                                    Job_Rate_Plan_Charge_Tier__c productChargeTier = tempTiers[i];
                                    if(usageQuantity >= productChargeTier.Start_Unit__c) {
                                        isTierQtyExists = true;
                                        decimal diff;

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
                                            usageAmount += (decimal) (remaningUsage * productChargeTier.Unit_Price__c);
                                        } else {
                                            //calculate the sp
                                            usageAmount += (decimal) (diff * productChargeTier.Unit_Price__c);
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
                                    sMessage = system.Label.UsageQuantityDoesNotExist+' '+charge.Name;
                                    return sMessage;
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
                            if(charge.Used_Quantity_for_Usage__c == null && charge.Is_Cumulative_Usage__c)
                                charge.Used_Quantity_for_Usage__c = chargetempQuantity;
                            else if(charge.Is_Cumulative_Usage__c)
                                charge.Used_Quantity_for_Usage__c = charge.Used_Quantity_for_Usage__c + chargetempQuantity;
                            charge.Charge_Date__c = targetDate;
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
                        //Here is the logic for minimum customer spend and maximum customer spend
                        //When the order is created if the customer has agreed to a minimum spend or maximum spend,
                        //then the invoice line value will be compared with that and adjusted
                       
                        if( charge.Min_Customer_Spend__c > 0
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
                        if(charge.Used_Quantity_for_Usage__c == null)
                            charge.Used_Quantity_for_Usage__c = chargetempQuantity;
                        else
                            charge.Used_Quantity_for_Usage__c = charge.Used_Quantity_for_Usage__c + chargetempQuantity;
                        charge.Previous_Charge_Date__c = charge.Charge_Date__c;
                        charge.Charge_Date__c = targetDate;
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
                   
                    /*listOfInvoiceLines.add(invoiceLine);
                    invoiceClass.invoiceLines = listOfInvoiceLines;*/
                    //Add the invoiceline to be created only if the quantity is > 0. This will avoid duplicate lines being created for Usage Amended BY Naveen Mallela 
                    if((invoiceline.Quantity__c > 0) || (charge.Bundle__c || charge.Package__c || charge.Required_By__c != null) ) {
                        listOfInvoiceLines.add(invoiceLine);
                        invoiceClass.invoiceLines = listOfInvoiceLines;
                    }
                }
            }
           
            //If the simulateInvoiceGeneration parameter is true then don't insert the invoices/update the charges. Else do that
            if(!simulateInvoiceGeneration){
                //Insert the invoices, invoice lines and update the charges to reflect the date changes
                InvoicingUtilClass.insertInvoicesAndLines(map_Id_InvoiceClass, listOfUsageChargesToUpdate);
                //Added By Balachary InvoiceIT-685
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

                //INVOICEIT-630, Linking Invoice and Payment installment records Once inoice is generated. Added by DL
                //Start
                if(job.Payment_Plan__c != null){
                    map<Id, list<Payment_Plan_Installment__c>> mapOfororderIdToPaymentPlanInstllment = new map<Id, list<Payment_Plan_Installment__c>>();
                    list<Payment_Plan_Installment__c> lstOfPaymentInstallmentsToUpdate = new list<Payment_Plan_Installment__c>();
                    list<Payment_Plan_Installment__c> lstOfPaymentInstallments= new list<Payment_Plan_Installment__c>();
                    //map<Id, Integer> mapOfInvoiceIdToNoOfInstalment = new map<Id, Integer>();

                    if(!setOfOrderIds.isEmpty()){
                        for(Job__c orders : [select Id, Name, (select Id, Invoice__c, Order__c From Payment_Plan_Installments__r) From Job__c Where Id IN:setOfOrderIds]){
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
               
                //Post the invoice
                if(autoPostInvoice){
                    for(InvoiceClass ic : map_Id_InvoiceClass.values()){
                        ic.invoice.Invoice_Status__c = CommonUtilClass.STATUS_POSTED;
                        invoicesToPost.add(ic.invoice);
                    }
                   
                    update invoicesToPost;
                }else{
                    /*
                        Modified By     : Rama krishna.v
                        Modified Date   : 15-11-2013
                        JIRA Task       : INVOICEIT-283
                        Comments        : Added below for loop, redirect to created invoice detail page
                    */
                    // add the invoice id to the list with status as draft.
                    for(InvoiceClass ic : map_Id_InvoiceClass.values()){
                        invoicesToPost.add(ic.invoice);
                    }

                    
                }
                
                //Added by Dev M for Debit Invoice
                if(!invoicesToPost.isEmpty()){
                    list<Invoice__c> invoiceToUpdate = [SELECT Id, Total_Invoice_Value__c FROM Invoice__c WHERE Id =: invoicesToPost[0].Id];
                    if(!invoiceToUpdate.isEmpty() && invoiceToUpdate[0].Total_Invoice_Value__c < 0) {
                        Invoice__c invoiceDebit = new Invoice__c(Id = invoiceToUpdate[0].Id);
                        invoiceDebit.Debit_Invoice__c = true;
                        update invoiceDebit;
                    }
                }
        
               
                // update the legal entity custom settings[05/02/2014]
                if(!mapOfSequenceNumbersToUpdate.isEmpty()) {
                    update mapOfSequenceNumbersToUpdate.Values();
                }
            }
           
        }catch(DMLException exDml) {
            //Added by DL,NVOICEIT-665, 
            //previously Invoice is creating without INVlines if exception comes, Now we are rollbacking all changes if exception is there 
            Database.rollback(sp); 
            
            sMessage += 'ERROR: ' + system.Label.ExceptionMessage + ':' + exDml.getTypeName() + ':'+ exDml.getMessage() + ':' + exDml.getLineNumber() + ':' + exDml.getStackTraceString() + '\n';
            sMessage+= ': ' + currentChargeDetails;
            return sMessage;
        }
        catch(Exception ex) {
            //Added by DL,NVOICEIT-665, 
            //previously Invoice is creating without INVlines if exception comes, Now we are rollbacking all changes if exception is there 
            Database.rollback(sp);
            
            sMessage += 'ERROR: ' + system.Label.ExceptionMessage + ex.getTypeName() + ':'+ex.getMessage() + ':' + ex.getLineNumber() + ':' + ex.getStackTraceString() + '\n';
            sMessage += ': ' + currentChargeDetails;
            return sMessage;
        }
       
        //If the invoice was created return the id
        if(invoicesToPost.size() > 0){
            sMessage = ''+invoicesToPost[0].Id;
        }
       
        return sMessage;
    }

    global class MethodParameters{
        global Id orderId;
        global Date invoiceDate;
        global Date targetDate;
        global Date cutoffDate;
        global boolean shouldBillUsages;
        global boolean simulateInvoiceGeneration;
        global boolean autoPostInvoice;

    }
}