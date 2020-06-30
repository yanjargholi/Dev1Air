declare module "@salesforce/apex/BI_UserProjectsHandler.getProjectsFieldInfo" {
  export default function getProjectsFieldInfo(): Promise<any>;
}
declare module "@salesforce/apex/BI_UserProjectsHandler.queryProjectAPIFieldNames" {
  export default function queryProjectAPIFieldNames(): Promise<any>;
}
declare module "@salesforce/apex/BI_UserProjectsHandler.getProjectRecords" {
  export default function getProjectRecords(param: {oneONoneId: any}): Promise<any>;
}
declare module "@salesforce/apex/BI_UserProjectsHandler.getProjectRecordsView" {
  export default function getProjectRecordsView(param: {recordId: any, initflag: any, sortField: any, isAsc: any}): Promise<any>;
}
declare module "@salesforce/apex/BI_UserProjectsHandler.checkForParticipant" {
  export default function checkForParticipant(param: {oneONoneId: any}): Promise<any>;
}
declare module "@salesforce/apex/BI_UserProjectsHandler.saveProjects" {
  export default function saveProjects(param: {oneOnOneId: any, ProjectList: any}): Promise<any>;
}
