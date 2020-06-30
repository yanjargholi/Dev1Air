/**********************************************************************
Purpose:
-------
   Contains methods used by Custom Lightning Component Bundle: BI_Objective_Enhancement_FocusAccounts
   1. fetchFocusRecords - returns existing focus records for the objective
   2. fetchAccounts - returns active corp, agency and membership accounts
                      > that don't already have focus records
                      > that belong to the objective owner
   3. createFocusCustomerRecords - creates focus account records for the selected accounts
								   > will auto create account plan for account if one does not exist 
                                   > will auto link account plan if an existing one is found
   4. createAccountPlans - invoked by the createFocusCustomerRecords to create accounts plans
                           for focus records to be created where the selected account does not have an
                           existing plan
History
-------
  VERSION       AUTHOR                   DATE                DETAIL                  
   1.0          YOLANDE ANJ	             2019 - 11           Initial Development
*************************************************************************/

public class BI_ObjectiveEnhancements {
    
    
    //Get and Retrun the Existing Focus Records
    @AuraEnabled
    public static List<BI_Focus_Account__c> fetchFocusRecords(Id recordId ,String sortField, boolean isAsc) {
        
        String soql = '';
        soql = 'Select Name, BI_Account__r.Name, BI_Objective_Strategy__c FROM BI_Focus_Account__c WHERE BI_Objective__c = :recordId';
        
        if (sortField != '') {
            soql += ' order by ' + sortField;
            if (isAsc) {
                soql += ' asc';
            } else {
                soql += ' desc';
            }
        }
        system.debug('************ fetching focus records query will be ' + soql);
        
        try {     
            List<BI_Focus_Account__c> returnFocusList; 
            returnFocusList = Database.Query(soql);
            if (returnFocusList.size() > 0){
                return returnFocusList;
            } else {
                return null;
            }
            
        }  catch (Exception c){
            return null;
        }
        
    } //end method
    
    
    //Get and Retrun th Accounts
    @AuraEnabled
    public static List<Account> fetchAccounts(Id recordId ,String sortField, boolean isAsc, string showSalesTeamAccounts) {
        system.debug('***** include sales team val is ' +showSalesTeamAccounts);
        String soql = '';
        List<Account> listAccounts = new List<Account>();
        
        //create a set of account ids that already have a focus record for the objective so that we exclude them from the displayed list
        Set<ID> existingFocusAccIds = new Set<Id>();       
        For(BI_Focus_Account__c fc : [Select BI_Account__c FROM BI_Focus_Account__c WHERE BI_Objective__c = :recordId ]){
            existingFocusAccIds.add(fc.BI_Account__c);
        }
        
        //get the objective owner id **bulkify** so that we can get the owners account records
        Set<Id> ownerids = new Set<Id>();		
        for(BI_Objectives__c ob: [Select OwnerId From BI_Objectives__c Where Id =: recordId]){
            ownerids.add(ob.OwnerId);
        }
        
        Set<String> recordTypes = new Set<String>{'Corporate', 'Agency HOL', 'Agency Branch', 'Custom Account', 'Membership Group', 'Membership Sub-Group'};
              
        //SOQL Dynamic to pass the caluses
        soql = 'Select Id,Name,Owner.Name,OwnerId,BI_Account_Type_ID__c,BillingCity FROM Account WHERE SIP_Active__c != \'InActive\' AND RecordType.Name In :recordTypes AND OwnerId IN :ownerids AND Id NOT IN :existingFocusAccIds';
        
        //get Sales Team Accounts
        if(showSalesTeamAccounts == 'true'){
            Set<Id> teamAccountIdSet = new Map<Id, Account>([Select Id From Account Where Id in (Select accountId from accountTeamMember where userId IN :ownerids) AND SIP_Active__c != 'InActive' AND Id NOT IN :existingFocusAccIds AND RecordType.Name In :recordTypes
                                                            ]).keySet();
            soql = 'Select Id,Name,Owner.Name,OwnerId,BI_Account_Type_ID__c,BillingCity FROM Account WHERE RecordType.Name In :recordTypes AND Id NOT IN :existingFocusAccIds AND (OwnerId IN :ownerids OR Id IN :teamAccountIdSet)';
        
        }
        
        
        if (sortField != '') {
            soql += ' order by ' + sortField;
            if (isAsc) {
                soql += ' asc';
            } else {
                soql += ' desc';
            }
        }
        
        list <Account> lstResult;
        try {
            //--listAccount = Database.Query(soql);
            lstResult = Database.Query(soql);
            //System.debug(LoggingLevel.INFO, '*** lstResult: ' + lstResult);
            List <Account> returnAccountList = new List <Account> ();
            
            for (Account acc : lstResult){
                returnAccountList.add(acc);
            }
            return returnAccountList;
            
        }
        catch (Exception c){
            return null;
        }
        
        
    } //end method
    
