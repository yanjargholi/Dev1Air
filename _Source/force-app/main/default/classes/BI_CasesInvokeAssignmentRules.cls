/**********************************************************************
Name:  BI_CasesInvokeAssignmentRules
======================================================
======================================================
Purpose:
-------
Invoke Case Assignment Rules after Case is updated via process builder
Currently Used in Process Builder Flow: tbd
======================================================
======================================================
History
-------
VERSION  AUTHOR                    DATE              DETAIL            
1.0     Yolande Anjargholi        2020 - 02          INITIAL DEVELOPMENT 
***********************************************************************/

public class BI_CasesInvokeAssignmentRules {

    @InvocableMethod
    
    public static void CaseAssign(List<Id> CaseIds)
    {
        
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true; 
        	dmo.EmailHeader.TriggerUserEmail = true;
            List<case> Cases = new List<case>([Select Id,BI_Vanity_Mailbox_Source__c,BI_Subject_Category__c From Case Where Id in : CaseIds]);
            For(case c : Cases){
                c.setOptions(dmo);
            }
            update Cases;
   }
}