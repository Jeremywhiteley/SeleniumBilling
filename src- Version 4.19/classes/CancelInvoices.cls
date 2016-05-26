public  with sharing class CancelInvoices {
        private static final Integer PAGE_SIZE =100;    
        Invoice_Run__c invoiceRun ; 
        public String invoiceRunName{get;set;}
        Invoice_Run__c invoiceRunRecord;       
        public Integer page{get;set;}
        public Integer totalRecords{get;set;}
        public Integer totalPages{get;set;}
        public Integer startIdx{get;set;}
        public Integer endIdx{get;set;}
        public List<InvoiceWrapper> listinvoice{get;set;}
        public CancelInvoices(ApexPages.StandardController controller)
        {
            invoiceRun = (Invoice_Run__c) controller.getRecord(); 
            invoiceRunRecord = [SELECT Id,Name FROM Invoice_Run__c WHERE Id =:invoiceRun.id]; 
            invoiceRunName = invoiceRunRecord.Name; 
            this.listinvoice = new List<InvoiceWrapper>();
            this.page = 1;
            getInvoices();
       
        }   
        public Pagereference invoiceSelected(){    
            set<id> setOfInvoice = new set<id>();
             for(InvoiceWrapper invoiceWra :  listinvoice){
                if(invoiceWra.isSelected){ 
                    setOfInvoice.add(invoiceWra.invoices.id);   
                                
                }            
            }        
            if(setOfInvoice.size()>0){
                BatchCancelInvoices b = new BatchCancelInvoices(setOfInvoice);
                database.executebatch(b,1);
            }else{
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.TherearenoInvoiceselected));            
            }
            return new PageReference('/' + invoiceRun.id);        
        } 
        Public Pagereference allInvoice(){
        
                    
            map<Id, Invoice__c> mapOfInvoices = new map<Id, Invoice__c>([SELECT Id,Invoice_Run_Created_By__c,Invoice_State__c,Invoice_Status__c,Name,Amount__c,Account__r.Name,Invoice_Date__c FROM Invoice__c  WHERE Invoice_Status__c != 'Cancelled' AND Invoice_Status__c != 'Posted' AND Invoice_Run_Created_By__c=:invoiceRun.ID ORDER BY Name]);
           
            if(mapOfInvoices.size()>0){    
                        
                BatchCancelInvoices b = new BatchCancelInvoices(mapOfInvoices.keyset());
                database.executebatch(b,1);
            }else{             
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.ThereAreNoInvoicesToDisplay));
            }
            return new PageReference('/' + invoiceRun.id);  
        }
        public void doNext(){
            
            if(getHasNext()){
                this.page++;
                getInvoices();
            }
     
        }
        public Boolean getHasNext(){
            if(this.page<this.totalPages){
                return true;
            }
            else{
                return false;
            }
        }
        public void doPrevious(){
            
            if(getHasPrevious()){
                this.page--;
                getInvoices();
            }
    }
          public Boolean getHasPrevious(){
            if(this.page>1){
                return true;
            }
            else{
                return false;
            }
        } 
        public List<InvoiceWrapper> getInvoices(){
            this.startIdx = (this.page-1)*PAGE_SIZE;
            this.endIdx = this.page*PAGE_SIZE;
            if(listinvoice!=null){
              List<InvoiceWrapper> listinvoice=new List<InvoiceWrapper>();
                this.totalRecords = 0;
        
                this.listinvoice.clear();
                for(Invoice__c invoice : [SELECT Id,Invoice_Run_Created_By__c,Invoice_State__c,Invoice_Status__c,Name,Amount__c,Account__r.Name,Invoice_Date__c FROM Invoice__c  WHERE Invoice_Status__c != 'Cancelled' AND Invoice_Status__c != 'Posted' AND Invoice_Run_Created_By__c=:invoiceRun.ID]){
                if(this.totalRecords>=this.startIdx && this.totalRecords<this.endIdx){  
                InvoiceWrapper invwrap=new InvoiceWrapper(invoice , false);      
                this.listinvoice.add(invwrap );
                }
                this.totalRecords++;
         }
            Decimal pages = Decimal.valueOf(this.totalRecords);
            pages = pages.divide(Decimal.valueOf(PAGE_SIZE), 2);
            this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);
          }  
            this.startIdx++;
            if(this.endIdx>this.totalRecords){
                this.endIdx = this.totalRecords;
            }        
           
            return listinvoice;
        }
        public with sharing class InvoiceWrapper{
            public Invoice__c invoices{get;set;}
            public Boolean IsSelected{get;set;}
            public InvoiceWrapper( Invoice__c invoices,  Boolean IsSelected){
            this.invoices=invoices;
            this.IsSelected=IsSelected;
            }
        }    
    }