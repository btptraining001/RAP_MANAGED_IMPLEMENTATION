@AbapCatalog.viewEnhancementCategory:[#NONE]
@AccessControl.authorizationCheck:#NOT_REQUIRED
@EndUserText.label:'Interface View- Sales Order Item'
@Metadata.ignorePropagatedAnnotations:true
@Metadata.allowExtensions:true
@ObjectModel.usageType:{
serviceQuality:#X,
sizeCategory:#S,
dataClass:#MIXED
}
define view entity ZVKJUN01_I_SOIT
  as select from zvkjun01_dt_soit

  association        to parent ZVKJUN01_R_SO as _Header    on  $projection.Soid = _Header.Soid

  association [1..1] to ZVKJUN01_I_PROD      as _Prod      on  zvkjun01_dt_soit.product = _Prod.ProdId

  association [0..*] to ZVKJUN01_I_DLSH      as _DeliveryS on  zvkjun01_dt_soit.soid    = _DeliveryS.Soid
                                                           and zvkjun01_dt_soit.item_id = _DeliveryS.ItemId

  association [0..*] to ZVKJUN01_I_INV      as _Invoice on  zvkjun01_dt_soit.soid    = _Invoice.Soid
                                                           and zvkjun01_dt_soit.item_id = _Invoice.ItemId                                                           

{
  key soid               as Soid,
  key item_id            as ItemId,
      product            as Product,
      @Semantics.amount.currencyCode:'Currency'
      amount             as Amount,
      currency           as Currency,
      sales_person       as SalesPerson,
      sales_timestamp    as SalesTimestamp,
      sales_manager      as SalesManager,
      approval_timestamp as ApprovalTimestamp,
      changed_by         as ChangedBy,
      changed_on         as ChangedOn,
@Semantics.imageUrl: true      
      image_item,
      _Prod,
      _Header,
      _DeliveryS,
      _Invoice
}
