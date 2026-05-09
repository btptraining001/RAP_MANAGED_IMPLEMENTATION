@AbapCatalog.viewEnhancementCategory:[#NONE]
@AccessControl.authorizationCheck:#NOT_REQUIRED
@EndUserText.label:'Interface View- Customer'
@Metadata.ignorePropagatedAnnotations:true
@Metadata.allowExtensions:true
@ObjectModel.usageType:{
serviceQuality:#X,
sizeCategory:#S,
dataClass:#MIXED
}
define view entity ZVKJUN01_I_CUST
as select from zvkjun01_dt_cust
{
key cust_id as CustId,
name as Name,
company_name as CompanyName,
country as Country,
city as City,
mobile as Mobile,
local_last_changed as LocalLastChanged,
last_changed as LastChanged,
local_changed_by as LocalChangedBy,
last_changed_by as LastChangedBy
}
