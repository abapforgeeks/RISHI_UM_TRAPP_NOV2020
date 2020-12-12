@EndUserText.label: 'pROJECTIO ON ITEMS'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_RISHI_POITEMS_UM as projection on ZI_RISHI_POITEMS_UM {
    key po_document,
    key po_item,
    item_desc,
    vendor,
    price,
    currency,
    quantity,
    unit,
    change_date_time,
    /* Associations */
    _Header: redirected to parent ZC_RISHI_POINFO_UM
}
