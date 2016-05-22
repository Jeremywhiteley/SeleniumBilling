global with sharing class RunSchedulerPaymentPlanInstallments implements Schedulable {
	     global void execute(SchedulableContext context) {
	         BatchChargePaymentPlanInstallmentProcess batch = new BatchChargePaymentPlanInstallmentProcess(system.today());
	         ID batchprocessid = Database.executeBatch(batch, 1); 
	     }
	}