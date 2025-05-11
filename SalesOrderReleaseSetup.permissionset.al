namespace SO;
using System.Security.AccessControl;

permissionset 99004 "SO Release Setup"
{
    IncludedPermissionSets = "D365 BUS FULL ACCESS", "D365 READ", "D365 BASIC";
    Assignable = true;
    Permissions = tabledata "Sales Order Release Setup" = RM,
        table "Sales Order Release Setup" = X,
        codeunit CreatePickOnSalesOrderRelease = X,
        codeunit InitializeSOReleaseSetup = X,
        page "Sales Order Release Setup" = X;
}