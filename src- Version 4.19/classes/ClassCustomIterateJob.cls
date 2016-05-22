//Deprecated class
	global with sharing class ClassCustomIterateJob implements Iterator<Job__c>{ 
	    //Deprecated
	    //Previously we were using this class in BatchInvoiceGeneration
	    //Now we have come with BatchInvoiceGeneration1 which process the orders
	    
	    global boolean hasNext() { 
	        return true;
	    }
	    
	    global Job__c next() {
	        return null;
	   } 
	}