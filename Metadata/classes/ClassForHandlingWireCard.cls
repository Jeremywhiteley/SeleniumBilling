/**
     * Webservice for handling payments.
     *
     * @author Laxman Rao M
     * @author Acertis Cloud Ltd
       Copyright (c) 2011, Acertis Cloud, Salesforce.com Inc.
       All rights reserved
     */
     
    /*
        Attributes :
        
        CreditCardNumber(Required)
        
        ExpirationYear(Required)
        
        ExpirationMonth(Required)
        
        Type(Required)
        
        Amount(Required)
        
        CVV(A conditional (con.) message field must be included in some instances. Its omission may cause the process request type to be rejected)
        

        Test Access
        For testing please use following connection data:
        ? URL for HTTPS : https://c3-test.wirecard.com/secure/ssl-gateway
        ? Username: 56501
        ? Password: TestXAPTER
        ? Business Case Signature: 56501
        ? Content-Type: text/xml
        ? Available currencies: BWP, CHF, DKK, EUR, GBP, INR, JPY, KWD, MYR, NOK, PHP, RUB, SEK, USD, ZAR
        ? Transaction Mode: demo
        
        Demo Test cards
        JCB 3528000000000000
        AIRPLUS 122000000000000
        DINERS 38000000000000
        VISA 4200000000000000
        VISA 4018490000000039
        MASTER 5500000000000000
        
    */ 
    public with sharing class ClassForHandlingWireCard implements InterfacePaymentClass.paymentOperationsInterface {
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
        private string sIpAddress;
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
        
        string sRawHttpResponse;
        map<string, string> mapOfKeyValue = new map<string, string>();
        
        // this variable is declared because on force.com site page if user selected the savecard information.
        boolean isSavePaymentMethod = false;
        
        //This is used for Virtualterminal Purpose
        private Id currencyId;

        private boolean isGenericMethodCall = true;
        
        public ClassForHandlingWireCard(Gateway__c gateway, Invoice__c invoice, Payment_Method__c paymentMethod) {
            this.invoice = invoice;
            this.paymentMethod = paymentMethod;
            this.gateway = gateway; 
            
            //Added by dhanalakshmi for INVOICEIT-18
            if(invoice == null)
            {
                this.invoice = new Invoice__c();
            } 
            parameters = new map<string, string>();
            
            //this determines is it sandboz or live
            if(gateway.Test_Mode__c) {
                sHttpEndPoint = CommonUtilClass.ENDPOINT_WIRECARD_TEST;
            } else {
                sHttpEndPoint = CommonUtilClass.ENDPOINT_WIRECARD_LIVE;
            }      
            
            list<LoginHistory> listOfLoginHistory = [SELECT SourceIp
                                                     FROM LoginHistory
                                                     ORDER BY LoginTime DESC
                                                     LIMIT 1];
                                                     
            sIpAddress = listOfLoginHistory.get(0).SourceIp;        
            /*
                Modified By          : Anil Pinto14 June 2013INVOICEIT-125
                Comments           : Added below line which gives details of customer for billing information.
            */
            populateCustomerDetails();
        }
        
            /*
            Modified By          : Rama Krishna      :19 june 2013I    :NVOICEIT-194
            Comments          : added two parameters to constructor(i.e, Account and dAmount). 
            */
        public ClassForHandlingWireCard(Gateway__c gateway, Invoice__c invoice, Payment_Method__c paymentMethod,string sDummyPaymentId,decimal dAmount,Account account) {
            this.invoice = invoice;
            this.account = account;
            this.dAmount = dAmount;
            this.paymentMethod = paymentMethod;
            this.gateway = gateway; 
            this.sDummyPaymentId = sDummyPaymentId;
            parameters = new map<string, string>();
            
            //this determines is it sandboz or live
            if(gateway.Test_Mode__c) {
                sHttpEndPoint = CommonUtilClass.ENDPOINT_WIRECARD_TEST;
            } else {
                sHttpEndPoint = CommonUtilClass.ENDPOINT_WIRECARD_LIVE;
            }      
            
            list<LoginHistory> listOfLoginHistory = [SELECT SourceIp
                                                     FROM LoginHistory
                                                     ORDER BY LoginTime DESC
                                                     LIMIT 1];
                                                     
            sIpAddress = listOfLoginHistory.get(0).SourceIp;
            /*
                Modified By          : Anil Pinto    :14 June 2013     :INVOICEIT-125
                Comments           : Added below line which gives details of customer for billing information.
            */
            populateCustomerDetails();                                     
        } 
        
        //This is used for Virtualterminal Purpose
        public ClassForHandlingWireCard(Gateway__c gateway, Invoice__c invoice, Payment_Method__c paymentMethod,string sDummyPaymentId,decimal dAmount,Account account, Id currencyId) {
            this.invoice = invoice;
            this.account = account;
            this.dAmount = dAmount;
            this.paymentMethod = paymentMethod;
            this.gateway = gateway; 
            this.sDummyPaymentId = sDummyPaymentId;
            this.currencyId = currencyId;
            parameters = new map<string, string>();
            
            //this determines is it sandboz or live
            if(gateway.Test_Mode__c) {
                sHttpEndPoint = CommonUtilClass.ENDPOINT_WIRECARD_TEST;
            } else {
                sHttpEndPoint = CommonUtilClass.ENDPOINT_WIRECARD_LIVE;
            }      
            
            list<LoginHistory> listOfLoginHistory = [SELECT SourceIp
                                                     FROM LoginHistory
                                                     ORDER BY LoginTime DESC
                                                     LIMIT 1];
                                                     
            sIpAddress = listOfLoginHistory.get(0).SourceIp;
            populateCustomerDetails();                                     
        } 
        
        public PaymentOperations.PaymentResult handleAuthorize_Click() {
            try {
                //This is the integer amount defined in the smallest currecy unit, for which the transaction is requested
                //(example : $10.00 = 1000)
                //minorunits specify the number of decimal places of the amount
                decimal amountToBeProcessed = 0;
                
                if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                    amountToBeProcessed = invoice.Payment_Request_Amount__c;            
                } else {
                    amountToBeProcessed = invoice.Unpaid_Amount__c;         
                }
                
                string amount = amountToBeProcessed.toPlainString().replace('.', '');
                string sCountryCode;
                map<string, Country_Codes__c> map_CountryName_Code = Country_Codes__c.getAll();
                if(map_CountryName_Code.containsKey(paymentMethod.Billing_Country__c)) {
                    sCountryCode = map_CountryName_Code.get(paymentMethod.Billing_Country__c).Country_Code__c.trim();
                } else {
                    result.message = system.Label.CountryCodeDoesNotExistForDefaultPaymentMethod;
                    return result;
                }
                
                /*
                    Modified By         : Anil Pinto    :14 June 2013    :INVOICEIT-125
                    Comments         : XML modified .The start of <CORPTRUSTCENTER_DATA> tag till end of </CORPTRUSTCENTER_DATA>,
                                                     this gives details of customer for billing.
                */
                string authorizationXmlRequest = '<?xml version="1.0" encoding="UTF-8"?>' + 
                        '<WIRECARD_BXML>' + 
                        '<W_REQUEST>' + 
                        '<W_JOB>' + 
                            '<JobID>' + invoice.Name  + '</JobID>' + 
                            '<BusinessCaseSignature>' + gateway.Merchant_ID__c + '</BusinessCaseSignature>' + 
                            '<FNC_CC_PREAUTHORIZATION>' + 
                                '<FunctionID>' + invoice.Name  + '</FunctionID>' + 
                                '<CC_TRANSACTION mode="demo">' + 
                                    '<TransactionID>Authorization Initial 1</TransactionID>' + 
                                    '<Amount minorunits="2">' + amount + '</Amount>' + 
                                    '<Currency>' + invoice.CurrencyL__r.Name + '</Currency>' + 
                                    '<CountryCode>' + sCountryCode + '</CountryCode>' + 
                                    '<Usage>' + 'OrderNo ' + invoice.Name + '</Usage>' +
                                    '<RECURRING_TRANSACTION>' + 
                                        '<Type>Initial</Type>' + 
                                    '</RECURRING_TRANSACTION>' + 
                                    '<CREDIT_CARD_DATA>' + 
                                        '<CreditCardNumber>' + paymentMethod.Card_Number__c + '</CreditCardNumber>' + 
                                        '<CVC2>' + paymentMethod.CVV__c + '</CVC2>' + 
                                        '<ExpirationYear>' + paymentMethod.Card_Expiration_Year__c + '</ExpirationYear>' + 
                                        '<ExpirationMonth>' + paymentMethod.Card_Expiration_Month__c + '</ExpirationMonth>' + 
                                        '<CardHolderName>' + paymentMethod.Name_on_Card__c + '</CardHolderName>' + 
                                    '</CREDIT_CARD_DATA>' + 
                                    '<CORPTRUSTCENTER_DATA>' +
                                        '<ADDRESS>' +
                                            '<FirstName>' + sFirstName + '</FirstName>' +
                                            '<LastName>' + sLastName + '</LastName>' +
                                            '<Address1>' + sAddress1 + '</Address1>' +
                                            '<Address2></Address2>' +
                                            '<City>' + sCity + '</City>' +
                                            '<ZipCode>' + sZipCode + '</ZipCode>' +
                                            '<State>' + sState + '</State>' +
                                            '<Country>' + sCountry + '</Country>' +
                                            '<Phone>' + sPhone + '</Phone>' +
                                            '<Email>' + sEmail + '</Email>' +
                                        '</ADDRESS>' +
                                    '</CORPTRUSTCENTER_DATA>' +
                                    '<CONTACT_DATA>' + 
                                        '<IPAddress>' + sIpAddress + '</IPAddress>' + 
                                    '</CONTACT_DATA>' + 
                                '</CC_TRANSACTION>' + 
                            '</FNC_CC_PREAUTHORIZATION>' + 
                        '</W_JOB>' + 
                        '</W_REQUEST>' + 
                        '</WIRECARD_BXML>';
                 
                //for live transactions, demo should be removed
                if(!gateway.Test_Mode__c) {
                    authorizationXmlRequest = authorizationXmlRequest.replace(' mode="demo"', '');
                }
                
                transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_AUTHORIZATION, Amount__c = amountToBeProcessed, Currency__c = invoice.CurrencyL__c, Is_Payment_Processed_Successfully__c = true, Payment_Gateway__c = gateway.Id);
                transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
                transactionObj.Request_Invoice__c = invoice.Id;
                transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
                transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_AUTHORIZATION;
                
                /*   Modified by Ram  on May 7-2013 */  
                transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
                transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
                transactionObj.Card_Type__c = paymentMethod.Card_Type__c;   
                
                sendHttpRequest(authorizationXmlRequest);
            } catch(Exception ex) {
                result.message = ex.getMessage();
            }
            return result;  
        }
        
        public PaymentOperations.PaymentResult handleAuthorizeAndCharge_Click(string transactionId, string gatewayID) {
            try {
                //This is the integer amount defined in the smallest currecy unit, for which the transaction is requested
                //(example : $10.00 = 1000)
                //minorunits specify the number of decimal places of the amount
                string sCountryCode;
                map<string, Country_Codes__c> map_CountryName_Code = Country_Codes__c.getAll();
                if(map_CountryName_Code.containsKey(paymentMethod.Billing_Country__c)) {
                    sCountryCode = map_CountryName_Code.get(paymentMethod.Billing_Country__c).Country_Code__c.trim();
                } else {
                    result.message = system.Label.CountryCodeDoesNotExistForDefaultPaymentMethod;
                    return result;
                }
                
                decimal amountToBeProcessed = 0;
                if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                    amountToBeProcessed = invoice.Payment_Request_Amount__c;
                } else {
                    amountToBeProcessed = invoice.Unpaid_Amount__c;
                }
                
                string amount = amountToBeProcessed.toPlainString().replace('.', '');
                string chargeXmlRequest;
                
                if(transactionId == null) {
                    transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                                                        Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, 
                                                        Amount__c = amountToBeProcessed, 
                                                        Currency__c = invoice.CurrencyL__c, 
                                                        Payment_Gateway__c = gateway.Id
                                                        );
                                                        
                     // XML modified .The start of <CORPTRUSTCENTER_DATA> tag till end of </CORPTRUSTCENTER_DATA>, included for the Jira Task - 125
                    /*
                        Modified By             : Anil Pinto    :14 June 2013     :INVOICEIT-125
                        Comments              : XML modified .The start of <CORPTRUSTCENTER_DATA> tag till end of </CORPTRUSTCENTER_DATA>,
                                                             this gives details of customer for billing.
                    */
                    chargeXmlRequest = '<?xml version="1.0" encoding="UTF-8"?>' + 
                        '<WIRECARD_BXML>' + 
                        '<W_REQUEST>' + 
                        '<W_JOB>' + 
                            '<JobID>' + invoice.Name  + '</JobID>' + 
                            '<BusinessCaseSignature>' + gateway.Merchant_ID__c + '</BusinessCaseSignature>' +
                            '<FNC_CC_PURCHASE>' + 
                                '<FunctionID>' + invoice.Name  + '</FunctionID>' + 
                                '<CC_TRANSACTION mode="demo">' + 
                                    '<TransactionID>Sale</TransactionID>' + 
                                    '<Amount minorunits="2">' + amount + '</Amount>' +
                                    '<Currency>' + invoice.CurrencyL__r.Name + '</Currency>' + 
                                    '<CountryCode>' + sCountryCode + '</CountryCode>' +  
                                    '<Usage>' + 'OrderNo ' + invoice.Name + '</Usage>' +  
                                    '<RECURRING_TRANSACTION>' + 
                                        '<Type>Initial</Type>' + 
                                    '</RECURRING_TRANSACTION>' + 
                                    '<CREDIT_CARD_DATA>' + 
                                        '<CreditCardNumber>' + paymentMethod.Card_Number__c + '</CreditCardNumber>' + 
                                        '<CVC2>' + paymentMethod.CVV__c + '</CVC2>' + 
                                        '<ExpirationYear>' + paymentMethod.Card_Expiration_Year__c + '</ExpirationYear>' + 
                                        '<ExpirationMonth>' + paymentMethod.Card_Expiration_Month__c + '</ExpirationMonth>' + 
                                        '<CardHolderName>' + paymentMethod.Name_on_Card__c + '</CardHolderName>' + 
                                    '</CREDIT_CARD_DATA>' + 
                                    '<CORPTRUSTCENTER_DATA>' +
                                        '<ADDRESS>' +
                                            '<FirstName>' + sFirstName + '</FirstName>' +
                                            '<LastName>' + sLastName + '</LastName>' +
                                            '<Address1>' + sAddress1 + '</Address1>' +
                                            '<Address2></Address2>' +
                                            '<City>' + sCity + '</City>' +
                                            '<ZipCode>' + sZipCode + '</ZipCode>' +
                                            '<State>' + sState + '</State>' +
                                            '<Country>' + sCountry + '</Country>' +
                                            '<Phone>' + sPhone + '</Phone>' +
                                            '<Email>' + sEmail + '</Email>' +
                                        '</ADDRESS>' +
                                    '</CORPTRUSTCENTER_DATA>' +
                                    '<CONTACT_DATA>' + 
                                        '<IPAddress>' + sIpAddress + '</IPAddress>' +  
                                    '</CONTACT_DATA>' + 
                                '</CC_TRANSACTION>' + 
                            '</FNC_CC_PURCHASE>' + 
                        '</W_JOB>' + 
                        '</W_REQUEST>' + 
                        '</WIRECARD_BXML>';                                             
            
                } else {
                  transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                                                      Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, 
                                                      Transaction__c = transactionId, 
                                                      Amount__c = amountToBeProcessed, 
                                                      Currency__c = invoice.CurrencyL__c, 
                                                      Payment_Gateway__c = gateway.Id
                                                      );
                  
                   // XML modified .The start of <CORPTRUSTCENTER_DATA> tag till end of </CORPTRUSTCENTER_DATA>, included for the Jira Task - 125
                    /*
                        Modified By         : Anil Pinto      :14 June 2013    :INVOICEIT-125
                        Comments          : XML modified .The start of <CORPTRUSTCENTER_DATA> tag till end of </CORPTRUSTCENTER_DATA>,
                                                         this gives details of customer for billing.
                    */
                  chargeXmlRequest = '<?xml version="1.0" encoding="UTF-8"?>' + 
                            '<WIRECARD_BXML>' + 
                            '<W_REQUEST>' + 
                            '<W_JOB>' + 
                                '<JobID>' + invoice.Name  + '</JobID>' + 
                                '<BusinessCaseSignature>' + gateway.Merchant_ID__c + '</BusinessCaseSignature>' + 
                                '<FNC_CC_CAPTURE>' + 
                                    '<FunctionID>' + invoice.Name  + '</FunctionID>' + 
                                    '<CC_TRANSACTION mode="demo">' + 
                                        '<TransactionID>Authorization Initial 1</TransactionID>' + 
                                        '<GuWID>' + gatewayID + '</GuWID>' +
                                        '<Usage>' + 'OrderNo ' + invoice.Name + '</Usage>' + 
                                        '<CORPTRUSTCENTER_DATA>' +
                                            '<ADDRESS>' +
                                                '<FirstName>' + sFirstName + '</FirstName>' +
                                                '<LastName>' + sLastName + '</LastName>' +
                                                '<Address1>' + sAddress1 + '</Address1>' +
                                                '<Address2></Address2>' +
                                                '<City>' + sCity + '</City>' +
                                                '<ZipCode>' + sZipCode + '</ZipCode>' +
                                                '<State>' + sState + '</State>' +
                                                '<Country>' + sCountry + '</Country>' +
                                                '<Phone>' + sPhone + '</Phone>' +
                                                '<Email>' + sEmail + '</Email>' +
                                            '</ADDRESS>' +
                                        '</CORPTRUSTCENTER_DATA>' +
                                    '</CC_TRANSACTION>' + 
                                '</FNC_CC_CAPTURE>' + 
                            '</W_JOB>' + 
                            '</W_REQUEST>' + 
                            '</WIRECARD_BXML>';                                   
                }
                
                //for live transactions, demo should be removed
                if(!gateway.Test_Mode__c) {
                    chargeXmlRequest = chargeXmlRequest.replace(' mode="demo"', '');
                }
                
                transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
                transactionObj.Request_Invoice__c = invoice.Id;
                transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
                transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE;
                
                /*   Modified by Ram  on May 7-2013 */
                transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
                transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
                transactionObj.Card_Type__c = paymentMethod.Card_Type__c;
            
                sendHttpRequest(chargeXmlRequest);      
                
                if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                  //create the payment and payment allocation against the inv
                  InvoicingUtilClass.createPaymentAndPaymentAllocation(invoice, transactionObj); 
                  transactionObj.Is_Payment_Processed_Successfully__c = true;
                  update transactionObj;                                                                 
                }
            } catch(Exception ex) {
               result.message += '\n \n '+ system.Label.ExceptionOccurred + ex.getMessage();
               if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                   result.message += '\n \n'+ system.Label.InvoiceIsCharged;
                   transactionObj.Is_Payment_Processed_Successfully__c = false;
                   transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                   upsert transactionObj;   
               }
            }
            
            return result;          
        }

     /* =================== Start ====================================== */

        /*
        Modified By         : Madhu Keshav    :1 Dec 2015    :INVOICEIT-641
        Comments         : Creating a generic method for processing all payments. This will be used in global methods and API
        */
        
       public PaymentSiteOperation.GenericPaymentResult handleAuthorizeAndCharge(PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters)
        {
            isGenericMethodCall = false;
            PaymentSiteOperation.GenericPaymentResult result;
            PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new  PaymentSiteOperation.GenericPaymentResult();
            try {
                string sCountryCode;
                map<string, Country_Codes__c> map_CountryName_Code = Country_Codes__c.getAll();
                if(map_CountryName_Code.containsKey(paymentMethod.Billing_Country__c)) {
                    sCountryCode = map_CountryName_Code.get(paymentMethod.Billing_Country__c).Country_Code__c.trim();
                } else {
                    result.message = system.Label.CountryCodeDoesNotExistForDefaultPaymentMethod;
                    return result;
                }
                decimal amountToBeProcessed = genericPaymentParameters.amountToProcess;

                string amount = amountToBeProcessed.toPlainString().replace('.', '');
                string chargeXmlRequest;


                transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                                                        Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, 
                                                        Amount__c = amountToBeProcessed, 
                                                        Currency__c = invoice.CurrencyL__c, 
                                                        Payment_Gateway__c = gateway.Id
                                                        );                         
        

                      chargeXmlRequest = '<?xml version="1.0" encoding="UTF-8"?>' + 
                        '<WIRECARD_BXML>' + 
                        '<W_REQUEST>' + 
                        '<W_JOB>' + 
                            '<JobID>' + invoice.Name  + '</JobID>' + 
                            '<BusinessCaseSignature>' + gateway.Merchant_ID__c + '</BusinessCaseSignature>' +
                            '<FNC_CC_PURCHASE>' + 
                                '<FunctionID>' + invoice.Name  + '</FunctionID>' + 
                                '<CC_TRANSACTION mode="demo">' + 
                                    '<TransactionID>Sale</TransactionID>' + 
                                    '<Amount minorunits="2">' + amount + '</Amount>' +
                                    '<Currency>'+ genericPaymentParameters.currencyISOCode + '</Currency>' + 
                                    '<CountryCode>' + sCountryCode + '</CountryCode>' +  
                                    '<Usage>' + 'OrderNo ' + invoice.Name + '</Usage>' +  
                                    '<RECURRING_TRANSACTION>' + 
                                        '<Type>Initial</Type>' + 
                                    '</RECURRING_TRANSACTION>' + 
                                    '<CREDIT_CARD_DATA>' + 
                                        '<CreditCardNumber>' + paymentMethod.Card_Number__c + '</CreditCardNumber>' + 
                                        '<CVC2>' + paymentMethod.CVV__c + '</CVC2>' + 
                                        '<ExpirationYear>' + paymentMethod.Card_Expiration_Year__c + '</ExpirationYear>' + 
                                        '<ExpirationMonth>' + paymentMethod.Card_Expiration_Month__c + '</ExpirationMonth>' + 
                                        '<CardHolderName>' + paymentMethod.Name_on_Card__c + '</CardHolderName>' + 
                                    '</CREDIT_CARD_DATA>' + 
                                    '<CORPTRUSTCENTER_DATA>' +
                                        '<ADDRESS>' +
                                            '<FirstName>' + sFirstName + '</FirstName>' +
                                            '<LastName>' + sLastName + '</LastName>' +
                                            '<Address1>' + sAddress1 + '</Address1>' +
                                            '<Address2></Address2>' +
                                            '<City>' + sCity + '</City>' +
                                            '<ZipCode>' + sZipCode + '</ZipCode>' +
                                            '<State>' + sState + '</State>' +
                                            '<Country>' + sCountry + '</Country>' +
                                            '<Phone>' + sPhone + '</Phone>' +
                                            '<Email>' + sEmail + '</Email>' +
                                        '</ADDRESS>' +
                                    '</CORPTRUSTCENTER_DATA>' +
                                    '<CONTACT_DATA>' + 
                                        '<IPAddress>' + sIpAddress + '</IPAddress>' +  
                                    '</CONTACT_DATA>' + 
                                '</CC_TRANSACTION>' + 
                            '</FNC_CC_PURCHASE>' + 
                        '</W_JOB>' + 
                        '</W_REQUEST>' + 
                        '</WIRECARD_BXML>';     

             
                sendHttpRequest(chargeXmlRequest);   

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
        Modified By          : Rama Krishna  :19 june 2013   :INVOICEIT-194
        Comments           : previously force.site only supporting for the Invoice Payment,
                                        now this method is accepting Payments for both Invoice and Account.    
        */
        public PaymentOperations.PaymentResult handleAuthorizeAndCharge_Site(boolean isSaveCardDetails) {  
            try {
                isSavePaymentMethod = isSaveCardDetails;
                decimal amountToBeProcessed = 0;
                if(invoice != null && currencyId == null){
                    if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                    amountToBeProcessed = invoice.Payment_Request_Amount__c;
                    } else {
                    amountToBeProcessed = invoice.Unpaid_Amount__c;
                 }
                } else {
                    /*
                    Modified By          : Rama Krishna     :19 june 2013  :INVOICEIT-194
                    Comments          : assigning advance request amount Of Account,
                    */
                    amountToBeProcessed = dAmount;
                }
                
                
                string amount = amountToBeProcessed.toPlainString().replace('.', '');
                string chargeXmlRequest;
                
                /*
                Modified By          : Rama Krishna  :19 june 2013   :INVOICEIT-194
                Comments          : querying the currency equals to USD, to assign currency for account Payments   
                */
               Currency__c currency1;
               // if the currency id is not null, means process for the virtual terminal
               if(currencyId != null) {
                   currency1 = [SELECT Name FROM Currency__c WHERE id =: currencyId];
               } else{
                 currency1 = [SELECT Name FROM Currency__c WHERE Name = 'USD' limit 1];
               }
               
               transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                                                        Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, 
                                                        Amount__c = amountToBeProcessed, 
                                                        Payment_Gateway__c = gateway.Id
                                                        );
                  
                    /*
                    Modified By         : Rama Krishna   :19 june 2013:  INVOICEIT-194
                    Comments         : if invoice id is null and assign accounts Name,account.Id  to the gateway Parameters. 
                    */
                  string sName = invoice != null ? invoice.Name : account.Name;
                  String sCurrrency = invoice != null ? invoice.CurrencyL__r.Name : currency1.Name;
                  
                    /*
                        Modified By         : Anil Pinto   :14 June 2013   :INVOICEIT-125
                        Comments         : XML modified .The start of <CORPTRUSTCENTER_DATA> tag till end of </CORPTRUSTCENTER_DATA>,
                                                        this gives details of customer for billing.
                    */
                    
                  chargeXmlRequest = '<?xml version="1.0" encoding="UTF-8"?>' + 
                        '<WIRECARD_BXML>' + 
                        '<W_REQUEST>' + 
                        '<W_JOB>' + 
                            '<JobID>' + sName  + '</JobID>' + 
                            '<BusinessCaseSignature>' + gateway.Merchant_ID__c + '</BusinessCaseSignature>' +
                            '<FNC_CC_PURCHASE>' + 
                                '<FunctionID>' + sName  + '</FunctionID>' + 
                                '<CC_TRANSACTION mode="demo">' + 
                                    '<TransactionID>Sale</TransactionID>' + 
                                    '<Amount minorunits="2">' + amount + '</Amount>' +
                                    '<Currency>' + sCurrrency + '</Currency>' + 
                                    //'<CountryCode>' + sCountryCode + '</CountryCode>' +  
                                    '<Usage>' + 'OrderNo ' + sName + '</Usage>' +  
                                    '<RECURRING_TRANSACTION>' + 
                                        '<Type>Initial</Type>' + 
                                    '</RECURRING_TRANSACTION>' + 
                                    '<CREDIT_CARD_DATA>' + 
                                        '<CreditCardNumber>' + paymentMethod.Card_Number__c + '</CreditCardNumber>' + 
                                        '<CVC2>' + paymentMethod.CVV__c + '</CVC2>' + 
                                        '<ExpirationYear>' + paymentMethod.Card_Expiration_Year__c + '</ExpirationYear>' + 
                                        '<ExpirationMonth>' + paymentMethod.Card_Expiration_Month__c + '</ExpirationMonth>' + 
                                        '<CardHolderName>' + paymentMethod.Name_on_Card__c + '</CardHolderName>' + 
                                    '</CREDIT_CARD_DATA>' + 
                                    '<CORPTRUSTCENTER_DATA>' +
                                        '<ADDRESS>' +
                                            '<FirstName>' + sFirstName + '</FirstName>' +
                                            '<LastName>' + sLastName + '</LastName>' +
                                            '<Address1>' + sAddress1 + '</Address1>' +
                                            '<Address2></Address2>' +
                                            '<City>' + sCity + '</City>' +
                                            '<ZipCode>' + sZipCode + '</ZipCode>' +
                                            '<State>' + sState + '</State>' +
                                            '<Country>' + sCountry + '</Country>' +
                                            '<Phone>' + sPhone + '</Phone>' +
                                            '<Email>' + sEmail + '</Email>' +
                                        '</ADDRESS>' +
                                    '</CORPTRUSTCENTER_DATA>' +
                                    '<CONTACT_DATA>' + 
                                        '<IPAddress>' + sIpAddress + '</IPAddress>' +  
                                    '</CONTACT_DATA>' + 
                                '</CC_TRANSACTION>' + 
                            '</FNC_CC_PURCHASE>' + 
                        '</W_JOB>' + 
                        '</W_REQUEST>' + 
                        '</WIRECARD_BXML>';                                           
                
                //for live transactions, demo should be removed
                if(!gateway.Test_Mode__c) {
                    chargeXmlRequest = chargeXmlRequest.replace(' mode="demo"', '');
                }
                
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
            
                if(isSaveCardDetails) {
                    sendHttpRequest(chargeXmlRequest);
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
                    insert paymentMethod;
                    //populate Default Method on account
                    CommonUtilClass.populateDefaultMethod(paymentMethod);
                    
                    transactionObj.Payment_Method__c = paymentMethod.Id;
          
                    
                    result.message =  system.label.transactioncreated;
                    upsert transactionObj;

                    transactionObj = [SELECT Name, Response_Status__c, Amount__c, Response_Code__c, Transaction__c, Response_Message__c
                                      FROM Transaction__c
                                      WHERE Id =: transactionObj.Id];

                    result.message  +=  transactionObj.Name + ' \n'
                    + 'Gateway Response : ' + transactionObj.Response_Code__c + ' \n'
                    + 'Gateway Status : ' + transactionObj.Response_Status__c;
                    
                } else {
                    transactionObj.Payment_Method__c = sDummyPaymentId;
     
                    sendHttpRequest(chargeXmlRequest);
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
                        /*
                        Modified By         : Rama Krishna    19 june 2013    INVOICEIT-194
                        Comments         : creating advance payment for account with out invoice.     
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
                            Modified By         : Rama Krishna    24-9-2013    INVOICEIT-239
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
               result.message += '\n \n'+ system.Label.ExceptionOccurred + ex.getMessage();
               if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                   result.message += '\n \n '+ system.Label.InvoiceIsCharged;
                   transactionObj.Is_Payment_Processed_Successfully__c = false;
                   transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                   upsert transactionObj;   
               }
            }
            return result;          
        } 
        
        public PaymentOperations.PaymentResult handleVoid_Click(string gatewayId, string transactionId, decimal transactionAmount) {
            //This is the integer amount defined in the smallest currecy unit, for which the transaction is requested
            //(example : $10.00 = 1000)
            //minorunits specify the number of decimal places of the amount
            try {
                string amount = transactionAmount.toPlainString().replace('.', '');
                string voidXmlRequest = '<?xml version="1.0" encoding="UTF-8"?>' + 
                        '<WIRECARD_BXML>' + 
                        '<W_REQUEST>' + 
                        '<W_JOB>' + 
                            '<JobID>' + invoice.Name  + '</JobID>' +  
                            '<BusinessCaseSignature>' + gateway.Merchant_ID__c + '</BusinessCaseSignature>' +  
                            '<FNC_CC_REVERSAL>' + 
                                '<FunctionID>' + invoice.Name  + '</FunctionID>' + 
                                '<CC_TRANSACTION mode="demo">' + 
                                    '<TransactionID>9457892347623478</TransactionID>' + 
                                    '<GuWID>' + gatewayId + '</GuWID>' +                            
                                '</CC_TRANSACTION>' + 
                            '</FNC_CC_REVERSAL>' + 
                        '</W_JOB>' + 
                        '</W_REQUEST>' + 
                        '</WIRECARD_BXML>'; 
                
                //for live transactions, demo should be removed
                if(!gateway.Test_Mode__c) {
                    voidXmlRequest = voidXmlRequest.replace(' mode="demo"', '');
                }
               
                transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                                                    Type__c = CommonUtilClass.TRANSACTION_TYPE_VOID, 
                                                    Transaction__c = transactionId, 
                                                    Gateway_ID__c = gatewayId, 
                                                    Is_Payment_Processed_Successfully__c = true, 
                                                    Amount__c = transactionAmount, 
                                                    Payment_Gateway__c = gateway.Id
                                                    );
                                                    
                transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
                transactionObj.Request_Invoice__c = invoice.Id;
                transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
                transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_VOID;     
                
                /*   Modified by Ram  on May 7-2013*/
                transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
                transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
                transactionObj.Card_Type__c = paymentMethod.Card_Type__c;
            
                sendHttpRequest(voidXmlRequest);
                
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
            //This is the integer amount defined in the smallest currecy unit, for which the transaction is requested
            //(example : $10.00 = 1000)
            //minorunits specify the number of decimal places of the amount
            try {
                string amount = transactionAmount.toPlainString().replace('.', '');
                string refundXmlRequest = '<?xml version="1.0" encoding="UTF-8"?>' + 
                        '<WIRECARD_BXML>' + 
                        '<W_REQUEST>' + 
                        '<W_JOB>' + 
                            '<JobID>' + invoice.Name  + '</JobID>' +  
                            '<BusinessCaseSignature>' + gateway.Merchant_ID__c + '</BusinessCaseSignature>' +  
                            '<FNC_CC_BOOKBACK>' + 
                                '<FunctionID>' + invoice.Name  + '</FunctionID>' + 
                                '<CC_TRANSACTION mode="demo">' + 
                                    '<TransactionID>9457892347623478</TransactionID>' + 
                                    '<GuWID>' + gatewayId + '</GuWID>' +                            
                                    '<Amount minorunits="2">' + amount + '</Amount>' +  
                                    '<Usage>' + 'Refund : OrderNo ' + invoice.Name + '</Usage>' +  
                                '</CC_TRANSACTION>' + 
                            '</FNC_CC_BOOKBACK>' + 
                        '</W_JOB>' + 
                        '</W_REQUEST>' + 
                        '</WIRECARD_BXML>'; 
                
                //for live transactions, demo should be removed
                if(!gateway.Test_Mode__c) {
                    refundXmlRequest = refundXmlRequest.replace(' mode="demo"', '');
                }
                transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                                                    Type__c = CommonUtilClass.TRANSACTION_TYPE_REFUND, 
                                                    Transaction__c = transactionId, 
                                                    Gateway_ID__c = gatewayId, 
                                                    Amount__c = transactionAmount, 
                                                    Is_Payment_Processed_Successfully__c = true, 
                                                    Payment_Gateway__c = gateway.Id
                                                    );
                                                    
                transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
                transactionObj.Request_Invoice__c = invoice.Id;
                transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
                transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_REFUND;
                
                /*   Modified by Ram  on May 7-2013*/
                transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
                transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
                transactionObj.Card_Type__c = paymentMethod.Card_Type__c;
            
                sendHttpRequest(refundXmlRequest);
                
                if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                    //cancel the payment 
                    InvoicingUtilClass.cancelPayment(transactionObj.Transaction__c);
                }   
            } catch(Exception ex) {
               result.message += '\n \n'+ system.Label.ExceptionOccurred + ex.getMessage();
            }   
            
            return result;
        }
        
        public void sendHttpRequest(string xmlBody) {
            Http httpObject = new Http();
            HttpRequest httpRequest = new HttpRequest();
            HttpResponse httpResponse;
            
            String username = gateway.Merchant_ID__c;
            String password = gateway.Security_Key__c;

            Blob headerValue = blob.valueOf(username + ':' + password);
            string authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            
            httpRequest.setHeader('Authorization', authorizationHeader);
            httpRequest.setHeader('Content-type', 'text/xml');
            
            httpRequest.setEndpoint(sHttpEndPoint);
            httpRequest.setMethod('POST');
            /*
                Modified By          : Rama Krishna    19 august 2014    SUP-312
                Comments           : exending the callout time to max
              */
            httpRequest.setTimeout(120000);
            httpRequest.setBody(xmlBody);
            
            if(!system.test.isRunningTest()) {
                httpResponse = httpObject.send(httpRequest);
                if(httpResponse.getStatusCode() == 401) {
                    result.message = system.Label.AuthorizationRequired;
                    result.reloadPage = false;
                } else if(httpResponse.getStatusCode() == 200) {
                    //parse the xml and create key-value pair
                    sRawHttpResponse = httpResponse.getBody();
                    Dom.Document doc = httpResponse.getBodyDocument();
                    Dom.XMLNode rootElement = doc.getRootElement();
                    getElements(rootElement);
                    handleRequest();
                } else {
                    result.message = httpResponse.getStatus();
                    result.reloadPage = false;
                }
                
            } else {
                string sSuccess = '<WIRECARD_BXML xmlns:xsi="http://www.w3.org/1999/XMLSchema-instance" xsi:noNamespaceSchemaLocation="wirecard.xsd"><W_RESPONSE><W_JOB><JobID>job 1</JobID><FNC_CC_PURCHASE><FunctionID>transaction 1</FunctionID><CC_TRANSACTION mode="demo"><TransactionID>9457892347623478</TransactionID><PROCESSING_STATUS><GuWID>C882607134433123066543</GuWID><AuthorizationCode>727989</AuthorizationCode><Info>THIS IS A DEMO TRANSACTION USING CREDIT CARD NUMBER 420000****0000. NO REAL MONEY WILL BE TRANSFERED.</Info><StatusType>INFO</StatusType><FunctionResult>PENDING</FunctionResult><TimeStamp>2012-08-07 11:20:30</TimeStamp></PROCESSING_STATUS></CC_TRANSACTION></FNC_CC_PURCHASE></W_JOB></W_RESPONSE></WIRECARD_BXML>';
                Dom.Document doc = new Dom.Document();
                doc.load(sSuccess);     
                Dom.XMLNode rootElement = doc.getRootElement();
                getElements(rootElement);
                handleRequest();
            }
        }
        
        private void handleRequest() {
             transactionObj.Gateway_Date__c = system.now();
             string sResponseFromGateway;
             //if it is 0,then transaction is approved
             if(mapOfKeyValue.containsKey('FunctionResult')) 
             {
                sResponseFromGateway = mapOfKeyValue.get('FunctionResult');
                
                //ACK Means successful transaction
                //PENDING Means successful transaction waiting to be captured
                //NOK Means failed transaction
                if(sResponseFromGateway == 'ACK' || sResponseFromGateway == 'PENDING') 
                {
                    result.reloadPage = true;
                    transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED;
                    transactionObj.Gateway_ID__c = mapOfKeyValue.get('GuWID');
                    transactionObj.Authorization__c = mapOfKeyValue.get('AuthorizationCode');
                    transactionObj.Response_Code__c = '0';
                    transactionObj.Response__c = 'This transaction has been approved.';
                }
                else
                {
                    result.reloadPage = false;
                    transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_ERROR + '. ' + mapOfKeyValue.get('Message');
                    transactionObj.Response_Code__c = mapOfKeyValue.get('Number');
                    transactionObj.Gateway_ID__c = mapOfKeyValue.get('GuWID');
                    //Added by DL, INVOICEIT-635
                    transactionObj.Is_Payment_Processed_Successfully__c = false;
                }
             }
             
             
             // for the site payment, if the the boolean is true dont insert transaction record
             result.message =  system.label.transactioncreated;
    if(isGenericMethodCall){
        
            if(!isSavePaymentMethod){
                 upsert transactionObj;
                
                 transactionObj = [SELECT Name, Response_Status__c, Amount__c, Response_Code__c, Transaction__c, Response_Message__c
                                   FROM Transaction__c
                                   WHERE Id =: transactionObj.Id];
                                  
                 result.message +=  transactionObj.Name + ' \n'
                                + 'Gateway Response : ' + transactionObj.Response_Code__c + ' \n'
                                + 'Gateway Status : ' + transactionObj.Response_Status__c;
            }
             result.transactionObj = transactionObj;  
         }
        }
        
        private void getElements(DOM.XMLNode node) 
        {
          if(node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            if(node.getText().trim() != '') {
                mapOfKeyValue.put(node.getName(), node.getText().trim());
            }

            for(Dom.XMLNode child : node.getChildElements()) {
                getElements(child);
            }
          }
        }
         /*
                Modified By         : Anil Pinto    :14 June 2013   :INVOICEIT-125
                Comments         : created new method which gives details of customer for billing information.
        */
        public void populateCustomerDetails() {      
            if(paymentMethod.Billing_First_Name__c != null) {
                sFirstName = paymentMethod.Billing_First_Name__c;
            }
            
            if(paymentMethod.Billing_Last_Name__c != null) {
                sLastName = paymentMethod.Billing_Last_Name__c;
            }   
            
            if(paymentMethod.Billing_Address__c != null) {
               sAddress1 = paymentMethod.Billing_Address__c;
            }
            
            if(paymentMethod.Billing_City__c != null) {
               sCity =  paymentMethod.Billing_City__c;
            }   
            
            if(paymentMethod.Billing_State_Province__c != null) {
              sState = paymentMethod.Billing_State_Province__c;
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