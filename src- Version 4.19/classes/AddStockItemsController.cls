public with sharing class AddStockItemsController {
        public String searchstring { get; set; }
        public String objectname { get; set; }
        public String searchfields { get; set; }
        public String displayfields { get; set; }
        public String orderfield { get; set; }
        public String sFilterCriteria { get; set; }
        public String sProductsLimit { get; set; }
        public string sStockStatus{ get; set; }
        public string sBarcodes { get; set; }
        list<Stock_Item__c> listofstockItems ;
        public list<Product__c> listdisplayProducts{ get; set; }
        Stock_Item__c stockStatusPicklist;
        public string selectedProductId;
        public map<String,Configuration__c> mapConfiguration;

        public AddStockItemsController(ApexPages.StandardController controller) {
            stockStatusPicklist = (Stock_Item__c) controller.getRecord();
            mapConfiguration = Configuration__c.getAll();
            listdisplayProducts = new list<Product__c>();
            //displayfields = mapConfiguration.get('PRODUCT_DISPLAYFIELDS').String_Value__c; 
            displayfields = '';
            objectname = mapConfiguration.get('PRODUCT_OBJECTNAME').String_Value__c;
            orderfield = mapConfiguration.get('PRODUCT_ORDERFIELD').String_Value__c;
            searchfields = mapConfiguration.get('PRODUCT_SEARCHFIELDS').String_Value__c;
            sProductsLimit = '' + (mapConfiguration.get('PRODUCT_SEARCH_LIMIT').Number_Value__c).intValue();
            searchstring = '';
            sFilterCriteria = '';   
        }

        public void addProductDetail() {
            selectedProductId = system.currentPageReference().getParameters().get('productId');
            listdisplayProducts = [SELECT Name 
                                   FROM Product__c 
                                   WHERE Id =: selectedProductId];
                                   
            searchstring = listdisplayProducts.get(0).Name;       
        }

        // This method is used to insert the stockitems
        public void insertStockItems() {
            Stock_Item__c stockItem;
            try {    
                listofstockItems = new list<Stock_Item__c>();
                if(selectedProductId != null && sBarcodes.trim().length() > 0) {
                    list<string> listOfbarcodes = sBarcodes.split('\n');    
                    Integer iBarCodesSize = 0;            

                    for(string s : listOfbarcodes) {                                       
                        if(s != null && s.trim()!='') {
                            stockItem = new Stock_Item__c();
                            stockItem.Product__c = selectedProductId;
                            stockItem.Available_Quantity__c = 1;  
                            stockItem.Received_Quantity__c = 1;
                            stockItem.Stock_Entry_Date__c = stockStatusPicklist.Stock_Entry_Date__c;
                            stockItem.Stock_Reference__c = stockStatusPicklist.Stock_Reference__c;
                            //stockItem.Name = s;
                            stockItem.Bar_Code__c = s;
                            listofstockItems.add(stockItem); 
                            iBarCodesSize++;
                        }
                    }              
                    upsert listofstockItems;

                    Apexpages.Message sucessMessage = new Apexpages.Message(ApexPages.Severity.CONFIRM,iBarCodesSize + ' ' + system.Label.AddStockItemsController_Stock_items_successfully);
                    Apexpages.addMessage(sucessMessage);
                    searchstring = null;
                    sBarcodes = null;
                    selectedProductId = null;
                    stockStatusPicklist.Stock_Reference__c = null;
                    stockStatusPicklist.Stock_Entry_Date__c = system.now();
                    listdisplayProducts.clear();
                } else {
                    Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO, system.Label.AddStockItemsController_search_the_product);
                    Apexpages.addMessage(infoMessage);
                }
            } catch(DMLException dMlEx){
                // Added by Mani ticket : INVOICEIT-310
                Apexpages.Message errorMessage; 
                for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                { 
                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                    Apexpages.addMessage(errorMessage);      
                } 

            }catch(Exception ex) {
                Apexpages.Message errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName()+':'+ex.getMessage() + ':LINE ' + ex.getLineNumber());
                Apexpages.addMessage(errorMessage);
            }
        }
    }