global with sharing class ClassIterateJob implements Iterable<Job__c> {
	   global Iterator<Job__c> Iterator() {
	      return new ClassCustomIterateJob();
	   }
	}