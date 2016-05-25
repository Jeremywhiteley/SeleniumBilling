public with sharing class ControllerAllocatePayments {

        public Payment__c payment {set; get;}
        public String sPrefix {get; set;}
        public list<ControllerAllocatePayments.PaymentAllocation> listOfallocationClass {set; get;}
        public map<Integer, ControllerAllocatePayments.PaymentAllocation> map_Counter_allocationClass {set; get;}
        list<Payment_Allocation__c> listOfPaymentAllocationsToInsert;
        public list<Payment_Allocation__c> listOfPaymentAllocationsInDb {set; get;}
        public boolean isPaymentAllocationsExists {set; get;}
        public boolean isUnpaidInvoicesExists {set; get;}
        //Done by Manigandan.SA on Dec 9, 2015 for INVOICEIT-638
        public boolean isPPInstallmentExists {set; get;}
        list<Payment_Allocation__c> listOfPPIPaymentAllocationsToInsert;
        list<Payment_Plan_Installment__c> listOfPPIChecked;
        public list<Payment_Plan_Installment__c> listOfPaymentPlanInstallment{get; set;}
        public Payment_Plan_Installment__c paymentplaninstallment {set; get;}
        public map<Integer, ControllerAllocatePayments.PaymentPlanInstallment> map_Counter_ppiallocationClass {set; get;}
        public list<ControllerAllocatePayments.PaymentPlanInstallment> listOfppiallocationClass {set; get;}
        
        public ControllerAllocatePayments(ApexPages.StandardController stdController) {
            this.payment = (Payment__c)stdController.getRecord();
            sPrefix = CommonUtilClass.getPrefix();
            initalize();
            if(payment.Payment_Allocations__r.size() > 0) {
                isPaymentAllocationsExists = true;
                listOfPaymentAllocationsInDb = new list<Payment_Allocation__c>();
                listOfPaymentAllocationsInDb.addAll(payment.Payment_Allocations__r);
            }
        }

        public void initalize() {
            try {
                string sQuery = 'SELECT '+ CommonUtilClass.getObjectFields(sPrefix+'Payment__c')
                                + ',(SELECT '+ CommonUtilClass.getObjectFields(sPrefix+'Payment_Allocation__c') 
                                + ' FROM Payment_Allocations__r) '
                                + 'FROM Payment__c '
                                + ' WHERE Id =' + '\'' + String.escapeSingleQuotes(payment.id) + '\'';
                payment = Database.query(sQuery);

                if(payment.Unallocated_Amount__c != 0 && ( payment.Status__c == 'completed' || payment.Status__c == 'Completed') ) { 
                    list<Invoice__c> listOfInvoices = ControllerAllocatePayments.getInvoicesForPayment(payment);
                   
                   
                    if(listOfInvoices.size() > 0) {
                        isUnpaidInvoicesExists = true;
                    }                                                                  
                    listOfallocationClass = new list<ControllerAllocatePayments.PaymentAllocation>();  
                    
                    map_Counter_allocationClass = new map<Integer, ControllerAllocatePayments.PaymentAllocation>(); 
                                                                          
                    ControllerAllocatePayments.PaymentAllocation allocationClass;
                    integer counter = 0;
                    Payment_Allocation__c paymentAllocation;
                    for(Invoice__c invoice : listOfInvoices) {
                        allocationClass = new ControllerAllocatePayments.paymentAllocation();
                        allocationClass.counter = ++counter;
                        allocationClass.isChecked = false;
                        allocationClass.invoice = invoice;
                        paymentAllocation = new Payment_Allocation__c(Invoice__c = invoice.Id, Payment__c = payment.Id);
                        allocationClass.paymentAllocation = paymentAllocation;
                        listOfallocationClass.add(allocationClass);
                        map_Counter_allocationClass.put(counter, allocationClass);
                    }
                    //Done by Manigandan.SA on Dec 9, 2015 for INVOICEIT-638
                    // Comments: To display all the payment plan installments during initiallization
                    
                    list<Payment_Plan_Installment__c> listOfPaymentPlanInstallment = ControllerAllocatePayments.getPaymentPlanInstallmentsForPayment(payment);
                    map_Counter_ppiallocationClass = new map<Integer, ControllerAllocatePayments.PaymentPlanInstallment>(); 
                    if(listOfPaymentPlanInstallment.size() > 0){
                        isPPInstallmentExists = true;
                    }
                    listOfppiallocationClass = new list<ControllerAllocatePayments.PaymentPlanInstallment>();
                    ControllerAllocatePayments.PaymentPlanInstallment ppInstallmentClass;
                    integer counter1 = 0;
                    Payment_Allocation__c ppIpaymentAllocation;
                     for(Payment_Plan_Installment__c pPInstallments : listOfPaymentPlanInstallment) {
                         ppInstallmentClass = new ControllerAllocatePayments.PaymentPlanInstallment();
                         ppInstallmentClass.counter1 = ++counter1;
                         ppInstallmentClass.isChecked1 = false;
                         ppInstallmentClass.paymentPlanInstallment = pPInstallments;
                         
                         paymentAllocation = new Payment_Allocation__c(Invoice__c = pPInstallments.Invoice__c, Payment__c = payment.Id, Amount__c = pPInstallments.Payment_Amount__c);
                         ppInstallmentClass.ppIpaymentAllocation = paymentAllocation;
                         
                         if(pPInstallments.Payment_Amount__c > payment.Unallocated_Amount__c){
                         ppInstallmentClass.isVisible1 = true;
                         }
                         if(pPInstallments.Payment_Status__c == 'Completed'){
                         ppInstallmentClass.isVisible1 = true;
                         }
                         
                         listOfppiallocationClass.add(ppInstallmentClass);
                         map_Counter_ppiallocationClass.put(counter1, ppInstallmentClass);
                         
                        
                     }
                   
                }//Added by dhanalakshmi, INVOICEIT-442, when payment status != 'Completed' do not add PaymentAllocations to Payment
                else{
                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.INFO,system.Label.Payment_Status);
                    Apexpages.addMessage(errorMessage);
                }
  
            } catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
                Apexpages.addMessage(errorMessage);
            }  
        }

        public void getSelectedInvoice() {
            integer selectedInoiceCounter = integer.ValueOf(system.currentPageReference().getParameters().get('selectedCounter'));
            ControllerAllocatePayments.paymentAllocation allocationClass = map_Counter_allocationClass.get(selectedInoiceCounter);
            if(allocationClass.isChecked) {
                allocationClass.paymentAllocation.Amount__c = 0;
            } else {
                allocationClass.paymentAllocation.Amount__c = null;
            }
        }
        
        public void getSelectedPaymentPlanInstallment() {
            integer selectedPPICounter = integer.ValueOf(system.currentPageReference().getParameters().get('selectedCounter'));
            ControllerAllocatePayments.paymentPlanInstallment ppiallocationClass = map_Counter_ppiallocationClass.get(selectedPPICounter);
            if(ppiallocationClass.isChecked1) {
                ppiallocationClass.ppIpaymentAllocation.Amount__c = 0;
            } else {
                ppiallocationClass.ppIpaymentAllocation.Amount__c = null;
            }
        }

        public PageReference savePaymentAllocations() {
            
            if(validateAmount()) {
                try {

                    insert listOfPaymentAllocationsToInsert;

                    if(!listOfPPIPaymentAllocationsToInsert.isempty())
                    insert listOfPPIPaymentAllocationsToInsert;
                    update listOfPPIchecked;

                    //Done by Manigandan.SA on Dec 9, 2015 for INVOICEIT-638
                    return new PageReference('/' + payment.Id);
                } catch(DMLException dMlEx){
                    // Added by Mani ticket : INVOICEIT-310
                    Apexpages.Message errorMessage; 
                    for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                    { 
                        errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                        Apexpages.addMessage(errorMessage);      
                    } 
                    return null; 
                }catch(Exception ex) {
                    Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
                    Apexpages.addMessage(errorMessage);
                }  
            }  
            return null;    
        }

        public PageReference backToPayment() {
            return new PageReference('/' + payment.Id);
        }
        public PageReference cancelPayment() {
            return new PageReference('/' + payment.Id);
        }

        public boolean validateAmount() {
            decimal calculatedSum = 0.0;
            listOfPaymentAllocationsToInsert = new list<Payment_Allocation__c>();
            listOfPPIPaymentAllocationsToInsert = new list<Payment_Allocation__c>();
            listOfPPIchecked = new list<Payment_Plan_Installment__c>();
            //1. We have to check whether it is checked
            //2. if it is checked and payment allocation amount is less than zero,show an error message
            //3. if it is checked and payment allocation amount is greathet than invoice un-paid amount,show an error message
            for(ControllerAllocatePayments.paymentAllocation allocationClass : listOfallocationClass) {
                if(allocationClass.isChecked) {
                    if(allocationClass.paymentAllocation.Amount__c <= 0) {
                        Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.PaymentPageNoZeroValues);
                        Apexpages.addMessage(errorMessage);
                        return false;
                    } else if(allocationClass.paymentAllocation.Amount__c > allocationClass.invoice.Unpaid_Amount__c) {
                        Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.PaymentPageAllocationIsGreater);
                        Apexpages.addMessage(errorMessage);
                        return false;
                    } else {
                        calculatedSum += allocationClass.paymentAllocation.Amount__c;
                        listOfPaymentAllocationsToInsert.add(allocationClass.paymentAllocation);
                    }
                }
            }

            // To validate the equality of Installment amount with the Payment Amount
            for(ControllerAllocatePayments.PaymentPlanInstallment ppInstallmentClass : listOfppiallocationClass) {
                if(ppInstallmentClass.isChecked1) {
                     //isExecute = true;
                     listOfPPIchecked.add(new Payment_Plan_Installment__c(Id = ppInstallmentClass.paymentPlanInstallment.id, Payment__c = payment.Id));
                    if(ppInstallmentClass.paymentPlanInstallment.Payment_Amount__c == ppInstallmentClass.ppIpaymentAllocation.Amount__c) {
                         calculatedSum += ppInstallmentClass.ppIpaymentAllocation.Amount__c;
                        listOfPPIPaymentAllocationsToInsert.add(ppInstallmentClass.ppIpaymentAllocation);
                    } else  {
                        Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.PaymentPageAllocationIsGreater);
                        Apexpages.addMessage(errorMessage);
                        return false;
                    } 
                }
            }
            if(calculatedSum <= payment.Unallocated_Amount__c) {
                return true;
            } else {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.PaymentPageTotalPaymentIsGreater);
                Apexpages.addMessage(errorMessage);
                return false;
            }
        }
        
        public PageReference cancelPaymentAllocation() {
            string selectedPaymentAllocationId = system.currentPageReference().getParameters().get('paymentAllocationId');
            for(Payment_Allocation__c pA : listOfPaymentAllocationsInDb) {
                if(pA.Id == selectedPaymentAllocationId) {
                    //make payment allocation amount to zero and status to CANCELLED
                    pA.Amount__c = 0.0;
                    pA.Status__c = CommonUtilClass.STATUS_CANCELLED;
                    //once the payAllocation is CANCELLED make invoice status from paid to active

                    Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO, system.Label.PaymentPageCancelledSuccessfully);
                    Apexpages.addMessage(infoMessage);
                    break;
                }
            }

            try {
                update listOfPaymentAllocationsInDb;
            }  catch(DMLException dMlEx){
                // Added by Mani ticket : INVOICEIT-310
                Apexpages.Message errorMessage; 
                for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                { 
                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                    Apexpages.addMessage(errorMessage);      
                } 
                return null; 
            }catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
                Apexpages.addMessage(errorMessage);
            }
            initalize();
            return null;
        }

        public class PaymentAllocation {
            public integer counter {get;set;}        
            public boolean isChecked {get;set;}
            public Invoice__c invoice {get;set;}
            public Payment_Allocation__c paymentAllocation {get;set;}
        }
        //Done by Manigandan.SA on Dec 9, 2015 for INVOICEIT-638
        //Comment: This inner class meant for payment plan installment
        public class PaymentPlanInstallment {
            public integer counter1 {get;set;}        
            public boolean isChecked1 {get;set;}
            public Invoice__c invoice1 {get;set;}
            public Payment_Plan_Installment__c paymentPlanInstallment {get;set;}
            public Payment_Allocation__c ppIpaymentAllocation {get;set;}
            public boolean isVisible1 {get;set;}
            
            public PaymentPlanInstallment(){
                isVisible1 = false;
            }

        }
        
        // Added 'Order__r.Payment_Plan__c = null' , INVOICEIT-630, Restricting automatic payment allocation if Invoice's order has payment plan.
        public static list<Invoice__c> getInvoicesForPayment(Payment__c payment) {
            string sPrefix = CommonUtilClass.getPrefix();
            string sQuery = 'SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Invoice__c')
                                      + 'FROM Invoice__c'
                                      + ' WHERE CurrencyL__c =' + '\'' +  String.escapeSingleQuotes(payment.Currency__c) + '\'' 
                                      + 'AND Account__c =' + '\'' +  String.escapeSingleQuotes(payment.Account__c) + '\''
                                      + 'AND Unpaid_Amount__c > 0'
                                      + ' AND Order__r.Payment_Plan__c = null'
                                      + ' AND '
                                      + '(Invoice_Status__c ='  + '\'' + CommonUtilClass.STATUS_POSTED+ '\'' 
                                      + ' OR'
                                      + '(Invoice_State__c =' + '\'' + CommonUtilClass.STATUS_PROFORMA + '\'' 
                                      + ' AND Invoice_Status__c !=' + '\'' + CommonUtilClass.STATUS_CANCELLED + '\')'
                                      + ')';
            list<Invoice__c> listOfInvoices = Database.query(sQuery);
            return listOfInvoices;                                            
        }
         //Done by Manigandan.SA on Dec 9, 2015 for INVOICEIT-638
         //Comment:  Lists all the payment plan installment for the posted invoices
         public static list<Payment_Plan_Installment__c> getPaymentPlanInstallmentsForPayment(Payment__c payment) {
             string sPrefix = CommonUtilClass.getPrefix();
             string sQuery = 'SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Payment_Plan_Installment__c')
                                       +'FROM Payment_Plan_Installment__c'
                                       + ' WHERE Invoice__r.Invoice_Status__c =' + '\'Posted\'' 
                                       + ' AND Account__c=' + '\'' + String.escapeSingleQuotes(payment.Account__c) + '\'' ;
             list<Payment_Plan_Installment__c> listOfPaymentPlanInstallment = Database.query(sQuery);
             return listOfPaymentPlanInstallment;
         }
    }