@AbapCatalog.viewEnhancementCategory:[#NONE]
@AccessControl.authorizationCheck:#NOT_REQUIRED
@EndUserText.label:'Interface CDS : Delivery Schedule'
@Metadata.ignorePropagatedAnnotations:true
@Metadata.allowExtensions:true
@ObjectModel.usageType:{
serviceQuality:#X,
sizeCategory:#S,
dataClass:#MIXED
}
define view entity ZVKJUN01_I_DLSH
as select from zvkjun01_dt_dlsh
{
key soid as Soid,
key item_id as ItemId,
key delv_id as DelvId,
product as Product,
quantity as Quantity,
delivery_date as DeliveryDate
}
