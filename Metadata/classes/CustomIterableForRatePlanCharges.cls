public class CustomIterableForRatePlanCharges {

      public list<Product_Rate_Plan_Charge__c> listofCharges; // This is the main list which has all the  charges for particular rate plans
      public list<Product_Rate_Plan_Charge__c> listofChargesRequested;
      list<Product_Rate_Plan_Charge__c> listofChargesRequestedUpdate; // This will hold the latest values form DB
      public Integer i {get; set;}  // Here i point to the index (or) position of elements
      public Integer setPageSize; // No of records to display in page
      public integer size;
      public String sPrefix {get; set;}

      public CustomIterableForRatePlanCharges(Id selectedRatePlanId) { 
          sPrefix = CommonUtilClass.getPrefix();
          listofCharges = ProductCreationUtil.getProductRatePlanCharges(selectedRatePlanId);
          // Were getting the value from custom settings, based on value we are displaying the records
          setPageSize = integer.valueOf(Configuration__c.getValues('NAVIGATION_FOR_PRODUCTCHARGE').Number_Value__c);
          i = 0; 
          size = listofCharges.size();
      }   
      
      // Method will verify does it has next set of records
      public boolean hasNext(){ 
         if(i >= listofCharges.size()) {
             return false; 
         } else {
             return true; 
         }
     }
     
      // Method will verify does it has next set of records
     public boolean hasPrevious(){ 
         if(i <= setPageSize) {
             return false; 
         } else {
             return true; 
         }
     }  
     
      // This will display the next set of records
     public list<Product_Rate_Plan_Charge__c> next(){       
         size = listofCharges.size(); 
         listofChargesRequested = new list<Product_Rate_Plan_Charge__c>(); 
         integer startNumber;
         integer iDisplaySize;
         if(hasNext())
         {  
             if(size <= (i + setPageSize))
             {
                 startNumber = i;
                 i = size;
             }
             else
             {
                 i = (i + setPageSize);
                 startNumber = (i - setPageSize);
             }
             
             // If the size of the display elemets are less below code is excuted
             iDisplaySize = i - startNumber;
             integer iloc = i;
             if(iDisplaySize < setPageSize) {
               i = i + setPageSize - iDisplaySize;
               if(i > size) {
                  i = iloc;
               }
             }
             
             for(integer start = startNumber; start < i; start++)
             {
                 listofChargesRequested.add(listofCharges[start]);
             }
         } 
         listofChargesRequestedUpdate = getListOfChargesNew(listofChargesRequested);
         return listofChargesRequestedUpdate;
     } 
     
     // This will display the previous set of records
     public list<Product_Rate_Plan_Charge__c> previous(){  
         size = listofCharges.size();    
         listofChargesRequested = new list<Product_Rate_Plan_Charge__c>(); 
         
         if(i == size)
         {
             if(math.mod(size, setPageSize) > 0)
             {    
                 i = size - math.mod(size, setPageSize);
             }
             else
             {
                 i = (size - setPageSize);
             }         
         }
         else
         {
             i = (i - setPageSize);
         }
         // If the pointer index exceeds the size return the first elements
         if((i - setPageSize) > 0) {
              for(integer start = (i - setPageSize); start < i; ++start)
             {
                 listofChargesRequested.add(listofCharges[start]);
             }
         } else {
            return first();
         }
          
         listofChargesRequestedUpdate = getListOfChargesNew(listofChargesRequested);
         return listofChargesRequestedUpdate;
     }
     
      public list<Product_Rate_Plan_Charge__c> first(){
          i = 0;
          return next();
      }
      
      // This will display the last set of records
      public list<Product_Rate_Plan_Charge__c> last(){
          size = listofCharges.size();
          i = size; 
          listofChargesRequested = new list<Product_Rate_Plan_Charge__c>(); 
          
          integer max;
          if(i >= setPageSize) {
              max = i - setPageSize;
          } else {
              max = i;
          }

          for(integer start = max; start < i; ++start)
          {
             listofChargesRequested.add(listofCharges[start]);
          }         
          
          listofChargesRequestedUpdate = getListOfChargesNew(listofChargesRequested);
          return listofChargesRequestedUpdate;
      }
      
      // This is for getting the updated values
      public list<Product_Rate_Plan_Charge__c> getListOfChargesNew(list<Product_Rate_Plan_Charge__c> listofCharges) {
          String sQuery =  'SELECT ' + ProductCreationUtil.getObjectFields(sPrefix+'Product_Rate_Plan_Charge__c') +  
          + 'from Product_Rate_Plan_Charge__c where Id in: listofCharges'
          + ' Order by '+sPrefix+'Charge_Sequence_Number__c ';      
          sQuery = String.escapeSingleQuotes(sQuery);                                                    
          return Database.query(sQuery);
      }
  }