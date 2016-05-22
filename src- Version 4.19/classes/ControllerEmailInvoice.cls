public with sharing class ControllerEmailInvoice {
      
      public String sLogo {get; set;}
      public String sInvoiceId {set; get;}
      public String sPrefix = CommonUtilClass.getPrefix();
      public string sInvoiceObjId;

      public Invoice__c invoice { 
          set; 
          get {
              if(sInvoiceId != null) {
                  // Addeb for security scan results check
                  sInvoiceObjId = '\''+ String.escapeSingleQuotes(sInvoiceId) + '\'';
                  string sQuery = 'SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Invoice__c')
                                  + ',CurrencyL__r.Name,CurrencyL__r.Currency_Symbol__c,Account__r.VAT_No__c,'
                                  + 'Shipping_Contact__r.Name, Shipping_Contact__r.MailingStreet, Shipping_Contact__r.MailingCity, Shipping_Contact__r.MailingState , Shipping_Contact__r.MailingCountry, Shipping_Contact__r.MailingPostalCode,  Shipping_Contact__r.Salutation ,'
                                  + 'Billing_Contact__r.Name, Billing_Contact__r.MailingStreet, Billing_Contact__r.MailingCity, Billing_Contact__r.MailingState , Billing_Contact__r.MailingCountry, Billing_Contact__r.MailingPostalCode, Billing_Contact__r.Salutation, '
                                  + 'Order__r.Name'
                                  + ' FROM Invoice__c '
                                  + ' WHERE Id =' + sInvoiceObjId + ' ';
                  invoice = Database.query(sQuery); 
                  list<StaticResource> listOfStaticResources = [SELECT Id,SystemModstamp 
                                                                FROM StaticResource 
                                                                WHERE Name = 'logo'];
                  if(!listOfStaticResources.isEmpty()) {
                      sLogo = '/resource/'+listOfStaticResources[0].SystemModStamp.getTime()+'/logo';
                  } else {
                      sLogo = (Configuration__c.getValues('COMPANY_LOGO').String_Value__c);
                  }
               }           
              return invoice;         
          }
      }

      public list<Invoice_Lines__c> listOfInvoiceLines {
          get {
                string sQuery = 'SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Invoice_Lines__c')
                              + ',Job_Rate_Plan_Charge__r.Price_Type__c, Job__r.Service_Activation_Date__c, Job__r.Service_End_Date__c, Job__r.Name'
                              + ' FROM Invoice_Lines__c '
                              + ' WHERE Invoice__c =' + sInvoiceObjId + ' '
                              + 'ORDER BY Sequence_No__c';
                return Database.query(sQuery);                
               }
      }
      
      public list<Usage_Charge__c> listOfUsageLines {
          get {
                string sQuery = 'SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Usage_Charge__c')
                              + ',Invoice_Line__r.Name'
                              + ' FROM Usage_Charge__c '
                              + ' WHERE Invoice__c =' + sInvoiceObjId + ' '
                              + 'ORDER BY Invoice_Line__r.Sequence_No__c';
                return Database.query(sQuery);                
               }
      }
  }