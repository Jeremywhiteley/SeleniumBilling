public with sharing class ControllerSendQuote {
      public Quote__c quote {get;set;}
      public List<Quote_Product__c> listQuoteProducts = new List<Quote_Product__c>();
      public list<Quote_Rate_Plan_Charge__c> listQuoteRatePlanCharge {get;set;}
      public list<Optional_Extra__c> listOptionalExtra {get;set;}
      public Integer iCountOfOptionalExtra {get;set;}
      public string sLogo {set; get;}
      private map<Id,QuoteProductClass> mapQuoteProducts = new  map<Id,QuoteProductClass>();
      public list<Quote_Rate_Plan__c> listQuoteRatePlans = new  list<Quote_Rate_Plan__c>();
      public Boolean isOtherCharge{get;set;}
      public Boolean isOneTimeCharge{get;set;}
      public Boolean isMonthlyCharge{get;set;}
      public QuoteClass quoteClass {get;set;}
      public QuoteProductClass quoteProductClass {get;set;}
      public QuoteRatePlanClass quoteRatePlanClass {get;set;}
      public QuoteRatePlanChargeClass quoteRatePlanChargeClass = new QuoteRatePlanChargeClass();
      public decimal sumOfNetTotalOneTime {get;set;}
      public decimal sumOfSubTotalOneTime {get;set;}
      public decimal sumOfNetTotalMonthly {get;set;}
      public decimal sumOfSubTotalMonthly {get;set;}
      public decimal sumOfNetTotalOther {get;set;}
      public decimal sumOfSubTotalOther {get;set;}
      public String sPrefix {get; set;}      
      public ControllerSendQuote(ApexPages.StandardController stdController) {
      sPrefix = CommonUtilClass.getPrefix();
          this.quote = (Quote__c)stdController.getRecord();
          isOtherCharge = false;
          isOneTimeCharge = false;
          isMonthlyCharge = false;
          quoteClass = new QuoteClass();
          quoteClass.quote = quote;
          if(quote.id != null) {
              this.quote = QuoteCreationUtil.getQuote(quote.id);           
              listQuoteProducts = QuoteCreationUtil.getListQuoteProducts(quote.id);
              //add listQuoteProducts to quoteProductClass
              for(Quote_Product__c qp : listQuoteProducts) {
                  quoteProductClass = new QuoteProductClass();
                  quoteProductClass.quoteproduct = qp;
                  quoteClass.quoteProducts.add(quoteProductClass);
              }
              //get the list of quoteProduct Ids in to Map
              mapQuoteProducts = QuoteCreationUtil.getMapQuoteProducts(listQuoteProducts);
              Set<Id> mapQuoteProductKeyset = new Set<Id>();
              mapQuoteProductKeyset = mapQuoteProducts.keySet();
              List<Id> quoteProductIds = new List<Id>();
              Integer mapQuoteProductKeysetSize = mapQuoteProductKeyset.size();
              quoteProductIds.addAll(mapQuoteProductKeyset);
              listQuoteRatePlans = QuoteCreationUtil.getListQuoteRatePlans(quoteProductIds);
              if(listQuoteRatePlans != null ){
                  for(Quote_Rate_Plan__c qr : listQuoteRatePlans ) {
                      quoteProductClass = mapQuoteProducts.get(qr.Quote_Product__c);
                      quoteRatePlanClass = new QuoteRatePlanClass();
                      quoteRatePlanClass.quoterateplan = qr;
                      for(Quote_Rate_Plan_Charge__c qrpc : qr.Quote_Rate_Plan_Charge__r) {
                          quoteRatePlanChargeClass = new QuoteRatePlanChargeClass();
                          quoteRatePlanChargeClass.quoterateplancharge = qrpc;
                          quoteRatePlanClass.quoteRatePlanCharges.add(quoteRatePlanChargeClass);
                      }
                      quoteProductClass.quoteRatePlans.add(quoteRatePlanClass);
                      mapQuoteProducts.remove(qr.Quote_Product__c);
                      mapQuoteProducts.put(qr.Quote_Product__c,quoteProductClass);
                  }
                  quoteClass = new QuoteClass();
                  quoteClass.quote = quote;
                  for(QuoteProductClass qpc : mapQuoteProducts.values()) {
                      quoteClass.quoteProducts.add(qpc);
                  }                
              } 
          }
          
          /* Modified By     : Asish Behera:  25 Sept 2013: INVOICEIT-229
              Comments     : to print logo.  
          */ 
          list<StaticResource> listOfStaticResources = [SELECT Id,SystemModstamp FROM StaticResource WHERE Name = 'logo'];
          if(!listOfStaticResources.isEmpty()) {
              
             sLogo = '/resource/'+listOfStaticResources[0].SystemModStamp.getTime()+'/logo';
          } else {
              sLogo = (Configuration__c.getValues('COMPANY_LOGO').String_Value__c);
          }

          listQuoteProducts = QuoteCreationUtil.getListQuoteProducts(quote.id);

          string sQuery = 'SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Quote_Rate_Plan_Charge__c') + ',' 
                          + 'Quote_Rate_Plan__r.Quote_Product__r.name,Quote_Rate_Plan__r.SequenceNumber__c,Quote_Rate_Plan__r.Quote_Product__r.SequenceNumber__c,Quote_Rate_Plan__r.Quote_Product__r.Product_Code__c'
                          + ' FROM Quote_Rate_Plan_Charge__c where Quote_Rate_Plan__r.Quote_Product__c IN : listQuoteProducts Order By Quote_Rate_Plan__r.Quote_Product__r.SequenceNumber__c,Sequence_No__c,Quote_Rate_Plan__r.SequenceNumber__c';                
          sQuery = String.escapeSingleQuotes(sQuery);
          listQuoteRatePlanCharge = Database.query(sQuery);
          string sQueryOptional = 'SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Optional_Extra__c')
                                  + ', Product_Rate_Plan_Charge__r.CurrencyL__r.Currency_Symbol__c'
                                  + ' From Optional_Extra__c'
                                  + ' Where Quote__c = ' + '\'' + String.escapeSingleQuotes(quote.id) + '\'';
          listOptionalExtra = Database.query(sQueryOptional);
          iCountOfOptionalExtra = listOptionalExtra.Size();
          
          //checking is there any other charge except one time or monthly
          list<Quote_Rate_Plan_Charge__c> listofOtherChargesExceptMonthandOne;
          listofOtherChargesExceptMonthandOne = [SELECT id,Name, Quote_Rate_Plan__c,Price_Type__c,Quote__c
                                                 FROM Quote_Rate_Plan_Charge__c
                                                 WHERE Quote__c = :quote.id AND (Price_Type__c !='One Time' AND Price_Type__c !='Monthly')];
         
          //checking for One time Charge
          list<Quote_Rate_Plan_Charge__c> listofOtherChargesOneTime;
          listofOtherChargesOneTime = [SELECT id,Name, Quote_Rate_Plan__c,Price_Type__c,Quote__c
                                                 FROM Quote_Rate_Plan_Charge__c
                                                 WHERE Quote__c = :quote.id AND Price_Type__c = 'One Time'];
          
          //checking for Monthly Charge
          list<Quote_Rate_Plan_Charge__c> listofOtherChargesExceptMonthly;
          listofOtherChargesExceptMonthly = [SELECT id,Name, Quote_Rate_Plan__c,Price_Type__c,Quote__c
                                                 FROM Quote_Rate_Plan_Charge__c
                                                 WHERE Quote__c = :quote.id AND Price_Type__c ='Monthly'];
                                                 
         AggregateResult[] groupedResultsOfChargeOneTime = [SELECT sum(Net_Total__c) priceSum,sum(Price__c) subtotalSum,Quote_Rate_Plan__r.Quote_Product__r.Quote__c QuoteId 
                                                            FROM Quote_Rate_Plan_Charge__c 
                                                            WHERE Quote_Rate_Plan__r.Quote_Product__r.Quote__c = :quote.id
                                                            AND Price_Type__c = 'One Time'
                                                            GROUP BY Quote_Rate_Plan__r.Quote_Product__r.Quote__c
                                                            ];
         AggregateResult[] groupedResultsOfChargeMonthly = [SELECT sum(Net_Total__c) priceSum,sum(Price__c) subtotalSum,Quote_Rate_Plan__r.Quote_Product__r.Quote__c QuoteId 
                                                            FROM Quote_Rate_Plan_Charge__c 
                                                            WHERE Quote_Rate_Plan__r.Quote_Product__r.Quote__c = :quote.id
                                                            AND Price_Type__c ='Monthly'
                                                            GROUP BY Quote_Rate_Plan__r.Quote_Product__r.Quote__c
                                                            ];
         AggregateResult[] groupedResultsOfChargeOthers = [SELECT sum(Net_Total__c) priceSum,sum(Price__c) subtotalSum,Quote_Rate_Plan__r.Quote_Product__r.Quote__c QuoteId 
                                                            FROM Quote_Rate_Plan_Charge__c 
                                                            WHERE Quote_Rate_Plan__r.Quote_Product__r.Quote__c = :quote.id
                                                            AND (Price_Type__c !='One Time' AND Price_Type__c !='Monthly')
                                                            GROUP BY Quote_Rate_Plan__r.Quote_Product__r.Quote__c
                                                            ];                                                                                                      
          
         for(AggregateResult aggResult : groupedResultsOfChargeOneTime) {
                  sumOfNetTotalOneTime = (decimal) aggResult.get('priceSum');
                  sumOfSubTotalOneTime = (decimal) aggResult.get('subtotalSum');
         }
         
         for(AggregateResult aggResult : groupedResultsOfChargeMonthly) {
                  sumOfNetTotalMonthly = (decimal) aggResult.get('priceSum');
                  sumOfSubTotalMonthly = (decimal) aggResult.get('subtotalSum');
         }
         
         for(AggregateResult aggResult : groupedResultsOfChargeOthers) {
                  sumOfNetTotalOther = (decimal) aggResult.get('priceSum');
                  sumOfSubTotalOther = (decimal) aggResult.get('subtotalSum');
         }
         
         if(listofOtherChargesExceptMonthandOne.size() == 0){
             isOtherCharge = true;
         }
         
         if(listofOtherChargesOneTime.size() > 0){
             isOneTimeCharge = true;
         }
         
         if(listofOtherChargesExceptMonthly.size() > 0){
             isMonthlyCharge = true;
         }
      }
      
  }