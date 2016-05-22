global with sharing class ControllerCancelInvoice {

        public Invoice__c invoice {set;get;}
        public String sPrefix {get; set;}
        public boolean bDisplayNoteMessage {set;get;}
        //We have declared this variables to call cancelletion of trigger invoice, related to SUP-381
        global static boolean isButtonClicked = false;
        public static boolean isButtonDisplayMessage = false;
        public ControllerCancelInvoice(ApexPages.StandardController stdController) {
            sPrefix = CommonUtilClass.getPrefix();
            invoice = (Invoice__c) stdController.getRecord();     
            string sQuery = 'SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Invoice__c')
                            + ',(Select Revenue_Recognition_Start_Date__c,Revenue_Recognition_End_Date__c,Service_End_Date__c,Service_Start_Date__c,Revenue_Recognition_Rule__c,Job_Rate_Plan_Charge__c,Accounting_Code__c,Calculated_Quantity__c,Deferred_Revenue_Accounting_Code__c,Price_Type__c,Pricing_Model__c,Discount_Value__c,Id, Name, VAT__c, Unit_Price__c, Tax__c, Sequence_No__c, Quantity__c, Unit_of_Measurement__c,Product_Name__c, CurrencyL__c,Net_Total__c,'
                            +  'Status__c,Line_Amount__c, Invoice__c, Credit_Line_Amount__c, Invoice__r.Unpaid_Amount__c, Invoice__r.Name, Line_Name__c,'
                            +  'Job__r.Number_Of_Terms__c, Total_Line_Amount__c , Job__c,Product__c,Product_Rate_Plan_Charge__c  '
                            +  'From Invoice_Lines__r where Status__c != ' + '\'' +'Cancelled' +'\')'
                            +  ',(Select name from Credit_Notes__r)'
                            + ' FROM Invoice__c '
                            + ' WHERE Id =' + '\'' + String.escapeSingleQuotes(invoice.id) + '\'';
            invoice = Database.query(sQuery);

        }
        public PageReference cancelInvoice() {
            isButtonClicked = true;
            isButtonDisplayMessage = true;
            if(invoice != null && invoice.Invoice_Status__c == CommonUtilClass.STATUS_CANCELLED) {
                //This invoice has already been cancelled.
                Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO,system.Label.Invoiceisalreadycancelled );
                Apexpages.addMessage(infoMessage);
                bDisplayNoteMessage = true;
                return null;
            }else if(invoice.Number_Of_Invoice_Lines__c >= 0 || invoice.Invoice_Status__c == CommonUtilClass.STATUS_DRAFT) {
                
                /*
                        Modified By         : Devender M  :28 Nov 2013  :INVOICEIT-280
                        Comments         : CLONE - Unpost Invoices - capture unpost/cancellation reason
                 */
                savepoint sp;
                try {    
                    boolean isCheck = false;
                    sp = Database.setSavepoint();
                    boolean isCheckNew = false;
                    string sInvStatus = invoice.Invoice_Status__c;
                    invoice.Invoice_Status__c = CommonUtilClass.STATUS_CANCELLED;
                    bDisplayNoteMessage = true;
                    update invoice;
                     if(invoice.Number_Of_Invoice_Lines__c == 0) {
                            Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO,system.Label.Yourhavesucessfullycancelledtheinvoice);
                            Apexpages.addMessage(infoMessage);
                     }
                     
                     list<Apexpages.Message> msgs = ApexPages.getMessages();
                        
                        for(Apexpages.Message msg:msgs){
                            if (msg.getDetail().contains(system.Label.Yourhavesucessfullycancelledtheinvoice)) isCheck = true;
                            if (msg.getDetail().contains(system.Label.Youcannotcancelthisinvoice)) isCheckNew = true;
                        }
                            
                        /*Start-Added by Dhanalakshmi for INVOICEIT-424 */
                        if(sInvStatus == CommonUtilClass.STATUS_POSTED && ( invoice.Total_Invoice_Value__c >= invoice.Credited_Amount__c || invoice.Total_Invoice_Value__c < 0 ) && invoice.Invoice_State__c == CommonUtilClass.STATUS_REGULAR)
                        {
                            Credit_Note__c creditNote = new Credit_Note__c(
                                Account__c = invoice.Account__c,
                                Billing_Contact__c = invoice.Billing_Contact__c,                                                 
                                CurrencyL__c = invoice.CurrencyL__c,                                                        
                                Due_Date__c = invoice.Due_Date__c,                                                       
                                Exchange_Rate_Applied__c = invoice.Exchange_Rate_Applied__c,
                                Related_Invoice__c = invoice.Id,
                                Credit_Note_Date__c = System.today(),
                                Credit_Note_Status__c = 'Posted',                                                        
                                Order__c = invoice.Order__c,
                                Shipping_Contact__c = invoice.Shipping_Contact__c
                            );
                            
                        
                            // if the invoice is successfully cancelled then only create
                            if(isCheck){
                                //insert credit Note
                                //insert creditNote;
                            
                                list<Credit_Line__c> listOfCreditLine = new list<Credit_Line__c>();
                                Credit_Line__c creditLineLocal;
                                
                                
                                for(Invoice_Lines__c invLine : invoice.Invoice_Lines__r){
                                    //if credited amount and subtotal amount both are same then do not apply the credit line
                                    if(invLine.Line_Amount__c != invLine.Credit_Line_Amount__c || invLine.Line_Amount__c == 0){
                                        creditLineLocal = new Credit_Line__c();
                                        
                                        creditLineLocal.Invoice_Line__c = invLine.id;
                                        creditLineLocal.Invoice__c = invLine.Invoice__c;
                                        creditLineLocal.Order__c = invLine.Job__c;
                                        creditLineLocal.CurrencyL__c = invLine.CurrencyL__c;
                                        creditLineLocal.Quantity__c = invLine.Quantity__c;
                                        creditLineLocal.Sequence_No__c = invLine.Sequence_No__c;
                                        creditLineLocal.Status__c = 'Posted';
                                        creditLineLocal.Unit_Price__c = invLine.Unit_Price__c;
                                        creditLineLocal.UOM__c = invLine.Unit_of_Measurement__c;
                                        creditLineLocal.Line_Name__c = invLine.Line_Name__c;
                                        
                                        creditLineLocal.Line_Amount__c = invLine.Net_Total__c;
                                        creditLineLocal.Tax__c = invLine.Tax__c;  
                                        creditLineLocal.VAT__c = invLine.VAT__c;
                                        //creditLineLocal.Discount_Value__c =  invLine.Discount_Value__c;

                                        //Modified by Dev M ticket : INVOICEIT-551
                                        creditLineLocal.Accounting_Code__c = invLine.Accounting_Code__c;
                                        creditLineLocal.Calculated_Quantity__c = invLine.Calculated_Quantity__c;
                                        creditLineLocal.Deferred_Revenue_Accounting_Code__c = invLine.Deferred_Revenue_Accounting_Code__c;
                                        creditLineLocal.Order_Rate_Plan_Charge__c = invLine.Job_Rate_Plan_Charge__c;
                                        creditLineLocal.Price_Type__c = invLine.Price_Type__c;
                                        creditLineLocal.Pricing_Model__c = invLine.Pricing_Model__c;
                                        creditLineLocal.Revenue_Recognition_Rule__c = invLine.Revenue_Recognition_Rule__c;
                                        creditLineLocal.Charge_End_Date__c = invLine.Service_End_Date__c;
                                        creditLineLocal.Charge_Start_Date__c = invLine.Service_Start_Date__c;
                                        creditLineLocal.Revenue_Recognition_Start_Date__c = invLine.Revenue_Recognition_Start_Date__c;
                                        creditLineLocal.Revenue_Recognition_End_Date__c = invLine.Revenue_Recognition_End_Date__c;
                                        //Modified by Dev M ticket : INVOICEIT-581
                                        creditLineLocal.Product__c = invLine.Product__c;
                                        creditLineLocal.Product_Name__c = invLine.Product_Name__c; 
                                        creditLineLocal.Product_Rate_Plan_Charge__c = invLine.Product_Rate_Plan_Charge__c;
                                        // Modified By Dev.M INVOICEIT-596
                                        if(invLine.Revenue_Recognition_Rule__c != null) {
                                            creditLineLocal.Revenue_Recognition_Status__c = CommonUtilClass.STATUS_QUEUED ;
                                        }
                                        // if the credit amount is not null, then create credit line for rest balance amount
                                        if(invLine.Credit_Line_Amount__c != null || invLine.Credit_Line_Amount__c > 0){
                                            decimal dVat = 0;
                                            decimal dTax =  0;
                                            decimal dDiscount = 0;
                                            decimal dFinalAmount = invLine.Net_Total__c - invLine.Credit_Line_Amount__c;
                                            
                                            if(invLine.Credit_Line_Amount__c > 0){
                                                creditLineLocal.Quantity__c = 1; 
                                            }
                                            if(invLine.Tax__c != null && invLine.Net_Total__c > 0){
                                                dTax = ( invLine.Tax__c / invLine.Net_Total__c) * dFinalAmount;
                                                dTax = dTax.setscale(2);
                                            }  
                                            
                                            if(invLine.Vat__c != null && invLine.Net_Total__c > 0){
                                                dVat = (invLine.Vat__c / invLine.Net_Total__c) * dFinalAmount;
                                                dvat = dvat.setscale(2);
                                            }  
                                            
                                            creditLineLocal.Tax__c = dTax;                                                
                                            creditLineLocal.VAT__c = dVat;
                                            
                                            creditLineLocal.Line_Amount__c = dFinalAmount;
                                            if(invLine.Credit_Line_Amount__c > 0){
                                                 creditLineLocal.Unit_Price__c = dFinalAmount;
                                            }
                                        }
                                        listOfCreditLine.add(creditLineLocal);
                                    }
                                }
                                //insert credit lines
                                if(!listOfCreditLine.isEmpty()){
                                    
                                    insert creditNote;
                                    for(Credit_Line__c creditLineobj : listOfCreditLine) {
                                        creditLineobj.Credit_Note__c = creditNote.id;
                                    }
                                    insert listOfCreditLine;
                                }
                                list<Invoice_Lines__c> listOfInvLines = new list<Invoice_Lines__c>();
                                for(Invoice_Lines__c invLine : invoice.Invoice_Lines__r){
                                    listOfInvLines.add(new Invoice_Lines__c(id = invLine.id,Credit_Line_Amount__c = invLine.Line_Amount__c));
                                }
                                
                                if(listOfInvLines.size() > 0){
                                     update listOfInvLines;
                                } 
                                
                                //added By Dev M ticket : INVOICEIT-551
                                //RevenueTransactionsForCreditUtilClass.createRevenueTransactionForCreditNote(creditNote.Id);
                                
                                if(system.Label.CreditNote_cancelPostInvoice != system.Label.EMPTY){
                                    //If Invoice is in 'Posted' status we are creating the Credit Note 
                                    Apexpages.Message infoMessageIfInvoiceInPosted = new Apexpages.Message(ApexPages.Severity.INFO,system.Label.CreditNote_cancelPostInvoice);
                                    Apexpages.addMessage(infoMessageIfInvoiceInPosted);
                                }
                                
                            }
                        }else if(!isCheckNew && sInvStatus == CommonUtilClass.STATUS_DRAFT && system.Label.CreditNote_cancelDraftInvoice != system.Label.EMPTY && invoice.Invoice_State__c == CommonUtilClass.STATUS_REGULAR){
                            //If Invoice is in 'Draft' status we are not creating the Credit Note 
                            Apexpages.Message infoMessageIfInvoiceInDraft = new Apexpages.Message(ApexPages.Severity.INFO,system.Label.CreditNote_cancelDraftInvoice);
                            Apexpages.addMessage(infoMessageIfInvoiceInDraft);
                        }else if(!isCheckNew && system.Label.CreditNote_CancelInvoice != system.Label.EMPTY){
                                Apexpages.Message infoMessageIfInvoiceInDraft = new Apexpages.Message(ApexPages.Severity.INFO,system.Label.CreditNote_CancelInvoice);
                                Apexpages.addMessage(infoMessageIfInvoiceInDraft);
                        }
                       /* End*/
                } catch(DMLException dMlEx){
                    // Added by Mani ticket : INVOICEIT-310
                    Database.rollback(sp);
                    Apexpages.Message errorMessage; 
                    for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                    { 
                        errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                        Apexpages.addMessage(errorMessage);      
                    } 
                    return null; 
                } catch(Exception ex) {
                    Database.rollback(sp);
                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
                    Apexpages.addMessage(errorMessage);
                } 
            }//Commented by dhanalakshmi this else will never execute 
            return null;
        }

        public PageReference cancelPost() {
            isButtonClicked = true;
            isButtonDisplayMessage = true;
            if(invoice.Number_Of_Invoice_Lines__c > 0 && invoice.Invoice_Status__c != CommonUtilClass.STATUS_POSTED) {
                //This invoice has already been posted.
                Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO, system.Label.invoice_status_Posted_can_be_drafted);
                Apexpages.addMessage(infoMessage);
                bDisplayNoteMessage = true;
                return null;
            } else {
                //Invoice__c newInvoice = new Invoice__c(Id = invoice.Id, Invoice_Status__c = CommonUtilClass.STATUS_DRAFT);
                
                        /*Modified By       : Devender M  :28 Nov 2013  :INVOICEIT-280
                          Comments        : CLONE - Unpost Invoices - capture unpost/cancellation reason 
                        */
                invoice.Invoice_Status__c = CommonUtilClass.STATUS_DRAFT;
                bDisplayNoteMessage = true;
                savepoint sp;
                try {
                    sp = Database.setSavepoint();
                    //update newInvoice;
                    update invoice;
                    
                    // added by ram, jira tkt invoiceIt-424
                    if(invoice.Credit_Notes__r.size() > 0){
                         delete invoice.Credit_Notes__r;
                    }
                    
                    list<Invoice_Lines__c> lstLineValueToUpdate = new list<Invoice_Lines__c>();
                    for(Invoice_Lines__c invLine : invoice.Invoice_Lines__r){
                        if(invLine.Credit_Line_Amount__c != null){
                            lstLineValueToUpdate.add(new Invoice_Lines__c(id = invLine.id,Credit_Line_Amount__c = 0));
                        }
                    }
                    
                    if(lstLineValueToUpdate.size() > 0)
                        update lstLineValueToUpdate;
                    
                    if(invoice.Number_Of_Invoice_Lines__c == 0) {
                        //Added by Shruthi related to INVOICEIT-200
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO, system.Label.invoice_status_changed_to_draft);
                        Apexpages.addMessage(infoMessage);
                    }

                }  catch(DMLException dMlEx){
                    // Added by Mani ticket : INVOICEIT-310
                    Database.rollback(sp);
                    Apexpages.Message errorMessage; 
                    for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                    { 
                        errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                        Apexpages.addMessage(errorMessage);      
                    } 
                    return null; 
                }catch(Exception ex) {
                    Database.rollback(sp);
                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
                    Apexpages.addMessage(errorMessage);
                } 
            }        
            return null;
        }
        public PageReference backToInvoice() {
            return new PageReference('/' + invoice.Id);
        }
    }