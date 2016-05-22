global Class InvoiceSOAPAPI {

    global string generateInvoice(string jobId) {
        Job__c job = new Job__c(Id = jobId);
        ApexPages.StandardController stdController = new ApexPages.StandardController(job);
        ControllerGenerateInvoice controllerGenerateInvoice = new ControllerGenerateInvoice(stdController);
        controllerGenerateInvoice.isAPIRequest = true;
        return controllerGenerateInvoice.generateInvoiceAPI();
    }    
}