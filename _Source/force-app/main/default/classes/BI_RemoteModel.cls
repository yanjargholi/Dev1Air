/**************************************************************************

Name : BI_RemoteModel
===========================================================================
Purpose : This class is used to modal data 

           ObjectFieldWrapper: used in BI_ConversationTopicsHandler
                               test code coverage via BI_ConversationTopicsHandler_Test
===========================================================================
History:
--------
VERSION    AUTHOR         DATE             DETAIL          DESCRIPTION
1.0       Yolande Anj    9/May/2018        Created
***************************************************************************/
public with sharing class BI_RemoteModel {
	// Action 
    public static final String ACTION_ADD = 'add';
    public static final String ACTION_DELETE = 'delete';
    public static final String ACTION_EDIT = 'edit';
    public static final String ACTION_SEARCH = 'search';

    //Sever
    public static final String RESULTSTAT_FAIL = 'Fail';
    public static final String RESULTSTAT_SUCCESS = 'Success';

    public class ObjectFieldWrapper{
    @AuraEnabled
    public String fieldLabel {get;set;} // field label name
    @AuraEnabled
    public String apiName {get;set;} // field api name
    @AuraEnabled
    public String type {get;set;} // field data type, such as String
    @AuraEnabled
    public List<String> options {get;set;} // field data type, such as String

    public ObjectFieldWrapper(String fieldLabel, String apiName, String type, List<String> options){
      this.fieldLabel = fieldLabel;
      this.apiName = apiName;
      this.type = type;
      this.options = options;
    }
  }
    
    
}