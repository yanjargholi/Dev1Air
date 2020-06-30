({
    /*
     * This finction defined column header
     * and calls getAccounts helper method for column data
     * editable:'true' will make the column editable
     * */
    doInit : function(component, event, helper) {        
        
        
        
    },
    
    createCase : function(component, event, helper) {        
        var whichOne = event.currentTarget.name;
        var recordTypeId = '';
        var areaOfSupport = '';
        var userId = $A.get("$SObjectType.CurrentUser.Id");

        
        switch (whichOne){
            case 'biSup':
                recordTypeId = "012360000012INUAA2"
                areaOfSupport = "Business Insight"
                break;
            case 'biRel':
                recordTypeId = "0120d000000cXLDAA2"
                areaOfSupport = "Business Insight"
                break;    
            case 'prodMeetings':
                recordTypeId = "01219000000dDGWAA2"
                 areaOfSupport = "United Meetings"
                break; 
            case 'prodPass':
                recordTypeId = "01219000000dDGWAA2"
                areaOfSupport = "United PassPlus"
                break; 
            case 'travPre':
                recordTypeId = "01219000000dDGMAA2"
                areaOfSupport = ""
                break;  
            case 'travPost':
                recordTypeId = "01219000000dDGMAA2"
                areaOfSupport = ""
                break;      
                
        }
        var createRecordEvent = $A.get("e.force:createRecord");
        
        createRecordEvent.setParams({
            "entityApiName": "Case",
            "recordTypeId": recordTypeId,
            "defaultFieldValues": {
                'BI_Area_of_Support__c': areaOfSupport,
                'BI_User__c': userId
            }
            
            
        });
        createRecordEvent.fire(); 
    },
    
    createCase2 : function(component, event, helper) {        
        alert('clicked');        
    },
    
     toggleSection : function(component, event, helper) {
        // dynamically get aura:id name from 'data-auraId' attribute
        var sectionAuraId = event.target.getAttribute("data-auraId");
        // get section Div element using aura:id
        var sectionDiv = component.find(sectionAuraId).getElement();
        /* The search() method searches for 'slds-is-open' class, and returns the position of the match.
         * This method returns -1 if no match is found.
        */
        var sectionState = sectionDiv.getAttribute('class').search('slds-is-open'); 
        
        // -1 if 'slds-is-open' class is missing...then set 'slds-is-open' class else set slds-is-close class to element
        if(sectionState == -1){
            sectionDiv.setAttribute('class' , 'slds-section slds-is-open');
        }else{
            sectionDiv.setAttribute('class' , 'slds-section slds-is-close');
        }
    }

    
})