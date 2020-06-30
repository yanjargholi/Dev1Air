/**************************************************************************************************
 * Name           : SIP_Triggers
 * Object         : All Objects
 * Requirement    : 
 * Target         : Manage triggers and trigger handers to keep one object one trigger principle
 * Refer classes  :
 * Author         : Sasi Naik (sasibushan.n.vislavath@cnsdc01.pwc.com)
 * Create Date    : 2016-08-29
 * Modify History :
 **************************************************************************************************/
public class SIP_Triggers {
    /**
        Enum representing each of before/after CRUD events on Sobjects
    */
    public enum Evt {
        afterdelete, afterinsert, afterundelete,
        afterupdate, beforedelete, beforeinsert, beforeupdate   
    }
    
    /**
        Simplistic handler to implement on any of the event. It doesn't requires or enforces any patter except the
        method name to be "handle()", a developer is free to use any Trigger context variable or reuse any other
        apex class here.
        -- modified by natic add trigger switcher 20170511
        "getName()" need to return handler class name
    */
    public interface Handler {
        // Tcool 2017-06-01 commented, get name in isActive() method directly
        //String getName();
        void handle();
    } 
    
    // Internal mapping of handlers
    Map<String, List<Handler>> eventHandlerMapping = new Map<String, List<Handler>>();
    
    /**
        Core API to bind handlers with events
    */
    public SIP_Triggers bind(Evt event, Handler eh) {
        List<Handler> handlers = eventHandlerMapping.get(event.name());
        if (handlers == null) {
            handlers = new List<Handler>();
            eventHandlerMapping.put(event.name(), handlers);
        }
        if (isActive(eh)) {
            handlers.add(eh);
        }
        return this;
    }

    private static Boolean isActive(Handler eh) {
        // Tcool 2017-06-01
        String handlerName = String.valueOf(eh).substring(0,String.valueOf(eh).indexOf(':'));
        // Tcool 2017-05-30 fix issue, custom setting name cannot be too long
        for (Trigger_Switcher__c switcher : Trigger_Switcher__c.getAll().values()) {
            if (switcher.Apex_Trigger_Handler_Name__c.toUpperCase() == handlerName.toUpperCase()) {
                return switcher.Active__c;
            }
        }
        /*Trigger_Switcher__c switcher = Trigger_Switcher__c.getValues(eh.getName());
        if (switcher != null) {
            return switcher.Active__c;
        }*/
        return true;
    }
    
    /**
        Invokes correct handlers as per the context of trigger and available registered handlers
    */
    public void manage() {
        Evt ev = null;
        if(Trigger.isInsert && Trigger.isBefore){
            ev = Evt.beforeinsert;
        } else if(Trigger.isInsert && Trigger.isAfter){
            ev = Evt.afterinsert;
        } else if(Trigger.isUpdate && Trigger.isBefore){
            ev = Evt.beforeupdate;
        } else if(Trigger.isUpdate && Trigger.isAfter){
            ev = Evt.afterupdate;
        } else if(Trigger.isDelete && Trigger.isBefore){
            ev = Evt.beforedelete;
        } else if(Trigger.isDelete && Trigger.isAfter){
            ev = Evt.afterdelete;
        } else if(Trigger.isundelete){
            ev = Evt.afterundelete;             
        }
        List<Handler> handlers = eventHandlerMapping.get(ev.name());
        if (handlers != null && !handlers.isEmpty()) {
            for (Handler h : handlers) {
                h.handle();
            }
        }
    }
    
}