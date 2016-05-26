public with sharing class QuoteRatePlanClass {
	    public Quote_Rate_Plan__c quoterateplan {get; set;}
	    public QuoteRatePlanChargeClass [] quoteRatePlanCharges = new List<QuoteRatePlanChargeClass>();
	    public List<QuoteRatePlanChargeClass> getQuoteRatePlanCharges()
	    {
	        return quoteRatePlanCharges;
	    }
	    public Integer quoteRatePlanCounter {get; set;}

	    /*Laxman added delete this*/
	    public QuoteRatePlanChargeClass[] quoteRatePlanChargesNew {get; set;}
	}