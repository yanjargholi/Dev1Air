/**********************************************************************
   Name:  BI_EventTriggerHandler
   ======================================================
   ======================================================
   Purpose:
   -------
   Auto set the Related to field for a task if the relatedto whatid 
   and related to whoid is blank when the task is created. We are setting
   related to field to a generic account so that activities are visible
   to users instead of just the owner, and will therefor show up in activity 
   reporting and the bi-weekly reports

   Invoked by Trigger: BI_EventTrigger

   ======================================================
   ======================================================
   History
   -------
   VERSION  AUTHOR            DATE              DETAIL                  
   1.0     YOLANDE ANJ	     04/10/2018         Initial Development
 ***********************************************************************/

public class BI_EventTriggerHandler implements SIP_Triggers.Handler {
    
    List<Event> NewEventTriggerContextList = new List<Event>();
    
    public void handle(){
        
        if(Trigger.isBefore && Trigger.isInsert){
            For(Event newEvent : (List<Event>)Trigger.new){
                if(newEvent.WhatId == null && newEvent.WhoId == null && newEvent.IsPrivate == False){
                    NewEventTriggerContextList.add(newEvent);
                }
            } 
        }
        
        if(NewEventTriggerContextList.size() > 0){
            UpdateEvents();
        }
        
    }//end handle 
    
    private void UpdateEvents(){
        try{
            //get the id from custom labels for the account used for activity sharing
            Id accId = system.Label.BI_Activity_Sharing_Account_ID;
            //Use the Id to retrieve the account id 
            Id SharingAccountId = [Select Id From Account Where Id  = :accId limit 1].Id;
            
            List<Event> insertEvents = new List<Event>();
            
            if(SharingAccountId != null){
                
                For(Event erec : NewEventTriggerContextList){
                    //trec.Whatid = '001m000000diZZRAA2'; crmdev3
                    erec.Whatid = SharingAccountId;
                    insertEvents.add(erec);
            	}
            }
            
            if(insertEvents.size() > 0){
                insert insertEvents;
            }
            
        }//end try
        catch(Exception e){system.debug('error ' +e);
                          }
        
    }//end method
    

} //end class