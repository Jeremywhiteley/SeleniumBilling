public with sharing class QuoteCreationUtil {
      // This method Returns all the rate plan charges for the specific rate plan.  @return ratePlanCharges
         public static string sPrefix = CommonUtilClass.getPrefix();
        public static list<Product_Rate_Plan_Charge__c> getProductRatePlanCharges(String ratePlanId, Id currencyId, map<String,String> searchMap) 
        {
            String searchString = '';
            if(searchMap != null && !searchMap.isEmpty()) {
                for(String field : searchMap.keySet()) {
                    String value = searchMap.get(field);
                    searchString = searchString + ' and '+ field +' = \'' + value + '\'';
                }
            }
            if(currencyId == null) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.WARNING,system.Label.Currency_NotSelected_Quote);
                Apexpages.addMessage(errorMessage);
                return null;
            }
            else {
                string sQuery ='SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Product_Rate_Plan_Charge__c')
                + ', (SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Product_Rate_Plan_Charge_Tier__c') +  'FROM Product_Rate_Plan_Charge_Tiers__r ORDER BY Start_Unit__c) '
                + ',Product_Rate_Plan__r.Product__r.Id,Product_Rate_Plan__r.Name,Product_Rate_Plan__r.Product__r.Product_Code__c, Product_Rate_Plan__r.Product__r.Name'               
                + ' from Product_Rate_Plan_Charge__c '
                + ' where Product_Rate_Plan__c =' + '\''+ String.escapeSingleQuotes(ratePlanId) + '\'' + ' '
                + ' and CurrencyL__c=' + '\''+ String.escapeSingleQuotes(currencyId) + '\'' + ' '
                + searchString
                + + 'order by Charge_Sequence_Number__c';
                Product_Rate_Plan_Charge__c[] ratePlanCharges = Database.query(sQuery);
                return ratePlanCharges;
            }
        }

        public static Product_Rate_Plan__c getProductRatePlanFromList(List<Product_Rate_Plan__c> listOfProductRatePlans,String selectedRatePlanId) 
        {
            if(listOfProductRatePlans != null) {
                for(Product_Rate_Plan__c productrateplan : listOfProductRatePlans ) {
                    if(selectedRatePlanId == productrateplan.Id) {
                        return productrateplan;
                    }
                }
            }       
            return null;
        }

       //This method Returns all the rate plans for the specific product.  @return ratePlans
        public static List<Product_Rate_Plan__c> getProductRatePlans(String productId, Date validCheckDate, map<String,String> searchMap) 
        {
            String searchString = '';
            if(searchMap != null && !searchMap.isEmpty()) {
                for(String field : searchMap.keySet()) {
                    String value = searchMap.get(field);
                    searchString = searchString + ' and '+field+' = \'' + value + '\'';
                }
            }
            string quoteProductId ='\''+ String.escapeSingleQuotes(productId) + '\'' + ' ';
            string sQuery ='SELECT Product__r.Name,' + CommonUtilClass.getObjectFields(sPrefix+'Product_Rate_Plan__c')
            + ' From Product_Rate_Plan__c'
            + ' where Product__c=' + quoteProductId 
            + searchString 
            + ' and Valid_From_Date__c != null'
            + ' and (Valid_To_Date__c >= ' + CommonUtilClass.convertDateToString(validCheckDate)
            + ' Or Valid_To_Date__c = null ) ORDER BY '+sPrefix+'Occurrence__c DESC NULLS LAST';
            
            Product_Rate_Plan__c [] ratePlans = Database.query(sQuery);                                                                    
            return ratePlans;
        }

        
        public static Quote__c getQuote(Id id)
        {
            String query =  'SELECT CurrencyL__r.Name,' + CommonUtilClass.getObjectFields(sPrefix+'Quote__c') + ','; 
            query = query + ' Account__r.Customer_Class__c FROM Quote__c';
            query = query + ' WHERE Id =\'' + String.escapeSingleQuotes(id) +'\'';            
            Quote__c quote = Database.query(query);
            return quote;
        }

        public static List<Quote_Product__c> getListQuoteProducts(Id quoteId)
        {
            String queryString = CommonUtilClass.getObjectSelectQuery(sPrefix+'Quote_Product__c')+ 'where  Quote__c = \''+String.escapeSingleQuotes(quoteId) + '\' order by SequenceNumber__c';
            Quote_Product__c  [] quoteProducts=database.query(queryString);                                  
            return quoteproducts;
        }

        public static Map<Id,QuoteProductClass> getMapQuoteProducts(List<Quote_Product__c> listQuoteProducts)
        {
            map<Id,QuoteProductClass> mapQuoteProducts=new Map<Id,QuoteProductClass>();
            for(Quote_Product__c qp : listQuoteProducts )
            {
                QuoteProductClass quoteProductClass = new QuoteProductClass();
                quoteProductClass.quoteproduct = qp;

                mapQuoteProducts.put(qp.id,quoteProductClass);
            }
            return mapQuoteProducts;
        }

        public static List<Quote_Rate_Plan__c> getListQuoteRatePlans(List<Id> quoteProductIds)
        {
            if(quoteProductIds.size() > 0) {
                string sQuoteProductIds = CommonUtilClass.convertListOfIdsIntoString(quoteProductIds);
                String sQuery =  'SELECT Quote_Product__r.Product_Bundle__r.Bundle_Type__c,Quote_Product__r.Product_Bundle__r.Is_Quantity_Editable__c,Quote_Product__r.Product_Bundle__r.Revenue_Recognition_Rule__c,' + CommonUtilClass.getObjectFields(sPrefix+'Quote_Rate_Plan__c') + ',' 
                + '(SELECT Product_Bundle_Line__r.Is_Quantity_Editable__c,' + CommonUtilClass.getObjectFields(sPrefix+'Quote_Rate_Plan_Charge__c') +  'from Quote_Rate_Plan_Charge__r Order by Sequence_No__c)'
                + 'from Quote_Rate_Plan__c where Quote_Product__c IN (' + sQuoteProductIds  + ') Order By Quote_Rate_Plan__c.Quote_Product__r.SequenceNumber__c,SequenceNumber__c';

                Quote_Rate_Plan__c [] quoteRatePlans = Database.query(sQuery);
                return quoteRatePlans;
            }
            else {
                return null;  
            }
        }

        public static Quote_Rate_Plan__c getquoteRatePlanToDelete(Id quoteRatePlanId)
        {
            String queryString = CommonUtilClass.getObjectSelectQuery(sPrefix+'Quote_Rate_Plan__c')+ 'where Id = \'' + String.escapeSingleQuotes(quoteRatePlanId) + '\'';
            Quote_Rate_Plan__c  quoteRatePlan=database.query(queryString);
            return quoteRatePlan;
        }

        public static Product__c getProduct(string selectedProductId)
        {
            String sQuery = CommonUtilClass.getObjectSelectQuery(sPrefix+'Product__c') + ' where Id =' + '\'' + String.escapeSingleQuotes(selectedProductId) + '\'';
            Product__c product = Database.query(sQuery);
            return product;
        } 
        
        //this is new method and not yet used
        //above method(i.e. getListOfDiscounts) is modified as below
        public static list<Discount_Code__c> getListOfDiscounts(string discountCode, QuoteClass quoteClass)
        {
            //no need to check account id here because i have handled in controller
            list<Discount_Code__c> listOfDiscounts = new list<Discount_Code__c>();
            Account account = [SELECT Customer_Class__c
                               FROM Account
                               WHERE Id =: quoteClass.quote.Account__c];
                               
            listOfDiscounts = [SELECT Name, Apply_to__c, Discount_Percent__c, Discount_Value__c, Price_Type__c, Product_Family__c 
                               FROM Discount_Code__c
                               WHERE Name =: discountCode 
                               AND 
                                    Currency__c =: quoteClass.quote.CurrencyL__c
                               And
                                    (Customer_Class__c Includes (:account.Customer_Class__c) OR Customer_Class__c Includes ('*'))
                               And
                                    Valid_From__c <=: system.today()
                               AND 
                                    (Valid_To__c >=: system.today() OR Valid_To__c = null)];
            
            return  listOfDiscounts;
        }
        
        public static list<Optional_Extra__c> getListOfOptionalExtrasForQuote(Id quoteId)
        {
            return [SELECT Name, Currency__c, Invoice_IT_Product__c, Product_Rate_Plan__c, Product_Rate_Plan_Charge__c
                    FROM Optional_Extra__c
                    WHERE Quote__c =: quoteId];
        }
        
        public static void tieredPricing(QuoteRatePlanChargeClass quoteChargeClass) 
        {
            Quote_Rate_Plan_Charge__c quoteRatePlanCharge = quoteChargeClass.quoterateplancharge;
            if(quoteRatePlanCharge.Quantity__c > 0) {
                
                integer quantityCalculated = 0;
                decimal usageAmount = 0;
                decimal costPrice = 0;
                integer remaningUsage = integer.ValueOf(quoteRatePlanCharge.Quantity__c);
                integer usageQuantity = integer.ValueOf(quoteRatePlanCharge.Quantity__c);
                boolean isTierExists = false;
                integer iSize;
                
                list<QuoteRatePlanChargeTierClass> tempTiers = quoteChargeClass.quoteRatePlanChargeTiers; 
                QuoteRatePlanChargeTierClass quoteTierClass; 
                Quote_Rate_Plan_Charge_Tier__c productChargeTier;
                iSize = tempTiers.Size();
                for(integer i = 0; i < iSize; i++) {
                    quoteTierClass = tempTiers[i];
                    productChargeTier = quoteTierClass.quoteRatePlanChargeTier;
                    if(usageQuantity >=  productChargeTier.Start_Unit__c) {
                        isTierExists = true;
                        integer diff;
                        
                        if(productChargeTier.End_Unit__c != null){
                            diff = integer.ValueOf(productChargeTier.End_Unit__c - productChargeTier.Start_Unit__c + 1);
                        }else{
                            diff = remaningUsage;
                        }
                        
                        if(remaningUsage <= diff) {
                            //calculate the sp
                            usageAmount +=  (decimal) (remaningUsage * productChargeTier.Unit_Price__c);
                            //calculate the cp
                            if(productChargeTier.Unit_Cost_Price__c != null && productChargeTier.Unit_Cost_Price__c > 0) {
                                costPrice +=  (decimal) (remaningUsage * productChargeTier.Unit_Cost_Price__c);
                            }
                        } else {
                            //calculate the sp
                            usageAmount +=  (decimal) (diff * productChargeTier.Unit_Price__c); 
                            //calculate the cp
                            if(productChargeTier.Unit_Cost_Price__c != null && productChargeTier.Unit_Cost_Price__c > 0) {
                                costPrice +=  (decimal) (diff * productChargeTier.Unit_Cost_Price__c); 
                            }
                        }
                        remaningUsage = remaningUsage - diff;
        
                        //this means it has reached end tier and remaning Usage is still present
                        if(i == tempTiers.Size() - 1 && remaningUsage > 0) {
                            //calculate the sp
                            usageAmount += (remaningUsage * productChargeTier.Unit_Price__c);
                            //calculate the cp
                            if(productChargeTier.Unit_Cost_Price__c != null && productChargeTier.Unit_Cost_Price__c > 0) {
                                costPrice +=  (remaningUsage * productChargeTier.Unit_Cost_Price__c);
                            }
                        }
                   }
                   
                   if(i == (iSize - 1) && !isTierExists) {
                        Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.WARNING,system.Label.Tieredlimit));
                   }
                }
                
                quoteRatePlanCharge.Price__c = usageAmount;
                quoteRatePlanCharge.Cost__c = costPrice;
                quoteRatePlanCharge.Cost_Price__c = costPrice/quoteRatePlanCharge.Quantity__c;
                quoteRatePlanCharge.Unit_Price__c = usageAmount/quoteRatePlanCharge.Quantity__c;
            } else {
                quoteRatePlanCharge.Cost_Price__c = 0;
                quoteRatePlanCharge.Unit_Price__c = 0;
                quoteRatePlanCharge.Price__c = 0;
            }
        }
        
        /*
            Modified By         : Devender M: 04 June 2013:  INVOICEIT-175
            Comments         : Previously discount was included in Total Contract Value, so i have subtracted the discount value.
                                         Used nettotal for calculating the Total Contract Value
        */
        //This is used for the TCV calculation
        public static decimal calculateQuoteChargeLineAmount(Quote_Rate_Plan_Charge__c charge,Date startDate, Date endDate) 
        {   
            // The end date and start date are dummy dates which are not used, only for calculation purpose BY Dev M
            //date endDate = system.today().addMonths(integer.valueof(noOfMonths));
            decimal noOfTimesCharge = InvoicingUtilClass.calculateDiffBetweenDatesInMonths(startDate, endDate.addDays(1), charge.Price_Type__c);
            
            if(charge.Price_Type__c == system.Label.OptionOneTime) {
                return (charge.Net_Total__c);
            } else if(charge.Price_Type__c == system.Label.OptionWeekly) {
                decimal noOfDays = startDate.daysBetween(endDate); 
                decimal noOfWeeks = noOfDays.Divide(7,3,System.RoundingMode.UP);
                return (noOfWeeks * charge.Net_Total__c);
            }  else {
                return (noOfTimesCharge*charge.Net_Total__c);
            }
        
            return 0;
        }
        
        public static map<Id, list<Quote_Rate_Plan_Charge_Tier__c>> queryTiersBasedOnQuoteId(string quoteId) 
        {
            map<Id, list<Quote_Rate_Plan_Charge_Tier__c>> map_QuoteCharge_QuoteTier = new map<Id, list<Quote_Rate_Plan_Charge_Tier__c>>();
            
            String sQuery = CommonUtilClass.getObjectSelectQuery(sPrefix+'Quote_Rate_Plan_Charge_Tier__c');
            sQuery = sQuery + ' WHERE Quote_Rate_Plan_Charge__r.Quote_Rate_Plan__r.Quote_Product__r.Quote__c =\'' + String.escapeSingleQuotes(quoteId) + '\' ORDER BY Start_Unit__c';
            list<Quote_Rate_Plan_Charge_Tier__c> quoteTiers = Database.query(sQuery);
            
            list<Quote_Rate_Plan_Charge_Tier__c> quoteTiersLocalVar;
            for(Quote_Rate_Plan_Charge_Tier__c quoteTier : quoteTiers) {
                if(map_QuoteCharge_QuoteTier.containsKey(quoteTier.Quote_Rate_Plan_Charge__c)) {
                    quoteTiersLocalVar = map_QuoteCharge_QuoteTier.get(quoteTier.Quote_Rate_Plan_Charge__c);
                } else {
                    quoteTiersLocalVar = new list<Quote_Rate_Plan_Charge_Tier__c>();
                }
                
                quoteTiersLocalVar.add(quoteTier);
                map_QuoteCharge_QuoteTier.put(quoteTier.Quote_Rate_Plan_Charge__c, quoteTiersLocalVar);
            }
            
            return map_QuoteCharge_QuoteTier;
        }
        
        public static map<String, string> getObjectApis(String objectName) {
            map<String, string> apiNames = new map<String, string>();
            string column;
            Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            for(Schema.SObjectField sObjectField: objectFieldMap.values()) {
                column = string.ValueOf(sObjectField);
                if(!column.contains(sPrefix) && sObjectField.getDescribe().isCreateable() && column.contains('__c')) {
                    apiNames.put(sObjectField.getDescribe().getLabel(), column);
                }
            }
            return apiNames;
        }
        
        public static list<SelectOption> getListOfCurreciesOptions(string currentCurrecyId) 
        {
            list<SelectOption> currecyOptions = new list<SelectOption>();
            for(Currency__c c : [SELECT Name, Currency_Symbol__c FROM Currency__c WHERE Id !=: currentCurrecyId]) {
                currecyOptions.add(new SelectOption(c.Id + ':' + c.Name + ':' + c.Currency_Symbol__c, c.Name));
            }
            
            return currecyOptions;
        }
        
        public static void populateExchangeRateOnQuote(Quote__c quote, string isoCode) {
            sobject datedConversionRate = CommonUtilClass.getExchangeRateByDate(quote.Valid_To__c, isoCode);
            
            if(datedConversionRate != null) {
                sobject sobjectQuote = (sobject)quote;
                sobjectQuote.put(sPrefix+'Exchange_Rate_Applied__c',(decimal) datedConversionRate.get('ConversionRate'));
                sobjectQuote.put('CurrencyIsoCode',(string) isoCode);
                quote = (Quote__c) sobjectQuote;
            } else {
                quote.Exchange_Rate_Applied__c = 1;
            }   
        }
    }