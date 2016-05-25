trigger triggerOnPaymentInstalments on Payment_Plan_Installment__c (after update, before delete) {
        
        set<Id> setOfInvoiceIds = new set<Id>();
        list<Invoice__c> listOfInvoices = new list<Invoice__c>();
        Map<string, Integer> mapOfInvoiceIdTONoofInstalments = new Map<string, Integer>();
        List <AggregateResult> PaymentInstalments = new List<AggregateResult>();
        if(trigger.isAfter && trigger.isUpdate){
            for(Payment_Plan_Installment__c paymentPlans :trigger.new){
                if(paymentPlans.Invoice__c != null){
                    setOfInvoiceIds.add(paymentPlans.Invoice__c);
                }
            }
        }
        if(trigger.isBefore && trigger.Isdelete){
            for(Payment_Plan_Installment__c paymentPlans :trigger.old){
                if(paymentPlans.Invoice__c != null){
                    setOfInvoiceIds.add(paymentPlans.Invoice__c);
                }
            }
        }
        
        PaymentInstalments = [Select Invoice__c invoiceId, Count(Id)paymentInstalment From Payment_Plan_Installment__c where Invoice__c In : setOfInvoiceIds group by Invoice__c];
        if(trigger.isBefore && trigger.Isdelete){
            PaymentInstalments = [Select Invoice__c invoiceId, Count(Id)paymentInstalment From Payment_Plan_Installment__c where Invoice__c NOT In : setOfInvoiceIds group by Invoice__c];
        }
        if(!PaymentInstalments.isEmpty()){
            for(AggregateResult ar: PaymentInstalments){
                mapOfInvoiceIdTONoofInstalments.put(string.valueOf(ar.get('invoiceId')),integer.valueof(ar.get('paymentInstalment')));
            }
        }
        
        
        for(Invoice__c Invoice : [select Id,No_Of_Instalments__c From Invoice__c Where Id In: setOfInvoiceIds]){
            Invoice__c invoiceToUpdte;
            listOfInvoices.add(invoiceToUpdte = new Invoice__c (Id = Invoice.id, No_Of_Instalments__c = mapOfInvoiceIdTONoofInstalments.get(Invoice.id)));
            
        }
        
        if(!listOfInvoices.isEmpty()){
            update listOfInvoices;
        }

    }