@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Sales Order - Items - Proj. View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
 
define view entity Z_C_ITEMS_0780
  as projection on Z_I_ITEMS_0780
{
  key Ordernumber,
  key Positionnumber,
      Name,
      Description,
      Releasedate,
      Discontinueddate,
      Price,
      @Semantics.quantity.unitOfMeasure : 'Unitofmeasure'
      Height,
      @Semantics.quantity.unitOfMeasure : 'Unitofmeasure'
      Width,
      Depth,
      Quantity,
      Unitofmeasure,
      /* Associations */
      _Header: redirected to parent Z_C_HEADER_0780
}
