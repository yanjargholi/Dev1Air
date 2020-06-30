({    
     onLoad: function(component, event, sortField) {
      //fire event to set component name
      //var compEvent = component.getEvent("refreshChildComponent");
      //compEvent.setParams({"componentName" : "BI_UserProjectsView" }); 
      //compEvent.fire();
         
         
         //call apex class method
      var action = component.get("c.getProjectRecordsView");
 
      // pass the apex method parameters to action 
      action.setParams({
         'sortField': sortField,
         'isAsc': component.get("v.isAsc"),
		 recordId : component.get('v.recordId'),
		 initflag : true
      });
      action.setCallback(this, function(a) {
         //store state of response
         var rtnValue = a.getReturnValue();
         if (rtnValue != null) {
            //set response value in ListOfContact attribute on component.
            component.set('v.listLiew', rtnValue);
         }
      });
      $A.enqueueAction(action);
   },
})