declare module "@salesforce/apex/BI_ObjectiveEnhancements.fetchFocusRecords" {
  export default function fetchFocusRecords(param: {recordId: any, sortField: any, isAsc: any}): Promise<any>;
}
declare module "@salesforce/apex/BI_ObjectiveEnhancements.fetchAccounts" {
  export default function fetchAccounts(param: {recordId: any, sortField: any, isAsc: any, showSalesTeamAccounts: any}): Promise<any>;
}
declare module "@salesforce/apex/BI_ObjectiveEnhancements.createFocusCustomerRecords" {
  export default function createFocusCustomerRecords(param: {objectiveId: any, AccountIdList: any}): Promise<any>;
}
