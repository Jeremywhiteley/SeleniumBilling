public with sharing class ClassAfterOnQuote {

        public static String sPrefix = CommonUtilClass.getPrefix();
        //1 Roll up the TCV of Quote to TotalQuoteValue__c on Account, it is roll up summary field for calculating the sum of Quotes on Account, only based on certain status
        //2 Once the check box is true, convert the Quote into Order
        public void handleAfterOnQuote(map<Id,Quote__c> newMap, map<Id,Quote__c> oldMap)
        {
            String sStatusToMapQuoteToAmount = Configuration__c.getValues('QUOTE_STATUS_VALUES_TO_ROLLUP').String_Value__c;
            set<Id> setOfAccountIds = new set<Id>();

            //check if it is deleted or not
            if(Trigger.isDelete)
            {
                for(Quote__c quote : oldMap.values())
                {
                    if(quote.Account__c != null && !setOfAccountIds.contains(quote.Account__c) && sStatusToMapQuoteToAmount != null) {
                        setOfAccountIds.add(quote.Account__c);
                    }
                }
            }
            //added by Balachary InvoiceIT-657
            else{
            //it is a insert or update operation
            if(Trigger.isInsert || Trigger.isUndelete) {
                list<Quote__c> quotes = (list<Quote__c>) trigger.New;
                for(Quote__c newQuote : quotes) {
                    //quotes intrested for calculation the total contract value
                    if(newQuote.Account__c != null && !setOfAccountIds.contains(newQuote.Account__c)) {
                        setOfAccountIds.add(newQuote.Account__c);
                    }
                }
            }

            if(Trigger.isUpdate) {
                for(Quote__c newQuote : newMap.values())
                {

                    Quote__c oldQuote = oldMap.get(newQuote.Id);    
                    if( oldQuote.Total_Contract_Value__c != newQuote.Total_Contract_Value__c ||
                            oldQuote.Number_Of_Terms__c != newQuote.Number_Of_Terms__c || 
                            oldQuote.Account__c != newQuote.Account__c || 
                            oldQuote.Status__c != newQuote.Status__c) {

                        if(newQuote.Account__c != null && !setOfAccountIds.contains(newQuote.Account__c) && sStatusToMapQuoteToAmount != null) {
                            setOfAccountIds.add(newQuote.Account__c);
                        }
                        if(oldQuote.Account__c != null && !setOfAccountIds.contains(oldQuote.Account__c) && sStatusToMapQuoteToAmount != null) {
                            setOfAccountIds.add(oldQuote.Account__c);
                        }
                    }
                 
                 /*   Modified By     : Laxman Rao M: 05 June 2013: INVOICEIT-196 
                       Comments     : When ever the Create_Automatic_Order__c is true, we should create the order Create_Automatic_Order__c goes live in 2.16
                */    
                                if(newQuote.Create_Automatic_Order__c 
                            && newQuote.Create_Automatic_Order__c != oldQuote.Create_Automatic_Order__c)
                    {
                        try {
                            ApexPages.Standardcontroller stdController = new Apexpages.Standardcontroller(newQuote);
                            CreateQuoteController createQuoteController = new CreateQuoteController(stdController);
                            createQuoteController.convertQuote();
                            } catch(Exception ex) {
                            newQuote.addError(system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':' + ex.getLineNumber());
                        }  
                        
                    }
                }
                /*      Modified By     : Dev M: 31 Dec 2013: INVOICEIT-295
                        Comments      : Recalculate on Quote
                 */
                Quote__c quote = null;
                for(Quote__c newQuote : newMap.values())
                {
                    Quote__c oldQuote = oldMap.get(newQuote.Id);
                    try {
                        if(newQuote.Recalculate__c && newQuote.Recalculate__c != oldQuote.Recalculate__c) 
                        {
                            QuoteClass quoteClass = populateQuoteClass(newQuote.Id);  
                            
                            QuoteChargesCalculator.calculateCharges(quoteClass);
                            saveQuote(quoteClass);
                            break;
                        }
                    } catch(Exception ex) {
                        newQuote.addError(system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':' + ex.getLineNumber());
                    }       
                }    
            }
            }
         /*  Modified By : Laxman Rao M: Ref : INVOICEIT-317,
             here we are checking, if the current user has access to account record
             if the user does not have access then we will remove from the set(some account and opportunity will be have access as private)
             the reason why I am creating the listOfAccountIds is, query is not being executed if we use setOfAccountIds
          */ 
            list<Id> listOfAccountIds = new list<Id>();
            listOfAccountIds.addAll(setOfAccountIds);
            list<UserRecordAccess> listOfRecordAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =: UserInfo.getUserId() AND RecordId IN: listOfAccountIds];
        
            for(UserRecordAccess userRecordAccess : listOfRecordAccess) {
                if(!userRecordAccess.HasEditAccess) {
                    setOfAccountIds.remove(userRecordAccess.RecordId);      
                }   
            }
            
         /*  Now we have a setOfAccountIds and a listOfStatus
             Say we have 10 ids and we try to filter them based on the status and only 8 turn up, then those 8 should be aggregated. 
             The other 2 simply dont have any quote that have the valid status values and therefore will be zero total 
        */
            if(setOfAccountIds.size() > 0) {
                ClassAfterOnQuote.rollupTotalContractValueOnAccount(setOfAccountIds);
            }
        }
        public static void rollupTotalContractValueOnAccount(set<Id> setOfAccountIds) {
            String sStatusToMapQuoteToAmount = Configuration__c.getValues('QUOTE_STATUS_VALUES_TO_ROLLUP').String_Value__c;

            list<Account> listOfAccountsToUpdate = new list<Account>();
            list<String> listOfStatus = new list<String>();
            if(sStatusToMapQuoteToAmount != null) {
                listOfStatus = sStatusToMapQuoteToAmount.split(',');
            }

            //Query the sum(total) for all Quotes pertaining to these accounts
            AggregateResult[] results = [SELECT Account__c, SUM(Total_Contract_Value__c) totalContractValue
                                         FROM Quote__c 
                                         WHERE Account__c IN : setOfAccountIds
                                         AND 
                                         Status__c IN : listOfStatus
                                         GROUP BY Account__c];
            for(AggregateResult result : results) {
                Id accountId = (Id)result.get(sPrefix+'Account__c');
                Double dTotalContractValue = (Double)result.get('totalContractValue');
                Account account = new Account(Id = accountId, TotalQuoteValue__c = dTotalContractValue);
                listOfAccountsToUpdate.add(account);
                //Once this account is added for updation, remove them from the set
                setOfAccountIds.remove(accountId);
            }

            //Now the setofAccountIds will have only those accounts that have been missed and they should be updated with zero value
            for(Id accountId : setOfAccountIds) {
                Account account = new Account(Id = accountId, TotalQuoteValue__c = 0);
                listOfAccountsToUpdate.add(account);
            }

            if(listOfAccountsToUpdate.size() > 0) {
                update listOfAccountsToUpdate;
            }
        }

        // This is to populate the quoteclass and used in recaluation method
        public static QuoteClass populateQuoteClass(Id quoteId) { 
            Map<Id,QuoteProductClass> mapQuoteProducts = new  Map<Id,QuoteProductClass>();
            QuoteClass quoteClass = new QuoteClass();
            Integer quoteProductCounter = 0;
            Integer quoteRatePlanCounter = 0;
            Integer quoteRateplanChargeCounter = 0;
            Integer quoteRatePlanChargeTierCounter = 0;
            Integer iQuoteProductSequenceNo = 1;
            Integer iQuoteRatePlanSequenceNo = 1;
            List<Quote_Product__c> listQuoteProducts = new List<Quote_Product__c>();
            List<Quote_Rate_Plan__c> listQuoteRatePlans = new List<Quote_Rate_Plan__c>();
            QuoteProductClass quoteProductClass;
            QuoteRatePlanClass quoteRatePlanClass;
            QuoteRatePlanChargeClass quoteRatePlanChargeClass;
            quoteRatePlanChargeTierClass quoteTierClass;
            Quote__c quote = QuoteCreationUtil.getQuote(quoteId);
            quoteClass.quote = quote;
            listQuoteProducts = QuoteCreationUtil.getListQuoteProducts(quoteid);
            //add listQuoteProducts to quoteProductClass
            for(Quote_Product__c qp : listQuoteProducts) {
                quoteProductClass = new QuoteProductClass();
                quoteProductClass.quoteProductCounter = ++quoteProductCounter;
                quoteProductClass.quoteproduct = qp;
                quoteClass.quoteProducts.add(quoteProductClass);
            }
            //get the list of quoteProduct Ids in to Map
            mapQuoteProducts = QuoteCreationUtil.getMapQuoteProducts(listQuoteProducts);
            Set<Id> mapQuoteProductKeyset = new Set<Id>();
            mapQuoteProductKeyset = mapQuoteProducts.keySet();
            List<Id> quoteProductIds = new List<Id>();
            Integer mapQuoteProductKeysetSize = mapQuoteProductKeyset.size();

            //Add all the ids to list quoteProductIds
            quoteProductIds.addAll(mapQuoteProductKeyset);

            map<Id, list<Quote_Rate_Plan_Charge_Tier__c>> map_QuoteChargeId_QuoteTiers = QuoteCreationUtil.queryTiersBasedOnQuoteId(quote.Id);
            //getListQuoteRatePlans returns listQuoteRatePlans 
            listQuoteRatePlans = QuoteCreationUtil.getListQuoteRatePlans(quoteProductIds);
         decimal chargeQuantity = 0;
            if(listQuoteRatePlans != null) {
             
                //get the listJobRatePlanCharges from the listQuoteRatePlans 
                for(Quote_Rate_Plan__c qr:listQuoteRatePlans ) {
                    quoteProductClass = mapQuoteProducts.get(qr.Quote_Product__c);
                    quoteRatePlanClass = new QuoteRatePlanClass();
                    quoteRatePlanClass.quoterateplan = qr;

                    for(Quote_Rate_Plan_Charge__c qrpc : qr.Quote_Rate_Plan_Charge__r) {
                        quoteRatePlanChargeClass = new QuoteRatePlanChargeClass();
                        quoteRatePlanChargeClass.quoterateplancharge = qrpc;
                        quoteRatePlanChargeClass.quoteRatePlanChargeCounter = ++quoteRateplanChargeCounter;
                     
                        //add the tiers
                        if(map_QuoteChargeId_QuoteTiers.containsKey(qrpc.Id)) {
                        //added by Balachary InvoiceIT-657
                        if(quoteRatePlanChargeClass.quoterateplancharge.Quantity__c > 0 && (quoteRatePlanChargeClass.quoterateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME || quoteRatePlanChargeClass.quoterateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE)) 
                              chargeQuantity = quoteRatePlanChargeClass.quoterateplancharge.Quantity__c;
                            for(Quote_Rate_Plan_Charge_Tier__c quoteTier : map_QuoteChargeId_QuoteTiers.get(qrpc.Id)) {
                             if(((quoteTier.Start_Unit__c <= chargeQuantity && quoteTier.End_Unit__c >= chargeQuantity)
                                     ||
                                    (quoteTier.Start_Unit__c <= chargeQuantity && quoteTier.End_Unit__c == null)) 
                                    && quoteRatePlanChargeClass.quoterateplancharge.Quantity__c > 0 
                                    && (quoteRatePlanChargeClass.quoterateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME
                                         || quoteRatePlanChargeClass.quoterateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE))
                                    {
                                        quoteRatePlanChargeClass.quoterateplancharge.Unit_Price__c = quoteTier.Unit_Price__c;
                                        quoteRatePlanChargeClass.quoterateplancharge.Cost_Price__c = quoteTier.Unit_Cost_Price__c;
                                  }
                                  
                                quoteTierClass = new quoteRatePlanChargeTierClass(); 
                                quoteTierClass.quoteRatePlanChargeTier = quoteTier;
                                quoteTierClass.quoteRatePlanChargeTierCounter = ++quoteRatePlanChargeTierCounter;
                                quoteRatePlanChargeClass.quoteRatePlanChargeTiers.add(quoteTierClass);
                            }
                        }
                        quoteRatePlanClass.quoteRatePlanCharges.add(quoteRatePlanChargeClass);
                    }
                    quoteRatePlanClass.quoteRatePlanCounter = ++quoteRatePlanCounter;
                    quoteProductClass.quoteRatePlans.add(quoteRatePlanClass);

                    mapQuoteProducts.put(qr.Quote_Product__c,quoteProductClass);
                }

                quoteClass = new QuoteClass();
                quoteClass.quote = quote;
                
                Integer iQuoteProductSize = listQuoteProducts.size();
                for(integer i = 0; i < iQuoteProductSize; i++) {
                    Id quoteProductId = listQuoteProducts.get(i).Id;
                    QuoteProductClass qpc = mapQuoteProducts.get(quoteProductId); 
                    qpc.quoteProductCounter = ++quoteProductCounter;
                    quoteClass.quoteProducts.add(qpc);
                }                   

                iQuoteProductSequenceNo = 1;
                for(QuoteProductClass quoteProductClas : quoteClass.quoteProducts) {
                    quoteProductClas.quoteproduct.SequenceNumber__c = iQuoteProductSequenceNo;
                    iQuoteProductSequenceNo ++;
                }

                iQuoteRatePlanSequenceNo = 1;
                for(QuoteProductClass quoteProductClas : quoteClass.quoteProducts) {
                    for(QuoteRatePlanClass quoterateplan : quoteProductClas.quoteRatePlans) {
                        quoterateplan.quoterateplan.SequenceNumber__c = iQuoteRatePlanSequenceNo;
                        iQuoteRatePlanSequenceNo ++;
                    }
                }
            }

            return quoteClass;   
        }
        // This is to calualte the totalcontractvalue used in recaluation method
        public static void saveQuote(QuoteClass quoteClass) {

            decimal totalContractValue = 0;
            decimal totalChargeContract = 0;
            decimal totalContractedMRR = 0;
            list<Quote_Rate_Plan__c> quoteRatePlansToDelete = new list<Quote_Rate_Plan__c>();
            list<Quote_Product__c> quoteProductsToDelete = new list<Quote_Product__c>();
            Quote__c quote = new Quote__c();
            quote = quoteClass.quote;
            Currency__c currencyObj = CommonUtilClass.getCurrencyObjectForId(quote.CurrencyL__c);
            string currecyISOCode = currencyObj.Name;
            list<Quote_Rate_Plan_Charge__c> listQuoteRatePlanCharges = new list<Quote_Rate_Plan_Charge__c>();
            list<Quote_Rate_Plan_Charge__c> listQuoteRatePlanChargesToDelete = new list<Quote_Rate_Plan_Charge__c>();
            list<Quote_Rate_Plan_Charge_Tier__c> listQuoteTiersToDelete = new list<Quote_Rate_Plan_Charge_Tier__c>();
            Map<Integer,Quote_Product__c> mapQuoteProducts = new Map<Integer, Quote_Product__c>();
                    map<String, Configuration__c> mapConfiguration = Configuration__c.getAll();
            boolean Align_Dates_Of_Quote_To_Products = mapConfiguration.get('ALIGN_DATES_OF_Quote_TO_PRODUCTS').Boolean_Value__c;

            //populate the exchange rate
            if(UserInfo.isMultiCurrencyOrganization()
                    && quoteClass.quote.Valid_To__c != null) 
            {
                QuoteCreationUtil.populateExchangeRateOnQuote(quoteClass.quote, currecyISOCode);
            }

            quote.Contracted_MRR__c = 0;
            quote.Total_Contract_Value__c = 0;
            
            map<Id, Integer> mapProductBundleId_sequenceNumber = new map<Id, Integer>();
            integer quoteBundleSequenceNo = 1;
            
            for(QuoteProductClass qpc : quoteClass.quoteProducts) {
                if(qpc.quoteproduct.Quote__c == null) {
                    qpc.quoteproduct.Quote__c = quoteClass.quote.Id;  
                }
                
                if(qpc.quoteproduct.Product_Bundle__c != null  && qpc.quoteproduct.Bundle_SequenceNumber__c == null) {
                    if(mapProductBundleId_sequenceNumber.containskey(qpc.quoteproduct.Product_Bundle__c)) {
                        qpc.quoteproduct.Bundle_SequenceNumber__c = mapProductBundleId_sequenceNumber.get(qpc.quoteproduct.Product_Bundle__c);
                    }else {
                        mapProductBundleId_sequenceNumber.put(qpc.quoteproduct.Product_Bundle__c ,quoteBundleSequenceNo);
                        qpc.quoteproduct.Bundle_SequenceNumber__c = quoteBundleSequenceNo;
                        quoteBundleSequenceNo++;
                    }
                }
                mapQuoteProducts.put(qpc.quoteProductCounter, qpc.quoteproduct);
            }
            upsert mapQuoteProducts.values();

            for(QuoteProductClass qpc: quoteClass.quoteProducts) {
                qpc.quoteproduct = mapQuoteProducts.get(qpc.quoteProductCounter);   
            }
            Map<Integer,Quote_Rate_Plan__c> mapQuoteRatePlan = new Map<Integer,Quote_Rate_Plan__c>();
            for(QuoteProductClass qpc : quoteClass.quoteProducts) {
                qpc.quoteproduct = mapQuoteProducts.get(qpc.quoteProductcounter);
                for(QuoteRatePlanClass qrc : qpc.quoteRatePlans ) {
                    if( qrc.quoterateplan.Quote_Product__c == null) {
                        qrc.quoterateplan.Quote_Product__c = qpc.quoteproduct.id;
                    }
                    mapQuoteRatePlan.put(qrc.quoteRatePlanCounter,qrc.quoterateplan);
                }
            }
            upsert mapQuoteRatePlan.values();

            for(QuoteProductClass qpc : quoteClass.quoteProducts) {
                qpc.quoteproduct = mapQuoteProducts.get(qpc.quoteProductcounter);
                for(QuoteRatePlanClass qrc : qpc.quoteRatePlans ) {
                    qrc.quoterateplan = mapQuoteRatePlan.get(qrc.quoteRatePlanCounter);
                }
            }       
            //upsert QuoteRatePlancharges
            Map<Integer,Quote_Rate_Plan_Charge__c> mapQuoteRatePlanCharges = new Map<Integer,Quote_Rate_Plan_Charge__c>();
            for(QuoteProductClass qpc :quoteClass.quoteProducts)
            {
                for(QuoteRatePlanClass qrc : qpc.quoteRatePlans)
                { 
                    integer i = 0;
                    for(QuoteRatePlanChargeClass qrpc :qrc.quoteRatePlanCharges)
                    {
                        totalChargeContract = 0;
                        if(qrpc.quoterateplancharge.Quote_Rate_Plan__c == null){
                            qrpc.quoterateplancharge.Quote_Rate_Plan__c = qrc.quoterateplan.id;
                        }        
                        //If Quantity__c is greather than 0,then add to the map.Else do not add to the map.
                        if(qrpc.quoterateplancharge.Quantity__c > 0 || qrpc.quoterateplancharge.Price_Type__c == system.Label.OptionUsage) {
                            qrpc.quoterateplancharge.Sequence_No__c = ++i; 
                            mapQuoteRatePlanCharges.put(qrpc.quoteRatePlanChargeCounter,qrpc.quoterateplancharge);
                            //If the Number_Of_Terms__c are present use that and calculate TCV                           
                            if(qrpc.quoterateplancharge.Price_Type__c == system.Label.OptionOneTime) {
                                totalChargeContract = qrpc.quoterateplancharge.Net_Total__c;
                            } //Anil has added the below lines on July 2nd 2015 to get the pro ration with the proposed dates (ticket no INVOICEIT-584)
                            else if(quote.Proposed_Start_Date__c != null && quote.Proposed_End_Date__c != null) {
                                totalChargeContract = QuoteCreationUtil.calculateQuoteChargeLineAmount(qrpc.quoterateplancharge, quote.Proposed_Start_Date__c, quote.Proposed_End_Date__c);
                            } else if(quote.Number_Of_Terms__c > 0) {
                                totalChargeContract = QuoteCreationUtil.calculateQuoteChargeLineAmount(qrpc.quoterateplancharge, system.today(), system.today().addMonths((Integer)quote.Number_Of_Terms__c).addDays(-1));  
                            } 
                            //calculate the ContractedMRR only if the type is not equal to one time
                            if(qrpc.quoterateplancharge.Price_Type__c != system.Label.OptionOneTime) {
                                totalContractValue += totalChargeContract;
                                totalContractedMRR += totalChargeContract;
                            } else {
                                totalContractValue += totalChargeContract;
                            }    
                        }
                        else if(qrpc.quoterateplancharge.Id != null) {
                            listQuoteRatePlanChargesToDelete.add(new Quote_Rate_Plan_Charge__c(Id = qrpc.quoterateplancharge.Id));
                            //Add the corresponding quoterateplanchargetiers to a delete list and delete those tiers to remove orphaned records
                            for(QuoteRatePlanChargeTierClass quoteTierClass : qrpc.quoteRatePlanChargeTiers) {
                                if(quoteTierClass.quoteRatePlanChargeTier.Id != null) {
                                    listQuoteTiersToDelete.add(quoteTierClass.quoteRatePlanChargeTier);    
                                }
                            }
                        }
                    }
                }
            }
            upsert mapQuoteRatePlanCharges.values();
            Map<Integer,Quote_Rate_Plan_Charge_Tier__c> mapQuoteRatePlanChargeTiers = new Map<Integer,Quote_Rate_Plan_Charge_Tier__c>();
            for(QuoteProductClass qpc :quoteClass.quoteProducts)
            {
                for(QuoteRatePlanClass qrc : qpc.quoteRatePlans)
                { 
                    for(QuoteRatePlanChargeClass qrpc :qrc.quoteRatePlanCharges)
                    {
                        if(qrpc.quoterateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_VOLUME 
                                || qrpc.quoterateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE 
                                || qrpc.quoterateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_TIERED)
                        {
                            for(QuoteRatePlanChargeTierClass quoteTierClass : qrpc.quoteRatePlanChargeTiers)
                            {
                                if(quoteTierClass.quoteRatePlanChargeTier.Quote_Rate_Plan_Charge__c == null) {
                                    if(mapQuoteRatePlanCharges.containsKey(qrpc.quoteRatePlanChargeCounter)) {
                                        quoteTierClass.quoteRatePlanChargeTier.Quote_Rate_Plan_Charge__c = mapQuoteRatePlanCharges.get(qrpc.quoteRatePlanChargeCounter).Id;
                                        mapQuoteRatePlanChargeTiers.put(quoteTierClass.quoteRatePlanChargeTierCounter, quoteTierClass.quoteRatePlanChargeTier); 
                                    }
                                }else {
                                    if(mapQuoteRatePlanCharges.containsKey(qrpc.quoteRatePlanChargeCounter)) {
                                        mapQuoteRatePlanChargeTiers.put(quoteTierClass.quoteRatePlanChargeTierCounter, quoteTierClass.quoteRatePlanChargeTier); 
                                    }
                                }
                            }
                        }
                    }
                }
            }
            upsert mapQuoteRatePlanChargeTiers.Values();

            if(quoteRatePlansToDelete != null && quoteRatePlansToDelete.size() > 0) {
                delete quoteRatePlansToDelete;    
            }
            //Here we are deleting the Quote_Products which has no rate Plan charges
            for(QuoteProductClass qpc : quoteClass.quoteProducts) {
                if(qpc.quoteproduct.Total_Quote_Rate_Plans__c == 0) {
                    quoteProductsToDelete.add(qpc.quoteproduct);  
                }
                mapQuoteProducts.put(qpc.quoteProductCounter, qpc.quoteproduct);
            }
            if(quoteProductsToDelete != null && quoteProductsToDelete.size() > 0) {
                delete quoteProductsToDelete;
            }
            if(listQuoteRatePlanChargesToDelete.size() > 0) {
                delete listQuoteRatePlanChargesToDelete;
            }
            if(listQuoteTiersToDelete.size() > 0) {
                delete listQuoteTiersToDelete;
            }
            //Added by Balachary InvoiceIT-657
            quote.VAT__c = quoteClass.quote.VAT__c;
            quote.Tax__c = quoteClass.quote.Tax__c;
            quote.Discount_Value__c = quoteClass.quote.Discount_Value__c;
            quote.Sub_Total__c = quoteClass.quote.Sub_Total__c;
            quote.Total__c = quoteClass.quote.Total__c;
            quote.Total_Cost__c = quoteClass.quote.Total_Cost__c;
            quote.Net_Total__c = quoteClass.quote.Net_Total__c;
            quote.Total_Profit__c = quoteClass.quote.Total_Profit__c;
            quote.TotalProfitPercent__c = quoteClass.quote.TotalProfitPercent__c;
            quote.Recalculate__c = false;
     if(totalContractValue > 0){
              quote.Total_Contract_Value__c = totalContractValue; 
            }else{
                quote.Total_Contract_Value__c = 0;
            }
            if(totalContractedMRR > 0 && quote.Number_Of_Terms__c != null && quote.Number_Of_Terms__c >= 1) {
                quote.Contracted_MRR__c = (totalContractedMRR/quote.Number_Of_Terms__c);
            }
            else{
                quote.Contracted_MRR__c = 0;
                }
            update quote;
        }
    }