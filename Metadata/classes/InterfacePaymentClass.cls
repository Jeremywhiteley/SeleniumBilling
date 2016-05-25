public with sharing class InterfacePaymentClass {
	    public Interface paymentOperationsInterface  {
	        PaymentOperations.PaymentResult handleAuthorize_Click();
	        PaymentOperations.PaymentResult handleAuthorizeAndCharge_Click(string transactionId, string gatewayID);
	        PaymentOperations.PaymentResult handleVoid_Click(string gatewayId, string transactionId, decimal transactionAmount);
	        PaymentOperations.PaymentResult handleRefund_Click(string gatewayId, string transactionId, decimal transactionAmount);
	    }
	}