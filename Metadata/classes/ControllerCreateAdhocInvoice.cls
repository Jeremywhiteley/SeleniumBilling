public with sharing class ControllerCreateAdhocInvoice {
        public Job__c order {get;set;}
        public String responseMessage;
        public Job__c job{get;set;}
        public string sLogo {set; get;}
        
        public ControllerCreateAdhocInvoice(ApexPages.StandardController controller) {
            
            order = (Job__c) controller.getRecord();
            
            // Querying the order status INVOICEIT-520 By Dev M
            order = [select Id, Is_Billing_Master_Order__c , Status__c, Name, Currency_Symbol__c, CurrencyL__r.Name, CurrencyL__c,Billing_Contact__r.MailingCountry, Billing_Contact__r.MailingPostalCode, Billing_Contact__r.MailingState, Billing_Contact__r.MailingCity, Billing_Contact__r.MailingStreet, Billing_Contact__c, Billing_Contact__r.Salutation, Billing_Contact__r.LastName From Job__c where id=:order.Id];
            // just initalize the instance, since we want invoice date and target date
            job = new Job__c();
            
            if(order.Is_Billing_Master_Order__c) 
             Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO,system.Label.Invoice_For_Billing_Master_Order));
        }

        public PageReference createAdhocInvoice() {
            Date invoiceDate, targetDate, cutoffDate;
            String chargeStatusForInvoicing = (Configuration__c.getValues('CHARGE_STATUS_FOR_INVOICING').String_Value__c); 
            SavePoint sp;
            try {
                sp = Database.setSavepoint();
                String orderStatusForInvoicing = (Configuration__c.getValues('ORDER_STATUS_FOR_INVOICING').String_Value__c);
                
                if(orderStatusForInvoicing != null && orderStatusForInvoicing.trim().length() > 0 && orderStatusForInvoicing != order.Status__c) {
                    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.Label.Order_Status));
                    return null; 
                }
                
                invoiceDate = job.Service_Activation_Date__c; 
                targetDate = job.Service_End_Date__c;
            
                CustomInvoiceGenerator invoiceGenerator = new CustomInvoiceGenerator();

                responseMessage = invoiceGenerator.generateInvoiceForOrder(order.Id, invoiceDate, targetDate, true, false, false);

                if( responseMessage != null && responseMessage.length() > 0 && !responseMessage.contains('null')) {
                    if(responseMessage.contains('ERROR') || responseMessage.contains('null')) {
                        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, responseMessage)); 
                    } else {
                        return new PageReference('/' + responseMessage);    
                    }
                } else {
                    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.Label.NoInvoicesGenerated));
                }   
            } catch(Exception ex) {
                //Added by DL,NVOICEIT-665, 
                
                Database.rollback(sp);
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.ExceptionMessage + ex.getTypeName() + ':'+ex.getMessage() + ':'  + ex.getLineNumber()));         
            }

            return null;
        }
        //Added by dhanalakshmi for INVOICEIT-188
        
        public Invoice__c invoiceObj{get;set;}
        public list<Invoice_Lines__c> listOfInvoiceLinesForPreview{get;set;} 
        public decimal subtotal{get;set;}
        public decimal discount{get;set;}
        public decimal vat{get;set;}
        public decimal tax{get;set;}
        public decimal invoiceTotal{get;set;}
        public String sPriceType{get;set;}
        
        public PageReference generateInvoicePreview() {
            
            list<StaticResource> listOfStaticResources = [SELECT Id,SystemModstamp FROM StaticResource WHERE Name = 'logo'];
            if(!listOfStaticResources.isEmpty()) {
                
               sLogo = '/resource/'+listOfStaticResources[0].SystemModStamp.getTime()+'/logo';
            } else {
                sLogo = (Configuration__c.getValues('COMPANY_LOGO').String_Value__c);
            }
            
            Date invoiceDate, targetDate, cutoffDate;
            String chargeStatusForInvoicing = (Configuration__c.getValues('CHARGE_STATUS_FOR_INVOICING').String_Value__c); 
            try {
                
                String orderStatusForInvoicing = (Configuration__c.getValues('ORDER_STATUS_FOR_INVOICING').String_Value__c);
                if(orderStatusForInvoicing != null && orderStatusForInvoicing.trim().length() > 0 && orderStatusForInvoicing != order.Status__c) {
                    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.Label..Order_Status));
                    return null; 
                }
                
                invoiceDate = job.Service_Activation_Date__c;
                targetDate = job.Service_End_Date__c;
            
                CustomInvoiceGenerator invoiceGenerator = new CustomInvoiceGenerator();

                responseMessage = invoiceGenerator.generateInvoiceForOrder(order.Id, invoiceDate, targetDate, true, true, false);
                invoiceObj = new Invoice__c();
                listOfInvoiceLinesForPreview = new list<Invoice_Lines__c>();
                Map<Id, Job_Rate_Plan_Charge__c> mapOfOrderIdToCharge = new Map<Id, Job_Rate_Plan_Charge__c>([Select Price_Type__c, Order__c     
                                                                                  From Job_Rate_Plan_Charge__c 
                                                                                  where Job_Rate_Plan__r.Job_Product__r.Job__c =: order.Id]);
                
                invoiceObj = invoiceGenerator.invoiceObj;
                listOfInvoiceLinesForPreview = invoiceGenerator.listOfInvoiceLinesForPreview;
                subtotal = 0.0;
                discount = 0.0;
                vat = 0.0;
                tax = 0.0;
                invoiceTotal = 0.0;
                if(listOfInvoiceLinesForPreview.size() > 0)
                {
                    for(Invoice_Lines__c invoiceLines: listOfInvoiceLinesForPreview)
                    {   
                        
                        if(mapOfOrderIdToCharge.containskey(invoiceLines.Job_Rate_Plan_Charge__c)){
                            invoiceLines.Line_Name__c = mapOfOrderIdToCharge.get(invoiceLines.Job_Rate_Plan_Charge__c).Price_Type__c;
                        }
                        
                        
                        if(invoiceLines.Line_Amount__c != null && invoiceLines.Line_Amount__c != 0){
                            subtotal = subtotal + invoiceLines.Line_Amount__c;
                        }
                        if(invoiceLines.Discount_Value__c != null && invoiceLines.Discount_Value__c != 0){
                            discount = discount + invoiceLines.Discount_Value__c;
                        }
                        if(invoiceLines.VAT__c != null && invoiceLines.VAT__c != 0){
                            vat = vat + invoiceLines.VAT__c;
                        }
                        if(invoiceLines.Tax__c != null && invoiceLines.Tax__c != 0){
                            tax = tax + invoiceLines.Tax__c;
                        }
                        invoiceTotal = subtotal - discount + vat + tax;
                    }
                } 
                if(listOfInvoiceLinesForPreview.size() == 0)
                { 
                    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.Label.NoInvoicesGenerated));
                    //return null;
                }
                else
                {
                    return page.generateInvoicePreview;
                }
                
            } catch(Exception ex) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.ExceptionMessage + ex.getTypeName() + ':'+ex.getMessage() + ':'  + ex.getLineNumber()));         
            }

            return null;
            
        }
        //End
    }