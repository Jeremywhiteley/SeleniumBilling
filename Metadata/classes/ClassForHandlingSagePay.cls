/**
 * Webservice for handling payments.
 *
 * @author Vinod KR 
 * @author Sagarika Rout,Naveen
 * @author Acertis Cloud Ltd
   Copyright (c) 2014, Acertis Cloud, Salesforce.com Inc.
   All rights reserved.
 */

/*

 Use the following Endpoint for the Sage Pay:

        1 For live use: 

            Authenticate or Direct Payment URL = https://live.sagepay.com/gateway/service/vspdirect-register.vsp
            AuthoriseURL = https://live.sagepay.com/gateway/service/authorise.vsp
            VoidURL = https://live.sagepay.com/gateway/service/void.vsp
            RefundURL = https://live.sagepay.com/gateway/service/refund.vsp
            ReleaseURL = https://live.sagepay.com/gateway/service/release.vsp
            RepeatURL = "ttps://live.sagepay.com/gateway/service/repeat.vsp
            CallbackURL = https://live.sagepay.com/gateway/service/direct3dcallback.vsp 

        2 For testing use: 

            Authenticate or Direct Payment URL = https://test.sagepay.com/gateway/service/vspdirect-register.vsp
            Authorise - Charge URL = https://test.sagepay.com/gateway/service/authorise.vsp
            Void URL = https://test.sagepay.com/gateway/service/void.vsp
            Refund URL = https://test.sagepay.com/gateway/service/refund.vsp
            Release URL = https://test.sagepay.com/gateway/service/release.vsp
            Repeat URL = https://test.sagepay.com/gateway/service/repeat.vsp
            Callback URL = https://test.sagepay.com/gateway/service/direct3dcallback.vsp

Attributes :

    CreditCardNumber(Required)
    ExpirationYear(Required)
    ExpirationMonth(Required)
    Type(Required)
    Amount(Required)
    CVV(A conditional (con.) message field must be included in some instances. Its omission may cause the process request type to be rejected)

    Demo Test cards
    4929000000006 VISA is Visa 
    5404000000000001 MC is MasterCard 
    5573470000000001 MCDEBIT is Debit MasterCard 
    4462000000000003 DELTA is Visa Debit 
    300000000000000004 MAESTRO is Domestic and International issued Maestro 
    4917300000000008 UKE is Visa Electron 
    374200000000004 AMEX is American Express 
    36000000000008 DC is Diners Club International and Discover 
    3569990000000009 JCB is Japan Credit Bureau 


 */ 

