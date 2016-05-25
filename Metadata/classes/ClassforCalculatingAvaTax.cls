global with sharing class ClassforCalculatingAvaTax{
    private string sHttpEndPoint = '';
    private string sHttpBody = '';
    private string sHttpResponse;
    private map<string, string> mapOfKeyValue = new map<string, string>();
    private ClassforCalculatingTax.ClassTaxParameters result = new ClassforCalculatingTax.ClassTaxParameters();
    private HttpRequest httpRequest;
    private string sResult;
    
    WebService static void voidTaxInvoice(Id accountId,ID orderID,Id invoiceID) {
       list<Tax_Integration__c> listofTaxIntegration = CommonUtilClassForTaxation.getDefaultTax(orderID,accountId);
         Invoice__c inv = [SELECT Name,Tax_Engine__c,Order__c,Account__c,Invoice_Date__c,Amount__c FROM Invoice__c where id=: invoiceID];
         if(listofTaxIntegration.size() > 0){
              ClassforCalculatingTax.ClassTaxParameters classTaxParametersObj = ClassforCalculatingTax.cancelTaxForInvoice(listofTaxIntegration[0], inv);       
          
              if(classTaxParametersObj.sMessage == 'Success' &&  ( classTaxParametersObj.sSummary == '' || classTaxParametersObj.sSummary == null )){
                 inv.Tax_Calculation_Status__c = 'Voided';
               }else{
                  if( classTaxParametersObj.sSummary != '' && classTaxParametersObj.sSummary != null ) {
                    inv.Exception_Log__c = classTaxParametersObj.sSummary;   
                  }else{
                    inv.Exception_Log__c = classTaxParametersObj.sMessage;  
                    } 
                  inv.Tax_Calculation_Status__c = 'Stopped';
               } 
         }else{
           inv.Exception_Log__c =  'Avalara Account is not configured.';
           inv.Tax_Calculation_Status__c = 'Stopped';
         }  
         update inv; 
    }
    
     WebService static void calculateTaxInvoice(Id accountId,ID orderID,Id invoiceID) {
     
       list<Tax_Integration__c> listofTaxIntegration = CommonUtilClassForTaxation.getDefaultTax(orderID,accountId);
         Invoice__c inv = new Invoice__c(id= invoiceID);
         if(listofTaxIntegration.size() > 0){
             ClassforCalculatingTax.ClassTaxParameters classTaxParametersObj = ClassforCalculatingTax.getTaxForInvoice(listofTaxIntegration[0], invoiceID);
             list<Invoice_Lines__c> listOfInvoiceLinesToUpdate = new list<Invoice_Lines__c>();
             if(classTaxParametersObj.sMessage == 'Success' &&  ( classTaxParametersObj.sSummary == '' || classTaxParametersObj.sSummary == null )) {
                 listOfInvoiceLinesToUpdate = classTaxParametersObj.listOfInvoiceLinesToUpdate;
                 //inv = [SELECT Name,Tax_Engine__c,Order__c,Account__c,Invoice_Date__c,Amount__c FROM Invoice__c where id=: invoiceID];
                 //classTaxParametersObj = ClassforCalculatingTax.postTaxForInvoice(listofTaxIntegration[0], inv,classTaxParametersObj.calculatedTax);
              //if(classTaxParametersObj.sMessage == 'Success'){
                inv.Tax_Calculation_Status__c = 'Processed';
                inv.Invoice_Status__c = 'Posted';
                inv.Exception_Log__c = null;
              /*}else {
                 inv.Exception_Log__c = classTaxParametersObj.sSummary;
                 inv.Tax_Calculation_Status__c = 'Stopped';
               }*/
               update listOfInvoiceLinesToUpdate;
           } else{
             if( classTaxParametersObj.sSummary != '' && classTaxParametersObj.sSummary != null ) {
                    inv.Exception_Log__c = classTaxParametersObj.sSummary;   
                }else{
                    inv.Exception_Log__c = classTaxParametersObj.sMessage;  
                }           
                 inv.Tax_Calculation_Status__c = 'Stopped';
           }
         }else{
           inv.Exception_Log__c =  'Avalara Account is not configured.';
           inv.Tax_Calculation_Status__c = 'Stopped';
         }   
         update inv;
    }

    WebService static void calculateTaxOrder(Id orderId) {
        list<Tax_Integration__c> listofTaxIntegration = new list<Tax_Integration__c> ();
        listofTaxIntegration = CommonUtilClassForTaxation.getDefaultTax(orderId, null);
        Job__c job;
        if(listofTaxIntegration != null && !listofTaxIntegration.isEmpty()){
            ClassforCalculatingTax.ClassTaxParameters classTaxParametersObj = ClassforCalculatingTax.getTaxForOrder(listofTaxIntegration[0],orderId);

            if(classTaxParametersObj.sMessage == 'Success' &&  ( classTaxParametersObj.sSummary == '' || classTaxParametersObj.sSummary == null )) {
                update classTaxParametersObj.listOfOrderLinesToUpdate;
                job = new Job__c(Id = orderId, Exception_Log__c = '', Tax_Calculation_Status__c = 'Processed', Recalculate__c = true);
            } else {
                if( classTaxParametersObj.sSummary != '' && classTaxParametersObj.sSummary != null ) {
                    job = new Job__c(Id = orderId, Exception_Log__c = classTaxParametersObj.sSummary, Tax_Calculation_Status__c = 'Stopped');
                } else {
                     job = new Job__c(Id = orderId, Exception_Log__c = classTaxParametersObj.sMessage, Tax_Calculation_Status__c = 'Stopped');
                }
            }  
        } else {
           job = new Job__c(Id = orderId, Exception_Log__c = 'Avalara Account is not configured.', Tax_Calculation_Status__c = 'Stopped');
        }
        update job;
    }
    
    global ClassforCalculatingTax.ClassTaxParameters getTax(ClassforCalculatingTax.ClassTaxParameters taxation){
        try{
            
            if(taxation.taxIntegrationObj.Test_Mode__c){
                sHttpEndPoint = CommonUtilClassForTaxation.ENDPOINT_AVALARATAX_TEST;
            }else{
                sHttpEndPoint = CommonUtilClassForTaxation.ENDPOINT_AVALARATAX_LIVE;
            }

            httpRequest = new httpRequest();
            httpRequest.setHeader('SOAPAction', 'http://avatax.avalara.com/services/GetTax');
            validateRequest(taxation, 'getTax');
            if(sResult == ''){
                string chargeXmlRequest = '<?xml version="1.0" encoding="UTF-8"?>'+
                                       '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://avatax.avalara.com/services">'+
                                       '<SOAP-ENV:Header>'+
                                        '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" SOAP-ENV:mustUnderstand="1">'+
                                            '<wsse:UsernameToken>'+
                                                '<wsse:Username>'+taxation.taxIntegrationObj.AvaTax_Account_Number__c+'</wsse:Username>'+
                                                '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+taxation.taxIntegrationObj.AvaTax_License_Key__c+'</wsse:Password>'+
                                            '</wsse:UsernameToken>'+
                                        '</wsse:Security>'+
                                        '<Profile xmlns="http://avatax.avalara.com/services" SOAP-ENV:actor="http://schemas.xmlsoap.org/soap/actor/next" SOAP-ENV:mustUnderstand="0">'+
                                            '<Client>'+taxation.taxIntegrationObj.AvaTax_Client_Name__c+'</Client>'+
                                            '<Adapter>'+taxation.taxIntegrationObj.AvaTax_Adapter__c+'</Adapter>'+
                                            '<Name>'+taxation.taxIntegrationObj.AvaTax_Environment_Name__c+'</Name>'+
                                        '</Profile>'+
                                        '</SOAP-ENV:Header>'+
                                        '<SOAP-ENV:Body>'+
                                            '<ns1:GetTax>'+
                                                '<ns1:GetTaxRequest>'+
                                                    '<ns1:CompanyCode>'+taxation.taxIntegrationObj.AvaTax_Company_Code__c+'</ns1:CompanyCode>'+
                                                    '<ns1:DocType>'+taxation.sDocType+'</ns1:DocType>'+
                                                    '<ns1:DocCode>'+taxation.sDocCode+'</ns1:DocCode>'+
                                                    '<ns1:DocDate>'+taxation.sDocDate+'</ns1:DocDate>'+
                                                    '<ns1:OriginCode>'+taxation.sOriginCode+'</ns1:OriginCode>'+
                                                    '<ns1:DestinationCode>'+taxation.sDestinationCode+'</ns1:DestinationCode>';
                                                    if(taxation.sCustomerCode != null){
                                                        chargeXmlRequest += '<ns1:CustomerCode>'+taxation.sCustomerCode+'</ns1:CustomerCode>';
                                                    }
                                                    if(taxation.dDiscount != null){
                                                        chargeXmlRequest += '<ns1:Discount>'+taxation.dDiscount+'</ns1:Discount>';
                                                    }
                                                    if(taxation.sCurrencyCode != null){
                                                       chargeXmlRequest += '<CurrencyCode>'+taxation.sCurrencyCode+'</CurrencyCode>';
                                                    }
                                                    
                                chargeXmlRequest += '<ns1:Addresses>';
                                                        for(ClassforCalculatingTax.ClassBaseAddress baseAddress :taxation.listofClassBaseAddress){
                                                            chargeXmlRequest +=  '<ns1:BaseAddress>'+
                                                                                     '<ns1:AddressCode>'+baseAddress.sAddressCode+'</ns1:AddressCode>'+
                                                                                     '<ns1:Line1>'+baseAddress.sLine1+'</ns1:Line1>'+
                                                                                     '<ns1:PostalCode>'+baseAddress.sPostalCode+'</ns1:PostalCode>';
                                                                                     if(baseAddress.sCity != null){
                                                                                        chargeXmlRequest += '<ns1:City>'+baseAddress.sCity+'</ns1:City>';
                                                                                     }
                                                                                     if(baseAddress.sRegion != null){
                                                                                        chargeXmlRequest += '<ns1:Region>'+baseAddress.sRegion+'</ns1:Region>';
                                                                                     }
                                                                                     if(baseAddress.sCountry != null){
                                                                                        chargeXmlRequest += '<ns1:Country>'+baseAddress.sCountry+'</ns1:Country>';
                                                                                     }
                                                                                     if(baseAddress.sTaxRegionId != null){
                                                                                        chargeXmlRequest += '<ns1:TaxRegionId>'+baseAddress.sTaxRegionId+'</ns1:TaxRegionId>';
                                                                                     }
                                                                                chargeXmlRequest +=  '</ns1:BaseAddress>';
                                                        }
                                chargeXmlRequest += '</ns1:Addresses>'+
                                                        '<ns1:Lines>';
                                                        for(ClassforCalculatingTax.ClassLines lines: taxation.listofClassLines){
                                                            chargeXmlRequest += '<ns1:Line>'+
                                                                                    '<ns1:No>'+lines.sLineNo+'</ns1:No>'+
                                                                                    '<ns1:OriginCode>'+lines.sOriginCode+'</ns1:OriginCode>'+
                                                                                    '<ns1:DestinationCode>'+lines.sDestinationCode+'</ns1:DestinationCode>'+
                                                                                    '<ns1:Amount>'+lines.dAmount+'</ns1:Amount>';
                                                                                    if(lines.dQty != null){
                                                                                        chargeXmlRequest += '<ns1:Qty>'+lines.dQty+'</ns1:Qty>';
                                                                                    }
                                                                                    if(lines.sItemCode != null){
                                                                                        chargeXmlRequest += '<ns1:ItemCode>'+lines.sItemCode+'</ns1:ItemCode>';
                                                                                    }
                                                                                    if(lines.sTaxCode != null){
                                                                                        chargeXmlRequest += '<ns1:TaxCode>'+lines.sTaxCode+'</ns1:TaxCode>';
                                                                                    }
                                                                                    if(lines.bDiscounted != null){
                                                                                        chargeXmlRequest += '<ns1:Discounted>'+lines.bDiscounted+'</ns1:Discounted>';
                                                                                    }
                                                                                    if(lines.sDescription != null){
                                                                                       chargeXmlRequest += '<ns1:Description>'+lines.sDescription+'</ns1:Description>';
                                                                                    }
                                                                                    
                                                                                chargeXmlRequest += '</ns1:Line>';
                                                        } 
                                chargeXmlRequest +=  '</ns1:Lines>'+
                                                    '<ns1:DetailLevel>Tax</ns1:DetailLevel>'+
                                                    '<ns1:HashCode>0</ns1:HashCode>'+
                                                    '<ns1:Commit>true</ns1:Commit>'+
                                                    '<ns1:ServiceMode>Automatic</ns1:ServiceMode>';
                                                    if(taxation.sPaymentDate != null){
                                                        chargeXmlRequest += '<ns1:PaymentDate>'+taxation.sPaymentDate+'</ns1:PaymentDate>';
                                                    }
                                                    if(taxation.dExchangeRate != null){
                                                        chargeXmlRequest += '<ns1:ExchangeRate>'+taxation.dExchangeRate+'</ns1:ExchangeRate>';
                                                    }
                                                    if(taxation.sExchangeRateEffDate != null){
                                                       chargeXmlRequest += '<ns1:ExchangeRateEffDate>'+taxation.sExchangeRateEffDate+'</ns1:ExchangeRateEffDate>';
                                                    } 
                                chargeXmlRequest += '</ns1:GetTaxRequest>'+
                                            '</ns1:GetTax>'+
                                        '</SOAP-ENV:Body>'+
                                    '</SOAP-ENV:Envelope>';
             
                sendHttpRequest(chargeXmlRequest,taxation);

                //calculating tax for invoice lines
             
                list<Invoice_Lines__c> listOfInvoiceLines = new list<Invoice_Lines__c>();
                if(taxation.listOfInvoiceLinesToUpdate != null && taxation.listOfInvoiceLinesToUpdate.size() > 0){
                    for(Invoice_Lines__c invoiceLines :taxation.listOfInvoiceLinesToUpdate){
                        Invoice_Lines__c invLines = new Invoice_Lines__c(id=invoiceLines.id,Tax__c=(invoiceLines.Line_Amount__c * result.calculatedTax)/invoiceLines.Invoice__r.Amount__c);
                       listOfInvoiceLines.add(invLines);
                    }
                    //update taxation.listOfInvoiceLinesToUpdate;
                
                }
                result.listOfInvoiceLinesToUpdate = listOfInvoiceLines;

                //calculating tax for order lines
                list<Job_Rate_Plan_Charge__c> listOfOrderLines = new list<Job_Rate_Plan_Charge__c>();
                if(taxation.listOfOrderLinesToUpdate != null && taxation.listOfOrderLinesToUpdate.size() > 0){
                    for(Job_Rate_Plan_Charge__c orderLines :taxation.listOfOrderLinesToUpdate){
                        Job_Rate_Plan_Charge__c charge = new Job_Rate_Plan_Charge__c(id=orderLines.id, Tax__c = (orderLines.Price__c * result.calculatedTax)/orderLines.Order__r.Sub_Total__c);
                        listOfOrderLines.add(charge);
                    }
                    //update taxation.listOfInvoiceLinesToUpdate;
                }

                result.listOfOrderLinesToUpdate = listOfOrderLines;
            }else{
                result.sMessage = sResult;
            }
     

        }catch(Exception ex){
            result.sMessage += '\n \n '+system.Label.ExceptionOccurred +' ' + ex.getMessage();
        }
       return result;
    }

    global ClassforCalculatingTax.ClassTaxParameters postTax(ClassforCalculatingTax.ClassTaxParameters taxation){
        try{

            if(taxation.taxIntegrationObj.Test_Mode__c){
                sHttpEndPoint = CommonUtilClassForTaxation.ENDPOINT_AVALARATAX_TEST; 
            }else{
                sHttpEndPoint = CommonUtilClassForTaxation.ENDPOINT_AVALARATAX_LIVE;
            }
            httpRequest = new httpRequest();
            httpRequest.setHeader('SOAPAction', 'http://avatax.avalara.com/services/PostTax');
            validateRequest(taxation, 'postTax');
            if(sResult == ''){
                string chargeXmlRequest = '<?xml version="1.0" encoding="UTF-8"?>'+
                                          '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://avatax.avalara.com/services">'+
                                            '<SOAP-ENV:Header>'+
                                                '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" SOAP-ENV:mustUnderstand="1">'+
                                                    '<wsse:UsernameToken>'+
                                                        '<wsse:Username>'+taxation.taxIntegrationObj.AvaTax_Account_Number__c+'</wsse:Username>'+
                                                             '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+taxation.taxIntegrationObj.AvaTax_License_Key__c+'</wsse:Password>'+
                                                    '</wsse:UsernameToken>'+ 
                                                '</wsse:Security>'+
                                                '<Profile xmlns="http://avatax.avalara.com/services" SOAP-ENV:actor="http://schemas.xmlsoap.org/soap/actor/next" SOAP-ENV:mustUnderstand="0">'+
                                                    '<Client>'+taxation.taxIntegrationObj.AvaTax_Client_Name__c+'</Client>'+
                                                    '<Adapter>'+taxation.taxIntegrationObj.AvaTax_Adapter__c+'</Adapter>'+
                                                    '<Name>'+taxation.taxIntegrationObj.AvaTax_Environment_Name__c+'</Name>'+
                                                '</Profile>'+ 
                                            '</SOAP-ENV:Header>'+
                                            '<SOAP-ENV:Body>'+
                                                '<ns1:PostTax>'+
                                                    '<ns1:PostTaxRequest>'+
                                                        '<ns1:CompanyCode>'+taxation.taxIntegrationObj.AvaTax_Company_Code__c+'</ns1:CompanyCode>'+
                                                        '<ns1:DocType>'+taxation.sDocType+'</ns1:DocType>'+
                                                        '<ns1:DocCode>'+taxation.sDocCode+'</ns1:DocCode>'+
                                                        '<ns1:DocDate>'+taxation.sDocDate+'</ns1:DocDate>'+
                                                        '<ns1:TotalAmount>'+taxation.dTotalAmount+'</ns1:TotalAmount>'+
                                                        '<ns1:TotalTax>'+taxation.dTotalTax+'</ns1:TotalTax>'+
                                                        '<ns1:HashCode>0</ns1:HashCode>'+
                                                       ' <ns1:Commit>false</ns1:Commit>'+
                                                    '</ns1:PostTaxRequest>'+
                                                '</ns1:PostTax>'+
                                            '</SOAP-ENV:Body>'+
                                        '</SOAP-ENV:Envelope>';
                sendHttpRequest(chargeXmlRequest,taxation);
            }else{
                result.sMessage = sResult;
            }
        }catch(Exception ex){
            result.sMessage += '\n \n '+system.Label.ExceptionOccurred +' ' + ex.getMessage();
        }
  
        return result;
    }

    global ClassforCalculatingTax.ClassTaxParameters cancelTax(ClassforCalculatingTax.ClassTaxParameters taxation){
        try{
            if(taxation.taxIntegrationObj.Test_Mode__c){
                sHttpEndPoint = CommonUtilClassForTaxation.ENDPOINT_AVALARATAX_TEST;
            }else{
                sHttpEndPoint = CommonUtilClassForTaxation.ENDPOINT_AVALARATAX_LIVE;
            }
            httpRequest = new httpRequest();
            httpRequest.setHeader('SOAPAction', 'http://avatax.avalara.com/services/CancelTax');
            validateRequest(taxation, 'cancelTax');
            if(sResult == ''){
                string chargeXmlRequest = '<?xml version="1.0" encoding="UTF-8"?>'+
                                          '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://avatax.avalara.com/services">'+
                                          '<SOAP-ENV:Header>'+
                                            '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" SOAP-ENV:mustUnderstand="1">'+
                                                '<wsse:UsernameToken>'+
                                                    '<wsse:Username>'+taxation.taxIntegrationObj.AvaTax_Account_Number__c+'</wsse:Username>'+
                                                    '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">'+taxation.taxIntegrationObj.AvaTax_License_Key__c+'</wsse:Password>'+
                                                '</wsse:UsernameToken>'+
                                            '</wsse:Security>'+
                                            '<Profile xmlns="http://avatax.avalara.com/services" SOAP-ENV:actor="http://schemas.xmlsoap.org/soap/actor/next" SOAP-ENV:mustUnderstand="0">'+
                                                '<Client>'+taxation.taxIntegrationObj.AvaTax_Client_Name__c+'</Client>'+
                                                '<Adapter>'+taxation.taxIntegrationObj.AvaTax_Adapter__c+'</Adapter>'+
                                                '<Name>'+taxation.taxIntegrationObj.AvaTax_Environment_Name__c+'</Name>'+
                                            '</Profile>'+
                                          '</SOAP-ENV:Header>'+
                                          '<SOAP-ENV:Body>'+
                                            '<ns1:CancelTax>'+
                                                '<ns1:CancelTaxRequest>'+
                                                    '<ns1:CompanyCode>'+taxation.taxIntegrationObj.AvaTax_Company_Code__c+'</ns1:CompanyCode>'+
                                                    '<ns1:DocType>'+taxation.sDocType+'</ns1:DocType>'+
                                                    '<ns1:DocCode>'+taxation.sDocCode+'</ns1:DocCode>'+
                                                    '<ns1:CancelCode>'+taxation.sCancelCode+'</ns1:CancelCode>'+
                                                '</ns1:CancelTaxRequest>'+
                                            '</ns1:CancelTax>'+
                                          '</SOAP-ENV:Body>'+
                                          '</SOAP-ENV:Envelope>';
                sendHttpRequest(chargeXmlRequest,taxation);
            }else{
                result.sMessage = sResult;
            }
        }catch(Exception ex){
            result.sMessage += '\n \n '+system.Label.ExceptionOccurred +' ' + ex.getMessage();
        }
    
        return result;
    }

    public void sendHttpRequest(string xmlBody,ClassforCalculatingTax.ClassTaxParameters taxation) {
    
        Http httpObject = new Http();
        HttpResponse httpResponse;
        string sRawHttpResponse;

        String username = string.valueOf(taxation.taxIntegrationObj.AvaTax_Account_Number__c);
        String password = taxation.taxIntegrationObj.AvaTax_License_Key__c;

        Blob headerValue = blob.valueOf(username + ':' + password);
        string authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        
        httpRequest.setHeader('Authorization', authorizationHeader);
        httpRequest.setHeader('Content-type', 'text/xml');
        
        httpRequest.setEndpoint(sHttpEndPoint);
        httpRequest.setMethod('POST');
        
        httpRequest.setTimeout(120000);
        httpRequest.setBody(xmlBody);
        if(!system.test.isRunningTest()) {
            httpResponse = httpObject.send(httpRequest);
      
            if(httpResponse.getStatusCode() == 200) {
                sRawHttpResponse = httpResponse.getBody();
                Dom.Document doc = httpResponse.getBodyDocument();
                Dom.XMLNode rootElement = doc.getRootElement();
                getElements(rootElement);
                handleRequest();

            }else if(httpResponse.getStatusCode() == 500){
                sRawHttpResponse = httpResponse.getBody();
                Dom.Document doc = httpResponse.getBodyDocument();
                Dom.XMLNode rootElement = doc.getRootElement();
                getElements(rootElement);
                result.sMessage = httpResponse.getStatus();
                result.sSummary = mapOfKeyValue.get('faultstring');
            }else{
                sRawHttpResponse = httpResponse.getBody();
                Dom.Document doc = httpResponse.getBodyDocument();
                Dom.XMLNode rootElement = doc.getRootElement();
                getElements(rootElement);
                result.sMessage = httpResponse.getStatus();
                result.sSummary = mapOfKeyValue.get('message');
            }
        }else {
            string sSuccess = '<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"><s:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><GetTaxResponse xmlns="http://avatax.avalara.com/services"><GetTaxResult><TransactionId>4750408166723020</TransactionId><ResultCode>Success</ResultCode><DocId>148583416</DocId><DocType>SalesInvoice</DocType><DocCode>INV003</DocCode><DocDate>2014-01-01</DocDate><DocStatus>Saved</DocStatus><Reconciled>false</Reconciled><Timestamp>2016-01-21T11:46:56.673</Timestamp><TotalAmount>5000</TotalAmount><TotalDiscount>0</TotalDiscount><TotalExemption>5000</TotalExemption><TotalTaxable>0</TotalTaxable><TotalTax>0</TotalTax><TotalTaxCalculated>0</TotalTaxCalculated><HashCode>0</HashCode><TaxLines><TaxLine><No>1</No><TaxCode>NT</TaxCode><Taxability>true</Taxability><BoundaryLevel>Address</BoundaryLevel><Exemption>5000</Exemption><Discount>0</Discount><Taxable>0</Taxable><Rate>0</Rate><Tax>0</Tax><TaxCalculated>0</TaxCalculated><TaxIncluded>false</TaxIncluded><TaxDetails><TaxDetail><Country>US</Country><Region>CA</Region><JurisType>State</JurisType><JurisCode>06</JurisCode><TaxType>Sales</TaxType><Base>0</Base><Taxable>0</Taxable><Rate>0</Rate><Tax>0</Tax><TaxCalculated>0</TaxCalculated><NonTaxable>5000</NonTaxable><Exemption>0</Exemption><JurisName>CALIFORNIA</JurisName><TaxName>CA STATE TAX</TaxName><TaxAuthorityType>45</TaxAuthorityType><TaxGroup/><RateType>G</RateType><StateAssignedNo/></TaxDetail></TaxDetails><ExemptCertId>0</ExemptCertId><TaxDate>2014-01-01</TaxDate><ReportingDate>2014-01-01</ReportingDate><AccountingMethod>Accrual</AccountingMethod></TaxLine></TaxLines><TaxAddresses><TaxAddress><Address>45 Fremont Street</Address><AddressCode>0</AddressCode><BoundaryLevel>0</BoundaryLevel><City>San Francisco</City><Country>US</Country><PostalCode>94105-2204</PostalCode><Region>CA</Region><TaxRegionId>2113460</TaxRegionId><JurisCode>0607500000</JurisCode><Latitude>37.791119</Latitude><Longitude>-122.397366</Longitude><GeocodeType>StreetLevel</GeocodeType><ValidateStatus>NormalHit</ValidateStatus><DistanceToBoundary>0</DistanceToBoundary></TaxAddress></TaxAddresses><Locked>false</Locked><AdjustmentReason>0</AdjustmentReason><AdjustmentDescription/><Version>1</Version><TaxDate>2014-01-01</TaxDate><TaxSummary/><VolatileTaxRates>false</VolatileTaxRates></GetTaxResult></GetTaxResponse></s:Body></s:Envelope>';
            Dom.Document doc = new Dom.Document();
            doc.load(sSuccess);     
            Dom.XMLNode rootElement = doc.getRootElement();
            getElements(rootElement);
            handleRequest();
        }
  
    }
    private void handleRequest() {
        string sResponseFromGateway;
        result.sMessage = '';
        if(mapOfKeyValue.containsKey('ResultCode')){
            sResponseFromGateway = mapOfKeyValue.get('ResultCode');
            if(sResponseFromGateway == 'Success'){
                result.isSuccess = true;
                result.sMessage = mapOfKeyValue.get('ResultCode');
                result.sDocCode = mapOfKeyValue.get('DocCode');
                result.sDocDate = mapOfKeyValue.get('DocDate');
                result.sDocId = mapOfKeyValue.get('DocId');
                result.sDocStatus = mapOfKeyValue.get('DocStatus');
                result.sTransactionId = mapOfKeyValue.get('TransactionId');
                if(mapOfKeyValue.containsKey('TotalTaxCalculated')){
                    result.calculatedTax = decimal.valueOf(mapOfKeyValue.get('TotalTaxCalculated'));
                }else{
                    result.calculatedTax = 0;
                }

            }else{
                result.isSuccess = false;
                result.sMessage = mapOfKeyValue.get('ResultCode');
                result.sSummary = mapOfKeyValue.get('Summary');
                result.sTransactionId = mapOfKeyValue.get('TransactionId');
                result.sDetails = mapOfKeyValue.get('Details');
            }
        }
    
    }
    private void getElements(DOM.XMLNode node){
        if(node.getNodeType() == DOM.XMLNodeType.ELEMENT){
       
            if(node.getText().trim() != '') {
                mapOfKeyValue.put(node.getName(), node.getText().trim());
            }

            for(Dom.XMLNode child : node.getChildElements()) {
                getElements(child);
            }
        }   
    }
    private string validateRequest(ClassforCalculatingTax.ClassTaxParameters taxation, string sTaxMethod){
        sResult = '';
        if(sTaxMethod == 'getTax'){
            if(taxation.taxIntegrationObj.AvaTax_Client_Name__c == null){
                sResult = 'Please provide Client name';
            }
            else if(taxation.taxIntegrationObj.AvaTax_Adapter__c == null ){
                sResult = 'Please provide Adapter';
            }
            else if(taxation.taxIntegrationObj.AvaTax_Environment_Name__c == null ){
                sResult = 'Please provide Environment';
            }
            else if(taxation.sDocCode == null || taxation.sDocCode == ''){
                sResult = 'DocCode is missing';
            }
            else if(taxation.sDocType == null || taxation.sDocType == ''){
                sResult = 'DocType is missing';
            }
            else if(taxation.sDocDate == null || taxation.sDocDate == ''){
                sResult = 'DocDate is missing';
            }
            else if(taxation.sDestinationCode == null){
                sResult = 'DestinationCode is missing';
            }
            else if(taxation.sOriginCode == null){
                sResult = 'OriginCode is missing';
            }
            for(ClassforCalculatingTax.ClassBaseAddress baseAddress :taxation.listofClassBaseAddress){
                if(baseAddress.sAddressCode == null || baseAddress.sAddressCode == ''){
                    sResult = 'AddressCode is missing';
                }
                else if(baseAddress.sLine1 == null || baseAddress.sLine1 == '' ){
                    sResult = 'Line1 is missing';
                }
                else if(baseAddress.sPostalCode == null || baseAddress.sPostalCode == '' ){
                    sResult = 'PostalCode is missing';
                }
            }
            for(ClassforCalculatingTax.ClassLines lines: taxation.listofClassLines){
                if(lines.dAmount == null){
                    sResult = 'Amount is missing';
                }else if(lines.dAmount <= 0 ){
                    sResult = 'Please provide valid Amount ';
                }else if(lines.sOriginCode == null || lines.sOriginCode == ''){
                    sResult = 'Please provide line OriginCode';
                }else if(lines.sDestinationCode == null || lines.sDestinationCode == ''){
                    sResult = 'Please provide line DestinationCode';
                }
            }
            
            if(sTaxMethod == 'postTax'){
                if(taxation.taxIntegrationObj.AvaTax_Client_Name__c == null){
                    sResult = 'Please provide Client name';
                }
                else if(taxation.taxIntegrationObj.AvaTax_Adapter__c == null ){
                    sResult = 'Please provide Adapter';
                }
                else if(taxation.taxIntegrationObj.AvaTax_Environment_Name__c == null ){
                    sResult = 'Please provide Environment';
                }
                else if(taxation.taxIntegrationObj.AvaTax_Company_Code__c == null){
                    sResult = 'Please provide company code';
                }
                else if(taxation.sDocCode == null || taxation.sDocCode == ''){
                    sResult = 'DocCode is missing';
                }
                else if(taxation.sDocType == null || taxation.sDocType == ''){
                    sResult = 'DocType is missing';
                }
                else if(taxation.sDocDate == null || taxation.sDocDate == ''){
                    sResult = 'DocDate is missing';
                }
                else if(taxation.dTotalAmount == null){
                    sResult = 'Please provide TotalAmount';
                }
                else if(taxation.dTotalTax == null){
                    sResult = 'Please provide Tax value';
                }
            }
            if(sTaxMethod == 'cancelTax'){
                if(taxation.taxIntegrationObj.AvaTax_Client_Name__c == null){
                    sResult = 'Please provide Client name';
                }
                else if(taxation.taxIntegrationObj.AvaTax_Adapter__c == null ){
                    sResult = 'Please provide Adapter';
                }
                else if(taxation.taxIntegrationObj.AvaTax_Environment_Name__c == null ){
                    sResult = 'Please provide Environment';
                }
                else if(taxation.taxIntegrationObj.AvaTax_Company_Code__c == null){
                    sResult = 'Please provide company code';
                }
                else if(taxation.sDocCode == null || taxation.sDocCode == ''){
                    sResult = 'DocCode is missing';
                }
                else if(taxation.sDocType == null || taxation.sDocType == ''){
                    sResult = 'DocType is missing';
                }
                else if(taxation.sCancelCode == null || taxation.sCancelCode == ''){
                    sResult = 'CancelCode is missing';
                }
            }
        }
        return sResult;
    }
}