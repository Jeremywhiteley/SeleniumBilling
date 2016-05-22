public with sharing class ControllerGrouping{

        public String searchstring { get; set; }
        public String objectname { get; set; }
        public String searchfields { get; set; }
        public String displayfields { get; set; }
        public String orderfield { get; set; }
        public String sFilterCriteria { get; set; }
        public String sProductsLimit { get; set; }
        public String sSelectedAccountId {get;set;}
        public list<Job_Rate_Plan_Charge__c> listOfJobCharges;
        public set<Id> setOfAccountIds;
        public map<Id,Account> mapIdAccount {get;set;}
        public list<Account> listOfAccounts{ get; set; }
        public list<OrderWrapperCharges> listOfWrapperCharges {get;set;}
        public map<string,map<string,list<OrderWrapperCharges>>> map_Acc_mapOrder_Charges{get;set;}
        public map<Id,Job__c> map_Job{get;set;}
        public Grouping__c groupObj {get;set;}
        public String sUnSelectedAccountId {get;set;}
        list<Job_Rate_Plan_Charge__c> listOfChargesToUpdate = new list<Job_Rate_Plan_Charge__c>();
        public Set<Id> unSelectedOrderChargeIds = new Set<Id>();
        public Set<Id> orderChargeIds = new Set<Id>();

        public ControllerGrouping(ApexPages.StandardController controller) {
            searchstring = '';
            objectname = 'Account';
            searchfields = 'Name';
            displayfields = ''; 
            orderfield = 'Name';
            sFilterCriteria = '';
            sProductsLimit = '20';
            // initialize set, to add the account ids
            setOfAccountIds = new set<Id>();
            listOfAccounts = new list<Account>();
            listOfWrapperCharges = new list<orderWrapperCharges>();
            map_Acc_mapOrder_Charges = new map<string,map<string,list<OrderWrapperCharges>>>();

            mapIdAccount = new map<Id,Account>();
            map_Job = new map<Id,Job__c>();

            groupObj = (Grouping__c)controller.getRecord();     
            // if the groupObj id is not null, display the selected charge relevant account and and order
            if(groupObj.Id  != null){
                groupObj = [SELECT Name,Type__c,Currency__c,Minimum_Customer_Spend_Amount__c From Grouping__c WHERE id =:groupObj.Id ];
                // query the charges based on the transaction Group Type
                if(groupObj.Type__c == 'Volume Based'){
                    listOfJobCharges = [SELECT Name,Price_Type__c,Charge_Code__c,
                                        Job_Rate_Plan__r.Job_Product__r.Job__r.Name, Job_Rate_Plan__r.Job_Product__r.Job__c,
                                        Product_Rate_Plan_Charge__r.Name, Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c,Price_Format__c,
                                        Product_Rate_Plan_Charge__c,Grouping__c
                                        FROM 
                                        Job_Rate_Plan_Charge__c
                                        WHERE
                                        Price_Type__c = 'Usage' 
                                            AND
                                            Price_Format__c =: CommonUtilClass.PRICE_FORMAT_VOLUME
                                            AND
                                            Job_Rate_Plan__r.Job_Product__r.Job__r.CurrencyL__c =: groupObj.Currency__c
                                            AND
                                            Grouping__c =: groupObj.Id
                                            ]; 
                }else{
                    listOfJobCharges = [SELECT Name,Price_Type__c,Charge_Code__c,
                                        Job_Rate_Plan__r.Job_Product__r.Job__r.Name, Job_Rate_Plan__r.Job_Product__r.Job__c,
                                        Product_Rate_Plan_Charge__r.Name, Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c,Price_Format__c,
                                        Product_Rate_Plan_Charge__c,Grouping__c
                                        FROM 
                                        Job_Rate_Plan_Charge__c
                                        WHERE
                                        Job_Rate_Plan__r.Job_Product__r.Job__r.CurrencyL__c =: groupObj.Currency__c 
                                        AND
                                        Grouping__c =: groupObj.Id 
                                        ];
                }

                // in the edit Transaction Group Mode, add the relavant charges ids to set.
                for(Job_Rate_Plan_Charge__c orderCharge : listOfJobCharges) {
                    setOfAccountIds.add(orderCharge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c);
                    unSelectedOrderChargeIds.add(orderCharge.Id);
                }  
                // query the Account names, to display the Account name on the vf page.
                mapIdAccount = new map<Id,Account>([SELECT Name FROM Account WHERE Id IN: setOfAccountIds]);
                // add the relevant charge order(s) account names to the list to display the account names on vf page
                for(id accId : setOfAccountIds){
                    listOfAccounts.add(new Account(Id = accId, Name = mapIdAccount.get(accId).Name));
                }
            } 
        }

        //This is used to add the Account and display the added Account Names on vf page. 
        public void addAccountDetail() {
            sSelectedAccountId = system.currentPageReference().getParameters().get('accountId');  
            if(sSelectedAccountId != null){     
                if(setOfAccountIds.contains(sSelectedAccountId)){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.AccountIsAlreadySelected)); 
                } else{
                    Account accountObj = [SELECT Name FROM Account WHERE Id =:sSelectedAccountId];
                    listOfAccounts.add(new Account(Id = sSelectedAccountId, Name = accountObj.Name));
                    mapIdAccount.put(accountObj.Id,accountObj);
                }
                setOfAccountIds.add(sSelectedAccountId);
                map_Acc_mapOrder_Charges.clear();
                orderChargeIds.clear();
                listOfWrapperCharges.clear();
            }     
        }   

        // remove the account names and ids from the list and set.
        public void removeAccount(){
            sUnSelectedAccountId = system.currentPageReference().getParameters().get('unSelectedAccountId');
            if(sUnSelectedAccountId != null){
                if(setOfAccountIds.contains(sUnSelectedAccountId)){
                    setOfAccountIds.remove(sUnSelectedAccountId);
                    map_Acc_mapOrder_Charges.clear();
                    orderChargeIds.clear();
                    listOfWrapperCharges.clear();
                    // remove UnSelectedAccountId from the displaying account list.
                    for(integer i=0; i<listOfAccounts.size(); i++) {
                        if(listOfAccounts[i].Id == sUnSelectedAccountId) {
                            listOfAccounts.remove(i);
                            break;
                        }
                    }
                }
            }   
        }

        // redirecting to next vf page : createGroupingStep2
        public Pagereference nextPage(){
            if(!setOfAccountIds.isEmpty()){
                displayOrderCharges();
                return page.createGroupingStep2;
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.SelectAccount)); 
                return null;
            }
            return null;
        }

        // redirect to createGroupingStep1/editGrouping
        public Pagereference step1(){
            // edit mode
            if(groupObj.Id != null){
                return page.editGrouping;
            } else{
                // non edit mode
                // clear the all values.
                map_Acc_mapOrder_Charges.clear();
                orderChargeIds.clear();
                listOfWrapperCharges.clear();
                return page.createGroupingStep1;  
            }
            return null;
        }

        // if the transaction group type = min customer spend, then show the transaction amount field on vf page.
        public PageReference isSelectedType(){
            // if the user has changed transaction group type or price type clear the all values
            map_Acc_mapOrder_Charges.clear();
            orderChargeIds.clear();
            listOfWrapperCharges.clear();
            listOfChargesToUpdate.clear();
            return null; 
        }

        // displaying the selected account(s) relevant order charges, the below method is used for both edit mode and view mode
        public void displayOrderCharges(){
            if(!setOfAccountIds.isEmpty()){
                map_Job = new map<Id,Job__c>([SELECT Name FROM Job__c WHERE Account__c IN:setOfAccountIds ]);        
                if(groupObj.Type__c == 'Volume Based'){
                    if(groupObj.Id != null){
                        listOfJobCharges = [SELECT Name,Price_Type__c,Charge_Code__c,
                                            Job_Rate_Plan__r.Job_Product__r.Job__r.Name, Job_Rate_Plan__r.Job_Product__r.Job__c,
                                            Product_Rate_Plan_Charge__r.Name, Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c,Price_Format__c,
                                            Product_Rate_Plan_Charge__c,Grouping__c
                                            FROM 
                                            Job_Rate_Plan_Charge__c
                                            WHERE
                                            Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c =: setOfAccountIds
                                            AND
                                            Price_Type__c = 'Usage' 
                                                AND
                                                Price_Format__c =: CommonUtilClass.PRICE_FORMAT_VOLUME
                                                AND
                                                Job_Rate_Plan__r.Job_Product__r.Job__r.CurrencyL__c =: groupObj.Currency__c
                                                AND
                                                Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c =: setOfAccountIds
                                                AND
                                                ((Grouping__c = null) OR (Grouping__c =: groupObj.Id))

                        ]; 
                    }else{
                        listOfJobCharges = [SELECT Name,Price_Type__c,Charge_Code__c,
                                            Job_Rate_Plan__r.Job_Product__r.Job__r.Name, Job_Rate_Plan__r.Job_Product__r.Job__c,
                                            Product_Rate_Plan_Charge__r.Name, Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c,Price_Format__c,
                                            Product_Rate_Plan_Charge__c,Grouping__c
                                            FROM 
                                            Job_Rate_Plan_Charge__c
                                            WHERE
                                            Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c =: setOfAccountIds
                                            AND
                                            Price_Type__c = 'Usage' 
                                                AND
                                                Price_Format__c =: CommonUtilClass.PRICE_FORMAT_VOLUME
                                                AND
                                                Job_Rate_Plan__r.Job_Product__r.Job__r.CurrencyL__c =: groupObj.Currency__c
                                                AND
                                                Grouping__c = null 
                                                ]; 
                    }
                }else{
                    if(groupObj.Id != null){
                        listOfJobCharges = [SELECT Name,Price_Type__c,Charge_Code__c,
                                            Job_Rate_Plan__r.Job_Product__r.Job__r.Name, Job_Rate_Plan__r.Job_Product__r.Job__c,
                                            Product_Rate_Plan_Charge__r.Name, Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c,Price_Format__c,
                                            Product_Rate_Plan_Charge__c,Grouping__c
                                            FROM 
                                            Job_Rate_Plan_Charge__c
                                            WHERE
                                            Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c =: setOfAccountIds
                                            AND
                                            Job_Rate_Plan__r.Job_Product__r.Job__r.CurrencyL__c =: groupObj.Currency__c 
                                            AND
                                            ((Grouping__c = null) OR (Grouping__c =: groupObj.Id))
                        ];
                    }else{
                        listOfJobCharges = [SELECT Name,Price_Type__c,Charge_Code__c,
                                            Job_Rate_Plan__r.Job_Product__r.Job__r.Name, Job_Rate_Plan__r.Job_Product__r.Job__c,
                                            Product_Rate_Plan_Charge__r.Name, Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c,Price_Format__c,
                                            Product_Rate_Plan_Charge__c,Grouping__c
                                            FROM 
                                            Job_Rate_Plan_Charge__c
                                            WHERE
                                            Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c =: setOfAccountIds
                                            AND
                                            Job_Rate_Plan__r.Job_Product__r.Job__r.CurrencyL__c =: groupObj.Currency__c 
                                            AND
                                            Grouping__c = null 
                                            ];
                    }
                }
                if(listOfJobCharges.isEmpty()) {
                    //Added by Shruthi related to INVOICEIT-200
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, system.Label.NoChargesForAccount)); 
                } else{
                    list<OrderWrapperCharges> locOrderWrapperCharges;
                    map<string,list<OrderWrapperCharges>> locMapOrder_Charges;

                    for(Job_Rate_Plan_Charge__c charge : listOfJobCharges){
                        if(!orderChargeIds.contains(charge.id)) {
                            OrderWrapperCharges orderWrapperCharges = new OrderWrapperCharges();
                            orderWrapperCharges.orderCharge = charge;
                            if(charge.Grouping__c != null ) {
                                orderWrapperCharges.isSelectedCharge = true;
                            } else {
                                orderWrapperCharges.isSelectedCharge = false;   
                            }
                            //construct a map, add the charges account and orders to the map
                            if(map_Acc_mapOrder_Charges.containsKey(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c)) {
                                locMapOrder_Charges = map_Acc_mapOrder_Charges.get(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c);   
                                if(locMapOrder_Charges.containskey(charge.Job_Rate_Plan__r.Job_Product__r.Job__c)) {
                                    locOrderWrapperCharges = locMapOrder_Charges.get(charge.Job_Rate_Plan__r.Job_Product__r.Job__c);
                                } else {  
                                    locOrderWrapperCharges = new list<OrderWrapperCharges>();
                                }
                            } else {   
                                locMapOrder_Charges = new map<string,list<OrderWrapperCharges>>();
                                locOrderWrapperCharges = new list<OrderWrapperCharges>();                                   
                            }  

                            // add the charges to the wrappercharge class list.
                            listOfWrapperCharges.add(orderWrapperCharges);
                            // add the charges to the local wrappercharge
                            locOrderWrapperCharges.add(orderWrapperCharges); 
                            locMapOrder_Charges.put(charge.Job_Rate_Plan__r.Job_Product__r.Job__c, locOrderWrapperCharges);
                            map_Acc_mapOrder_Charges.put(charge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c , locMapOrder_Charges);
                            orderChargeIds.add(charge.Id); 
                        }
                    }
                } 
            }
        }

        // creating group for the selected charges, and then assigned from created group to selected charges.
        public pagereference saveGroup(){
            SavePoint sp; 
            try { 
                listOfChargesToUpdate.clear();
                sp = Database.SetSavePoint();
                if(groupObj.Type__c == 'Volume Based' && groupObj.Minimum_Customer_Spend_Amount__c != null){
                    groupObj.Minimum_Customer_Spend_Amount__c = null;
                    insert groupObj;
                }else{
                    insert groupObj;
                }
                for(OrderWrapperCharges orderWrapperCharges : listOfWrapperCharges) {
                    if(orderWrapperCharges.isSelectedCharge){
                        if(orderChargeIds.contains(orderWrapperCharges.orderCharge.Id)){
                            listOfChargesToUpdate.add(new Job_Rate_Plan_Charge__c(Id = orderWrapperCharges.orderCharge.Id, Grouping__c = groupObj.Id));
                        }
                    }
                }
                if(!listOfChargesToUpdate.isEmpty()) {
                    update listOfChargesToUpdate;
                } 

            }catch(DMLException dMlEx){
                // Added by Lopamudra ticket : INVOICEIT-310
                Apexpages.Message errorMessage; 
                for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                { 
                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                    Apexpages.addMessage(errorMessage);      
                } 
                return null; 
            }catch(Exception ex) {
                Database.rollback(sp);
                Grouping__c groupObjTemp = groupObj;
                groupObj = new Grouping__c();
                groupObj = groupObjTemp.clone(false);
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName() + ':' + ex.getMessage() + ':LINE ' + ex.getLineNumber()));
                return null;  
            }  
            return new pagereference('/' + groupObj.id);
        }

        // this method is used for editing and updating the charges of particuler selected group.
        public pagereference updateGroup(){
            SavePoint sp; 
            try { 
                sp = Database.SetSavePoint();
                update groupObj;
                listOfChargesToUpdate.clear();
                for(OrderWrapperCharges orderWrapperCharges : listOfWrapperCharges){
                    // make all the Grouping__c to null for the unselected AccountId.
                    if(!setOfAccountIds.contains(orderWrapperCharges.orderCharge.Job_Rate_Plan__r.Job_Product__r.Job__r.Account__c)){
                        listOfChargesToUpdate.add(new Job_Rate_Plan_Charge__c(id=orderWrapperCharges.orderCharge.id,Grouping__c = null));
                    }
                    if(orderWrapperCharges.isSelectedCharge){
                        if(unSelectedOrderChargeIds.contains(orderWrapperCharges.orderCharge.id)) {
                            unSelectedOrderChargeIds.remove(orderWrapperCharges.orderCharge.id);
                        } 
                        if(orderChargeIds.contains(orderWrapperCharges.orderCharge.Id)){
                            listOfChargesToUpdate.add( new Job_Rate_Plan_Charge__c(id=orderWrapperCharges.orderCharge.id,Grouping__c = groupObj.id));
                        }
                    }
                }
                // make the Grouping__c is null for the unselected chargeids.
                for(Id chargeId : unSelectedOrderChargeIds) {
                    Job_Rate_Plan_Charge__c charge = new Job_Rate_Plan_Charge__c(Id = chargeId, Grouping__c = null);
                    listOfChargesToUpdate.add(charge);
                }
                // update all the charges
                if(!listOfChargesToUpdate.isEmpty()) {
                    update listOfChargesToUpdate;
                } 
            }catch(DMLException dMlEx){
                // Added by Lopamudra ticket : INVOICEIT-310
                Apexpages.Message errorMessage; 
                for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                { 
                    errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                    Apexpages.addMessage(errorMessage);      
                } 
                return null; 
            }catch(Exception ex) {
                Database.rollback(sp);
                Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR,system.Label.ExceptionMessage + ex.getTypeName() + ':' + ex.getMessage() + ':LINE ' + ex.getLineNumber()));
                return null;
            } 
            return new pagereference('/'+groupObj.id);
        }

        // order charge wrapper class
        public class OrderWrapperCharges {
            public boolean isSelectedCharge {get;set;}
            public Job_Rate_Plan_Charge__c orderCharge {get;set;}
        } 
    }