    @AuraEnabled
    public static BI_Result createFocusCustomerRecords(string objectiveId, List<Id> AccountIdList){
        //check if focus record exist for obj - customer
        //if not create it
        BI_Result ret = new BI_Result();
        String objOwnerId = '';
        String Year = '';
        List<BI_Focus_Account__c> toInsertFocusRecords = new List<BI_Focus_Account__c>();
        List<BI_Focus_Account__c> toCreatePlanFocusRecords = new List<BI_Focus_Account__c>();
        List<String> insertedFocusRecords = new List<String>();
        
        
        try{
            if(AccountIdList.size() > 0 && objectiveId != null){
                
                //get objective record
                system.debug('****** in handler if');
                for(BI_Objectives__c obj : [Select Id, Name, OwnerId, BI_RelatedPlan_Plan_Year__c From BI_Objectives__c WHERE Id = :objectiveId limit 1]){
                    objOwnerId = obj.OwnerId;
                    Year = obj.BI_RelatedPlan_Plan_Year__c;
                }
                
                Map<ID, Id> mapAccountIdwithAccountPlanId = new Map<ID, Id>();
                Map<ID, Id> mapAccountIdwithNewAccountPlanId = new Map<ID, Id>();
                
                for(BI_Account_Plan__c accPlan : [SELECT Id, BI_Account__c FROM BI_Account_Plan__c 
                                                  WHERE BI_Plan_Year__c = :Year 
                                                  AND OwnerId = :objOwnerId 
                                                  AND BI_Account__c IN :AccountIdList]){
                                                      mapAccountIdwithAccountPlanId.put(accPlan.BI_Account__c, accPlan.Id);
                                                  }
                
                system.debug('*********************** map populated is ' + mapAccountIdwithAccountPlanId);
                
                
                for(Id AccId : AccountIdList){
                    
                    Id planId = null;
                    
                    if(mapAccountIdwithAccountPlanId.containsKey(AccId)){
                        planId = mapAccountIdwithAccountPlanId.get(AccId);
                    }
                    system.debug('********** plan id if found is ' +planId);
                    system.debug('******* in loop for account - acc is ' +AccId);
                    
                    BI_Focus_Account__c fc = new BI_Focus_Account__c(
                        //OwnerId = objOwnerId,
                        BI_Objective__c = objectiveId,
                        BI_Account__c = AccId,
                        BI_Account_Plan__c = planId
                    );
                    toInsertFocusRecords.add(fc); 
                    //Get Focus Record Accounts with no plans
                    if(fc.BI_Account_Plan__c == null){
                        toCreatePlanFocusRecords.add(fc); 
                    }
                }
                
                //create the account plans for accounts / focus records with no plans                
                If(toCreatePlanFocusRecords.size() > 0){
                    mapAccountIdwithNewAccountPlanId = createAccountPlans(toCreatePlanFocusRecords, Year, objOwnerId);
                }
                
                //update the FR records with the plan ID of the newly created plans
                For(BI_Focus_Account__c newFCrec : toInsertFocusRecords){
                    if(mapAccountIdwithNewAccountPlanId.containsKey(newFCrec.BI_Account__c)){
                        newFCrec.BI_Account_Plan__c = mapAccountIdwithNewAccountPlanId.get(newFCrec.BI_Account__c);
                    }
                }
                
                system.debug('*******************************focus records created for insert ' + toInsertFocusRecords);
                
                if(toInsertFocusRecords.size() > 0){
                    Database.insert(toInsertFocusRecords, False);
                    ret.Result = True;                    
                }
                
                
            } else{
                ret.Result = False;
            }
            
        } catch (Exception e){
            ret.Result = False;
            ret.Errors.add(e.getMessage());
        }
        
        system.debug('the objective id is ' +objectiveId);
        system.debug('the accountlist is ' +AccountIdList);
        return ret;
    }//end method
    
    public static Map<Id, Id> createAccountPlans (List<BI_Focus_Account__c> fcsWithoutPlans, String Year, String OwnerId){
        
        Map<ID, Id> mapAccountIdwithnewPlanId = new Map<ID, Id>();
        List<BI_Account_Plan__c> newPlans = new List<BI_Account_Plan__c>();
        
        For(BI_Focus_Account__c noPlanFC : fcsWithoutPlans){
            ID accID = noPlanFC.BI_Account__c;
            Account acc = [Select Name, OwnerId,RecordType.Name From Account Where ID = :accID limit 1];
            String accName = acc.Name;
            String AccrecType = acc.RecordType.Name;
            String ownId = Ownerid;
            String accPlanrecTypeId = BI_UtilityCls.getRecordTypeIdByAPIName(BI_UtilityCls.OBJACCOUNTPLAN,BI_UtilityCls.AGENCYACCTPLANRECORDTYPE);  
            IF(AccrecType == BI_UtilityCls.ACCTCORPRECORDTYPE || AccrecType == 'Custom Account'){
                accPlanrecTypeId = BI_UtilityCls.getRecordTypeIdByAPIName(BI_UtilityCls.OBJACCOUNTPLAN,BI_UtilityCls.CORPACCTPLANRECORDTYPE);   
            }
            BI_Account_Plan__c pl = new BI_Account_Plan__c(
                Name = Year + ' - ' + accName,           
                OwnerId = ownId,
                BI_Account__c = noPlanFC.BI_Account__c,
                BI_Plan_Year__c = Year,
                RecordTypeId = accPlanrecTypeId
            );
            newPlans.add(pl); 
            
        }
        
        If(newPlans.size() > 0){
            insert newPlans;
            For(BI_Account_Plan__c prec : newPlans){
                mapAccountIdwithnewPlanId.Put(prec.BI_Account__c, prec.Id);
            }
        }
        
        return mapAccountIdwithnewPlanId;
        
    } 
}