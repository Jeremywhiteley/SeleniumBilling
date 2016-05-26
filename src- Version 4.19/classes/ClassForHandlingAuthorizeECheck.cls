/**
    Merchant to ensure that the following minimum requirements have been met:
        The merchant must have a U.S. based merchant bank account that allows Internet
    transactions.

    Note
    The integration described in this document is not required for merchants using
    Server Integration Method (SIM) since all required eCheck.Net fields are
    provided by default on the payment gateway hosted payment form.

        1  The merchant must have an e-commerce (Card Not Present) Authorize.Net Payment
           Gateway account.

        2  The merchant’s website or other business application has been successfully
           integrated to the Authorize.Net Payment Gateway using Advanced Integration Method
           (AIM). See the AIM Developer Guide at http://developer.authorize.net/guides/AIM/ for
           more information.

        3  The merchant has completed the eCheck.Net application and underwriting process
           with Authorize.Net and is enabled to process eCheck.Net transactions.

        // attributes
        // Required :
        Merchant Information 
            x_login
            x_tran_key

        Payment Information 
            x_method
            x_amount
            x_bank_aba_code
            x_bank_acct_num
            x_bank_acct_type
            x_bank_name
            x_bank_acct_name
            x_echeck_type
            x_bank_check_number (required only when x_echeck_type=ARC or BOC)
            x_recurring_billing (required only when x_echeck_type=WEB or TEL)
            x_delim_data (TRUE)
            x_relay_response (FALSE)
     */
    public with sharing class ClassForHandlingAuthorizeECheck implements InterfacePaymentClass.paymentOperationsInterface {
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
        private Account account;
        private decimal dAmount;
        private string sDummyPaymentId;
        private Id currencyId;
        private boolean isSavePaymentMethod = false;
        private boolean isGenericMethodCall = true;

        public ClassForHandlingAuthorizeECheck(Gateway__c gateway, Invoice__c invoice, Payment_Method__c paymentMethod) {
            this.invoice = invoice;
            this.paymentMethod = paymentMethod;
            this.gateway = gateway;
            
            //Added by dhanalakshmi INVOICEIT-18
            if(invoice == null)
            {
                this.invoice = new Invoice__c();
            } 
            initialize();
        } 

        public ClassForHandlingAuthorizeECheck(Gateway__c gateway, Invoice__c invoice, Payment_Method__c paymentMethod, string sDummyPaymentId, decimal dAmount,Account account,Id currencyId) {
            
            this.invoice = invoice;     
            this.account = account;
            this.dAmount = dAmount;
            this.paymentMethod = paymentMethod;
            this.gateway = gateway;
            // This has been declared but never used
            this.sDummyPaymentId = sDummyPaymentId;
            this.currencyId = currencyId;

            initialize();
         } 

        private void initialize() {
            parameters = new map<string, string>();

            //this determines is it sandboz or live
            if(gateway.Test_Mode__c){
                sHttpEndPoint = CommonUtilClass.ENDPOINT_AUTHORIZEDOTNET_TEST;
                parameters.put('x_email_customer', 'FALSE');
            } else {
                sHttpEndPoint = CommonUtilClass.ENDPOINT_AUTHORIZEDOTNET_LIVE;
                parameters.put('x_email_customer', 'TRUE');
            }

            //fill the merchant information from gateway
            parameters.put('x_login', gateway.Merchant_ID__c);
            parameters.put('x_tran_key', gateway.Security_Key__c);

            //fill the version
            parameters.put('x_version', '3.1');          

            //are the response fields(In order to receive a delimited response from the payment gateway,submit this field with a value of TRUE, or the merchant has to configure a delimited response through the Merchant Interface.)
            //x_response_format = 0 or 1. 0 = XML and 1 = Delimited
            parameters.put('x_response_format','1'); 
            parameters.put('x_delim_data', 'TRUE');
            parameters.put('x_delim_char', '|'); 

            //This field, when set to TRUE, instructs the payment gateway to return transaction results to the merchant by means of an HTML form POST to the merchant’s Web server for a relay response.
            parameters.put('x_relay_response', 'FALSE');
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
                parameters.put('x_type', 'AUTH_ONLY');   

                //fill the invoice number
                parameters.put('x_invoice_num', invoice.Name);

                //fill the invoice number and invoice Id
                parameters.put('x_description', 'SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name);

                //fill  amount
                parameters.put('x_amount', string.ValueOf(amountToBeProcessed));

                //call the method fillCardInformation() where card information is captured
                fillCardInformation();

                //intialize the transactionObj with parentId and set the type of transaction like Authorize, Charge, Void , Refund
                transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_AUTHORIZATION, Amount__c = amountToBeProcessed, Currency__c = invoice.CurrencyL__c, Is_Payment_Processed_Successfully__c = true, Payment_Gateway__c = gateway.Id);
                transactionObj.Request_Credit_Card_Number__c = paymentMethod.Bank_Account_Number__c.substring((paymentMethod.Bank_Account_Number__c.Length() - 4), paymentMethod.Bank_Account_Number__c.Length());
                transactionObj.Request_Invoice__c = invoice.Id;
                transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_ECHECK;
                transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_AUTHORIZATION;

                //call the methods for creating string of paramters from map, send http request to server, parse the response and handle request
                createStringFromMap();      

                sHttpResponse = InvoicingUtilClass.getHTTPResponse(sHttpEndPoint, sHttpBody); 
                responseArray = sHttpResponse.split('\\|');
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
                parameters.put('x_amount', string.ValueOf(amountToBeProcessed));

                //fill the invoice number
                parameters.put('x_invoice_num', invoice.Name);

                //fill the invoice number and invoice Id
                parameters.put('x_description', 'SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name);

                //call the method fillCardInformation() where card information is captured
                fillCardInformation();

                //intialize the transactionObj with parentId and set the type of transaction like Authorize, Charge, Void , Refund
                if(transactionId == null) {
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

                transactionObj.Request_Credit_Card_Number__c = paymentMethod.Bank_Account_Number__c.substring((paymentMethod.Bank_Account_Number__c.Length() - 4), paymentMethod.Bank_Account_Number__c.Length());
                transactionObj.Request_Invoice__c = invoice.Id;
                transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_ECHECK;
                transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE;

                //call the methods for creating string of paramters from map, send http request to server, parse the response and handle request
                createStringFromMap();      
                sHttpResponse = InvoicingUtilClass.getHTTPResponse(sHttpEndPoint, sHttpBody); 
                responseArray = sHttpResponse.split('\\|');
                handleRequest();
                if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                    /*
                    Modified By : Rama Krishna.V: 23-7-13/21-10-2013: SUP-23/SUP-119
                    Comments    : creating paymetnt and allocation against the requested invoice.
                     */
                    Payment__c payment = new Payment__c(Account__c = invoice.Account__c, 
                            Amount__c = transactionObj.Amount__c, 
                            Status__c = CommonUtilClass.STATUS_COMPLETED, 
                            Payment_Type__c = CommonUtilClass.PAYMENTTYPE_ACH,
                            Payment_Date__c = system.today(),
                            Transaction__c = transactionObj.Id,
                            Currency__c = invoice.CurrencyL__c,Invoice__c = invoice.Id);

                    insert payment;

                    Payment_Allocation__c paymentAllocation = new Payment_Allocation__c(Payment__c = payment.Id,
                            Amount__c = payment.Amount__c,
                            Invoice__c = invoice.Id,
                            Status__c = CommonUtilClass.STATUS_COMPLETED);   

                    insert paymentAllocation; 

                    transactionObj.Is_Payment_Processed_Successfully__c = true;
                    update transactionObj;                                                                                                 
                }
            } catch(Exception ex) {
                result.message += '\n \n '+system.Label.ExceptionOccurred +' ' + ex.getMessage();
                if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                    result.message +=  system.Label.InvoiceIsCharged;
                    transactionObj.Is_Payment_Processed_Successfully__c = false;
                    transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                    update transactionObj;   
                }
            }    

            return result;
        }
        
