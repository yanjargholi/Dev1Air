/**********************************************************************
Name:  BI_LeadsRRobinInvokeAssignmentRules
======================================================
======================================================
Purpose:
-------
Invoke Lead Assignment Rules after Lead is updated via process builder
Currently Used in Process Builder Flow: Update Lead - Assign Round Robin ID
======================================================
======================================================
History
-------
VERSION  AUTHOR                    DATE              DETAIL            
1.0     Yolande Anjargholi        08/12/2019         INITIAL DEVELOPMENT 
***********************************************************************/

public class BI_LeadsRRobinInvokeAssignmentRules {

    @InvocableMethod
    
    public static void LeadAssign(List<Id> LeadIds)
    {
        
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule= true; 
        	dmo.EmailHeader.TriggerUserEmail = true;
            Lead Leads=[select id, Name, BI_Round_Robin_ID__c from lead where lead.id in :LeadIds];
                
            Leads.setOptions(dmo);
            update Leads;
   }
}