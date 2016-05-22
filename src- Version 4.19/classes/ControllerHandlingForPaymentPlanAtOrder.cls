public with sharing class ControllerHandlingForPaymentPlanAtOrder {
            
            public Job__c orderObj{get;set;}
            public list<InstallmentWrapper> listOFInstallmentWrapper{get;set;}
            public Payment_Plan__c paymentPlan{get;set;}
            public integer InstllCount;
            public boolean isRender{get;set;}
            public list<Payment_Plan_Installment__c> listOfpaymentPlanInstallment;
            public boolean isAddedPID{get;set;}
            public boolean isPaymentPlan{get;set;}
            
            public ControllerHandlingForPaymentPlanAtOrder(ApexPages.StandardController controller) {
                    orderObj = (Job__c)controller.getRecord();
                    isRender = true;
                    orderObj = [select id,Name,Payment_Plan__c,Account__c,Account__r.Payment_Method__c,Total__c,
                                (SELECT Name  
                                FROM Order_Rate_Plan_Charges__r where Price_Type__c = 'One Time')
                                FROM Job__c where id=: orderObj.id];
                    listOFInstallmentWrapper = new list<InstallmentWrapper>();
                    InstllCount = 0;
                    
                    if(orderObj.Payment_Plan__c != null){
                       isAddedPID = false;
                    } else{
                       isAddedPID = true;
                    }

                    integer iCountOFCharges = [SELECT count() FROM Job_Rate_Plan_Charge__c
                                                WHERE Order__c =: orderObj.id]; 

                    String query3 = orderObj.id;
                    string paymentplaninstallment = 'SELECT id,Payment_Status__c FROM Payment_Plan_Installment__c WHERE Order__c = \'' + query3 + '\'' + ' AND Payment__c = null'; 

                    listOfpaymentPlanInstallment = Database.query(paymentplaninstallment);
                                                    
                    if(listOfpaymentPlanInstallment.size() > 0 ){
                       isPaymentPlan = true;
                    }else{
                       isPaymentPlan = false;
                    }                                   
                                                                          
                    if(iCountOFCharges == orderObj.Order_Rate_Plan_Charges__r.size()){
                          if(orderObj.Payment_Plan__c != null){
                           string query1 = 'SELECT Down_Payment__c,Down_Payment_Amount__c,Name,Installment_Start_Date__c,No_of_Installments__c,Type_of_Installments__c,Is_Plan_Editable__c,Maximum_Installments__c,Minimum_Installments__c '+
                                         'FROM Payment_Plan__c WHERE ID = \'' + orderObj.Payment_Plan__c + '\''; 
                           paymentPlan = Database.query(query1);
                           
                            String query2 = orderObj.id;
                            String strorderid = 'SELECT Account__c,Name,Description__c, Order__c,Payment_Date__c,Payment_Status__c,Payment_Method__c,Invoice__c,Payment__c,Payment_Amount__c,Payment_Type__c '+
                                                                                      'FROM Payment_Plan_Installment__c WHERE Order__c = \'' + query2 + '\''; 
                            list<Payment_Plan_Installment__c> lstInstallment = Database.query(strorderid);                                                            
                            
                            InstallmentWrapper installmentWrapperLocal;
                            for(Payment_Plan_Installment__c insPlan : lstInstallment){
                            installmentWrapperLocal = new InstallmentWrapper();
                            installmentWrapperLocal.paymetnInstallment = insPlan;                        
                            installmentWrapperLocal.iCount = InstllCount;
                            listOFInstallmentWrapper.add(installmentWrapperLocal);       
                            ++InstllCount;
                            isRender = true;
                            
                           }                                                 

                        }else{
                            paymentPlan = new Payment_Plan__c();
                            paymentPlan.Type_of_Installments__c = null;
                        }  
                    }else{
                        isRender = false;
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO, system.Label.PaymentPlan_Supports_OnetimeCharges);
                        Apexpages.addMessage(infoMessage);
                    }                           
            }

           Public void showPlanDetails(){
                string query4 = 'SELECT Down_Payment__c,Down_Payment_Amount__c,Name,Installment_Start_Date__c,No_of_Installments__c,Type_of_Installments__c,Is_Plan_Editable__c,Maximum_Installments__c,Minimum_Installments__c FROM Payment_Plan__c WHERE ID = \'' + orderObj.Payment_Plan__c + '\'';
                paymentPlan = Database.query(query4);
               
            }
            
            
            Public void modifyPlanDetails(){
                if(!listOfpaymentPlanInstallment.isEmpty()){
                    orderObj.Payment_Plan__c = null;
                    update orderObj;
                    delete listOfpaymentPlanInstallment;
                    isAddedPID = true;
                    isPaymentPlan = false;
                    listOFInstallmentWrapper.clear();
                    paymentPlan = new Payment_Plan__c();
                }
            }
            
            public PageReference processpaymentPlan(){
                    listOFInstallmentWrapper = new list<InstallmentWrapper>();
                    if(orderObj.Payment_Plan__c != null){                   
                            integer iCountOfInstallment = integer.valueof(paymentPlan.No_of_Installments__c);
                            Payment_Plan_Installment__c paymetnInstallment;
                            
                            
                            InstallmentWrapper installmentWrapperLocal;

                            paymetnInstallment = new Payment_Plan_Installment__c();
                            if(paymentPlan.Down_Payment_Amount__c != null){
                                 paymetnInstallment.Payment_Amount__c =  paymentPlan.Down_Payment_Amount__c;   
                            }else if(paymentPlan.Down_Payment__c != null){
                                paymetnInstallment.Payment_Amount__c = (paymentPlan.Down_Payment__c * orderObj.Total__c )/ 100 ;
                            } else{
                                paymetnInstallment.Payment_Amount__c = 0;
                            }

                            if(paymetnInstallment.Payment_Amount__c >= orderObj.Total__c){
                                Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO, system.Label.Down_Payment_Is_More);
                                Apexpages.addMessage(infoMessage);
                                return null;
                            }
                            
                            paymetnInstallment.Payment_Date__c = paymentPlan.Installment_Start_Date__c;                     

                        if(iCountOfInstallment > 0){
                            decimal iAmount = (orderObj.Total__c - paymetnInstallment.Payment_Amount__c) / iCountOfInstallment;

                            paymetnInstallment.Description__c = 'Down Payment';
                            paymetnInstallment.Order__c = orderObj.id;
                            paymetnInstallment.Account__c = orderObj.Account__c;
                            installmentWrapperLocal = new InstallmentWrapper();
                            installmentWrapperLocal.paymetnInstallment = paymetnInstallment;                        
                            installmentWrapperLocal.iCount = 0;
                            listOFInstallmentWrapper.add(installmentWrapperLocal); 

                            ++InstllCount;
                            
                               for(integer i=1; i<=iCountOfInstallment;i++){
                                    paymetnInstallment = new Payment_Plan_Installment__c();
                                    paymetnInstallment.Order__c = orderObj.id;
                                    if(paymentPlan.Type_of_Installments__c == 'Monthly'){
                                        if(paymentPlan.Installment_Start_Date__c != null){
                                            paymetnInstallment.Payment_Date__c = paymentPlan.Installment_Start_Date__c.addMonths(i);
                                        }
                                     }
                                paymetnInstallment.Payment_Amount__c =  iAmount;
                                paymetnInstallment.Account__c = orderObj.Account__c;
                                paymetnInstallment.Description__c = 'Installment  ' + i +'/'+iCountOfInstallment ;
                                installmentWrapperLocal = new InstallmentWrapper();
                                installmentWrapperLocal.paymetnInstallment = paymetnInstallment;                        
                                installmentWrapperLocal.iCount = i;
                                listOFInstallmentWrapper.add(installmentWrapperLocal);       
                                ++InstllCount;
                            } 
                        } 
                    }else{
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO, system.Label.Please_Select_Payment_Plan);
                        Apexpages.addMessage(infoMessage);
                        return null;
                    } 

                    return null;
            }


            public PageReference addInstallment(){
                
                integer iWrapperListCout = listOFInstallmentWrapper.size() -1 ;
                if(paymentPlan.Maximum_Installments__c != null && iWrapperListCout == integer.valueof(paymentPlan.Maximum_Installments__c)){
                    Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO, system.Label.Limit_Exceeded);
                    Apexpages.addMessage(infoMessage);
                    return null;
                }
                InstallmentWrapper installmentWrapperLocal;
                Payment_Plan_Installment__c paymetnInstallment = new Payment_Plan_Installment__c();
                paymetnInstallment.Order__c = orderObj.id;
                installmentWrapperLocal = new InstallmentWrapper();
                installmentWrapperLocal.paymetnInstallment = paymetnInstallment;
                installmentWrapperLocal.iCount = InstllCount + 1;
                listOFInstallmentWrapper.add(installmentWrapperLocal);      
                ++InstllCount;

                return null;
            }

            public PageReference removeInstallment(){
                integer iWrapperListCout = listOFInstallmentWrapper.size() - 1 ;
                if(paymentPlan.Minimum_Installments__c != null && iWrapperListCout == integer.valueof(paymentPlan.Minimum_Installments__c)){
                    Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.INFO, system.Label.You_Cannot_Remove);
                    Apexpages.addMessage(infoMessage);
                    return null;
                }
                string  sParamCount = system.currentPageReference().getParameters().get('unWantedInstallmentCount');
                Payment_Plan_Installment__c paymetnInstallmentToDelete = new Payment_Plan_Installment__c();
                for(integer i = 0; i< listOFInstallmentWrapper.size();i++){
                    InstallmentWrapper installmentWrapperLocal = listOFInstallmentWrapper[i];
                    if(installmentWrapperLocal.iCount == integer.valueof(sParamCount)){
                             if(installmentWrapperLocal.paymetnInstallment.id != null){
                                paymetnInstallmentToDelete.id = installmentWrapperLocal.paymetnInstallment.id;
                             }
                            listOFInstallmentWrapper.remove(i);     
                            break;
                    }
                }
                
                for(integer i = 0; i< listOfpaymentPlanInstallment.size();i++){
                    if(listOfpaymentPlanInstallment[i].id == paymetnInstallmentToDelete.id){
                        listOfpaymentPlanInstallment.remove(i);
                    }
                
                }
                    
                if(paymetnInstallmentToDelete.id != null){
                    delete paymetnInstallmentToDelete;
                }
                
                for(integer i=0;i<listOFInstallmentWrapper.size();i++){
                    if(i > 0){
                        listOFInstallmentWrapper[i].paymetnInstallment.Description__c = 'Installment  ' + i +'/'+(listOFInstallmentWrapper.size()-1);
                    }
                }
                
            return null;
            }

            public PageReference save(){
                try{
                list<Payment_Plan_Installment__c> listOfInsUpdate = new list<Payment_Plan_Installment__c>();
                
                for(InstallmentWrapper installmentWrapperLocal : listOFInstallmentWrapper){

                    listOfInsUpdate.add(installmentWrapperLocal.paymetnInstallment);
                    if(installmentWrapperLocal.paymetnInstallment.Payment_Amount__c <0|| installmentWrapperLocal.paymetnInstallment.Payment_Amount__c == null){
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.Payment_Amount_should_be_greater_than_zero);
                        Apexpages.addMessage(infoMessage);
                        return null;
                    }
                    if(installmentWrapperLocal.paymetnInstallment.Account__c == null){
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.Please_select_Account);
                        Apexpages.addMessage(infoMessage);
                        return null;
                    }
                    if(installmentWrapperLocal.paymetnInstallment.Payment_Date__c < paymentPlan.Installment_Start_Date__c){
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.Payment_Date_Cannot_be_less_than_the_Installment_Start_Date);
                        Apexpages.addMessage(infoMessage);
                        return null;
                    }
                    if(installmentWrapperLocal.paymetnInstallment.Payment_Date__c == null ){
                        Apexpages.Message infoMessage = new Apexpages.Message(ApexPages.Severity.ERROR, system.Label.Please_Select_the_Payment_Date);
                        Apexpages.addMessage(infoMessage);
                        return null;
                    }
                }
                //Added by DL, INVOICEIT-635, Update order only if we genarate Installments.
                if(listOfInsUpdate.size() > 0){
                    update orderObj;
                }
                
                upsert listOfInsUpdate;

                return new PageReference('/'+orderObj.id);
                }catch(DMLException dMlEx) {
                    Apexpages.Message errorMessage; 
                    for (Integer i = 0; i < dMlEx.getNumDml(); i++)
                    { 
                            errorMessage = new Apexpages.Message(ApexPages.Severity.ERROR,dMlEx.getDmlMessage(i));
                            Apexpages.addMessage(errorMessage);      
                    } 
                    
                }catch(Exception ex) {
                   CustomException.populateApexMessage(CustomException.handleError('ControllerHandlingForPaymentPlanAtOrder', '', null, ex), 'ERROR');
                }
               return null; 
            } 

            public class InstallmentWrapper{
                    public Payment_Plan_Installment__c paymetnInstallment{get;set;}
                    public integer iCount{get;set;}

                    public InstallmentWrapper(){
                            paymetnInstallment =  new Payment_Plan_Installment__c();
                            iCount = 0;
                    }
            } 

    }