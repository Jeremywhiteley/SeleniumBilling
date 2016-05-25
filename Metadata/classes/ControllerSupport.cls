public with sharing class ControllerSupport {
	    public PageReference initPageAction() {
	        String url = Configuration__c.getValues('SUPPORT_PAGE_URL').String_Value__c;
	        
	        PageReference homePage = new PageReference(url);
	        homePage.setRedirect(true);  
	        return homePage;
	   }
	}