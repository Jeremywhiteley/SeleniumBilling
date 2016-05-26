public with sharing class ControllerVirtualTerminal {

    public string currentPageId{get;set;}
    public list<Payment_Method__c> listOfPaymentMethod;
    public list<paymentMethodWrapper> listOfPaymentMethodWrapper{get;set;}
    public Account account{get;set;}
    public boolean isNone {get;set;}
    public boolean isCybersource {get;set;}
    public boolean isSaveCardDetails {get;set;}
    public Payment_Method__c paymentMethod {get;set;}
    public boolean isSavePaymentDetailse {get;set;}
    public string sSaveCardDetails {get;set;} 
    public boolean isSavePaymentDetails {get;set;}
    public boolean isSaveAndReload {get;set;} 
    public list<SelectOption> listOfSPCurrency {get;set;}
    public string sSelectedCurrency {get;set;}
    public list<Currency__c> listOfCurrency;
    public Invoice__c invoice{get;set;}
    public decimal dAmount{get;set;}
    public String selectedValue { get; set; }
    public boolean isDisable {get;set;} 
    list<Gateway__c> listOfGateway;
    PaymentMethodWrapper paymentMethodWrapper;
    Gateway__c gateWayToUse;
    public boolean isVisible {get;set;}
    public Contact contactRef{get;set;}   
    public boolean isCountryPickListEnable {get;set;}
    public boolean isStateCountryPickListEnable;
    public string sCountryAPIName {get;set;}
    public string sStateAPIName {get;set;}
    map<string,string> mapOfCountry;   
    public list<String> listOfCardTypes {get;set;}
    public string slistOfCardTypes  {get;set;}
    
    public ControllerVirtualTerminal(ApexPages.StandardController controller) {
        try {
                        
            listOfCardTypes = new list<String>(); 
            Schema.DescribeFieldResult fieldResult = Payment_Method__c.Card_Type__c.getDescribe();
            List<Schema.PicklistEntry> CreditCardPickListValue = fieldResult.getPicklistValues();
            for( Schema.PicklistEntry pickListValue : CreditCardPickListValue)
            {
               listOfCardTypes.add(pickListValue.getValue());
            } 
            slistOfCardTypes = JSON.serialize(listOfCardTypes);
            contactRef = new Contact();
            mapOfCountry = new map<string,string>();  
            isCountryPickListEnable = false;
            // We are using the currentPageId Id as AccountId
            currentPageId = apexPages.currentPage().getParameters().get('Id');
            listOfPaymentMethodWrapper = new list<paymentMethodWrapper>();
            account = new Account();
            paymentMethod = new Payment_Method__c(Payment_Method__c = 'Credit Card');  
            // commented by ram,Sup- 386
            isSavePaymentDetails = true; 
            listOfSPCurrency = new list<SelectOption>();
            isDisable = true;
            isSaveAndReload = false;
            isVisible = false;
            //isCybersource = false;
            
            // added by Ram, Sup- 386
            isSavePaymentDetails = Configuration__c.getValues('SAVE_CREDIT_CARD_ON_PAYMENT_PAGE').Boolean_Value__c;
            isSaveCardDetails = false;
            // If it comes form invoice we intailaze the invoice and assign the account Id & currency
            if(!currentPageId.startsWith('001')) {
                invoice = new Invoice__c();
                invoice = InvoicingUtilClass.getInvoiceById(currentPageId);
                //Added by Shruthi : Ticket No- INVOICEIT-361:For populating amount, billing address in Virtual terminal                
                if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c >0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c){
                    damount = invoice.Payment_Request_Amount__c;  
                }
                else{
                    damount = invoice.Unpaid_Amount__c;
                }
                paymentMethod.Billing_First_Name__c = invoice.Billing_Contact__r.FirstName;
                paymentMethod.Billing_Last_Name__c  = invoice.Billing_Contact__r.LastName;  
                paymentMethod.Billing_Address__c = invoice.Billing_Contact__r.MailingStreet;
                paymentMethod.Billing_City__c = invoice.Billing_Contact__r.MailingCity;
                paymentMethod.Billing_State_Province__c = invoice.Billing_Contact__r.MailingState;
                paymentMethod.Billing_Zip_Postal__c = invoice.Billing_Contact__r.MailingPostalCode;
                paymentMethod.Billing_Country__c = invoice.Billing_Contact__r.MailingCountry;
                currentPageId = invoice.Account__c;
                sSelectedCurrency = invoice.CurrencyL__c;
            }  

            account = [SELECT Gateway__c, Name from Account WHERE Id=:currentPageId];

            if(account.Gateway__c == null) {
                listOfGateway = InvoicingUtilClass.getDefaultGateway();
                if(listOfGateway.isEmpty()) {
                    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.Payment_Gateway_does_not_exists_Please_contact_your_service_provider));  
                    isNone = true;
                    isDisable = false;
                } else {
                    gateWayToUse = listOfGateway.get(0); 
                    if(gateWayToUse.Gateway_Type__c == 'CyberSource_CC_Token'){
              isCybersource = true;}else{
              isCybersource = false;}
                } 
            } else {
                gateWayToUse = [SELECT Name, Merchant_Reference__c, Exact_ID_Security_Key__c, Exact_ID__c, Gateway_Type__c, Merchant_ID__c, Transaction_Security_Key__c, Security_Key__c, Test_Mode__c, Merchant_Seal_User_Id__c,Email_Customer__c
                                FROM Gateway__c
                                WHERE 
                                Id =:account.Gateway__c ];
              if(gateWayToUse.Gateway_Type__c == 'CyberSource_CC_Token'){
              isCybersource = true;}else{
              isCybersource = false;}
                              
            }
            // We are getting default currency
            string defaultCurrency = Configuration__c.getValues('DEFAULT_CURRENCY').String_Value__c;
            isStateCountryPickListEnable = Configuration__c.getValues('ENABLE_STATE_AND_COUNTRY_PICKLIST').Boolean_Value__c;
              
            if(currentPageId.startsWith('001') && gateWayToUse != null) {

                if(defaultCurrency != null) {
                    Currency__c CurrencyLoc = [SELECT Id, Name FROM Currency__c WHERE Name =:defaultCurrency LIMIT 1 ];
                    listOfSPCurrency.add(new SelectOption(CurrencyLoc.Id, CurrencyLoc.Name));
                }                

                if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNET || gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_PAYPAL || gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNETCIM) {
                    if(defaultCurrency != 'USD') {
                        listOfCurrency = [SELECT Id, Name FROM Currency__c WHERE Name = 'USD' LIMIT 1];
                        for(Currency__c CurrencyObj : listOfCurrency) {
                            listOfSPCurrency.add(new SelectOption(CurrencyObj.Id, CurrencyObj.Name));
                        }   
                    }              
                }  else if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_SAGEPAY || gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_WIRECARD || gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_FIRSTDATA || gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_STRIPE || gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_EWAY) {
                    if(defaultCurrency != null) {
                        listOfCurrency = [SELECT Id, Name FROM Currency__c WHERE Name !=: defaultCurrency];
                    } else {
                        listOfCurrency = [SELECT Id, Name FROM Currency__c LIMIT 1000];     
                    } 
                    for(Currency__c CurrencyObj : listOfCurrency) {
                        if( (gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_WIRECARD) && (CurrencyObj.Name == 'BWP' || CurrencyObj.Name == 'CHF' || CurrencyObj.Name == 'DKK' || CurrencyObj.Name == 'EUR' || CurrencyObj.Name == 'GBP' || CurrencyObj.Name == 'INR' || CurrencyObj.Name == 'JPY' || CurrencyObj.Name == 'KWD' || CurrencyObj.Name == 'MYR' || CurrencyObj.Name == 'NOK' || CurrencyObj.Name == 'PHP' || CurrencyObj.Name == 'RUB' || CurrencyObj.Name == 'SEK' || CurrencyObj.Name == 'USD' || CurrencyObj.Name == 'ZAR')) {
                            listOfSPCurrency.add(new SelectOption(CurrencyObj.Id, CurrencyObj.Name));
                        } else if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_FIRSTDATA || gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_STRIPE || gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_EWAY) {
                            listOfSPCurrency.add(new SelectOption(CurrencyObj.Id, CurrencyObj.Name));
                        } else if((gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_SAGEPAY) && (CurrencyObj.Name == 'GBP' || CurrencyObj.Name == 'USD' || CurrencyObj.Name == 'EUR')) {
                            listOfSPCurrency.add(new SelectOption(CurrencyObj.Id, CurrencyObj.Name));
                        }  
                    } 
                }

                if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNETCIM){
                    listOfPaymentMethod = [SELECT Card_Number__c, Card_Type__c, Card_Expiration_Month__c, Card_Expiration_Year__c, CVV__c, Name_on_Card__c, Billing_Country__c,
                                           Bank_Routing_Code__c, Bank_Account_Number__c, Bank_Account_Type__c, Bank_Name__c, Bank_Account_Name__c,
                                           Billing_First_Name__c, Billing_Last_Name__c, Billing_Address__c, Billing_City__c, Billing_State_Province__c, Billing_Zip_Postal__c ,
                                           Account__c, Account__r.Name, Billing_Phone__c, Billing_Fax__c, Billing_Email__c,Payment_Profile_ID__c,Account__r.Customer_Profile_ID__c  
                                           ,Encrypted_Card_Number__c,Encrypted_CVV__c ,Token__c
                                           FROM Payment_Method__c 
                                           WHERE
                                           Account__c =: currentPageId
                                           AND
                                           Active__c = true
                                           AND
                                           Payment_Profile_ID__c != null
                                           AND
                                           Is_Dummy__c = false
                                           AND
                                           Account__r.Customer_Profile_ID__c  != null                                       
                                           AND
                                           Payment_Method__c = 'Credit Card'];
                    isVisible = true;
                } else{    
                    // This is to display the payment methods present for an account
                    listOfPaymentMethod = [SELECT Card_Number__c, Card_Type__c, Card_Expiration_Month__c, Card_Expiration_Year__c, CVV__c, Name_on_Card__c, Billing_Country__c,
                                           Bank_Routing_Code__c, Bank_Account_Number__c, Bank_Account_Type__c, Bank_Name__c, Bank_Account_Name__c,
                                           Billing_First_Name__c, Billing_Last_Name__c, Billing_Address__c, Billing_City__c, Billing_State_Province__c, Billing_Zip_Postal__c ,
                                           Account__c, Account__r.Name, Billing_Phone__c, Billing_Fax__c, Billing_Email__c,Account__r.Customer_Profile_ID__c,Payment_Profile_ID__c 
                                           ,Encrypted_Card_Number__c,Encrypted_CVV__c,Token__c
                                           FROM Payment_Method__c 
                                           WHERE
                                           Account__c =: currentPageId
                                           AND
                                           ((Active__c = true
                                           AND
                                           Card_Type__c != null
                                           AND
                                           Is_Dummy__c = false
                                           AND
                                           Payment_Method__c = 'Credit Card'
                                           AND
                                           Card_Expiration_Month__c != null
                                           AND
                                           Card_Expiration_Year__c != null)
                                           OR Token__c != null)];
                }

                if(!listOfPaymentMethod.isEmpty()) {
                    for(Payment_Method__c paymentMethod : listOfPaymentMethod) {
                        paymentMethodWrapper = new PaymentMethodWrapper(paymentMethod.Id);
                        paymentMethodWrapper.paymentMethod = paymentMethod;
                        listOfPaymentMethodWrapper.add(paymentMethodWrapper);
                    }
                } else {
                    isNone = true;
                }
            }

        } catch(Exception ex) {
            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
            Apexpages.addMessage(errorMessage);
        }   
    }

    public PageReference processPaymentRedirect() {
        
        try{
            //Country picklist code
            if(isStateCountryPickListEnable != null && isStateCountryPickListEnable && Schema.SObjectType.Contact.fields.getMap().containsKey('MailingCountryCode')){
                if(invoice != null && invoice.Billing_Contact__c != null){
                        string contactId = invoice.Billing_Contact__c;
                        string contactInfo = 'select MailingCountry,MailingState, MailingCountryCode, MailingStateCode from Contact where id =:contactId';
                        list<Contact> contactObj = Database.query(contactInfo);  
                        if(!contactObj.isEmpty()) {
                            contactRef = contactObj[0].clone(false);   
                        }                         
                }                                          
                sCountryAPIName = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get('MailingCountryCode').getDescribe().getName();
                sStateAPIName = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap().get('MailingStateCode').getDescribe().getName();
               
                List<Schema.PicklistEntry> countryListValue = Schema.SObjectType.Contact.fields.getMap().get('MailingCountryCode').getDescribe().getPicklistValues();
                for( Schema.PicklistEntry countryName : countryListValue) {
                   mapOfCountry.put(countryName.getValue(),countryName.getLabel()); 
                }         
                
                isCountryPickListEnable = true;  
            }
        
            // Here we are inserting a dummy payment method if there are no dummy payment method                                                   
        }// Added by Mani ticket : INVOICEIT-310
        catch(DMLException dMlEx){
            Apexpages.Message errorMessage; 
            for (Integer i = 0; i < dMlEx.getNumDml(); i++)
            { 
                errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                Apexpages.addMessage(errorMessage);      
            } 
        } catch(Exception ex) {
               Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
               Apexpages.addMessage(errorMessage); 
        }  
        return null; 
    }

    public PageReference processPayment() {
        try {
            
            if(isStateCountryPickListEnable != null && isStateCountryPickListEnable && isCountryPickListEnable){
                    if(mapOfCountry.containsKey((String)contactRef.get('MailingCountryCode'))){
                        paymentMethod.Billing_Country__c = mapOfCountry.get((String)contactRef.get('MailingCountryCode'));              
                    } else {
                        paymentMethod.Billing_Country__c = '';  
                    }
            
                    if((string)contactRef.get('MailingStateCode') != null) {
                        paymentMethod.Billing_State_Province__c = (string)contactRef.get('MailingStateCode');
                    } else if((string)contactRef.get('MailingStateCode') == null){              
                        paymentMethod.Billing_State_Province__c = '';
                    } else {                
                        paymentMethod.Billing_State_Province__c = invoice.Billing_Contact__r.MailingState;  
                    }         
                }

            if(dAmount == null || dAmount == 0) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,system.Label.PleaseEnterAmount));
                selectedValue = null;                          
                return null;
            }

            if(invoice != null) {
                if( dAmount > invoice.Unpaid_Amount__c) {
                    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,system.Label.UnpaidAmount+' '+invoice.Unpaid_Amount__c));
                    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.EnterAmountEqualToUnpaid)); 
                    selectedValue = null;                          
                    return null;
                }
            }

            if((selectedValue == null || selectedValue == '') && (!isNone)) {
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,system.Label.PleaseSelectCard));
                return null;
            }

            PaymentOperations.PaymentResult paymentResult;
            Payment_Method__c paymentMethodLoc = new Payment_Method__c();
            if( paymentMethod.Account__c == null)
                paymentMethod.Account__c = currentPageId;

            Account accountObj = InvoicingUtilClass.getAccountById(currentPageId); 
            // commented by Ram, Sup- 386
            //isSaveCardDetails = false;
            Id dummyId;

            if(isNone) {
                if(paymentMethod.Card_Expiration_Month__c == null || paymentMethod.Card_Expiration_Year__c  == null) {
                    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.Error, system.Label.SelectCardExpirationDate));
                    return null;
                }
                
                  // added by Ram, Sup- 386
                if(isSavePaymentDetails && (sSaveCardDetails == null || sSaveCardDetails == 'none')) {
                  Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,system.Label.SaveCardInformation));
                  return null;
               }
               
               
                paymentMethodLoc = paymentMethod;
                list<Payment_Method__c> listOfdummyPaymentMethod = [SELECT Id FROM Payment_Method__c WHERE Is_Dummy__c = true
                                                                    AND 
                                                                    Account__c =: currentPageId];
                if(!listOfdummyPaymentMethod.isEmpty()) {
                    dummyId = listOfdummyPaymentMethod.get(0).Id;
                }  
                
                if(sSaveCardDetails == 'yes') {
                    isSaveCardDetails = true;
                }else if(sSaveCardDetails == 'no'){
                    isSaveCardDetails = false;
                }            
            } else {
                 // added by Ram, Sup- 386
                isSaveCardDetails = false;
                for(PaymentMethodWrapper paymentMethodWrapper : listOfPaymentMethodWrapper){
                    if(selectedValue == PaymentMethodWrapper.paymentMethod.Id) {
                        paymentMethodLoc = PaymentMethodWrapper.paymentMethod;
                        dummyId = paymentMethodLoc.Id ;
                        break;
                    }
                }
            }

            if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNET) {
                ClassForHandlingAuthorizeDotNet classForHandlingAuthorizeDotNet = new ClassForHandlingAuthorizeDotNet(gateWayToUse, invoice, paymentMethodLoc, dummyId, dAmount, accountObj, sSelectedCurrency); 
                paymentResult = classForHandlingAuthorizeDotNet.handleAuthorizeAndCharge_Site(isSaveCardDetails); 
            } else if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_PAYPAL) {
                ClassForHandlingPaypal classForHandlingPaypal = new ClassForHandlingPaypal(gateWayToUse, invoice, paymentMethodLoc, dummyId, dAmount, accountObj, sSelectedCurrency); 
                paymentResult = classForHandlingPaypal.handleAuthorizeAndCharge_Site(isSaveCardDetails); 
            } else if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_WIRECARD) {
                ClassForHandlingWireCard classForHandlingWireCard = new ClassForHandlingWireCard(gateWayToUse, invoice, paymentMethodLoc, dummyId, dAmount, accountObj, sSelectedCurrency ); 
                paymentResult = classForHandlingWireCard.handleAuthorizeAndCharge_Site(isSaveCardDetails); 
            }  else if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_FIRSTDATA) {
                ClassForHandlingFirstdataCard classForHandlingFirstdataCard = new ClassForHandlingFirstdataCard(gateWayToUse, invoice, paymentMethodLoc, dummyId, dAmount, accountObj, sSelectedCurrency ); 
                paymentResult = classForHandlingFirstdataCard.handleAuthorizeAndCharge_Site(isSaveCardDetails); 
            } else if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_AUTHORIZEDOTNETCIM) {
                ClassForHandlingAuthorizeDotNetCIM classForHandlingAuthorizeDotNetCIM = new ClassForHandlingAuthorizeDotNetCIM(gateWayToUse, invoice, paymentMethodLoc, dummyId, dAmount, accountObj, sSelectedCurrency ); 
                paymentResult = classForHandlingAuthorizeDotNetCIM.handleAuthorizeAndCharge_Site(isSaveCardDetails); 
            }  else if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_STRIPE) {
                ClassForHandlingStripeCard classForHandlingStripeCard = new ClassForHandlingStripeCard(gateWayToUse, invoice, paymentMethodLoc, dummyId, dAmount, accountObj, sSelectedCurrency); 
                paymentResult = classForHandlingStripeCard.handleAuthorizeAndCharge_Site(isSaveCardDetails); 
            }  else if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_SAGEPAY) {
                ClassForHandlingSagePay classForHandlingSagePay = new ClassForHandlingSagePay(gateWayToUse, invoice, paymentMethodLoc, dummyId, dAmount, accountObj, sSelectedCurrency); 
                paymentResult = classForHandlingSagePay.handleAuthorizeAndCharge_Site(isSaveCardDetails); 
            }   else if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_EWAY) {
                string s1 = dAmount.toPlainString();
                decimal dAmountNew = dAmount;
                if(!s1.contains('.')){
                    s1 = s1 + '.00';
                    dAmountNew = decimal.valueof(s1);
                }   
                ClassForHandlingEway classForHandlingEway = new ClassForHandlingEway(gateWayToUse, invoice, paymentMethodLoc, dummyId, dAmountNew, accountObj, sSelectedCurrency ); 
                paymentResult = classForHandlingEway.handleAuthorizeAndCharge_Site(isSaveCardDetails); 
            } else if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_BRAINTREE) {
                ClassForHandlingBrainTree classForHandlingBrainTree = new ClassForHandlingBrainTree(gateWayToUse, invoice, paymentMethodLoc, dummyId, dAmount, accountObj, sSelectedCurrency); 
                paymentResult = classForHandlingBrainTree.handleAuthorizeAndCharge_Site(isSaveCardDetails); 
            }  else if(gateWayToUse.Gateway_Type__c == CommonUtilClass.GATEWAY_TYPE_CyberSource_CC_Token) {
                ClassForHandlingCyberSourceForCreditCard classForHandlingCyberSourceForCreditCard = new ClassForHandlingCyberSourceForCreditCard(gateWayToUse, invoice, paymentMethodLoc, dummyId, dAmount, accountObj, sSelectedCurrency); 
                paymentResult = classForHandlingCyberSourceForCreditCard.handleAuthorizeAndCharge_Site(isSaveCardDetails); 
                //isCybersource = true;
            } 

            // This is use to show the end user transcation Id
            if(paymentResult.transactionObj != null) {
                list<Transaction__c> TransactionObj = [SELECT Name,Response__c,Response_Message__c,Authorization__c FROM Transaction__c WHERE ID=:paymentResult.transactionObj.Id ];
                isDisable = false;
                if(paymentResult.transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {           
                    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.Label.Payment_Success_message));
                } else {
                    Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, paymentResult.message));
                }
                if(TransactionObj[0].Name!=null)
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.Label.InvoiceITTransactionReferenceNumber+ ' ' +TransactionObj[0].Name ));
                if(TransactionObj[0].Response__c!=null)
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.Label.GatewayResponse+' ' +TransactionObj[0].Response__c));
                if(TransactionObj[0].Authorization__c!=null)
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.Label.GatewayAuthorizationCode+' ' +TransactionObj[0].Authorization__c ));
                isSaveAndReload = true;
            }else {
                 if(paymentResult.message!=null)
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.INFO, system.Label.ErrorMessage+' ' +paymentResult.message ));
            }
        } catch(Exception ex) {
            Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
            Apexpages.addMessage(errorMessage);

        }
        return null;
    }

    public class PaymentMethodWrapper {
        public Payment_Method__c paymentMethod{get;set;}
        public String Value { get; set; }

        public paymentMethodWrapper(String Value) {
            paymentMethod = new Payment_Method__c();
            this.Value = Value;
        }
    }
}