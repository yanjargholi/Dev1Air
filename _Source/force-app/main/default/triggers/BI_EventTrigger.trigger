/**********************************************************************
   Name:  BI_EventTrigger
   ======================================================
   ======================================================
   Purpose:
   -------
   Auto set the Related to field for a event if the relatedto whatid 
   and related to whoid is blank when the event is created. We are setting
   related to field to a generic account so that activities are visible
   to users instead of just the owner, and will therefor show up in activity 
   reporting and the bi-weekly reports

   Trigger Handler: BI_EventTriggerHandler

   ======================================================
   ======================================================
   History
   -------
   VERSION  AUTHOR            DATE              DETAIL                  
   1.0     YOLANDE ANJ	     04/11/2018         Initial Development
 ***********************************************************************/

trigger BI_EventTrigger on Event (before insert) {
    new SIP_Triggers()
        .bind(SIP_Triggers.Evt.beforeinsert, new BI_EventTriggerHandler())

    .manage();    

}