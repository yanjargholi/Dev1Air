({
    init: function(component, event, helper){
        helper.initData(component, event, component.get("v.data").length);       
    },
    
     loadMoreData: function(component, event, helper){
        var rowsToLoad = component.get('v.rowsToLoad');
        event.getSource().set("v.isLoading", true);
        component.set('v.loadMoreStatus', 'Loading');
        helper.getRecords(component, event, component.get("v.data").length);      
     },
    
    onRefresh: function(component, event, helper){
        //helper.initData(component, event, component.get("v.data").length);
        $A.get('e.force:refreshView').fire();           
    },
            
     updateColumnSorting: function (cmp, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        //helper.sortData(cmp, fieldName, sortDirection); xx
        cmp.set('v.data', []);
        event.getSource().set("v.isLoading", true);
        cmp.set('v.loadMoreStatus', 'Loading');
        helper.initData(cmp, event, cmp.get("v.data").length);
    },         
            
    onSave : function (component, event, helper) {
        var draftValues = event.getParam('draftValues');
        var action = component.get("c.updateCases");
             action.setParams({
            "editedCaseList" : draftValues
            });
            action.setCallback(this, function(response) {
                var state = response.getState();            
                if(state === "SUCCESS"){
                if(response.getReturnValue() === true){
                    helper.showToast({
                    "title": "Success",
                    "type": "success",
                    "message": "Case Record(s) Updated Successfully"
                    });
                    $A.get('e.force:refreshView').fire();
                }            
                }            
            });
            $A.enqueueAction(action);
    },
            
    handleRowAction: function (component, event, helper) {
        var actionName = event.getParam('action').name;
        component.set('v.rowActionName', actionName);
        var row = event.getParam('row');
        var selectedRows = component.find("objDataTable").get("v.selectedRows");
        component.set('v.idCartListSize', selectedRows.length);
        var Idcart = []; 
        component.set('v.idCartList', []);            
        component.set('v.idCartListType', '');
        component.set('v.applyCheck', false); 
       	component.set('v.updateOwnerList', []);
        
        //for update of Status or Category picklists row actions
        component.set('v.isClosedStatus', false); 
		component.set('v.recordType', '');	
        component.set('v.getPickListCaseList', []);
        component.set('v.validPickListValues', []); //list of picklist values we will show
        component.set('v.status', row.Status);   
        component.set('v.category', row.BI_Subject_Category__c); 
        
       	var toUpdateList = component.get('v.updateOwnerList'); //list for case ID owner change
        
        if(selectedRows.length > 0 ){
            var addClickedRow = '';
                //alert('multiple');
                component.set('v.idCartListType', 'Id');
                selectedRows.forEach(function(record){                    
                        Idcart.push(record);
                        if(actionName == 'Own'|| actionName == 'editCategory'){
                            toUpdateList.push(record); 
                        }
                        if(record == row.Id){
                            addClickedRow = 'no';
                        }              
       			});
            
                if(addClickedRow != 'no'){
                    Idcart.push(row.Id);
                }
            } else {
                    if(selectedRows.length == 0 && row != ''){
                        component.set('v.idCartListType', 'Full'); 
                        Idcart.push(row); 
                        if(actionName == 'Own' || actionName == 'editCategory'){
                            toUpdateList.push(row.Id);                           
                        }
                    }
                }
        
        if(row != ''){
                component.set('v.selectedRowId', row.Id);
            }
        
        if(toUpdateList.length > 0){
            if(actionName == 'Own'){
                component.set('v.updateOwnerList', toUpdateList);
                helper.updateCaseOwner(component, event, helper);
            }
            if(actionName == 'editCategory'){
                component.set('v.getPickListCaseList', toUpdateList);
                helper.getCasePickLists(component, event, helper); 
            }
        }
        
        if(Idcart.length > 0){                
                component.set('v.idCartList', Idcart);                 
            }
    },
    
    saveDescEdit: function(component, event, helper) {
        var updateCart = [];
        var action = component.get('v.rowActionName');
        updateCart = component.get('v.idCartList'); 
        var updateCartType = component.get('v.idCartListType'); 
        var carSize = updateCart.length; 
        var editedRecords =  component.find("objDataTable").get("v.draftValues");
        var edrSize = editedRecords.length; 
        var userSelection = component.get("v.selectedPickVal");
        var applyCheck = component.get('v.applyCheck');
        var isSuccess = false;
        var cart = []; 
        
        component.set('v.getReqFieldsFlag', true);             
   		var recType = component.get('v.recordTypeimpDate');
        var clickedRowId = component.get('v.selectedRowId');
        
        for(var i = 0; i < carSize; i++){
            isSuccess = false;
            var getId = '';
         
         if(updateCartType == 'Full'){
                 getId = updateCart[i].Id;              
             } else{
                 getId = updateCart[i];
                 if(applyCheck == false){
                     i = carSize;
                     getId = clickedRowId;
                 }
             }
         
         if(edrSize == 0){
             var element = {};             
             element.Id = "" + getId + "";
             
             if(action == 'editCategory' ){
                 var stringSelection = userSelection.toString();
                 element.BI_Subject_Category__c = "" + stringSelection + "";
             }
             cart.push(element);
             editedRecords.push(element);
             isSuccess = true;
         } else {
             //alert('prior edits editrecs are ' + JSON.stringify(editedRecords));
             for(var y = 0; y < edrSize; y++){
                 //alert('now looping through edit rec ' + y);
                     if (editedRecords[y].Id == getId){
                         if (action == 'editCategory'){
                             var stringSelection = userSelection.toString();
                             editedRecords[y].BI_Subject_Category__c = stringSelection;                                             
                         }
                         isSuccess = true;
                     }
                 }
             
             if(isSuccess == false){
                 //alert('not found in edit list');
                 var element = {};
             	 element.Id = "" + getId + "";
             	 
                 if (action == 'editCategory'){
                             var stringSelection = userSelection.toString();
                             element.BI_Subject_Category__c = "" + stringSelection + ""; 
							                              
                         }

                 cart.push(element);
             	 editedRecords.push(element);
             	 isSuccess = true;
             } 
         } 
     } //end cart loop
     
     if(isSuccess == true) {
                 component.find("objDataTable").set("v.draftValues", editedRecords);
        		 component.set('v.showCategoryEdit', false);
             }	
    //alert('** draftList after is ' + JSON.stringify(editedRecords));
    },    
    
    onPickListChange: function(component, event, helper){
        var action = component.get('v.rowActionName');        
        component.set('v.getReqFieldsFlag', true);
        
        if(action == 'editCategory'){
            var selectedCategories = event.getParam("value");
            var selectString = selectedCategories.toString();            
            var selection = selectString.replace(/,/g,';');
            component.set("v.selectedPickVal", selection);
        }     
    },    
    
    onCancel: function(component, event, helper) {
        component.set('v.showCategoryEdit', false);
    }, 
    
    searchTable : function(component,event,helper) {         
        component.set("v.enableInfiniteLoading", true);
        var searchFilter = component.get("v.keyWord").toUpperCase();
        //alert('CONT: searchTabe - fired:' + searchFilter + 'INFINITE LOA: ' + component.get("v.enableInfiniteLoading"));
        if(searchFilter == ''){
            //alert('CONT: searchTabe - fire init: ' + searchFilter);
            helper.initData(component, event, component.get("v.data").length);
        } else {
            //alert('CONT: searchTabe - fire filterData: ' + searchFilter);
            helper.filterData(component, event, '');                          
        }
    },
    
    searchCleared: function(component, event, helper){
        var searchFilter = event.getSource().get("v.value").toUpperCase();       
        if(searchFilter == ''){   
            component.set("v.enableInfiniteLoading", true);
            helper.initData(component, event, component.get("v.data").length);            
        }
    }
   
})