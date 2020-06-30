/**************************************************************************

Name : BI_Result
===========================================================================
Purpose : This class is used to return result
===========================================================================
History:
--------
VERSION    AUTHOR              DATE              DETAIL          DESCRIPTION
1.0       Danni Xi             18/May/207        Created
2.0       Yolande Anjargholi   17/May/2018       Updated
***************************************************************************/
public with sharing class BI_Result {
	@AuraEnabled public Object Result { get; set; }
    @AuraEnabled public List<String> Errors { get; set; }
    public BI_Result() {
        this.Errors = new List<String>();
    } 
}