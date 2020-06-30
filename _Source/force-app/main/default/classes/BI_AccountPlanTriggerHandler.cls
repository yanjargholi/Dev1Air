/**************************************************************************************************
* Name           : BI_AccountPlanTriggerHandler
* author         : Yolande Anjargholi
* Objective      : 1) When a new account plan is created with auto complete from prior year set to yes,
look for the prior year account plan for the account, and pre-populate certain fields with prior 
year values. Happens before insert only. Method is AutoComplete.
2) if multiple prior year plans exist, first look for plan that belongs to logged in user,
if none found, look for plan that belonged to acc owner, 
if none found, use the first prior year plan found
* Target         : BI_Account_Plan__c

* Refer Trigger  : BI_AccountPlanTrigger

* History        :  VERSION    |     DATE       |        AUTHOR         |  DESCRIPTION
V1.0       |  Sept/05/2018  |   Yolande Anjargholi  |    Created 
V1.1       | 2019-11        |  Yolande Anjargholi   |    Updated        | many fields auto completed from prior year plans moved to account object instead
                                                                          logic changed to populate account object fields from a prior year plan if the account fields are empty
test 123                                                                       


********************************************************************************************/
public class BI_AccountPlanTriggerHandler implements SIP_Triggers.Handler {
    
    private List<BI_Account_Plan__c> NewAccPlanList = new List<BI_Account_Plan__c>();
    Map<BI_Account_Plan__c, List<BI_Account_Plan__c>> planMap = new Map<BI_Account_Plan__c, List<BI_Account_Plan__c>>(); 
    Set<BI_Account_Plan__c> PlansInContext = new Set<BI_Account_Plan__C>();
    Set<Id> AccIds = new Set<Id>();
    Set<String> planYears = new Set<String>();
    
    public void handle() {
        if (Trigger.isBefore && Trigger.isInsert) {
            for (BI_Account_Plan__c accPlan : (List<BI_Account_Plan__c>)Trigger.new){
                
                if(accPlan.BI_Auto_Complete_From_Prior_Year_Plan__c == 'Yes'){
                    PlansInContext.add(accPlan);
                    AccIds.add(accPlan.BI_Account__c);
                    Integer PlanYearInt = integer.valueOf(accPlan.BI_Plan_Year__c);
                    planYears.add(String.valueOf(PlanYearInt - 1));
                }
            }
        }
        
        if (PlansInContext.size() > 0) {
            AutoComplete();
        }        
        
    }
    
