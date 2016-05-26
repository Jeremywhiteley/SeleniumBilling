public with sharing class ControllerGenerateProformaInvoice {
            public Job__c order{get;set;}
            public string sInvoiceRefNo {get;set;}
            public list<OrderRPChargeWrapper> listOfOrderRPChargeWrapper{get;set;}
            public boolean isOrderRPChargeSelected = false;
            OrderRPChargeWrapper orderRPChargeWrapper;
            list<Job_Rate_Plan_Charge__c> listOfOrderRPcharges;
            public string currecyISOCode = null;
            public boolean isDisplay {get;set;}
            public ControllerGenerateProformaInvoice(ApexPages.StandardController controller) {
                order = (Job__c)controller.getRecord();
                listOfOrderRPChargeWrapper = new list<OrderRPChargeWrapper>();
                isDisplay = true;
                if(order.Id != null) {
                    order = JobCreationUtil.getJob(order.Id);
                    Currency__c currencyObj = CommonUtilClass.getCurrencyObjectForId(order.CurrencyL__c);
                    currecyISOCode = currencyObj.Name;
                    if(order.Is_Billing_Master_Order__c)
                         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, system.label.ProformaInvoiceCannotBeGeneratedForBillingMasterOrder));
                }
                //Added by DL, INVOICEIT_417
                String orderStatusForInvoicing = (Configuration__c.getValues('ORDER_STATUS_FOR_INVOICING').String_Value__c);
                if(orderStatusForInvoicing != null && orderStatusForInvoicing.trim().length() > 0 && orderStatusForInvoicing != order.Status__c) {
                    isDisplay = false;
                    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.Label.Order_Status));
                }
                String chargeStatusForInvoicing = (Configuration__c.getValues('CHARGE_STATUS_FOR_INVOICING').String_Value__c);           
                listOfOrderRPcharges = InvoicingUtilClass.getJobProductRatePlanCharges(new Id[]{order.Id});
                if(listOfOrderRPcharges.size() == 0) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.OrderRatePlanChargesDoesNotExist));
                } else {
                    for(Job_Rate_Plan_Charge__c orderCharge : listOfOrderRPcharges){
                        // display only Price Type equals to 'One Time' and status is not equals to proforma.
                        if(orderCharge.Price_Type__c == System.label.OptionOneTime && orderCharge.Charge_Date__c == null && orderCharge.Status__c == chargeStatusForInvoicing){
                            orderRPChargeWrapper = new OrderRPChargeWrapper();
                            orderRPChargeWrapper.isChecked = false;
                            orderRPChargeWrapper.orderRPCharge = orderCharge;
                            listOfOrderRPChargeWrapper.add(orderRPChargeWrapper);
                        }
                    }
                }                                       
            }

            // to create proforma invoice with invoice lines
            public PageReference createProformaInvoice(){
                // selected checkboxs
                for(OrderRPChargeWrapper orderRPChargeWrapper: listOfOrderRPChargeWrapper){
                    if(orderRPChargeWrapper.isChecked){
                        isOrderRPChargeSelected = true;
                    }
                } 

                if(sInvoiceRefNo == null || sInvoiceRefNo == ''){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.Label.EnterInvReferenceForProformaInv));
                    return null;
                }

                // no selection. else create invoice with invoice line for the selected checkbox
                if(!isOrderRPChargeSelected) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, system.label.SelectAtLeastOneOrderLine));
                } else {
                    Invoice__c invoice;
                    list<Invoice_Lines__c> invLines = new list<Invoice_Lines__c>();
                    Invoice_Lines__c invLine; 
                    Savepoint sp = Database.setSavepoint();

                    try {                       
                       
                        invoice = new Invoice__c(Account__c = order.Account__c, Order__c = order.Id);
                        invoice.Billing_Contact__c = order.Billing_Contact__c;
                        invoice.Shipping_Contact__c = order.Shipping_Contact__c;
                        invoice.Invoice_Reference__c = sInvoiceRefNo;
                        invoice.CurrencyL__c = order.CurrencyL__c;
                        invoice.Invoice_Date__c = system.today();
                        invoice.Target_Date__c = system.today();
                        //Proforma due date is the invoice date
                        invoice.Due_Date__c = system.today();
                        invoice.Invoice_Status__c = CommonUtilClass.STATUS_DRAFT;
                        invoice.Invoice_State__c = CommonUtilClass.STATUS_PROFORMA;
                        //mapping order Tax Engine to invoice Tax Engine
                        invoice.Tax_Engine__c = order.Tax_Engine__c;
                        /*
                                    Modified By         : Ankit Sharma   :28 Feb 2014   :INVOICEIT-322
                                    Comments         : Populating the standard field currency (CurrencyIsoCode) only for multi currency org.
                         */
                        if(UserInfo.isMultiCurrencyOrganization() && currecyISOCode != null){
                            InvoicingUtilClass.populateExchangeRateOnInvoice(invoice, currecyISOCode);
                        } else{
                            invoice.Exchange_Rate_Applied__c = 1;
                        }

                        insert invoice;

                        Job_Rate_Plan_Charge__c orderRPcharge;
                        integer sequenceNumber = 0;
                        for(OrderRPChargeWrapper orderRPChargeWrapper: listOfOrderRPChargeWrapper) {
                            if(orderRPChargeWrapper.isChecked) {        
                                orderRPcharge = orderRPChargeWrapper.orderRPCharge;
                                invLine = new Invoice_Lines__c(Invoice__c = invoice.Id, Job__c = order.Id);
                                if(invoice.Tax_Engine__c == System.Label.Standard || invoice.Tax_Engine__c == '' || invoice.Tax_Engine__c == null){
                                    invLine.Tax__c = orderRPcharge.Tax__c;
                                }else{
                                    invLine.Tax__c = 0.0;
                                }
                                
                                invLine.VAT__c = orderRPcharge.VAT__c;
                                invLine.Line_Name__c = orderRPcharge.Name;
                                invLine.Status__c = CommonUtilClass.STATUS_PROFORMA;
                                invLine.Service_Start_Date__c = system.today();
                                invLine.Sequence_No__c = ++sequenceNumber;
                                invLine.Quantity__c = orderRPcharge.Quantity__c;
                                invLine.Unit_Price__c = orderRPcharge.Unit_Price__c;
                                invLine.Discount_Value__c = orderRPcharge.Discount_Value__c;
                                invLine.Line_Amount__c = orderRPcharge.Price__c;
                                invLine.Job_Rate_Plan_Charge__c = orderRPcharge.Id;

                                invLine.Product_Name__c = orderRPcharge.Job_Rate_Plan__r.Job_Product__r.Name;
                                invLine.Product_Rate_Plan_Charge__c = orderRPcharge.Product_Rate_Plan_Charge__c;
                                invLine.Accounting_Code__c = orderRPcharge.Accounting_Code__c;
                                invLine.Quantity__c = orderRPcharge.Quantity__c;
                                invLine.Unit_of_Measurement__c = orderRPcharge.Unit_Of_Measurement__c;
                                invLine.Price_Type__c = orderRPCharge.Price_Type__c;
                                invLine.Pricing_Model__c = orderRPCharge.Price_Format__c;
                                //Add the revrec details
                                invLine.Revenue_Recognition_Rule__c = orderRPCharge.Revenue_Recognition_Rule__c;
                                invLine.Revenue_Recognition_Start_Date__c = orderRPCharge.Revenue_Recognition_Start_Date__c;
                                invLine.Revenue_Recognition_End_Date__c = orderRPCharge.Revenue_Recognition_End_Date__c;
                                // Modified by DEV M INVOICEIT-545
                                invLine.Calculated_Quantity__c = 1;
                                // Modified By Dev.M INVOICEIT-548
                                invLine.Deferred_Revenue_Accounting_Code__c = orderRPCharge.Deferred_Revenue_Accounting_Code__c;
                                /*
                                                    Modified By         : Ankit Sharma  :28 Feb 2014   :INVOICEIT-322
                                                    Comments         : Populating the standard field currency (CurrencyIsoCode) only for multi currency org.
                                 */
                                 if(UserInfo.isMultiCurrencyOrganization()){
                                     CommonUtilClass.populateCurrencyIsoCodeOnSobject(invLine, currecyISOCode);
                                 }       

                                 /*
                                                    Modified By         : Ankit Sharma   :27 Feb 2014   :INVOICEIT-319
                                                    Comments         : Look up to currency for invoice line object
                                  */
                                 invLine.CurrencyL__c = orderRPcharge.CurrencyL__c;
                                 
                                 // Code starts for Consortium Billing Here INVOICEIT-556
                                // Change the values of the invoice Line accordingly to Consortium Billing or else old values will retained 
                                // Execute the code only if the Billing Master order is present and master order is true
                                // And the pricing type is Volume, Flat Fee, Tiered  pricing
                                // This code is for quick release we need to make generic methods pass the charge 
                                // calculate values accordingly since we have written same code for usages also
                                // Code ends for Consortium Billing Here
                                   
                                 //mark the charge date as today, so that the scheduler will not pick up
                                 orderRPcharge.Charge_Date__c = system.today();
                                 invLines.add(invLine);
                            }
                        }

                        if(!invLines.isEmpty()){ 
                            insert invLines;
                        }
                        //update the charge ststus to charge date
                        update listOfOrderRPcharges;
                    } catch(DMLException dMlEx){
                        //Added by DL,NVOICEIT-665, 
                        //previously Invoice is creating without INVlines if exception comes, Now we are rollbacking all changes if exception is there 
                        Database.rollback(sp);
                        // Added by Mani ticket : INVOICEIT-310
                        Apexpages.Message errorMessage; 
                        for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                        { 
                            errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                            Apexpages.addMessage(errorMessage);      
                        } 
                        return null; 
                    }catch(Exception ex) {
                        CustomException.populateApexMessage(CustomException.handleError('ControllerGenerateProformaInvoice', '', null, ex), 'ERROR');   
                        Database.rollback(sp); 
                        return null;
                    }
                    return new PageReference('/' + invoice.Id);
                }
                return null; 
            }

            // wrapper class for the order rate plan charge. 
            public class OrderRPChargeWrapper {
                public boolean isChecked {get;set;}
                public Job_Rate_Plan_Charge__c orderRPCharge {get;set;}
            }
        }