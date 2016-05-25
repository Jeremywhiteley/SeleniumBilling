public with sharing class QuoteClass {
	    public Quote__c quote;
	    public List<QuoteProductClass> quoteProducts = new List<QuoteProductClass>();
	    public List<QuoteProductClass> getQuoteProducts() {
	        return quoteProducts;
	    }    
	    public Quote__c getQuote() {
	        return quote;
	    }    
	}