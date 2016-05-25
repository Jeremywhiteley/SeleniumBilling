public with sharing class QuoteRatePlanChargeClass {
        public Quote_Rate_Plan_Charge__c quoterateplancharge {get; set;}
        public Integer quoteRatePlanChargeCounter {get; set;}
        
        public QuoteRatePlanChargeTierClass[] quoteRatePlanChargeTiers = new List<QuoteRatePlanChargeTierClass>();
        public List<QuoteRatePlanChargeTierClass> getQuoteRatePlanChargeTiers()
        {
            return quoteRatePlanChargeTiers;
        }
        
        //Below are used in product bundle concept
        public Boolean displayRemove  {get;set;}
        public Boolean isQuantityEditable  {get;set;}
        
        public QuoteRatePlanChargeClass() {
            isQuantityEditable = true;
        }
        
        /*Laxman added delete this*/
        public Quote_Product__c quoteProduct {get; set;}
    }