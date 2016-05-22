public with sharing class ControllerProformaInvToRegularInv {
    Invoice__c invoice;
    List<Invoice_Lines__c> listOfInvoiceLines;
    public boolean executeActionMethod{get;set;} 

    public ControllerProformaInvToRegularInv(ApexPages.StandardController controller) {
        executeActionMethod = true;
        invoice = (Invoice__c) controller.getRecord();
        
        if(invoice.Invoice_State__c != CommonUtilClass.STATUS_PROFORMA) {
            //only proforma invoices are allowed    
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.ProformaInvCanBeConvertedToRegularInv));
            executeActionMethod = false;
        } else if(invoice.Invoice_Status__c == CommonUtilClass.STATUS_CANCELLED) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.CancelledProformaInvCanNotConvertedToRegularInv));
            executeActionMethod = false;
        } else {
            ControllerEmailInvoice controllerEmailInvoice = new ControllerEmailInvoice();
            controllerEmailInvoice.sInvoiceId = invoice.Id;
            invoice = controllerEmailInvoice.invoice;
            listOfInvoiceLines = controllerEmailInvoice.listOfInvoiceLines;
        }
    }

    public pagereference createRegularInvoice() {
      
        if(executeActionMethod) {
            list<Payment_Allocation__c> listOfPaymenAllocationsToInsert = new list<Payment_Allocation__c>();
            Payment_Allocation__c paymentAllocation;
            List<Invoice_Lines__c> listOfRegularInvoiceLines = new List<Invoice_Lines__c>();
            set<Id> chargeIds = new set<Id>();
            List<Job_Rate_Plan_Charge__c> listOfOrderChargesToUpdate = new List<Job_Rate_Plan_Charge__c>(); 
            Invoice_Lines__c regularInvoiceLine;
            Savepoint sp;
            integer noOfDaysToDueDate;

            sobject sObjectBasedOnGroupBy = null;
            string legalEntityName = null;
            string groupBy = Configuration__c.getValues('INVOICE_GROUP_CRITERIA').String_Value__c;
            string sOrderLegalEntity = Configuration__c.getValues('ORDER_LEGAL_ENTITY_FIELD_NAME').String_Value__c;
            string sAccountLegalEntity = Configuration__c.getValues('ACCOUNT_LEGAL_ENTITY_FIELD_NAME').String_Value__c;
            string sDefaultPaymentTerm = Configuration__c.getValues('DEFAULT_PAYMENT_TERMS_TO_BE_USED_FROM').String_Value__c;
            string defaultPaymentTerms = Configuration__c.getValues('DEFAULT_PAYMENT_TERMS').String_Value__c;
            map<String, Sequence_Number__c> mapOfSequenceNumbersToUpdate = Sequence_Number__c.getAll().deepClone();
            map<Id, Sobject> map_Id_Sobject;
            set<Id> listOfIds = new set<Id>();

            try {
                /*
                    Modified By     : Ankit Sharma
                    Modified Date   : 27 Feb 2014
                    JIRA Task       : INVOICEIT-319
                    Comments        : Allow change the status of Invoice to Cancel.
                 */
                ControllerCancelInvoice.isButtonClicked = true;
                map<string,Payment_Terms__c> mapPaymentTerms = Payment_Terms__c.getAll();
                if(invoice.Regular_Invoice__c != null) {
                    //invoice is already created
                    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Regular Invoice is already created for this Invoice'));
                    //Added by Shruthi related to INVOICEIT-200
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.Label.RegularInvIsAlreadyGenerated));
                    return null;
                }
              
                if(listOfInvoiceLines == null || listOfInvoiceLines.size() == 0) {
                 
                    //no invoice lines are present
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.Label.InvLinesAreNotPresent));
                    return null;
                }   

                sp = Database.setSavepoint();
                //create the new invoice
                Invoice__c regularInvoice = invoice.clone(false);
                Job__c order = [select Payment_Terms__c,Account__r.Payment_Terms__c from Job__c where id=:regularInvoice.Order__c] ;
                regularInvoice.Invoice_Date__c = system.today();
                regularInvoice.Target_Date__c = system.today();
                regularInvoice.Invoice_Status__c = CommonUtilClass.STATUS_POSTED;
                regularInvoice.Invoice_State__c = CommonUtilClass.STATUS_REGULAR;
                regularInvoice.Invoice_Reference__c = null;

                //Anil has modified because we should calculate the due DATE based on payment terms configured- Issue 80
                if(sDefaultPaymentTerm!=null && sDefaultPaymentTerm==CommonUtilClass.PAYMENT_TERM_ACCOUNT && order.Account__r.Payment_Terms__c != null && mapPaymentTerms.containsKey(order.Account__r.Payment_Terms__c)) {
                    noOfDaysToDueDate = (integer) mapPaymentTerms.get(order.Account__r.Payment_Terms__c).Number_Of_Days__c; 
                    regularInvoice.Due_Date__c = regularInvoice.Invoice_Date__c.addDays(noOfDaysToDueDate);
                }
                else if(sDefaultPaymentTerm!=null && sDefaultPaymentTerm==CommonUtilClass.PAYMENT_TERM_ORDER && order.Payment_Terms__c != null && mapPaymentTerms.containsKey(order.Payment_Terms__c)) {
                    noOfDaysToDueDate = (integer) mapPaymentTerms.get(order.Payment_Terms__c).Number_Of_Days__c;
                    regularInvoice.Due_Date__c = regularInvoice.Invoice_Date__c.addDays(noOfDaysToDueDate);
                }
                else {
                    // Dev M if defaultPaymentTerms are null the assign due date INVOICEIT-356
                    if(mapPaymentTerms.containskey(defaultPaymentTerms)) {
                        noOfDaysToDueDate = (integer) mapPaymentTerms.get(defaultPaymentTerms).Number_Of_Days__c;
                        regularInvoice.Due_Date__c = regularInvoice.Invoice_Date__c.addDays(noOfDaysToDueDate);
                    }else {
                        regularInvoice.Due_Date__c = regularInvoice.Invoice_Date__c;
                    }   
                }

                //populate the legal entity
                if(groupBy == CommonUtilClass.INVOICING_GROUP_BY_ACCOUNT){
                    listOfIds.add(invoice.Account__c);
                } else {
                    listOfIds.add(invoice.Order__c);
                }

                if(sOrderLegalEntity != null || sAccountLegalEntity != null) {
                    if(groupBy == CommonUtilClass.INVOICING_GROUP_BY_ACCOUNT) {
                        map_Id_Sobject = InvoicingUtilClass.getSobjects(listOfIds, 'Account');
                    } else {
                        map_Id_Sobject = InvoicingUtilClass.getSobjects(listOfIds, 'Job__c');
                    }
                }

                if(groupBy == CommonUtilClass.INVOICING_GROUP_BY_ACCOUNT && sAccountLegalEntity != null) {
                    sObjectBasedOnGroupBy = map_Id_Sobject.get(invoice.Account__c);
                    legalEntityName = (string) sObjectBasedOnGroupBy.get(sAccountLegalEntity);
                } else if(sOrderLegalEntity != null) {
                    sObjectBasedOnGroupBy = map_Id_Sobject.get(invoice.Order__c);
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
                            regularInvoice.Invoice_Reference__c = invoiceNumber;
                           
                        }
                    }
                }

                //insert the regular invoice
                insert regularInvoice;

                //update the proforma with regular invoice number and cancelled the proforma invoice
                invoice.Regular_Invoice__c = regularInvoice.Id;
                invoice.Invoice_Status__c = CommonUtilClass.STATUS_CANCELLED;
                update invoice;

                for(Invoice_Lines__c invLine : listOfInvoiceLines) {
                    if(invLine.Job_Rate_Plan_Charge__c != null && !chargeIds.contains(invLine.Job_Rate_Plan_Charge__c)) {
                        listOfOrderChargesToUpdate.add(new Job_Rate_Plan_Charge__c(Id = invLine.Job_Rate_Plan_Charge__c, Charge_Date__c = invLine.Service_Start_Date__c));
                        chargeIds.add(invLine.Job_Rate_Plan_Charge__c); 
                    }

                    regularInvoiceLine = invLine.clone(false);
                    regularInvoiceLine.Invoice__c = regularInvoice.Id;
                    regularInvoiceLine.Status__c = CommonUtilClass.STATUS_ACTIVE;
                    // Modified By Dev.M INVOICEIT-596
                    if(regularInvoiceLine.Revenue_Recognition_Rule__c != null) {
                        regularInvoiceLine.Revenue_Recognition_Status__c = CommonUtilClass.STATUS_QUEUED ;
                    }
                    listOfRegularInvoiceLines.add(regularInvoiceLine);
                }

                insert listOfRegularInvoiceLines;

                //query the related payment allocations and assign it to the original regular invoice
                list<Payment_Allocation__c> listOfPaymenAllocations = [SELECT Amount__c, Invoice__c, Payment__c, Status__c
                                                                       FROM Payment_Allocation__c
                                                                       WHERE Invoice__c =: invoice.Id
                                                                       AND
                                                                       Status__c =: CommonUtilClass.STATUS_COMPLETED];

                for(Payment_Allocation__c payAllocation : listOfPaymenAllocations) {
                    paymentAllocation = payAllocation.clone(false);
                    paymentAllocation.Invoice__c = regularInvoice.Id;
                    paymentAllocation.Payment__c = payAllocation.Payment__c;
                    listOfPaymenAllocationsToInsert.add(paymentAllocation);

                    //make the original payment allocation to cancelled
                    payAllocation.Status__c = CommonUtilClass.STATUS_CANCELLED;
                } 

                listOfPaymenAllocations.addAll(listOfPaymenAllocationsToInsert);

                //cancel for the proforma invoice payment allocations and create the payment allocations for regular invoice
                upsert listOfPaymenAllocations;

                //populate the charge date
                update listOfOrderChargesToUpdate;

                if(!mapOfSequenceNumbersToUpdate.isEmpty()) {
                    update mapOfSequenceNumbersToUpdate.Values();
                }
                
                //Added by Dev M INVOICEIT-591
                // Commented by Dev M INVOICEIT-596
                /* list<Id> invoiceIds = new list<Id>();
                invoiceIds.add(regularInvoice.Id);
                RevenueTransactionsForInvoiceUtilClass.createRevenueTransactionForInvoice(invoiceIds);*/
                
                return new Pagereference('/' + regularInvoice.Id);

            } catch(DMLException dMlEx){
                // Added by Mani ticket : INVOICEIT-310
                Apexpages.Message errorMessage; 
                for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                { 
                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                    Apexpages.addMessage(errorMessage);      
                } 
                return null; 
            } catch(Exception ex) {
                CustomException.populateApexMessage(CustomException.handleError('ControllerProformaInvToRegulerInv', '', null, ex), 'ERROR');   
                Database.rollback(sp); 
            }
        }
        return null;
    }
}