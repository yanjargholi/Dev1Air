({
     doInit : function(component, event, helper) {
       helper.getValidObjectiveYearPickListvalues(component, event,helper);
     },
      pushobjectives : function(component, event, helper) { 
	       //helper.GenarateObjectives(component);
	       var action = component.get("c.CreateRelevantPlanObjectives");
	       var vObjType = document.getElementById('vObjType').value;
	            action.setParams({
	                objectiveTypeid : component.get("v.recordId"),
	                'validyear': vObjType
	            });
	    	
	        action.setCallback(this, function(a) {
	            if (a.getState() === "SUCCESS") {
	                //component.set("v.Successvalue", a.getReturnValue());
	                //var dismissActionPanel = $A.get("e.force:closeQuickAction");
	                //dismissActionPanel.fire();
	                //$A.get('e.force:refreshView').fire();
	               component.set('v.statusMessage', a.getReturnValue()); 
	            } else if (a.getState() === "ERROR") {
	               // $A.log("Errors", a.getError());
	               this.showErrorMessage(component, a.getError());
	            }
	        });

	         var dismissActionPanel = $A.get("e.force:closeQuickAction");
		       dismissActionPanel.fire();
		       $A.get('e.force:refreshView').fire();

			        $A.enqueueAction(action);
		     },

    close : function(component, event, helper) {
       var dismissActionPanel = $A.get("e.force:closeQuickAction");
       dismissActionPanel.fire();
       $A.get('e.force:refreshView').fire();
   }
})