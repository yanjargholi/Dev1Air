/**************************************************************************************
Apex Trigger Name  : BI_ObjectivesTrigger
Version          : 1.0 
Created Date     : 22 May 2017
Function         : Trigger on Objectives Object
Modification Log :
-----------------------------------------------------------------------------
* Developer                       Date                       Description
* ----------------------------------------------------------------------------                 
* Sasi Naik                     22/05/2016                Original Version
***************************************************************************************/
trigger BI_ObjectivesTrigger on BI_Objectives__c(before insert, before update) {
     new SIP_Triggers()
    // before insert
    .bind(SIP_Triggers.Evt.beforeinsert, new BI_ObjectiveHandler())

    //before update
    .bind(SIP_Triggers.Evt.beforeupdate, new BI_ObjectiveHandler())
    .manage();
}