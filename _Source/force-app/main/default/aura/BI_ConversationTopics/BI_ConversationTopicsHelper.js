({
	onDiscussionTopicsFieldInfo : function(component, event, helper) {
		component.set('v.showSpinner', true);
        var action = component.get("c.getDiscussionTopicFieldInfo");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS'){
                var result = response.getReturnValue().Result;
                if(result.length > 0){
                    component.set('v.fieldVisibleList', result);
                    this.ongetConvoTopicRecords(component, event, helper);
                } else {
                    //message
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    
 ongetConvoTopicRecords: function(component, event, helper){
     var action = component.get("c.getConvoTopicRecords");
     var getCloseWindowFlag = component.get("v.closeWindowFlag");
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
                     component.set('v.currentList', result);
                 }
                 component.set('v.isReloadSuccess', true);                                                  
             }
         }
     });
     $A.enqueueAction(action);  
     

},
    
    createNewRows: function(component, event, helper, count){
        return new Promise($A.getCallback(function(resolve, reject) {
            var list = component.get('v.currentList');
            var currentLen = list.length;
            for(var index = 0; index < count; index++) {
                var convoItem = helper.onInitialConvoItems(component, event, helper);
                list.push(convoItem);
            }
            resolve(list);
        }));        
    },
    
    addRowWithPromise: function(component, event, helper, count){
        this.setToggleSpin(component)
        .then($A.getCallback(function(result){
            return helper.createNewRows(component, event, helper, count);
        })).then(
            $A.getCallback(function(result){
                component.set('v.currentList', []);
                component.set('v.currentList', result);
                setTimeout(function(){
                    component.set('v.showSpinner', false);
                }, 500);
            })
        ).catch(function(error) {
            $A.reportError("An error occurred. Please report this to your Business Insight team: ", error);
        });
    },
    
    onInitialConvoItems: function(component, event, helper){
        var convoItem = { sobjectType: 'BI_Conversation_Topic__c'};
        var fieldSet = component.get('v.fieldVisibleList');
        if(fieldSet.length == 0){
            return;
        }
        for (var index = 0; index < fieldSet.length; index++){
            var convoTopicfield = fieldSet[index].apiName;
            convoItem[convoTopicfield] = '';
        }
        return convoItem;
    },
    
    showSpinner: function() {
        var appEvent = $A.get("e.c:BIToggleSpinnerEvent");
        appEvent.setParams({
            "currentStatus": "hide"
        });
        appEvent.fire();
    },
    
    hideSpinner: function() {
        var appEvent = $A.get("e.c:BIToggleSpinnerEvent");
        appEvent.setParams({
            "currentStatus": "show"
        });
        appEvent.fire();
    },
    
    setToggleSpin: function(component) {
        return new Promise($A.getCallback(function(resolve, reject) {
            console.log('in setToggleSpin' + (new Date()));
            component.set('v.showSpinner', true);
            setTimeout(function() {
                resolve('value set');
            }, 500);
        }));
    },
    
    onCheckValidation: function(component, event, helper, convoItem) {
        var flag = false;
        var fieldList = component.get('v.fieldVisibleList');
        if (convoItem.Id != undefined) {// existing record
            flag = true
            return flag;
        }
        for (var index = 0; index < fieldList.length; index++) {
            var key = fieldList[index].apiName;
            if (convoItem[key] != '' && convoItem[key] != null) {
                flag = true;
            }
        }
        return flag;
    },
    
    onShowAlarmMessage: function(component, event, helper, messageType) {
        var errorMessage = '';
        
        if (messageType == 'NoneRecords') {
            errorMessage = 'No Valid Records Available To Save';
        } else if (messageType == 'Required') {
            errorMessage = 'Name is Required';
        } else if (messageType = 'DateError') {
            errorMessage = 'Please ensure valid dates in date fields';
        } else {
            errorMessage = 'Undefined Error - please log a Business Insight case'
        }
        component.set('v.errMessage', errorMessage);
        //known issue with toast display on top of modal so using component text variable until it is fixed by salesforce
        
    },
    
    showToast : function(component, event, helper) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": "Success!",
        "message": "Conversation Topic records created / updated successfully.",
        "type": "success"
    });
    toastEvent.fire();
}   
    
    
})