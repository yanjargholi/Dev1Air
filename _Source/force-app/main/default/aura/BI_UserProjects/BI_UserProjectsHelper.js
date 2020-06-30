({
	onProjectsFieldInfo : function(component, event, helper) {
        component.set('v.showSpinner', true);
        var action = component.get('c.getProjectsFieldInfo');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === 'SUCCESS'){
                var result = response.getReturnValue().Result;
                if(result.length > 0){
                    component.set('v.fieldVisibleList', result);
                    this.onGetProjectRecords(component, event, helper);
                } else {
                    //message
                }
            }
            
        });
        $A.enqueueAction(action);
        
        //var childComponentToRefresh = event.getParam("componentName");
        //alert(childComponentToRefresh);
	},    
       
    onGetProjectRecords: function(component, event, helper){
     var action = component.get("c.getProjectRecords");
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
                var projectItem = helper.onInitialProjectItems(component, event, helper);
                list.push(projectItem);
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
    
    
    onInitialProjectItems: function(component, event, helper){
        var projectItem = { sobjectType: 'BI_Project__c'};
        var fieldSet = component.get('v.fieldVisibleList');
        if(fieldSet.length == 0){
            return;
        }
        for (var index = 0; index < fieldSet.length; index++){
            var projectfield = fieldSet[index].apiName;
            projectItem[projectfield] = '';
        }
        return projectItem;
    },
    
    onCheckValidation: function(component, event, helper, projectItem) {
        var flag = false;
        var fieldList = component.get('v.fieldVisibleList');
        if (projectItem.Id != undefined) {// existing record
            flag = true
            return flag;
        }
        for (var index = 0; index < fieldList.length; index++) {
            var key = fieldList[index].apiName;
            if (projectItem[key] != '' && projectItem[key] != null) {
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
    },
    
    showToast : function(component, event, helper) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
        "title": "Success!",
        "message": "Project records created / updated successfully.",
        "type": "success"
    });
    toastEvent.fire();
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
    }
})