/*-------------------------Generic Method starts-------------------------*/

public PaymentSiteOperation.GenericPaymentResult handleAuthorizeAndCharge(PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters) {

         PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new  PaymentSiteOperation.GenericPaymentResult();


            decimal amountToBeProcessed = 0;
            try { 
                 isGenericMethodCall = false;
                // string amount = genericPaymentParameters.amountToProcess.toPlainString();
                /*if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                    amountToBeProcessed = invoice.Payment_Request_Amount__c;
                } else {
                    amountToBeProcessed = invoice.Unpaid_Amount__c;
                }*/

                //fill  amount
                parameters.put('x_amount', string.ValueOf(genericPaymentParameters.amountToProcess));

                //fill the invoice number
                parameters.put('x_invoice_num', invoice.Name);

                //fill the invoice number and invoice Id
                parameters.put('x_description', 'SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name);

                //call the method fillCardInformation() where card information is captured
                fillCardInformation();
                  string transactionId;
                  string gatewayId;
                //intialize the transactionObj with parentId and set the type of transaction like Authorize, Charge, Void , Refund
                if(transactionId == null) {
                    transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, Amount__c = genericPaymentParameters.amountToProcess, Currency__c = invoice.CurrencyL__c, Payment_Gateway__c = gateway.Id);

                    //fill the type of method (Transaction Information)
                    parameters.put('x_type', 'AUTH_CAPTURE');
                } else {
                    transactionObj = new Transaction__c(Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, Id = transactionId, Amount__c = genericPaymentParameters.amountToProcess, Currency__c = invoice.CurrencyL__c);

                    //fill the type of method (Transaction Information)
                    parameters.put('x_type', 'PRIOR_AUTH_CAPTURE');

                    //fill the gatewayId
                    parameters.put('x_trans_id', gatewayID);
                }

                transactionObj.Request_Credit_Card_Number__c = paymentMethod.Bank_Account_Number__c.substring((paymentMethod.Bank_Account_Number__c.Length() - 4), paymentMethod.Bank_Account_Number__c.Length());
                transactionObj.Request_Invoice__c = invoice.Id;
                transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_ECHECK;
                transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE;

                //call the methods for creating string of paramters from map, send http request to server, parse the response and handle request
                createStringFromMap();      
                sHttpResponse = InvoicingUtilClass.getHTTPResponse(sHttpEndPoint, sHttpBody); 
                responseArray = sHttpResponse.split('\\|');
                handleRequest();
               /* if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED)
                   
                    Payment__c payment = new Payment__c(Account__c = invoice.Account__c, 
                            Amount__c = transactionObj.Amount__c, 
                            Status__c = CommonUtilClass.STATUS_COMPLETED, 
                            Payment_Type__c = CommonUtilClass.PAYMENTTYPE_ACH,
                            Payment_Date__c = system.today(),
                            Transaction__c = transactionObj.Id,
                            Currency__c = invoice.CurrencyL__c,Invoice__c = invoice.Id);

                    //insert payment;

                    Payment_Allocation__c paymentAllocation = new Payment_Allocation__c(Payment__c = payment.Id,
                            Amount__c = payment.Amount__c,
                            Invoice__c = invoice.Id,
                            Status__c = CommonUtilClass.STATUS_COMPLETED);   

                   // insert paymentAllocation; 

                    transactionObj.Is_Payment_Processed_Successfully__c = true;
                    update transactionObj;  */
                    
                     genericPaymentResult.transactionObj = transactionObj;
            genericPaymentResult.message = transactionObj.Response_Status__c + ' ' + transactionObj.Response_Message__c;
            if(transactionObj.Exception_Message__c != null){
                genericPaymentResult.message = transactionObj.Exception_Message__c;
            }

            if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED){
                genericPaymentResult.isSuccess = true;
            }else{
                genericPaymentResult.isSuccess = false;
            }
            return genericPaymentResult;
              
                                                                                                                   
                }
                
                catch(Exception ex) {
                genericPaymentResult.message += '\n \n ' + system.Label.ExceptionOccurred;
                genericPaymentResult.message += 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                genericPaymentResult.isSuccess = false;
                 
                return genericPaymentResult;
             }

            return null;
        }
        


