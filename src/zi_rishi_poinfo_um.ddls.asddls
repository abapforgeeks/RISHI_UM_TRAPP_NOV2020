@AbapCatalog.sqlViewName: 'ZRSHPOUM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Unmanage TRAPP'
define root view ZI_RISHI_POINFO_UM as select from zrishi_podata
composition[0..*] of ZI_RISHI_POITEMS_UM as _Items

 {
    key po_doc  ,
    po_description ,
    postatus ,
    popriority ,
    compcode ,
    total_poprice,
    curkey ,
    createby ,
    created_on,
    changed_on ,
    final_change, 
    _Items
}
