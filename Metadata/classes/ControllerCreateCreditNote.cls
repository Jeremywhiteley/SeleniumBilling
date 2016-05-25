public with sharing class ControllerCreateCreditNote {
            public Invoice__c invoice {set;get;}
            public list<InvoiceLineWrapper> ListOfInvoiceLineWrapper{get;set;}
            public decimal totalAmount{get;set;}
            public boolean isRender{get;set;}
            public boolean isConfirm{get;set;}
            map<Id, list<Credit_Line__c>> map_InvoiceId_listofCreditLine = new map<Id, list<Credit_Line__c>>();
            public  String sPrefix {get; set;}

            public ControllerCreateCreditNote(ApexPages.StandardController controller) {
                sPrefix = CommonUtilClass.getPrefix();
                totalAmount = 0; 
                isRender = false;
                invoice = (Invoice__c) controller.getRecord(); 
                isConfirm = true;
                string sQuery = 'SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Invoice__c')
                                + ',(Select ' + CommonUtilClass.getObjectFields(sPrefix+'Invoice_Lines__c') + ',Invoice__r.Unpaid_Amount__c, Invoice__r.Name, Job__r.Number_Of_Terms__c '
                                +  'From Invoice_Lines__r where Status__c != ' + '\'' +'Cancelled' +'\')'
                                + ' FROM Invoice__c '
                                + ' WHERE Id =' + '\'' + String.escapeSingleQuotes(invoice.id) + '\'';
                invoice = Database.query(sQuery);
                       
                ListOfInvoiceLineWrapper = new list<InvoiceLineWrapper>();
                InvoiceLineWrapper invoiceLineWrapper;
                if(invoice.Invoice_Status__c != 'Posted'){
                    Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO,system.label.invoiceisnotposted);
                    Apexpages.addMessage(infoMessage);
                    isRender = true;
                }else if(invoice.Total_Invoice_Value__c > 0) {
                   try{  
                    sQuery = 'SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Invoice_Lines__c')
                        + ',Invoice__r.Unpaid_Amount__c, Invoice__r.Name, Job__r.Number_Of_Terms__c,(Select ' + CommonUtilClass.getObjectFields(sPrefix+'Credit_Line__c')
                        + ' From Credit_Lines__r) '
                        + ' FROM Invoice_Lines__c WHERE Status__c != ' + '\'' +'Cancelled' +'\''
                        + ' AND Invoice__c =' + '\'' + String.escapeSingleQuotes(invoice.id) + '\'';

                    list<Invoice_Lines__c> listOfInvoiceLine = new list<Invoice_Lines__c>();
                    listOfInvoiceLine = Database.query(sQuery);
                
                    for(Invoice_Lines__c invLine : listOfInvoiceLine){
                        if(invLine.Line_Amount__c > 0){
                            invoiceLineWrapper = new invoiceLineWrapper();
                            invoiceLineWrapper.invoiceline = invLine;
                            if(invoiceLineWrapper.invoiceline.Price_Type__c == 'One Time' || invoiceLineWrapper.invoiceline.Price_Type__c == 'Usage') {
                                invoiceLineWrapper.creditLine.Credit_Type_Applied__c = 'Amount';
                            }
                            ListOfInvoiceLineWrapper.add(invoiceLineWrapper);
                            map_InvoiceId_listofCreditLine.put(invLine.Id, invLine.Credit_Lines__r);
                        }
                    }  
                    
                    } catch(exception ex) {
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO,sQuery );
                        Apexpages.addMessage(infoMessage);
                    }
                } else {
                    Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.Error, system.label.You_Cannot_Create );
                    Apexpages.addMessage(infoMessage);
                }
            }
            
            //Added by Dev M calculateCreditLineAmount(): INVOICEIT-581
            public void calculateCreditLineAmount() {
                boolean lineSelectedToCreate = false;
                boolean isExecuteNew  = false;
                for(InvoiceLineWrapper invWrapper : ListOfInvoiceLineWrapper){
                    if(invWrapper.isSelected && invWrapper.creditLine.Credit_Type_Applied__c != 'Amount') {
                        
                        lineSelectedToCreate = true; 
                        
                        if(invWrapper.creditLine.Charge_Start_Date__c == null){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.Please_enter_start_date +invWrapper.invoiceline.Name));
                            break;
                        } 
                        
                        if(invWrapper.creditLine.Charge_End_Date__c == null){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.Please_enter_end_date +invWrapper.invoiceline.Name));
                            break;
                        } 

                        if(invWrapper.creditLine.Charge_Start_Date__c < invWrapper.invoiceline.Service_Start_Date__c){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.StartDateShouldBeGreater +invWrapper.invoiceline.Name));
                            break;
                        }   
                        
                        if(invWrapper.creditLine.Charge_Start_Date__c > invWrapper.invoiceline.Service_End_Date__c) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.StartDateShouldBeLess +invWrapper.invoiceline.Name));
                            break;
                        }
                        
                        if(invWrapper.creditLine.Charge_End_Date__c <= invWrapper.creditLine.Charge_Start_Date__c){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.EndDateShouldBeGreater +invWrapper.invoiceline.Name));
                            break;
                        }   
                        
                        if(invWrapper.creditLine.Charge_End_Date__c > invWrapper.invoiceline.Service_End_Date__c) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.EndDateShouldBeLess +invWrapper.invoiceline.Name));
                            break;
                        }
                        
                        if(invWrapper.creditLine.Credit_Type_Applied__c == 'Date') {
                            decimal noOfTimesCharge = InvoicingUtilClass.calculateDiffBetweenDatesInMonths(invWrapper.creditLine.Charge_Start_Date__c, invWrapper.creditLine.Charge_End_Date__c.addDays(1), invWrapper.invoiceline.Price_Type__c);
                            invWrapper.creditAmount = (invWrapper.invoiceline.Net_Total__c) * (noOfTimesCharge/invWrapper.invoiceline.Calculated_Quantity__c);
                            invWrapper.creditAmount = invWrapper.creditAmount.setScale(2, RoundingMode.HALF_UP);
                        }
                        
                        if(invWrapper.creditAmount <=  0){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.In +invWrapper.invoiceline.Name + system.label.Amount_To_Credit ));    
                            break; 
                        }  
                        
                        list<Credit_Line__c> listofCreditLines  = map_InvoiceId_listofCreditLine.get(invWrapper.invoiceline.Id);
         
                         if(listofCreditLines != null) {
                            boolean isBreak = false;
                            for(Credit_Line__c creditLineLine : listofCreditLines ){
                                 if( ( creditLineLine.Charge_Start_Date__c >= invWrapper.creditLine.Charge_Start_Date__c && creditLineLine.Charge_Start_Date__c <= invWrapper.creditLine.Charge_End_Date__c) 
                                      || (creditLineLine.Charge_End_Date__c >= invWrapper.creditLine.Charge_Start_Date__c && creditLineLine.Charge_End_Date__c <= invWrapper.creditLine.Charge_End_Date__c)) { 
                                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.DateRangeIsOverlapping +invWrapper.invoiceline.Name));    
                                        isBreak = true;
                                        break;
                                 }  
                            }
                            if(isBreak)
                              break;  
                        }
                        
                        if(invWrapper.creditAmount + invWrapper.invoiceline.Credit_Line_Amount__c > invWrapper.invoiceline.Net_Total__c) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.AmountShouldNotExceed +invWrapper.invoiceline.Name));    
                            break; 
                        }
                        
                        
                    } else if(invWrapper.isSelected && invWrapper.creditAmount != null) {
                        lineSelectedToCreate = true; 
                        if(invWrapper.creditAmount + invWrapper.invoiceline.Credit_Line_Amount__c > invWrapper.invoiceline.Net_Total__c) {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.label.AmountShouldNotExceed +invWrapper.invoiceline.Name));    
                            break; 
                        } 
                    }
                }
                
                if(!lineSelectedToCreate) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.CreditNote_invoiceLineToCreateCN));
                }
                
                if(isExecuteNew){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.CreditNote_enterAmountForInvoiceLine));
                }   
                
                list<Apexpages.Message> msgs = new list<Apexpages.Message>();
                msgs = ApexPages.getMessages();

                if(msgs.size() == 0) {
                    isConfirm = false;
                }    
            }
            
            public void backToCreditNote() {
                isConfirm = true;
            }
            
            Invoice_Lines__c invLine;
            public list<Invoice_Lines__c> listOfInvoiceLine = new list<Invoice_Lines__c>();
            public PageReference createCreditNote() {
                savepoint sp;
                try {
                    sp = Database.setSavepoint();
                    boolean isExecute = false;
                    boolean isExecuteNew = false;
                    decimal amount = 0;
                    decimal invoicePaidAmount = invoice.Net_Total__c - invoice.Paid_Amount__c - invoice.Credited_Amount__c;
                    for(InvoiceLineWrapper invWrapper : ListOfInvoiceLineWrapper){
                        if(invWrapper.isSelected){
                            isExecute = true;
                            amount = amount + invWrapper.creditAmount;
                        }
                        if(invWrapper.isSelected && invWrapper.creditAmount <=  0){
                                isExecuteNew = true;
                        }
                    }
                    if(invoicePaidAmount < amount){
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO, system.Label.CNAmountCanNotGreaterThanInvAmount);
                        Apexpages.addMessage(infoMessage);
                        return null;
                    }
                    list<Credit_Line__c> listOfCreditLine = new list<Credit_Line__c>();
                    if(!isExecute) {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.Label.CreditNote_invoiceLineToCreateCN));
                        return null;
                    }else if(isExecuteNew){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.Label.CreditNote_enterAmountForInvoiceLine));
                        return null;
                    }else {
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

                        // insert the credit note
                        insert creditNote;   

                        Credit_Line__c creditLineLocal;
                        integer iSequenceNumber = 1;
                        for(InvoiceLineWrapper invWrapper : ListOfInvoiceLineWrapper){
                        
                            if(invWrapper.isSelected && invWrapper.creditAmount > 0 && invWrapper.creditAmount != null){
                                creditLineLocal = new Credit_Line__c();
                                creditLineLocal.Credit_Note__c = creditNote.id;
                                creditLineLocal.Line_Amount__c = invWrapper.creditAmount;
                                creditLineLocal.Invoice_Line__c = invWrapper.invoiceline.id;
                                creditLineLocal.Invoice__c = invWrapper.invoiceline.Invoice__c;
                                creditLineLocal.Order__c = invWrapper.invoiceline.Job__c;
                                creditLineLocal.CurrencyL__c = invWrapper.invoiceline.CurrencyL__c;
                                creditLineLocal.Quantity__c = 1;
                                creditLineLocal.Sequence_No__c = iSequenceNumber;
                                iSequenceNumber++;
                                creditLineLocal.Status__c = 'Posted';
                                creditLineLocal.Line_Name__c = invWrapper.invoiceline.Line_Name__c;
                                
                                //Modified by Dev M: INVOICEIT-551
                                creditLineLocal.Accounting_Code__c = invWrapper.invoiceline.Accounting_Code__c;
                                creditLineLocal.Calculated_Quantity__c = invWrapper.invoiceline.Calculated_Quantity__c;
                                creditLineLocal.Deferred_Revenue_Accounting_Code__c = invWrapper.invoiceline.Deferred_Revenue_Accounting_Code__c;
                                creditLineLocal.Order_Rate_Plan_Charge__c = invWrapper.invoiceline.Job_Rate_Plan_Charge__c;
                                creditLineLocal.Price_Type__c = invWrapper.invoiceline.Price_Type__c;
                                creditLineLocal.Pricing_Model__c = invWrapper.invoiceline.Pricing_Model__c;
                                creditLineLocal.Revenue_Recognition_Rule__c = invWrapper.invoiceline.Revenue_Recognition_Rule__c; 
                                creditLineLocal.Charge_Start_Date__c = invWrapper.invoiceline.Service_Start_Date__c;
                                creditLineLocal.Charge_End_Date__c = invWrapper.invoiceline.Service_End_Date__c;
                                
                                // Modified By Dev.M INVOICEIT-596
                                if(invWrapper.invoiceline.Revenue_Recognition_Rule__c != null) {
                                    creditLineLocal.Revenue_Recognition_Status__c = CommonUtilClass.STATUS_QUEUED ;
                                }
                                    
                                //Modified by Dev M: INVOICEIT-581
                                creditLineLocal.Product__c = invWrapper.invoiceline.Product__c;
                                creditLineLocal.Product_Name__c = invWrapper.invoiceline.Product_Name__c; 
                                creditLineLocal.Product_Rate_Plan_Charge__c = invWrapper.invoiceline.Product_Rate_Plan_Charge__c;
                                creditLineLocal.Tax_Code__c = invWrapper.invoiceline.Tax_Code__c;
                                if(invWrapper.creditLine.Credit_Type_Applied__c != 'Amount' && invWrapper.creditLine.Credit_Type_Applied__c != '') {
                                 creditLineLocal.Charge_Start_Date__c = invWrapper.creditLine.Charge_Start_Date__c;
                                 creditLineLocal.Charge_End_Date__c = invWrapper.creditLine.Charge_End_Date__c;
                                } else {
                                    creditLineLocal.Revenue_Recognition_Start_Date__c = invWrapper.invoiceline.Revenue_Recognition_Start_Date__c;
                                    creditLineLocal.Revenue_Recognition_End_Date__c = invWrapper.invoiceline.Revenue_Recognition_End_Date__c;
                                }
                                creditLineLocal.Credit_Type_Applied__c = invWrapper.creditLine.Credit_Type_Applied__c;
                                 
                                decimal dTax =  0;
                                if(invWrapper.invoiceline.Tax__c != null){
                                    dTax = ( invWrapper.invoiceline.Tax__c / invWrapper.invoiceline.Net_Total__c) * invWrapper.creditAmount;
                                }  
                                
                                
                                decimal dVat = 0;
                                if(invWrapper.invoiceline.Vat__c != null){
                                    dVat = (invWrapper.invoiceline.Vat__c / invWrapper.invoiceline.Net_Total__c) * invWrapper.creditAmount;
                                }  
                                
                                creditLineLocal.Tax__c = dTax;                                                
                                creditLineLocal.Unit_Price__c = invWrapper.creditAmount;
                                creditLineLocal.UOM__c = invWrapper.invoiceline.Unit_of_Measurement__c;
                                creditLineLocal.VAT__c = dVat;
                                

                                listOfCreditLine.add(creditLineLocal); 

                                if(invWrapper.invoiceline.Credit_Line_Amount__c == null){
                                    invLine = new Invoice_Lines__c(id = invWrapper.invoiceline.id,Credit_Line_Amount__c = invWrapper.invoiceline.Credit_Line_Amount__c + invWrapper.creditAmount);
                                    listOfInvoiceLine.add(invLine);
                                }else{
                                    invLine = new Invoice_Lines__c(id = invWrapper.invoiceline.id,Credit_Line_Amount__c = invWrapper.creditAmount);
                                    listOfInvoiceLine.add(invLine);
                                }
                            }
                        }
                        // insert credit lines
                        insert listOfCreditLine;

                        update listOfInvoiceLine;
                        return new pagereference('/'+invoice.id);
                    }
                } catch(DMLException dMlEx){
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
                    return null;
                }   
                return null;
            }

            public string invoiceLineId{get;set;}
            public boolean displayPopup {get; set;}  
            public list<Credit_Line__c> listOfCreditLines{get;set;}
            
             public void displayCreditLines(){
                displayPopup = true;    
                invoiceLineId = system.currentPageReference().getParameters().get('invoiceLineId');
                listOfCreditLines = map_InvoiceId_listofCreditLine.get(invoiceLineId);
             }
            
             public void closePopup(){
                displayPopup = false;    
            }
            
            public void display(){   
            }

            public class InvoiceLineWrapper{
                public Invoice_Lines__c invoiceline{get;set;}
                public decimal creditAmount{get;set;}
                public boolean isSelected{get;set;}
                public boolean overWriteValue{get;set;}
                
                public Credit_Line__c creditLine{get;set;} 
                public InvoiceLineWrapper(){
                    isSelected = false;
                    overWriteValue = false;
                    creditAmount = 0;
                    creditLine = new Credit_Line__c();
                }
            }
        }