global with sharing class BatchInvoiceGeneration1 implements Database.Batchable<sObject>, Database.Stateful {

    global final String query; 
    global Invoice_Run__c invoiceRun;
    global Integer noOfAccountsProcessed = 0;
    global Integer noOfJobsProcessed = 0; 
    global Integer noOfInvoicesGenerated = 0;
    global Integer noOfCreditNotesGenerated = 0;
    global Double totalInvoiceValue;
    global Integer noOfDaysToDueDate = 0;
    global final String INVOICING_GROUP_BY;
    global Date invoiceDate;
    global Date targetDate;
    global Id currencyId;
    global String schedulerName;
    global Id schedulerId;
    global String errorLog;
    global String currentChargeDetails;
    global map<string, Payment_Terms__c> mapPaymentTerms;
    global boolean automaticallyPostInvoices = false;
    global boolean shouldBillUsages = true;
    global map<String, Sequence_Number__c> mapOfSequenceNumbersToUpdate;
    global sobject datedConversionRate;
    boolean shouldBillOneTimeChargesBasedOnServiceActivation;
    string sOrderLegalEntity;
    string sAccountLegalEntity;
    string currencyIsoCode;
    string sDefaultPaymentTerm;
    string sInvoiceBatch;
    set<Id> orderIds = new set<Id>();
    list<Invoice_Lines__c> invoiceLinesToInsert = new list<Invoice_Lines__c>();
    map<Id, Job_Rate_Plan_Charge__c> map_Id_OrderCharge = new map<Id, Job_Rate_Plan_Charge__c>();
    /*
     Modified By     :   Rama krishna.v
     Modified Date   :   06-12-2013
     JIRA Task       :   INVOICEIT-272
     Comments        :   created new set, to count the no of accounts processed
    */
    global set<Id> setOfAllAccountIdsProcessed = new set<Id>();

    global BatchInvoiceGeneration1(String query, String groupby, Date invoiceDate, Date targetDate, Id currencyId, String schedulerName, Id schedulerId) {
        totalInvoiceValue = 0;
        this.query = query;
        this.invoiceDate = invoiceDate;
        this.targetDate = targetDate;
        this.currencyId = currencyId;
        // Making Blank, as we are using invoice presentation INVOICING_GROUP_BY is not used Added by Dev M
        this.INVOICING_GROUP_BY = '';
        this.schedulerName = schedulerName;
        this.schedulerId = schedulerId;
        this.errorLog = null;
        this.currentChargeDetails = '';
        mapPaymentTerms = Payment_Terms__c.getAll();
        mapOfSequenceNumbersToUpdate = Sequence_Number__c.getAll().deepClone();
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        //Get the config parameter that determines the no of days due date of invoice is from the invoice date
        //noOfDaysToDueDate = (Configuration__c.getValues('INVOICE_NO_OF_DAYS_TILL_DUE_DATE').Number_Value__c).intValue();
        /*Amended on 28 Jun 2012 by Laxman(Jira -- INVOICEIT-56)*/
        Invoice_RunScheduler__c runScheduler = [SELECT Automatically_Post_Invoices__c, Bill_Usage_Charges__c,Invoice_Currency__r.Name, Invoice_Batch__c
                                                FROM Invoice_RunScheduler__c
                                                WHERE Id = : schedulerId];
        automaticallyPostInvoices = runScheduler.Automatically_Post_Invoices__c;
        shouldBillUsages = runScheduler.Bill_Usage_Charges__c;
        //Added by dhanalakshmi for INVOICEIT-615 
        sInvoiceBatch = runScheduler.Invoice_Batch__c;
        invoiceRun = new Invoice_Run__c();
        invoiceRun.Name = schedulerName;
        invoiceRun.Invoice_Run_Scheduler__c = schedulerId;
        invoiceRun.Status__c = CommonUtilClass.STATUS_STARTED;
        invoiceRun.Accounts_Processed__c = noOfAccountsProcessed;
        invoiceRun.Jobs_Processed__c = noOfJobsProcessed;
        invoiceRun.Invoices_Generated__c = noOfInvoicesGenerated;
        invoiceRun.CreditNotes_Generated__c = noOfCreditNotesGenerated;
        invoiceRun.Start_Time__c = Datetime.now();
        invoiceRun.Target_Run_Date__c = targetDate;
        invoiceRun.Invoice_Date__c = invoiceDate;
        invoiceRun.Total_Invoice_Value__c = 0;
        insert invoiceRun;

        sOrderLegalEntity = Configuration__c.getValues('ORDER_LEGAL_ENTITY_FIELD_NAME').String_Value__c;
        sAccountLegalEntity = Configuration__c.getValues('ACCOUNT_LEGAL_ENTITY_FIELD_NAME').String_Value__c;
        shouldBillOneTimeChargesBasedOnServiceActivation = Configuration__c.getValues('BILL_ONETIME_CHARGES_BASED_ON_DATES').Boolean_Value__c;
        sDefaultPaymentTerm = Configuration__c.getValues('DEFAULT_PAYMENT_TERMS_TO_BE_USED_FROM').String_Value__c;

        if (UserInfo.isMultiCurrencyOrganization()) {
            datedConversionRate = CommonUtilClass.getExchangeRateByDate(invoiceDate, runScheduler.Invoice_Currency__r.Name);
            currencyIsoCode = runScheduler.Invoice_Currency__r.Name;
        }

        //Ref : INVOICEIT-556, Modified by : Manoj Ganapathy
        // Added for consortium billing 
        // need to modified this query to handle the cancelled charges which are expired  
        // limiting based on currency: Added by Dev M 
        AggregateResult[] results = [SELECT Sum(Quantity__c) Quantity, Billing_Master_Order_Rate_Plan_Charge__c MasterChargeId
                                        FROM Job_Rate_Plan_Charge__c
                                        WHERE Service_Activation_Date__c <= :targetDate
                                        AND (Service_End_Date__c > :targetDate OR Service_End_Date__c = NULL)
                                        AND Billing_Master_Order_Rate_Plan_Charge__c != NULL
                                        AND Job_Rate_Plan__r.Job_Product__r.Job__r.CurrencyL__c = :currencyId
                                        GROUP BY Billing_Master_Order_Rate_Plan_Charge__c];

        list<Job_Rate_Plan_Charge__c> listOfOrderChargesBillingGroup = new list<Job_Rate_Plan_Charge__c>();

        for(AggregateResult result : results)
        {
            Job_Rate_Plan_Charge__c charge = new Job_Rate_Plan_Charge__c(Id = (Id)result.get('MasterChargeId'));
            charge.Billing_Master_Grouped_Quantity__c = ((Decimal)result.get('Quantity'));

            listOfOrderChargesBillingGroup.add(charge);
        }

        if(listOfOrderChargesBillingGroup.size() > 0)
        {
            update listOfOrderChargesBillingGroup;  
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<sObject> scope) {

        set<Id> listOfIds = new set<Id>();
        //To count the no of accounts/jobs processed
        set<Id> setOfAccountIds = new set<Id>();
        set<Id> setOfJobIds = new set<Id>();
        SavePoint sp;

        try {
            //Ref : INVOICEIT-252, Modified by : Laxman Rao M
            // Previously we were giving the option for the customer to decide what is the size of batch
            // but now we are processing only one Order at a time, if their is any exception we will rollback the all the dml operations like roll back Invoice Lines, Invoice, Order charges, Usage Charges etc
            sp = DataBase.setSavepoint();
            invoiceLinesToInsert = new list<Invoice_Lines__c>();
            map_Id_OrderCharge = new map<Id, Job_Rate_Plan_Charge__c>();
            map<Id,Job_Rate_Plan_Charge__c> mapOfChargesToUpdate = new map<Id,Job_Rate_Plan_Charge__c>();
            //If the invoicing group by is account or order all we need is just the id from the scope
            for (sObject s : scope) {
                if (this.INVOICING_GROUP_BY == CommonUtilClass.INVOICING_GROUP_BY_ACCOUNT) {
                    Job__c j = (Job__c)s;
                    if (!listOfIds.contains(j.Account__c)) {
                        listOfIds.add(j.Account__c);
                    }
                } else {
                    Job__c j = (Job__c)s;
                    if (!listOfIds.contains(j.Id)) {
                        listOfIds.add(j.Id);
                    }
                }
            }

            map<Id, Sobject> map_Id_Sobject;
            if (sOrderLegalEntity != null || sAccountLegalEntity != null) {
                if (this.INVOICING_GROUP_BY == CommonUtilClass.INVOICING_GROUP_BY_ACCOUNT) {
                    map_Id_Sobject = InvoicingUtilClass.getSobjects(listOfIds, 'Account');
                } else {
                    map_Id_Sobject = InvoicingUtilClass.getSobjects(listOfIds, 'Job__c');
                }
            }

            // initialize the custom settings again, since we are updating in end of this method
            mapOfSequenceNumbersToUpdate = Sequence_Number__c.getAll().deepClone();

            String targetDayString = String.valueOf(targetDate.day());
            list<string> targetDayStrings = CommonUtilClass.isLastDayOfMonth(targetDate);
            String chargeStatusForInvoicing = (Configuration__c.getValues('CHARGE_STATUS_FOR_INVOICING').String_Value__c);

            Job_Rate_Plan_Charge__c[] charges;
            //INVOICEIT-630, Modified filter conditions, If we are processing payment plan order we are not checking 'Service_Activation_Date__c <= :targetDate' condition
            if (INVOICING_GROUP_BY == CommonUtilClass.INVOICING_GROUP_BY_ACCOUNT) {
                //Filter the results based on the charge status if mentioned in the custom settings
                if (chargeStatusForInvoicing != null && chargeStatusForInvoicing.trim().length() > 0) {
                    charges = [SELECT Id, Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c, Job_Rate_Plan__r.Job_Product__r.Job__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Invoice_Delivery_Type__c, Deferred_Revenue_Accounting_Code__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Contact__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Shipping_Contact__c,
                               Job_Rate_Plan__r.Job_Product__r.Product__c, Job_Rate_Plan__r.Job_Product__r.Name, Product_Rate_Plan_Charge__c,
                               Accounting_Code__c, Name, Quantity__c, Unit_Of_Measurement__c, Charge_Date__c, Previous_Charge_Date__c, Next_Charge_Date__c,
                               Discount_Value__c, Service_Activation_Date__c, Service_End_Date__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Service_End_Date__c,
                               Price_Type__c, Price__c, Unit_Price__c, VAT__c, Tax__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c, Grouping__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Payment_Terms__c, Price_Format__c, Discount_Percent__c, VAT_Percentage__c, Tax_Percentage__c,
                               Committed_Quantity__c, Min_Customer_Spend__c, Max_Customer_Spend__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Terms__c, CurrencyL__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Master_Order__c, Invoice_Grouping__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Account__c,
                               Billing_Master_Order_Rate_Plan_Charge__r.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Order__c,
                               Billing_Master_Order_Rate_Plan_Charge__r.Job_Rate_Plan__r.Job_Product__r.Job__r.Is_Billing_Master_Order__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Order__c,
                               Billing_Master_Order_Rate_Plan_Charge__r.Billing_Master_Grouped_Quantity__c,Billing_Master_Order_Rate_Plan_Charge__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Partner__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Account__c,
                               Revenue_Recognition_Rule__c, Revenue_Recognition_Start_Date__c, Revenue_Recognition_End_Date__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Account__r.Payment_Terms__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Account__r.Payment_Terms__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Partner__r.Payment_Terms__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Account__r.Invoice_Delivery_Type__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Account__r.Invoice_Delivery_Type__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Partner__r.Invoice_Delivery_Type__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Plan__c,
                               Bundle__c, Package__c, Required_By__c,Mid_Term_Adjustment__c,Order__r.Payment_Plan__c, Is_Cumulative_Usage__c, Used_Quantity_for_Usage__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Tax_Engine__c 
                               FROM Job_Rate_Plan_Charge__c
                               WHERE Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c IN : listOfIds
                               AND Job_Rate_Plan__r.Job_Product__r.Job__r.CurrencyL__c = :currencyId
                               AND Status__c = :chargeStatusForInvoicing     
                                         AND(
                                             ((Price_Type__c = :System.Label.OptionOneTime AND Charge_Date__c = null AND Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Plan__c = null AND Service_Activation_Date__c <= :targetDate)
                                              OR(Price_Type__c = :System.Label.OptionOneTime AND Charge_Date__c = null AND Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Plan__c != null))
                                             OR
                                             (   (   Price_Type__c = :System.Label.OptionWeekly
                                                     OR Price_Type__c = :System.Label.OptionMonthly
                                                             OR Price_Type__c = :System.Label.OptionQuarterly
                                                                     OR Price_Type__c = :System.Label.OptionHalfYearly
                                                                             OR Price_Type__c = :System.Label.OptionAnnual
                                                                                     OR Price_Type__c = :System.Label.OptionUsage
                                                 )
                                                  AND Service_Activation_Date__c <= :targetDate
                                                  AND (Charge_Date__c = null OR Next_Charge_Date__c <= :targetDate)
                                             )
                                         )
                                         AND(
                                             (   Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c = null
                                                     AND
                                                     Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c = null
                                             )
                                             OR
                                             (   Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c = null
                                                     AND
                                                     //Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c = :targetDayString
                                                     Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c IN :targetDayStrings
                                             )
                                             OR
                                             (   //Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c = :targetDayString
                                                     Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c IN :targetDayStrings
                                             )
                                         )
                                         AND Job_Rate_Plan__r.Job_Product__r.Job__r.Invoice_Batch__c =: sInvoiceBatch
                                         ORDER BY Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c, Job_Rate_Plan__r.Job_Product__r.Job__c,
                                        Job_Rate_Plan__r.Job_Product__c, CreatedDate, Sequence_No__c];
                } else {
                    charges = [SELECT Id, Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c, Job_Rate_Plan__r.Job_Product__r.Job__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Invoice_Delivery_Type__c, Deferred_Revenue_Accounting_Code__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Contact__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Shipping_Contact__c,
                               Job_Rate_Plan__r.Job_Product__r.Product__c, Job_Rate_Plan__r.Job_Product__r.Name, Product_Rate_Plan_Charge__c,
                               Accounting_Code__c, Name, Quantity__c, Unit_Of_Measurement__c, Charge_Date__c, Previous_Charge_Date__c, Next_Charge_Date__c,
                               Discount_Value__c, Service_Activation_Date__c, Service_End_Date__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Service_End_Date__c,
                               Price_Type__c, Price__c, Unit_Price__c, VAT__c, Tax__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c, Grouping__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Payment_Terms__c, Price_Format__c, Discount_Percent__c, VAT_Percentage__c, Tax_Percentage__c,
                               Committed_Quantity__c, Min_Customer_Spend__c, Max_Customer_Spend__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Terms__c, CurrencyL__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Master_Order__c, Invoice_Grouping__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Account__c,
                               Billing_Master_Order_Rate_Plan_Charge__r.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Order__c,
                               Billing_Master_Order_Rate_Plan_Charge__r.Job_Rate_Plan__r.Job_Product__r.Job__r.Is_Billing_Master_Order__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Order__c,
                               Billing_Master_Order_Rate_Plan_Charge__r.Billing_Master_Grouped_Quantity__c,Billing_Master_Order_Rate_Plan_Charge__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Partner__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Account__c,
                               Revenue_Recognition_Rule__c, Revenue_Recognition_Start_Date__c, Revenue_Recognition_End_Date__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Account__r.Payment_Terms__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Account__r.Payment_Terms__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Partner__r.Payment_Terms__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Account__r.Invoice_Delivery_Type__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Account__r.Invoice_Delivery_Type__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Partner__r.Invoice_Delivery_Type__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Plan__c,
                               Bundle__c, Package__c, Required_By__c,Mid_Term_Adjustment__c,Order__r.Payment_Plan__c , Is_Cumulative_Usage__c, Used_Quantity_for_Usage__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Tax_Engine__c
                               FROM Job_Rate_Plan_Charge__c
                               WHERE Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c IN : listOfIds
                               AND Job_Rate_Plan__r.Job_Product__r.Job__r.CurrencyL__c = :currencyId
                               AND(
                                   ((Price_Type__c = :System.Label.OptionOneTime AND Charge_Date__c = null AND Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Plan__c = null AND Service_Activation_Date__c <= :targetDate)
                                      OR(Price_Type__c = :System.Label.OptionOneTime AND Charge_Date__c = null AND Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Plan__c != null))
                                   OR
                                   (   (   Price_Type__c = :System.Label.OptionWeekly
                                           OR Price_Type__c = :System.Label.OptionMonthly
                                                   OR Price_Type__c = :System.Label.OptionQuarterly
                                                           OR Price_Type__c = :System.Label.OptionHalfYearly
                                                                   OR Price_Type__c = :System.Label.OptionAnnual
                                                                           OR Price_Type__c = :System.Label.OptionUsage
                                       )
                                       AND Service_Activation_Date__c <= :targetDate
                                       AND (Charge_Date__c = null OR Next_Charge_Date__c <= :targetDate)
                                   )
                               )
                               AND(
                                   (   Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c = null
                                           AND Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c = null
                                   )
                                   OR
                                   (   Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c = null
                                           //AND Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c = :targetDayString)
                                           AND Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c IN :targetDayStrings)
                                   OR
                                   (       //Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c = :targetDayString
                                       Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c IN :targetDayStrings
                                   )
                               )
                               AND Job_Rate_Plan__r.Job_Product__r.Job__r.Invoice_Batch__c =: sInvoiceBatch
                               ORDER BY Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c, Job_Rate_Plan__r.Job_Product__r.Job__c,
                              Job_Rate_Plan__r.Job_Product__c, CreatedDate, Sequence_No__c];
                }

            } else {
                //Filter the results based on the charge status if mentioned in the custom settings
                if (chargeStatusForInvoicing != null && chargeStatusForInvoicing.trim().length() > 0) {
                    charges = [SELECT Id, Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c, Job_Rate_Plan__r.Job_Product__r.Job__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Invoice_Delivery_Type__c, Deferred_Revenue_Accounting_Code__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Contact__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Shipping_Contact__c,
                               Job_Rate_Plan__r.Job_Product__r.Product__c, Job_Rate_Plan__r.Job_Product__r.Name, Product_Rate_Plan_Charge__c,
                               Accounting_Code__c, Name, Quantity__c, Unit_Of_Measurement__c, Charge_Date__c, Previous_Charge_Date__c, Next_Charge_Date__c,
                               Discount_Value__c, Service_Activation_Date__c, Service_End_Date__c, Grouping__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Service_End_Date__c, Price_Type__c, Price__c, Unit_Price__c, VAT__c, Tax__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Payment_Terms__c, Price_Format__c, Discount_Percent__c, VAT_Percentage__c, Tax_Percentage__c,
                               Committed_Quantity__c, Min_Customer_Spend__c, Max_Customer_Spend__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Terms__c, CurrencyL__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Master_Order__c, Invoice_Grouping__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Account__c,
                               Billing_Master_Order_Rate_Plan_Charge__r.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Order__c,
                               Billing_Master_Order_Rate_Plan_Charge__r.Job_Rate_Plan__r.Job_Product__r.Job__r.Is_Billing_Master_Order__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Order__c,
                               Billing_Master_Order_Rate_Plan_Charge__r.Billing_Master_Grouped_Quantity__c,Billing_Master_Order_Rate_Plan_Charge__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Partner__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Account__c,
                               Revenue_Recognition_Rule__c, Revenue_Recognition_Start_Date__c, Revenue_Recognition_End_Date__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Account__r.Payment_Terms__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Account__r.Payment_Terms__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Partner__r.Payment_Terms__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Account__r.Invoice_Delivery_Type__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Account__r.Invoice_Delivery_Type__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Partner__r.Invoice_Delivery_Type__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Plan__c,
                               Bundle__c, Package__c, Required_By__c,Mid_Term_Adjustment__c,Order__r.Payment_Plan__c, Is_Cumulative_Usage__c, Used_Quantity_for_Usage__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Tax_Engine__c
                               FROM Job_Rate_Plan_Charge__c
                               WHERE Job_Rate_Plan__r.Job_Product__r.Job__c IN : listOfIds
                               AND Job_Rate_Plan__r.Job_Product__r.Job__r.CurrencyL__c = :currencyId
                               AND Status__c = :chargeStatusForInvoicing               
                                   AND
                                   (
                                       ((Price_Type__c = :System.Label.OptionOneTime AND Charge_Date__c = null AND Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Plan__c = null AND Service_Activation_Date__c <= :targetDate)
                                          OR(Price_Type__c = :System.Label.OptionOneTime AND Charge_Date__c = null AND Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Plan__c != null))
                                       OR
                                       (   (   Price_Type__c = :System.Label.OptionWeekly
                                               OR Price_Type__c = :System.Label.OptionMonthly
                                                       OR Price_Type__c = :System.Label.OptionQuarterly
                                                               OR Price_Type__c = :System.Label.OptionHalfYearly
                                                                       OR Price_Type__c = :System.Label.OptionAnnual
                                                                               OR Price_Type__c = :System.Label.OptionUsage
                                           )
                                            AND Service_Activation_Date__c <= :targetDate
                                            AND (Charge_Date__c = null OR Next_Charge_Date__c <= :targetDate)
                                       )
                                   )
                                   AND
                                   (
                                       (   Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c = null
                                               AND Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c = null
                                       )
                                       OR
                                       (   Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c = null
                                               //AND Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c = :targetDayString
                                               AND Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c IN :targetDayStrings
                                       )
                                       OR
                                       (   //Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c = :targetDayString
                                               Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c IN :targetDayStrings
                                       )
                                   )
                                   ORDER BY Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c, Job_Rate_Plan__r.Job_Product__r.Job__c,
                                   Job_Rate_Plan__r.Job_Product__c, CreatedDate, Sequence_No__c];
                } else {
                    charges = [SELECT Id, Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c, Job_Rate_Plan__r.Job_Product__r.Job__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Invoice_Delivery_Type__c, Deferred_Revenue_Accounting_Code__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Contact__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Shipping_Contact__c,
                               Job_Rate_Plan__r.Job_Product__r.Product__c, Job_Rate_Plan__r.Job_Product__r.Name, Product_Rate_Plan_Charge__c,
                               Accounting_Code__c, Name, Quantity__c, Unit_Of_Measurement__c, Charge_Date__c, Previous_Charge_Date__c, Next_Charge_Date__c,
                               Discount_Value__c, Service_Activation_Date__c, Service_End_Date__c, Grouping__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Service_End_Date__c, Price_Type__c, Price__c, Unit_Price__c, VAT__c, Tax__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Payment_Terms__c, Price_Format__c, Discount_Percent__c, VAT_Percentage__c, Tax_Percentage__c,
                               Committed_Quantity__c, Min_Customer_Spend__c, Max_Customer_Spend__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Terms__c, CurrencyL__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Master_Order__c, Invoice_Grouping__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Account__c,
                               Billing_Master_Order_Rate_Plan_Charge__r.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Order__c,
                               Billing_Master_Order_Rate_Plan_Charge__r.Job_Rate_Plan__r.Job_Product__r.Job__r.Is_Billing_Master_Order__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Order__c,
                               Billing_Master_Order_Rate_Plan_Charge__r.Billing_Master_Grouped_Quantity__c,Billing_Master_Order_Rate_Plan_Charge__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Partner__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Account__c,
                               Revenue_Recognition_Rule__c, Revenue_Recognition_Start_Date__c, Revenue_Recognition_End_Date__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Account__r.Payment_Terms__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Account__r.Payment_Terms__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Partner__r.Payment_Terms__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Account__r.Invoice_Delivery_Type__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Account__r.Invoice_Delivery_Type__c,
                               Job_Rate_Plan__r.Job_Product__r.Job__r.Partner__r.Invoice_Delivery_Type__c, Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Plan__c,
                               Bundle__c, Package__c, Required_By__c,Mid_Term_Adjustment__c,Order__r.Payment_Plan__c , Is_Cumulative_Usage__c, Used_Quantity_for_Usage__c,Job_Rate_Plan__r.Job_Product__r.Job__r.Tax_Engine__c
                               FROM Job_Rate_Plan_Charge__c
                               WHERE Job_Rate_Plan__r.Job_Product__r.Job__c IN : listOfIds
                               AND Job_Rate_Plan__r.Job_Product__r.Job__r.CurrencyL__c = :currencyId
                                   AND(
                                       ((Price_Type__c = :System.Label.OptionOneTime AND Charge_Date__c = null AND Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Plan__c = null AND Service_Activation_Date__c <= :targetDate)
                                      OR(Price_Type__c = :System.Label.OptionOneTime AND Charge_Date__c = null AND Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Plan__c != null))
                                       OR
                                       (   (   Price_Type__c = :System.Label.OptionWeekly
                                               OR Price_Type__c = :System.Label.OptionMonthly
                                                       OR Price_Type__c = :System.Label.OptionQuarterly
                                                               OR Price_Type__c = :System.Label.OptionHalfYearly
                                                                       OR Price_Type__c = :System.Label.OptionAnnual
                                                                               OR Price_Type__c = :System.Label.OptionUsage
                                           )
                                            AND Service_Activation_Date__c <= :targetDate
                                           AND (Charge_Date__c = null OR Next_Charge_Date__c <= :targetDate)
                                       )
                                   )
                                   AND(
                                       (   Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c = null
                                               AND Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c = null
                                       )
                                       OR
                                       (   Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c = null
                                               //AND Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c = :targetDayString
                                               AND Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c IN :targetDayStrings
                                       )
                                       OR
                                       (//Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c = :targetDayString
                                           Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c IN :targetDayStrings
                                       )
                                   )
                                   ORDER BY Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c, Job_Rate_Plan__r.Job_Product__r.Job__c,
                                  Job_Rate_Plan__r.Job_Product__c, CreatedDate, Sequence_No__c];
                }
            }

            //We need to create one invoice and multiple lines for each group of order/account
            map<Id, InvoiceClass> map_Id_InvoiceClass = new map<Id, InvoiceClass>();

            //This list holds all the usage charges to be updated
            list<Usage_Charge__c> listOfUsageChargesToUpdate = new list<Usage_Charge__c>();

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
            map<Id, Grouping__c> mapOfGroupId_Group = new map<Id, Grouping__c>();
            // Added by Dev M ticket : INVOICEIT-564 Invoice Presentation
            map<Id, Job_Rate_Plan_Charge__c> mapOfInvoiceGrouping = new map<Id, Job_Rate_Plan_Charge__c>();

            list<Usage_Charge__c> usagesLocal;
            decimal existingUnBilledAmount;
            for (Usage_Charge__c usageCharge : [SELECT Quantity__c, Order_Rate_Plan_Charge__c
                                                FROM Usage_Charge__c
                                                WHERE End_Date__c < :targetDate
                                                AND Status__c = :CommonUtilClass.STATUS_UNBILLED
                                                        AND Order_Rate_Plan_Charge__c IN: charges
                                                        AND Quantity__c != null]) {
                if (mapOfChargeId_UnBilledUsages.containsKey(usageCharge.Order_Rate_Plan_Charge__c)) {
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

            // loop over the charges to construct the map of groupId and groupObject
            for (Job_Rate_Plan_Charge__c charge : charges) {

                if (charge.Grouping__c != null) {
                    mapOfGroupId_Group.put(charge.Grouping__c, null);
                }
            // group the charge accordingly to Invoice Grouping    
                if(charge.Invoice_Grouping__c != null) {
                        mapOfInvoiceGrouping.put(charge.Id, charge);
                }
            }

            // query the group with order charges
            if (mapOfGroupId_Group.size() > 0) {
                mapOfGroupId_Group = new map<Id, Grouping__c>([SELECT Id,
                        (SELECT Id FROM Order_Rate_Plan_Charges__r)
                        FROM Grouping__c
                        WHERE Id In: mapOfGroupId_Group.keySet()]
                                                             );
            }

            //INVOICEIT_630, Collecting orderIds which If it has payment plan, Added by DL
            set<Id> setOfOrderIds = new set<Id>();
            set<Id> setOfMidtermAdjestments = new set<Id>();

            for (Job_Rate_Plan_Charge__c charge : charges) {

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
                //If the price type is usage process them only if shouldBillUsages is true
                //Also there appears to be a bug with the billing process where the service start date for the line is greater than service end date
                //especially when the charge date is null, the calculated value is negative
                //To tackle this we need filter out the charges where the charge date is null and the calculationstartdate > targetdate
                //To handle this we need to calculate the calculationstartdate and calculationenddate here
                if ( charge.Price_Type__c == System.Label.OptionWeekly ||
                        charge.Price_Type__c == System.Label.OptionMonthly ||
                        charge.Price_Type__c == System.Label.OptionQuarterly ||
                        charge.Price_Type__c == System.Label.OptionHalfYearly ||
                        charge.Price_Type__c == System.Label.OptionAnnual) {

                    if (charge.Next_Charge_Date__c != null) {
                        calculationStartDate = charge.Next_Charge_Date__c;
                    } else if (charge.Service_Activation_Date__c != null) {
                        calculationStartDate = charge.Service_Activation_Date__c;
                    }

                    /*Amended on 28 Apr 2012 by MG*/
                    //The invoice gets generated every month on the preferred billing day
                    //So align the end date to be invoice date + 1 month for weekly and monthly
                    //This ensures the charge is billed from the service activation date to invoice date in arrears and then 1 period in advance
                    //The charges for quarterly and above are not aligned as they need to be based on the service activation date always

                    if (calculationStartDate != null) {
                        if (charge.Price_Type__c == System.Label.OptionWeekly) {
                            //Even if the price type is weekly we would bill them every month for those many weeks in a month
                            calculationEndDate = targetDate.addMonths(1);
                        } else if (charge.Price_Type__c == System.Label.OptionMonthly) {
                            calculationEndDate = targetDate.addMonths(1);
                        } else if (charge.Price_Type__c == System.Label.OptionQuarterly) {
                            calculationEndDate = targetDate.addMonths(3);
                        } else if (charge.Price_Type__c == System.Label.OptionHalfYearly) {
                            calculationEndDate = targetDate.addMonths(6);
                        } else if (charge.Price_Type__c == System.Label.OptionAnnual) {
                            calculationEndDate = targetDate.addYears(1);
                        }

                        //If the service ends before the calculation end date we would be billing only till the service end date and not the target date
                        if (charge.Service_End_Date__c != null
                                && charge.Service_End_Date__c < calculationEndDate) {
                            //The service end date will be one day before the actual end date... say the service starts on 14th mar and ends on 13th apr
                            //So add 1 day to this to ensure the calculation is correct
                            calculationEndDate = charge.Service_End_Date__c;
                            calculationEndDate = calculationEndDate.addDays(1);
                            dateAdjusted = true;
                        } else if (charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Service_End_Date__c != null
                                   && charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Service_End_Date__c < calculationEndDate) {
                            //The service end date will be one day before the actual end date... say the service starts on 14th mar and ends on 13th apr
                            //So add 1 day to this to ensure the calculation is correct
                            calculationEndDate = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Service_End_Date__c;
                            calculationEndDate = calculationEndDate.addDays(1);
                            dateAdjusted = true;
                        }
                    }
                } else if (charge.Price_Type__c == System.Label.OptionOneTime || charge.Price_Type__c == System.Label.OptionUsage) {
                    if (charge.Service_Activation_Date__c != null) {
                        calculationStartDate = charge.Service_Activation_Date__c;
                    }
                }
                //To manage refunds during mid-term adjustements etc need to add another condition similar to
                //if the partrefund config parameter is true and the next charge date is null then the calculationstartdate < calculationenddate condition can be ignored

                boolean canRefundChargesDuringAdjustments = (Configuration__c.getValues('CAN_REFUND_CHARGES_DURING_ADJUSTMENTS').Boolean_Value__c);

                //If the config parameter BILL_ONETIME_CHARGES_BASED_ON_DATES is true then pick up those one time charges
                //that have their Service_Activation_Date__c on or before the target date
                if ( calculationStartDate != null
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
                         ) ) ) {
                    string defaultPaymentTerms = Configuration__c.getValues('DEFAULT_PAYMENT_TERMS').String_Value__c;
                    currentChargeDetails = '\n Current Charge Id : ' + charge.Id + ' \n Order Id : ' + charge.Job_Rate_Plan__r.Job_Product__r.Job__c + ' \n Account Id : ' + charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c;
                    InvoiceClass invoiceClass;
                    Invoice__c invoice;
                    list<Invoice_Lines__c> listOfInvoiceLines;

                    //If you group by orders, then use order id as the key for the map else account id
                    Id idForComparison;

                    if (INVOICING_GROUP_BY == CommonUtilClass.INVOICING_GROUP_BY_ACCOUNT) {
                        idForComparison = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c;
                    } else {
                        idForComparison = charge.Job_Rate_Plan__r.Job_Product__r.Job__c;
                    }

                    if (map_Id_InvoiceClass.containsKey(idForComparison)) {
                        invoiceClass = map_Id_InvoiceClass.get(idForComparison);
                        invoice = InvoiceClass.invoice;
                        listOfInvoiceLines = invoiceClass.invoiceLines;
                    } else {
                        invoiceClass = new InvoiceClass();
                        map_Id_InvoiceClass.put(idForComparison, invoiceClass);
                        invoice = new Invoice__c();
                        listOfInvoiceLines = new list<Invoice_Lines__c>();

                        invoice.account__c = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c;
                        /*
                             Modified By     :   Rama krishna.v
                             Modified Date   :   05-12-2013
                             JIRA Task       :   INVOICEIT-272
                             Comments        :   i have changed the below condition, because no of account ids are processed wrong on invoice run deatil page,
                                                                     for this created new set<id> as global to check how many Accounts are processed in entire batch then only adding
                                                                     the ids to the local setofAccount

                                                                        Previous code
                                                                        if(!setOfAccountIds.contains(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c)){
                                                                            setOfAccountIds.add(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c);
                                                                        }
                         */
                        //Increment the account counter for every unique account processed
                        if (!setOfAllAccountIdsProcessed.contains(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c)) {
                            setOfAllAccountIdsProcessed.add(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c);
                            setOfAccountIds.add(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c);
                        }
                        //Increment the order counter for every unique order processed
                        if (!setOfJobIds.contains(charge.Job_Rate_Plan__r.Job_Product__r.Job__c)) {
                            setOfJobIds.add(charge.Job_Rate_Plan__r.Job_Product__r.Job__c);
                        }
                        invoice.Invoice_Date__c = invoiceDate;

                        /*Amended on 05 Jun 2013 by Anil(Jira -- INVOICEIT-80)*/
                        //Laxman has modified because we should calculate based on account payment terms
                        //Anil has modified because we should calculate the due DATE based on payment terms configured based on Account Or Order- Issue 80
                        if (sDefaultPaymentTerm != null && sDefaultPaymentTerm == CommonUtilClass.PAYMENT_TERM_ACCOUNT && charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Payment_Terms__c != null && mapPaymentTerms.containsKey(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Payment_Terms__c)) {
                            noOfDaysToDueDate = (integer) mapPaymentTerms.get(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Payment_Terms__c).Number_Of_Days__c;
                            invoice.Due_Date__c = invoiceDate.addDays(noOfDaysToDueDate);
                        } else if (sDefaultPaymentTerm != null && sDefaultPaymentTerm == CommonUtilClass.PAYMENT_TERM_ORDER && charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Terms__c != null && mapPaymentTerms.containsKey(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Terms__c)) {
                            noOfDaysToDueDate = (integer) mapPaymentTerms.get(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Terms__c).Number_Of_Days__c;
                            invoice.Due_Date__c = invoiceDate.addDays(noOfDaysToDueDate);
                        } else {
                            // Dev M if defaultPaymentTerms are null the assign due date INVOICEIT-356
                            if (mapPaymentTerms.containskey(defaultPaymentTerms)) {
                                noOfDaysToDueDate = (integer) mapPaymentTerms.get(defaultPaymentTerms).Number_Of_Days__c;
                                invoice.Due_Date__c = invoiceDate.addDays(noOfDaysToDueDate);
                            } else {
                                invoice.Due_Date__c = invoice.Invoice_Date__c;
                            }
                        }

                        invoice.Invoice_Status__c = CommonUtilClass.STATUS_DRAFT;
                        invoice.Target_Date__c = targetDate;
                        invoice.CurrencyL__c = currencyId;
                        invoice.Invoice_Run_Created_By__c = invoiceRun.Id;
                        invoice.Delivery_Type__c = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Invoice_Delivery_Type__c;
                        invoice.Billing_Contact__c = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Contact__c;
                        invoice.Shipping_Contact__c = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Shipping_Contact__c;
                        //mapping order Tax Engine to invoice Tax Engine
                        invoice.Tax_Engine__c = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Tax_Engine__c;
                        //Link this invoice to the order if the group by is order
                        if (INVOICING_GROUP_BY == CommonUtilClass.INVOICING_GROUP_BY_ORDER) {
                            invoice.Order__c = charge.Job_Rate_Plan__r.Job_Product__r.Job__c;
                        }

                        /*Amended on 23 Nov 2012 by Laxman*/
                        //Populate the custom Invoice number based on the custom setttings
                        sobject sObjectBasedOnGroupBy = null;
                        string legalEntityName = null;
                        if (this.INVOICING_GROUP_BY == CommonUtilClass.INVOICING_GROUP_BY_ACCOUNT && sAccountLegalEntity != null) {
                            sObjectBasedOnGroupBy = map_Id_Sobject.get(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c);
                            legalEntityName = (string) sObjectBasedOnGroupBy.get(sAccountLegalEntity);
                        } else if (sOrderLegalEntity != null) {
                            sObjectBasedOnGroupBy = map_Id_Sobject.get(charge.Job_Rate_Plan__r.Job_Product__r.Job__c);
                            legalEntityName = (string) sObjectBasedOnGroupBy.get(sOrderLegalEntity);
                        }

                        if (sObjectBasedOnGroupBy != null && legalEntityName != null) {
                            string invoiceNumber = '';
                            if (mapOfSequenceNumbersToUpdate.containsKey(legalEntityName)) {
                                Sequence_Number__c sequenceNumber = mapOfSequenceNumbersToUpdate.get(legalEntityName);
                                // enter only if the next invoice next number is not null
                                if (sequenceNumber.Invoice_Next_Number__c != null) {
                                    // get the prefix if it not null
                                    if (sequenceNumber.Invoice_Prefix__c != null) {
                                        invoiceNumber = sequenceNumber.Invoice_Prefix__c;
                                    }
                                    // get the Invoice_Next_Number__c
                                    invoiceNumber = invoiceNumber + string.ValueOf(Integer.ValueOf(sequenceNumber.Invoice_Next_Number__c));
                                    // get the suffix if it not null
                                    if (sequenceNumber.Invoice_Suffix__c != null) {
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

                        //Apply the exchange rate if this is a multicurrency org
                        if (UserInfo.isMultiCurrencyOrganization()) {
                            if (datedConversionRate != null) {
                                sobject sobjectInvoice = (sobject)invoice;
                                sobjectInvoice.put(CommonUtilClass.getPrefix()+'Exchange_Rate_Applied__c', (decimal) datedConversionRate.get('ConversionRate'));
                                sobjectInvoice.put('CurrencyIsoCode', (string) currencyIsoCode);
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
                    if (UserInfo.isMultiCurrencyOrganization()) {
                        CommonUtilClass.populateCurrencyIsoCodeOnSobject(invoiceLine, currencyIsoCode);
                    }
                    /*
                            Modified By   : Ankit Sharma
                            Modified Date : 27 Feb 2014
                            JIRA Task     : INVOICEIT-319
                            Comments      : assinging the currency to invoice line currency
                    */
                    invoiceLine.CurrencyL__c = charge.CurrencyL__c;
                    // One Time charges code is commented by DEV M also handled in below condition
                    
                    //All the other fields for the invoiceline are different for onetime and recurring
                    /* if (charge.Price_Type__c == System.Label.OptionOneTime) {
                        invoiceLine.Line_Amount__c = charge.Price__c;
                        invoiceLine.Discount_Value__c = charge.Discount_Value__c;
                        invoiceLine.Unit_Price__c = charge.Unit_Price__c;
                        invoiceLine.Line_Name__c = charge.Name;
                        invoiceLine.VAT__c = charge.VAT__c;
                        invoiceLine.Tax__c = charge.Tax__c;
                        invoiceLine.Service_Start_Date__c = targetDate;
                        // Modified by DEV M INVOICEIT-545
                        invoiceLine.Calculated_Quantity__c = 1;
                        //laxman added on 18 jan
                        //Add up these values to be stored in the invoicerun record
                        //totalInvoiceValue += invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c + invoiceLine.VAT__c + invoiceLine.Tax__c;

                        //Update the charge date to the target date as that is till what the charges have been calculated for
                        charge.Charge_Date__c = targetDate;

                    } else */ if ( charge.Price_Type__c == System.Label.OptionWeekly ||
                                  charge.Price_Type__c == System.Label.OptionMonthly ||
                                  charge.Price_Type__c == System.Label.OptionQuarterly ||
                                  charge.Price_Type__c == System.Label.OptionHalfYearly ||
                                  charge.Price_Type__c == System.Label.OptionAnnual ||
                                  charge.Price_Type__c == System.Label.OptionOneTime) {
                        //These store the no of days and months inbetween both the dates
                        Decimal noOfDays = 0;
                        //This determines how many times the actual charge price to be applied
                        Decimal noOfTimesCharge = 0;


                        
                        if(charge.Price_Type__c == System.Label.OptionOneTime) {
                            noOfTimesCharge = 1;
                        }else if (charge.Price_Type__c == System.Label.OptionWeekly) {
                            noOfDays = calculationStartDate.daysBetween(calculationEndDate);
                            noOfTimesCharge = noOfDays.Divide(7, 3, System.RoundingMode.UP);
                        } else {
                            noOfTimesCharge = InvoicingUtilClass.calculateDiffBetweenDatesInMonths(calculationStartDate, calculationEndDate, charge.Price_Type__c);
                        }
                        
                        invoiceLine.Line_Amount__c = charge.Price__c * noOfTimesCharge;
                        invoiceLine.Discount_Value__c = charge.Discount_Value__c * noOfTimesCharge;
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
                                    throw new CustomException(system.Label.UsageQuantityDoesNotExist + charge.Name);
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
                                    throw new CustomException(system.Label.UsageQuantityDoesNotExist + charge.Name);
                                }           
                            
                            }

                        }

                        // Code ends for Consortium Billing Here


                        //Add up these values to be stored in the invoicerun record
                        //totalInvoiceValue += invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c + invoiceLine.VAT__c + invoiceLine.Tax__c;

                        

                        // Add by Dev M dont excecute for one time

                        if(charge.Price_Type__c != System.Label.OptionOneTime) {    
                            //Update the charge date to the target date as that is till what the charges have been calculated for
                            //Update the previous charge date with the charge date
                            charge.Previous_Charge_Date__c = charge.Charge_Date__c;
                            charge.Charge_Date__c = targetDate;
                        
                            //In this case the next charge date should not be populated as there is no next charge date
                            //If during this run the charges have been calculated till the service end date, then dont populate the next charge date
                            if (calculationEndDate >= charge.Service_End_Date__c) {
                                charge.Next_Charge_Date__c = null;
                            } else if (calculationEndDate >= charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Service_End_Date__c) {
                                charge.Next_Charge_Date__c = null;
                            } else {
                                if (dateAdjusted) {
                                    calculationEndDate = calculationEndDate.addDays(-1);
                                }
                                charge.Next_Charge_Date__c = calculationEndDate;

                                // INVOICEIT-251 Moified by Laxman
                                /*   If PBD = 29 && calculationEndDate.month() == Mar
                                        then invoiceLine Service_End_Date__c = 29 Mar

                                        *If PBD = 30 && calculationEndDate.month() == Mar
                                        then invoiceLine Service_End_Date__c = 30 Mar

                                        *If PBD = 31 && calculationEndDate.month() == Mar
                                        then invoiceLine Service_End_Date__c = 31 Mar*/

                                integer preferredBillingDate = null;
                                if (INVOICING_GROUP_BY == CommonUtilClass.INVOICING_GROUP_BY_ACCOUNT) {
                                    if (charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c != null)
                                        preferredBillingDate = integer.ValueOf(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Preferred_Billing_Day__c);
                                } else {
                                    if (charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c != null)
                                        preferredBillingDate = integer.ValueOf(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Preferred_Billing_Day__c);
                                }

                                if (preferredBillingDate != null && calculationEndDate != null ) { //&& charge.Price_Type__c == System.Label.OptionMonthly) {
                                    integer lastDayOfEndDate = date.daysInMonth(calculationEndDate.year(), calculationEndDate.month());
                                    if (calculationEndDate.month() == 3) {
                                        if (preferredBillingDate == 29) {
                                            invoiceLine.Service_End_Date__c = Date.newInstance(calculationEndDate.year(), calculationEndDate.month(), 28);
                                            charge.Next_Charge_Date__c = invoiceLine.Service_End_Date__c.addDays(1);
                                        } else if (preferredBillingDate == 30) {
                                            invoiceLine.Service_End_Date__c = Date.newInstance(calculationEndDate.year(), calculationEndDate.month(), 29);
                                            charge.Next_Charge_Date__c = invoiceLine.Service_End_Date__c.addDays(1);
                                        } else if (preferredBillingDate == 31) {
                                            invoiceLine.Service_End_Date__c = Date.newInstance(calculationEndDate.year(), calculationEndDate.month(), 30);
                                            charge.Next_Charge_Date__c = invoiceLine.Service_End_Date__c.addDays(1);
                                        }
                                    } else if (calculationEndDate.month() == 5 || calculationEndDate.month() == 7 || calculationEndDate.month() == 8 || calculationEndDate.month() == 10 || calculationEndDate.month() == 12) {
                                        if (preferredBillingDate == 31) {
                                            invoiceLine.Service_End_Date__c = Date.newInstance(calculationEndDate.year(), calculationEndDate.month(), 30);
                                            charge.Next_Charge_Date__c = invoiceLine.Service_End_Date__c.addDays(1);
                                        }
                                    }
                                }
                            }
                        }   
                    } else if ( charge.Price_Type__c == System.label.OptionUsage) {
                       
                        // Modified By : Laxman Rao M, Jira No: INVOICEIT-316
                        // get the unbilled charges from the map. if usageCharges does not contain in the map then initialize it because it will give null pointer exception
                        Usage_Charge__c[] usageCharges;
                        if (mapOfChargeId_UnBilledUsages.containsKey(charge.Id)) {
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
                        if (mapOfChargeId_UnBilledQuantity.containsKey(charge.Id)) {
                            tempQuantity = mapOfChargeId_UnBilledQuantity.get(charge.Id);

                            // some times the quantity might be null
                            if (tempQuantity == null) {
                                tempQuantity = 0;
                            }
                        }

                        //If the order charge has committed quantity populated then compare this quantity with that
                        //If usage quantity is < committed quantity then use the committed quantity
                        //If usage quantity >= committed quantity then use the usage quantity
                        if ( charge.Committed_Quantity__c != null
                                && charge.Committed_Quantity__c != 0
                                && tempQuantity < charge.Committed_Quantity__c) {
                            tempQuantity = charge.Committed_Quantity__c;
                        }

                        invoiceLine.Quantity__c = tempQuantity;
                        chargetempQuantity = tempQuantity;

                        if(charge.Used_Quantity_for_Usage__c != null && charge.Is_Cumulative_Usage__c)
                             tempQuantity = tempQuantity + charge.Used_Quantity_for_Usage__c;

                        if (tempQuantity > 0) {
                            //If the price model is volume pricing
                            if (charge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME) {
                                Job_Rate_Plan_Charge_Tier__c[] tiers;
                                // Ref : INVOICEIT-243
                                Decimal totalQuantityOfGroup = 0;
                                if (charge.Grouping__c == null) {

                                    /*
                                    Modified By     : Ramakrishna.v
                                    Modified Date   : 03-7-2013
                                    JIRA Task       : SUP-2/INVOICEIT-209
                                    Comments        : some order charges does not have product charges ids
                                    */
                                    //previously querying from product charge tiers due to that after creation of inv line, amount is not caluclating, now changed to order charge tiers
                                    tiers = [SELECT Unit_Price__c
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
                                } else {
                                    // Modified By : Laxman Rao M, Jira No: INVOICEIT-316
                                    // here based on the groupId we are getting the listOfCharges
                                    Job_Rate_Plan_Charge__c[] chargesRelatedtoTransactionGroup;
                                    if (mapOfGroupId_Group.containsKey(charge.Grouping__c)) {
                                        chargesRelatedtoTransactionGroup =  mapOfGroupId_Group.get(charge.Grouping__c).Order_Rate_Plan_Charges__r;
                                    }

                                    AggregateResult[] resultsRelatedtoTransactionGroup;
                                    resultsRelatedtoTransactionGroup = [SELECT SUM(Quantity__c) Quantity
                                                                        FROM Usage_Charge__c
                                                                        WHERE End_Date__c < :targetDate
                                                                        AND
                                                                        (
                                                                            Status__c = :CommonUtilClass.STATUS_UNBILLED
                                                                                    OR
                                                                                    Invoice__r.Invoice_Run_Created_By__c = : invoiceRun.Id
                                                                        )
                                                                        AND Order_Rate_Plan_Charge__c In: chargesRelatedToTransactionGroup
                                                                       ];


                                    if (!resultsRelatedtoTransactionGroup.isEmpty()) {
                                        totalQuantityOfGroup = (decimal)(resultsRelatedtoTransactionGroup.get(0).get('Quantity'));
                                    }

                                    tiers = [SELECT Unit_Price__c
                                             FROM Job_Rate_Plan_Charge_Tier__c
                                             WHERE Job_Rate_Plan_Charge__c = :charge.Id
                                                     AND
                                                     (
                                                         (
                                                             Start_Unit__c <= :totalQuantityOfGroup
                                                             AND
                                                             End_Unit__c >= :totalQuantityOfGroup
                                                         )
                                                         OR
                                                         (
                                                             Start_Unit__c <= :totalQuantityOfGroup
                                                             AND
                                                             End_Unit__c = NULL
                                                         )
                                                     )];

                                }

                                if (!tiers.isEmpty()) {
                                    invoiceLine.Unit_Price__c = tiers.get(0).Unit_Price__c;
                                    invoiceLine.Line_Amount__c = invoiceLine.Unit_Price__c * chargetempQuantity;
                                    invoiceLine.Discount_Value__c = (charge.Discount_Percent__c * invoiceLine.Line_Amount__c) / 100;
                                    invoiceLine.Line_Name__c = charge.Name;
                                    // Ref : IT-86, Modified By : Devender M
                                    invoiceLine.Grouped_Quantity__c = totalQuantityOfGroup;
                                    invoiceLine.VAT__c = (charge.VAT_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c)) / 100;
                                    if(invoice.Tax_Engine__c == System.Label.Standard || invoice.Tax_Engine__c == '' || invoice.Tax_Engine__c == null){
                                        invoiceLine.Tax__c = (charge.Tax_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c)) / 100;
                                    }else{
                                        invoiceLine.Tax__c = 0.0;
                                    }
                                    
                                } else {
                                    // Ref : INVOICEIT-256, Modified By : Laxman Rao M
                                    // if the tiers are not found, throw an exception(custom)
                                    throw new CustomException(system.Label.UsageQuantityDoesNotExist + charge.Name);
                                }

                            } else if (charge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE) {
                                /*
                                Modified By     : Ramakrishna.v
                                Modified Date   : 03-7-2013
                                JIRA Task       : SUP-2/INVOICEIT-209
                                Comments        : some order charges does not have product charges ids
                                Product_Rate_Plan_Charge_Tier__c[] tiers = [SELECT Unit_Price__c
                                                                                                                         FROM Product_Rate_Plan_Charge_Tier__c
                                                                                                                         WHERE Product_Rate_Plan_Charge__c = :charge.Product_Rate_Plan_Charge__c
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
                                                                                                                        ]; */

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
                                if (!tiers.isEmpty()) {
                                    invoiceLine.Unit_Price__c = tiers.get(0).Unit_Price__c;
                                    invoiceLine.Line_Amount__c = invoiceLine.Unit_Price__c * 1;
                                    invoiceLine.Discount_Value__c = (charge.Discount_Percent__c * invoiceLine.Line_Amount__c) / 100;
                                    invoiceLine.Line_Name__c = charge.Name;
                                    invoiceLine.VAT__c = (charge.VAT_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c)) / 100;
                                    if(invoice.Tax_Engine__c == System.Label.Standard || invoice.Tax_Engine__c == '' || invoice.Tax_Engine__c == null){
                                        invoiceLine.Tax__c = (charge.Tax_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c)) / 100;
                                    }else{
                                        invoiceLine.Tax__c = 0.0;
                                    }
                                    
                                } else {
                                    // Ref : INVOICEIT-256, Modified By : Laxman Rao M
                                    // throw a custom exception, saying no tiers found
                                    throw new CustomException(system.Label.UsageQuantityDoesNotExist + charge.Name);
                                }
                            } else if (charge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_TIERED) {
                                /*
                                Modified By     : Ramakrishna.v
                                Modified Date   : 03-7-2013
                                JIRA Task       : SUP-2/INVOICEIT-209
                                Comments        : some order charges does not have product charges ids
                                list<Product_Rate_Plan_Charge_Tier__c> tempTiers = [SELECT Id, Start_Unit__c, Unit_Price__c, End_Unit__c
                                                                                                                                        FROM Product_Rate_Plan_Charge_Tier__c
                                                                                                                                        WHERE Product_Rate_Plan_Charge__c =: charge.Product_Rate_Plan_Charge__c
                                                                                                                                        order BY Start_Unit__c]; */
                                // previously querying from product charge tiers due to that after creation of inv line, amount is not caluclating, now changed to order charge tiers
                                list<Job_Rate_Plan_Charge_Tier__c> tempTiers = [SELECT Id, Start_Unit__c, Unit_Price__c, End_Unit__c
                                        FROM Job_Rate_Plan_Charge_Tier__c
                                        WHERE Job_Rate_Plan_Charge__c = : charge.Id
                                                                        order BY Start_Unit__c];

                                // Ref : INVOICEIT-256, Modified By : Laxman Rao M
                                // throw a custom exception, saying no tiers found
                                if (tempTiers.size() == 0) {
                                    throw new CustomException('Tiers were not defined for ' + charge.Name);
                                }

                                decimal usageAmount = 0;
                                boolean isTierQtyExists = false;
                                decimal remaningUsage = tempQuantity;
                                decimal usageQuantity = tempQuantity;
                                boolean hasbilledOld = false;
                                decimal remaningCumulativeUsage = tempQuantity - chargetempQuantity;

                                for (integer i = 0; i < tempTiers.Size(); i++) {
                                    // declation of variable 'productChargeTier' not changed because this is refereing other places.
                                    Job_Rate_Plan_Charge_Tier__c productChargeTier = tempTiers[i];
                                    if (usageQuantity >= productChargeTier.Start_Unit__c) {
                                        decimal diff;
                                        isTierQtyExists = true;
                                        if (productChargeTier.End_Unit__c != null) {
                                            diff = integer.ValueOf(productChargeTier.End_Unit__c - productChargeTier.Start_Unit__c + 1);
                                        } else {
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

                                        if (remaningUsage <= diff) {
                                            //calculate the sp
                                            usageAmount += (decimal) (remaningUsage * productChargeTier.Unit_Price__c);
                                        } else {
                                            //calculate the sp
                                            usageAmount += (decimal) (diff * productChargeTier.Unit_Price__c);
                                        }
                                        remaningUsage = remaningUsage - diff;

                                        //this means it has reached end tier and remaning Usage is still present
                                        if (i == tempTiers.Size() - 1 && remaningUsage > 0) {
                                            //calculate the sp
                                            usageAmount += (remaningUsage * productChargeTier.Unit_Price__c);
                                        }
                                    }
                                }

                                if (!isTierQtyExists) {
                                    throw new CustomException(system.Label.UsageQuantityDoesNotExist + charge.Name);
                                }

                                invoiceLine.Line_Amount__c = usageAmount;
                                invoiceLine.Unit_Price__c = usageAmount / chargetempQuantity;
                                invoiceLine.Discount_Value__c = (charge.Discount_Percent__c * invoiceLine.Line_Amount__c) / 100;
                                invoiceLine.Line_Name__c = charge.Name;
                                invoiceLine.VAT__c = (charge.VAT_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c)) / 100;
                                if(invoice.Tax_Engine__c == System.Label.Standard || invoice.Tax_Engine__c == '' || invoice.Tax_Engine__c == null){
                                    invoiceLine.Tax__c = (charge.Tax_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c)) / 100;
                                }else{
                                    invoiceLine.Tax__c = 0.0;
                                }
                                
                            } else {
                                invoiceLine.Unit_Price__c = charge.Unit_Price__c;
                                invoiceLine.Line_Amount__c = invoiceLine.Unit_Price__c * tempQuantity;
                                invoiceLine.Discount_Value__c = (charge.Discount_Percent__c * invoiceLine.Line_Amount__c) / 100;
                                invoiceLine.Line_Name__c = charge.Name;
                                invoiceLine.VAT__c = (charge.VAT_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c)) / 100;
                                if(invoice.Tax_Engine__c == System.Label.Standard || invoice.Tax_Engine__c == '' || invoice.Tax_Engine__c == null){
                                    invoiceLine.Tax__c = (charge.Tax_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c)) / 100;
                                }else{
                                    invoiceLine.Tax__c = 0.0;
                                }
                                
                            }
                            //reset the next charge date of that charge
                            charge.Charge_Date__c = targetDate;
                            charge.Next_Charge_Date__c = null;
                        } else {
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

                        if ( charge.Min_Customer_Spend__c > 0
                                && invoiceLine.Line_Amount__c < charge.Min_Customer_Spend__c) {
                            invoiceLine.Line_Amount__c = charge.Min_Customer_Spend__c;
                            invoiceLine.Discount_Value__c = (charge.Discount_Percent__c * invoiceLine.Line_Amount__c) / 100;
                            invoiceLine.VAT__c = (charge.VAT_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c)) / 100;
                            if(invoice.Tax_Engine__c == System.Label.Standard || invoice.Tax_Engine__c == '' || invoice.Tax_Engine__c == null){
                                invoiceLine.Tax__c = (charge.Tax_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c)) / 100;
                            }else{
                                invoiceLine.Tax__c = 0.0;
                            }
                            
                        } else if ( charge.Max_Customer_Spend__c > 0
                                    && invoiceLine.Line_Amount__c > charge.Max_Customer_Spend__c) {
                            //We are capping the customer spend here
                            invoiceLine.Line_Amount__c = charge.Max_Customer_Spend__c;
                            invoiceLine.Discount_Value__c = (charge.Discount_Percent__c * invoiceLine.Line_Amount__c) / 100;
                            invoiceLine.VAT__c = (charge.VAT_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c)) / 100;
                            if(invoice.Tax_Engine__c == System.Label.Standard || invoice.Tax_Engine__c == '' || invoice.Tax_Engine__c == null){
                                invoiceLine.Tax__c = (charge.Tax_Percentage__c * (invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c)) / 100;
                            }else{
                                invoiceLine.Tax__c = 0.0;
                            }
                            
                        }

                        //Add up these values to be stored in the invoicerun record
                        //totalInvoiceValue += invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c + invoiceLine.VAT__c + invoiceLine.Tax__c;

                        //Update the charge date to the target date as that is till what the charges have been calculated for
                        //Update the previous charge date with the charge date
                        if(charge.Used_Quantity_for_Usage__c == null && charge.Is_Cumulative_Usage__c)
                            charge.Used_Quantity_for_Usage__c = chargetempQuantity;
                        else if(charge.Is_Cumulative_Usage__c)
                            charge.Used_Quantity_for_Usage__c = charge.Used_Quantity_for_Usage__c + chargetempQuantity;
                        charge.Previous_Charge_Date__c = charge.Charge_Date__c;
                        charge.Charge_Date__c = targetDate;
                        mapOfChargesToUpdate.put(charge.Id, charge);

                    }

                    //added in 1.9.1(Laxman : Partially paid invoice that is paid in full)
                    if (invoiceLine.Line_Amount__c != null && invoiceLine.Line_Amount__c > 0) {
                        invoiceLine.Line_Amount__c = invoiceLine.Line_Amount__c.setScale(2);
                    }
                    if (invoiceLine.Discount_Value__c != null && invoiceLine.Discount_Value__c > 0) {
                        invoiceLine.Discount_Value__c = invoiceLine.Discount_Value__c.setScale(2);
                    }
                    if (invoiceLine.VAT__c != null && invoiceLine.VAT__c > 0) {
                        invoiceLine.VAT__c = invoiceLine.VAT__c.setScale(2);
                    }
                    if (invoiceLine.Tax__c != null && invoiceLine.Tax__c > 0) {
                        invoiceLine.Tax__c = invoiceLine.Tax__c.setScale(2);
                    }
                    //Add the invoiceline to be created only if the quantity is > 0. This will avoid duplicate lines being created for Usage
                    if ((invoiceline.Quantity__c > 0) || (charge.Bundle__c || charge.Package__c || charge.Required_By__c != null)) {
                        listOfInvoiceLines.add(invoiceLine);
                        invoiceLinesToInsert.add(invoiceline);
                        map_Id_OrderCharge.put(charge.Id, charge); 
                    }
                    invoiceClass.invoiceLines = listOfInvoiceLines;
                }
            }
            noOfAccountsProcessed += setOfAccountIds.size();
            noOfJobsProcessed += setOfJobIds.size();

            // 272(Laxman Rao M)
            // If the control comes here means their is no exception while processing any charge, so we need to clear the currentChargeDetails as null
            // their might be an exception while inserting the invoices or updating the usage charges, populate the error message saying "Exception occurred while updating the charges"
            currentChargeDetails = null;
            //currentChargeDetails = 'An exception has occurred while inserting the invoices or updating the usage charges, error is logged. Current Account or OrderIs is : ' + scope[0].Id;
            //Added by Shruthi related to INVOICEIT-200
            currentChargeDetails = system.Label.ExceptionOccurredWhileInsertingInvoices + ' ' + scope[0].Id;

            // Added by Dev M ticket : INVOICEIT-564 Invoice Presentation and commented insertInvoicesAndLines
            //Insert the invoices, invoice lines and update the charges to reflect the date changes
            //InvoicingUtilClass.insertInvoicesAndLines(map_Id_InvoiceClass, listOfUsageChargesToUpdate);
            //InvoicingUtilClass.insertInvoicesAndLines2(map_Id_InvoiceClass, listOfUsageChargesToUpdate, mapOfInvoiceGrouping, invoiceRun.Id);
            InvoicingUtilClass.insertInvoicesAndLines2(invoiceLinesToInsert, listOfUsageChargesToUpdate, map_Id_OrderCharge, invoiceRun, currencyIsoCode, mapPaymentTerms, datedConversionRate);
            // 272(Laxman Rao M)
            // If the control comes here means their is no exception till insertion of invoices in the system, so we need to clear the currentChargeDetails as null
            // their might be an exception while updating the order rate plan charges, populate the error message saying "Exception occurred while updating the charges"
            currentChargeDetails = null;
            currentChargeDetails = system.Label.ExceptionOccurredWhileUpdatingTheOrderRPC + ' ' + scope[0].Id;
             list<AggregateResult> results = [select min(End_Date__c) enddate,  Order_Rate_Plan_Charge__c ord from Usage_Charge__c where  Status__c = 'Un-billed' And Order_Rate_Plan_Charge__c IN: charges group by Order_Rate_Plan_Charge__c];             Job_Rate_Plan_Charge__c charge;
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

            //Update the charges to reflect the date changes
            update charges; 

            //INVOICEIT-630, Linking Invoice and Payment installment records Once inoice is generated. Added by DL
            //Start
            if(!charges.isEmpty() && charges[0].Order__r.Payment_Plan__c != null) {
                Map<Id, Id> mapOfOrderIdToInvoiceId = new Map<Id, Id>();
                set<Id> setOfInvoiceIds = new set<Id>();
                for(Invoice_Lines__c invLines: invoiceLinesToInsert){
                  setOfInvoiceIds.add(invLines.Invoice__c);
                }
                list<Invoice__c> listOfInvoice = [Select Id, Total_Invoice_Value__c, Order__c From Invoice__c Where Id In: setOfInvoiceIds];
                for(Invoice__c invoice : listOfInvoice){
                    if(invoice.Order__c != null){
                      mapOfOrderIdToInvoiceId.put(invoice.Order__c, invoice.id);
                    }       
                }
                map<Id, list<Payment_Plan_Installment__c>> mapOfororderIdToPaymentPlanInstllment = new map<Id, list<Payment_Plan_Installment__c>>();
                list<Payment_Plan_Installment__c> listOfPaymentInstallmentsToUpdate = new list<Payment_Plan_Installment__c>();
                list<Payment_Plan_Installment__c> listOfPaymentInstallments= new list<Payment_Plan_Installment__c>();

                //If order has Amendments then map only related PPI to invoice, INVOICEIT-680
                //Else map all the PPI to invoice
                if(!setOfOrderIds.isEmpty() && !setOfMidtermAdjestments.isEmpty()){
                    for(Job__c orders : [select Id, Name, (select Id, Invoice__c, Order__c,Mid_Term_Adjustment__c From Payment_Plan_Installments__r where Mid_Term_Adjustment__c IN: setOfMidtermAdjestments) From Job__c Where Id IN:setOfOrderIds]){
                        mapOfororderIdToPaymentPlanInstllment.put(orders.Id, orders.Payment_Plan_Installments__r);
                    }
                }else if(!setOfOrderIds.isEmpty()){
                    for(Job__c orders : [select Id, Name, (select Id, Invoice__c, Order__c,Mid_Term_Adjustment__c From Payment_Plan_Installments__r) From Job__c Where Id IN:setOfOrderIds]){
                        mapOfororderIdToPaymentPlanInstllment.put(orders.Id, orders.Payment_Plan_Installments__r);
                    }
                }

                for(Id ids: mapOfOrderIdToInvoiceId.keySet()){
                    if(mapOfororderIdToPaymentPlanInstllment.containskey(ids)){
                        listOfPaymentInstallments = mapOfororderIdToPaymentPlanInstllment.get(ids);
                        for(Payment_Plan_Installment__c pInstallments: listOfPaymentInstallments){
                            pInstallments.Invoice__c = mapOfOrderIdToInvoiceId.get(ids);
                            listOfPaymentInstallmentsToUpdate.add(pInstallments);
                        }
                    }
                } 
                

                if(!listOfPaymentInstallmentsToUpdate.isEmpty()){
                    update listOfPaymentInstallmentsToUpdate;
                }
                // Added by Dev M Ticket : INVOICEIT-677
                list<Invoice__c> listOfInvoiceToUpdate = new list<Invoice__c>();
                for(Invoice__c invoice : listOfInvoice) {
                    if(invoice.Total_Invoice_Value__c < 0) {
                        invoice.Debit_Invoice__c = true;
                        listOfInvoiceToUpdate.add(invoice);
                    }
                }
                if(!listOfInvoiceToUpdate.isEmpty())
                    update listOfInvoiceToUpdate;
            }
           // End 

            // increment the counter of noOfInvoicesGenerated, only if everything executes good
            /*
                    Modified By     : Laxman Rao M
                    Modified Date   : 11 June 2013
                    JIRA Task       : INVOICEIT-192
                    Comments        : Number of invoices processed is calculating wrong
                                                        Previosuly we were assigning the noOfInvoicesGenerated += map_Id_InvoiceClass.size(), their might be some invoices
                                                        which does not have a invoice line
             */
            // Laxman Rao M, INVOICEIT-261
            //totalInvoiceValue = 0;
           /* for (Id id : map_Id_InvoiceClass.keySet()) {
                //only those invoices where the lines are not empty should be inserted
                //this is done to prevent the 0 value invoices without invoice lines being inserted
                //this could happen due to usage records with the wrong next charge date
                if (map_Id_InvoiceClass.get(Id).invoiceLines.size() > 0) {
                    ++noOfInvoicesGenerated;

                    for (Invoice_Lines__c invoiceLine : map_Id_InvoiceClass.get(Id).invoiceLines) {
                        //Add up these values to be stored in the invoicerun record
                        totalInvoiceValue += invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c + invoiceLine.VAT__c + invoiceLine.Tax__c;
                    }
                }
            }

            //update the invoicerun record
            invoiceRun.Accounts_Processed__c = noOfAccountsProcessed;
            invoiceRun.Jobs_Processed__c = noOfJobsProcessed;
            invoiceRun.Invoices_Generated__c = noOfInvoicesGenerated;
            invoiceRun.CreditNotes_Generated__c = noOfCreditNotesGenerated;
            invoiceRun.Total_Invoice_Value__c = totalInvoiceValue;
            invoiceRun.Status__c = CommonUtilClass.STATUS_PROCESSING;

            // 272(Laxman Rao M)
            // If the control comes here means their is no exception till updating the order rate plan charges, so we need to clear the currentChargeDetails as null
            // their might be an exception while inserting the invoices or updating the usage charges, populate the error message saying "Exception occurred while updating the charges"

            update invoiceRun;

            // update the legal entites to new values
            if (!mapOfSequenceNumbersToUpdate.isEmpty()) {
                update mapOfSequenceNumbersToUpdate.Values();
            } */
            
            currentChargeDetails = null;
            currentChargeDetails = system.Label.ExceptionOccurredWhileUpdatingTheInvRun + ' ' + scope[0].Id;
        } catch (DMLException exDml) {
            //Ref : INVOICEIT-252, Modified by : Laxman Rao M
            // roll back the changes
            Database.rollback(sp);
            errorLog += '\n' + system.Label.ExceptionMessage + ':' + exDml.getTypeName() + ':' + exDml.getMessage() + ':' + exDml.getLineNumber() + ':' + exDml.getStackTraceString() + '\n';
            errorLog += ': ' + currentChargeDetails;
        } catch (Exception ex) {
            //Ref : INVOICEIT-252, Modified by : Laxman Rao M
            // roll back the changes
            Database.rollback(sp);
            errorLog += '\n' + system.Label.ExceptionMessage + ex.getTypeName() + ':' + ex.getMessage() + ':' + ex.getLineNumber() + ':' + ex.getStackTraceString() + '\n';
            errorLog += ': ' + currentChargeDetails;
        }
    }

    global void finish(Database.BatchableContext BC) {
        /*Amended on 28 Jun 2012 by Laxman(Jira -- INVOICEIT-56)*/
        if (automaticallyPostInvoices && !system.test.isRunningTest()) {
             // removed old code and executing with new batch
             string sQuery = 'SELECT Name,Tax_Engine__c,Order__c,Account__c,Invoice_Date__c,Amount__c FROM Invoice__c where Invoice_Run_Created_By__c =\'' +invoiceRun.Id + '\' And Invoice_Status__c = \'Draft\'';
             BatchForPostingInvoices  b = new BatchForPostingInvoices(sQuery);
             database.executebatch(b,1);
        }
        
        // Update the Invoice Generated and Total Invoice Line

        Integer invoiceCount = [SELECT Count() FROM Invoice__c WHERE Invoice_Run_Created_By__c =: invoiceRun.Id LIMIT 50000];
        AggregateResult totalInvoiceValue = [SELECT SUM(Total_Invoice_Value__c) sumoftotal FROM Invoice__c WHERE Invoice_Run_Created_By__c =: invoiceRun.Id];
        
        invoiceRun.Invoices_Generated__c = Integer.valueOf(invoiceCount);
        if(totalInvoiceValue != null)
            invoiceRun.Total_Invoice_Value__c = (decimal) totalInvoiceValue.get('sumoftotal');

        
        if (errorLog == null) {
            invoiceRun.Status__c = CommonUtilClass.STATUS_COMPLETED;
        } else {
            /*
                    Modified By : Laxman Rao M,
                    Reason : the maximum size of Long Text Area is 32768. If error log is more than this then create the attachment with error log
                    Ref : INVOICEIT-218
            */

            invoiceRun.Status__c = CommonUtilClass.STATUS_COMPLETED_WITH_ERRORS;

            // the maximum size of Long Text Area is 32768. If error log is more than this then create the attachment with error log
            if (errorLog.Length() < 32768) {
                invoiceRun.Exception_Log__c = errorLog;
            } else {
                Attachment attachment = new Attachment();
                attachment.Body = Blob.valueOf(errorLog);
                attachment.Name = 'ErrorLog.txt';
                attachment.ParentId = invoiceRun.Id;
                insert attachment;

                //invoiceRun.Exception_Log__c = 'Error log is attached as an attachment, you can find the attachment in releated list';
                //Added by Shruthi related to INVOICEIT-200
                invoiceRun.Exception_Log__c = system.Label.ErrorLogIsAttatchedAsAnAttachment;
            }
        }
        invoiceRun.Completed_Time__c = system.now();

        update invoiceRun;

        if (!mapOfSequenceNumbersToUpdate.isEmpty()) {
            update mapOfSequenceNumbersToUpdate.Values();
        }
    }
}