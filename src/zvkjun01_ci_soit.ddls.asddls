@AccessControl.authorizationCheck:#NOT_REQUIRED
@EndUserText.label:'Projection CDS : Sales Order Item'
@Metadata.ignorePropagatedAnnotations:false
@Metadata.allowExtensions:true
define view entity  ZVKJUN01_CI_SOIT
as projection on ZVKJUN01_I_SOIT
{
key Soid,
key ItemId,
Product,
Amount,
Currency,
SalesPerson,
SalesTimestamp,
SalesManager,
ApprovalTimestamp,
ChangedBy,
ChangedOn,
image_item,
/* Associations */
_Header: redirected to parent ZVKJUN01_CR_SO,
_Prod,
_DeliveryS,
_Invoice
}
