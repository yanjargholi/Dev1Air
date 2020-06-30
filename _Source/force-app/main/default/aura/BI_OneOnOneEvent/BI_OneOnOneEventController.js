({
    doInit : function(component, event, helper) {
        var action = component.get("c.CreateOneonOne");
        action.setParams({
            'eventId' : component.get("v.recordId")         
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid && state == 'SUCCESS'){
                
                
                var errors = response.getReturnValue().Errors;
                if(errors.length > 0){
                    var errorMessage = errors[0];
                    return;
                } else {
                    var result = response.getReturnValue().Result;
                    if(result.length > 0){
                        
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "You are ready to start the One-On-One",
                            "message": "Be sure to capture all important / relevant conversation topics - Have a good meeting",
                            "type": "success",
                            "duration": "8000",
                            "mode": "dismissible"
                        });
                        toastEvent.fire();
                        var sObjectEvent = $A.get("e.force:navigateToSObject");              
                        sObjectEvent.setParams({
                            "recordId": result
                        })
                        sObjectEvent.fire();
                        
                        
                    }
                    //component.set('v.isReloadSuccess', true);
                }
            }
        });
        $A.enqueueAction(action);   
        
    }
})