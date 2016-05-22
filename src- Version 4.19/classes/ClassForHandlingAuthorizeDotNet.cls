/**
     * Webservice for handling payments.
     *
     * @author Laxman Rao M, Manoj Ganapathy, Acertis Cloud Ltd
       Copyright (c) 2011, Acertis Cloud, Salesforce.com Inc.
       All rights reserved.
     */

    /*
        We have used AIM(Advanced Integration Method)
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

        Host Addresses
            Use the following host addresses for the authorize.net:
            1 For live transactions, use https://secure.authorize.net/gateway/transact.dll
            2 For testing purposes, use https://test.authorize.net/gateway/transact.dll
     */

    /*
    When To Use a Authorization and Capture(Sale Transaction in payapl)
       This is the most common type of credit card transaction and is the default payment
       gateway transaction type. The amount is sent for authorization, and if approved, is
       automatically submitted for settlement.

       The unique field requirement for an Authorization and Capture transaction is:
       x_type=AUTH_CAPTURE

    When To Use Authorization Only(Authorization/Delayed Capture Transactions in payapl)
       This transaction type is sent for authorization only. The transaction will not be sent for
       settlement until the credit card transaction type Prior Authorization and Capture (see
       definition below) is submitted, or the transaction is submitted for capture manually in the
       Merchant Interface.

       If action for the Authorization Only transaction is not taken on the payment gateway within
       30 days, the authorization expires and is no longer available for capture. A new
       Authorization Only transaction would then have to be submitted to obtain a new
       authorization code.

       The unique field requirement for an Authorization Only transaction is:
       x_type=AUTH_ONLY

    When To Use a Void Transaction
       This transaction type can be used to cancel either an original transaction that is not yet
       settled, or an entire order composed of more than one transactions. A Void prevents the
       transaction or the order from being sent for settlement. A Void can be submitted against
       any other transaction type.

       Note :
       If you are not sure whether a transaction is settled, you can attempt to submit a
       Void first. If the Void transaction results in an error, the original transaction is
       likely settled and you can submit a Credit for the transaction

       The payment gateway accepts Voids if the following conditions are met:
        1 The transaction is submitted with the valid transaction ID (x_trans_id) of an original,
        successfully authorized transaction. To void an entire order, submit the split tender ID
        (x_split_tender_id).
        2 The original transaction is not already settled, expired or errored.
        The unique field requirements for a Void transaction are:
        x_type=VOID
        x_trans_id=Transaction ID, or x_split_tender_id=Split Tender ID.

    When To Use a Credit Transaction
        This transaction type is used to refund a customer for a transaction that was originally
       processed and successfully settled through the payment gateway.

       The payment gateway accepts Credits if the following conditions are met:
        1 The transaction is submitted with the valid transaction ID (x_trans_id) of an original,
          successfully settled transaction.
        2 The amount being requested for refund is less than or equal to the original settled
          amount.
        3 The sum of multiple Credit transactions submitted against the original transaction is
          less than or equal to the original settled amount.
        4 At least the last four digits of the credit card number (x_card_num) used for the
        original, successfully settled transaction are submitted. An expiration date is not
        required.
        5 The transaction is submitted within 120 days of the settlement date of the original
          transaction.
        The unique field requirements for a Credit transactiton are:
        x_type=CREDIT
        x_trans_id=Transaction ID here
        x_card_num=Full credit card number or last four digits only here

    ================================================================
    Attributes :

    x_login (Required) :
        The merchant’s unique API Login ID
        The API Login ID and Transaction Key together provide the merchant authentication required for access to the payment gateway.
        The merchant API Login ID is provided in the Merchant Interface and must be stored securely.

    x_tran_key (Required) :
        The merchant’s unique Transaction Key

    x_type (Required) Indicates the type of transaction to perform. Values are:
                        ��CAPTURE_ONLY
                        �� CREDIT
                        �� AUTH_ONLY
                        �� AUTH_CAPTURE (default)
                        ��VOID

    x_method (Required) The method of payment. Values are:
        CC or ECHECK
        The method of payment for the transaction, CC (credit card) or ECHECK (electronic
        check). If this field is not submitted or is blank, the value will default to CC.

    x_card_num (Required for credit cards)
        The customer’s credit card number
        This is sensitive cardholder information and must be stored securely and in accordance
        with the Payment Card Industry (PCI) Data Security Standard

    x_exp_date (Required)
        Expiration date of the credit card.
        Format: MMYY, MM/YY, MM-YY, MMYYYY, MM/YYYY, MM-YYYY

    x_amount (Required)
       The amount of the transaction(usd)

    x_card_code (Optional)
       Customer code/customer reference ID

    x_invoice_num (Optional)
       The merchant-assigned invoice number for the transaction

    x_description
       The transaction description

    ==========================================================================
     */
    public with sharing class ClassForHandlingAuthorizeDotNet implements InterfacePaymentClass.paymentOperationsInterface {

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
        //This is used for Virtualterminal Purpose
        private Id currencyId;

        public ClassForHandlingAuthorizeDotNet(Gateway__c gateway, Invoice__c invoice, Payment_Method__c paymentMethod) {
            this.invoice = invoice;
            this.paymentMethod = paymentMethod;
            this.gateway = gateway;
            //Added by dhanalakshmi INVOICEIT-18
            if (invoice == null) {
                this.invoice = new Invoice__c();
            }

            initialize();
        }

        /*
        Modified By : Rama Krishna: 19 june 2013: INVOICEIT-194
        Comments    : added two parameters to constructor(i.e, Account and dAmount).
         */
        public ClassForHandlingAuthorizeDotNet(Gateway__c gateway, invoice__c invoice, Payment_Method__c paymentMethod, string sDummyPaymentId, decimal dAmount, Account account) {
            this.invoice = invoice;
            this.account = account;
            this.dAmount = dAmount;
            this.paymentMethod = paymentMethod;
            this.gateway = gateway;
            this.sDummyPaymentId = sDummyPaymentId;

            initialize();
        }

        //This is used for Virtualterminal Purpose
        public ClassForHandlingAuthorizeDotNet(Gateway__c gateway, invoice__c invoice, Payment_Method__c paymentMethod, string sDummyPaymentId, decimal dAmount, Account account, Id currencyId) {
            this.invoice = invoice;
            this.account = account;
            this.dAmount = dAmount;
            this.paymentMethod = paymentMethod;
            this.gateway = gateway;
            this.sDummyPaymentId = sDummyPaymentId;
            this.currencyId = currencyId;
            initialize();
        }

        private void initialize() {
            parameters = new map<string, string>();

            //this determines is it sandboz or live
            if (gateway.Test_Mode__c) {
                sHttpEndPoint = CommonUtilClass.ENDPOINT_AUTHORIZEDOTNET_TEST;
                parameters.put('x_email_customer', 'FALSE');
            } else {
                sHttpEndPoint = CommonUtilClass.ENDPOINT_AUTHORIZEDOTNET_LIVE;
                // Modified by Dhana Lakshmi:12-2014: INVOICEIT-294.
                if (gateway.Email_Customer__c == true) {
                    parameters.put('x_email_customer', 'TRUE');
                } else {
                    parameters.put('x_email_customer', 'FALSE');
                }
            }

            //fill the merchant information from gateway
            parameters.put('x_login', gateway.Merchant_ID__c);
            parameters.put('x_tran_key', gateway.Security_Key__c);

            //fill the version
            parameters.put('x_version', '3.1');

            //are the response fields(In order to receive a delimited response from the payment gateway,submit this field with a value of TRUE, or the merchant has to configure a delimited response through the Merchant Interface.)
            parameters.put('x_response_format', '1');
            parameters.put('x_delim_data', 'TRUE');
            parameters.put('x_delim_char', '|');

            //This field, when set to TRUE, instructs the payment gateway to return transaction results to the merchant by means of an HTML form POST to the merchant’s Web server for a relay response.
            parameters.put('x_relay_response', 'FALSE');
        }

        public PaymentOperations.PaymentResult handleAuthorize_Click() {
            decimal amountToBeProcessed = 0;
            try {
                if (invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                    amountToBeProcessed = invoice.Payment_Request_Amount__c;
                } else {
                    amountToBeProcessed = invoice.Unpaid_Amount__c;
                }

                //fill the type of method (Transaction Information)
                parameters.put('x_type', 'AUTH_ONLY');

                //fill the invoice number
                parameters.put('x_invoice_num', invoice.Name);

                //fill the invoice number and invoice Id
                parameters.put('x_description', 'SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name);

                //fill  amount
                parameters.put('x_amount', string.ValueOf(amountToBeProcessed));

                //call the method fillCardInformation() where card information is captured
                fillCardInformation();
                /*
                Modified By : Anil Pinto: 14 June 2013: INVOICEIT-125
                Comments    : Added below line which gives details of customer for billing and shipping information.
                 */
                populateCustomerDetails();
                transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_AUTHORIZATION, Amount__c = amountToBeProcessed, Currency__c = invoice.CurrencyL__c, Is_Payment_Processed_Successfully__c = true, Payment_Gateway__c = gateway.Id);
                /*   Modified by laxman     */
                transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
                transactionObj.Request_Invoice__c = invoice.Id;
                transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
                transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_AUTHORIZATION;

                /*   Modified by Ram  on April 30-2013 */
                transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
                transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
                transactionObj.Card_Type__c = paymentMethod.Card_Type__c;

                //call the methods for creating string of paramters from map, send http request to server, parse the response and handle request
                createStringFromMap();

                sHttpResponse = InvoicingUtilClass.getHTTPResponse(sHttpEndPoint, sHttpBody);
                responseArray = sHttpResponse.split('\\|');
                handleRequest();
            } catch (Exception ex) {
                result.message = ex.getMessage();
            }

            return result;
        }

        public PaymentOperations.PaymentResult handleAuthorizeAndCharge_Click(string transactionId, string gatewayID) {
            decimal amountToBeProcessed = 0;
            try {
                if (invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                    amountToBeProcessed = invoice.Payment_Request_Amount__c;
                } else {
                    amountToBeProcessed = invoice.Unpaid_Amount__c;
                }

                //fill  amount
                parameters.put('x_amount', string.ValueOf(amountToBeProcessed));

                //fill the invoice number
                parameters.put('x_invoice_num', invoice.Name);

                //fill the invoice number and invoice Id
                parameters.put('x_description', 'SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name);

                //call the method fillCardInformation() where card information is captured
                fillCardInformation();
                /*
                Modified By : Anil Pinto: 14 June 2013: INVOICEIT-125
                Comments    : Added below line which gives details of customer for billing and shipping information.
                */
                populateCustomerDetails();

                //intialize the transactionObj with parentId and set the type of transaction like Authorize, Charge, Void , Refund
                if (transactionId == null) {
                    transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, Amount__c = amountToBeProcessed, Currency__c = invoice.CurrencyL__c, Payment_Gateway__c = gateway.Id);
                    //fill the type of method (Transaction Information)
                    parameters.put('x_type', 'AUTH_CAPTURE');
                } else {
                    transactionObj = new Transaction__c(Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, Id = transactionId, Amount__c = amountToBeProcessed, Currency__c = invoice.CurrencyL__c);
                    //fill the type of method (Transaction Information)
                    parameters.put('x_type', 'PRIOR_AUTH_CAPTURE');

                    //fill the gatewayId
                    parameters.put('x_trans_id', gatewayID);
                }

                transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
                transactionObj.Request_Invoice__c = invoice.Id;
                transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
                transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE;

                /*   Modified by Ram:April 30-2013 */
                transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
                transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
                transactionObj.Card_Type__c = paymentMethod.Card_Type__c;

                //call the methods for creating string of paramters from map, send http request to server, parse the response and handle request
                createStringFromMap();

                sHttpResponse = InvoicingUtilClass.getHTTPResponse(sHttpEndPoint, sHttpBody);
                responseArray = sHttpResponse.split('\\|');
                handleRequest();
                if (transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                    //create the payment and payment allocation against the inv
                    InvoicingUtilClass.createPaymentAndPaymentAllocation(invoice, transactionObj);

                    transactionObj.Is_Payment_Processed_Successfully__c = true;
                    update transactionObj;
                }
            } catch (Exception ex) {
                result.message += '\n \n ' + system.Label.ExceptionOccurred + ' ' + ex.getMessage();
                if (transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                    result.message += system.Label.InvoiceIsCharged;
                    transactionObj.Is_Payment_Processed_Successfully__c = false;
                    transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                    update transactionObj;
                }
            }

            return result;
        }

       /* =================== Start ====================================== */

        /*
        Modified By : Rama Krishna: 12 Nov 2015: INVOICEIT-629
        Comments    : Creating a generic method for processing all payments. This will be used in global methods and API
        */

        // this constructor is created because we do not want to pass any values from ohter method 
        public ClassForHandlingAuthorizeDotNet(){

        }

        public PaymentSiteOperation.GenericPaymentResult handleAuthorizeAndCharge(PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters)
        {
            PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new  PaymentSiteOperation.GenericPaymentResult();
            try {
                    gateway = new Gateway__c();
                    invoice = new invoice__c();
                    paymentMethod  = new Payment_Method__c();
                    gateway = genericPaymentParameters.gateway;
                    invoice = genericPaymentParameters.invoiceObj;
                    paymentMethod = genericPaymentParameters.paymentMethod;

                    // this method to populate gateway method.
                    initialize();

                    parameters.put('x_amount', string.ValueOf(genericPaymentParameters.amountToProcess));

                    //fill the invoice number
                    //fill the invoice number and invoice Id
                    if (invoice.id != null) {
                        parameters.put('x_invoice_num', invoice.Name);
                        parameters.put('x_description', 'SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name);
                    } else if (paymentMethod.Account__r.Name != null ) {
                        parameters.put('x_invoice_num', paymentMethod.Account__r.Name);
                        parameters.put('x_description', 'SalesForce Id : ' + paymentMethod.Account__c + ' and Account Name : ' + paymentMethod.Account__r.Name);
                    }

                    parameters.put('x_type', 'AUTH_CAPTURE');
                    parameters.put('x_card_num', paymentMethod.Card_Number__c);
                    parameters.put('x_exp_date', paymentMethod.Card_Expiration_Month__c + paymentMethod.Card_Expiration_Year__c);
                    parameters.put('x_card_code', paymentMethod.CVV__c);
                    parameters.put('x_method', 'CC');
     
                    populateFullDetailsOfCustomer();

                    //call the methods for creating string of paramters from map, send http request to server, parse the response and handle request
                    createStringFromMap();
                    sHttpResponse = InvoicingUtilClass.getHTTPResponse(sHttpEndPoint, sHttpBody);
                    responseArray = sHttpResponse.split('\\|');


                    genericPaymentResult.transactionObj.Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE;
                    genericPaymentResult.transactionObj.Amount__c = genericPaymentParameters.amountToProcess;
                    genericPaymentResult.transactionObj.Payment_Gateway__c = gateway.Id;
                    genericPaymentResult.transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
                    genericPaymentResult.transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
                    genericPaymentResult.transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE;
                    genericPaymentResult.transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
                    genericPaymentResult.transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
                    genericPaymentResult.transactionObj.Card_Type__c = paymentMethod.Card_Type__c;
                    genericPaymentResult.transactionObj.Gateway_Date__c = system.now();
                    genericPaymentResult.transactionObj.Response_Code__c = responseArray.get(0);
                    genericPaymentResult.transactionObj.Reason_Code__c = decimal.ValueOf(responseArray.get(0));
                    genericPaymentResult.transactionObj.Response_Message__c = responseArray.get(3);
                    genericPaymentResult.transactionObj.Response__c = responseArray.get(3);
                    genericPaymentResult.transactionObj.AVS_Response_Code__c =  responseArray.get(5);
                    genericPaymentResult.transactionObj.Authorization__c = responseArray.get(4); // Authorization code
                    genericPaymentResult.transactionObj.Gateway_ID__c = responseArray.get(6); // transaction Id

                    if (responseArray.get(0) == '1') {
                        genericPaymentResult.isSuccess = true;
                        genericPaymentResult.message = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED;

                        genericPaymentResult.transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED;
                         
                        return genericPaymentResult;
                    } else if (responseArray.get(0) == '2') {
                        genericPaymentResult.isSuccess = false;
                        genericPaymentResult.message = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_DECLINED;
                        genericPaymentResult.transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_DECLINED;
                         
                        return genericPaymentResult;
                    } else if (responseArray.get(0) == '3') {
                        genericPaymentResult.isSuccess = false;
                        genericPaymentResult.message = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_ERROR;
                        genericPaymentResult.transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_ERROR;
                         
                        return genericPaymentResult;
                    } else {
                        genericPaymentResult.isSuccess = false;
                        genericPaymentResult.message = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_HELDFORREVIEW; 
                        genericPaymentResult.transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_HELDFORREVIEW;
                         
                        return genericPaymentResult;
                    }
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
        Modified By : Rama Krishna: 19 june 2013: INVOICEIT-194
        Comments    : previously force.site only supporting for the Invoice Payment,
                      now this method is accepting Payments for both Invoice and Account.
         */
        public PaymentOperations.PaymentResult handleAuthorizeAndCharge_Site(boolean isSaveCardDetails) {
            decimal amountToBeProcessed = 0;
            try {
                if (invoice != null && currencyId == null) {
                    if (invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                        amountToBeProcessed = invoice.Payment_Request_Amount__c;
                    } else {
                        amountToBeProcessed = invoice.Unpaid_Amount__c;
                    }
                } else {
                    /*
                    Modified By : Rama Krishna: 19 june 2013: INVOICEIT-194
                    Comments    : assigning advance request amount Of Account,
                     */
                    amountToBeProcessed = dAmount;
                }

                //fill  amount
                parameters.put('x_amount', string.ValueOf(amountToBeProcessed));

                //fill the invoice number
                //fill the invoice number and invoice Id
                if (invoice != null) {
                    parameters.put('x_invoice_num', invoice.Name);
                    parameters.put('x_description', 'SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name);
                } else {
                    /*
                    Modified By : Rama Krishna: 19 june 2013: INVOICEIT-194
                    Comments    : passing accounts Name,account.Id  to the gateway Parameters.
                     */
                    parameters.put('x_invoice_num', account.Name);
                    parameters.put('x_description', 'SalesForce Id : ' + account.Id + ' and Account Name : ' + account.Name);
                }

                //fill the type of method (Transaction Information)
                parameters.put('x_type', 'AUTH_CAPTURE');

                //call the method fillCardInformation() where card information is captured
                fillCardInformation();

                /*
                Modified By : Anil Pinto 14 June 2013: INVOICEIT-125
                Comment     : Added below line which gives details of customer for billing and shipping information.
                 */
                populateCustomerDetails();

                /*
                Modified By : Rama Krishna: 19 june 2013: INVOICEIT-194
                Comments    : querying the currency equals to USD, to assign currency for account Payments
                 */

                Currency__c currency1 = [SELECT Name FROM Currency__c WHERE Name = 'USD'];

                transactionObj = new Transaction__c(Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, Amount__c = amountToBeProcessed, Payment_Gateway__c = gateway.Id);

                if (invoice != null) {
                    transactionObj.Currency__c = invoice.CurrencyL__c;
                    transactionObj.Request_Invoice__c = invoice.Id;
                } else {
                    if (currencyId != null) {
                        //This is used for Virtualterminal Purpose
                        transactionObj.Currency__c = currencyId;
                    } else {
                        //This is used for Advance Request Payment Purpose
                        transactionObj.Currency__c = currency1.id;
                    }
                }

                transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
                transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
                transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE;

                /*   Modified by Ram  on April 30-2013 */
                transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
                transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
                transactionObj.Card_Type__c = paymentMethod.Card_Type__c;

                //call the methods for creating string of paramters from map, send http request to server, parse the response and handle request
                createStringFromMap();
                sHttpResponse = InvoicingUtilClass.getHTTPResponse(sHttpEndPoint, sHttpBody);
                responseArray = sHttpResponse.split('\\|');
                //
                if (responseArray.get(0) == '1') {
                    transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED;
                    if (isSaveCardDetails) {
                        // query the default payment method present for the account and update default to false
                        list<Payment_Method__c> defaultPaymentMethods;
                        if (invoice != null) {
                            defaultPaymentMethods = InvoicingUtilClass.getDefaultMethodForAccount(invoice.Account__c);
                        } else {
                            defaultPaymentMethods = InvoicingUtilClass.getDefaultMethodForAccount(account.Id);
                        }

                        if (!defaultPaymentMethods.isEmpty()) {
                            for (Payment_Method__c pm : defaultPaymentMethods) {
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
                } else {
                    if (responseArray.get(0) == '2') {
                        transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_DECLINED;
                    } else if (responseArray.get(0) == '3') {
                        transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_ERROR;
                    } else {
                        transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_HELDFORREVIEW;
                    }
                    transactionObj.Payment_Method__c = sDummyPaymentId;
                }

                if (invoice != null) {
                    transactionObj.Request_Invoice__c = invoice.Id;
                }

                transactionObj.Gateway_Date__c = system.now();
                transactionObj.Response_Code__c = responseArray.get(0);
                transactionObj.Reason_Code__c = decimal.ValueOf(responseArray.get(0));
                transactionObj.Response_Message__c = responseArray.get(3);
                transactionObj.Response__c = responseArray.get(3);
                transactionObj.AVS_Response_Code__c =  responseArray.get(5);
                transactionObj.Authorization__c = responseArray.get(4); // Authorization code
                transactionObj.Gateway_ID__c = responseArray.get(6); // transaction Id

                insert transactionObj;
                result.message = transactionObj.Response_Status__c + ' ' + transactionObj.Response_Message__c;

                if (transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                    //create the payment and payment allocation against the inv
                    if (invoice != null) {
                        if (currencyId != null) {
                            //this is used for virtual terminal payment
                            InvoicingUtilClass.createPaymentAndAllocationForVirtualTerminal(invoice, transactionObj);
                        } else {
                            InvoicingUtilClass.createPaymentAndPaymentAllocation(invoice, transactionObj);
                        }
                    } else {
                        if (currencyId != null) {
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
                        } else {
                            /*
                            Modified By : Rama Krishna: 19 june 2013: INVOICEIT-194
                            Comment     : creating payment for account with out invoice.
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
                            Modified By : Rama Krishna: 24-9-2013: INVOICEIT-239
                            Comment     : once Advance Amount Requested is received, updating the Advance Request Status To paid on Account
                             */
                            Account accToUpdate = new Account(id = account.Id, Advance_Request_Status__c = CommonUtilClass.STATUS_PAID);
                            update accToUpdate;
                        }
                    }
                    transactionObj.Is_Payment_Processed_Successfully__c = true;
                    update transactionObj;
                }
            } catch (Exception ex) {
                result.message += '\n \n ' + system.Label.ExceptionOccurred;
                if (transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                    result.message += system.Label.InvoiceIsCharged;
                    transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                } else {
                    result.message += '\n \n ' + system.Label.InvoiceIsNotCharged;
                    transactionObj.Exception_Message__c = 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                }

                transactionObj.Is_Payment_Processed_Successfully__c = false;
                if (transactionObj.Payment_Method__c == null) {
                    transactionObj.Payment_Method__c = sDummyPaymentId;
                }
                upsert transactionObj;
            }

            result.transactionObj = transactionObj;
            return result;
        }

        public PaymentOperations.PaymentResult handleVoid_Click(string gatewayId, string transactionId, decimal transactionAmount) {
            try {
                //fill the type of method (Transaction Information)
                parameters.put('x_type', 'VOID');

                //fill the invoice number
                parameters.put('x_invoice_num', invoice.Name);

                //in order to void the transaction we need trasactionId
                parameters.put('x_trans_id', gatewayId);

                /*
                Modified By : Anil Pinto: 14 June 2013: INVOICEIT-125
                Comments    : Added below line which gives full details of customer for billing and shipping information.
                 */
                populateFullDetailsOfCustomer();

                //intialize the transactionObj with parentId and set the type of transaction like Authorize, Charge, Void , Refund
                //transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_VOID, Id = transactionId, Gateway_ID__c = gatewayId, Is_Payment_Processed_Successfully__c = true, Amount__c = transactionAmount, Payment_Gateway__c = gateway.Id);
                transactionObj = new Transaction__c(Type__c = CommonUtilClass.TRANSACTION_TYPE_VOID, Id = transactionId, Gateway_ID__c = gatewayId, Is_Payment_Processed_Successfully__c = true, Amount__c = transactionAmount);
                transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
                transactionObj.Request_Invoice__c = invoice.Id;
                transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
                transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_VOID;

                /*   Modified by Ram  on April 30-2013 */
                transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
                transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
                transactionObj.Card_Type__c = paymentMethod.Card_Type__c;

                //call the methods for creating string of paramters from map, send http request to server, parse the response and handle request
                createStringFromMap();
                sHttpResponse = InvoicingUtilClass.getHTTPResponse(sHttpEndPoint, sHttpBody);
                responseArray = sHttpResponse.split('\\|');
                handleRequest();
                /* Modified by Laxman, according to jira - 49, 38 */
                if (transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                    //cancel the payment
                    InvoicingUtilClass.cancelPayment(transactionObj.Id);
                }
            } catch (Exception ex) {
                result.message = ex.getMessage();
            }

            return result;
        }

        public PaymentOperations.PaymentResult handleRefund_Click(string gatewayId, string transactionId, decimal transactionAmount) {
            try {
                //fill the type of method (Transaction Information)
                parameters.put('x_type', 'CREDIT');

                //fill the invoice number
                parameters.put('x_invoice_num', invoice.Name);

                //fill the invoice number and invoice Id
                parameters.put('x_description', 'Refund against SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name);

                //in order to refund/credit the money we need trasactionId
                parameters.put('x_trans_id', gatewayId);

                //x_card_num is the card number to be credited
                parameters.put('x_card_num', paymentMethod.Card_Number__c);

                //fill  amount
                parameters.put('x_amount', string.ValueOf(transactionAmount));

                /*
                Modified By  : Devender: 05 March 2014: INVOICEIT-332
                Comments     : Missing expiration date in refund transaction : Authorize.net
                 */
                //x_exp_date is the card exp date
                parameters.put('x_exp_date', paymentMethod.Card_Expiration_Month__c + paymentMethod.Card_Expiration_Year__c);

                /*
                Modified By : Anil Pinto: 14 June 2013: INVOICEIT-125
                Comments    : Added below line which gives full details of customer for billing and shipping information.
                 */
                populateFullDetailsOfCustomer();

                //intialize the transactionObj with parentId and set the type of transaction like Authorize, Charge, Void , Refund
                transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_REFUND, Id = transactionId, Gateway_ID__c = gatewayId, Amount__c = transactionAmount, Is_Payment_Processed_Successfully__c = true, Payment_Gateway__c = gateway.Id);
                transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
                transactionObj.Request_Invoice__c = invoice.Id;
                transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
                transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_REFUND;

                /*   Modified by Ram  on April 30-2013 */
                transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
                transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
                transactionObj.Card_Type__c = paymentMethod.Card_Type__c;

                //call the methods for creating string of paramters from map, send http request to server, parse the response and handle request
                createStringFromMap();

                sHttpResponse = InvoicingUtilClass.getHTTPResponse(sHttpEndPoint, sHttpBody);
                responseArray = sHttpResponse.split('\\|');
                handleRequest();

                if (transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                    //cancel the payment
                    InvoicingUtilClass.cancelPayment(transactionObj.Id);
                }
            } catch (Exception ex) {
                result.message = ex.getMessage();
            }

            return result;
        }

        private void fillCardInformation() {
            //fill the card information like card number, cvv, exp date and method like credit card
            parameters.put('x_card_num', paymentMethod.Card_Number__c);
            parameters.put('x_exp_date', paymentMethod.Card_Expiration_Month__c + paymentMethod.Card_Expiration_Year__c);
            parameters.put('x_card_code', paymentMethod.CVV__c);
            parameters.put('x_method', 'CC');

            //the following parameters are for the AVS
            /* Changed by Manoj and Dev on 25-04-2012 */
            if (paymentMethod.Billing_First_Name__c != null)
                parameters.put('x_first_name', paymentMethod.Billing_First_Name__c);

            if (paymentMethod.Billing_Last_Name__c != null)
                parameters.put('x_last_name', paymentMethod.Billing_Last_Name__c);

            if (paymentMethod.Billing_Address__c != null)
                parameters.put('x_address', paymentMethod.Billing_Address__c);

            if (paymentMethod.Billing_City__c != null)
                parameters.put('x_city', paymentMethod.Billing_City__c);

            if (paymentMethod.Billing_State_Province__c != null)
                parameters.put('x_state', paymentMethod.Billing_State_Province__c);

            if (paymentMethod.Billing_Zip_Postal__c != null)
                parameters.put('x_zip', paymentMethod.Billing_Zip_Postal__c);

            if (paymentMethod.Billing_Country__c != null)
                parameters.put('x_country', paymentMethod.Billing_Country__c);

        }

        //here from map we will "create key = value &" format
        //because we have to pass to endPoint
        private void createStringFromMap() {
            for (String key : parameters.keyset()) {
                // if the value is null, then it throws an exception
                // Ref : INVOICEIT-222, sometimes cvv will be optional for Authorize.net
                if (parameters.get(key) != null) {
                    sHttpBody += key + '=' +  EncodingUtil.urlEncode(parameters.get(key), 'UTF-8') + '&';
                }
            }

            sHttpBody = this.sHttpBody.substring(0, sHttpBody.length() - 1);
        }

        private void handleRequest() {
            Transaction__c transactionObj2;
            //we have to refer page http://www.authorize.net/support/AIM_guide.pdf 37 page
            //if responseArray.get(0). 1 = Approved, 2 = Declined, 3 = Error, 4 = Held For review
            if (responseArray.get(0) == '1') {
                transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED;
                result.reloadPage = true;
            } else {
                if (transactionObj.Id != null) {
                    transactionObj2 = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = transactionObj.Type__c, Gateway_ID__c = transactionObj.Gateway_ID__c, Amount__c = transactionObj.Amount__c);
                    transactionObj2.Request_Credit_Card_Number__c = transactionObj.Request_Credit_Card_Number__c;
                    transactionObj2.Currency__c = transactionObj.Currency__c;
                    transactionObj2.Request_Type_Of_Payment__c = transactionObj.Request_Type_Of_Payment__c;
                    transactionObj2.Request_Transaction_Type__c = transactionObj.Request_Transaction_Type__c;
                    sObject sObjTrasn = (sObject)transactionObj2;
                    transactionObj = (Transaction__c)sObjTrasn;
                }

                if (responseArray.get(0) == '2') {
                    transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_DECLINED;
                    //Added by DL, for faild transactions unchecking the 'Payment Process Successful?' checkbox, INVOICEIT-635
                    transactionObj.Is_Payment_Processed_Successfully__c = false;
                } else if (responseArray.get(0) == '3') {
                    transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_ERROR;
                    //Added by DL, INVOICEIT-635
                    transactionObj.Is_Payment_Processed_Successfully__c = false;
                } else {
                    transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_HELDFORREVIEW;
                    //Added by DL, INVOICEIT-635
                    transactionObj.Is_Payment_Processed_Successfully__c = false;
                }
            }

            transactionObj.Request_Invoice__c = invoice.Id;
            //transactionObj.Payment_Gateway__c = gateway.Id;
            transactionObj.Gateway_Date__c = system.now();
            transactionObj.Response_Code__c = responseArray.get(0);
            transactionObj.Reason_Code__c = decimal.ValueOf(responseArray.get(0));
            transactionObj.Response_Message__c = responseArray.get(3);
            transactionObj.Response__c = responseArray.get(3);
            transactionObj.AVS_Response_Code__c =  responseArray.get(5);
            transactionObj.Authorization__c = responseArray.get(4); // Authorization code
            if (transactionObj.Gateway_ID__c == null) {
                transactionObj.Gateway_ID__c = responseArray.get(6); // transaction Id
            }

            if (transactionObj.Id == null) {
                result.message =  system.Label.transactioncreated;
            } else {
                result.message =  system.Label.transactionupdated;
            }

            if (transactionObj.Id == null) {
                transactionObj.Payment_Gateway__c = gateway.Id;

            }
            upsert transactionObj;

            transactionObj = [SELECT Name, Response_Status__c, Amount__c
                              FROM Transaction__c
                              WHERE Id = : transactionObj.Id];

            result.message +=  transactionObj.Name + ' \n'
                               + 'Gateway Response : ' +  responseArray.get(3) + ' \n'
                               + 'Gateway Status : ' + transactionObj.Response_Status__c;

            result.transactionObj = transactionObj;
        }

        // This below method gives the details of customer, included for the Jira Task - 125
        /*
            Modified By : Anil Pinto: 14 June 2013: INVOICEIT-125
            Comments    : This code gives the full details of customer for billing and shipping information.
         */
        public void populateFullDetailsOfCustomer() {
            // billing details
            if (paymentMethod.Billing_First_Name__c != null) {
                parameters.put('x_first_name', paymentMethod.Billing_First_Name__c);
            }

            if (paymentMethod.Billing_Last_Name__c != null) {
                parameters.put('x_last_name', paymentMethod.Billing_Last_Name__c);
            }

            if (paymentMethod.Account__r.Name != null) {
                parameters.put('x_company', paymentMethod.Account__r.Name);
            }

            if (paymentMethod.Billing_Address__c != null) {
                parameters.put('x_address', paymentMethod.Billing_Address__c);
            }

            if (paymentMethod.Account__r.Name != null && paymentMethod.Account__c != null) {
                parameters.put('x_cust_id', paymentMethod.Account__r.Name + '(' + paymentMethod.Account__c + ')');
            }

            if (paymentMethod.Billing_City__c != null) {
                parameters.put('x_city', paymentMethod.Billing_City__c);
            }

            if (paymentMethod.Billing_State_Province__c != null) {
                parameters.put('x_state', paymentMethod.Billing_State_Province__c);
            }

            if (paymentMethod.Billing_Zip_Postal__c != null) {
                parameters.put('x_zip', paymentMethod.Billing_Zip_Postal__c);
            }

            if ( paymentMethod.Billing_Country__c != null) {
                parameters.put('x_country', paymentMethod.Billing_Country__c);
            }

            if (paymentMethod.Billing_Phone__c != null) {
                parameters.put('x_phone', paymentMethod.Billing_Phone__c);
            }

            if (paymentMethod.Billing_Fax__c != null) {
                parameters.put('x_fax', paymentMethod.Billing_Fax__c);
            }

            if (paymentMethod.Billing_Email__c != null) {
                parameters.put('x_email', paymentMethod.Billing_Email__c);
            }

            // shipping details
            //invoice will be null, if the payment is done directly against the account
            if (invoice != null) {
                if (invoice.Shipping_Contact__r.FirstName != null) {
                    parameters.put('x_ship_to_first_name', invoice.Shipping_Contact__r.FirstName);
                }
                if (invoice.Shipping_Contact__r.LastName != null) {
                    parameters.put('x_ship_to_last_name', invoice.Shipping_Contact__r.LastName);
                }

                if (invoice.Shipping_Contact__r.Account.Name != null) {
                    parameters.put('x_ship_to_company', invoice.Shipping_Contact__r.Account.Name);
                }

                if (invoice.Shipping_Contact__r.MailingStreet != null) {
                    parameters.put('x_ship_to_address', invoice.Shipping_Contact__r.MailingStreet);
                }

                if (invoice.Shipping_Contact__r.MailingCity != null) {
                    parameters.put('x_ship_to_city', invoice.Shipping_Contact__r.MailingCity);
                }

                if (invoice.Shipping_Contact__r.MailingState != null) {
                    parameters.put('x_ship_to_state', invoice.Shipping_Contact__r.MailingState);
                }

                if (invoice.Shipping_Contact__r.MailingPostalCode != null) {
                    parameters.put('x_ship_to_zip', invoice.Shipping_Contact__r.MailingPostalCode);
                }

                if (invoice.Shipping_Contact__r.MailingPostalCode != null) {
                    parameters.put('x_ship_to_country', invoice.Shipping_Contact__r.MailingCountry);
                }
            }
        }

        // This below method gives the details of customer, included - 125
        /*
        Modified By : Anil Pinto: 14 June 2013: INVOICEIT-125
        Comment     : This code gives the details of customer for billing and shipping information, not all fields data are used in this method since some other method gives
                      the information
         */
        public void populateCustomerDetails() {
            // Billing details
            if (paymentMethod.Account__r.Name != null) {
                parameters.put('x_company', paymentMethod.Account__r.Name);
            }
            if (paymentMethod.Account__c != null) {
                parameters.put('x_cust_id', paymentMethod.Account__c);
            }

            if (paymentMethod.Billing_Phone__c != null) {
                parameters.put('x_phone', paymentMethod.Billing_Phone__c);
            }

            if (paymentMethod.Billing_Fax__c != null) {
                parameters.put('x_fax', paymentMethod.Billing_Fax__c);
            }

            if (paymentMethod.Billing_Email__c != null) {
                parameters.put('x_email', paymentMethod.Billing_Email__c);
            }

            //invoice will be null, if the payment is done directly against the account
            if (invoice != null) {
                // shipping details
                if (invoice.Shipping_Contact__r.FirstName != null) {
                    parameters.put('x_ship_to_first_name', invoice.Shipping_Contact__r.FirstName);
                }
                if (invoice.Shipping_Contact__r.LastName != null) {
                    parameters.put('x_ship_to_last_name', invoice.Shipping_Contact__r.LastName);
                }

                if (invoice.Shipping_Contact__r.Account.Name != null) {
                    parameters.put('x_ship_to_company', invoice.Shipping_Contact__r.Account.Name);
                }

                if (invoice.Shipping_Contact__r.MailingStreet != null) {
                    parameters.put('x_ship_to_address', invoice.Shipping_Contact__r.MailingStreet);
                }

                if (invoice.Shipping_Contact__r.MailingCity != null) {
                    parameters.put('x_ship_to_city', invoice.Shipping_Contact__r.MailingCity);
                }

                if (invoice.Shipping_Contact__r.MailingState != null) {
                    parameters.put('x_ship_to_state', invoice.Shipping_Contact__r.MailingState);
                }

                if (invoice.Shipping_Contact__r.MailingPostalCode != null) {
                    parameters.put('x_ship_to_zip', invoice.Shipping_Contact__r.MailingPostalCode);
                }

                if (invoice.Shipping_Contact__r.MailingPostalCode != null) {
                    parameters.put('x_ship_to_country', invoice.Shipping_Contact__r.MailingCountry);
                }
            }
        }
    }