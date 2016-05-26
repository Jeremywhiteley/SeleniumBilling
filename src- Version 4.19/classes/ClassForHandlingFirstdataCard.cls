/**
   * Webservice for handling payments.
   * @author Devender M,Acertis Cloud Ltd
     Copyright (c) 2011, Acertis Cloud, Salesforce.com Inc.
     All rights reserved.
   */
   
  /*
   
   Host Addresses
          Use the following host addresses for the authorize.net:
          1 For live transactions, use https://api.globalgatewaye4.firstdata.com/transaction/v11
          2 For testing purposes, use https://api.demo.globalgatewaye4.firstdata.com/transaction/v11
          
  Attributes :
      
      CreditCardNumber(Required)
      
      ExpirationYear(Required)
      
      ExpirationMonth(Required)
      
      Type(Required)
      
      Amount(Required)
      
      CVV(A conditional (con.) message field must be included in some instances. Its omission may cause the process request type to be rejected)
      
      Demo Test cards
      JCB 3566002020140006
      DINERS 38000000000000
      Discover 6011000000000004
      VISA 4111111111111111
      MASTER 5500000000000004
      American Express 340000000000009 
  */ 


  public with sharing class ClassForHandlingFirstdataCard implements InterfacePaymentClass.paymentOperationsInterface{
      
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
      private String sFirstName = '';
      private String sLastName = '';
      private String sAddress1 = '';
      private String sCity = '';
      private String sZipCode = '';
      private String sState = '';
      private String sCountry = '';
      private String sPhone = '';
      private String sEmail = '';
      private string sExpiry_Date = '';
      private string sReference_No = '';
      private string sCustomer_Ref = '';
      private boolean isGenericMethodCall = true;
      string sRawHttpResponse;
      map<string, string> mapOfKeyValue = new map<string, string>();
      
      // this variable is declared because on force.com site page if user selected the savecard information.
      boolean isSavePaymentMethod = false;
      
      //This is used for Virtualterminal Purpose
      private Id currencyId;
      
      //This is used for Virtualterminal Purpose
      public ClassForHandlingFirstdataCard(Gateway__c gateway, Invoice__c invoice, Payment_Method__c paymentMethod,string sDummyPaymentId,decimal dAmount,Account account, Id currencyId) {
          this.invoice = invoice;
          this.account = account;
          this.dAmount = dAmount;
          this.paymentMethod = paymentMethod;
          this.gateway = gateway; 
          this.sDummyPaymentId = sDummyPaymentId;
          this.currencyId = currencyId;
          parameters = new map<string, string>();
          
          //Added by dhanalakshmi INVOICEIT-18
          if(invoice == null)
          {
              this.invoice = new Invoice__c();
          } 
          //this determines is it sandboz or live
          if(gateway.Test_Mode__c) {
              sHttpEndPoint = CommonUtilClass.ENDPOINT_FIRSTDATA_TEST;
          } else {
              sHttpEndPoint = CommonUtilClass.ENDPOINT_FIRSTDATA_LIVE;
          }      
          
          populateCustomerDetails();   
          sExpiry_Date = paymentMethod.Card_Expiration_Month__c + paymentMethod.Card_Expiration_Year__c.substring((paymentMethod.Card_Expiration_Year__c.Length() - 2), paymentMethod.Card_Expiration_Year__c.Length());      
              
          if(invoice != null) {
              sReference_No = invoice.Name;
              sCustomer_Ref = invoice.Account__r.Name;
          } else {
              sReference_No = account.Name;
              sCustomer_Ref = account.Name;
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
              
              string amount = amountToBeProcessed.toPlainString().replace('.', '');
                           
              string authorizationXmlRequest = '<?xml version="1.0" encoding="utf-8" ?>' + 
                                      '<Transaction>' + 
                                        '<ExactID>' +gateway.Exact_ID__c+ '</ExactID>' + 
                                        '<Password>' +gateway.Exact_ID_Security_Key__c+ '</Password>' + 
                                        '<Card_Number>' +paymentMethod.Card_Number__c+'</Card_Number>' + 
                                        '<CardHoldersName>' +sFirstName + sLastName +'</CardHoldersName>' + 
                                        '<Transaction_Type>01</Transaction_Type>' + 
                                        '<Expiry_Date>' +sExpiry_Date+'</Expiry_Date>' + 
                                        '<Currency>' +invoice.CurrencyL__r.Name+'</Currency>' + 
                                        '<DollarAmount>'+amountToBeProcessed+'</DollarAmount>' + 
                                        '<Reference_No>'+invoice.Name+'</Reference_No>' +
                                        '<Customer_Ref>'+invoice.Account__r.Name+'</Customer_Ref>' +
                                       '</Transaction>' ; 
      
              transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, Type__c = CommonUtilClass.TRANSACTION_TYPE_AUTHORIZATION, Amount__c = amountToBeProcessed, Currency__c = invoice.CurrencyL__c, Is_Payment_Processed_Successfully__c = true, Payment_Gateway__c = gateway.Id);
              transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
              transactionObj.Request_Invoice__c = invoice.Id;
              transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
              transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_AUTHORIZATION;
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
                                                      
                  chargeXmlRequest = '<?xml version="1.0" encoding="utf-8" ?>' + 
                                      '<Transaction>' + 
                                        '<ExactID>' +gateway.Exact_ID__c+ '</ExactID>' + 
                                        '<Password>' +gateway.Exact_ID_Security_Key__c+ '</Password>' + 
                                        '<Card_Number>' +paymentMethod.Card_Number__c+'</Card_Number>' + 
                                        '<CardHoldersName>' +sFirstName + sLastName +'</CardHoldersName>' + 
                                        '<Transaction_Type>00</Transaction_Type>' + 
                                        '<Expiry_Date>' +sExpiry_Date+'</Expiry_Date>' + 
                                        '<Currency>' +invoice.CurrencyL__r.Name+'</Currency>' + 
                                        '<DollarAmount>'+amountToBeProcessed+'</DollarAmount>' + 
                                        '<Reference_No>'+invoice.Name+'</Reference_No>' +
                                        '<Customer_Ref>'+invoice.Account__r.Name+'</Customer_Ref>' +
                                       '</Transaction>' ;                                            
          
              } else {
                transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                                                    Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, 
                                                    Transaction__c = transactionId, 
                                                    Amount__c = amountToBeProcessed, 
                                                    Currency__c = invoice.CurrencyL__c, 
                                                    Payment_Gateway__c = gateway.Id
                                                    );
                                                      
                  chargeXmlRequest = '<?xml version="1.0" encoding="utf-8" ?>' + 
                                      '<Transaction>' + 
                                        '<ExactID>' +gateway.Exact_ID__c+ '</ExactID>' + 
                                        '<Password>' +gateway.Exact_ID_Security_Key__c+ '</Password>' + 
                                        '<Card_Number>' +paymentMethod.Card_Number__c+'</Card_Number>' + 
                                        '<CardHoldersName>' +sFirstName + sLastName +'</CardHoldersName>' + 
                                        '<Transaction_Type>00</Transaction_Type>' + 
                                        '<Expiry_Date>' +sExpiry_Date+'</Expiry_Date>' + 
                                        '<Currency>' +invoice.CurrencyL__r.Name+'</Currency>' + 
                                        '<DollarAmount>'+amountToBeProcessed+'</DollarAmount>' +
                                        '<Reference_No>'+invoice.Name+'</Reference_No>' + 
                                        '<Customer_Ref>'+invoice.Account__r.Name+'</Customer_Ref>' +
                                       '</Transaction>' ;  
                                                   
              }
              
              //for live transactions, demo should be removed
              if(!gateway.Test_Mode__c) {
                  chargeXmlRequest = chargeXmlRequest.replace(' mode="demo"', '');
              }
              
              transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
              transactionObj.Request_Invoice__c = invoice.Id;
              transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
              transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE;
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
             result.message += '\n \n '+system.Label.ExceptionOccurred  + ex.getMessage();
             if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                 result.message += system.Label.InvoiceIsCharged;
                 transactionObj.Is_Payment_Processed_Successfully__c = false;
                 transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                 upsert transactionObj;   
             }
          }
          
          return result;          
      }

