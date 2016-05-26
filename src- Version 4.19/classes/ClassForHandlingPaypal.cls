/**
 * Webservice for handling payments.
 *
 * @author Laxman Rao M
 * @author Manoj Ganapathy
 * @author Acertis Cloud Ltd
   Copyright (c) 2011, Acertis Cloud, Salesforce.com Inc.
   All rights reserved.
 */

/*
    We have used Payflow Pro
    Payflow Pro is a high performance TCP/IP-based internet payment solution that resides on your computer system

    Host Addresses
        Use the following host addresses for the Payflow V4 SDK:
        1 For live transactions, use payflowpro.paypal.com
        2 For testing purposes, use pilot-payflowpro.paypal.com

    AIM is a customizable payment processing solution that gives the merchant control over
    all the steps in processing a transaction, including:
    1 Collecting customer payment information through a custom application
    2 Generating a receipt to the customer
    3 Secure transmission of data to the payment gateway for transaction processing
    4 Securely storing cardholder information
    5 And more, depending on the merchant’s business requirements

    The security of an AIM transaction is ensured through a 128-bit Secure Sockets Layer
    (SSL) connection between the merchant’s Web server and the Authorize.Net Payment
    Gateway.
    AIM allows merchants the highest degree of customization and control over their
    customers’ checkout experience.
 */

/*
When To Use a Sale Transaction
    A Sale transaction is best suited to businesses that provide immediate fulfillment for their
    products or services. If your business does not provide immediate fulfillment, then credit card
    association rules recommend that you use an Authorization and a Delayed Capture transaction.(TRXTYPE=S)
    To perform a Sale transaction, you are required to pass the following parameters:
    1 ACCT
    2 AMT
    3 EXPDATE

When To Use Authorization/Delayed Capture Transactions
    If your business does not provide immediate fulfillment of products or services, you should
    use this two-stage transaction solution, also known as Delayed Capture processing, because it
    enables you to capture credit card transaction funds when your are ready to collect them.
    NOTE: If you signed up for the PayPal processor with Fraud Protection Services, you must use
    delayed capture processing for all sale transactions.   
    To perform an Authorization transaction, you are required to pass the following parameters:
    1 ACCT
    2 AMT
    3 EXPDATE
    How to use this :
    1. Perform the Authorization transaction(TRXTYPE=A).
    2. Perform the Delayed Capture transaction(TRXTYPE=D, Set ORIGID to the PNREF value returned in the original Authorization).

When To Use a Void Transaction
    Follow these guidelines:
    1 You can void Delayed Capture, Sale, Credit, Authorization, and Voice Authorization
    transactions. You cannot void a Void transaction.
    2 You can only use a Void transaction on a transaction that has not yet settled. To refund a
    customer’s money for a settled transaction, you must submit a Credit transaction.
    3 To submit a Void transaction, you must pass the following parameter:
    ORIGID

When To Use a Credit Transaction    
    Whenever you want to credit back the amount to user use this
    The Credit transaction (TRXTYPE=C) refunds the specified amount to the cardholder.

Note :
    1 An Inquiry transaction (TRXTYPE=I) returns the result and status of a transaction.    
    2 You can only use a Void transaction on a transaction that has not yet settled.

================================================================
Attributes :

USER (Required) :
    If you set up one or more additional users on the account, this value is the ID
    of the user authorized to process transactions. If, however, you have not set up additional
    users on the account, USER has the same value as VENDOR.
    Limitations: Sixty-four alphanumeric, case-sensitive characters.

VENDOR (Required) :
    Your merchant login ID that you created when you registered for the account.
    Limitations: Sixty-four alphanumeric, case-sensitive characters.

PARTNER (Required) :
    The ID provided to you by the authorized PayPal Reseller who registered you
    for the Payflow SDK. If you purchased your account directly from PayPal, use PayPal.
    Limitations: Sixty-four alphanumeric, case-sensitive characters.

PWD (Required) : 
    The password that you defined while registering for the account.
    Limitations: Six- to thirty-two alphanumeric, case-sensitive characters.

TRXTYPE (Required) Indicates the type of transaction to perform. Values are:
                    �� S = Sale transaction
                    �� C = Credit
                    �� A = Authorization
                    �� D = Delayed Capture
                    �� V = Void
       //we are intrested in above 5 TRXTYPE             
                    �� F = Voice Authorization
                    �� I = Inquiry
                    �� N = Duplicate transaction

TENDER (Required) The method of payment. Values are:
                    �� P = PayPal            
                    �� A = Automated clearinghouse
                    �� C = Credit card
                    �� D = Pinless debit
                    �� K = Telecheck

ACCT (Required for credit cards) 
    Credit card or purchase card number. For the Pinless debit
    TENDER type, ACCT can be the bank account number.                    

EXPDATE (Required) 
    Expiration date of the credit card.
    Limitations: mmyy format. For example, 1008 represents November 2008

AMT (Required) 
    Amount (Default: U.S. based currency)  

CUSTCODE (Optional) 
    Customer code/customer reference ID

COMMENT1 (Optional) 
    Merchant-defined value for reporting and auditing purposes

CVV2 (Optional) 
    A code that is printed (not imprinted) on the back of a credit card. Used as
    partial assurance that the card is in the buyer’s possession.
==========================================================================                     
 */