/*-------------------------Generic Method Ends--------------------------*/        
        
        
        
        // Created by Dev M : INVOICEIT-536
        public PaymentOperations.PaymentResult handleAuthorizeAndCharge_Site(boolean isSaveCardDetails){
            decimal amountToBeProcessed = 0;
            isSavePaymentMethod = isSaveCardDetails;
            try { 
                if(dAmount != null) {
                    amountToBeProcessed = dAmount;
                } else if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                    amountToBeProcessed = invoice.Payment_Request_Amount__c;
                } else {
                    amountToBeProcessed = invoice.Unpaid_Amount__c;
                }

                //fill  amount
                parameters.put('x_amount', string.ValueOf(amountToBeProcessed));

                //fill the invoice number
                if(invoice != null)
                    parameters.put('x_invoice_num', invoice.Name);
                else
                    parameters.put('x_invoice_num', account.Name);

                //fill the invoice number and invoice Id
                if(invoice != null)
                    parameters.put('x_description', 'SalesForce Id : ' + invoice.Id + ' and Invoice Number : ' + invoice.Name);
                else
                    parameters.put('x_description', 'SalesForce Id : ' + account.Id + ' and Invoice Number : ' + account.Name);

                if(invoice != null)
                    currencyId = invoice.CurrencyL__c;
                else if(currencyId == null) {
                    Currency__c currency1 = [SELECT Name FROM Currency__c WHERE Name = 'USD']; 
                    currencyId = currency1.Id;   
                }

                //call the method fillCardInformation() where card information is captured
                fillCardInformation();

                //intialize the transactionObj with parentId and set the type of transaction like Authorize, Charge, Void , Refund
                if(!isSavePaymentMethod) {
                    transactionObj = new Transaction__c(Payment_Method__c = sDummyPaymentId, Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, Amount__c = amountToBeProcessed, Currency__c = currencyId, Payment_Gateway__c = gateway.Id);

                    //fill the type of method (Transaction Information)
                    parameters.put('x_type', 'AUTH_CAPTURE');
                } else {
                    transactionObj = new Transaction__c(Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, Amount__c = amountToBeProcessed, Currency__c = currencyId, Payment_Gateway__c = gateway.Id);

                    //fill the type of method (Transaction Information)
                    parameters.put('x_type', 'AUTH_CAPTURE');
                }

                transactionObj.Request_Credit_Card_Number__c = paymentMethod.Bank_Account_Number__c.substring((paymentMethod.Bank_Account_Number__c.Length() - 4), paymentMethod.Bank_Account_Number__c.Length());
                if(invoice != null)
                    transactionObj.Request_Invoice__c = invoice.Id;
                transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_ECHECK;
                transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE;

                //call the methods for creating string of paramters from map, send http request to server, parse the response and handle request
                createStringFromMap();      
                sHttpResponse = InvoicingUtilClass.getHTTPResponse(sHttpEndPoint, sHttpBody); 
                responseArray = sHttpResponse.split('\\|');
                handleRequest();
                if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
       
                    if(invoice != null) {
                        Payment__c payment = new Payment__c(Account__c = invoice.Account__c, 
                                Amount__c = transactionObj.Amount__c, 
                                Status__c = CommonUtilClass.STATUS_COMPLETED, 
                                Payment_Type__c = CommonUtilClass.PAYMENTTYPE_ACH,
                                Payment_Date__c = system.today(),
                                Transaction__c = transactionObj.Id,
                                Currency__c = invoice.CurrencyL__c,Invoice__c = invoice.Id);

                        insert payment;

                        Payment_Allocation__c paymentAllocation = new Payment_Allocation__c(Payment__c = payment.Id,
                                Amount__c = payment.Amount__c,
                                Invoice__c = invoice.Id,
                                Status__c = CommonUtilClass.STATUS_COMPLETED);   

                        insert paymentAllocation; 
                    } else {
                        Payment__c payment = new Payment__c(Account__c = account.Id, 
                                Amount__c = transactionObj.Amount__c, 
                                Status__c = CommonUtilClass.STATUS_COMPLETED, 
                                Payment_Type__c = CommonUtilClass.PAYMENTTYPE_ACH,
                                Payment_Date__c = system.today(),
                                Transaction__c = transactionObj.Id,
                                Currency__c = currencyId);

                        insert payment;
                    }

                    transactionObj.Is_Payment_Processed_Successfully__c = true;
                    update transactionObj;                                                                                                 
                }
            } catch(Exception ex) {
                result.message += '\n \n '+system.Label.ExceptionOccurred +' ' + ex.getMessage();
                if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                    result.message +=  system.Label.InvoiceIsCharged;
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
                parameters.put('x_type', 'VOID');    

                //in order to void the transaction we need trasactionId
                parameters.put('x_trans_id', gatewayId);

                //intialize the transactionObj with parentId and set the type of transaction like Authorize, Charge, Void , Refund
                transactionObj = new Transaction__c(Type__c = CommonUtilClass.TRANSACTION_TYPE_VOID, Id = transactionId, Gateway_ID__c = gatewayId, Is_Payment_Processed_Successfully__c = true, Amount__c = transactionAmount);
                transactionObj.Request_Credit_Card_Number__c = paymentMethod.Bank_Account_Number__c.substring((paymentMethod.Bank_Account_Number__c.Length() - 4), paymentMethod.Bank_Account_Number__c.Length());
                transactionObj.Request_Invoice__c = invoice.Id;
                transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_ECHECK;
                transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_VOID;

                //call the methods for creating string of paramters from map, send http request to server, parse the response and handle request
                createStringFromMap();      
                sHttpResponse = InvoicingUtilClass.getHTTPResponse(sHttpEndPoint, sHttpBody); 
                responseArray = sHttpResponse.split('\\|');
                handleRequest();
                /* Modified by Laxman, according to jira - 49, 38 */
                if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                    /*
                    Modified By : Rama Krishna.V: 23-7-13: SUP-23
                    Comments    : cancelling payment and allocation.
                    */
                    InvoicingUtilClass.cancelPayment(transactionObj.Id);
                }
            } catch(Exception ex) {
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

                //fill the bank information from the payment method to refund
                fillCardInformation();

                //fill amount
                parameters.put('x_amount', string.ValueOf(transactionAmount));

                //intialize the transactionObj with parentId and set the type of transaction like Authorize, Charge, Void , Refund
                transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_REFUND, Id = transactionId, Gateway_ID__c = gatewayId, Amount__c = transactionAmount, Is_Payment_Processed_Successfully__c = true, Payment_Gateway__c = gateway.Id);
                transactionObj.Request_Credit_Card_Number__c = paymentMethod.Bank_Account_Number__c.substring((paymentMethod.Bank_Account_Number__c.Length() - 4), paymentMethod.Bank_Account_Number__c.Length());
                transactionObj.Request_Invoice__c = invoice.Id;
                transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_ECHECK;
                transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_REFUND;

                //call the methods for creating string of paramters from map, send http request to server, parse the response and handle request
                createStringFromMap();      
                sHttpResponse = InvoicingUtilClass.getHTTPResponse(sHttpEndPoint, sHttpBody); 
                responseArray = sHttpResponse.split('\\|');
                handleRequest();

                if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                    /*
                    Modified By : Rama Krishna.V: 23-7-13: SUP-23
                    Comments    : cancelling payment and allocation.
                     */
                    InvoicingUtilClass.cancelPayment(transactionObj.Id);
                }
            } catch(Exception ex) {
                result.message = ex.getMessage();
            }

            return result;
        }

        private void fillCardInformation() {
            //fill the card information like bank account number, bank code, bank name, type of account
            parameters.put('x_bank_aba_code', paymentMethod.Bank_Routing_Code__c);
            parameters.put('x_bank_acct_num', paymentMethod.Bank_Account_Number__c);
            parameters.put('x_bank_acct_type', paymentMethod.Bank_Account_Type__c);
            parameters.put('x_bank_name', paymentMethod.Bank_Name__c);
            parameters.put('x_bank_acct_name', paymentMethod.Bank_Account_Name__c);
            parameters.put('x_echeck_type', 'CCD');
            parameters.put('x_method', 'ECHECK');
        }

        private void createStringFromMap() {
            for(String key : parameters.keyset()) {
                // if the value is null, then it throws an exception
                // Ref : INVOICEIT-222, sometimes cvv will be optional for Paypal
                if(parameters.get(key) != null) {
                    sHttpBody += key + '=' +  EncodingUtil.urlEncode(parameters.get(key), 'UTF-8') + '&';
                }
            }

            sHttpBody = this.sHttpBody.substring(0, sHttpBody.length() - 1);
        }

        private void handleRequest() {
            Transaction__c transactionObj2;
            //we have to refer page http://www.authorize.net/support/AIM_guide.pdf 37 page
            //if responseArray.get(0). 1 = Approved, 2 = Declined, 3 = Error, 4 = Held For review
            // if(isGenericMethodCall){
           // result.message = system.Label.transactioncreated;
            if(isSavePaymentMethod) {
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
                insert paymentMethod;
                //populate Default Method on account
                CommonUtilClass.populateDefaultMethod(paymentMethod);

                transactionObj.Payment_Method__c = paymentMethod.Id;
            }
            if(responseArray.get(0) == '1') {
                transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED;
                result.reloadPage = true;
            } else {
                if(transactionObj.Id != null) {
                    transactionObj2 = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = transactionObj.Type__c, Gateway_ID__c = transactionObj.Gateway_ID__c, Amount__c = transactionObj.Amount__c);
                    transactionObj2.Request_Credit_Card_Number__c = transactionObj.Request_Credit_Card_Number__c;
                    transactionObj2.Currency__c = transactionObj.Currency__c;
                    transactionObj2.Request_Type_Of_Payment__c = transactionObj.Request_Type_Of_Payment__c;
                    transactionObj2.Request_Transaction_Type__c = transactionObj.Request_Transaction_Type__c;

                    sObject sObjTrasn = (sObject)transactionObj2;
                    transactionObj = (Transaction__c)sObjTrasn;
                }

                if(responseArray.get(0) == '2') {
                    transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_DECLINED;
                    //Added by DL, for faild transactions unchecking the 'Payment Process Successful?' checkbox, INVOICEIT-635
                    transactionObj.Is_Payment_Processed_Successfully__c = false;
                } else if(responseArray.get(0) == '3') {
                    transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_ERROR;
                    //Added by DL, INVOICEIT-635
                    transactionObj.Is_Payment_Processed_Successfully__c = false;
                } else {
                    transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_HELDFORREVIEW;
                    //Added by DL, INVOICEIT-635
                    transactionObj.Is_Payment_Processed_Successfully__c = false;
                }
            }
            if(invoice != null)
                transactionObj.Request_Invoice__c = invoice.Id;
            
            transactionObj.Gateway_Date__c = system.now(); 
            transactionObj.Response_Code__c = responseArray.get(0);
            transactionObj.Reason_Code__c = decimal.ValueOf(responseArray.get(2));
            transactionObj.Response_Message__c = responseArray.get(3);
            transactionObj.Response__c = responseArray.get(3);
            transactionObj.AVS_Response_Code__c =  responseArray.get(5);    
            transactionObj.Authorization__c = responseArray.get(4); // Authorization code  
            if(transactionObj.Gateway_ID__c == null) {  
                transactionObj.Gateway_ID__c = responseArray.get(6); // transaction Id  
            }

            if(transactionObj.Id == null) {
                result.message =  system.Label.transactioncreated;
            } else {
                result.message =  system.Label.transactionupdated;
            }
             if(isGenericMethodCall){
            if(transactionObj.Id == null) {
                transactionObj.Payment_Gateway__c = gateway.Id;
            }

            upsert transactionObj;

            transactionObj = [SELECT Name, Response_Status__c, Amount__c
                              FROM Transaction__c
                              WHERE Id =: transactionObj.Id];

            result.message +=  transactionObj.Name + ' \n'
            + 'Gateway Response : ' +  responseArray.get(3) + ' \n'
            + 'Gateway Status : ' + transactionObj.Response_Status__c;

            result.transactionObj = transactionObj; 
        }
        
    }
    }