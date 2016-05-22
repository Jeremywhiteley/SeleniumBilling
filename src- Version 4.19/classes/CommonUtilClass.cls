public with sharing class CommonUtilClass { 

            //Need not worry about tranlation for other languages
            public static final String SPACE = ' ';
            public static final String COLAN = ':';

            //Please donot use the below variable for dynamic query this is used only for custom mapping and product filters FROM 8 to 18 Version 30 Changes
            public static final String OBJECT_NAME_PRODUCT = 'Product__c';
            public static final String OBJECT_NAME_JOB_PRODUCT = 'Job_Product__c';
            public static final String OBJECT_NAME_QUOTE_PRODUCT = 'Quote_Product__c';
            public static final String OBJECT_NAME_PRODUCT_RATE_PLAN = 'Product_Rate_Plan__c';
            public static final String OBJECT_NAME_JOB_RATE_PLAN = 'Job_Rate_Plan__c';
            public static final String OBJECT_NAME_QUOTE_RATE_PLAN = 'Quote_Rate_Plan__c';
            public static final String OBJECT_NAME_PRODUCT_RATE_PLAN_CHARGE = 'Product_Rate_Plan_Charge__c';
            public static final String OBJECT_NAME_JOB_RATE_PLAN_CHARGE = 'Job_Rate_Plan_Charge__c';
            public static final String OBJECT_NAME_QUOTE_RATE_PLAN_CHARGE = 'Quote_Rate_Plan_Charge__c';
            public static final String OBJECT_NAME_JOB = 'Job__c';
            public static final String OBJECT_NAME_QUOTE = 'Quote__c';
            
             //Added INVOICEIT-573
            public static final String OBJECT_NAME_OPPORTUNITY = 'Opportunity';
            public static final String OBJECT_NAME_OPPORTUNITY_PRODUCT = 'Opportunity_Product__c';
            public static final String OBJECT_NAME_OPPORTUNITY_RATE_PLAN = 'Opportunity_Rate_Plan__c';
            public static final String OBJECT_NAME_OPPORTUNITY_RATE_PLAN_CHARGE = 'Opportunity_Rate_Plan_Charge__c';

            public static final String OBJECT_NAME_ACCOUNT = 'Account';
            public static final String ORDER_PRODUCT_SEARCH_FIELDS = 'ORDER_PRODUCT_SEARCH_FIELDS';
            public static final String INVOICING_GROUP_BY_ORDER = 'ONE_INVOICE_PER_ORDER';
            public static final String INVOICING_GROUP_BY_ACCOUNT = 'ONE_INVOICE_PER_ACCOUNT';
            public static final String TAX_CALCULATION_BASED_ON = 'TAX_CALCULATION_BASED_ON';
            public static final String USE_SERVICE_START_DATE_FOR_INVOICE = 'USE_SERVICE_START_DATE_FOR_INVOICE';
            public static final String ALIGN_DATES_OF_ORDER_TO_PRODUCTS = 'ALIGN_DATES_OF_ORDER_TO_PRODUCTS';
            public static final String OBSOLETE = 'Obsolete';
            public static final boolean STATUS_TRUE = true;
            public static final String  OWNER = 'Owner ID';

            //The following need to be translated
            public static final String STATUS_PAID = 'Paid';
            public static final String STATUS_POSTED = 'Posted';
            public static final String STATUS_PROFORMA = 'Proforma';
            public static final String STATUS_REGULAR = 'Regular';
            public static final String STATUS_DRAFT = 'Draft';
            public static final String STATUS_STARTED = 'Started';
            public static final String STATUS_FAILED = 'Failed';
            public static final String STATUS_PROCESSING = 'Processing';
            public static final String STATUS_COMPLETED = 'Completed';
            public static final String STATUS_COMPLETED_WITH_ERRORS = 'Completed with errors';
            public static final String STATUS_CANCELLED = 'Cancelled';
            public static final String STATUS_ACTIVE = 'Active';
            public static final String STATUS_UNBILLED = 'Un-billed';
            public static final String STATUS_BILLED = 'Billed';
            public static final String STATUS_ROLLED_UP = 'Rolled-Up';
            public static final String PRICE_FORMAT_TIERED = 'Tiered Pricing';
            public static final String PRICE_FORMAT_VOLUME = 'Volume Pricing';
            public static final String PRICE_FORMAT_PER_UNIT = 'Per Unit Pricing';
            public static final String PRICE_FORMAT_FLAT_FEE = 'Flat Fee Pricing';
            public static final String PRICE_FORMAT_PERCENTAGE_PRICING = 'Percentage Pricing';
            public static final String CONTACT_TYPE_BILLING = 'Billing Contact';
            public static final String CONTACT_TYPE_SHIPPING = 'Shipping Contact';
            public static final String ACCOUNT_BILLING_ADDRESS = 'Account Billing Address';
            public static final String ACCOUNT_SHIPPING_ADDRESS = 'Account Shipping Address';
            public static final String LEGAL_ENTITY_ADDRESS = 'Legal Entity Address';
            public static final String CONVERTED = 'Converted';
            public static final String STATUS_CONVERTED = 'Converted';
            public static final String STRING_TRUE = 'true';
            public static final String TAX = 'Tax';
            public static final String VAT = 'VAT';
            public static final String STATUS_DELIVERED = 'Delivered';
            public static final String STATUS_QUEUED = 'Queued' ;

            public static final String DUE_DATE = 'Due Date';
            public static final String PREFERRED_PAYMENT_DATE = 'Preferred Payment Date';
            public static final String INVOICE_DATE = 'Invoice Date';
            public static final String PAYMENT_TERM_ACCOUNT = 'ACCOUNT';
            public static final String PAYMENT_TERM_ORDER = 'ORDER';

            public static final String APPLY_TO_CHARGE_LEVEL = 'Charge level';
            public static final String APPLY_TO_QUOTEORORDER_LEVEL = 'Quote/Order level';
            public static final String MATCHING_ALL_STAR = '*';
            public static final String APPLY_DISCOUNT_BY_PERCENTAGE = 'APPLY_DISCOUNT_BY_PERCENTAGE';
            public static final String APPLY_DISCOUNT_BY_VALUE = 'APPLY_DISCOUNT_BY_VALUE';
            //Added by dhanalakshmi for INVOICEIT-430
            public static final String APPLY_DISCOUNT_BY_BOTH = 'APPLY_DISCOUNT_BY_BOTH';

            //payments module
            public static final String TRANSACTION_TYPE_AUTHORIZATION = 'Authorization';
            public static final String TRANSACTION_TYPE_CHARGE = 'Charge';
            public static final String TRANSACTION_TYPE_REFUND = 'Refund';
            public static final String TRANSACTION_TYPE_VOID = 'Void';
            public static final String TRANSACTION_TYPE_Charged_Authorization = 'Charged_Authorization';

            public static final String TRANSACTION_RESPONSE_STATUS_APPROVED = 'Approved';
            public static final String TRANSACTION_RESPONSE_STATUS_DECLINED = 'Declined';
            public static final String TRANSACTION_RESPONSE_STATUS_ERROR = 'Error';
            public static final String TRANSACTION_RESPONSE_STATUS_HELDFORREVIEW = 'Held For review';

            public static final String GATEWAY_TYPE_AUTHORIZEDOTNET = 'Authorize.net';
            public static final String ENDPOINT_AUTHORIZEDOTNET_TEST = 'https://test.authorize.net/gateway/transact.dll';
            public static final String ENDPOINT_AUTHORIZEDOTNET_LIVE = 'https://secure.authorize.net/gateway/transact.dll';

            public static final String GATEWAY_TYPE_PAYPAL = 'PayPal';
            public static final String ENDPOINT_PAYFLOWPRO_TEST = 'https://pilot-payflowpro.paypal.com';
            public static final String ENDPOINT_PAYFLOWPRO_LIVE = 'https://payflowpro.paypal.com';

            public static final String GATEWAY_TYPE_WIRECARD = 'WireCard';
            public static final String ENDPOINT_WIRECARD_TEST = 'https://c3-test.wirecard.com/secure/ssl-gateway';
            public static final String ENDPOINT_WIRECARD_LIVE = 'https://c3.wirecard.com/secure/ssl-gateway';

            public static final String GATEWAY_TYPE_FIRSTDATA = 'FirstData';
            public static final String ENDPOINT_FIRSTDATA_TEST = 'https://api.demo.globalgatewaye4.firstdata.com/transaction/v11';
            public static final String ENDPOINT_FIRSTDATA_LIVE = 'https://api.globalgatewaye4.firstdata.com/transaction/v11';

            public static final String GATEWAY_TYPE_AUTHORIZEDOTNETCIM = 'Authorize.net CIM';
            public static final String ENDPOINT_AUTHORIZEDOTNETCIM_TEST = 'https://apitest.authorize.net/xml/v1/request.api';
            public static final String ENDPOINT_AUTHORIZEDOTNETCIM_LIVE = 'https://api.authorize.net/xml/v1/request.api';

            // Manigandan SA, INVOICEIT-600
            public static final String GATEWAY_TYPE_CyberSource = 'CyberSource';
            public static final String ENDPOINT_CyberSource_TEST = 'https://ics2wstest.ic3.com/commerce/1.x/transactionProcessor/';
            public static final String ENDPOINT_CyberSource_LIVE = 'https://ics2ws.ic3.com/commerce/1.x/transactionProcessor/';
            
            public static final String GATEWAY_TYPE_CyberSource_CC_Token = 'CyberSource_CC_Token';
             public static final String ENDPOINT_CyberSource_CC_Token_TEST = 'https://ics2wstest.ic3.com/commerce/1.x/transactionProcessor/';
            public static final String ENDPOINT_CyberSource_CC_Token_LIVE = 'https://ics2ws.ic3.com/commerce/1.x/transactionProcessor/';
            
            public static final String GATEWAY_TYPE_STRIPE = 'Stripe';
            public static final String ENDPOINT_STRIPE = 'https://api.stripe.com/v1/charges';
            
            //Added by Dhanalakshmi, INVOICEIT-616
            public static final String ENDPOINT_STRIPE_Token = 'https://api.stripe.com/v1/tokens';

            public static final String GATEWAY_TYPE_SAGEPAY = 'SagePay';

            //public static final String ENDPOINT_BRAINTREE = 'https://weinvoiceit.herokuapp.com/braintree';
            // public static final String ENDPOINT_BRAINTREE = 'https://btserver-invoiceit.rhcloud.com/braintree';

            public static final String ENDPOINT_BRAINTREE_PRODUCTION = 'https://weinvoiceit.herokuapp.com/braintree';
            public static final String ENDPOINT_BRAINTREE_SANDBOX = 'https://weinvoiceit-sandbox.herokuapp.com/braintree';

            //Live URLs
            public static final String ENDPOINT_SAGEPAY_AUTHENTICATE_OR_PAYMENT_URL_LIVE = 'https://live.sagepay.com/gateway/service/vspdirect-register.vsp?';
            public static final String ENDPOINT_SAGEPAY_VOID_URL_LIVE = 'https://live.sagepay.com/gateway/service/void.vsp?';
            public static final String ENDPOINT_SAGEPAY_REFUND_URL_LIVE = 'https://live.sagepay.com/gateway/service/refund.vsp?';
            public static final String ENDPOINT_SAGEPAY_RELEASE_URL_LIVE = 'https://live.sagepay.com/gateway/service/release.vsp?';
            public static final String ENDPOINT_SAGEPAY_REPEAT_URL_LIVE = 'ttps://live.sagepay.com/gateway/service/repeat.vsp?';
            public static final String ENDPOINT_SAGEPAY_AUTHORIZE_URL_LIVE = 'https://live.sagepay.com/gateway/service/authorise.vsp?';

            //Test URLs
            public static final String ENDPOINT_SAGEPAY_AUTHENTICATE_OR_PAYMENT_URL_TEST = 'https://test.sagepay.com/gateway/service/vspdirect-register.vsp?';
            public static final String ENDPOINT_SAGEPAY_VOID_URL_TEST = 'https://test.sagepay.com/gateway/service/void.vsp?';
            public static final String ENDPOINT_SAGEPAY_REFUND_URL_TEST = 'https://test.sagepay.com/gateway/service/refund.vsp?';
            public static final String ENDPOINT_SAGEPAY_RELEASE_URL_TEST = 'https://test.sagepay.com/gateway/service/release.vsp?';
            public static final String ENDPOINT_SAGEPAY_REPEAT_URL_TEST = 'https://test.sagepay.com/gateway/service/repeat.vsp?';
            public static final String ENDPOINT_SAGEPAY_AUTHORIZE_URL_TEST = 'https://test.sagepay.com/gateway/service/authorise.vsp?';
            //Added by dhanalakshmi for sagepay 3dSecure
            public static final String ENDPOINT_SAGEPAY_3DSECURE_URL_TEST = 'https://test.sagepay.com/gateway/service/direct3dcallback.vsp?';

            public static final String GATEWAY_TYPE_ACH = 'ACH';

            public static final String PAYMENTTYPE_CREDITCARD = 'Credit Card';
            public static final String PAYMENTTYPE_ECHECK = 'eCheck';
            public static final String PAYMENTTYPE_ACH = 'ACH';

            public static final String GATEWAY_TYPE_EWAY = 'Eway';
            // added by ram,INVOICEIT-501
            public static final String GATEWAY_TYPE_BRAINTREE = 'BrainTree';

            // static resource variables
            public static final String STATICRESOURCE_LOGO = 'logo';
            public static final String STATICRESOURCE_PAYMENTCSS = 'payment_defaultcss';
            public static final String STATICRESOURCE_FOOTER = 'payment_footer';

            public static final String DISCOUNT_TYPE_PERCENTAGE = '%';
            public static final String DISCOUNT_TYPE_VALUE = 'Value';

              //This method returns a select query string that contains all the standard fields of the object
            public static String getObjectSelectQuery(String objectName) {
                String sQuery = 'SELECT ';
                sQuery += getObjectFields(objectName);
                sQuery += ' FROM ' + objectName + ' ';
                return sQuery;
            }

            //This method returns a comma seperated string of all the standard fields of the object
            public static String getObjectFields(String objectName) {
                String sQuery = '';
                String sCompareAddress = '';
                Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
                for (Schema.SObjectField column : objectFieldMap.values()) {
                    sCompareAddress = '' + column;
                    /*
                        Modified By     : Naveen M 22-4-2014 SUP-235, INVOICEITCRM-42
                        Comments        : added if condition to avoid querying the shipping and billing address.
                    */
                    if (sCompareAddress != 'ShippingAddress' && sCompareAddress != 'BillingAddress') {
                        sQuery += column + ', ';
                    }
                }
                sQuery = sQuery.substring(0, sQuery.length() - 2);
                sQuery += ' ';
                return sQuery;
            }

            public static String convertListOfIdsIntoString(List<Id> ids) {
                String idString = '';
                for (Id id : ids) {
                    idString = idString + '\'' + id + '\',';
                }
                if (idString != null && idString.length() > 0) {
                    idString = idString.substring(0, idString.length() - 1);
                }

                return idString;
            }

            public static String convertListOfStingsIntoString(List<string> ids) {
                String idString = '';
                for (string s : ids) {
                    idString = idString + '\'' + s + '\',';
                }
                if (idString != null && idString.length() > 0) {
                    idString = idString.substring(0, idString.length() - 1);
                }

                return idString;
            }

             // This method getTheCurrencyID @return CurrencyName Like GBP
             
            public static String getCurrency(Id currencyId) {
                if (currencyId != null) {
                    return [SELECT Symbol__c, Currency_Symbol__c, Currency_Name__c
                            FROM Currency__c
                            WHERE Id = : currencyId].Currency_Symbol__c;
                } else {
                    return null;
                }
            }

            public static Currency__c getCurrencyObjectForId(Id currencyId) {
                Currency__c currencyObj = [SELECT id, Name, Symbol__c, Currency_Name__c, Currency_Symbol__c
                                           FROM Currency__c
                                           WHERE Id = : currencyId];
                return currencyObj;
            }

            public static Currency__c getCurrencyObject(string currencyName) {
                Currency__c currencyObj = [SELECT id, Name, Symbol__c, Currency_Name__c, Currency_Symbol__c
                                           FROM Currency__c
                                           WHERE Name = : currencyName Limit 1];
                return currencyObj;
            }

             // This method convertDateToString @return dateString
            public static String convertDateToString(Date dateValue) {
                if (dateValue == null) {
                    dateValue = Date.today();
                }
                Datetime dt = datetime.newInstance(dateValue.year(), dateValue.month(), dateValue.day());
                String dateString = dt.format('yyyy-MM-dd'); //formatting complies with SOQL
                return dateString;
            }

            public static Job__c getJob(string quoteId) {
                list<Job__c> listJob = [SELECT id
                                        FROM Job__c
                                        WHERE Quote__c = : quoteId AND Status__c != : CommonUtilClass.STATUS_CANCELLED];
                if (listJob.size() > 0) {
                    return listJob.get(0);
                }
                return null;
            }

            public static Invoice_RunScheduler__c getinvoiceRunScheduler(string invoiceRunSchedulerId) {
                Invoice_RunScheduler__c invoiceRunScheduler;
                string sQuery = 'SELECT ' + CommonUtilClass.getObjectFields(getPrefix()+'Invoice_RunScheduler__c')
                                + ' FROM Invoice_RunScheduler__c '
                                + ' WHERE Id =' + '\'' + String.escapeSingleQuotes(invoiceRunSchedulerId) + '\'';
                invoiceRunScheduler = Database.query(sQuery);
                return invoiceRunScheduler;
            }

            public static String convertDateToString(Date Value, String format) {
                if (value == null) {
                    return null;
                } else {
                    Datetime temp = Datetime.newInstance(Value.year(), Value.month(), Value.day());
                    return temp.format(format);
                }
            }

            //this will send only writable fields
            public static list<String> getObjectFieldsWritable(String objectName) {
                list<String> listOfLabelNameAndApi = new list<String>();
                String sApiLabels = '';
                String sAPINames = '';
                Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
                for (Schema.SObjectField column : objectFieldMap.values()) {
                    if (column.getDescribe().isUpdateable() == true && !column.getDescribe().getLabel().startsWith(OBSOLETE) &&
                            !column.getDescribe().getLabel().equals(OWNER)) {
                        sApiLabels += column.getDescribe().getLabel() + ',';
                        sAPINames += column + ',';
                    }
                }
                sApiLabels = sApiLabels.substring(0, sApiLabels.length() - 1);
                sAPINames = sAPINames.substring(0, sAPINames.length() - 1);
                listOfLabelNameAndApi.add(sApiLabels);
                listOfLabelNameAndApi.add(sAPINames);
                return listOfLabelNameAndApi;
            }

            public static map<Integer, String> getObjectFieldsNKey(String objectName) {
                map<Integer, String> mapOfNameAndKey = new map<Integer, String>();
                String sAPINames = '';
                String sTypeName = '';
                String sLabel = '';
                Map<String, Schema.SObjectField> objectFieldMap = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
                Integer iKey = 1;
                for (Schema.SObjectField column : objectFieldMap.values()) {
                    if (column.getDescribe().isUpdateable() == true && !column.getDescribe().getLabel().startsWith(OBSOLETE) &&
                            !column.getDescribe().getLabel().equals(OWNER)) {
                        sAPINames = String.valueOf(column) ;
                        sTypeName = String.valueOf(column.getDescribe().getType());
                        sLabel = column.getDescribe().getLabel();
                        mapOfNameAndKey.put(iKey, sAPINames + '-' + sTypeName + '-' + sLabel);
                        iKey++;
                    }
                }
                return mapOfNameAndKey;
            }

            public static Date convertStringtoDateNFormat(String fielddata) {
                String thirdStr = '';
                String firstStr = '';
                Date finalDate = null;
                String [] fieldDataArray = fielddata.split('-');
                Integer lengthoffirstfield = fieldDataArray[0].trim().length();
                if (lengthoffirstfield > 2) {
                    if (fieldDataArray[0].trim().length() > 4) {
                        firstStr = fieldDataArray[0].substring(0, 4).trim();
                    } else {
                        firstStr = fieldDataArray[0].trim();
                    }
                    String mergeString = firstStr + '-' + fieldDataArray[1] + '-' + fieldDataArray[2];
                    Date convertedDate = date.valueOf(mergeString);
                    String finalString = convertDateToString(convertedDate, 'yyyy-MM-dd');
                    finalDate = date.valueOf(finalString);

                } else {
                    if (fieldDataArray[2].trim().length() > 4) {
                        thirdStr = fieldDataArray[2].substring(0, 4).trim();
                    } else {
                        thirdStr = fieldDataArray[2].trim();
                    }
                    String mergeString = thirdStr + '-' + fieldDataArray[1] + '-' + fieldDataArray[0];
                    Date convertedDate = date.valueOf(mergeString);
                    String finalString = convertDateToString(convertedDate, 'yyyy-MM-dd');
                    finalDate = date.valueOf(finalString);
                }
                return finalDate;
            }

            public static map<Id, String> getCurrencyIdNCurrencyName() {
                map<Id, String> mapOfCurrencyIdAndCurrencyName = new map<Id, String>();
                for (Currency__c currencyObj : [SELECT Name FROM Currency__c WHERE Name != null]) {
                    mapOfCurrencyIdAndCurrencyName.put(currencyObj.Id, currencyObj.Name);
                }

                return mapOfCurrencyIdAndCurrencyName;
            }

            public static map<String, Id> getCurrencyNameNCurrencyId() {
                map<String, Id> mapOfCurrencyNameAndCurrencyId = new map<String, Id>();
                for (Currency__c currencyObj : [SELECT Name FROM Currency__c WHERE Name != null]) {
                    mapOfCurrencyNameAndCurrencyId.put(currencyObj.Name, currencyObj.Id);
                }

                return mapOfCurrencyNameAndCurrencyId;
            }

            public static Payment_Scheduler__c getPaymentScheduler(string paymentSchedulerId) {
                Payment_Scheduler__c paymentScheduler;
                string sQuery = 'SELECT ' + CommonUtilClass.getObjectFields(getPrefix()+'Payment_Scheduler__c')
                                + ' FROM Payment_Scheduler__c'
                                + ' WHERE Id =' + '\'' + String.escapeSingleQuotes(paymentSchedulerId) + '\'';
                paymentScheduler = Database.query(sQuery);
                return paymentScheduler;
            }

            public static sobject getExchangeRateByDate(date dateExchange, string isoCode) {

                Date startDate = Date.newInstance(dateExchange.Year(), dateExchange.Month(), dateExchange.Day());
                String dateExchangeInString = string.ValueOf(startDate);

                string sQuery =   'SELECT ISOCode, ConversionRate, StartDate, NextStartDate FROM DatedConversionRate '
                                  + 'WHERE ISOCode = \'' + String.escapeSingleQuotes(isoCode) + '\' '
                                  + 'AND StartDate <= ' + dateExchangeInString + ' AND NextStartDate > ' +  dateExchangeInString + ' LIMIT 1';
                list<sobject> sobjectDatedConversionRates = Database.query(sQuery);

                if (!sobjectDatedConversionRates.isEmpty()) {
                    return sobjectDatedConversionRates[0];
                } else {
                    sQuery = 'SELECT ConversionRate,DecimalPlaces,Id,IsActive,IsCorporate,IsoCode FROM CurrencyType WHERE IsActive = true AND ISOCode = \'' + isoCode + '\'';
                    sobjectDatedConversionRates = Database.query(sQuery);

                    if (!sobjectDatedConversionRates.isEmpty()) {
                        return sobjectDatedConversionRates[0];
                    } else {
                        return null;
                    }
                }
            }

            public static sobject getSobjectById(String sObjectName, String idOfSobject) {
                String sQuery = CommonUtilClass.getObjectSelectQuery(sObjectName) + ' WHERE  Id = \'' + String.escapeSingleQuotes(idOfSobject) + '\'';
                return database.query(sQuery);
            }


            //This change was done for the new feature Billing Master Order
            //When the order record has the billing master order field populated, associate each Order Charge to the corresponding charge record from the master order
            //The only criteria here is if the master order has an Order Charge for the same product charge id
            public static void relateChargeRecordsToMasterChargeRecords(JobClass jobClass) {

                //If the Billing Master Order field is null then reset the master order charge fields too
                //If the Billing Master Order field is not null then query for the master order charge fields and set them
                if (jobClass.job.Billing_Master_Order__c == null) {
                    for (JobProductClass jpc : jobClass.jobProducts) {
                        for (JobRatePlanClass jrc : jpc.jobRatePlans) {
                            for (JobRatePlanChargeClass jrpc : jrc.jobRatePlanCharges) {
                                jrpc.jobrateplancharge.Billing_Master_Order_Rate_Plan_Charge__c = null;
                            }
                        }
                    }
                } else {
                    Job_Rate_Plan_Charge__c[] billingMasterCharges = [select id, Product_Rate_Plan_Charge__c
                                                                        from Job_Rate_Plan_Charge__c
                                                                        where Job_Rate_Plan__r.Job_Product__r.Job__c = :jobClass.job.Billing_Master_Order__c];
                    //The order charges from this order are mapped to the order charges from the billing master
                    //Use a map to easily perform this
                    for (JobProductClass jpc : jobClass.jobProducts) {
                        for (JobRatePlanClass jrc : jpc.jobRatePlans) {
                            for (JobRatePlanChargeClass jrpc : jrc.jobRatePlanCharges) {
                                for (Job_Rate_Plan_Charge__c billingMasterCharge : billingMasterCharges) {
                                    if (jrpc.jobrateplancharge.Product_Rate_Plan_Charge__c == billingMasterCharge.Product_Rate_Plan_Charge__c) {
                                        jrpc.jobrateplancharge.Billing_Master_Order_Rate_Plan_Charge__c = billingMasterCharge.Id;
                                    }
                                }
                            }
                        }
                    }
                }

            }

            /*
                In scheduler we are picking the charges whose prefereed billing date is target date.
                Some customers might have prefereed billing as 30, 31 etc.
                But for months like feb and apr will have only 28 or 30 days so we are not picking up the customers who are on 30,31.
                To pick up this method is used a util
            */
            public static list<string> isLastDayOfMonth(date targetDate) {

                Integer numberDaysInMonth = date.daysInMonth(targetDate.year(), targetDate.month());

                if (numberDaysInMonth != 31 && numberDaysInMonth == targetDate.day()) {
                    //this is a feb month which is non leap year
                    if (numberDaysInMonth == 28) {
                        //pick up the 29,30,31
                        return new list<string> {'28', '29', '30', '31'};
                    }
                    //this is a feb month which is a leap year
                    else if (numberDaysInMonth == 29) {
                        //pick up the 30,31
                        return new list<string> {'29', '30', '31'};
                    }
                    //this is not a feb month(Apr, Jun)
                    else if (numberDaysInMonth == 30) {
                        //pick up the 31
                        return new list<string> {'30', '31'};
                    }
                }

                return new list<string> {string.ValueOf(targetDate.day())};
            }

            /*
                Modified By     : Ankit Sharma 28 Feb 2014 INVOICEIT-322
                Comments        : Populating the standard field currency (CurrencyIsoCode) only for multi currency org.
            */

            public static void populateCurrencyIsoCodeOnSobject(Sobject sobjectObj, string isoCode) {
                sobjectObj.put('CurrencyIsoCode', (string) isoCode);
            }

            public static void populateDefaultMethod(Payment_Method__c paymentMethod) {
                Account account = new Account(Id = paymentMethod.Account__c, Payment_Method__c = paymentMethod.Id );
                update account;
            }

            public static list<Product_Bundle_Line__c> getProductBundleLine(string productBundleId) {
                string sQuery = 'SELECT Product_Bundle__r.Bundle_Type__c,Product_Rate_Plan__r.Name,' + CommonUtilClass.getObjectFields(getPrefix()+'Product_Bundle_Line__c')
                                + ' FROM Product_Bundle_Line__c '
                                + ' WHERE Product_Bundle__c =' + '\'' + String.escapeSingleQuotes(productBundleId) + '\' AND Product__c != null AND Product_Rate_Plan__c != null AND Product_Rate_Plan_Charge__c != null Order By Name';
                return Database.query(sQuery);
            }

            public static Product_Bundle__c getProductBundle(Id id) {
                String query = getObjectSelectQuery(getPrefix()+'Product_Bundle__c');
                query = query + ' WHERE Id =\'' + String.escapeSingleQuotes(id) + '\'';
                Product_Bundle__c pb = Database.query(query);
                return pb;
            }

            // Added by Dev M ticket Number : SUP-543
            public static void createFailedtransaction(Id invoiceId, Id paymentRunId, string exceptionMessage) {
                
               Gateway__c gateway;
               Invoice__c invoice = InvoicingUtilClass.getInvoiceById(invoiceId);

               
               list<Gateway__c> listOfGateway = new list<Gateway__c>();
               if(invoice.Account__r.Gateway__c == null) {
                    listOfGateway = InvoicingUtilClass.getDefaultGateway();
                    gateway = listOfGateway.get(0);               
               } else {
                  gateway = InvoicingUtilClass.getGateway(invoice.Account__r.Gateway__c);
               }
               
               list<Payment_Method__c> paymentMethods = InvoicingUtilClass.getDefaultMethodForAccount(invoice.Account__c);
               Payment_Method__c paymentMethod = paymentMethods.get(0);
                
                //Check if there is an existing authorized transaction against the same gateway and same payment method and same invoice
                list<Transaction__c> transactions = [   SELECT Id FROM Transaction__c
                                                    WHERE Response_Status__c =: CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED
                                                    AND Gateway_ID__c != null
                                                    AND Type__c =: CommonUtilClass.TRANSACTION_TYPE_CHARGE
                                                    AND Request_Invoice__c = :invoice.Id
                                                    AND Payment_Gateway__c = :gateway.Id
                                                    AND Payment_Method__c = :paymentMethod.Id
                                                    order BY Name DESC LIMIT 1 ];
                
                decimal amountToBeProcessed = 0;    
                if(invoice.Payment_Request_Amount__c != null && invoice.Payment_Request_Amount__c > 0 && invoice.Payment_Request_Amount__c < invoice.Unpaid_Amount__c) {
                    amountToBeProcessed = invoice.Payment_Request_Amount__c;
                } else {
                    amountToBeProcessed = invoice.Unpaid_Amount__c;
                }
                        
                Transaction__c transactionObj = new Transaction__c(Payment_Method__c = paymentMethod.Id, 
                                    Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE, 
                                    Amount__c = amountToBeProcessed, Request_Invoice__c = invoice.Id,
                                    Currency__c = invoice.CurrencyL__c, Request_Type_Of_Payment__c = paymentMethod.Payment_Method__c,
                                    Payment_Gateway__c = gateway.Id, Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE,
                                    Card_Expiration_Month__c = paymentMethod.Card_Expiration_Month__c,
                                    Card_Expiration_Year__c = paymentMethod.Card_Expiration_Year__c,
                                    Card_Type__c = paymentMethod.Card_Type__c,Response_Status__c = 'Error',
                                    Payment_Run__c = paymentRunId, Exception_Message__c = exceptionMessage
                                     );
                                     
                if(!transactions.isEmpty()) {
                    transactionObj.Id = transactions.get(0).Id;
                }
                                         
                if(paymentMethod.Card_Number__c != null){
                    transactionObj.Request_Credit_Card_Number__c = paymentMethod.Card_Number__c.substring((paymentMethod.Card_Number__c.Length() - 4), paymentMethod.Card_Number__c.Length());
                }
                
                upsert transactionObj;
            }

            // Added by Dev M ticket Number : INVOICEIT-661
            public static void createFailedtransactionForPaymentPlan(Payment_Plan_Installment__c paymentPlan, Id paymentRunId, string exceptionMessage) {
                
               Gateway__c gateway;
               
               list<Gateway__c> listOfGateway = new list<Gateway__c>();
               if(paymentPlan.Account__r.Gateway__c  == null) {
                    listOfGateway = InvoicingUtilClass.getDefaultGateway();
                    gateway = listOfGateway.get(0);               
               } else {
                  gateway = InvoicingUtilClass.getGateway(paymentPlan.Account__r.Gateway__c);
               }
                
                
                //Check if there is an existing authorized transaction against the same gateway and same payment method and same invoice
                list<Transaction__c> transactions = [   SELECT Id FROM Transaction__c
                                                     WHERE ( Response_Status__c =: CommonUtilClass.TRANSACTION_RESPONSE_STATUS_APPROVED
                                                        OR Payment_Run__c =: paymentRunId )
                                                    AND Gateway_ID__c != null
                                                    AND Type__c =: CommonUtilClass.TRANSACTION_TYPE_CHARGE
                                                    AND Payment_Plan_Installment__c = :paymentPlan.Id
                                                    AND Payment_Gateway__c = :gateway.Id
                                                    AND Payment_Method__c = :paymentPlan.Payment_Method__c
                                                    order BY Name DESC LIMIT 1 ];
                
                decimal amountToBeProcessed = paymentPlan.Payment_Amount__c;    
                
                Transaction__c transactionObj = new Transaction__c(Payment_Method__c = paymentPlan.Payment_Method__c, 
                                    Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE,Request_Invoice__c = paymentPlan.Invoice__c,
                                    Amount__c = amountToBeProcessed, Payment_Plan_Installment__c = paymentPlan.Id,
                                    Currency__c = paymentPlan.Invoice__r.CurrencyL__c, Request_Type_Of_Payment__c = paymentPlan.Payment_Method__r.Payment_Method__c,
                                    Payment_Gateway__c = gateway.Id, Request_Transaction_Type__c = CommonUtilClass.TRANSACTION_TYPE_CHARGE,
                                    Card_Expiration_Month__c = paymentPlan.Payment_Method__r.Card_Expiration_Month__c,
                                    Card_Expiration_Year__c = paymentPlan.Payment_Method__r.Card_Expiration_Year__c,
                                    Card_Type__c = paymentPlan.Payment_Method__r.Card_Type__c,Response_Status__c = 'Error',
                                    Payment_Run__c = paymentRunId, Exception_Message__c = exceptionMessage
                                     );
                                     
                if(!transactions.isEmpty()) {
                    transactionObj.Id = transactions.get(0).Id;
                }

                if(paymentPlan.Transaction__c != null) {
                    transactionObj.Id = paymentPlan.Transaction__c;
                }
                                         
                if(paymentPlan.Payment_Method__r.Card_Number__c != null){
                    transactionObj.Request_Credit_Card_Number__c = paymentPlan.Payment_Method__r.Card_Number__c.substring((paymentPlan.Payment_Method__r.Card_Number__c.Length() - 4), paymentPlan.Payment_Method__r.Card_Number__c.Length());
                }
                
                upsert transactionObj;
            }
            
            public static String getPrefix() {
                return String.valueOf(Invoice__c.sObjectType).toLowerCase().startsWith('invoiceit_s__') ? 'invoiceit_s__' : '';
            }
        }