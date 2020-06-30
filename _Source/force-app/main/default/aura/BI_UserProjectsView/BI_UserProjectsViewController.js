({
	doInit : function(component, event, helper) {
		helper.onLoad(component, event, 'Name');
	},
    
    navigateToObjective:function(component, evt){
    //debugger;
    var sObectEvent = $A.get("e.force:navigateToSObject");
      sObectEvent .setParams({
        "recordId": evt.currentTarget.id
      });
    sObectEvent.fire(); 
  },
    
})