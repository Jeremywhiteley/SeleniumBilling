public with sharing class ClassAfterOnInvoice {
        public static boolean INVOICE_AFTER_PROCESSING_COMPLETE = false;

        public void setInvoiceAfterProcessingComplete() {
            INVOICE_AFTER_PROCESSING_COMPLETE = true;
        }

        public Boolean getInvoiceAfterProcessingComplete() {
            return INVOICE_AFTER_PROCESSING_COMPLETE;
        }

        public void handleBeforeOnInvoice(list<Invoice__c> listOfDeletedInvoices)
        {
            for(Invoice__c newInvoice : listOfDeletedInvoices) {
                if(newInvoice.Number_Of_Invoice_Lines__c > 0 && newInvoice.Invoice_Status__c != CommonUtilClass.STATUS_CANCELLED) {
                    //newInvoice.addError('You can only delete invoice(s) whose status is cancelled');
                    //Added by Shruthi related to INVOICEIT-200
                    newInvoice.addError(system.Label.OnlyCancelledInvoicesCanBeDeleted);
                }
            }
        }

        map<Id,Invoice_Lines__c> map_ChargeId_InvoiceLine = new map<Id,Invoice_Lines__c>();
        list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
        boolean isLatestInvoice = false;
        Invoice__c currentInvoice;

        public void createpayment(list<Invoice__c> listOfInvoice) {
            list<Payment__c> listPaymentTocreate = new list<Payment__c>();
            for(Invoice__c invoice : listOfInvoice) {
                Payment__c payment = new Payment__c(Account__c = invoice.Account__c, Currency__c = invoice.CurrencyL__c,
                Payment_Date__c = invoice.Invoice_Date__c, Payment_Created_From__c = invoice.Id,  Amount__c = invoice.Total_Invoice_Value__c * -1, 
                Payment_Type__c = 'From Credit Invoice', Status__c = 'Completed', Payment_Description__c = 'Credit Invoice amount :' + invoice.name);
                listPaymentTocreate.add(payment); 
            }
        insert listPaymentTocreate;
        }

        public void handleAfterOnInvoice(map<Id,Invoice__c> newMap, map<Id,Invoice__c> oldMap)
        {
            set<ID> setOfInvoicePostedIds = new set<ID>();
            set<ID> setOfInvoiceIds = new set<ID>();
            list<ID> listOfInvoiceForRevenueTransactions = new list<ID>();

            list<Invoice__c> listInvoicesToUpdate = new list<Invoice__c>();
            list<Invoice_Lines__c> listInvoiceLinesToUpdate = new list<Invoice_Lines__c>(); 
            list<Invoice__c> listInvoicesToCreatePayments = new list<Invoice__c>();
            //we have taken a static boolean in ControllerCancelInvoice, to know from where the cancel is clicked from UI or from cancel visual force page.
            //if cancel is button is clicked then the boolean will be true else it will false
            //when it is false we should tell the user saying use the cancel button for cancelling the invoice
            for(Invoice__c newInvoice : newMap.values()) {
                Invoice__c oldInvoice = oldMap.get(newInvoice.Id);
                
                // added by Devender M, INVOICEIT-550 once invoice status updated to posted from draft
                // Here we are processing Revenue Transactions.
                //Added by Dev M INVOICEIT-591 created rev rec only for regular lines
                // Commented by Dev M due to new changes INVOICEIT-595
                if(newInvoice.Invoice_Status__c != oldInvoice.Invoice_Status__c 
                  && oldInvoice.Invoice_Status__c == CommonUtilClass.STATUS_DRAFT
                  && newInvoice.Invoice_Status__c == CommonUtilClass.STATUS_POSTED
                  && newInvoice.Invoice_State__c == CommonUtilClass.STATUS_REGULAR){
                    if(newInvoice.Total_Invoice_Value__c < 0){
                       listInvoicesToCreatePayments.add(newInvoice);
                     }else{
                        // call ava tax method to apply tax. added by ram
                         if(newInvoice.Tax_Engine__c == System.Label.Avalara && BatchForPostingInvoices.isExecuteAvaTax){
                            calculateAvataxOnInvoice(newInvoice.Account__c,newInvoice.Order__c,newInvoice.Id);
                         }
                      }
                }
                if(!listInvoicesToCreatePayments.isEmpty()) {
                    createpayment(listInvoicesToCreatePayments);
                }
                // added by Dhanalakshmi,INVOICEIT-504 once invoice status updated to posted 
                // we are restricting the status to set as draft.
                if(newInvoice.Invoice_Status__c != oldInvoice.Invoice_Status__c 
                  && oldInvoice.Invoice_Status__c == CommonUtilClass.STATUS_POSTED
                  && newInvoice.Invoice_Status__c == CommonUtilClass.STATUS_DRAFT){
                     newInvoice.addError(system.Label.PostedInvoicesCanNotBeRevertedBack);
                }

                if(newInvoice.Invoice_Status__c != oldInvoice.Invoice_Status__c
                        && oldInvoice.Invoice_Status__c == CommonUtilClass.STATUS_CANCELLED) {
                    //newInvoice.addError('You cannot change the status of a Cancelled invoice');
                    //Added by Shruthi related to INVOICEIT-200
                    newInvoice.addError(system.Label.CancelledInvoiceStatusCannotBeChanged);
                }
                if(newInvoice.Number_Of_Invoice_Lines__c > 0 && newInvoice.Invoice_Status__c != oldInvoice.Invoice_Status__c
                        && newInvoice.Invoice_Status__c == CommonUtilClass.STATUS_CANCELLED) {
                    if(ControllerCancelInvoice.isButtonClicked) {
                        setOfInvoiceIds.add(newInvoice.Id);
                        currentInvoice = newInvoice;
                    } else {
                        //newInvoice.addError('Please use the Cancel button to update the Invoice Status. If you do not see the button, please contact your Salesforce Administrator');
                        //Added by Shruthi related to INVOICEIT-200
                        newInvoice.addError(system.Label.UseCancelButtonToUpdateTheInvoiceStatus);
                    }
                }

                if(newInvoice.Number_Of_Invoice_Lines__c > 0 && newInvoice.Invoice_Status__c != oldInvoice.Invoice_Status__c
                        && newInvoice.Invoice_Status__c == CommonUtilClass.STATUS_DRAFT) {
                    if(ControllerCancelInvoice.isButtonClicked) {
                        setOfInvoicePostedIds.add(newInvoice.Id);
                        currentInvoice = newInvoice;
                    } 
                    // commented by Dhanalakshmi,INVOICEIT-504
                    // we are no longer using the unpost invoice button to unpost the invoice. so we have just commented the below(else loop) code 
                }
            }

            //populate the map of invoiceId and list of invoicelines
            if(setOfInvoiceIds.size() > 0) {
                    isLatestInvoiceCheck(setOfInvoiceIds);
                    //check if this is the latest invoice - this means all the invoice lines for this invoice should be the 
                    //latest against their respective order charges
                    if(isLatestInvoice) {
                        for(Invoice_Lines__c invoiceLine : listInvoiceLines) {
                            Invoice_Lines__c newInvoiceLineToUpdate = new Invoice_Lines__c(Id = invoiceLine.id,
                                    Status__c = CommonUtilClass.STATUS_CANCELLED);
                            listInvoiceLinesToUpdate.add(newInvoiceLineToUpdate);
                        }

                        /*
                        Modified By          : Rama Krishna    :18 october 2013
                        Comments          : if any exception is occurs before saving only messege is displaying to user, so we have moved to the listInvoiceLinesToUpdate.size() 
                         */
                        //update the payment allocations to cancelled status
                        updatePaymentAllocations(currentInvoice.Id);

                        if(currentInvoice.Total_Invoice_Value__c < 0) {
                            list<Payment__c> listPaymentToUpdate = [SELECT Id FROM Payment__c WHERE 
                                                        Payment_Created_From__c =: currentInvoice.Id AND Status__c = 'Completed'];
                            if(!listPaymentToUpdate.isEmpty()) {
                                for(Payment__c payment : listPaymentToUpdate) {
                                    payment.Status__c = CommonUtilClass.STATUS_CANCELLED;
                                } 
                                update listPaymentToUpdate; 
                            }                         
                        }
                    } else {
                        //add to a list for errors
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO,system.Label.Youcannotcancelthisinvoice);
                        if(ControllerCancelInvoice.isButtonDisplayMessage)
                            Apexpages.addMessage(infoMessage);
                        //here we have to roll this back to the previous status
                        Invoice__c oldInvoice = oldMap.get(currentInvoice.Id);
                        Invoice__c invoice = new Invoice__c(Id = currentInvoice.Id,
                                Invoice_Status__c = oldInvoice.Invoice_Status__c, Cancellation_Reason__c = '');
                        listInvoicesToUpdate.add(invoice);
                    }

                    if(listInvoiceLinesToUpdate.size() > 0) {
                        update listInvoiceLinesToUpdate;

                        Invoice__c invoiceObj = newMap.get(currentInvoice.Id);
                        // call ava tax method to apply tax. added by ram
                         if(invoiceObj.Tax_Engine__c == System.Label.Avalara && invoiceObj.Tax_Calculation_Status__c == 'Processed'){
                            processTaxOnVoidInvoiceToAvaTax(invoiceObj.Account__c,invoiceObj.Order__c,invoiceObj.Id);
                         }

                        /*
                        Modified By       : Rama Krishna18 october 2013 
                        Comments       : added below apex messeges,  
                         */
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO,system.Label.Yourhavesucessfullycancelledtheinvoice);
                        if(ControllerCancelInvoice.isButtonDisplayMessage)
                            Apexpages.addMessage(infoMessage);
                    }

                    if(listInvoicesToUpdate.size() > 0) {
                        update listInvoicesToUpdate;
                    }   
            }

            if(setOfInvoicePostedIds.size() > 0) {
                isLatestInvoiceCheck(setOfInvoicePostedIds);
                if(isLatestInvoice) {
                    for(Invoice_Lines__c invoiceLine : listInvoiceLines) {
                        Invoice_Lines__c newInvoiceLineToUpdate = new Invoice_Lines__c(Id = invoiceLine.id,
                                Status__c = CommonUtilClass.STATUS_DRAFT);
                        listInvoiceLinesToUpdate.add(newInvoiceLineToUpdate);
                    }
                    //Added by Shruthi related to INVOICEIT-200
                    //Commentedby dhanalakshmi since we are not giving option to change the invoice satus to draft once it is posted or cancelled
                    //update the payment allocations to cancelled status
                    updatePaymentAllocations(currentInvoice.Id);
                } else {
                    //Commentedby dhanalakshmi since we are not giving option to change the invoice satus to draft once it is posted or cancelled
                    //here we have to roll this back to the previous status
                    Invoice__c oldInvoice = oldMap.get(currentInvoice.Id);
                    Invoice__c invoice = new Invoice__c(id = currentInvoice.Id,
                            Invoice_Status__c = oldInvoice.Invoice_Status__c);
                    listInvoicesToUpdate.add(invoice);
                }

                if(listInvoiceLinesToUpdate.size() > 0) {
                    update listInvoiceLinesToUpdate;
                }

                if(listInvoicesToUpdate.size() > 0) {
                    update listInvoicesToUpdate;
                }                                          
            }

             // Commented by Dev M due to new changes INVOICEIT-595
        }

        public void isLatestInvoiceCheck(set<Id> setOfInvoiceIds) {
            set<ID> setOfJobChargeIds = new set<ID>();
            listInvoiceLines = [SELECT Service_End_Date__c, Invoice__c, Job_Rate_Plan_Charge__r.Charge_Date__c,
                                Job_Rate_Plan_Charge__r.Price_Type__c, Job_Rate_Plan_Charge__c, Charge_Date__c
                                FROM Invoice_Lines__c
                                WHERE Invoice__c IN : setOfInvoiceIds
                                ];

            for(Invoice_Lines__c invoiceLine : listInvoiceLines) {
                if(invoiceLine.Job_Rate_Plan_Charge__r.Price_Type__c == system.Label.OptionOneTime) {
                    isLatestInvoice = true;  
                } else if(invoiceLine.Job_Rate_Plan_Charge__c != null){
                    setOfJobChargeIds.add(invoiceLine.Job_Rate_Plan_Charge__c);
                    map_ChargeId_InvoiceLine.put(invoiceLine.Job_Rate_Plan_Charge__c,invoiceLine);
                }
            }    
            
             if(!setOfJobChargeIds.isEmpty()) {
            AggregateResult[] groupedResults = [SELECT Job_Rate_Plan_Charge__c chargeId, max(Charge_Date__c) maxinvoiceDate
                                                FROM Invoice_Lines__c 
                                                WHERE Job_Rate_Plan_Charge__c IN: setOfJobChargeIds
                                                AND
                                                Status__c !=: CommonUtilClass.STATUS_CANCELLED
                                                GROUP BY Job_Rate_Plan_Charge__c
                                                ];     

            for(AggregateResult aggResult : groupedResults) {
                date maxDate = (date) aggResult.get('maxinvoiceDate');
                Id chargeId = (Id) aggResult.get('chargeId');
                Invoice_Lines__c invoiceLine = map_ChargeId_InvoiceLine.get(chargeId);

                if(invoiceLine.Charge_Date__c == maxDate) {
                    isLatestInvoice = true;
                } else {
                    isLatestInvoice = false;
                    break;
                }
            } 
         } else {
            isLatestInvoice = true;
        }
        }

        public static void updatePaymentAllocations(string invoiceId) {
            //once the invoice is CANCELLED all the Payment Allocations should be CANCELLED
            list<Payment_Allocation__c> listOfPaymenAllocations = [SELECT Id
                                                                   FROM Payment_Allocation__c
                                                                   WHERE Invoice__c =: invoiceId
                                                                   AND
                                                                   Invoice__r.Invoice_State__c !=: CommonUtilClass.STATUS_PROFORMA];

            for(Payment_Allocation__c payAllocation : listOfPaymenAllocations) {
                payAllocation.Status__c = CommonUtilClass.STATUS_CANCELLED;
            } 
            update listOfPaymenAllocations;
        }

        /*
        Modified By      : Rama Krishna   :19 june 2013:  INVOICEIT-130
        Comments      : Whenever invoice status is changed from Draft to Posted & invoice Account have any payments,Allow Unallocated Payments to be automatically allocated to future invoices. 
         */  
        public void handleAfterOnInvoiceAutomaticAllocation(map<Id,Invoice__c> newMap, map<Id,Invoice__c> oldMap) {
            set<Id> setOfAccountIds = new set<Id>();
            list<Payment_Allocation__c> listOfPaymentAllocations = new list<Payment_Allocation__c>();
            Invoice__c oldInvoice;
            list<Invoice__c> listOfInvoicesOfInterest = new list<Invoice__c>();
            set<id> setOfCurrencyMatches = new set<id>();

            for(Invoice__c invoice : newMap.values()) {
                oldInvoice = oldMap.get(invoice.Id);
                if(invoice.Unpaid_Amount__c > 0 && 
                        oldInvoice.Invoice_Status__c == CommonUtilClass.STATUS_DRAFT && 
                        invoice.Invoice_Status__c == CommonUtilClass.STATUS_POSTED) 
                {
                    setOfAccountIds.add(invoice.Account__c);
                    setOfCurrencyMatches.add(invoice.CurrencyL__c);
                    listOfInvoicesOfInterest.add(invoice);
                }
            }
            //Added by DL, INVOICEIT-630, Restricting allocating of excess amount to invoices if invoice's order has payment plan.
            list<Invoice__c>lstOfInvoices = [select Id, Unpaid_Amount__c, Account__c, Order__r.Payment_Plan__c From Invoice__c Where Id IN: listOfInvoicesOfInterest AND Order__r.Payment_Plan__c = null];
            if(!setOfAccountIds.isEmpty()) {
                decimal invoiceUnpaidAmount = 0.0;  
                Payment_Allocation__c paymentAllocation;
                map<Id, list<Payment__c>> mapAccountId_listOfPayment = new map<Id, list<Payment__c>>();
                list<Payment__c> listOfPaymentLoc;

                list<Payment__c> listOfPayments = [SELECT Name, Unallocated_Amount__c, Account__c  
                                                   FROM Payment__c 
                                                   WHERE 
                                                   Unallocated_Amount__c > 0                 
                                                   AND
                                                   Account__c in: setOfAccountIds
                                                   AND
                                                   Currency__c in: setOfCurrencyMatches
                                                   AND  
                                                   Status__c = 'Completed'
                                                   ORDER BY CreatedDate];

                if(!listOfPayments.isEmpty()) {

                    //construct a map of account id and list of payments 
                    for(Payment__c payment : listOfPayments) {
                        payment.Amount__c = payment.Unallocated_Amount__c;

                        if(mapAccountId_listOfPayment.containsKey(payment.Account__c)) {
                            listOfPaymentLoc = mapAccountId_listOfPayment.get(payment.Account__c);
                        } else {
                            listOfPaymentLoc = new list<Payment__c>();
                        }
                        listOfPaymentLoc.add(payment);
                        mapAccountId_listOfPayment.put(payment.Account__c, listOfPaymentLoc);
                    }
                    //Collecting the invoices which dont have the paymentplan order, to avoid allocating of excess amount to invoices, Previously we are iterating over 'listOfInvoicesOfInterest'
                    for(Invoice__c invoice : lstOfInvoices) {
                        invoiceUnpaidAmount = invoice.Unpaid_Amount__c;  
                        if(mapAccountId_listOfPayment.containsKey(invoice.Account__c)) {
                            listOfPaymentLoc = mapAccountId_listOfPayment.get(invoice.Account__c);

                            for(Payment__c payment : listOfPaymentLoc) {
                                if(invoiceUnpaidAmount > 0) {
                                    if(payment.Amount__c > 0) {
                                        if(payment.Amount__c >= invoiceUnpaidAmount) {
                                            paymentAllocation = new Payment_Allocation__c(Payment__c = payment.Id,
                                                    Amount__c = invoiceUnpaidAmount,
                                                    Invoice__c = invoice.Id,
                                                    Status__c = CommonUtilClass.STATUS_COMPLETED); 
                                            listOfPaymentAllocations.add(paymentAllocation);  
                                            payment.Amount__c = payment.Amount__c - invoiceUnpaidAmount;
                                            invoiceUnpaidAmount = 0;
                                        } else {
                                            paymentAllocation = new Payment_Allocation__c(Payment__c = payment.Id,
                                                    Amount__c = payment.Amount__c,
                                                    Invoice__c = invoice.Id,
                                                    Status__c = CommonUtilClass.STATUS_COMPLETED);

                                            listOfPaymentAllocations.add(paymentAllocation);  

                                            invoiceUnpaidAmount = invoiceUnpaidAmount - payment.Amount__c;  
                                            payment.Amount__c = 0;
                                        }
                                    }
                                } else {
                                    //once the invoiceUnpaidAmount is 0 break the loop
                                    break;
                                }
                            }
                        }
                    }

                    insert listOfPaymentAllocations;
                }
            }  
        }    

      // upon posted call Avalara to caluclate the tax.
      @future(Callout=true)
      public static void calculateAvataxOnInvoice(Id accountId,ID orderID,Id invoiceID) {
          ClassforCalculatingAvaTax.calculateTaxInvoice(accountId,orderID,invoiceID);     
      }  

      @future(Callout=true)
      public static void processTaxOnVoidInvoiceToAvaTax(Id accountId,ID orderID,Id invoiceID) {
           ClassforCalculatingAvaTax.voidTaxInvoice(accountId,orderID,invoiceID);    
      } 


}