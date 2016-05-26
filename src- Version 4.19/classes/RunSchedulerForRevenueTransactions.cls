global with sharing class RunSchedulerForRevenueTransactions implements Schedulable {
	    global void execute(SchedulableContext context) {
	        BatchProcessRevenueForInvoiceLines batch = new BatchProcessRevenueForInvoiceLines(null);
	        Database.executeBatch(batch, 30);
	    }
	}