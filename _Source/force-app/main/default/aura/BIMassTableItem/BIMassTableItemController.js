({
    doInit: function(component, event, helper) {
        
        //**populate data
        var myList = new Array();
        var obj = component.get('v.priceItem');
        var keyItem = component.get('v.itemKey').apiName;
        component.set('v.test', obj[keyItem]);
        //--------------------------------------------
        
        //**get objective type records to set as picklist values
        var opts2 = [];	
        var curValue = '';
        
        if (obj[keyItem] != '' && obj[keyItem] != undefined && component.get('v.itemKey').type == 'PICKLIST') {
                curValue = obj[keyItem];
				} else {curValue = '---Please Select---';}
        
        if(keyItem == 'BI_Category__c') {   
            var action = component.get("c.getObjectiveTypeName");    		
            action.setCallback(this, function(response){
                var state = response.getState();
                if(component.isValid && state == 'SUCCESS'){             		
                    var allValues = response.getReturnValue().Result;
                    
                    if (allValues != undefined && allValues.length > 0){                        
                        //**set current value if there is one
                        opts2.push({
                            label: curValue,
                            value: curValue
                        });
                        
                        //**get picklist options to show
                        for (var i = 0; i < allValues.length; i++){
                            var value = allValues[i];
                            opts2.push({
                                label: allValues[i],
                                value: allValues[i]
                            });                   
                        }
                        component.set("v.options", opts2);                                            
                    } 
                } 
            });
            $A.enqueueAction(action);
        }
        
        //**if no objective type records found, use values in the conversation topic's category picklist field
        if(opts2.length <= 0  || component.get('v.itemKey') == 'BI_Project_Status__c'){
            //**set current value if there is one
            var curValue = ''
            if (component.get('v.itemKey').type == 'PICKLIST') {
                var sOption = component.get('v.itemKey').options.slice(0);
                sOption.splice(0, 0, '---None---');
                
                if (obj[keyItem] != '' && obj[keyItem] != undefined && component.get('v.itemKey').type == 'PICKLIST') {
                    curValue = obj[keyItem];
                    component.set('v.selectedValue', curValue);
                } else {
                    component.set('v.selectedValue', '---None---');
                }                    
                //**get picklist options to show
                var opts = [];                
                for (var i = 0; i < sOption.length; i++) {
                    var item = {};
                    item.value = sOption[i];
                    item.label = sOption[i];
                    
                    opts.push(item);
                }            
                component.set("v.options", opts);           
            }
        }
        
    },    
    
    onKeyup: function(component, event, helper) {
        var obj = component.get('v.priceItem');
        var keyItem = component.get('v.itemKey').apiName;
        obj[keyItem] = component.get('v.test');
        component.set('v.priceItem', obj);
        
    },
    onSelectChange: function(component, event, helper) {
        var selected = component.find("mySelect").get("v.value");
        var obj = component.get('v.priceItem');
        var keyItem = component.get('v.itemKey').apiName;
        obj[keyItem] = selected;
        component.set('v.priceItem', obj);
    }
    
})