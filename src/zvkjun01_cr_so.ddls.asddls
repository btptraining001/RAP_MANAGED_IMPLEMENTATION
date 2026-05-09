
@AccessControl.authorizationCheck:#NOT_REQUIRED
@EndUserText.label:'Projection CDS : Sales Order'
@Metadata.ignorePropagatedAnnotations:true
@Metadata.allowExtensions:true
define root view entity ZVKJUN01_CR_SO
provider contract transactional_query
as projection on ZVKJUN01_R_SO
{
key Soid,
Buyer,
SalesPerson,
SalesTimestamp,
SalesManager,
ApprovalTimestamp,
CreatedBy,
CreatedOn,
ChangedBy,
ChangedOn,
Url,
CustomerRating,
/* Associations */
_Cust,
_Item: redirected to composition child ZVKJUN01_CI_SOIT
}