public with sharing class ClassForHandlingSagePay implements InterfacePaymentClass.paymentOperationsInterface {

    private map<string, string> parameters = new Map<string, string>();
    private string sHttpBody = '';
    private string sHttpEndPoint = '';
    private string sHttpResponse;
    private Payment_Method__c paymentMethod;
    private Gateway__c gateway;
    private Invoice__c invoice;
    private PaymentOperations.PaymentResult result = new PaymentOperations.PaymentResult();
    private Transaction__c transactionObj;
    private string sDummyPaymentId;
    private Account account;
    private decimal dAmount;
    private String sFirstName = '';
    private String sLastName = '';
    private String sAddress1 = '';
    private String sCity = '';
    private String sZipCode = '';
    private String sState = '';
    private String sCountry = '';
    private String sPhone = '';
    private String sEmail = '';
    private string cardType = '';
    string sCountryCode;
    map<string, Country_Codes__c> map_CountryName_Code = new map<string, Country_Codes__c>();
    // this variable is declared because on force.com site page if user selected the savecard information.
    boolean isSavePaymentMethod = false;
    //This is used for Virtualterminal Purpose
    private Id currencyId;
    map<string, string>  map_StateName_Code = new map<string, string>();
    //This is used for Virtualterminal Purpose
    
    private boolean isGenericMethodCall = true;

    public void frameMapStateNameANDCode() {
        map_StateName_Code.put('alabama','AL');
        map_StateName_Code.put('alaska','AK');
        map_StateName_Code.put('arizona','AZ');
        map_StateName_Code.put('arkansas','AR');
        map_StateName_Code.put('california','CA');
        map_StateName_Code.put('colorado','CO');
        map_StateName_Code.put('connecticut','CT');
        map_StateName_Code.put('delaware','DE');
        map_StateName_Code.put('florida','FL');
        map_StateName_Code.put('georgia','GA');
        map_StateName_Code.put('hawaii','HI');
        map_StateName_Code.put('idaho','ID');
        map_StateName_Code.put('illinois','IL');
        map_StateName_Code.put('indiana','IN');
        map_StateName_Code.put('iowa','IA');
        map_StateName_Code.put('kansas','KS');
        map_StateName_Code.put('kentucky','KY');
        map_StateName_Code.put('louisiana','LA');
        map_StateName_Code.put('maine','ME');
        map_StateName_Code.put('maryland','MD');
        map_StateName_Code.put('massachusetts','MA');
        map_StateName_Code.put('michigan','MI');
        map_StateName_Code.put('minnesota','MN');
        map_StateName_Code.put('mississippi','MS');
        map_StateName_Code.put('missouri','MO');
        map_StateName_Code.put('montana','MT');
        map_StateName_Code.put('nebraska','NE');
        map_StateName_Code.put('nevada','NV');
        map_StateName_Code.put('new hampshire','NH');
        map_StateName_Code.put('new jersey','NJ');
        map_StateName_Code.put('new mexico','NM');
        map_StateName_Code.put('new york','NY');
        map_StateName_Code.put('north carolina','NC');
        map_StateName_Code.put('north dakota','ND');
        map_StateName_Code.put('ohio','OH');
        map_StateName_Code.put('oklahoma','OK');
        map_StateName_Code.put('oregon','OR');
        map_StateName_Code.put('pennsylvania','PA');
        map_StateName_Code.put('rhode island','RI');
        map_StateName_Code.put('south carolina','SC');
        map_StateName_Code.put('south dakota','SD');
        map_StateName_Code.put('tennessee','TN');
        map_StateName_Code.put('texas','TX');
        map_StateName_Code.put('utah','UT');
        map_StateName_Code.put('vermont','VT');
        map_StateName_Code.put('virginia','VA');
        map_StateName_Code.put('washington','WA');
        map_StateName_Code.put('west virginia','WV');
        map_StateName_Code.put('wisconsin','WI');
        map_StateName_Code.put('wyoming','WY');
        map_StateName_Code.put('district of columbia','DC');
    }

    public ClassForHandlingSagePay(Gateway__c gateway, Invoice__c invoice, Payment_Method__c paymentMethod,string sDummyPaymentId,decimal dAmount,Account account, Id currencyId) {
        this.invoice = invoice;
        this.account = account;
        this.dAmount = dAmount;
        this.paymentMethod = paymentMethod;
        this.gateway = gateway; 
        this.sDummyPaymentId = sDummyPaymentId;
        this.currencyId = currencyId;
        map_CountryName_Code = Country_Codes__c.getAll();
        
        populateCustomerDetails();   
        // By Dev Ticket : INVOICEIT-429
        if(paymentMethod.Card_Type__c == 'Visa') {
            cardType = 'VISA';
        } else if (paymentMethod.Card_Type__c == 'Master'  || paymentMethod.Card_Type__c == 'Mastercard') {
            cardType = 'MC';
        } else if (paymentMethod.Card_Type__c == 'American Express') {
            cardType = 'AMEX';
        } else {
            cardType = paymentMethod.Card_Type__c;
        }
    } 

    public PaymentOperations.PaymentResult handleAuthorize_Click() {
        try {
            decimal amountToBeProcessed = 0;

            if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                amountToBeProcessed = invoice.Payment_Request_Amount__c;            
            } else {
                amountToBeProcessed = invoice.Unpaid_Amount__c;         
            }

            string sAmount = amountToBeProcessed.toPlainString().replace('.', '');
            string sExpirationYear = string.ValueOf(paymentMethod.Card_Expiration_Year__c).substring(2,4);

            if(verfiybillandState())
                return result; 

            Integer iRandNumber = Math.round(Math.random()*1000);
            
            String authorizationRequest ='VPSProtocol=2.23'+'&TxType=AUTHENTICATE'+'&Vendor='+gateway.Merchant_Seal_User_Id__c+'&VendorTxCode='+invoice.id+iRandNumber+'&Amount='+amountToBeProcessed+'&Currency='+invoice.CurrencyL__r.Name+'&Description='+invoice.Name+'&CardHolder='+paymentMethod.Name_on_Card__c+'&CardNumber='+paymentMethod.Card_Number__c+'&ExpiryDate='+paymentMethod.Card_Expiration_Month__c+sExpirationYear+'&CardType='+cardType+'&CV2='+paymentMethod.CVV__c+'&BillingAddress1='+sAddress1+'&BillingSurname='+sLastName+'&BillingFirstnames='+sFirstName+'&BillingCity='+sCity+'&BillingPostcode='+sZipCode+'&BillingCountry='+sCountryCode+'&BillingState='+sState+'&DeliverySurname='+sLastName+'&DeliveryFirstnames='+sFirstName+'&DeliveryAddress1='+sAddress1+'&DeliveryCity='+sCity+'&DeliveryPostcode='+sZipCode+'&DeliveryCountry='+sCountryCode+'&DeliveryState='+sState+'&Apply3DSecure=2';
            authorizationRequest = authorizationRequest.replaceAll('(\\s+)', '');  

            String encodedUrlParameter = EncodingUtil.urlEncode(authorizationRequest, 'UTF-8');
            transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_AUTHORIZATION, Amount__c = amountToBeProcessed, Currency__c = invoice.CurrencyL__c, Payment_Gateway__c = gateway.Id, Is_Payment_Processed_Successfully__c = true);
            transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
            transactionObj.Request_Invoice__c = invoice.Id;
            transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
            transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_AUTHORIZATION;
            transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
            transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
            transactionObj.Card_Type__c = paymentMethod.Card_Type__c;   
            transactionObj.Currency__c = currencyId;
            transactionObj.Authorization__c = invoice.id+String.valueOf(iRandNumber);
            
            if(gateway.Test_Mode__c) {
                sHttpEndPoint = CommonUtilClass.ENDPOINT_SAGEPAY_AUTHENTICATE_OR_PAYMENT_URL_TEST+authorizationRequest;
            } else {
                sHttpEndPoint = CommonUtilClass.ENDPOINT_SAGEPAY_AUTHENTICATE_OR_PAYMENT_URL_LIVE+authorizationRequest;
            }      

            sendHttpRequest(sHttpEndPoint);
        } catch(Exception ex) {
            result.message = ex.getMessage();
        }
        result.message += sCountryCode;
        return result; 
    }

    public PaymentOperations.PaymentResult handleAuthorizeAndCharge_Click(string transactionId, string gatewayID) {
        try {
            decimal amountToBeProcessed = 0;
            Integer iRandNumber = Math.round(Math.random()*1000);
            string amount = amountToBeProcessed.toPlainString().replace('.', '');
            string sExpirationYear = string.ValueOf(paymentMethod.Card_Expiration_Year__c).substring(2,4);
            String authorizationRequest;

            if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                amountToBeProcessed = invoice.Payment_Request_Amount__c;            
            } else {
                amountToBeProcessed = invoice.Unpaid_Amount__c;         
            }

            if(verfiybillandState())
                return result; 
            if(transactionId == null) {
                transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                        Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, 
                        Amount__c = amountToBeProcessed, Request_Invoice__c = invoice.Id,
                        Currency__c = invoice.CurrencyL__c, Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                        Payment_Gateway__c = gateway.Id, Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE,
                        Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c, Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c,
                        Card_Type__c = paymentMethod.Card_Type__c, Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length())
                );
                
                authorizationRequest ='VPSProtocol=2.23'+'&TxType=PAYMENT'+'&Vendor='+gateway.Merchant_Seal_User_Id__c+'&VendorTxCode='+invoice.id+iRandNumber+'&Amount='+amountToBeProcessed+'&Currency='+invoice.CurrencyL__r.Name+'&Description='+invoice.Name+'&CardHolder='+paymentMethod.Billing_Last_Name__c+ paymentMethod.Billing_First_Name__c +''+'&CardNumber='+paymentMethod.Card_Number__c+'&ExpiryDate='+paymentMethod.Card_Expiration_Month__c+sExpirationYear+'&CardType='+cardType+'&CV2='+paymentMethod.CVV__c+'&BillingAddress1='+sAddress1+'&BillingSurname='+sLastName+'&BillingFirstnames='+sFirstName+'&BillingCity='+sCity+'&BillingPostcode='+sZipCode+'&BillingCountry='+sCountryCode+'&BillingState='+sState+'&DeliverySurname='+sLastName+'&DeliveryFirstnames='+sFirstName+'&DeliveryAddress1='+sAddress1+'&DeliveryCity='+sCity+'&DeliveryPostcode='+sZipCode+'&DeliveryCountry='+sCountryCode+'&DeliveryState='+sState+'&Apply3DSecure=2';
                authorizationRequest = authorizationRequest.replaceAll('(\\s+)', '');  
                
                if(gateway.Test_Mode__c) {
                    sHttpEndPoint = CommonUtilClass.ENDPOINT_SAGEPAY_AUTHENTICATE_OR_PAYMENT_URL_TEST+authorizationRequest;
                } else {
                    sHttpEndPoint = CommonUtilClass.ENDPOINT_SAGEPAY_AUTHENTICATE_OR_PAYMENT_URL_LIVE+authorizationRequest;
                } 

            } else {
                Transaction__c transactionObj1 = [ SELECT Name, Gateway_ID__c,Authorization__c,Response_Code__c,Response_Message__c,Response_Status__c
                                                   FROM Transaction__c
                                                   WHERE Id =:transactionId 
                                                   ];
                transactionObj = new Transaction__c(Id = transactionId, Payment_Method__c = paymentMethod.Id,
                        Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE,
                        Amount__c = amountToBeProcessed, Request_Invoice__c = invoice.Id,
                        Currency__c = invoice.CurrencyL__c, Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                        Payment_Gateway__c = gateway.Id, Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE,
                        Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c, Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c,
                        Card_Type__c = paymentMethod.Card_Type__c, Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length())
                );

                authorizationRequest ='VPSProtocol=2.23'+'&TxType=AUTHORISE'+'&Vendor='+gateway.Merchant_Seal_User_Id__c+'&VendorTxCode='+invoice.id+iRandNumber+'&Amount='+amountToBeProcessed+'&Description='+invoice.Name+'&RelatedVPSTxId='+transactionObj1.Response_Code__c+'&RelatedVendorTxCode='+transactionObj1.Authorization__c+'&RelatedSecurityKey='+transactionObj1.Gateway_ID__c+'';
                authorizationRequest = authorizationRequest.replaceAll('(\\s+)', '');     
                
                if(gateway.Test_Mode__c) {
                    sHttpEndPoint = CommonUtilClass.ENDPOINT_SAGEPAY_AUTHORIZE_URL_TEST+authorizationRequest;
                    //sHttpEndPoint = 'https://test.sagepay.com/showpost/showpost.asp?'+authorizationRequest;
                } else {
                    sHttpEndPoint = CommonUtilClass.ENDPOINT_SAGEPAY_AUTHORIZE_URL_LIVE+authorizationRequest;
                } 
            }  
                
            sendHttpRequest(sHttpEndPoint);    
 
            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                //create the payment and payment allocation against the inv
                InvoicingUtilClass.createPaymentAndPaymentAllocation(invoice, transactionObj); 
                transactionObj.Authorization__c = invoice.id+String.valueOf(iRandNumber);
                transactionObj.Is_Payment_Processed_Successfully__c = true;
                update transactionObj;                                                                 
            } 

        } catch(Exception ex) {
            result.message += '\n \n'+ system.Label.ExceptionOccurred + ex.getMessage();

            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                result.message += '\n \n '+system.Label.InvoiceIsCharged;
                transactionObj.Is_Payment_Processed_Successfully__c = false;
                transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                upsert transactionObj;   
            }
        }
        return result;          
    }
    
    
   /* =================== Start ====================================== */

    /*
    Modified By          : Madhu Keshav   :26 Nov 2015 : INVOICEIT-641
    Comments          : Creating a generic method for processing all payments. This will be used in global methods and API
    */
    
   public PaymentSiteOperation.GenericPaymentResult handleAuthorizeAndCharge(PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters)
    {
        isGenericMethodCall = false;
        PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new  PaymentSiteOperation.GenericPaymentResult();
        try {
   
            decimal amountToBeProcessed = genericPaymentParameters.amountToProcess;
            Integer iRandNumber = Math.round(Math.random()*1000);
            string amount = amountToBeProcessed.toPlainString().replace('.', '');
            string sExpirationYear = string.ValueOf(paymentMethod.Card_Expiration_Year__c).substring(2,4);
            String authorizationRequest;

            if(verfiybillandState())
                return null; 


            transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                        Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, 
                        Amount__c = amountToBeProcessed, Request_Invoice__c = invoice.Id,
                        Currency__c = invoice.CurrencyL__c, Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                        Payment_Gateway__c = gateway.Id, Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE,
                        Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c, Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c,
                        Card_Type__c = paymentMethod.Card_Type__c, Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length()));
                                                    

            authorizationRequest ='VPSProtocol=2.23'+'&TxType=PAYMENT'+'&Vendor='+gateway.Merchant_Seal_User_Id__c+'&VendorTxCode='+invoice.id+iRandNumber+'&Amount='+amountToBeProcessed+'&Currency='+genericPaymentParameters.currencyISOCode+'&Description='+invoice.Name+'&CardHolder='+paymentMethod.Billing_Last_Name__c+ paymentMethod.Billing_First_Name__c +''+'&CardNumber='+paymentMethod.Card_Number__c+'&ExpiryDate='+paymentMethod.Card_Expiration_Month__c+sExpirationYear+'&CardType='+cardType+'&CV2='+paymentMethod.CVV__c+'&BillingAddress1='+sAddress1+'&BillingSurname='+sLastName+'&BillingFirstnames='+sFirstName+'&BillingCity='+sCity+'&BillingPostcode='+sZipCode+'&BillingCountry='+sCountryCode+'&BillingState='+sState+'&DeliverySurname='+sLastName+'&DeliveryFirstnames='+sFirstName+'&DeliveryAddress1='+sAddress1+'&DeliveryCity='+sCity+'&DeliveryPostcode='+sZipCode+'&DeliveryCountry='+sCountryCode+'&DeliveryState='+sState+'&Apply3DSecure=2';
            authorizationRequest = authorizationRequest.replaceAll('(\\s+)', '');  
                
            if(gateway.Test_Mode__c) {
                    sHttpEndPoint = CommonUtilClass.ENDPOINT_SAGEPAY_AUTHENTICATE_OR_PAYMENT_URL_TEST+authorizationRequest;
                } else {
                    sHttpEndPoint = CommonUtilClass.ENDPOINT_SAGEPAY_AUTHENTICATE_OR_PAYMENT_URL_LIVE+authorizationRequest;
                } 
                
            sendHttpRequest(sHttpEndPoint);  
            
            genericPaymentResult.transactionObj = transactionObj;
            genericPaymentResult.message = transactionObj.Response_Status__c; 
                
            if(transactionObj.Exception_Message__c != null){
                genericPaymentResult.message = transactionObj.Exception_Message__c;
            }

            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED){
                genericPaymentResult.isSuccess = true;
            }else{
                genericPaymentResult.isSuccess = false;
            }
            return genericPaymentResult;

            } catch (Exception ex) {
                genericPaymentResult.message += '\n \n ' + system.Label.ExceptionOccurred;
                genericPaymentResult.message += 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                genericPaymentResult.isSuccess = false;
                 
                return genericPaymentResult;   
        }
      return null;        
    }
    
 /* =================== ended ====================================== */
    
    public PaymentOperations.PaymentResult handleVoid_Click(string gatewayId, string transactionId, decimal transactionAmount) {
        try {
            string amount = transactionAmount.toPlainString().replace('.', '');
            string authorizationRequest = '';
            Integer iRandNumber = Math.round(Math.random()*1000);
            list<Transaction__c> transactions = [   SELECT Name, Gateway_ID__c,Authorization__c,Response_Code__c,Card_Code_Response__c
                                                    FROM Transaction__c
                                                    WHERE Id =:transactionId 
                                                    LIMIT 1
                                                    ];

            transactionObj = new Transaction__c(Id = transactions[0].Id,
                    Payment_Method__c = paymentMethod.Id, 
                    Type__c = CommonUtilClass.TRANSACTION_TYPE_VOID, 
                    Gateway_ID__c = gatewayId, 
                    Amount__c = transactionAmount, 
                    Payment_Gateway__c = gateway.Id
            );

            transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
            if(invoice != null)
            {
                transactionObj.Request_Invoice__c = invoice.Id;
            }
            transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
            transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_VOID;
            transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
            transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
            transactionObj.Card_Type__c = paymentMethod.Card_Type__c; 

            authorizationRequest ='VPSProtocol=2.23'+'&TxType=VOID'+'&Vendor='+gateway.Merchant_Seal_User_Id__c+''+'&VendorTxCode='+transactions.get(0).Authorization__c+'&VPSTxId='+transactions.get(0).Response_Code__c+'&SecurityKey='+transactions.get(0).Gateway_ID__c+''+'&TxAuthNo='+transactions.get(0).Card_Code_Response__c+'';

            if(gateway.Test_Mode__c) {
                sHttpEndPoint = CommonUtilClass.ENDPOINT_SAGEPAY_VOID_URL_TEST+authorizationRequest;
            } else {
                sHttpEndPoint = CommonUtilClass.ENDPOINT_SAGEPAY_VOID_URL_LIVE+authorizationRequest;
            } 
            sendHttpRequest(sHttpEndPoint);

            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                //cancel the payment 
                InvoicingUtilClass.cancelPayment(transactionObj.Id);
            } 

        } catch(Exception ex) {
            result.message += '\n \n '+ system.Label.ExceptionOccurred + ex.getMessage();
        } 
        return result;
    }

    public PaymentOperations.PaymentResult handleRefund_Click(string gatewayId, string transactionId, decimal transactionAmount) {
        try {
            
            string amount = transactionAmount.toPlainString().replace('.', '');
            string authorizationRequest = '';
            Integer iRandNumber = Math.round(Math.random()*1000);
            list<Transaction__c> transactions = [   SELECT Name, Gateway_ID__c,Authorization__c,Response_Code__c,Card_Code_Response__c,Currency__c, Currency__r.Name
                                                    FROM Transaction__c
                                                    WHERE Id =:transactionId 
                                                    LIMIT 1
                                                    ];

            transactionObj = new Transaction__c(Transaction__c = transactions[0].Id,
                    Payment_Method__c = paymentMethod.Id, 
                    Type__c = CommonUtilClass.TRANSACTION_TYPE_REFUND, 
                    Gateway_ID__c = gatewayId, 
                    Amount__c = transactionAmount, 
                    Payment_Gateway__c = gateway.Id
            );

            transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
            if(invoice != null)
            {
                transactionObj.Request_Invoice__c = invoice.Id;
            }
            transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
            transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_REFUND;
            transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
            transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
            transactionObj.Card_Type__c = paymentMethod.Card_Type__c;
            
            if(invoice != null)
            {
                authorizationRequest ='VPSProtocol=2.23'+'&TxType=REFUND'+'&Vendor='+gateway.Merchant_Seal_User_Id__c+''+'&VendorTxCode='+invoice.id+iRandNumber+'&Amount='+transactionAmount+'&Currency='+invoice.CurrencyL__r.Name+'&Description=Refund&RelatedVPSTxId='+transactions.get(0).Response_Code__c+'&RelatedVendorTxCode='+transactions.get(0).Authorization__c+'&RelatedSecurityKey='+transactions.get(0).Gateway_ID__c+''+'&RelatedTxAuthNo='+transactions.get(0).Card_Code_Response__c+'';
            }else{
                authorizationRequest ='VPSProtocol=2.23'+'&TxType=REFUND'+'&Vendor='+gateway.Merchant_Seal_User_Id__c+''+'&VendorTxCode='+transactionId+iRandNumber+'&Amount='+transactionAmount+'&Currency='+transactions[0].Currency__r.Name+'&Description=Refund&RelatedVPSTxId='+transactions.get(0).Response_Code__c+'&RelatedVendorTxCode='+transactions.get(0).Authorization__c+'&RelatedSecurityKey='+transactions.get(0).Gateway_ID__c+''+'&RelatedTxAuthNo='+transactions.get(0).Card_Code_Response__c+'';
            }

            if(gateway.Test_Mode__c) {
                sHttpEndPoint = CommonUtilClass.ENDPOINT_SAGEPAY_REFUND_URL_TEST+authorizationRequest;
            } else {
                sHttpEndPoint = CommonUtilClass.ENDPOINT_SAGEPAY_REFUND_URL_LIVE+authorizationRequest;
            } 

            sendHttpRequest(sHttpEndPoint); 

            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                //cancel the payment 
                InvoicingUtilClass.cancelPayment(transactionObj.Transaction__c);
            }
        } catch(Exception ex) {
            result.message += '\n \n '+ system.Label.ExceptionOccurred + ex.getMessage();
        } 
        return result;
    }
    
    
    public PaymentOperations.PaymentResult handleAuthorizeAndCharge_Site(boolean isSaveCardDetails) {  
        try {
            isSavePaymentMethod = isSaveCardDetails;
            decimal amountToBeProcessed = 0;
            if(invoice != null && currencyId == null) {
                if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                    amountToBeProcessed = invoice.Payment_Request_Amount__c;
                } else {
                    amountToBeProcessed = invoice.Unpaid_Amount__c;
                }
            } else {
                amountToBeProcessed = dAmount;
            }

            string s1 = amountToBeProcessed.toPlainString();
            decimal d = amountToBeProcessed;
            if(!s1.contains('.')){
                s1 = s1 + '.00';
                d = decimal.valueof(s1);
            }   

            string amount = d.toPlainString().replace('.', '');
            string sExpirationYear = string.ValueOf(paymentMethod.Card_Expiration_Year__c).substring(2,4);
            string authorizationRequest;

            if(verfiybillandState())
                return result;  
                
            Currency__c currency1;
            // if the currency id is not null, means process for the virtual terminal
            if(currencyId != null) {
                currency1 = [SELECT Name FROM Currency__c WHERE id =: currencyId];
            } else {
                currency1 = [SELECT Name FROM Currency__c WHERE Name = 'USD' limit 1];
            }

            transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                    Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, 
                    Amount__c = amountToBeProcessed, 
                    Payment_Gateway__c = gateway.Id
            );

            String sCurrrency = invoice != null ? invoice.CurrencyL__r.Name : currency1.Name;
            Integer iRandNumber = Math.round(Math.random()*1000);
            String sName = invoice != null ? invoice.Name : account.Name;
            String sVendorTxCode = invoice != null ? invoice.id+''+iRandNumber : account.id+''+iRandNumber;
            sAddress1 = sAddress1.replaceAll('(\\n+)', '');

            authorizationRequest ='VPSProtocol=2.23'+'&TxType=PAYMENT'+'&Vendor='+gateway.Merchant_Seal_User_Id__c+'&VendorTxCode='+sVendorTxCode+'&Amount='+amountToBeProcessed+'&Currency='+sCurrrency+'&Description='+sName+'&CardHolder='+paymentMethod.Billing_Last_Name__c+ paymentMethod.Billing_First_Name__c +'&CardNumber='+paymentMethod.Card_Number__c+'&ExpiryDate='+paymentMethod.Card_Expiration_Month__c+sExpirationYear+'&CardType='+cardType+'&CV2='+paymentMethod.CVV__c+'&BillingAddress1='+sAddress1+'&BillingSurname='+sLastName+'&BillingFirstnames='+sFirstName+'&BillingCity='+sCity+'&BillingPostcode='+sZipCode+'&BillingCountry='+sCountryCode+'&BillingState='+sState+'&DeliverySurname='+sLastName+'&DeliveryFirstnames='+sFirstName+'&DeliveryAddress1='+sAddress1+'&DeliveryCity='+sCity+'&DeliveryPostcode='+sZipCode+'&DeliveryCountry='+sCountryCode+'&DeliveryState='+sState+'&Apply3DSecure=2';                                         
            authorizationRequest = authorizationRequest.replaceAll('(\\s+)', '');

            if(invoice != null){
                transactionObj.Currency__c = invoice.CurrencyL__c;
                transactionObj.Request_Invoice__c = invoice.Id;
            } else{
                transactionObj.Currency__c = Currency1.id;
            }

            transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
            transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
            transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE;
            transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
            transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
            transactionObj.Card_Type__c = paymentMethod.Card_Type__c;
            transactionObj.Authorization__c = sVendorTxCode;

            if(gateway.Test_Mode__c) {
                sHttpEndPoint = CommonUtilClass.ENDPOINT_SAGEPAY_AUTHENTICATE_OR_PAYMENT_URL_TEST+authorizationRequest;
            } else {
                sHttpEndPoint = CommonUtilClass.ENDPOINT_SAGEPAY_AUTHENTICATE_OR_PAYMENT_URL_LIVE+authorizationRequest;
            } 
            
            if(isSaveCardDetails) {
                sendHttpRequest(sHttpEndPoint);
                result.message = transactionObj.Response_Status__c + ' ' + transactionObj.Response_Message__c;
                result.transactionObj = transactionObj;

                // query the default payment method present for the account and update default to false
                list<Payment_Method__c> defaultPaymentMethods;
                if(invoice != null){
                    defaultPaymentMethods = InvoicingUtilClass.getDefaultMethodForAccount(invoice.Account__c);
                } else {
                    defaultPaymentMethods = InvoicingUtilClass.getDefaultMethodForAccount(account.Id);
                }
                if(!defaultPaymentMethods.isEmpty()) {
                    for(Payment_Method__c pm : defaultPaymentMethods) {
                        pm.Default__c = false;
                    }
                    update defaultPaymentMethods;
                }

                // make the new payment method to default
                paymentMethod.Default__c = true;
                /*
                Modified By : Rama Krishna: 03 feb 2016 : INVOICEIT-679
                Comments    : make cvv as null
                */    
                paymentMethod.CVV__c = null;
                upsert paymentMethod;
                //populate Default Method on account
                CommonUtilClass.populateDefaultMethod(paymentMethod);
                
                transactionObj.Payment_Method__c = paymentMethod.Id;

                result.message =  system.Label.transactioncreated+' ';
                upsert transactionObj;

                transactionObj = [SELECT Name, Response_Status__c, Amount__c, Response_Code__c, Transaction__c, Response_Message__c
                                  FROM Transaction__c
                                  WHERE Id =: transactionObj.Id];

                result.message  +=  transactionObj.Name + ' \n'
                + 'Gateway Response : ' + transactionObj.Response_Message__c + ' \n'
                + 'Gateway Status : ' + transactionObj.Response_Status__c;

            } else {
                transactionObj.Payment_Method__c = sDummyPaymentId;
                sendHttpRequest(sHttpEndPoint);
                result.message = transactionObj.Response_Status__c + ' ' + transactionObj.Response_Message__c;
                result.transactionObj = transactionObj;
            }

            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                //create the payment and payment allocation against the inv
                if(invoice != null){
                    if(currencyId != null){
                        // this is used for virtual terminal payment
                        InvoicingUtilClass.createPaymentAndAllocationForVirtualTerminal(invoice, transactionObj);
                    } else{
                        InvoicingUtilClass.createPaymentAndPaymentAllocation(invoice, transactionObj);
                    }
                } else {
                    if(currencyId != null){
                        // this is used for virtual terminal payment
                        Payment__c payment = new Payment__c(Account__c = account.Id, 
                                Amount__c = transactionObj.Amount__c, 
                                Status__c = CommonUtilClass.STATUS_COMPLETED, 
                                Payment_Type__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                                Payment_Date__c = system.today(),
                                Transaction__c = transactionObj.Id,
                                Currency__c = currencyId,
                                Payment_Description__c = 'Virtual terminal payment');

                        insert payment;
                    } else{
                        Payment__c payment = new Payment__c(Account__c = account.Id, 
                                Amount__c = transactionObj.Amount__c, 
                                Status__c = CommonUtilClass.STATUS_COMPLETED, 
                                Payment_Type__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                                Payment_Date__c = system.today(),
                                Transaction__c = transactionObj.Id,
                                Currency__c = Currency1.Id,
                                Payment_Description__c = 'Against Advance Payment Request');

                        insert payment;
                        Account accToUpdate = new Account(id = account.Id,Advance_Request_Status__c = CommonUtilClass.STATUS_PAID);
                        update accToUpdate;
                    }
                }

                transactionObj.Is_Payment_Processed_Successfully__c = true;
                update transactionObj;                                                                 
            }else {
                upsert transactionObj; 
            }
        } catch(Exception ex) {
            result.message += '\n \n  '+ system.Label.ExceptionOccurred+ ex.getMessage();
            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                result.message += '\n \n '+system.label.InvoiceIsCharged;
                transactionObj.Is_Payment_Processed_Successfully__c = false;
                transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                upsert transactionObj;   
            }
        }
        return result;          
    } 

    public void sendHttpRequest(string reqEndPointAndBody) {
        HttpResponse httpResponse;
        Http httpObject = new Http();
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(reqEndPointAndBody);
        httpRequest.setMethod('POST');
        httpRequest.setHeader('Content-Length', '0');   
        /*
            Modified By          : Rama Krishna  :19 august 2014  :SUP-312
            Comments          : exending the callout time to max
          */
        httpRequest.setTimeout(120000);
        list<string>  sHttpResponseBodyList = new list<string>();
        list<string>  sHttpResponseBodySplitList;
        string sHttpResponseBody;

        if(!system.test.isRunningTest()) {
            httpResponse = httpObject.send(httpRequest);
            sHttpResponseBody = httpResponse.getBody().Replace('\n','').Replace('\r',',');
            
        } else {
            sHttpResponseBody = 'VPSProtocol=2.23,Status=OK,StatusDetail=0000 : The Authorisation was Successful.,VPSTxId={A22CC840-F473-F790-EE8E-BBBD46958DB0},SecurityKey=SDEDNEOXVF,TxAuthNo=6531459,AVSCV2=DATA NOT CHECKED,AddressResult=NOTPROVIDED,PostCodeResult=NOTPROVIDED,CV2Result=NOTPROVIDED,3DSecureStatus=NOTCHECKED';
        } 

        sHttpResponseBodyList = sHttpResponseBody.split(',') ;
            for(string sReponse : sHttpResponseBodyList){
                sHttpResponseBodySplitList = new list<string>();
                sHttpResponseBodySplitList = sReponse.split('=') ;
                if(sHttpResponseBodySplitList.size() > 1)
                    parameters.put(sHttpResponseBodySplitList[0],sHttpResponseBodySplitList[1]);
            }
        handleRequest();
    }

    private void handleRequest() {
        //if it contains OK,then transaction is approved
        if(parameters.get('Status') == 'OK' || ( parameters.get('StatusDetail').contains('2011') || parameters.get('StatusDetail').contains('0000') || parameters.get('StatusDetail').contains('2005'))) {
            result.reloadPage = true;
            transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED;
            transactionObj.Response__c = system.Label.TransactionHasBeenApproved;
            transactionObj.Response_Code__c = parameters.get('VPSTxId');
            transactionObj.Gateway_ID__c = parameters.get('SecurityKey');
            transactionObj.Response_Message__c = parameters.get('StatusDetail');
            transactionObj.Card_Code_Response__c = parameters.get('TxAuthNo');
        } else {
            result.reloadPage = false;
            transactionObj.Authorization__c = '';
            transactionObj.Response_Status__c = parameters.get('Status');
            transactionObj.Response_Message__c = parameters.get('StatusDetail');
            transactionObj.Response__c = parameters.get('StatusDetail');
            //Added by DL, INVOICEIT-635
            transactionObj.Is_Payment_Processed_Successfully__c = false;
        }
        
         if(isGenericMethodCall){

        result.message =  system.Label.transactioncreated;
        // for the site payment, if the the boolean is true dont insert transaction record
        if(!isSavePaymentMethod){
            upsert transactionObj;
            
             transactionObj = [SELECT Name, Response_Status__c, Amount__c, Response_Code__c, Transaction__c, Response_Message__c
                               FROM Transaction__c
                               WHERE Id =: transactionObj.Id];
        }
        result.message +=  transactionObj.Name + ' \n'
                            + 'Gateway Response : ' + parameters.get('StatusDetail').substring(6, parameters.get('StatusDetail').length()) + ' \n'
                            + 'Gateway Status : ' + transactionObj.Response_Status__c;
        result.transactionObj = transactionObj; 
        } 
    }
    
    public boolean verfiybillandState() {
        
        if(paymentMethod.Billing_Address__c == null || paymentMethod.Billing_City__c == null || paymentMethod.Billing_Zip_Postal__c == null || paymentMethod.Billing_Country__c == null) {
            result.message = system.Label.PleaseMakeSureAddressIsFilled;
            return true;
        }
        
        if(map_CountryName_Code.containsKey(paymentMethod.Billing_Country__c)) {
            if(paymentMethod.Billing_Country__c != 'United Kingdom') {
                sCountryCode = map_CountryName_Code.get(paymentMethod.Billing_Country__c).Country_Code__c.trim();
            }else {
                sCountryCode = 'GB';
            }
        } else {
            result.message = system.Label.CountryCodeDoesNotExistForDefaultPaymentMethod;
            return true;
        }
        
        if(sState == '' && paymentMethod.Billing_Country__c == 'United States') {
            result.message = system.label.StateDoesNotExist;
            return true;
        } 
            
        return false;
    }
    
    public void populateCustomerDetails() {      
        if(paymentMethod.Billing_First_Name__c != null) {
            sFirstName = paymentMethod.Billing_First_Name__c;
        }
        if(paymentMethod.Billing_Last_Name__c != null) {
            sLastName = paymentMethod.Billing_Last_Name__c;
        }   
        if(paymentMethod.Billing_Address__c != null) {
            sAddress1 = paymentMethod.Billing_Address__c;
            sAddress1 = sAddress1.replaceAll('(\\n+)', '');
        }
        if(paymentMethod.Billing_City__c != null) {
            sCity =  paymentMethod.Billing_City__c;
        }
        // For this gate way we need to populate the state code as TWO characters and it is only required for United States
        if(paymentMethod.Billing_State_Province__c != null && paymentMethod.Billing_Country__c == 'United States') {
            frameMapStateNameANDCode();
            if(map_StateName_Code.containskey(paymentMethod.Billing_State_Province__c.toLowerCase())) {
                sState = map_StateName_Code.get(paymentMethod.Billing_State_Province__c.toLowerCase());
            } else if(paymentMethod.Billing_State_Province__c.length() == 2){
                sState = paymentMethod.Billing_State_Province__c.toUpperCase();
            }   
        }   
        if(paymentMethod.Billing_Zip_Postal__c != null) {
            sZipCode = paymentMethod.Billing_Zip_Postal__c;
        }
        if(paymentMethod.Billing_Country__c != null) {
            sCountry = paymentMethod.Billing_Country__c;
        }   
        if(paymentMethod.Billing_Phone__c != null){
            sPhone = paymentMethod.Billing_Phone__c;
        }
        if(paymentMethod.Billing_Email__c != null){
            sEmail = paymentMethod.Billing_Email__c;
        }
    }  
}