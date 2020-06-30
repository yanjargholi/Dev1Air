/**************************************************************************

Name : BI_TerritoryPlanWithAccountAndObjective 

===========================================================================
Purpose : This class is used for showing Objective realted to Account in the Territory Plan
===========================================================================
History:
--------
VERSION    AUTHOR         DATE           DETAIL          DESCRIPTION
1.0        Lester         31/May/2017     Created 
***************************************************************************/
public with sharing class BI_TerritoryPlanWithAccountAndObjective {

	//This method will get the objective list records to pass in the UI
	@AuraEnabled
	public static List<Account> getObjectivesList(Id recordId ,Boolean initflag, String sortField, boolean isAsc) {
		List<Account> listAccount = new List<Account>();
		List<BI_Territory_Plan__c> terrPlan = [Select OwnerId From BI_Territory_Plan__c Where Id =: recordId limit 1];
	    String soql = '';

	    //System.debug(LoggingLevel.INFO, '*** terrPlan: ' + terrPlan);
		Set<Id> ownerids = new Set<Id>();
		if(terrPlan.size()>0){
			for(BI_Territory_Plan__c tp: terrPlan){
				ownerids.add(tp.OwnerId);
			}
		}
		//SOQL Dynamic to pass the caluses
		soql = 'Select Id,Name,Owner.Name,Phone,BillingCity,BI_Abbreviated_Account_Name__c,SIP_ARC_Number__c,BI_NH_Corporate_Code__c,BI_LH_UCID__c,SIP_Corp_UCS_ID__c,RecordType.Name FROM Account WHERE OwnerId IN';
		soql +=':ownerids';		
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
        
		//System.debug(LoggingLevel.INFO, '*** : soql' + soql);
		//--listAccount = Database.Query(soql);
		//--return listAccount;
        
        list <Account> lstResult;
        try {
            //--listAccount = Database.Query(soql);
            lstResult = Database.Query(soql);
            //System.debug(LoggingLevel.INFO, '*** lstResult: ' + lstResult);
            List <Account> returnAccList = new List <Account> ();
            
            for (account a : lstResult){
                returnAccList.add(a);
            }
            return returnAccList;
        }
        catch (Exception c){
            return null;
        }
        
        
	} //end method

} //end class