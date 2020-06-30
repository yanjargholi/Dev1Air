public with sharing class BI_TerritoryPlanWithAccountPlans {

	//This method will get the account plan list records to pass in to the lightning component UI
	@AuraEnabled
	public static List<BI_Account_Plan__c> getAccountPlanList(Id recordId ,Boolean initflag, String sortField, boolean isAsc) {
		
		List<BI_Account_Plan__c> listAccountPlans = new List<BI_Account_Plan__c>();
		
        List<BI_Territory_Plan__c> terrPlan = [Select Id, OwnerId, BI_Territory_Plan_Year__c From BI_Territory_Plan__c Where Id =: recordId limit 1];
	    String soql = '';

	    //System.debug(LoggingLevel.INFO, '*** terrPlan: ' + terrPlan);
		Set<Id> ownerids = new Set<Id>();
		Set<String> planYears = new Set<String>();
        
        if(terrPlan.size()>0){
			for(BI_Territory_Plan__c tp: terrPlan){
				ownerids.add(tp.OwnerId);
                planYears.add(tp.BI_Territory_Plan_Year__c);
			}
		}
		

        
        //SOQL Dynamic to pass the caluses
		soql = 'Select Id,Name,Owner.Name,BI_Account__c,BI_Plan_Year__c, RecordType.Name, BI_Account__r.BI_Account_Type_ID__c, BI_ManagerRSD_Review_Completed_On__c, BI_RSDMD_Review_Completed_On__c FROM BI_Account_Plan__c WHERE OwnerId IN';
		soql +=':ownerids' + ' ';
        soql +='AND BI_Plan_Year__c IN' + ' ';
        soql +=':planYears';
		//soql += ' order by Name, RecordType.Name ASC';

        
        if (sortField != '') {
         soql += ' order by ' + sortField;
         if (isAsc) {
            soql += ' asc';
         } else {
            soql += ' desc';
         }
      }
		
       //soql += 'Limit 20';
        //set record limit
        if(initflag == true){
			soql=soql + ' limit 25';
		} else {
			soql=soql + ' limit 10000';
		 
		}

        
        list <BI_Account_Plan__c> lstResult;
        try {
            //--listAccount = Database.Query(soql);
            lstResult = Database.Query(soql);
            //System.debug(LoggingLevel.INFO, '*** lstResult: ' + lstResult);
            List <BI_Account_Plan__c> returnAccPlanList = new List <BI_Account_Plan__c> ();
            
            for (BI_Account_Plan__c accPlan : lstResult){
                returnAccPlanList.add(accPlan);
            }
            return returnAccPlanList;
           
        }
        catch (Exception c){
            return null;
        }
        
        
	} //end method

} //end class