public with sharing class QuoteProductClass {
	    public Quote_Product__c quoteproduct {get; set;}
	    public QuoteRatePlanClass[] quoteRatePlans = new List<QuoteRatePlanClass>();
	    public Integer quoteProductCounter;
	    public List<QuoteRatePlanClass> getQuoteRatePlans() {
	        return quoteRatePlans;
	    }
	}