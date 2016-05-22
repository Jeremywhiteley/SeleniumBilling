/**
 * This class contains unit tests for validating the behavior of controllerForExportImportTemplate classes
 * created By Asish
 */
@isTest
private class TestControllerForExportImportTemplate {

    static testMethod void controllerForExportImportTemplate() {
        
        //poplulate the data
        Date validtodate = Date.today();   
        list<Product__c> listProducts = new list<Product__c>();
        Product__c product;
        for(Integer x = 0;x < 2;x++){
          product = new  Product__c(Name = 'Test Product' + x,Valid_From_Date__c = validtodate,Valid_To_Date__c = validtodate,Product_Family__c = 'Default',Product_Code__c = 'AC001',Description__c = 'Product');
          listProducts.add(product);
        }    
        insert listProducts;
        
        list<Product_Rate_Plan__c> listProductRatePlans = new list<Product_Rate_Plan__c>();
        Product_Rate_Plan__c productRatePlan;
        for(Integer x = 0;x< 2;x++){
          productRatePlan = new  Product_Rate_Plan__c(Name = 'Test ProductRatePlan' + x,
                                                      Product__c = listProducts.get(0).Id,Valid_From_Date__c = validtodate,Valid_To_Date__c = validtodate);
          listProductRatePlans.add(productRatePlan);
        }
        insert listProductRatePlans;
            
        list<Currency__c> listCurrencys = new list<Currency__c>();
        listCurrencys.add(new Currency__c(Name = 'GBP', Currency_Symbol__c = 'sss',Symbol__c = 's'));
        insert listCurrencys;
        
        list< Product_Rate_Plan_Charge__c> listProductRatePlanCharges = new list< Product_Rate_Plan_Charge__c>();
        Product_Rate_Plan_Charge__c productRatePlanCharge;
        for(Integer x = 0;x < 5;x++){
          productRatePlanCharge = new  Product_Rate_Plan_Charge__c(Name = 'Test ProductRatePlan Charge' + x,CurrencyL__c = listCurrencys.get(0).Id,
                                                                   Product_Rate_Plan__c = listProductRatePlans.get(0).Id,
                                                                   Unit_price__c = 200,Cost_Price__c = 160,Product_Charge_Category__c = 'Taxable');
          listProductRatePlanCharges.add(productRatePlanCharge);
        }
        insert listProductRatePlanCharges;
        
        //import the data
        ControllerForExportImportTemplate controllerForExportImportTemplate = new ControllerForExportImportTemplate();
        controllerForExportImportTemplate.exportProductsToCsvForSample();
        string csvBuild = controllerForExportImportTemplate.recStr;
        system.assert(csvBuild.contains('Test Product'));
        //export the dat
        string str = '"';
        controllerForExportImportTemplate.uploadCSV();
        controllerForExportImportTemplate.parseCSV(str);
        
        str += 'Product Family,Valid From Date,Product Code,Valid To Date,Description,Product Name,Valid To Date,Description,Product Rate Plan Name,Valid From Date,Accounting Code,Unit Cost Price,Charge Sequence Number,Price Type,Currency,UOM,Unit Selling Price,Charge Name,Product Charge Category,Price Format,Is Price Editable In Quote/Order Wizards';
        str += '\n';
        str += '13-12-2011,13-12-2021,13-12-2021 00:00,13-12-2011 00:00,13-12-2011,13-12-2021,13-12-2021 00:00,13-12-2011 00:00';
        str +='"';
        blob b = blob.valueOf(str);
        controllerForExportImportTemplate.contentFile = b;
        controllerForExportImportTemplate.uploadCSV();
        controllerForExportImportTemplate.parseCSV(str);
        controllerForExportImportTemplate.exportCsv();
        controllerForExportImportTemplate.downloadTemplateCsv();
        
    }
    
}