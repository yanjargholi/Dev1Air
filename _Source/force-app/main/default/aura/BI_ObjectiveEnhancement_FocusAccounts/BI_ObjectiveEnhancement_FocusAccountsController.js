({
	doInit : function(component, event, helper) { 
         $A.enqueueAction(component.get('c.focusListDisplay'));
        
	},
    
    focusListDisplay: function(component, event, helper){
        helper.fetchFocusList(component, event,'BI_Account__r.Name');
        $A.get( 'e.force:refreshView' ).fire();     
    },
    
    includeSalesTeam:  function(component, event, helper){
        var checboxVal = component.get('v.salesteamCheckBox');
        if(checboxVal == 'false'){
            component.set('v.salesteamCheckBox', 'true');
        } else{
            component.set('v.salesteamCheckBox', 'false');
        }
        //alert("the checkbox value is " + component.get('v.salesteamCheckBox'));
    },
    
    accountListDisplay : function(component, event, helper) {		
        component.set('v.showFocusList', false);
        helper.fetchAccountList(component, event,'Name');        
        component.set('v.showAccountList', true);
        $A.get( 'e.force:refreshView' ).fire();  

	},
    
    accountListClose: function(component, event, helper) {
        component.set('v.showAccountList', false);
         component.set('v.salesteamCheckBox', 'false');
         component.set('v.headerCheckBox','');
         component.set('v.controlSelectAll', 'not set');
         component.set('v.selectedAccountList', new Array());
         component.set('v.accountList', new Array());
        component.set('v.disableCreateButton', 'False');
        $A.enqueueAction(component.get('c.focusListDisplay'));

        //$A.get( 'e.force:refreshView' ).fire();     
    },
    
    selectAll: function(component, event, helper) {
        var headerCheckBox = component.get('v.headerCheckBox');
         var controlSelectAll = component.get('v.controlSelectAll');
        //alert('selectAll FUNCTION - headerCheckBox is ' +headerCheckBox + ' and controlSelectAll is ' +controlSelectAll);
        //alert('selectAll FUNCTION - selectedAccountList is ' + component.get('v.selectedAccountList'));
        
        if(headerCheckBox == 'true' && controlSelectAll == 'not set'){
            headerCheckBox = '';
            component.set('v.headerCheckBox', '');
            controlSelectAll = 'enable uncheck all';
            component.set('v.controlSelectAll', 'enable uncheck all');
        } else{
            component.set('v.headerCheckBox', 'true'); 
            component.set('v.controlSelectAll', 'all checked');
        }
        
        
        $A.enqueueAction(component.get('c.setSelectedAccounts'));

    },
    
    setSelectedAccounts: function(component, event, helper){

        var accountList = component.get('v.accountList');
        component.set('v.selectedAccountList', new Array());
        var selectedAccountList = component.get('v.selectedAccountList');
         var headerCheckBox = component.get('v.headerCheckBox');
        var controlSelectAll = component.get('v.controlSelectAll');
         //alert('setSelectedAccounts FUNCTION - headerCheckBox is ' +headerCheckBox + ' and controlSelectAll is ' +controlSelectAll);
          //alert('setSelectedAccounts FUNCTION - selectedAccountList is ' +selectedAccountList);
        for(var i = 0; i < accountList.length; i++){
            
            if(headerCheckBox == 'true' && controlSelectAll == 'all checked'){
                accountList[i].isSelected = true;                
            } else {
                if(headerCheckBox == '' && controlSelectAll == 'enable uncheck all'){
                    //alert('single select should not be in here');
                    accountList[i].isSelected = false;
                    component.set('v.headerCheckBox','');
                    
                }
            }

             if (accountList[i].isSelected) {
                 //alert('try index ' + accountList.indexOf(accountList[i]));
                 //alert('account selected is ' + accountList[i].Name + ' was ' + accountList[i].isSelected);
                 selectedAccountList.push(accountList[i].Id);
             }  else {
                 if(accountList[i].isSelected == false && headerCheckBox == 'true'){
                     component.set('v.headerCheckBox','');
                 }
             }
        }
        //alert('total selected is ' +selectedAccountList.length);
        //alert('selection list is ' +selectedAccountList);
        component.set('v.accountList', accountList);
        
         if((headerCheckBox == 'true' && controlSelectAll == 'all checked') || (headerCheckBox == '' && controlSelectAll == 'enable uncheck all')){
             component.set('v.controlSelectAll', 'not set');
         }
        
        if(selectedAccountList.length > 0){
            component.set('v.disableCreateButton', false);
        } else component.set('v.disableCreateButton', true);

    },
    
    focusCustomersCreate : function(component, event, helper) {		
        helper.createFocusRecords(component, event, helper);
        //perhaps call a toast here
         $A.enqueueAction(component.get('c.accountListClose'));
         $A.enqueueAction(component.get('c.focusListDisplay'));

	},
    
    navigateToAccount: function(component, event, helper){        
        var sObectEvent = $A.get("e.force:navigateToSObject");
      sObectEvent .setParams({
        "recordId": event.currentTarget.id
      });
    sObectEvent.fire();        
    },
    
    navigateToFocusRecord: function(component, event, helper){
        //alert('in the navigate function the target id is ' +event.currentTarget.id);
        var sObectEvent = $A.get("e.force:navigateToSObject");
      sObectEvent .setParams({
        "recordId": event.currentTarget.id
      });
    sObectEvent.fire();  
    },
    
    sortColumn: function(component, event, helper){
        var sortcol = event.currentTarget.id;
        component.set('v.sortColumn', sortcol);       
        helper.sortHelper(component,event,sortcol);
    },
    
   
    
})