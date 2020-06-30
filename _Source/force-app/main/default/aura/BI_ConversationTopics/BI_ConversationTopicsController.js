({
	doInit : function(component, event, helper) {        
        

        var action = component.get("c.checkForParticipant");
        action.setParams({
            'oneONoneId' : component.get("v.recordId")         
        });
        
        action.setCallback(this, function(response){
         var state = response.getState();
         if(component.isValid && state == 'SUCCESS'){
             component.set('v.showSpinner', false);
             
             var errors = response.getReturnValue().Errors;
             if(errors.length > 0){
                 var errorMessage = errors[0];
                 return;
             } else {
                 var result = response.getReturnValue().Result;
                 if(result.length > 0){
                     if(result == 'True'){
                         component.set('v.hasParticipant', true); 
                     }
                     component.set('v.participantID', result);
                 }
                 component.set('v.isReloadSuccess', true);
             }
         }
     });
     $A.enqueueAction(action);    
        helper.onDiscussionTopicsFieldInfo(component, event, helper);	       
        
	},
    
    AddOneRow: function(component, event, helper) {    
        helper.addRowWithPromise(component, event, helper, 1);
    },
    
    AddFiveRows: function(component, event, helper) {    
        helper.addRowWithPromise(component, event, helper, 5);
    },
    
    onHandleLoaded: function(component, event, helper) {
        helper.addRowWithPromise(component, event, helper, 1);
    },
    
    onSaveandClose: function(component, event, helper){
        component.set("v.closeWindowFlag", 1);
        $A.enqueueAction(component.get('c.OnSave'));
    },
    
    OnSave: function(component, event, helper) {
        var getCloseWindowFlag = component.get("v.closeWindowFlag");
        component.set('v.showSpinner', true);
        var validItems = new Array();
        var items = component.get('v.currentList');
        for (var index = 0; index < items.length; index++) {
            var convoItem = items[index];
            if (helper.onCheckValidation(component, event, helper, convoItem)) {
                validItems.push(convoItem);
            } else {
            }
        }

        if (validItems.length == 0) {
            component.set('v.showSpinner', false);// helper.hideSpinner();
            helper.onShowAlarmMessage(component, event, helper, 'NoneRecords')
            return;
        } 
        
        component.set('v.errMessage', '');
        // call back-end function
        var action = component.get("c.saveConvoTopics");
        action.setParams({
            oneOnOneId: component.get("v.recordId"),
            convoTopicList: validItems,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                if (getCloseWindowFlag == 1){ 
                                 
                	$A.get("e.force:closeQuickAction").fire();
                	$A.get('e.force:refreshView').fire();
                	helper.showToast(component, event, helper);
					
                } else {
                    helper.ongetConvoTopicRecords(component, event, helper);
                } 
                

            } else {
                // helper.hideSpinner();
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },  
    
    onCancel: function(component, event, helper) {
         $A.get("e.force:closeQuickAction").fire();
         $A.get('e.force:refreshView').fire();
    },
      
    toggleSpinner: function(component, event, helper) {
        var spinner = component.find('spinner22');
        var showSpin = component.get('v.showSpinner'); 
        if(showSpin == true) {
            $A.util.removeClass(spinner, 'slds-hide');
            $A.util.addClass(spinner, 'slds-show');
        } else {
            $A.util.removeClass(spinner, 'slds-show');
            $A.util.addClass(spinner, 'slds-hide');
        }
    }

})