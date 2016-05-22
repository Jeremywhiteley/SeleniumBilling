public with sharing class InvoicingUtilClass {
                //====================Code start for Invoice Presentation================================//
                  public static String sPrefix = CommonUtilClass.getPrefix();
                  public static void insertInvoicesAndLines2(list<Invoice_Lines__c> invoiceLinesToInsert, 
                        list<Usage_Charge__c> listOfUsageChargesToUpdate, 
                        map<Id, Job_Rate_Plan_Charge__c> mapOfInvoiceGrouping, 
                        Invoice_Run__c invoiceRun, String currencyIsoCode,
                        Map<string, Payment_Terms__c> mapPaymentTerms,
                        SObject datedConversionRate) {
                    string BILLING_MASTER_ACCOUNT = 'Billing Master Account';
                    string PARTNER_ACCOUNT = 'Partner Account';
                    string ACCOUNT = 'Account';
                    string ORDER = 'Order';
                    string BILLING_CONTACT_ACCOUNT = 'Billing Account';

                    // PARTNER old is take to handle Chronical or old users who are using this picklist value
                    string PARTNER_ACCOUNT_OLD = 'Partner';

                    // Master old is take to handle KVH or old users who are using this picklist value (Need to add condition accordingly for KVH)
                    string BILLING_MASTER_ACCOUNT_OLD  = 'Master Order.Account';

                    set<Id> setOfAccountIds = new set<Id>();
                    set<Id> setOfOrderIds = new set<Id>();

                    // This will hold all the Invoices and Lines according to the grouping
                    map<Id, InvoiceClass> map_MasterAccountId_InvoiceClass = new map<Id, InvoiceClass>();
                    map<Id, InvoiceClass> map_PatnerAccountId_InvoiceClass = new map<Id, InvoiceClass>();
                    map<Id, InvoiceClass> map_AccountId_InvoiceClass = new map<Id, InvoiceClass>();
                    map<Id, InvoiceClass> map_orderAccountId_InvoiceClass = new map<Id, InvoiceClass>();
                    map<Id, InvoiceClass> map_billingContactAccountId_InvoiceClass = new map<Id, InvoiceClass>();

                    // This will hold all the Invoices and Lines which should be inserted or updated
                    map<string, Invoice__c> map_Id_Invoice = new map<string, Invoice__c>();
                    map<string, list<Invoice_Lines__c>> map_Id_Invoice_Lines = new map<string, list<Invoice_Lines__c>>();   
                    list<Invoice_Lines__c> listOfInvoiceLinesToCreate = new list<Invoice_Lines__c>();


                    // If the grouping field is mentioned then get the account/order Id value based on Invoice Grouping
                    // Based on the Id's segregate invoice & invoice lines
                    for(Job_Rate_Plan_Charge__c charge : mapOfInvoiceGrouping.Values()) {

                        if(charge.Invoice_Grouping__c == BILLING_CONTACT_ACCOUNT && charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Account__c != null) {
                            setOfAccountIds.add(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Account__c);
                        } else if((charge.Invoice_Grouping__c == BILLING_MASTER_ACCOUNT || charge.Invoice_Grouping__c == BILLING_MASTER_ACCOUNT_OLD) && charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Account__c != null) {    
                            setOfAccountIds.add(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Account__c); 
                        } else if((charge.Invoice_Grouping__c == PARTNER_ACCOUNT  || charge.Invoice_Grouping__c == PARTNER_ACCOUNT_OLD )&& charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Partner__c != null) {
                            setOfAccountIds.add(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Partner__c); 
                        } else if(charge.Invoice_Grouping__c == ACCOUNT) {
                            setOfAccountIds.add(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c); 
                        } else {
                            setOfAccountIds.add(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c);
                            setOfOrderIds.add(charge.Job_Rate_Plan__r.Job_Product__r.Job__c); 
                        }
                    }
                    // get all the existingInvs from the system which has been created in this run, so that will assign other lines to it
                    map<Id, Invoice__c> existingMasterInvs = new map<Id, Invoice__c>();
                    Map<Id, Invoice__c> map_OrderId_Invoice = new Map<Id, Invoice__c>();

                    for(Invoice__c invoice : [SELECT Account__c, Id, Invoice_Reference__c, Number_Of_Invoice_Lines__c,Order__c
                                              FROM Invoice__c
                                              WHERE 
                                              Account__c IN: setOfAccountIds
                                              AND
                                              Invoice_Run_Created_By__c =: invoiceRun.Id
                                              ]) 
                    {   
                        if(invoice.Order__c != null) {
                            map_OrderId_Invoice.put(invoice.Order__c, invoice); 
                            setOfOrderIds.add(invoice.Order__c); 
                        }
                        else {
                            existingMasterInvs.put(invoice.Account__c, invoice);    
                        }
                    }
                    boolean isInvoiceExists;
                    for(Invoice_Lines__c invoiceLine :  invoiceLinesToInsert) {

                        invoiceRun.Total_Invoice_Value__c += invoiceLine.Line_Amount__c - invoiceLine.Discount_Value__c + invoiceLine.VAT__c + invoiceLine.Tax__c;
                        // if the condition is true then it means charge is having grouping
                        if(mapOfInvoiceGrouping.containsKey(invoiceLine.Job_Rate_Plan_Charge__c)) {
                            Job_Rate_Plan_Charge__c charge = mapOfInvoiceGrouping.get(invoiceLine.Job_Rate_Plan_Charge__c);
                            // first check if any invoices are created in this batch, if yes pull it
                            // else check if there is any invoice in existing map

                            if( ((charge.Invoice_Grouping__c == BILLING_MASTER_ACCOUNT || charge.Invoice_Grouping__c == BILLING_MASTER_ACCOUNT_OLD) && existingMasterInvs.containsKey(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Account__c))
                                    || ((charge.Invoice_Grouping__c == PARTNER_ACCOUNT || charge.Invoice_Grouping__c == PARTNER_ACCOUNT_OLD) && existingMasterInvs.containsKey(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Partner__c))
                                    || (charge.Invoice_Grouping__c == ACCOUNT && existingMasterInvs.containsKey(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c))
                                    || (charge.Invoice_Grouping__c == BILLING_CONTACT_ACCOUNT && existingMasterInvs.containsKey(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Account__c)) 
                                    || ((charge.Invoice_Grouping__c == ORDER || charge.Invoice_Grouping__c == '' || charge.Invoice_Grouping__c == null) && map_OrderId_Invoice.containsKey(charge.Job_Rate_Plan__r.Job_Product__r.Job__c))) {
                                isInvoiceExists = true;
                            } else {
                                // invoice is not present
                                isInvoiceExists = false;
                            }

                            if(charge.Invoice_Grouping__c == BILLING_CONTACT_ACCOUNT && charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Account__c != null) {
                                map_billingContactAccountId_InvoiceClass = populateInvoiceMap(existingMasterInvs, invoiceLine, map_billingContactAccountId_InvoiceClass, charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Account__c, charge, isInvoiceExists, invoiceRun, charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Account__r.Payment_Terms__c, charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Account__r.Invoice_Delivery_Type__c, mapPaymentTerms, datedConversionRate, currencyIsoCode);
                            } else if((charge.Invoice_Grouping__c == BILLING_MASTER_ACCOUNT || charge.Invoice_Grouping__c == BILLING_MASTER_ACCOUNT_OLD)  && charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Account__c != null) {
                                map_MasterAccountId_InvoiceClass = populateInvoiceMap(existingMasterInvs, invoiceLine, map_MasterAccountId_InvoiceClass, charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Account__c, charge, isInvoiceExists, invoiceRun, charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Account__r.Payment_Terms__c, charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Account__r.Invoice_Delivery_Type__c, mapPaymentTerms, datedConversionRate, currencyIsoCode);
                            } else if((charge.Invoice_Grouping__c == PARTNER_ACCOUNT || charge.Invoice_Grouping__c == PARTNER_ACCOUNT_OLD) && charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Partner__c  != null) {
                                map_PatnerAccountId_InvoiceClass = populateInvoiceMap(existingMasterInvs, invoiceLine, map_PatnerAccountId_InvoiceClass, charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Partner__c, charge, isInvoiceExists, invoiceRun, charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Partner__r.Payment_Terms__c, charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Partner__r.Invoice_Delivery_Type__c, mapPaymentTerms, datedConversionRate, currencyIsoCode);    
                            } else if(charge.Invoice_Grouping__c == ACCOUNT) {
                                map_AccountId_InvoiceClass = populateInvoiceMap(existingMasterInvs, invoiceLine, map_AccountId_InvoiceClass, charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c, charge, isInvoiceExists, invoiceRun, charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Payment_Terms__c, charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Invoice_Delivery_Type__c, mapPaymentTerms, datedConversionRate, currencyIsoCode);    
                            } else {
                                // We dont have delivery type on order need to discuss with manoj
                                map_orderAccountId_InvoiceClass = populateInvoiceMap(map_OrderId_Invoice, invoiceLine, map_orderAccountId_InvoiceClass, charge.Job_Rate_Plan__r.Job_Product__r.Job__c, charge, isInvoiceExists, invoiceRun, charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Payment_Terms__c, charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Invoice_Delivery_Type__c, mapPaymentTerms, datedConversionRate, currencyIsoCode); 
                            }
                        }   
                    }            

                    //Now that we have the invoices to create, we need to populate the invoice sequence numbers based on legal entities
                    //Get the field names that hold the legal entities in both Order object and Account object
                    String sOrderLegalEntity = Configuration__c.getValues('ORDER_LEGAL_ENTITY_FIELD_NAME').String_Value__c;
                    String sAccountLegalEntity = Configuration__c.getValues('ACCOUNT_LEGAL_ENTITY_FIELD_NAME').String_Value__c;
                    Map<String, Sequence_Number__c> mapOfSequenceNumbersToUpdate = Sequence_Number__c.getAll().deepClone();
                    Map<Id, SObject> map_Id_OrderSobject = new Map<Id, SObject>();
                    Map<Id, SObject> map_Id_AccountSobject = new Map<Id, SObject>();

                    if (sOrderLegalEntity != null && !setOfOrderIds.isEmpty()) {
                        map_Id_OrderSobject = InvoicingUtilClass.getSobjects(setOfOrderIds, 'Job__c');
                    }
                    if (sAccountLegalEntity != null && !setOfAccountIds.isEmpty()) {
                        map_Id_AccountSobject = InvoicingUtilClass.getSobjects(setOfAccountIds, 'Account');
                    }

                    // Here we populate legal entites and validate the Invoice and Invoice Lines

                    validateInvoiceandInvoiceLines(map_billingContactAccountId_InvoiceClass, map_Id_Invoice, map_Id_Invoice_Lines, sOrderLegalEntity, sAccountLegalEntity, map_Id_OrderSobject, map_Id_AccountSobject, mapOfSequenceNumbersToUpdate);
                    validateInvoiceandInvoiceLines(map_MasterAccountId_InvoiceClass, map_Id_Invoice, map_Id_Invoice_Lines, sOrderLegalEntity, sAccountLegalEntity, map_Id_OrderSobject, map_Id_AccountSobject, mapOfSequenceNumbersToUpdate);
                    validateInvoiceandInvoiceLines(map_PatnerAccountId_InvoiceClass, map_Id_Invoice, map_Id_Invoice_Lines, sOrderLegalEntity, sAccountLegalEntity, map_Id_OrderSobject, map_Id_AccountSobject, mapOfSequenceNumbersToUpdate);
                    validateInvoiceandInvoiceLines(map_AccountId_InvoiceClass, map_Id_Invoice, map_Id_Invoice_Lines, sOrderLegalEntity, sAccountLegalEntity, map_Id_OrderSobject, map_Id_AccountSobject, mapOfSequenceNumbersToUpdate);
                    validateInvoiceandInvoiceLines(map_orderAccountId_InvoiceClass, map_Id_Invoice, map_Id_Invoice_Lines, sOrderLegalEntity, sAccountLegalEntity, map_Id_OrderSobject, map_Id_AccountSobject, mapOfSequenceNumbersToUpdate);
                    

                    //update the legal entites to new values
                    if (!mapOfSequenceNumbersToUpdate.isEmpty()) {
                        update mapOfSequenceNumbersToUpdate.Values();
                    }

                    //Insert the invoices first
                    upsert map_Id_Invoice.values();

                    //Now the id is common between the invoices and the invoice lines
                    //Match them and update the invoices lines with the invoice ids

                    Invoice__c invoiceReference;
                    for (Id id : map_Id_Invoice_Lines.keySet()) {
                        invoiceReference = ((Invoice__c)map_Id_Invoice.get(id));
                        Integer sequenceNumber = 0;
                        // get the number of invoice lines created so that the sequence number will populate correctly
                        if(invoiceReference.Number_Of_Invoice_Lines__c != null)
                            sequenceNumber = (Integer) invoiceReference.Number_Of_Invoice_Lines__c;
                        List<Invoice_Lines__c> tempListOfInvoiceLines = map_Id_Invoice_Lines.get(id);
                        for (Invoice_Lines__c invoiceLine : tempListOfInvoiceLines) {
                            invoiceLine.Invoice__c = invoiceReference.Id;
                            sequenceNumber++;
                            invoiceLine.Sequence_No__c = sequenceNumber;
                        }
                        listOfInvoiceLinesToCreate.addAll(tempListOfInvoiceLines);
                    }

                    //Insert the invoice lines
                    insert listOfInvoiceLinesToCreate;

                    //Now that the invoice lines have been inserted, we need to update the invoice and invoice line fields on the usage charges records
                    //This is done to ensure we can record against which invoice lines the usage charges have been billed
                    //The only linking factor between usage charges and the invoice lines is the OrderRateplanChargeId. We need to match then 

                    //Put the invoice lines into a map where the key is orderchargeid
                    map<Id, Invoice_Lines__c> map_OrderChargeId_InvoiceLine = new map<Id, Invoice_Lines__c>();

                    for(Invoice_Lines__c invoiceLine : listOfInvoiceLinesToCreate){
                        map_OrderChargeId_InvoiceLine.put(invoiceLine.Job_Rate_Plan_Charge__c, invoiceLine);            
                    }


                    //Now that we have the order charges, we can match them against the usagerecords
                    for(Usage_Charge__c usageCharge : listOfUsageChargesToUpdate){
                        //some times the usage charge quantity is zero(0), at that point of time their will be no invoice & invoice line created,it will throw a null pointer exception
                        if(map_OrderChargeId_InvoiceLine.containsKey(usageCharge.Order_Rate_Plan_Charge__c)) {
                            Invoice_Lines__c matchingInvoiceLine = map_OrderChargeId_InvoiceLine.get(usageCharge.Order_Rate_Plan_Charge__c);
                            usageCharge.Invoice_Line__c = matchingInvoiceLine.Id;
                            usageCharge.Invoice__c = matchingInvoiceLine.Invoice__c;
                        }
                        //Also update the status to billed
                        usageCharge.Status__c = CommonUtilClass.STATUS_BILLED;
                    }

                    update listOfUsageChargesToUpdate;
                }   


                public static void validateInvoiceandInvoiceLines( map<Id, InvoiceClass> map_Id_InvoiceClass, 
                        map<string, Invoice__c>  map_Id_Invoice, 
                        map<string, list<Invoice_Lines__c>> map_Id_Invoice_Lines,
                        String  sOrderLegalEntity, String sAccountLegalEntity, 
                        Map<Id, SObject> map_Id_OrderSobject, Map<Id, SObject> map_Id_AccountSobject, 
                        Map<String, Sequence_Number__c> mapOfSequenceNumbersToUpdate) {

                    //only those invoices where the lines are not empty should be inserted
                    //this is done to prevent the 0 value invoices without invoice lines being inserted
                    //this could happen due to usage records with the wrong next charge date     
                    Invoice__c invoice;
                    sobject sObjectBasedOnGroupBy = null;
                    String invoiceNumber = '';

                    for(string id : map_Id_InvoiceClass.keySet()){ 
                        if(map_Id_InvoiceClass.get(id).invoiceLines.size() > 0){                

                            invoice = map_Id_InvoiceClass.get(id).invoice;
                            sObjectBasedOnGroupBy = null;

                            if(invoice.Invoice_Reference__c == null) {  
                                String legalEntityName;

                                if(sOrderLegalEntity != null && invoice.Order__c != null && map_Id_OrderSobject.containsKey(invoice.Order__c)) {
                                    sObjectBasedOnGroupBy = map_Id_OrderSobject.get(invoice.Order__c);
                                    legalEntityName = (string) sObjectBasedOnGroupBy.get(sOrderLegalEntity);
                                } else if(sAccountLegalEntity != null && map_Id_AccountSobject.containsKey(invoice.Account__c)) {
                                    sObjectBasedOnGroupBy = map_Id_AccountSobject.get(invoice.Account__c);
                                    legalEntityName = (string) sObjectBasedOnGroupBy.get(sAccountLegalEntity);
                                }

                                if (legalEntityName != null && mapOfSequenceNumbersToUpdate.containsKey(legalEntityName)) {
                                    Sequence_Number__c sequenceNumber = mapOfSequenceNumbersToUpdate.get(legalEntityName);
                                    // enter only if the next invoice next number is not null
                                    invoiceNumber = '';
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


                            map_Id_Invoice.put(id, invoice);
                            map_Id_Invoice_Lines.put(id, map_Id_InvoiceClass.get(id).invoiceLines);             

                        }
                    }

                }

                public static map<Id, InvoiceClass> populateInvoiceMap(map<Id, Invoice__c> existingMasterInvs, 
                        Invoice_Lines__c invoiceLine, 
                        map<Id, InvoiceClass> map_Id_InvoiceClass, 
                        string key, Job_Rate_Plan_Charge__c charge, 
                        boolean invoiceExist, Invoice_Run__c invoiceRun,
                        String sPaymentTerms, String sDeliveryType,
                        Map<string, Payment_Terms__c> mapPaymentTerms,
                        SObject datedConversionRate,
                        String currencyIsoCode) {

                    InvoiceClass invClass = new InvoiceClass();
                    Integer noOfDaysToDueDate = 0;

                    if(map_Id_InvoiceClass.containsKey(key)) {
                        // Get the existing invoice which is not created
                        invClass = map_Id_InvoiceClass.get(key); 
                    } else if (!invoiceExist) {
                        // Create the invoice which is not created
                        Invoice__c masterInvoice = new Invoice__c();

                        if(charge.Invoice_Grouping__c != 'Order' && charge.Invoice_Grouping__c != '' && charge.Invoice_Grouping__c != null) {
                            masterInvoice.Account__c = key;
                            invoiceRun.Accounts_Processed__c = invoiceRun.Accounts_Processed__c + 1;
                        } else {
                            masterInvoice.Account__c = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c;
                            masterInvoice.Order__c = key;
                            invoiceRun.Jobs_Processed__c = invoiceRun.Jobs_Processed__c + 1;
                        }    
                        masterInvoice.Tax_Engine__c = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Tax_Engine__c;
                        masterInvoice.Invoice_Run_Created_By__c = invoiceRun.Id;
                        masterInvoice.Billing_Contact__c = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Contact__c;
                        masterInvoice.Shipping_Contact__c = charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Shipping_Contact__c;
                        masterInvoice.CurrencyL__c = charge.CurrencyL__c;
                        masterInvoice.Invoice_Date__c = invoiceRun.Invoice_Date__c;
                        masterInvoice.Delivery_Type__c = sDeliveryType;
                        masterInvoice.Invoice_Status__c = CommonUtilClass.STATUS_DRAFT;
                        masterInvoice.Target_Date__c = invoiceRun.Target_Run_Date__c;

                        //Apply the exchange rate if this is a multicurrency org
                        if (UserInfo.isMultiCurrencyOrganization()) {
                            if (datedConversionRate != null) {
                                sobject sobjectInvoice = (sobject)masterInvoice;
                                sobjectInvoice.put(sPrefix+'Exchange_Rate_Applied__c', (decimal) datedConversionRate.get('ConversionRate'));
                                sobjectInvoice.put('CurrencyIsoCode', (string) currencyIsoCode);
                                masterInvoice = (Invoice__c) sobjectInvoice;
                            } else {
                                masterInvoice.Exchange_Rate_Applied__c = 1;
                            }
                        }

                        // Here we are assigning payment terms
                        if (sPaymentTerms != null) {
                            noOfDaysToDueDate = (integer) mapPaymentTerms.get(sPaymentTerms).Number_Of_Days__c;
                        }
                        masterInvoice.Due_Date__c = masterInvoice.Invoice_Date__c.addDays(noOfDaysToDueDate);
                        invClass.invoice = masterInvoice; 
                        invoiceRun.Invoices_Generated__c = invoiceRun.Invoices_Generated__c + 1;             
                    } else {
                        // Get the old invoice which is created in the system
                        Invoice__c masterInvoice = existingMasterInvs.get(key);
                        invClass.invoice = masterInvoice;
                    }

                    invClass.invoiceLines.add(invoiceLine);
                    map_Id_InvoiceClass.put(key, invClass); 
                    return map_Id_InvoiceClass;
                }    
                
                public static void updateOrderChargesBillingGroup(Job__c order, Date targetDate) {

                    //Ref : INVOICEIT-556, Modified by : Dev M
                    // Added for consortium billing 
                    // need to modified this query to handle the cancelled charges which are expired  
                    // limiting based on currency: Added by Dev M 
                    list<Job__c> listofJob = [SELECT Id FROM Job__c WHERE Id =: order.Billing_Master_Order__c OR Billing_Master_Order__c =: order.Billing_Master_Order__c];

                    AggregateResult[] results = [SELECT Sum(Quantity__c) Quantity, Billing_Master_Order_Rate_Plan_Charge__c MasterChargeId
                                                    FROM Job_Rate_Plan_Charge__c
                                                    WHERE Service_Activation_Date__c <= :targetDate
                                                    AND (Service_End_Date__c > :targetDate OR Service_End_Date__c = NULL)
                                                    AND Billing_Master_Order_Rate_Plan_Charge__c != NULL
                                                    AND Job_Rate_Plan__r.Job_Product__r.Job__r.CurrencyL__c = : order.CurrencyL__c
                                                    AND Job_Rate_Plan__r.Job_Product__r.Job__c in: listofJob
                                                    GROUP BY Billing_Master_Order_Rate_Plan_Charge__c];

                    list<Job_Rate_Plan_Charge__c> listOfOrderChargesBillingGroup = new list<Job_Rate_Plan_Charge__c>();

                    for(AggregateResult result : results)
                    {
                        Job_Rate_Plan_Charge__c charge = new Job_Rate_Plan_Charge__c(Id = (Id)result.get('MasterChargeId'));
                        charge.Billing_Master_Grouped_Quantity__c = ((Decimal)result.get('Quantity'));

                        listOfOrderChargesBillingGroup.add(charge);
                    }
                     update listOfOrderChargesBillingGroup;
                }

                public static List<Job_Rate_Plan_Charge__c> getJobProductRatePlanCharges(List<Id> jobIds) {
                    List<Job_Rate_Plan_Charge__c>   jobRatePlanChgs = new List<Job_Rate_Plan_Charge__c>() ; 

                    String idStringQuery = CommonUtilClass.convertListOfIdsIntoString(jobIds);
                    String query = 'SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Job_Rate_Plan_Charge__c');
                    query += ',Job_Rate_Plan__r.Job_Product__r.Product__c';
                    query += ',Job_Rate_Plan__r.Job_Product__r.Name';
                    query += ',Job_Rate_Plan__r.Job_Product__r.Job__c';
                    query += ',Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c';
                    query += ',Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Invoice_Delivery_Type__c';
                    query += ',Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Contact__c';
                    query += ',Job_Rate_Plan__r.Job_Product__r.Job__r.Shipping_Contact__c';
                    query += ',Job_Rate_Plan__r.Job_Product__r.Job__r.CurrencyL__c';
                    query += ',Billing_Master_Order_Rate_Plan_Charge__r.Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Order__c';
                    query += ',Billing_Master_Order_Rate_Plan_Charge__r.Job_Rate_Plan__r.Job_Product__r.Job__r.Is_Billing_Master_Order__c';
                    query += ',Job_Rate_Plan__r.Job_Product__r.Job__r.Billing_Master_Order__c';
                    query += ',Billing_Master_Order_Rate_Plan_Charge__r.Billing_Master_Grouped_Quantity__c';
                    query += ' FROM  Job_Rate_Plan_Charge__c';
                    query += ' where Job_Rate_Plan__r.Job_Product__r.Job__c in ('+idStringQuery+')';
                    query += ' Order by Job_Rate_Plan__r.Job_Product__r.SequenceNumber__c,Sequence_No__c,Job_Rate_Plan__r.SequenceNumber__c';

                    jobRatePlanChgs = database.query(query);     
                    return jobRatePlanChgs;
                }

                public static void insertInvoicesAndLines(map<Id, InvoiceClass> map_Id_InvoiceClass, list<Usage_Charge__c> listOfUsageChargesToUpdate) {
                    map<Id, Invoice__c> map_Id_Invoice = new map<Id, Invoice__c>();
                    map<Id, list<Invoice_Lines__c>> map_Id_Invoice_Lines = new map<Id, list<Invoice_Lines__c>>();
                    list<Invoice_Lines__c> listOfInvoiceLinesToCreate = new list<Invoice_Lines__c>();
                    Set<Id> keys = map_Id_InvoiceClass.keySet(); 
                    
                    for(Id id : keys){
                        //only those invoices where the lines are not empty should be inserted
                        //this is done to prevent the 0 value invoices without invoice lines being inserted
                        //this could happen due to usage records with the wrong next charge date 
                        if(map_Id_InvoiceClass.get(id).invoiceLines.size() > 0){
                            map_Id_Invoice.put(id, map_Id_InvoiceClass.get(id).invoice);
                            map_Id_Invoice_Lines.put(id, map_Id_InvoiceClass.get(id).invoiceLines);             
                        }
                    }
     
                    //Insert the invoices first
                    insert map_Id_Invoice.values();

                    //Now the id is common between the invoices and the invoice lines
                    //Match them and update the invoices lines with the invoice ids

                    for(Id id : map_Id_Invoice_Lines.keySet()){
                        Id invoiceId = ((Invoice__c)map_Id_Invoice.get(id)).Id;
                        Integer sequenceNumber = 0;
                        list<Invoice_Lines__c> tempListOfInvoiceLines = map_Id_Invoice_Lines.get(id);
                        for(Invoice_Lines__c invoiceLine : tempListOfInvoiceLines){
                            invoiceLine.Invoice__c = invoiceId;
                            sequenceNumber++;
                            invoiceLine.Sequence_No__c = sequenceNumber; 
                        }
                        listOfInvoiceLinesToCreate.addAll(tempListOfInvoiceLines);
                    }

                    //Insert the invoice lines
                    insert listOfInvoiceLinesToCreate;
                    
                    //Now that the invoice lines have been inserted, we need to update the invoice and invoice line fields on the usage charges records
                    //This is done to ensure we can record against which invoice lines the usage charges have been billed
                    //The only linking factor between usage charges and the invoice lines is the OrderRateplanChargeId. We need to match then 
                    
                    //Put the invoice lines into a map where the key is orderchargeid
                    map<Id, Invoice_Lines__c> map_OrderChargeId_InvoiceLine = new map<Id, Invoice_Lines__c>();
                    
                    for(Invoice_Lines__c invoiceLine : listOfInvoiceLinesToCreate){
                        map_OrderChargeId_InvoiceLine.put(invoiceLine.Job_Rate_Plan_Charge__c, invoiceLine);            
                    }
                    
                    /*
                        Modified By         : Laxman Rao M   :11 June 2013 :  INVOICEIT-199
                        Comments        : Some times the usage charge quantity is zero(0), at that point of time their will be no invoice & invoice line created(because we are creating the invoice line if the quantity is > 0),it will throw a null pointer exception
                                          
                    */
                    //Now that we have the order charges, we can match them against the usagerecords
                    for(Usage_Charge__c usageCharge : listOfUsageChargesToUpdate){
                        //some times the usage charge quantity is zero(0), at that point of time their will be no invoice & invoice line created,it will throw a null pointer exception
                        if(map_OrderChargeId_InvoiceLine.containsKey(usageCharge.Order_Rate_Plan_Charge__c)) {
                            Invoice_Lines__c matchingInvoiceLine = map_OrderChargeId_InvoiceLine.get(usageCharge.Order_Rate_Plan_Charge__c);
                            usageCharge.Invoice_Line__c = matchingInvoiceLine.Id;
                            usageCharge.Invoice__c = matchingInvoiceLine.Invoice__c;
                        }
                        //Also update the status to billed
                        usageCharge.Status__c = CommonUtilClass.STATUS_BILLED;
                    }
                    
                    update listOfUsageChargesToUpdate;
                }
                
                public static void populateExchangeRateOnInvoice(Invoice__c invoice, string isoCode) {
                    sobject datedConversionRate = CommonUtilClass.getExchangeRateByDate(invoice.Invoice_Date__c, isoCode);
                    
                    if(datedConversionRate != null) {
                        sobject sobjectInvoice = (sobject)invoice;
                        sobjectInvoice.put(sPrefix+'Exchange_Rate_Applied__c',(decimal) datedConversionRate.get('ConversionRate'));
                        sobjectInvoice.put('CurrencyIsoCode',(string) isoCode);
                        invoice = (Invoice__c) sobjectInvoice;
                    } else {
                        invoice.Exchange_Rate_Applied__c = 1;
                    }   
                }
                
                //This is used for the TCV calculation
                public static decimal calculateLineAmount(Job_Rate_Plan_Charge__c charge, Date startDate, Date endDate) {
                    //If the charge start and end dates are present use that, else use the order start and end dates
                    //Else use the dates supplied
                    if(charge.Service_Activation_Date__c != null){
                        startDate = charge.Service_Activation_Date__c;
                    }
                    if(charge.Service_End_Date__c != null){
                        endDate = charge.Service_End_Date__c;
                    }
                    
                    if(startDate == null || endDate == null){
                        return 0;
                    }
                    //assuming startDate & endDate are not equal to null
                    decimal noOfMonths = startDate.monthsBetween(endDate);
                    
                    if(charge.Price_Type__c == system.Label.OptionOneTime) {
                        return (charge.Unit_Price__c * charge.Quantity__c);
                    } else if(charge.Price_Type__c == system.Label.OptionWeekly) {
                        decimal noOfDays = startDate.daysBetween(endDate); 
                        decimal noOfWeeks = noOfDays.Divide(7,3,System.RoundingMode.UP);
                        return (noOfWeeks * charge.Unit_Price__c * charge.Quantity__c);
                    } else if(charge.Price_Type__c == system.Label.OptionMonthly) {
                        return (noOfMonths * charge.Unit_Price__c * charge.Quantity__c);
                    } else if(charge.Price_Type__c == system.Label.OptionQuarterly) {
                        decimal noOfQuarters = noOfMonths.Divide(3,3,System.RoundingMode.UP);
                        return (noOfQuarters * charge.Unit_Price__c * charge.Quantity__c);
                    } else if(charge.Price_Type__c == system.Label.OptionHalfYearly) {
                        decimal noOfHalfYears = noOfMonths.Divide(6,3,System.RoundingMode.UP);
                        return (noOfHalfYears * charge.Unit_Price__c * charge.Quantity__c);
                    } else if(charge.Price_Type__c == system.Label.OptionAnnual) {
                        decimal noOfAnnualYears = noOfMonths.Divide(12,3,System.RoundingMode.UP);
                        return (noOfAnnualYears * charge.Unit_Price__c * charge.Quantity__c);
                    }
                    
                    return 0;
                }

                //This is used for the TCV calculation
                public static decimal calculateQuoteLineAmount(Quote_Rate_Plan_Charge__c charge, decimal noOfMonths) {
                    if(charge.Price_Type__c == system.Label.OptionOneTime) {
                        return (charge.Unit_Price__c * charge.Quantity__c);
                    } else if(charge.Price_Type__c == system.Label.OptionWeekly) {
                        decimal noOfDays = noOfMonths * 30.42; 
                        decimal noOfWeeks = noOfDays.Divide(7,3,System.RoundingMode.UP);
                        return (noOfWeeks * charge.Unit_Price__c * charge.Quantity__c);
                    } else if(charge.Price_Type__c == system.Label.OptionMonthly) {
                        return (noOfMonths * charge.Unit_Price__c * charge.Quantity__c);
                    } else if(charge.Price_Type__c == system.Label.OptionQuarterly) {
                        decimal noOfQuarters = noOfMonths.Divide(3,3,System.RoundingMode.UP);
                        return (noOfQuarters * charge.Unit_Price__c * charge.Quantity__c);
                    } else if(charge.Price_Type__c == system.Label.OptionHalfYearly) {
                        decimal noOfHalfYears = noOfMonths.Divide(6,3,System.RoundingMode.UP);
                        return (noOfHalfYears * charge.Unit_Price__c * charge.Quantity__c);
                    } else if(charge.Price_Type__c == system.Label.OptionAnnual) {
                        decimal noOfAnnualYears = noOfMonths.Divide(12,3,System.RoundingMode.UP);
                        return (noOfAnnualYears * charge.Unit_Price__c * charge.Quantity__c);
                    }
                    
                    return 0;
                }
            
                // Included more fields in this query for the Jira Task - 125
                // Below query modified by Siri:INVOICEIT-678
                public static list<Invoice__c> getInvoiceByName(string invoiceName) {
                    list<Invoice__c> listOfInvoices = [SELECT Account__c, Name, Total_Invoice_Value__c, Unpaid_Amount__c, CurrencyL__c, 
                                                       Account__r.Gateway__c, CurrencyL__r.Name, Payment_Request_Amount__c, Invoice_Reference__c,
                                                       Account__r.VAT_No__c, Account__r.Name, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState , Account__r.BillingCountry, Account__r.BillingPostalCode,
                                                       Account__r.ShippingStreet, Account__r.ShippingCity, Account__r.ShippingCountry, Account__r.ShippingState,Account__r.ShippingPostalCode,
                                                       Billing_Contact__r.Name, Billing_Contact__r.MailingStreet, Billing_Contact__r.MailingCity, Billing_Contact__r.MailingState , Billing_Contact__r.MailingCountry, Billing_Contact__r.MailingPostalCode, Billing_Contact__r.Salutation,
                                                       Billing_Contact__r.FirstName, Billing_Contact__r.LastName,Order__r.Name,Invoice_Status__c, Invoice_State__c,
                                                       Shipping_Contact__r.FirstName, Shipping_Contact__r.LastName, Shipping_Contact__r.Account.Name, Shipping_Contact__r.MailingStreet,
                                                       Shipping_Contact__r.MailingCity, Shipping_Contact__r.MailingState, Shipping_Contact__r.MailingPostalCode, Shipping_Contact__r.MailingCountry,
                                                       (
                                                         SELECT Name, Gateway_ID__c, Amount__c
                                                         FROM Transactions__r 
                                                         WHERE (Gateway_ID__c != null 
                                                         AND Response_Status__c =: CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED 
                                                         AND (
                                                                Type__c =: CommonUtilClass.TRANSACTION_TYPE_AUTHORIZATION 
                                                                OR Type__c =: CommonUtilClass.TRANSACTION_TYPE_CHARGE)
                                                             )
                                                       )
                                                       FROM Invoice__c
                                                       WHERE Name =: invoiceName];
                                          
                    return listOfInvoices;                    
                }
                
                // Included more fields in this query for the Jira Task - 125
                public static Invoice__c getInvoiceById(Id invoiceId) {
                    Invoice__c invoice = [SELECT Account__c, Name, Total_Invoice_Value__c, Unpaid_Amount__c,Payment_Status__c,  
                                          CurrencyL__c, CurrencyL__r.Name, CurrencyL__r.Currency_Symbol__c,Invoice_Reference__c,Invoice_Date__c,
                                          Account__r.Gateway__c, Account__r.VAT_No__c, Account__r.Name, Account__r.BillingStreet, Account__r.BillingCity, Account__r.BillingState , Account__r.BillingCountry, Account__r.BillingPostalCode,
                                          Account__r.ShippingStreet, Account__r.ShippingCity, Account__r.ShippingCountry, Account__r.ShippingState,Account__r.ShippingPostalCode,
                                          Billing_Contact__r.Name, Billing_Contact__r.MailingStreet, Billing_Contact__r.MailingCity, Billing_Contact__r.MailingState , Billing_Contact__r.MailingCountry, Billing_Contact__r.MailingPostalCode, Billing_Contact__r.Salutation,
                                          Billing_Contact__r.FirstName, Billing_Contact__r.LastName,Order__r.Name,Invoice_Status__c, Payment_Request_Amount__c,Invoice_State__c,
                                          Shipping_Contact__r.FirstName, Shipping_Contact__r.LastName, Shipping_Contact__r.Account.Name, Shipping_Contact__r.MailingStreet,
                                          Shipping_Contact__r.MailingCity, Shipping_Contact__r.MailingState, Shipping_Contact__r.MailingPostalCode, Shipping_Contact__r.MailingCountry,Shipping_Contact__r.Phone,Order__r.Payment_Plan__c,
                                          (
                                            SELECT Name, Gateway_ID__c, Amount__c
                                            FROM Transactions__r 
                                            WHERE (Gateway_ID__c != null 
                                            AND Response_Status__c =: CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED 
                                            AND (
                                                    Type__c =: CommonUtilClass.TRANSACTION_TYPE_AUTHORIZATION 
                                                    OR Type__c =: CommonUtilClass.TRANSACTION_TYPE_CHARGE)
                                                )
                                          )
                                          FROM Invoice__c
                                          WHERE Id =: invoiceId];
                                          
                    return invoice;                   
                } 
                
                public static Gateway__c getGateway(Id gatewayId) {
                    Gateway__c gateway = [SELECT Name, Merchant_Reference__c, Transaction_Security_Key__c, Exact_ID_Security_Key__c, Exact_ID__c, Gateway_Type__c, Merchant_ID__c, Security_Key__c, Test_Mode__c, Merchant_Seal_User_Id__c,Email_Customer__c
                                          FROM Gateway__c
                                          WHERE Id =: gatewayId];
                    return gateway;                   
                }
                
                public static Transaction__c getTransaction(Id transactionId) {
                    Transaction__c transactionObj = [SELECT Name, Gateway_ID__c, Response_Status__c, Type__c, Amount__c,
                                                     Payment_Method__r.Card_Number__c, Payment_Method__r.Card_Type__c, Payment_Method__r.Card_Expiration_Month__c, Payment_Method__r.Card_Expiration_Year__c, Payment_Method__r.CVV__c, Payment_Method__r.Name_on_Card__c, Payment_Method__c
                                                     ,Payment_Method__r.Account__r.Gateway__c, Request_Invoice__c, Payment_Gateway__c
                                                     FROM Transaction__c
                                                     WHERE Id =: transactionId];
                                                     
                    return transactionObj;                               
                }
                
                public static list<Gateway__c> getDefaultGateway() {
                   list<Gateway__c> listOfGateway = [SELECT Name, Merchant_Reference__c, Transaction_Security_Key__c, Exact_ID_Security_Key__c, Exact_ID__c, Gateway_Type__c, Merchant_ID__c, Security_Key__c, Test_Mode__c, Merchant_Seal_User_Id__c,Email_Customer__c
                                                     FROM Gateway__c
                                                     WHERE Active__c = true
                                                     AND
                                                     Default__c = true];
                                                     
                    return listOfGateway;                             
                }
                
                public static PaymentOperations.PaymentResult sendResponse(string message, boolean isReload) {
                    PaymentOperations.PaymentResult result = new PaymentOperations.PaymentResult();
                    result.message = message;
                    result.reloadPage = isReload; 
                    
                    return result;
                }
                
                public static string getHTTPResponse(string sHttpEndPoint, string sHttpBody) {
                    Http httpObject = new Http();
                    HttpResponse httpResponse;
                    HttpRequest httpRequest = new HttpRequest();
                    httpRequest.setEndpoint(sHttpEndPoint);
                    httpRequest.setMethod('POST');
                     /*
                        Modified By             : Rama Krishna  :19 august 2014  :SUP-312
                        Comments             : exending the callout time to max
                      */
                    httpRequest.setTimeout(120000);
                    httpRequest.setBody(sHttpBody);
                    
                    if(!system.test.isRunningTest()) {
                        httpResponse = httpObject.send(httpRequest);
                    } else {
                        if(sHttpEndPoint == CommonUtilClass.ENDPOINT_AUTHORIZEDOTNET_TEST || sHttpEndPoint == CommonUtilClass.ENDPOINT_AUTHORIZEDOTNET_LIVE) {
                            return '1|1|1|This transaction has been approved.|YUJNGH|Y|2160295577||0|600.00|CC|auth_capture||sandeep|b||dfsdf||wa|5555||||||||||||||||||71AFA2003D02930E47E84F23E14E07C3|P|2|||||||||||XXXX1111|Visa|||||||||||||||||false|1';
                        } else if(sHttpEndPoint == CommonUtilClass.ENDPOINT_PAYFLOWPRO_TEST || sHttpEndPoint == CommonUtilClass.ENDPOINT_PAYFLOWPRO_LIVE) {
                            return 'RESULT=0&PNREF=V35A1F9ECC2E&RESPMSG=Verified&AUTHCODE=018PNI&CVV2MATCH=N';
                        }
                    }
                    return httpResponse.getBody(); 
                }
                
                public static list<Payment_Method__c> getDummyPaymentMethodForAccount(string sAccountId) {
                    return [SELECT Id 
                            FROM Payment_Method__c
                            WHERE Account__c =: sAccountId
                            AND
                            Active__c = false
                            AND
                            Is_Dummy__c = true
                            ];
                }
                
                // Included more fields in this query for the Jira Task - 125
                public static list<Payment_Method__c> getDefaultMethodForAccount(string sAccountId) {
                    return [SELECT Card_Number__c, Card_Type__c, Payment_Method__c, Card_Expiration_Month__c, Card_Expiration_Year__c, CVV__c, Name_on_Card__c, Billing_Country__c,
                            Bank_Routing_Code__c, Bank_Account_Number__c, Bank_Account_Type__c, Bank_Name__c, Bank_Account_Name__c,
                            Billing_First_Name__c, Billing_Last_Name__c, Billing_Address__c, Billing_City__c, Billing_State_Province__c, Billing_Zip_Postal__c ,
                            Account__c, Account__r.Name, Billing_Phone__c, Billing_Fax__c, Billing_Email__c,Account__r.Customer_Profile_ID__c,Payment_Profile_ID__c,
                            Encrypted_CVV__c,Encrypted_Card_Number__c,Token__c 
                            FROM Payment_Method__c
                            WHERE Account__c =: sAccountId
                            AND 
                            Active__c = true
                            AND 
                            Default__c = true
                            LIMIT 1
                            ];
                } 
                
                public static Account getAccountById(Id accountId) {
                    String sQuery = CommonUtilClass.getObjectSelectQuery('Account');
                    sQuery = sQuery + ' WHERE Id =\'' + String.escapeSingleQuotes(accountId) + '\'';
                    return Database.query(sQuery);
                }
                
                public static string validatePaymentBankDetails(Payment_Method__c paymentMethod) {
                    if(paymentMethod.Bank_Routing_Code__c == null) {
                        return 'Payment Method, Bank Routing Code is null';
                    } 
                    if(paymentMethod.Bank_Account_Number__c == null) {
                        return 'Payment Method, Bank Account Number is null';
                    } 
                    if(paymentMethod.Bank_Account_Type__c == null) {
                        return 'Payment Method, Bank Account Type is null';
                    } 
                    if(paymentMethod.Bank_Name__c == null) {
                        return 'Payment Method, Bank Name is null';
                    } 
                    if(paymentMethod.Bank_Account_Name__c == null) {
                        return 'Payment Method, Bank Account Name is null';
                    } 
                    return null;
                }
                
                // Created By Laxman, Ref : INVOICEIT-221
                // To validate the credit card information
                public static string validatePaymentCardDetails(Payment_Method__c paymentMethod) {
                    if(paymentMethod.Card_Number__c == null)
                        return 'WARNING : Missing Credit Card number in payment method';

                    if(paymentMethod.Card_Expiration_Month__c == null)
                        return 'WARNING : Missing Expiration Month in payment method';

                    if(paymentMethod.Card_Expiration_Year__c == null)
                        return 'WARNING : Missing Expiration Year in payment method';

                    return null;
                }
                
                 public static string validatePaymentProfileInfo(Payment_Method__c paymentMethod) {
                    if(paymentMethod.Account__r.Customer_Profile_ID__c == null)
                        return 'WARNING : Missing Customer Profile Id in Account';

                    if(paymentMethod.Payment_Profile_ID__c == null)
                        return 'WARNING : Missing Payment Profile ID in payment method';
                   
                    return null;
                }
                
                
                public static map<Id, Sobject> getSobjects(set<Id> setIds, string objectName) {
                    list<Id> ids = new list<Id>();
                    ids.addAll(setIds);
                    
                    if(objectName.containsIgnoreCase('Job') && !objectName.containsIgnoreCase(sPrefix)) {
                        objectName = sPrefix +objectName;
                    }
                    
                    string sIds = CommonUtilClass.convertListOfIdsIntoString(ids);
                    string sQuery =  'SELECT ' + CommonUtilClass.getObjectFields(objectName) 
                    + ' FROM ' + objectName + ' WHERE Id IN (' + sIds  + ')';
                    
                    sQuery = String.escapeSingleQuotes(sQuery);
                    sQuery = sQuery.replace('\\','');
                    map<Id, Sobject> map_Id_Sobject = new map<Id, Sobject>();
                    List<Sobject> accs = Database.query(sQuery);

                    map_Id_Sobject.putAll(accs);
                    return map_Id_Sobject;
                }
                
                public static void createPaymentAndPaymentAllocation(Invoice__c invoice, Transaction__c transactionObj) {
                    Payment__c payment = new Payment__c(Account__c = invoice.Account__c, 
                                                        Amount__c = transactionObj.Amount__c, 
                                                        Status__c = CommonUtilClass.STATUS_COMPLETED, 
                                                        Payment_Type__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                                                        Payment_Date__c = system.today(),
                                                        Transaction__c = transactionObj.Id,
                                                        Currency__c = invoice.CurrencyL__c,
                                                        Invoice__c = invoice.Id
                                                        );
                    insert payment;
                    
                    Payment_Allocation__c paymentAllocation = new Payment_Allocation__c(Payment__c = payment.Id,
                                                                                    Amount__c = payment.Amount__c,
                                                                                    Invoice__c = invoice.Id,
                                                                                    Status__c = CommonUtilClass.STATUS_COMPLETED);   
                
                    insert paymentAllocation;
                      
                }
                
                // this method is using for virtual terminal payment.
                public static void createPaymentAndAllocationForVirtualTerminal(Invoice__c invoice, Transaction__c transactionObj) {
                    Payment__c payment = new Payment__c(Account__c = invoice.Account__c, 
                                                        Amount__c = transactionObj.Amount__c, 
                                                        Status__c = CommonUtilClass.STATUS_COMPLETED, 
                                                        Payment_Type__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                                                        Payment_Date__c = system.today(),
                                                        Transaction__c = transactionObj.Id,
                                                        Currency__c = invoice.CurrencyL__c,
                                                        Invoice__c = invoice.Id,
                                                        Payment_Description__c = 'Virtual terminal payment');
                    
                    insert payment;
                    
                    Payment_Allocation__c paymentAllocation = new Payment_Allocation__c(Payment__c = payment.Id,
                                                                                    Amount__c = payment.Amount__c,
                                                                                    Invoice__c = invoice.Id,
                                                                                    Status__c = CommonUtilClass.STATUS_COMPLETED);   
                
                    insert paymentAllocation;
                      
                }
                
                public static void cancelPayment(Id transactionObjId) {
                    list<Payment__c> listOfPaymentsToCancelled = [SELECT Id,
                                                                  (SELECT Id FROM Payment_Allocations__r)
                                                                   FROM Payment__c
                                                                   WHERE Transaction__c =: transactionObjId];
                                                               
                    for(Payment__c payment : listOfPaymentsToCancelled) {
                        payment.Status__c = CommonUtilClass.STATUS_CANCELLED;
                    }                                              
                    
                    //update the payment to STATUS_CANCELLED then all the allocations will also get CANCELLED(by using trigger)
                    update listOfPaymentsToCancelled;  
                }
                
                // InvoicingUtilClass.calculateDiffBetweenDatesInMonths(calculationStartDate, calculationEndDate, 'Monthly');
                public static decimal calculateDiffBetweenDatesInMonths(date calculationStartDate, date calculationEndDate, String priceType) {
                    decimal noOfMonthsComputed = 0;
                    decimal noOfDaysComputed = 0; 
                    decimal noOfTimesCharge = 0;
                    
                    Decimal noOfMonths = calculationStartDate.monthsBetween(calculationEndDate);
                    // as a industry standard, we need to bill prorated days as days/30 days
                    Decimal daysInAMonth = 30.0;

                    // just verify the dates by adding the noOfMonths
                    // If dates are equal then 100%, we need to charges for noOfMonths
                    // If dates are not equal then we need to calculate for how many extra days we need to compute i.e (noOfMonths - 1) + ExtraDays
                    if(calculationStartDate.addMonths(Integer.ValueOf(noOfMonths)) == calculationEndDate) {
                        noOfMonthsComputed = noOfMonths;
                        noOfDaysComputed = 0;
                        
                        noOfTimesCharge = noOfMonths;

                        //return noOfTimesCharge;
                    } else {
                        noOfMonthsComputed = noOfMonths - 1;
                        date removedComputedMonths = calculationStartDate.addMonths(integer.ValueOf(noOfMonthsComputed));
                        Decimal remainingDays = removedComputedMonths.daysBetween(calculationEndDate);
                        noOfDaysComputed = remainingDays;
                        
                        // Some time remaning day might be greather than 30+ when noOfMonths is not calculated properly
                        if(remainingDays > 28) {
                            date oneMonthFront = removedComputedMonths.addMonths(1);
                            ++noOfMonthsComputed;
                            remainingDays = oneMonthFront.daysBetween(calculationEndDate);
                        } 
                        
                        if(noOfMonthsComputed <= 0) {
                            // this is for calculations like : (five days) or (three days)
                            noOfMonths = (remainingDays/daysInAMonth);
                            
                        } else {
                            // use the endDate Month for calculating the remanining days
                            // subtract one day since both days are included
                            //remainingDays = remainingDays - 1;
                            noOfMonths = noOfMonthsComputed + (remainingDays/daysInAMonth);
                        }
                        
                    }
                    
                    if(priceType == System.Label.OptionMonthly) {
                        noOfTimesCharge = noOfMonths;
                    } else if(priceType == System.Label.OptionQuarterly) {
                        noOfTimesCharge = noOfMonths / 3.0;
                    } else if(priceType == System.Label.OptionHalfYearly) {
                        noOfTimesCharge = noOfMonths / 6.0;
                    } else if(priceType == System.Label.OptionAnnual) {
                        noOfTimesCharge = noOfMonths / 12.0;
                    }
                    return noOfTimesCharge;
                }
            }