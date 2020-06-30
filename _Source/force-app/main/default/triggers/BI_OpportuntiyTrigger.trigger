/**************************************************************************************
Apex Trigger Name  : BI_OpportuntiyTrigger
Version          : 1.0 
Created Date     : 20 June 2017
Function         : Trigger on Opportuntiy
Modification Log :
-----------------------------------------------------------------------------
* Developer                       Date                       Description
* ----------------------------------------------------------------------------                 
* Sasi Naik                     20/06/2017                Original Version
***************************************************************************************/
trigger BI_OpportuntiyTrigger on Opportunity(after insert,before insert, before update, after update) {
     new SIP_Triggers()
    // before insert
     .bind(SIP_Triggers.Evt.beforeinsert, new BI_OpportunityTriggerHandler())
     
     // before Update
     .bind(SIP_Triggers.Evt.beforeupdate, new BI_OpportunityTriggerHandler())
     
     // After insert
     .bind(SIP_Triggers.Evt.afterinsert, new BI_OpportunityTriggerHandler())

    //After update
     .bind(SIP_Triggers.Evt.afterupdate, new BI_OpportunityTriggerHandler())
    .manage();
}