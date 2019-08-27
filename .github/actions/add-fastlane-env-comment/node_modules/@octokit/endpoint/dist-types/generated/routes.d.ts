import { Url, Headers, EndpointRequestOptions } from "../types";
export interface Routes {
    "GET /events": [ActivityListPublicEventsEndpoint, ActivityListPublicEventsRequestOptions];
    "GET /repos/:owner/:repo/events": [ActivityListRepoEventsEndpoint, ActivityListRepoEventsRequestOptions];
    "GET /networks/:owner/:repo/events": [ActivityListPublicEventsForRepoNetworkEndpoint, ActivityListPublicEventsForRepoNetworkRequestOptions];
    "GET /orgs/:org/events": [ActivityListPublicEventsForOrgEndpoint, ActivityListPublicEventsForOrgRequestOptions];
    "GET /users/:username/received_events": [ActivityListReceivedEventsForUserEndpoint, ActivityListReceivedEventsForUserRequestOptions];
    "GET /users/:username/received_events/public": [ActivityListReceivedPublicEventsForUserEndpoint, ActivityListReceivedPublicEventsForUserRequestOptions];
    "GET /users/:username/events": [ActivityListEventsForUserEndpoint, ActivityListEventsForUserRequestOptions];
    "GET /users/:username/events/public": [ActivityListPublicEventsForUserEndpoint, ActivityListPublicEventsForUserRequestOptions];
    "GET /users/:username/events/orgs/:org": [ActivityListEventsForOrgEndpoint, ActivityListEventsForOrgRequestOptions];
    "GET /feeds": [ActivityListFeedsEndpoint, ActivityListFeedsRequestOptions];
    "GET /notifications": [ActivityListNotificationsEndpoint, ActivityListNotificationsRequestOptions];
    "GET /repos/:owner/:repo/notifications": [ActivityListNotificationsForRepoEndpoint, ActivityListNotificationsForRepoRequestOptions];
    "PUT /notifications": [ActivityMarkAsReadEndpoint, ActivityMarkAsReadRequestOptions];
    "PUT /repos/:owner/:repo/notifications": [ActivityMarkNotificationsAsReadForRepoEndpoint, ActivityMarkNotificationsAsReadForRepoRequestOptions];
    "GET /notifications/threads/:thread_id": [ActivityGetThreadEndpoint, ActivityGetThreadRequestOptions];
    "PATCH /notifications/threads/:thread_id": [ActivityMarkThreadAsReadEndpoint, ActivityMarkThreadAsReadRequestOptions];
    "GET /notifications/threads/:thread_id/subscription": [ActivityGetThreadSubscriptionEndpoint, ActivityGetThreadSubscriptionRequestOptions];
    "PUT /notifications/threads/:thread_id/subscription": [ActivitySetThreadSubscriptionEndpoint, ActivitySetThreadSubscriptionRequestOptions];
    "DELETE /notifications/threads/:thread_id/subscription": [ActivityDeleteThreadSubscriptionEndpoint, ActivityDeleteThreadSubscriptionRequestOptions];
    "GET /repos/:owner/:repo/stargazers": [ActivityListStargazersForRepoEndpoint, ActivityListStargazersForRepoRequestOptions];
    "GET /users/:username/starred": [ActivityListReposStarredByUserEndpoint, ActivityListReposStarredByUserRequestOptions];
    "GET /user/starred": [ActivityListReposStarredByAuthenticatedUserEndpoint, ActivityListReposStarredByAuthenticatedUserRequestOptions];
    "GET /user/starred/:owner/:repo": [ActivityCheckStarringRepoEndpoint, ActivityCheckStarringRepoRequestOptions];
    "PUT /user/starred/:owner/:repo": [ActivityStarRepoEndpoint, ActivityStarRepoRequestOptions];
    "DELETE /user/starred/:owner/:repo": [ActivityUnstarRepoEndpoint, ActivityUnstarRepoRequestOptions];
    "GET /repos/:owner/:repo/subscribers": [ActivityListWatchersForRepoEndpoint, ActivityListWatchersForRepoRequestOptions];
    "GET /users/:username/subscriptions": [ActivityListReposWatchedByUserEndpoint, ActivityListReposWatchedByUserRequestOptions];
    "GET /user/subscriptions": [ActivityListWatchedReposForAuthenticatedUserEndpoint, ActivityListWatchedReposForAuthenticatedUserRequestOptions];
    "GET /repos/:owner/:repo/subscription": [ActivityGetRepoSubscriptionEndpoint, ActivityGetRepoSubscriptionRequestOptions];
    "PUT /repos/:owner/:repo/subscription": [ActivitySetRepoSubscriptionEndpoint, ActivitySetRepoSubscriptionRequestOptions];
    "DELETE /repos/:owner/:repo/subscription": [ActivityDeleteRepoSubscriptionEndpoint, ActivityDeleteRepoSubscriptionRequestOptions];
    "GET /user/subscriptions/:owner/:repo": [ActivityCheckWatchingRepoLegacyEndpoint, ActivityCheckWatchingRepoLegacyRequestOptions];
    "PUT /user/subscriptions/:owner/:repo": [ActivityWatchRepoLegacyEndpoint, ActivityWatchRepoLegacyRequestOptions];
    "DELETE /user/subscriptions/:owner/:repo": [ActivityStopWatchingRepoLegacyEndpoint, ActivityStopWatchingRepoLegacyRequestOptions];
    "GET /apps/:app_slug": [AppsGetBySlugEndpoint, AppsGetBySlugRequestOptions];
    "GET /app": [AppsGetAuthenticatedEndpoint, AppsGetAuthenticatedRequestOptions];
    "GET /app/installations": [AppsListInstallationsEndpoint, AppsListInstallationsRequestOptions];
    "GET /app/installations/:installation_id": [AppsGetInstallationEndpoint, AppsGetInstallationRequestOptions];
    "DELETE /app/installations/:installation_id": [AppsDeleteInstallationEndpoint, AppsDeleteInstallationRequestOptions];
    "POST /app/installations/:installation_id/access_tokens": [AppsCreateInstallationTokenEndpoint, AppsCreateInstallationTokenRequestOptions];
    "GET /orgs/:org/installation": [AppsGetOrgInstallationEndpoint | AppsFindOrgInstallationEndpoint, AppsGetOrgInstallationRequestOptions | AppsFindOrgInstallationRequestOptions];
    "GET /repos/:owner/:repo/installation": [AppsGetRepoInstallationEndpoint | AppsFindRepoInstallationEndpoint, AppsGetRepoInstallationRequestOptions | AppsFindRepoInstallationRequestOptions];
    "GET /users/:username/installation": [AppsGetUserInstallationEndpoint | AppsFindUserInstallationEndpoint, AppsGetUserInstallationRequestOptions | AppsFindUserInstallationRequestOptions];
    "POST /app-manifests/:code/conversions": [AppsCreateFromManifestEndpoint, AppsCreateFromManifestRequestOptions];
    "GET /installation/repositories": [AppsListReposEndpoint, AppsListReposRequestOptions];
    "GET /user/installations": [AppsListInstallationsForAuthenticatedUserEndpoint, AppsListInstallationsForAuthenticatedUserRequestOptions];
    "GET /user/installations/:installation_id/repositories": [AppsListInstallationReposForAuthenticatedUserEndpoint, AppsListInstallationReposForAuthenticatedUserRequestOptions];
    "PUT /user/installations/:installation_id/repositories/:repository_id": [AppsAddRepoToInstallationEndpoint, AppsAddRepoToInstallationRequestOptions];
    "DELETE /user/installations/:installation_id/repositories/:repository_id": [AppsRemoveRepoFromInstallationEndpoint, AppsRemoveRepoFromInstallationRequestOptions];
    "POST /content_references/:content_reference_id/attachments": [AppsCreateContentAttachmentEndpoint, AppsCreateContentAttachmentRequestOptions];
    "GET /marketplace_listing/plans": [AppsListPlansEndpoint, AppsListPlansRequestOptions];
    "GET /marketplace_listing/stubbed/plans": [AppsListPlansStubbedEndpoint, AppsListPlansStubbedRequestOptions];
    "GET /marketplace_listing/plans/:plan_id/accounts": [AppsListAccountsUserOrOrgOnPlanEndpoint, AppsListAccountsUserOrOrgOnPlanRequestOptions];
    "GET /marketplace_listing/stubbed/plans/:plan_id/accounts": [AppsListAccountsUserOrOrgOnPlanStubbedEndpoint, AppsListAccountsUserOrOrgOnPlanStubbedRequestOptions];
    "GET /marketplace_listing/accounts/:account_id": [AppsCheckAccountIsAssociatedWithAnyEndpoint, AppsCheckAccountIsAssociatedWithAnyRequestOptions];
    "GET /marketplace_listing/stubbed/accounts/:account_id": [AppsCheckAccountIsAssociatedWithAnyStubbedEndpoint, AppsCheckAccountIsAssociatedWithAnyStubbedRequestOptions];
    "GET /user/marketplace_purchases": [AppsListMarketplacePurchasesForAuthenticatedUserEndpoint, AppsListMarketplacePurchasesForAuthenticatedUserRequestOptions];
    "GET /user/marketplace_purchases/stubbed": [AppsListMarketplacePurchasesForAuthenticatedUserStubbedEndpoint, AppsListMarketplacePurchasesForAuthenticatedUserStubbedRequestOptions];
    "POST /repos/:owner/:repo/check-runs": [ChecksCreateEndpoint, ChecksCreateRequestOptions];
    "PATCH /repos/:owner/:repo/check-runs/:check_run_id": [ChecksUpdateEndpoint, ChecksUpdateRequestOptions];
    "GET /repos/:owner/:repo/commits/:ref/check-runs": [ChecksListForRefEndpoint, ChecksListForRefRequestOptions];
    "GET /repos/:owner/:repo/check-suites/:check_suite_id/check-runs": [ChecksListForSuiteEndpoint, ChecksListForSuiteRequestOptions];
    "GET /repos/:owner/:repo/check-runs/:check_run_id": [ChecksGetEndpoint, ChecksGetRequestOptions];
    "GET /repos/:owner/:repo/check-runs/:check_run_id/annotations": [ChecksListAnnotationsEndpoint, ChecksListAnnotationsRequestOptions];
    "GET /repos/:owner/:repo/check-suites/:check_suite_id": [ChecksGetSuiteEndpoint, ChecksGetSuiteRequestOptions];
    "GET /repos/:owner/:repo/commits/:ref/check-suites": [ChecksListSuitesForRefEndpoint, ChecksListSuitesForRefRequestOptions];
    "PATCH /repos/:owner/:repo/check-suites/preferences": [ChecksSetSuitesPreferencesEndpoint, ChecksSetSuitesPreferencesRequestOptions];
    "POST /repos/:owner/:repo/check-suites": [ChecksCreateSuiteEndpoint, ChecksCreateSuiteRequestOptions];
    "POST /repos/:owner/:repo/check-suites/:check_suite_id/rerequest": [ChecksRerequestSuiteEndpoint, ChecksRerequestSuiteRequestOptions];
    "GET /codes_of_conduct": [CodesOfConductListConductCodesEndpoint, CodesOfConductListConductCodesRequestOptions];
    "GET /codes_of_conduct/:key": [CodesOfConductGetConductCodeEndpoint, CodesOfConductGetConductCodeRequestOptions];
    "GET /repos/:owner/:repo/community/code_of_conduct": [CodesOfConductGetForRepoEndpoint, CodesOfConductGetForRepoRequestOptions];
    "GET /emojis": [EmojisGetEndpoint, EmojisGetRequestOptions];
    "GET /users/:username/gists": [GistsListPublicForUserEndpoint, GistsListPublicForUserRequestOptions];
    "GET /gists": [GistsListEndpoint, GistsListRequestOptions];
    "GET /gists/public": [GistsListPublicEndpoint, GistsListPublicRequestOptions];
    "GET /gists/starred": [GistsListStarredEndpoint, GistsListStarredRequestOptions];
    "GET /gists/:gist_id": [GistsGetEndpoint, GistsGetRequestOptions];
    "GET /gists/:gist_id/:sha": [GistsGetRevisionEndpoint, GistsGetRevisionRequestOptions];
    "POST /gists": [GistsCreateEndpoint, GistsCreateRequestOptions];
    "PATCH /gists/:gist_id": [GistsUpdateEndpoint, GistsUpdateRequestOptions];
    "GET /gists/:gist_id/commits": [GistsListCommitsEndpoint, GistsListCommitsRequestOptions];
    "PUT /gists/:gist_id/star": [GistsStarEndpoint, GistsStarRequestOptions];
    "DELETE /gists/:gist_id/star": [GistsUnstarEndpoint, GistsUnstarRequestOptions];
    "GET /gists/:gist_id/star": [GistsCheckIsStarredEndpoint, GistsCheckIsStarredRequestOptions];
    "POST /gists/:gist_id/forks": [GistsForkEndpoint, GistsForkRequestOptions];
    "GET /gists/:gist_id/forks": [GistsListForksEndpoint, GistsListForksRequestOptions];
    "DELETE /gists/:gist_id": [GistsDeleteEndpoint, GistsDeleteRequestOptions];
    "GET /gists/:gist_id/comments": [GistsListCommentsEndpoint, GistsListCommentsRequestOptions];
    "GET /gists/:gist_id/comments/:comment_id": [GistsGetCommentEndpoint, GistsGetCommentRequestOptions];
    "POST /gists/:gist_id/comments": [GistsCreateCommentEndpoint, GistsCreateCommentRequestOptions];
    "PATCH /gists/:gist_id/comments/:comment_id": [GistsUpdateCommentEndpoint, GistsUpdateCommentRequestOptions];
    "DELETE /gists/:gist_id/comments/:comment_id": [GistsDeleteCommentEndpoint, GistsDeleteCommentRequestOptions];
    "GET /repos/:owner/:repo/git/blobs/:file_sha": [GitGetBlobEndpoint, GitGetBlobRequestOptions];
    "POST /repos/:owner/:repo/git/blobs": [GitCreateBlobEndpoint, GitCreateBlobRequestOptions];
    "GET /repos/:owner/:repo/git/commits/:commit_sha": [GitGetCommitEndpoint, GitGetCommitRequestOptions];
    "POST /repos/:owner/:repo/git/commits": [GitCreateCommitEndpoint, GitCreateCommitRequestOptions];
    "GET /repos/:owner/:repo/git/refs/:ref": [GitGetRefEndpoint, GitGetRefRequestOptions];
    "GET /repos/:owner/:repo/git/refs/:namespace": [GitListRefsEndpoint, GitListRefsRequestOptions];
    "POST /repos/:owner/:repo/git/refs": [GitCreateRefEndpoint, GitCreateRefRequestOptions];
    "PATCH /repos/:owner/:repo/git/refs/:ref": [GitUpdateRefEndpoint, GitUpdateRefRequestOptions];
    "DELETE /repos/:owner/:repo/git/refs/:ref": [GitDeleteRefEndpoint, GitDeleteRefRequestOptions];
    "GET /repos/:owner/:repo/git/tags/:tag_sha": [GitGetTagEndpoint, GitGetTagRequestOptions];
    "POST /repos/:owner/:repo/git/tags": [GitCreateTagEndpoint, GitCreateTagRequestOptions];
    "GET /repos/:owner/:repo/git/trees/:tree_sha": [GitGetTreeEndpoint, GitGetTreeRequestOptions];
    "POST /repos/:owner/:repo/git/trees": [GitCreateTreeEndpoint, GitCreateTreeRequestOptions];
    "GET /gitignore/templates": [GitignoreListTemplatesEndpoint, GitignoreListTemplatesRequestOptions];
    "GET /gitignore/templates/:name": [GitignoreGetTemplateEndpoint, GitignoreGetTemplateRequestOptions];
    "GET /orgs/:org/interaction-limits": [InteractionsGetRestrictionsForOrgEndpoint, InteractionsGetRestrictionsForOrgRequestOptions];
    "PUT /orgs/:org/interaction-limits": [InteractionsAddOrUpdateRestrictionsForOrgEndpoint, InteractionsAddOrUpdateRestrictionsForOrgRequestOptions];
    "DELETE /orgs/:org/interaction-limits": [InteractionsRemoveRestrictionsForOrgEndpoint, InteractionsRemoveRestrictionsForOrgRequestOptions];
    "GET /repos/:owner/:repo/interaction-limits": [InteractionsGetRestrictionsForRepoEndpoint, InteractionsGetRestrictionsForRepoRequestOptions];
    "PUT /repos/:owner/:repo/interaction-limits": [InteractionsAddOrUpdateRestrictionsForRepoEndpoint, InteractionsAddOrUpdateRestrictionsForRepoRequestOptions];
    "DELETE /repos/:owner/:repo/interaction-limits": [InteractionsRemoveRestrictionsForRepoEndpoint, InteractionsRemoveRestrictionsForRepoRequestOptions];
    "GET /issues": [IssuesListEndpoint, IssuesListRequestOptions];
    "GET /user/issues": [IssuesListForAuthenticatedUserEndpoint, IssuesListForAuthenticatedUserRequestOptions];
    "GET /orgs/:org/issues": [IssuesListForOrgEndpoint, IssuesListForOrgRequestOptions];
    "GET /repos/:owner/:repo/issues": [IssuesListForRepoEndpoint, IssuesListForRepoRequestOptions];
    "GET /repos/:owner/:repo/issues/:issue_number": [IssuesGetEndpoint, IssuesGetRequestOptions];
    "POST /repos/:owner/:repo/issues": [IssuesCreateEndpoint, IssuesCreateRequestOptions];
    "PATCH /repos/:owner/:repo/issues/:issue_number": [IssuesUpdateEndpoint, IssuesUpdateRequestOptions];
    "PUT /repos/:owner/:repo/issues/:issue_number/lock": [IssuesLockEndpoint, IssuesLockRequestOptions];
    "DELETE /repos/:owner/:repo/issues/:issue_number/lock": [IssuesUnlockEndpoint, IssuesUnlockRequestOptions];
    "GET /repos/:owner/:repo/assignees": [IssuesListAssigneesEndpoint, IssuesListAssigneesRequestOptions];
    "GET /repos/:owner/:repo/assignees/:assignee": [IssuesCheckAssigneeEndpoint, IssuesCheckAssigneeRequestOptions];
    "POST /repos/:owner/:repo/issues/:issue_number/assignees": [IssuesAddAssigneesEndpoint, IssuesAddAssigneesRequestOptions];
    "DELETE /repos/:owner/:repo/issues/:issue_number/assignees": [IssuesRemoveAssigneesEndpoint, IssuesRemoveAssigneesRequestOptions];
    "GET /repos/:owner/:repo/issues/:issue_number/comments": [IssuesListCommentsEndpoint, IssuesListCommentsRequestOptions];
    "GET /repos/:owner/:repo/issues/comments": [IssuesListCommentsForRepoEndpoint, IssuesListCommentsForRepoRequestOptions];
    "GET /repos/:owner/:repo/issues/comments/:comment_id": [IssuesGetCommentEndpoint, IssuesGetCommentRequestOptions];
    "POST /repos/:owner/:repo/issues/:issue_number/comments": [IssuesCreateCommentEndpoint, IssuesCreateCommentRequestOptions];
    "PATCH /repos/:owner/:repo/issues/comments/:comment_id": [IssuesUpdateCommentEndpoint, IssuesUpdateCommentRequestOptions];
    "DELETE /repos/:owner/:repo/issues/comments/:comment_id": [IssuesDeleteCommentEndpoint, IssuesDeleteCommentRequestOptions];
    "GET /repos/:owner/:repo/issues/:issue_number/events": [IssuesListEventsEndpoint, IssuesListEventsRequestOptions];
    "GET /repos/:owner/:repo/issues/events": [IssuesListEventsForRepoEndpoint, IssuesListEventsForRepoRequestOptions];
    "GET /repos/:owner/:repo/issues/events/:event_id": [IssuesGetEventEndpoint, IssuesGetEventRequestOptions];
    "GET /repos/:owner/:repo/labels": [IssuesListLabelsForRepoEndpoint, IssuesListLabelsForRepoRequestOptions];
    "GET /repos/:owner/:repo/labels/:name": [IssuesGetLabelEndpoint, IssuesGetLabelRequestOptions];
    "POST /repos/:owner/:repo/labels": [IssuesCreateLabelEndpoint, IssuesCreateLabelRequestOptions];
    "PATCH /repos/:owner/:repo/labels/:current_name": [IssuesUpdateLabelEndpoint, IssuesUpdateLabelRequestOptions];
    "DELETE /repos/:owner/:repo/labels/:name": [IssuesDeleteLabelEndpoint, IssuesDeleteLabelRequestOptions];
    "GET /repos/:owner/:repo/issues/:issue_number/labels": [IssuesListLabelsOnIssueEndpoint, IssuesListLabelsOnIssueRequestOptions];
    "POST /repos/:owner/:repo/issues/:issue_number/labels": [IssuesAddLabelsEndpoint, IssuesAddLabelsRequestOptions];
    "DELETE /repos/:owner/:repo/issues/:issue_number/labels/:name": [IssuesRemoveLabelEndpoint, IssuesRemoveLabelRequestOptions];
    "PUT /repos/:owner/:repo/issues/:issue_number/labels": [IssuesReplaceLabelsEndpoint, IssuesReplaceLabelsRequestOptions];
    "DELETE /repos/:owner/:repo/issues/:issue_number/labels": [IssuesRemoveLabelsEndpoint, IssuesRemoveLabelsRequestOptions];
    "GET /repos/:owner/:repo/milestones/:milestone_number/labels": [IssuesListLabelsForMilestoneEndpoint, IssuesListLabelsForMilestoneRequestOptions];
    "GET /repos/:owner/:repo/milestones": [IssuesListMilestonesForRepoEndpoint, IssuesListMilestonesForRepoRequestOptions];
    "GET /repos/:owner/:repo/milestones/:milestone_number": [IssuesGetMilestoneEndpoint, IssuesGetMilestoneRequestOptions];
    "POST /repos/:owner/:repo/milestones": [IssuesCreateMilestoneEndpoint, IssuesCreateMilestoneRequestOptions];
    "PATCH /repos/:owner/:repo/milestones/:milestone_number": [IssuesUpdateMilestoneEndpoint, IssuesUpdateMilestoneRequestOptions];
    "DELETE /repos/:owner/:repo/milestones/:milestone_number": [IssuesDeleteMilestoneEndpoint, IssuesDeleteMilestoneRequestOptions];
    "GET /repos/:owner/:repo/issues/:issue_number/timeline": [IssuesListEventsForTimelineEndpoint, IssuesListEventsForTimelineRequestOptions];
    "GET /licenses": [LicensesListCommonlyUsedEndpoint | LicensesListEndpoint, LicensesListCommonlyUsedRequestOptions | LicensesListRequestOptions];
    "GET /licenses/:license": [LicensesGetEndpoint, LicensesGetRequestOptions];
    "GET /repos/:owner/:repo/license": [LicensesGetForRepoEndpoint, LicensesGetForRepoRequestOptions];
    "POST /markdown": [MarkdownRenderEndpoint, MarkdownRenderRequestOptions];
    "POST /markdown/raw": [MarkdownRenderRawEndpoint, MarkdownRenderRawRequestOptions];
    "GET /meta": [MetaGetEndpoint, MetaGetRequestOptions];
    "POST /orgs/:org/migrations": [MigrationsStartForOrgEndpoint, MigrationsStartForOrgRequestOptions];
    "GET /orgs/:org/migrations": [MigrationsListForOrgEndpoint, MigrationsListForOrgRequestOptions];
    "GET /orgs/:org/migrations/:migration_id": [MigrationsGetStatusForOrgEndpoint, MigrationsGetStatusForOrgRequestOptions];
    "GET /orgs/:org/migrations/:migration_id/archive": [MigrationsGetArchiveForOrgEndpoint, MigrationsGetArchiveForOrgRequestOptions];
    "DELETE /orgs/:org/migrations/:migration_id/archive": [MigrationsDeleteArchiveForOrgEndpoint, MigrationsDeleteArchiveForOrgRequestOptions];
    "DELETE /orgs/:org/migrations/:migration_id/repos/:repo_name/lock": [MigrationsUnlockRepoForOrgEndpoint, MigrationsUnlockRepoForOrgRequestOptions];
    "PUT /repos/:owner/:repo/import": [MigrationsStartImportEndpoint, MigrationsStartImportRequestOptions];
    "GET /repos/:owner/:repo/import": [MigrationsGetImportProgressEndpoint, MigrationsGetImportProgressRequestOptions];
    "PATCH /repos/:owner/:repo/import": [MigrationsUpdateImportEndpoint, MigrationsUpdateImportRequestOptions];
    "GET /repos/:owner/:repo/import/authors": [MigrationsGetCommitAuthorsEndpoint, MigrationsGetCommitAuthorsRequestOptions];
    "PATCH /repos/:owner/:repo/import/authors/:author_id": [MigrationsMapCommitAuthorEndpoint, MigrationsMapCommitAuthorRequestOptions];
    "PATCH /repos/:owner/:repo/import/lfs": [MigrationsSetLfsPreferenceEndpoint, MigrationsSetLfsPreferenceRequestOptions];
    "GET /repos/:owner/:repo/import/large_files": [MigrationsGetLargeFilesEndpoint, MigrationsGetLargeFilesRequestOptions];
    "DELETE /repos/:owner/:repo/import": [MigrationsCancelImportEndpoint, MigrationsCancelImportRequestOptions];
    "POST /user/migrations": [MigrationsStartForAuthenticatedUserEndpoint, MigrationsStartForAuthenticatedUserRequestOptions];
    "GET /user/migrations": [MigrationsListForAuthenticatedUserEndpoint, MigrationsListForAuthenticatedUserRequestOptions];
    "GET /user/migrations/:migration_id": [MigrationsGetStatusForAuthenticatedUserEndpoint, MigrationsGetStatusForAuthenticatedUserRequestOptions];
    "GET /user/migrations/:migration_id/archive": [MigrationsGetArchiveForAuthenticatedUserEndpoint, MigrationsGetArchiveForAuthenticatedUserRequestOptions];
    "DELETE /user/migrations/:migration_id/archive": [MigrationsDeleteArchiveForAuthenticatedUserEndpoint, MigrationsDeleteArchiveForAuthenticatedUserRequestOptions];
    "DELETE /user/migrations/:migration_id/repos/:repo_name/lock": [MigrationsUnlockRepoForAuthenticatedUserEndpoint, MigrationsUnlockRepoForAuthenticatedUserRequestOptions];
    "GET /applications/grants": [OauthAuthorizationsListGrantsEndpoint, OauthAuthorizationsListGrantsRequestOptions];
    "GET /applications/grants/:grant_id": [OauthAuthorizationsGetGrantEndpoint, OauthAuthorizationsGetGrantRequestOptions];
    "DELETE /applications/grants/:grant_id": [OauthAuthorizationsDeleteGrantEndpoint, OauthAuthorizationsDeleteGrantRequestOptions];
    "GET /authorizations": [OauthAuthorizationsListAuthorizationsEndpoint, OauthAuthorizationsListAuthorizationsRequestOptions];
    "GET /authorizations/:authorization_id": [OauthAuthorizationsGetAuthorizationEndpoint, OauthAuthorizationsGetAuthorizationRequestOptions];
    "POST /authorizations": [OauthAuthorizationsCreateAuthorizationEndpoint, OauthAuthorizationsCreateAuthorizationRequestOptions];
    "PUT /authorizations/clients/:client_id": [OauthAuthorizationsGetOrCreateAuthorizationForAppEndpoint, OauthAuthorizationsGetOrCreateAuthorizationForAppRequestOptions];
    "PUT /authorizations/clients/:client_id/:fingerprint": [OauthAuthorizationsGetOrCreateAuthorizationForAppAndFingerprintEndpoint | OauthAuthorizationsGetOrCreateAuthorizationForAppFingerprintEndpoint, OauthAuthorizationsGetOrCreateAuthorizationForAppAndFingerprintRequestOptions | OauthAuthorizationsGetOrCreateAuthorizationForAppFingerprintRequestOptions];
    "PATCH /authorizations/:authorization_id": [OauthAuthorizationsUpdateAuthorizationEndpoint, OauthAuthorizationsUpdateAuthorizationRequestOptions];
    "DELETE /authorizations/:authorization_id": [OauthAuthorizationsDeleteAuthorizationEndpoint, OauthAuthorizationsDeleteAuthorizationRequestOptions];
    "GET /applications/:client_id/tokens/:access_token": [OauthAuthorizationsCheckAuthorizationEndpoint, OauthAuthorizationsCheckAuthorizationRequestOptions];
    "POST /applications/:client_id/tokens/:access_token": [OauthAuthorizationsResetAuthorizationEndpoint, OauthAuthorizationsResetAuthorizationRequestOptions];
    "DELETE /applications/:client_id/tokens/:access_token": [OauthAuthorizationsRevokeAuthorizationForApplicationEndpoint, OauthAuthorizationsRevokeAuthorizationForApplicationRequestOptions];
    "DELETE /applications/:client_id/grants/:access_token": [OauthAuthorizationsRevokeGrantForApplicationEndpoint, OauthAuthorizationsRevokeGrantForApplicationRequestOptions];
    "GET /user/orgs": [OrgsListForAuthenticatedUserEndpoint, OrgsListForAuthenticatedUserRequestOptions];
    "GET /organizations": [OrgsListEndpoint, OrgsListRequestOptions];
    "GET /users/:username/orgs": [OrgsListForUserEndpoint, OrgsListForUserRequestOptions];
    "GET /orgs/:org": [OrgsGetEndpoint, OrgsGetRequestOptions];
    "PATCH /orgs/:org": [OrgsUpdateEndpoint, OrgsUpdateRequestOptions];
    "GET /orgs/:org/credential-authorizations": [OrgsListCredentialAuthorizationsEndpoint, OrgsListCredentialAuthorizationsRequestOptions];
    "DELETE /orgs/:org/credential-authorizations/:credential_id": [OrgsRemoveCredentialAuthorizationEndpoint, OrgsRemoveCredentialAuthorizationRequestOptions];
    "GET /orgs/:org/blocks": [OrgsListBlockedUsersEndpoint, OrgsListBlockedUsersRequestOptions];
    "GET /orgs/:org/blocks/:username": [OrgsCheckBlockedUserEndpoint, OrgsCheckBlockedUserRequestOptions];
    "PUT /orgs/:org/blocks/:username": [OrgsBlockUserEndpoint, OrgsBlockUserRequestOptions];
    "DELETE /orgs/:org/blocks/:username": [OrgsUnblockUserEndpoint, OrgsUnblockUserRequestOptions];
    "GET /orgs/:org/hooks": [OrgsListHooksEndpoint, OrgsListHooksRequestOptions];
    "GET /orgs/:org/hooks/:hook_id": [OrgsGetHookEndpoint, OrgsGetHookRequestOptions];
    "POST /orgs/:org/hooks": [OrgsCreateHookEndpoint, OrgsCreateHookRequestOptions];
    "PATCH /orgs/:org/hooks/:hook_id": [OrgsUpdateHookEndpoint, OrgsUpdateHookRequestOptions];
    "POST /orgs/:org/hooks/:hook_id/pings": [OrgsPingHookEndpoint, OrgsPingHookRequestOptions];
    "DELETE /orgs/:org/hooks/:hook_id": [OrgsDeleteHookEndpoint, OrgsDeleteHookRequestOptions];
    "GET /orgs/:org/members": [OrgsListMembersEndpoint, OrgsListMembersRequestOptions];
    "GET /orgs/:org/members/:username": [OrgsCheckMembershipEndpoint, OrgsCheckMembershipRequestOptions];
    "DELETE /orgs/:org/members/:username": [OrgsRemoveMemberEndpoint, OrgsRemoveMemberRequestOptions];
    "GET /orgs/:org/public_members": [OrgsListPublicMembersEndpoint, OrgsListPublicMembersRequestOptions];
    "GET /orgs/:org/public_members/:username": [OrgsCheckPublicMembershipEndpoint, OrgsCheckPublicMembershipRequestOptions];
    "PUT /orgs/:org/public_members/:username": [OrgsPublicizeMembershipEndpoint, OrgsPublicizeMembershipRequestOptions];
    "DELETE /orgs/:org/public_members/:username": [OrgsConcealMembershipEndpoint, OrgsConcealMembershipRequestOptions];
    "GET /orgs/:org/memberships/:username": [OrgsGetMembershipEndpoint, OrgsGetMembershipRequestOptions];
    "PUT /orgs/:org/memberships/:username": [OrgsAddOrUpdateMembershipEndpoint, OrgsAddOrUpdateMembershipRequestOptions];
    "DELETE /orgs/:org/memberships/:username": [OrgsRemoveMembershipEndpoint, OrgsRemoveMembershipRequestOptions];
    "GET /orgs/:org/invitations/:invitation_id/teams": [OrgsListInvitationTeamsEndpoint, OrgsListInvitationTeamsRequestOptions];
    "GET /orgs/:org/invitations": [OrgsListPendingInvitationsEndpoint, OrgsListPendingInvitationsRequestOptions];
    "POST /orgs/:org/invitations": [OrgsCreateInvitationEndpoint, OrgsCreateInvitationRequestOptions];
    "GET /user/memberships/orgs": [OrgsListMembershipsEndpoint, OrgsListMembershipsRequestOptions];
    "GET /user/memberships/orgs/:org": [OrgsGetMembershipForAuthenticatedUserEndpoint, OrgsGetMembershipForAuthenticatedUserRequestOptions];
    "PATCH /user/memberships/orgs/:org": [OrgsUpdateMembershipEndpoint, OrgsUpdateMembershipRequestOptions];
    "GET /orgs/:org/outside_collaborators": [OrgsListOutsideCollaboratorsEndpoint, OrgsListOutsideCollaboratorsRequestOptions];
    "DELETE /orgs/:org/outside_collaborators/:username": [OrgsRemoveOutsideCollaboratorEndpoint, OrgsRemoveOutsideCollaboratorRequestOptions];
    "PUT /orgs/:org/outside_collaborators/:username": [OrgsConvertMemberToOutsideCollaboratorEndpoint, OrgsConvertMemberToOutsideCollaboratorRequestOptions];
    "GET /repos/:owner/:repo/projects": [ProjectsListForRepoEndpoint, ProjectsListForRepoRequestOptions];
    "GET /orgs/:org/projects": [ProjectsListForOrgEndpoint, ProjectsListForOrgRequestOptions];
    "GET /users/:username/projects": [ProjectsListForUserEndpoint, ProjectsListForUserRequestOptions];
    "GET /projects/:project_id": [ProjectsGetEndpoint, ProjectsGetRequestOptions];
    "POST /repos/:owner/:repo/projects": [ProjectsCreateForRepoEndpoint, ProjectsCreateForRepoRequestOptions];
    "POST /orgs/:org/projects": [ProjectsCreateForOrgEndpoint, ProjectsCreateForOrgRequestOptions];
    "POST /user/projects": [ProjectsCreateForAuthenticatedUserEndpoint, ProjectsCreateForAuthenticatedUserRequestOptions];
    "PATCH /projects/:project_id": [ProjectsUpdateEndpoint, ProjectsUpdateRequestOptions];
    "DELETE /projects/:project_id": [ProjectsDeleteEndpoint, ProjectsDeleteRequestOptions];
    "GET /projects/columns/:column_id/cards": [ProjectsListCardsEndpoint, ProjectsListCardsRequestOptions];
    "GET /projects/columns/cards/:card_id": [ProjectsGetCardEndpoint, ProjectsGetCardRequestOptions];
    "POST /projects/columns/:column_id/cards": [ProjectsCreateCardEndpoint, ProjectsCreateCardRequestOptions];
    "PATCH /projects/columns/cards/:card_id": [ProjectsUpdateCardEndpoint, ProjectsUpdateCardRequestOptions];
    "DELETE /projects/columns/cards/:card_id": [ProjectsDeleteCardEndpoint, ProjectsDeleteCardRequestOptions];
    "POST /projects/columns/cards/:card_id/moves": [ProjectsMoveCardEndpoint, ProjectsMoveCardRequestOptions];
    "GET /projects/:project_id/collaborators": [ProjectsListCollaboratorsEndpoint, ProjectsListCollaboratorsRequestOptions];
    "GET /projects/:project_id/collaborators/:username/permission": [ProjectsReviewUserPermissionLevelEndpoint, ProjectsReviewUserPermissionLevelRequestOptions];
    "PUT /projects/:project_id/collaborators/:username": [ProjectsAddCollaboratorEndpoint, ProjectsAddCollaboratorRequestOptions];
    "DELETE /projects/:project_id/collaborators/:username": [ProjectsRemoveCollaboratorEndpoint, ProjectsRemoveCollaboratorRequestOptions];
    "GET /projects/:project_id/columns": [ProjectsListColumnsEndpoint, ProjectsListColumnsRequestOptions];
    "GET /projects/columns/:column_id": [ProjectsGetColumnEndpoint, ProjectsGetColumnRequestOptions];
    "POST /projects/:project_id/columns": [ProjectsCreateColumnEndpoint, ProjectsCreateColumnRequestOptions];
    "PATCH /projects/columns/:column_id": [ProjectsUpdateColumnEndpoint, ProjectsUpdateColumnRequestOptions];
    "DELETE /projects/columns/:column_id": [ProjectsDeleteColumnEndpoint, ProjectsDeleteColumnRequestOptions];
    "POST /projects/columns/:column_id/moves": [ProjectsMoveColumnEndpoint, ProjectsMoveColumnRequestOptions];
    "GET /repos/:owner/:repo/pulls": [PullsListEndpoint, PullsListRequestOptions];
    "GET /repos/:owner/:repo/pulls/:pull_number": [PullsGetEndpoint, PullsGetRequestOptions];
    "POST /repos/:owner/:repo/pulls": [PullsCreateEndpoint | PullsCreateFromIssueEndpoint, PullsCreateRequestOptions | PullsCreateFromIssueRequestOptions];
    "PUT /repos/:owner/:repo/pulls/:pull_number/update-branch": [PullsUpdateBranchEndpoint, PullsUpdateBranchRequestOptions];
    "PATCH /repos/:owner/:repo/pulls/:pull_number": [PullsUpdateEndpoint, PullsUpdateRequestOptions];
    "GET /repos/:owner/:repo/pulls/:pull_number/commits": [PullsListCommitsEndpoint, PullsListCommitsRequestOptions];
    "GET /repos/:owner/:repo/pulls/:pull_number/files": [PullsListFilesEndpoint, PullsListFilesRequestOptions];
    "GET /repos/:owner/:repo/pulls/:pull_number/merge": [PullsCheckIfMergedEndpoint, PullsCheckIfMergedRequestOptions];
    "PUT /repos/:owner/:repo/pulls/:pull_number/merge": [PullsMergeEndpoint, PullsMergeRequestOptions];
    "GET /repos/:owner/:repo/pulls/:pull_number/comments": [PullsListCommentsEndpoint, PullsListCommentsRequestOptions];
    "GET /repos/:owner/:repo/pulls/comments": [PullsListCommentsForRepoEndpoint, PullsListCommentsForRepoRequestOptions];
    "GET /repos/:owner/:repo/pulls/comments/:comment_id": [PullsGetCommentEndpoint, PullsGetCommentRequestOptions];
    "POST /repos/:owner/:repo/pulls/:pull_number/comments": [PullsCreateCommentEndpoint | PullsCreateCommentReplyEndpoint, PullsCreateCommentRequestOptions | PullsCreateCommentReplyRequestOptions];
    "PATCH /repos/:owner/:repo/pulls/comments/:comment_id": [PullsUpdateCommentEndpoint, PullsUpdateCommentRequestOptions];
    "DELETE /repos/:owner/:repo/pulls/comments/:comment_id": [PullsDeleteCommentEndpoint, PullsDeleteCommentRequestOptions];
    "GET /repos/:owner/:repo/pulls/:pull_number/requested_reviewers": [PullsListReviewRequestsEndpoint, PullsListReviewRequestsRequestOptions];
    "POST /repos/:owner/:repo/pulls/:pull_number/requested_reviewers": [PullsCreateReviewRequestEndpoint, PullsCreateReviewRequestRequestOptions];
    "DELETE /repos/:owner/:repo/pulls/:pull_number/requested_reviewers": [PullsDeleteReviewRequestEndpoint, PullsDeleteReviewRequestRequestOptions];
    "GET /repos/:owner/:repo/pulls/:pull_number/reviews": [PullsListReviewsEndpoint, PullsListReviewsRequestOptions];
    "GET /repos/:owner/:repo/pulls/:pull_number/reviews/:review_id": [PullsGetReviewEndpoint, PullsGetReviewRequestOptions];
    "DELETE /repos/:owner/:repo/pulls/:pull_number/reviews/:review_id": [PullsDeletePendingReviewEndpoint, PullsDeletePendingReviewRequestOptions];
    "GET /repos/:owner/:repo/pulls/:pull_number/reviews/:review_id/comments": [PullsGetCommentsForReviewEndpoint, PullsGetCommentsForReviewRequestOptions];
    "POST /repos/:owner/:repo/pulls/:pull_number/reviews": [PullsCreateReviewEndpoint, PullsCreateReviewRequestOptions];
    "PUT /repos/:owner/:repo/pulls/:pull_number/reviews/:review_id": [PullsUpdateReviewEndpoint, PullsUpdateReviewRequestOptions];
    "POST /repos/:owner/:repo/pulls/:pull_number/reviews/:review_id/events": [PullsSubmitReviewEndpoint, PullsSubmitReviewRequestOptions];
    "PUT /repos/:owner/:repo/pulls/:pull_number/reviews/:review_id/dismissals": [PullsDismissReviewEndpoint, PullsDismissReviewRequestOptions];
    "GET /rate_limit": [RateLimitGetEndpoint, RateLimitGetRequestOptions];
    "GET /repos/:owner/:repo/comments/:comment_id/reactions": [ReactionsListForCommitCommentEndpoint, ReactionsListForCommitCommentRequestOptions];
    "POST /repos/:owner/:repo/comments/:comment_id/reactions": [ReactionsCreateForCommitCommentEndpoint, ReactionsCreateForCommitCommentRequestOptions];
    "GET /repos/:owner/:repo/issues/:issue_number/reactions": [ReactionsListForIssueEndpoint, ReactionsListForIssueRequestOptions];
    "POST /repos/:owner/:repo/issues/:issue_number/reactions": [ReactionsCreateForIssueEndpoint, ReactionsCreateForIssueRequestOptions];
    "GET /repos/:owner/:repo/issues/comments/:comment_id/reactions": [ReactionsListForIssueCommentEndpoint, ReactionsListForIssueCommentRequestOptions];
    "POST /repos/:owner/:repo/issues/comments/:comment_id/reactions": [ReactionsCreateForIssueCommentEndpoint, ReactionsCreateForIssueCommentRequestOptions];
    "GET /repos/:owner/:repo/pulls/comments/:comment_id/reactions": [ReactionsListForPullRequestReviewCommentEndpoint, ReactionsListForPullRequestReviewCommentRequestOptions];
    "POST /repos/:owner/:repo/pulls/comments/:comment_id/reactions": [ReactionsCreateForPullRequestReviewCommentEndpoint, ReactionsCreateForPullRequestReviewCommentRequestOptions];
    "GET /teams/:team_id/discussions/:discussion_number/reactions": [ReactionsListForTeamDiscussionEndpoint, ReactionsListForTeamDiscussionRequestOptions];
    "POST /teams/:team_id/discussions/:discussion_number/reactions": [ReactionsCreateForTeamDiscussionEndpoint, ReactionsCreateForTeamDiscussionRequestOptions];
    "GET /teams/:team_id/discussions/:discussion_number/comments/:comment_number/reactions": [ReactionsListForTeamDiscussionCommentEndpoint, ReactionsListForTeamDiscussionCommentRequestOptions];
    "POST /teams/:team_id/discussions/:discussion_number/comments/:comment_number/reactions": [ReactionsCreateForTeamDiscussionCommentEndpoint, ReactionsCreateForTeamDiscussionCommentRequestOptions];
    "DELETE /reactions/:reaction_id": [ReactionsDeleteEndpoint, ReactionsDeleteRequestOptions];
    "GET /user/repos": [ReposListEndpoint, ReposListRequestOptions];
    "GET /users/:username/repos": [ReposListForUserEndpoint, ReposListForUserRequestOptions];
    "GET /orgs/:org/repos": [ReposListForOrgEndpoint, ReposListForOrgRequestOptions];
    "GET /repositories": [ReposListPublicEndpoint, ReposListPublicRequestOptions];
    "POST /user/repos": [ReposCreateForAuthenticatedUserEndpoint, ReposCreateForAuthenticatedUserRequestOptions];
    "POST /orgs/:org/repos": [ReposCreateInOrgEndpoint, ReposCreateInOrgRequestOptions];
    "POST /repos/:template_owner/:template_repo/generate": [ReposCreateUsingTemplateEndpoint, ReposCreateUsingTemplateRequestOptions];
    "GET /repos/:owner/:repo": [ReposGetEndpoint, ReposGetRequestOptions];
    "PATCH /repos/:owner/:repo": [ReposUpdateEndpoint, ReposUpdateRequestOptions];
    "GET /repos/:owner/:repo/topics": [ReposListTopicsEndpoint, ReposListTopicsRequestOptions];
    "PUT /repos/:owner/:repo/topics": [ReposReplaceTopicsEndpoint, ReposReplaceTopicsRequestOptions];
    "GET /repos/:owner/:repo/vulnerability-alerts": [ReposCheckVulnerabilityAlertsEndpoint, ReposCheckVulnerabilityAlertsRequestOptions];
    "PUT /repos/:owner/:repo/vulnerability-alerts": [ReposEnableVulnerabilityAlertsEndpoint, ReposEnableVulnerabilityAlertsRequestOptions];
    "DELETE /repos/:owner/:repo/vulnerability-alerts": [ReposDisableVulnerabilityAlertsEndpoint, ReposDisableVulnerabilityAlertsRequestOptions];
    "PUT /repos/:owner/:repo/automated-security-fixes": [ReposEnableAutomatedSecurityFixesEndpoint, ReposEnableAutomatedSecurityFixesRequestOptions];
    "DELETE /repos/:owner/:repo/automated-security-fixes": [ReposDisableAutomatedSecurityFixesEndpoint, ReposDisableAutomatedSecurityFixesRequestOptions];
    "GET /repos/:owner/:repo/contributors": [ReposListContributorsEndpoint, ReposListContributorsRequestOptions];
    "GET /repos/:owner/:repo/languages": [ReposListLanguagesEndpoint, ReposListLanguagesRequestOptions];
    "GET /repos/:owner/:repo/teams": [ReposListTeamsEndpoint, ReposListTeamsRequestOptions];
    "GET /repos/:owner/:repo/tags": [ReposListTagsEndpoint, ReposListTagsRequestOptions];
    "DELETE /repos/:owner/:repo": [ReposDeleteEndpoint, ReposDeleteRequestOptions];
    "POST /repos/:owner/:repo/transfer": [ReposTransferEndpoint, ReposTransferRequestOptions];
    "GET /repos/:owner/:repo/branches": [ReposListBranchesEndpoint, ReposListBranchesRequestOptions];
    "GET /repos/:owner/:repo/branches/:branch": [ReposGetBranchEndpoint, ReposGetBranchRequestOptions];
    "GET /repos/:owner/:repo/branches/:branch/protection": [ReposGetBranchProtectionEndpoint, ReposGetBranchProtectionRequestOptions];
    "PUT /repos/:owner/:repo/branches/:branch/protection": [ReposUpdateBranchProtectionEndpoint, ReposUpdateBranchProtectionRequestOptions];
    "DELETE /repos/:owner/:repo/branches/:branch/protection": [ReposRemoveBranchProtectionEndpoint, ReposRemoveBranchProtectionRequestOptions];
    "GET /repos/:owner/:repo/branches/:branch/protection/required_status_checks": [ReposGetProtectedBranchRequiredStatusChecksEndpoint, ReposGetProtectedBranchRequiredStatusChecksRequestOptions];
    "PATCH /repos/:owner/:repo/branches/:branch/protection/required_status_checks": [ReposUpdateProtectedBranchRequiredStatusChecksEndpoint, ReposUpdateProtectedBranchRequiredStatusChecksRequestOptions];
    "DELETE /repos/:owner/:repo/branches/:branch/protection/required_status_checks": [ReposRemoveProtectedBranchRequiredStatusChecksEndpoint, ReposRemoveProtectedBranchRequiredStatusChecksRequestOptions];
    "GET /repos/:owner/:repo/branches/:branch/protection/required_status_checks/contexts": [ReposListProtectedBranchRequiredStatusChecksContextsEndpoint, ReposListProtectedBranchRequiredStatusChecksContextsRequestOptions];
    "PUT /repos/:owner/:repo/branches/:branch/protection/required_status_checks/contexts": [ReposReplaceProtectedBranchRequiredStatusChecksContextsEndpoint, ReposReplaceProtectedBranchRequiredStatusChecksContextsRequestOptions];
    "POST /repos/:owner/:repo/branches/:branch/protection/required_status_checks/contexts": [ReposAddProtectedBranchRequiredStatusChecksContextsEndpoint, ReposAddProtectedBranchRequiredStatusChecksContextsRequestOptions];
    "DELETE /repos/:owner/:repo/branches/:branch/protection/required_status_checks/contexts": [ReposRemoveProtectedBranchRequiredStatusChecksContextsEndpoint, ReposRemoveProtectedBranchRequiredStatusChecksContextsRequestOptions];
    "GET /repos/:owner/:repo/branches/:branch/protection/required_pull_request_reviews": [ReposGetProtectedBranchPullRequestReviewEnforcementEndpoint, ReposGetProtectedBranchPullRequestReviewEnforcementRequestOptions];
    "PATCH /repos/:owner/:repo/branches/:branch/protection/required_pull_request_reviews": [ReposUpdateProtectedBranchPullRequestReviewEnforcementEndpoint, ReposUpdateProtectedBranchPullRequestReviewEnforcementRequestOptions];
    "DELETE /repos/:owner/:repo/branches/:branch/protection/required_pull_request_reviews": [ReposRemoveProtectedBranchPullRequestReviewEnforcementEndpoint, ReposRemoveProtectedBranchPullRequestReviewEnforcementRequestOptions];
    "GET /repos/:owner/:repo/branches/:branch/protection/required_signatures": [ReposGetProtectedBranchRequiredSignaturesEndpoint, ReposGetProtectedBranchRequiredSignaturesRequestOptions];
    "POST /repos/:owner/:repo/branches/:branch/protection/required_signatures": [ReposAddProtectedBranchRequiredSignaturesEndpoint, ReposAddProtectedBranchRequiredSignaturesRequestOptions];
    "DELETE /repos/:owner/:repo/branches/:branch/protection/required_signatures": [ReposRemoveProtectedBranchRequiredSignaturesEndpoint, ReposRemoveProtectedBranchRequiredSignaturesRequestOptions];
    "GET /repos/:owner/:repo/branches/:branch/protection/enforce_admins": [ReposGetProtectedBranchAdminEnforcementEndpoint, ReposGetProtectedBranchAdminEnforcementRequestOptions];
    "POST /repos/:owner/:repo/branches/:branch/protection/enforce_admins": [ReposAddProtectedBranchAdminEnforcementEndpoint, ReposAddProtectedBranchAdminEnforcementRequestOptions];
    "DELETE /repos/:owner/:repo/branches/:branch/protection/enforce_admins": [ReposRemoveProtectedBranchAdminEnforcementEndpoint, ReposRemoveProtectedBranchAdminEnforcementRequestOptions];
    "GET /repos/:owner/:repo/branches/:branch/protection/restrictions": [ReposGetProtectedBranchRestrictionsEndpoint, ReposGetProtectedBranchRestrictionsRequestOptions];
    "DELETE /repos/:owner/:repo/branches/:branch/protection/restrictions": [ReposRemoveProtectedBranchRestrictionsEndpoint, ReposRemoveProtectedBranchRestrictionsRequestOptions];
    "GET /repos/:owner/:repo/branches/:branch/protection/restrictions/teams": [ReposListProtectedBranchTeamRestrictionsEndpoint, ReposListProtectedBranchTeamRestrictionsRequestOptions];
    "PUT /repos/:owner/:repo/branches/:branch/protection/restrictions/teams": [ReposReplaceProtectedBranchTeamRestrictionsEndpoint, ReposReplaceProtectedBranchTeamRestrictionsRequestOptions];
    "POST /repos/:owner/:repo/branches/:branch/protection/restrictions/teams": [ReposAddProtectedBranchTeamRestrictionsEndpoint, ReposAddProtectedBranchTeamRestrictionsRequestOptions];
    "DELETE /repos/:owner/:repo/branches/:branch/protection/restrictions/teams": [ReposRemoveProtectedBranchTeamRestrictionsEndpoint, ReposRemoveProtectedBranchTeamRestrictionsRequestOptions];
    "GET /repos/:owner/:repo/branches/:branch/protection/restrictions/users": [ReposListProtectedBranchUserRestrictionsEndpoint, ReposListProtectedBranchUserRestrictionsRequestOptions];
    "PUT /repos/:owner/:repo/branches/:branch/protection/restrictions/users": [ReposReplaceProtectedBranchUserRestrictionsEndpoint, ReposReplaceProtectedBranchUserRestrictionsRequestOptions];
    "POST /repos/:owner/:repo/branches/:branch/protection/restrictions/users": [ReposAddProtectedBranchUserRestrictionsEndpoint, ReposAddProtectedBranchUserRestrictionsRequestOptions];
    "DELETE /repos/:owner/:repo/branches/:branch/protection/restrictions/users": [ReposRemoveProtectedBranchUserRestrictionsEndpoint, ReposRemoveProtectedBranchUserRestrictionsRequestOptions];
    "GET /repos/:owner/:repo/collaborators": [ReposListCollaboratorsEndpoint, ReposListCollaboratorsRequestOptions];
    "GET /repos/:owner/:repo/collaborators/:username": [ReposCheckCollaboratorEndpoint, ReposCheckCollaboratorRequestOptions];
    "GET /repos/:owner/:repo/collaborators/:username/permission": [ReposGetCollaboratorPermissionLevelEndpoint, ReposGetCollaboratorPermissionLevelRequestOptions];
    "PUT /repos/:owner/:repo/collaborators/:username": [ReposAddCollaboratorEndpoint, ReposAddCollaboratorRequestOptions];
    "DELETE /repos/:owner/:repo/collaborators/:username": [ReposRemoveCollaboratorEndpoint, ReposRemoveCollaboratorRequestOptions];
    "GET /repos/:owner/:repo/comments": [ReposListCommitCommentsEndpoint, ReposListCommitCommentsRequestOptions];
    "GET /repos/:owner/:repo/commits/:commit_sha/comments": [ReposListCommentsForCommitEndpoint, ReposListCommentsForCommitRequestOptions];
    "POST /repos/:owner/:repo/commits/:commit_sha/comments": [ReposCreateCommitCommentEndpoint, ReposCreateCommitCommentRequestOptions];
    "GET /repos/:owner/:repo/comments/:comment_id": [ReposGetCommitCommentEndpoint, ReposGetCommitCommentRequestOptions];
    "PATCH /repos/:owner/:repo/comments/:comment_id": [ReposUpdateCommitCommentEndpoint, ReposUpdateCommitCommentRequestOptions];
    "DELETE /repos/:owner/:repo/comments/:comment_id": [ReposDeleteCommitCommentEndpoint, ReposDeleteCommitCommentRequestOptions];
    "GET /repos/:owner/:repo/commits": [ReposListCommitsEndpoint, ReposListCommitsRequestOptions];
    "GET /repos/:owner/:repo/commits/:ref": [ReposGetCommitEndpoint | ReposGetCommitRefShaEndpoint, ReposGetCommitRequestOptions | ReposGetCommitRefShaRequestOptions];
    "GET /repos/:owner/:repo/compare/:base...:head": [ReposCompareCommitsEndpoint, ReposCompareCommitsRequestOptions];
    "GET /repos/:owner/:repo/commits/:commit_sha/branches-where-head": [ReposListBranchesForHeadCommitEndpoint, ReposListBranchesForHeadCommitRequestOptions];
    "GET /repos/:owner/:repo/commits/:commit_sha/pulls": [ReposListPullRequestsAssociatedWithCommitEndpoint, ReposListPullRequestsAssociatedWithCommitRequestOptions];
    "GET /repos/:owner/:repo/community/profile": [ReposRetrieveCommunityProfileMetricsEndpoint, ReposRetrieveCommunityProfileMetricsRequestOptions];
    "GET /repos/:owner/:repo/readme": [ReposGetReadmeEndpoint, ReposGetReadmeRequestOptions];
    "GET /repos/:owner/:repo/contents/:path": [ReposGetContentsEndpoint, ReposGetContentsRequestOptions];
    "PUT /repos/:owner/:repo/contents/:path": [ReposCreateOrUpdateFileEndpoint | ReposCreateFileEndpoint | ReposUpdateFileEndpoint, ReposCreateOrUpdateFileRequestOptions | ReposCreateFileRequestOptions | ReposUpdateFileRequestOptions];
    "DELETE /repos/:owner/:repo/contents/:path": [ReposDeleteFileEndpoint, ReposDeleteFileRequestOptions];
    "GET /repos/:owner/:repo/:archive_format/:ref": [ReposGetArchiveLinkEndpoint, ReposGetArchiveLinkRequestOptions];
    "GET /repos/:owner/:repo/deployments": [ReposListDeploymentsEndpoint, ReposListDeploymentsRequestOptions];
    "GET /repos/:owner/:repo/deployments/:deployment_id": [ReposGetDeploymentEndpoint, ReposGetDeploymentRequestOptions];
    "POST /repos/:owner/:repo/deployments": [ReposCreateDeploymentEndpoint, ReposCreateDeploymentRequestOptions];
    "GET /repos/:owner/:repo/deployments/:deployment_id/statuses": [ReposListDeploymentStatusesEndpoint, ReposListDeploymentStatusesRequestOptions];
    "GET /repos/:owner/:repo/deployments/:deployment_id/statuses/:status_id": [ReposGetDeploymentStatusEndpoint, ReposGetDeploymentStatusRequestOptions];
    "POST /repos/:owner/:repo/deployments/:deployment_id/statuses": [ReposCreateDeploymentStatusEndpoint, ReposCreateDeploymentStatusRequestOptions];
    "GET /repos/:owner/:repo/downloads": [ReposListDownloadsEndpoint, ReposListDownloadsRequestOptions];
    "GET /repos/:owner/:repo/downloads/:download_id": [ReposGetDownloadEndpoint, ReposGetDownloadRequestOptions];
    "DELETE /repos/:owner/:repo/downloads/:download_id": [ReposDeleteDownloadEndpoint, ReposDeleteDownloadRequestOptions];
    "GET /repos/:owner/:repo/forks": [ReposListForksEndpoint, ReposListForksRequestOptions];
    "POST /repos/:owner/:repo/forks": [ReposCreateForkEndpoint, ReposCreateForkRequestOptions];
    "GET /repos/:owner/:repo/hooks": [ReposListHooksEndpoint, ReposListHooksRequestOptions];
    "GET /repos/:owner/:repo/hooks/:hook_id": [ReposGetHookEndpoint, ReposGetHookRequestOptions];
    "POST /repos/:owner/:repo/hooks": [ReposCreateHookEndpoint, ReposCreateHookRequestOptions];
    "PATCH /repos/:owner/:repo/hooks/:hook_id": [ReposUpdateHookEndpoint, ReposUpdateHookRequestOptions];
    "POST /repos/:owner/:repo/hooks/:hook_id/tests": [ReposTestPushHookEndpoint, ReposTestPushHookRequestOptions];
    "POST /repos/:owner/:repo/hooks/:hook_id/pings": [ReposPingHookEndpoint, ReposPingHookRequestOptions];
    "DELETE /repos/:owner/:repo/hooks/:hook_id": [ReposDeleteHookEndpoint, ReposDeleteHookRequestOptions];
    "GET /repos/:owner/:repo/invitations": [ReposListInvitationsEndpoint, ReposListInvitationsRequestOptions];
    "DELETE /repos/:owner/:repo/invitations/:invitation_id": [ReposDeleteInvitationEndpoint, ReposDeleteInvitationRequestOptions];
    "PATCH /repos/:owner/:repo/invitations/:invitation_id": [ReposUpdateInvitationEndpoint, ReposUpdateInvitationRequestOptions];
    "GET /user/repository_invitations": [ReposListInvitationsForAuthenticatedUserEndpoint, ReposListInvitationsForAuthenticatedUserRequestOptions];
    "PATCH /user/repository_invitations/:invitation_id": [ReposAcceptInvitationEndpoint, ReposAcceptInvitationRequestOptions];
    "DELETE /user/repository_invitations/:invitation_id": [ReposDeclineInvitationEndpoint, ReposDeclineInvitationRequestOptions];
    "GET /repos/:owner/:repo/keys": [ReposListDeployKeysEndpoint, ReposListDeployKeysRequestOptions];
    "GET /repos/:owner/:repo/keys/:key_id": [ReposGetDeployKeyEndpoint, ReposGetDeployKeyRequestOptions];
    "POST /repos/:owner/:repo/keys": [ReposAddDeployKeyEndpoint, ReposAddDeployKeyRequestOptions];
    "DELETE /repos/:owner/:repo/keys/:key_id": [ReposRemoveDeployKeyEndpoint, ReposRemoveDeployKeyRequestOptions];
    "POST /repos/:owner/:repo/merges": [ReposMergeEndpoint, ReposMergeRequestOptions];
    "GET /repos/:owner/:repo/pages": [ReposGetPagesEndpoint, ReposGetPagesRequestOptions];
    "POST /repos/:owner/:repo/pages": [ReposEnablePagesSiteEndpoint, ReposEnablePagesSiteRequestOptions];
    "DELETE /repos/:owner/:repo/pages": [ReposDisablePagesSiteEndpoint, ReposDisablePagesSiteRequestOptions];
    "PUT /repos/:owner/:repo/pages": [ReposUpdateInformationAboutPagesSiteEndpoint, ReposUpdateInformationAboutPagesSiteRequestOptions];
    "POST /repos/:owner/:repo/pages/builds": [ReposRequestPageBuildEndpoint, ReposRequestPageBuildRequestOptions];
    "GET /repos/:owner/:repo/pages/builds": [ReposListPagesBuildsEndpoint, ReposListPagesBuildsRequestOptions];
    "GET /repos/:owner/:repo/pages/builds/latest": [ReposGetLatestPagesBuildEndpoint, ReposGetLatestPagesBuildRequestOptions];
    "GET /repos/:owner/:repo/pages/builds/:build_id": [ReposGetPagesBuildEndpoint, ReposGetPagesBuildRequestOptions];
    "GET /repos/:owner/:repo/releases": [ReposListReleasesEndpoint, ReposListReleasesRequestOptions];
    "GET /repos/:owner/:repo/releases/:release_id": [ReposGetReleaseEndpoint, ReposGetReleaseRequestOptions];
    "GET /repos/:owner/:repo/releases/latest": [ReposGetLatestReleaseEndpoint, ReposGetLatestReleaseRequestOptions];
    "GET /repos/:owner/:repo/releases/tags/:tag": [ReposGetReleaseByTagEndpoint, ReposGetReleaseByTagRequestOptions];
    "POST /repos/:owner/:repo/releases": [ReposCreateReleaseEndpoint, ReposCreateReleaseRequestOptions];
    "PATCH /repos/:owner/:repo/releases/:release_id": [ReposUpdateReleaseEndpoint, ReposUpdateReleaseRequestOptions];
    "DELETE /repos/:owner/:repo/releases/:release_id": [ReposDeleteReleaseEndpoint, ReposDeleteReleaseRequestOptions];
    "GET /repos/:owner/:repo/releases/:release_id/assets": [ReposListAssetsForReleaseEndpoint, ReposListAssetsForReleaseRequestOptions];
    "POST :url": [ReposUploadReleaseAssetEndpoint, ReposUploadReleaseAssetRequestOptions];
    "GET /repos/:owner/:repo/releases/assets/:asset_id": [ReposGetReleaseAssetEndpoint, ReposGetReleaseAssetRequestOptions];
    "PATCH /repos/:owner/:repo/releases/assets/:asset_id": [ReposUpdateReleaseAssetEndpoint, ReposUpdateReleaseAssetRequestOptions];
    "DELETE /repos/:owner/:repo/releases/assets/:asset_id": [ReposDeleteReleaseAssetEndpoint, ReposDeleteReleaseAssetRequestOptions];
    "GET /repos/:owner/:repo/stats/contributors": [ReposGetContributorsStatsEndpoint, ReposGetContributorsStatsRequestOptions];
    "GET /repos/:owner/:repo/stats/commit_activity": [ReposGetCommitActivityStatsEndpoint, ReposGetCommitActivityStatsRequestOptions];
    "GET /repos/:owner/:repo/stats/code_frequency": [ReposGetCodeFrequencyStatsEndpoint, ReposGetCodeFrequencyStatsRequestOptions];
    "GET /repos/:owner/:repo/stats/participation": [ReposGetParticipationStatsEndpoint, ReposGetParticipationStatsRequestOptions];
    "GET /repos/:owner/:repo/stats/punch_card": [ReposGetPunchCardStatsEndpoint, ReposGetPunchCardStatsRequestOptions];
    "POST /repos/:owner/:repo/statuses/:sha": [ReposCreateStatusEndpoint, ReposCreateStatusRequestOptions];
    "GET /repos/:owner/:repo/commits/:ref/statuses": [ReposListStatusesForRefEndpoint, ReposListStatusesForRefRequestOptions];
    "GET /repos/:owner/:repo/commits/:ref/status": [ReposGetCombinedStatusForRefEndpoint, ReposGetCombinedStatusForRefRequestOptions];
    "GET /repos/:owner/:repo/traffic/popular/referrers": [ReposGetTopReferrersEndpoint, ReposGetTopReferrersRequestOptions];
    "GET /repos/:owner/:repo/traffic/popular/paths": [ReposGetTopPathsEndpoint, ReposGetTopPathsRequestOptions];
    "GET /repos/:owner/:repo/traffic/views": [ReposGetViewsEndpoint, ReposGetViewsRequestOptions];
    "GET /repos/:owner/:repo/traffic/clones": [ReposGetClonesEndpoint, ReposGetClonesRequestOptions];
    "GET /scim/v2/organizations/:org/Users": [ScimListProvisionedIdentitiesEndpoint, ScimListProvisionedIdentitiesRequestOptions];
    "GET /scim/v2/organizations/:org/Users/:scim_user_id": [ScimGetProvisioningDetailsForUserEndpoint, ScimGetProvisioningDetailsForUserRequestOptions];
    "POST /scim/v2/organizations/:org/Users": [ScimProvisionAndInviteUsersEndpoint | ScimProvisionInviteUsersEndpoint, ScimProvisionAndInviteUsersRequestOptions | ScimProvisionInviteUsersRequestOptions];
    "PUT /scim/v2/organizations/:org/Users/:scim_user_id": [ScimReplaceProvisionedUserInformationEndpoint | ScimUpdateProvisionedOrgMembershipEndpoint, ScimReplaceProvisionedUserInformationRequestOptions | ScimUpdateProvisionedOrgMembershipRequestOptions];
    "PATCH /scim/v2/organizations/:org/Users/:scim_user_id": [ScimUpdateUserAttributeEndpoint, ScimUpdateUserAttributeRequestOptions];
    "DELETE /scim/v2/organizations/:org/Users/:scim_user_id": [ScimRemoveUserFromOrgEndpoint, ScimRemoveUserFromOrgRequestOptions];
    "GET /search/repositories": [SearchReposEndpoint, SearchReposRequestOptions];
    "GET /search/commits": [SearchCommitsEndpoint, SearchCommitsRequestOptions];
    "GET /search/code": [SearchCodeEndpoint, SearchCodeRequestOptions];
    "GET /search/issues": [SearchIssuesAndPullRequestsEndpoint | SearchIssuesEndpoint, SearchIssuesAndPullRequestsRequestOptions | SearchIssuesRequestOptions];
    "GET /search/users": [SearchUsersEndpoint, SearchUsersRequestOptions];
    "GET /search/topics": [SearchTopicsEndpoint, SearchTopicsRequestOptions];
    "GET /search/labels": [SearchLabelsEndpoint, SearchLabelsRequestOptions];
    "GET /legacy/issues/search/:owner/:repository/:state/:keyword": [SearchIssuesLegacyEndpoint, SearchIssuesLegacyRequestOptions];
    "GET /legacy/repos/search/:keyword": [SearchReposLegacyEndpoint, SearchReposLegacyRequestOptions];
    "GET /legacy/user/search/:keyword": [SearchUsersLegacyEndpoint, SearchUsersLegacyRequestOptions];
    "GET /legacy/user/email/:email": [SearchEmailLegacyEndpoint, SearchEmailLegacyRequestOptions];
    "GET /orgs/:org/teams": [TeamsListEndpoint, TeamsListRequestOptions];
    "GET /teams/:team_id": [TeamsGetEndpoint, TeamsGetRequestOptions];
    "GET /orgs/:org/teams/:team_slug": [TeamsGetByNameEndpoint, TeamsGetByNameRequestOptions];
    "POST /orgs/:org/teams": [TeamsCreateEndpoint, TeamsCreateRequestOptions];
    "PATCH /teams/:team_id": [TeamsUpdateEndpoint, TeamsUpdateRequestOptions];
    "DELETE /teams/:team_id": [TeamsDeleteEndpoint, TeamsDeleteRequestOptions];
    "GET /teams/:team_id/teams": [TeamsListChildEndpoint, TeamsListChildRequestOptions];
    "GET /teams/:team_id/repos": [TeamsListReposEndpoint, TeamsListReposRequestOptions];
    "GET /teams/:team_id/repos/:owner/:repo": [TeamsCheckManagesRepoEndpoint, TeamsCheckManagesRepoRequestOptions];
    "PUT /teams/:team_id/repos/:owner/:repo": [TeamsAddOrUpdateRepoEndpoint, TeamsAddOrUpdateRepoRequestOptions];
    "DELETE /teams/:team_id/repos/:owner/:repo": [TeamsRemoveRepoEndpoint, TeamsRemoveRepoRequestOptions];
    "GET /user/teams": [TeamsListForAuthenticatedUserEndpoint, TeamsListForAuthenticatedUserRequestOptions];
    "GET /teams/:team_id/projects": [TeamsListProjectsEndpoint, TeamsListProjectsRequestOptions];
    "GET /teams/:team_id/projects/:project_id": [TeamsReviewProjectEndpoint, TeamsReviewProjectRequestOptions];
    "PUT /teams/:team_id/projects/:project_id": [TeamsAddOrUpdateProjectEndpoint, TeamsAddOrUpdateProjectRequestOptions];
    "DELETE /teams/:team_id/projects/:project_id": [TeamsRemoveProjectEndpoint, TeamsRemoveProjectRequestOptions];
    "GET /teams/:team_id/discussions/:discussion_number/comments": [TeamsListDiscussionCommentsEndpoint, TeamsListDiscussionCommentsRequestOptions];
    "GET /teams/:team_id/discussions/:discussion_number/comments/:comment_number": [TeamsGetDiscussionCommentEndpoint, TeamsGetDiscussionCommentRequestOptions];
    "POST /teams/:team_id/discussions/:discussion_number/comments": [TeamsCreateDiscussionCommentEndpoint, TeamsCreateDiscussionCommentRequestOptions];
    "PATCH /teams/:team_id/discussions/:discussion_number/comments/:comment_number": [TeamsUpdateDiscussionCommentEndpoint, TeamsUpdateDiscussionCommentRequestOptions];
    "DELETE /teams/:team_id/discussions/:discussion_number/comments/:comment_number": [TeamsDeleteDiscussionCommentEndpoint, TeamsDeleteDiscussionCommentRequestOptions];
    "GET /teams/:team_id/discussions": [TeamsListDiscussionsEndpoint, TeamsListDiscussionsRequestOptions];
    "GET /teams/:team_id/discussions/:discussion_number": [TeamsGetDiscussionEndpoint, TeamsGetDiscussionRequestOptions];
    "POST /teams/:team_id/discussions": [TeamsCreateDiscussionEndpoint, TeamsCreateDiscussionRequestOptions];
    "PATCH /teams/:team_id/discussions/:discussion_number": [TeamsUpdateDiscussionEndpoint, TeamsUpdateDiscussionRequestOptions];
    "DELETE /teams/:team_id/discussions/:discussion_number": [TeamsDeleteDiscussionEndpoint, TeamsDeleteDiscussionRequestOptions];
    "GET /teams/:team_id/members": [TeamsListMembersEndpoint, TeamsListMembersRequestOptions];
    "GET /teams/:team_id/members/:username": [TeamsGetMemberEndpoint, TeamsGetMemberRequestOptions];
    "PUT /teams/:team_id/members/:username": [TeamsAddMemberEndpoint, TeamsAddMemberRequestOptions];
    "DELETE /teams/:team_id/members/:username": [TeamsRemoveMemberEndpoint, TeamsRemoveMemberRequestOptions];
    "GET /teams/:team_id/memberships/:username": [TeamsGetMembershipEndpoint, TeamsGetMembershipRequestOptions];
    "PUT /teams/:team_id/memberships/:username": [TeamsAddOrUpdateMembershipEndpoint, TeamsAddOrUpdateMembershipRequestOptions];
    "DELETE /teams/:team_id/memberships/:username": [TeamsRemoveMembershipEndpoint, TeamsRemoveMembershipRequestOptions];
    "GET /teams/:team_id/invitations": [TeamsListPendingInvitationsEndpoint, TeamsListPendingInvitationsRequestOptions];
    "GET /orgs/:org/team-sync/groups": [TeamsListIdPGroupsForOrgEndpoint, TeamsListIdPGroupsForOrgRequestOptions];
    "GET /teams/:team_id/team-sync/group-mappings": [TeamsListIdPGroupsEndpoint, TeamsListIdPGroupsRequestOptions];
    "PATCH /teams/:team_id/team-sync/group-mappings": [TeamsCreateOrUpdateIdPGroupConnectionsEndpoint, TeamsCreateOrUpdateIdPGroupConnectionsRequestOptions];
    "GET /users/:username": [UsersGetByUsernameEndpoint, UsersGetByUsernameRequestOptions];
    "GET /user": [UsersGetAuthenticatedEndpoint, UsersGetAuthenticatedRequestOptions];
    "PATCH /user": [UsersUpdateAuthenticatedEndpoint, UsersUpdateAuthenticatedRequestOptions];
    "GET /users/:username/hovercard": [UsersGetContextForUserEndpoint, UsersGetContextForUserRequestOptions];
    "GET /users": [UsersListEndpoint, UsersListRequestOptions];
    "GET /user/blocks": [UsersListBlockedEndpoint, UsersListBlockedRequestOptions];
    "GET /user/blocks/:username": [UsersCheckBlockedEndpoint, UsersCheckBlockedRequestOptions];
    "PUT /user/blocks/:username": [UsersBlockEndpoint, UsersBlockRequestOptions];
    "DELETE /user/blocks/:username": [UsersUnblockEndpoint, UsersUnblockRequestOptions];
    "GET /user/emails": [UsersListEmailsEndpoint, UsersListEmailsRequestOptions];
    "GET /user/public_emails": [UsersListPublicEmailsEndpoint, UsersListPublicEmailsRequestOptions];
    "POST /user/emails": [UsersAddEmailsEndpoint, UsersAddEmailsRequestOptions];
    "DELETE /user/emails": [UsersDeleteEmailsEndpoint, UsersDeleteEmailsRequestOptions];
    "PATCH /user/email/visibility": [UsersTogglePrimaryEmailVisibilityEndpoint, UsersTogglePrimaryEmailVisibilityRequestOptions];
    "GET /users/:username/followers": [UsersListFollowersForUserEndpoint, UsersListFollowersForUserRequestOptions];
    "GET /user/followers": [UsersListFollowersForAuthenticatedUserEndpoint, UsersListFollowersForAuthenticatedUserRequestOptions];
    "GET /users/:username/following": [UsersListFollowingForUserEndpoint, UsersListFollowingForUserRequestOptions];
    "GET /user/following": [UsersListFollowingForAuthenticatedUserEndpoint, UsersListFollowingForAuthenticatedUserRequestOptions];
    "GET /user/following/:username": [UsersCheckFollowingEndpoint, UsersCheckFollowingRequestOptions];
    "GET /users/:username/following/:target_user": [UsersCheckFollowingForUserEndpoint, UsersCheckFollowingForUserRequestOptions];
    "PUT /user/following/:username": [UsersFollowEndpoint, UsersFollowRequestOptions];
    "DELETE /user/following/:username": [UsersUnfollowEndpoint, UsersUnfollowRequestOptions];
    "GET /users/:username/gpg_keys": [UsersListGpgKeysForUserEndpoint, UsersListGpgKeysForUserRequestOptions];
    "GET /user/gpg_keys": [UsersListGpgKeysEndpoint, UsersListGpgKeysRequestOptions];
    "GET /user/gpg_keys/:gpg_key_id": [UsersGetGpgKeyEndpoint, UsersGetGpgKeyRequestOptions];
    "POST /user/gpg_keys": [UsersCreateGpgKeyEndpoint, UsersCreateGpgKeyRequestOptions];
    "DELETE /user/gpg_keys/:gpg_key_id": [UsersDeleteGpgKeyEndpoint, UsersDeleteGpgKeyRequestOptions];
    "GET /users/:username/keys": [UsersListPublicKeysForUserEndpoint, UsersListPublicKeysForUserRequestOptions];
    "GET /user/keys": [UsersListPublicKeysEndpoint, UsersListPublicKeysRequestOptions];
    "GET /user/keys/:key_id": [UsersGetPublicKeyEndpoint, UsersGetPublicKeyRequestOptions];
    "POST /user/keys": [UsersCreatePublicKeyEndpoint, UsersCreatePublicKeyRequestOptions];
    "DELETE /user/keys/:key_id": [UsersDeletePublicKeyEndpoint, UsersDeletePublicKeyRequestOptions];
}
declare type ActivityListPublicEventsEndpoint = {
    per_page?: number;
    page?: number;
};
declare type ActivityListPublicEventsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityListRepoEventsEndpoint = {
    owner: string;
    repo: string;
    per_page?: number;
    page?: number;
};
declare type ActivityListRepoEventsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityListPublicEventsForRepoNetworkEndpoint = {
    owner: string;
    repo: string;
    per_page?: number;
    page?: number;
};
declare type ActivityListPublicEventsForRepoNetworkRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityListPublicEventsForOrgEndpoint = {
    org: string;
    per_page?: number;
    page?: number;
};
declare type ActivityListPublicEventsForOrgRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityListReceivedEventsForUserEndpoint = {
    username: string;
    per_page?: number;
    page?: number;
};
declare type ActivityListReceivedEventsForUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityListReceivedPublicEventsForUserEndpoint = {
    username: string;
    per_page?: number;
    page?: number;
};
declare type ActivityListReceivedPublicEventsForUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityListEventsForUserEndpoint = {
    username: string;
    per_page?: number;
    page?: number;
};
declare type ActivityListEventsForUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityListPublicEventsForUserEndpoint = {
    username: string;
    per_page?: number;
    page?: number;
};
declare type ActivityListPublicEventsForUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityListEventsForOrgEndpoint = {
    username: string;
    org: string;
    per_page?: number;
    page?: number;
};
declare type ActivityListEventsForOrgRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityListFeedsEndpoint = {};
declare type ActivityListFeedsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityListNotificationsEndpoint = {
    all?: boolean;
    participating?: boolean;
    since?: string;
    before?: string;
    per_page?: number;
    page?: number;
};
declare type ActivityListNotificationsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityListNotificationsForRepoEndpoint = {
    owner: string;
    repo: string;
    all?: boolean;
    participating?: boolean;
    since?: string;
    before?: string;
    per_page?: number;
    page?: number;
};
declare type ActivityListNotificationsForRepoRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityMarkAsReadEndpoint = {
    last_read_at?: string;
};
declare type ActivityMarkAsReadRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityMarkNotificationsAsReadForRepoEndpoint = {
    owner: string;
    repo: string;
    last_read_at?: string;
};
declare type ActivityMarkNotificationsAsReadForRepoRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityGetThreadEndpoint = {
    thread_id: number;
};
declare type ActivityGetThreadRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityMarkThreadAsReadEndpoint = {
    thread_id: number;
};
declare type ActivityMarkThreadAsReadRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityGetThreadSubscriptionEndpoint = {
    thread_id: number;
};
declare type ActivityGetThreadSubscriptionRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivitySetThreadSubscriptionEndpoint = {
    thread_id: number;
    ignored?: boolean;
};
declare type ActivitySetThreadSubscriptionRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityDeleteThreadSubscriptionEndpoint = {
    thread_id: number;
};
declare type ActivityDeleteThreadSubscriptionRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityListStargazersForRepoEndpoint = {
    owner: string;
    repo: string;
    per_page?: number;
    page?: number;
};
declare type ActivityListStargazersForRepoRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityListReposStarredByUserEndpoint = {
    username: string;
    sort?: string;
    direction?: string;
    per_page?: number;
    page?: number;
};
declare type ActivityListReposStarredByUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityListReposStarredByAuthenticatedUserEndpoint = {
    sort?: string;
    direction?: string;
    per_page?: number;
    page?: number;
};
declare type ActivityListReposStarredByAuthenticatedUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityCheckStarringRepoEndpoint = {
    owner: string;
    repo: string;
};
declare type ActivityCheckStarringRepoRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityStarRepoEndpoint = {
    owner: string;
    repo: string;
};
declare type ActivityStarRepoRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityUnstarRepoEndpoint = {
    owner: string;
    repo: string;
};
declare type ActivityUnstarRepoRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityListWatchersForRepoEndpoint = {
    owner: string;
    repo: string;
    per_page?: number;
    page?: number;
};
declare type ActivityListWatchersForRepoRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityListReposWatchedByUserEndpoint = {
    username: string;
    per_page?: number;
    page?: number;
};
declare type ActivityListReposWatchedByUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityListWatchedReposForAuthenticatedUserEndpoint = {
    per_page?: number;
    page?: number;
};
declare type ActivityListWatchedReposForAuthenticatedUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityGetRepoSubscriptionEndpoint = {
    owner: string;
    repo: string;
};
declare type ActivityGetRepoSubscriptionRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivitySetRepoSubscriptionEndpoint = {
    owner: string;
    repo: string;
    subscribed?: boolean;
    ignored?: boolean;
};
declare type ActivitySetRepoSubscriptionRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityDeleteRepoSubscriptionEndpoint = {
    owner: string;
    repo: string;
};
declare type ActivityDeleteRepoSubscriptionRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityCheckWatchingRepoLegacyEndpoint = {
    owner: string;
    repo: string;
};
declare type ActivityCheckWatchingRepoLegacyRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityWatchRepoLegacyEndpoint = {
    owner: string;
    repo: string;
};
declare type ActivityWatchRepoLegacyRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ActivityStopWatchingRepoLegacyEndpoint = {
    owner: string;
    repo: string;
};
declare type ActivityStopWatchingRepoLegacyRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsGetBySlugEndpoint = {
    app_slug: string;
};
declare type AppsGetBySlugRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsGetAuthenticatedEndpoint = {};
declare type AppsGetAuthenticatedRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsListInstallationsEndpoint = {
    per_page?: number;
    page?: number;
};
declare type AppsListInstallationsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsGetInstallationEndpoint = {
    installation_id: number;
};
declare type AppsGetInstallationRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsDeleteInstallationEndpoint = {
    installation_id: number;
};
declare type AppsDeleteInstallationRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsCreateInstallationTokenEndpoint = {
    installation_id: number;
    repository_ids?: number[];
    permissions?: object;
};
declare type AppsCreateInstallationTokenRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsGetOrgInstallationEndpoint = {
    org: string;
};
declare type AppsGetOrgInstallationRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsFindOrgInstallationEndpoint = {
    org: string;
};
declare type AppsFindOrgInstallationRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsGetRepoInstallationEndpoint = {
    owner: string;
    repo: string;
};
declare type AppsGetRepoInstallationRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsFindRepoInstallationEndpoint = {
    owner: string;
    repo: string;
};
declare type AppsFindRepoInstallationRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsGetUserInstallationEndpoint = {
    username: string;
};
declare type AppsGetUserInstallationRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsFindUserInstallationEndpoint = {
    username: string;
};
declare type AppsFindUserInstallationRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsCreateFromManifestEndpoint = {
    code: string;
};
declare type AppsCreateFromManifestRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsListReposEndpoint = {
    per_page?: number;
    page?: number;
};
declare type AppsListReposRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsListInstallationsForAuthenticatedUserEndpoint = {
    per_page?: number;
    page?: number;
};
declare type AppsListInstallationsForAuthenticatedUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsListInstallationReposForAuthenticatedUserEndpoint = {
    installation_id: number;
    per_page?: number;
    page?: number;
};
declare type AppsListInstallationReposForAuthenticatedUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsAddRepoToInstallationEndpoint = {
    installation_id: number;
    repository_id: number;
};
declare type AppsAddRepoToInstallationRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsRemoveRepoFromInstallationEndpoint = {
    installation_id: number;
    repository_id: number;
};
declare type AppsRemoveRepoFromInstallationRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsCreateContentAttachmentEndpoint = {
    content_reference_id: number;
    title: string;
    body: string;
};
declare type AppsCreateContentAttachmentRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsListPlansEndpoint = {
    per_page?: number;
    page?: number;
};
declare type AppsListPlansRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsListPlansStubbedEndpoint = {
    per_page?: number;
    page?: number;
};
declare type AppsListPlansStubbedRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsListAccountsUserOrOrgOnPlanEndpoint = {
    plan_id: number;
    sort?: string;
    direction?: string;
    per_page?: number;
    page?: number;
};
declare type AppsListAccountsUserOrOrgOnPlanRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsListAccountsUserOrOrgOnPlanStubbedEndpoint = {
    plan_id: number;
    sort?: string;
    direction?: string;
    per_page?: number;
    page?: number;
};
declare type AppsListAccountsUserOrOrgOnPlanStubbedRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsCheckAccountIsAssociatedWithAnyEndpoint = {
    account_id: number;
    per_page?: number;
    page?: number;
};
declare type AppsCheckAccountIsAssociatedWithAnyRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsCheckAccountIsAssociatedWithAnyStubbedEndpoint = {
    account_id: number;
    per_page?: number;
    page?: number;
};
declare type AppsCheckAccountIsAssociatedWithAnyStubbedRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsListMarketplacePurchasesForAuthenticatedUserEndpoint = {
    per_page?: number;
    page?: number;
};
declare type AppsListMarketplacePurchasesForAuthenticatedUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type AppsListMarketplacePurchasesForAuthenticatedUserStubbedEndpoint = {
    per_page?: number;
    page?: number;
};
declare type AppsListMarketplacePurchasesForAuthenticatedUserStubbedRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ChecksCreateEndpoint = {
    owner: string;
    repo: string;
    name: string;
    head_sha: string;
    details_url?: string;
    external_id?: string;
    status?: string;
    started_at?: string;
    conclusion?: string;
    completed_at?: string;
    output?: object;
    "output.title": string;
    "output.summary": string;
    "output.text"?: string;
    "output.annotations"?: object[];
    "output.annotations[].path": string;
    "output.annotations[].start_line": number;
    "output.annotations[].end_line": number;
    "output.annotations[].start_column"?: number;
    "output.annotations[].end_column"?: number;
    "output.annotations[].annotation_level": string;
    "output.annotations[].message": string;
    "output.annotations[].title"?: string;
    "output.annotations[].raw_details"?: string;
    "output.images"?: object[];
    "output.images[].alt": string;
    "output.images[].image_url": string;
    "output.images[].caption"?: string;
    actions?: object[];
    "actions[].label": string;
    "actions[].description": string;
    "actions[].identifier": string;
};
declare type ChecksCreateRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ChecksUpdateEndpoint = {
    owner: string;
    repo: string;
    check_run_id: number;
    name?: string;
    details_url?: string;
    external_id?: string;
    started_at?: string;
    status?: string;
    conclusion?: string;
    completed_at?: string;
    output?: object;
    "output.title"?: string;
    "output.summary": string;
    "output.text"?: string;
    "output.annotations"?: object[];
    "output.annotations[].path": string;
    "output.annotations[].start_line": number;
    "output.annotations[].end_line": number;
    "output.annotations[].start_column"?: number;
    "output.annotations[].end_column"?: number;
    "output.annotations[].annotation_level": string;
    "output.annotations[].message": string;
    "output.annotations[].title"?: string;
    "output.annotations[].raw_details"?: string;
    "output.images"?: object[];
    "output.images[].alt": string;
    "output.images[].image_url": string;
    "output.images[].caption"?: string;
    actions?: object[];
    "actions[].label": string;
    "actions[].description": string;
    "actions[].identifier": string;
};
declare type ChecksUpdateRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ChecksListForRefEndpoint = {
    owner: string;
    repo: string;
    ref: string;
    check_name?: string;
    status?: string;
    filter?: string;
    per_page?: number;
    page?: number;
};
declare type ChecksListForRefRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ChecksListForSuiteEndpoint = {
    owner: string;
    repo: string;
    check_suite_id: number;
    check_name?: string;
    status?: string;
    filter?: string;
    per_page?: number;
    page?: number;
};
declare type ChecksListForSuiteRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ChecksGetEndpoint = {
    owner: string;
    repo: string;
    check_run_id: number;
};
declare type ChecksGetRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ChecksListAnnotationsEndpoint = {
    owner: string;
    repo: string;
    check_run_id: number;
    per_page?: number;
    page?: number;
};
declare type ChecksListAnnotationsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ChecksGetSuiteEndpoint = {
    owner: string;
    repo: string;
    check_suite_id: number;
};
declare type ChecksGetSuiteRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ChecksListSuitesForRefEndpoint = {
    owner: string;
    repo: string;
    ref: string;
    app_id?: number;
    check_name?: string;
    per_page?: number;
    page?: number;
};
declare type ChecksListSuitesForRefRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ChecksSetSuitesPreferencesEndpoint = {
    owner: string;
    repo: string;
    auto_trigger_checks?: object[];
    "auto_trigger_checks[].app_id": number;
    "auto_trigger_checks[].setting": boolean;
};
declare type ChecksSetSuitesPreferencesRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ChecksCreateSuiteEndpoint = {
    owner: string;
    repo: string;
    head_sha: string;
};
declare type ChecksCreateSuiteRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ChecksRerequestSuiteEndpoint = {
    owner: string;
    repo: string;
    check_suite_id: number;
};
declare type ChecksRerequestSuiteRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type CodesOfConductListConductCodesEndpoint = {};
declare type CodesOfConductListConductCodesRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type CodesOfConductGetConductCodeEndpoint = {
    key: string;
};
declare type CodesOfConductGetConductCodeRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type CodesOfConductGetForRepoEndpoint = {
    owner: string;
    repo: string;
};
declare type CodesOfConductGetForRepoRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type EmojisGetEndpoint = {};
declare type EmojisGetRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GistsListPublicForUserEndpoint = {
    username: string;
    since?: string;
    per_page?: number;
    page?: number;
};
declare type GistsListPublicForUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GistsListEndpoint = {
    since?: string;
    per_page?: number;
    page?: number;
};
declare type GistsListRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GistsListPublicEndpoint = {
    since?: string;
    per_page?: number;
    page?: number;
};
declare type GistsListPublicRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GistsListStarredEndpoint = {
    since?: string;
    per_page?: number;
    page?: number;
};
declare type GistsListStarredRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GistsGetEndpoint = {
    gist_id: string;
};
declare type GistsGetRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GistsGetRevisionEndpoint = {
    gist_id: string;
    sha: string;
};
declare type GistsGetRevisionRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GistsCreateEndpoint = {
    files: object;
    "files.content"?: string;
    description?: string;
    public?: boolean;
};
declare type GistsCreateRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GistsUpdateEndpoint = {
    gist_id: string;
    description?: string;
    files?: object;
    "files.content"?: string;
    "files.filename"?: string;
};
declare type GistsUpdateRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GistsListCommitsEndpoint = {
    gist_id: string;
    per_page?: number;
    page?: number;
};
declare type GistsListCommitsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GistsStarEndpoint = {
    gist_id: string;
};
declare type GistsStarRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GistsUnstarEndpoint = {
    gist_id: string;
};
declare type GistsUnstarRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GistsCheckIsStarredEndpoint = {
    gist_id: string;
};
declare type GistsCheckIsStarredRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GistsForkEndpoint = {
    gist_id: string;
};
declare type GistsForkRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GistsListForksEndpoint = {
    gist_id: string;
    per_page?: number;
    page?: number;
};
declare type GistsListForksRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GistsDeleteEndpoint = {
    gist_id: string;
};
declare type GistsDeleteRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GistsListCommentsEndpoint = {
    gist_id: string;
    per_page?: number;
    page?: number;
};
declare type GistsListCommentsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GistsGetCommentEndpoint = {
    gist_id: string;
    comment_id: number;
};
declare type GistsGetCommentRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GistsCreateCommentEndpoint = {
    gist_id: string;
    body: string;
};
declare type GistsCreateCommentRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GistsUpdateCommentEndpoint = {
    gist_id: string;
    comment_id: number;
    body: string;
};
declare type GistsUpdateCommentRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GistsDeleteCommentEndpoint = {
    gist_id: string;
    comment_id: number;
};
declare type GistsDeleteCommentRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GitGetBlobEndpoint = {
    owner: string;
    repo: string;
    file_sha: string;
};
declare type GitGetBlobRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GitCreateBlobEndpoint = {
    owner: string;
    repo: string;
    content: string;
    encoding?: string;
};
declare type GitCreateBlobRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GitGetCommitEndpoint = {
    owner: string;
    repo: string;
    commit_sha: string;
};
declare type GitGetCommitRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GitCreateCommitEndpoint = {
    owner: string;
    repo: string;
    message: string;
    tree: string;
    parents: string[];
    author?: object;
    "author.name"?: string;
    "author.email"?: string;
    "author.date"?: string;
    committer?: object;
    "committer.name"?: string;
    "committer.email"?: string;
    "committer.date"?: string;
    signature?: string;
};
declare type GitCreateCommitRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GitGetRefEndpoint = {
    owner: string;
    repo: string;
    ref: string;
};
declare type GitGetRefRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GitListRefsEndpoint = {
    owner: string;
    repo: string;
    namespace?: string;
    per_page?: number;
    page?: number;
};
declare type GitListRefsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GitCreateRefEndpoint = {
    owner: string;
    repo: string;
    ref: string;
    sha: string;
};
declare type GitCreateRefRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GitUpdateRefEndpoint = {
    owner: string;
    repo: string;
    ref: string;
    sha: string;
    force?: boolean;
};
declare type GitUpdateRefRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GitDeleteRefEndpoint = {
    owner: string;
    repo: string;
    ref: string;
};
declare type GitDeleteRefRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GitGetTagEndpoint = {
    owner: string;
    repo: string;
    tag_sha: string;
};
declare type GitGetTagRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GitCreateTagEndpoint = {
    owner: string;
    repo: string;
    tag: string;
    message: string;
    object: string;
    type: string;
    tagger?: object;
    "tagger.name"?: string;
    "tagger.email"?: string;
    "tagger.date"?: string;
};
declare type GitCreateTagRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GitGetTreeEndpoint = {
    owner: string;
    repo: string;
    tree_sha: string;
    recursive?: number;
};
declare type GitGetTreeRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GitCreateTreeEndpoint = {
    owner: string;
    repo: string;
    tree: object[];
    "tree[].path"?: string;
    "tree[].mode"?: string;
    "tree[].type"?: string;
    "tree[].sha"?: string;
    "tree[].content"?: string;
    base_tree?: string;
};
declare type GitCreateTreeRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GitignoreListTemplatesEndpoint = {};
declare type GitignoreListTemplatesRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type GitignoreGetTemplateEndpoint = {
    name: string;
};
declare type GitignoreGetTemplateRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type InteractionsGetRestrictionsForOrgEndpoint = {
    org: string;
};
declare type InteractionsGetRestrictionsForOrgRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type InteractionsAddOrUpdateRestrictionsForOrgEndpoint = {
    org: string;
    limit: string;
};
declare type InteractionsAddOrUpdateRestrictionsForOrgRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type InteractionsRemoveRestrictionsForOrgEndpoint = {
    org: string;
};
declare type InteractionsRemoveRestrictionsForOrgRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type InteractionsGetRestrictionsForRepoEndpoint = {
    owner: string;
    repo: string;
};
declare type InteractionsGetRestrictionsForRepoRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type InteractionsAddOrUpdateRestrictionsForRepoEndpoint = {
    owner: string;
    repo: string;
    limit: string;
};
declare type InteractionsAddOrUpdateRestrictionsForRepoRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type InteractionsRemoveRestrictionsForRepoEndpoint = {
    owner: string;
    repo: string;
};
declare type InteractionsRemoveRestrictionsForRepoRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesListEndpoint = {
    filter?: string;
    state?: string;
    labels?: string;
    sort?: string;
    direction?: string;
    since?: string;
    per_page?: number;
    page?: number;
};
declare type IssuesListRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesListForAuthenticatedUserEndpoint = {
    filter?: string;
    state?: string;
    labels?: string;
    sort?: string;
    direction?: string;
    since?: string;
    per_page?: number;
    page?: number;
};
declare type IssuesListForAuthenticatedUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesListForOrgEndpoint = {
    org: string;
    filter?: string;
    state?: string;
    labels?: string;
    sort?: string;
    direction?: string;
    since?: string;
    per_page?: number;
    page?: number;
};
declare type IssuesListForOrgRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesListForRepoEndpoint = {
    owner: string;
    repo: string;
    milestone?: string;
    state?: string;
    assignee?: string;
    creator?: string;
    mentioned?: string;
    labels?: string;
    sort?: string;
    direction?: string;
    since?: string;
    per_page?: number;
    page?: number;
};
declare type IssuesListForRepoRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesGetEndpoint = {
    owner: string;
    repo: string;
    issue_number: number;
    number?: number;
};
declare type IssuesGetRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesCreateEndpoint = {
    owner: string;
    repo: string;
    title: string;
    body?: string;
    assignee?: string;
    milestone?: number;
    labels?: string[];
    assignees?: string[];
};
declare type IssuesCreateRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesUpdateEndpoint = {
    owner: string;
    repo: string;
    issue_number: number;
    title?: string;
    body?: string;
    assignee?: string;
    state?: string;
    milestone?: number | null;
    labels?: string[];
    assignees?: string[];
    number?: number;
};
declare type IssuesUpdateRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesLockEndpoint = {
    owner: string;
    repo: string;
    issue_number: number;
    lock_reason?: string;
    number?: number;
};
declare type IssuesLockRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesUnlockEndpoint = {
    owner: string;
    repo: string;
    issue_number: number;
    number?: number;
};
declare type IssuesUnlockRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesListAssigneesEndpoint = {
    owner: string;
    repo: string;
    per_page?: number;
    page?: number;
};
declare type IssuesListAssigneesRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesCheckAssigneeEndpoint = {
    owner: string;
    repo: string;
    assignee: string;
};
declare type IssuesCheckAssigneeRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesAddAssigneesEndpoint = {
    owner: string;
    repo: string;
    issue_number: number;
    assignees?: string[];
    number?: number;
};
declare type IssuesAddAssigneesRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesRemoveAssigneesEndpoint = {
    owner: string;
    repo: string;
    issue_number: number;
    assignees?: string[];
    number?: number;
};
declare type IssuesRemoveAssigneesRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesListCommentsEndpoint = {
    owner: string;
    repo: string;
    issue_number: number;
    since?: string;
    per_page?: number;
    page?: number;
    number?: number;
};
declare type IssuesListCommentsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesListCommentsForRepoEndpoint = {
    owner: string;
    repo: string;
    sort?: string;
    direction?: string;
    since?: string;
};
declare type IssuesListCommentsForRepoRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesGetCommentEndpoint = {
    owner: string;
    repo: string;
    comment_id: number;
    per_page?: number;
    page?: number;
};
declare type IssuesGetCommentRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesCreateCommentEndpoint = {
    owner: string;
    repo: string;
    issue_number: number;
    body: string;
    number?: number;
};
declare type IssuesCreateCommentRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesUpdateCommentEndpoint = {
    owner: string;
    repo: string;
    comment_id: number;
    body: string;
};
declare type IssuesUpdateCommentRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesDeleteCommentEndpoint = {
    owner: string;
    repo: string;
    comment_id: number;
};
declare type IssuesDeleteCommentRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesListEventsEndpoint = {
    owner: string;
    repo: string;
    issue_number: number;
    per_page?: number;
    page?: number;
    number?: number;
};
declare type IssuesListEventsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesListEventsForRepoEndpoint = {
    owner: string;
    repo: string;
    per_page?: number;
    page?: number;
};
declare type IssuesListEventsForRepoRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesGetEventEndpoint = {
    owner: string;
    repo: string;
    event_id: number;
};
declare type IssuesGetEventRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesListLabelsForRepoEndpoint = {
    owner: string;
    repo: string;
    per_page?: number;
    page?: number;
};
declare type IssuesListLabelsForRepoRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesGetLabelEndpoint = {
    owner: string;
    repo: string;
    name: string;
};
declare type IssuesGetLabelRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesCreateLabelEndpoint = {
    owner: string;
    repo: string;
    name: string;
    color: string;
    description?: string;
};
declare type IssuesCreateLabelRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesUpdateLabelEndpoint = {
    owner: string;
    repo: string;
    current_name: string;
    name?: string;
    color?: string;
    description?: string;
};
declare type IssuesUpdateLabelRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesDeleteLabelEndpoint = {
    owner: string;
    repo: string;
    name: string;
};
declare type IssuesDeleteLabelRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesListLabelsOnIssueEndpoint = {
    owner: string;
    repo: string;
    issue_number: number;
    per_page?: number;
    page?: number;
    number?: number;
};
declare type IssuesListLabelsOnIssueRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesAddLabelsEndpoint = {
    owner: string;
    repo: string;
    issue_number: number;
    labels: string[];
    number?: number;
};
declare type IssuesAddLabelsRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesRemoveLabelEndpoint = {
    owner: string;
    repo: string;
    issue_number: number;
    name: string;
    number?: number;
};
declare type IssuesRemoveLabelRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesReplaceLabelsEndpoint = {
    owner: string;
    repo: string;
    issue_number: number;
    labels?: string[];
    number?: number;
};
declare type IssuesReplaceLabelsRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesRemoveLabelsEndpoint = {
    owner: string;
    repo: string;
    issue_number: number;
    number?: number;
};
declare type IssuesRemoveLabelsRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesListLabelsForMilestoneEndpoint = {
    owner: string;
    repo: string;
    milestone_number: number;
    per_page?: number;
    page?: number;
    number?: number;
};
declare type IssuesListLabelsForMilestoneRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesListMilestonesForRepoEndpoint = {
    owner: string;
    repo: string;
    state?: string;
    sort?: string;
    direction?: string;
    per_page?: number;
    page?: number;
};
declare type IssuesListMilestonesForRepoRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesGetMilestoneEndpoint = {
    owner: string;
    repo: string;
    milestone_number: number;
    number?: number;
};
declare type IssuesGetMilestoneRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesCreateMilestoneEndpoint = {
    owner: string;
    repo: string;
    title: string;
    state?: string;
    description?: string;
    due_on?: string;
};
declare type IssuesCreateMilestoneRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesUpdateMilestoneEndpoint = {
    owner: string;
    repo: string;
    milestone_number: number;
    title?: string;
    state?: string;
    description?: string;
    due_on?: string;
    number?: number;
};
declare type IssuesUpdateMilestoneRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesDeleteMilestoneEndpoint = {
    owner: string;
    repo: string;
    milestone_number: number;
    number?: number;
};
declare type IssuesDeleteMilestoneRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type IssuesListEventsForTimelineEndpoint = {
    owner: string;
    repo: string;
    issue_number: number;
    per_page?: number;
    page?: number;
    number?: number;
};
declare type IssuesListEventsForTimelineRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type LicensesListCommonlyUsedEndpoint = {};
declare type LicensesListCommonlyUsedRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type LicensesListEndpoint = {};
declare type LicensesListRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type LicensesGetEndpoint = {
    license: string;
};
declare type LicensesGetRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type LicensesGetForRepoEndpoint = {
    owner: string;
    repo: string;
};
declare type LicensesGetForRepoRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MarkdownRenderEndpoint = {
    text: string;
    mode?: string;
    context?: string;
};
declare type MarkdownRenderRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MarkdownRenderRawEndpoint = {
    data: string;
};
declare type MarkdownRenderRawRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MetaGetEndpoint = {};
declare type MetaGetRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MigrationsStartForOrgEndpoint = {
    org: string;
    repositories: string[];
    lock_repositories?: boolean;
    exclude_attachments?: boolean;
};
declare type MigrationsStartForOrgRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MigrationsListForOrgEndpoint = {
    org: string;
    per_page?: number;
    page?: number;
};
declare type MigrationsListForOrgRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MigrationsGetStatusForOrgEndpoint = {
    org: string;
    migration_id: number;
};
declare type MigrationsGetStatusForOrgRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MigrationsGetArchiveForOrgEndpoint = {
    org: string;
    migration_id: number;
};
declare type MigrationsGetArchiveForOrgRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MigrationsDeleteArchiveForOrgEndpoint = {
    org: string;
    migration_id: number;
};
declare type MigrationsDeleteArchiveForOrgRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MigrationsUnlockRepoForOrgEndpoint = {
    org: string;
    migration_id: number;
    repo_name: string;
};
declare type MigrationsUnlockRepoForOrgRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MigrationsStartImportEndpoint = {
    owner: string;
    repo: string;
    vcs_url: string;
    vcs?: string;
    vcs_username?: string;
    vcs_password?: string;
    tfvc_project?: string;
};
declare type MigrationsStartImportRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MigrationsGetImportProgressEndpoint = {
    owner: string;
    repo: string;
};
declare type MigrationsGetImportProgressRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MigrationsUpdateImportEndpoint = {
    owner: string;
    repo: string;
    vcs_username?: string;
    vcs_password?: string;
};
declare type MigrationsUpdateImportRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MigrationsGetCommitAuthorsEndpoint = {
    owner: string;
    repo: string;
    since?: string;
};
declare type MigrationsGetCommitAuthorsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MigrationsMapCommitAuthorEndpoint = {
    owner: string;
    repo: string;
    author_id: number;
    email?: string;
    name?: string;
};
declare type MigrationsMapCommitAuthorRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MigrationsSetLfsPreferenceEndpoint = {
    owner: string;
    repo: string;
    use_lfs: string;
};
declare type MigrationsSetLfsPreferenceRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MigrationsGetLargeFilesEndpoint = {
    owner: string;
    repo: string;
};
declare type MigrationsGetLargeFilesRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MigrationsCancelImportEndpoint = {
    owner: string;
    repo: string;
};
declare type MigrationsCancelImportRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MigrationsStartForAuthenticatedUserEndpoint = {
    repositories: string[];
    lock_repositories?: boolean;
    exclude_attachments?: boolean;
};
declare type MigrationsStartForAuthenticatedUserRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MigrationsListForAuthenticatedUserEndpoint = {
    per_page?: number;
    page?: number;
};
declare type MigrationsListForAuthenticatedUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MigrationsGetStatusForAuthenticatedUserEndpoint = {
    migration_id: number;
};
declare type MigrationsGetStatusForAuthenticatedUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MigrationsGetArchiveForAuthenticatedUserEndpoint = {
    migration_id: number;
};
declare type MigrationsGetArchiveForAuthenticatedUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MigrationsDeleteArchiveForAuthenticatedUserEndpoint = {
    migration_id: number;
};
declare type MigrationsDeleteArchiveForAuthenticatedUserRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type MigrationsUnlockRepoForAuthenticatedUserEndpoint = {
    migration_id: number;
    repo_name: string;
};
declare type MigrationsUnlockRepoForAuthenticatedUserRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OauthAuthorizationsListGrantsEndpoint = {
    per_page?: number;
    page?: number;
};
declare type OauthAuthorizationsListGrantsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OauthAuthorizationsGetGrantEndpoint = {
    grant_id: number;
};
declare type OauthAuthorizationsGetGrantRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OauthAuthorizationsDeleteGrantEndpoint = {
    grant_id: number;
};
declare type OauthAuthorizationsDeleteGrantRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OauthAuthorizationsListAuthorizationsEndpoint = {
    per_page?: number;
    page?: number;
};
declare type OauthAuthorizationsListAuthorizationsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OauthAuthorizationsGetAuthorizationEndpoint = {
    authorization_id: number;
};
declare type OauthAuthorizationsGetAuthorizationRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OauthAuthorizationsCreateAuthorizationEndpoint = {
    scopes?: string[];
    note: string;
    note_url?: string;
    client_id?: string;
    client_secret?: string;
    fingerprint?: string;
};
declare type OauthAuthorizationsCreateAuthorizationRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OauthAuthorizationsGetOrCreateAuthorizationForAppEndpoint = {
    client_id: string;
    client_secret: string;
    scopes?: string[];
    note?: string;
    note_url?: string;
    fingerprint?: string;
};
declare type OauthAuthorizationsGetOrCreateAuthorizationForAppRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OauthAuthorizationsGetOrCreateAuthorizationForAppAndFingerprintEndpoint = {
    client_id: string;
    fingerprint: string;
    client_secret: string;
    scopes?: string[];
    note?: string;
    note_url?: string;
};
declare type OauthAuthorizationsGetOrCreateAuthorizationForAppAndFingerprintRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OauthAuthorizationsGetOrCreateAuthorizationForAppFingerprintEndpoint = {
    client_id: string;
    fingerprint: string;
    client_secret: string;
    scopes?: string[];
    note?: string;
    note_url?: string;
};
declare type OauthAuthorizationsGetOrCreateAuthorizationForAppFingerprintRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OauthAuthorizationsUpdateAuthorizationEndpoint = {
    authorization_id: number;
    scopes?: string[];
    add_scopes?: string[];
    remove_scopes?: string[];
    note?: string;
    note_url?: string;
    fingerprint?: string;
};
declare type OauthAuthorizationsUpdateAuthorizationRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OauthAuthorizationsDeleteAuthorizationEndpoint = {
    authorization_id: number;
};
declare type OauthAuthorizationsDeleteAuthorizationRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OauthAuthorizationsCheckAuthorizationEndpoint = {
    client_id: string;
    access_token: string;
};
declare type OauthAuthorizationsCheckAuthorizationRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OauthAuthorizationsResetAuthorizationEndpoint = {
    client_id: string;
    access_token: string;
};
declare type OauthAuthorizationsResetAuthorizationRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OauthAuthorizationsRevokeAuthorizationForApplicationEndpoint = {
    client_id: string;
    access_token: string;
};
declare type OauthAuthorizationsRevokeAuthorizationForApplicationRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OauthAuthorizationsRevokeGrantForApplicationEndpoint = {
    client_id: string;
    access_token: string;
};
declare type OauthAuthorizationsRevokeGrantForApplicationRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsListForAuthenticatedUserEndpoint = {
    per_page?: number;
    page?: number;
};
declare type OrgsListForAuthenticatedUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsListEndpoint = {
    since?: string;
    per_page?: number;
    page?: number;
};
declare type OrgsListRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsListForUserEndpoint = {
    username: string;
    per_page?: number;
    page?: number;
};
declare type OrgsListForUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsGetEndpoint = {
    org: string;
};
declare type OrgsGetRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsUpdateEndpoint = {
    org: string;
    billing_email?: string;
    company?: string;
    email?: string;
    location?: string;
    name?: string;
    description?: string;
    has_organization_projects?: boolean;
    has_repository_projects?: boolean;
    default_repository_permission?: string;
    members_can_create_repositories?: boolean;
    members_allowed_repository_creation_type?: string;
};
declare type OrgsUpdateRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsListCredentialAuthorizationsEndpoint = {
    org: string;
};
declare type OrgsListCredentialAuthorizationsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsRemoveCredentialAuthorizationEndpoint = {
    org: string;
    credential_id: number;
};
declare type OrgsRemoveCredentialAuthorizationRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsListBlockedUsersEndpoint = {
    org: string;
};
declare type OrgsListBlockedUsersRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsCheckBlockedUserEndpoint = {
    org: string;
    username: string;
};
declare type OrgsCheckBlockedUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsBlockUserEndpoint = {
    org: string;
    username: string;
};
declare type OrgsBlockUserRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsUnblockUserEndpoint = {
    org: string;
    username: string;
};
declare type OrgsUnblockUserRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsListHooksEndpoint = {
    org: string;
    per_page?: number;
    page?: number;
};
declare type OrgsListHooksRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsGetHookEndpoint = {
    org: string;
    hook_id: number;
};
declare type OrgsGetHookRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsCreateHookEndpoint = {
    org: string;
    name: string;
    config: object;
    "config.url": string;
    "config.content_type"?: string;
    "config.secret"?: string;
    "config.insecure_ssl"?: string;
    events?: string[];
    active?: boolean;
};
declare type OrgsCreateHookRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsUpdateHookEndpoint = {
    org: string;
    hook_id: number;
    config?: object;
    "config.url": string;
    "config.content_type"?: string;
    "config.secret"?: string;
    "config.insecure_ssl"?: string;
    events?: string[];
    active?: boolean;
};
declare type OrgsUpdateHookRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsPingHookEndpoint = {
    org: string;
    hook_id: number;
};
declare type OrgsPingHookRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsDeleteHookEndpoint = {
    org: string;
    hook_id: number;
};
declare type OrgsDeleteHookRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsListMembersEndpoint = {
    org: string;
    filter?: string;
    role?: string;
    per_page?: number;
    page?: number;
};
declare type OrgsListMembersRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsCheckMembershipEndpoint = {
    org: string;
    username: string;
};
declare type OrgsCheckMembershipRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsRemoveMemberEndpoint = {
    org: string;
    username: string;
};
declare type OrgsRemoveMemberRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsListPublicMembersEndpoint = {
    org: string;
    per_page?: number;
    page?: number;
};
declare type OrgsListPublicMembersRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsCheckPublicMembershipEndpoint = {
    org: string;
    username: string;
};
declare type OrgsCheckPublicMembershipRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsPublicizeMembershipEndpoint = {
    org: string;
    username: string;
};
declare type OrgsPublicizeMembershipRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsConcealMembershipEndpoint = {
    org: string;
    username: string;
};
declare type OrgsConcealMembershipRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsGetMembershipEndpoint = {
    org: string;
    username: string;
};
declare type OrgsGetMembershipRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsAddOrUpdateMembershipEndpoint = {
    org: string;
    username: string;
    role?: string;
};
declare type OrgsAddOrUpdateMembershipRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsRemoveMembershipEndpoint = {
    org: string;
    username: string;
};
declare type OrgsRemoveMembershipRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsListInvitationTeamsEndpoint = {
    org: string;
    invitation_id: number;
    per_page?: number;
    page?: number;
};
declare type OrgsListInvitationTeamsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsListPendingInvitationsEndpoint = {
    org: string;
    per_page?: number;
    page?: number;
};
declare type OrgsListPendingInvitationsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsCreateInvitationEndpoint = {
    org: string;
    invitee_id?: number;
    email?: string;
    role?: string;
    team_ids?: number[];
};
declare type OrgsCreateInvitationRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsListMembershipsEndpoint = {
    state?: string;
    per_page?: number;
    page?: number;
};
declare type OrgsListMembershipsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsGetMembershipForAuthenticatedUserEndpoint = {
    org: string;
};
declare type OrgsGetMembershipForAuthenticatedUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsUpdateMembershipEndpoint = {
    org: string;
    state: string;
};
declare type OrgsUpdateMembershipRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsListOutsideCollaboratorsEndpoint = {
    org: string;
    filter?: string;
    per_page?: number;
    page?: number;
};
declare type OrgsListOutsideCollaboratorsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsRemoveOutsideCollaboratorEndpoint = {
    org: string;
    username: string;
};
declare type OrgsRemoveOutsideCollaboratorRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type OrgsConvertMemberToOutsideCollaboratorEndpoint = {
    org: string;
    username: string;
};
declare type OrgsConvertMemberToOutsideCollaboratorRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsListForRepoEndpoint = {
    owner: string;
    repo: string;
    state?: string;
    per_page?: number;
    page?: number;
};
declare type ProjectsListForRepoRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsListForOrgEndpoint = {
    org: string;
    state?: string;
    per_page?: number;
    page?: number;
};
declare type ProjectsListForOrgRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsListForUserEndpoint = {
    username: string;
    state?: string;
    per_page?: number;
    page?: number;
};
declare type ProjectsListForUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsGetEndpoint = {
    project_id: number;
    per_page?: number;
    page?: number;
};
declare type ProjectsGetRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsCreateForRepoEndpoint = {
    owner: string;
    repo: string;
    name: string;
    body?: string;
    per_page?: number;
    page?: number;
};
declare type ProjectsCreateForRepoRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsCreateForOrgEndpoint = {
    org: string;
    name: string;
    body?: string;
    per_page?: number;
    page?: number;
};
declare type ProjectsCreateForOrgRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsCreateForAuthenticatedUserEndpoint = {
    name: string;
    body?: string;
    per_page?: number;
    page?: number;
};
declare type ProjectsCreateForAuthenticatedUserRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsUpdateEndpoint = {
    project_id: number;
    name?: string;
    body?: string;
    state?: string;
    organization_permission?: string;
    private?: boolean;
    per_page?: number;
    page?: number;
};
declare type ProjectsUpdateRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsDeleteEndpoint = {
    project_id: number;
};
declare type ProjectsDeleteRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsListCardsEndpoint = {
    column_id: number;
    archived_state?: string;
    per_page?: number;
    page?: number;
};
declare type ProjectsListCardsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsGetCardEndpoint = {
    card_id: number;
};
declare type ProjectsGetCardRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsCreateCardEndpoint = {
    column_id: number;
    note?: string;
    content_id?: number;
    content_type?: string;
};
declare type ProjectsCreateCardRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsUpdateCardEndpoint = {
    card_id: number;
    note?: string;
    archived?: boolean;
};
declare type ProjectsUpdateCardRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsDeleteCardEndpoint = {
    card_id: number;
};
declare type ProjectsDeleteCardRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsMoveCardEndpoint = {
    card_id: number;
    position: string;
    column_id?: number;
};
declare type ProjectsMoveCardRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsListCollaboratorsEndpoint = {
    project_id: number;
    affiliation?: string;
    per_page?: number;
    page?: number;
};
declare type ProjectsListCollaboratorsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsReviewUserPermissionLevelEndpoint = {
    project_id: number;
    username: string;
};
declare type ProjectsReviewUserPermissionLevelRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsAddCollaboratorEndpoint = {
    project_id: number;
    username: string;
    permission?: string;
};
declare type ProjectsAddCollaboratorRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsRemoveCollaboratorEndpoint = {
    project_id: number;
    username: string;
};
declare type ProjectsRemoveCollaboratorRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsListColumnsEndpoint = {
    project_id: number;
    per_page?: number;
    page?: number;
};
declare type ProjectsListColumnsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsGetColumnEndpoint = {
    column_id: number;
};
declare type ProjectsGetColumnRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsCreateColumnEndpoint = {
    project_id: number;
    name: string;
};
declare type ProjectsCreateColumnRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsUpdateColumnEndpoint = {
    column_id: number;
    name: string;
};
declare type ProjectsUpdateColumnRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsDeleteColumnEndpoint = {
    column_id: number;
};
declare type ProjectsDeleteColumnRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ProjectsMoveColumnEndpoint = {
    column_id: number;
    position: string;
};
declare type ProjectsMoveColumnRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsListEndpoint = {
    owner: string;
    repo: string;
    state?: string;
    head?: string;
    base?: string;
    sort?: string;
    direction?: string;
    per_page?: number;
    page?: number;
};
declare type PullsListRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsGetEndpoint = {
    owner: string;
    repo: string;
    pull_number: number;
    number?: number;
};
declare type PullsGetRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsCreateEndpoint = {
    owner: string;
    repo: string;
    title: string;
    head: string;
    base: string;
    body?: string;
    maintainer_can_modify?: boolean;
    draft?: boolean;
};
declare type PullsCreateRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsCreateFromIssueEndpoint = {
    owner: string;
    repo: string;
    issue: number;
    head: string;
    base: string;
    maintainer_can_modify?: boolean;
    draft?: boolean;
};
declare type PullsCreateFromIssueRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsUpdateBranchEndpoint = {
    owner: string;
    repo: string;
    pull_number: number;
    expected_head_sha?: string;
};
declare type PullsUpdateBranchRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsUpdateEndpoint = {
    owner: string;
    repo: string;
    pull_number: number;
    title?: string;
    body?: string;
    state?: string;
    base?: string;
    maintainer_can_modify?: boolean;
    number?: number;
};
declare type PullsUpdateRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsListCommitsEndpoint = {
    owner: string;
    repo: string;
    pull_number: number;
    per_page?: number;
    page?: number;
    number?: number;
};
declare type PullsListCommitsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsListFilesEndpoint = {
    owner: string;
    repo: string;
    pull_number: number;
    per_page?: number;
    page?: number;
    number?: number;
};
declare type PullsListFilesRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsCheckIfMergedEndpoint = {
    owner: string;
    repo: string;
    pull_number: number;
    number?: number;
};
declare type PullsCheckIfMergedRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsMergeEndpoint = {
    owner: string;
    repo: string;
    pull_number: number;
    commit_title?: string;
    commit_message?: string;
    sha?: string;
    merge_method?: string;
    number?: number;
};
declare type PullsMergeRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsListCommentsEndpoint = {
    owner: string;
    repo: string;
    pull_number: number;
    sort?: string;
    direction?: string;
    since?: string;
    per_page?: number;
    page?: number;
    number?: number;
};
declare type PullsListCommentsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsListCommentsForRepoEndpoint = {
    owner: string;
    repo: string;
    sort?: string;
    direction?: string;
    since?: string;
    per_page?: number;
    page?: number;
};
declare type PullsListCommentsForRepoRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsGetCommentEndpoint = {
    owner: string;
    repo: string;
    comment_id: number;
};
declare type PullsGetCommentRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsCreateCommentEndpoint = {
    owner: string;
    repo: string;
    pull_number: number;
    body: string;
    commit_id: string;
    path: string;
    position: number;
    number?: number;
};
declare type PullsCreateCommentRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsCreateCommentReplyEndpoint = {
    owner: string;
    repo: string;
    pull_number: number;
    body: string;
    in_reply_to: number;
    number?: number;
};
declare type PullsCreateCommentReplyRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsUpdateCommentEndpoint = {
    owner: string;
    repo: string;
    comment_id: number;
    body: string;
};
declare type PullsUpdateCommentRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsDeleteCommentEndpoint = {
    owner: string;
    repo: string;
    comment_id: number;
};
declare type PullsDeleteCommentRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsListReviewRequestsEndpoint = {
    owner: string;
    repo: string;
    pull_number: number;
    per_page?: number;
    page?: number;
    number?: number;
};
declare type PullsListReviewRequestsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsCreateReviewRequestEndpoint = {
    owner: string;
    repo: string;
    pull_number: number;
    reviewers?: string[];
    team_reviewers?: string[];
    number?: number;
};
declare type PullsCreateReviewRequestRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsDeleteReviewRequestEndpoint = {
    owner: string;
    repo: string;
    pull_number: number;
    reviewers?: string[];
    team_reviewers?: string[];
    number?: number;
};
declare type PullsDeleteReviewRequestRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsListReviewsEndpoint = {
    owner: string;
    repo: string;
    pull_number: number;
    per_page?: number;
    page?: number;
    number?: number;
};
declare type PullsListReviewsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsGetReviewEndpoint = {
    owner: string;
    repo: string;
    pull_number: number;
    review_id: number;
    number?: number;
};
declare type PullsGetReviewRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsDeletePendingReviewEndpoint = {
    owner: string;
    repo: string;
    pull_number: number;
    review_id: number;
    number?: number;
};
declare type PullsDeletePendingReviewRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsGetCommentsForReviewEndpoint = {
    owner: string;
    repo: string;
    pull_number: number;
    review_id: number;
    per_page?: number;
    page?: number;
    number?: number;
};
declare type PullsGetCommentsForReviewRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsCreateReviewEndpoint = {
    owner: string;
    repo: string;
    pull_number: number;
    commit_id?: string;
    body?: string;
    event?: string;
    comments?: object[];
    "comments[].path": string;
    "comments[].position": number;
    "comments[].body": string;
    number?: number;
};
declare type PullsCreateReviewRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsUpdateReviewEndpoint = {
    owner: string;
    repo: string;
    pull_number: number;
    review_id: number;
    body: string;
    number?: number;
};
declare type PullsUpdateReviewRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsSubmitReviewEndpoint = {
    owner: string;
    repo: string;
    pull_number: number;
    review_id: number;
    body?: string;
    event: string;
    number?: number;
};
declare type PullsSubmitReviewRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type PullsDismissReviewEndpoint = {
    owner: string;
    repo: string;
    pull_number: number;
    review_id: number;
    message: string;
    number?: number;
};
declare type PullsDismissReviewRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type RateLimitGetEndpoint = {};
declare type RateLimitGetRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReactionsListForCommitCommentEndpoint = {
    owner: string;
    repo: string;
    comment_id: number;
    content?: string;
    per_page?: number;
    page?: number;
};
declare type ReactionsListForCommitCommentRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReactionsCreateForCommitCommentEndpoint = {
    owner: string;
    repo: string;
    comment_id: number;
    content: string;
};
declare type ReactionsCreateForCommitCommentRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReactionsListForIssueEndpoint = {
    owner: string;
    repo: string;
    issue_number: number;
    content?: string;
    per_page?: number;
    page?: number;
    number?: number;
};
declare type ReactionsListForIssueRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReactionsCreateForIssueEndpoint = {
    owner: string;
    repo: string;
    issue_number: number;
    content: string;
    number?: number;
};
declare type ReactionsCreateForIssueRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReactionsListForIssueCommentEndpoint = {
    owner: string;
    repo: string;
    comment_id: number;
    content?: string;
    per_page?: number;
    page?: number;
};
declare type ReactionsListForIssueCommentRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReactionsCreateForIssueCommentEndpoint = {
    owner: string;
    repo: string;
    comment_id: number;
    content: string;
};
declare type ReactionsCreateForIssueCommentRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReactionsListForPullRequestReviewCommentEndpoint = {
    owner: string;
    repo: string;
    comment_id: number;
    content?: string;
    per_page?: number;
    page?: number;
};
declare type ReactionsListForPullRequestReviewCommentRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReactionsCreateForPullRequestReviewCommentEndpoint = {
    owner: string;
    repo: string;
    comment_id: number;
    content: string;
};
declare type ReactionsCreateForPullRequestReviewCommentRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReactionsListForTeamDiscussionEndpoint = {
    team_id: number;
    discussion_number: number;
    content?: string;
    per_page?: number;
    page?: number;
};
declare type ReactionsListForTeamDiscussionRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReactionsCreateForTeamDiscussionEndpoint = {
    team_id: number;
    discussion_number: number;
    content: string;
};
declare type ReactionsCreateForTeamDiscussionRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReactionsListForTeamDiscussionCommentEndpoint = {
    team_id: number;
    discussion_number: number;
    comment_number: number;
    content?: string;
    per_page?: number;
    page?: number;
};
declare type ReactionsListForTeamDiscussionCommentRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReactionsCreateForTeamDiscussionCommentEndpoint = {
    team_id: number;
    discussion_number: number;
    comment_number: number;
    content: string;
};
declare type ReactionsCreateForTeamDiscussionCommentRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReactionsDeleteEndpoint = {
    reaction_id: number;
};
declare type ReactionsDeleteRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListEndpoint = {
    visibility?: string;
    affiliation?: string;
    type?: string;
    sort?: string;
    direction?: string;
    per_page?: number;
    page?: number;
};
declare type ReposListRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListForUserEndpoint = {
    username: string;
    type?: string;
    sort?: string;
    direction?: string;
    per_page?: number;
    page?: number;
};
declare type ReposListForUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListForOrgEndpoint = {
    org: string;
    type?: string;
    sort?: string;
    direction?: string;
    per_page?: number;
    page?: number;
};
declare type ReposListForOrgRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListPublicEndpoint = {
    since?: string;
    per_page?: number;
    page?: number;
};
declare type ReposListPublicRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposCreateForAuthenticatedUserEndpoint = {
    name: string;
    description?: string;
    homepage?: string;
    private?: boolean;
    has_issues?: boolean;
    has_projects?: boolean;
    has_wiki?: boolean;
    is_template?: boolean;
    team_id?: number;
    auto_init?: boolean;
    gitignore_template?: string;
    license_template?: string;
    allow_squash_merge?: boolean;
    allow_merge_commit?: boolean;
    allow_rebase_merge?: boolean;
};
declare type ReposCreateForAuthenticatedUserRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposCreateInOrgEndpoint = {
    org: string;
    name: string;
    description?: string;
    homepage?: string;
    private?: boolean;
    has_issues?: boolean;
    has_projects?: boolean;
    has_wiki?: boolean;
    is_template?: boolean;
    team_id?: number;
    auto_init?: boolean;
    gitignore_template?: string;
    license_template?: string;
    allow_squash_merge?: boolean;
    allow_merge_commit?: boolean;
    allow_rebase_merge?: boolean;
};
declare type ReposCreateInOrgRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposCreateUsingTemplateEndpoint = {
    template_owner: string;
    template_repo: string;
    owner?: string;
    name: string;
    description?: string;
    private?: boolean;
};
declare type ReposCreateUsingTemplateRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposGetRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposUpdateEndpoint = {
    owner: string;
    repo: string;
    name?: string;
    description?: string;
    homepage?: string;
    private?: boolean;
    has_issues?: boolean;
    has_projects?: boolean;
    has_wiki?: boolean;
    is_template?: boolean;
    default_branch?: string;
    allow_squash_merge?: boolean;
    allow_merge_commit?: boolean;
    allow_rebase_merge?: boolean;
    archived?: boolean;
};
declare type ReposUpdateRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListTopicsEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposListTopicsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposReplaceTopicsEndpoint = {
    owner: string;
    repo: string;
    names: string[];
};
declare type ReposReplaceTopicsRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposCheckVulnerabilityAlertsEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposCheckVulnerabilityAlertsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposEnableVulnerabilityAlertsEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposEnableVulnerabilityAlertsRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposDisableVulnerabilityAlertsEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposDisableVulnerabilityAlertsRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposEnableAutomatedSecurityFixesEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposEnableAutomatedSecurityFixesRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposDisableAutomatedSecurityFixesEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposDisableAutomatedSecurityFixesRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListContributorsEndpoint = {
    owner: string;
    repo: string;
    anon?: string;
    per_page?: number;
    page?: number;
};
declare type ReposListContributorsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListLanguagesEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposListLanguagesRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListTeamsEndpoint = {
    owner: string;
    repo: string;
    per_page?: number;
    page?: number;
};
declare type ReposListTeamsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListTagsEndpoint = {
    owner: string;
    repo: string;
    per_page?: number;
    page?: number;
};
declare type ReposListTagsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposDeleteEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposDeleteRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposTransferEndpoint = {
    owner: string;
    repo: string;
    new_owner?: string;
    team_ids?: number[];
};
declare type ReposTransferRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListBranchesEndpoint = {
    owner: string;
    repo: string;
    protected?: boolean;
    per_page?: number;
    page?: number;
};
declare type ReposListBranchesRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetBranchEndpoint = {
    owner: string;
    repo: string;
    branch: string;
};
declare type ReposGetBranchRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetBranchProtectionEndpoint = {
    owner: string;
    repo: string;
    branch: string;
};
declare type ReposGetBranchProtectionRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposUpdateBranchProtectionEndpoint = {
    owner: string;
    repo: string;
    branch: string;
    required_status_checks: object | null;
    "required_status_checks.strict": boolean;
    "required_status_checks.contexts": string[];
    enforce_admins: boolean | null;
    required_pull_request_reviews: object | null;
    "required_pull_request_reviews.dismissal_restrictions"?: object;
    "required_pull_request_reviews.dismissal_restrictions.users"?: string[];
    "required_pull_request_reviews.dismissal_restrictions.teams"?: string[];
    "required_pull_request_reviews.dismiss_stale_reviews"?: boolean;
    "required_pull_request_reviews.require_code_owner_reviews"?: boolean;
    "required_pull_request_reviews.required_approving_review_count"?: number;
    restrictions: object | null;
    "restrictions.users"?: string[];
    "restrictions.teams"?: string[];
};
declare type ReposUpdateBranchProtectionRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposRemoveBranchProtectionEndpoint = {
    owner: string;
    repo: string;
    branch: string;
};
declare type ReposRemoveBranchProtectionRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetProtectedBranchRequiredStatusChecksEndpoint = {
    owner: string;
    repo: string;
    branch: string;
};
declare type ReposGetProtectedBranchRequiredStatusChecksRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposUpdateProtectedBranchRequiredStatusChecksEndpoint = {
    owner: string;
    repo: string;
    branch: string;
    strict?: boolean;
    contexts?: string[];
};
declare type ReposUpdateProtectedBranchRequiredStatusChecksRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposRemoveProtectedBranchRequiredStatusChecksEndpoint = {
    owner: string;
    repo: string;
    branch: string;
};
declare type ReposRemoveProtectedBranchRequiredStatusChecksRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListProtectedBranchRequiredStatusChecksContextsEndpoint = {
    owner: string;
    repo: string;
    branch: string;
};
declare type ReposListProtectedBranchRequiredStatusChecksContextsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposReplaceProtectedBranchRequiredStatusChecksContextsEndpoint = {
    owner: string;
    repo: string;
    branch: string;
    contexts: string[];
};
declare type ReposReplaceProtectedBranchRequiredStatusChecksContextsRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposAddProtectedBranchRequiredStatusChecksContextsEndpoint = {
    owner: string;
    repo: string;
    branch: string;
    contexts: string[];
};
declare type ReposAddProtectedBranchRequiredStatusChecksContextsRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposRemoveProtectedBranchRequiredStatusChecksContextsEndpoint = {
    owner: string;
    repo: string;
    branch: string;
    contexts: string[];
};
declare type ReposRemoveProtectedBranchRequiredStatusChecksContextsRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetProtectedBranchPullRequestReviewEnforcementEndpoint = {
    owner: string;
    repo: string;
    branch: string;
};
declare type ReposGetProtectedBranchPullRequestReviewEnforcementRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposUpdateProtectedBranchPullRequestReviewEnforcementEndpoint = {
    owner: string;
    repo: string;
    branch: string;
    dismissal_restrictions?: object;
    "dismissal_restrictions.users"?: string[];
    "dismissal_restrictions.teams"?: string[];
    dismiss_stale_reviews?: boolean;
    require_code_owner_reviews?: boolean;
    required_approving_review_count?: number;
};
declare type ReposUpdateProtectedBranchPullRequestReviewEnforcementRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposRemoveProtectedBranchPullRequestReviewEnforcementEndpoint = {
    owner: string;
    repo: string;
    branch: string;
};
declare type ReposRemoveProtectedBranchPullRequestReviewEnforcementRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetProtectedBranchRequiredSignaturesEndpoint = {
    owner: string;
    repo: string;
    branch: string;
};
declare type ReposGetProtectedBranchRequiredSignaturesRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposAddProtectedBranchRequiredSignaturesEndpoint = {
    owner: string;
    repo: string;
    branch: string;
};
declare type ReposAddProtectedBranchRequiredSignaturesRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposRemoveProtectedBranchRequiredSignaturesEndpoint = {
    owner: string;
    repo: string;
    branch: string;
};
declare type ReposRemoveProtectedBranchRequiredSignaturesRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetProtectedBranchAdminEnforcementEndpoint = {
    owner: string;
    repo: string;
    branch: string;
};
declare type ReposGetProtectedBranchAdminEnforcementRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposAddProtectedBranchAdminEnforcementEndpoint = {
    owner: string;
    repo: string;
    branch: string;
};
declare type ReposAddProtectedBranchAdminEnforcementRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposRemoveProtectedBranchAdminEnforcementEndpoint = {
    owner: string;
    repo: string;
    branch: string;
};
declare type ReposRemoveProtectedBranchAdminEnforcementRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetProtectedBranchRestrictionsEndpoint = {
    owner: string;
    repo: string;
    branch: string;
};
declare type ReposGetProtectedBranchRestrictionsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposRemoveProtectedBranchRestrictionsEndpoint = {
    owner: string;
    repo: string;
    branch: string;
};
declare type ReposRemoveProtectedBranchRestrictionsRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListProtectedBranchTeamRestrictionsEndpoint = {
    owner: string;
    repo: string;
    branch: string;
    per_page?: number;
    page?: number;
};
declare type ReposListProtectedBranchTeamRestrictionsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposReplaceProtectedBranchTeamRestrictionsEndpoint = {
    owner: string;
    repo: string;
    branch: string;
    teams: string[];
};
declare type ReposReplaceProtectedBranchTeamRestrictionsRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposAddProtectedBranchTeamRestrictionsEndpoint = {
    owner: string;
    repo: string;
    branch: string;
    teams: string[];
};
declare type ReposAddProtectedBranchTeamRestrictionsRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposRemoveProtectedBranchTeamRestrictionsEndpoint = {
    owner: string;
    repo: string;
    branch: string;
    teams: string[];
};
declare type ReposRemoveProtectedBranchTeamRestrictionsRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListProtectedBranchUserRestrictionsEndpoint = {
    owner: string;
    repo: string;
    branch: string;
};
declare type ReposListProtectedBranchUserRestrictionsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposReplaceProtectedBranchUserRestrictionsEndpoint = {
    owner: string;
    repo: string;
    branch: string;
    users: string[];
};
declare type ReposReplaceProtectedBranchUserRestrictionsRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposAddProtectedBranchUserRestrictionsEndpoint = {
    owner: string;
    repo: string;
    branch: string;
    users: string[];
};
declare type ReposAddProtectedBranchUserRestrictionsRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposRemoveProtectedBranchUserRestrictionsEndpoint = {
    owner: string;
    repo: string;
    branch: string;
    users: string[];
};
declare type ReposRemoveProtectedBranchUserRestrictionsRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListCollaboratorsEndpoint = {
    owner: string;
    repo: string;
    affiliation?: string;
    per_page?: number;
    page?: number;
};
declare type ReposListCollaboratorsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposCheckCollaboratorEndpoint = {
    owner: string;
    repo: string;
    username: string;
};
declare type ReposCheckCollaboratorRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetCollaboratorPermissionLevelEndpoint = {
    owner: string;
    repo: string;
    username: string;
};
declare type ReposGetCollaboratorPermissionLevelRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposAddCollaboratorEndpoint = {
    owner: string;
    repo: string;
    username: string;
    permission?: string;
};
declare type ReposAddCollaboratorRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposRemoveCollaboratorEndpoint = {
    owner: string;
    repo: string;
    username: string;
};
declare type ReposRemoveCollaboratorRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListCommitCommentsEndpoint = {
    owner: string;
    repo: string;
    per_page?: number;
    page?: number;
};
declare type ReposListCommitCommentsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListCommentsForCommitEndpoint = {
    owner: string;
    repo: string;
    commit_sha: string;
    per_page?: number;
    page?: number;
    ref?: string;
};
declare type ReposListCommentsForCommitRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposCreateCommitCommentEndpoint = {
    owner: string;
    repo: string;
    commit_sha: string;
    body: string;
    path?: string;
    position?: number;
    line?: number;
    sha?: string;
};
declare type ReposCreateCommitCommentRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetCommitCommentEndpoint = {
    owner: string;
    repo: string;
    comment_id: number;
};
declare type ReposGetCommitCommentRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposUpdateCommitCommentEndpoint = {
    owner: string;
    repo: string;
    comment_id: number;
    body: string;
};
declare type ReposUpdateCommitCommentRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposDeleteCommitCommentEndpoint = {
    owner: string;
    repo: string;
    comment_id: number;
};
declare type ReposDeleteCommitCommentRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListCommitsEndpoint = {
    owner: string;
    repo: string;
    sha?: string;
    path?: string;
    author?: string;
    since?: string;
    until?: string;
    per_page?: number;
    page?: number;
};
declare type ReposListCommitsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetCommitEndpoint = {
    owner: string;
    repo: string;
    ref: string;
    sha?: string;
    commit_sha?: string;
};
declare type ReposGetCommitRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetCommitRefShaEndpoint = {
    owner: string;
    repo: string;
    ref: string;
};
declare type ReposGetCommitRefShaRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposCompareCommitsEndpoint = {
    owner: string;
    repo: string;
    base: string;
    head: string;
};
declare type ReposCompareCommitsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListBranchesForHeadCommitEndpoint = {
    owner: string;
    repo: string;
    commit_sha: string;
};
declare type ReposListBranchesForHeadCommitRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListPullRequestsAssociatedWithCommitEndpoint = {
    owner: string;
    repo: string;
    commit_sha: string;
    per_page?: number;
    page?: number;
};
declare type ReposListPullRequestsAssociatedWithCommitRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposRetrieveCommunityProfileMetricsEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposRetrieveCommunityProfileMetricsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetReadmeEndpoint = {
    owner: string;
    repo: string;
    ref?: string;
};
declare type ReposGetReadmeRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetContentsEndpoint = {
    owner: string;
    repo: string;
    path: string;
    ref?: string;
};
declare type ReposGetContentsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposCreateOrUpdateFileEndpoint = {
    owner: string;
    repo: string;
    path: string;
    message: string;
    content: string;
    sha?: string;
    branch?: string;
    committer?: object;
    "committer.name": string;
    "committer.email": string;
    author?: object;
    "author.name": string;
    "author.email": string;
};
declare type ReposCreateOrUpdateFileRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposCreateFileEndpoint = {
    owner: string;
    repo: string;
    path: string;
    message: string;
    content: string;
    sha?: string;
    branch?: string;
    committer?: object;
    "committer.name": string;
    "committer.email": string;
    author?: object;
    "author.name": string;
    "author.email": string;
};
declare type ReposCreateFileRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposUpdateFileEndpoint = {
    owner: string;
    repo: string;
    path: string;
    message: string;
    content: string;
    sha?: string;
    branch?: string;
    committer?: object;
    "committer.name": string;
    "committer.email": string;
    author?: object;
    "author.name": string;
    "author.email": string;
};
declare type ReposUpdateFileRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposDeleteFileEndpoint = {
    owner: string;
    repo: string;
    path: string;
    message: string;
    sha: string;
    branch?: string;
    committer?: object;
    "committer.name"?: string;
    "committer.email"?: string;
    author?: object;
    "author.name"?: string;
    "author.email"?: string;
};
declare type ReposDeleteFileRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetArchiveLinkEndpoint = {
    owner: string;
    repo: string;
    archive_format: string;
    ref: string;
};
declare type ReposGetArchiveLinkRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListDeploymentsEndpoint = {
    owner: string;
    repo: string;
    sha?: string;
    ref?: string;
    task?: string;
    environment?: string;
    per_page?: number;
    page?: number;
};
declare type ReposListDeploymentsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetDeploymentEndpoint = {
    owner: string;
    repo: string;
    deployment_id: number;
};
declare type ReposGetDeploymentRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposCreateDeploymentEndpoint = {
    owner: string;
    repo: string;
    ref: string;
    task?: string;
    auto_merge?: boolean;
    required_contexts?: string[];
    payload?: string;
    environment?: string;
    description?: string;
    transient_environment?: boolean;
    production_environment?: boolean;
};
declare type ReposCreateDeploymentRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListDeploymentStatusesEndpoint = {
    owner: string;
    repo: string;
    deployment_id: number;
    per_page?: number;
    page?: number;
};
declare type ReposListDeploymentStatusesRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetDeploymentStatusEndpoint = {
    owner: string;
    repo: string;
    deployment_id: number;
    status_id: number;
};
declare type ReposGetDeploymentStatusRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposCreateDeploymentStatusEndpoint = {
    owner: string;
    repo: string;
    deployment_id: number;
    state: string;
    target_url?: string;
    log_url?: string;
    description?: string;
    environment?: string;
    environment_url?: string;
    auto_inactive?: boolean;
};
declare type ReposCreateDeploymentStatusRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListDownloadsEndpoint = {
    owner: string;
    repo: string;
    per_page?: number;
    page?: number;
};
declare type ReposListDownloadsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetDownloadEndpoint = {
    owner: string;
    repo: string;
    download_id: number;
};
declare type ReposGetDownloadRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposDeleteDownloadEndpoint = {
    owner: string;
    repo: string;
    download_id: number;
};
declare type ReposDeleteDownloadRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListForksEndpoint = {
    owner: string;
    repo: string;
    sort?: string;
    per_page?: number;
    page?: number;
};
declare type ReposListForksRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposCreateForkEndpoint = {
    owner: string;
    repo: string;
    organization?: string;
};
declare type ReposCreateForkRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListHooksEndpoint = {
    owner: string;
    repo: string;
    per_page?: number;
    page?: number;
};
declare type ReposListHooksRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetHookEndpoint = {
    owner: string;
    repo: string;
    hook_id: number;
};
declare type ReposGetHookRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposCreateHookEndpoint = {
    owner: string;
    repo: string;
    name?: string;
    config: object;
    "config.url": string;
    "config.content_type"?: string;
    "config.secret"?: string;
    "config.insecure_ssl"?: string;
    events?: string[];
    active?: boolean;
};
declare type ReposCreateHookRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposUpdateHookEndpoint = {
    owner: string;
    repo: string;
    hook_id: number;
    config?: object;
    "config.url": string;
    "config.content_type"?: string;
    "config.secret"?: string;
    "config.insecure_ssl"?: string;
    events?: string[];
    add_events?: string[];
    remove_events?: string[];
    active?: boolean;
};
declare type ReposUpdateHookRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposTestPushHookEndpoint = {
    owner: string;
    repo: string;
    hook_id: number;
};
declare type ReposTestPushHookRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposPingHookEndpoint = {
    owner: string;
    repo: string;
    hook_id: number;
};
declare type ReposPingHookRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposDeleteHookEndpoint = {
    owner: string;
    repo: string;
    hook_id: number;
};
declare type ReposDeleteHookRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListInvitationsEndpoint = {
    owner: string;
    repo: string;
    per_page?: number;
    page?: number;
};
declare type ReposListInvitationsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposDeleteInvitationEndpoint = {
    owner: string;
    repo: string;
    invitation_id: number;
};
declare type ReposDeleteInvitationRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposUpdateInvitationEndpoint = {
    owner: string;
    repo: string;
    invitation_id: number;
    permissions?: string;
};
declare type ReposUpdateInvitationRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListInvitationsForAuthenticatedUserEndpoint = {
    per_page?: number;
    page?: number;
};
declare type ReposListInvitationsForAuthenticatedUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposAcceptInvitationEndpoint = {
    invitation_id: number;
};
declare type ReposAcceptInvitationRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposDeclineInvitationEndpoint = {
    invitation_id: number;
};
declare type ReposDeclineInvitationRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListDeployKeysEndpoint = {
    owner: string;
    repo: string;
    per_page?: number;
    page?: number;
};
declare type ReposListDeployKeysRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetDeployKeyEndpoint = {
    owner: string;
    repo: string;
    key_id: number;
};
declare type ReposGetDeployKeyRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposAddDeployKeyEndpoint = {
    owner: string;
    repo: string;
    title?: string;
    key: string;
    read_only?: boolean;
};
declare type ReposAddDeployKeyRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposRemoveDeployKeyEndpoint = {
    owner: string;
    repo: string;
    key_id: number;
};
declare type ReposRemoveDeployKeyRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposMergeEndpoint = {
    owner: string;
    repo: string;
    base: string;
    head: string;
    commit_message?: string;
};
declare type ReposMergeRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetPagesEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposGetPagesRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposEnablePagesSiteEndpoint = {
    owner: string;
    repo: string;
    source?: object;
    "source.branch"?: string;
    "source.path"?: string;
};
declare type ReposEnablePagesSiteRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposDisablePagesSiteEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposDisablePagesSiteRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposUpdateInformationAboutPagesSiteEndpoint = {
    owner: string;
    repo: string;
    cname?: string;
    source?: string;
};
declare type ReposUpdateInformationAboutPagesSiteRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposRequestPageBuildEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposRequestPageBuildRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListPagesBuildsEndpoint = {
    owner: string;
    repo: string;
    per_page?: number;
    page?: number;
};
declare type ReposListPagesBuildsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetLatestPagesBuildEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposGetLatestPagesBuildRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetPagesBuildEndpoint = {
    owner: string;
    repo: string;
    build_id: number;
};
declare type ReposGetPagesBuildRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListReleasesEndpoint = {
    owner: string;
    repo: string;
    per_page?: number;
    page?: number;
};
declare type ReposListReleasesRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetReleaseEndpoint = {
    owner: string;
    repo: string;
    release_id: number;
};
declare type ReposGetReleaseRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetLatestReleaseEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposGetLatestReleaseRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetReleaseByTagEndpoint = {
    owner: string;
    repo: string;
    tag: string;
};
declare type ReposGetReleaseByTagRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposCreateReleaseEndpoint = {
    owner: string;
    repo: string;
    tag_name: string;
    target_commitish?: string;
    name?: string;
    body?: string;
    draft?: boolean;
    prerelease?: boolean;
};
declare type ReposCreateReleaseRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposUpdateReleaseEndpoint = {
    owner: string;
    repo: string;
    release_id: number;
    tag_name?: string;
    target_commitish?: string;
    name?: string;
    body?: string;
    draft?: boolean;
    prerelease?: boolean;
};
declare type ReposUpdateReleaseRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposDeleteReleaseEndpoint = {
    owner: string;
    repo: string;
    release_id: number;
};
declare type ReposDeleteReleaseRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListAssetsForReleaseEndpoint = {
    owner: string;
    repo: string;
    release_id: number;
    per_page?: number;
    page?: number;
};
declare type ReposListAssetsForReleaseRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposUploadReleaseAssetEndpoint = {
    url: string;
    headers: object;
    "headers.content-length": number;
    "headers.content-type": string;
    name: string;
    label?: string;
    file: string | object;
};
declare type ReposUploadReleaseAssetRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetReleaseAssetEndpoint = {
    owner: string;
    repo: string;
    asset_id: number;
};
declare type ReposGetReleaseAssetRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposUpdateReleaseAssetEndpoint = {
    owner: string;
    repo: string;
    asset_id: number;
    name?: string;
    label?: string;
};
declare type ReposUpdateReleaseAssetRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposDeleteReleaseAssetEndpoint = {
    owner: string;
    repo: string;
    asset_id: number;
};
declare type ReposDeleteReleaseAssetRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetContributorsStatsEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposGetContributorsStatsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetCommitActivityStatsEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposGetCommitActivityStatsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetCodeFrequencyStatsEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposGetCodeFrequencyStatsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetParticipationStatsEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposGetParticipationStatsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetPunchCardStatsEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposGetPunchCardStatsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposCreateStatusEndpoint = {
    owner: string;
    repo: string;
    sha: string;
    state: string;
    target_url?: string;
    description?: string;
    context?: string;
};
declare type ReposCreateStatusRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposListStatusesForRefEndpoint = {
    owner: string;
    repo: string;
    ref: string;
    per_page?: number;
    page?: number;
};
declare type ReposListStatusesForRefRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetCombinedStatusForRefEndpoint = {
    owner: string;
    repo: string;
    ref: string;
};
declare type ReposGetCombinedStatusForRefRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetTopReferrersEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposGetTopReferrersRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetTopPathsEndpoint = {
    owner: string;
    repo: string;
};
declare type ReposGetTopPathsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetViewsEndpoint = {
    owner: string;
    repo: string;
    per?: string;
};
declare type ReposGetViewsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ReposGetClonesEndpoint = {
    owner: string;
    repo: string;
    per?: string;
};
declare type ReposGetClonesRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ScimListProvisionedIdentitiesEndpoint = {
    org: string;
    startIndex?: number;
    count?: number;
    filter?: string;
};
declare type ScimListProvisionedIdentitiesRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ScimGetProvisioningDetailsForUserEndpoint = {
    org: string;
    scim_user_id: number;
    external_identity_guid?: number;
};
declare type ScimGetProvisioningDetailsForUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ScimProvisionAndInviteUsersEndpoint = {
    org: string;
};
declare type ScimProvisionAndInviteUsersRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ScimProvisionInviteUsersEndpoint = {
    org: string;
};
declare type ScimProvisionInviteUsersRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ScimReplaceProvisionedUserInformationEndpoint = {
    org: string;
    scim_user_id: number;
    external_identity_guid?: number;
};
declare type ScimReplaceProvisionedUserInformationRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ScimUpdateProvisionedOrgMembershipEndpoint = {
    org: string;
    scim_user_id: number;
    external_identity_guid?: number;
};
declare type ScimUpdateProvisionedOrgMembershipRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ScimUpdateUserAttributeEndpoint = {
    org: string;
    scim_user_id: number;
    external_identity_guid?: number;
};
declare type ScimUpdateUserAttributeRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type ScimRemoveUserFromOrgEndpoint = {
    org: string;
    scim_user_id: number;
    external_identity_guid?: number;
};
declare type ScimRemoveUserFromOrgRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type SearchReposEndpoint = {
    q: string;
    sort?: string;
    order?: string;
    per_page?: number;
    page?: number;
};
declare type SearchReposRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type SearchCommitsEndpoint = {
    q: string;
    sort?: string;
    order?: string;
    per_page?: number;
    page?: number;
};
declare type SearchCommitsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type SearchCodeEndpoint = {
    q: string;
    sort?: string;
    order?: string;
    per_page?: number;
    page?: number;
};
declare type SearchCodeRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type SearchIssuesAndPullRequestsEndpoint = {
    q: string;
    sort?: string;
    order?: string;
    per_page?: number;
    page?: number;
};
declare type SearchIssuesAndPullRequestsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type SearchIssuesEndpoint = {
    q: string;
    sort?: string;
    order?: string;
    per_page?: number;
    page?: number;
};
declare type SearchIssuesRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type SearchUsersEndpoint = {
    q: string;
    sort?: string;
    order?: string;
    per_page?: number;
    page?: number;
};
declare type SearchUsersRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type SearchTopicsEndpoint = {
    q: string;
};
declare type SearchTopicsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type SearchLabelsEndpoint = {
    repository_id: number;
    q: string;
    sort?: string;
    order?: string;
};
declare type SearchLabelsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type SearchIssuesLegacyEndpoint = {
    owner: string;
    repository: string;
    state: string;
    keyword: string;
};
declare type SearchIssuesLegacyRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type SearchReposLegacyEndpoint = {
    keyword: string;
    language?: string;
    start_page?: string;
    sort?: string;
    order?: string;
};
declare type SearchReposLegacyRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type SearchUsersLegacyEndpoint = {
    keyword: string;
    start_page?: string;
    sort?: string;
    order?: string;
};
declare type SearchUsersLegacyRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type SearchEmailLegacyEndpoint = {
    email: string;
};
declare type SearchEmailLegacyRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsListEndpoint = {
    org: string;
    per_page?: number;
    page?: number;
};
declare type TeamsListRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsGetEndpoint = {
    team_id: number;
};
declare type TeamsGetRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsGetByNameEndpoint = {
    org: string;
    team_slug: string;
};
declare type TeamsGetByNameRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsCreateEndpoint = {
    org: string;
    name: string;
    description?: string;
    maintainers?: string[];
    repo_names?: string[];
    privacy?: string;
    permission?: string;
    parent_team_id?: number;
};
declare type TeamsCreateRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsUpdateEndpoint = {
    team_id: number;
    name: string;
    description?: string;
    privacy?: string;
    permission?: string;
    parent_team_id?: number;
};
declare type TeamsUpdateRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsDeleteEndpoint = {
    team_id: number;
};
declare type TeamsDeleteRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsListChildEndpoint = {
    team_id: number;
    per_page?: number;
    page?: number;
};
declare type TeamsListChildRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsListReposEndpoint = {
    team_id: number;
    per_page?: number;
    page?: number;
};
declare type TeamsListReposRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsCheckManagesRepoEndpoint = {
    team_id: number;
    owner: string;
    repo: string;
};
declare type TeamsCheckManagesRepoRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsAddOrUpdateRepoEndpoint = {
    team_id: number;
    owner: string;
    repo: string;
    permission?: string;
};
declare type TeamsAddOrUpdateRepoRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsRemoveRepoEndpoint = {
    team_id: number;
    owner: string;
    repo: string;
};
declare type TeamsRemoveRepoRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsListForAuthenticatedUserEndpoint = {
    per_page?: number;
    page?: number;
};
declare type TeamsListForAuthenticatedUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsListProjectsEndpoint = {
    team_id: number;
    per_page?: number;
    page?: number;
};
declare type TeamsListProjectsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsReviewProjectEndpoint = {
    team_id: number;
    project_id: number;
};
declare type TeamsReviewProjectRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsAddOrUpdateProjectEndpoint = {
    team_id: number;
    project_id: number;
    permission?: string;
};
declare type TeamsAddOrUpdateProjectRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsRemoveProjectEndpoint = {
    team_id: number;
    project_id: number;
};
declare type TeamsRemoveProjectRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsListDiscussionCommentsEndpoint = {
    team_id: number;
    discussion_number: number;
    direction?: string;
    per_page?: number;
    page?: number;
};
declare type TeamsListDiscussionCommentsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsGetDiscussionCommentEndpoint = {
    team_id: number;
    discussion_number: number;
    comment_number: number;
};
declare type TeamsGetDiscussionCommentRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsCreateDiscussionCommentEndpoint = {
    team_id: number;
    discussion_number: number;
    body: string;
};
declare type TeamsCreateDiscussionCommentRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsUpdateDiscussionCommentEndpoint = {
    team_id: number;
    discussion_number: number;
    comment_number: number;
    body: string;
};
declare type TeamsUpdateDiscussionCommentRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsDeleteDiscussionCommentEndpoint = {
    team_id: number;
    discussion_number: number;
    comment_number: number;
};
declare type TeamsDeleteDiscussionCommentRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsListDiscussionsEndpoint = {
    team_id: number;
    direction?: string;
    per_page?: number;
    page?: number;
};
declare type TeamsListDiscussionsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsGetDiscussionEndpoint = {
    team_id: number;
    discussion_number: number;
};
declare type TeamsGetDiscussionRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsCreateDiscussionEndpoint = {
    team_id: number;
    title: string;
    body: string;
    private?: boolean;
};
declare type TeamsCreateDiscussionRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsUpdateDiscussionEndpoint = {
    team_id: number;
    discussion_number: number;
    title?: string;
    body?: string;
};
declare type TeamsUpdateDiscussionRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsDeleteDiscussionEndpoint = {
    team_id: number;
    discussion_number: number;
};
declare type TeamsDeleteDiscussionRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsListMembersEndpoint = {
    team_id: number;
    role?: string;
    per_page?: number;
    page?: number;
};
declare type TeamsListMembersRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsGetMemberEndpoint = {
    team_id: number;
    username: string;
};
declare type TeamsGetMemberRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsAddMemberEndpoint = {
    team_id: number;
    username: string;
};
declare type TeamsAddMemberRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsRemoveMemberEndpoint = {
    team_id: number;
    username: string;
};
declare type TeamsRemoveMemberRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsGetMembershipEndpoint = {
    team_id: number;
    username: string;
};
declare type TeamsGetMembershipRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsAddOrUpdateMembershipEndpoint = {
    team_id: number;
    username: string;
    role?: string;
};
declare type TeamsAddOrUpdateMembershipRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsRemoveMembershipEndpoint = {
    team_id: number;
    username: string;
};
declare type TeamsRemoveMembershipRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsListPendingInvitationsEndpoint = {
    team_id: number;
    per_page?: number;
    page?: number;
};
declare type TeamsListPendingInvitationsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsListIdPGroupsForOrgEndpoint = {
    org: string;
    per_page?: number;
    page?: number;
};
declare type TeamsListIdPGroupsForOrgRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsListIdPGroupsEndpoint = {
    team_id: number;
};
declare type TeamsListIdPGroupsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type TeamsCreateOrUpdateIdPGroupConnectionsEndpoint = {
    team_id: number;
    groups: object[];
    "groups[].group_id": string;
    "groups[].group_name": string;
    "groups[].group_description": string;
};
declare type TeamsCreateOrUpdateIdPGroupConnectionsRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersGetByUsernameEndpoint = {
    username: string;
};
declare type UsersGetByUsernameRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersGetAuthenticatedEndpoint = {};
declare type UsersGetAuthenticatedRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersUpdateAuthenticatedEndpoint = {
    name?: string;
    email?: string;
    blog?: string;
    company?: string;
    location?: string;
    hireable?: boolean;
    bio?: string;
};
declare type UsersUpdateAuthenticatedRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersGetContextForUserEndpoint = {
    username: string;
    subject_type?: string;
    subject_id?: string;
};
declare type UsersGetContextForUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersListEndpoint = {
    since?: string;
    per_page?: number;
    page?: number;
};
declare type UsersListRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersListBlockedEndpoint = {};
declare type UsersListBlockedRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersCheckBlockedEndpoint = {
    username: string;
};
declare type UsersCheckBlockedRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersBlockEndpoint = {
    username: string;
};
declare type UsersBlockRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersUnblockEndpoint = {
    username: string;
};
declare type UsersUnblockRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersListEmailsEndpoint = {
    per_page?: number;
    page?: number;
};
declare type UsersListEmailsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersListPublicEmailsEndpoint = {
    per_page?: number;
    page?: number;
};
declare type UsersListPublicEmailsRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersAddEmailsEndpoint = {
    emails: string[];
};
declare type UsersAddEmailsRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersDeleteEmailsEndpoint = {
    emails: string[];
};
declare type UsersDeleteEmailsRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersTogglePrimaryEmailVisibilityEndpoint = {
    email: string;
    visibility: string;
};
declare type UsersTogglePrimaryEmailVisibilityRequestOptions = {
    method: "PATCH";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersListFollowersForUserEndpoint = {
    username: string;
    per_page?: number;
    page?: number;
};
declare type UsersListFollowersForUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersListFollowersForAuthenticatedUserEndpoint = {
    per_page?: number;
    page?: number;
};
declare type UsersListFollowersForAuthenticatedUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersListFollowingForUserEndpoint = {
    username: string;
    per_page?: number;
    page?: number;
};
declare type UsersListFollowingForUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersListFollowingForAuthenticatedUserEndpoint = {
    per_page?: number;
    page?: number;
};
declare type UsersListFollowingForAuthenticatedUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersCheckFollowingEndpoint = {
    username: string;
};
declare type UsersCheckFollowingRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersCheckFollowingForUserEndpoint = {
    username: string;
    target_user: string;
};
declare type UsersCheckFollowingForUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersFollowEndpoint = {
    username: string;
};
declare type UsersFollowRequestOptions = {
    method: "PUT";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersUnfollowEndpoint = {
    username: string;
};
declare type UsersUnfollowRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersListGpgKeysForUserEndpoint = {
    username: string;
    per_page?: number;
    page?: number;
};
declare type UsersListGpgKeysForUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersListGpgKeysEndpoint = {
    per_page?: number;
    page?: number;
};
declare type UsersListGpgKeysRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersGetGpgKeyEndpoint = {
    gpg_key_id: number;
};
declare type UsersGetGpgKeyRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersCreateGpgKeyEndpoint = {
    armored_public_key?: string;
};
declare type UsersCreateGpgKeyRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersDeleteGpgKeyEndpoint = {
    gpg_key_id: number;
};
declare type UsersDeleteGpgKeyRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersListPublicKeysForUserEndpoint = {
    username: string;
    per_page?: number;
    page?: number;
};
declare type UsersListPublicKeysForUserRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersListPublicKeysEndpoint = {
    per_page?: number;
    page?: number;
};
declare type UsersListPublicKeysRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersGetPublicKeyEndpoint = {
    key_id: number;
};
declare type UsersGetPublicKeyRequestOptions = {
    method: "GET";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersCreatePublicKeyEndpoint = {
    title?: string;
    key?: string;
};
declare type UsersCreatePublicKeyRequestOptions = {
    method: "POST";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
declare type UsersDeletePublicKeyEndpoint = {
    key_id: number;
};
declare type UsersDeletePublicKeyRequestOptions = {
    method: "DELETE";
    url: Url;
    headers: Headers;
    request: EndpointRequestOptions;
};
export {};
