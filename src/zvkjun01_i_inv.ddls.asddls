@AbapCatalog.viewEnhancementCategory:[#NONE]
@AccessControl.authorizationCheck:#NOT_REQUIRED
@EndUserText.label:'Interface CDS : Invoice'
@Metadata.ignorePropagatedAnnotations:false
@Metadata.allowExtensions:true
@ObjectModel.usageType:{
serviceQuality:#X,
sizeCategory:#S,
dataClass:#MIXED
}
define view entity ZVKJUN01_I_INV
as select from zvkjun01_dt_inv
{
key soid as Soid,
key item_id as ItemId,
key invoice_id as InvoiceId,
buyer as Buyer,
@Semantics.amount.currencyCode:'Currency'
billing_amt as BillingAmt,
currency as Currency
}