public with sharing class ClassForHandlingPaypal implements InterfacePaymentClass.paymentOperationsInterface {

    private map<string, string> parameters;
    private string sHttpBody = '';
    private string sHttpEndPoint = '';
    private string sHttpResponse;
    private list<string> responseArray;
    private Payment_Method__c paymentMethod;
    private Gateway__c gateway;
    private Invoice__c invoice;
    private PaymentOperations.PaymentResult result = new PaymentOperations.PaymentResult();
    private Transaction__c transactionObj;
    private boolean isException = false;
    private string sDummyPaymentId;
    private Account account;
    private decimal dAmount;
    private boolean isGenericMethodCall = true;

    //This is used for Virtualterminal Purpose
    private Id CurrencyId;

    public ClassForHandlingPaypal(Gateway__c gateway, Invoice__c invoice, Payment_Method__c paymentMethod) {
        this.invoice = invoice;
        this.paymentMethod = paymentMethod;
        this.gateway = gateway;
        
        //Added by dhanalakshmi for INVOICEIT-18
        if(invoice == null)
        {
            this.invoice = new Invoice__c();
        } 
        
        initialize();  
    }
    /*
        Modified By         : Rama Krishna   :19 june 2013   :INVOICEIT-194
        Comments         : added two parameters to constructor(i.e, Account and dAmount). 
     */
    public ClassForHandlingPaypal(Gateway__c gateway, Invoice__c invoice, Payment_Method__c paymentMethod, string sDummyPaymentId,decimal dAmount,Account account) {
        this.invoice = invoice;
        this.account = account;
        this.dAmount = dAmount;
        this.paymentMethod = paymentMethod;
        this.gateway = gateway;
        this.sDummyPaymentId = sDummyPaymentId;

        initialize();  
    }


    //This is used for Virtualterminal Purpose
    public ClassForHandlingPaypal(Gateway__c gateway, invoice__c invoice, Payment_Method__c paymentMethod, string sDummyPaymentId, decimal dAmount,Account account, Id CurrencyId) {
        this.invoice = invoice;
        this.account = account;
        this.dAmount = dAmount;
        this.paymentMethod = paymentMethod;
        this.gateway = gateway;
        this.sDummyPaymentId = sDummyPaymentId;
        this.CurrencyId = CurrencyId;
        initialize();  
    }

    private void initialize() {
        parameters = new map<string, string>();

        //this determines is it sandboz or live
        if(gateway.Test_Mode__c) {
            sHttpEndPoint = CommonUtilClass.ENDPOINT_PAYFLOWPRO_TEST;
        } else {
            sHttpEndPoint = CommonUtilClass.ENDPOINT_PAYFLOWPRO_LIVE;
        }

        //fill the merchant information from gateway
        parameters.put('USER', gateway.Merchant_ID__c);
        parameters.put('PWD', gateway.Security_Key__c);
        parameters.put('VENDOR', gateway.Merchant_ID__c);
        parameters.put('PARTNER', 'PayPal');    
    }

    public PaymentOperations.PaymentResult handleAuthorize_Click() {
        decimal amountToBeProcessed = 0;
        try {
            if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                amountToBeProcessed = invoice.Payment_Request_Amount__c;
            } else {
                amountToBeProcessed = invoice.Unpaid_Amount__c;
            }

            //fill the type of method (Transaction Information)
            parameters.put('TRXTYPE', 'A');   

            //fill  amount
            parameters.put('AMT', string.ValueOf(amountToBeProcessed));

            //fill customer reference 
            parameters.put('CUSTCODE', invoice.Id); 

            //Merchant-defined value for reporting and auditing purposes.
            parameters.put('COMMENT1', 'SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name); 

            //call the method fillCardInformation() where card information is captured
            fillCardInformation();

            // This below method gives the details of customer, included for the Jira Task - 125
            /*
            Modified By             : Anil Pinto    :14 June 2013    :INVOICEIT-125
            Comments              : Added below line which gives required details of customer for billing and shipping information.
             */
            populateFullDetailsOfCustomer();

            //intialize the transactionObj with parentId and set the type of transaction like Authorize, Charge, Void , Refund
           
            transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_AUTHORIZATION, Amount__c = amountToBeProcessed, Currency__c = invoice.CurrencyL__c, Is_Payment_Processed_Successfully__c = true, Payment_Gateway__c = gateway.Id);
            transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
            transactionObj.Request_Invoice__c = invoice.Id;
            transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
            transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_AUTHORIZATION;

            /* Modified by Ram  on May 2-2013*/
            transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
            transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
            transactionObj.Card_Type__c = paymentMethod.Card_Type__c;

            //call the methods for creating string of paramters from map, send http request to server, parse the response and handle request
            createStringFromMap();      

            sHttpResponse = InvoicingUtilClass.getHTTPResponse(sHttpEndPoint, sHttpBody); 
            responseArray = sHttpResponse.split('&');
            handleRequest();
        } catch(Exception ex) {
            result.message = ex.getMessage();
        }

        return result;
    }

    public PaymentOperations.PaymentResult handleAuthorizeAndCharge_Click(string transactionId, string gatewayID) {  
        decimal amountToBeProcessed = 0;
        try {
            if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                amountToBeProcessed = invoice.Payment_Request_Amount__c;
            } else {
                amountToBeProcessed = invoice.Unpaid_Amount__c;
            }

            //fill  amount
            parameters.put('AMT', string.ValueOf(amountToBeProcessed));

            //fill customer reference 
            parameters.put('CUSTCODE', invoice.Id); 

            //Merchant-defined value for reporting and auditing purposes.
            parameters.put('COMMENT1', 'SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name); 

            //call the method fillCardInformation() where card information is captured
            fillCardInformation();

            /*
            Modified By         : Anil Pinto  :14 June 2013  :INVOICEIT-125
            Comments         : Added below line which gives required details of customer for billing and shipping information.
             */
            populateFullDetailsOfCustomer();

            //intialize the transactionObj with parentId and set the type of transaction like Authorize, Charge, Void , Refund
            if(transactionId == null) {
                transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, Amount__c = amountToBeProcessed, Currency__c = invoice.CurrencyL__c, Payment_Gateway__c = gateway.Id);
                //fill the type of method (Transaction Information)
                parameters.put('TRXTYPE', 'S'); 
            } else {
                //old code commented
             
                transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, Transaction__c = transactionId, Amount__c = amountToBeProcessed, Currency__c = invoice.CurrencyL__c, Payment_Gateway__c = gateway.Id);

                //fill the type of method (Transaction Information)
                parameters.put('TRXTYPE', 'D'); 

                //fill the gatewayId
                parameters.put('ORIGID', gatewayID);
            }

            transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
            transactionObj.Request_Invoice__c = invoice.Id;
            transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
            transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE;

            /*  Modified by Ram  on May 2-2013*/
            transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
            transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
            transactionObj.Card_Type__c = paymentMethod.Card_Type__c;

            //call the methods for creating string of paramters from map, send http request to server, parse the response and handle request
            createStringFromMap();  
            sHttpResponse = InvoicingUtilClass.getHTTPResponse(sHttpEndPoint, sHttpBody); 
            responseArray = sHttpResponse.split('&');
            handleRequest();
            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                //create the payment and payment allocation against the invoice
                InvoicingUtilClass.createPaymentAndPaymentAllocation(invoice, transactionObj);
                transactionObj.Is_Payment_Processed_Successfully__c = true;
                update transactionObj;                                                                 
            }  
        } catch(Exception ex) {
            result.message += '\n \n  '+system.Label.ExceptionOccurred + ex.getMessage();
            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                result.message += '\n \n '+ system.Label.InvoiceIsCharged;
                transactionObj.Is_Payment_Processed_Successfully__c = false;
                transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                upsert transactionObj;   
            }
        }   

        return result;
    }

