public class CustomIterableForRatePlan { 

      public list<Product_Rate_Plan__c> listofRatePlans; // This is the main list which has all the rate plans for particular product
      public list<Product_Rate_Plan__c> listofRatePlansRequested;
      list<Product_Rate_Plan__c> listofRatePlansRequestedUpdate; // This will hold the latest values form DB
      public Integer i {get; set;} // Here i point to the index (or) position of elements
      public Integer setPageSize; // No of records to display in page
      public integer size;
      public String sPrefix {get; set;}

      public CustomIterableForRatePlan(Id productId) { 
      sPrefix = CommonUtilClass.getPrefix();
          listofRatePlans = ProductCreationUtil.getListOfRatePlansNew(productId);
          // Were getting the value from custom settings, based on value we are displaying the records
          setPageSize = integer.valueOf(Configuration__c.getValues('NAVIGATION_FOR_PRODUCTRATEPLAN').Number_Value__c);
          i = 0; 
          size = listofRatePlans.size();
      }   
      
      // Method will verify does it has next set of records
      public boolean hasNext(){ 
         if(i >= listofRatePlans.size()) {
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
     public list<Product_Rate_Plan__c> next(){       
         size = listofRatePlans.size();
         listofRatePlansRequested = new list<Product_Rate_Plan__c>(); 
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
                 listofRatePlansRequested.add(listofRatePlans[start]);
             }
         } 
         listofRatePlansRequestedUpdate = getListOfRatePlansNew(listofRatePlansRequested);
         return listofRatePlansRequestedUpdate;
     } 
     
     // This will display the previous set of records
     public list<Product_Rate_Plan__c> previous(){ 
         size = listofRatePlans.size();     
         listofRatePlansRequested = new list<Product_Rate_Plan__c>(); 
         
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
                 listofRatePlansRequested.add(listofRatePlans[start]);
             }
         } else {
            return first();
         }
         
         listofRatePlansRequestedUpdate = getListOfRatePlansNew(listofRatePlansRequested);
         return listofRatePlansRequestedUpdate;
     }
     
      public list<Product_Rate_Plan__c> first(){
          i = 0;
          return next();
      }
      
      // This will display the last set of records
      public list<Product_Rate_Plan__c> last(){
          size = listofRatePlans.size();
          i = size; 
          listofRatePlansRequested = new list<Product_Rate_Plan__c>(); 
          
          integer max;

          if(i >= setPageSize) {
              max = i - setPageSize;
          } else {
              max = i;
          }
          
          for(integer start = max; start < i; ++start)
          {
             listofRatePlansRequested.add(listofRatePlans[start]);
          }         
          
          listofRatePlansRequestedUpdate = getListOfRatePlansNew(listofRatePlansRequested);
         return listofRatePlansRequestedUpdate;
      }
      
      // This is for getting the updated values
      public list<Product_Rate_Plan__c> getListOfRatePlansNew(list<Product_Rate_Plan__c> listofProdcutRatePlan) {
          String sQuery =  'SELECT ' + ProductCreationUtil.getObjectFields(sPrefix+ 'Product_Rate_Plan__c') +  
          + 'from Product_Rate_Plan__c where Id in: listofProdcutRatePlan'
          + ' Order by createdDate ';      
          sQuery = String.escapeSingleQuotes(sQuery);
          return Database.query(sQuery);
      }
  }