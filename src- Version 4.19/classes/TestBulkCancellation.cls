@isTest(seeAlldata = true)
private class TestBulkCancellation{
    static testMethod void myUnitTest() {
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        Contact contact =  new Contact(LastName = 'Laxman', AccountId = account.Id);                                 
        insert contact;
        
        Currency__c currencyObj = new Currency__c(Name = 'GBP',Symbol__c = '£1');
        insert currencyObj;   
        
        Product__c product = new  Product__c(Name = 'Product', Valid_From_Date__c = system.today() - 100,Valid_To_Date__c = system.today() + 100,Product_Family__c = 'Default',Product_Code__c = 'Code1',Description__c = 'Product');
        insert product;
        
        Product__c productAdv = new  Product__c(Name = 'Product', Valid_From_Date__c = system.today() - 100,Valid_To_Date__c = system.today() + 100,Product_Family__c = 'Default',Product_Code__c = 'Code1',Description__c = 'Product');
        insert productAdv;
        Job__c job = new Job__c(Name = 'Test Job', 
                Account__c = account.Id,
                Billing_Contact__c = contact.Id,
                Shipping_Contact__c = contact.Id,
                Number_Of_Terms__c = 24,
                CurrencyL__c = currencyObj.Id,
                Start_Date__c = system.today(), 
                Service_Activation_Date__c = system.today(), 
                Service_End_Date__c = system.today().addMonths(10),
                Preferred_Billing_Day__c = '1'
        );   
        insert job;
        Invoice_RunScheduler__c runScheduler = new Invoice_RunScheduler__c(Name = 'InvoiceRun', Invoice_Currency__c = currencyObj.Id,Type__c = 'Once', Invoice_Date__c = system.today(), Target_Date__c = system.today());
        insert runScheduler;
        
        Invoice_Run__c invoiceRun = new Invoice_Run__c(Name = 'InvoiceRun' , Status__c = 'Started');
        insert invoiceRun;
        
        list<Invoice__c> listInvoice = new list<Invoice__c>();
        Invoice__c invoice = new Invoice__c(Account__c = account.id,
                                            Billing_Contact__c = contact.Id,
                                            Shipping_Contact__c = contact.Id,
                                            CurrencyL__c = currencyObj.Id, 
                                            Target_Date__c = Date.today(),
                                            Delivery_Type__c = 'Both',
                                            Invoice_Status__c = 'Draft',
                                            Payment_Request_Amount__c = 20,
                                            Invoice_Run_Created_By__c = invoiceRun.Id  ,
                                            Due_Date__c = system.today() + 100,
                                            Invoice_Date__c = system.today()                                   
                                            );
        insert invoice;
        list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
        listInvoiceLines.add(new Invoice_Lines__c(Product__c = product.id, Invoice__c = invoice.id, Charge_Date__c = system.today(), Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id , Service_End_Date__c = system.today()));
        listInvoiceLines.add(new Invoice_Lines__c(Product__c = product.id, Invoice__c = invoice.id, Charge_Date__c = system.today(), Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id, Service_End_Date__c = system.today()-1));
        listInvoiceLines.add(new Invoice_Lines__c(Product__c = productAdv.id, Invoice__c = invoice.id, Charge_Date__c = system.today(), Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id, Service_End_Date__c = system.today()+1));
        insert listInvoiceLines;
        ApexPages.StandardController stdobj =new ApexPages.StandardController(invoiceRun);
        CancelInvoices  cancelInvoices = new CancelInvoices (stdobj);          
        for(cancelInvoices.InvoiceWrapper vInvoiceWra : cancelInvoices.listinvoice){
          vInvoiceWra.isSelected = true;
        }        
        cancelInvoices.invoiceSelected(); 
        cancelInvoices.allInvoice();  
        cancelInvoices.doNext();
        cancelInvoices.doPrevious();
        cancelInvoices.getHasPrevious();
        cancelInvoices.getHasNext();
        Invoice_Run__c invoiceRun1 = new Invoice_Run__c(Name = 'InvoiceRun' , Status__c = 'Started');
        insert invoiceRun1;
        System.assertEquals('InvoiceRun', invoiceRun1.Name);
        ApexPages.StandardController stdobj1 =new ApexPages.StandardController(invoiceRun1);
        CancelInvoices  cancelInvoices1 = new CancelInvoices (stdobj1);
        for(cancelInvoices.InvoiceWrapper vInvoiceWra : cancelInvoices.listinvoice){
          vInvoiceWra.isSelected = false;
        }
        cancelInvoices.invoiceSelected();
        cancelInvoices.allInvoice(); 
    }

}