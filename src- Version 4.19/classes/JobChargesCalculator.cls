public with sharing class JobChargesCalculator {
    public static String sPrefix = CommonUtilClass.getPrefix();
        /**
        * This method calculates all the charges related to the jobProduct
        * @return charges
        */
        public static void calculateCharges(JobClass jobClass)
        {
            //try {
                JobChargesCalculator.Charges charges = new JobChargesCalculator.Charges();
                integer iNoOfDecimalPlaces = integer.valueOf(Configuration__c.getValues('NO_OF_DECIMALS_FOR_CURRENCY_VALUES').Number_Value__c);

                if(jobClass.job.Discount_Value__c == null) {
                    jobClass.job.Discount_Value__c = 0;
                }
                
                if(jobClass.job.Discount_Percent__c == null) {
                    jobClass.job.Discount_Percent__c = 0;
                }

                map<String, decimal> mapCategoryAndTaxRates = new map<String, decimal>();
                map<String, decimal> mapCategoryAndVATRates = new map<String, decimal>();  
                
                //In the config if the tax calculation is based on billing contact, then get the details
                /*The tax/vat rate calculations can be based on 3 options below
                    -Billing Contact
                    -Shipping Contact
                    -Account Billing Address
                */
                String sPostCode, sCity, sState, sCountry;
                Account account;
                
                String sTaxCalculationBasedOn = Configuration__c.getValues(CommonUtilClass.TAX_CALCULATION_BASED_ON).String_Value__c;
                //Get the legal entity for the tax calculation
                String legalEntityField = Configuration__c.getValues('ACCOUNT_LEGAL_ENTITY_FIELD_NAME').String_Value__c;
                
                if(legalEntityField != null || sTaxCalculationBasedOn == CommonUtilClass.ACCOUNT_BILLING_ADDRESS || sTaxCalculationBasedOn == CommonUtilClass.ACCOUNT_SHIPPING_ADDRESS) { 
                    account = (Account) CommonUtilClass.getSobjectById(CommonUtilClass.OBJECT_NAME_ACCOUNT, jobClass.job.Account__c);
                }
                // Modified by Dev Ticket : INVOICEIT-434
                if(!jobClass.job.Override_Vat_Tax__c) {
                    if(sTaxCalculationBasedOn == CommonUtilClass.CONTACT_TYPE_BILLING 
                        && jobClass.job.Billing_Contact__c != null)
                    {
                        Contact contact = [SELECT MailingCountry, MailingCity, MailingState, MailingPostalCode
                                          FROM Contact
                                          WHERE Id = :jobClass.job.Billing_Contact__c];
                        if(contact != null){
                            sPostCode = contact.MailingPostalCode;
                            sCity = contact.MailingCity;
                            sState = contact.MailingState;
                            sCountry = contact.MailingCountry;
                        }
                    } else if(sTaxCalculationBasedOn == CommonUtilClass.CONTACT_TYPE_SHIPPING
                                && jobClass.job.Shipping_Contact__c != null) {
                        Contact contact = [SELECT MailingCountry, MailingCity, MailingState, MailingPostalCode
                                          FROM Contact
                                          WHERE Id = :jobClass.job.Shipping_Contact__c];
                        if(contact != null){
                            sPostCode = contact.MailingPostalCode;
                            sCity = contact.MailingCity;
                            sState = contact.MailingState;
                            sCountry = contact.MailingCountry;
                        }
                    }else if(sTaxCalculationBasedOn == CommonUtilClass.ACCOUNT_BILLING_ADDRESS){  
                        sPostCode = account.BillingPostalCode;
                        sCity = account.BillingCity;
                        sState = account.BillingState;
                        sCountry = account.BillingCountry;
                    }else if(sTaxCalculationBasedOn == CommonUtilClass.ACCOUNT_SHIPPING_ADDRESS){  
                        sPostCode = account.ShippingPostalCode;
                        sCity = account.ShippingCity;
                        sState = account.ShippingState;
                        sCountry = account.ShippingCountry;
                    }
                }
                
                if(sCountry != null) {
                    String legalEntiyName;
                    
                    if(legalEntityField != null) {
                        SObject sObjTemp = (SObject)account;
                        legalEntiyName = (string) sObjTemp.get(legalEntityField);
                    } else {
                        legalEntityField = Configuration__c.getValues('ORDER_LEGAL_ENTITY_FIELD_NAME').String_Value__c;
                        if(legalEntityField != null) {
                            SObject sObjTemp = (SObject)jobClass.job;
                            legalEntiyName = (string) sObjTemp.get(legalEntityField);
                        }
                    }
                    
                    //Laxman fixed the issue with dynamic query, ref : Jira : SUP-8, INVOICEIT-211
                    if(sCountry != null)
                        sCountry = sCountry.replaceAll('\'', '\\\\\'');
                    
                    if(sState != null)
                        sState = sState.replaceAll('\'', '\\\\\'');
                    
                    if(sCity != null)
                        sCity = sCity.replaceAll('\'', '\\\\\'');
                    
                    if(sPostCode != null)
                        sPostCode = sPostCode.replaceAll('\'', '\\\\\'');
                        
                    String taxQuery = 'SELECT Product_Charge_Category__c, Priority__c, SUM(Rate__c) Rate '+
                                                    'FROM Tax_Rate__c '+
                                                    'WHERE  Tax_VAT__c = \'' + CommonUtilClass.Tax + '\' ' +
                                                    'AND Country__c = \'' + sCountry + '\' ' +
                                                    'AND (State__c = \'' + sState + '\' OR State__c = \'*\') ' +
                                                    'AND (City__c = \'' + sCity + '\' OR City__c = \'*\') ' +
                                                    'AND (Post_Code__c = \'' + sPostCode + '\' OR Post_Code__c = \'*\' OR Post_Code__c = \'\') ';
                    //If they have not configured the app to use legal entity for tax calculation ignore this 
                    if(legalEntityField != null){
                        if(legalEntiyName == null){
                            legalEntiyName = '';
                        }
                        taxQuery += 'AND Legal_Entity_Name__c '+' = \'' + legalEntiyName + '\' ';
                    }
                    
                    taxQuery += 'GROUP BY Product_Charge_Category__c, Priority__c '+
                                'ORDER BY Product_Charge_Category__c, Priority__c';
                    AggregateResult[] taxRates = Database.query(taxQuery);
                    
                    String vatQuery = 'SELECT Product_Charge_Category__c, Priority__c, SUM(Rate__c) Rate '+
                                                    'FROM Tax_Rate__c '+
                                                    'WHERE  Tax_VAT__c = \'' + CommonUtilClass.VAT + '\' ' +
                                                    'AND Country__c = \'' + sCountry + '\' ' +
                                                    'AND (State__c = \'' + sState + '\' OR State__c = \'*\') ' +
                                                    'AND (City__c = \'' + sCity + '\' OR City__c = \'*\') ' +
                                                    'AND (Post_Code__c = \'' + sPostCode + '\' OR Post_Code__c = \'*\' OR Post_Code__c = \'\') ';
                    //If they have not configured the app to use legal entity for tax calculation ignore this 
                    if(legalEntityField != null){
                        if(legalEntiyName == null){
                            legalEntiyName = '';
                        }
                        vatQuery += 'AND Legal_Entity_Name__c '+' = \'' + legalEntiyName + '\' ';
                    }
                    
                    vatquery += 'GROUP BY Product_Charge_Category__c, Priority__c '+
                                'ORDER BY Product_Charge_Category__c, Priority__c';
                                                    
                    AggregateResult[] vatRates = Database.query(vatQuery);        
                    
                    //Now that we have all the data here all we need to do is consolidate the tax rates into a single value
                    for(AggregateResult taxRate : taxRates) {
                        decimal rate = (Decimal)taxRate.get('Rate');
                        String chargeCategory = (String)taxRate.get(sPrefix+'Product_Charge_Category__c');

                        //The results are already grouped - this means they would have one rate per priority
                        //Moreover the results are ordered based on their priority values
                        //This means the taxes need to be compounded from top down
                        if(mapCategoryAndTaxRates.containsKey(chargeCategory)){
                            decimal tempRate = mapCategoryAndTaxRates.get(chargeCategory);
                            rate = rate + (rate*tempRate/100) + tempRate;
                            mapCategoryAndTaxRates.remove(chargeCategory);
                            mapCategoryAndTaxRates.put(chargeCategory, rate);
                        } else {
                            mapCategoryAndTaxRates.put(chargeCategory, rate);
                        }   
                    } 

                    for(AggregateResult vatRate : vatRates) {
                        decimal rate = (Decimal)vatRate.get('Rate');
                        String chargeCategory = (String)vatRate.get(sPrefix+'Product_Charge_Category__c');
                        
                        //The results are already grouped - this means they would have one rate per priority
                        //Moreover the results are ordered based on their priority values
                        //This means the taxes need to be compounded from top down
                        if(mapCategoryAndVATRates.containsKey(chargeCategory)){
                            decimal tempRate = mapCategoryAndVATRates.get(chargeCategory);
                            rate = rate + (rate*tempRate/100) + tempRate;
                            mapCategoryAndVATRates.remove(chargeCategory);
                            mapCategoryAndVATRates.put(chargeCategory, rate);
                        } else {
                            mapCategoryAndVATRates.put(chargeCategory, rate);
                        }   
                    }
                }
                
                calculateSubtotal(jobClass, charges);
                calculateDiscountsAndTaxes(jobClass, charges, mapCategoryAndTaxRates, mapCategoryAndVATRates, iNoOfDecimalPlaces);
                calculateTotal(jobClass, charges, iNoOfDecimalPlaces);

                //Assign the charges to job
                jobClass.job.VAT__c = charges.vat;
                jobClass.job.Tax__c = charges.tax;
                
                jobClass.job.Discount_Value__c = charges.discountTotal;
                
                jobClass.job.Sub_Total__c = charges.subTotal;
                jobClass.job.Total__c = charges.grandTotal;
                jobClass.job.Total_Cost__c = charges.totalCost;
                jobClass.job.Net_Total__c = charges.netTotal;

                jobClass.job.Total_Profit__c = charges.totalProfit;
                jobClass.job.TotalProfitPercent__c = charges.totalProfitPercent;
              
        }

        public static void calculateSubtotal(JobClass jobClass, JobChargesCalculator.Charges charges)
        {
            decimal subTotal = 0.0;
            integer iNoOfDecimalPlaces = integer.valueOf(Configuration__c.getValues('NO_OF_DECIMALS_FOR_CURRENCY_VALUES').Number_Value__c);
            decimal sumOfPreviousCharges;
            
            for(JobProductClass jpc : jobClass.jobProducts)
            {
                for(JobRatePlanClass jrc : jpc.jobRatePlans)
                {
                   sumOfPreviousCharges = 0;
                   for(JobRatePlanChargeClass jrpc : jrc.jobRatePlanCharges)
                   {
                      //if the Price Format is percentage pricing, then calculate the price based on previous charges
                      if(jrpc.jobrateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_PERCENTAGE_PRICING && jrpc.jobrateplancharge.Quantity__c > 0 && jrpc.jobrateplancharge.Percentage_of_other_Charges__c != null) {
                            jrpc.jobrateplancharge.Price__c = (sumOfPreviousCharges * jrpc.jobrateplancharge.Percentage_of_other_Charges__c * jrpc.jobrateplancharge.Quantity__c)/100;
                            jrpc.jobrateplancharge.Unit_Price__c = (jrpc.jobrateplancharge.Price__c/jrpc.jobrateplancharge.Quantity__c);
                            
                            //Add the price to the subtotal(Fixed in 1.8.2)
                            subTotal += jrpc.jobrateplancharge.Price__c;
                      }
                      else {
                          if(jrpc.jobrateplancharge.Unit_Price__c != null && jrpc.jobrateplancharge.Quantity__c != null && jrpc.jobrateplancharge.Price_Format__c != CommonUtilClass.PRICE_FORMAT_TIERED)
                          {
                               //if the pricing is flat fee then consider the quantity as 1 
                               if(jrpc.jobrateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE) {
                                    jrpc.jobrateplancharge.Price__c = 1 * (jrpc.jobrateplancharge.Unit_Price__c);
                                    
                               }else{
                                    jrpc.jobrateplancharge.Price__c = (jrpc.jobrateplancharge.Quantity__c)*(jrpc.jobrateplancharge.Unit_Price__c);  
                               }
                               
                               jrpc.jobrateplancharge.Price__c = jrpc.jobrateplancharge.Price__c.setScale(iNoOfDecimalPlaces);  
                               
                               //Add the price to the subtotal
                               subTotal += jrpc.jobrateplancharge.Price__c;
                               
                               //Add to sumOfPreviousCharges
                               sumOfPreviousCharges += jrpc.jobrateplancharge.Price__c;
                          }   
                          
                          //If the jobrateplancharge is of priceformat Tiered Pricing, then we need to calculate the unit selling price from the tiers
                          if(jrpc.jobrateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_TIERED) {
                               JobCreationUtil.tieredPricing(jrpc);
                               jrpc.jobrateplancharge.Price__c = jrpc.jobrateplancharge.Price__c.setScale(iNoOfDecimalPlaces);  

                               //Add the price to the subtotal
                               subTotal += jrpc.jobrateplancharge.Price__c;
                               
                               //Add to sumOfPreviousCharges
                               sumOfPreviousCharges += jrpc.jobrateplancharge.Price__c;
                          }
                      }
                   } 
                }
            }
            charges.subTotal = subTotal;    
        }
        
        public static void calculateDiscountsAndTaxes(JobClass jobClass, JobChargesCalculator.Charges charges, map<String, decimal> mapCategoryAndTaxRates, map<String, decimal> mapCategoryAndVATRates, integer iNoOfDecimalPlaces)
        {
            string job_LevelDiscount_By = Configuration__c.getValues('DISCOUNT_BY_VALUE_OR_PERCENTAGE').String_Value__c;
            
            decimal subTotal = 0.0;
            decimal vat = 0.0;
            decimal tax = 0.0;
            decimal totalCost = 0.0;
            
            //try {
                decimal totalDiscountValue = 0.0;
                
                //this is executed on a click of update button on page3
                //here we are just using the charge discounts and summing upto order
                for(JobProductClass jpc : jobClass.jobProducts)
                {
                    for(JobRatePlanClass jrc : jpc.jobRatePlans)
                    {
                        for(JobRatePlanChargeClass jrpc : jrc.jobRatePlanCharges)
                        {
                            decimal vatPercentage = 0;
                            decimal taxPercentage = 0;
                            boolean applyDiscountPercentage = false;
                            
                           
                           // INVOICEIT-430, DhanaLaksmi, for existing records if value is applied then we need to convert into percentage to display when setting is flip flop
                           
                             if((jrpc.jobrateplancharge.Discount_Value__c  != null && jrpc.jobrateplancharge.Discount_Value__c > 0)
                                && (jrpc.jobrateplancharge.Discount_Percent__c <= 0 || jrpc.jobrateplancharge.Discount_Percent__c  == null) 
                                && jrpc.jobrateplancharge.Discount_Type__c == 'By Value'
                                && jrpc.jobrateplancharge.Discount_Type__c != null){
                                 if(jrpc.jobrateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE && jrpc.jobrateplancharge.Unit_Price__c > 0) {
                                        jrpc.jobrateplancharge.Discount_Percent__c = ((jrpc.jobrateplancharge.Discount_Value__c/jrpc.jobrateplancharge.Unit_Price__c) * 100).setscale(3,RoundingMode.HALF_UP); 
                                }else if(jrpc.jobrateplancharge.Price__c > 0){
                                        jrpc.jobrateplancharge.Discount_Percent__c = ((jrpc.jobrateplancharge.Discount_Value__c/jrpc.jobrateplancharge.Price__c) * 100).setscale(3,RoundingMode.HALF_UP);
                                } 
                            }
                           
                           
                            // if the discount type is null then populate the value accordingly to the discount custom setting, INVOICEIT-383, Laxman Rao M
                            if(jrpc.jobrateplancharge.Discount_Type__c == null || jrpc.jobrateplancharge.Discount_Type__c == '') {
                                if(job_LevelDiscount_By == CommonUtilClass.APPLY_DISCOUNT_BY_PERCENTAGE) {
                                    jrpc.jobrateplancharge.Discount_Type__c = CommonUtilClass.DISCOUNT_TYPE_PERCENTAGE;
                                }
                                //If discount type is 'Both'in custom settings, for new order display discount type as 'None', if discount type picklist field does not have any default value, previously they are populating default value as 'By Value'. INVOICEIT-430, Dhanalakshmi
                                else if(job_LevelDiscount_By == CommonUtilClass.APPLY_DISCOUNT_BY_VALUE){
                                    jrpc.jobrateplancharge.Discount_Type__c = CommonUtilClass.DISCOUNT_TYPE_VALUE;
                                }else{
                                    // INVOICEIT-430,added by ram, if setting as both and selected values as none then set the values as 0
                                    jrpc.jobrateplancharge.Discount_Percent__c = 0;
                                    jrpc.jobrateplancharge.Discount_Value__c = 0;
                                }
                            }else if(job_LevelDiscount_By == CommonUtilClass.APPLY_DISCOUNT_BY_PERCENTAGE){
                                jrpc.jobrateplancharge.Discount_Type__c = CommonUtilClass.DISCOUNT_TYPE_PERCENTAGE; 
                            }else if(job_LevelDiscount_By == CommonUtilClass.APPLY_DISCOUNT_BY_VALUE){
                                jrpc.jobrateplancharge.Discount_Type__c = CommonUtilClass.DISCOUNT_TYPE_VALUE;
                            }

                            // INVOICEIT-383, Laxman Rao M
                            if(jrpc.jobrateplancharge.Discount_Type__c == CommonUtilClass.DISCOUNT_TYPE_PERCENTAGE || jrpc.jobrateplancharge.Discount_Type__c == 'By Percentage') {
                                if(jrpc.jobrateplancharge.Discount_Percent__c  == null ) {
                                    jrpc.jobrateplancharge.Discount_Percent__c = 0;
                                }
                              
                                if(jrpc.jobrateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE) {
                                    jrpc.jobrateplancharge.Discount_Value__c = (1 * jrpc.jobrateplancharge.Unit_Price__c) * jrpc.jobrateplancharge.Discount_Percent__c/100;
                                }else{
                                    jrpc.jobrateplancharge.Discount_Value__c = (jrpc.jobrateplancharge.Quantity__c * jrpc.jobrateplancharge.Unit_Price__c) * jrpc.jobrateplancharge.Discount_Percent__c/100;                                
                                }   
                            }
                            
                            // INVOICEIT-430, DhanaLaksmi, if values is applied need to show the percentage
                            if(jrpc.jobrateplancharge.Discount_Type__c == CommonUtilClass.DISCOUNT_TYPE_VALUE || jrpc.jobrateplancharge.Discount_Type__c == 'By Value') {
                                if(jrpc.jobrateplancharge.Discount_Value__c  == null) {
                                    jrpc.jobrateplancharge.Discount_Value__c = 0;
                                }
                                if(jrpc.jobrateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE) {
                                    if(jrpc.jobrateplancharge.Unit_Price__c != 0)
                                    {
                                        jrpc.jobrateplancharge.Discount_Percent__c = ((jrpc.jobrateplancharge.Discount_Value__c/jrpc.jobrateplancharge.Unit_Price__c) * 100).setscale(3,RoundingMode.HALF_UP); 
                                    }
                                }else{
                                    if(jrpc.jobrateplancharge.Price__c != 0)
                                    {
                                        jrpc.jobrateplancharge.Discount_Percent__c = ((jrpc.jobrateplancharge.Discount_Value__c/jrpc.jobrateplancharge.Price__c) * 100).setscale(3,RoundingMode.HALF_UP);
                                    }
                                }   
                            }
                            
                            if(jrpc.jobrateplancharge.Discount_Value__c  == null) {
                                jrpc.jobrateplancharge.Discount_Value__c = 0;
                            }
                            
                            /*
                                Modified By : Ankit 04-12-13  INVOICEIT-291
                                Comments    : previously the discount value are not rounding to 2 decimal places at Order before saving in to database,
                                              now we are setting scale of the Decimal places using the rounding mode
                            */
                            //calculating grand total only if subtotal is > 0, INVOICEIT-649, Added by DL
                           
                                jrpc.jobrateplancharge.Discount_Value__c = jrpc.jobrateplancharge.Discount_Value__c.setscale(2,RoundingMode.HALF_UP);                                              
                                totalDiscountValue += jrpc.jobrateplancharge.Discount_Value__c;
                           
                            //Modified by Naveen M  SUP-352
                            jrpc.jobrateplancharge.Net_Total__c = jrpc.jobrateplancharge.Price__c - jrpc.jobrateplancharge.Discount_Value__c;
                            
                            if(jrpc.jobrateplancharge.Cost_Price__c == null) {
                               jrpc.jobrateplancharge.Cost_Price__c = 0;
                            }
                            
                            if(jrpc.jobrateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE) {
                                jrpc.jobrateplancharge.Cost__c = 1*(jrpc.jobrateplancharge.Cost_Price__c);  
                            }else{
                                jrpc.jobrateplancharge.Cost__c = (jrpc.jobrateplancharge.Quantity__c)*(jrpc.jobrateplancharge.Cost_Price__c);
                            }
                            
                            jrpc.jobrateplancharge.Cost__c = jrpc.jobrateplancharge.Cost__c.setScale(iNoOfDecimalPlaces);
                            
                            
                            jrpc.jobrateplancharge.Profit__c = jrpc.jobrateplancharge.Price__c - jrpc.jobrateplancharge.Cost__c - jrpc.jobrateplancharge.Discount_Value__c;
                           
                            
                            
                            //Calculate the tax for the charge category 
                            if(mapCategoryAndVATRates.containsKey(jrpc.jobrateplancharge.Product_Charge_Category__c)) {
                                vatPercentage = mapCategoryAndVATRates.get(jrpc.jobrateplancharge.Product_Charge_Category__c);
                            }
                            
                            //Calculate the tax for the charge category 
                            if(mapCategoryAndTaxRates.containsKey(jrpc.jobrateplancharge.Product_Charge_Category__c)) {
                                taxPercentage = mapCategoryAndTaxRates.get(jrpc.jobrateplancharge.Product_Charge_Category__c);
                            }
                            // Modified by Dev Ticket : INVOICEIT-434
                            if(!jobClass.job.Override_Vat_Tax__c) {
                                jrpc.jobrateplancharge.VAT_Percentage__c = vatPercentage;
                                jrpc.jobrateplancharge.Tax_Percentage__c = taxPercentage;
                                
                                if(jrpc.jobrateplancharge.Price_Format__c == CommonUtilClass.PRICE_FORMAT_FLAT_FEE) {
                                    jrpc.jobrateplancharge.VAT__c = ((1 * jrpc.jobrateplancharge.Unit_Price__c) - jrpc.jobrateplancharge.Discount_Value__c)*(vatPercentage/100);
                                    //If Tax engine is standard then calculate tax else we are calculating Avalara tax,INVOICEIT-675
                                    if(jobClass.job.Tax_Engine__c == System.Label.Standard || jobClass.job.Tax_Engine__c == '' || jobClass.job.Tax_Engine__c == null){
                                        jrpc.jobrateplancharge.Tax__c = ((1 * jrpc.jobrateplancharge.Unit_Price__c) - jrpc.jobrateplancharge.Discount_Value__c)*(taxPercentage/100);
                                    }
                                        
                                }else{
                                    jrpc.jobrateplancharge.VAT__c = ((jrpc.jobrateplancharge.Quantity__c * jrpc.jobrateplancharge.Unit_Price__c) - jrpc.jobrateplancharge.Discount_Value__c)*(vatPercentage/100);
                                    //If Tax engine is standard then calculate tax else we are calculating Avalara tax ,INVOICEIT-675
                                    if(jobClass.job.Tax_Engine__c == System.Label.Standard || jobClass.job.Tax_Engine__c == '' || jobClass.job.Tax_Engine__c == null){
                                        jrpc.jobrateplancharge.Tax__c = ((jrpc.jobrateplancharge.Quantity__c * jrpc.jobrateplancharge.Unit_Price__c) - jrpc.jobrateplancharge.Discount_Value__c)*(taxPercentage/100);
                                    }
                                }
                            }
                            
                            vat += jrpc.jobrateplancharge.VAT__c;
                            tax += jrpc.jobrateplancharge.Tax__c; 
                            
                            totalCost += jrpc.jobrateplancharge.Cost__c;
                        }
                    }
                }
                
                charges.vat = vat;
                charges.tax = tax;
                charges.totalCost = totalCost;
                charges.discountTotal = totalDiscountValue;
                
            
        }

        /**
         * This method calculates TotalPrice
         * @return totalPrice
         */
        public static void calculateTotal(JobClass jobClass, JobChargesCalculator.Charges charges, integer iNoOfDecimalPlaces)
        {
            charges.netTotal = charges.subTotal - charges.discountTotal;
            
            charges.grandTotal = charges.vat + charges.tax + charges.netTotal;

            if(charges.grandTotal > 0) { 
                charges.totalProfit = charges.netTotal - charges.totalCost;
                if(charges.subTotal > 0) {
                    charges.totalProfitPercent = charges.totalProfit/(charges.subTotal) * 100;
                } else {
                    charges.totalProfitPercent = 100;
                }
                          
                //depending upon custom settings value round up or round down is done
                String sRoundUpDown = Configuration__c.getValues('CALCULATION_PRECISION').String_Value__c;
        
                if(sRoundUpDown != null && sRoundUpDown.equals('ROUND_UP')) {
                    charges.subTotal = charges.subTotal.round(system.RoundingMode.CEILING);
                    charges.netTotal = charges.subTotal.round(system.RoundingMode.CEILING);
                    charges.grandTotal = charges.grandTotal.round(system.RoundingMode.CEILING);
                } else if(sRoundUpDown != null && sRoundUpDown.equals('ROUND_DOWN')) {
                    charges.subTotal = charges.subTotal.round();
                    charges.netTotal = charges.netTotal.round();
                    charges.grandTotal = charges.grandTotal.round();
                } else {
                    charges.subTotal = charges.subTotal.setScale(iNoOfDecimalPlaces);
                    charges.netTotal = charges.netTotal.setScale(iNoOfDecimalPlaces);
                    charges.grandTotal = charges.grandTotal.setScale(iNoOfDecimalPlaces);
                }
            }
            
            /*
                Modified By     : Ankit 07/03/2014 INVOICEIT-333
                Comments        : Set Net total calculation after the round off.
            */
            charges.netTotal = charges.subTotal - charges.discountTotal;        
            charges.grandTotal = charges.vat + charges.tax + charges.netTotal;
        }

        public class Charges {
            public decimal vat {get; set;} 
            public decimal tax {get; set;} 
            public decimal subTotal {get; set;}
            public decimal netTotal {get; set;}
            public decimal discountTotal {get; set;}
            public decimal grandTotal {get; set;}
            public decimal totalCost{get;set;}
            public decimal totalProfit{get; set;}
            public decimal totalProfitPercent{get; set;}
        }
    }