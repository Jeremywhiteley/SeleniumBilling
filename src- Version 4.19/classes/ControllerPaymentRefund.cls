public with sharing class ControllerPaymentRefund {
    public Payment__c payment {get;set;}
    public String sPrefix {get; set;}
    public Refund__c refund{get;set;}
    public list<ControllerPaymentRefund.payments> listOfPaymentsClass{get;set;}
    public map<Integer, ControllerPaymentRefund.payments> map_Counter_paymentsClass {set; get;}
    public ControllerPaymentRefund(ApexPages.StandardController controller){
        sPrefix = CommonUtilClass.getPrefix();
        payment = (Payment__c)controller.getRecord();
        listOfPaymentsClass = new list<ControllerPaymentRefund.payments>();
        string sQuery = 'SELECT '+ CommonUtilClass.getObjectFields(sPrefix+'Payment__c')
                        + 'FROM Payment__c '
                        + ' WHERE Id =' + '\'' + payment.id+ '\'';
        sQuery = String.escapeSingleQuotes(sQuery);
        sQuery = sQuery.replace('\\', '');
        payment = Database.query(sQuery);
        refund = new Refund__c();
        listOfPaymentsClass = new list<ControllerPaymentRefund.payments>();
        map_Counter_paymentsClass = new map<Integer, ControllerPaymentRefund.payments>();
        ControllerPaymentRefund.payments paymentsClass;
        integer counter = 0;
        if(payment != null){
            paymentsClass = new ControllerPaymentRefund.payments();
            paymentsClass.counter = ++counter;
            paymentsClass.payment = payment;
            paymentsClass.refundAmount = 0;
            paymentsClass.isChecked = false;
            listOfPaymentsClass.add(paymentsClass);
            map_Counter_paymentsClass.put(counter,paymentsClass);
        }
        if(payment.Status__c == 'Cancelled'){
            Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO, System.Label.Payment_Cancelled);
            Apexpages.addMessage(infoMessage);
        }
        else if(payment.Status__c == 'Completed' && payment.Unallocated_Amount__c <= 0){
            Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO, System.Label.Payment_Refund);
            Apexpages.addMessage(infoMessage);
        }
        else if(payment.Status__c == 'Initiated'){
            Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO, System.Label.Refund_Payment_Status);
            Apexpages.addMessage(infoMessage);
        }
    }
    
    public pagereference createRefunds(){
        boolean isExecute = false;
        boolean isExecuteNew = false;
        for(ControllerPaymentRefund.payments paymentClass: listOfPaymentsClass){
            if(paymentClass.isChecked){
                isExecuteNew = true;
            }
            if(paymentClass.isChecked && paymentClass.refundAmount <=  0){
                isExecute = true;
            }
        }
        if(isExecute){
            Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO, System.Label.Refund_Amount);
            Apexpages.addMessage(infoMessage);
            return null;
        }
        if(!isExecuteNew){
            Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO, System.Label.Payment_To_Refund);
            Apexpages.addMessage(infoMessage);
            return null;
        }
        refund.Account__c = payment.Account__c;
        refund.Currency__c = payment.Currency__c;
        if(refund.Refund_Date__c != null){
            refund.Refund_Date__c = refund.Refund_Date__c;
        }
        if(refund.Refund_Description__c != null){
            refund.Refund_Description__c = refund.Refund_Description__c;
        }
        decimal conversionRate = 1;
        if(UserInfo.isMultiCurrencyOrganization()){
            string sQuery =   'SELECT ISOCode, ConversionRate, StartDate, NextStartDate FROM DatedConversionRate '
                        + 'WHERE ISOCode = \'' + refund.Currency__r.Name + '\''
                        + ' AND StartDate <= ' + refund.Refund_Date__c + ' LIMIT 1';
            sQuery = String.escapeSingleQuotes(sQuery); 
            list<sobject> sobjectDatedConversionRates = Database.query(sQuery);
            list<sobject> listofCurrencyType = Database.query('SELECT IsoCode FROM CurrencyType WHERE IsCorporate = true');
            if(sobjectDatedConversionRates.size() > 0) {
                if(listofCurrencyType[0].get('IsoCode') == refund.Currency__r.Name) {
                    conversionRate = (decimal) sobjectDatedConversionRates[0].get('ConversionRate');
                    refund.Exchange_Rate_Applied__c = conversionRate;
                }
            }
        }else{
            refund.Exchange_Rate_Applied__c = conversionRate;
        }
        insert refund;
        list<Refund_Line__c> listOfRefundLinesToInsert = new list<Refund_Line__c>();
        for(ControllerPaymentRefund.payments paymentClass: listOfPaymentsClass){
            Refund_Line__c refundLine = new Refund_Line__c();
            if(paymentClass.isChecked){
                refundLine.Payment__c = paymentClass.payment.id;
                refundLine.Refund__c = refund.id;
                refundLine.Refund_Amount__c = paymentClass.refundAmount;
                listOfRefundLinesToInsert.add(refundLine);
            }
        }
        if(!listOfRefundLinesToInsert.isEmpty()){
            insert listOfRefundLinesToInsert;
        }
        return new PageReference('/' + payment.Id);
    }
    
    public class payments{
        public boolean isChecked {get;set;}
        public decimal refundAmount {get;set;}
        public integer counter {get;set;}      
        public Payment__c payment {get;set;}
    }
}