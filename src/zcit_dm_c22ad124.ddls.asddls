@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'DMS Projection View 22AD124'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZCIT_DM_C22AD124
  as projection on ZCIT_DM_I22AD124
{
  key DocumentID,
      Title,
      DocType,
      Status,
      Priority,
      CreatedBy,
      CreatedAt,
      @Semantics.amount.currencyCode: 'Currency'
      StorageCost,
      Currency
}
