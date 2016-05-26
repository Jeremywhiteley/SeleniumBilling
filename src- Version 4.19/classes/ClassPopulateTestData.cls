public with sharing class ClassPopulateTestData {

    //-------------Genric Methods------------------------//
    public static void createCustomSettings() {
        ControllerInsertCustomSettings ControllerInsertCustomSettings = new ControllerInsertCustomSettings();
        ControllerInsertCustomSettings.insertValues();
    }

    public static void createTaxAndVatRates() {
        list<Tax_Rate__c> listOfTaxAndVatRates = new list<Tax_Rate__c>();
        listOfTaxAndVatRates.add(new Tax_Rate__c(Tax_VAT__c = 'Tax', 
                Country__c = 'Canada', 
                State__c = 'Prince Edward Island',
                City__c = '*', 
                Product_Charge_Category__c = 'Taxable', 
                Rate__c = 10, Priority__c = '1')
        );

        listOfTaxAndVatRates.add(new Tax_Rate__c(Tax_VAT__c = 'Tax', 
                Country__c = 'Canada', 
                State__c = 'Prince Edward Island',
                City__c = '*', 
                Product_Charge_Category__c = 'Taxable', 
                Rate__c = 5, Priority__c = '2')
        );

        listOfTaxAndVatRates.add(new Tax_Rate__c(Tax_VAT__c = 'VAT', 
                Country__c = 'Canada', 
                State__c = 'Prince Edward Island',
                City__c = '*', 
                Product_Charge_Category__c = 'Taxable', 
                Rate__c = 10)
        );

        listOfTaxAndVatRates.add(new Tax_Rate__c(Tax_VAT__c = 'VAT', 
                Country__c = 'Canada', 
                State__c = 'Prince Edward Island',
                City__c = '*', 
                Product_Charge_Category__c = 'Taxable', 
                Rate__c = 10)
        );

        listOfTaxAndVatRates.add(new Tax_Rate__c(Tax_VAT__c = 'VAT', 
                Country__c = 'Canada', 
                State__c = 'Prince Edward Island',
                City__c = '*', 
                Product_Charge_Category__c = 'Taxable', 
                Rate__c = 10, Priority__c = '1')
        );

        listOfTaxAndVatRates.add(new Tax_Rate__c(Tax_VAT__c = 'VAT', 
                Country__c = 'Canada', 
                State__c = 'Prince Edward Island',
                City__c = '*', 
                Product_Charge_Category__c = 'Taxable', 
                Rate__c = 10, 
                Priority__c = '2')
        );
        insert listOfTaxAndVatRates;
    }

    public static list<Discount_Code__c> createDiscountCodes(Currency__c currencyObj) {
        list<Discount_Code__c> discounts = new  list<Discount_Code__c>();

        Discount_Code__c d = new Discount_Code__c(Name = 'san', 
                Valid_From__c = system.today(), 
                Price_Type__c = '*', 
                Discount_Value__c = 20, 
                Apply_to__c = 'Charge level',
                Currency__c = currencyObj.Id, 
                Product_Family__c = '*');
        discounts.add(d);       

        Discount_Code__c d2 = new Discount_Code__c(Name = 'san2', 
                Valid_From__c = system.today(), 
                Price_Type__c = '*', 
                Discount_Percent__c = 10, 
                Apply_to__c = 'Charge level',
                Currency__c = currencyObj.Id, 
                Product_Family__c = '*'
        );                               
        discounts.add(d2);  

        Discount_Code__c d3 = new Discount_Code__c(Name = 'san3', 
                Valid_From__c = system.today(), 
                Price_Type__c = '*', 
                Discount_Value__c = 10, 
                Apply_to__c = 'Quote/Order level',
                Currency__c = currencyObj.Id, 
                Product_Family__c = '*'
        );                               
        discounts.add(d3);

        Discount_Code__c d4 = new Discount_Code__c(Name = 'san4', 
                Valid_From__c = system.today(), 
                Price_Type__c = '*', 
                Discount_Percent__c = 10, 
                Apply_to__c = 'Quote/Order level',
                Currency__c = currencyObj.Id, 
                Product_Family__c = '*'
        );                               
        discounts.add(d4);

        insert discounts;   

        return discounts;
    }

    // this method creates the account
    public static Account createAccount() {
        Account account = new Account(Name = 'Test Account', 
                Preferred_Billing_Day__c = string.ValueOf(system.Today().Day()),
                BillingCountry = 'India'
        );
        insert account;

        return account;
    }

    // this method creates the contact
    public static list<Contact> createContacts(Account account) {

        list<Contact> listOfContacts = new list<Contact>();
        listOfContacts.add(new Contact(LastName = 'Sandeep' ,
                AccountId = account.Id ,
                MailingCountry = 'UK',
                Email = 'acertisUK@gmail.com')
        );

        listOfContacts.add(new Contact(LastName = 'Manoj GanPathy',
                AccountId = account.Id, 
                MailingCountry = 'Canada',
                MailingState = 'Prince Edward Island',
                Email = 'acertisIN@gmail.com')
        );   
        
        listOfContacts.add(new Contact(LastName = 'Laxman',
                AccountId = account.Id, 
                MailingCountry = 'USA',
                MailingCity = 'Test',
                MailingPostalCode = '898979',
                MailingState = 'Prince Edward Island',
                Email = 'acertisIN@gmail.com')
        );                                 
        insert listOfContacts;

        return listOfContacts;
    }

    // this method creates the Currencies
    public static list<Currency__c> currencies() {
        list<Currency__c> currencies = new list<Currency__c>();
        currencies.add(new Currency__c(Name = 'GBP', 
                Symbol__c = '£1')
        );

        currencies.add(new Currency__c(Name = 'USD', 
                Symbol__c = '$2')
        );

        currencies.add(new Currency__c(Name = 'EUR', 
                Symbol__c = '€3')
        );    
        insert currencies;   

        return currencies;
    }

    //this method is used for creating order
    public static Job__c createOrder(Account account, Contact contact, Currency__c currencyObj) {
        Job__c job = new Job__c(Name = 'Test Job', 
                Account__c = account.Id,
                Billing_Contact__c = contact.Id,
                Shipping_Contact__c = contact.Id,
                Number_Of_Terms__c = 24,
                CurrencyL__c = currencyObj.Id,
                Start_Date__c = system.today(), 
                Service_Activation_Date__c = system.today(), 
                Service_End_Date__c = system.today().addMonths(10),
                Preferred_Billing_Day__c = '01'
        );
        insert job;

        return job;
    }

    //this method is used for creating invoice
    public static Invoice__c createInvoice(Account account, Contact contact, Currency__c currencyObj) {
        Invoice__c invoice = new Invoice__c(Account__c = account.id,
                                            Billing_Contact__c = contact.Id,
                                            Shipping_Contact__c = contact.Id,
                                            CurrencyL__c = currencyObj.Id, 
                                            Target_Date__c = Date.today(),
                                            Delivery_Type__c = 'Both',
                                            Invoice_Status__c = 'Posted',
                                            Payment_Request_Amount__c = 20                                          
                                            );
        insert invoice;

        return invoice;
    }

    //this method is used for creating list of invoice lines
    public static list<Invoice_Lines__c> createListOfInvoiceLines(Invoice__c invoice, Job__c job) {

        list<Invoice_Lines__c> listInvoiceLines = new list<Invoice_Lines__c>();
        listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Charge_Date__c = system.today(), Line_Name__c = 'Broadband Installation For L',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
        listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Charge_Date__c = system.today(), Line_Name__c = 'Broadband Installation For X',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
        listInvoiceLines.add(new Invoice_Lines__c(Invoice__c = invoice.id, Charge_Date__c = system.today(), Line_Name__c = 'Broadband Installation For M',Quantity__c = 1,Unit_Price__c = 40.00,VAT__c = 8.00,Line_Amount__c = 40.00,Job__c = job.Id));
        insert listInvoiceLines;

        return listInvoiceLines;
    }

    //this method is used for creating payment
    public static Payment__c createPayment(Account account, Currency__c currencyObj) {

        Payment__c payment = new Payment__c(Account__c = account.Id, Currency__c = currencyObj.Id, Amount__c = 200000);
        insert payment;

        return payment;
    }

    //this method is used for creating payment gateway
    public static Gateway__c createGateway() {

        Gateway__c gateway = new Gateway__c(Active__c = true, Gateway_Type__c = 'PayPal', Test_Mode__c = true, Merchant_ID__c = '22LbQ9b7', Security_Key__c = '8Fh7VnPV3e6h4b4S', Merchant_Seal_User_Id__c = '8Fh7VnPV3e6h4b4S...');
        insert gateway;

        return gateway;
    }

    //creating product 
    public static list<Product__c> createProduct(){
        list<Product__c> listProducts = new list<Product__c>();
        Date validtodate = Date.today();
        Product__c product;
        for(Integer x = 0;x < 1;x++){
            product = new  Product__c(Name = 'Test Product' + x,Valid_From_Date__c = validtodate,Valid_To_Date__c = validtodate,Product_Family__c = 'Default',Product_Code__c = 'Code1',Description__c = 'Product');
            listProducts.add(product);
        } 
        Product__c productTiers = new  Product__c(Name = 'Test Product for tiers',Valid_From_Date__c = validtodate,Valid_To_Date__c = validtodate,Product_Family__c = 'Default',Product_Code__c = 'Code1',Description__c = 'Product');
        listProducts.add(productTiers);
        insert listProducts;

        return listProducts;
    }

    //create product rate plan
    public static list<Product_Rate_Plan__c> createProductRatePlan(Product__c product){
        Date validtodate = Date.today();
        list<Product_Rate_Plan__c> listProductRatePlans = new list<Product_Rate_Plan__c>();
        Product_Rate_Plan__c productRatePlan;
        for(Integer x = 0;x< 1;x++){
            productRatePlan = new  Product_Rate_Plan__c(  Name = 'Test ProductRatePlan' + x,
                    Product__c = product.Id,
                    Valid_From_Date__c = validtodate,Valid_To_Date__c = validtodate);
            listProductRatePlans.add(productRatePlan);
        }

        Product_Rate_Plan__c productRatePlanTiers = new Product_Rate_Plan__c(Name = 'Test ProductRatePlan tiers',
                Product__c = product.Id,
                Valid_From_Date__c = validtodate,Valid_To_Date__c = validtodate);

        listProductRatePlans.add(productRatePlanTiers);
        insert listProductRatePlans;

        return listProductRatePlans;

    }

    //creating product rate plan charges
    public static list<Product_Rate_Plan_Charge__c> createProductRatePlanCharge(Product_Rate_Plan__c productRatePlan,Currency__c currencyObj){
        list<Product_Rate_Plan_Charge__c> listProductRatePlanCharges = new list< Product_Rate_Plan_Charge__c>();
        Product_Rate_Plan_Charge__c productRatePlanCharge;
        Product_Rate_Plan_Charge__c productRatePlanCharge2;
        
            Product_Rate_Plan_Charge__c productRatePlanCharge_SetUp = new Product_Rate_Plan_Charge__c(Name = 'Setup Charges',
                                                                  CurrencyL__c = currencyObj.Id,
                                                                  Product_Rate_Plan__c = productRatePlan.Id,
                                                                  Unit_price__c = 1000,
                                                                  Cost_Price__c = 500,
                                                                  Product_Charge_Category__c = 'Taxable',
                                                                  Price_Type__c = 'One Time'
                                                                  );
            listProductRatePlanCharges.add(productRatePlanCharge_SetUp);
            
            Product_Rate_Plan_Charge__c productRatePlanCharge_Monthly = new Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                                                                  CurrencyL__c = currencyObj.Id,
                                                                  Product_Rate_Plan__c = productRatePlan.Id,
                                                                  Unit_price__c = 500,
                                                                  Cost_Price__c = 250,
                                                                  Product_Charge_Category__c = 'Taxable',
                                                                  Price_Type__c = 'Monthly'
                                                                  );                                                       
            listProductRatePlanCharges.add(productRatePlanCharge_Monthly);
            
            Product_Rate_Plan_Charge__c productRatePlanCharge_Usage = new Product_Rate_Plan_Charge__c(Name = 'Usage Charges',
                                                                  CurrencyL__c = currencyObj.Id,
                                                                  Product_Rate_Plan__c = productRatePlan.Id,
                                                                  Unit_price__c = 0,
                                                                  Cost_Price__c = 0,
                                                                  Product_Charge_Category__c = 'Taxable',
                                                                  Price_Type__c = 'Usage',
                                                                  Price_Format__c = CommonUtilClass.PRICE_FORMAT_VOLUME
                                                                  ); 
          listProductRatePlanCharges.add(productRatePlanCharge_Usage);
          
          Product_Rate_Plan_Charge__c productRatePlanCharge_Usage_Tier = new Product_Rate_Plan_Charge__c(Name = 'Usage Charges',
                                                                  CurrencyL__c = currencyObj.Id,
                                                                  Product_Rate_Plan__c = productRatePlan.Id,
                                                                  Unit_price__c = 0,
                                                                  Cost_Price__c = 0,
                                                                  Product_Charge_Category__c = 'Taxable',
                                                                  Price_Type__c = 'Usage',
                                                                  Price_Format__c = CommonUtilClass.PRICE_FORMAT_TIERED
                                                                  );
          listProductRatePlanCharges.add(productRatePlanCharge_Usage_Tier);
          
          Product_Rate_Plan_Charge__c productRatePlanCharge_OptionAnnual = new Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                                                                  CurrencyL__c = currencyObj.Id,
                                                                  Product_Rate_Plan__c = productRatePlan.Id,
                                                                  Unit_price__c = 500,
                                                                  Cost_Price__c = 250,
                                                                  Product_Charge_Category__c = 'Taxable',
                                                                  Price_Type__c = System.Label.OptionAnnual
                                                                  );
           listProductRatePlanCharges.add(productRatePlanCharge_OptionAnnual);
           
           Product_Rate_Plan_Charge__c productRatePlanCharge_HalfYearly = new Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                                                                  CurrencyL__c = currencyObj.Id,
                                                                  Product_Rate_Plan__c = productRatePlan.Id,
                                                                  Unit_price__c = 500,
                                                                  Cost_Price__c = 250,
                                                                  Product_Charge_Category__c = 'Taxable',
                                                                  Price_Type__c = System.Label.OptionHalfYearly
                                                                  );
            listProductRatePlanCharges.add(productRatePlanCharge_HalfYearly);
            
            Product_Rate_Plan_Charge__c productRatePlanCharge_Weekly = new Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                                                                  CurrencyL__c = currencyObj.Id,
                                                                  Product_Rate_Plan__c = productRatePlan.Id,
                                                                  Unit_price__c = 500,
                                                                  Cost_Price__c = 250,
                                                                  Product_Charge_Category__c = 'Taxable',
                                                                  Price_Type__c = System.Label.OptionWeekly
                                                                  );
            listProductRatePlanCharges.add(productRatePlanCharge_Weekly);  
            
            Product_Rate_Plan_Charge__c productRatePlanCharge_Quarterly = new Product_Rate_Plan_Charge__c(Name = 'Monthly Charges',
                                                                  CurrencyL__c = currencyObj.Id,
                                                                  Product_Rate_Plan__c = productRatePlan.Id,
                                                                  Unit_price__c = 500,
                                                                  Cost_Price__c = 250,
                                                                  Product_Charge_Category__c = 'Taxable',
                                                                  Price_Type__c = System.Label.OptionQuarterly
                                                                  );
           listProductRatePlanCharges.add(productRatePlanCharge_Quarterly);
                                                                                                                        
        Product_Rate_Plan_Charge__c tierCharge = new Product_Rate_Plan_Charge__c(Name = 'Test ProductRatePlan Charge Tiers',CurrencyL__c = currencyObj.Id,Price_Type__c = system.Label.OptionOneTime,
                Product_Rate_Plan__c = productRatePlan.Id,
                Unit_price__c = 0,Cost_Price__c = 0, Product_Charge_Category__c = 'Taxable', Price_Format__c = CommonUtilClass.PRICE_FORMAT_VOLUME);
        listProductRatePlanCharges.add(tierCharge);
        insert listProductRatePlanCharges;

        return listProductRatePlanCharges;
    }

    //creating  tiers
    public static list<Product_Rate_Plan_Charge_Tier__c> createProductRatePlanChargeTier(Product_Rate_Plan_Charge__c charge){
        list<Product_Rate_Plan_Charge_Tier__c> tiers = new list<Product_Rate_Plan_Charge_Tier__c>();
        tiers.add(new Product_Rate_Plan_Charge_Tier__c(Start_Unit__c = 1, End_Unit__c = 10, Unit_Cost_Price__c = 90, Unit_Price__c = 120, Product_Rate_Plan_Charge__c = charge.Id));
        tiers.add(new Product_Rate_Plan_Charge_Tier__c(Start_Unit__c = 11, End_Unit__c = 20, Unit_Cost_Price__c = 90, Unit_Price__c = 110, Product_Rate_Plan_Charge__c = charge.Id));
        tiers.add(new Product_Rate_Plan_Charge_Tier__c(Start_Unit__c = 21, End_Unit__c = 30, Unit_Cost_Price__c = 90, Unit_Price__c = 100, Product_Rate_Plan_Charge__c = charge.Id));
        insert tiers;   

        return tiers;
    }

    // creating product filter criteria
    public static void createProductCatalogFilterCriteria(){
        list<Product_Catalog_Filter_Criteria__c> listFilters = new list<Product_Catalog_Filter_Criteria__c>();
        listFilters.add(new Product_Catalog_Filter_Criteria__c(Destination_Field__c = 'CurrencyL__c',Destination_Object__c = 'Product_Rate_Plan_Charge__c',Source_Field__c = 'CurrencyL__c',Source_Object__c = 'Job__c', Name = 'a1'));
        listFilters.add(new Product_Catalog_Filter_Criteria__c(Destination_Field__c = 'CurrencyL__c',Destination_Object__c = 'Product_Rate_Plan_Charge__c',Source_Field__c = 'CurrencyL__c',Source_Object__c = 'Quote__c', Name = 'a2'));
        listFilters.add(new Product_Catalog_Filter_Criteria__c(Destination_Field__c = 'Name',Destination_Object__c = 'Product__c',Source_Field__c = 'Name',Source_Object__c = 'Job__c', Name = 'a3'));
        listFilters.add(new Product_Catalog_Filter_Criteria__c(Destination_Field__c = 'Name',Destination_Object__c = 'Product__c',Source_Field__c = 'Name',Source_Object__c = 'Quote__c', Name = 'a4'));
        insert listFilters; 

    }

    //create custom mapping 
    public static void createCustomSettingMapping(){
        list<Custom_Mappings__c> listCustomMapping = new list<Custom_Mappings__c>();
        listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = 'Name',Destination_Object__c = 'Quote_Rate_Plan__c',Source_Field__c = 'Name',Source_Object__c = 'Product_Rate_Plan__c', Name = 'q1'));
        listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = 'Name',Destination_Object__c = 'Quote_Rate_Plan_Charge__c',Source_Field__c = 'Name',Source_Object__c = 'Product_Rate_Plan_Charge__c', Name = 'q2'));
        listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = 'Name',Destination_Object__c = 'Quote_Product__c',Source_Field__c = 'Name',Source_Object__c = 'Product__c', Name = 'q3'));
        listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = 'Name',Destination_Object__c = 'Job_Rate_Plan__c',Source_Field__c = 'Name',Source_Object__c = 'Product_Rate_Plan__c', Name = 'a1'));
        listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = 'Name',Destination_Object__c = 'Job_Rate_Plan_Charge__c',Source_Field__c = 'Name',Source_Object__c = 'Product_Rate_Plan_Charge__c', Name = 'a2'));
        listCustomMapping.add(new Custom_Mappings__c(Destination_Field__c = 'Name',Destination_Object__c = 'Job_Product__c',Source_Field__c = 'Name',Source_Object__c = 'Product__c', Name = 'a3'));
        insert listCustomMapping;
    }
    //creating Quote
    public static Quote__c createQuote( Account account,Contact contact,Currency__c currencyObj){
        Date validtodate = Date.today();

        Quote__c quote = new Quote__c(Name = 'Test quote1',CurrencyL__c = currencyObj.Id,Number_Of_Terms__c = 24,
                Start_Date__c = validtodate,Valid_To__c = validtodate,Billing_Contact__c = contact.id,Shipping_Contact__c = contact.id,Account__c = account.Id);
        insert quote;
        return quote;

    }

    // creating payment method
    public static Payment_Method__c createPaymentMethod( Account account){
        Payment_Method__c paymentMethod = new Payment_Method__c(Active__c = true, Default__c = true, Account__c = account.Id,
                                                                 CVV__c = '123', Card_Number__c = '4007000000027', 
                                                                 Card_Expiration_Year__c = '2023', Card_Expiration_Month__c = '10', 
                                                                 Billing_Country__c = 'Australia', Billing_First_Name__c = 'First Name',
                                                                 Billing_Last_Name__c = 'Last Name',Billing_Address__c = 'Address',
                                                                 Billing_City__c = 'City', Billing_State_Province__c = 'State',
                                                                 Billing_Zip_Postal__c = '2013',Billing_Phone__c = '99999999',
                                                                 Billing_Email__c = 'test@Test.com' );
        insert paymentMethod;
        return paymentMethod;
    }
    
    // creating opportuinity method
    
    public static Opportunity createOpportunity( Account account){
        Opportunity opp = new Opportunity(StageName = 'One', Name = '12/13 Communications - Once', AccountId = account.Id, CloseDate = system.today());
        insert opp;
        return opp;
    }
    
    // creating Gateway method
    public static Gateway__c createGateway( Account account){
        Gateway__c gateway = new Gateway__c(Active__c = true, Gateway_Type__c = 'PayPal', Test_Mode__c = true, Merchant_ID__c = '22LbQ9b7', Security_Key__c = '8Fh7VnPV3e6h4b4S', Merchant_Seal_User_Id__c = '8Fh7VnPV3e6h4b4S...');
        insert gateway;
        return gateway;
    }
    
    

}