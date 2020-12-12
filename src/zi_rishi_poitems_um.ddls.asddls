@AbapCatalog.sqlViewName: 'ZIRSHPOITMUM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Unmanage TRAPP'
define view ZI_RISHI_POITEMS_UM
  as select from zrishi_poitmdata
  association to parent ZI_RISHI_POINFO_UM as _Header on $projection.po_document = _Header.po_doc
{
  key po_document,
  key po_item,
      item_desc,
      vendor,
      price,
      currency,
      quantity,
      unit,
      change_date_time,
      _Header
}
