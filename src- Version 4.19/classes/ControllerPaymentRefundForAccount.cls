public with sharing class ControllerPaymentRefundForAccount {
    public Account account{get;set;}
    public Refund__c refund{get;set;}
    public boolean isDisplay{get;set;}
    public list<Payment__c> listOfPayments{get;set;}
    public list<ControllerPaymentRefundForAccount.payments> listOfPaymentsClass{get;set;}
    public map<Integer, ControllerPaymentRefundForAccount.payments> map_Counter_paymentClass {set; get;}
    public  String sPrefix {get; set;}
    
    public ControllerPaymentRefundForAccount(ApexPages.StandardController controller) {
        account = (Account)controller.getRecord(); 
        sPrefix = CommonUtilClass.getPrefix();
        isDisplay = false;
        refund = new Refund__c();
        listOfPayments = new list<Payment__c>();
    }
    public void displayPayments(){
        isDisplay = true;
        listOfPayments = new list<Payment__c>();
        string sQuery = 'SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Payment__c')
                        + ' FROM Payment__c '
                        + ' WHERE Account__c =' + '\'' + account.id+ '\''
                        + ' AND Unallocated_Amount__c > 0' 
                        + ' AND Status__c = \'Completed\''
                        +' AND Currency__c =' + '\'' + refund.Currency__c+ '\'';
                        
        sQuery = String.escapeSingleQuotes(sQuery);
        sQuery = sQuery.replace('\\', '');
        listOfPayments = Database.query(sQuery);
        listOfPaymentsClass = new list<ControllerPaymentRefundForAccount.payments>();
        map_Counter_paymentClass = new map<Integer, ControllerPaymentRefundForAccount.payments>();
        ControllerPaymentRefundForAccount.payments paymentsClass;
        integer counter = 0;
        if(!listOfPayments.isEmpty()){
            for(Payment__c payment: listOfPayments){
                paymentsClass = new ControllerPaymentRefundForAccount.payments();
                paymentsClass.counter = ++counter;
                paymentsClass.payment = payment;
                paymentsClass.refundAmount = 0;
                paymentsClass.isChecked = false;
                listOfPaymentsClass.add(paymentsClass);
                map_Counter_paymentClass.put(counter,paymentsClass);
            }
        }
        else{
            Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO, System.Label.Payment_Records);
            Apexpages.addMessage(infoMessage);
        }

    }
    public pagereference createRefunds() {
        boolean isExecute = false;
        boolean isExecuteNew = false;
        for(ControllerPaymentRefundForAccount.payments paymentClass: listOfPaymentsClass){
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
        refund.Account__c = account.id;
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
        for(ControllerPaymentRefundForAccount.payments paymentClass: listOfPaymentsClass){
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
        return new PageReference('/' + account.Id);
    }
    public class payments{
        public boolean isChecked {get;set;}
        public decimal refundAmount {get;set;}
        public integer counter {get;set;}      
        public Payment__c payment {get;set;}
    }
}