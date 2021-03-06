({
	doInit : function(component, event, helper) {
		helper.onLoad(component, event, 'Name');
	},
	
	 navigateToAccountPlan:function(component, evt){
    //debugger;
    var sObectEvent = $A.get("e.force:navigateToSObject");
      sObectEvent .setParams({
        "recordId": evt.currentTarget.id
      });
    sObectEvent.fire(); 
  },
    
    sortName: function(component, event, helper) {
       // set current selected header field on selectedTabsoft attribute.     
       component.set("v.selectedTabsoft", 'Name');
       // call the helper function with pass sortField Name   
       helper.sortHelper(component, event, 'Name');
    },
    
    sortIdentifier: function(component, event, helper) {
       // set current selected header field on selectedTabsoft attribute.     
       component.set("v.selectedTabsoft", 'BI_Account__r.BI_Account_Type_ID__c');
       // call the helper function with pass sortField Name   
       helper.sortHelper(component, event, 'BI_Account__r.BI_Account_Type_ID__c');
    },
    
    close : function(component, event, helper) {
       var sObectEvent = $A.get("e.force:navigateToSObject");
       sObectEvent .setParams({
        "recordId": component.get('v.recordId')
                      
      });
    sObectEvent.fire(); 
   }
  
})