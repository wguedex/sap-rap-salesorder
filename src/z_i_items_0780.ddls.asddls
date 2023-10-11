@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Sales Order - Items'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Z_I_ITEMS_0780
  as select from zitems_0780 as Items 
  association to parent Z_I_HEADER_0780 as _Header on $projection.Ordernumber = _Header.Ordernumber

{
  key ordernumber      as Ordernumber,
  key positionnumber   as Positionnumber,
      name             as Name,
      description      as Description,
      releasedate      as Releasedate,
      discontinueddate as Discontinueddate,
      price            as Price,
      @Semantics.quantity.unitOfMeasure : 'Unitofmeasure'
      height           as Height,
      @Semantics.quantity.unitOfMeasure : 'Unitofmeasure'
      width            as Width,
      depth            as Depth,
      quantity         as Quantity,
      unitofmeasure    as Unitofmeasure, 
      _Header
}
