/**************************************************************************

Name : BI_UtilityCls

===========================================================================
Purpose : 
===========================================================================
History:
--------
VERSION    AUTHOR         DATE            DETAIL          DESCRIPTION
1.0        Sasi Naik      17/May/2017     Created         CSR:    
2.0        Yolande Anj    16/May/2018     Updated         Included missed objects and record type definitions   
***************************************************************************/

public without sharing class BI_UtilityCls {
	
    public static Boolean isTriggerFired = false;
    
    //objects
    public static Final String OBJSTATUS  = 'BI_Status__c';
    public static Final String DIVISIONALOBJECTIVE  = 'BI_Divisional_Objective';
    public static Final String REGIONALOBJECTIVE  = 'BI_Regional_Objective';
    public static Final String TERRITORYOBJECTIVE  = 'BI_Territory_Objective';
    public static Final String OBJACCOUNTPLAN = 'BI_Account_Plan__c';
    public static Final String OBJACTIVES  = 'BI_Objectives__c';
    public static Final String LEADOBJECT  = 'Lead';
    public static Final String CASEOBJECT  = 'Case';
    public static Final String CONTACTOBJECT = 'Contact';
    public static Final String CONVOTOPIC  = 'BI_Conversation_Topic__c';
	public static Final String ProjectObject  = 'BI_Project__c';
    
    //Record Types
    
    public static Final String OBJCORPCONTRACTRECORDTYPE = 'Corporate_Contract';
    
    //Contact Record Types
    public static Final String BUSCONTACTRECORDTYPE = 'Business';
    
    //Opportunity Record Types
    public static Final String TMCCONTRACTOPTYRECORDTYPE  = 'BI_TMC_Contract';
    public static Final String OPPTACINCTMCRECORDTYPE = 'BI_Tactical_Incentive_TMC';
    public static Final String CORPORATEOPTYRECORDTYPE  = 'BI_Corporate';
    public static Final String GLOBALCONTRACTOPTYRECORDTYPE  = 'BI_Global_Contract';
    public static Final String OTHEROPTYRECORDTYPE = 'BI_Other';
    
    //Account Record Types
    public static Final String ACCTAGENCYBRANCHRECORDTYPE = 'Agency_Branch';
    public static Final String ACCTAGENCYHOLRECORDTYPE = 'Agency';
    public static Final String ACCTCORPRECORDTYPE = 'Corporate'; 
	public static Final String ACCTNONUCSRECORDTYPE = 'BI_International_Account';
    public static Final String ACCMEMGROUPRECORDTYPE = 'BI_Membership_Group';
    public static Final String ACCMEMSUBGROUPRECORDTYPE = 'BI_Membership_Sub_Group';
    
    //CASE RECORD TYPES
    public static Final String BISUPCASERECORDTYPE = 'Business_Insight_Case';
    public static Final String BIRELCASERECORDTYPE = 'Business_Insight_Case_Release';
    
    
    //Objective Record Types
    public static Final String ACCOUNTOBJECTIVE  = 'BI_Account_Objecitve';
    
    //Account Plan Record Types
    public static Final String AGENCYACCTPLANRECORDTYPE = 'BI_Agency_Account_Plan';
    public static Final String CORPACCTPLANRECORDTYPE = 'BI_Corporate_Account_Plan';
    
        //Stage/Status History Record Type API Names
    public static Final String LEADSTATUSHISTORYRECORDTYPE  = 'BI_Lead_Status_History';
    public static Final String OPTYSTAGEHISTORYRECORDTYPE  = 'BI_Opportunity_Stage_History';
    public static Final String PRICINGREQSTAGEHISTORYRECORDTYPE  = 'BI_Proposal_Request_Form_Stage_History';

    public static Final String PRICINGREQCPRPORATERECORDTYPE  = 'BI_Corporate_Proposal_Request_Form';
    public static Final String PRICINGRETACINCRECORDTYPE  = 'BI_Tactical_Incentive_Proposal_Request_Form';
    public static Final String PRICINGREQPASSPLUSRECORDTYPE  = 'BI_PassPlus_Proposal_Request_Form';
    public static Final String PRICINGREQTMCCONTRACTRECORDTYPE  = 'BI_TMC_Contract_Proposal_Request_Form';
	public static Final String PRICINGRETACINCTMCRECORDTYPE = 'BI_Tactical_Incentive_TMC_Proposal_Request_Form';


    public static Final String OPPORTUNITYOBJECTIVE  = 'Opportunity';
    public static Final String DIVISIONALPLAN  = 'Divisional Plan';
    public static Final String REGIONALPLAN  = 'Regional Plan';
    public static Final String TERRITORYPLAN  = 'Territory Plan';
    public static Final String ACCOUNTPLAN  = 'Account Plan';
    public static Final String CORPORATE  = 'Corporate';
    public static Final String TRAVELAGENCY  = 'Travel Agency';
    public static Final String CORPORATEGLOBAL  = 'Corporate (global)';
    public static Final String ACCOUNTOBJ  = 'Account';
    public static Final String OPPORTUNTIYOBJ  = 'Opportunity';


    public static Final Boolean TRUEVALUE  = true;
    public static Final Boolean FALSEVALUE  = false;
    public static Final String NULLVALUE  = null;
    public static Final String DAY  = 'Day';
    public static Final String DAYS  = 'Days';
    public static Final String HOURS  = 'H';
    public static Final String MINUTES  = 'M';
    public static Final String NONE  ='--NONE--';
    public static Final String PICKLIST  ='PICKLIST';
    public static Final String MULTIPICKLIST  ='MULTIPICKLIST';
    public static Final String AGENCY  ='Agency';
    public static Final String TESTNAME  ='test name';
    public static Final String NOTVALIDPRF  = 'Not Valid Proposal Request Form';
    public static Final String ALLVALUE  = 'All';


    public static Final String PRICINGNEGOPROPOSAL = 'Pricing/Negotiation/Proposal';
    public static Final String LEGAL = 'Legal';
    public static Final String SIGNATORY = 'Signatory';
    public static Final String CONTRACTLEAD = 'Contract Lead';
    public static Final String LOST = 'LOS';
    public static Final String LOSSOFACQUISITION = 'LOA';
    public static Final String INACTIVE = 'INA';
    public static Final String RENEWED = 'NCR';
    public static Final String WITHDRAWNCANCELLED = 'Withdrawn/Cancelled';
    public static Final String SUBMIT = 'Submitted';
    public static Final String SUBMITFORBUILD = 'Submitted for build';
    public static String DRF_STAGE = 'Draft';
    public static String RFB_STAGE = 'RFB';
    public static Final String ACTIVEVALUE = 'Active';

    public static Final String YES = 'Yes';
    public static Final String OTHER = 'Other';
    public static Final String NORTHAMERICA = 'North America';
    public static Final String LATINAMERICA = 'Latin America';
    public static Final String APAC = 'APAC';
    public static Final String EMEAI = 'EMEAI';

    public static Final String REGION = 'BI_Region__c';

    public static Final String NONUCSACCOUNTRECORDTYPE = 'BI_International_Account';
    public static Final String SMEACCOUNTRECORDTYPE = 'BI_SME_Account';
    public static Final String AGENCY_BRANCH = 'Agency_Branch';
    public static Final String AGENCY_SUMMARY = 'PL_Agency_Summary';
    public static Final String AGENT = 'Agent';

    //BI RELEASE 2019-08 Lead Management
    public static Final String CLOSEDORLOST = 'Closed (Not Converted)';
    public static Final String CLOSEDCONVERTED = 'Converted';
    public static Final String LEADSTATUS1 = 'Pre-Work';
    public static Final String LEADSTATUS2 = 'Engaged';

    public static Final String PRICEGRIDAPINAME  = 'BI_Pricing_Grid__c';
    public static Final String DIVISIONALPLANAPIOBJECT  = 'BI_Divisional_Plan__c';
    public static Final String REGIONALPLANAPIOBJECT  = 'BI_Regional_Plan__c';
    public static Final String OBJACTIVESTYPE  = 'BI_Objective_Type__c';
    public static Final String VALIDOBJACTIVESYEAR  = 'BI_Valid_Objective_Year__c';
    public static Final String OBJPRICINGREQUEST  = 'BI_Proposal_Request_Form__c';
    public static Final String OBJCONTRACT  = 'SIP_Contract__c';
     // Field Set
    public static Final String PRICING_MASS_FIELD_SET  = 'Pricing_Mass_POC_Field_Set';
    public static Final String CONVOTOPIC_MASS_FIELD_SET  = 'Conversation_Topic_Mass_Field_Set';
	public static Final String PROJECT_MASS_FIELD_SET  = 'Project_Mass_Field_Set';

    //Object API Names 
    public static Final String STAGEORSTATUSHISTORYOBJAPI  = 'BI_Stage_Or_Status_History__c';
    // Objective Type - Region, Division
    public static Final String OBJECTIVETYPEREGION = 'ARN - SALES';
    public static Final String OBJECTIVETYPEDIVISION = 'BRAZIL SALES';
    // User - Region, Division
    public static Final String USERREGION = 'ARN - SALES';
    public static Final String USERDIVISION = 'BRAZIL SALES';
    // Plan Year
    public static Final String PLAN_YEAR = '2017';
    public static Final String PLAN_YEAR_A = '2016';
    // Opportunity Stage 
    public static Final String STAGE_FIRST = 'Prework & Qualification';
    public static Final String STAGE_SECOND = 'Data Analysis/Review';
    public static Final String STAGE_THIRD = 'Pricing/Negotiation/Proposal';
    //User Country
    public static Final String USER_COUNTRY = 'ZAIRE';
    public static Final String BRAZIL = 'BRAZIL';
    public static Final String ARGENTINA = 'ARGENTINA';
    public static Final String MEXICO = 'MEXTO';
     public static Final String MEXICOUN = 'MEXICO';
    public static Final String BELIZE = 'BELIZE';
    public static Final String ACCOUNT_CONTACT_RELATIONSHIP_ROLE = 'Signatory;Contract Lead;';
    public static Final String CONTRACT_CATEGORY = 'New';
    public static Final String OPPORTUNITY_TACTICAL_INCENTIVE_RECORD_TYPE = 'BI_Tactical_Incentive_Pricing';
    public static Final String TYOSS = 'TYOSS';
    public static Final String LHRSS ='LHRSS';
    public static Final String PREVIEW = 'Preview';
    public static Final String APFJAPAN = 'APF Japan';
    

    
    /*
     * Method : getPicklistValues
     * Purpose : Get field picklist values based on object name and Field Name
     * Params : String strObjName   - ApI Name of the object
                String strFieldName - API Name of the picklist field
     */
    public static List<String> getPicklistValues(String strObjName, String strFieldName){ 
     
      List<String> lstPickvals = new List<String>();
      Schema.SObjectType targetType = Schema.getGlobalDescribe().get(strObjName);//From the Object Api name retrieving the SObject
      Sobject ObjectName = targetType.newSObject();
      Schema.sObjectType sobjType = ObjectName.getSObjectType(); //grab the sobject that was passed
      Schema.DescribeSObjectResult sobjDesc = sobjType.getDescribe(); //describe the sobject
      Map<String, Schema.SObjectField> mapField = sobjDesc.fields.getMap(); //get a map of fields for the passed sobject
      List<Schema.PicklistEntry> listPickListVals = mapField.get(strFieldName).getDescribe().getPickListValues(); 
      
      for (Schema.PicklistEntry entry : listPickListVals) {
        lstPickvals.add(entry.getValue());
      }
      return lstPickvals;
  }
    /*
     * Method : getFieldSetAllFields
     * Purpose : Get all FieldPaths from fieldset
     * Params : String objectName   - ApI Name of the object
                String fieldSetName - API Name of the fieldSet field
     */
    
  public static List<String> getFieldSetAllFieldPaths(String objectName, String fieldSetName) {
      Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
      Schema.DescribeSObjectResult describe = targetType.getDescribe();
      Map<String, Schema.FieldSet> fsMap = describe.fieldSets.getMap();
      Schema.FieldSet fs = fsMap.get(fieldSetName);
      List<Schema.FieldSetMember> fieldSetList = fs.getFields();

      List<String> allFieldPathsList = new List<String>(); // Object's API name
      for(Schema.FieldSetMember fieldSet : fieldSetList) {
        allFieldPathsList.add(fieldSet.getFieldPath());
      }

      return allFieldPathsList; 
  }
 
  /*
     * Method : getRecordTypeIdByAPIName
     * Purpose : Get the reordtype Id of the particular object
     * Params : String objectName   - ApI Name of the object
                String fieldSetName - API Name of the fieldAPIName
     */
  public static String getRecordTypeIdByAPIName(String objectName, String fieldAPIName) {
    return [select Id,DeveloperName from RecordType where SobjectType =:objectName and DeveloperName=:fieldAPIName].Id;
  }
}