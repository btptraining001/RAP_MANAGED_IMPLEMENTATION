
@AccessControl.authorizationCheck:#NOT_REQUIRED
@EndUserText.label:'Interface CDS : Sales Order Header'
@Metadata.ignorePropagatedAnnotations:true
@Metadata.allowExtensions:true
define root view entity ZVKJUN01_R_SO
as select from zvkjun01_dt_so
composition [0..*] of ZVKJUN01_I_SOIT as _Item


association [1..1] to ZVKJUN01_I_CUST as _Cust
on $projection.Buyer = _Cust.CustId 
{

key soid as Soid,
buyer as Buyer,
sales_person as SalesPerson,


sales_timestamp as SalesTimestamp,
sales_manager as SalesManager,
approval_timestamp as ApprovalTimestamp,
created_by as CreatedBy,
created_on as CreatedOn,
changed_by as ChangedBy,
3.5 as CustomerRating, /* Hardcoded Value for Demo */
@Semantics.systemDateTime.lastChangedAt:true
@Semantics.systemDateTime.localInstanceLastChangedAt:true
changed_on as ChangedOn,
url as Url,
_Item,// Make association public
_Cust
}
