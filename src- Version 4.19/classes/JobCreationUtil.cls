public with sharing class JobCreationUtil {
    public static String sPrefix = CommonUtilClass.getPrefix();
        
        //This method Returns all the rate plan charges for the specific rate plan @return ratePlanCharges
        public static list<Product_Rate_Plan_Charge__c> getProductRatePlanCharges(String ratePlanId, Id currencyId, map<String,String> searchMap) {
            String searchString = '';
            if(searchMap != null && !searchMap.isEmpty()) {
                for(String field : searchMap.keySet()){
                    String value = searchMap.get(field);
                    searchString = searchString + ' and '+ field +' = \'' + value + '\'';
                }
            }

            if(currencyId == null) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.WARNING,system.Label.Currency_NotSelected_Order);
                Apexpages.addMessage(errorMessage);
                return null;
            }
            else {
                string sQuery ='SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Product_Rate_Plan_Charge__c')
                + ', (SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Product_Rate_Plan_Charge_Tier__c') +  'FROM Product_Rate_Plan_Charge_Tiers__r ORDER BY Start_Unit__c) '
                + ',Product_Rate_Plan__r.Product__r.Id,Product_Rate_Plan__r.Name,Product_Rate_Plan__r.Product__r.Product_Code__c, Product_Rate_Plan__r.Product__r.Name '
                + ' from Product_Rate_Plan_Charge__c '
                + ' where Product_Rate_Plan__c =' + '\''+ String.escapeSingleQuotes(ratePlanId) + '\'' + ' '
                + ' and CurrencyL__c=' + '\''+ String.escapeSingleQuotes(currencyId) + '\'' + ' '
                + searchString
                + 'order by Charge_Sequence_Number__c';
                Product_Rate_Plan_Charge__c[] ratePlanCharges = Database.query(sQuery);

                return ratePlanCharges;
            }
        }
        
        public static Product_Rate_Plan__c getProductRatePlanFromList(List<Product_Rate_Plan__c> listOfProductRatePlans,String selectedRatePlanId) 
        {
            if(listOfProductRatePlans != null) {
                for(Product_Rate_Plan__c productrateplan : listOfProductRatePlans ) {
                    if(selectedRatePlanId == productrateplan.Id){
                        return productrateplan;
                    }
                }
            }       
            return null;
        }

        
         // This method Returns all the rate plans for the specific product @return ratePlans
        public static List<Product_Rate_Plan__c> getProductRatePlans(String productId, Date validCheckDate, map<String,String> searchMap, Boolean midTerm)
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
            + searchString;
            string sDateFilter = '';
            sDateFilter = ' and Valid_From_Date__c != null'
            + ' and (Valid_To_Date__c >= ' + CommonUtilClass.convertDateToString(validCheckDate)
            + ' Or Valid_To_Date__c = null ) ORDER BY Occurrence__c DESC NULLS LAST';
            
            sQuery = sQuery + sDateFilter;
            Product_Rate_Plan__c [] ratePlans = Database.query(sQuery);                                                                    
            return ratePlans;
        }

         // This method getJob @return job
        public static Job__c getJob(Id id)
        {
            String query = CommonUtilClass.getObjectSelectQuery(sPrefix+'Job__c');
            query = query + ' WHERE Id =\'' + String.escapeSingleQuotes(id) + '\'';
            Job__c job = Database.query(query);
            return job;
        }

         // This method getListJobProducts @return charges

        /*
            Modified By     : Anil Pinto  14 June 2013  INVOICEIT-85
            Comments        : This code is changed since we wanted to display products name in the orderProductsInline page, so we added a field in query "Product__r.Name" ,since its a
                              relationship field and could not get in the dynamic SOQL query, we changed it
         */
       public static List<Job_Product__c> getListJobProducts(Id jobId)
        {
            string queryString ='SELECT Product__r.Name, ' + CommonUtilClass.getObjectFields(sPrefix+'Job_Product__c') + ' From Job_Product__c where  Job__c = \'' + String.escapeSingleQuotes(jobId) + '\' order by SequenceNumber__c';
            Job_Product__c  [] jobProducts = database.query(queryString);                                  
            return jobproducts;
        }

         // This method get map of jobProducts @return mapJobProducts
        public static Map<Id,JobProductClass> getMapJobProducts(List<Job_Product__c> listJobProducts)
        {
            Map<Id,JobProductClass> mapJobProducts = new Map<Id,JobProductClass>();
            for(Job_Product__c qp : listJobProducts)
            {
                JobProductClass jobProductClass = new JobProductClass();
                jobProductClass.jobproduct = qp;

                mapJobProducts.put(qp.id,jobProductClass);
            }
            return mapJobProducts;
        }

       //This method CheckforDuplicateProducts @return jp
       // This method get ListJobRatePlans @return charges
        public static List<Job_Rate_Plan__c> getListJobRatePlans(List<Id> jobProductIds)
        {
            if(jobProductIds.size() > 0){
                string sQuoteProductIds = CommonUtilClass.convertListOfIdsIntoString(jobProductIds);
                String sQuery =  'SELECT Job_Product__r.Product_Bundle__c,Job_Product__r.Product_Bundle__r.Is_Quantity_Editable__c,Job_Product__r.Product_Bundle__r.Bundle_Type__c,' + CommonUtilClass.getObjectFields(sPrefix+'Job_Rate_Plan__c') + ',' 
                + '(SELECT Product_Bundle_Line__r.Is_Quantity_Editable__c,Product_Rate_Plan_Charge__r.Uplift__c,' + CommonUtilClass.getObjectFields(sPrefix+'Job_Rate_Plan_Charge__c') +  'from Job_Rate_Plan_Charge__r Order by Sequence_No__c)'
                + 'from Job_Rate_Plan__c where Job_Product__c IN (' + sQuoteProductIds  + ') Order By Job_Rate_Plan__c.Job_Product__r.SequenceNumber__c,SequenceNumber__c';
                
                Job_Rate_Plan__c [] jobRatePlans = Database.query(sQuery);

                return jobRatePlans;   
            }
            else {
                return null;
            }                                             
        }
        
        
        public static List<Job_Rate_Plan__c> getListJobRatePlansForRenew(List<Id> jobProductIds)
        {
            if(jobProductIds.size() > 0){
                string sQuoteProductIds = CommonUtilClass.convertListOfIdsIntoString(jobProductIds);
                
                // This is to make sure all the bundle items are picked up when any of bundle line is selected
                set<Integer> setOfBundle = new set<Integer>();
                String sJobProductQuery = 'SELECT Id,Job_Rate_Plan__r.Job_Product__r.Bundle_SequenceNumber__c FROM Job_Rate_Plan_Charge__c WHERE Auto_Renew__c = true AND Job_Rate_Plan__r.Job_Product__c IN (' + sQuoteProductIds  + ')';
                //list<Job_Rate_Plan_Charge__c> listofCharges = [SELECT Id,Job_Rate_Plan__r.Job_Product__r.Bundle_SequenceNumber__c FROM Job_Rate_Plan_Charge__c WHERE Auto_Renew__c = true AND Job_Rate_Plan__r.Job_Product__c  IN: sQuoteProductIds ];
                list<Job_Rate_Plan_Charge__c> listofCharges = Database.query(sJobProductQuery);     
                for(Job_Rate_Plan_Charge__c charge : listofCharges) {
                    if(charge.Job_Rate_Plan__r.Job_Product__r.Bundle_SequenceNumber__c != null)
                        setOfBundle.add((Integer)charge.Job_Rate_Plan__r.Job_Product__r.Bundle_SequenceNumber__c);
                }

                // AND Price_Type__c !=\'One Time\' removed by dev for task INVOICEIT-541
                String sQuery =  'SELECT Job_Product__r.Product_Bundle__c,Job_Product__r.Product_Bundle__r.Is_Quantity_Editable__c,Job_Product__r.Product_Bundle__r.Bundle_Type__c,' + CommonUtilClass.getObjectFields(sPrefix+'Job_Rate_Plan__c') + ',' 
                + '(SELECT Product_Bundle_Line__r.Is_Quantity_Editable__c,Product_Rate_Plan_Charge__r.Uplift__c,Job_Rate_Plan__r.Job_Product__r.Product_Bundle__r.Bundle_Type__c,Job_Rate_Plan__r.Job_Product__r.Product_Bundle__r.Uplift__c,Product_Bundle_Line__r.Product_Bundle__r.Bundle_Price__c,' + CommonUtilClass.getObjectFields(sPrefix+'Job_Rate_Plan_Charge__c') +  'from Job_Rate_Plan_Charge__r WHERE (Auto_Renew__c = true AND Mid_Term_Status__c != \'Old\') OR (Mid_Term_Status__c != \'Old\' AND Job_Rate_Plan__r.Job_Product__r.Bundle_SequenceNumber__c in: setOfBundle)  Order by Sequence_No__c)'
                + 'from Job_Rate_Plan__c where Job_Product__c IN (' + sQuoteProductIds  + ') Order By Job_Rate_Plan__c.Job_Product__r.SequenceNumber__c,SequenceNumber__c ';
          
                Job_Rate_Plan__c [] jobRatePlans = Database.query(sQuery);

                return jobRatePlans;   
            }
            else {
                return null;
            }                                             
        }

        //This method get jobRatePlans @return jobRatePlan
        public static Job_Rate_Plan__c getjobRatePlanToDelete(Id jobRatePlanId)
        {
            String queryString = CommonUtilClass.getObjectSelectQuery(sPrefix+'Job_Rate_Plan__c')+ 'where Id = \'' + String.escapeSingleQuotes(jobRatePlanId) + '\'';
            Job_Rate_Plan__c  jobRatePlan=database.query(queryString);
            if(jobRatePlan == null) {
               return null;
            }
            else { 
               return jobRatePlan;
            }
        }

        public static Product__c getProduct(string selectedProductId)
        {
            String sQuery = CommonUtilClass.getObjectSelectQuery(sPrefix+'Product__c') + ' where Id =' + '\'' + String.escapeSingleQuotes(selectedProductId) + '\'';
            Product__c product = Database.query(sQuery);
            return product;
        }

        public static list<Product_Rate_Plan__c> getListOfRatePlans(Id productId)
        {
            String sQuery =  'SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Product_Rate_Plan__c') + ',' 
            + '(SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Product_Rate_Plan_Charge__c') +  'from ProductRatePlanCharge__r Order by Charge_Sequence_Number__c)'
            + 'from Product_Rate_Plan__c where Product__c =\'' + String.escapeSingleQuotes(productId) + '\''; 
            return Database.query(sQuery);
        }

        public static list<Product_Rate_Plan_Charge_Tier__c> getListOfTiers(set<Id> setOfRatePlanChargesIds)
        {
            return [SELECT Start_Unit__c, End_Unit__c, Unit_Price__c, Unit_Cost_Price__c, Product_Rate_Plan_Charge__c
                    FROM Product_Rate_Plan_Charge_Tier__c
                    WHERE Product_Rate_Plan_Charge__c IN : setOfRatePlanChargesIds
                    ORDER BY Start_Unit__c];
        }

        //this is new method and not yet used
        //above method(i.e. getListOfDiscounts) is modified as below
        public static list<Discount_Code__c> getListOfDiscounts(string discountCode, JobClass jobClass)
        {
            //no need to check account id here because i have handled in controller
            list<Discount_Code__c> listOfDiscounts = new list<Discount_Code__c>();
            Account account = [SELECT Customer_Class__c
                               FROM Account
                               WHERE Id =: jobClass.job.Account__c];

            listOfDiscounts = [SELECT Name, Apply_to__c, Discount_Percent__c, Discount_Value__c, Price_Type__c, Product_Family__c 
                               FROM Discount_Code__c
                               WHERE Name =: discountCode 
                               AND 
                               Currency__c =: jobClass.job.CurrencyL__c
                               And
                               (Customer_Class__c Includes (:account.Customer_Class__c) OR Customer_Class__c Includes ('*'))
            And
            Valid_From__c <=: system.today()
            AND 
            (Valid_To__c >=: system.today() OR Valid_To__c = null)];

            return  listOfDiscounts;
        }

       
        public static void tieredPricing(JobRatePlanChargeClass jobChargeClass) 
        {
            Job_Rate_Plan_Charge__c jobRatePlanCharge = jobChargeClass.jobRatePlanCharge;
            if(jobRatePlanCharge.Quantity__c > 0) {

                integer quantityCalculated = 0;
                decimal usageAmount = 0;
                decimal costPrice = 0;
                integer remaningUsage = integer.ValueOf(jobRatePlanCharge.Quantity__c);
                integer usageQuantity = integer.ValueOf(jobRatePlanCharge.Quantity__c);
                boolean isTierExists = false;
                integer iSize;

                list<JobRatePlanChargeTierClass> tempTiers = jobChargeClass.jobRatePlanChargeTiers; 
                JobRatePlanChargeTierClass jobTierClass; 
                Job_Rate_Plan_Charge_Tier__c productChargeTier;
                iSize = tempTiers.Size();        
                for(integer i = 0; i < iSize; i++) {
                    jobTierClass = tempTiers[i];
                    productChargeTier = jobTierClass.jobRatePlanChargeTier;
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

                jobRatePlanCharge.Price__c = usageAmount;
                jobRatePlanCharge.Cost__c = costPrice;
                jobRatePlanCharge.Cost_Price__c = costPrice/jobRatePlanCharge.Quantity__c;
                jobRatePlanCharge.Unit_Price__c = usageAmount/jobRatePlanCharge.Quantity__c;
            } else {
                jobRatePlanCharge.Cost_Price__c = 0;
                jobRatePlanCharge.Unit_Price__c = 0;
                jobRatePlanCharge.Price__c = 0;
            }
        }

     
        public static decimal calculateJobChargeLineAmount(Job_Rate_Plan_Charge__c charge, Date startDate, Date endDate) 
        {
             
            decimal noOfTimesCharge = InvoicingUtilClass.calculateDiffBetweenDatesInMonths(startDate, endDate.addDays(1), charge.Price_Type__c);
             
            if(charge.Price_Type__c == system.Label.OptionOneTime) {
                return (charge.Net_Total__c);
            } else if(charge.Price_Type__c == system.Label.OptionWeekly) {
                decimal noOfDays = startDate.daysBetween(endDate); 
                decimal noOfWeeks = noOfDays.Divide(7,3,System.RoundingMode.UP);
                return (noOfWeeks * charge.Net_Total__c);
            } else {
                return (noOfTimesCharge*charge.Net_Total__c);
            }

            return 0;
        }

        public static list<Job_Rate_Plan_Charge__c> getChargesToBeDispatched(set<Id> setOfChargesIdsToBeDispatched) 
        {
            list<Job_Rate_Plan_Charge__c> chargesToBeDispatched;
            chargesToBeDispatched = [SELECT Id,Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c,
                                     Job_Rate_Plan__r.Job_Product__r.Product__c,
                                     Job_Rate_Plan__r.Job_Product__r.Job__r.Account__r.Invoice_Delivery_Type__c,
                                     Job_Rate_Plan__r.Job_Product__r.Product__r.Name,
                                     Name, 
                                     Quantity__c, Quantity_to_Dispatch__c, Remaining_Quantity__c, Quantity_Already_Dispatched__c
                                     FROM Job_Rate_Plan_Charge__c 
                                     WHERE Id IN: setOfChargesIdsToBeDispatched
                                     AND
                                     Dispatch__c != true
                                     ];

            return chargesToBeDispatched;
        }

        public static list<Stock_Item__c> getListOfStockItems(set<Id> setOfProductIds) 
        {
            list<Stock_Item__c> listOfStocks = [SELECT Name, Available_Quantity__c, Product__c
                                                FROM Stock_Item__c
                                                WHERE Available_Quantity__c > 0
                                                AND
                                                Product__c IN: setOfProductIds
                                                ORDER BY Stock_Entry_Date__c
                                                ];

            return listOfStocks;
        }

        public static list<Stock_Item__c> getListOfStockItems(set<Id> setOfProductIds, set<string> setOfScannedBarCodes) 
        {
            list<Stock_Item__c> listOfStocks = [SELECT Name, Available_Quantity__c, Product__c, Product__r.Name, Bar_Code__c
                                                FROM Stock_Item__c
                                                WHERE Available_Quantity__c > 0
                                                AND
                                                Bar_Code__c IN: setOfScannedBarCodes
                                                ORDER BY Stock_Entry_Date__c
                                                ];
            return listOfStocks;
        }

        public static list<AggregateResult> getAvailableStocks(set<Id> setOfProductIds) 
        {
            list<AggregateResult> aggRes = [SELECT sum(Available_Quantity__c) availableQty, Product__c productId
                                            FROM Stock_Item__c
                                            WHERE Available_Quantity__c > 0
                                            AND
                                            Product__c IN: setOfProductIds
                                            GROUP BY Product__c
                                            ];
            return aggRes;
        }

        public static map<Id, list<Job_Rate_Plan_Charge_Tier__c>> queryTiersBasedOnJobId(string jobId) 
        {
            map<Id, list<Job_Rate_Plan_Charge_Tier__c>> map_JobCharge_QuoteTier = new map<Id, list<Job_Rate_Plan_Charge_Tier__c>>();
            list<Job_Rate_Plan_Charge_Tier__c> jobTiers = [SELECT End_Unit__c, Job_Rate_Plan_Charge__c, Start_Unit__c, Unit_Cost_Price__c, Unit_Price__c
                                                           FROM Job_Rate_Plan_Charge_Tier__c
                                                           WHERE  Job_Rate_Plan_Charge__r.Job_Rate_Plan__r.Job_Product__r.Job__c =: jobId
                                                           ORDER BY Start_Unit__c];

            list<Job_Rate_Plan_Charge_Tier__c> jobTiersLocalVar;
            for(Job_Rate_Plan_Charge_Tier__c jobTier : jobTiers) {
                if(map_JobCharge_QuoteTier.containsKey(jobTier.Job_Rate_Plan_Charge__c)) {
                    jobTiersLocalVar = map_JobCharge_QuoteTier.get(jobTier.Job_Rate_Plan_Charge__c);
                } else {
                    jobTiersLocalVar = new list<Job_Rate_Plan_Charge_Tier__c>();
                }

                jobTiersLocalVar.add(jobTier);
                map_JobCharge_QuoteTier.put(jobTier.Job_Rate_Plan_Charge__c, jobTiersLocalVar);
            }

            return map_JobCharge_QuoteTier;
        }    

       
        public static void populateExchangeRateOnOrder(Job__c order, string isoCode) {
            sobject datedConversionRate = CommonUtilClass.getExchangeRateByDate(order.Start_Date__c, isoCode);

            if(datedConversionRate != null) {
                sobject sobjectOrder = (sobject)order;
                sobjectOrder.put(sPrefix+'Exchange_Rate_Applied__c',(decimal) datedConversionRate.get('ConversionRate'));
                sobjectOrder.put('CurrencyIsoCode',(string) isoCode);
                order = (Job__c) sobjectOrder;
            } else {
                order.Exchange_Rate_Applied__c = 1;
            }   
        }
        
        public static list<Product_Rate_Plan_Charge__c> getListOfRatePlans(list<Product_Rate_Plan__c> listOfRatePlan)
        {
            String sQuery =  'SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Product_Rate_Plan_Charge__c') + ',' 
            + '(SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Product_Rate_Plan_Charge_Tier__c') +  'from Product_Rate_Plan_Charge_Tiers__r ORDER BY Start_Unit__c)'
            + 'from Product_Rate_Plan_Charge__c where Product_Rate_Plan__c in: listOfRatePlan ORDER BY Name';     
            return Database.query(sQuery);
        }
        
        public static Product_Rate_Plan__c getProductRatePlan(Id id) {
            String query = CommonUtilClass.getObjectSelectQuery(sPrefix+'Product_Rate_Plan__c');
            query = query + ' WHERE Id =\'' + String.escapeSingleQuotes(id) + '\'';
            Product_Rate_Plan__c productRatePlan = Database.query(query);
            return productRatePlan;
        }
        
        
        public static list<Product_Rate_Plan_Charge__c> getProductRatePlanCharges(String ratePlanId, Id currencyId, set<Id> ChargeIds) {
             string sQuery ='SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Product_Rate_Plan_Charge__c')
                + ', (SELECT ' + CommonUtilClass.getObjectFields(sPrefix+'Product_Rate_Plan_Charge_Tier__c') +  'FROM Product_Rate_Plan_Charge_Tiers__r ORDER BY Start_Unit__c) '
                + ',Product_Rate_Plan__r.Product__r.Id,Product_Rate_Plan__r.Name,Product_Rate_Plan__r.Product__r.Product_Code__c, Product_Rate_Plan__r.Product__r.Name '
                + ' from Product_Rate_Plan_Charge__c ';
                
                if(ratePlanId != '')
                sQuery = sQuery + ' where Product_Rate_Plan__c =' + '\''+ String.escapeSingleQuotes(ratePlanId) + '\'' + ' ';
                else
                sQuery = sQuery + ' where Product_Rate_Plan__r.Name != null';
                
                sQuery = sQuery + ' AND CurrencyL__c=' + '\''+ String.escapeSingleQuotes(currencyId) + '\'' + ' '
                + ' AND Id in: ChargeIds '
                + 'order by Charge_Sequence_Number__c';

                Product_Rate_Plan_Charge__c[] ratePlanCharges = Database.query(sQuery);
                return ratePlanCharges;
        }
    }