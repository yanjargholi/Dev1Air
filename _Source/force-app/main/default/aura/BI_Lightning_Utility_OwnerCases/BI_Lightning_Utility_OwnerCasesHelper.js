({
    initData : function(component, event, helper) {  
            component.set('v.columns', [
                {label: '#', fieldName: 'linkName', type: 'url', disabled: 'true', sortable: 'true', initialWidth: 80, typeAttributes: {label: {fieldName: 'CaseNumber'}, target: '_self'}},
                {label: 'Opened', fieldName: 'CreatedDate', disabled: 'true', type: 'date', sortable: 'true', initialWidth: 130, typeAttributes: {
                    year: 'numeric',
                    month: 'numeric',
                    day: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit',
                }},
                {label: 'Rec Type', fieldName: 'BI_Record_Type__c', disabled:'true', sortable: 'true', type: 'text', initialWidth: 130},
                {label: 'Logged By', fieldName: 'BI_Logged_By__c', disabled:'true', sortable: 'true', type: 'text', initialWidth: 100},
                {label: 'Account', fieldName: 'BI_Account__c', disabled:'true', type: 'lookup', sortable: 'true'}, 
                {label: 'Subject', fieldName: 'Subject', editable: 'true', type: 'text', sortable: 'true'},
                {label: 'Category', fieldName: 'BI_Subject_Category__c', sortable: 'true', disabled:'true', type: 'text'},
                {type: 'button', initialWidth: 10, typeAttributes: {
                    iconName: 'utility:edit',
                    label: '',
                    variant: 'inverse',
                    Id: 'editCategory',                
                    name: 'editCategory',
                    title: 'Edit Category',
                    disabled: false,
                    value: 'test',
                    focusable: true,                
                    class: "hoverWrapper slds-button slds-button_icon slds-button_icon-inverse slds-button_icon-container-more slds-button_icon-border-inverse slds-button_icon-small slds-hint-parent slds-cell-edit__button slds-cell-edit:hover"}
            },
                {label: 'Status', fieldName: 'Status', disabled:'true', sortable: 'true', type: 'text'},
                {type: 'button', initialWidth: 10, typeAttributes: {
                    iconName: 'utility:edit',
                    label: '',
                    variant: 'inverse',
                    Id: 'editStatus',                
                    name: 'editStatus',
                    title: 'Edit Status',
                    disabled: false,
                    value: 'test',
                    focusable: true,                
                    class: "hoverWrapper slds-button slds-button_icon slds-button_icon-inverse slds-button_icon-container-more slds-button_icon-border-inverse slds-button_icon-small slds-hint-parent slds-cell-edit__button slds-cell-edit:hover"}
                },
                //columns we will hide via CSS as they are used on Modal Screens
                {label: 'Imp Date', fieldName: 'BI_Planned_Release_Date__c', initialWidth: 0, disabled:'true', sortable: 'false', type: 'date', cellAttributes: {class: {fieldName: 'impDateStyle'}}},
                {label: 'Comments', fieldName: 'BI_Close_Comments__c', initialWidth: 0, disabled:'true', sortable: 'false', type: 'text', cellAttributes: {class: {fieldName: 'commentStyle'}}},
                {label: 'Auto Nofify - In Progress', fieldName: 'BI_Auto_Notification_In_Progress__c', initialWidth: 0, disabled:'true', sortable: 'false', type: 'text', cellAttributes: {class: {fieldName: 'notifyIPStyle'}}},
                {label: 'Auto Nofify - Closed', fieldName: 'BI_Auto_Notification_Closed__c', initialWidth: 0, disabled:'true', sortable: 'false', type: 'text', cellAttributes: {class: {fieldName: 'notifyClosedStyle'}}},
            ]);    
             var action = component.get("c.getOwnerCases"); 
                action.setParams({
            	LimitSize: 50, 
            	Orderby: component.get("v.sortedBy"),
            	OrderDir: component.get("v.sortedDirection")
            }); 
            action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	var records=response.getReturnValue();
            	records.forEach(function(record){
                  record.linkName = '/'+record.Id;
                  record.displayStatus = record.Status;
                  record.impDateStyle ='hiddenCol';
                  record.commentStyle = 'hiddenCol';
                  record.notifyIPStyle = 'hiddenCol';
                  record.notifyClosedStyle = 'hiddenCol'; 
            	});
                component.set("v.data", records);
                component.set('v.loadMoreStatus', '');
                event.getSource().set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);                       
     },
    
    getRecords : function(component, event, helper) {
        var data = component.get("v.data"); 
        var dataSize = component.get("v.data").length;
        var searchTerm = component.get("v.keyWord"); 
        var searchLimit = 50;
            if(searchTerm != ''){searchLimit = 1000}  //alert('**HELP - getRecords: Shown Data Size: ' + dataSize);
                
        //prepare ID List
		var yList = [];
        data.forEach(function(record){
                         yList.push(record.Id);
                     });
        
		var action = component.get("c.getOwnerCases");
        action.setParams({
            LimitSize: searchLimit, 
            recIdList: yList, 
            Orderby: component.get("v.sortedBy"),
            OrderDir: component.get("v.sortedDirection")
        });    
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(component.get("v.data").length >= component.get("v.totalNumberOfRows")){
                    component.set("v.enableInfiniteLoading", false);
                    component.set("v.loadMoreStatus", 'No more data to load');
                } else {
                    var currentData = component.get("v.data");
                    var records = response.getReturnValue();
                    records.forEach(function(record){
                         record.linkName = '/'+record.Id; 
                         record.displayStatus = record.Status;
                         record.impDateStyle ='hiddenCol';
                         record.commentStyle = 'hiddenCol';
                         record.notifyIPStyle = 'hiddenCol';
                         record.notifyClosedStyle = 'hiddenCol';
                     });
                    var newData = currentData.concat(records);
                    var newDataSize = newData.length; 
                    component.set("v.getRecordsMonitor", newDataSize);
                    
                     //check for active search terms and apply if needed
                    if(searchTerm != ''){
                        //alert('DO SEARCH - fire filterdata');
                        //alert('**HELP - getRecords: Fire filterData');
                         this.filterData(component, event, newData);    
                    } else {
                        //alert('**HELP - getRecords: DO NOT fire filterData');
                        component.set("v.data", newData);                        
                        //alert('compare sizes: dataSize is ' + dataSize + 'newDataSize is ' + newDataSize);
                        if(dataSize == newDataSize){
                            //alert('HELP - getRecords: MATCH, stop loading');
                            component.set("v.enableInfiniteLoading", false);
                        }
                    }
                    
                    //search check end
                    component.set("v.loadMoreStatus", "");  
                    event.getSource().set("v.isLoading", false);                    
                }
                //event.getSource().set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action); 
    },
    
    sortData : function(component, fieldName, sortDirection){
        var data = component.get("v.data");
        var reverse = sortDirection !== 'asc';
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.data", data);
    },
    
	sortBy: function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};
        reverse = !reverse ? 1 : -1;
        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },    
    
    validation : function(component, event, helper) {
        var userSelection = component.get("v.selectedPickVal");
        var closedStatus = component.get('v.isClosedStatus');
        var cComments = component.get('v.cComments');
        var impDate = component.get('v.impDate');
        
        
        if(closedStatus == true){                   
            if(userSelection == 'Closed - Implemented'){
                if(cComments != null && impDate != null){
                    component.set('v.getReqFieldsFlag', true);
                } else {
                    //alert('oops required fields missing');
                    component.set('v.getReqFieldsFlag', false);
                }                         
            } else {
                if(cComments != null){
                    component.set('v.getReqFieldsFlag', true);
                } else {
                    component.set('v.getReqFieldsFlag', false);
                }                         
            }
            //alert('user selection is ' + userSelection);
        } else{
            if(userSelection == 'Prioritized for Next Release'){
                if(impDate != null){
                    component.set('v.getReqFieldsFlag', true);
                } else{
                    component.set('v.getReqFieldsFlag', false);
                }
            }
        }  
    },
    
    getCasePickLists : function(component, event, helper) {
        //alert('START - in helper getting pick vals and defaults - ' + component.get('v.categoryList'))
        var pickValuestoShow = component.get('v.validPickListValues');
        var validPickListValuesNotify = component.get('v.validPickListValuesNotify');
        var pickcart = [];
        var statusList = [];
        var categoryList = [];
        var notifyList = [];
        var defStat = component.get('v.status');
        var defnotifyIP = component.get('v.notifyIP');
        var defnotifyClosed = component.get('v.notifyClosed');
        var defCat = component.get('v.category');
        var defCatList = [];
        component.set('v.categoryList', '[]');
        component.set('v.getStatusFlag', true);        
        var rowAction = component.get('v.rowActionName');
        var isClosedStatus = component.get('v.isClosedStatus');
        
        //alert('pickvalues to show is ' + pickValuestoShow);
        //alert('current record status is ' + defStat);
        //alert('xxxxx current record category is ' + defCat);
        //alert('row action clicked is ' +rowAction);
        
        var action = component.get("c.getCasesRecType");
        action.setParams({
            theCaseList : component.get('v.getPickListCaseList'),
            selectedRowId:   component.get('v.selectedRowId'),
        });    
        action.setCallback(this,function(response) {
            var state = response.getState();
            if(state === "SUCCESS"){
                var returnString=response.getReturnValue();
                //alert('returned status values are ' + returnString);                
                if(returnString == 'invalid'){
                    //alert('not valid for now');
                    component.set('v.getStatusFlag', false);                
                } else{                    
                    if(returnString == 'BI Release Request'){
                        statusList = ["New - Pending Review","Reviewed - Release Assignment Pending","Prioritized for Next Release","Awaiting Input", "Closed - Implemented","Closed - Not Planned", "Cancelled"]; 
                        categoryList = ["Accounts and Contacts","Activities","Chatter","Data","Memberships", "Mobile Application", "Outlook Synchronization",
                                        "Pipeline", "Setup and Security", "Reports and Dashboards", "Sales Planning", "Other"];
                        notifyList = ["", "Do Not Send", "UA Employee (Internal Only)"];
                        
                    }
                    if(returnString == 'BI Support Request'){
                        statusList = ["New - Pending Review","In Progress","Awaiting Input","Closed - Resolved","Cancelled"];
                        categoryList = ["Accounts and Contacts","Activities","Chatter","Data","Memberships", "Mobile Application", "Outlook Synchronization",
                                        "Pipeline", "Setup and Security", "Reports and Dashboards", "Sales Planning", "Other"];
                        notifyList = ["","Do Not Send", "UA Employee (Internal Only)"];
                    }
                    if(returnString == 'Product'){
                        statusList = ["New - Pending Review","In Progress","Awaiting Input","Awaiting External Action","Closed","Cancelled"];
                        categoryList = ["Amenities","Jetstream Banking","Login / Password","Portal help","Pricing","Product Inquiry","PNR – General",
                                       "Reservation Help","United Meetings – Agreement","United PassPlus – Contract","United PassPlus – UATP (low on funds)",
                                       "United PassPlus – UATP (contacts)","United PassPlus – JP Morgan/PayConnexion","Other"];
                        notifyList = ["Do Not Send", "UA Employee (Internal Only)","Customer Contact (External Only)","UA Employee & Customer Contact"];
                    }
                    if(returnString == 'Pre-Travel'){
                        statusList = ["New - Pending Review","In Progress","Awaiting Internal Action","Awaiting External Action","Closed","Cancelled"];
                        categoryList = ["AO Support (Airport Support)","Baggage – General / Other", "Baggage – LOB (Lost on Board)","Baggage – Prepaid",
                                       "Corporate Security","ER","MileagePlus","NDC – Link","PNR – General / Other","PNR – Seats","PNR – Ticketing",
                                       "PNR – Upgrades","Policy and Procedure","Refunds – General / Other","Other"];
                        notifyList = ["Do Not Send", "UA Employee (Internal Only)","Customer Contact (External Only)","UA Employee & Customer Contact"];
                    }
                    if(returnString == 'Post-Travel'){
                        statusList = ["New - Pending Review","In Progress","Awaiting Internal Action","Awaiting External Action","Closed","Cancelled"];
                        categoryList = ["Baggage – Delayed","Baggage – General / Other","Baggage – LOB (Lost on Board)","Baggage – Prepaid","Corporate Security",
                                       "Customer Care","Debit Memo","MileagePlus","PNR – General / Other","PNR – Seats","PNR – Upgrades","Refunds – Expired ticket",
                                       "Refunds – General / Other","Refunds – OA Escalation","Refunds – TAEX","Other"];
                        notifyList = ["Do Not Send", "UA Employee (Internal Only)","Customer Contact (External Only)","UA Employee & Customer Contact"];
                    }
                    if(returnString == 'Jetstream Case'){
                        statusList = ["New - Pending Review","In Progress","Awaiting Input","Closed - Resolved","Escalated"];
                        categoryList = ["Other"];
                        notifyList = ["Do Not Send", "UA Employee (Internal Only)","Customer Contact (External Only)","UA Employee & Customer Contact"];
                    }
                    if(returnString == 'SIP Beverage Coupon'){
                        statusList = ["New - Pending Review","In Progress","Awaiting Input","Closed - Resolved","Escalated"];
                        categoryList = ["Other"];
                        notifyList = ["Do Not Send"];
                    }
                    
                    if(rowAction =="editStatus"){
                        component.set('v.validPickListValues', statusList);
                        component.find("select_status").set("v.value", defStat);
                        component.set('v.selectedPickVal', defStat);
                        
                        //notifications
                        component.set('v.validPickListValuesNotify', notifyList);
                        
                        if(defStat == "In Progress"){
                            component.find("select_notifyIP").set("v.value", defnotifyIP);
                            component.set('v.selectedPickValNotifyIP', defnotifyIP);
                        }
                        if(isClosedStatus == true){
                            component.find("select_notifyClosed").set("v.value", defnotifyClosed); 
                            component.set('v.selectedPickValNotifyClosed', defnotifyClosed);
                        }                        
                    }
                    
                    if(rowAction =="editCategory"){
                        
                        if(categoryList.length > 0){
                            categoryList.forEach(function(record){
                                var element = {};
                                element.label = record;
                                element.value = record;
                                pickcart.push(element);                                          
                            });
                            component.set('v.validPickListValues', pickcart);                        
                        } 
                        
                        if(defCat != null){
                            var selectedCats = [];                            
                            selectedCats = defCat.split(";");
                            selectedCats.forEach(function(record){
                                component.get('v.categoryList').push(record);                                                                          
                            });
                        }
                        //alert('END - in helper getting pick vals and defaults - ' + component.get('v.categoryList'))
                        //alert('xxxx the list of selected values are ' +   JSON.stringify(defCatList));
                        //xxx TO DOcomponent.set('v.selectedPickVal', defCatList);
                    }
                    component.set('v.recordType', returnString);
                    component.set('v.getStatusFlag', true);   
                }                        
            }   
        });
        $A.enqueueAction(action);
        
        if(rowAction =="editStatus"){
            component.set('v.showStatusEdit', true);   
        }
        
        if(rowAction =="editCategory"){
            component.set('v.showCategoryEdit', true);   
        }
    },
        
    showToast : function(params){
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams(params);
            toastEvent.fire();
        } else{
            alert(params.message);
        }
    },
    
    filterData : function(component,event,loadMoreData) { 
        //alert('SEARCING.. filterData fired.');
        var dataSize = component.get("v.data").length;
        //alert('SEARCHING - shown data/dataSize ' + dataSize);
        if(loadMoreData == ''){
            var allRecords = component.get("v.data");
        } else {
            var allRecords = loadMoreData;
        }
        
        var searchFilter = component.get("v.keyWord").toUpperCase();    
        //alert('SEARCHING - search value is ' + searchFilter);
        if(searchFilter == ''){            
            helper.initData(component, event, component.get("v.data").length);
            component.set("v.enableInfiniteLoading", true);
        } else {
             var tempArray = [];
            var i;
            for(i=0; i < allRecords.length; i++){  
                //alert('rec: ' + i + 'value: ' + allRecords[i].Subject );
                if((allRecords[i].CaseNumber && allRecords[i].CaseNumber.toUpperCase().indexOf(searchFilter) != -1) ||
                   (allRecords[i].CreatedDate && allRecords[i].CreatedDate.toUpperCase().indexOf(searchFilter) != -1) ||
               	   (allRecords[i].BI_Record_Type__c && allRecords[i].BI_Record_Type__c.toUpperCase().indexOf(searchFilter) != -1 ) ||
                   (allRecords[i].BI_Logged_By__c && allRecords[i].BI_Logged_By__c.toUpperCase().indexOf(searchFilter) != -1 ) ||
                   (allRecords[i].BI_Account__c && allRecords[i].BI_Account__c.toUpperCase().indexOf(searchFilter) != -1 ) ||
                   (allRecords[i].Subject && allRecords[i].Subject.toUpperCase().indexOf(searchFilter) != -1) ||
                   (allRecords[i].BI_Subject_Category__c && allRecords[i].BI_Subject_Category__c.toUpperCase().indexOf(searchFilter) != -1) ||
                   (allRecords[i].Status  && allRecords[i].Status .toUpperCase().indexOf(searchFilter) != -1))
                {
                tempArray.push(allRecords[i]);
                }
            }
            component.set("v.data",tempArray);          
            
            if(dataSize == tempArray.length){
                component.set("v.enableInfiniteLoading", false);
            }           
        }
    }
   

})