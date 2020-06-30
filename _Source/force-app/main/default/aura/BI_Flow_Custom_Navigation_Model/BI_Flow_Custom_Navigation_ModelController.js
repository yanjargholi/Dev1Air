({
    handleChange : function(component, event, helper) {
        // When an option is selected, navigate to the next screen
        var response = event.getSource().getLocalId();
        var toastMessage = component.get("v.toastText"); 
        var toastType = component.get("v.toastType");
        component.set("v.value", response);
        var navigate = component.get("v.navigateFlow");
        var toastButton = component.get("v.toastButton");
        console.log('navigate'+navigate);
        var getButtonClicked = component.get('v.buttonClickFlag');
        if(response=='button1Id'){
            var buttonnavigate1 = component.get('v.buttonNavigation'); 
            getButtonClicked = 'One';
            navigate(buttonnavigate1);
            if(toastMessage != null && toastButton == '1'){
                $A.enqueueAction(component.get('c.showToast'));
            }            
            
        }
        
        if(response=='button2Id'){
            var buttonnavigate2 = component.get('v.buttonNavigation2'); 
            getButtonClicked = 'Two';
            navigate(buttonnavigate2);
            if(toastMessage != null  && toastButton == '2'){
                $A.enqueueAction(component.get('c.showToast'));
            }            
            
        }
        component.set('v.buttonClickFlag', getButtonClicked);
        
        
    },
    
    showToast : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        var toastMessage = component.get("v.toastText");
        var toastType = component.get("v.toastType");
        toastEvent.setParams({
            "title": "System Message!",
            "message": toastMessage,
            "type": toastType
        });
        toastEvent.fire();
    }
})