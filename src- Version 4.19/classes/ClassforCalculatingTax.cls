global with sharing class ClassforCalculatingTax{

    //This method is used to get and commit the tax
    global static ClassTaxParameters getTaxForInvoice(Tax_Integration__c taxIntegration, string sObjectId){

        String sPrefix = CommonUtilClassForTaxation.getPrefix();
        string sObjectQuery = 'SELECT '+ CommonUtilClassForTaxation.getObjectFields(sPrefix+'Invoice__c')
                            + ', (SELECT Invoice__r.Amount__c,' + CommonUtilClassForTaxation.getObjectFields(sPrefix+'Invoice_Lines__c') +  'FROM Invoice_Lines__r ) '
                            + ',CurrencyL__r.Name '
                            + 'FROM Invoice__c '
                            + 'WHERE Id =' + '\'' + sObjectId + '\'';

        sObjectQuery = String.escapeSingleQuotes(sObjectQuery);
        sObjectQuery = sObjectQuery.replace('\\', '');
        Invoice__c invoice = Database.query(sObjectQuery);
        Account account;
        String sTaxCalculationBasedOn = Configuration__c.getValues(CommonUtilClassForTaxation.TAX_CALCULATION_BASED_ON).String_Value__c;
        if(sTaxCalculationBasedOn != null ||  sTaxCalculationBasedOn == CommonUtilClassForTaxation.ACCOUNT_BILLING_ADDRESS || sTaxCalculationBasedOn == CommonUtilClassForTaxation.ACCOUNT_SHIPPING_ADDRESS){ 
                account = (Account) CommonUtilClassForTaxation.getSobjectById(CommonUtilClassForTaxation.OBJECT_NAME_ACCOUNT, invoice.Account__c);
        }

        ClassforCalculatingTax.ClassTaxParameters objTaxation = new ClassforCalculatingTax.ClassTaxParameters();
        objTaxation.sDocType = 'SalesInvoice';
        objTaxation.sDocCode = invoice.Name;
        objTaxation.sCustomerCode = invoice.Name;
        objTaxation.sDocDate = string.valueof(invoice.Invoice_Date__c);
        objTaxation.dDiscount = invoice.Discount_Value__c;
        objTaxation.sOriginCode = '0';
        objTaxation.sDestinationCode = '1';
        objTaxation.sCurrencyCode = invoice.CurrencyL__r.Name;
        objTaxation.sPaymentDate = string.valueof(invoice.Target_Date__c);
        objTaxation.dExchangeRate = invoice.Exchange_Rate_Applied__c;

        objTaxation.listOfInvoiceLinesToUpdate = invoice.Invoice_Lines__r;
        //obj.sExchangeRateEffDate = d;
        list<ClassforCalculatingTax.ClassBaseAddress> listOfBaseAddress = new list<ClassforCalculatingTax.ClassBaseAddress>();
        ClassforCalculatingTax.ClassBaseAddress baseAddress = new ClassforCalculatingTax.ClassBaseAddress();
        list<ClassforCalculatingTax.ClassLines> listOfline = new list<ClassforCalculatingTax.ClassLines>();
        ClassforCalculatingTax.ClassLines lineAddress; 
        
        //Framing data
        if(sTaxCalculationBasedOn == CommonUtilClassForTaxation.ACCOUNT_BILLING_ADDRESS){  
            if(account != null){
                baseAddress.sAddressCode = '0';
                baseAddress.sLine1 = string.valueof(account.BillingStreet);
                baseAddress.scity = string.valueof(account.BillingCity);
                baseAddress.sRegion = string.valueof(account.BillingState);
                baseAddress.sPostalCode = string.valueof(account.BillingPostalCode);
                baseAddress.sCountry = string.valueof(account.BillingCountry);
                baseAddress.sTaxRegionId = '0';
                listOfBaseAddress.add(baseAddress);
                objTaxation.listofClassBaseAddress = listOfBaseAddress;
                
            }
        }else if(sTaxCalculationBasedOn == CommonUtilClassForTaxation.ACCOUNT_SHIPPING_ADDRESS){  
            if(account != null){
                baseAddress.sAddressCode = '0';
                baseAddress.sLine1 = string.valueof(account.ShippingStreet);
                baseAddress.scity = string.valueof(account.ShippingCity);
                baseAddress.sRegion = string.valueof(account.ShippingState);
                baseAddress.sPostalCode = string.valueof(account.ShippingPostalCode);
                baseAddress.sCountry = string.valueof(account.ShippingCountry);
                baseAddress.sTaxRegionId = '0';
                listOfBaseAddress.add(baseAddress);
                objTaxation.listofClassBaseAddress = listOfBaseAddress;
            }
        }else if(sTaxCalculationBasedOn == CommonUtilClassForTaxation.CONTACT_TYPE_BILLING && invoice.Billing_Contact__c != null)
        {
            Contact contact = [SELECT MailingStreet,MailingCountry, MailingCity, MailingState, MailingPostalCode
                              FROM Contact
                              WHERE Id = :invoice.Billing_Contact__c];
            if(contact != null){
                baseAddress.sAddressCode = '0';
                baseAddress.sLine1 = string.valueof(contact.MailingStreet);
                baseAddress.scity = string.valueof(contact.MailingCity);
                baseAddress.sRegion = string.valueof(contact.MailingState);
                baseAddress.sPostalCode = string.valueof(contact.MailingPostalCode);
                baseAddress.sCountry = string.valueof(contact.MailingCountry);
                baseAddress.sTaxRegionId = '0';
                listOfBaseAddress.add(baseAddress);
                objTaxation.listofClassBaseAddress = listOfBaseAddress;

            }
        }
        else if(sTaxCalculationBasedOn == CommonUtilClassForTaxation.CONTACT_TYPE_SHIPPING && invoice.Shipping_Contact__c != null)
        {
            Contact contact = [SELECT MailingStreet,MailingCountry, MailingCity, MailingState, MailingPostalCode
                                      FROM Contact
                                      WHERE Id = :invoice.Shipping_Contact__c];
            if(contact != null){
                baseAddress.sAddressCode = '0';
                baseAddress.sLine1 = string.valueof(contact.MailingStreet);
                baseAddress.scity = string.valueof(contact.MailingCity);
                baseAddress.sRegion = string.valueof(contact.MailingState);
                baseAddress.sPostalCode = string.valueof(contact.MailingPostalCode);
                baseAddress.sCountry = string.valueof(contact.MailingCountry);
                baseAddress.sTaxRegionId = '0';
                listOfBaseAddress.add(baseAddress);
                objTaxation.listofClassBaseAddress = listOfBaseAddress;

            }
        }
        if(invoice != null){
            
            for(Invoice_Lines__c invoiceLines : invoice.Invoice_Lines__r){
                lineAddress = new ClassforCalculatingTax.ClassLines();
                lineAddress.sLineNo = string.valueof(invoiceLines.Name);
                lineAddress.sOriginCode = '0';
                lineAddress.sDestinationCode = '1';
                //lineAddress.sItemCode = 'N543'; 
                lineAddress.sTaxCode = invoiceLines.Tax_Code__c;
                lineAddress.dQty = invoiceLines.Quantity__c;
                lineAddress.dAmount = invoiceLines.Line_Amount__c;
                //lineAddress.bDiscounted = false; 
                //lineAddress.sDescription = 'Size 10 Green Running Shoe';
                listOfline.add(lineAddress);
                objTaxation.listofClassLines = listOfline;
            }
        }
        

        objTaxation.taxIntegrationObj = taxIntegration;
       
        ClassforCalculatingAvaTax objClassforCalculatingAvaTax = new ClassforCalculatingAvaTax();
        objTaxation = objClassforCalculatingAvaTax.getTax(objTaxation);
        
        return objTaxation;
    }

    //We are not using this method, as we are using 'getTaxForInvoice' method to get and commit the tax
    global static ClassTaxParameters postTaxForInvoice(Tax_Integration__c taxIntegration, Invoice__c invoice,Decimal taxamount){
        ClassforCalculatingTax.ClassTaxParameters objTaxation = new ClassforCalculatingTax.ClassTaxParameters();
        objTaxation.taxIntegrationObj = taxIntegration;
        //framing data for post tax
        objTaxation.sDocType = 'SalesInvoice';
        objTaxation.sDocCode = invoice.Name;
        objTaxation.sCustomerCode = invoice.Name;
        objTaxation.sDocDate = string.valueof(invoice.Invoice_Date__c);
        objTaxation.dTotalAmount = invoice.Amount__c;
        objTaxation.dTotalTax = taxamount;
        
        ClassforCalculatingAvaTax objClassforCalculatingAvaTax = new ClassforCalculatingAvaTax();
        objTaxation = objClassforCalculatingAvaTax.postTax(objTaxation);
    
        return objTaxation;
    }
    global static ClassTaxParameters cancelTaxForInvoice(Tax_Integration__c taxIntegration, Invoice__c invoice){
        
        ClassforCalculatingTax.ClassTaxParameters objTaxation = new ClassforCalculatingTax.ClassTaxParameters();
        objTaxation.taxIntegrationObj = taxIntegration;

        //framing data for cancel tax
        objTaxation.sDocType = 'SalesInvoice';
        objTaxation.sDocCode = invoice.Name;
        objTaxation.sCancelCode  = 'DocVoided';
   
        ClassforCalculatingAvaTax objClassforCalculatingAvaTax = new ClassforCalculatingAvaTax();
        objTaxation = objClassforCalculatingAvaTax.cancelTax(objTaxation);
       
        return objTaxation;
    }
    global static ClassTaxParameters getTaxForOrder(Tax_Integration__c taxIntegration, string sObjectId){

        String sPrefix = CommonUtilClassForTaxation.getPrefix();
        string sObjectQuery = 'SELECT '+ CommonUtilClassForTaxation.getObjectFields(sPrefix+'Job__c')
                            + ', (SELECT Order__r.Sub_Total__c,' + CommonUtilClassForTaxation.getObjectFields(sPrefix+'Job_Rate_Plan_Charge__c') +  'FROM Order_Rate_Plan_Charges__r ) '
                            + ',CurrencyL__r.Name '
                            + 'FROM Job__c '
                            + 'WHERE Id =' + '\'' + sObjectId + '\'';

        sObjectQuery = String.escapeSingleQuotes(sObjectQuery);
        sObjectQuery = sObjectQuery.replace('\\', '');
   
        Job__c order = Database.query(sObjectQuery);
        Account account;
        String sTaxCalculationBasedOn = Configuration__c.getValues(CommonUtilClassForTaxation.TAX_CALCULATION_BASED_ON).String_Value__c;
        if(sTaxCalculationBasedOn != null ||  sTaxCalculationBasedOn == CommonUtilClassForTaxation.ACCOUNT_BILLING_ADDRESS || sTaxCalculationBasedOn == CommonUtilClassForTaxation.ACCOUNT_SHIPPING_ADDRESS){ 
                account = (Account) CommonUtilClassForTaxation.getSobjectById(CommonUtilClassForTaxation.OBJECT_NAME_ACCOUNT, order.Account__c);
        }

        ClassforCalculatingTax.ClassTaxParameters objTaxation = new ClassforCalculatingTax.ClassTaxParameters();
        objTaxation.sDocType = 'SalesInvoice';
        objTaxation.sDocCode = order.Name;
        objTaxation.sCustomerCode = order.Name;
        objTaxation.sDocDate = string.valueof(order.Service_Activation_Date__c);
        objTaxation.dDiscount = order.Discount_Value__c;
        objTaxation.sOriginCode = '0';
        objTaxation.sDestinationCode = '1';
        objTaxation.sCurrencyCode = order.CurrencyL__r.Name;
        objTaxation.sPaymentDate = string.valueof(order.Service_Activation_Date__c);
        objTaxation.dExchangeRate = order.Exchange_Rate_Applied__c;

        objTaxation.listOfOrderLinesToUpdate = order.Order_Rate_Plan_Charges__r;
     
        list<ClassforCalculatingTax.ClassBaseAddress> listOfBaseAddress = new list<ClassforCalculatingTax.ClassBaseAddress>();
        ClassforCalculatingTax.ClassBaseAddress baseAddress = new ClassforCalculatingTax.ClassBaseAddress();
        list<ClassforCalculatingTax.ClassLines> listOfline = new list<ClassforCalculatingTax.ClassLines>();
        ClassforCalculatingTax.ClassLines lineAddress; 
        
        //Framing data
        if(sTaxCalculationBasedOn == CommonUtilClassForTaxation.ACCOUNT_BILLING_ADDRESS){  
            if(account != null){
                baseAddress.sAddressCode = '0';
                baseAddress.sLine1 = string.valueof(account.BillingStreet);
                baseAddress.scity = string.valueof(account.BillingCity);
                baseAddress.sRegion = string.valueof(account.BillingState);
                baseAddress.sPostalCode = string.valueof(account.BillingPostalCode);
                baseAddress.sCountry = string.valueof(account.BillingCountry);
                baseAddress.sTaxRegionId = '0';
                listOfBaseAddress.add(baseAddress);
                objTaxation.listofClassBaseAddress = listOfBaseAddress;
                
            }
        }else if(sTaxCalculationBasedOn == CommonUtilClassForTaxation.ACCOUNT_SHIPPING_ADDRESS){  
            if(account != null){
                baseAddress.sAddressCode = '0';
                baseAddress.sLine1 = string.valueof(account.ShippingStreet);
                baseAddress.scity = string.valueof(account.ShippingCity);
                baseAddress.sRegion = string.valueof(account.ShippingState);
                baseAddress.sPostalCode = string.valueof(account.ShippingPostalCode);
                baseAddress.sCountry = string.valueof(account.ShippingCountry);
                baseAddress.sTaxRegionId = '0';
                listOfBaseAddress.add(baseAddress);
                objTaxation.listofClassBaseAddress = listOfBaseAddress;
            }
        }else if(sTaxCalculationBasedOn == CommonUtilClassForTaxation.CONTACT_TYPE_BILLING && order.Billing_Contact__c != null)
        {
            Contact contact = [SELECT MailingStreet,MailingCountry, MailingCity, MailingState, MailingPostalCode
                              FROM Contact
                              WHERE Id = :order.Billing_Contact__c];
            if(contact != null){
                baseAddress.sAddressCode = '0';
                baseAddress.sLine1 = string.valueof(contact.MailingStreet);
                baseAddress.scity = string.valueof(contact.MailingCity);
                baseAddress.sRegion = string.valueof(contact.MailingState);
                baseAddress.sPostalCode = string.valueof(contact.MailingPostalCode);
                baseAddress.sCountry = string.valueof(contact.MailingCountry);
                baseAddress.sTaxRegionId = '0';
                listOfBaseAddress.add(baseAddress);
                objTaxation.listofClassBaseAddress = listOfBaseAddress;

            }
        }
        else if(sTaxCalculationBasedOn == CommonUtilClassForTaxation.CONTACT_TYPE_SHIPPING && order.Shipping_Contact__c != null)
        {
            Contact contact = [SELECT MailingStreet,MailingCountry, MailingCity, MailingState, MailingPostalCode
                                      FROM Contact
                                      WHERE Id = :order.Shipping_Contact__c];
            if(contact != null){
                baseAddress.sAddressCode = '0';
                baseAddress.sLine1 = string.valueof(contact.MailingStreet);
                baseAddress.scity = string.valueof(contact.MailingCity);
                baseAddress.sRegion = string.valueof(contact.MailingState);
                baseAddress.sPostalCode = string.valueof(contact.MailingPostalCode);
                baseAddress.sCountry = string.valueof(contact.MailingCountry);
                baseAddress.sTaxRegionId = '0';
                listOfBaseAddress.add(baseAddress);
                objTaxation.listofClassBaseAddress = listOfBaseAddress;

            }
        }
        if(order != null){
            
            for(Job_Rate_Plan_Charge__c orderRatePlanCharges : order.Order_Rate_Plan_Charges__r){
                lineAddress = new ClassforCalculatingTax.ClassLines();
                lineAddress.sLineNo = string.valueof(orderRatePlanCharges.Name);
                lineAddress.sOriginCode = '0';
                lineAddress.sDestinationCode = '1';
                //lineAddress.sItemCode = 'N543'; 
                lineAddress.sTaxCode = orderRatePlanCharges.Tax_Code__c;
                lineAddress.dQty = orderRatePlanCharges.Quantity__c;
                lineAddress.dAmount = orderRatePlanCharges.Price__c;
                //lineAddress.bDiscounted = false; 
                //lineAddress.sDescription = 'Size 10 Green Running Shoe';
                listOfline.add(lineAddress);
                objTaxation.listofClassLines = listOfline;
            }
        }
       
   
        objTaxation.taxIntegrationObj = taxIntegration;
       
        ClassforCalculatingAvaTax objClassforCalculatingAvaTax = new ClassforCalculatingAvaTax();
        objTaxation = objClassforCalculatingAvaTax.getTax(objTaxation);
        
        return objTaxation;
    }
    // Class to hold the baseaddress 
    global class ClassBaseAddress {
        global string sAddressCode;
        global string sLine1;
        global string sLine2;
        global string scity;
        global string sRegion;
        global string sPostalCode;
        global string sCountry;
        global string sTaxRegionId;
    }
    // Class to hold the line items.
    global class ClassLines {
        global string sLineNo; 
        global string sOriginCode;
        global string sDestinationCode;
        global string sItemCode;
        global string sTaxCode;
        global decimal dQty;
        global decimal dAmount;
        global boolean bDiscounted;
        global string sDescription;
    }

    global class ClassTaxParameters{
        //Variables to hold the document level values
        global string sTaxType;
        global string sDocType;
        global string sDocCode;
        global string sCustomerCode;
        global string sDocDate;
        global decimal dDiscount;
        global string sOriginCode;
        global string sDestinationCode;
        global string sCurrencyCode;
        global string sPaymentDate;
        global decimal dExchangeRate;
        global string sExchangeRateEffDate;
        global decimal dTotalAmount;
        global decimal dTotalTax;
        global string sCancelCode;
        global Tax_Integration__c taxIntegrationObj;
        //variables to hold the staus of requrest and while retuning values
        global string sMessage;
        global string sDocId;
        global string sDocStatus;
        global string sTransactionId;
        global string sSummary;
        global string sDetails;
        global boolean isSuccess;
        
        global decimal calculatedTax; 
        global list<ClassBaseAddress> listofClassBaseAddress;
        global list<ClassLines> listofClassLines;

        public list<Invoice_Lines__c> listOfInvoiceLinesToUpdate;
        public list<Job_Rate_Plan_Charge__c> listOfOrderLinesToUpdate;


    }
}