/*----------------------------Generic Method starts------------------------------*/

public PaymentSiteOperation.GenericPaymentResult handleAuthorizeAndCharge(PaymentSiteOperation.GenericPaymentParameters genericPaymentParameters) {

         PaymentSiteOperation.GenericPaymentResult genericPaymentResult = new  PaymentSiteOperation.GenericPaymentResult();
          try {
            isGenericMethodCall = false;
            string amount = genericPaymentParameters.amountToProcess.toPlainString();
            //string amount = amountToProcess.toPlainString().replace('.', '');
            string chargeXmlRequest;
              
              //decimal amountToBeProcessed = 0;
             /* if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                  amountToProcess = invoice.Payment_Request_Amount__c;
              } else {
                  amountToProcess = invoice.Unpaid_Amount__c;
              }
              */
              
             // string chargeXmlRequest;
             string transactionId;
              if(transactionId == null) {
                  transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                                                      Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, 
                                                      Amount__c = genericPaymentParameters.amountToProcess, 
                                                      Currency__c = invoice.CurrencyL__c, 
                                                      Payment_Gateway__c = gateway.Id
                                                      );
                                                      
                  chargeXmlRequest = '<?xml version="1.0" encoding="utf-8" ?>' + 
                                      '<Transaction>' + 
                                        '<ExactID>' +gateway.Exact_ID__c+ '</ExactID>' + 
                                        '<Password>' +gateway.Exact_ID_Security_Key__c+ '</Password>' + 
                                        '<Card_Number>' +paymentMethod.Card_Number__c+'</Card_Number>' + 
                                        '<CardHoldersName>' +sFirstName + sLastName +'</CardHoldersName>' + 
                                        '<Transaction_Type>00</Transaction_Type>' + 
                                        '<Expiry_Date>' +sExpiry_Date+'</Expiry_Date>' + 
                                        '<Currency>' +genericPaymentParameters.currencyISOCode+'</Currency>' + 
                                        '<DollarAmount>'+amount+'</DollarAmount>' + 
                                        '<Reference_No>'+invoice.Name+'</Reference_No>' +
                                        '<Customer_Ref>'+invoice.Account__r.Name+'</Customer_Ref>' +
                                       '</Transaction>' ;                                            
          
              } else {
                transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                                                    Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, 
                                                     Amount__c = genericPaymentParameters.amountToProcess, 
                                                    Currency__c = invoice.CurrencyL__c, 
                                                    Payment_Gateway__c = gateway.Id
                                                    );
                                                      
                  chargeXmlRequest = '<?xml version="1.0" encoding="utf-8" ?>' + 
                                      '<Transaction>' + 
                                        '<ExactID>' +gateway.Exact_ID__c+ '</ExactID>' + 
                                        '<Password>' +gateway.Exact_ID_Security_Key__c+ '</Password>' + 
                                        '<Card_Number>' +paymentMethod.Card_Number__c+'</Card_Number>' + 
                                        '<CardHoldersName>' +sFirstName + sLastName +'</CardHoldersName>' + 
                                        '<Transaction_Type>00</Transaction_Type>' + 
                                        '<Expiry_Date>' +sExpiry_Date+'</Expiry_Date>' + 
                                        '<Currency>' +genericPaymentParameters.currencyISOCode+'</Currency>' + 
                                        '<DollarAmount>'+amount+'</DollarAmount>' +
                                        '<Reference_No>'+invoice.Name+'</Reference_No>' + 
                                        '<Customer_Ref>'+invoice.Account__r.Name+'</Customer_Ref>' +
                                       '</Transaction>' ;  
                                                   
              }
              
              //for live transactions, demo should be removed
              if(!gateway.Test_Mode__c) {
                  chargeXmlRequest = chargeXmlRequest.replace(' mode="demo"', '');
              }
              
              transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
              transactionObj.Request_Invoice__c = invoice.Id;
              transactionObj.Request_Type_Of_Payment__c = CommonUtilClass.PAYMENTTYPE_CREDITCARD;
              transactionObj.Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE;
              transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
              transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
              transactionObj.Card_Type__c = paymentMethod.Card_Type__c;
          
          
              sendHttpRequest(chargeXmlRequest);     
              
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
              
               
              
            /*  if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                //create the payment and payment allocation against the inv
                InvoicingUtilClass.createPaymentAndPaymentAllocation(invoice, transactionObj); 
                transactionObj.Is_Payment_Processed_Successfully__c = true;
                update transactionObj;                                                                 
              }*/
          } catch(Exception ex) {
                genericPaymentResult.message += '\n \n ' + system.Label.ExceptionOccurred;
                genericPaymentResult.message += 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                genericPaymentResult.isSuccess = false;
                 
                return genericPaymentResult;
          
          
             /*result.message += '\n \n '+system.Label.ExceptionOccurred  + ex.getMessage();
             if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                 result.message += system.Label.InvoiceIsCharged;
                 transactionObj.Is_Payment_Processed_Successfully__c = false;
                 transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                 upsert transactionObj;   
             }*/
          }
          
          return null;          
      }





