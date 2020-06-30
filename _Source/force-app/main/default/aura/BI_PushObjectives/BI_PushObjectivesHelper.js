({
     showErrorMessage : function(component, errorObj){
       // console.dir(errorObj);
        var message = 'Unable to process your request.';
        if (errorObj) {
            if (errorObj[0] && errorObj[0].fieldErrors){
                var fErrors = errorObj[0].fieldErrors;
                for(field in fErrors){
                    //console.log(fErrors[field]);
                    message += ' Reason: Missing ' + field + ' - ' + fErrors[field][0].message;
                }
            }
            if (errorObj[0] && errorObj[0].pageErrors && !this.isNull(errorObj[0].pageErrors[0])) {
                if(!this.isNull(errorObj[0].pageErrors[0].message))
                    message += ' Reason: ' + errorObj[0].pageErrors[0].message;
            }
            // alert(message);
            component.set('v.statusMessage', message);
        } else {
            // alert(message);
            component.set('v.statusMessage', message);
        }
    },

    getValidObjectiveYearPickListvalues : function (component,event, helper) {
        var action = component.get("c.getValidObjectiveYearPickListvalues");
        // action.setParams({'Name': name, 'Territory': territory});
        action.setCallback(this, function (response) {
          var state = response.getState();
          if (component.isValid() && state === "SUCCESS") {
            console.log(response.getReturnValue());
            component.set('v.ValidObjectiveYearList', response.getReturnValue());
          }
        });
        $A.enqueueAction(action);
      },

    
    // GenarateObjectives : function(component,event, helper) {
    //     var action = component.get("c.CreateRelevantPlanObjectives");
    //      var vObjType = document.getElementById('vObjType').value;
    //         action.setParams({
    //             objectiveTypeid : component.get("v.recordId")
    //             'validyear': vObjType
    //         });
    	
    //     action.setCallback(this, function(a) {
    //         if (a.getState() === "SUCCESS") {
    //             //component.set("v.Successvalue", a.getReturnValue());
    //             //var dismissActionPanel = $A.get("e.force:closeQuickAction");
    //             //dismissActionPanel.fire();
    //             //$A.get('e.force:refreshView').fire();
    //            component.set('v.statusMessage', a.getReturnValue()); 
    //         } else if (a.getState() === "ERROR") {
    //            // $A.log("Errors", a.getError());
    //            this.showErrorMessage(component, a.getError());
    //         }
    //     });

    //     $A.enqueueAction(action);
    // }
})