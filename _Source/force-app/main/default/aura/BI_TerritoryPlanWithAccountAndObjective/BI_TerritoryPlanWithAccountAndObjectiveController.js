({
	doInit : function(component, event, helper) {
		helper.onLoad(component, event, 'Name');
	},
    
    sortName: function(component, event, helper) {
       // set current selected header field on selectedTabsoft attribute.     
       component.set("v.selectedTabsoft", 'Name');
       // call the helper function with pass sortField Name   
       helper.sortHelper(component, event, 'Name');
    },
    
    sortAbbvName: function(component, event, helper) {
       // set current selected header field on selectedTabsoft attribute.     
       component.set("v.selectedTabsoft", 'BI_Abbreviated_Account_Name__c');
       // call the helper function with pass sortField Name   
       helper.sortHelper(component, event, 'BI_Abbreviated_Account_Name__c');
    },
    
    sortPhone: function(component, event, helper) {
       // set current selected header field on selectedTabsoft attribute.     
       component.set("v.selectedTabsoft", 'Phone');
       // call the helper function with pass sortField Name   
       helper.sortHelper(component, event, 'Phone');
    },
    
    sortCity: function(component, event, helper) {
       // set current selected header field on selectedTabsoft attribute.     
       component.set("v.selectedTabsoft", 'BillingCity');
       // call the helper function with pass sortField Name   
       helper.sortHelper(component, event, 'BillingCity');
    },
    
    sortRecordType: function(component, event, helper) {
       // set current selected header field on selectedTabsoft attribute.     
       component.set('v.selectedTabsoft', 'RecordType.Name');
       // call the helper function with pass sortField Name   
       helper.sortHelper(component, event, 'RecordType.Name');
    },
    
  navigateToObjective:function(component, evt){
    //debugger;
    var sObectEvent = $A.get("e.force:navigateToSObject");
      sObectEvent .setParams({
        "recordId": evt.currentTarget.id
      });
    sObectEvent.fire(); 
  },
  navigateToViewAll : function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:BI_TerritoryPlanWithAccountAndObjectiveViewAll",
            componentAttributes: {
                recordId : component.get("v.recordId")
            }
        });
        evt.fire();
    }

})