/*----------------------------Generic Method Ends--------------------------------*/




      
      public PaymentOperations.PaymentResult handleVoid_Click(string gatewayId, string transactionId, decimal transactionAmount) {
          try {
              list<Transaction__c> transactions = [   SELECT Name, Gateway_ID__c,Authorization__c
                                                      FROM Transaction__c
                                                      WHERE Id =:transactionId 
                                                      LIMIT 1
                                                      ];
      
              string amount = transactionAmount.toPlainString().replace('.', '');
              string voidXmlRequest = '<?xml version="1.0" encoding="utf-8" ?>' + 
                                      '<Transaction>' + 
                                        '<ExactID>' +gateway.Exact_ID__c+ '</ExactID>' + 
                                        '<Password>' +gateway.Exact_ID_Security_Key__c+ '</Password>' + 
                                        '<Card_Number>' +paymentMethod.Card_Number__c+'</Card_Number>' + 
                                        '<CardHoldersName>' +sFirstName + sLastName +'</CardHoldersName>' + 
                                        '<Transaction_Type>13</Transaction_Type>' + 
                                        '<Expiry_Date>' +sExpiry_Date+'</Expiry_Date>' + 
                                        '<Currency>' +invoice.CurrencyL__r.Name+'</Currency>' + 
                                        '<DollarAmount>'+transactionAmount+'</DollarAmount>' + 
                                        '<Authorization_Num>' +transactions[0].Authorization__c +'</Authorization_Num>' + 
                                        '<Reference_No>'+invoice.Name+'</Reference_No>' +
                                        '<Customer_Ref>'+invoice.Account__r.Name+'</Customer_Ref>' +
                                       '</Transaction>' ;
              
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
          try {
              list<Transaction__c> transactions = [   SELECT Name, Gateway_ID__c,Authorization__c
                                                      FROM Transaction__c
                                                      WHERE Id =:transactionId 
                                                      LIMIT 1
                                                      ];

              string amount = transactionAmount.toPlainString().replace('.', '');
              string refundXmlRequest = '<?xml version="1.0" encoding="utf-8" ?>' + 
                                      '<Transaction>' + 
                                        '<ExactID>' +gateway.Exact_ID__c+ '</ExactID>' + 
                                        '<Password>' +gateway.Exact_ID_Security_Key__c+ '</Password>' + 
                                        '<Card_Number>' +paymentMethod.Card_Number__c+'</Card_Number>' + 
                                        '<CardHoldersName>' +sFirstName + sLastName +'</CardHoldersName>' + 
                                        '<Transaction_Type>04</Transaction_Type>' + 
                                        '<Expiry_Date>' +sExpiry_Date+'</Expiry_Date>' + 
                                        '<Currency>' +invoice.CurrencyL__r.Name+'</Currency>' + 
                                        '<DollarAmount>'+transactionAmount+'</DollarAmount>' +
                                        '<Reference_No>'+invoice.Name+'</Reference_No>' + 
                                        '<Customer_Ref>'+invoice.Account__r.Name+'</Customer_Ref>' +
                                        '<Authorization_Num>' +transactions[0].Authorization__c +'</Authorization_Num>' + 
                                       '</Transaction>' ;
                                       
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
              transactionObj.Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c;
              transactionObj.Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c;
              transactionObj.Card_Type__c = paymentMethod.Card_Type__c;
          
              sendHttpRequest(refundXmlRequest);
              
              if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                  //cancel the payment 
                  InvoicingUtilClass.cancelPayment(transactionObj.Transaction__c);
              }   
          } catch(Exception ex) {
             result.message += '\n \n '+system.Label.ExceptionOccurred  + ex.getMessage();
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

              string amount = amountToBeProcessed.toPlainString().replace('.', '');
              string chargeXmlRequest;
      
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
            chargeXmlRequest = '<?xml version="1.0" encoding="utf-8" ?>' + 
                                  '<Transaction>' + 
                                    '<ExactID>' +gateway.Exact_ID__c+ '</ExactID>' + 
                                    '<Password>' +gateway.Exact_ID_Security_Key__c+ '</Password>' + 
                                    '<Card_Number>' +paymentMethod.Card_Number__c+'</Card_Number>' + 
                                    '<CardHoldersName>' +sFirstName + sLastName +'</CardHoldersName>' + 
                                    '<Transaction_Type>00</Transaction_Type>' + 
                                    '<Expiry_Date>' +sExpiry_Date+'</Expiry_Date>' + 
                                    '<Currency>' +sCurrrency+'</Currency>' + 
                                    '<DollarAmount>'+amountToBeProcessed+'</DollarAmount>' + 
                                    '<Reference_No>'+sReference_No+'</Reference_No>' + 
                                    '<Customer_Ref>'+sCustomer_Ref+'</Customer_Ref>' +
                                   '</Transaction>' ;                                           
                  
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
                  if(invoice.Id != null){
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
                  
                  result.message = system.Label.transactioncreated;
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
                if(invoice.Id != null){
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
             result.message += '\n \n '+system.Label.ExceptionOccurred  + ex.getMessage();
             if(transactionObj.Response_Status__c == CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED) {
                 result.message += system.Label.InvoiceIsCharged;
                 transactionObj.Is_Payment_Processed_Successfully__c = false;
                 transactionObj.Exception_Message__c = system.Label.transactionIsDoneButPAIsNotDone + '\n' + 'Exception message is : ' +  ex.getMessage() + ' \n Line no is ' +  ex.getLineNumber() + ' \n Type of exception ' + ex.getTypeName();
                 upsert transactionObj;   
             }
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
              Modified By : Rama Krishna: 19 august 2014: SUP-312
              Comments    : exending the callout time to max
          */
          httpRequest.setTimeout(120000);
          httpRequest.setBody(xmlBody);
          
           if(!system.test.isRunningTest()) {
              httpResponse = httpObject.send(httpRequest);
            
            if(httpResponse.getStatusCode() == 201) {
                  //parse the xml and create key-value pair
                  sRawHttpResponse = httpResponse.getBody();
                  Dom.Document doc = httpResponse.getBodyDocument();
                  Dom.XMLNode rootElement = doc.getRootElement();
                  getElements(rootElement);
                  handleRequest();
                  
              } else {
                  /*transactionObj.Response__c = httpResponse.getBody();
                  transactionObj.Response_Status__c = httpResponse.getBody();
                  result.message = httpResponse.getBody();
                  result.reloadPage = false;*/
                  if(isGenericMethodCall){
                    result.message = httpResponse.getStatus();
                    result.reloadPage = false;
                 }else{
                     transactionObj.Exception_Message__c = system.Label.AuthorizationRequired;
                 }
                  
              }
              
          } else {
              string sSuccess = '<?xml version="1.0" encoding="UTF-8"?> <TransactionResult> <ExactID>AD8627-02</ExactID> <Password></Password> <Transaction_Type>00</Transaction_Type> <DollarAmount>120.0</DollarAmount> <SurchargeAmount></SurchargeAmount> <Card_Number>############1111</Card_Number> <Transaction_Tag>16987205</Transaction_Tag> <Track1></Track1> <Track2></Track2> <PAN></PAN> <Authorization_Num>ET141287</Authorization_Num> <Expiry_Date>0219</Expiry_Date> <CardHoldersName>Dev</CardHoldersName> <VerificationStr1></VerificationStr1> <VerificationStr2></VerificationStr2> <CVD_Presence_Ind>0</CVD_Presence_Ind> <ZipCode></ZipCode> <Tax1Amount></Tax1Amount> <Tax1Number></Tax1Number> <Tax2Amount></Tax2Amount> <Tax2Number></Tax2Number> <Secure_AuthRequired></Secure_AuthRequired> <Secure_AuthResult></Secure_AuthResult> <Ecommerce_Flag></Ecommerce_Flag> <XID></XID> <CAVV></CAVV> <CAVV_Algorithm></CAVV_Algorithm> <Reference_No></Reference_No> <Customer_Ref></Customer_Ref> <Reference_3></Reference_3> <Language></Language> <Client_IP>96.43.146.8</Client_IP> <Client_Email></Client_Email> <Transaction_Error>false</Transaction_Error> <Transaction_Approved>true</Transaction_Approved> <EXact_Resp_Code>00</EXact_Resp_Code> <EXact_Message>Transaction Normal</EXact_Message> <Bank_Resp_Code>100</Bank_Resp_Code> <Bank_Message>Approved</Bank_Message> <Bank_Resp_Code_2></Bank_Resp_Code_2> <SequenceNo>000165</SequenceNo> <AVS></AVS> <CVV2>I</CVV2> <Retrieval_Ref_No>6498571</Retrieval_Ref_No> <CAVV_Response></CAVV_Response> <Currency>INR</Currency> <AmountRequested></AmountRequested> <PartialRedemption>false</PartialRedemption> <MerchantName>myown DEMO0141</MerchantName> <MerchantAddress>Bangalore</MerchantAddress> <MerchantCity>bangalore</MerchantCity> <MerchantProvince></MerchantProvince> <MerchantCountry>India</MerchantCountry> <MerchantPostal>560095</MerchantPostal> <MerchantURL></MerchantURL> <TransarmorToken></TransarmorToken> <CardType>Visa</CardType> <CurrentBalance></CurrentBalance> <PreviousBalance></PreviousBalance> <EAN></EAN> <CardCost></CardCost> <VirtualCard>false</VirtualCard> <CTR>=========== TRANSACTION RECORD ========== myown DEMO0141 Bangalore bangalore, 560095 India TYPE: Purchase ACCT: Visa 120.00 INR CARDHOLDER NAME : Dev CARD NUMBER : ############1111 DATE/TIME : 11 Feb 14 04:33:03 REFERENCE # : 000165 M AUTHOR. # : ET141287 TRANS. REF. : Approved - Thank You 100 SIGNATURE ------------------------------------ Please retain this copy for your records. Cardholder will pay above amount to card issuer pursuant to cardholder agreement. =========================================</CTR> </TransactionResult>';
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
           //if it is true,then transaction is approved
           if(mapOfKeyValue.containsKey('Transaction_Approved')) 
           {
              sResponseFromGateway = mapOfKeyValue.get('Transaction_Approved');

              if(sResponseFromGateway == 'true') 
              {
                  result.reloadPage = true;
                  transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED;
                  transactionObj.Gateway_ID__c = mapOfKeyValue.get('Retrieval_Ref_No');
                  transactionObj.Authorization__c = mapOfKeyValue.get('Authorization_Num');
                  transactionObj.Response_Code__c = mapOfKeyValue.get('Bank_Resp_Code');
                  transactionObj.Response__c = mapOfKeyValue.get('Bank_Resp_Code');
              }
              else
              {
                  result.reloadPage = false;
                  transactionObj.Response_Status__c = CommonUtilClass.TRANSACTION_RESPONSE_STATUS_ERROR + '. ' + mapOfKeyValue.get('Bank_Message');
                  transactionObj.Response_Code__c = mapOfKeyValue.get('Bank_Resp_Code');
                  transactionObj.Gateway_ID__c = mapOfKeyValue.get('Authorization_Num');
                  //Added by DL, INVOICEIT-635
                  transactionObj.Is_Payment_Processed_Successfully__c = false;
              }
           }
           
            if(isGenericMethodCall){
           result.message = system.Label.transactioncreated;
           // for the site payment, if the the boolean is true dont insert transaction record
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
          
      } }
      
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