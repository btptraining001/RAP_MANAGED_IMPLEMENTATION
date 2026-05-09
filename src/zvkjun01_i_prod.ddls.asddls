@AbapCatalog.viewEnhancementCategory:[#NONE]
@AccessControl.authorizationCheck:#NOT_REQUIRED
@EndUserText.label:'Interface View- Product'
@Metadata.ignorePropagatedAnnotations:true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
serviceQuality:#X,
sizeCategory:#S,
dataClass:#MIXED
}
define view entity ZVKJUN01_I_PROD
as select from zvkjun01_dt_prod
{
key prod_id as ProdId,
descpt as Descpt,
@Semantics.amount.currencyCode:'Currency'
price as Price,
currency as Currency
}
