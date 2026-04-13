@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DMS Interface View 22AD124'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZCIT_DM_I22AD124
  as select from zcit_dm_t22ad124
{
  key doc_id       as DocumentID,
      doc_title    as Title,
      doc_type     as DocType,
      doc_status   as Status,
      priority     as Priority,
      created_by   as CreatedBy,
      created_at   as CreatedAt,
      
      @Semantics.amount.currencyCode: 'Currency'
      storage_cost as StorageCost,
      currency     as Currency
}
