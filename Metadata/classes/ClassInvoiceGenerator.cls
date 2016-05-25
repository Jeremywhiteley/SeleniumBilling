public with sharing class ClassInvoiceGenerator {

        public Invoice__c invoice { get; set; }
        public String sShippingContact { get; set; }
        public String sBillingContact { get; set; }

        list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
        String sInvoiceID = System.currentPageReference().getParameters().get('ID');

        public ClassInvoiceGenerator() {
            if(sInvoiceID != null) {
                invoice = [SELECT Name, Invoice_Date__c, Due_Date__c, CurrencyL__r.Name ,Billing_Contact__c ,VAT__c, Total_Invoice_Value__c ,Delivery_Type__c,
                           Shipping_Contact__r.MailingStreet,Shipping_Contact__r.MailingCity, Shipping_Contact__r.MailingCountry ,Shipping_Contact__r.MailingPostalCode,Shipping_Contact__r.MailingState,
                           Billing_Contact__r.MailingStreet,Billing_Contact__r.MailingCity, Billing_Contact__r.MailingCountry ,Billing_Contact__r.MailingPostalCode,Billing_Contact__r.MailingState      
                           FROM Invoice__c
                           WHERE id =: sInvoiceID];
                sShippingContact = invoice.Shipping_Contact__r.MailingStreet + '  '
                + invoice.Shipping_Contact__r.MailingCity + '  '
                + invoice.Shipping_Contact__r.MailingState + ' '
                + invoice.Shipping_Contact__r.MailingCountry + '  '
                + invoice.Shipping_Contact__r.MailingPostalCode;

                sBillingContact = invoice.Billing_Contact__r.MailingStreet + ' ' 
                + invoice.Billing_Contact__r.MailingCity + ' '
                + invoice.Billing_Contact__r.MailingState + ' '
                + invoice.Billing_Contact__r.MailingCountry + ' '
                + invoice.Billing_Contact__r.MailingPostalCode;
            }
        }               

        public List<Invoice_Lines__c> getListInvoiceLines() {
            listInvoiceLines = [SELECT VAT__c, Unit_Price__c, Total_Line_Amount__c, Quantity__c, Line_Name__c, Id 
                                FROM Invoice_Lines__c 
                                WHERE Invoice__c =: sInvoiceID];
            return  listInvoiceLines;               
        }
    }