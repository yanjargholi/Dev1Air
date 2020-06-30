/**************************************************************************************
Apex Trigger Name  : BI_TerritoryPlanTrigger
Version          : 1.0 
Created Date     : 17 May 2017
Function         : Trigger on Territory Plan
Modification Log :
-----------------------------------------------------------------------------
* Developer                       Date                       Description
* ----------------------------------------------------------------------------                 
* Sasi Naik                     17/05/2016                Original Version
***************************************************************************************/
trigger BI_TerritoryPlanTrigger on BI_Territory_Plan__c(after insert, before update, after update) {
     new SIP_Triggers()
    // after insert
    .bind(SIP_Triggers.Evt.afterinsert, new BI_TerritoryPlanHandler())

    //After update
    .bind(SIP_Triggers.Evt.afterupdate, new BI_TerritoryPlanHandler())
    .manage();
}