    private void AutoComplete(){
        
        Id LoggedInUserId = userInfo.getUserId();
        Map<Id, Set<BI_Account_Plan__c>> AccwithOldplansMap = new Map<Id, Set<BI_Account_Plan__c>>(); 
        Map<Id, Account> accMap = new Map<Id, Account>();
        List<Account> updateAccSet = new List<Account>();
        
        
        For(BI_Account_Plan__c oldPlan : [Select Id, OwnerId, BI_Account__r.OwnerId, Name, BI_Plan_Year__c, BI_Account_Overview_History__c, BI_Strategic_Plan_Details__c, 
                                          BI_Executive_Engagement_Plan_Details__c, BI_Soft_Dollar_Benefits__c, BI_Strengths__c, BI_Weaknesses__c, BI_Opportunities__c, BI_Threats__c 
                                          From BI_Account_Plan__c Where BI_Plan_Year__c In :planYears and BI_Account__c In : AccIds])
        {
            if(AccwithOldplansMap .containsKey(oldPlan.BI_Account__c)){                   
                AccwithOldplansMap.get(oldPlan.BI_Account__c).add(oldPlan);
            } 
            else{
                AccwithOldplansMap.put(oldPlan.BI_Account__c, new Set< BI_Account_Plan__c >{oldPlan});
            }                                                                             
        }
        
        For(Account acc : [Select Id, Name, BI_Account_Overview_History__c, BI_Strengths__c,BI_Opportunities__c, BI_Weaknesses__c, BI_Threats__c 
                           From Account Where Id In :AccwithOldplansMap.keyset() ]){
                               accMap.put(acc.Id, acc);
                           }
        
        
        For(BI_Account_Plan__c accP : PlansInContext){            
            
            //old Plan to auto complete from
            BI_Account_Plan__c oldPlan = new BI_Account_Plan__c(); 
            List<BI_Account_Plan__c> thisUserOldPlans = new List<BI_Account_Plan__C>();
            List<BI_Account_Plan__c> accOwnerOldPlans = new List<BI_Account_Plan__C>();
            List<BI_Account_Plan__c> oldPlanList = new List<BI_Account_Plan__C>();
            Id accId = accP.BI_Account__c;
            Integer InsertedPlanYearInt = integer.valueOf(accP.BI_Plan_Year__c);
            String year = String.valueOf(InsertedPlanYearInt - 1);
            
            If(AccwithOldplansMap .containsKey(accId)){
                
                For(BI_Account_Plan__c oldie : AccwithOldplansMap.get(accId)){
                    
                    If(thisUserOldPlans.size() == 0 && oldie.OwnerId == LoggedInUserId && oldie.BI_Plan_Year__c == year){
                        thisUserOldPlans.add(oldie);
                    }                
                    If(thisUserOldPlans.size() == 0 && accOwnerOldPlans.size() == 0 && oldie.OwnerId == oldie.BI_Account__r.OwnerId && oldie.BI_Plan_Year__c == year){
                        accOwnerOldPlans.add(oldie);
                    }                
                    If(thisUserOldPlans.size() == 0 && accOwnerOldPlans.size() == 0 && oldie.BI_Plan_Year__c == year){
                        oldPlanList.add(oldie);
                    }                
                }
                
                If(thisUserOldPlans.size() >= 1){
                    oldPlan = thisUserOldPlans[0];
                } else {
                    if(accOwnerOldPlans.size() >= 1){
                        oldPlan = accOwnerOldPlans[0];
                    } 
                }                
                IF(thisUserOldPlans.size() == 0 && accOwnerOldPlans.size() == 0 && oldPlanList.size() >=1){
                    oldPlan = oldPlanList[0];
                }
                
            } else{
                accP.BI_Auto_Complete_From_Prior_Year_Plan__c = 'Yes - Result: ' + year + ' plan not found';                
            }
            
            
            If(oldplan.Id != null){
                Account thisAcc = accMap.get(accId);
                String placeholdertext = '<p><b>System Message</b>: Copied from ' + oldPlan.BI_Plan_Year__c + '. Review/Update as required, and <u>delete this system message once done</u></p><br></br>';
                String emptyplaceholdertext = '<p><b>System Message</b>: ' + oldPlan.BI_Plan_Year__c  + ' plan had no info. Enter details for this plan, and <u>delete this system message once done</u></p><br></br>';
                
                If((String.isBlank(thisAcc.BI_Account_Overview_History__c)) || 
                   (String.isBlank(thisAcc.BI_Strengths__c)) || 
                   (String.isBlank(thisAcc.BI_Opportunities__c)) || 
                   (String.isBlank(thisAcc.BI_Weaknesses__c)) || 
                   (String.isBlank(thisAcc.BI_Threats__c))){
                       
                       if(String.isBlank(thisAcc.BI_Account_Overview_History__c) && !String.isBlank(oldPlan.BI_Account_Overview_History__c) ){
                           thisAcc.BI_Account_Overview_History__c = oldPlan.BI_Account_Overview_History__c;
                       }
                       
                       if(String.isBlank(thisAcc.BI_Strengths__c) && !String.isBlank(oldPlan.BI_Strengths__c)){
                           thisAcc.BI_Strengths__c = oldPlan.BI_Strengths__c;
                       }
                       
                       if(String.isBlank(thisAcc.BI_Opportunities__c) && !String.isBlank(oldPlan.BI_Opportunities__c)){
                           thisAcc.BI_Opportunities__c = oldPlan.BI_Opportunities__c;
                       }
                       
                       if(String.isBlank(thisAcc.BI_Weaknesses__c) && !String.isBlank(oldPlan.BI_Weaknesses__c)){
                           thisAcc.BI_Weaknesses__c = oldPlan.BI_Weaknesses__c;
                       }
                       
                       if(String.isBlank(thisAcc.BI_Threats__c) && !String.isBlank(oldPlan.BI_Strengths__c)){
                           thisAcc.BI_Threats__c = oldPlan.BI_Strengths__c;
                       }                      
                       updateAccSet.add(thisAcc);
                   }
                
                accP.BI_Auto_Completed_From__c = oldPlan.id;
                
                
                /*
                 * deprecated in 2019-11 Sales planning release as many of these fields moved to the account object
                if(String.isblank(oldPlan.BI_Strategic_Plan_Details__c)){
                    accP.BI_Strategic_Plan_Details__c = emptyplaceholdertext;
                } else{ accP.BI_Strategic_Plan_Details__c = placeholdertext + oldPlan.BI_Strategic_Plan_Details__c;}
                
                if(String.isblank(oldPlan.BI_Executive_Engagement_Plan_Details__c)){
                    accP.BI_Executive_Engagement_Plan_Details__c = emptyplaceholdertext;
                } else{ accP.BI_Executive_Engagement_Plan_Details__c = placeholdertext + oldPlan.BI_Executive_Engagement_Plan_Details__c;}
                
                if(String.isblank(oldPlan.BI_Account_Overview_History__c)){
                    accP.BI_Account_Overview_History__c = emptyplaceholdertext;
                } else{ accP.BI_Account_Overview_History__c = placeholdertext + oldPlan.BI_Account_Overview_History__c;}
                
                if(String.isblank(oldPlan.BI_Soft_Dollar_Benefits__c)){
                    accP.BI_Soft_Dollar_Benefits__c = emptyplaceholdertext;
                } else{ accP.BI_Soft_Dollar_Benefits__c = placeholdertext + oldPlan.BI_Soft_Dollar_Benefits__c;}
                
                if(String.isblank(oldPlan.BI_Strengths__c)){
                    accP.BI_Strengths__c = emptyplaceholdertext;
                } else{ accP.BI_Strengths__c = placeholdertext + oldPlan.BI_Strengths__c;}
                
                if(String.isblank(oldPlan.BI_Weaknesses__c)){
                    accP.BI_Weaknesses__c = emptyplaceholdertext;
                } else{ accP.BI_Weaknesses__c = placeholdertext + oldPlan.BI_Weaknesses__c;}
                
                if(String.isblank(oldPlan.BI_Opportunities__c)){
                    accP.BI_Opportunities__c = emptyplaceholdertext;
                } else{ accP.BI_Opportunities__c = placeholdertext + oldPlan.BI_Opportunities__c;}
                
                if(String.isblank(oldPlan.BI_Threats__c)){
                    accP.BI_Threats__c = emptyplaceholdertext;
                } else{ accP.BI_Threats__c = placeholdertext + oldPlan.BI_Threats__c;}
                */
                accP.BI_Auto_Complete_From_Prior_Year_Plan__c = 'Yes - Result: Success';                
            } 
  
        } //end loop through map keys
        update updateAccSet;
    }//end method
    
} //end class