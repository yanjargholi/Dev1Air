declare module "@salesforce/apex/BI_LightningUtility_OwnerQueueCases.getQueueCases" {
  export default function getQueueCases(param: {LimitSize: any, recIdList: any, Orderby: any, OrderDir: any}): Promise<any>;
}
declare module "@salesforce/apex/BI_LightningUtility_OwnerQueueCases.getOwnerCases" {
  export default function getOwnerCases(param: {LimitSize: any, recIdList: any, Orderby: any, OrderDir: any}): Promise<any>;
}
declare module "@salesforce/apex/BI_LightningUtility_OwnerQueueCases.updateCases" {
  export default function updateCases(param: {editedCaseList: any}): Promise<any>;
}
declare module "@salesforce/apex/BI_LightningUtility_OwnerQueueCases.ownCases" {
  export default function ownCases(param: {myCaseList: any}): Promise<any>;
}
declare module "@salesforce/apex/BI_LightningUtility_OwnerQueueCases.getCasesRecType" {
  export default function getCasesRecType(param: {theCaseList: any, selectedRowId: any}): Promise<any>;
}