/* =================== Start ====================================== */

    /*
    Modified By         : Madhu Keshav1   :Dec 2015I  :NVOICEIT-641
    Comments         : Creating a generic method for processing all payments. This will be used in global methods and API
    */
    
   public PaymentSiteOperation.GenericPaymentResult handleAuthorizeAndCharge(PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters)
    {
        isGenericMethodCall = false;
        
        PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new  PaymentSiteOperation.GenericPaymentResult();
        try {
           
            
            decimal amountToBeProcessed = genericPaymentParameters.amountToProcess;
            //fill  amount
            parameters.put('AMT', string.ValueOf(amountToBeProcessed));

            //fill customer reference 
            parameters.put('CUSTCODE', invoice.Id); 

            //Merchant-defined value for reporting and auditing purposes.
            parameters.put('COMMENT1', 'SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name); 

            //call the method fillCardInformation() where card information is captured
            fillCardInformation();

            transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, Amount__c = amountToBeProcessed, Currency__c = invoice.CurrencyL__c, Payment_Gateway__c = gateway.Id);
            parameters.put('TRXTYPE', 'S'); 

            createStringFromMap();  
            sHttpResponse = InvoicingUtilClass.getHTTPResponse(sHttpEndPoint, sHttpBody); 
            responseArray = sHttpResponse.split('&');
            handleRequest(); 

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

    /*
    Modified By          : Rama Krishna     :19 june 2013   :INVOICEIT-194
    Comments          : previously force.site only supporting for the Invoice Payment,
                                    now this method is accepting Payments for both Invoice and Account.    
     */
    public PaymentOperations.PaymentResult handleAuthorizeAndCharge_Site(boolean isSaveCardDetails) {  
        decimal amountToBeProcessed = 0;
        try {
            if(invoice != null && currencyId == null) {
                if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                    amountToBeProcessed = invoice.Payment_Request_Amount__c;
                } else {
                    amountToBeProcessed = invoice.Unpaid_Amount__c;
                }
            } else{
                /*
            Modified By          : Rama Krishna  :19 june 2013   :INVOICEIT-194
            Comments           : assigning advance request amount Of Account,
                 */
                amountToBeProcessed = dAmount;
            }

            //fill  amount
            parameters.put('AMT', string.ValueOf(amountToBeProcessed));
            //fill customer reference 
            //Merchant-defined value for reporting and auditing purposes.
            if(invoice != null){
                parameters.put('CUSTCODE', invoice.Id);
                parameters.put('COMMENT1', 'SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name); 
            } else{
                /*
            Modified By         : Rama Krishna      :19 june 2013   :INVOICEIT-194
            Comments         : passing accounts Name,account.Id  to the gateway Parameters.
                 */
                parameters.put('CUSTCODE', account.Id);
                parameters.put('COMMENT1', 'SalesForce Id : ' + account.Id + ' and Account Name : ' + account.Name); 
            }

            //call the method fillCardInformation() where card information is captured
            fillCardInformation();

            /*
            Modified By         : Anil Pinto       :14 June 2013        :INVOICEIT-125
            Comments         : Added below line which gives required details of customer for billing and shipping information.
             */
            populateFullDetailsOfCustomer();

            /*
            Modified By         : Rama Krishna  :9 june 2013:   IVOICEIT-194
            Comments         : querying the currency equals to USD, to assign currency for account Payments   
             */
            Currency__c currency1 = [SELECT Name FROM Currency__c WHERE Name = 'USD'];

            //intialize the transactionObj with parentId and set the type of transaction like Authorize, Charge, Void , Refund
            transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, Amount__c = amountToBeProcessed, Payment_Gateway__c = gateway.Id);
            //fill the type of method (Transaction Information)
            parameters.put('TRXTYPE', 'S'); 
            if(invoice != null){
                transactionObj.Currency__c = invoice.CurrencyL__c;
                transactionObj.Request_Invoice__c = invoice.Id;
            } else {
                if(CurrencyId != null) {
                    //This is used for Virtualterminal Purpose
                    transactionObj.Currency__c = CurrencyId;
                } else{
                    //This is used for Advance Request Payment Purpose
                    transactionObj.Currency__c = currency1.id;
                }
            }

            transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
            transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
            transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE;

            /*  Modified by Ram  on May 2-2013 */
            transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
            transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
            transactionObj.Card_Type__c = paymentMethod.Card_Type__c;

            //call the methods for creating string of paramters from map, send http request to server, parse the response and handle request
            createStringFromMap();  
            sHttpResponse = InvoicingUtilClass.getHTTPResponse(sHttpEndPoint, sHttpBody); 
            responseArray = sHttpResponse.split('&');
            populateTransaction();
            if(isSaveCardDetails) {
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
                insert paymentMethod;
                //populate Default Method on account
                CommonUtilClass.populateDefaultMethod(paymentMethod);
                
                transactionObj.Payment_Method__c = paymentMethod.Id;
            } else {
                transactionObj.Payment_Method__c = sDummyPaymentId;
            }

            insert transactionObj;
            result.message = transactionObj.Response_Status__c + ' ' + transactionObj.Response_Message__c;
            result.transactionObj = transactionObj;

            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                //create the payment and payment allocation against the inv
                transactionObj.Response__c = system.Label.TransactionHasBeenApproved;
                if(invoice != null){
                    if(currencyId != null){
                        // this is used for virtual payment.
                        InvoicingUtilClass.createPaymentAndAllocationForVirtualTerminal(invoice, transactionObj);
                    } else{
                        InvoicingUtilClass.createPaymentAndPaymentAllocation(invoice, transactionObj);
                    }
                } else {
                    if(CurrencyId != null){
                        // this is used for virtual terminal payment
                        Payment__c payment = new Payment__c(Account__c = account.Id, 
                                Amount__c = transactionObj.Amount__c, 
                                Status__c = CommonUtilClass.STATUS_COMPLETED, 
                                Payment_Type__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                                Payment_Date__c = system.today(),
                                Transaction__c = transactionObj.Id,
                                Currency__c = CurrencyId,
                                Payment_Description__c = 'Virtual terminal payment');

                        insert payment;
                    }else{
                        /*
                        Modified By         : Rama Krishna19 june 2013:    INVOICEIT-194
                        Comments         : reating payment for account with out invoice.     
                         */
                        Payment__c payment = new Payment__c(Account__c = account.Id, 
                                Amount__c = transactionObj.Amount__c, 
                                Status__c = CommonUtilClass.STATUS_COMPLETED, 
                                Payment_Type__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD,
                                Payment_Date__c = system.today(),
                                Transaction__c = transactionObj.Id,
                                Currency__c = Currency1.Id,                     
                                Payment_Description__c = 'Against Advance Payment Request');

                        insert payment;
                        /*
                        Modified By         : Rama Krishna24-9-2013INVOICEIT-239
                        Comments         : once Advance Amount Requested is received, updating the Advance Request Status To paid on Account
                         */
                        Account accToUpdate = new Account(id = account.Id,Advance_Request_Status__c = CommonUtilClass.STATUS_PAID);
                        update accToUpdate;
                    }
                }
                transactionObj.Is_Payment_Processed_Successfully__c = true;
                update transactionObj;                                                                 
            }  
        } catch(Exception ex) {
            result.message += '\n \n '+system.Label.ExceptionOccurred + ex.getMessage();
            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                result.message += '\n \n '+system.Label.InvoiceIsCharged;
                transactionObj.Is_Payment_Processed_Successfully__c = false;
                transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                upsert transactionObj;   
            }
        }   

        return result;
    }

    public PaymentOperations.PaymentResult handleVoid_Click(string gatewayId, string transactionId, decimal transactionAmount) {
        try {   
            //fill the type of method (Transaction Information)
            parameters.put('TRXTYPE', 'V');    

            //fill customer reference 
            parameters.put('CUSTCODE', invoice.Id); 

            //Merchant-defined value for reporting and auditing purposes.
            parameters.put('COMMENT1', 'SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name); 

            //in order to void the transaction we need trasactionId
            parameters.put('ORIGID', gatewayId);

            /*
            Modified By     : Anil Pinto:  14 June 2013  :INVOICEIT-125
            Comments        : Added below line which gives required details of customer for billing and shipping information.
             */
            populateFullDetailsOfCustomer();

            //intialize the transactionObj with parentId and set the type of transaction like Authorize, Charge, Void , Refund
            //old code
            transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_VOID, Transaction__c = transactionId, Gateway_ID__c = gatewayId, Is_Payment_Processed_Successfully__c = true, Amount__c = transactionAmount, Payment_Gateway__c = gateway.Id);
            transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
            transactionObj.Request_Invoice__c = invoice.Id;
            transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
            transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_VOID;

            /*  Modified by Ram  on May 2-2013*/
            transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
            transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
            transactionObj.Card_Type__c = paymentMethod.Card_Type__c;

            //call the methods for creating string of paramters from map, send http request to server, parse the response and handle request
            createStringFromMap(); 

            sHttpResponse = InvoicingUtilClass.getHTTPResponse(sHttpEndPoint, sHttpBody); 
            responseArray = sHttpResponse.split('&');
            handleRequest();
            /* Modified by Laxman, according to jira - 49, 38 */
            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                //cancel the payment 
                InvoicingUtilClass.cancelPayment(transactionObj.Transaction__c);
            }
        } catch(Exception ex) {
            result.message = ex.getMessage();
        }

        return result;
    }

    public PaymentOperations.PaymentResult handleRefund_Click(string gatewayId, string transactionId, decimal transactionAmount) {
        try {   
            //fill the type of method (Transaction Information)
            parameters.put('TRXTYPE', 'C');    

            //in order to refund/credit the money we need trasactionId
            parameters.put('ORIGID', gatewayId);

            //fill amount
            parameters.put('AMT', string.ValueOf(transactionAmount));

            //fill customer reference 
            parameters.put('CUSTCODE', invoice.Id); 

            //Merchant-defined value for reporting and auditing purposes.
            parameters.put('COMMENT1', 'Refund against SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name); 

            //call the method fillCardInformation() where card information is captured
            fillCardInformation();

            /*
            Modified By          : Anil Pinto  :14 June 2013   :INVOICEIT-125
            Comments          : Added below line which gives required details of customer for billing and shipping information.
             */
            populateFullDetailsOfCustomer();

            //intialize the transactionObj with parentId and set the type of transaction like Authorize, Charge, Void , Refund        
            transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_REFUND, Transaction__c = transactionId, Gateway_ID__c = gatewayId, Amount__c = transactionAmount, Is_Payment_Processed_Successfully__c = true, Payment_Gateway__c = gateway.Id);
            transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
            transactionObj.Request_Invoice__c = invoice.Id;
            transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
            transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_REFUND;

            /*  Modified by Ram  on May 2-2013 */
            transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
            transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
            transactionObj.Card_Type__c = paymentMethod.Card_Type__c;

            //call the methods for creating string of paramters from map, send http request to server, parse the response and handle request
            createStringFromMap();      
            sHttpResponse = InvoicingUtilClass.getHTTPResponse(sHttpEndPoint, sHttpBody); 
            responseArray = sHttpResponse.split('&');
            handleRequest();
            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                //cancel the payment 
                InvoicingUtilClass.cancelPayment(transactionObj.Transaction__c);
            }
        } catch(Exception ex) {
            result.message = ex.getMessage();
        }

        return result;
    }

    private void createStringFromMap() {
        for(String key : parameters.keyset()) {
            string value = parameters.get(key);
            // if the value is null, then it throws an exception
            // Ref : INVOICEIT-222, sometimes cvv will be optional for Paypal
            if(value != null) {
                sHttpBody += key + '[' + string.ValueOf(value.Length()) + ']' + '=' +  value + '&';
            }
        }

        sHttpBody = this.sHttpBody.substring(0, sHttpBody.length() - 1);
    }

    private void fillCardInformation() {
        //fill the card information like card number, cvv, exp date and method like credit card
        parameters.put('ACCT', paymentMethod.Card_Number__c);
        parameters.put('EXPDATE', paymentMethod.Card_Expiration_Month__c + paymentMethod.Card_Expiration_Year__c.substring(2,4));
        parameters.put('CVV2', paymentMethod.CVV__c);
        //TENDER - The method of payment, such as C for credit card
        parameters.put('TENDER', 'C');
    }

    private void handleRequest() {
        populateTransaction();
        if(isGenericMethodCall){
        result.message =  system.Label.transactioncreated;
        //Added by DL, for faild transactions unchecking the 'Payment Process Successful?' checkbox, INVOICEIT-635
        if(transactionObj.Response_Status__c != CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED){
            transactionObj.Is_Payment_Processed_Successfully__c = false;
        }
        upsert transactionObj;

        transactionObj = [SELECT Name, Response_Status__c, Amount__c, Response_Code__c, Transaction__c
                          FROM Transaction__c
                          WHERE Id =: transactionObj.Id];

        result.message +=  transactionObj.Name + ' \n'
        + 'Gateway Response : ' + transactionObj.Response_Code__c + ' \n'
        + 'Gateway Status : ' + transactionObj.Response_Status__c;

        result.transactionObj = transactionObj;  
       }
    }

    private void populateTransaction() {
        map<string, string> map_Key_Value = new map<string, string>();
        list<string> keyValuesSepratedByEqual = responseArray;
        list<string> resultkeyValue = keyValuesSepratedByEqual.get(0).split('=');
        list<string> responsekeyValue;

        transactionObj.Gateway_Date__c = system.now();
        //if it is 0,then transaction is approved
        if(resultkeyValue.get(1) == '0') 
        {
            result.reloadPage = true;
            transactionObj.Response_Code__c = '0';
            transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED;
            for(integer i = 1; i < keyValuesSepratedByEqual.size(); i++)
            {
                string keyValueSepratedByEqual = keyValuesSepratedByEqual[i];
                list<string> keyAndValue = keyValueSepratedByEqual.split('=');
                map_Key_Value.put(keyAndValue.get(0), keyAndValue.get(1)); 
            }

            if(map_Key_Value.containsKey('PNREF')) 
            {
                transactionObj.Gateway_ID__c = map_Key_Value.get('PNREF');
            }
            if(map_Key_Value.containsKey('AUTHCODE')) 
            {
                transactionObj.Authorization__c = map_Key_Value.get('AUTHCODE');
            }
            if(map_Key_Value.containsKey('CVV2MATCH')) 
            {
                transactionObj.Card_Code_Response__c = map_Key_Value.get('CVV2MATCH');
            }
        }
        else
        {
            transactionObj.Response_Code__c = resultkeyValue.get(1);
            for(integer i = 1; i < keyValuesSepratedByEqual.size(); i++)
            {
                string keyValueSepratedByEqual = keyValuesSepratedByEqual[i];
                list<string> keyAndValue = keyValueSepratedByEqual.split('=');
                map_Key_Value.put(keyAndValue.get(0), keyAndValue.get(1)); 
            }

            if(map_Key_Value.containsKey('PNREF')) 
            {
                transactionObj.Gateway_ID__c = map_Key_Value.get('PNREF');
            }
            if(map_Key_Value.containsKey('RESPMSG')) 
            {
                transactionObj.Response_Status__c = map_Key_Value.get('RESPMSG');
                transactionObj.Response_Message__c = map_Key_Value.get('RESPMSG');
            }
        }
    }

    // This below method gives the details of customer, included for the Jira Task - 125
    /*
            Modified By          : Anil Pinto  :14 June 2013  :INVOICEIT-125
            Comments          : created new method which gives required details of customer for billing and shipping information.
     */
    public void populateFullDetailsOfCustomer() {
        // billing details
        if(paymentMethod.Billing_First_Name__c != null) {
            parameters.put('FIRSTNAME', paymentMethod.Billing_First_Name__c);
        } 
        if(paymentMethod.Billing_Last_Name__c != null) {
            parameters.put('LASTNAME', paymentMethod.Billing_Last_Name__c);
        }

        if(paymentMethod.Billing_Address__c != null) {
            parameters.put('STREET', paymentMethod.Billing_Address__c);         
        }

        if(paymentMethod.Billing_City__c != null) {
            parameters.put('CITY',paymentMethod.Billing_City__c);
        }

        if(paymentMethod.Billing_Zip_Postal__c != null) {
            parameters.put('ZIP', paymentMethod.Billing_Zip_Postal__c);
        }

        if( paymentMethod.Billing_Country__c != null) {
            parameters.put('BILLTOCOUNTRY', paymentMethod.Billing_Country__c);
        }
        // Modified by Dhana Lakshmi on Dec 12-2014, Ticket : INVOICEIT-294.
        if(paymentMethod.Billing_Email__c != null && gateway.Email_Customer__c == true) {
            parameters.put('EMAIL', paymentMethod.Billing_Email__c);
        }

        //invoice will be null, if the payment is done directly against the account
        if(invoice != null) {
            // shipping details
            if(invoice.Shipping_Contact__r.FirstName != null) {
                parameters.put('SHIPTOFIRSTNAME', invoice.Shipping_Contact__r.FirstName);
            }

            if(invoice.Shipping_Contact__r.LastName != null) {
                parameters.put('SHIPTOLASTNAME', invoice.Shipping_Contact__r.LastName);
            }

            if(invoice.Shipping_Contact__r.MailingStreet != null) {
                parameters.put('SHIPTOSTREET', invoice.Shipping_Contact__r.MailingStreet);
            }

            if(invoice.Shipping_Contact__r.MailingCity != null) {
                parameters.put('SHIPTOCITY', invoice.Shipping_Contact__r.MailingCity);
            }

            if(invoice.Shipping_Contact__r.MailingPostalCode != null) {
                parameters.put('SHIPTOZIP', invoice.Shipping_Contact__r.MailingPostalCode);
            }

            if(invoice.Shipping_Contact__r.MailingPostalCode != null) {
                parameters.put('SHIPTOCOUNTRY', invoice.Shipping_Contact__r.MailingCountry);
            }
        }
    }
}