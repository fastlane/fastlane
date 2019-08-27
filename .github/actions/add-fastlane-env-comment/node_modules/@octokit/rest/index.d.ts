/**
 * This declaration file requires TypeScript 3.1 or above.
 */

/// <reference lib="esnext.asynciterable" />

import * as http from "http";

declare namespace Octokit {
  type json = any;
  type date = string;

  export interface Static {
    plugin(plugin: Plugin): Static;
    new (options?: Octokit.Options): Octokit;
  }

  export interface Response<T> {
    /** This is the data you would see in https://developer.github.com/v3/ */
    data: T;

    /** Response status number */
    status: number;

    /** Response headers */
    headers: {
      date: string;
      "x-ratelimit-limit": string;
      "x-ratelimit-remaining": string;
      "x-ratelimit-reset": string;
      "x-Octokit-request-id": string;
      "x-Octokit-media-type": string;
      link: string;
      "last-modified": string;
      etag: string;
      status: string;
    };

    [Symbol.iterator](): Iterator<any>;
  }

  export type AnyResponse = Response<any>;

  export interface EmptyParams {}

  export interface Options {
    auth?:
      | string
      | { username: string; password: string; on2fa: () => Promise<string> }
      | { clientId: string; clientSecret: string }
      | { (): string | Promise<string> };
    userAgent?: string;
    previews?: string[];
    baseUrl?: string;
    log?: {
      debug?: (message: string, info?: object) => void;
      info?: (message: string, info?: object) => void;
      warn?: (message: string, info?: object) => void;
      error?: (message: string, info?: object) => void;
    };
    request?: {
      agent?: http.Agent;
      timeout?: number;
    };
    timeout?: number; // Deprecated
    headers?: { [header: string]: any }; // Deprecated
    agent?: http.Agent; // Deprecated
    [option: string]: any;
  }

  export type RequestMethod =
    | "DELETE"
    | "GET"
    | "HEAD"
    | "PATCH"
    | "POST"
    | "PUT";

  export interface EndpointOptions {
    baseUrl?: string;
    method?: RequestMethod;
    url?: string;
    headers?: { [header: string]: any };
    data?: any;
    request?: { [option: string]: any };
    [parameter: string]: any;
  }

  export interface RequestOptions {
    method?: RequestMethod;
    url?: string;
    headers?: { [header: string]: any };
    body?: any;
    request?: { [option: string]: any };
  }

  export interface Log {
    debug: (message: string, additionalInfo?: object) => void;
    info: (message: string, additionalInfo?: object) => void;
    warn: (message: string, additionalInfo?: object) => void;
    error: (message: string, additionalInfo?: object) => void;
  }

  export interface Endpoint {
    (
      Route: string,
      EndpointOptions?: Octokit.EndpointOptions
    ): Octokit.RequestOptions;
    (EndpointOptions: Octokit.EndpointOptions): Octokit.RequestOptions;
    /**
     * Current default options
     */
    DEFAULTS: Octokit.EndpointOptions;
    /**
     * Get the defaulted endpoint options, but without parsing them into request options:
     */
    merge(
      Route: string,
      EndpointOptions?: Octokit.EndpointOptions
    ): Octokit.RequestOptions;
    merge(EndpointOptions: Octokit.EndpointOptions): Octokit.RequestOptions;
    /**
     * Stateless method to turn endpoint options into request options. Calling endpoint(options) is the same as calling endpoint.parse(endpoint.merge(options)).
     */
    parse(EndpointOptions: Octokit.EndpointOptions): Octokit.RequestOptions;
    /**
     * Merges existing defaults with passed options and returns new endpoint() method with new defaults
     */
    defaults(EndpointOptions: Octokit.EndpointOptions): Octokit.Endpoint;
  }

  export interface Request {
    (Route: string, EndpointOptions?: Octokit.EndpointOptions): Promise<
      Octokit.AnyResponse
    >;
    (EndpointOptions: Octokit.EndpointOptions): Promise<Octokit.AnyResponse>;
    endpoint: Octokit.Endpoint;
  }

  export interface AuthBasic {
    type: "basic";
    username: string;
    password: string;
  }

  export interface AuthOAuthToken {
    type: "oauth";
    token: string;
  }

  export interface AuthOAuthSecret {
    type: "oauth";
    key: string;
    secret: string;
  }

  export interface AuthUserToken {
    type: "token";
    token: string;
  }

  export interface AuthJWT {
    type: "app";
    token: string;
  }

  export type Link = { link: string } | { headers: { link: string } } | string;

  export interface Callback<T> {
    (error: Error | null, result: T): any;
  }

  export type Plugin = (octokit: Octokit, options: Octokit.Options) => void;

  // See https://github.com/octokit/request.js#octokitrequest
  export type HookOptions = {
    baseUrl: string;
    headers: { [header: string]: string };
    method: string;
    url: string;
    data: any;
    // See https://github.com/bitinn/node-fetch#options
    request: {
      follow?: number;
      timeout?: number;
      compress?: boolean;
      size?: number;
      agent?: string | null;
    };
    [index: string]: any;
  };

  export type HookError = Error & {
    status: number;
    headers: { [header: string]: string };
    documentation_url?: string;
    errors?: [
      {
        resource: string;
        field: string;
        code: string;
      }
    ];
  };

  export interface Paginate {
    (
      Route: string,
      EndpointOptions?: Octokit.EndpointOptions,
      callback?: (response: Octokit.AnyResponse) => any
    ): Promise<any[]>;
    (
      EndpointOptions: Octokit.EndpointOptions,
      callback?: (response: Octokit.AnyResponse) => any
    ): Promise<any[]>;
    iterator: (
      EndpointOptions: Octokit.EndpointOptions
    ) => AsyncIterableIterator<Octokit.AnyResponse>;
  }

  type UsersDeletePublicKeyResponse = {};
  type UsersCreatePublicKeyResponse = {
    id: number;
    key: string;
    url: string;
    title: string;
    verified: boolean;
    created_at: string;
    read_only: boolean;
  };
  type UsersGetPublicKeyResponse = {
    id: number;
    key: string;
    url: string;
    title: string;
    verified: boolean;
    created_at: string;
    read_only: boolean;
  };
  type UsersListPublicKeysResponseItem = {
    id: number;
    key: string;
    url: string;
    title: string;
    verified: boolean;
    created_at: string;
    read_only: boolean;
  };
  type UsersListPublicKeysForUserResponseItem = { id: number; key: string };
  type UsersDeleteGpgKeyResponse = {};
  type UsersCreateGpgKeyResponseSubkeysItem = {
    id: number;
    primary_key_id: number;
    key_id: string;
    public_key: string;
    emails: Array<any>;
    subkeys: Array<any>;
    can_sign: boolean;
    can_encrypt_comms: boolean;
    can_encrypt_storage: boolean;
    can_certify: boolean;
    created_at: string;
    expires_at: null;
  };
  type UsersCreateGpgKeyResponseEmailsItem = {
    email: string;
    verified: boolean;
  };
  type UsersCreateGpgKeyResponse = {
    id: number;
    primary_key_id: null;
    key_id: string;
    public_key: string;
    emails: Array<UsersCreateGpgKeyResponseEmailsItem>;
    subkeys: Array<UsersCreateGpgKeyResponseSubkeysItem>;
    can_sign: boolean;
    can_encrypt_comms: boolean;
    can_encrypt_storage: boolean;
    can_certify: boolean;
    created_at: string;
    expires_at: null;
  };
  type UsersGetGpgKeyResponseSubkeysItem = {
    id: number;
    primary_key_id: number;
    key_id: string;
    public_key: string;
    emails: Array<any>;
    subkeys: Array<any>;
    can_sign: boolean;
    can_encrypt_comms: boolean;
    can_encrypt_storage: boolean;
    can_certify: boolean;
    created_at: string;
    expires_at: null;
  };
  type UsersGetGpgKeyResponseEmailsItem = { email: string; verified: boolean };
  type UsersGetGpgKeyResponse = {
    id: number;
    primary_key_id: null;
    key_id: string;
    public_key: string;
    emails: Array<UsersGetGpgKeyResponseEmailsItem>;
    subkeys: Array<UsersGetGpgKeyResponseSubkeysItem>;
    can_sign: boolean;
    can_encrypt_comms: boolean;
    can_encrypt_storage: boolean;
    can_certify: boolean;
    created_at: string;
    expires_at: null;
  };
  type UsersListGpgKeysResponseItemSubkeysItem = {
    id: number;
    primary_key_id: number;
    key_id: string;
    public_key: string;
    emails: Array<any>;
    subkeys: Array<any>;
    can_sign: boolean;
    can_encrypt_comms: boolean;
    can_encrypt_storage: boolean;
    can_certify: boolean;
    created_at: string;
    expires_at: null;
  };
  type UsersListGpgKeysResponseItemEmailsItem = {
    email: string;
    verified: boolean;
  };
  type UsersListGpgKeysResponseItem = {
    id: number;
    primary_key_id: null;
    key_id: string;
    public_key: string;
    emails: Array<UsersListGpgKeysResponseItemEmailsItem>;
    subkeys: Array<UsersListGpgKeysResponseItemSubkeysItem>;
    can_sign: boolean;
    can_encrypt_comms: boolean;
    can_encrypt_storage: boolean;
    can_certify: boolean;
    created_at: string;
    expires_at: null;
  };
  type UsersListGpgKeysForUserResponseItemSubkeysItem = {
    id: number;
    primary_key_id: number;
    key_id: string;
    public_key: string;
    emails: Array<any>;
    subkeys: Array<any>;
    can_sign: boolean;
    can_encrypt_comms: boolean;
    can_encrypt_storage: boolean;
    can_certify: boolean;
    created_at: string;
    expires_at: null;
  };
  type UsersListGpgKeysForUserResponseItemEmailsItem = {
    email: string;
    verified: boolean;
  };
  type UsersListGpgKeysForUserResponseItem = {
    id: number;
    primary_key_id: null;
    key_id: string;
    public_key: string;
    emails: Array<UsersListGpgKeysForUserResponseItemEmailsItem>;
    subkeys: Array<UsersListGpgKeysForUserResponseItemSubkeysItem>;
    can_sign: boolean;
    can_encrypt_comms: boolean;
    can_encrypt_storage: boolean;
    can_certify: boolean;
    created_at: string;
    expires_at: null;
  };
  type UsersUnfollowResponse = {};
  type UsersFollowResponse = {};
  type UsersListFollowingForAuthenticatedUserResponseItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type UsersListFollowingForUserResponseItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type UsersListFollowersForAuthenticatedUserResponseItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type UsersListFollowersForUserResponseItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type UsersTogglePrimaryEmailVisibilityResponseItem = {
    email: string;
    primary: boolean;
    verified: boolean;
    visibility: string;
  };
  type UsersDeleteEmailsResponse = {};
  type UsersAddEmailsResponseItem = {
    email: string;
    primary: boolean;
    verified: boolean;
    visibility: string | null;
  };
  type UsersListPublicEmailsResponseItem = {
    email: string;
    verified: boolean;
    primary: boolean;
    visibility: string;
  };
  type UsersListEmailsResponseItem = {
    email: string;
    verified: boolean;
    primary: boolean;
    visibility: string;
  };
  type UsersUnblockResponse = {};
  type UsersBlockResponse = {};
  type UsersCheckBlockedResponse = {};
  type UsersListBlockedResponseItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type UsersListResponseItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type UsersUpdateAuthenticatedResponsePlan = {
    name: string;
    space: number;
    private_repos: number;
    collaborators: number;
  };
  type UsersUpdateAuthenticatedResponse = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
    name: string;
    company: string;
    blog: string;
    location: string;
    email: string;
    hireable: boolean;
    bio: string;
    public_repos: number;
    public_gists: number;
    followers: number;
    following: number;
    created_at: string;
    updated_at: string;
    private_gists: number;
    total_private_repos: number;
    owned_private_repos: number;
    disk_usage: number;
    collaborators: number;
    two_factor_authentication: boolean;
    plan: UsersUpdateAuthenticatedResponsePlan;
  };
  type UsersGetByUsernameResponse = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
    name: string;
    company: string;
    blog: string;
    location: string;
    email: string;
    hireable: boolean;
    bio: string;
    public_repos: number;
    public_gists: number;
    followers: number;
    following: number;
    created_at: string;
    updated_at: string;
  };
  type TeamsListPendingInvitationsResponseItemInviter = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type TeamsListPendingInvitationsResponseItem = {
    id: number;
    login: string;
    email: string;
    role: string;
    created_at: string;
    inviter: TeamsListPendingInvitationsResponseItemInviter;
    team_count: number;
    invitation_team_url: string;
  };
  type TeamsRemoveMembershipResponse = {};
  type TeamsRemoveMemberResponse = {};
  type TeamsAddMemberResponse = {};
  type TeamsListMembersResponseItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type TeamsDeleteDiscussionResponse = {};
  type TeamsUpdateDiscussionResponseReactions = {
    url: string;
    total_count: number;
    "+1": number;
    "-1": number;
    laugh: number;
    confused: number;
    heart: number;
    hooray: number;
  };
  type TeamsUpdateDiscussionResponseAuthor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type TeamsUpdateDiscussionResponse = {
    author: TeamsUpdateDiscussionResponseAuthor;
    body: string;
    body_html: string;
    body_version: string;
    comments_count: number;
    comments_url: string;
    created_at: string;
    last_edited_at: string;
    html_url: string;
    node_id: string;
    number: number;
    pinned: boolean;
    private: boolean;
    team_url: string;
    title: string;
    updated_at: string;
    url: string;
    reactions: TeamsUpdateDiscussionResponseReactions;
  };
  type TeamsCreateDiscussionResponseReactions = {
    url: string;
    total_count: number;
    "+1": number;
    "-1": number;
    laugh: number;
    confused: number;
    heart: number;
    hooray: number;
  };
  type TeamsCreateDiscussionResponseAuthor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type TeamsCreateDiscussionResponse = {
    author: TeamsCreateDiscussionResponseAuthor;
    body: string;
    body_html: string;
    body_version: string;
    comments_count: number;
    comments_url: string;
    created_at: string;
    last_edited_at: null;
    html_url: string;
    node_id: string;
    number: number;
    pinned: boolean;
    private: boolean;
    team_url: string;
    title: string;
    updated_at: string;
    url: string;
    reactions: TeamsCreateDiscussionResponseReactions;
  };
  type TeamsGetDiscussionResponseReactions = {
    url: string;
    total_count: number;
    "+1": number;
    "-1": number;
    laugh: number;
    confused: number;
    heart: number;
    hooray: number;
  };
  type TeamsGetDiscussionResponseAuthor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type TeamsGetDiscussionResponse = {
    author: TeamsGetDiscussionResponseAuthor;
    body: string;
    body_html: string;
    body_version: string;
    comments_count: number;
    comments_url: string;
    created_at: string;
    last_edited_at: null;
    html_url: string;
    node_id: string;
    number: number;
    pinned: boolean;
    private: boolean;
    team_url: string;
    title: string;
    updated_at: string;
    url: string;
    reactions: TeamsGetDiscussionResponseReactions;
  };
  type TeamsListDiscussionsResponseItemReactions = {
    url: string;
    total_count: number;
    "+1": number;
    "-1": number;
    laugh: number;
    confused: number;
    heart: number;
    hooray: number;
  };
  type TeamsListDiscussionsResponseItemAuthor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type TeamsListDiscussionsResponseItem = {
    author: TeamsListDiscussionsResponseItemAuthor;
    body: string;
    body_html: string;
    body_version: string;
    comments_count: number;
    comments_url: string;
    created_at: string;
    last_edited_at: null;
    html_url: string;
    node_id: string;
    number: number;
    pinned: boolean;
    private: boolean;
    team_url: string;
    title: string;
    updated_at: string;
    url: string;
    reactions: TeamsListDiscussionsResponseItemReactions;
  };
  type TeamsDeleteDiscussionCommentResponse = {};
  type TeamsUpdateDiscussionCommentResponseReactions = {
    url: string;
    total_count: number;
    "+1": number;
    "-1": number;
    laugh: number;
    confused: number;
    heart: number;
    hooray: number;
  };
  type TeamsUpdateDiscussionCommentResponseAuthor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type TeamsUpdateDiscussionCommentResponse = {
    author: TeamsUpdateDiscussionCommentResponseAuthor;
    body: string;
    body_html: string;
    body_version: string;
    created_at: string;
    last_edited_at: string;
    discussion_url: string;
    html_url: string;
    node_id: string;
    number: number;
    updated_at: string;
    url: string;
    reactions: TeamsUpdateDiscussionCommentResponseReactions;
  };
  type TeamsCreateDiscussionCommentResponseReactions = {
    url: string;
    total_count: number;
    "+1": number;
    "-1": number;
    laugh: number;
    confused: number;
    heart: number;
    hooray: number;
  };
  type TeamsCreateDiscussionCommentResponseAuthor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type TeamsCreateDiscussionCommentResponse = {
    author: TeamsCreateDiscussionCommentResponseAuthor;
    body: string;
    body_html: string;
    body_version: string;
    created_at: string;
    last_edited_at: null;
    discussion_url: string;
    html_url: string;
    node_id: string;
    number: number;
    updated_at: string;
    url: string;
    reactions: TeamsCreateDiscussionCommentResponseReactions;
  };
  type TeamsGetDiscussionCommentResponseReactions = {
    url: string;
    total_count: number;
    "+1": number;
    "-1": number;
    laugh: number;
    confused: number;
    heart: number;
    hooray: number;
  };
  type TeamsGetDiscussionCommentResponseAuthor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type TeamsGetDiscussionCommentResponse = {
    author: TeamsGetDiscussionCommentResponseAuthor;
    body: string;
    body_html: string;
    body_version: string;
    created_at: string;
    last_edited_at: null;
    discussion_url: string;
    html_url: string;
    node_id: string;
    number: number;
    updated_at: string;
    url: string;
    reactions: TeamsGetDiscussionCommentResponseReactions;
  };
  type TeamsListDiscussionCommentsResponseItemReactions = {
    url: string;
    total_count: number;
    "+1": number;
    "-1": number;
    laugh: number;
    confused: number;
    heart: number;
    hooray: number;
  };
  type TeamsListDiscussionCommentsResponseItemAuthor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type TeamsListDiscussionCommentsResponseItem = {
    author: TeamsListDiscussionCommentsResponseItemAuthor;
    body: string;
    body_html: string;
    body_version: string;
    created_at: string;
    last_edited_at: null;
    discussion_url: string;
    html_url: string;
    node_id: string;
    number: number;
    updated_at: string;
    url: string;
    reactions: TeamsListDiscussionCommentsResponseItemReactions;
  };
  type TeamsRemoveProjectResponse = {};
  type TeamsAddOrUpdateProjectResponse = {};
  type TeamsReviewProjectResponsePermissions = {
    read: boolean;
    write: boolean;
    admin: boolean;
  };
  type TeamsReviewProjectResponseCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type TeamsReviewProjectResponse = {
    owner_url: string;
    url: string;
    html_url: string;
    columns_url: string;
    id: number;
    node_id: string;
    name: string;
    body: string;
    number: number;
    state: string;
    creator: TeamsReviewProjectResponseCreator;
    created_at: string;
    updated_at: string;
    organization_permission: string;
    private: boolean;
    permissions: TeamsReviewProjectResponsePermissions;
  };
  type TeamsListProjectsResponseItemPermissions = {
    read: boolean;
    write: boolean;
    admin: boolean;
  };
  type TeamsListProjectsResponseItemCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type TeamsListProjectsResponseItem = {
    owner_url: string;
    url: string;
    html_url: string;
    columns_url: string;
    id: number;
    node_id: string;
    name: string;
    body: string;
    number: number;
    state: string;
    creator: TeamsListProjectsResponseItemCreator;
    created_at: string;
    updated_at: string;
    organization_permission: string;
    private: boolean;
    permissions: TeamsListProjectsResponseItemPermissions;
  };
  type TeamsListForAuthenticatedUserResponseItemOrganization = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
    name: string;
    company: string;
    blog: string;
    location: string;
    email: string;
    is_verified: boolean;
    has_organization_projects: boolean;
    has_repository_projects: boolean;
    public_repos: number;
    public_gists: number;
    followers: number;
    following: number;
    html_url: string;
    created_at: string;
    type: string;
  };
  type TeamsListForAuthenticatedUserResponseItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
    members_count: number;
    repos_count: number;
    created_at: string;
    updated_at: string;
    organization: TeamsListForAuthenticatedUserResponseItemOrganization;
  };
  type TeamsRemoveRepoResponse = {};
  type TeamsAddOrUpdateRepoResponse = {};
  type TeamsListReposResponseItemLicense = {
    key: string;
    name: string;
    spdx_id: string;
    url: string;
    node_id: string;
  };
  type TeamsListReposResponseItemPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type TeamsListReposResponseItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type TeamsListReposResponseItem = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: TeamsListReposResponseItemOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: TeamsListReposResponseItemPermissions;
    template_repository: null;
    subscribers_count: number;
    network_count: number;
    license: TeamsListReposResponseItemLicense;
  };
  type TeamsDeleteResponse = {};
  type TeamsUpdateResponseOrganization = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
    name: string;
    company: string;
    blog: string;
    location: string;
    email: string;
    is_verified: boolean;
    has_organization_projects: boolean;
    has_repository_projects: boolean;
    public_repos: number;
    public_gists: number;
    followers: number;
    following: number;
    html_url: string;
    created_at: string;
    type: string;
  };
  type TeamsUpdateResponse = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
    members_count: number;
    repos_count: number;
    created_at: string;
    updated_at: string;
    organization: TeamsUpdateResponseOrganization;
  };
  type TeamsCreateResponseOrganization = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
    name: string;
    company: string;
    blog: string;
    location: string;
    email: string;
    is_verified: boolean;
    has_organization_projects: boolean;
    has_repository_projects: boolean;
    public_repos: number;
    public_gists: number;
    followers: number;
    following: number;
    html_url: string;
    created_at: string;
    type: string;
  };
  type TeamsCreateResponse = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
    members_count: number;
    repos_count: number;
    created_at: string;
    updated_at: string;
    organization: TeamsCreateResponseOrganization;
  };
  type TeamsGetByNameResponseOrganization = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
    name: string;
    company: string;
    blog: string;
    location: string;
    email: string;
    is_verified: boolean;
    has_organization_projects: boolean;
    has_repository_projects: boolean;
    public_repos: number;
    public_gists: number;
    followers: number;
    following: number;
    html_url: string;
    created_at: string;
    type: string;
  };
  type TeamsGetByNameResponse = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
    members_count: number;
    repos_count: number;
    created_at: string;
    updated_at: string;
    organization: TeamsGetByNameResponseOrganization;
  };
  type TeamsGetResponseOrganization = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
    name: string;
    company: string;
    blog: string;
    location: string;
    email: string;
    is_verified: boolean;
    has_organization_projects: boolean;
    has_repository_projects: boolean;
    public_repos: number;
    public_gists: number;
    followers: number;
    following: number;
    html_url: string;
    created_at: string;
    type: string;
  };
  type TeamsGetResponse = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
    members_count: number;
    repos_count: number;
    created_at: string;
    updated_at: string;
    organization: TeamsGetResponseOrganization;
  };
  type TeamsListResponseItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
  };
  type ReposGetClonesResponseClonesItem = {
    timestamp: string;
    count: number;
    uniques: number;
  };
  type ReposGetClonesResponse = {
    count: number;
    uniques: number;
    clones: Array<ReposGetClonesResponseClonesItem>;
  };
  type ReposGetViewsResponseViewsItem = {
    timestamp: string;
    count: number;
    uniques: number;
  };
  type ReposGetViewsResponse = {
    count: number;
    uniques: number;
    views: Array<ReposGetViewsResponseViewsItem>;
  };
  type ReposGetTopPathsResponseItem = {
    path: string;
    title: string;
    count: number;
    uniques: number;
  };
  type ReposGetTopReferrersResponseItem = {
    referrer: string;
    count: number;
    uniques: number;
  };
  type ReposGetCombinedStatusForRefResponseRepositoryOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetCombinedStatusForRefResponseRepository = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ReposGetCombinedStatusForRefResponseRepositoryOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
  };
  type ReposGetCombinedStatusForRefResponseStatusesItem = {
    url: string;
    avatar_url: string;
    id: number;
    node_id: string;
    state: string;
    description: string;
    target_url: string;
    context: string;
    created_at: string;
    updated_at: string;
  };
  type ReposGetCombinedStatusForRefResponse = {
    state: string;
    statuses: Array<ReposGetCombinedStatusForRefResponseStatusesItem>;
    sha: string;
    total_count: number;
    repository: ReposGetCombinedStatusForRefResponseRepository;
    commit_url: string;
    url: string;
  };
  type ReposListStatusesForRefResponseItemCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListStatusesForRefResponseItem = {
    url: string;
    avatar_url: string;
    id: number;
    node_id: string;
    state: string;
    description: string;
    target_url: string;
    context: string;
    created_at: string;
    updated_at: string;
    creator: ReposListStatusesForRefResponseItemCreator;
  };
  type ReposCreateStatusResponseCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposCreateStatusResponse = {
    url: string;
    avatar_url: string;
    id: number;
    node_id: string;
    state: string;
    description: string;
    target_url: string;
    context: string;
    created_at: string;
    updated_at: string;
    creator: ReposCreateStatusResponseCreator;
  };
  type ReposGetParticipationStatsResponse = {
    all: Array<number>;
    owner: Array<number>;
  };
  type ReposGetCommitActivityStatsResponseItem = {
    days: Array<number>;
    total: number;
    week: number;
  };
  type ReposGetContributorsStatsResponseItemWeeksItem = {
    w: string;
    a: number;
    d: number;
    c: number;
  };
  type ReposGetContributorsStatsResponseItemAuthor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetContributorsStatsResponseItem = {
    author: ReposGetContributorsStatsResponseItemAuthor;
    total: number;
    weeks: Array<ReposGetContributorsStatsResponseItemWeeksItem>;
  };
  type ReposDeleteReleaseAssetResponse = {};
  type ReposUpdateReleaseAssetResponseUploader = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposUpdateReleaseAssetResponse = {
    url: string;
    browser_download_url: string;
    id: number;
    node_id: string;
    name: string;
    label: string;
    state: string;
    content_type: string;
    size: number;
    download_count: number;
    created_at: string;
    updated_at: string;
    uploader: ReposUpdateReleaseAssetResponseUploader;
  };
  type ReposGetReleaseAssetResponseUploader = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetReleaseAssetResponse = {
    url: string;
    browser_download_url: string;
    id: number;
    node_id: string;
    name: string;
    label: string;
    state: string;
    content_type: string;
    size: number;
    download_count: number;
    created_at: string;
    updated_at: string;
    uploader: ReposGetReleaseAssetResponseUploader;
  };
  type ReposListAssetsForReleaseResponseItemUploader = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListAssetsForReleaseResponseItem = {
    url: string;
    browser_download_url: string;
    id: number;
    node_id: string;
    name: string;
    label: string;
    state: string;
    content_type: string;
    size: number;
    download_count: number;
    created_at: string;
    updated_at: string;
    uploader: ReposListAssetsForReleaseResponseItemUploader;
  };
  type ReposDeleteReleaseResponse = {};
  type ReposUpdateReleaseResponseAssetsItemUploader = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposUpdateReleaseResponseAssetsItem = {
    url: string;
    browser_download_url: string;
    id: number;
    node_id: string;
    name: string;
    label: string;
    state: string;
    content_type: string;
    size: number;
    download_count: number;
    created_at: string;
    updated_at: string;
    uploader: ReposUpdateReleaseResponseAssetsItemUploader;
  };
  type ReposUpdateReleaseResponseAuthor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposUpdateReleaseResponse = {
    url: string;
    html_url: string;
    assets_url: string;
    upload_url: string;
    tarball_url: string;
    zipball_url: string;
    id: number;
    node_id: string;
    tag_name: string;
    target_commitish: string;
    name: string;
    body: string;
    draft: boolean;
    prerelease: boolean;
    created_at: string;
    published_at: string;
    author: ReposUpdateReleaseResponseAuthor;
    assets: Array<ReposUpdateReleaseResponseAssetsItem>;
  };
  type ReposCreateReleaseResponseAuthor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposCreateReleaseResponse = {
    url: string;
    html_url: string;
    assets_url: string;
    upload_url: string;
    tarball_url: string;
    zipball_url: string;
    id: number;
    node_id: string;
    tag_name: string;
    target_commitish: string;
    name: string;
    body: string;
    draft: boolean;
    prerelease: boolean;
    created_at: string;
    published_at: string;
    author: ReposCreateReleaseResponseAuthor;
    assets: Array<any>;
  };
  type ReposGetReleaseByTagResponseAssetsItemUploader = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetReleaseByTagResponseAssetsItem = {
    url: string;
    browser_download_url: string;
    id: number;
    node_id: string;
    name: string;
    label: string;
    state: string;
    content_type: string;
    size: number;
    download_count: number;
    created_at: string;
    updated_at: string;
    uploader: ReposGetReleaseByTagResponseAssetsItemUploader;
  };
  type ReposGetReleaseByTagResponseAuthor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetReleaseByTagResponse = {
    url: string;
    html_url: string;
    assets_url: string;
    upload_url: string;
    tarball_url: string;
    zipball_url: string;
    id: number;
    node_id: string;
    tag_name: string;
    target_commitish: string;
    name: string;
    body: string;
    draft: boolean;
    prerelease: boolean;
    created_at: string;
    published_at: string;
    author: ReposGetReleaseByTagResponseAuthor;
    assets: Array<ReposGetReleaseByTagResponseAssetsItem>;
  };
  type ReposGetLatestReleaseResponseAssetsItemUploader = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetLatestReleaseResponseAssetsItem = {
    url: string;
    browser_download_url: string;
    id: number;
    node_id: string;
    name: string;
    label: string;
    state: string;
    content_type: string;
    size: number;
    download_count: number;
    created_at: string;
    updated_at: string;
    uploader: ReposGetLatestReleaseResponseAssetsItemUploader;
  };
  type ReposGetLatestReleaseResponseAuthor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetLatestReleaseResponse = {
    url: string;
    html_url: string;
    assets_url: string;
    upload_url: string;
    tarball_url: string;
    zipball_url: string;
    id: number;
    node_id: string;
    tag_name: string;
    target_commitish: string;
    name: string;
    body: string;
    draft: boolean;
    prerelease: boolean;
    created_at: string;
    published_at: string;
    author: ReposGetLatestReleaseResponseAuthor;
    assets: Array<ReposGetLatestReleaseResponseAssetsItem>;
  };
  type ReposGetReleaseResponseAssetsItemUploader = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetReleaseResponseAssetsItem = {
    url: string;
    browser_download_url: string;
    id: number;
    node_id: string;
    name: string;
    label: string;
    state: string;
    content_type: string;
    size: number;
    download_count: number;
    created_at: string;
    updated_at: string;
    uploader: ReposGetReleaseResponseAssetsItemUploader;
  };
  type ReposGetReleaseResponseAuthor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetReleaseResponse = {
    url: string;
    html_url: string;
    assets_url: string;
    upload_url: string;
    tarball_url: string;
    zipball_url: string;
    id: number;
    node_id: string;
    tag_name: string;
    target_commitish: string;
    name: string;
    body: string;
    draft: boolean;
    prerelease: boolean;
    created_at: string;
    published_at: string;
    author: ReposGetReleaseResponseAuthor;
    assets: Array<ReposGetReleaseResponseAssetsItem>;
  };
  type ReposListReleasesResponseItemAssetsItemUploader = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListReleasesResponseItemAssetsItem = {
    url: string;
    browser_download_url: string;
    id: number;
    node_id: string;
    name: string;
    label: string;
    state: string;
    content_type: string;
    size: number;
    download_count: number;
    created_at: string;
    updated_at: string;
    uploader: ReposListReleasesResponseItemAssetsItemUploader;
  };
  type ReposListReleasesResponseItemAuthor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListReleasesResponseItem = {
    url: string;
    html_url: string;
    assets_url: string;
    upload_url: string;
    tarball_url: string;
    zipball_url: string;
    id: number;
    node_id: string;
    tag_name: string;
    target_commitish: string;
    name: string;
    body: string;
    draft: boolean;
    prerelease: boolean;
    created_at: string;
    published_at: string;
    author: ReposListReleasesResponseItemAuthor;
    assets: Array<ReposListReleasesResponseItemAssetsItem>;
  };
  type ReposGetPagesBuildResponsePusher = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetPagesBuildResponseError = { message: null };
  type ReposGetPagesBuildResponse = {
    url: string;
    status: string;
    error: ReposGetPagesBuildResponseError;
    pusher: ReposGetPagesBuildResponsePusher;
    commit: string;
    duration: number;
    created_at: string;
    updated_at: string;
  };
  type ReposGetLatestPagesBuildResponsePusher = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetLatestPagesBuildResponseError = { message: null };
  type ReposGetLatestPagesBuildResponse = {
    url: string;
    status: string;
    error: ReposGetLatestPagesBuildResponseError;
    pusher: ReposGetLatestPagesBuildResponsePusher;
    commit: string;
    duration: number;
    created_at: string;
    updated_at: string;
  };
  type ReposListPagesBuildsResponseItemPusher = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListPagesBuildsResponseItemError = { message: null };
  type ReposListPagesBuildsResponseItem = {
    url: string;
    status: string;
    error: ReposListPagesBuildsResponseItemError;
    pusher: ReposListPagesBuildsResponseItemPusher;
    commit: string;
    duration: number;
    created_at: string;
    updated_at: string;
  };
  type ReposRequestPageBuildResponse = { url: string; status: string };
  type ReposUpdateInformationAboutPagesSiteResponse = {};
  type ReposDisablePagesSiteResponse = {};
  type ReposEnablePagesSiteResponseSource = {
    branch: string;
    directory: string;
  };
  type ReposEnablePagesSiteResponse = {
    url: string;
    status: string;
    cname: string;
    custom_404: boolean;
    html_url: string;
    source: ReposEnablePagesSiteResponseSource;
  };
  type ReposGetPagesResponseSource = { branch: string; directory: string };
  type ReposGetPagesResponse = {
    url: string;
    status: string;
    cname: string;
    custom_404: boolean;
    html_url: string;
    source: ReposGetPagesResponseSource;
  };
  type ReposRemoveDeployKeyResponse = {};
  type ReposAddDeployKeyResponse = {
    id: number;
    key: string;
    url: string;
    title: string;
    verified: boolean;
    created_at: string;
    read_only: boolean;
  };
  type ReposGetDeployKeyResponse = {
    id: number;
    key: string;
    url: string;
    title: string;
    verified: boolean;
    created_at: string;
    read_only: boolean;
  };
  type ReposListDeployKeysResponseItem = {
    id: number;
    key: string;
    url: string;
    title: string;
    verified: boolean;
    created_at: string;
    read_only: boolean;
  };
  type ReposDeclineInvitationResponse = {};
  type ReposAcceptInvitationResponse = {};
  type ReposListInvitationsForAuthenticatedUserResponseItemInviter = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListInvitationsForAuthenticatedUserResponseItemInvitee = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListInvitationsForAuthenticatedUserResponseItemRepositoryOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListInvitationsForAuthenticatedUserResponseItemRepository = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ReposListInvitationsForAuthenticatedUserResponseItemRepositoryOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
  };
  type ReposListInvitationsForAuthenticatedUserResponseItem = {
    id: number;
    repository: ReposListInvitationsForAuthenticatedUserResponseItemRepository;
    invitee: ReposListInvitationsForAuthenticatedUserResponseItemInvitee;
    inviter: ReposListInvitationsForAuthenticatedUserResponseItemInviter;
    permissions: string;
    created_at: string;
    url: string;
    html_url: string;
  };
  type ReposUpdateInvitationResponseInviter = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposUpdateInvitationResponseInvitee = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposUpdateInvitationResponseRepositoryOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposUpdateInvitationResponseRepository = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ReposUpdateInvitationResponseRepositoryOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
  };
  type ReposUpdateInvitationResponse = {
    id: number;
    repository: ReposUpdateInvitationResponseRepository;
    invitee: ReposUpdateInvitationResponseInvitee;
    inviter: ReposUpdateInvitationResponseInviter;
    permissions: string;
    created_at: string;
    url: string;
    html_url: string;
  };
  type ReposDeleteInvitationResponse = {};
  type ReposListInvitationsResponseItemInviter = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListInvitationsResponseItemInvitee = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListInvitationsResponseItemRepositoryOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListInvitationsResponseItemRepository = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ReposListInvitationsResponseItemRepositoryOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
  };
  type ReposListInvitationsResponseItem = {
    id: number;
    repository: ReposListInvitationsResponseItemRepository;
    invitee: ReposListInvitationsResponseItemInvitee;
    inviter: ReposListInvitationsResponseItemInviter;
    permissions: string;
    created_at: string;
    url: string;
    html_url: string;
  };
  type ReposDeleteHookResponse = {};
  type ReposPingHookResponse = {};
  type ReposTestPushHookResponse = {};
  type ReposUpdateHookResponseLastResponse = {
    code: null;
    status: string;
    message: null;
  };
  type ReposUpdateHookResponseConfig = {
    content_type: string;
    insecure_ssl: string;
    url: string;
  };
  type ReposUpdateHookResponse = {
    type: string;
    id: number;
    name: string;
    active: boolean;
    events: Array<string>;
    config: ReposUpdateHookResponseConfig;
    updated_at: string;
    created_at: string;
    url: string;
    test_url: string;
    ping_url: string;
    last_response: ReposUpdateHookResponseLastResponse;
  };
  type ReposCreateHookResponseLastResponse = {
    code: null;
    status: string;
    message: null;
  };
  type ReposCreateHookResponseConfig = {
    content_type: string;
    insecure_ssl: string;
    url: string;
  };
  type ReposCreateHookResponse = {
    type: string;
    id: number;
    name: string;
    active: boolean;
    events: Array<string>;
    config: ReposCreateHookResponseConfig;
    updated_at: string;
    created_at: string;
    url: string;
    test_url: string;
    ping_url: string;
    last_response: ReposCreateHookResponseLastResponse;
  };
  type ReposGetHookResponseLastResponse = {
    code: null;
    status: string;
    message: null;
  };
  type ReposGetHookResponseConfig = {
    content_type: string;
    insecure_ssl: string;
    url: string;
  };
  type ReposGetHookResponse = {
    type: string;
    id: number;
    name: string;
    active: boolean;
    events: Array<string>;
    config: ReposGetHookResponseConfig;
    updated_at: string;
    created_at: string;
    url: string;
    test_url: string;
    ping_url: string;
    last_response: ReposGetHookResponseLastResponse;
  };
  type ReposListHooksResponseItemLastResponse = {
    code: null;
    status: string;
    message: null;
  };
  type ReposListHooksResponseItemConfig = {
    content_type: string;
    insecure_ssl: string;
    url: string;
  };
  type ReposListHooksResponseItem = {
    type: string;
    id: number;
    name: string;
    active: boolean;
    events: Array<string>;
    config: ReposListHooksResponseItemConfig;
    updated_at: string;
    created_at: string;
    url: string;
    test_url: string;
    ping_url: string;
    last_response: ReposListHooksResponseItemLastResponse;
  };
  type ReposCreateForkResponsePermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ReposCreateForkResponseOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposCreateForkResponse = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ReposCreateForkResponseOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ReposCreateForkResponsePermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type ReposListForksResponseItemLicense = {
    key: string;
    name: string;
    spdx_id: string;
    url: string;
    node_id: string;
  };
  type ReposListForksResponseItemPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ReposListForksResponseItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListForksResponseItem = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ReposListForksResponseItemOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ReposListForksResponseItemPermissions;
    template_repository: null;
    subscribers_count: number;
    network_count: number;
    license: ReposListForksResponseItemLicense;
  };
  type ReposDeleteDownloadResponse = {};
  type ReposGetDownloadResponse = {
    url: string;
    html_url: string;
    id: number;
    name: string;
    description: string;
    size: number;
    download_count: number;
    content_type: string;
  };
  type ReposListDownloadsResponseItem = {
    url: string;
    html_url: string;
    id: number;
    name: string;
    description: string;
    size: number;
    download_count: number;
    content_type: string;
  };
  type ReposCreateDeploymentStatusResponseCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposCreateDeploymentStatusResponse = {
    url: string;
    id: number;
    node_id: string;
    state: string;
    creator: ReposCreateDeploymentStatusResponseCreator;
    description: string;
    environment: string;
    target_url: string;
    created_at: string;
    updated_at: string;
    deployment_url: string;
    repository_url: string;
    environment_url: string;
    log_url: string;
  };
  type ReposGetDeploymentStatusResponseCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetDeploymentStatusResponse = {
    url: string;
    id: number;
    node_id: string;
    state: string;
    creator: ReposGetDeploymentStatusResponseCreator;
    description: string;
    environment: string;
    target_url: string;
    created_at: string;
    updated_at: string;
    deployment_url: string;
    repository_url: string;
    environment_url: string;
    log_url: string;
  };
  type ReposListDeploymentStatusesResponseItemCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListDeploymentStatusesResponseItem = {
    url: string;
    id: number;
    node_id: string;
    state: string;
    creator: ReposListDeploymentStatusesResponseItemCreator;
    description: string;
    environment: string;
    target_url: string;
    created_at: string;
    updated_at: string;
    deployment_url: string;
    repository_url: string;
    environment_url: string;
    log_url: string;
  };
  type ReposGetDeploymentResponseCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetDeploymentResponsePayload = { deploy: string };
  type ReposGetDeploymentResponse = {
    url: string;
    id: number;
    node_id: string;
    sha: string;
    ref: string;
    task: string;
    payload: ReposGetDeploymentResponsePayload;
    original_environment: string;
    environment: string;
    description: string;
    creator: ReposGetDeploymentResponseCreator;
    created_at: string;
    updated_at: string;
    statuses_url: string;
    repository_url: string;
    transient_environment: boolean;
    production_environment: boolean;
  };
  type ReposListDeploymentsResponseItemCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListDeploymentsResponseItemPayload = { deploy: string };
  type ReposListDeploymentsResponseItem = {
    url: string;
    id: number;
    node_id: string;
    sha: string;
    ref: string;
    task: string;
    payload: ReposListDeploymentsResponseItemPayload;
    original_environment: string;
    environment: string;
    description: string;
    creator: ReposListDeploymentsResponseItemCreator;
    created_at: string;
    updated_at: string;
    statuses_url: string;
    repository_url: string;
    transient_environment: boolean;
    production_environment: boolean;
  };
  type ReposGetArchiveLinkResponse = {};
  type ReposDeleteFileResponseCommitVerification = {
    verified: boolean;
    reason: string;
    signature: null;
    payload: null;
  };
  type ReposDeleteFileResponseCommitParentsItem = {
    url: string;
    html_url: string;
    sha: string;
  };
  type ReposDeleteFileResponseCommitTree = { url: string; sha: string };
  type ReposDeleteFileResponseCommitCommitter = {
    date: string;
    name: string;
    email: string;
  };
  type ReposDeleteFileResponseCommitAuthor = {
    date: string;
    name: string;
    email: string;
  };
  type ReposDeleteFileResponseCommit = {
    sha: string;
    node_id: string;
    url: string;
    html_url: string;
    author: ReposDeleteFileResponseCommitAuthor;
    committer: ReposDeleteFileResponseCommitCommitter;
    message: string;
    tree: ReposDeleteFileResponseCommitTree;
    parents: Array<ReposDeleteFileResponseCommitParentsItem>;
    verification: ReposDeleteFileResponseCommitVerification;
  };
  type ReposDeleteFileResponse = {
    content: null;
    commit: ReposDeleteFileResponseCommit;
  };
  type ReposUpdateFileResponseCommitVerification = {
    verified: boolean;
    reason: string;
    signature: null;
    payload: null;
  };
  type ReposUpdateFileResponseCommitParentsItem = {
    url: string;
    html_url: string;
    sha: string;
  };
  type ReposUpdateFileResponseCommitTree = { url: string; sha: string };
  type ReposUpdateFileResponseCommitCommitter = {
    date: string;
    name: string;
    email: string;
  };
  type ReposUpdateFileResponseCommitAuthor = {
    date: string;
    name: string;
    email: string;
  };
  type ReposUpdateFileResponseCommit = {
    sha: string;
    node_id: string;
    url: string;
    html_url: string;
    author: ReposUpdateFileResponseCommitAuthor;
    committer: ReposUpdateFileResponseCommitCommitter;
    message: string;
    tree: ReposUpdateFileResponseCommitTree;
    parents: Array<ReposUpdateFileResponseCommitParentsItem>;
    verification: ReposUpdateFileResponseCommitVerification;
  };
  type ReposUpdateFileResponseContentLinks = {
    self: string;
    git: string;
    html: string;
  };
  type ReposUpdateFileResponseContent = {
    name: string;
    path: string;
    sha: string;
    size: number;
    url: string;
    html_url: string;
    git_url: string;
    download_url: string;
    type: string;
    _links: ReposUpdateFileResponseContentLinks;
  };
  type ReposUpdateFileResponse = {
    content: ReposUpdateFileResponseContent;
    commit: ReposUpdateFileResponseCommit;
  };
  type ReposCreateFileResponseCommitVerification = {
    verified: boolean;
    reason: string;
    signature: null;
    payload: null;
  };
  type ReposCreateFileResponseCommitParentsItem = {
    url: string;
    html_url: string;
    sha: string;
  };
  type ReposCreateFileResponseCommitTree = { url: string; sha: string };
  type ReposCreateFileResponseCommitCommitter = {
    date: string;
    name: string;
    email: string;
  };
  type ReposCreateFileResponseCommitAuthor = {
    date: string;
    name: string;
    email: string;
  };
  type ReposCreateFileResponseCommit = {
    sha: string;
    node_id: string;
    url: string;
    html_url: string;
    author: ReposCreateFileResponseCommitAuthor;
    committer: ReposCreateFileResponseCommitCommitter;
    message: string;
    tree: ReposCreateFileResponseCommitTree;
    parents: Array<ReposCreateFileResponseCommitParentsItem>;
    verification: ReposCreateFileResponseCommitVerification;
  };
  type ReposCreateFileResponseContentLinks = {
    self: string;
    git: string;
    html: string;
  };
  type ReposCreateFileResponseContent = {
    name: string;
    path: string;
    sha: string;
    size: number;
    url: string;
    html_url: string;
    git_url: string;
    download_url: string;
    type: string;
    _links: ReposCreateFileResponseContentLinks;
  };
  type ReposCreateFileResponse = {
    content: ReposCreateFileResponseContent;
    commit: ReposCreateFileResponseCommit;
  };
  type ReposCreateOrUpdateFileResponseCommitVerification = {
    verified: boolean;
    reason: string;
    signature: null;
    payload: null;
  };
  type ReposCreateOrUpdateFileResponseCommitParentsItem = {
    url: string;
    html_url: string;
    sha: string;
  };
  type ReposCreateOrUpdateFileResponseCommitTree = { url: string; sha: string };
  type ReposCreateOrUpdateFileResponseCommitCommitter = {
    date: string;
    name: string;
    email: string;
  };
  type ReposCreateOrUpdateFileResponseCommitAuthor = {
    date: string;
    name: string;
    email: string;
  };
  type ReposCreateOrUpdateFileResponseCommit = {
    sha: string;
    node_id: string;
    url: string;
    html_url: string;
    author: ReposCreateOrUpdateFileResponseCommitAuthor;
    committer: ReposCreateOrUpdateFileResponseCommitCommitter;
    message: string;
    tree: ReposCreateOrUpdateFileResponseCommitTree;
    parents: Array<ReposCreateOrUpdateFileResponseCommitParentsItem>;
    verification: ReposCreateOrUpdateFileResponseCommitVerification;
  };
  type ReposCreateOrUpdateFileResponseContentLinks = {
    self: string;
    git: string;
    html: string;
  };
  type ReposCreateOrUpdateFileResponseContent = {
    name: string;
    path: string;
    sha: string;
    size: number;
    url: string;
    html_url: string;
    git_url: string;
    download_url: string;
    type: string;
    _links: ReposCreateOrUpdateFileResponseContentLinks;
  };
  type ReposCreateOrUpdateFileResponse = {
    content: ReposCreateOrUpdateFileResponseContent;
    commit: ReposCreateOrUpdateFileResponseCommit;
  };
  type ReposGetReadmeResponseLinks = {
    git: string;
    self: string;
    html: string;
  };
  type ReposGetReadmeResponse = {
    type: string;
    encoding: string;
    size: number;
    name: string;
    path: string;
    content: string;
    sha: string;
    url: string;
    git_url: string;
    html_url: string;
    download_url: string;
    _links: ReposGetReadmeResponseLinks;
  };
  type ReposRetrieveCommunityProfileMetricsResponseFilesReadme = {
    url: string;
    html_url: string;
  };
  type ReposRetrieveCommunityProfileMetricsResponseFilesLicense = {
    name: string;
    key: string;
    spdx_id: string;
    url: string;
    html_url: string;
  };
  type ReposRetrieveCommunityProfileMetricsResponseFilesPullRequestTemplate = {
    url: string;
    html_url: string;
  };
  type ReposRetrieveCommunityProfileMetricsResponseFilesIssueTemplate = {
    url: string;
    html_url: string;
  };
  type ReposRetrieveCommunityProfileMetricsResponseFilesContributing = {
    url: string;
    html_url: string;
  };
  type ReposRetrieveCommunityProfileMetricsResponseFilesCodeOfConduct = {
    name: string;
    key: string;
    url: string;
    html_url: string;
  };
  type ReposRetrieveCommunityProfileMetricsResponseFiles = {
    code_of_conduct: ReposRetrieveCommunityProfileMetricsResponseFilesCodeOfConduct;
    contributing: ReposRetrieveCommunityProfileMetricsResponseFilesContributing;
    issue_template: ReposRetrieveCommunityProfileMetricsResponseFilesIssueTemplate;
    pull_request_template: ReposRetrieveCommunityProfileMetricsResponseFilesPullRequestTemplate;
    license: ReposRetrieveCommunityProfileMetricsResponseFilesLicense;
    readme: ReposRetrieveCommunityProfileMetricsResponseFilesReadme;
  };
  type ReposRetrieveCommunityProfileMetricsResponse = {
    health_percentage: number;
    description: string;
    documentation: boolean;
    files: ReposRetrieveCommunityProfileMetricsResponseFiles;
    updated_at: string;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemLinksStatuses = {
    href: string;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemLinksCommits = {
    href: string;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemLinksReviewComment = {
    href: string;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemLinksReviewComments = {
    href: string;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemLinksComments = {
    href: string;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemLinksIssue = {
    href: string;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemLinksHtml = {
    href: string;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemLinksSelf = {
    href: string;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemLinks = {
    self: ReposListPullRequestsAssociatedWithCommitResponseItemLinksSelf;
    html: ReposListPullRequestsAssociatedWithCommitResponseItemLinksHtml;
    issue: ReposListPullRequestsAssociatedWithCommitResponseItemLinksIssue;
    comments: ReposListPullRequestsAssociatedWithCommitResponseItemLinksComments;
    review_comments: ReposListPullRequestsAssociatedWithCommitResponseItemLinksReviewComments;
    review_comment: ReposListPullRequestsAssociatedWithCommitResponseItemLinksReviewComment;
    commits: ReposListPullRequestsAssociatedWithCommitResponseItemLinksCommits;
    statuses: ReposListPullRequestsAssociatedWithCommitResponseItemLinksStatuses;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemBaseRepoPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemBaseRepoOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemBaseRepo = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ReposListPullRequestsAssociatedWithCommitResponseItemBaseRepoOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ReposListPullRequestsAssociatedWithCommitResponseItemBaseRepoPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemBaseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemBase = {
    label: string;
    ref: string;
    sha: string;
    user: ReposListPullRequestsAssociatedWithCommitResponseItemBaseUser;
    repo: ReposListPullRequestsAssociatedWithCommitResponseItemBaseRepo;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemHeadRepoPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemHeadRepoOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemHeadRepo = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ReposListPullRequestsAssociatedWithCommitResponseItemHeadRepoOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ReposListPullRequestsAssociatedWithCommitResponseItemHeadRepoPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemHeadUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemHead = {
    label: string;
    ref: string;
    sha: string;
    user: ReposListPullRequestsAssociatedWithCommitResponseItemHeadUser;
    repo: ReposListPullRequestsAssociatedWithCommitResponseItemHeadRepo;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemRequestedTeamsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemRequestedReviewersItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemAssigneesItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemAssignee = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemMilestoneCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemMilestone = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: ReposListPullRequestsAssociatedWithCommitResponseItemMilestoneCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemLabelsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListPullRequestsAssociatedWithCommitResponseItem = {
    url: string;
    id: number;
    node_id: string;
    html_url: string;
    diff_url: string;
    patch_url: string;
    issue_url: string;
    commits_url: string;
    review_comments_url: string;
    review_comment_url: string;
    comments_url: string;
    statuses_url: string;
    number: number;
    state: string;
    locked: boolean;
    title: string;
    user: ReposListPullRequestsAssociatedWithCommitResponseItemUser;
    body: string;
    labels: Array<
      ReposListPullRequestsAssociatedWithCommitResponseItemLabelsItem
    >;
    milestone: ReposListPullRequestsAssociatedWithCommitResponseItemMilestone;
    active_lock_reason: string;
    created_at: string;
    updated_at: string;
    closed_at: string;
    merged_at: string;
    merge_commit_sha: string;
    assignee: ReposListPullRequestsAssociatedWithCommitResponseItemAssignee;
    assignees: Array<
      ReposListPullRequestsAssociatedWithCommitResponseItemAssigneesItem
    >;
    requested_reviewers: Array<
      ReposListPullRequestsAssociatedWithCommitResponseItemRequestedReviewersItem
    >;
    requested_teams: Array<
      ReposListPullRequestsAssociatedWithCommitResponseItemRequestedTeamsItem
    >;
    head: ReposListPullRequestsAssociatedWithCommitResponseItemHead;
    base: ReposListPullRequestsAssociatedWithCommitResponseItemBase;
    _links: ReposListPullRequestsAssociatedWithCommitResponseItemLinks;
    author_association: string;
    draft: boolean;
  };
  type ReposListBranchesForHeadCommitResponseItemCommit = {
    sha: string;
    url: string;
  };
  type ReposListBranchesForHeadCommitResponseItem = {
    name: string;
    commit: ReposListBranchesForHeadCommitResponseItemCommit;
    protected: string;
  };
  type ReposGetCommitRefShaResponse = {};
  type ReposGetCommitResponseFilesItem = {
    filename: string;
    additions: number;
    deletions: number;
    changes: number;
    status: string;
    raw_url: string;
    blob_url: string;
    patch: string;
  };
  type ReposGetCommitResponseStats = {
    additions: number;
    deletions: number;
    total: number;
  };
  type ReposGetCommitResponseParentsItem = { url: string; sha: string };
  type ReposGetCommitResponseCommitter = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetCommitResponseAuthor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetCommitResponseCommitVerification = {
    verified: boolean;
    reason: string;
    signature: null;
    payload: null;
  };
  type ReposGetCommitResponseCommitTree = { url: string; sha: string };
  type ReposGetCommitResponseCommitCommitter = {
    name: string;
    email: string;
    date: string;
  };
  type ReposGetCommitResponseCommitAuthor = {
    name: string;
    email: string;
    date: string;
  };
  type ReposGetCommitResponseCommit = {
    url: string;
    author: ReposGetCommitResponseCommitAuthor;
    committer: ReposGetCommitResponseCommitCommitter;
    message: string;
    tree: ReposGetCommitResponseCommitTree;
    comment_count: number;
    verification: ReposGetCommitResponseCommitVerification;
  };
  type ReposGetCommitResponse = {
    url: string;
    sha: string;
    node_id: string;
    html_url: string;
    comments_url: string;
    commit: ReposGetCommitResponseCommit;
    author: ReposGetCommitResponseAuthor;
    committer: ReposGetCommitResponseCommitter;
    parents: Array<ReposGetCommitResponseParentsItem>;
    stats: ReposGetCommitResponseStats;
    files: Array<ReposGetCommitResponseFilesItem>;
  };
  type ReposListCommitsResponseItemParentsItem = { url: string; sha: string };
  type ReposListCommitsResponseItemCommitter = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListCommitsResponseItemAuthor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListCommitsResponseItemCommitVerification = {
    verified: boolean;
    reason: string;
    signature: null;
    payload: null;
  };
  type ReposListCommitsResponseItemCommitTree = { url: string; sha: string };
  type ReposListCommitsResponseItemCommitCommitter = {
    name: string;
    email: string;
    date: string;
  };
  type ReposListCommitsResponseItemCommitAuthor = {
    name: string;
    email: string;
    date: string;
  };
  type ReposListCommitsResponseItemCommit = {
    url: string;
    author: ReposListCommitsResponseItemCommitAuthor;
    committer: ReposListCommitsResponseItemCommitCommitter;
    message: string;
    tree: ReposListCommitsResponseItemCommitTree;
    comment_count: number;
    verification: ReposListCommitsResponseItemCommitVerification;
  };
  type ReposListCommitsResponseItem = {
    url: string;
    sha: string;
    node_id: string;
    html_url: string;
    comments_url: string;
    commit: ReposListCommitsResponseItemCommit;
    author: ReposListCommitsResponseItemAuthor;
    committer: ReposListCommitsResponseItemCommitter;
    parents: Array<ReposListCommitsResponseItemParentsItem>;
  };
  type ReposDeleteCommitCommentResponse = {};
  type ReposUpdateCommitCommentResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposUpdateCommitCommentResponse = {
    html_url: string;
    url: string;
    id: number;
    node_id: string;
    body: string;
    path: string;
    position: number;
    line: number;
    commit_id: string;
    user: ReposUpdateCommitCommentResponseUser;
    created_at: string;
    updated_at: string;
  };
  type ReposGetCommitCommentResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetCommitCommentResponse = {
    html_url: string;
    url: string;
    id: number;
    node_id: string;
    body: string;
    path: string;
    position: number;
    line: number;
    commit_id: string;
    user: ReposGetCommitCommentResponseUser;
    created_at: string;
    updated_at: string;
  };
  type ReposCreateCommitCommentResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposCreateCommitCommentResponse = {
    html_url: string;
    url: string;
    id: number;
    node_id: string;
    body: string;
    path: string;
    position: number;
    line: number;
    commit_id: string;
    user: ReposCreateCommitCommentResponseUser;
    created_at: string;
    updated_at: string;
  };
  type ReposListCommentsForCommitResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListCommentsForCommitResponseItem = {
    html_url: string;
    url: string;
    id: number;
    node_id: string;
    body: string;
    path: string;
    position: number;
    line: number;
    commit_id: string;
    user: ReposListCommentsForCommitResponseItemUser;
    created_at: string;
    updated_at: string;
  };
  type ReposListCommitCommentsResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListCommitCommentsResponseItem = {
    html_url: string;
    url: string;
    id: number;
    node_id: string;
    body: string;
    path: string;
    position: number;
    line: number;
    commit_id: string;
    user: ReposListCommitCommentsResponseItemUser;
    created_at: string;
    updated_at: string;
  };
  type ReposRemoveCollaboratorResponse = {};
  type ReposListCollaboratorsResponseItemPermissions = {
    pull: boolean;
    push: boolean;
    admin: boolean;
  };
  type ReposListCollaboratorsResponseItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
    permissions: ReposListCollaboratorsResponseItemPermissions;
  };
  type ReposRemoveProtectedBranchUserRestrictionsResponseItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposAddProtectedBranchUserRestrictionsResponseItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposReplaceProtectedBranchUserRestrictionsResponseItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposRemoveProtectedBranchTeamRestrictionsResponseItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
  };
  type ReposAddProtectedBranchTeamRestrictionsResponseItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
  };
  type ReposReplaceProtectedBranchTeamRestrictionsResponseItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
  };
  type ReposAddProtectedBranchAdminEnforcementResponse = {
    url: string;
    enabled: boolean;
  };
  type ReposAddProtectedBranchRequiredSignaturesResponse = {
    url: string;
    enabled: boolean;
  };
  type ReposGetProtectedBranchRequiredSignaturesResponse = {
    url: string;
    enabled: boolean;
  };
  type ReposUpdateProtectedBranchPullRequestReviewEnforcementResponseDismissalRestrictionsTeamsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
  };
  type ReposUpdateProtectedBranchPullRequestReviewEnforcementResponseDismissalRestrictionsUsersItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposUpdateProtectedBranchPullRequestReviewEnforcementResponseDismissalRestrictions = {
    url: string;
    users_url: string;
    teams_url: string;
    users: Array<
      ReposUpdateProtectedBranchPullRequestReviewEnforcementResponseDismissalRestrictionsUsersItem
    >;
    teams: Array<
      ReposUpdateProtectedBranchPullRequestReviewEnforcementResponseDismissalRestrictionsTeamsItem
    >;
  };
  type ReposUpdateProtectedBranchPullRequestReviewEnforcementResponse = {
    url: string;
    dismissal_restrictions: ReposUpdateProtectedBranchPullRequestReviewEnforcementResponseDismissalRestrictions;
    dismiss_stale_reviews: boolean;
    require_code_owner_reviews: boolean;
    required_approving_review_count: number;
  };
  type ReposUpdateProtectedBranchRequiredStatusChecksResponse = {
    url: string;
    strict: boolean;
    contexts: Array<string>;
    contexts_url: string;
  };
  type ReposGetProtectedBranchRequiredStatusChecksResponse = {
    url: string;
    strict: boolean;
    contexts: Array<string>;
    contexts_url: string;
  };
  type ReposRemoveBranchProtectionResponse = {};
  type ReposUpdateBranchProtectionResponseRestrictionsTeamsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
  };
  type ReposUpdateBranchProtectionResponseRestrictionsUsersItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposUpdateBranchProtectionResponseRestrictions = {
    url: string;
    users_url: string;
    teams_url: string;
    users: Array<ReposUpdateBranchProtectionResponseRestrictionsUsersItem>;
    teams: Array<ReposUpdateBranchProtectionResponseRestrictionsTeamsItem>;
  };
  type ReposUpdateBranchProtectionResponseRequiredPullRequestReviewsDismissalRestrictionsTeamsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
  };
  type ReposUpdateBranchProtectionResponseRequiredPullRequestReviewsDismissalRestrictionsUsersItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposUpdateBranchProtectionResponseRequiredPullRequestReviewsDismissalRestrictions = {
    url: string;
    users_url: string;
    teams_url: string;
    users: Array<
      ReposUpdateBranchProtectionResponseRequiredPullRequestReviewsDismissalRestrictionsUsersItem
    >;
    teams: Array<
      ReposUpdateBranchProtectionResponseRequiredPullRequestReviewsDismissalRestrictionsTeamsItem
    >;
  };
  type ReposUpdateBranchProtectionResponseRequiredPullRequestReviews = {
    url: string;
    dismissal_restrictions: ReposUpdateBranchProtectionResponseRequiredPullRequestReviewsDismissalRestrictions;
    dismiss_stale_reviews: boolean;
    require_code_owner_reviews: boolean;
    required_approving_review_count: number;
  };
  type ReposUpdateBranchProtectionResponseEnforceAdmins = {
    url: string;
    enabled: boolean;
  };
  type ReposUpdateBranchProtectionResponseRequiredStatusChecks = {
    url: string;
    strict: boolean;
    contexts: Array<string>;
    contexts_url: string;
  };
  type ReposUpdateBranchProtectionResponse = {
    url: string;
    required_status_checks: ReposUpdateBranchProtectionResponseRequiredStatusChecks;
    enforce_admins: ReposUpdateBranchProtectionResponseEnforceAdmins;
    required_pull_request_reviews: ReposUpdateBranchProtectionResponseRequiredPullRequestReviews;
    restrictions: ReposUpdateBranchProtectionResponseRestrictions;
  };
  type ReposGetBranchProtectionResponseRestrictionsTeamsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
  };
  type ReposGetBranchProtectionResponseRestrictionsUsersItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetBranchProtectionResponseRestrictions = {
    url: string;
    users_url: string;
    teams_url: string;
    users: Array<ReposGetBranchProtectionResponseRestrictionsUsersItem>;
    teams: Array<ReposGetBranchProtectionResponseRestrictionsTeamsItem>;
  };
  type ReposGetBranchProtectionResponseRequiredPullRequestReviewsDismissalRestrictionsTeamsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
  };
  type ReposGetBranchProtectionResponseRequiredPullRequestReviewsDismissalRestrictionsUsersItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetBranchProtectionResponseRequiredPullRequestReviewsDismissalRestrictions = {
    url: string;
    users_url: string;
    teams_url: string;
    users: Array<
      ReposGetBranchProtectionResponseRequiredPullRequestReviewsDismissalRestrictionsUsersItem
    >;
    teams: Array<
      ReposGetBranchProtectionResponseRequiredPullRequestReviewsDismissalRestrictionsTeamsItem
    >;
  };
  type ReposGetBranchProtectionResponseRequiredPullRequestReviews = {
    url: string;
    dismissal_restrictions: ReposGetBranchProtectionResponseRequiredPullRequestReviewsDismissalRestrictions;
    dismiss_stale_reviews: boolean;
    require_code_owner_reviews: boolean;
    required_approving_review_count: number;
  };
  type ReposGetBranchProtectionResponseEnforceAdmins = {
    url: string;
    enabled: boolean;
  };
  type ReposGetBranchProtectionResponseRequiredStatusChecks = {
    url: string;
    strict: boolean;
    contexts: Array<string>;
    contexts_url: string;
  };
  type ReposGetBranchProtectionResponse = {
    url: string;
    required_status_checks: ReposGetBranchProtectionResponseRequiredStatusChecks;
    enforce_admins: ReposGetBranchProtectionResponseEnforceAdmins;
    required_pull_request_reviews: ReposGetBranchProtectionResponseRequiredPullRequestReviews;
    restrictions: ReposGetBranchProtectionResponseRestrictions;
  };
  type ReposGetBranchResponseProtectionRequiredStatusChecks = {
    enforcement_level: string;
    contexts: Array<string>;
  };
  type ReposGetBranchResponseProtection = {
    enabled: boolean;
    required_status_checks: ReposGetBranchResponseProtectionRequiredStatusChecks;
  };
  type ReposGetBranchResponseLinks = { html: string; self: string };
  type ReposGetBranchResponseCommitCommitter = {
    gravatar_id: string;
    avatar_url: string;
    url: string;
    id: number;
    login: string;
  };
  type ReposGetBranchResponseCommitParentsItem = { sha: string; url: string };
  type ReposGetBranchResponseCommitAuthor = {
    gravatar_id: string;
    avatar_url: string;
    url: string;
    id: number;
    login: string;
  };
  type ReposGetBranchResponseCommitCommitVerification = {
    verified: boolean;
    reason: string;
    signature: null;
    payload: null;
  };
  type ReposGetBranchResponseCommitCommitCommitter = {
    name: string;
    date: string;
    email: string;
  };
  type ReposGetBranchResponseCommitCommitTree = { sha: string; url: string };
  type ReposGetBranchResponseCommitCommitAuthor = {
    name: string;
    date: string;
    email: string;
  };
  type ReposGetBranchResponseCommitCommit = {
    author: ReposGetBranchResponseCommitCommitAuthor;
    url: string;
    message: string;
    tree: ReposGetBranchResponseCommitCommitTree;
    committer: ReposGetBranchResponseCommitCommitCommitter;
    verification: ReposGetBranchResponseCommitCommitVerification;
  };
  type ReposGetBranchResponseCommit = {
    sha: string;
    node_id: string;
    commit: ReposGetBranchResponseCommitCommit;
    author: ReposGetBranchResponseCommitAuthor;
    parents: Array<ReposGetBranchResponseCommitParentsItem>;
    url: string;
    committer: ReposGetBranchResponseCommitCommitter;
  };
  type ReposGetBranchResponse = {
    name: string;
    commit: ReposGetBranchResponseCommit;
    _links: ReposGetBranchResponseLinks;
    protected: boolean;
    protection: ReposGetBranchResponseProtection;
    protection_url: string;
  };
  type ReposListBranchesResponseItemProtectionRequiredStatusChecks = {
    enforcement_level: string;
    contexts: Array<string>;
  };
  type ReposListBranchesResponseItemProtection = {
    enabled: boolean;
    required_status_checks: ReposListBranchesResponseItemProtectionRequiredStatusChecks;
  };
  type ReposListBranchesResponseItemCommit = { sha: string; url: string };
  type ReposListBranchesResponseItem = {
    name: string;
    commit: ReposListBranchesResponseItemCommit;
    protected: boolean;
    protection: ReposListBranchesResponseItemProtection;
    protection_url: string;
  };
  type ReposTransferResponsePermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ReposTransferResponseOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposTransferResponse = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ReposTransferResponseOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ReposTransferResponsePermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type ReposDeleteResponse = { message?: string; documentation_url?: string };
  type ReposListTagsResponseItemCommit = { sha: string; url: string };
  type ReposListTagsResponseItem = {
    name: string;
    commit: ReposListTagsResponseItemCommit;
    zipball_url: string;
    tarball_url: string;
  };
  type ReposListTeamsResponseItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
  };
  type ReposListLanguagesResponse = { C: number; Python: number };
  type ReposDisableAutomatedSecurityFixesResponse = {};
  type ReposEnableAutomatedSecurityFixesResponse = {};
  type ReposDisableVulnerabilityAlertsResponse = {};
  type ReposEnableVulnerabilityAlertsResponse = {};
  type ReposReplaceTopicsResponse = { names: Array<string> };
  type ReposListTopicsResponse = { names: Array<string> };
  type ReposUpdateResponseSourcePermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ReposUpdateResponseSourceOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposUpdateResponseSource = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ReposUpdateResponseSourceOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ReposUpdateResponseSourcePermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type ReposUpdateResponseParentPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ReposUpdateResponseParentOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposUpdateResponseParent = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ReposUpdateResponseParentOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ReposUpdateResponseParentPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type ReposUpdateResponseOrganization = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposUpdateResponsePermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ReposUpdateResponseOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposUpdateResponse = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ReposUpdateResponseOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ReposUpdateResponsePermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
    organization: ReposUpdateResponseOrganization;
    parent: ReposUpdateResponseParent;
    source: ReposUpdateResponseSource;
  };
  type ReposGetResponseSourcePermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ReposGetResponseSourceOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetResponseSource = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ReposGetResponseSourceOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ReposGetResponseSourcePermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type ReposGetResponseParentPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ReposGetResponseParentOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetResponseParent = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ReposGetResponseParentOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ReposGetResponseParentPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type ReposGetResponseOrganization = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetResponseLicense = {
    key: string;
    name: string;
    spdx_id: string;
    url: string;
    node_id: string;
  };
  type ReposGetResponsePermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ReposGetResponseOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposGetResponse = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ReposGetResponseOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ReposGetResponsePermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
    license: ReposGetResponseLicense;
    organization: ReposGetResponseOrganization;
    parent: ReposGetResponseParent;
    source: ReposGetResponseSource;
  };
  type ReposCreateUsingTemplateResponseTemplateRepositoryPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ReposCreateUsingTemplateResponseTemplateRepositoryOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposCreateUsingTemplateResponseTemplateRepository = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ReposCreateUsingTemplateResponseTemplateRepositoryOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ReposCreateUsingTemplateResponseTemplateRepositoryPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type ReposCreateUsingTemplateResponsePermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ReposCreateUsingTemplateResponseOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposCreateUsingTemplateResponse = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ReposCreateUsingTemplateResponseOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ReposCreateUsingTemplateResponsePermissions;
    allow_rebase_merge: boolean;
    template_repository: ReposCreateUsingTemplateResponseTemplateRepository;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type ReposCreateInOrgResponsePermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ReposCreateInOrgResponseOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposCreateInOrgResponse = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ReposCreateInOrgResponseOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ReposCreateInOrgResponsePermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type ReposCreateForAuthenticatedUserResponsePermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ReposCreateForAuthenticatedUserResponseOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposCreateForAuthenticatedUserResponse = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ReposCreateForAuthenticatedUserResponseOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ReposCreateForAuthenticatedUserResponsePermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type ReposListPublicResponseItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListPublicResponseItem = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ReposListPublicResponseItemOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
  };
  type ReposListForOrgResponseItemLicense = {
    key: string;
    name: string;
    spdx_id: string;
    url: string;
    node_id: string;
  };
  type ReposListForOrgResponseItemPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ReposListForOrgResponseItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReposListForOrgResponseItem = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ReposListForOrgResponseItemOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ReposListForOrgResponseItemPermissions;
    template_repository: null;
    subscribers_count: number;
    network_count: number;
    license: ReposListForOrgResponseItemLicense;
  };
  type ReactionsDeleteResponse = {};
  type ReactionsCreateForTeamDiscussionCommentResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReactionsCreateForTeamDiscussionCommentResponse = {
    id: number;
    node_id: string;
    user: ReactionsCreateForTeamDiscussionCommentResponseUser;
    content: string;
    created_at: string;
  };
  type ReactionsListForTeamDiscussionCommentResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReactionsListForTeamDiscussionCommentResponseItem = {
    id: number;
    node_id: string;
    user: ReactionsListForTeamDiscussionCommentResponseItemUser;
    content: string;
    created_at: string;
  };
  type ReactionsCreateForTeamDiscussionResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReactionsCreateForTeamDiscussionResponse = {
    id: number;
    node_id: string;
    user: ReactionsCreateForTeamDiscussionResponseUser;
    content: string;
    created_at: string;
  };
  type ReactionsListForTeamDiscussionResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReactionsListForTeamDiscussionResponseItem = {
    id: number;
    node_id: string;
    user: ReactionsListForTeamDiscussionResponseItemUser;
    content: string;
    created_at: string;
  };
  type ReactionsCreateForPullRequestReviewCommentResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReactionsCreateForPullRequestReviewCommentResponse = {
    id: number;
    node_id: string;
    user: ReactionsCreateForPullRequestReviewCommentResponseUser;
    content: string;
    created_at: string;
  };
  type ReactionsListForPullRequestReviewCommentResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReactionsListForPullRequestReviewCommentResponseItem = {
    id: number;
    node_id: string;
    user: ReactionsListForPullRequestReviewCommentResponseItemUser;
    content: string;
    created_at: string;
  };
  type ReactionsCreateForIssueCommentResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReactionsCreateForIssueCommentResponse = {
    id: number;
    node_id: string;
    user: ReactionsCreateForIssueCommentResponseUser;
    content: string;
    created_at: string;
  };
  type ReactionsListForIssueCommentResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReactionsListForIssueCommentResponseItem = {
    id: number;
    node_id: string;
    user: ReactionsListForIssueCommentResponseItemUser;
    content: string;
    created_at: string;
  };
  type ReactionsCreateForIssueResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReactionsCreateForIssueResponse = {
    id: number;
    node_id: string;
    user: ReactionsCreateForIssueResponseUser;
    content: string;
    created_at: string;
  };
  type ReactionsListForIssueResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReactionsListForIssueResponseItem = {
    id: number;
    node_id: string;
    user: ReactionsListForIssueResponseItemUser;
    content: string;
    created_at: string;
  };
  type ReactionsCreateForCommitCommentResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReactionsCreateForCommitCommentResponse = {
    id: number;
    node_id: string;
    user: ReactionsCreateForCommitCommentResponseUser;
    content: string;
    created_at: string;
  };
  type ReactionsListForCommitCommentResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ReactionsListForCommitCommentResponseItem = {
    id: number;
    node_id: string;
    user: ReactionsListForCommitCommentResponseItemUser;
    content: string;
    created_at: string;
  };
  type RateLimitGetResponseRate = {
    limit: number;
    remaining: number;
    reset: number;
  };
  type RateLimitGetResponseResourcesIntegrationManifest = {
    limit: number;
    remaining: number;
    reset: number;
  };
  type RateLimitGetResponseResourcesGraphql = {
    limit: number;
    remaining: number;
    reset: number;
  };
  type RateLimitGetResponseResourcesSearch = {
    limit: number;
    remaining: number;
    reset: number;
  };
  type RateLimitGetResponseResourcesCore = {
    limit: number;
    remaining: number;
    reset: number;
  };
  type RateLimitGetResponseResources = {
    core: RateLimitGetResponseResourcesCore;
    search: RateLimitGetResponseResourcesSearch;
    graphql: RateLimitGetResponseResourcesGraphql;
    integration_manifest: RateLimitGetResponseResourcesIntegrationManifest;
  };
  type RateLimitGetResponse = {
    resources: RateLimitGetResponseResources;
    rate: RateLimitGetResponseRate;
  };
  type PullsDismissReviewResponseLinksPullRequest = { href: string };
  type PullsDismissReviewResponseLinksHtml = { href: string };
  type PullsDismissReviewResponseLinks = {
    html: PullsDismissReviewResponseLinksHtml;
    pull_request: PullsDismissReviewResponseLinksPullRequest;
  };
  type PullsDismissReviewResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsDismissReviewResponse = {
    id: number;
    node_id: string;
    user: PullsDismissReviewResponseUser;
    body: string;
    commit_id: string;
    state: string;
    html_url: string;
    pull_request_url: string;
    _links: PullsDismissReviewResponseLinks;
  };
  type PullsSubmitReviewResponseLinksPullRequest = { href: string };
  type PullsSubmitReviewResponseLinksHtml = { href: string };
  type PullsSubmitReviewResponseLinks = {
    html: PullsSubmitReviewResponseLinksHtml;
    pull_request: PullsSubmitReviewResponseLinksPullRequest;
  };
  type PullsSubmitReviewResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsSubmitReviewResponse = {
    id: number;
    node_id: string;
    user: PullsSubmitReviewResponseUser;
    body: string;
    commit_id: string;
    state: string;
    html_url: string;
    pull_request_url: string;
    _links: PullsSubmitReviewResponseLinks;
  };
  type PullsUpdateReviewResponseLinksPullRequest = { href: string };
  type PullsUpdateReviewResponseLinksHtml = { href: string };
  type PullsUpdateReviewResponseLinks = {
    html: PullsUpdateReviewResponseLinksHtml;
    pull_request: PullsUpdateReviewResponseLinksPullRequest;
  };
  type PullsUpdateReviewResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsUpdateReviewResponse = {
    id: number;
    node_id: string;
    user: PullsUpdateReviewResponseUser;
    body: string;
    commit_id: string;
    state: string;
    html_url: string;
    pull_request_url: string;
    _links: PullsUpdateReviewResponseLinks;
  };
  type PullsCreateReviewResponseLinksPullRequest = { href: string };
  type PullsCreateReviewResponseLinksHtml = { href: string };
  type PullsCreateReviewResponseLinks = {
    html: PullsCreateReviewResponseLinksHtml;
    pull_request: PullsCreateReviewResponseLinksPullRequest;
  };
  type PullsCreateReviewResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateReviewResponse = {
    id: number;
    node_id: string;
    user: PullsCreateReviewResponseUser;
    body: string;
    commit_id: string;
    state: string;
    html_url: string;
    pull_request_url: string;
    _links: PullsCreateReviewResponseLinks;
  };
  type PullsGetCommentsForReviewResponseItemLinksPullRequest = { href: string };
  type PullsGetCommentsForReviewResponseItemLinksHtml = { href: string };
  type PullsGetCommentsForReviewResponseItemLinksSelf = { href: string };
  type PullsGetCommentsForReviewResponseItemLinks = {
    self: PullsGetCommentsForReviewResponseItemLinksSelf;
    html: PullsGetCommentsForReviewResponseItemLinksHtml;
    pull_request: PullsGetCommentsForReviewResponseItemLinksPullRequest;
  };
  type PullsGetCommentsForReviewResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsGetCommentsForReviewResponseItem = {
    url: string;
    id: number;
    node_id: string;
    pull_request_review_id: number;
    diff_hunk: string;
    path: string;
    position: number;
    original_position: number;
    commit_id: string;
    original_commit_id: string;
    in_reply_to_id: number;
    user: PullsGetCommentsForReviewResponseItemUser;
    body: string;
    created_at: string;
    updated_at: string;
    html_url: string;
    pull_request_url: string;
    _links: PullsGetCommentsForReviewResponseItemLinks;
  };
  type PullsDeletePendingReviewResponseLinksPullRequest = { href: string };
  type PullsDeletePendingReviewResponseLinksHtml = { href: string };
  type PullsDeletePendingReviewResponseLinks = {
    html: PullsDeletePendingReviewResponseLinksHtml;
    pull_request: PullsDeletePendingReviewResponseLinksPullRequest;
  };
  type PullsDeletePendingReviewResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsDeletePendingReviewResponse = {
    id: number;
    node_id: string;
    user: PullsDeletePendingReviewResponseUser;
    body: string;
    commit_id: string;
    state: string;
    html_url: string;
    pull_request_url: string;
    _links: PullsDeletePendingReviewResponseLinks;
  };
  type PullsGetReviewResponseLinksPullRequest = { href: string };
  type PullsGetReviewResponseLinksHtml = { href: string };
  type PullsGetReviewResponseLinks = {
    html: PullsGetReviewResponseLinksHtml;
    pull_request: PullsGetReviewResponseLinksPullRequest;
  };
  type PullsGetReviewResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsGetReviewResponse = {
    id: number;
    node_id: string;
    user: PullsGetReviewResponseUser;
    body: string;
    commit_id: string;
    state: string;
    html_url: string;
    pull_request_url: string;
    _links: PullsGetReviewResponseLinks;
  };
  type PullsListReviewsResponseItemLinksPullRequest = { href: string };
  type PullsListReviewsResponseItemLinksHtml = { href: string };
  type PullsListReviewsResponseItemLinks = {
    html: PullsListReviewsResponseItemLinksHtml;
    pull_request: PullsListReviewsResponseItemLinksPullRequest;
  };
  type PullsListReviewsResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsListReviewsResponseItem = {
    id: number;
    node_id: string;
    user: PullsListReviewsResponseItemUser;
    body: string;
    commit_id: string;
    state: string;
    html_url: string;
    pull_request_url: string;
    _links: PullsListReviewsResponseItemLinks;
  };
  type PullsDeleteReviewRequestResponse = {};
  type PullsCreateReviewRequestResponseLinksStatuses = { href: string };
  type PullsCreateReviewRequestResponseLinksCommits = { href: string };
  type PullsCreateReviewRequestResponseLinksReviewComment = { href: string };
  type PullsCreateReviewRequestResponseLinksReviewComments = { href: string };
  type PullsCreateReviewRequestResponseLinksComments = { href: string };
  type PullsCreateReviewRequestResponseLinksIssue = { href: string };
  type PullsCreateReviewRequestResponseLinksHtml = { href: string };
  type PullsCreateReviewRequestResponseLinksSelf = { href: string };
  type PullsCreateReviewRequestResponseLinks = {
    self: PullsCreateReviewRequestResponseLinksSelf;
    html: PullsCreateReviewRequestResponseLinksHtml;
    issue: PullsCreateReviewRequestResponseLinksIssue;
    comments: PullsCreateReviewRequestResponseLinksComments;
    review_comments: PullsCreateReviewRequestResponseLinksReviewComments;
    review_comment: PullsCreateReviewRequestResponseLinksReviewComment;
    commits: PullsCreateReviewRequestResponseLinksCommits;
    statuses: PullsCreateReviewRequestResponseLinksStatuses;
  };
  type PullsCreateReviewRequestResponseBaseRepoPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type PullsCreateReviewRequestResponseBaseRepoOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateReviewRequestResponseBaseRepo = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: PullsCreateReviewRequestResponseBaseRepoOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: PullsCreateReviewRequestResponseBaseRepoPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type PullsCreateReviewRequestResponseBaseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateReviewRequestResponseBase = {
    label: string;
    ref: string;
    sha: string;
    user: PullsCreateReviewRequestResponseBaseUser;
    repo: PullsCreateReviewRequestResponseBaseRepo;
  };
  type PullsCreateReviewRequestResponseHeadRepoPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type PullsCreateReviewRequestResponseHeadRepoOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateReviewRequestResponseHeadRepo = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: PullsCreateReviewRequestResponseHeadRepoOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: PullsCreateReviewRequestResponseHeadRepoPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type PullsCreateReviewRequestResponseHeadUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateReviewRequestResponseHead = {
    label: string;
    ref: string;
    sha: string;
    user: PullsCreateReviewRequestResponseHeadUser;
    repo: PullsCreateReviewRequestResponseHeadRepo;
  };
  type PullsCreateReviewRequestResponseRequestedTeamsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
  };
  type PullsCreateReviewRequestResponseRequestedReviewersItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateReviewRequestResponseAssigneesItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateReviewRequestResponseAssignee = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateReviewRequestResponseMilestoneCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateReviewRequestResponseMilestone = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: PullsCreateReviewRequestResponseMilestoneCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type PullsCreateReviewRequestResponseLabelsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type PullsCreateReviewRequestResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateReviewRequestResponse = {
    url: string;
    id: number;
    node_id: string;
    html_url: string;
    diff_url: string;
    patch_url: string;
    issue_url: string;
    commits_url: string;
    review_comments_url: string;
    review_comment_url: string;
    comments_url: string;
    statuses_url: string;
    number: number;
    state: string;
    locked: boolean;
    title: string;
    user: PullsCreateReviewRequestResponseUser;
    body: string;
    labels: Array<PullsCreateReviewRequestResponseLabelsItem>;
    milestone: PullsCreateReviewRequestResponseMilestone;
    active_lock_reason: string;
    created_at: string;
    updated_at: string;
    closed_at: string;
    merged_at: string;
    merge_commit_sha: string;
    assignee: PullsCreateReviewRequestResponseAssignee;
    assignees: Array<PullsCreateReviewRequestResponseAssigneesItem>;
    requested_reviewers: Array<
      PullsCreateReviewRequestResponseRequestedReviewersItem
    >;
    requested_teams: Array<PullsCreateReviewRequestResponseRequestedTeamsItem>;
    head: PullsCreateReviewRequestResponseHead;
    base: PullsCreateReviewRequestResponseBase;
    _links: PullsCreateReviewRequestResponseLinks;
    author_association: string;
    draft: boolean;
  };
  type PullsListReviewRequestsResponseTeamsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
  };
  type PullsListReviewRequestsResponseUsersItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsListReviewRequestsResponse = {
    users: Array<PullsListReviewRequestsResponseUsersItem>;
    teams: Array<PullsListReviewRequestsResponseTeamsItem>;
  };
  type PullsDeleteCommentResponse = {};
  type PullsUpdateCommentResponseLinksPullRequest = { href: string };
  type PullsUpdateCommentResponseLinksHtml = { href: string };
  type PullsUpdateCommentResponseLinksSelf = { href: string };
  type PullsUpdateCommentResponseLinks = {
    self: PullsUpdateCommentResponseLinksSelf;
    html: PullsUpdateCommentResponseLinksHtml;
    pull_request: PullsUpdateCommentResponseLinksPullRequest;
  };
  type PullsUpdateCommentResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsUpdateCommentResponse = {
    url: string;
    id: number;
    node_id: string;
    pull_request_review_id: number;
    diff_hunk: string;
    path: string;
    position: number;
    original_position: number;
    commit_id: string;
    original_commit_id: string;
    in_reply_to_id: number;
    user: PullsUpdateCommentResponseUser;
    body: string;
    created_at: string;
    updated_at: string;
    html_url: string;
    pull_request_url: string;
    _links: PullsUpdateCommentResponseLinks;
  };
  type PullsCreateCommentReplyResponseLinksPullRequest = { href: string };
  type PullsCreateCommentReplyResponseLinksHtml = { href: string };
  type PullsCreateCommentReplyResponseLinksSelf = { href: string };
  type PullsCreateCommentReplyResponseLinks = {
    self: PullsCreateCommentReplyResponseLinksSelf;
    html: PullsCreateCommentReplyResponseLinksHtml;
    pull_request: PullsCreateCommentReplyResponseLinksPullRequest;
  };
  type PullsCreateCommentReplyResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateCommentReplyResponse = {
    url: string;
    id: number;
    node_id: string;
    pull_request_review_id: number;
    diff_hunk: string;
    path: string;
    position: number;
    original_position: number;
    commit_id: string;
    original_commit_id: string;
    in_reply_to_id: number;
    user: PullsCreateCommentReplyResponseUser;
    body: string;
    created_at: string;
    updated_at: string;
    html_url: string;
    pull_request_url: string;
    _links: PullsCreateCommentReplyResponseLinks;
  };
  type PullsCreateCommentResponseLinksPullRequest = { href: string };
  type PullsCreateCommentResponseLinksHtml = { href: string };
  type PullsCreateCommentResponseLinksSelf = { href: string };
  type PullsCreateCommentResponseLinks = {
    self: PullsCreateCommentResponseLinksSelf;
    html: PullsCreateCommentResponseLinksHtml;
    pull_request: PullsCreateCommentResponseLinksPullRequest;
  };
  type PullsCreateCommentResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateCommentResponse = {
    url: string;
    id: number;
    node_id: string;
    pull_request_review_id: number;
    diff_hunk: string;
    path: string;
    position: number;
    original_position: number;
    commit_id: string;
    original_commit_id: string;
    in_reply_to_id: number;
    user: PullsCreateCommentResponseUser;
    body: string;
    created_at: string;
    updated_at: string;
    html_url: string;
    pull_request_url: string;
    _links: PullsCreateCommentResponseLinks;
  };
  type PullsGetCommentResponseLinksPullRequest = { href: string };
  type PullsGetCommentResponseLinksHtml = { href: string };
  type PullsGetCommentResponseLinksSelf = { href: string };
  type PullsGetCommentResponseLinks = {
    self: PullsGetCommentResponseLinksSelf;
    html: PullsGetCommentResponseLinksHtml;
    pull_request: PullsGetCommentResponseLinksPullRequest;
  };
  type PullsGetCommentResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsGetCommentResponse = {
    url: string;
    id: number;
    node_id: string;
    pull_request_review_id: number;
    diff_hunk: string;
    path: string;
    position: number;
    original_position: number;
    commit_id: string;
    original_commit_id: string;
    in_reply_to_id: number;
    user: PullsGetCommentResponseUser;
    body: string;
    created_at: string;
    updated_at: string;
    html_url: string;
    pull_request_url: string;
    _links: PullsGetCommentResponseLinks;
  };
  type PullsListCommentsForRepoResponseItemLinksPullRequest = { href: string };
  type PullsListCommentsForRepoResponseItemLinksHtml = { href: string };
  type PullsListCommentsForRepoResponseItemLinksSelf = { href: string };
  type PullsListCommentsForRepoResponseItemLinks = {
    self: PullsListCommentsForRepoResponseItemLinksSelf;
    html: PullsListCommentsForRepoResponseItemLinksHtml;
    pull_request: PullsListCommentsForRepoResponseItemLinksPullRequest;
  };
  type PullsListCommentsForRepoResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsListCommentsForRepoResponseItem = {
    url: string;
    id: number;
    node_id: string;
    pull_request_review_id: number;
    diff_hunk: string;
    path: string;
    position: number;
    original_position: number;
    commit_id: string;
    original_commit_id: string;
    in_reply_to_id: number;
    user: PullsListCommentsForRepoResponseItemUser;
    body: string;
    created_at: string;
    updated_at: string;
    html_url: string;
    pull_request_url: string;
    _links: PullsListCommentsForRepoResponseItemLinks;
  };
  type PullsListCommentsResponseItemLinksPullRequest = { href: string };
  type PullsListCommentsResponseItemLinksHtml = { href: string };
  type PullsListCommentsResponseItemLinksSelf = { href: string };
  type PullsListCommentsResponseItemLinks = {
    self: PullsListCommentsResponseItemLinksSelf;
    html: PullsListCommentsResponseItemLinksHtml;
    pull_request: PullsListCommentsResponseItemLinksPullRequest;
  };
  type PullsListCommentsResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsListCommentsResponseItem = {
    url: string;
    id: number;
    node_id: string;
    pull_request_review_id: number;
    diff_hunk: string;
    path: string;
    position: number;
    original_position: number;
    commit_id: string;
    original_commit_id: string;
    in_reply_to_id: number;
    user: PullsListCommentsResponseItemUser;
    body: string;
    created_at: string;
    updated_at: string;
    html_url: string;
    pull_request_url: string;
    _links: PullsListCommentsResponseItemLinks;
  };
  type PullsListFilesResponseItem = {
    sha: string;
    filename: string;
    status: string;
    additions: number;
    deletions: number;
    changes: number;
    blob_url: string;
    raw_url: string;
    contents_url: string;
    patch: string;
  };
  type PullsListCommitsResponseItemParentsItem = { url: string; sha: string };
  type PullsListCommitsResponseItemCommitter = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsListCommitsResponseItemAuthor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsListCommitsResponseItemCommitVerification = {
    verified: boolean;
    reason: string;
    signature: null;
    payload: null;
  };
  type PullsListCommitsResponseItemCommitTree = { url: string; sha: string };
  type PullsListCommitsResponseItemCommitCommitter = {
    name: string;
    email: string;
    date: string;
  };
  type PullsListCommitsResponseItemCommitAuthor = {
    name: string;
    email: string;
    date: string;
  };
  type PullsListCommitsResponseItemCommit = {
    url: string;
    author: PullsListCommitsResponseItemCommitAuthor;
    committer: PullsListCommitsResponseItemCommitCommitter;
    message: string;
    tree: PullsListCommitsResponseItemCommitTree;
    comment_count: number;
    verification: PullsListCommitsResponseItemCommitVerification;
  };
  type PullsListCommitsResponseItem = {
    url: string;
    sha: string;
    node_id: string;
    html_url: string;
    comments_url: string;
    commit: PullsListCommitsResponseItemCommit;
    author: PullsListCommitsResponseItemAuthor;
    committer: PullsListCommitsResponseItemCommitter;
    parents: Array<PullsListCommitsResponseItemParentsItem>;
  };
  type PullsUpdateResponseMergedBy = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsUpdateResponseLinksStatuses = { href: string };
  type PullsUpdateResponseLinksCommits = { href: string };
  type PullsUpdateResponseLinksReviewComment = { href: string };
  type PullsUpdateResponseLinksReviewComments = { href: string };
  type PullsUpdateResponseLinksComments = { href: string };
  type PullsUpdateResponseLinksIssue = { href: string };
  type PullsUpdateResponseLinksHtml = { href: string };
  type PullsUpdateResponseLinksSelf = { href: string };
  type PullsUpdateResponseLinks = {
    self: PullsUpdateResponseLinksSelf;
    html: PullsUpdateResponseLinksHtml;
    issue: PullsUpdateResponseLinksIssue;
    comments: PullsUpdateResponseLinksComments;
    review_comments: PullsUpdateResponseLinksReviewComments;
    review_comment: PullsUpdateResponseLinksReviewComment;
    commits: PullsUpdateResponseLinksCommits;
    statuses: PullsUpdateResponseLinksStatuses;
  };
  type PullsUpdateResponseBaseRepoPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type PullsUpdateResponseBaseRepoOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsUpdateResponseBaseRepo = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: PullsUpdateResponseBaseRepoOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: PullsUpdateResponseBaseRepoPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type PullsUpdateResponseBaseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsUpdateResponseBase = {
    label: string;
    ref: string;
    sha: string;
    user: PullsUpdateResponseBaseUser;
    repo: PullsUpdateResponseBaseRepo;
  };
  type PullsUpdateResponseHeadRepoPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type PullsUpdateResponseHeadRepoOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsUpdateResponseHeadRepo = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: PullsUpdateResponseHeadRepoOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: PullsUpdateResponseHeadRepoPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type PullsUpdateResponseHeadUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsUpdateResponseHead = {
    label: string;
    ref: string;
    sha: string;
    user: PullsUpdateResponseHeadUser;
    repo: PullsUpdateResponseHeadRepo;
  };
  type PullsUpdateResponseRequestedTeamsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
  };
  type PullsUpdateResponseRequestedReviewersItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsUpdateResponseAssigneesItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsUpdateResponseAssignee = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsUpdateResponseMilestoneCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsUpdateResponseMilestone = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: PullsUpdateResponseMilestoneCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type PullsUpdateResponseLabelsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type PullsUpdateResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsUpdateResponse = {
    url: string;
    id: number;
    node_id: string;
    html_url: string;
    diff_url: string;
    patch_url: string;
    issue_url: string;
    commits_url: string;
    review_comments_url: string;
    review_comment_url: string;
    comments_url: string;
    statuses_url: string;
    number: number;
    state: string;
    locked: boolean;
    title: string;
    user: PullsUpdateResponseUser;
    body: string;
    labels: Array<PullsUpdateResponseLabelsItem>;
    milestone: PullsUpdateResponseMilestone;
    active_lock_reason: string;
    created_at: string;
    updated_at: string;
    closed_at: string;
    merged_at: string;
    merge_commit_sha: string;
    assignee: PullsUpdateResponseAssignee;
    assignees: Array<PullsUpdateResponseAssigneesItem>;
    requested_reviewers: Array<PullsUpdateResponseRequestedReviewersItem>;
    requested_teams: Array<PullsUpdateResponseRequestedTeamsItem>;
    head: PullsUpdateResponseHead;
    base: PullsUpdateResponseBase;
    _links: PullsUpdateResponseLinks;
    author_association: string;
    draft: boolean;
    merged: boolean;
    mergeable: boolean;
    rebaseable: boolean;
    mergeable_state: string;
    merged_by: PullsUpdateResponseMergedBy;
    comments: number;
    review_comments: number;
    maintainer_can_modify: boolean;
    commits: number;
    additions: number;
    deletions: number;
    changed_files: number;
  };
  type PullsUpdateBranchResponse = { message: string; url: string };
  type PullsCreateFromIssueResponseMergedBy = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateFromIssueResponseLinksStatuses = { href: string };
  type PullsCreateFromIssueResponseLinksCommits = { href: string };
  type PullsCreateFromIssueResponseLinksReviewComment = { href: string };
  type PullsCreateFromIssueResponseLinksReviewComments = { href: string };
  type PullsCreateFromIssueResponseLinksComments = { href: string };
  type PullsCreateFromIssueResponseLinksIssue = { href: string };
  type PullsCreateFromIssueResponseLinksHtml = { href: string };
  type PullsCreateFromIssueResponseLinksSelf = { href: string };
  type PullsCreateFromIssueResponseLinks = {
    self: PullsCreateFromIssueResponseLinksSelf;
    html: PullsCreateFromIssueResponseLinksHtml;
    issue: PullsCreateFromIssueResponseLinksIssue;
    comments: PullsCreateFromIssueResponseLinksComments;
    review_comments: PullsCreateFromIssueResponseLinksReviewComments;
    review_comment: PullsCreateFromIssueResponseLinksReviewComment;
    commits: PullsCreateFromIssueResponseLinksCommits;
    statuses: PullsCreateFromIssueResponseLinksStatuses;
  };
  type PullsCreateFromIssueResponseBaseRepoPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type PullsCreateFromIssueResponseBaseRepoOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateFromIssueResponseBaseRepo = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: PullsCreateFromIssueResponseBaseRepoOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: PullsCreateFromIssueResponseBaseRepoPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type PullsCreateFromIssueResponseBaseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateFromIssueResponseBase = {
    label: string;
    ref: string;
    sha: string;
    user: PullsCreateFromIssueResponseBaseUser;
    repo: PullsCreateFromIssueResponseBaseRepo;
  };
  type PullsCreateFromIssueResponseHeadRepoPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type PullsCreateFromIssueResponseHeadRepoOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateFromIssueResponseHeadRepo = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: PullsCreateFromIssueResponseHeadRepoOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: PullsCreateFromIssueResponseHeadRepoPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type PullsCreateFromIssueResponseHeadUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateFromIssueResponseHead = {
    label: string;
    ref: string;
    sha: string;
    user: PullsCreateFromIssueResponseHeadUser;
    repo: PullsCreateFromIssueResponseHeadRepo;
  };
  type PullsCreateFromIssueResponseRequestedTeamsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
  };
  type PullsCreateFromIssueResponseRequestedReviewersItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateFromIssueResponseAssigneesItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateFromIssueResponseAssignee = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateFromIssueResponseMilestoneCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateFromIssueResponseMilestone = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: PullsCreateFromIssueResponseMilestoneCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type PullsCreateFromIssueResponseLabelsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type PullsCreateFromIssueResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateFromIssueResponse = {
    url: string;
    id: number;
    node_id: string;
    html_url: string;
    diff_url: string;
    patch_url: string;
    issue_url: string;
    commits_url: string;
    review_comments_url: string;
    review_comment_url: string;
    comments_url: string;
    statuses_url: string;
    number: number;
    state: string;
    locked: boolean;
    title: string;
    user: PullsCreateFromIssueResponseUser;
    body: string;
    labels: Array<PullsCreateFromIssueResponseLabelsItem>;
    milestone: PullsCreateFromIssueResponseMilestone;
    active_lock_reason: string;
    created_at: string;
    updated_at: string;
    closed_at: string;
    merged_at: string;
    merge_commit_sha: string;
    assignee: PullsCreateFromIssueResponseAssignee;
    assignees: Array<PullsCreateFromIssueResponseAssigneesItem>;
    requested_reviewers: Array<
      PullsCreateFromIssueResponseRequestedReviewersItem
    >;
    requested_teams: Array<PullsCreateFromIssueResponseRequestedTeamsItem>;
    head: PullsCreateFromIssueResponseHead;
    base: PullsCreateFromIssueResponseBase;
    _links: PullsCreateFromIssueResponseLinks;
    author_association: string;
    draft: boolean;
    merged: boolean;
    mergeable: boolean;
    rebaseable: boolean;
    mergeable_state: string;
    merged_by: PullsCreateFromIssueResponseMergedBy;
    comments: number;
    review_comments: number;
    maintainer_can_modify: boolean;
    commits: number;
    additions: number;
    deletions: number;
    changed_files: number;
  };
  type PullsCreateResponseMergedBy = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateResponseLinksStatuses = { href: string };
  type PullsCreateResponseLinksCommits = { href: string };
  type PullsCreateResponseLinksReviewComment = { href: string };
  type PullsCreateResponseLinksReviewComments = { href: string };
  type PullsCreateResponseLinksComments = { href: string };
  type PullsCreateResponseLinksIssue = { href: string };
  type PullsCreateResponseLinksHtml = { href: string };
  type PullsCreateResponseLinksSelf = { href: string };
  type PullsCreateResponseLinks = {
    self: PullsCreateResponseLinksSelf;
    html: PullsCreateResponseLinksHtml;
    issue: PullsCreateResponseLinksIssue;
    comments: PullsCreateResponseLinksComments;
    review_comments: PullsCreateResponseLinksReviewComments;
    review_comment: PullsCreateResponseLinksReviewComment;
    commits: PullsCreateResponseLinksCommits;
    statuses: PullsCreateResponseLinksStatuses;
  };
  type PullsCreateResponseBaseRepoPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type PullsCreateResponseBaseRepoOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateResponseBaseRepo = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: PullsCreateResponseBaseRepoOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: PullsCreateResponseBaseRepoPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type PullsCreateResponseBaseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateResponseBase = {
    label: string;
    ref: string;
    sha: string;
    user: PullsCreateResponseBaseUser;
    repo: PullsCreateResponseBaseRepo;
  };
  type PullsCreateResponseHeadRepoPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type PullsCreateResponseHeadRepoOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateResponseHeadRepo = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: PullsCreateResponseHeadRepoOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: PullsCreateResponseHeadRepoPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type PullsCreateResponseHeadUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateResponseHead = {
    label: string;
    ref: string;
    sha: string;
    user: PullsCreateResponseHeadUser;
    repo: PullsCreateResponseHeadRepo;
  };
  type PullsCreateResponseRequestedTeamsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
  };
  type PullsCreateResponseRequestedReviewersItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateResponseAssigneesItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateResponseAssignee = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateResponseMilestoneCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateResponseMilestone = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: PullsCreateResponseMilestoneCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type PullsCreateResponseLabelsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type PullsCreateResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsCreateResponse = {
    url: string;
    id: number;
    node_id: string;
    html_url: string;
    diff_url: string;
    patch_url: string;
    issue_url: string;
    commits_url: string;
    review_comments_url: string;
    review_comment_url: string;
    comments_url: string;
    statuses_url: string;
    number: number;
    state: string;
    locked: boolean;
    title: string;
    user: PullsCreateResponseUser;
    body: string;
    labels: Array<PullsCreateResponseLabelsItem>;
    milestone: PullsCreateResponseMilestone;
    active_lock_reason: string;
    created_at: string;
    updated_at: string;
    closed_at: string;
    merged_at: string;
    merge_commit_sha: string;
    assignee: PullsCreateResponseAssignee;
    assignees: Array<PullsCreateResponseAssigneesItem>;
    requested_reviewers: Array<PullsCreateResponseRequestedReviewersItem>;
    requested_teams: Array<PullsCreateResponseRequestedTeamsItem>;
    head: PullsCreateResponseHead;
    base: PullsCreateResponseBase;
    _links: PullsCreateResponseLinks;
    author_association: string;
    draft: boolean;
    merged: boolean;
    mergeable: boolean;
    rebaseable: boolean;
    mergeable_state: string;
    merged_by: PullsCreateResponseMergedBy;
    comments: number;
    review_comments: number;
    maintainer_can_modify: boolean;
    commits: number;
    additions: number;
    deletions: number;
    changed_files: number;
  };
  type PullsGetResponseMergedBy = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsGetResponseLinksStatuses = { href: string };
  type PullsGetResponseLinksCommits = { href: string };
  type PullsGetResponseLinksReviewComment = { href: string };
  type PullsGetResponseLinksReviewComments = { href: string };
  type PullsGetResponseLinksComments = { href: string };
  type PullsGetResponseLinksIssue = { href: string };
  type PullsGetResponseLinksHtml = { href: string };
  type PullsGetResponseLinksSelf = { href: string };
  type PullsGetResponseLinks = {
    self: PullsGetResponseLinksSelf;
    html: PullsGetResponseLinksHtml;
    issue: PullsGetResponseLinksIssue;
    comments: PullsGetResponseLinksComments;
    review_comments: PullsGetResponseLinksReviewComments;
    review_comment: PullsGetResponseLinksReviewComment;
    commits: PullsGetResponseLinksCommits;
    statuses: PullsGetResponseLinksStatuses;
  };
  type PullsGetResponseBaseRepoPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type PullsGetResponseBaseRepoOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsGetResponseBaseRepo = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: PullsGetResponseBaseRepoOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: PullsGetResponseBaseRepoPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type PullsGetResponseBaseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsGetResponseBase = {
    label: string;
    ref: string;
    sha: string;
    user: PullsGetResponseBaseUser;
    repo: PullsGetResponseBaseRepo;
  };
  type PullsGetResponseHeadRepoPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type PullsGetResponseHeadRepoOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsGetResponseHeadRepo = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: PullsGetResponseHeadRepoOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: PullsGetResponseHeadRepoPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type PullsGetResponseHeadUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsGetResponseHead = {
    label: string;
    ref: string;
    sha: string;
    user: PullsGetResponseHeadUser;
    repo: PullsGetResponseHeadRepo;
  };
  type PullsGetResponseRequestedTeamsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
  };
  type PullsGetResponseRequestedReviewersItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsGetResponseAssigneesItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsGetResponseAssignee = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsGetResponseMilestoneCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsGetResponseMilestone = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: PullsGetResponseMilestoneCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type PullsGetResponseLabelsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type PullsGetResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsGetResponse = {
    url: string;
    id: number;
    node_id: string;
    html_url: string;
    diff_url: string;
    patch_url: string;
    issue_url: string;
    commits_url: string;
    review_comments_url: string;
    review_comment_url: string;
    comments_url: string;
    statuses_url: string;
    number: number;
    state: string;
    locked: boolean;
    title: string;
    user: PullsGetResponseUser;
    body: string;
    labels: Array<PullsGetResponseLabelsItem>;
    milestone: PullsGetResponseMilestone;
    active_lock_reason: string;
    created_at: string;
    updated_at: string;
    closed_at: string;
    merged_at: string;
    merge_commit_sha: string;
    assignee: PullsGetResponseAssignee;
    assignees: Array<PullsGetResponseAssigneesItem>;
    requested_reviewers: Array<PullsGetResponseRequestedReviewersItem>;
    requested_teams: Array<PullsGetResponseRequestedTeamsItem>;
    head: PullsGetResponseHead;
    base: PullsGetResponseBase;
    _links: PullsGetResponseLinks;
    author_association: string;
    draft: boolean;
    merged: boolean;
    mergeable: boolean;
    rebaseable: boolean;
    mergeable_state: string;
    merged_by: PullsGetResponseMergedBy;
    comments: number;
    review_comments: number;
    maintainer_can_modify: boolean;
    commits: number;
    additions: number;
    deletions: number;
    changed_files: number;
  };
  type PullsListResponseItemLinksStatuses = { href: string };
  type PullsListResponseItemLinksCommits = { href: string };
  type PullsListResponseItemLinksReviewComment = { href: string };
  type PullsListResponseItemLinksReviewComments = { href: string };
  type PullsListResponseItemLinksComments = { href: string };
  type PullsListResponseItemLinksIssue = { href: string };
  type PullsListResponseItemLinksHtml = { href: string };
  type PullsListResponseItemLinksSelf = { href: string };
  type PullsListResponseItemLinks = {
    self: PullsListResponseItemLinksSelf;
    html: PullsListResponseItemLinksHtml;
    issue: PullsListResponseItemLinksIssue;
    comments: PullsListResponseItemLinksComments;
    review_comments: PullsListResponseItemLinksReviewComments;
    review_comment: PullsListResponseItemLinksReviewComment;
    commits: PullsListResponseItemLinksCommits;
    statuses: PullsListResponseItemLinksStatuses;
  };
  type PullsListResponseItemBaseRepoPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type PullsListResponseItemBaseRepoOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsListResponseItemBaseRepo = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: PullsListResponseItemBaseRepoOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: PullsListResponseItemBaseRepoPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type PullsListResponseItemBaseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsListResponseItemBase = {
    label: string;
    ref: string;
    sha: string;
    user: PullsListResponseItemBaseUser;
    repo: PullsListResponseItemBaseRepo;
  };
  type PullsListResponseItemHeadRepoPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type PullsListResponseItemHeadRepoOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsListResponseItemHeadRepo = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: PullsListResponseItemHeadRepoOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: PullsListResponseItemHeadRepoPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type PullsListResponseItemHeadUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsListResponseItemHead = {
    label: string;
    ref: string;
    sha: string;
    user: PullsListResponseItemHeadUser;
    repo: PullsListResponseItemHeadRepo;
  };
  type PullsListResponseItemRequestedTeamsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
  };
  type PullsListResponseItemRequestedReviewersItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsListResponseItemAssigneesItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsListResponseItemAssignee = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsListResponseItemMilestoneCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsListResponseItemMilestone = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: PullsListResponseItemMilestoneCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type PullsListResponseItemLabelsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type PullsListResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type PullsListResponseItem = {
    url: string;
    id: number;
    node_id: string;
    html_url: string;
    diff_url: string;
    patch_url: string;
    issue_url: string;
    commits_url: string;
    review_comments_url: string;
    review_comment_url: string;
    comments_url: string;
    statuses_url: string;
    number: number;
    state: string;
    locked: boolean;
    title: string;
    user: PullsListResponseItemUser;
    body: string;
    labels: Array<PullsListResponseItemLabelsItem>;
    milestone: PullsListResponseItemMilestone;
    active_lock_reason: string;
    created_at: string;
    updated_at: string;
    closed_at: string;
    merged_at: string;
    merge_commit_sha: string;
    assignee: PullsListResponseItemAssignee;
    assignees: Array<PullsListResponseItemAssigneesItem>;
    requested_reviewers: Array<PullsListResponseItemRequestedReviewersItem>;
    requested_teams: Array<PullsListResponseItemRequestedTeamsItem>;
    head: PullsListResponseItemHead;
    base: PullsListResponseItemBase;
    _links: PullsListResponseItemLinks;
    author_association: string;
    draft: boolean;
  };
  type ProjectsMoveColumnResponse = {};
  type ProjectsDeleteColumnResponse = {};
  type ProjectsListColumnsResponseItem = {
    url: string;
    project_url: string;
    cards_url: string;
    id: number;
    node_id: string;
    name: string;
    created_at: string;
    updated_at: string;
  };
  type ProjectsRemoveCollaboratorResponse = {};
  type ProjectsAddCollaboratorResponse = {};
  type ProjectsReviewUserPermissionLevelResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ProjectsReviewUserPermissionLevelResponse = {
    permission: string;
    user: ProjectsReviewUserPermissionLevelResponseUser;
  };
  type ProjectsListCollaboratorsResponseItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ProjectsMoveCardResponse = {};
  type ProjectsDeleteCardResponse = {};
  type ProjectsCreateCardResponseCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ProjectsCreateCardResponse = {
    url: string;
    id: number;
    node_id: string;
    note: string;
    creator: ProjectsCreateCardResponseCreator;
    created_at: string;
    updated_at: string;
    archived: boolean;
    column_url: string;
    content_url: string;
    project_url: string;
  };
  type ProjectsListCardsResponseItemCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ProjectsListCardsResponseItem = {
    url: string;
    id: number;
    node_id: string;
    note: string;
    creator: ProjectsListCardsResponseItemCreator;
    created_at: string;
    updated_at: string;
    archived: boolean;
    column_url: string;
    content_url: string;
    project_url: string;
  };
  type ProjectsUpdateResponseCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ProjectsUpdateResponse = {
    owner_url: string;
    url: string;
    html_url: string;
    columns_url: string;
    id: number;
    node_id: string;
    name: string;
    body: string;
    number: number;
    state: string;
    creator: ProjectsUpdateResponseCreator;
    created_at: string;
    updated_at: string;
  };
  type ProjectsCreateForAuthenticatedUserResponseCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ProjectsCreateForAuthenticatedUserResponse = {
    owner_url: string;
    url: string;
    html_url: string;
    columns_url: string;
    id: number;
    node_id: string;
    name: string;
    body: string;
    number: number;
    state: string;
    creator: ProjectsCreateForAuthenticatedUserResponseCreator;
    created_at: string;
    updated_at: string;
  };
  type ProjectsCreateForOrgResponseCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ProjectsCreateForOrgResponse = {
    owner_url: string;
    url: string;
    html_url: string;
    columns_url: string;
    id: number;
    node_id: string;
    name: string;
    body: string;
    number: number;
    state: string;
    creator: ProjectsCreateForOrgResponseCreator;
    created_at: string;
    updated_at: string;
  };
  type ProjectsCreateForRepoResponseCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ProjectsCreateForRepoResponse = {
    owner_url: string;
    url: string;
    html_url: string;
    columns_url: string;
    id: number;
    node_id: string;
    name: string;
    body: string;
    number: number;
    state: string;
    creator: ProjectsCreateForRepoResponseCreator;
    created_at: string;
    updated_at: string;
  };
  type ProjectsGetResponseCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ProjectsGetResponse = {
    owner_url: string;
    url: string;
    html_url: string;
    columns_url: string;
    id: number;
    node_id: string;
    name: string;
    body: string;
    number: number;
    state: string;
    creator: ProjectsGetResponseCreator;
    created_at: string;
    updated_at: string;
  };
  type ProjectsListForUserResponseItemCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ProjectsListForUserResponseItem = {
    owner_url: string;
    url: string;
    html_url: string;
    columns_url: string;
    id: number;
    node_id: string;
    name: string;
    body: string;
    number: number;
    state: string;
    creator: ProjectsListForUserResponseItemCreator;
    created_at: string;
    updated_at: string;
  };
  type ProjectsListForOrgResponseItemCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ProjectsListForOrgResponseItem = {
    owner_url: string;
    url: string;
    html_url: string;
    columns_url: string;
    id: number;
    node_id: string;
    name: string;
    body: string;
    number: number;
    state: string;
    creator: ProjectsListForOrgResponseItemCreator;
    created_at: string;
    updated_at: string;
  };
  type ProjectsListForRepoResponseItemCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ProjectsListForRepoResponseItem = {
    owner_url: string;
    url: string;
    html_url: string;
    columns_url: string;
    id: number;
    node_id: string;
    name: string;
    body: string;
    number: number;
    state: string;
    creator: ProjectsListForRepoResponseItemCreator;
    created_at: string;
    updated_at: string;
  };
  type OrgsConvertMemberToOutsideCollaboratorResponse = {};
  type OrgsRemoveOutsideCollaboratorResponse = {};
  type OrgsListOutsideCollaboratorsResponseItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type OrgsUpdateMembershipResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type OrgsUpdateMembershipResponseOrganization = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
  };
  type OrgsUpdateMembershipResponse = {
    url: string;
    state: string;
    role: string;
    organization_url: string;
    organization: OrgsUpdateMembershipResponseOrganization;
    user: OrgsUpdateMembershipResponseUser;
  };
  type OrgsGetMembershipForAuthenticatedUserResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type OrgsGetMembershipForAuthenticatedUserResponseOrganization = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
  };
  type OrgsGetMembershipForAuthenticatedUserResponse = {
    url: string;
    state: string;
    role: string;
    organization_url: string;
    organization: OrgsGetMembershipForAuthenticatedUserResponseOrganization;
    user: OrgsGetMembershipForAuthenticatedUserResponseUser;
  };
  type OrgsListMembershipsResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type OrgsListMembershipsResponseItemOrganization = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
  };
  type OrgsListMembershipsResponseItem = {
    url: string;
    state: string;
    role: string;
    organization_url: string;
    organization: OrgsListMembershipsResponseItemOrganization;
    user: OrgsListMembershipsResponseItemUser;
  };
  type OrgsCreateInvitationResponseInviter = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type OrgsCreateInvitationResponse = {
    id: number;
    login: string;
    email: string;
    role: string;
    created_at: string;
    inviter: OrgsCreateInvitationResponseInviter;
    team_count: number;
    invitation_team_url: string;
  };
  type OrgsListPendingInvitationsResponseItemInviter = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type OrgsListPendingInvitationsResponseItem = {
    id: number;
    login: string;
    email: string;
    role: string;
    created_at: string;
    inviter: OrgsListPendingInvitationsResponseItemInviter;
    team_count: number;
    invitation_team_url: string;
  };
  type OrgsListInvitationTeamsResponseItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    slug: string;
    description: string;
    privacy: string;
    permission: string;
    members_url: string;
    repositories_url: string;
    parent: null;
  };
  type OrgsRemoveMembershipResponse = {};
  type OrgsConcealMembershipResponse = {};
  type OrgsPublicizeMembershipResponse = {};
  type OrgsListPublicMembersResponseItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type OrgsRemoveMemberResponse = {};
  type OrgsListMembersResponseItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type OrgsDeleteHookResponse = {};
  type OrgsPingHookResponse = {};
  type OrgsUpdateHookResponseConfig = { url: string; content_type: string };
  type OrgsUpdateHookResponse = {
    id: number;
    url: string;
    ping_url: string;
    name: string;
    events: Array<string>;
    active: boolean;
    config: OrgsUpdateHookResponseConfig;
    updated_at: string;
    created_at: string;
  };
  type OrgsCreateHookResponseConfig = { url: string; content_type: string };
  type OrgsCreateHookResponse = {
    id: number;
    url: string;
    ping_url: string;
    name: string;
    events: Array<string>;
    active: boolean;
    config: OrgsCreateHookResponseConfig;
    updated_at: string;
    created_at: string;
  };
  type OrgsGetHookResponseConfig = { url: string; content_type: string };
  type OrgsGetHookResponse = {
    id: number;
    url: string;
    ping_url: string;
    name: string;
    events: Array<string>;
    active: boolean;
    config: OrgsGetHookResponseConfig;
    updated_at: string;
    created_at: string;
  };
  type OrgsListHooksResponseItemConfig = { url: string; content_type: string };
  type OrgsListHooksResponseItem = {
    id: number;
    url: string;
    ping_url: string;
    name: string;
    events: Array<string>;
    active: boolean;
    config: OrgsListHooksResponseItemConfig;
    updated_at: string;
    created_at: string;
  };
  type OrgsUnblockUserResponse = {};
  type OrgsBlockUserResponse = {};
  type OrgsCheckBlockedUserResponse = {};
  type OrgsListBlockedUsersResponseItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type OrgsUpdateResponsePlan = {
    name: string;
    space: number;
    private_repos: number;
  };
  type OrgsUpdateResponse = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
    name: string;
    company: string;
    blog: string;
    location: string;
    email: string;
    is_verified: boolean;
    has_organization_projects: boolean;
    has_repository_projects: boolean;
    public_repos: number;
    public_gists: number;
    followers: number;
    following: number;
    html_url: string;
    created_at: string;
    type: string;
    total_private_repos: number;
    owned_private_repos: number;
    private_gists: number;
    disk_usage: number;
    collaborators: number;
    billing_email: string;
    plan: OrgsUpdateResponsePlan;
    default_repository_settings: string;
    members_can_create_repositories: boolean;
    two_factor_requirement_enabled: boolean;
    members_allowed_repository_creation_type: string;
  };
  type OrgsGetResponsePlan = {
    name: string;
    space: number;
    private_repos: number;
  };
  type OrgsGetResponse = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
    name: string;
    company: string;
    blog: string;
    location: string;
    email: string;
    is_verified: boolean;
    has_organization_projects: boolean;
    has_repository_projects: boolean;
    public_repos: number;
    public_gists: number;
    followers: number;
    following: number;
    html_url: string;
    created_at: string;
    type: string;
    total_private_repos: number;
    owned_private_repos: number;
    private_gists: number;
    disk_usage: number;
    collaborators: number;
    billing_email: string;
    plan: OrgsGetResponsePlan;
    default_repository_settings: string;
    members_can_create_repositories: boolean;
    two_factor_requirement_enabled: boolean;
    members_allowed_repository_creation_type: string;
  };
  type OrgsListForUserResponseItem = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
  };
  type OrgsListResponseItem = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
  };
  type OrgsListForAuthenticatedUserResponseItem = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
  };
  type OauthAuthorizationsRevokeGrantForApplicationResponse = {};
  type OauthAuthorizationsRevokeAuthorizationForApplicationResponse = {};
  type OauthAuthorizationsResetAuthorizationResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type OauthAuthorizationsResetAuthorizationResponseApp = {
    url: string;
    name: string;
    client_id: string;
  };
  type OauthAuthorizationsResetAuthorizationResponse = {
    id: number;
    url: string;
    scopes: Array<string>;
    token: string;
    token_last_eight: string;
    hashed_token: string;
    app: OauthAuthorizationsResetAuthorizationResponseApp;
    note: string;
    note_url: string;
    updated_at: string;
    created_at: string;
    fingerprint: string;
    user: OauthAuthorizationsResetAuthorizationResponseUser;
  };
  type OauthAuthorizationsCheckAuthorizationResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type OauthAuthorizationsCheckAuthorizationResponseApp = {
    url: string;
    name: string;
    client_id: string;
  };
  type OauthAuthorizationsCheckAuthorizationResponse = {
    id: number;
    url: string;
    scopes: Array<string>;
    token: string;
    token_last_eight: string;
    hashed_token: string;
    app: OauthAuthorizationsCheckAuthorizationResponseApp;
    note: string;
    note_url: string;
    updated_at: string;
    created_at: string;
    fingerprint: string;
    user: OauthAuthorizationsCheckAuthorizationResponseUser;
  };
  type OauthAuthorizationsDeleteAuthorizationResponse = {};
  type OauthAuthorizationsUpdateAuthorizationResponseApp = {
    url: string;
    name: string;
    client_id: string;
  };
  type OauthAuthorizationsUpdateAuthorizationResponse = {
    id: number;
    url: string;
    scopes: Array<string>;
    token: string;
    token_last_eight: string;
    hashed_token: string;
    app: OauthAuthorizationsUpdateAuthorizationResponseApp;
    note: string;
    note_url: string;
    updated_at: string;
    created_at: string;
    fingerprint: string;
  };
  type OauthAuthorizationsCreateAuthorizationResponseApp = {
    url: string;
    name: string;
    client_id: string;
  };
  type OauthAuthorizationsCreateAuthorizationResponse = {
    id: number;
    url: string;
    scopes: Array<string>;
    token: string;
    token_last_eight: string;
    hashed_token: string;
    app: OauthAuthorizationsCreateAuthorizationResponseApp;
    note: string;
    note_url: string;
    updated_at: string;
    created_at: string;
    fingerprint: string;
  };
  type OauthAuthorizationsGetAuthorizationResponseApp = {
    url: string;
    name: string;
    client_id: string;
  };
  type OauthAuthorizationsGetAuthorizationResponse = {
    id: number;
    url: string;
    scopes: Array<string>;
    token: string;
    token_last_eight: string;
    hashed_token: string;
    app: OauthAuthorizationsGetAuthorizationResponseApp;
    note: string;
    note_url: string;
    updated_at: string;
    created_at: string;
    fingerprint: string;
  };
  type OauthAuthorizationsListAuthorizationsResponseItemApp = {
    url: string;
    name: string;
    client_id: string;
  };
  type OauthAuthorizationsListAuthorizationsResponseItem = {
    id: number;
    url: string;
    scopes: Array<string>;
    token: string;
    token_last_eight: string;
    hashed_token: string;
    app: OauthAuthorizationsListAuthorizationsResponseItemApp;
    note: string;
    note_url: string;
    updated_at: string;
    created_at: string;
    fingerprint: string;
  };
  type OauthAuthorizationsDeleteGrantResponse = {};
  type OauthAuthorizationsGetGrantResponseApp = {
    url: string;
    name: string;
    client_id: string;
  };
  type OauthAuthorizationsGetGrantResponse = {
    id: number;
    url: string;
    app: OauthAuthorizationsGetGrantResponseApp;
    created_at: string;
    updated_at: string;
    scopes: Array<string>;
  };
  type OauthAuthorizationsListGrantsResponseItemApp = {
    url: string;
    name: string;
    client_id: string;
  };
  type OauthAuthorizationsListGrantsResponseItem = {
    id: number;
    url: string;
    app: OauthAuthorizationsListGrantsResponseItemApp;
    created_at: string;
    updated_at: string;
    scopes: Array<string>;
  };
  type MigrationsUnlockRepoForAuthenticatedUserResponse = {};
  type MigrationsDeleteArchiveForAuthenticatedUserResponse = {};
  type MigrationsGetArchiveForAuthenticatedUserResponse = {};
  type MigrationsGetStatusForAuthenticatedUserResponseRepositoriesItemPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type MigrationsGetStatusForAuthenticatedUserResponseRepositoriesItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type MigrationsGetStatusForAuthenticatedUserResponseRepositoriesItem = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: MigrationsGetStatusForAuthenticatedUserResponseRepositoriesItemOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: MigrationsGetStatusForAuthenticatedUserResponseRepositoriesItemPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type MigrationsGetStatusForAuthenticatedUserResponseOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type MigrationsGetStatusForAuthenticatedUserResponse = {
    id: number;
    owner: MigrationsGetStatusForAuthenticatedUserResponseOwner;
    guid: string;
    state: string;
    lock_repositories: boolean;
    exclude_attachments: boolean;
    repositories: Array<
      MigrationsGetStatusForAuthenticatedUserResponseRepositoriesItem
    >;
    url: string;
    created_at: string;
    updated_at: string;
  };
  type MigrationsListForAuthenticatedUserResponseItemRepositoriesItemPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type MigrationsListForAuthenticatedUserResponseItemRepositoriesItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type MigrationsListForAuthenticatedUserResponseItemRepositoriesItem = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: MigrationsListForAuthenticatedUserResponseItemRepositoriesItemOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: MigrationsListForAuthenticatedUserResponseItemRepositoriesItemPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type MigrationsListForAuthenticatedUserResponseItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type MigrationsListForAuthenticatedUserResponseItem = {
    id: number;
    owner: MigrationsListForAuthenticatedUserResponseItemOwner;
    guid: string;
    state: string;
    lock_repositories: boolean;
    exclude_attachments: boolean;
    repositories: Array<
      MigrationsListForAuthenticatedUserResponseItemRepositoriesItem
    >;
    url: string;
    created_at: string;
    updated_at: string;
  };
  type MigrationsStartForAuthenticatedUserResponseRepositoriesItemPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type MigrationsStartForAuthenticatedUserResponseRepositoriesItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type MigrationsStartForAuthenticatedUserResponseRepositoriesItem = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: MigrationsStartForAuthenticatedUserResponseRepositoriesItemOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: MigrationsStartForAuthenticatedUserResponseRepositoriesItemPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type MigrationsStartForAuthenticatedUserResponseOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type MigrationsStartForAuthenticatedUserResponse = {
    id: number;
    owner: MigrationsStartForAuthenticatedUserResponseOwner;
    guid: string;
    state: string;
    lock_repositories: boolean;
    exclude_attachments: boolean;
    repositories: Array<
      MigrationsStartForAuthenticatedUserResponseRepositoriesItem
    >;
    url: string;
    created_at: string;
    updated_at: string;
  };
  type MigrationsCancelImportResponse = {};
  type MigrationsGetLargeFilesResponseItem = {
    ref_name: string;
    path: string;
    oid: string;
    size: number;
  };
  type MigrationsSetLfsPreferenceResponse = {
    vcs: string;
    use_lfs: string;
    vcs_url: string;
    status: string;
    status_text: string;
    has_large_files: boolean;
    large_files_size: number;
    large_files_count: number;
    authors_count: number;
    url: string;
    html_url: string;
    authors_url: string;
    repository_url: string;
  };
  type MigrationsMapCommitAuthorResponse = {
    id: number;
    remote_id: string;
    remote_name: string;
    email: string;
    name: string;
    url: string;
    import_url: string;
  };
  type MigrationsGetCommitAuthorsResponseItem = {
    id: number;
    remote_id: string;
    remote_name: string;
    email: string;
    name: string;
    url: string;
    import_url: string;
  };
  type MigrationsUpdateImportResponse = {
    vcs: string;
    use_lfs: string;
    vcs_url: string;
    status: string;
    url: string;
    html_url: string;
    authors_url: string;
    repository_url: string;
  };
  type MigrationsGetImportProgressResponse = {
    vcs: string;
    use_lfs: string;
    vcs_url: string;
    status: string;
    status_text: string;
    has_large_files: boolean;
    large_files_size: number;
    large_files_count: number;
    authors_count: number;
    url: string;
    html_url: string;
    authors_url: string;
    repository_url: string;
  };
  type MigrationsStartImportResponse = {
    vcs: string;
    use_lfs: string;
    vcs_url: string;
    status: string;
    status_text: string;
    has_large_files: boolean;
    large_files_size: number;
    large_files_count: number;
    authors_count: number;
    percent: number;
    commit_count: number;
    url: string;
    html_url: string;
    authors_url: string;
    repository_url: string;
  };
  type MigrationsUnlockRepoForOrgResponse = {};
  type MigrationsDeleteArchiveForOrgResponse = {};
  type MigrationsGetArchiveForOrgResponse = {};
  type MigrationsGetStatusForOrgResponseRepositoriesItemPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type MigrationsGetStatusForOrgResponseRepositoriesItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type MigrationsGetStatusForOrgResponseRepositoriesItem = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: MigrationsGetStatusForOrgResponseRepositoriesItemOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: MigrationsGetStatusForOrgResponseRepositoriesItemPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type MigrationsGetStatusForOrgResponseOwner = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
  };
  type MigrationsGetStatusForOrgResponse = {
    id: number;
    owner: MigrationsGetStatusForOrgResponseOwner;
    guid: string;
    state: string;
    lock_repositories: boolean;
    exclude_attachments: boolean;
    repositories: Array<MigrationsGetStatusForOrgResponseRepositoriesItem>;
    url: string;
    created_at: string;
    updated_at: string;
  };
  type MigrationsListForOrgResponseItemRepositoriesItemPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type MigrationsListForOrgResponseItemRepositoriesItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type MigrationsListForOrgResponseItemRepositoriesItem = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: MigrationsListForOrgResponseItemRepositoriesItemOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: MigrationsListForOrgResponseItemRepositoriesItemPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type MigrationsListForOrgResponseItemOwner = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
  };
  type MigrationsListForOrgResponseItem = {
    id: number;
    owner: MigrationsListForOrgResponseItemOwner;
    guid: string;
    state: string;
    lock_repositories: boolean;
    exclude_attachments: boolean;
    repositories: Array<MigrationsListForOrgResponseItemRepositoriesItem>;
    url: string;
    created_at: string;
    updated_at: string;
  };
  type MigrationsStartForOrgResponseRepositoriesItemPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type MigrationsStartForOrgResponseRepositoriesItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type MigrationsStartForOrgResponseRepositoriesItem = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: MigrationsStartForOrgResponseRepositoriesItemOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: MigrationsStartForOrgResponseRepositoriesItemPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type MigrationsStartForOrgResponseOwner = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
  };
  type MigrationsStartForOrgResponse = {
    id: number;
    owner: MigrationsStartForOrgResponseOwner;
    guid: string;
    state: string;
    lock_repositories: boolean;
    exclude_attachments: boolean;
    repositories: Array<MigrationsStartForOrgResponseRepositoriesItem>;
    url: string;
    created_at: string;
    updated_at: string;
  };
  type MetaGetResponse = {
    verifiable_password_authentication: boolean;
    hooks: Array<string>;
    git: Array<string>;
    pages: Array<string>;
    importer: Array<string>;
  };
  type MarkdownRenderRawResponse = {};
  type MarkdownRenderResponse = {};
  type LicensesGetForRepoResponseLicense = {
    key: string;
    name: string;
    spdx_id: string;
    url: string;
    node_id: string;
  };
  type LicensesGetForRepoResponseLinks = {
    self: string;
    git: string;
    html: string;
  };
  type LicensesGetForRepoResponse = {
    name: string;
    path: string;
    sha: string;
    size: number;
    url: string;
    html_url: string;
    git_url: string;
    download_url: string;
    type: string;
    content: string;
    encoding: string;
    _links: LicensesGetForRepoResponseLinks;
    license: LicensesGetForRepoResponseLicense;
  };
  type LicensesGetResponse = {
    key: string;
    name: string;
    spdx_id: string;
    url: string;
    node_id: string;
    html_url: string;
    description: string;
    implementation: string;
    permissions: Array<string>;
    conditions: Array<string>;
    limitations: Array<string>;
    body: string;
    featured: boolean;
  };
  type LicensesListResponseItem = {
    key: string;
    name: string;
    spdx_id: string;
    url: string;
    node_id?: string;
  };
  type LicensesListCommonlyUsedResponseItem = {
    key: string;
    name: string;
    spdx_id: string;
    url: string;
    node_id?: string;
  };
  type IssuesListEventsForTimelineResponseItemActor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListEventsForTimelineResponseItem = {
    id: number;
    node_id: string;
    url: string;
    actor: IssuesListEventsForTimelineResponseItemActor;
    event: string;
    commit_id: string;
    commit_url: string;
    created_at: string;
  };
  type IssuesDeleteMilestoneResponse = {};
  type IssuesUpdateMilestoneResponseCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesUpdateMilestoneResponse = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: IssuesUpdateMilestoneResponseCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type IssuesCreateMilestoneResponseCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesCreateMilestoneResponse = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: IssuesCreateMilestoneResponseCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type IssuesGetMilestoneResponseCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesGetMilestoneResponse = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: IssuesGetMilestoneResponseCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type IssuesListMilestonesForRepoResponseItemCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListMilestonesForRepoResponseItem = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: IssuesListMilestonesForRepoResponseItemCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type IssuesListLabelsForMilestoneResponseItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type IssuesRemoveLabelsResponse = {};
  type IssuesReplaceLabelsResponseItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type IssuesRemoveLabelResponseItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type IssuesAddLabelsResponseItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type IssuesListLabelsOnIssueResponseItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type IssuesDeleteLabelResponse = {};
  type IssuesUpdateLabelResponse = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type IssuesCreateLabelResponse = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type IssuesGetLabelResponse = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type IssuesListLabelsForRepoResponseItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type IssuesGetEventResponseIssuePullRequest = {
    url: string;
    html_url: string;
    diff_url: string;
    patch_url: string;
  };
  type IssuesGetEventResponseIssueMilestoneCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesGetEventResponseIssueMilestone = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: IssuesGetEventResponseIssueMilestoneCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type IssuesGetEventResponseIssueAssigneesItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesGetEventResponseIssueAssignee = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesGetEventResponseIssueLabelsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type IssuesGetEventResponseIssueUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesGetEventResponseIssue = {
    id: number;
    node_id: string;
    url: string;
    repository_url: string;
    labels_url: string;
    comments_url: string;
    events_url: string;
    html_url: string;
    number: number;
    state: string;
    title: string;
    body: string;
    user: IssuesGetEventResponseIssueUser;
    labels: Array<IssuesGetEventResponseIssueLabelsItem>;
    assignee: IssuesGetEventResponseIssueAssignee;
    assignees: Array<IssuesGetEventResponseIssueAssigneesItem>;
    milestone: IssuesGetEventResponseIssueMilestone;
    locked: boolean;
    active_lock_reason: string;
    comments: number;
    pull_request: IssuesGetEventResponseIssuePullRequest;
    closed_at: null;
    created_at: string;
    updated_at: string;
  };
  type IssuesGetEventResponseActor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesGetEventResponse = {
    id: number;
    node_id: string;
    url: string;
    actor: IssuesGetEventResponseActor;
    event: string;
    commit_id: string;
    commit_url: string;
    created_at: string;
    issue: IssuesGetEventResponseIssue;
  };
  type IssuesListEventsForRepoResponseItemIssuePullRequest = {
    url: string;
    html_url: string;
    diff_url: string;
    patch_url: string;
  };
  type IssuesListEventsForRepoResponseItemIssueMilestoneCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListEventsForRepoResponseItemIssueMilestone = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: IssuesListEventsForRepoResponseItemIssueMilestoneCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type IssuesListEventsForRepoResponseItemIssueAssigneesItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListEventsForRepoResponseItemIssueAssignee = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListEventsForRepoResponseItemIssueLabelsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type IssuesListEventsForRepoResponseItemIssueUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListEventsForRepoResponseItemIssue = {
    id: number;
    node_id: string;
    url: string;
    repository_url: string;
    labels_url: string;
    comments_url: string;
    events_url: string;
    html_url: string;
    number: number;
    state: string;
    title: string;
    body: string;
    user: IssuesListEventsForRepoResponseItemIssueUser;
    labels: Array<IssuesListEventsForRepoResponseItemIssueLabelsItem>;
    assignee: IssuesListEventsForRepoResponseItemIssueAssignee;
    assignees: Array<IssuesListEventsForRepoResponseItemIssueAssigneesItem>;
    milestone: IssuesListEventsForRepoResponseItemIssueMilestone;
    locked: boolean;
    active_lock_reason: string;
    comments: number;
    pull_request: IssuesListEventsForRepoResponseItemIssuePullRequest;
    closed_at: null;
    created_at: string;
    updated_at: string;
  };
  type IssuesListEventsForRepoResponseItemActor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListEventsForRepoResponseItem = {
    id: number;
    node_id: string;
    url: string;
    actor: IssuesListEventsForRepoResponseItemActor;
    event: string;
    commit_id: string;
    commit_url: string;
    created_at: string;
    issue: IssuesListEventsForRepoResponseItemIssue;
  };
  type IssuesListEventsResponseItemActor = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListEventsResponseItem = {
    id: number;
    node_id: string;
    url: string;
    actor: IssuesListEventsResponseItemActor;
    event: string;
    commit_id: string;
    commit_url: string;
    created_at: string;
  };
  type IssuesDeleteCommentResponse = {};
  type IssuesUpdateCommentResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesUpdateCommentResponse = {
    id: number;
    node_id: string;
    url: string;
    html_url: string;
    body: string;
    user: IssuesUpdateCommentResponseUser;
    created_at: string;
    updated_at: string;
  };
  type IssuesCreateCommentResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesCreateCommentResponse = {
    id: number;
    node_id: string;
    url: string;
    html_url: string;
    body: string;
    user: IssuesCreateCommentResponseUser;
    created_at: string;
    updated_at: string;
  };
  type IssuesGetCommentResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesGetCommentResponse = {
    id: number;
    node_id: string;
    url: string;
    html_url: string;
    body: string;
    user: IssuesGetCommentResponseUser;
    created_at: string;
    updated_at: string;
  };
  type IssuesListCommentsForRepoResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListCommentsForRepoResponseItem = {
    id: number;
    node_id: string;
    url: string;
    html_url: string;
    body: string;
    user: IssuesListCommentsForRepoResponseItemUser;
    created_at: string;
    updated_at: string;
  };
  type IssuesListCommentsResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListCommentsResponseItem = {
    id: number;
    node_id: string;
    url: string;
    html_url: string;
    body: string;
    user: IssuesListCommentsResponseItemUser;
    created_at: string;
    updated_at: string;
  };
  type IssuesRemoveAssigneesResponsePullRequest = {
    url: string;
    html_url: string;
    diff_url: string;
    patch_url: string;
  };
  type IssuesRemoveAssigneesResponseMilestoneCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesRemoveAssigneesResponseMilestone = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: IssuesRemoveAssigneesResponseMilestoneCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type IssuesRemoveAssigneesResponseAssigneesItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesRemoveAssigneesResponseAssignee = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesRemoveAssigneesResponseLabelsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type IssuesRemoveAssigneesResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesRemoveAssigneesResponse = {
    id: number;
    node_id: string;
    url: string;
    repository_url: string;
    labels_url: string;
    comments_url: string;
    events_url: string;
    html_url: string;
    number: number;
    state: string;
    title: string;
    body: string;
    user: IssuesRemoveAssigneesResponseUser;
    labels: Array<IssuesRemoveAssigneesResponseLabelsItem>;
    assignee: IssuesRemoveAssigneesResponseAssignee;
    assignees: Array<IssuesRemoveAssigneesResponseAssigneesItem>;
    milestone: IssuesRemoveAssigneesResponseMilestone;
    locked: boolean;
    active_lock_reason: string;
    comments: number;
    pull_request: IssuesRemoveAssigneesResponsePullRequest;
    closed_at: null;
    created_at: string;
    updated_at: string;
  };
  type IssuesAddAssigneesResponsePullRequest = {
    url: string;
    html_url: string;
    diff_url: string;
    patch_url: string;
  };
  type IssuesAddAssigneesResponseMilestoneCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesAddAssigneesResponseMilestone = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: IssuesAddAssigneesResponseMilestoneCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type IssuesAddAssigneesResponseAssigneesItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesAddAssigneesResponseAssignee = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesAddAssigneesResponseLabelsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type IssuesAddAssigneesResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesAddAssigneesResponse = {
    id: number;
    node_id: string;
    url: string;
    repository_url: string;
    labels_url: string;
    comments_url: string;
    events_url: string;
    html_url: string;
    number: number;
    state: string;
    title: string;
    body: string;
    user: IssuesAddAssigneesResponseUser;
    labels: Array<IssuesAddAssigneesResponseLabelsItem>;
    assignee: IssuesAddAssigneesResponseAssignee;
    assignees: Array<IssuesAddAssigneesResponseAssigneesItem>;
    milestone: IssuesAddAssigneesResponseMilestone;
    locked: boolean;
    active_lock_reason: string;
    comments: number;
    pull_request: IssuesAddAssigneesResponsePullRequest;
    closed_at: null;
    created_at: string;
    updated_at: string;
  };
  type IssuesCheckAssigneeResponse = {};
  type IssuesListAssigneesResponseItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesUnlockResponse = {};
  type IssuesLockResponse = {};
  type IssuesUpdateResponseClosedBy = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesUpdateResponsePullRequest = {
    url: string;
    html_url: string;
    diff_url: string;
    patch_url: string;
  };
  type IssuesUpdateResponseMilestoneCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesUpdateResponseMilestone = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: IssuesUpdateResponseMilestoneCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type IssuesUpdateResponseAssigneesItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesUpdateResponseAssignee = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesUpdateResponseLabelsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type IssuesUpdateResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesUpdateResponse = {
    id: number;
    node_id: string;
    url: string;
    repository_url: string;
    labels_url: string;
    comments_url: string;
    events_url: string;
    html_url: string;
    number: number;
    state: string;
    title: string;
    body: string;
    user: IssuesUpdateResponseUser;
    labels: Array<IssuesUpdateResponseLabelsItem>;
    assignee: IssuesUpdateResponseAssignee;
    assignees: Array<IssuesUpdateResponseAssigneesItem>;
    milestone: IssuesUpdateResponseMilestone;
    locked: boolean;
    active_lock_reason: string;
    comments: number;
    pull_request: IssuesUpdateResponsePullRequest;
    closed_at: null;
    created_at: string;
    updated_at: string;
    closed_by: IssuesUpdateResponseClosedBy;
  };
  type IssuesCreateResponseClosedBy = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesCreateResponsePullRequest = {
    url: string;
    html_url: string;
    diff_url: string;
    patch_url: string;
  };
  type IssuesCreateResponseMilestoneCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesCreateResponseMilestone = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: IssuesCreateResponseMilestoneCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type IssuesCreateResponseAssigneesItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesCreateResponseAssignee = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesCreateResponseLabelsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type IssuesCreateResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesCreateResponse = {
    id: number;
    node_id: string;
    url: string;
    repository_url: string;
    labels_url: string;
    comments_url: string;
    events_url: string;
    html_url: string;
    number: number;
    state: string;
    title: string;
    body: string;
    user: IssuesCreateResponseUser;
    labels: Array<IssuesCreateResponseLabelsItem>;
    assignee: IssuesCreateResponseAssignee;
    assignees: Array<IssuesCreateResponseAssigneesItem>;
    milestone: IssuesCreateResponseMilestone;
    locked: boolean;
    active_lock_reason: string;
    comments: number;
    pull_request: IssuesCreateResponsePullRequest;
    closed_at: null;
    created_at: string;
    updated_at: string;
    closed_by: IssuesCreateResponseClosedBy;
  };
  type IssuesGetResponseClosedBy = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesGetResponsePullRequest = {
    url: string;
    html_url: string;
    diff_url: string;
    patch_url: string;
  };
  type IssuesGetResponseMilestoneCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesGetResponseMilestone = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: IssuesGetResponseMilestoneCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type IssuesGetResponseAssigneesItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesGetResponseAssignee = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesGetResponseLabelsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type IssuesGetResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesGetResponse = {
    id: number;
    node_id: string;
    url: string;
    repository_url: string;
    labels_url: string;
    comments_url: string;
    events_url: string;
    html_url: string;
    number: number;
    state: string;
    title: string;
    body: string;
    user: IssuesGetResponseUser;
    labels: Array<IssuesGetResponseLabelsItem>;
    assignee: IssuesGetResponseAssignee;
    assignees: Array<IssuesGetResponseAssigneesItem>;
    milestone: IssuesGetResponseMilestone;
    locked: boolean;
    active_lock_reason: string;
    comments: number;
    pull_request: IssuesGetResponsePullRequest;
    closed_at: null;
    created_at: string;
    updated_at: string;
    closed_by: IssuesGetResponseClosedBy;
  };
  type IssuesListForRepoResponseItemPullRequest = {
    url: string;
    html_url: string;
    diff_url: string;
    patch_url: string;
  };
  type IssuesListForRepoResponseItemMilestoneCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListForRepoResponseItemMilestone = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: IssuesListForRepoResponseItemMilestoneCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type IssuesListForRepoResponseItemAssigneesItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListForRepoResponseItemAssignee = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListForRepoResponseItemLabelsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type IssuesListForRepoResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListForRepoResponseItem = {
    id: number;
    node_id: string;
    url: string;
    repository_url: string;
    labels_url: string;
    comments_url: string;
    events_url: string;
    html_url: string;
    number: number;
    state: string;
    title: string;
    body: string;
    user: IssuesListForRepoResponseItemUser;
    labels: Array<IssuesListForRepoResponseItemLabelsItem>;
    assignee: IssuesListForRepoResponseItemAssignee;
    assignees: Array<IssuesListForRepoResponseItemAssigneesItem>;
    milestone: IssuesListForRepoResponseItemMilestone;
    locked: boolean;
    active_lock_reason: string;
    comments: number;
    pull_request: IssuesListForRepoResponseItemPullRequest;
    closed_at: null;
    created_at: string;
    updated_at: string;
  };
  type IssuesListForOrgResponseItemRepositoryPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type IssuesListForOrgResponseItemRepositoryOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListForOrgResponseItemRepository = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: IssuesListForOrgResponseItemRepositoryOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: IssuesListForOrgResponseItemRepositoryPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type IssuesListForOrgResponseItemPullRequest = {
    url: string;
    html_url: string;
    diff_url: string;
    patch_url: string;
  };
  type IssuesListForOrgResponseItemMilestoneCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListForOrgResponseItemMilestone = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: IssuesListForOrgResponseItemMilestoneCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type IssuesListForOrgResponseItemAssigneesItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListForOrgResponseItemAssignee = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListForOrgResponseItemLabelsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type IssuesListForOrgResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListForOrgResponseItem = {
    id: number;
    node_id: string;
    url: string;
    repository_url: string;
    labels_url: string;
    comments_url: string;
    events_url: string;
    html_url: string;
    number: number;
    state: string;
    title: string;
    body: string;
    user: IssuesListForOrgResponseItemUser;
    labels: Array<IssuesListForOrgResponseItemLabelsItem>;
    assignee: IssuesListForOrgResponseItemAssignee;
    assignees: Array<IssuesListForOrgResponseItemAssigneesItem>;
    milestone: IssuesListForOrgResponseItemMilestone;
    locked: boolean;
    active_lock_reason: string;
    comments: number;
    pull_request: IssuesListForOrgResponseItemPullRequest;
    closed_at: null;
    created_at: string;
    updated_at: string;
    repository: IssuesListForOrgResponseItemRepository;
  };
  type IssuesListForAuthenticatedUserResponseItemRepositoryPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type IssuesListForAuthenticatedUserResponseItemRepositoryOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListForAuthenticatedUserResponseItemRepository = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: IssuesListForAuthenticatedUserResponseItemRepositoryOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: IssuesListForAuthenticatedUserResponseItemRepositoryPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type IssuesListForAuthenticatedUserResponseItemPullRequest = {
    url: string;
    html_url: string;
    diff_url: string;
    patch_url: string;
  };
  type IssuesListForAuthenticatedUserResponseItemMilestoneCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListForAuthenticatedUserResponseItemMilestone = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: IssuesListForAuthenticatedUserResponseItemMilestoneCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type IssuesListForAuthenticatedUserResponseItemAssigneesItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListForAuthenticatedUserResponseItemAssignee = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListForAuthenticatedUserResponseItemLabelsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type IssuesListForAuthenticatedUserResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListForAuthenticatedUserResponseItem = {
    id: number;
    node_id: string;
    url: string;
    repository_url: string;
    labels_url: string;
    comments_url: string;
    events_url: string;
    html_url: string;
    number: number;
    state: string;
    title: string;
    body: string;
    user: IssuesListForAuthenticatedUserResponseItemUser;
    labels: Array<IssuesListForAuthenticatedUserResponseItemLabelsItem>;
    assignee: IssuesListForAuthenticatedUserResponseItemAssignee;
    assignees: Array<IssuesListForAuthenticatedUserResponseItemAssigneesItem>;
    milestone: IssuesListForAuthenticatedUserResponseItemMilestone;
    locked: boolean;
    active_lock_reason: string;
    comments: number;
    pull_request: IssuesListForAuthenticatedUserResponseItemPullRequest;
    closed_at: null;
    created_at: string;
    updated_at: string;
    repository: IssuesListForAuthenticatedUserResponseItemRepository;
  };
  type IssuesListResponseItemRepositoryPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type IssuesListResponseItemRepositoryOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListResponseItemRepository = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: IssuesListResponseItemRepositoryOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: IssuesListResponseItemRepositoryPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type IssuesListResponseItemPullRequest = {
    url: string;
    html_url: string;
    diff_url: string;
    patch_url: string;
  };
  type IssuesListResponseItemMilestoneCreator = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListResponseItemMilestone = {
    url: string;
    html_url: string;
    labels_url: string;
    id: number;
    node_id: string;
    number: number;
    state: string;
    title: string;
    description: string;
    creator: IssuesListResponseItemMilestoneCreator;
    open_issues: number;
    closed_issues: number;
    created_at: string;
    updated_at: string;
    closed_at: string;
    due_on: string;
  };
  type IssuesListResponseItemAssigneesItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListResponseItemAssignee = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListResponseItemLabelsItem = {
    id: number;
    node_id: string;
    url: string;
    name: string;
    description: string;
    color: string;
    default: boolean;
  };
  type IssuesListResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type IssuesListResponseItem = {
    id: number;
    node_id: string;
    url: string;
    repository_url: string;
    labels_url: string;
    comments_url: string;
    events_url: string;
    html_url: string;
    number: number;
    state: string;
    title: string;
    body: string;
    user: IssuesListResponseItemUser;
    labels: Array<IssuesListResponseItemLabelsItem>;
    assignee: IssuesListResponseItemAssignee;
    assignees: Array<IssuesListResponseItemAssigneesItem>;
    milestone: IssuesListResponseItemMilestone;
    locked: boolean;
    active_lock_reason: string;
    comments: number;
    pull_request: IssuesListResponseItemPullRequest;
    closed_at: null;
    created_at: string;
    updated_at: string;
    repository: IssuesListResponseItemRepository;
  };
  type InteractionsRemoveRestrictionsForRepoResponse = {};
  type InteractionsAddOrUpdateRestrictionsForRepoResponse = {
    limit: string;
    origin: string;
    expires_at: string;
  };
  type InteractionsGetRestrictionsForRepoResponse = {
    limit: string;
    origin: string;
    expires_at: string;
  };
  type InteractionsRemoveRestrictionsForOrgResponse = {};
  type InteractionsAddOrUpdateRestrictionsForOrgResponse = {
    limit: string;
    origin: string;
    expires_at: string;
  };
  type InteractionsGetRestrictionsForOrgResponse = {
    limit: string;
    origin: string;
    expires_at: string;
  };
  type GitignoreGetTemplateResponse = { name?: string; source?: string };
  type GitCreateTreeResponseTreeItem = {
    path: string;
    mode: string;
    type: string;
    size: number;
    sha: string;
    url: string;
  };
  type GitCreateTreeResponse = {
    sha: string;
    url: string;
    tree: Array<GitCreateTreeResponseTreeItem>;
  };
  type GitCreateTagResponseVerification = {
    verified: boolean;
    reason: string;
    signature: null;
    payload: null;
  };
  type GitCreateTagResponseObject = { type: string; sha: string; url: string };
  type GitCreateTagResponseTagger = {
    name: string;
    email: string;
    date: string;
  };
  type GitCreateTagResponse = {
    node_id: string;
    tag: string;
    sha: string;
    url: string;
    message: string;
    tagger: GitCreateTagResponseTagger;
    object: GitCreateTagResponseObject;
    verification: GitCreateTagResponseVerification;
  };
  type GitGetTagResponseVerification = {
    verified: boolean;
    reason: string;
    signature: null;
    payload: null;
  };
  type GitGetTagResponseObject = { type: string; sha: string; url: string };
  type GitGetTagResponseTagger = { name: string; email: string; date: string };
  type GitGetTagResponse = {
    node_id: string;
    tag: string;
    sha: string;
    url: string;
    message: string;
    tagger: GitGetTagResponseTagger;
    object: GitGetTagResponseObject;
    verification: GitGetTagResponseVerification;
  };
  type GitDeleteRefResponse = {};
  type GitUpdateRefResponseObject = { type: string; sha: string; url: string };
  type GitUpdateRefResponse = {
    ref: string;
    node_id: string;
    url: string;
    object: GitUpdateRefResponseObject;
  };
  type GitCreateRefResponseObject = { type: string; sha: string; url: string };
  type GitCreateRefResponse = {
    ref: string;
    node_id: string;
    url: string;
    object: GitCreateRefResponseObject;
  };
  type GitCreateCommitResponseVerification = {
    verified: boolean;
    reason: string;
    signature: null;
    payload: null;
  };
  type GitCreateCommitResponseParentsItem = { url: string; sha: string };
  type GitCreateCommitResponseTree = { url: string; sha: string };
  type GitCreateCommitResponseCommitter = {
    date: string;
    name: string;
    email: string;
  };
  type GitCreateCommitResponseAuthor = {
    date: string;
    name: string;
    email: string;
  };
  type GitCreateCommitResponse = {
    sha: string;
    node_id: string;
    url: string;
    author: GitCreateCommitResponseAuthor;
    committer: GitCreateCommitResponseCommitter;
    message: string;
    tree: GitCreateCommitResponseTree;
    parents: Array<GitCreateCommitResponseParentsItem>;
    verification: GitCreateCommitResponseVerification;
  };
  type GitGetCommitResponseVerification = {
    verified: boolean;
    reason: string;
    signature: null;
    payload: null;
  };
  type GitGetCommitResponseParentsItem = { url: string; sha: string };
  type GitGetCommitResponseTree = { url: string; sha: string };
  type GitGetCommitResponseCommitter = {
    date: string;
    name: string;
    email: string;
  };
  type GitGetCommitResponseAuthor = {
    date: string;
    name: string;
    email: string;
  };
  type GitGetCommitResponse = {
    sha: string;
    url: string;
    author: GitGetCommitResponseAuthor;
    committer: GitGetCommitResponseCommitter;
    message: string;
    tree: GitGetCommitResponseTree;
    parents: Array<GitGetCommitResponseParentsItem>;
    verification: GitGetCommitResponseVerification;
  };
  type GitCreateBlobResponse = { url: string; sha: string };
  type GitGetBlobResponse = {
    content: string;
    encoding: string;
    url: string;
    sha: string;
    size: number;
  };
  type GistsDeleteCommentResponse = {};
  type GistsUpdateCommentResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsUpdateCommentResponse = {
    id: number;
    node_id: string;
    url: string;
    body: string;
    user: GistsUpdateCommentResponseUser;
    created_at: string;
    updated_at: string;
  };
  type GistsCreateCommentResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsCreateCommentResponse = {
    id: number;
    node_id: string;
    url: string;
    body: string;
    user: GistsCreateCommentResponseUser;
    created_at: string;
    updated_at: string;
  };
  type GistsGetCommentResponseUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsGetCommentResponse = {
    id: number;
    node_id: string;
    url: string;
    body: string;
    user: GistsGetCommentResponseUser;
    created_at: string;
    updated_at: string;
  };
  type GistsListCommentsResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsListCommentsResponseItem = {
    id: number;
    node_id: string;
    url: string;
    body: string;
    user: GistsListCommentsResponseItemUser;
    created_at: string;
    updated_at: string;
  };
  type GistsDeleteResponse = {};
  type GistsListForksResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsListForksResponseItem = {
    user: GistsListForksResponseItemUser;
    url: string;
    id: string;
    created_at: string;
    updated_at: string;
  };
  type GistsForkResponseOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsForkResponseFilesHelloWorldRb = {
    filename: string;
    type: string;
    language: string;
    raw_url: string;
    size: number;
  };
  type GistsForkResponseFiles = {
    "hello_world.rb": GistsForkResponseFilesHelloWorldRb;
  };
  type GistsForkResponse = {
    url: string;
    forks_url: string;
    commits_url: string;
    id: string;
    node_id: string;
    git_pull_url: string;
    git_push_url: string;
    html_url: string;
    files: GistsForkResponseFiles;
    public: boolean;
    created_at: string;
    updated_at: string;
    description: string;
    comments: number;
    user: null;
    comments_url: string;
    owner: GistsForkResponseOwner;
    truncated: boolean;
  };
  type GistsUnstarResponse = {};
  type GistsStarResponse = {};
  type GistsListCommitsResponseItemChangeStatus = {
    deletions: number;
    additions: number;
    total: number;
  };
  type GistsListCommitsResponseItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsListCommitsResponseItem = {
    url: string;
    version: string;
    user: GistsListCommitsResponseItemUser;
    change_status: GistsListCommitsResponseItemChangeStatus;
    committed_at: string;
  };
  type GistsUpdateResponseHistoryItemChangeStatus = {
    deletions: number;
    additions: number;
    total: number;
  };
  type GistsUpdateResponseHistoryItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsUpdateResponseHistoryItem = {
    url: string;
    version: string;
    user: GistsUpdateResponseHistoryItemUser;
    change_status: GistsUpdateResponseHistoryItemChangeStatus;
    committed_at: string;
  };
  type GistsUpdateResponseForksItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsUpdateResponseForksItem = {
    user: GistsUpdateResponseForksItemUser;
    url: string;
    id: string;
    created_at: string;
    updated_at: string;
  };
  type GistsUpdateResponseOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsUpdateResponseFilesNewFileTxt = {
    filename: string;
    type: string;
    language: string;
    raw_url: string;
    size: number;
    truncated: boolean;
    content: string;
  };
  type GistsUpdateResponseFilesHelloWorldMd = {
    filename: string;
    type: string;
    language: string;
    raw_url: string;
    size: number;
    truncated: boolean;
    content: string;
  };
  type GistsUpdateResponseFilesHelloWorldPy = {
    filename: string;
    type: string;
    language: string;
    raw_url: string;
    size: number;
    truncated: boolean;
    content: string;
  };
  type GistsUpdateResponseFilesHelloWorldRb = {
    filename: string;
    type: string;
    language: string;
    raw_url: string;
    size: number;
    truncated: boolean;
    content: string;
  };
  type GistsUpdateResponseFiles = {
    "hello_world.rb": GistsUpdateResponseFilesHelloWorldRb;
    "hello_world.py": GistsUpdateResponseFilesHelloWorldPy;
    "hello_world.md": GistsUpdateResponseFilesHelloWorldMd;
    "new_file.txt": GistsUpdateResponseFilesNewFileTxt;
  };
  type GistsUpdateResponse = {
    url: string;
    forks_url: string;
    commits_url: string;
    id: string;
    node_id: string;
    git_pull_url: string;
    git_push_url: string;
    html_url: string;
    files: GistsUpdateResponseFiles;
    public: boolean;
    created_at: string;
    updated_at: string;
    description: string;
    comments: number;
    user: null;
    comments_url: string;
    owner: GistsUpdateResponseOwner;
    truncated: boolean;
    forks: Array<GistsUpdateResponseForksItem>;
    history: Array<GistsUpdateResponseHistoryItem>;
  };
  type GistsCreateResponseHistoryItemChangeStatus = {
    deletions: number;
    additions: number;
    total: number;
  };
  type GistsCreateResponseHistoryItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsCreateResponseHistoryItem = {
    url: string;
    version: string;
    user: GistsCreateResponseHistoryItemUser;
    change_status: GistsCreateResponseHistoryItemChangeStatus;
    committed_at: string;
  };
  type GistsCreateResponseForksItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsCreateResponseForksItem = {
    user: GistsCreateResponseForksItemUser;
    url: string;
    id: string;
    created_at: string;
    updated_at: string;
  };
  type GistsCreateResponseOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsCreateResponseFilesHelloWorldPythonTxt = {
    filename: string;
    type: string;
    language: string;
    raw_url: string;
    size: number;
    truncated: boolean;
    content: string;
  };
  type GistsCreateResponseFilesHelloWorldRubyTxt = {
    filename: string;
    type: string;
    language: string;
    raw_url: string;
    size: number;
    truncated: boolean;
    content: string;
  };
  type GistsCreateResponseFilesHelloWorldPy = {
    filename: string;
    type: string;
    language: string;
    raw_url: string;
    size: number;
    truncated: boolean;
    content: string;
  };
  type GistsCreateResponseFilesHelloWorldRb = {
    filename: string;
    type: string;
    language: string;
    raw_url: string;
    size: number;
    truncated: boolean;
    content: string;
  };
  type GistsCreateResponseFiles = {
    "hello_world.rb": GistsCreateResponseFilesHelloWorldRb;
    "hello_world.py": GistsCreateResponseFilesHelloWorldPy;
    "hello_world_ruby.txt": GistsCreateResponseFilesHelloWorldRubyTxt;
    "hello_world_python.txt": GistsCreateResponseFilesHelloWorldPythonTxt;
  };
  type GistsCreateResponse = {
    url: string;
    forks_url: string;
    commits_url: string;
    id: string;
    node_id: string;
    git_pull_url: string;
    git_push_url: string;
    html_url: string;
    files: GistsCreateResponseFiles;
    public: boolean;
    created_at: string;
    updated_at: string;
    description: string;
    comments: number;
    user: null;
    comments_url: string;
    owner: GistsCreateResponseOwner;
    truncated: boolean;
    forks: Array<GistsCreateResponseForksItem>;
    history: Array<GistsCreateResponseHistoryItem>;
  };
  type GistsGetRevisionResponseHistoryItemChangeStatus = {
    deletions: number;
    additions: number;
    total: number;
  };
  type GistsGetRevisionResponseHistoryItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsGetRevisionResponseHistoryItem = {
    url: string;
    version: string;
    user: GistsGetRevisionResponseHistoryItemUser;
    change_status: GistsGetRevisionResponseHistoryItemChangeStatus;
    committed_at: string;
  };
  type GistsGetRevisionResponseForksItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsGetRevisionResponseForksItem = {
    user: GistsGetRevisionResponseForksItemUser;
    url: string;
    id: string;
    created_at: string;
    updated_at: string;
  };
  type GistsGetRevisionResponseOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsGetRevisionResponseFilesHelloWorldPythonTxt = {
    filename: string;
    type: string;
    language: string;
    raw_url: string;
    size: number;
    truncated: boolean;
    content: string;
  };
  type GistsGetRevisionResponseFilesHelloWorldRubyTxt = {
    filename: string;
    type: string;
    language: string;
    raw_url: string;
    size: number;
    truncated: boolean;
    content: string;
  };
  type GistsGetRevisionResponseFilesHelloWorldPy = {
    filename: string;
    type: string;
    language: string;
    raw_url: string;
    size: number;
    truncated: boolean;
    content: string;
  };
  type GistsGetRevisionResponseFilesHelloWorldRb = {
    filename: string;
    type: string;
    language: string;
    raw_url: string;
    size: number;
    truncated: boolean;
    content: string;
  };
  type GistsGetRevisionResponseFiles = {
    "hello_world.rb": GistsGetRevisionResponseFilesHelloWorldRb;
    "hello_world.py": GistsGetRevisionResponseFilesHelloWorldPy;
    "hello_world_ruby.txt": GistsGetRevisionResponseFilesHelloWorldRubyTxt;
    "hello_world_python.txt": GistsGetRevisionResponseFilesHelloWorldPythonTxt;
  };
  type GistsGetRevisionResponse = {
    url: string;
    forks_url: string;
    commits_url: string;
    id: string;
    node_id: string;
    git_pull_url: string;
    git_push_url: string;
    html_url: string;
    files: GistsGetRevisionResponseFiles;
    public: boolean;
    created_at: string;
    updated_at: string;
    description: string;
    comments: number;
    user: null;
    comments_url: string;
    owner: GistsGetRevisionResponseOwner;
    truncated: boolean;
    forks: Array<GistsGetRevisionResponseForksItem>;
    history: Array<GistsGetRevisionResponseHistoryItem>;
  };
  type GistsGetResponseHistoryItemChangeStatus = {
    deletions: number;
    additions: number;
    total: number;
  };
  type GistsGetResponseHistoryItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsGetResponseHistoryItem = {
    url: string;
    version: string;
    user: GistsGetResponseHistoryItemUser;
    change_status: GistsGetResponseHistoryItemChangeStatus;
    committed_at: string;
  };
  type GistsGetResponseForksItemUser = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsGetResponseForksItem = {
    user: GistsGetResponseForksItemUser;
    url: string;
    id: string;
    created_at: string;
    updated_at: string;
  };
  type GistsGetResponseOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsGetResponseFilesHelloWorldPythonTxt = {
    filename: string;
    type: string;
    language: string;
    raw_url: string;
    size: number;
    truncated: boolean;
    content: string;
  };
  type GistsGetResponseFilesHelloWorldRubyTxt = {
    filename: string;
    type: string;
    language: string;
    raw_url: string;
    size: number;
    truncated: boolean;
    content: string;
  };
  type GistsGetResponseFilesHelloWorldPy = {
    filename: string;
    type: string;
    language: string;
    raw_url: string;
    size: number;
    truncated: boolean;
    content: string;
  };
  type GistsGetResponseFilesHelloWorldRb = {
    filename: string;
    type: string;
    language: string;
    raw_url: string;
    size: number;
    truncated: boolean;
    content: string;
  };
  type GistsGetResponseFiles = {
    "hello_world.rb": GistsGetResponseFilesHelloWorldRb;
    "hello_world.py": GistsGetResponseFilesHelloWorldPy;
    "hello_world_ruby.txt": GistsGetResponseFilesHelloWorldRubyTxt;
    "hello_world_python.txt": GistsGetResponseFilesHelloWorldPythonTxt;
  };
  type GistsGetResponse = {
    url: string;
    forks_url: string;
    commits_url: string;
    id: string;
    node_id: string;
    git_pull_url: string;
    git_push_url: string;
    html_url: string;
    files: GistsGetResponseFiles;
    public: boolean;
    created_at: string;
    updated_at: string;
    description: string;
    comments: number;
    user: null;
    comments_url: string;
    owner: GistsGetResponseOwner;
    truncated: boolean;
    forks: Array<GistsGetResponseForksItem>;
    history: Array<GistsGetResponseHistoryItem>;
  };
  type GistsListStarredResponseItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsListStarredResponseItemFilesHelloWorldRb = {
    filename: string;
    type: string;
    language: string;
    raw_url: string;
    size: number;
  };
  type GistsListStarredResponseItemFiles = {
    "hello_world.rb": GistsListStarredResponseItemFilesHelloWorldRb;
  };
  type GistsListStarredResponseItem = {
    url: string;
    forks_url: string;
    commits_url: string;
    id: string;
    node_id: string;
    git_pull_url: string;
    git_push_url: string;
    html_url: string;
    files: GistsListStarredResponseItemFiles;
    public: boolean;
    created_at: string;
    updated_at: string;
    description: string;
    comments: number;
    user: null;
    comments_url: string;
    owner: GistsListStarredResponseItemOwner;
    truncated: boolean;
  };
  type GistsListPublicResponseItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsListPublicResponseItemFilesHelloWorldRb = {
    filename: string;
    type: string;
    language: string;
    raw_url: string;
    size: number;
  };
  type GistsListPublicResponseItemFiles = {
    "hello_world.rb": GistsListPublicResponseItemFilesHelloWorldRb;
  };
  type GistsListPublicResponseItem = {
    url: string;
    forks_url: string;
    commits_url: string;
    id: string;
    node_id: string;
    git_pull_url: string;
    git_push_url: string;
    html_url: string;
    files: GistsListPublicResponseItemFiles;
    public: boolean;
    created_at: string;
    updated_at: string;
    description: string;
    comments: number;
    user: null;
    comments_url: string;
    owner: GistsListPublicResponseItemOwner;
    truncated: boolean;
  };
  type GistsListResponseItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsListResponseItemFilesHelloWorldRb = {
    filename: string;
    type: string;
    language: string;
    raw_url: string;
    size: number;
  };
  type GistsListResponseItemFiles = {
    "hello_world.rb": GistsListResponseItemFilesHelloWorldRb;
  };
  type GistsListResponseItem = {
    url: string;
    forks_url: string;
    commits_url: string;
    id: string;
    node_id: string;
    git_pull_url: string;
    git_push_url: string;
    html_url: string;
    files: GistsListResponseItemFiles;
    public: boolean;
    created_at: string;
    updated_at: string;
    description: string;
    comments: number;
    user: null;
    comments_url: string;
    owner: GistsListResponseItemOwner;
    truncated: boolean;
  };
  type GistsListPublicForUserResponseItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type GistsListPublicForUserResponseItemFilesHelloWorldRb = {
    filename: string;
    type: string;
    language: string;
    raw_url: string;
    size: number;
  };
  type GistsListPublicForUserResponseItemFiles = {
    "hello_world.rb": GistsListPublicForUserResponseItemFilesHelloWorldRb;
  };
  type GistsListPublicForUserResponseItem = {
    url: string;
    forks_url: string;
    commits_url: string;
    id: string;
    node_id: string;
    git_pull_url: string;
    git_push_url: string;
    html_url: string;
    files: GistsListPublicForUserResponseItemFiles;
    public: boolean;
    created_at: string;
    updated_at: string;
    description: string;
    comments: number;
    user: null;
    comments_url: string;
    owner: GistsListPublicForUserResponseItemOwner;
    truncated: boolean;
  };
  type EmojisGetResponse = {};
  type CodesOfConductGetForRepoResponse = {
    key: string;
    name: string;
    url: string;
    body: string;
  };
  type CodesOfConductGetConductCodeResponse = {
    key: string;
    name: string;
    url: string;
    body: string;
  };
  type CodesOfConductListConductCodesResponseItem = {
    key: string;
    name: string;
    url: string;
  };
  type ChecksRerequestSuiteResponse = {};
  type ChecksCreateSuiteResponseRepositoryPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ChecksCreateSuiteResponseRepositoryOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ChecksCreateSuiteResponseRepository = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ChecksCreateSuiteResponseRepositoryOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ChecksCreateSuiteResponseRepositoryPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type ChecksCreateSuiteResponseAppOwner = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
  };
  type ChecksCreateSuiteResponseApp = {
    id: number;
    node_id: string;
    owner: ChecksCreateSuiteResponseAppOwner;
    name: string;
    description: string;
    external_url: string;
    html_url: string;
    created_at: string;
    updated_at: string;
  };
  type ChecksCreateSuiteResponse = {
    id: number;
    node_id: string;
    head_branch: string;
    head_sha: string;
    status: string;
    conclusion: string;
    url: string;
    before: string;
    after: string;
    pull_requests: Array<any>;
    app: ChecksCreateSuiteResponseApp;
    repository: ChecksCreateSuiteResponseRepository;
  };
  type ChecksSetSuitesPreferencesResponseRepositoryPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ChecksSetSuitesPreferencesResponseRepositoryOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ChecksSetSuitesPreferencesResponseRepository = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ChecksSetSuitesPreferencesResponseRepositoryOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ChecksSetSuitesPreferencesResponseRepositoryPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type ChecksSetSuitesPreferencesResponsePreferencesAutoTriggerChecksItem = {
    app_id: number;
    setting: boolean;
  };
  type ChecksSetSuitesPreferencesResponsePreferences = {
    auto_trigger_checks: Array<
      ChecksSetSuitesPreferencesResponsePreferencesAutoTriggerChecksItem
    >;
  };
  type ChecksSetSuitesPreferencesResponse = {
    preferences: ChecksSetSuitesPreferencesResponsePreferences;
    repository: ChecksSetSuitesPreferencesResponseRepository;
  };
  type ChecksListSuitesForRefResponseCheckSuitesItemRepositoryPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ChecksListSuitesForRefResponseCheckSuitesItemRepositoryOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ChecksListSuitesForRefResponseCheckSuitesItemRepository = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ChecksListSuitesForRefResponseCheckSuitesItemRepositoryOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ChecksListSuitesForRefResponseCheckSuitesItemRepositoryPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type ChecksListSuitesForRefResponseCheckSuitesItemAppOwner = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
  };
  type ChecksListSuitesForRefResponseCheckSuitesItemApp = {
    id: number;
    node_id: string;
    owner: ChecksListSuitesForRefResponseCheckSuitesItemAppOwner;
    name: string;
    description: string;
    external_url: string;
    html_url: string;
    created_at: string;
    updated_at: string;
  };
  type ChecksListSuitesForRefResponseCheckSuitesItem = {
    id: number;
    node_id: string;
    head_branch: string;
    head_sha: string;
    status: string;
    conclusion: string;
    url: string;
    before: string;
    after: string;
    pull_requests: Array<any>;
    app: ChecksListSuitesForRefResponseCheckSuitesItemApp;
    repository: ChecksListSuitesForRefResponseCheckSuitesItemRepository;
  };
  type ChecksListSuitesForRefResponse = {
    total_count: number;
    check_suites: Array<ChecksListSuitesForRefResponseCheckSuitesItem>;
  };
  type ChecksGetSuiteResponseRepositoryPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ChecksGetSuiteResponseRepositoryOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ChecksGetSuiteResponseRepository = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ChecksGetSuiteResponseRepositoryOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ChecksGetSuiteResponseRepositoryPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type ChecksGetSuiteResponseAppOwner = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
  };
  type ChecksGetSuiteResponseApp = {
    id: number;
    node_id: string;
    owner: ChecksGetSuiteResponseAppOwner;
    name: string;
    description: string;
    external_url: string;
    html_url: string;
    created_at: string;
    updated_at: string;
  };
  type ChecksGetSuiteResponse = {
    id: number;
    node_id: string;
    head_branch: string;
    head_sha: string;
    status: string;
    conclusion: string;
    url: string;
    before: string;
    after: string;
    pull_requests: Array<any>;
    app: ChecksGetSuiteResponseApp;
    repository: ChecksGetSuiteResponseRepository;
  };
  type ChecksListAnnotationsResponseItem = {
    path: string;
    start_line: number;
    end_line: number;
    start_column: number;
    end_column: number;
    annotation_level: string;
    title: string;
    message: string;
    raw_details: string;
  };
  type ChecksGetResponsePullRequestsItemBaseRepo = {
    id: number;
    url: string;
    name: string;
  };
  type ChecksGetResponsePullRequestsItemBase = {
    ref: string;
    sha: string;
    repo: ChecksGetResponsePullRequestsItemBaseRepo;
  };
  type ChecksGetResponsePullRequestsItemHeadRepo = {
    id: number;
    url: string;
    name: string;
  };
  type ChecksGetResponsePullRequestsItemHead = {
    ref: string;
    sha: string;
    repo: ChecksGetResponsePullRequestsItemHeadRepo;
  };
  type ChecksGetResponsePullRequestsItem = {
    url: string;
    id: number;
    number: number;
    head: ChecksGetResponsePullRequestsItemHead;
    base: ChecksGetResponsePullRequestsItemBase;
  };
  type ChecksGetResponseAppOwner = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
  };
  type ChecksGetResponseApp = {
    id: number;
    node_id: string;
    owner: ChecksGetResponseAppOwner;
    name: string;
    description: string;
    external_url: string;
    html_url: string;
    created_at: string;
    updated_at: string;
  };
  type ChecksGetResponseCheckSuite = { id: number };
  type ChecksGetResponseOutput = {
    title: string;
    summary: string;
    text: string;
    annotations_count: number;
    annotations_url: string;
  };
  type ChecksGetResponse = {
    id: number;
    head_sha: string;
    node_id: string;
    external_id: string;
    url: string;
    html_url: string;
    details_url: string;
    status: string;
    conclusion: string;
    started_at: string;
    completed_at: string;
    output: ChecksGetResponseOutput;
    name: string;
    check_suite: ChecksGetResponseCheckSuite;
    app: ChecksGetResponseApp;
    pull_requests: Array<ChecksGetResponsePullRequestsItem>;
  };
  type ChecksListForSuiteResponseCheckRunsItemPullRequestsItemBaseRepo = {
    id: number;
    url: string;
    name: string;
  };
  type ChecksListForSuiteResponseCheckRunsItemPullRequestsItemBase = {
    ref: string;
    sha: string;
    repo: ChecksListForSuiteResponseCheckRunsItemPullRequestsItemBaseRepo;
  };
  type ChecksListForSuiteResponseCheckRunsItemPullRequestsItemHeadRepo = {
    id: number;
    url: string;
    name: string;
  };
  type ChecksListForSuiteResponseCheckRunsItemPullRequestsItemHead = {
    ref: string;
    sha: string;
    repo: ChecksListForSuiteResponseCheckRunsItemPullRequestsItemHeadRepo;
  };
  type ChecksListForSuiteResponseCheckRunsItemPullRequestsItem = {
    url: string;
    id: number;
    number: number;
    head: ChecksListForSuiteResponseCheckRunsItemPullRequestsItemHead;
    base: ChecksListForSuiteResponseCheckRunsItemPullRequestsItemBase;
  };
  type ChecksListForSuiteResponseCheckRunsItemAppOwner = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
  };
  type ChecksListForSuiteResponseCheckRunsItemApp = {
    id: number;
    node_id: string;
    owner: ChecksListForSuiteResponseCheckRunsItemAppOwner;
    name: string;
    description: string;
    external_url: string;
    html_url: string;
    created_at: string;
    updated_at: string;
  };
  type ChecksListForSuiteResponseCheckRunsItemCheckSuite = { id: number };
  type ChecksListForSuiteResponseCheckRunsItemOutput = {
    title: string;
    summary: string;
    text: string;
    annotations_count: number;
    annotations_url: string;
  };
  type ChecksListForSuiteResponseCheckRunsItem = {
    id: number;
    head_sha: string;
    node_id: string;
    external_id: string;
    url: string;
    html_url: string;
    details_url: string;
    status: string;
    conclusion: string;
    started_at: string;
    completed_at: string;
    output: ChecksListForSuiteResponseCheckRunsItemOutput;
    name: string;
    check_suite: ChecksListForSuiteResponseCheckRunsItemCheckSuite;
    app: ChecksListForSuiteResponseCheckRunsItemApp;
    pull_requests: Array<
      ChecksListForSuiteResponseCheckRunsItemPullRequestsItem
    >;
  };
  type ChecksListForSuiteResponse = {
    total_count: number;
    check_runs: Array<ChecksListForSuiteResponseCheckRunsItem>;
  };
  type ChecksListForRefResponseCheckRunsItemPullRequestsItemBaseRepo = {
    id: number;
    url: string;
    name: string;
  };
  type ChecksListForRefResponseCheckRunsItemPullRequestsItemBase = {
    ref: string;
    sha: string;
    repo: ChecksListForRefResponseCheckRunsItemPullRequestsItemBaseRepo;
  };
  type ChecksListForRefResponseCheckRunsItemPullRequestsItemHeadRepo = {
    id: number;
    url: string;
    name: string;
  };
  type ChecksListForRefResponseCheckRunsItemPullRequestsItemHead = {
    ref: string;
    sha: string;
    repo: ChecksListForRefResponseCheckRunsItemPullRequestsItemHeadRepo;
  };
  type ChecksListForRefResponseCheckRunsItemPullRequestsItem = {
    url: string;
    id: number;
    number: number;
    head: ChecksListForRefResponseCheckRunsItemPullRequestsItemHead;
    base: ChecksListForRefResponseCheckRunsItemPullRequestsItemBase;
  };
  type ChecksListForRefResponseCheckRunsItemAppOwner = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
  };
  type ChecksListForRefResponseCheckRunsItemApp = {
    id: number;
    node_id: string;
    owner: ChecksListForRefResponseCheckRunsItemAppOwner;
    name: string;
    description: string;
    external_url: string;
    html_url: string;
    created_at: string;
    updated_at: string;
  };
  type ChecksListForRefResponseCheckRunsItemCheckSuite = { id: number };
  type ChecksListForRefResponseCheckRunsItemOutput = {
    title: string;
    summary: string;
    text: string;
    annotations_count: number;
    annotations_url: string;
  };
  type ChecksListForRefResponseCheckRunsItem = {
    id: number;
    head_sha: string;
    node_id: string;
    external_id: string;
    url: string;
    html_url: string;
    details_url: string;
    status: string;
    conclusion: string;
    started_at: string;
    completed_at: string;
    output: ChecksListForRefResponseCheckRunsItemOutput;
    name: string;
    check_suite: ChecksListForRefResponseCheckRunsItemCheckSuite;
    app: ChecksListForRefResponseCheckRunsItemApp;
    pull_requests: Array<ChecksListForRefResponseCheckRunsItemPullRequestsItem>;
  };
  type ChecksListForRefResponse = {
    total_count: number;
    check_runs: Array<ChecksListForRefResponseCheckRunsItem>;
  };
  type ChecksUpdateResponsePullRequestsItemBaseRepo = {
    id: number;
    url: string;
    name: string;
  };
  type ChecksUpdateResponsePullRequestsItemBase = {
    ref: string;
    sha: string;
    repo: ChecksUpdateResponsePullRequestsItemBaseRepo;
  };
  type ChecksUpdateResponsePullRequestsItemHeadRepo = {
    id: number;
    url: string;
    name: string;
  };
  type ChecksUpdateResponsePullRequestsItemHead = {
    ref: string;
    sha: string;
    repo: ChecksUpdateResponsePullRequestsItemHeadRepo;
  };
  type ChecksUpdateResponsePullRequestsItem = {
    url: string;
    id: number;
    number: number;
    head: ChecksUpdateResponsePullRequestsItemHead;
    base: ChecksUpdateResponsePullRequestsItemBase;
  };
  type ChecksUpdateResponseAppOwner = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
  };
  type ChecksUpdateResponseApp = {
    id: number;
    node_id: string;
    owner: ChecksUpdateResponseAppOwner;
    name: string;
    description: string;
    external_url: string;
    html_url: string;
    created_at: string;
    updated_at: string;
  };
  type ChecksUpdateResponseCheckSuite = { id: number };
  type ChecksUpdateResponseOutput = {
    title: string;
    summary: string;
    text: string;
    annotations_count: number;
    annotations_url: string;
  };
  type ChecksUpdateResponse = {
    id: number;
    head_sha: string;
    node_id: string;
    external_id: string;
    url: string;
    html_url: string;
    details_url: string;
    status: string;
    conclusion: string;
    started_at: string;
    completed_at: string;
    output: ChecksUpdateResponseOutput;
    name: string;
    check_suite: ChecksUpdateResponseCheckSuite;
    app: ChecksUpdateResponseApp;
    pull_requests: Array<ChecksUpdateResponsePullRequestsItem>;
  };
  type ChecksCreateResponsePullRequestsItemBaseRepo = {
    id: number;
    url: string;
    name: string;
  };
  type ChecksCreateResponsePullRequestsItemBase = {
    ref: string;
    sha: string;
    repo: ChecksCreateResponsePullRequestsItemBaseRepo;
  };
  type ChecksCreateResponsePullRequestsItemHeadRepo = {
    id: number;
    url: string;
    name: string;
  };
  type ChecksCreateResponsePullRequestsItemHead = {
    ref: string;
    sha: string;
    repo: ChecksCreateResponsePullRequestsItemHeadRepo;
  };
  type ChecksCreateResponsePullRequestsItem = {
    url: string;
    id: number;
    number: number;
    head: ChecksCreateResponsePullRequestsItemHead;
    base: ChecksCreateResponsePullRequestsItemBase;
  };
  type ChecksCreateResponseAppOwner = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
  };
  type ChecksCreateResponseApp = {
    id: number;
    node_id: string;
    owner: ChecksCreateResponseAppOwner;
    name: string;
    description: string;
    external_url: string;
    html_url: string;
    created_at: string;
    updated_at: string;
  };
  type ChecksCreateResponseCheckSuite = { id: number };
  type ChecksCreateResponseOutput = {
    title: string;
    summary: string;
    text: string;
  };
  type ChecksCreateResponse = {
    id: number;
    head_sha: string;
    node_id: string;
    external_id: string;
    url: string;
    html_url: string;
    details_url: string;
    status: string;
    conclusion: null;
    started_at: string;
    completed_at: null;
    output: ChecksCreateResponseOutput;
    name: string;
    check_suite: ChecksCreateResponseCheckSuite;
    app: ChecksCreateResponseApp;
    pull_requests: Array<ChecksCreateResponsePullRequestsItem>;
  };
  type AppsListMarketplacePurchasesForAuthenticatedUserStubbedResponseItemPlan = {
    url: string;
    accounts_url: string;
    id: number;
    number: number;
    name: string;
    description: string;
    monthly_price_in_cents: number;
    yearly_price_in_cents: number;
    price_model: string;
    has_free_trial: boolean;
    unit_name: null;
    state: string;
    bullets: Array<string>;
  };
  type AppsListMarketplacePurchasesForAuthenticatedUserStubbedResponseItemAccount = {
    login: string;
    id: number;
    url: string;
    email: null;
    organization_billing_email: string;
    type: string;
  };
  type AppsListMarketplacePurchasesForAuthenticatedUserStubbedResponseItem = {
    billing_cycle: string;
    next_billing_date: string;
    unit_count: null;
    on_free_trial: boolean;
    free_trial_ends_on: string;
    updated_at: string;
    account: AppsListMarketplacePurchasesForAuthenticatedUserStubbedResponseItemAccount;
    plan: AppsListMarketplacePurchasesForAuthenticatedUserStubbedResponseItemPlan;
  };
  type AppsListMarketplacePurchasesForAuthenticatedUserResponseItemPlan = {
    url: string;
    accounts_url: string;
    id: number;
    number: number;
    name: string;
    description: string;
    monthly_price_in_cents: number;
    yearly_price_in_cents: number;
    price_model: string;
    has_free_trial: boolean;
    unit_name: null;
    state: string;
    bullets: Array<string>;
  };
  type AppsListMarketplacePurchasesForAuthenticatedUserResponseItemAccount = {
    login: string;
    id: number;
    url: string;
    email: null;
    organization_billing_email: string;
    type: string;
  };
  type AppsListMarketplacePurchasesForAuthenticatedUserResponseItem = {
    billing_cycle: string;
    next_billing_date: string;
    unit_count: null;
    on_free_trial: boolean;
    free_trial_ends_on: string;
    updated_at: string;
    account: AppsListMarketplacePurchasesForAuthenticatedUserResponseItemAccount;
    plan: AppsListMarketplacePurchasesForAuthenticatedUserResponseItemPlan;
  };
  type AppsCheckAccountIsAssociatedWithAnyStubbedResponseMarketplacePurchasePlan = {
    url: string;
    accounts_url: string;
    id: number;
    number: number;
    name: string;
    description: string;
    monthly_price_in_cents: number;
    yearly_price_in_cents: number;
    price_model: string;
    has_free_trial: boolean;
    unit_name: null;
    state: string;
    bullets: Array<string>;
  };
  type AppsCheckAccountIsAssociatedWithAnyStubbedResponseMarketplacePurchase = {
    billing_cycle: string;
    next_billing_date: string;
    unit_count: null;
    on_free_trial: boolean;
    free_trial_ends_on: string;
    updated_at: string;
    plan: AppsCheckAccountIsAssociatedWithAnyStubbedResponseMarketplacePurchasePlan;
  };
  type AppsCheckAccountIsAssociatedWithAnyStubbedResponseMarketplacePendingChangePlan = {
    url: string;
    accounts_url: string;
    id: number;
    number: number;
    name: string;
    description: string;
    monthly_price_in_cents: number;
    yearly_price_in_cents: number;
    price_model: string;
    has_free_trial: boolean;
    state: string;
    unit_name: null;
    bullets: Array<string>;
  };
  type AppsCheckAccountIsAssociatedWithAnyStubbedResponseMarketplacePendingChange = {
    effective_date: string;
    unit_count: null;
    id: number;
    plan: AppsCheckAccountIsAssociatedWithAnyStubbedResponseMarketplacePendingChangePlan;
  };
  type AppsCheckAccountIsAssociatedWithAnyStubbedResponse = {
    url: string;
    type: string;
    id: number;
    login: string;
    email: null;
    organization_billing_email: string;
    marketplace_pending_change: AppsCheckAccountIsAssociatedWithAnyStubbedResponseMarketplacePendingChange;
    marketplace_purchase: AppsCheckAccountIsAssociatedWithAnyStubbedResponseMarketplacePurchase;
  };
  type AppsCheckAccountIsAssociatedWithAnyResponseMarketplacePurchasePlan = {
    url: string;
    accounts_url: string;
    id: number;
    number: number;
    name: string;
    description: string;
    monthly_price_in_cents: number;
    yearly_price_in_cents: number;
    price_model: string;
    has_free_trial: boolean;
    unit_name: null;
    state: string;
    bullets: Array<string>;
  };
  type AppsCheckAccountIsAssociatedWithAnyResponseMarketplacePurchase = {
    billing_cycle: string;
    next_billing_date: string;
    unit_count: null;
    on_free_trial: boolean;
    free_trial_ends_on: string;
    updated_at: string;
    plan: AppsCheckAccountIsAssociatedWithAnyResponseMarketplacePurchasePlan;
  };
  type AppsCheckAccountIsAssociatedWithAnyResponseMarketplacePendingChangePlan = {
    url: string;
    accounts_url: string;
    id: number;
    number: number;
    name: string;
    description: string;
    monthly_price_in_cents: number;
    yearly_price_in_cents: number;
    price_model: string;
    has_free_trial: boolean;
    state: string;
    unit_name: null;
    bullets: Array<string>;
  };
  type AppsCheckAccountIsAssociatedWithAnyResponseMarketplacePendingChange = {
    effective_date: string;
    unit_count: null;
    id: number;
    plan: AppsCheckAccountIsAssociatedWithAnyResponseMarketplacePendingChangePlan;
  };
  type AppsCheckAccountIsAssociatedWithAnyResponse = {
    url: string;
    type: string;
    id: number;
    login: string;
    email: null;
    organization_billing_email: string;
    marketplace_pending_change: AppsCheckAccountIsAssociatedWithAnyResponseMarketplacePendingChange;
    marketplace_purchase: AppsCheckAccountIsAssociatedWithAnyResponseMarketplacePurchase;
  };
  type AppsListAccountsUserOrOrgOnPlanStubbedResponseItemMarketplacePurchasePlan = {
    url: string;
    accounts_url: string;
    id: number;
    number: number;
    name: string;
    description: string;
    monthly_price_in_cents: number;
    yearly_price_in_cents: number;
    price_model: string;
    has_free_trial: boolean;
    unit_name: null;
    state: string;
    bullets: Array<string>;
  };
  type AppsListAccountsUserOrOrgOnPlanStubbedResponseItemMarketplacePurchase = {
    billing_cycle: string;
    next_billing_date: string;
    unit_count: null;
    on_free_trial: boolean;
    free_trial_ends_on: string;
    updated_at: string;
    plan: AppsListAccountsUserOrOrgOnPlanStubbedResponseItemMarketplacePurchasePlan;
  };
  type AppsListAccountsUserOrOrgOnPlanStubbedResponseItemMarketplacePendingChangePlan = {
    url: string;
    accounts_url: string;
    id: number;
    number: number;
    name: string;
    description: string;
    monthly_price_in_cents: number;
    yearly_price_in_cents: number;
    price_model: string;
    has_free_trial: boolean;
    state: string;
    unit_name: null;
    bullets: Array<string>;
  };
  type AppsListAccountsUserOrOrgOnPlanStubbedResponseItemMarketplacePendingChange = {
    effective_date: string;
    unit_count: null;
    id: number;
    plan: AppsListAccountsUserOrOrgOnPlanStubbedResponseItemMarketplacePendingChangePlan;
  };
  type AppsListAccountsUserOrOrgOnPlanStubbedResponseItem = {
    url: string;
    type: string;
    id: number;
    login: string;
    email: null;
    organization_billing_email: string;
    marketplace_pending_change: AppsListAccountsUserOrOrgOnPlanStubbedResponseItemMarketplacePendingChange;
    marketplace_purchase: AppsListAccountsUserOrOrgOnPlanStubbedResponseItemMarketplacePurchase;
  };
  type AppsListAccountsUserOrOrgOnPlanResponseItemMarketplacePurchasePlan = {
    url: string;
    accounts_url: string;
    id: number;
    number: number;
    name: string;
    description: string;
    monthly_price_in_cents: number;
    yearly_price_in_cents: number;
    price_model: string;
    has_free_trial: boolean;
    unit_name: null;
    state: string;
    bullets: Array<string>;
  };
  type AppsListAccountsUserOrOrgOnPlanResponseItemMarketplacePurchase = {
    billing_cycle: string;
    next_billing_date: string;
    unit_count: null;
    on_free_trial: boolean;
    free_trial_ends_on: string;
    updated_at: string;
    plan: AppsListAccountsUserOrOrgOnPlanResponseItemMarketplacePurchasePlan;
  };
  type AppsListAccountsUserOrOrgOnPlanResponseItemMarketplacePendingChangePlan = {
    url: string;
    accounts_url: string;
    id: number;
    number: number;
    name: string;
    description: string;
    monthly_price_in_cents: number;
    yearly_price_in_cents: number;
    price_model: string;
    has_free_trial: boolean;
    state: string;
    unit_name: null;
    bullets: Array<string>;
  };
  type AppsListAccountsUserOrOrgOnPlanResponseItemMarketplacePendingChange = {
    effective_date: string;
    unit_count: null;
    id: number;
    plan: AppsListAccountsUserOrOrgOnPlanResponseItemMarketplacePendingChangePlan;
  };
  type AppsListAccountsUserOrOrgOnPlanResponseItem = {
    url: string;
    type: string;
    id: number;
    login: string;
    email: null;
    organization_billing_email: string;
    marketplace_pending_change: AppsListAccountsUserOrOrgOnPlanResponseItemMarketplacePendingChange;
    marketplace_purchase: AppsListAccountsUserOrOrgOnPlanResponseItemMarketplacePurchase;
  };
  type AppsListPlansStubbedResponseItem = {
    url: string;
    accounts_url: string;
    id: number;
    number: number;
    name: string;
    description: string;
    monthly_price_in_cents: number;
    yearly_price_in_cents: number;
    price_model: string;
    has_free_trial: boolean;
    unit_name: null;
    state: string;
    bullets: Array<string>;
  };
  type AppsListPlansResponseItem = {
    url: string;
    accounts_url: string;
    id: number;
    number: number;
    name: string;
    description: string;
    monthly_price_in_cents: number;
    yearly_price_in_cents: number;
    price_model: string;
    has_free_trial: boolean;
    unit_name: null;
    state: string;
    bullets: Array<string>;
  };
  type AppsCreateContentAttachmentResponse = {
    id: number;
    title: string;
    body: string;
  };
  type AppsRemoveRepoFromInstallationResponse = {};
  type AppsAddRepoToInstallationResponse = {};
  type AppsListInstallationReposForAuthenticatedUserResponseRepositoriesItemPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type AppsListInstallationReposForAuthenticatedUserResponseRepositoriesItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type AppsListInstallationReposForAuthenticatedUserResponseRepositoriesItem = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: AppsListInstallationReposForAuthenticatedUserResponseRepositoriesItemOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: AppsListInstallationReposForAuthenticatedUserResponseRepositoriesItemPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type AppsListInstallationReposForAuthenticatedUserResponse = {
    total_count: number;
    repositories: Array<
      AppsListInstallationReposForAuthenticatedUserResponseRepositoriesItem
    >;
  };
  type AppsListInstallationsForAuthenticatedUserResponseInstallationsItemPermissions = {
    metadata: string;
    contents: string;
    issues: string;
    single_file: string;
  };
  type AppsListInstallationsForAuthenticatedUserResponseInstallationsItemAccount = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url?: string;
    issues_url?: string;
    members_url?: string;
    public_members_url?: string;
    avatar_url: string;
    description?: string;
    gravatar_id?: string;
    html_url?: string;
    followers_url?: string;
    following_url?: string;
    gists_url?: string;
    starred_url?: string;
    subscriptions_url?: string;
    organizations_url?: string;
    received_events_url?: string;
    type?: string;
    site_admin?: boolean;
  };
  type AppsListInstallationsForAuthenticatedUserResponseInstallationsItem = {
    id: number;
    account: AppsListInstallationsForAuthenticatedUserResponseInstallationsItemAccount;
    access_tokens_url: string;
    repositories_url: string;
    html_url: string;
    app_id: number;
    target_id: number;
    target_type: string;
    permissions: AppsListInstallationsForAuthenticatedUserResponseInstallationsItemPermissions;
    events: Array<string>;
    single_file_name: string;
  };
  type AppsListInstallationsForAuthenticatedUserResponse = {
    total_count: number;
    installations: Array<
      AppsListInstallationsForAuthenticatedUserResponseInstallationsItem
    >;
  };
  type AppsListReposResponseRepositoriesItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type AppsListReposResponseRepositoriesItem = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: AppsListReposResponseRepositoriesItemOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type AppsListReposResponse = {
    total_count: number;
    repositories: Array<AppsListReposResponseRepositoriesItem>;
  };
  type AppsCreateFromManifestResponseOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type AppsCreateFromManifestResponse = {
    id: number;
    node_id: string;
    owner: AppsCreateFromManifestResponseOwner;
    name: string;
    description: null;
    external_url: string;
    html_url: string;
    created_at: string;
    updated_at: string;
    client_id: string;
    client_secret: string;
    webhook_secret: string;
    pem: string;
  };
  type AppsFindUserInstallationResponsePermissions = {
    checks: string;
    metadata: string;
    contents: string;
  };
  type AppsFindUserInstallationResponseAccount = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type AppsFindUserInstallationResponse = {
    id: number;
    account: AppsFindUserInstallationResponseAccount;
    repository_selection: string;
    access_tokens_url: string;
    repositories_url: string;
    html_url: string;
    app_id: number;
    target_id: number;
    target_type: string;
    permissions: AppsFindUserInstallationResponsePermissions;
    events: Array<string>;
    created_at: string;
    updated_at: string;
    single_file_name: null;
  };
  type AppsGetUserInstallationResponsePermissions = {
    checks: string;
    metadata: string;
    contents: string;
  };
  type AppsGetUserInstallationResponseAccount = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type AppsGetUserInstallationResponse = {
    id: number;
    account: AppsGetUserInstallationResponseAccount;
    repository_selection: string;
    access_tokens_url: string;
    repositories_url: string;
    html_url: string;
    app_id: number;
    target_id: number;
    target_type: string;
    permissions: AppsGetUserInstallationResponsePermissions;
    events: Array<string>;
    created_at: string;
    updated_at: string;
    single_file_name: null;
  };
  type AppsFindRepoInstallationResponsePermissions = {
    checks: string;
    metadata: string;
    contents: string;
  };
  type AppsFindRepoInstallationResponseAccount = {
    login: string;
    id: number;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type AppsFindRepoInstallationResponse = {
    id: number;
    account: AppsFindRepoInstallationResponseAccount;
    repository_selection: string;
    access_tokens_url: string;
    repositories_url: string;
    html_url: string;
    app_id: number;
    target_id: number;
    target_type: string;
    permissions: AppsFindRepoInstallationResponsePermissions;
    events: Array<string>;
    created_at: string;
    updated_at: string;
    single_file_name: null;
  };
  type AppsGetRepoInstallationResponsePermissions = {
    checks: string;
    metadata: string;
    contents: string;
  };
  type AppsGetRepoInstallationResponseAccount = {
    login: string;
    id: number;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type AppsGetRepoInstallationResponse = {
    id: number;
    account: AppsGetRepoInstallationResponseAccount;
    repository_selection: string;
    access_tokens_url: string;
    repositories_url: string;
    html_url: string;
    app_id: number;
    target_id: number;
    target_type: string;
    permissions: AppsGetRepoInstallationResponsePermissions;
    events: Array<string>;
    created_at: string;
    updated_at: string;
    single_file_name: null;
  };
  type AppsFindOrgInstallationResponsePermissions = {
    checks: string;
    metadata: string;
    contents: string;
  };
  type AppsFindOrgInstallationResponseAccount = {
    login: string;
    id: number;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type AppsFindOrgInstallationResponse = {
    id: number;
    account: AppsFindOrgInstallationResponseAccount;
    repository_selection: string;
    access_tokens_url: string;
    repositories_url: string;
    html_url: string;
    app_id: number;
    target_id: number;
    target_type: string;
    permissions: AppsFindOrgInstallationResponsePermissions;
    events: Array<string>;
    created_at: string;
    updated_at: string;
    single_file_name: null;
  };
  type AppsGetOrgInstallationResponsePermissions = {
    checks: string;
    metadata: string;
    contents: string;
  };
  type AppsGetOrgInstallationResponseAccount = {
    login: string;
    id: number;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type AppsGetOrgInstallationResponse = {
    id: number;
    account: AppsGetOrgInstallationResponseAccount;
    repository_selection: string;
    access_tokens_url: string;
    repositories_url: string;
    html_url: string;
    app_id: number;
    target_id: number;
    target_type: string;
    permissions: AppsGetOrgInstallationResponsePermissions;
    events: Array<string>;
    created_at: string;
    updated_at: string;
    single_file_name: null;
  };
  type AppsCreateInstallationTokenResponseRepositoriesItemPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type AppsCreateInstallationTokenResponseRepositoriesItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type AppsCreateInstallationTokenResponseRepositoriesItem = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: AppsCreateInstallationTokenResponseRepositoriesItemOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: AppsCreateInstallationTokenResponseRepositoriesItemPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type AppsCreateInstallationTokenResponsePermissions = {
    issues: string;
    contents: string;
  };
  type AppsCreateInstallationTokenResponse = {
    token: string;
    expires_at: string;
    permissions: AppsCreateInstallationTokenResponsePermissions;
    repositories: Array<AppsCreateInstallationTokenResponseRepositoriesItem>;
  };
  type AppsDeleteInstallationResponse = {};
  type AppsGetInstallationResponsePermissions = {
    metadata: string;
    contents: string;
    issues: string;
    single_file: string;
  };
  type AppsGetInstallationResponseAccount = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
  };
  type AppsGetInstallationResponse = {
    id: number;
    account: AppsGetInstallationResponseAccount;
    access_tokens_url: string;
    repositories_url: string;
    html_url: string;
    app_id: number;
    target_id: number;
    target_type: string;
    permissions: AppsGetInstallationResponsePermissions;
    events: Array<string>;
    single_file_name: string;
    repository_selection: string;
  };
  type AppsListInstallationsResponseItemPermissions = {
    metadata: string;
    contents: string;
    issues: string;
    single_file: string;
  };
  type AppsListInstallationsResponseItemAccount = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
  };
  type AppsListInstallationsResponseItem = {
    id: number;
    account: AppsListInstallationsResponseItemAccount;
    access_tokens_url: string;
    repositories_url: string;
    html_url: string;
    app_id: number;
    target_id: number;
    target_type: string;
    permissions: AppsListInstallationsResponseItemPermissions;
    events: Array<string>;
    single_file_name: string;
    repository_selection: string;
  };
  type AppsGetAuthenticatedResponseOwner = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
  };
  type AppsGetAuthenticatedResponse = {
    id: number;
    node_id: string;
    owner: AppsGetAuthenticatedResponseOwner;
    name: string;
    description: string;
    external_url: string;
    html_url: string;
    created_at: string;
    updated_at: string;
    installations_count: number;
  };
  type AppsGetBySlugResponseOwner = {
    login: string;
    id: number;
    node_id: string;
    url: string;
    repos_url: string;
    events_url: string;
    hooks_url: string;
    issues_url: string;
    members_url: string;
    public_members_url: string;
    avatar_url: string;
    description: string;
  };
  type AppsGetBySlugResponse = {
    id: number;
    node_id: string;
    owner: AppsGetBySlugResponseOwner;
    name: string;
    description: string;
    external_url: string;
    html_url: string;
    created_at: string;
    updated_at: string;
  };
  type ActivityDeleteRepoSubscriptionResponse = {};
  type ActivitySetRepoSubscriptionResponse = {
    subscribed: boolean;
    ignored: boolean;
    reason: null;
    created_at: string;
    url: string;
    repository_url: string;
  };
  type ActivityListWatchedReposForAuthenticatedUserResponseItemLicense = {
    key: string;
    name: string;
    spdx_id: string;
    url: string;
    node_id: string;
  };
  type ActivityListWatchedReposForAuthenticatedUserResponseItemPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ActivityListWatchedReposForAuthenticatedUserResponseItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ActivityListWatchedReposForAuthenticatedUserResponseItem = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ActivityListWatchedReposForAuthenticatedUserResponseItemOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ActivityListWatchedReposForAuthenticatedUserResponseItemPermissions;
    template_repository: null;
    subscribers_count: number;
    network_count: number;
    license: ActivityListWatchedReposForAuthenticatedUserResponseItemLicense;
  };
  type ActivityListReposWatchedByUserResponseItemLicense = {
    key: string;
    name: string;
    spdx_id: string;
    url: string;
    node_id: string;
  };
  type ActivityListReposWatchedByUserResponseItemPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ActivityListReposWatchedByUserResponseItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ActivityListReposWatchedByUserResponseItem = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ActivityListReposWatchedByUserResponseItemOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ActivityListReposWatchedByUserResponseItemPermissions;
    template_repository: null;
    subscribers_count: number;
    network_count: number;
    license: ActivityListReposWatchedByUserResponseItemLicense;
  };
  type ActivityListWatchersForRepoResponseItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ActivityUnstarRepoResponse = {};
  type ActivityStarRepoResponse = {};
  type ActivityListReposStarredByAuthenticatedUserResponseItemPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ActivityListReposStarredByAuthenticatedUserResponseItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ActivityListReposStarredByAuthenticatedUserResponseItem = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ActivityListReposStarredByAuthenticatedUserResponseItemOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ActivityListReposStarredByAuthenticatedUserResponseItemPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type ActivityListReposStarredByUserResponseItemPermissions = {
    admin: boolean;
    push: boolean;
    pull: boolean;
  };
  type ActivityListReposStarredByUserResponseItemOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ActivityListReposStarredByUserResponseItem = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ActivityListReposStarredByUserResponseItemOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
    clone_url: string;
    mirror_url: string;
    hooks_url: string;
    svn_url: string;
    homepage: string;
    language: null;
    forks_count: number;
    stargazers_count: number;
    watchers_count: number;
    size: number;
    default_branch: string;
    open_issues_count: number;
    is_template: boolean;
    topics: Array<string>;
    has_issues: boolean;
    has_projects: boolean;
    has_wiki: boolean;
    has_pages: boolean;
    has_downloads: boolean;
    archived: boolean;
    disabled: boolean;
    pushed_at: string;
    created_at: string;
    updated_at: string;
    permissions: ActivityListReposStarredByUserResponseItemPermissions;
    allow_rebase_merge: boolean;
    template_repository: null;
    allow_squash_merge: boolean;
    allow_merge_commit: boolean;
    subscribers_count: number;
    network_count: number;
  };
  type ActivityListStargazersForRepoResponseItem = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ActivityDeleteThreadSubscriptionResponse = {};
  type ActivitySetThreadSubscriptionResponse = {
    subscribed: boolean;
    ignored: boolean;
    reason: null;
    created_at: string;
    url: string;
    thread_url: string;
  };
  type ActivityGetThreadSubscriptionResponse = {
    subscribed: boolean;
    ignored: boolean;
    reason: null;
    created_at: string;
    url: string;
    thread_url: string;
  };
  type ActivityMarkThreadAsReadResponse = {};
  type ActivityGetThreadResponseSubject = {
    title: string;
    url: string;
    latest_comment_url: string;
    type: string;
  };
  type ActivityGetThreadResponseRepositoryOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ActivityGetThreadResponseRepository = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ActivityGetThreadResponseRepositoryOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
  };
  type ActivityGetThreadResponse = {
    id: string;
    repository: ActivityGetThreadResponseRepository;
    subject: ActivityGetThreadResponseSubject;
    reason: string;
    unread: boolean;
    updated_at: string;
    last_read_at: string;
    url: string;
  };
  type ActivityMarkNotificationsAsReadForRepoResponse = {};
  type ActivityMarkAsReadResponse = {};
  type ActivityListNotificationsForRepoResponseItemSubject = {
    title: string;
    url: string;
    latest_comment_url: string;
    type: string;
  };
  type ActivityListNotificationsForRepoResponseItemRepositoryOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ActivityListNotificationsForRepoResponseItemRepository = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ActivityListNotificationsForRepoResponseItemRepositoryOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
  };
  type ActivityListNotificationsForRepoResponseItem = {
    id: string;
    repository: ActivityListNotificationsForRepoResponseItemRepository;
    subject: ActivityListNotificationsForRepoResponseItemSubject;
    reason: string;
    unread: boolean;
    updated_at: string;
    last_read_at: string;
    url: string;
  };
  type ActivityListNotificationsResponseItemSubject = {
    title: string;
    url: string;
    latest_comment_url: string;
    type: string;
  };
  type ActivityListNotificationsResponseItemRepositoryOwner = {
    login: string;
    id: number;
    node_id: string;
    avatar_url: string;
    gravatar_id: string;
    url: string;
    html_url: string;
    followers_url: string;
    following_url: string;
    gists_url: string;
    starred_url: string;
    subscriptions_url: string;
    organizations_url: string;
    repos_url: string;
    events_url: string;
    received_events_url: string;
    type: string;
    site_admin: boolean;
  };
  type ActivityListNotificationsResponseItemRepository = {
    id: number;
    node_id: string;
    name: string;
    full_name: string;
    owner: ActivityListNotificationsResponseItemRepositoryOwner;
    private: boolean;
    html_url: string;
    description: string;
    fork: boolean;
    url: string;
    archive_url: string;
    assignees_url: string;
    blobs_url: string;
    branches_url: string;
    collaborators_url: string;
    comments_url: string;
    commits_url: string;
    compare_url: string;
    contents_url: string;
    contributors_url: string;
    deployments_url: string;
    downloads_url: string;
    events_url: string;
    forks_url: string;
    git_commits_url: string;
    git_refs_url: string;
    git_tags_url: string;
    git_url: string;
    issue_comment_url: string;
    issue_events_url: string;
    issues_url: string;
    keys_url: string;
    labels_url: string;
    languages_url: string;
    merges_url: string;
    milestones_url: string;
    notifications_url: string;
    pulls_url: string;
    releases_url: string;
    ssh_url: string;
    stargazers_url: string;
    statuses_url: string;
    subscribers_url: string;
    subscription_url: string;
    tags_url: string;
    teams_url: string;
    trees_url: string;
  };
  type ActivityListNotificationsResponseItem = {
    id: string;
    repository: ActivityListNotificationsResponseItemRepository;
    subject: ActivityListNotificationsResponseItemSubject;
    reason: string;
    unread: boolean;
    updated_at: string;
    last_read_at: string;
    url: string;
  };
  type ActivityListFeedsResponseLinksSecurityAdvisories = {
    href: string;
    type: string;
  };
  type ActivityListFeedsResponseLinksCurrentUserOrganizationsItem = {
    href: string;
    type: string;
  };
  type ActivityListFeedsResponseLinksCurrentUserOrganization = {
    href: string;
    type: string;
  };
  type ActivityListFeedsResponseLinksCurrentUserActor = {
    href: string;
    type: string;
  };
  type ActivityListFeedsResponseLinksCurrentUser = {
    href: string;
    type: string;
  };
  type ActivityListFeedsResponseLinksCurrentUserPublic = {
    href: string;
    type: string;
  };
  type ActivityListFeedsResponseLinksUser = { href: string; type: string };
  type ActivityListFeedsResponseLinksTimeline = { href: string; type: string };
  type ActivityListFeedsResponseLinks = {
    timeline: ActivityListFeedsResponseLinksTimeline;
    user: ActivityListFeedsResponseLinksUser;
    current_user_public: ActivityListFeedsResponseLinksCurrentUserPublic;
    current_user: ActivityListFeedsResponseLinksCurrentUser;
    current_user_actor: ActivityListFeedsResponseLinksCurrentUserActor;
    current_user_organization: ActivityListFeedsResponseLinksCurrentUserOrganization;
    current_user_organizations: Array<
      ActivityListFeedsResponseLinksCurrentUserOrganizationsItem
    >;
    security_advisories: ActivityListFeedsResponseLinksSecurityAdvisories;
  };
  type ActivityListFeedsResponse = {
    timeline_url: string;
    user_url: string;
    current_user_public_url: string;
    current_user_url: string;
    current_user_actor_url: string;
    current_user_organization_url: string;
    current_user_organization_urls: Array<string>;
    security_advisories_url: string;
    _links: ActivityListFeedsResponseLinks;
  };
  type ActivityListNotificationsResponse = Array<
    ActivityListNotificationsResponseItem
  >;
  type ActivityListNotificationsForRepoResponse = Array<
    ActivityListNotificationsForRepoResponseItem
  >;
  type ActivityListStargazersForRepoResponse = Array<
    ActivityListStargazersForRepoResponseItem
  >;
  type ActivityListReposStarredByUserResponse = Array<
    ActivityListReposStarredByUserResponseItem
  >;
  type ActivityListReposStarredByAuthenticatedUserResponse = Array<
    ActivityListReposStarredByAuthenticatedUserResponseItem
  >;
  type ActivityListWatchersForRepoResponse = Array<
    ActivityListWatchersForRepoResponseItem
  >;
  type ActivityListReposWatchedByUserResponse = Array<
    ActivityListReposWatchedByUserResponseItem
  >;
  type ActivityListWatchedReposForAuthenticatedUserResponse = Array<
    ActivityListWatchedReposForAuthenticatedUserResponseItem
  >;
  type AppsListInstallationsResponse = Array<AppsListInstallationsResponseItem>;
  type AppsListPlansResponse = Array<AppsListPlansResponseItem>;
  type AppsListPlansStubbedResponse = Array<AppsListPlansStubbedResponseItem>;
  type AppsListAccountsUserOrOrgOnPlanResponse = Array<
    AppsListAccountsUserOrOrgOnPlanResponseItem
  >;
  type AppsListAccountsUserOrOrgOnPlanStubbedResponse = Array<
    AppsListAccountsUserOrOrgOnPlanStubbedResponseItem
  >;
  type AppsListMarketplacePurchasesForAuthenticatedUserResponse = Array<
    AppsListMarketplacePurchasesForAuthenticatedUserResponseItem
  >;
  type AppsListMarketplacePurchasesForAuthenticatedUserStubbedResponse = Array<
    AppsListMarketplacePurchasesForAuthenticatedUserStubbedResponseItem
  >;
  type ChecksListAnnotationsResponse = Array<ChecksListAnnotationsResponseItem>;
  type CodesOfConductListConductCodesResponse = Array<
    CodesOfConductListConductCodesResponseItem
  >;
  type GistsListPublicForUserResponse = Array<
    GistsListPublicForUserResponseItem
  >;
  type GistsListResponse = Array<GistsListResponseItem>;
  type GistsListPublicResponse = Array<GistsListPublicResponseItem>;
  type GistsListStarredResponse = Array<GistsListStarredResponseItem>;
  type GistsListCommitsResponse = Array<GistsListCommitsResponseItem>;
  type GistsListForksResponse = Array<GistsListForksResponseItem>;
  type GistsListCommentsResponse = Array<GistsListCommentsResponseItem>;
  type GitignoreListTemplatesResponse = Array<string>;
  type IssuesListResponse = Array<IssuesListResponseItem>;
  type IssuesListForAuthenticatedUserResponse = Array<
    IssuesListForAuthenticatedUserResponseItem
  >;
  type IssuesListForOrgResponse = Array<IssuesListForOrgResponseItem>;
  type IssuesListForRepoResponse = Array<IssuesListForRepoResponseItem>;
  type IssuesListAssigneesResponse = Array<IssuesListAssigneesResponseItem>;
  type IssuesListCommentsResponse = Array<IssuesListCommentsResponseItem>;
  type IssuesListCommentsForRepoResponse = Array<
    IssuesListCommentsForRepoResponseItem
  >;
  type IssuesListEventsResponse = Array<IssuesListEventsResponseItem>;
  type IssuesListEventsForRepoResponse = Array<
    IssuesListEventsForRepoResponseItem
  >;
  type IssuesListLabelsForRepoResponse = Array<
    IssuesListLabelsForRepoResponseItem
  >;
  type IssuesListLabelsOnIssueResponse = Array<
    IssuesListLabelsOnIssueResponseItem
  >;
  type IssuesAddLabelsResponse = Array<IssuesAddLabelsResponseItem>;
  type IssuesRemoveLabelResponse = Array<IssuesRemoveLabelResponseItem>;
  type IssuesReplaceLabelsResponse = Array<IssuesReplaceLabelsResponseItem>;
  type IssuesListLabelsForMilestoneResponse = Array<
    IssuesListLabelsForMilestoneResponseItem
  >;
  type IssuesListMilestonesForRepoResponse = Array<
    IssuesListMilestonesForRepoResponseItem
  >;
  type IssuesListEventsForTimelineResponse = Array<
    IssuesListEventsForTimelineResponseItem
  >;
  type LicensesListCommonlyUsedResponse = Array<
    LicensesListCommonlyUsedResponseItem
  >;
  type LicensesListResponse = Array<LicensesListResponseItem>;
  type MigrationsListForOrgResponse = Array<MigrationsListForOrgResponseItem>;
  type MigrationsGetCommitAuthorsResponse = Array<
    MigrationsGetCommitAuthorsResponseItem
  >;
  type MigrationsGetLargeFilesResponse = Array<
    MigrationsGetLargeFilesResponseItem
  >;
  type MigrationsListForAuthenticatedUserResponse = Array<
    MigrationsListForAuthenticatedUserResponseItem
  >;
  type OauthAuthorizationsListGrantsResponse = Array<
    OauthAuthorizationsListGrantsResponseItem
  >;
  type OauthAuthorizationsListAuthorizationsResponse = Array<
    OauthAuthorizationsListAuthorizationsResponseItem
  >;
  type OrgsListForAuthenticatedUserResponse = Array<
    OrgsListForAuthenticatedUserResponseItem
  >;
  type OrgsListResponse = Array<OrgsListResponseItem>;
  type OrgsListForUserResponse = Array<OrgsListForUserResponseItem>;
  type OrgsListBlockedUsersResponse = Array<OrgsListBlockedUsersResponseItem>;
  type OrgsListHooksResponse = Array<OrgsListHooksResponseItem>;
  type OrgsListMembersResponse = Array<OrgsListMembersResponseItem>;
  type OrgsListPublicMembersResponse = Array<OrgsListPublicMembersResponseItem>;
  type OrgsListInvitationTeamsResponse = Array<
    OrgsListInvitationTeamsResponseItem
  >;
  type OrgsListPendingInvitationsResponse = Array<
    OrgsListPendingInvitationsResponseItem
  >;
  type OrgsListMembershipsResponse = Array<OrgsListMembershipsResponseItem>;
  type OrgsListOutsideCollaboratorsResponse = Array<
    OrgsListOutsideCollaboratorsResponseItem
  >;
  type ProjectsListForRepoResponse = Array<ProjectsListForRepoResponseItem>;
  type ProjectsListForOrgResponse = Array<ProjectsListForOrgResponseItem>;
  type ProjectsListForUserResponse = Array<ProjectsListForUserResponseItem>;
  type ProjectsListCardsResponse = Array<ProjectsListCardsResponseItem>;
  type ProjectsListCollaboratorsResponse = Array<
    ProjectsListCollaboratorsResponseItem
  >;
  type ProjectsListColumnsResponse = Array<ProjectsListColumnsResponseItem>;
  type PullsListResponse = Array<PullsListResponseItem>;
  type PullsListCommitsResponse = Array<PullsListCommitsResponseItem>;
  type PullsListFilesResponse = Array<PullsListFilesResponseItem>;
  type PullsListCommentsResponse = Array<PullsListCommentsResponseItem>;
  type PullsListCommentsForRepoResponse = Array<
    PullsListCommentsForRepoResponseItem
  >;
  type PullsListReviewsResponse = Array<PullsListReviewsResponseItem>;
  type PullsGetCommentsForReviewResponse = Array<
    PullsGetCommentsForReviewResponseItem
  >;
  type ReactionsListForCommitCommentResponse = Array<
    ReactionsListForCommitCommentResponseItem
  >;
  type ReactionsListForIssueResponse = Array<ReactionsListForIssueResponseItem>;
  type ReactionsListForIssueCommentResponse = Array<
    ReactionsListForIssueCommentResponseItem
  >;
  type ReactionsListForPullRequestReviewCommentResponse = Array<
    ReactionsListForPullRequestReviewCommentResponseItem
  >;
  type ReactionsListForTeamDiscussionResponse = Array<
    ReactionsListForTeamDiscussionResponseItem
  >;
  type ReactionsListForTeamDiscussionCommentResponse = Array<
    ReactionsListForTeamDiscussionCommentResponseItem
  >;
  type ReposListForOrgResponse = Array<ReposListForOrgResponseItem>;
  type ReposListPublicResponse = Array<ReposListPublicResponseItem>;
  type ReposListTeamsResponse = Array<ReposListTeamsResponseItem>;
  type ReposListTagsResponse = Array<ReposListTagsResponseItem>;
  type ReposListBranchesResponse = Array<ReposListBranchesResponseItem>;
  type ReposReplaceProtectedBranchRequiredStatusChecksContextsResponse = Array<
    string
  >;
  type ReposAddProtectedBranchRequiredStatusChecksContextsResponse = Array<
    string
  >;
  type ReposRemoveProtectedBranchRequiredStatusChecksContextsResponse = Array<
    string
  >;
  type ReposListProtectedBranchTeamRestrictionsResponse = any;
  type ReposReplaceProtectedBranchTeamRestrictionsResponse = Array<
    ReposReplaceProtectedBranchTeamRestrictionsResponseItem
  >;
  type ReposAddProtectedBranchTeamRestrictionsResponse = Array<
    ReposAddProtectedBranchTeamRestrictionsResponseItem
  >;
  type ReposRemoveProtectedBranchTeamRestrictionsResponse = Array<
    ReposRemoveProtectedBranchTeamRestrictionsResponseItem
  >;
  type ReposReplaceProtectedBranchUserRestrictionsResponse = Array<
    ReposReplaceProtectedBranchUserRestrictionsResponseItem
  >;
  type ReposAddProtectedBranchUserRestrictionsResponse = Array<
    ReposAddProtectedBranchUserRestrictionsResponseItem
  >;
  type ReposRemoveProtectedBranchUserRestrictionsResponse = Array<
    ReposRemoveProtectedBranchUserRestrictionsResponseItem
  >;
  type ReposListCollaboratorsResponse = Array<
    ReposListCollaboratorsResponseItem
  >;
  type ReposListCommitCommentsResponse = Array<
    ReposListCommitCommentsResponseItem
  >;
  type ReposListCommentsForCommitResponse = Array<
    ReposListCommentsForCommitResponseItem
  >;
  type ReposListCommitsResponse = Array<ReposListCommitsResponseItem>;
  type ReposCompareCommitsResponse = any;
  type ReposListBranchesForHeadCommitResponse = Array<
    ReposListBranchesForHeadCommitResponseItem
  >;
  type ReposListPullRequestsAssociatedWithCommitResponse = Array<
    ReposListPullRequestsAssociatedWithCommitResponseItem
  >;
  type ReposListDeploymentsResponse = Array<ReposListDeploymentsResponseItem>;
  type ReposListDeploymentStatusesResponse = Array<
    ReposListDeploymentStatusesResponseItem
  >;
  type ReposListDownloadsResponse = Array<ReposListDownloadsResponseItem>;
  type ReposListForksResponse = Array<ReposListForksResponseItem>;
  type ReposListHooksResponse = Array<ReposListHooksResponseItem>;
  type ReposListInvitationsResponse = Array<ReposListInvitationsResponseItem>;
  type ReposListInvitationsForAuthenticatedUserResponse = Array<
    ReposListInvitationsForAuthenticatedUserResponseItem
  >;
  type ReposListDeployKeysResponse = Array<ReposListDeployKeysResponseItem>;
  type ReposListPagesBuildsResponse = Array<ReposListPagesBuildsResponseItem>;
  type ReposListReleasesResponse = Array<ReposListReleasesResponseItem>;
  type ReposListAssetsForReleaseResponse = Array<
    ReposListAssetsForReleaseResponseItem
  >;
  type ReposGetContributorsStatsResponse = Array<
    ReposGetContributorsStatsResponseItem
  >;
  type ReposGetCommitActivityStatsResponse = Array<
    ReposGetCommitActivityStatsResponseItem
  >;
  type ReposGetCodeFrequencyStatsResponse = Array<Array<number>>;
  type ReposGetPunchCardStatsResponse = Array<Array<number>>;
  type ReposListStatusesForRefResponse = Array<
    ReposListStatusesForRefResponseItem
  >;
  type ReposGetTopReferrersResponse = Array<ReposGetTopReferrersResponseItem>;
  type ReposGetTopPathsResponse = Array<ReposGetTopPathsResponseItem>;
  type TeamsListResponse = Array<TeamsListResponseItem>;
  type TeamsListReposResponse = Array<TeamsListReposResponseItem>;
  type TeamsListForAuthenticatedUserResponse = Array<
    TeamsListForAuthenticatedUserResponseItem
  >;
  type TeamsListProjectsResponse = Array<TeamsListProjectsResponseItem>;
  type TeamsListDiscussionCommentsResponse = Array<
    TeamsListDiscussionCommentsResponseItem
  >;
  type TeamsListDiscussionsResponse = Array<TeamsListDiscussionsResponseItem>;
  type TeamsListMembersResponse = Array<TeamsListMembersResponseItem>;
  type TeamsListPendingInvitationsResponse = Array<
    TeamsListPendingInvitationsResponseItem
  >;
  type UsersGetContextForUserResponse = any;
  type UsersListResponse = Array<UsersListResponseItem>;
  type UsersListBlockedResponse = Array<UsersListBlockedResponseItem>;
  type UsersListEmailsResponse = Array<UsersListEmailsResponseItem>;
  type UsersListPublicEmailsResponse = Array<UsersListPublicEmailsResponseItem>;
  type UsersAddEmailsResponse = Array<UsersAddEmailsResponseItem>;
  type UsersTogglePrimaryEmailVisibilityResponse = Array<
    UsersTogglePrimaryEmailVisibilityResponseItem
  >;
  type UsersListFollowersForUserResponse = Array<
    UsersListFollowersForUserResponseItem
  >;
  type UsersListFollowersForAuthenticatedUserResponse = Array<
    UsersListFollowersForAuthenticatedUserResponseItem
  >;
  type UsersListFollowingForUserResponse = Array<
    UsersListFollowingForUserResponseItem
  >;
  type UsersListFollowingForAuthenticatedUserResponse = Array<
    UsersListFollowingForAuthenticatedUserResponseItem
  >;
  type UsersListGpgKeysForUserResponse = Array<
    UsersListGpgKeysForUserResponseItem
  >;
  type UsersListGpgKeysResponse = Array<UsersListGpgKeysResponseItem>;
  type UsersListPublicKeysForUserResponse = Array<
    UsersListPublicKeysForUserResponseItem
  >;
  type UsersListPublicKeysResponse = Array<UsersListPublicKeysResponseItem>;

  export type ActivityListPublicEventsParams = {
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ActivityListRepoEventsParams = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ActivityListPublicEventsForRepoNetworkParams = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ActivityListPublicEventsForOrgParams = {
    org: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ActivityListReceivedEventsForUserParams = {
    username: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ActivityListReceivedPublicEventsForUserParams = {
    username: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ActivityListEventsForUserParams = {
    username: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ActivityListPublicEventsForUserParams = {
    username: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ActivityListEventsForOrgParams = {
    username: string;

    org: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ActivityListNotificationsParams = {
    /**
     * If `true`, show notifications marked as read.
     */
    all?: boolean;
    /**
     * If `true`, only shows notifications in which the user is directly participating or mentioned.
     */
    participating?: boolean;
    /**
     * Only show notifications updated after the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    since?: string;
    /**
     * Only show notifications updated before the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    before?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ActivityListNotificationsForRepoParams = {
    owner: string;

    repo: string;
    /**
     * If `true`, show notifications marked as read.
     */
    all?: boolean;
    /**
     * If `true`, only shows notifications in which the user is directly participating or mentioned.
     */
    participating?: boolean;
    /**
     * Only show notifications updated after the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    since?: string;
    /**
     * Only show notifications updated before the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    before?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ActivityMarkAsReadParams = {
    /**
     * Describes the last point that notifications were checked. Anything updated since this time will not be updated. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    last_read_at?: string;
  };
  export type ActivityMarkNotificationsAsReadForRepoParams = {
    owner: string;

    repo: string;
    /**
     * Describes the last point that notifications were checked. Anything updated since this time will not be updated. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    last_read_at?: string;
  };
  export type ActivityGetThreadParams = {
    thread_id: number;
  };
  export type ActivityMarkThreadAsReadParams = {
    thread_id: number;
  };
  export type ActivityGetThreadSubscriptionParams = {
    thread_id: number;
  };
  export type ActivitySetThreadSubscriptionParams = {
    thread_id: number;
    /**
     * Unsubscribes and subscribes you to a conversation. Set `ignored` to `true` to block all notifications from this thread.
     */
    ignored?: boolean;
  };
  export type ActivityDeleteThreadSubscriptionParams = {
    thread_id: number;
  };
  export type ActivityListStargazersForRepoParams = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ActivityListReposStarredByUserParams = {
    username: string;
    /**
     * One of `created` (when the repository was starred) or `updated` (when it was last pushed to).
     */
    sort?: "created" | "updated";
    /**
     * One of `asc` (ascending) or `desc` (descending).
     */
    direction?: "asc" | "desc";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ActivityListReposStarredByAuthenticatedUserParams = {
    /**
     * One of `created` (when the repository was starred) or `updated` (when it was last pushed to).
     */
    sort?: "created" | "updated";
    /**
     * One of `asc` (ascending) or `desc` (descending).
     */
    direction?: "asc" | "desc";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ActivityCheckStarringRepoParams = {
    owner: string;

    repo: string;
  };
  export type ActivityStarRepoParams = {
    owner: string;

    repo: string;
  };
  export type ActivityUnstarRepoParams = {
    owner: string;

    repo: string;
  };
  export type ActivityListWatchersForRepoParams = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ActivityListReposWatchedByUserParams = {
    username: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ActivityListWatchedReposForAuthenticatedUserParams = {
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ActivityGetRepoSubscriptionParams = {
    owner: string;

    repo: string;
  };
  export type ActivitySetRepoSubscriptionParams = {
    owner: string;

    repo: string;
    /**
     * Determines if notifications should be received from this repository.
     */
    subscribed?: boolean;
    /**
     * Determines if all notifications should be blocked from this repository.
     */
    ignored?: boolean;
  };
  export type ActivityDeleteRepoSubscriptionParams = {
    owner: string;

    repo: string;
  };
  export type AppsGetBySlugParams = {
    app_slug: string;
  };
  export type AppsListInstallationsParams = {
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type AppsGetInstallationParams = {
    installation_id: number;
  };
  export type AppsDeleteInstallationParams = {
    installation_id: number;
  };
  export type AppsCreateInstallationTokenParams = {
    installation_id: number;
    /**
     * The `id`s of the repositories that the installation token can access. Providing repository `id`s restricts the access of an installation token to specific repositories. You can use the "[List repositories](https://developer.github.com/v3/apps/installations/#list-repositories)" endpoint to get the `id` of all repositories that an installation can access. For example, you can select specific repositories when creating an installation token to restrict the number of repositories that can be cloned using the token.
     */
    repository_ids?: number[];
    /**
     * The permissions granted to the access token. The permissions object includes the permission names and their access type. For a complete list of permissions and allowable values, see "[GitHub App permissions](https://developer.github.com/apps/building-github-apps/creating-github-apps-using-url-parameters/#github-app-permissions)."
     */
    permissions?: AppsCreateInstallationTokenParamsPermissions;
  };
  export type AppsGetOrgInstallationParams = {
    org: string;
  };
  export type AppsFindOrgInstallationParams = {
    org: string;
  };
  export type AppsGetRepoInstallationParams = {
    owner: string;

    repo: string;
  };
  export type AppsFindRepoInstallationParams = {
    owner: string;

    repo: string;
  };
  export type AppsGetUserInstallationParams = {
    username: string;
  };
  export type AppsFindUserInstallationParams = {
    username: string;
  };
  export type AppsCreateFromManifestParams = {
    code: string;
  };
  export type AppsListReposParams = {
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type AppsListInstallationsForAuthenticatedUserParams = {
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type AppsListInstallationReposForAuthenticatedUserParams = {
    installation_id: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type AppsAddRepoToInstallationParams = {
    installation_id: number;

    repository_id: number;
  };
  export type AppsRemoveRepoFromInstallationParams = {
    installation_id: number;

    repository_id: number;
  };
  export type AppsCreateContentAttachmentParams = {
    content_reference_id: number;
    /**
     * The title of the content attachment displayed in the body or comment of an issue or pull request.
     */
    title: string;
    /**
     * The body text of the content attachment displayed in the body or comment of an issue or pull request. This parameter supports markdown.
     */
    body: string;
  };
  export type AppsListPlansParams = {
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type AppsListPlansStubbedParams = {
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type AppsListAccountsUserOrOrgOnPlanParams = {
    plan_id: number;
    /**
     * Sorts the GitHub accounts by the date they were created or last updated. Can be one of `created` or `updated`.
     */
    sort?: "created" | "updated";
    /**
     * To return the oldest accounts first, set to `asc`. Can be one of `asc` or `desc`. Ignored without the `sort` parameter.
     */
    direction?: "asc" | "desc";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type AppsListAccountsUserOrOrgOnPlanStubbedParams = {
    plan_id: number;
    /**
     * Sorts the GitHub accounts by the date they were created or last updated. Can be one of `created` or `updated`.
     */
    sort?: "created" | "updated";
    /**
     * To return the oldest accounts first, set to `asc`. Can be one of `asc` or `desc`. Ignored without the `sort` parameter.
     */
    direction?: "asc" | "desc";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type AppsCheckAccountIsAssociatedWithAnyParams = {
    account_id: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type AppsCheckAccountIsAssociatedWithAnyStubbedParams = {
    account_id: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type AppsListMarketplacePurchasesForAuthenticatedUserParams = {
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type AppsListMarketplacePurchasesForAuthenticatedUserStubbedParams = {
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ChecksCreateParams = {
    owner: string;

    repo: string;
    /**
     * The name of the check. For example, "code-coverage".
     */
    name: string;
    /**
     * The SHA of the commit.
     */
    head_sha: string;
    /**
     * The URL of the integrator's site that has the full details of the check.
     */
    details_url?: string;
    /**
     * A reference for the run on the integrator's system.
     */
    external_id?: string;
    /**
     * The current status. Can be one of `queued`, `in_progress`, or `completed`.
     */
    status?: "queued" | "in_progress" | "completed";
    /**
     * The time that the check run began. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    started_at?: string;
    /**
     * **Required if you provide `completed_at` or a `status` of `completed`**. The final conclusion of the check. Can be one of `success`, `failure`, `neutral`, `cancelled`, `timed_out`, or `action_required`. When the conclusion is `action_required`, additional details should be provided on the site specified by `details_url`.
     * **Note:** Providing `conclusion` will automatically set the `status` parameter to `completed`.
     */
    conclusion?:
      | "success"
      | "failure"
      | "neutral"
      | "cancelled"
      | "timed_out"
      | "action_required";
    /**
     * The time the check completed. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    completed_at?: string;
    /**
     * Check runs can accept a variety of data in the `output` object, including a `title` and `summary` and can optionally provide descriptive details about the run. See the [`output` object](https://developer.github.com/v3/checks/runs/#output-object) description.
     */
    output?: ChecksCreateParamsOutput;
    /**
     * Displays a button on GitHub that can be clicked to alert your app to do additional tasks. For example, a code linting app can display a button that automatically fixes detected errors. The button created in this object is displayed after the check run completes. When a user clicks the button, GitHub sends the [`check_run.requested_action` webhook](https://developer.github.com/v3/activity/events/types/#checkrunevent) to your app. Each action includes a `label`, `identifier` and `description`. A maximum of three actions are accepted. See the [`actions` object](https://developer.github.com/v3/checks/runs/#actions-object) description. To learn more about check runs and requested actions, see "[Check runs and requested actions](https://developer.github.com/v3/checks/runs/#check-runs-and-requested-actions)."
     */
    actions?: ChecksCreateParamsActions[];
  };
  export type ChecksUpdateParams = {
    owner: string;

    repo: string;

    check_run_id: number;
    /**
     * The name of the check. For example, "code-coverage".
     */
    name?: string;
    /**
     * The URL of the integrator's site that has the full details of the check.
     */
    details_url?: string;
    /**
     * A reference for the run on the integrator's system.
     */
    external_id?: string;
    /**
     * This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    started_at?: string;
    /**
     * The current status. Can be one of `queued`, `in_progress`, or `completed`.
     */
    status?: "queued" | "in_progress" | "completed";
    /**
     * **Required if you provide `completed_at` or a `status` of `completed`**. The final conclusion of the check. Can be one of `success`, `failure`, `neutral`, `cancelled`, `timed_out`, or `action_required`.
     * **Note:** Providing `conclusion` will automatically set the `status` parameter to `completed`.
     */
    conclusion?:
      | "success"
      | "failure"
      | "neutral"
      | "cancelled"
      | "timed_out"
      | "action_required";
    /**
     * The time the check completed. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    completed_at?: string;
    /**
     * Check runs can accept a variety of data in the `output` object, including a `title` and `summary` and can optionally provide descriptive details about the run. See the [`output` object](https://developer.github.com/v3/checks/runs/#output-object-1) description.
     */
    output?: ChecksUpdateParamsOutput;
    /**
     * Possible further actions the integrator can perform, which a user may trigger. Each action includes a `label`, `identifier` and `description`. A maximum of three actions are accepted. See the [`actions` object](https://developer.github.com/v3/checks/runs/#actions-object) description.
     */
    actions?: ChecksUpdateParamsActions[];
  };
  export type ChecksListForRefParams = {
    owner: string;

    repo: string;

    ref: string;
    /**
     * Returns check runs with the specified `name`.
     */
    check_name?: string;
    /**
     * Returns check runs with the specified `status`. Can be one of `queued`, `in_progress`, or `completed`.
     */
    status?: "queued" | "in_progress" | "completed";
    /**
     * Filters check runs by their `completed_at` timestamp. Can be one of `latest` (returning the most recent check runs) or `all`.
     */
    filter?: "latest" | "all";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ChecksListForSuiteParams = {
    owner: string;

    repo: string;

    check_suite_id: number;
    /**
     * Returns check runs with the specified `name`.
     */
    check_name?: string;
    /**
     * Returns check runs with the specified `status`. Can be one of `queued`, `in_progress`, or `completed`.
     */
    status?: "queued" | "in_progress" | "completed";
    /**
     * Filters check runs by their `completed_at` timestamp. Can be one of `latest` (returning the most recent check runs) or `all`.
     */
    filter?: "latest" | "all";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ChecksGetParams = {
    owner: string;

    repo: string;

    check_run_id: number;
  };
  export type ChecksListAnnotationsParams = {
    owner: string;

    repo: string;

    check_run_id: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ChecksGetSuiteParams = {
    owner: string;

    repo: string;

    check_suite_id: number;
  };
  export type ChecksListSuitesForRefParams = {
    owner: string;

    repo: string;

    ref: string;
    /**
     * Filters check suites by GitHub App `id`.
     */
    app_id?: number;
    /**
     * Filters checks suites by the name of the [check run](https://developer.github.com/v3/checks/runs/).
     */
    check_name?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ChecksSetSuitesPreferencesParams = {
    owner: string;

    repo: string;
    /**
     * Enables or disables automatic creation of CheckSuite events upon pushes to the repository. Enabled by default. See the [`auto_trigger_checks` object](https://developer.github.com/v3/checks/suites/#auto_trigger_checks-object) description for details.
     */
    auto_trigger_checks?: ChecksSetSuitesPreferencesParamsAutoTriggerChecks[];
  };
  export type ChecksCreateSuiteParams = {
    owner: string;

    repo: string;
    /**
     * The sha of the head commit.
     */
    head_sha: string;
  };
  export type ChecksRerequestSuiteParams = {
    owner: string;

    repo: string;

    check_suite_id: number;
  };
  export type CodesOfConductGetConductCodeParams = {
    key: string;
  };
  export type CodesOfConductGetForRepoParams = {
    owner: string;

    repo: string;
  };
  export type GistsListPublicForUserParams = {
    username: string;
    /**
     * This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`. Only gists updated at or after this time are returned.
     */
    since?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type GistsListParams = {
    /**
     * This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`. Only gists updated at or after this time are returned.
     */
    since?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type GistsListPublicParams = {
    /**
     * This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`. Only gists updated at or after this time are returned.
     */
    since?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type GistsListStarredParams = {
    /**
     * This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`. Only gists updated at or after this time are returned.
     */
    since?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type GistsGetParams = {
    gist_id: string;
  };
  export type GistsGetRevisionParams = {
    gist_id: string;

    sha: string;
  };
  export type GistsCreateParams = {
    /**
     * The filenames and content of each file in the gist. The keys in the `files` object represent the filename and have the type `string`.
     */
    files: GistsCreateParamsFiles;
    /**
     * A descriptive name for this gist.
     */
    description?: string;
    /**
     * When `true`, the gist will be public and available for anyone to see.
     */
    public?: boolean;
  };
  export type GistsUpdateParams = {
    gist_id: string;
    /**
     * A descriptive name for this gist.
     */
    description?: string;
    /**
     * The filenames and content that make up this gist.
     */
    files?: GistsUpdateParamsFiles;
  };
  export type GistsListCommitsParams = {
    gist_id: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type GistsStarParams = {
    gist_id: string;
  };
  export type GistsUnstarParams = {
    gist_id: string;
  };
  export type GistsCheckIsStarredParams = {
    gist_id: string;
  };
  export type GistsForkParams = {
    gist_id: string;
  };
  export type GistsListForksParams = {
    gist_id: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type GistsDeleteParams = {
    gist_id: string;
  };
  export type GistsListCommentsParams = {
    gist_id: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type GistsGetCommentParams = {
    gist_id: string;

    comment_id: number;
  };
  export type GistsCreateCommentParams = {
    gist_id: string;
    /**
     * The comment text.
     */
    body: string;
  };
  export type GistsUpdateCommentParams = {
    gist_id: string;

    comment_id: number;
    /**
     * The comment text.
     */
    body: string;
  };
  export type GistsDeleteCommentParams = {
    gist_id: string;

    comment_id: number;
  };
  export type GitGetBlobParams = {
    owner: string;

    repo: string;

    file_sha: string;
  };
  export type GitCreateBlobParams = {
    owner: string;

    repo: string;
    /**
     * The new blob's content.
     */
    content: string;
    /**
     * The encoding used for `content`. Currently, `"utf-8"` and `"base64"` are supported.
     */
    encoding?: string;
  };
  export type GitGetCommitParams = {
    owner: string;

    repo: string;

    commit_sha: string;
  };
  export type GitCreateCommitParams = {
    owner: string;

    repo: string;
    /**
     * The commit message
     */
    message: string;
    /**
     * The SHA of the tree object this commit points to
     */
    tree: string;
    /**
     * The SHAs of the commits that were the parents of this commit. If omitted or empty, the commit will be written as a root commit. For a single parent, an array of one SHA should be provided; for a merge commit, an array of more than one should be provided.
     */
    parents: string[];
    /**
     * Information about the author of the commit. By default, the `author` will be the authenticated user and the current date. See the `author` and `committer` object below for details.
     */
    author?: GitCreateCommitParamsAuthor;
    /**
     * Information about the person who is making the commit. By default, `committer` will use the information set in `author`. See the `author` and `committer` object below for details.
     */
    committer?: GitCreateCommitParamsCommitter;
    /**
     * The [PGP signature](https://en.wikipedia.org/wiki/Pretty_Good_Privacy) of the commit. GitHub adds the signature to the `gpgsig` header of the created commit. For a commit signature to be verifiable by Git or GitHub, it must be an ASCII-armored detached PGP signature over the string commit as it would be written to the object database. To pass a `signature` parameter, you need to first manually create a valid PGP signature, which can be complicated. You may find it easier to [use the command line](https://git-scm.com/book/id/v2/Git-Tools-Signing-Your-Work) to create signed commits.
     */
    signature?: string;
  };
  export type GitGetRefParams = {
    owner: string;

    repo: string;
    /**
     * Must be formatted as `heads/branch`, not just `branch`
     */
    ref: string;
  };
  export type GitListRefsParams = {
    owner: string;

    repo: string;
    /**
     * Filter by sub-namespace (reference prefix). Most commen examples would be `'heads/'` and `'tags/'` to retrieve branches or tags
     */
    namespace?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type GitCreateRefParams = {
    owner: string;

    repo: string;
    /**
     * The name of the fully qualified reference (ie: `refs/heads/master`). If it doesn't start with 'refs' and have at least two slashes, it will be rejected.
     */
    ref: string;
    /**
     * The SHA1 value for this reference.
     */
    sha: string;
  };
  export type GitUpdateRefParams = {
    owner: string;

    repo: string;

    ref: string;
    /**
     * The SHA1 value to set this reference to
     */
    sha: string;
    /**
     * Indicates whether to force the update or to make sure the update is a fast-forward update. Leaving this out or setting it to `false` will make sure you're not overwriting work.
     */
    force?: boolean;
  };
  export type GitDeleteRefParams = {
    owner: string;

    repo: string;

    ref: string;
  };
  export type GitGetTagParams = {
    owner: string;

    repo: string;

    tag_sha: string;
  };
  export type GitCreateTagParams = {
    owner: string;

    repo: string;
    /**
     * The tag's name. This is typically a version (e.g., "v0.0.1").
     */
    tag: string;
    /**
     * The tag message.
     */
    message: string;
    /**
     * The SHA of the git object this is tagging.
     */
    object: string;
    /**
     * The type of the object we're tagging. Normally this is a `commit` but it can also be a `tree` or a `blob`.
     */
    type: "commit" | "tree" | "blob";
    /**
     * An object with information about the individual creating the tag.
     */
    tagger?: GitCreateTagParamsTagger;
  };
  export type GitGetTreeParams = {
    owner: string;

    repo: string;

    tree_sha: string;

    recursive?: 1;
  };
  export type GitCreateTreeParams = {
    owner: string;

    repo: string;
    /**
     * Objects (of `path`, `mode`, `type`, and `sha`) specifying a tree structure.
     */
    tree: GitCreateTreeParamsTree[];
    /**
     * The SHA1 of the tree you want to update with new data. If you don't set this, the commit will be created on top of everything; however, it will only contain your change, the rest of your files will show up as deleted.
     */
    base_tree?: string;
  };
  export type GitignoreGetTemplateParams = {
    name: string;
  };
  export type InteractionsGetRestrictionsForOrgParams = {
    org: string;
  };
  export type InteractionsAddOrUpdateRestrictionsForOrgParams = {
    org: string;
    /**
     * Specifies the group of GitHub users who can comment, open issues, or create pull requests in public repositories for the given organization. Must be one of: `existing_users`, `contributors_only`, or `collaborators_only`.
     */
    limit: "existing_users" | "contributors_only" | "collaborators_only";
  };
  export type InteractionsRemoveRestrictionsForOrgParams = {
    org: string;
  };
  export type InteractionsGetRestrictionsForRepoParams = {
    owner: string;

    repo: string;
  };
  export type InteractionsAddOrUpdateRestrictionsForRepoParams = {
    owner: string;

    repo: string;
    /**
     * Specifies the group of GitHub users who can comment, open issues, or create pull requests for the given repository. Must be one of: `existing_users`, `contributors_only`, or `collaborators_only`.
     */
    limit: "existing_users" | "contributors_only" | "collaborators_only";
  };
  export type InteractionsRemoveRestrictionsForRepoParams = {
    owner: string;

    repo: string;
  };
  export type IssuesListParams = {
    /**
     * Indicates which sorts of issues to return. Can be one of:
     * \* `assigned`: Issues assigned to you
     * \* `created`: Issues created by you
     * \* `mentioned`: Issues mentioning you
     * \* `subscribed`: Issues you're subscribed to updates for
     * \* `all`: All issues the authenticated user can see, regardless of participation or creation
     */
    filter?: "assigned" | "created" | "mentioned" | "subscribed" | "all";
    /**
     * Indicates the state of the issues to return. Can be either `open`, `closed`, or `all`.
     */
    state?: "open" | "closed" | "all";
    /**
     * A list of comma separated label names. Example: `bug,ui,@high`
     */
    labels?: string;
    /**
     * What to sort results by. Can be either `created`, `updated`, `comments`.
     */
    sort?: "created" | "updated" | "comments";
    /**
     * The direction of the sort. Can be either `asc` or `desc`.
     */
    direction?: "asc" | "desc";
    /**
     * Only issues updated at or after this time are returned. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    since?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type IssuesListForAuthenticatedUserParams = {
    /**
     * Indicates which sorts of issues to return. Can be one of:
     * \* `assigned`: Issues assigned to you
     * \* `created`: Issues created by you
     * \* `mentioned`: Issues mentioning you
     * \* `subscribed`: Issues you're subscribed to updates for
     * \* `all`: All issues the authenticated user can see, regardless of participation or creation
     */
    filter?: "assigned" | "created" | "mentioned" | "subscribed" | "all";
    /**
     * Indicates the state of the issues to return. Can be either `open`, `closed`, or `all`.
     */
    state?: "open" | "closed" | "all";
    /**
     * A list of comma separated label names. Example: `bug,ui,@high`
     */
    labels?: string;
    /**
     * What to sort results by. Can be either `created`, `updated`, `comments`.
     */
    sort?: "created" | "updated" | "comments";
    /**
     * The direction of the sort. Can be either `asc` or `desc`.
     */
    direction?: "asc" | "desc";
    /**
     * Only issues updated at or after this time are returned. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    since?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type IssuesListForOrgParams = {
    org: string;
    /**
     * Indicates which sorts of issues to return. Can be one of:
     * \* `assigned`: Issues assigned to you
     * \* `created`: Issues created by you
     * \* `mentioned`: Issues mentioning you
     * \* `subscribed`: Issues you're subscribed to updates for
     * \* `all`: All issues the authenticated user can see, regardless of participation or creation
     */
    filter?: "assigned" | "created" | "mentioned" | "subscribed" | "all";
    /**
     * Indicates the state of the issues to return. Can be either `open`, `closed`, or `all`.
     */
    state?: "open" | "closed" | "all";
    /**
     * A list of comma separated label names. Example: `bug,ui,@high`
     */
    labels?: string;
    /**
     * What to sort results by. Can be either `created`, `updated`, `comments`.
     */
    sort?: "created" | "updated" | "comments";
    /**
     * The direction of the sort. Can be either `asc` or `desc`.
     */
    direction?: "asc" | "desc";
    /**
     * Only issues updated at or after this time are returned. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    since?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type IssuesListForRepoParams = {
    owner: string;

    repo: string;
    /**
     * If an `integer` is passed, it should refer to a milestone by its `number` field. If the string `*` is passed, issues with any milestone are accepted. If the string `none` is passed, issues without milestones are returned.
     */
    milestone?: string;
    /**
     * Indicates the state of the issues to return. Can be either `open`, `closed`, or `all`.
     */
    state?: "open" | "closed" | "all";
    /**
     * Can be the name of a user. Pass in `none` for issues with no assigned user, and `*` for issues assigned to any user.
     */
    assignee?: string;
    /**
     * The user that created the issue.
     */
    creator?: string;
    /**
     * A user that's mentioned in the issue.
     */
    mentioned?: string;
    /**
     * A list of comma separated label names. Example: `bug,ui,@high`
     */
    labels?: string;
    /**
     * What to sort results by. Can be either `created`, `updated`, `comments`.
     */
    sort?: "created" | "updated" | "comments";
    /**
     * The direction of the sort. Can be either `asc` or `desc`.
     */
    direction?: "asc" | "desc";
    /**
     * Only issues updated at or after this time are returned. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    since?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type IssuesGetParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * @deprecated "number" parameter renamed to "issue_number"
     */
    number: number;
  };
  export type IssuesGetParams = {
    owner: string;

    repo: string;

    issue_number: number;
  };
  export type IssuesCreateParams = {
    owner: string;

    repo: string;
    /**
     * The title of the issue.
     */
    title: string;
    /**
     * The contents of the issue.
     */
    body?: string;
    /**
     * Login for the user that this issue should be assigned to. _NOTE: Only users with push access can set the assignee for new issues. The assignee is silently dropped otherwise. **This field is deprecated.**_
     */
    assignee?: string;
    /**
     * The `number` of the milestone to associate this issue with. _NOTE: Only users with push access can set the milestone for new issues. The milestone is silently dropped otherwise._
     */
    milestone?: number;
    /**
     * Labels to associate with this issue. _NOTE: Only users with push access can set labels for new issues. Labels are silently dropped otherwise._
     */
    labels?: string[];
    /**
     * Logins for Users to assign to this issue. _NOTE: Only users with push access can set assignees for new issues. Assignees are silently dropped otherwise._
     */
    assignees?: string[];
  };
  export type IssuesUpdateParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * The title of the issue.
     */
    title?: string;
    /**
     * The contents of the issue.
     */
    body?: string;
    /**
     * Login for the user that this issue should be assigned to. **This field is deprecated.**
     */
    assignee?: string;
    /**
     * State of the issue. Either `open` or `closed`.
     */
    state?: "open" | "closed";
    /**
     * The `number` of the milestone to associate this issue with or `null` to remove current. _NOTE: Only users with push access can set the milestone for issues. The milestone is silently dropped otherwise._
     */
    milestone?: number | null;
    /**
     * Labels to associate with this issue. Pass one or more Labels to _replace_ the set of Labels on this Issue. Send an empty array (`[]`) to clear all Labels from the Issue. _NOTE: Only users with push access can set labels for issues. Labels are silently dropped otherwise._
     */
    labels?: string[];
    /**
     * Logins for Users to assign to this issue. Pass one or more user logins to _replace_ the set of assignees on this Issue. Send an empty array (`[]`) to clear all assignees from the Issue. _NOTE: Only users with push access can set assignees for new issues. Assignees are silently dropped otherwise._
     */
    assignees?: string[];
    /**
     * @deprecated "number" parameter renamed to "issue_number"
     */
    number: number;
  };
  export type IssuesUpdateParams = {
    owner: string;

    repo: string;

    issue_number: number;
    /**
     * The title of the issue.
     */
    title?: string;
    /**
     * The contents of the issue.
     */
    body?: string;
    /**
     * Login for the user that this issue should be assigned to. **This field is deprecated.**
     */
    assignee?: string;
    /**
     * State of the issue. Either `open` or `closed`.
     */
    state?: "open" | "closed";
    /**
     * The `number` of the milestone to associate this issue with or `null` to remove current. _NOTE: Only users with push access can set the milestone for issues. The milestone is silently dropped otherwise._
     */
    milestone?: number | null;
    /**
     * Labels to associate with this issue. Pass one or more Labels to _replace_ the set of Labels on this Issue. Send an empty array (`[]`) to clear all Labels from the Issue. _NOTE: Only users with push access can set labels for issues. Labels are silently dropped otherwise._
     */
    labels?: string[];
    /**
     * Logins for Users to assign to this issue. Pass one or more user logins to _replace_ the set of assignees on this Issue. Send an empty array (`[]`) to clear all assignees from the Issue. _NOTE: Only users with push access can set assignees for new issues. Assignees are silently dropped otherwise._
     */
    assignees?: string[];
  };
  export type IssuesLockParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * The reason for locking the issue or pull request conversation. Lock will fail if you don't use one of these reasons:
     * \* `off-topic`
     * \* `too heated`
     * \* `resolved`
     * \* `spam`
     */
    lock_reason?: "off-topic" | "too heated" | "resolved" | "spam";
    /**
     * @deprecated "number" parameter renamed to "issue_number"
     */
    number: number;
  };
  export type IssuesLockParams = {
    owner: string;

    repo: string;

    issue_number: number;
    /**
     * The reason for locking the issue or pull request conversation. Lock will fail if you don't use one of these reasons:
     * \* `off-topic`
     * \* `too heated`
     * \* `resolved`
     * \* `spam`
     */
    lock_reason?: "off-topic" | "too heated" | "resolved" | "spam";
  };
  export type IssuesUnlockParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * @deprecated "number" parameter renamed to "issue_number"
     */
    number: number;
  };
  export type IssuesUnlockParams = {
    owner: string;

    repo: string;

    issue_number: number;
  };
  export type IssuesListAssigneesParams = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type IssuesCheckAssigneeParams = {
    owner: string;

    repo: string;

    assignee: string;
  };
  export type IssuesAddAssigneesParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * Usernames of people to assign this issue to. _NOTE: Only users with push access can add assignees to an issue. Assignees are silently ignored otherwise._
     */
    assignees?: string[];
    /**
     * @deprecated "number" parameter renamed to "issue_number"
     */
    number: number;
  };
  export type IssuesAddAssigneesParams = {
    owner: string;

    repo: string;

    issue_number: number;
    /**
     * Usernames of people to assign this issue to. _NOTE: Only users with push access can add assignees to an issue. Assignees are silently ignored otherwise._
     */
    assignees?: string[];
  };
  export type IssuesRemoveAssigneesParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * Usernames of assignees to remove from an issue. _NOTE: Only users with push access can remove assignees from an issue. Assignees are silently ignored otherwise._
     */
    assignees?: string[];
    /**
     * @deprecated "number" parameter renamed to "issue_number"
     */
    number: number;
  };
  export type IssuesRemoveAssigneesParams = {
    owner: string;

    repo: string;

    issue_number: number;
    /**
     * Usernames of assignees to remove from an issue. _NOTE: Only users with push access can remove assignees from an issue. Assignees are silently ignored otherwise._
     */
    assignees?: string[];
  };
  export type IssuesListCommentsParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * Only comments updated at or after this time are returned. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    since?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
    /**
     * @deprecated "number" parameter renamed to "issue_number"
     */
    number: number;
  };
  export type IssuesListCommentsParams = {
    owner: string;

    repo: string;

    issue_number: number;
    /**
     * Only comments updated at or after this time are returned. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    since?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type IssuesListCommentsForRepoParams = {
    owner: string;

    repo: string;
    /**
     * Either `created` or `updated`.
     */
    sort?: "created" | "updated";
    /**
     * Either `asc` or `desc`. Ignored without the `sort` parameter.
     */
    direction?: "asc" | "desc";
    /**
     * Only comments updated at or after this time are returned. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    since?: string;
  };
  export type IssuesGetCommentParams = {
    owner: string;

    repo: string;

    comment_id: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type IssuesCreateCommentParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * The contents of the comment.
     */
    body: string;
    /**
     * @deprecated "number" parameter renamed to "issue_number"
     */
    number: number;
  };
  export type IssuesCreateCommentParams = {
    owner: string;

    repo: string;

    issue_number: number;
    /**
     * The contents of the comment.
     */
    body: string;
  };
  export type IssuesUpdateCommentParams = {
    owner: string;

    repo: string;

    comment_id: number;
    /**
     * The contents of the comment.
     */
    body: string;
  };
  export type IssuesDeleteCommentParams = {
    owner: string;

    repo: string;

    comment_id: number;
  };
  export type IssuesListEventsParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
    /**
     * @deprecated "number" parameter renamed to "issue_number"
     */
    number: number;
  };
  export type IssuesListEventsParams = {
    owner: string;

    repo: string;

    issue_number: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type IssuesListEventsForRepoParams = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type IssuesGetEventParams = {
    owner: string;

    repo: string;

    event_id: number;
  };
  export type IssuesListLabelsForRepoParams = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type IssuesGetLabelParams = {
    owner: string;

    repo: string;

    name: string;
  };
  export type IssuesCreateLabelParams = {
    owner: string;

    repo: string;
    /**
     * The name of the label. Emoji can be added to label names, using either native emoji or colon-style markup. For example, typing `:strawberry:` will render the emoji ![:strawberry:](https://github.githubassets.com/images/icons/emoji/unicode/1f353.png ":strawberry:"). For a full list of available emoji and codes, see [emoji-cheat-sheet.com](http://emoji-cheat-sheet.com/).
     */
    name: string;
    /**
     * The [hexadecimal color code](http://www.color-hex.com/) for the label, without the leading `#`.
     */
    color: string;
    /**
     * A short description of the label.
     */
    description?: string;
  };
  export type IssuesUpdateLabelParams = {
    owner: string;

    repo: string;

    current_name: string;
    /**
     * The new name of the label. Emoji can be added to label names, using either native emoji or colon-style markup. For example, typing `:strawberry:` will render the emoji ![:strawberry:](https://github.githubassets.com/images/icons/emoji/unicode/1f353.png ":strawberry:"). For a full list of available emoji and codes, see [emoji-cheat-sheet.com](http://emoji-cheat-sheet.com/).
     */
    name?: string;
    /**
     * The [hexadecimal color code](http://www.color-hex.com/) for the label, without the leading `#`.
     */
    color?: string;
    /**
     * A short description of the label.
     */
    description?: string;
  };
  export type IssuesDeleteLabelParams = {
    owner: string;

    repo: string;

    name: string;
  };
  export type IssuesListLabelsOnIssueParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
    /**
     * @deprecated "number" parameter renamed to "issue_number"
     */
    number: number;
  };
  export type IssuesListLabelsOnIssueParams = {
    owner: string;

    repo: string;

    issue_number: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type IssuesAddLabelsParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * The name of the label to add to the issue. Must contain at least one label. **Note:** Alternatively, you can pass a single label as a `string` or an `array` of labels directly, but GitHub recommends passing an object with the `labels` key.
     */
    labels: string[];
    /**
     * @deprecated "number" parameter renamed to "issue_number"
     */
    number: number;
  };
  export type IssuesAddLabelsParams = {
    owner: string;

    repo: string;

    issue_number: number;
    /**
     * The name of the label to add to the issue. Must contain at least one label. **Note:** Alternatively, you can pass a single label as a `string` or an `array` of labels directly, but GitHub recommends passing an object with the `labels` key.
     */
    labels: string[];
  };
  export type IssuesRemoveLabelParamsDeprecatedNumber = {
    owner: string;

    repo: string;

    name: string;
    /**
     * @deprecated "number" parameter renamed to "issue_number"
     */
    number: number;
  };
  export type IssuesRemoveLabelParams = {
    owner: string;

    repo: string;

    issue_number: number;

    name: string;
  };
  export type IssuesReplaceLabelsParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * The names of the labels to add to the issue. You can pass an empty array to remove all labels. **Note:** Alternatively, you can pass a single label as a `string` or an `array` of labels directly, but GitHub recommends passing an object with the `labels` key.
     */
    labels?: string[];
    /**
     * @deprecated "number" parameter renamed to "issue_number"
     */
    number: number;
  };
  export type IssuesReplaceLabelsParams = {
    owner: string;

    repo: string;

    issue_number: number;
    /**
     * The names of the labels to add to the issue. You can pass an empty array to remove all labels. **Note:** Alternatively, you can pass a single label as a `string` or an `array` of labels directly, but GitHub recommends passing an object with the `labels` key.
     */
    labels?: string[];
  };
  export type IssuesRemoveLabelsParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * @deprecated "number" parameter renamed to "issue_number"
     */
    number: number;
  };
  export type IssuesRemoveLabelsParams = {
    owner: string;

    repo: string;

    issue_number: number;
  };
  export type IssuesListLabelsForMilestoneParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
    /**
     * @deprecated "number" parameter renamed to "milestone_number"
     */
    number: number;
  };
  export type IssuesListLabelsForMilestoneParams = {
    owner: string;

    repo: string;

    milestone_number: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type IssuesListMilestonesForRepoParams = {
    owner: string;

    repo: string;
    /**
     * The state of the milestone. Either `open`, `closed`, or `all`.
     */
    state?: "open" | "closed" | "all";
    /**
     * What to sort results by. Either `due_on` or `completeness`.
     */
    sort?: "due_on" | "completeness";
    /**
     * The direction of the sort. Either `asc` or `desc`.
     */
    direction?: "asc" | "desc";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type IssuesGetMilestoneParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * @deprecated "number" parameter renamed to "milestone_number"
     */
    number: number;
  };
  export type IssuesGetMilestoneParams = {
    owner: string;

    repo: string;

    milestone_number: number;
  };
  export type IssuesCreateMilestoneParams = {
    owner: string;

    repo: string;
    /**
     * The title of the milestone.
     */
    title: string;
    /**
     * The state of the milestone. Either `open` or `closed`.
     */
    state?: "open" | "closed";
    /**
     * A description of the milestone.
     */
    description?: string;
    /**
     * The milestone due date. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    due_on?: string;
  };
  export type IssuesUpdateMilestoneParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * The title of the milestone.
     */
    title?: string;
    /**
     * The state of the milestone. Either `open` or `closed`.
     */
    state?: "open" | "closed";
    /**
     * A description of the milestone.
     */
    description?: string;
    /**
     * The milestone due date. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    due_on?: string;
    /**
     * @deprecated "number" parameter renamed to "milestone_number"
     */
    number: number;
  };
  export type IssuesUpdateMilestoneParams = {
    owner: string;

    repo: string;

    milestone_number: number;
    /**
     * The title of the milestone.
     */
    title?: string;
    /**
     * The state of the milestone. Either `open` or `closed`.
     */
    state?: "open" | "closed";
    /**
     * A description of the milestone.
     */
    description?: string;
    /**
     * The milestone due date. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    due_on?: string;
  };
  export type IssuesDeleteMilestoneParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * @deprecated "number" parameter renamed to "milestone_number"
     */
    number: number;
  };
  export type IssuesDeleteMilestoneParams = {
    owner: string;

    repo: string;

    milestone_number: number;
  };
  export type IssuesListEventsForTimelineParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
    /**
     * @deprecated "number" parameter renamed to "issue_number"
     */
    number: number;
  };
  export type IssuesListEventsForTimelineParams = {
    owner: string;

    repo: string;

    issue_number: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type LicensesGetParams = {
    license: string;
  };
  export type LicensesGetForRepoParams = {
    owner: string;

    repo: string;
  };
  export type MarkdownRenderParams = {
    /**
     * The Markdown text to render in HTML. Markdown content must be 400 KB or less.
     */
    text: string;
    /**
     * The rendering mode. Can be either:
     * \* `markdown` to render a document in plain Markdown, just like README.md files are rendered.
     * \* `gfm` to render a document in [GitHub Flavored Markdown](https://github.github.com/gfm/), which creates links for user mentions as well as references to SHA-1 hashes, issues, and pull requests.
     */
    mode?: "markdown" | "gfm";
    /**
     * The repository context to use when creating references in `gfm` mode. Omit this parameter when using `markdown` mode.
     */
    context?: string;
  };
  export type MarkdownRenderRawParams = {
    data: string;
  };
  export type MigrationsStartForOrgParams = {
    org: string;
    /**
     * A list of arrays indicating which repositories should be migrated.
     */
    repositories: string[];
    /**
     * Indicates whether repositories should be locked (to prevent manipulation) while migrating data.
     */
    lock_repositories?: boolean;
    /**
     * Indicates whether attachments should be excluded from the migration (to reduce migration archive file size).
     */
    exclude_attachments?: boolean;
  };
  export type MigrationsListForOrgParams = {
    org: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type MigrationsGetStatusForOrgParams = {
    org: string;

    migration_id: number;
  };
  export type MigrationsGetArchiveForOrgParams = {
    org: string;

    migration_id: number;
  };
  export type MigrationsDeleteArchiveForOrgParams = {
    org: string;

    migration_id: number;
  };
  export type MigrationsUnlockRepoForOrgParams = {
    org: string;

    migration_id: number;

    repo_name: string;
  };
  export type MigrationsStartImportParams = {
    owner: string;

    repo: string;
    /**
     * The URL of the originating repository.
     */
    vcs_url: string;
    /**
     * The originating VCS type. Can be one of `subversion`, `git`, `mercurial`, or `tfvc`. Please be aware that without this parameter, the import job will take additional time to detect the VCS type before beginning the import. This detection step will be reflected in the response.
     */
    vcs?: "subversion" | "git" | "mercurial" | "tfvc";
    /**
     * If authentication is required, the username to provide to `vcs_url`.
     */
    vcs_username?: string;
    /**
     * If authentication is required, the password to provide to `vcs_url`.
     */
    vcs_password?: string;
    /**
     * For a tfvc import, the name of the project that is being imported.
     */
    tfvc_project?: string;
  };
  export type MigrationsGetImportProgressParams = {
    owner: string;

    repo: string;
  };
  export type MigrationsUpdateImportParams = {
    owner: string;

    repo: string;
    /**
     * The username to provide to the originating repository.
     */
    vcs_username?: string;
    /**
     * The password to provide to the originating repository.
     */
    vcs_password?: string;
  };
  export type MigrationsGetCommitAuthorsParams = {
    owner: string;

    repo: string;
    /**
     * Only authors found after this id are returned. Provide the highest author ID you've seen so far. New authors may be added to the list at any point while the importer is performing the `raw` step.
     */
    since?: string;
  };
  export type MigrationsMapCommitAuthorParams = {
    owner: string;

    repo: string;

    author_id: number;
    /**
     * The new Git author email.
     */
    email?: string;
    /**
     * The new Git author name.
     */
    name?: string;
  };
  export type MigrationsSetLfsPreferenceParams = {
    owner: string;

    repo: string;
    /**
     * Can be one of `opt_in` (large files will be stored using Git LFS) or `opt_out` (large files will be removed during the import).
     */
    use_lfs: "opt_in" | "opt_out";
  };
  export type MigrationsGetLargeFilesParams = {
    owner: string;

    repo: string;
  };
  export type MigrationsCancelImportParams = {
    owner: string;

    repo: string;
  };
  export type MigrationsStartForAuthenticatedUserParams = {
    /**
     * An array of repositories to include in the migration.
     */
    repositories: string[];
    /**
     * Locks the `repositories` to prevent changes during the migration when set to `true`.
     */
    lock_repositories?: boolean;
    /**
     * Does not include attachments uploaded to GitHub.com in the migration data when set to `true`. Excluding attachments will reduce the migration archive file size.
     */
    exclude_attachments?: boolean;
  };
  export type MigrationsListForAuthenticatedUserParams = {
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type MigrationsGetStatusForAuthenticatedUserParams = {
    migration_id: number;
  };
  export type MigrationsGetArchiveForAuthenticatedUserParams = {
    migration_id: number;
  };
  export type MigrationsDeleteArchiveForAuthenticatedUserParams = {
    migration_id: number;
  };
  export type MigrationsUnlockRepoForAuthenticatedUserParams = {
    migration_id: number;

    repo_name: string;
  };
  export type OauthAuthorizationsListGrantsParams = {
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type OauthAuthorizationsGetGrantParams = {
    grant_id: number;
  };
  export type OauthAuthorizationsDeleteGrantParams = {
    grant_id: number;
  };
  export type OauthAuthorizationsListAuthorizationsParams = {
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type OauthAuthorizationsGetAuthorizationParams = {
    authorization_id: number;
  };
  export type OauthAuthorizationsCreateAuthorizationParams = {
    /**
     * A list of scopes that this authorization is in.
     */
    scopes?: string[];
    /**
     * A note to remind you what the OAuth token is for. Tokens not associated with a specific OAuth application (i.e. personal access tokens) must have a unique note.
     */
    note: string;
    /**
     * A URL to remind you what app the OAuth token is for.
     */
    note_url?: string;
    /**
     * The 20 character OAuth app client key for which to create the token.
     */
    client_id?: string;
    /**
     * The 40 character OAuth app client secret for which to create the token.
     */
    client_secret?: string;
    /**
     * A unique string to distinguish an authorization from others created for the same client ID and user.
     */
    fingerprint?: string;
  };
  export type OauthAuthorizationsGetOrCreateAuthorizationForAppParams = {
    client_id: string;
    /**
     * The 40 character OAuth app client secret associated with the client ID specified in the URL.
     */
    client_secret: string;
    /**
     * A list of scopes that this authorization is in.
     */
    scopes?: string[];
    /**
     * A note to remind you what the OAuth token is for.
     */
    note?: string;
    /**
     * A URL to remind you what app the OAuth token is for.
     */
    note_url?: string;
    /**
     * A unique string to distinguish an authorization from others created for the same client and user. If provided, this API is functionally equivalent to [Get-or-create an authorization for a specific app and fingerprint](https://developer.github.com/v3/oauth_authorizations/#get-or-create-an-authorization-for-a-specific-app-and-fingerprint).
     */
    fingerprint?: string;
  };
  export type OauthAuthorizationsGetOrCreateAuthorizationForAppAndFingerprintParams = {
    client_id: string;

    fingerprint: string;
    /**
     * The 40 character OAuth app client secret associated with the client ID specified in the URL.
     */
    client_secret: string;
    /**
     * A list of scopes that this authorization is in.
     */
    scopes?: string[];
    /**
     * A note to remind you what the OAuth token is for.
     */
    note?: string;
    /**
     * A URL to remind you what app the OAuth token is for.
     */
    note_url?: string;
  };
  export type OauthAuthorizationsGetOrCreateAuthorizationForAppFingerprintParams = {
    client_id: string;

    fingerprint: string;
    /**
     * The 40 character OAuth app client secret associated with the client ID specified in the URL.
     */
    client_secret: string;
    /**
     * A list of scopes that this authorization is in.
     */
    scopes?: string[];
    /**
     * A note to remind you what the OAuth token is for.
     */
    note?: string;
    /**
     * A URL to remind you what app the OAuth token is for.
     */
    note_url?: string;
  };
  export type OauthAuthorizationsUpdateAuthorizationParams = {
    authorization_id: number;
    /**
     * Replaces the authorization scopes with these.
     */
    scopes?: string[];
    /**
     * A list of scopes to add to this authorization.
     */
    add_scopes?: string[];
    /**
     * A list of scopes to remove from this authorization.
     */
    remove_scopes?: string[];
    /**
     * A note to remind you what the OAuth token is for. Tokens not associated with a specific OAuth application (i.e. personal access tokens) must have a unique note.
     */
    note?: string;
    /**
     * A URL to remind you what app the OAuth token is for.
     */
    note_url?: string;
    /**
     * A unique string to distinguish an authorization from others created for the same client ID and user.
     */
    fingerprint?: string;
  };
  export type OauthAuthorizationsDeleteAuthorizationParams = {
    authorization_id: number;
  };
  export type OauthAuthorizationsCheckAuthorizationParams = {
    client_id: string;

    access_token: string;
  };
  export type OauthAuthorizationsResetAuthorizationParams = {
    client_id: string;

    access_token: string;
  };
  export type OauthAuthorizationsRevokeAuthorizationForApplicationParams = {
    client_id: string;

    access_token: string;
  };
  export type OauthAuthorizationsRevokeGrantForApplicationParams = {
    client_id: string;

    access_token: string;
  };
  export type OrgsListForAuthenticatedUserParams = {
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type OrgsListParams = {
    /**
     * The integer ID of the last Organization that you've seen.
     */
    since?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type OrgsListForUserParams = {
    username: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type OrgsGetParams = {
    org: string;
  };
  export type OrgsUpdateParams = {
    org: string;
    /**
     * Billing email address. This address is not publicized.
     */
    billing_email?: string;
    /**
     * The company name.
     */
    company?: string;
    /**
     * The publicly visible email address.
     */
    email?: string;
    /**
     * The location.
     */
    location?: string;
    /**
     * The shorthand name of the company.
     */
    name?: string;
    /**
     * The description of the company.
     */
    description?: string;
    /**
     * Toggles whether organization projects are enabled for the organization.
     */
    has_organization_projects?: boolean;
    /**
     * Toggles whether repository projects are enabled for repositories that belong to the organization.
     */
    has_repository_projects?: boolean;
    /**
     * Default permission level members have for organization repositories:
     * \* `read` - can pull, but not push to or administer this repository.
     * \* `write` - can pull and push, but not administer this repository.
     * \* `admin` - can pull, push, and administer this repository.
     * \* `none` - no permissions granted by default.
     */
    default_repository_permission?: "read" | "write" | "admin" | "none";
    /**
     * Toggles the ability of non-admin organization members to create repositories. Can be one of:
     * \* `true` - all organization members can create repositories.
     * \* `false` - only admin members can create repositories.
     * Default: `true`
     * **Note:** Another parameter can override the this parameter. See [this note](https://developer.github.com/v3/orgs/#members_can_create_repositories) for details. **Note:** Another parameter can override the this parameter. See [this note](https://developer.github.com/v3/orgs/#members_can_create_repositories) for details.
     */
    members_can_create_repositories?: boolean;
    /**
     * Specifies which types of repositories non-admin organization members can create. Can be one of:
     * \* `all` - all organization members can create public and private repositories.
     * \* `private` - members can create private repositories. This option is only available to repositories that are part of an organization on [GitHub Business Cloud](https://github.com/pricing/business-cloud).
     * \* `none` - only admin members can create repositories.
     * **Note:** Using this parameter will override values set in `members_can_create_repositories`. See [this note](https://developer.github.com/v3/orgs/#members_can_create_repositories) for details.
     */
    members_allowed_repository_creation_type?: "all" | "private" | "none";
  };
  export type OrgsListBlockedUsersParams = {
    org: string;
  };
  export type OrgsCheckBlockedUserParams = {
    org: string;

    username: string;
  };
  export type OrgsBlockUserParams = {
    org: string;

    username: string;
  };
  export type OrgsUnblockUserParams = {
    org: string;

    username: string;
  };
  export type OrgsListHooksParams = {
    org: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type OrgsGetHookParams = {
    org: string;

    hook_id: number;
  };
  export type OrgsCreateHookParams = {
    org: string;
    /**
     * Must be passed as "web".
     */
    name: string;
    /**
     * Key/value pairs to provide settings for this webhook. [These are defined below](https://developer.github.com/v3/orgs/hooks/#create-hook-config-params).
     */
    config: OrgsCreateHookParamsConfig;
    /**
     * Determines what [events](https://developer.github.com/v3/activity/events/types/) the hook is triggered for.
     */
    events?: string[];
    /**
     * Determines if notifications are sent when the webhook is triggered. Set to `true` to send notifications.
     */
    active?: boolean;
  };
  export type OrgsUpdateHookParams = {
    org: string;

    hook_id: number;
    /**
     * Key/value pairs to provide settings for this webhook. [These are defined below](https://developer.github.com/v3/orgs/hooks/#update-hook-config-params).
     */
    config?: OrgsUpdateHookParamsConfig;
    /**
     * Determines what [events](https://developer.github.com/v3/activity/events/types/) the hook is triggered for.
     */
    events?: string[];
    /**
     * Determines if notifications are sent when the webhook is triggered. Set to `true` to send notifications.
     */
    active?: boolean;
  };
  export type OrgsPingHookParams = {
    org: string;

    hook_id: number;
  };
  export type OrgsDeleteHookParams = {
    org: string;

    hook_id: number;
  };
  export type OrgsListMembersParams = {
    org: string;
    /**
     * Filter members returned in the list. Can be one of:
     * \* `2fa_disabled` - Members without [two-factor authentication](https://github.com/blog/1614-two-factor-authentication) enabled. Available for organization owners.
     * \* `all` - All members the authenticated user can see.
     */
    filter?: "2fa_disabled" | "all";
    /**
     * Filter members returned by their role. Can be one of:
     * \* `all` - All members of the organization, regardless of role.
     * \* `admin` - Organization owners.
     * \* `member` - Non-owner organization members.
     */
    role?: "all" | "admin" | "member";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type OrgsCheckMembershipParams = {
    org: string;

    username: string;
  };
  export type OrgsRemoveMemberParams = {
    org: string;

    username: string;
  };
  export type OrgsListPublicMembersParams = {
    org: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type OrgsCheckPublicMembershipParams = {
    org: string;

    username: string;
  };
  export type OrgsPublicizeMembershipParams = {
    org: string;

    username: string;
  };
  export type OrgsConcealMembershipParams = {
    org: string;

    username: string;
  };
  export type OrgsGetMembershipParams = {
    org: string;

    username: string;
  };
  export type OrgsAddOrUpdateMembershipParams = {
    org: string;

    username: string;
    /**
     * The role to give the user in the organization. Can be one of:
     * \* `admin` - The user will become an owner of the organization.
     * \* `member` - The user will become a non-owner member of the organization.
     */
    role?: "admin" | "member";
  };
  export type OrgsRemoveMembershipParams = {
    org: string;

    username: string;
  };
  export type OrgsListInvitationTeamsParams = {
    org: string;

    invitation_id: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type OrgsListPendingInvitationsParams = {
    org: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type OrgsCreateInvitationParams = {
    org: string;
    /**
     * **Required unless you provide `email`**. GitHub user ID for the person you are inviting.
     */
    invitee_id?: number;
    /**
     * **Required unless you provide `invitee_id`**. Email address of the person you are inviting, which can be an existing GitHub user.
     */
    email?: string;
    /**
     * Specify role for new member. Can be one of:
     * \* `admin` - Organization owners with full administrative rights to the organization and complete access to all repositories and teams.
     * \* `direct_member` - Non-owner organization members with ability to see other members and join teams by invitation.
     * \* `billing_manager` - Non-owner organization members with ability to manage the billing settings of your organization.
     */
    role?: "admin" | "direct_member" | "billing_manager";
    /**
     * Specify IDs for the teams you want to invite new members to.
     */
    team_ids?: number[];
  };
  export type OrgsListMembershipsParams = {
    /**
     * Indicates the state of the memberships to return. Can be either `active` or `pending`. If not specified, the API returns both active and pending memberships.
     */
    state?: "active" | "pending";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type OrgsGetMembershipForAuthenticatedUserParams = {
    org: string;
  };
  export type OrgsUpdateMembershipParams = {
    org: string;
    /**
     * The state that the membership should be in. Only `"active"` will be accepted.
     */
    state: "active";
  };
  export type OrgsListOutsideCollaboratorsParams = {
    org: string;
    /**
     * Filter the list of outside collaborators. Can be one of:
     * \* `2fa_disabled`: Outside collaborators without [two-factor authentication](https://github.com/blog/1614-two-factor-authentication) enabled.
     * \* `all`: All outside collaborators.
     */
    filter?: "2fa_disabled" | "all";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type OrgsRemoveOutsideCollaboratorParams = {
    org: string;

    username: string;
  };
  export type OrgsConvertMemberToOutsideCollaboratorParams = {
    org: string;

    username: string;
  };
  export type ProjectsListForRepoParams = {
    owner: string;

    repo: string;
    /**
     * Indicates the state of the projects to return. Can be either `open`, `closed`, or `all`.
     */
    state?: "open" | "closed" | "all";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ProjectsListForOrgParams = {
    org: string;
    /**
     * Indicates the state of the projects to return. Can be either `open`, `closed`, or `all`.
     */
    state?: "open" | "closed" | "all";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ProjectsListForUserParams = {
    username: string;
    /**
     * Indicates the state of the projects to return. Can be either `open`, `closed`, or `all`.
     */
    state?: "open" | "closed" | "all";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ProjectsGetParams = {
    project_id: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ProjectsCreateForRepoParams = {
    owner: string;

    repo: string;
    /**
     * The name of the project.
     */
    name: string;
    /**
     * The description of the project.
     */
    body?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ProjectsCreateForOrgParams = {
    org: string;
    /**
     * The name of the project.
     */
    name: string;
    /**
     * The description of the project.
     */
    body?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ProjectsCreateForAuthenticatedUserParams = {
    /**
     * The name of the project.
     */
    name: string;
    /**
     * The description of the project.
     */
    body?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ProjectsUpdateParams = {
    project_id: number;
    /**
     * The name of the project.
     */
    name?: string;
    /**
     * The description of the project.
     */
    body?: string;
    /**
     * State of the project. Either `open` or `closed`.
     */
    state?: "open" | "closed";
    /**
     * The permission level that determines whether all members of the project's organization can see and/or make changes to the project. Setting `organization_permission` is only available for organization projects. If an organization member belongs to a team with a higher level of access or is a collaborator with a higher level of access, their permission level is not lowered by `organization_permission`. For information on changing access for a team or collaborator, see [Add or update team project](https://developer.github.com/v3/teams/#add-or-update-team-project) or [Add user as a collaborator](https://developer.github.com/v3/projects/collaborators/#add-user-as-a-collaborator).
     *
     * **Note:** Updating a project's `organization_permission` requires `admin` access to the project.
     *
     * Can be one of:
     * \* `read` - Organization members can read, but not write to or administer this project.
     * \* `write` - Organization members can read and write, but not administer this project.
     * \* `admin` - Organization members can read, write and administer this project.
     * \* `none` - Organization members can only see this project if it is public.
     */
    organization_permission?: string;
    /**
     * Sets the visibility of a project board. Setting `private` is only available for organization and user projects. **Note:** Updating a project's visibility requires `admin` access to the project.
     *
     * Can be one of:
     * \* `false` - Anyone can see the project.
     * \* `true` - Only the user can view a project board created on a user account. Organization members with the appropriate `organization_permission` can see project boards in an organization account.
     */
    private?: boolean;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ProjectsDeleteParams = {
    project_id: number;
  };
  export type ProjectsListCardsParams = {
    column_id: number;
    /**
     * Filters the project cards that are returned by the card's state. Can be one of `all`,`archived`, or `not_archived`.
     */
    archived_state?: "all" | "archived" | "not_archived";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ProjectsGetCardParams = {
    card_id: number;
  };
  export type ProjectsCreateCardParams = {
    column_id: number;
    /**
     * The card's note content. Only valid for cards without another type of content, so you must omit when specifying `content_id` and `content_type`.
     */
    note?: string;
    /**
     * The issue or pull request id you want to associate with this card. You can use the [List issues for a repository](https://developer.github.com/v3/issues/#list-issues-for-a-repository) and [List pull requests](https://developer.github.com/v3/pulls/#list-pull-requests) endpoints to find this id.
     * **Note:** Depending on whether you use the issue id or pull request id, you will need to specify `Issue` or `PullRequest` as the `content_type`.
     */
    content_id?: number;
    /**
     * **Required if you provide `content_id`**. The type of content you want to associate with this card. Use `Issue` when `content_id` is an issue id and use `PullRequest` when `content_id` is a pull request id.
     */
    content_type?: string;
  };
  export type ProjectsUpdateCardParams = {
    card_id: number;
    /**
     * The card's note content. Only valid for cards without another type of content, so this cannot be specified if the card already has a `content_id` and `content_type`.
     */
    note?: string;
    /**
     * Use `true` to archive a project card. Specify `false` if you need to restore a previously archived project card.
     */
    archived?: boolean;
  };
  export type ProjectsDeleteCardParams = {
    card_id: number;
  };
  export type ProjectsMoveCardParams = {
    card_id: number;
    /**
     * Can be one of `top`, `bottom`, or `after:<card_id>`, where `<card_id>` is the `id` value of a card in the same column, or in the new column specified by `column_id`.
     */
    position: string;
    /**
     * The `id` value of a column in the same project.
     */
    column_id?: number;
  };
  export type ProjectsListCollaboratorsParams = {
    project_id: number;
    /**
     * Filters the collaborators by their affiliation. Can be one of:
     * \* `outside`: Outside collaborators of a project that are not a member of the project's organization.
     * \* `direct`: Collaborators with permissions to a project, regardless of organization membership status.
     * \* `all`: All collaborators the authenticated user can see.
     */
    affiliation?: "outside" | "direct" | "all";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ProjectsReviewUserPermissionLevelParams = {
    project_id: number;

    username: string;
  };
  export type ProjectsAddCollaboratorParams = {
    project_id: number;

    username: string;
    /**
     * The permission to grant the collaborator. Note that, if you choose not to pass any parameters, you'll need to set `Content-Length` to zero when calling out to this endpoint. For more information, see "[HTTP verbs](https://developer.github.com/v3/#http-verbs)." Can be one of:
     * \* `read` - can read, but not write to or administer this project.
     * \* `write` - can read and write, but not administer this project.
     * \* `admin` - can read, write and administer this project.
     */
    permission?: "read" | "write" | "admin";
  };
  export type ProjectsRemoveCollaboratorParams = {
    project_id: number;

    username: string;
  };
  export type ProjectsListColumnsParams = {
    project_id: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ProjectsGetColumnParams = {
    column_id: number;
  };
  export type ProjectsCreateColumnParams = {
    project_id: number;
    /**
     * The name of the column.
     */
    name: string;
  };
  export type ProjectsUpdateColumnParams = {
    column_id: number;
    /**
     * The new name of the column.
     */
    name: string;
  };
  export type ProjectsDeleteColumnParams = {
    column_id: number;
  };
  export type ProjectsMoveColumnParams = {
    column_id: number;
    /**
     * Can be one of `first`, `last`, or `after:<column_id>`, where `<column_id>` is the `id` value of a column in the same project.
     */
    position: string;
  };
  export type PullsListParams = {
    owner: string;

    repo: string;
    /**
     * Either `open`, `closed`, or `all` to filter by state.
     */
    state?: "open" | "closed" | "all";
    /**
     * Filter pulls by head user or head organization and branch name in the format of `user:ref-name` or `organization:ref-name`. For example: `github:new-script-format` or `octocat:test-branch`.
     */
    head?: string;
    /**
     * Filter pulls by base branch name. Example: `gh-pages`.
     */
    base?: string;
    /**
     * What to sort results by. Can be either `created`, `updated`, `popularity` (comment count) or `long-running` (age, filtering by pulls updated in the last month).
     */
    sort?: "created" | "updated" | "popularity" | "long-running";
    /**
     * The direction of the sort. Can be either `asc` or `desc`.
     */
    direction?: "asc" | "desc";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type PullsGetParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * @deprecated "number" parameter renamed to "pull_number"
     */
    number: number;
  };
  export type PullsGetParams = {
    owner: string;

    repo: string;

    pull_number: number;
  };
  export type PullsCreateParams = {
    owner: string;

    repo: string;
    /**
     * The title of the pull request.
     */
    title: string;
    /**
     * The name of the branch where your changes are implemented. For cross-repository pull requests in the same network, namespace `head` with a user like this: `username:branch`.
     */
    head: string;
    /**
     * The name of the branch you want the changes pulled into. This should be an existing branch on the current repository. You cannot submit a pull request to one repository that requests a merge to a base of another repository.
     */
    base: string;
    /**
     * The contents of the pull request.
     */
    body?: string;
    /**
     * Indicates whether [maintainers can modify](https://help.github.com/articles/allowing-changes-to-a-pull-request-branch-created-from-a-fork/) the pull request.
     */
    maintainer_can_modify?: boolean;
    /**
     * Indicates whether the pull request is a draft. See "[Draft Pull Requests](https://help.github.com/en/articles/about-pull-requests#draft-pull-requests)" in the GitHub Help documentation to learn more.
     */
    draft?: boolean;
  };
  export type PullsCreateFromIssueParams = {
    owner: string;

    repo: string;
    /**
     * The issue number in this repository to turn into a Pull Request.
     */
    issue: number;
    /**
     * The name of the branch where your changes are implemented. For cross-repository pull requests in the same network, namespace `head` with a user like this: `username:branch`.
     */
    head: string;
    /**
     * The name of the branch you want the changes pulled into. This should be an existing branch on the current repository. You cannot submit a pull request to one repository that requests a merge to a base of another repository.
     */
    base: string;
    /**
     * Indicates whether [maintainers can modify](https://help.github.com/articles/allowing-changes-to-a-pull-request-branch-created-from-a-fork/) the pull request.
     */
    maintainer_can_modify?: boolean;
    /**
     * Indicates whether the pull request is a draft. See "[Draft Pull Requests](https://help.github.com/en/articles/about-pull-requests#draft-pull-requests)" in the GitHub Help documentation to learn more.
     */
    draft?: boolean;
  };
  export type PullsUpdateBranchParams = {
    owner: string;

    repo: string;

    pull_number: number;
    /**
     * The expected SHA of the pull request's HEAD ref. This is the most recent commit on the pull request's branch. If the expected SHA does not match the pull request's HEAD, you will receive a `422 Unprocessable Entity` status. You can use the "[List commits on a repository](https://developer.github.com/v3/repos/commits/#list-commits-on-a-repository)" endpoint to find the most recent commit SHA.
     */
    expected_head_sha?: string;
  };
  export type PullsUpdateParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * The title of the pull request.
     */
    title?: string;
    /**
     * The contents of the pull request.
     */
    body?: string;
    /**
     * State of this Pull Request. Either `open` or `closed`.
     */
    state?: "open" | "closed";
    /**
     * The name of the branch you want your changes pulled into. This should be an existing branch on the current repository. You cannot update the base branch on a pull request to point to another repository.
     */
    base?: string;
    /**
     * Indicates whether [maintainers can modify](https://help.github.com/articles/allowing-changes-to-a-pull-request-branch-created-from-a-fork/) the pull request.
     */
    maintainer_can_modify?: boolean;
    /**
     * @deprecated "number" parameter renamed to "pull_number"
     */
    number: number;
  };
  export type PullsUpdateParams = {
    owner: string;

    repo: string;

    pull_number: number;
    /**
     * The title of the pull request.
     */
    title?: string;
    /**
     * The contents of the pull request.
     */
    body?: string;
    /**
     * State of this Pull Request. Either `open` or `closed`.
     */
    state?: "open" | "closed";
    /**
     * The name of the branch you want your changes pulled into. This should be an existing branch on the current repository. You cannot update the base branch on a pull request to point to another repository.
     */
    base?: string;
    /**
     * Indicates whether [maintainers can modify](https://help.github.com/articles/allowing-changes-to-a-pull-request-branch-created-from-a-fork/) the pull request.
     */
    maintainer_can_modify?: boolean;
  };
  export type PullsListCommitsParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
    /**
     * @deprecated "number" parameter renamed to "pull_number"
     */
    number: number;
  };
  export type PullsListCommitsParams = {
    owner: string;

    repo: string;

    pull_number: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type PullsListFilesParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
    /**
     * @deprecated "number" parameter renamed to "pull_number"
     */
    number: number;
  };
  export type PullsListFilesParams = {
    owner: string;

    repo: string;

    pull_number: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type PullsCheckIfMergedParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * @deprecated "number" parameter renamed to "pull_number"
     */
    number: number;
  };
  export type PullsCheckIfMergedParams = {
    owner: string;

    repo: string;

    pull_number: number;
  };
  export type PullsMergeParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * Title for the automatic commit message.
     */
    commit_title?: string;
    /**
     * Extra detail to append to automatic commit message.
     */
    commit_message?: string;
    /**
     * SHA that pull request head must match to allow merge.
     */
    sha?: string;
    /**
     * Merge method to use. Possible values are `merge`, `squash` or `rebase`. Default is `merge`.
     */
    merge_method?: "merge" | "squash" | "rebase";
    /**
     * @deprecated "number" parameter renamed to "pull_number"
     */
    number: number;
  };
  export type PullsMergeParams = {
    owner: string;

    repo: string;

    pull_number: number;
    /**
     * Title for the automatic commit message.
     */
    commit_title?: string;
    /**
     * Extra detail to append to automatic commit message.
     */
    commit_message?: string;
    /**
     * SHA that pull request head must match to allow merge.
     */
    sha?: string;
    /**
     * Merge method to use. Possible values are `merge`, `squash` or `rebase`. Default is `merge`.
     */
    merge_method?: "merge" | "squash" | "rebase";
  };
  export type PullsListCommentsParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * Can be either `created` or `updated` comments.
     */
    sort?: "created" | "updated";
    /**
     * Can be either `asc` or `desc`. Ignored without `sort` parameter.
     */
    direction?: "asc" | "desc";
    /**
     * This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`. Only returns comments `updated` at or after this time.
     */
    since?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
    /**
     * @deprecated "number" parameter renamed to "pull_number"
     */
    number: number;
  };
  export type PullsListCommentsParams = {
    owner: string;

    repo: string;

    pull_number: number;
    /**
     * Can be either `created` or `updated` comments.
     */
    sort?: "created" | "updated";
    /**
     * Can be either `asc` or `desc`. Ignored without `sort` parameter.
     */
    direction?: "asc" | "desc";
    /**
     * This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`. Only returns comments `updated` at or after this time.
     */
    since?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type PullsListCommentsForRepoParams = {
    owner: string;

    repo: string;
    /**
     * Can be either `created` or `updated` comments.
     */
    sort?: "created" | "updated";
    /**
     * Can be either `asc` or `desc`. Ignored without `sort` parameter.
     */
    direction?: "asc" | "desc";
    /**
     * This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`. Only returns comments `updated` at or after this time.
     */
    since?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type PullsGetCommentParams = {
    owner: string;

    repo: string;

    comment_id: number;
  };
  export type PullsCreateCommentParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * The text of the comment.
     */
    body: string;
    /**
     * The SHA of the commit needing a comment. Not using the latest commit SHA may render your comment outdated if a subsequent commit modifies the line you specify as the `position`.
     */
    commit_id: string;
    /**
     * The relative path to the file that necessitates a comment.
     */
    path: string;
    /**
     * The position in the diff where you want to add a review comment. Note this value is not the same as the line number in the file. For help finding the position value, read the note below.
     */
    position: number;
    /**
     * @deprecated "number" parameter renamed to "pull_number"
     */
    number: number;
  };
  export type PullsCreateCommentParams = {
    owner: string;

    repo: string;

    pull_number: number;
    /**
     * The text of the comment.
     */
    body: string;
    /**
     * The SHA of the commit needing a comment. Not using the latest commit SHA may render your comment outdated if a subsequent commit modifies the line you specify as the `position`.
     */
    commit_id: string;
    /**
     * The relative path to the file that necessitates a comment.
     */
    path: string;
    /**
     * The position in the diff where you want to add a review comment. Note this value is not the same as the line number in the file. For help finding the position value, read the note below.
     */
    position: number;
  };
  export type PullsCreateCommentReplyParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * The text of the comment.
     */
    body: string;
    /**
     * The comment ID to reply to. **Note**: This must be the ID of a _top-level comment_, not a reply to that comment. Replies to replies are not supported.
     */
    in_reply_to: number;
    /**
     * @deprecated "number" parameter renamed to "pull_number"
     */
    number: number;
  };
  export type PullsCreateCommentReplyParams = {
    owner: string;

    repo: string;

    pull_number: number;
    /**
     * The text of the comment.
     */
    body: string;
    /**
     * The comment ID to reply to. **Note**: This must be the ID of a _top-level comment_, not a reply to that comment. Replies to replies are not supported.
     */
    in_reply_to: number;
  };
  export type PullsUpdateCommentParams = {
    owner: string;

    repo: string;

    comment_id: number;
    /**
     * The text of the comment.
     */
    body: string;
  };
  export type PullsDeleteCommentParams = {
    owner: string;

    repo: string;

    comment_id: number;
  };
  export type PullsListReviewRequestsParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
    /**
     * @deprecated "number" parameter renamed to "pull_number"
     */
    number: number;
  };
  export type PullsListReviewRequestsParams = {
    owner: string;

    repo: string;

    pull_number: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type PullsCreateReviewRequestParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * An array of user `login`s that will be requested.
     */
    reviewers?: string[];
    /**
     * An array of team `slug`s that will be requested.
     */
    team_reviewers?: string[];
    /**
     * @deprecated "number" parameter renamed to "pull_number"
     */
    number: number;
  };
  export type PullsCreateReviewRequestParams = {
    owner: string;

    repo: string;

    pull_number: number;
    /**
     * An array of user `login`s that will be requested.
     */
    reviewers?: string[];
    /**
     * An array of team `slug`s that will be requested.
     */
    team_reviewers?: string[];
  };
  export type PullsDeleteReviewRequestParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * An array of user `login`s that will be removed.
     */
    reviewers?: string[];
    /**
     * An array of team `slug`s that will be removed.
     */
    team_reviewers?: string[];
    /**
     * @deprecated "number" parameter renamed to "pull_number"
     */
    number: number;
  };
  export type PullsDeleteReviewRequestParams = {
    owner: string;

    repo: string;

    pull_number: number;
    /**
     * An array of user `login`s that will be removed.
     */
    reviewers?: string[];
    /**
     * An array of team `slug`s that will be removed.
     */
    team_reviewers?: string[];
  };
  export type PullsListReviewsParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
    /**
     * @deprecated "number" parameter renamed to "pull_number"
     */
    number: number;
  };
  export type PullsListReviewsParams = {
    owner: string;

    repo: string;

    pull_number: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type PullsGetReviewParamsDeprecatedNumber = {
    owner: string;

    repo: string;

    review_id: number;
    /**
     * @deprecated "number" parameter renamed to "pull_number"
     */
    number: number;
  };
  export type PullsGetReviewParams = {
    owner: string;

    repo: string;

    pull_number: number;

    review_id: number;
  };
  export type PullsDeletePendingReviewParamsDeprecatedNumber = {
    owner: string;

    repo: string;

    review_id: number;
    /**
     * @deprecated "number" parameter renamed to "pull_number"
     */
    number: number;
  };
  export type PullsDeletePendingReviewParams = {
    owner: string;

    repo: string;

    pull_number: number;

    review_id: number;
  };
  export type PullsGetCommentsForReviewParamsDeprecatedNumber = {
    owner: string;

    repo: string;

    review_id: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
    /**
     * @deprecated "number" parameter renamed to "pull_number"
     */
    number: number;
  };
  export type PullsGetCommentsForReviewParams = {
    owner: string;

    repo: string;

    pull_number: number;

    review_id: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type PullsCreateReviewParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * The SHA of the commit that needs a review. Not using the latest commit SHA may render your review comment outdated if a subsequent commit modifies the line you specify as the `position`. Defaults to the most recent commit in the pull request when you do not specify a value.
     */
    commit_id?: string;
    /**
     * **Required** when using `REQUEST_CHANGES` or `COMMENT` for the `event` parameter. The body text of the pull request review.
     */
    body?: string;
    /**
     * The review action you want to perform. The review actions include: `APPROVE`, `REQUEST_CHANGES`, or `COMMENT`. By leaving this blank, you set the review action state to `PENDING`, which means you will need to [submit the pull request review](https://developer.github.com/v3/pulls/reviews/#submit-a-pull-request-review) when you are ready.
     */
    event?: "APPROVE" | "REQUEST_CHANGES" | "COMMENT";
    /**
     * Use the following table to specify the location, destination, and contents of the draft review comment.
     */
    comments?: PullsCreateReviewParamsComments[];
    /**
     * @deprecated "number" parameter renamed to "pull_number"
     */
    number: number;
  };
  export type PullsCreateReviewParams = {
    owner: string;

    repo: string;

    pull_number: number;
    /**
     * The SHA of the commit that needs a review. Not using the latest commit SHA may render your review comment outdated if a subsequent commit modifies the line you specify as the `position`. Defaults to the most recent commit in the pull request when you do not specify a value.
     */
    commit_id?: string;
    /**
     * **Required** when using `REQUEST_CHANGES` or `COMMENT` for the `event` parameter. The body text of the pull request review.
     */
    body?: string;
    /**
     * The review action you want to perform. The review actions include: `APPROVE`, `REQUEST_CHANGES`, or `COMMENT`. By leaving this blank, you set the review action state to `PENDING`, which means you will need to [submit the pull request review](https://developer.github.com/v3/pulls/reviews/#submit-a-pull-request-review) when you are ready.
     */
    event?: "APPROVE" | "REQUEST_CHANGES" | "COMMENT";
    /**
     * Use the following table to specify the location, destination, and contents of the draft review comment.
     */
    comments?: PullsCreateReviewParamsComments[];
  };
  export type PullsUpdateReviewParamsDeprecatedNumber = {
    owner: string;

    repo: string;

    review_id: number;
    /**
     * The body text of the pull request review.
     */
    body: string;
    /**
     * @deprecated "number" parameter renamed to "pull_number"
     */
    number: number;
  };
  export type PullsUpdateReviewParams = {
    owner: string;

    repo: string;

    pull_number: number;

    review_id: number;
    /**
     * The body text of the pull request review.
     */
    body: string;
  };
  export type PullsSubmitReviewParamsDeprecatedNumber = {
    owner: string;

    repo: string;

    review_id: number;
    /**
     * The body text of the pull request review
     */
    body?: string;
    /**
     * The review action you want to perform. The review actions include: `APPROVE`, `REQUEST_CHANGES`, or `COMMENT`. When you leave this blank, the API returns _HTTP 422 (Unrecognizable entity)_ and sets the review action state to `PENDING`, which means you will need to re-submit the pull request review using a review action.
     */
    event: "APPROVE" | "REQUEST_CHANGES" | "COMMENT";
    /**
     * @deprecated "number" parameter renamed to "pull_number"
     */
    number: number;
  };
  export type PullsSubmitReviewParams = {
    owner: string;

    repo: string;

    pull_number: number;

    review_id: number;
    /**
     * The body text of the pull request review
     */
    body?: string;
    /**
     * The review action you want to perform. The review actions include: `APPROVE`, `REQUEST_CHANGES`, or `COMMENT`. When you leave this blank, the API returns _HTTP 422 (Unrecognizable entity)_ and sets the review action state to `PENDING`, which means you will need to re-submit the pull request review using a review action.
     */
    event: "APPROVE" | "REQUEST_CHANGES" | "COMMENT";
  };
  export type PullsDismissReviewParamsDeprecatedNumber = {
    owner: string;

    repo: string;

    review_id: number;
    /**
     * The message for the pull request review dismissal
     */
    message: string;
    /**
     * @deprecated "number" parameter renamed to "pull_number"
     */
    number: number;
  };
  export type PullsDismissReviewParams = {
    owner: string;

    repo: string;

    pull_number: number;

    review_id: number;
    /**
     * The message for the pull request review dismissal
     */
    message: string;
  };
  export type ReactionsListForCommitCommentParams = {
    owner: string;

    repo: string;

    comment_id: number;
    /**
     * Returns a single [reaction type](https://developer.github.com/v3/reactions/#reaction-types). Omit this parameter to list all reactions to a commit comment.
     */
    content?:
      | "+1"
      | "-1"
      | "laugh"
      | "confused"
      | "heart"
      | "hooray"
      | "rocket"
      | "eyes";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReactionsCreateForCommitCommentParams = {
    owner: string;

    repo: string;

    comment_id: number;
    /**
     * The [reaction type](https://developer.github.com/v3/reactions/#reaction-types) to add to the commit comment.
     */
    content:
      | "+1"
      | "-1"
      | "laugh"
      | "confused"
      | "heart"
      | "hooray"
      | "rocket"
      | "eyes";
  };
  export type ReactionsListForIssueParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * Returns a single [reaction type](https://developer.github.com/v3/reactions/#reaction-types). Omit this parameter to list all reactions to an issue.
     */
    content?:
      | "+1"
      | "-1"
      | "laugh"
      | "confused"
      | "heart"
      | "hooray"
      | "rocket"
      | "eyes";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
    /**
     * @deprecated "number" parameter renamed to "issue_number"
     */
    number: number;
  };
  export type ReactionsListForIssueParams = {
    owner: string;

    repo: string;

    issue_number: number;
    /**
     * Returns a single [reaction type](https://developer.github.com/v3/reactions/#reaction-types). Omit this parameter to list all reactions to an issue.
     */
    content?:
      | "+1"
      | "-1"
      | "laugh"
      | "confused"
      | "heart"
      | "hooray"
      | "rocket"
      | "eyes";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReactionsCreateForIssueParamsDeprecatedNumber = {
    owner: string;

    repo: string;
    /**
     * The [reaction type](https://developer.github.com/v3/reactions/#reaction-types) to add to the issue.
     */
    content:
      | "+1"
      | "-1"
      | "laugh"
      | "confused"
      | "heart"
      | "hooray"
      | "rocket"
      | "eyes";
    /**
     * @deprecated "number" parameter renamed to "issue_number"
     */
    number: number;
  };
  export type ReactionsCreateForIssueParams = {
    owner: string;

    repo: string;

    issue_number: number;
    /**
     * The [reaction type](https://developer.github.com/v3/reactions/#reaction-types) to add to the issue.
     */
    content:
      | "+1"
      | "-1"
      | "laugh"
      | "confused"
      | "heart"
      | "hooray"
      | "rocket"
      | "eyes";
  };
  export type ReactionsListForIssueCommentParams = {
    owner: string;

    repo: string;

    comment_id: number;
    /**
     * Returns a single [reaction type](https://developer.github.com/v3/reactions/#reaction-types). Omit this parameter to list all reactions to an issue comment.
     */
    content?:
      | "+1"
      | "-1"
      | "laugh"
      | "confused"
      | "heart"
      | "hooray"
      | "rocket"
      | "eyes";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReactionsCreateForIssueCommentParams = {
    owner: string;

    repo: string;

    comment_id: number;
    /**
     * The [reaction type](https://developer.github.com/v3/reactions/#reaction-types) to add to the issue comment.
     */
    content:
      | "+1"
      | "-1"
      | "laugh"
      | "confused"
      | "heart"
      | "hooray"
      | "rocket"
      | "eyes";
  };
  export type ReactionsListForPullRequestReviewCommentParams = {
    owner: string;

    repo: string;

    comment_id: number;
    /**
     * Returns a single [reaction type](https://developer.github.com/v3/reactions/#reaction-types). Omit this parameter to list all reactions to a pull request review comment.
     */
    content?:
      | "+1"
      | "-1"
      | "laugh"
      | "confused"
      | "heart"
      | "hooray"
      | "rocket"
      | "eyes";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReactionsCreateForPullRequestReviewCommentParams = {
    owner: string;

    repo: string;

    comment_id: number;
    /**
     * The [reaction type](https://developer.github.com/v3/reactions/#reaction-types) to add to the pull request review comment.
     */
    content:
      | "+1"
      | "-1"
      | "laugh"
      | "confused"
      | "heart"
      | "hooray"
      | "rocket"
      | "eyes";
  };
  export type ReactionsListForTeamDiscussionParams = {
    team_id: number;

    discussion_number: number;
    /**
     * Returns a single [reaction type](https://developer.github.com/v3/reactions/#reaction-types). Omit this parameter to list all reactions to a team discussion.
     */
    content?:
      | "+1"
      | "-1"
      | "laugh"
      | "confused"
      | "heart"
      | "hooray"
      | "rocket"
      | "eyes";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReactionsCreateForTeamDiscussionParams = {
    team_id: number;

    discussion_number: number;
    /**
     * The [reaction type](https://developer.github.com/v3/reactions/#reaction-types) to add to the team discussion.
     */
    content:
      | "+1"
      | "-1"
      | "laugh"
      | "confused"
      | "heart"
      | "hooray"
      | "rocket"
      | "eyes";
  };
  export type ReactionsListForTeamDiscussionCommentParams = {
    team_id: number;

    discussion_number: number;

    comment_number: number;
    /**
     * Returns a single [reaction type](https://developer.github.com/v3/reactions/#reaction-types). Omit this parameter to list all reactions to a team discussion comment.
     */
    content?:
      | "+1"
      | "-1"
      | "laugh"
      | "confused"
      | "heart"
      | "hooray"
      | "rocket"
      | "eyes";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReactionsCreateForTeamDiscussionCommentParams = {
    team_id: number;

    discussion_number: number;

    comment_number: number;
    /**
     * The [reaction type](https://developer.github.com/v3/reactions/#reaction-types) to add to the team discussion comment.
     */
    content:
      | "+1"
      | "-1"
      | "laugh"
      | "confused"
      | "heart"
      | "hooray"
      | "rocket"
      | "eyes";
  };
  export type ReactionsDeleteParams = {
    reaction_id: number;
  };
  export type ReposListParams = {
    /**
     * Can be one of `all`, `public`, or `private`.
     */
    visibility?: "all" | "public" | "private";
    /**
     * Comma-separated list of values. Can include:
     * \* `owner`: Repositories that are owned by the authenticated user.
     * \* `collaborator`: Repositories that the user has been added to as a collaborator.
     * \* `organization_member`: Repositories that the user has access to through being a member of an organization. This includes every repository on every team that the user is on.
     */
    affiliation?: string;
    /**
     * Can be one of `all`, `owner`, `public`, `private`, `member`. Default: `all`
     *
     * Will cause a `422` error if used in the same request as **visibility** or **affiliation**. Will cause a `422` error if used in the same request as **visibility** or **affiliation**.
     */
    type?: "all" | "owner" | "public" | "private" | "member";
    /**
     * Can be one of `created`, `updated`, `pushed`, `full_name`.
     */
    sort?: "created" | "updated" | "pushed" | "full_name";
    /**
     * Can be one of `asc` or `desc`.
     */
    direction?: "asc" | "desc";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposListForUserParams = {
    username: string;
    /**
     * Can be one of `all`, `owner`, `member`.
     */
    type?: "all" | "owner" | "member";
    /**
     * Can be one of `created`, `updated`, `pushed`, `full_name`.
     */
    sort?: "created" | "updated" | "pushed" | "full_name";
    /**
     * Can be one of `asc` or `desc`.
     */
    direction?: "asc" | "desc";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposListForOrgParams = {
    org: string;
    /**
     * Can be one of `all`, `public`, `private`, `forks`, `sources`, `member`.
     */
    type?: "all" | "public" | "private" | "forks" | "sources" | "member";
    /**
     * Can be one of `created`, `updated`, `pushed`, `full_name`.
     */
    sort?: "created" | "updated" | "pushed" | "full_name";
    /**
     * Can be one of `asc` or `desc`.
     */
    direction?: "asc" | "desc";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposListPublicParams = {
    /**
     * The integer ID of the last Repository that you've seen.
     */
    since?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposCreateForAuthenticatedUserParams = {
    /**
     * The name of the repository.
     */
    name: string;
    /**
     * A short description of the repository.
     */
    description?: string;
    /**
     * A URL with more information about the repository.
     */
    homepage?: string;
    /**
     * Either `true` to create a private repository or `false` to create a public one. Creating private repositories requires a paid GitHub account.
     */
    private?: boolean;
    /**
     * Either `true` to enable issues for this repository or `false` to disable them.
     */
    has_issues?: boolean;
    /**
     * Either `true` to enable projects for this repository or `false` to disable them. **Note:** If you're creating a repository in an organization that has disabled repository projects, the default is `false`, and if you pass `true`, the API returns an error.
     */
    has_projects?: boolean;
    /**
     * Either `true` to enable the wiki for this repository or `false` to disable it.
     */
    has_wiki?: boolean;
    /**
     * Either `true` to make this repo available as a template repository or `false` to prevent it.
     */
    is_template?: boolean;
    /**
     * The id of the team that will be granted access to this repository. This is only valid when creating a repository in an organization.
     */
    team_id?: number;
    /**
     * Pass `true` to create an initial commit with empty README.
     */
    auto_init?: boolean;
    /**
     * Desired language or platform [.gitignore template](https://github.com/github/gitignore) to apply. Use the name of the template without the extension. For example, "Haskell".
     */
    gitignore_template?: string;
    /**
     * Choose an [open source license template](https://choosealicense.com/) that best suits your needs, and then use the [license keyword](https://help.github.com/articles/licensing-a-repository/#searching-github-by-license-type) as the `license_template` string. For example, "mit" or "mpl-2.0".
     */
    license_template?: string;
    /**
     * Either `true` to allow squash-merging pull requests, or `false` to prevent squash-merging.
     */
    allow_squash_merge?: boolean;
    /**
     * Either `true` to allow merging pull requests with a merge commit, or `false` to prevent merging pull requests with merge commits.
     */
    allow_merge_commit?: boolean;
    /**
     * Either `true` to allow rebase-merging pull requests, or `false` to prevent rebase-merging.
     */
    allow_rebase_merge?: boolean;
  };
  export type ReposCreateInOrgParams = {
    org: string;
    /**
     * The name of the repository.
     */
    name: string;
    /**
     * A short description of the repository.
     */
    description?: string;
    /**
     * A URL with more information about the repository.
     */
    homepage?: string;
    /**
     * Either `true` to create a private repository or `false` to create a public one. Creating private repositories requires a paid GitHub account.
     */
    private?: boolean;
    /**
     * Either `true` to enable issues for this repository or `false` to disable them.
     */
    has_issues?: boolean;
    /**
     * Either `true` to enable projects for this repository or `false` to disable them. **Note:** If you're creating a repository in an organization that has disabled repository projects, the default is `false`, and if you pass `true`, the API returns an error.
     */
    has_projects?: boolean;
    /**
     * Either `true` to enable the wiki for this repository or `false` to disable it.
     */
    has_wiki?: boolean;
    /**
     * Either `true` to make this repo available as a template repository or `false` to prevent it.
     */
    is_template?: boolean;
    /**
     * The id of the team that will be granted access to this repository. This is only valid when creating a repository in an organization.
     */
    team_id?: number;
    /**
     * Pass `true` to create an initial commit with empty README.
     */
    auto_init?: boolean;
    /**
     * Desired language or platform [.gitignore template](https://github.com/github/gitignore) to apply. Use the name of the template without the extension. For example, "Haskell".
     */
    gitignore_template?: string;
    /**
     * Choose an [open source license template](https://choosealicense.com/) that best suits your needs, and then use the [license keyword](https://help.github.com/articles/licensing-a-repository/#searching-github-by-license-type) as the `license_template` string. For example, "mit" or "mpl-2.0".
     */
    license_template?: string;
    /**
     * Either `true` to allow squash-merging pull requests, or `false` to prevent squash-merging.
     */
    allow_squash_merge?: boolean;
    /**
     * Either `true` to allow merging pull requests with a merge commit, or `false` to prevent merging pull requests with merge commits.
     */
    allow_merge_commit?: boolean;
    /**
     * Either `true` to allow rebase-merging pull requests, or `false` to prevent rebase-merging.
     */
    allow_rebase_merge?: boolean;
  };
  export type ReposCreateUsingTemplateParams = {
    template_owner: string;

    template_repo: string;
    /**
     * The organization or person who will own the new repository. To create a new repository in an organization, the authenticated user must be a member of the specified organization.
     */
    owner?: string;
    /**
     * The name of the new repository.
     */
    name: string;
    /**
     * A short description of the new repository.
     */
    description?: string;
    /**
     * Either `true` to create a new private repository or `false` to create a new public one.
     */
    private?: boolean;
  };
  export type ReposGetParams = {
    owner: string;

    repo: string;
  };
  export type ReposUpdateParams = {
    owner: string;

    repo: string;
    /**
     * The name of the repository.
     */
    name?: string;
    /**
     * A short description of the repository.
     */
    description?: string;
    /**
     * A URL with more information about the repository.
     */
    homepage?: string;
    /**
     * Either `true` to make the repository private or `false` to make it public. Creating private repositories requires a paid GitHub account. Default: `false`.
     * **Note**: You will get a `422` error if the organization restricts [changing repository visibility](https://help.github.com/articles/repository-permission-levels-for-an-organization#changing-the-visibility-of-repositories) to organization owners and a non-owner tries to change the value of private. **Note**: You will get a `422` error if the organization restricts [changing repository visibility](https://help.github.com/articles/repository-permission-levels-for-an-organization#changing-the-visibility-of-repositories) to organization owners and a non-owner tries to change the value of private.
     */
    private?: boolean;
    /**
     * Either `true` to enable issues for this repository or `false` to disable them.
     */
    has_issues?: boolean;
    /**
     * Either `true` to enable projects for this repository or `false` to disable them. **Note:** If you're creating a repository in an organization that has disabled repository projects, the default is `false`, and if you pass `true`, the API returns an error.
     */
    has_projects?: boolean;
    /**
     * Either `true` to enable the wiki for this repository or `false` to disable it.
     */
    has_wiki?: boolean;
    /**
     * Either `true` to make this repo available as a template repository or `false` to prevent it.
     */
    is_template?: boolean;
    /**
     * Updates the default branch for this repository.
     */
    default_branch?: string;
    /**
     * Either `true` to allow squash-merging pull requests, or `false` to prevent squash-merging.
     */
    allow_squash_merge?: boolean;
    /**
     * Either `true` to allow merging pull requests with a merge commit, or `false` to prevent merging pull requests with merge commits.
     */
    allow_merge_commit?: boolean;
    /**
     * Either `true` to allow rebase-merging pull requests, or `false` to prevent rebase-merging.
     */
    allow_rebase_merge?: boolean;
    /**
     * `true` to archive this repository. **Note**: You cannot unarchive repositories through the API.
     */
    archived?: boolean;
  };
  export type ReposListTopicsParams = {
    owner: string;

    repo: string;
  };
  export type ReposReplaceTopicsParams = {
    owner: string;

    repo: string;
    /**
     * An array of topics to add to the repository. Pass one or more topics to _replace_ the set of existing topics. Send an empty array (`[]`) to clear all topics from the repository. **Note:** Topic `names` cannot contain uppercase letters.
     */
    names: string[];
  };
  export type ReposCheckVulnerabilityAlertsParams = {
    owner: string;

    repo: string;
  };
  export type ReposEnableVulnerabilityAlertsParams = {
    owner: string;

    repo: string;
  };
  export type ReposDisableVulnerabilityAlertsParams = {
    owner: string;

    repo: string;
  };
  export type ReposEnableAutomatedSecurityFixesParams = {
    owner: string;

    repo: string;
  };
  export type ReposDisableAutomatedSecurityFixesParams = {
    owner: string;

    repo: string;
  };
  export type ReposListContributorsParams = {
    owner: string;

    repo: string;
    /**
     * Set to `1` or `true` to include anonymous contributors in results.
     */
    anon?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposListLanguagesParams = {
    owner: string;

    repo: string;
  };
  export type ReposListTeamsParams = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposListTagsParams = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposDeleteParams = {
    owner: string;

    repo: string;
  };
  export type ReposTransferParams = {
    owner: string;

    repo: string;
    /**
     * **Required:** The username or organization name the repository will be transferred to.
     */
    new_owner?: string;
    /**
     * ID of the team or teams to add to the repository. Teams can only be added to organization-owned repositories.
     */
    team_ids?: number[];
  };
  export type ReposListBranchesParams = {
    owner: string;

    repo: string;
    /**
     * Setting to `true` returns only protected branches. When set to `false`, only unprotected branches are returned. Omitting this parameter returns all branches.
     */
    protected?: boolean;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposGetBranchParams = {
    owner: string;

    repo: string;

    branch: string;
  };
  export type ReposGetBranchProtectionParams = {
    owner: string;

    repo: string;

    branch: string;
  };
  export type ReposUpdateBranchProtectionParams = {
    owner: string;

    repo: string;

    branch: string;
    /**
     * Require status checks to pass before merging. Set to `null` to disable.
     */
    required_status_checks: ReposUpdateBranchProtectionParamsRequiredStatusChecks | null;
    /**
     * Enforce all configured restrictions for administrators. Set to `true` to enforce required status checks for repository administrators. Set to `null` to disable.
     */
    enforce_admins: boolean | null;
    /**
     * Require at least one approving review on a pull request, before merging. Set to `null` to disable.
     */
    required_pull_request_reviews: ReposUpdateBranchProtectionParamsRequiredPullRequestReviews | null;
    /**
     * Restrict who can push to this branch. Team and user `restrictions` are only available for organization-owned repositories. Set to `null` to disable.
     */
    restrictions: ReposUpdateBranchProtectionParamsRestrictions | null;
  };
  export type ReposRemoveBranchProtectionParams = {
    owner: string;

    repo: string;

    branch: string;
  };
  export type ReposGetProtectedBranchRequiredStatusChecksParams = {
    owner: string;

    repo: string;

    branch: string;
  };
  export type ReposUpdateProtectedBranchRequiredStatusChecksParams = {
    owner: string;

    repo: string;

    branch: string;
    /**
     * Require branches to be up to date before merging.
     */
    strict?: boolean;
    /**
     * The list of status checks to require in order to merge into this branch
     */
    contexts?: string[];
  };
  export type ReposRemoveProtectedBranchRequiredStatusChecksParams = {
    owner: string;

    repo: string;

    branch: string;
  };
  export type ReposListProtectedBranchRequiredStatusChecksContextsParams = {
    owner: string;

    repo: string;

    branch: string;
  };
  export type ReposReplaceProtectedBranchRequiredStatusChecksContextsParams = {
    owner: string;

    repo: string;

    branch: string;

    contexts: string[];
  };
  export type ReposAddProtectedBranchRequiredStatusChecksContextsParams = {
    owner: string;

    repo: string;

    branch: string;

    contexts: string[];
  };
  export type ReposRemoveProtectedBranchRequiredStatusChecksContextsParams = {
    owner: string;

    repo: string;

    branch: string;

    contexts: string[];
  };
  export type ReposGetProtectedBranchPullRequestReviewEnforcementParams = {
    owner: string;

    repo: string;

    branch: string;
  };
  export type ReposUpdateProtectedBranchPullRequestReviewEnforcementParams = {
    owner: string;

    repo: string;

    branch: string;
    /**
     * Specify which users and teams can dismiss pull request reviews. Pass an empty `dismissal_restrictions` object to disable. User and team `dismissal_restrictions` are only available for organization-owned repositories. Omit this parameter for personal repositories.
     */
    dismissal_restrictions?: ReposUpdateProtectedBranchPullRequestReviewEnforcementParamsDismissalRestrictions;
    /**
     * Set to `true` if you want to automatically dismiss approving reviews when someone pushes a new commit.
     */
    dismiss_stale_reviews?: boolean;
    /**
     * Blocks merging pull requests until [code owners](https://help.github.com/articles/about-code-owners/) have reviewed.
     */
    require_code_owner_reviews?: boolean;
    /**
     * Specifies the number of reviewers required to approve pull requests. Use a number between 1 and 6.
     */
    required_approving_review_count?: number;
  };
  export type ReposRemoveProtectedBranchPullRequestReviewEnforcementParams = {
    owner: string;

    repo: string;

    branch: string;
  };
  export type ReposGetProtectedBranchRequiredSignaturesParams = {
    owner: string;

    repo: string;

    branch: string;
  };
  export type ReposAddProtectedBranchRequiredSignaturesParams = {
    owner: string;

    repo: string;

    branch: string;
  };
  export type ReposRemoveProtectedBranchRequiredSignaturesParams = {
    owner: string;

    repo: string;

    branch: string;
  };
  export type ReposGetProtectedBranchAdminEnforcementParams = {
    owner: string;

    repo: string;

    branch: string;
  };
  export type ReposAddProtectedBranchAdminEnforcementParams = {
    owner: string;

    repo: string;

    branch: string;
  };
  export type ReposRemoveProtectedBranchAdminEnforcementParams = {
    owner: string;

    repo: string;

    branch: string;
  };
  export type ReposGetProtectedBranchRestrictionsParams = {
    owner: string;

    repo: string;

    branch: string;
  };
  export type ReposRemoveProtectedBranchRestrictionsParams = {
    owner: string;

    repo: string;

    branch: string;
  };
  export type ReposListProtectedBranchTeamRestrictionsParams = {
    owner: string;

    repo: string;

    branch: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposReplaceProtectedBranchTeamRestrictionsParams = {
    owner: string;

    repo: string;

    branch: string;

    teams: string[];
  };
  export type ReposAddProtectedBranchTeamRestrictionsParams = {
    owner: string;

    repo: string;

    branch: string;

    teams: string[];
  };
  export type ReposRemoveProtectedBranchTeamRestrictionsParams = {
    owner: string;

    repo: string;

    branch: string;

    teams: string[];
  };
  export type ReposListProtectedBranchUserRestrictionsParams = {
    owner: string;

    repo: string;

    branch: string;
  };
  export type ReposReplaceProtectedBranchUserRestrictionsParams = {
    owner: string;

    repo: string;

    branch: string;

    users: string[];
  };
  export type ReposAddProtectedBranchUserRestrictionsParams = {
    owner: string;

    repo: string;

    branch: string;

    users: string[];
  };
  export type ReposRemoveProtectedBranchUserRestrictionsParams = {
    owner: string;

    repo: string;

    branch: string;

    users: string[];
  };
  export type ReposListCollaboratorsParams = {
    owner: string;

    repo: string;
    /**
     * Filter collaborators returned by their affiliation. Can be one of:
     * \* `outside`: All outside collaborators of an organization-owned repository.
     * \* `direct`: All collaborators with permissions to an organization-owned repository, regardless of organization membership status.
     * \* `all`: All collaborators the authenticated user can see.
     */
    affiliation?: "outside" | "direct" | "all";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposCheckCollaboratorParams = {
    owner: string;

    repo: string;

    username: string;
  };
  export type ReposGetCollaboratorPermissionLevelParams = {
    owner: string;

    repo: string;

    username: string;
  };
  export type ReposAddCollaboratorParams = {
    owner: string;

    repo: string;

    username: string;
    /**
     * The permission to grant the collaborator. **Only valid on organization-owned repositories.** Can be one of:
     * \* `pull` - can pull, but not push to or administer this repository.
     * \* `push` - can pull and push, but not administer this repository.
     * \* `admin` - can pull, push and administer this repository.
     */
    permission?: "pull" | "push" | "admin";
  };
  export type ReposRemoveCollaboratorParams = {
    owner: string;

    repo: string;

    username: string;
  };
  export type ReposListCommitCommentsParams = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposListCommentsForCommitParamsDeprecatedRef = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
    /**
     * @deprecated "ref" parameter renamed to "commit_sha"
     */
    ref: string;
  };
  export type ReposListCommentsForCommitParams = {
    owner: string;

    repo: string;

    commit_sha: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposCreateCommitCommentParamsDeprecatedSha = {
    owner: string;

    repo: string;
    /**
     * The contents of the comment.
     */
    body: string;
    /**
     * Relative path of the file to comment on.
     */
    path?: string;
    /**
     * Line index in the diff to comment on.
     */
    position?: number;
    /**
     * **Deprecated**. Use **position** parameter instead. Line number in the file to comment on.
     */
    line?: number;
    /**
     * @deprecated "sha" parameter renamed to "commit_sha"
     */
    sha: string;
  };
  export type ReposCreateCommitCommentParams = {
    owner: string;

    repo: string;

    commit_sha: string;
    /**
     * The contents of the comment.
     */
    body: string;
    /**
     * Relative path of the file to comment on.
     */
    path?: string;
    /**
     * Line index in the diff to comment on.
     */
    position?: number;
    /**
     * **Deprecated**. Use **position** parameter instead. Line number in the file to comment on.
     */
    line?: number;
  };
  export type ReposGetCommitCommentParams = {
    owner: string;

    repo: string;

    comment_id: number;
  };
  export type ReposUpdateCommitCommentParams = {
    owner: string;

    repo: string;

    comment_id: number;
    /**
     * The contents of the comment
     */
    body: string;
  };
  export type ReposDeleteCommitCommentParams = {
    owner: string;

    repo: string;

    comment_id: number;
  };
  export type ReposListCommitsParams = {
    owner: string;

    repo: string;
    /**
     * SHA or branch to start listing commits from.
     */
    sha?: string;
    /**
     * Only commits containing this file path will be returned.
     */
    path?: string;
    /**
     * GitHub login or email address by which to filter by commit author.
     */
    author?: string;
    /**
     * Only commits after this date will be returned. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    since?: string;
    /**
     * Only commits before this date will be returned. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
     */
    until?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposGetCommitParamsDeprecatedCommitSha = {
    owner: string;

    repo: string;
    /**
     * @deprecated "commit_sha" parameter renamed to "ref"
     */
    commit_sha: string;
  };
  export type ReposGetCommitParamsDeprecatedSha = {
    owner: string;

    repo: string;

    ref: string;
    /**
     * @deprecated "sha" parameter renamed to "ref"
     */
    sha?: ReposGetCommitParamsDeprecatedSha;
  };
  export type ReposGetCommitParams = {
    owner: string;

    repo: string;

    ref: string;
  };
  export type ReposGetCommitRefShaParams = {
    owner: string;

    repo: string;

    ref: string;
  };
  export type ReposCompareCommitsParams = {
    owner: string;

    repo: string;

    base: string;

    head: string;
  };
  export type ReposListBranchesForHeadCommitParams = {
    owner: string;

    repo: string;

    commit_sha: string;
  };
  export type ReposListPullRequestsAssociatedWithCommitParams = {
    owner: string;

    repo: string;

    commit_sha: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposRetrieveCommunityProfileMetricsParams = {
    owner: string;

    repo: string;
  };
  export type ReposGetReadmeParams = {
    owner: string;

    repo: string;
    /**
     * The name of the commit/branch/tag.
     */
    ref?: string;
  };
  export type ReposGetContentsParams = {
    owner: string;

    repo: string;

    path: string;
    /**
     * The name of the commit/branch/tag.
     */
    ref?: string;
  };
  export type ReposCreateOrUpdateFileParams = {
    owner: string;

    repo: string;

    path: string;
    /**
     * The commit message.
     */
    message: string;
    /**
     * The new file content, using Base64 encoding.
     */
    content: string;
    /**
     * **Required if you are updating a file**. The blob SHA of the file being replaced.
     */
    sha?: string;
    /**
     * The branch name.
     */
    branch?: string;
    /**
     * The person that committed the file.
     */
    committer?: ReposCreateOrUpdateFileParamsCommitter;
    /**
     * The author of the file.
     */
    author?: ReposCreateOrUpdateFileParamsAuthor;
  };
  export type ReposCreateFileParams = {
    owner: string;

    repo: string;

    path: string;
    /**
     * The commit message.
     */
    message: string;
    /**
     * The new file content, using Base64 encoding.
     */
    content: string;
    /**
     * **Required if you are updating a file**. The blob SHA of the file being replaced.
     */
    sha?: string;
    /**
     * The branch name.
     */
    branch?: string;
    /**
     * The person that committed the file.
     */
    committer?: ReposCreateFileParamsCommitter;
    /**
     * The author of the file.
     */
    author?: ReposCreateFileParamsAuthor;
  };
  export type ReposUpdateFileParams = {
    owner: string;

    repo: string;

    path: string;
    /**
     * The commit message.
     */
    message: string;
    /**
     * The new file content, using Base64 encoding.
     */
    content: string;
    /**
     * **Required if you are updating a file**. The blob SHA of the file being replaced.
     */
    sha?: string;
    /**
     * The branch name.
     */
    branch?: string;
    /**
     * The person that committed the file.
     */
    committer?: ReposUpdateFileParamsCommitter;
    /**
     * The author of the file.
     */
    author?: ReposUpdateFileParamsAuthor;
  };
  export type ReposDeleteFileParams = {
    owner: string;

    repo: string;

    path: string;
    /**
     * The commit message.
     */
    message: string;
    /**
     * The blob SHA of the file being replaced.
     */
    sha: string;
    /**
     * The branch name.
     */
    branch?: string;
    /**
     * object containing information about the committer.
     */
    committer?: ReposDeleteFileParamsCommitter;
    /**
     * object containing information about the author.
     */
    author?: ReposDeleteFileParamsAuthor;
  };
  export type ReposGetArchiveLinkParams = {
    owner: string;

    repo: string;

    archive_format: string;

    ref: string;
  };
  export type ReposListDeploymentsParams = {
    owner: string;

    repo: string;
    /**
     * The SHA recorded at creation time.
     */
    sha?: string;
    /**
     * The name of the ref. This can be a branch, tag, or SHA.
     */
    ref?: string;
    /**
     * The name of the task for the deployment (e.g., `deploy` or `deploy:migrations`).
     */
    task?: string;
    /**
     * The name of the environment that was deployed to (e.g., `staging` or `production`).
     */
    environment?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposGetDeploymentParams = {
    owner: string;

    repo: string;

    deployment_id: number;
  };
  export type ReposCreateDeploymentParams = {
    owner: string;

    repo: string;
    /**
     * The ref to deploy. This can be a branch, tag, or SHA.
     */
    ref: string;
    /**
     * Specifies a task to execute (e.g., `deploy` or `deploy:migrations`).
     */
    task?: string;
    /**
     * Attempts to automatically merge the default branch into the requested ref, if it's behind the default branch.
     */
    auto_merge?: boolean;
    /**
     * The [status](https://developer.github.com/v3/repos/statuses/) contexts to verify against commit status checks. If you omit this parameter, GitHub verifies all unique contexts before creating a deployment. To bypass checking entirely, pass an empty array. Defaults to all unique contexts.
     */
    required_contexts?: string[];
    /**
     * JSON payload with extra information about the deployment.
     */
    payload?: string;
    /**
     * Name for the target deployment environment (e.g., `production`, `staging`, `qa`).
     */
    environment?: string;
    /**
     * Short description of the deployment.
     */
    description?: string;
    /**
     * Specifies if the given environment is specific to the deployment and will no longer exist at some point in the future. Default: `false`
     * **Note:** This parameter requires you to use the [`application/vnd.github.ant-man-preview+json`](https://developer.github.com/v3/previews/#enhanced-deployments) custom media type. **Note:** This parameter requires you to use the [`application/vnd.github.ant-man-preview+json`](https://developer.github.com/v3/previews/#enhanced-deployments) custom media type.
     */
    transient_environment?: boolean;
    /**
     * Specifies if the given environment is one that end-users directly interact with. Default: `true` when `environment` is `production` and `false` otherwise.
     * **Note:** This parameter requires you to use the [`application/vnd.github.ant-man-preview+json`](https://developer.github.com/v3/previews/#enhanced-deployments) custom media type.
     */
    production_environment?: boolean;
  };
  export type ReposListDeploymentStatusesParams = {
    owner: string;

    repo: string;

    deployment_id: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposGetDeploymentStatusParams = {
    owner: string;

    repo: string;

    deployment_id: number;

    status_id: number;
  };
  export type ReposCreateDeploymentStatusParams = {
    owner: string;

    repo: string;

    deployment_id: number;
    /**
     * The state of the status. Can be one of `error`, `failure`, `inactive`, `in_progress`, `queued` `pending`, or `success`. **Note:** To use the `inactive` state, you must provide the [`application/vnd.github.ant-man-preview+json`](https://developer.github.com/v3/previews/#enhanced-deployments) custom media type. To use the `in_progress` and `queued` states, you must provide the [`application/vnd.github.flash-preview+json`](https://developer.github.com/v3/previews/#deployment-statuses) custom media type.
     */
    state:
      | "error"
      | "failure"
      | "inactive"
      | "in_progress"
      | "queued"
      | "pending"
      | "success";
    /**
     * The target URL to associate with this status. This URL should contain output to keep the user updated while the task is running or serve as historical information for what happened in the deployment. **Note:** It's recommended to use the `log_url` parameter, which replaces `target_url`.
     */
    target_url?: string;
    /**
     * The full URL of the deployment's output. This parameter replaces `target_url`. We will continue to accept `target_url` to support legacy uses, but we recommend replacing `target_url` with `log_url`. Setting `log_url` will automatically set `target_url` to the same value. Default: `""`
     * **Note:** This parameter requires you to use the [`application/vnd.github.ant-man-preview+json`](https://developer.github.com/v3/previews/#enhanced-deployments) custom media type. **Note:** This parameter requires you to use the [`application/vnd.github.ant-man-preview+json`](https://developer.github.com/v3/previews/#enhanced-deployments) custom media type.
     */
    log_url?: string;
    /**
     * A short description of the status. The maximum description length is 140 characters.
     */
    description?: string;
    /**
     * Name for the target deployment environment, which can be changed when setting a deploy status. For example, `production`, `staging`, or `qa`. **Note:** This parameter requires you to use the [`application/vnd.github.flash-preview+json`](https://developer.github.com/v3/previews/#deployment-statuses) custom media type.
     */
    environment?: "production" | "staging" | "qa";
    /**
     * Sets the URL for accessing your environment. Default: `""`
     * **Note:** This parameter requires you to use the [`application/vnd.github.ant-man-preview+json`](https://developer.github.com/v3/previews/#enhanced-deployments) custom media type. **Note:** This parameter requires you to use the [`application/vnd.github.ant-man-preview+json`](https://developer.github.com/v3/previews/#enhanced-deployments) custom media type.
     */
    environment_url?: string;
    /**
     * Adds a new `inactive` status to all prior non-transient, non-production environment deployments with the same repository and `environment` name as the created status's deployment. An `inactive` status is only added to deployments that had a `success` state. Default: `true`
     * **Note:** To add an `inactive` status to `production` environments, you must use the [`application/vnd.github.flash-preview+json`](https://developer.github.com/v3/previews/#deployment-statuses) custom media type.
     * **Note:** This parameter requires you to use the [`application/vnd.github.ant-man-preview+json`](https://developer.github.com/v3/previews/#enhanced-deployments) custom media type. **Note:** To add an `inactive` status to `production` environments, you must use the [`application/vnd.github.flash-preview+json`](https://developer.github.com/v3/previews/#deployment-statuses) custom media type.
     */
    auto_inactive?: boolean;
  };
  export type ReposListDownloadsParams = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposGetDownloadParams = {
    owner: string;

    repo: string;

    download_id: number;
  };
  export type ReposDeleteDownloadParams = {
    owner: string;

    repo: string;

    download_id: number;
  };
  export type ReposListForksParams = {
    owner: string;

    repo: string;
    /**
     * The sort order. Can be either `newest`, `oldest`, or `stargazers`.
     */
    sort?: "newest" | "oldest" | "stargazers";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposCreateForkParams = {
    owner: string;

    repo: string;
    /**
     * Optional parameter to specify the organization name if forking into an organization.
     */
    organization?: string;
  };
  export type ReposListHooksParams = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposGetHookParams = {
    owner: string;

    repo: string;

    hook_id: number;
  };
  export type ReposCreateHookParams = {
    owner: string;

    repo: string;
    /**
     * Use `web` to create a webhook. This parameter only accepts the value `web`.
     */
    name?: string;
    /**
     * Key/value pairs to provide settings for this webhook. [These are defined below](https://developer.github.com/v3/repos/hooks/#create-hook-config-params).
     */
    config: ReposCreateHookParamsConfig;
    /**
     * Determines what [events](https://developer.github.com/v3/activity/events/types/) the hook is triggered for.
     */
    events?: string[];
    /**
     * Determines if notifications are sent when the webhook is triggered. Set to `true` to send notifications.
     */
    active?: boolean;
  };
  export type ReposUpdateHookParams = {
    owner: string;

    repo: string;

    hook_id: number;
    /**
     * Key/value pairs to provide settings for this webhook. [These are defined below](https://developer.github.com/v3/repos/hooks/#create-hook-config-params).
     */
    config?: ReposUpdateHookParamsConfig;
    /**
     * Determines what [events](https://developer.github.com/v3/activity/events/types/) the hook is triggered for. This replaces the entire array of events.
     */
    events?: string[];
    /**
     * Determines a list of events to be added to the list of events that the Hook triggers for.
     */
    add_events?: string[];
    /**
     * Determines a list of events to be removed from the list of events that the Hook triggers for.
     */
    remove_events?: string[];
    /**
     * Determines if notifications are sent when the webhook is triggered. Set to `true` to send notifications.
     */
    active?: boolean;
  };
  export type ReposTestPushHookParams = {
    owner: string;

    repo: string;

    hook_id: number;
  };
  export type ReposPingHookParams = {
    owner: string;

    repo: string;

    hook_id: number;
  };
  export type ReposDeleteHookParams = {
    owner: string;

    repo: string;

    hook_id: number;
  };
  export type ReposListInvitationsParams = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposDeleteInvitationParams = {
    owner: string;

    repo: string;

    invitation_id: number;
  };
  export type ReposUpdateInvitationParams = {
    owner: string;

    repo: string;

    invitation_id: number;
    /**
     * The permissions that the associated user will have on the repository. Valid values are `read`, `write`, and `admin`.
     */
    permissions?: "read" | "write" | "admin";
  };
  export type ReposListInvitationsForAuthenticatedUserParams = {
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposAcceptInvitationParams = {
    invitation_id: number;
  };
  export type ReposDeclineInvitationParams = {
    invitation_id: number;
  };
  export type ReposListDeployKeysParams = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposGetDeployKeyParams = {
    owner: string;

    repo: string;

    key_id: number;
  };
  export type ReposAddDeployKeyParams = {
    owner: string;

    repo: string;
    /**
     * A name for the key.
     */
    title?: string;
    /**
     * The contents of the key.
     */
    key: string;
    /**
     * If `true`, the key will only be able to read repository contents. Otherwise, the key will be able to read and write.
     *
     * Deploy keys with write access can perform the same actions as an organization member with admin access, or a collaborator on a personal repository. For more information, see "[Repository permission levels for an organization](https://help.github.com/articles/repository-permission-levels-for-an-organization/)" and "[Permission levels for a user account repository](https://help.github.com/articles/permission-levels-for-a-user-account-repository/)."
     */
    read_only?: boolean;
  };
  export type ReposRemoveDeployKeyParams = {
    owner: string;

    repo: string;

    key_id: number;
  };
  export type ReposMergeParams = {
    owner: string;

    repo: string;
    /**
     * The name of the base branch that the head will be merged into.
     */
    base: string;
    /**
     * The head to merge. This can be a branch name or a commit SHA1.
     */
    head: string;
    /**
     * Commit message to use for the merge commit. If omitted, a default message will be used.
     */
    commit_message?: string;
  };
  export type ReposGetPagesParams = {
    owner: string;

    repo: string;
  };
  export type ReposEnablePagesSiteParams = {
    owner: string;

    repo: string;

    source?: ReposEnablePagesSiteParamsSource;
  };
  export type ReposDisablePagesSiteParams = {
    owner: string;

    repo: string;
  };
  export type ReposUpdateInformationAboutPagesSiteParams = {
    owner: string;

    repo: string;
    /**
     * Specify a custom domain for the repository. Sending a `null` value will remove the custom domain. For more about custom domains, see "[Using a custom domain with GitHub Pages](https://help.github.com/articles/using-a-custom-domain-with-github-pages/)."
     */
    cname?: string;
    /**
     * Update the source for the repository. Must include the branch name, and may optionally specify the subdirectory `/docs`. Possible values are `"gh-pages"`, `"master"`, and `"master /docs"`.
     */
    source?: '"gh-pages"' | '"master"' | '"master /docs"';
  };
  export type ReposRequestPageBuildParams = {
    owner: string;

    repo: string;
  };
  export type ReposListPagesBuildsParams = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposGetLatestPagesBuildParams = {
    owner: string;

    repo: string;
  };
  export type ReposGetPagesBuildParams = {
    owner: string;

    repo: string;

    build_id: number;
  };
  export type ReposListReleasesParams = {
    owner: string;

    repo: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposGetReleaseParams = {
    owner: string;

    repo: string;

    release_id: number;
  };
  export type ReposGetLatestReleaseParams = {
    owner: string;

    repo: string;
  };
  export type ReposGetReleaseByTagParams = {
    owner: string;

    repo: string;

    tag: string;
  };
  export type ReposCreateReleaseParams = {
    owner: string;

    repo: string;
    /**
     * The name of the tag.
     */
    tag_name: string;
    /**
     * Specifies the commitish value that determines where the Git tag is created from. Can be any branch or commit SHA. Unused if the Git tag already exists.
     */
    target_commitish?: string;
    /**
     * The name of the release.
     */
    name?: string;
    /**
     * Text describing the contents of the tag.
     */
    body?: string;
    /**
     * `true` to create a draft (unpublished) release, `false` to create a published one.
     */
    draft?: boolean;
    /**
     * `true` to identify the release as a prerelease. `false` to identify the release as a full release.
     */
    prerelease?: boolean;
  };
  export type ReposUpdateReleaseParams = {
    owner: string;

    repo: string;

    release_id: number;
    /**
     * The name of the tag.
     */
    tag_name?: string;
    /**
     * Specifies the commitish value that determines where the Git tag is created from. Can be any branch or commit SHA. Unused if the Git tag already exists.
     */
    target_commitish?: string;
    /**
     * The name of the release.
     */
    name?: string;
    /**
     * Text describing the contents of the tag.
     */
    body?: string;
    /**
     * `true` makes the release a draft, and `false` publishes the release.
     */
    draft?: boolean;
    /**
     * `true` to identify the release as a prerelease, `false` to identify the release as a full release.
     */
    prerelease?: boolean;
  };
  export type ReposDeleteReleaseParams = {
    owner: string;

    repo: string;

    release_id: number;
  };
  export type ReposListAssetsForReleaseParams = {
    owner: string;

    repo: string;

    release_id: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposUploadReleaseAssetParams = {
    url: string;
    /**
     * Request headers containing `content-type` and `content-length`
     */
    headers: ReposUploadReleaseAssetParamsHeaders;
    /**
     * The file name of the asset. This should be set in a URI query parameter.
     */
    name: string;
    /**
     * An alternate short description of the asset. Used in place of the filename. This should be set in a URI query parameter.
     */
    label?: string;

    file: string | object;
  };
  export type ReposGetReleaseAssetParams = {
    owner: string;

    repo: string;

    asset_id: number;
  };
  export type ReposUpdateReleaseAssetParams = {
    owner: string;

    repo: string;

    asset_id: number;
    /**
     * The file name of the asset.
     */
    name?: string;
    /**
     * An alternate short description of the asset. Used in place of the filename.
     */
    label?: string;
  };
  export type ReposDeleteReleaseAssetParams = {
    owner: string;

    repo: string;

    asset_id: number;
  };
  export type ReposGetContributorsStatsParams = {
    owner: string;

    repo: string;
  };
  export type ReposGetCommitActivityStatsParams = {
    owner: string;

    repo: string;
  };
  export type ReposGetCodeFrequencyStatsParams = {
    owner: string;

    repo: string;
  };
  export type ReposGetParticipationStatsParams = {
    owner: string;

    repo: string;
  };
  export type ReposGetPunchCardStatsParams = {
    owner: string;

    repo: string;
  };
  export type ReposCreateStatusParams = {
    owner: string;

    repo: string;

    sha: string;
    /**
     * The state of the status. Can be one of `error`, `failure`, `pending`, or `success`.
     */
    state: "error" | "failure" | "pending" | "success";
    /**
     * The target URL to associate with this status. This URL will be linked from the GitHub UI to allow users to easily see the source of the status.
     * For example, if your continuous integration system is posting build status, you would want to provide the deep link for the build output for this specific SHA:
     * `http://ci.example.com/user/repo/build/sha`
     */
    target_url?: string;
    /**
     * A short description of the status.
     */
    description?: string;
    /**
     * A string label to differentiate this status from the status of other systems.
     */
    context?: string;
  };
  export type ReposListStatusesForRefParams = {
    owner: string;

    repo: string;

    ref: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type ReposGetCombinedStatusForRefParams = {
    owner: string;

    repo: string;

    ref: string;
  };
  export type ReposGetTopReferrersParams = {
    owner: string;

    repo: string;
  };
  export type ReposGetTopPathsParams = {
    owner: string;

    repo: string;
  };
  export type ReposGetViewsParams = {
    owner: string;

    repo: string;
    /**
     * Must be one of: `day`, `week`.
     */
    per?: "day" | "week";
  };
  export type ReposGetClonesParams = {
    owner: string;

    repo: string;
    /**
     * Must be one of: `day`, `week`.
     */
    per?: "day" | "week";
  };
  export type SearchReposParams = {
    /**
     * The query contains one or more search keywords and qualifiers. Qualifiers allow you to limit your search to specific areas of GitHub. The REST API supports the same qualifiers as GitHub.com. To learn more about the format of the query, see [Constructing a search query](https://developer.github.com/v3/search/#constructing-a-search-query). See "[Searching for repositories](https://help.github.com/articles/searching-for-repositories/)" for a detailed list of qualifiers.
     */
    q: string;
    /**
     * Sorts the results of your query by number of `stars`, `forks`, or `help-wanted-issues` or how recently the items were `updated`.
     */
    sort?: "stars" | "forks" | "help-wanted-issues" | "updated";
    /**
     * Determines whether the first search result returned is the highest number of matches (`desc`) or lowest number of matches (`asc`). This parameter is ignored unless you provide `sort`.
     */
    order?: "desc" | "asc";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type SearchCommitsParams = {
    /**
     * The query contains one or more search keywords and qualifiers. Qualifiers allow you to limit your search to specific areas of GitHub. The REST API supports the same qualifiers as GitHub.com. To learn more about the format of the query, see [Constructing a search query](https://developer.github.com/v3/search/#constructing-a-search-query). See "[Searching commits](https://help.github.com/articles/searching-commits/)" for a detailed list of qualifiers.
     */
    q: string;
    /**
     * Sorts the results of your query by `author-date` or `committer-date`.
     */
    sort?: "author-date" | "committer-date";
    /**
     * Determines whether the first search result returned is the highest number of matches (`desc`) or lowest number of matches (`asc`). This parameter is ignored unless you provide `sort`.
     */
    order?: "desc" | "asc";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type SearchCodeParams = {
    /**
     * The query contains one or more search keywords and qualifiers. Qualifiers allow you to limit your search to specific areas of GitHub. The REST API supports the same qualifiers as GitHub.com. To learn more about the format of the query, see [Constructing a search query](https://developer.github.com/v3/search/#constructing-a-search-query). See "[Searching code](https://help.github.com/articles/searching-code/)" for a detailed list of qualifiers.
     */
    q: string;
    /**
     * Sorts the results of your query. Can only be `indexed`, which indicates how recently a file has been indexed by the GitHub search infrastructure.
     */
    sort?: "indexed";
    /**
     * Determines whether the first search result returned is the highest number of matches (`desc`) or lowest number of matches (`asc`). This parameter is ignored unless you provide `sort`.
     */
    order?: "desc" | "asc";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type SearchIssuesAndPullRequestsParams = {
    /**
     * The query contains one or more search keywords and qualifiers. Qualifiers allow you to limit your search to specific areas of GitHub. The REST API supports the same qualifiers as GitHub.com. To learn more about the format of the query, see [Constructing a search query](https://developer.github.com/v3/search/#constructing-a-search-query). See "[Searching issues and pull requests](https://help.github.com/articles/searching-issues-and-pull-requests/)" for a detailed list of qualifiers.
     */
    q: string;
    /**
     * Sorts the results of your query by the number of `comments`, `reactions`, `reactions-+1`, `reactions--1`, `reactions-smile`, `reactions-thinking_face`, `reactions-heart`, `reactions-tada`, or `interactions`. You can also sort results by how recently the items were `created` or `updated`,
     */
    sort?:
      | "comments"
      | "reactions"
      | "reactions-+1"
      | "reactions--1"
      | "reactions-smile"
      | "reactions-thinking_face"
      | "reactions-heart"
      | "reactions-tada"
      | "interactions"
      | "created"
      | "updated";
    /**
     * Determines whether the first search result returned is the highest number of matches (`desc`) or lowest number of matches (`asc`). This parameter is ignored unless you provide `sort`.
     */
    order?: "desc" | "asc";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type SearchIssuesParams = {
    /**
     * The query contains one or more search keywords and qualifiers. Qualifiers allow you to limit your search to specific areas of GitHub. The REST API supports the same qualifiers as GitHub.com. To learn more about the format of the query, see [Constructing a search query](https://developer.github.com/v3/search/#constructing-a-search-query). See "[Searching issues and pull requests](https://help.github.com/articles/searching-issues-and-pull-requests/)" for a detailed list of qualifiers.
     */
    q: string;
    /**
     * Sorts the results of your query by the number of `comments`, `reactions`, `reactions-+1`, `reactions--1`, `reactions-smile`, `reactions-thinking_face`, `reactions-heart`, `reactions-tada`, or `interactions`. You can also sort results by how recently the items were `created` or `updated`,
     */
    sort?:
      | "comments"
      | "reactions"
      | "reactions-+1"
      | "reactions--1"
      | "reactions-smile"
      | "reactions-thinking_face"
      | "reactions-heart"
      | "reactions-tada"
      | "interactions"
      | "created"
      | "updated";
    /**
     * Determines whether the first search result returned is the highest number of matches (`desc`) or lowest number of matches (`asc`). This parameter is ignored unless you provide `sort`.
     */
    order?: "desc" | "asc";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type SearchUsersParams = {
    /**
     * The query contains one or more search keywords and qualifiers. Qualifiers allow you to limit your search to specific areas of GitHub. The REST API supports the same qualifiers as GitHub.com. To learn more about the format of the query, see [Constructing a search query](https://developer.github.com/v3/search/#constructing-a-search-query). See "[Searching users](https://help.github.com/articles/searching-users/)" for a detailed list of qualifiers.
     */
    q: string;
    /**
     * Sorts the results of your query by number of `followers` or `repositories`, or when the person `joined` GitHub.
     */
    sort?: "followers" | "repositories" | "joined";
    /**
     * Determines whether the first search result returned is the highest number of matches (`desc`) or lowest number of matches (`asc`). This parameter is ignored unless you provide `sort`.
     */
    order?: "desc" | "asc";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type SearchTopicsParams = {
    /**
     * The query contains one or more search keywords and qualifiers. Qualifiers allow you to limit your search to specific areas of GitHub. The REST API supports the same qualifiers as GitHub.com. To learn more about the format of the query, see [Constructing a search query](https://developer.github.com/v3/search/#constructing-a-search-query).
     */
    q: string;
  };
  export type SearchLabelsParams = {
    /**
     * The id of the repository.
     */
    repository_id: number;
    /**
     * The search keywords. This endpoint does not accept qualifiers in the query. To learn more about the format of the query, see [Constructing a search query](https://developer.github.com/v3/search/#constructing-a-search-query).
     */
    q: string;
    /**
     * Sorts the results of your query by when the label was `created` or `updated`.
     */
    sort?: "created" | "updated";
    /**
     * Determines whether the first search result returned is the highest number of matches (`desc`) or lowest number of matches (`asc`). This parameter is ignored unless you provide `sort`.
     */
    order?: "desc" | "asc";
  };
  export type TeamsListParams = {
    org: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type TeamsGetParams = {
    team_id: number;
  };
  export type TeamsGetByNameParams = {
    org: string;

    team_slug: string;
  };
  export type TeamsCreateParams = {
    org: string;
    /**
     * The name of the team.
     */
    name: string;
    /**
     * The description of the team.
     */
    description?: string;
    /**
     * The logins of organization members to add as maintainers of the team.
     */
    maintainers?: string[];
    /**
     * The full name (e.g., "organization-name/repository-name") of repositories to add the team to.
     */
    repo_names?: string[];
    /**
     * The level of privacy this team should have. The options are:
     * **For a non-nested team:**
     * \* `secret` - only visible to organization owners and members of this team.
     * \* `closed` - visible to all members of this organization.
     * Default: `secret`
     * **For a parent or child team:**
     * \* `closed` - visible to all members of this organization.
     * Default for child team: `closed`
     * **Note**: You must pass the `hellcat-preview` media type to set privacy default to `closed` for child teams. **For a parent or child team:**
     */
    privacy?: "secret" | "closed";
    /**
     * **Deprecated**. The permission that new repositories will be added to the team with when none is specified. Can be one of:
     * \* `pull` - team members can pull, but not push to or administer newly-added repositories.
     * \* `push` - team members can pull and push, but not administer newly-added repositories.
     * \* `admin` - team members can pull, push and administer newly-added repositories.
     */
    permission?: "pull" | "push" | "admin";
    /**
     * The ID of a team to set as the parent team. **Note**: You must pass the `hellcat-preview` media type to use this parameter.
     */
    parent_team_id?: number;
  };
  export type TeamsUpdateParams = {
    team_id: number;
    /**
     * The name of the team.
     */
    name: string;
    /**
     * The description of the team.
     */
    description?: string;
    /**
     * The level of privacy this team should have. Editing teams without specifying this parameter leaves `privacy` intact. The options are:
     * **For a non-nested team:**
     * \* `secret` - only visible to organization owners and members of this team.
     * \* `closed` - visible to all members of this organization.
     * **For a parent or child team:**
     * \* `closed` - visible to all members of this organization.
     */
    privacy?: string;
    /**
     * **Deprecated**. The permission that new repositories will be added to the team with when none is specified. Can be one of:
     * \* `pull` - team members can pull, but not push to or administer newly-added repositories.
     * \* `push` - team members can pull and push, but not administer newly-added repositories.
     * \* `admin` - team members can pull, push and administer newly-added repositories.
     */
    permission?: "pull" | "push" | "admin";
    /**
     * The ID of a team to set as the parent team. **Note**: You must pass the `hellcat-preview` media type to use this parameter.
     */
    parent_team_id?: number;
  };
  export type TeamsDeleteParams = {
    team_id: number;
  };
  export type TeamsListChildParams = {
    team_id: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type TeamsListReposParams = {
    team_id: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type TeamsCheckManagesRepoParams = {
    team_id: number;

    owner: string;

    repo: string;
  };
  export type TeamsAddOrUpdateRepoParams = {
    team_id: number;

    owner: string;

    repo: string;
    /**
     * The permission to grant the team on this repository. Can be one of:
     * \* `pull` - team members can pull, but not push to or administer this repository.
     * \* `push` - team members can pull and push, but not administer this repository.
     * \* `admin` - team members can pull, push and administer this repository.
     *
     * If no permission is specified, the team's `permission` attribute will be used to determine what permission to grant the team on this repository.
     * **Note**: If you pass the `hellcat-preview` media type, you can promote—but not demote—a `permission` attribute inherited through a parent team.
     */
    permission?: "pull" | "push" | "admin";
  };
  export type TeamsRemoveRepoParams = {
    team_id: number;

    owner: string;

    repo: string;
  };
  export type TeamsListForAuthenticatedUserParams = {
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type TeamsListProjectsParams = {
    team_id: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type TeamsReviewProjectParams = {
    team_id: number;

    project_id: number;
  };
  export type TeamsAddOrUpdateProjectParams = {
    team_id: number;

    project_id: number;
    /**
     * The permission to grant to the team for this project. Can be one of:
     * \* `read` - team members can read, but not write to or administer this project.
     * \* `write` - team members can read and write, but not administer this project.
     * \* `admin` - team members can read, write and administer this project.
     * Default: the team's `permission` attribute will be used to determine what permission to grant the team on this project. Note that, if you choose not to pass any parameters, you'll need to set `Content-Length` to zero when calling out to this endpoint. For more information, see "[HTTP verbs](https://developer.github.com/v3/#http-verbs)."
     * **Note**: If you pass the `hellcat-preview` media type, you can promote—but not demote—a `permission` attribute inherited from a parent team.
     */
    permission?: "read" | "write" | "admin";
  };
  export type TeamsRemoveProjectParams = {
    team_id: number;

    project_id: number;
  };
  export type TeamsListDiscussionCommentsParams = {
    team_id: number;

    discussion_number: number;
    /**
     * Sorts the discussion comments by the date they were created. To return the oldest comments first, set to `asc`. Can be one of `asc` or `desc`.
     */
    direction?: "asc" | "desc";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type TeamsGetDiscussionCommentParams = {
    team_id: number;

    discussion_number: number;

    comment_number: number;
  };
  export type TeamsCreateDiscussionCommentParams = {
    team_id: number;

    discussion_number: number;
    /**
     * The discussion comment's body text.
     */
    body: string;
  };
  export type TeamsUpdateDiscussionCommentParams = {
    team_id: number;

    discussion_number: number;

    comment_number: number;
    /**
     * The discussion comment's body text.
     */
    body: string;
  };
  export type TeamsDeleteDiscussionCommentParams = {
    team_id: number;

    discussion_number: number;

    comment_number: number;
  };
  export type TeamsListDiscussionsParams = {
    team_id: number;
    /**
     * Sorts the discussion comments by the date they were created. To return the oldest comments first, set to `asc`. Can be one of `asc` or `desc`.
     */
    direction?: "asc" | "desc";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type TeamsGetDiscussionParams = {
    team_id: number;

    discussion_number: number;
  };
  export type TeamsCreateDiscussionParams = {
    team_id: number;
    /**
     * The discussion post's title.
     */
    title: string;
    /**
     * The discussion post's body text.
     */
    body: string;
    /**
     * Private posts are only visible to team members, organization owners, and team maintainers. Public posts are visible to all members of the organization. Set to `true` to create a private post.
     */
    private?: boolean;
  };
  export type TeamsUpdateDiscussionParams = {
    team_id: number;

    discussion_number: number;
    /**
     * The discussion post's title.
     */
    title?: string;
    /**
     * The discussion post's body text.
     */
    body?: string;
  };
  export type TeamsDeleteDiscussionParams = {
    team_id: number;

    discussion_number: number;
  };
  export type TeamsListMembersParams = {
    team_id: number;
    /**
     * Filters members returned by their role in the team. Can be one of:
     * \* `member` - normal members of the team.
     * \* `maintainer` - team maintainers.
     * \* `all` - all members of the team.
     */
    role?: "member" | "maintainer" | "all";
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type TeamsGetMemberParams = {
    team_id: number;

    username: string;
  };
  export type TeamsAddMemberParams = {
    team_id: number;

    username: string;
  };
  export type TeamsRemoveMemberParams = {
    team_id: number;

    username: string;
  };
  export type TeamsGetMembershipParams = {
    team_id: number;

    username: string;
  };
  export type TeamsAddOrUpdateMembershipParams = {
    team_id: number;

    username: string;
    /**
     * The role that this user should have in the team. Can be one of:
     * \* `member` - a normal member of the team.
     * \* `maintainer` - a team maintainer. Able to add/remove other team members, promote other team members to team maintainer, and edit the team's name and description.
     */
    role?: "member" | "maintainer";
  };
  export type TeamsRemoveMembershipParams = {
    team_id: number;

    username: string;
  };
  export type TeamsListPendingInvitationsParams = {
    team_id: number;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type UsersGetByUsernameParams = {
    username: string;
  };
  export type UsersUpdateAuthenticatedParams = {
    /**
     * The new name of the user.
     */
    name?: string;
    /**
     * The publicly visible email address of the user.
     */
    email?: string;
    /**
     * The new blog URL of the user.
     */
    blog?: string;
    /**
     * The new company of the user.
     */
    company?: string;
    /**
     * The new location of the user.
     */
    location?: string;
    /**
     * The new hiring availability of the user.
     */
    hireable?: boolean;
    /**
     * The new short biography of the user.
     */
    bio?: string;
  };
  export type UsersGetContextForUserParams = {
    username: string;
    /**
     * Identifies which additional information you'd like to receive about the person's hovercard. Can be `organization`, `repository`, `issue`, `pull_request`. **Required** when using `subject_id`.
     */
    subject_type?: "organization" | "repository" | "issue" | "pull_request";
    /**
     * Uses the ID for the `subject_type` you specified. **Required** when using `subject_type`.
     */
    subject_id?: string;
  };
  export type UsersListParams = {
    /**
     * The integer ID of the last User that you've seen.
     */
    since?: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type UsersCheckBlockedParams = {
    username: string;
  };
  export type UsersBlockParams = {
    username: string;
  };
  export type UsersUnblockParams = {
    username: string;
  };
  export type UsersListEmailsParams = {
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type UsersListPublicEmailsParams = {
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type UsersAddEmailsParams = {
    /**
     * Adds one or more email addresses to your GitHub account. Must contain at least one email address. **Note:** Alternatively, you can pass a single email address or an `array` of emails addresses directly, but we recommend that you pass an object using the `emails` key.
     */
    emails: string[];
  };
  export type UsersDeleteEmailsParams = {
    /**
     * Deletes one or more email addresses from your GitHub account. Must contain at least one email address. **Note:** Alternatively, you can pass a single email address or an `array` of emails addresses directly, but we recommend that you pass an object using the `emails` key.
     */
    emails: string[];
  };
  export type UsersTogglePrimaryEmailVisibilityParams = {
    /**
     * Specify the _primary_ email address that needs a visibility change.
     */
    email: string;
    /**
     * Use `public` to enable an authenticated user to view the specified email address, or use `private` so this primary email address cannot be seen publicly.
     */
    visibility: string;
  };
  export type UsersListFollowersForUserParams = {
    username: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type UsersListFollowersForAuthenticatedUserParams = {
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type UsersListFollowingForUserParams = {
    username: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type UsersListFollowingForAuthenticatedUserParams = {
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type UsersCheckFollowingParams = {
    username: string;
  };
  export type UsersCheckFollowingForUserParams = {
    username: string;

    target_user: string;
  };
  export type UsersFollowParams = {
    username: string;
  };
  export type UsersUnfollowParams = {
    username: string;
  };
  export type UsersListGpgKeysForUserParams = {
    username: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type UsersListGpgKeysParams = {
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type UsersGetGpgKeyParams = {
    gpg_key_id: number;
  };
  export type UsersCreateGpgKeyParams = {
    /**
     * Your GPG key, generated in ASCII-armored format. See "[Generating a new GPG key](https://help.github.com/articles/generating-a-new-gpg-key/)" for help creating a GPG key.
     */
    armored_public_key?: string;
  };
  export type UsersDeleteGpgKeyParams = {
    gpg_key_id: number;
  };
  export type UsersListPublicKeysForUserParams = {
    username: string;
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type UsersListPublicKeysParams = {
    /**
     * Results per page (max 100)
     */
    per_page?: number;
    /**
     * Page number of the results to fetch.
     */
    page?: number;
  };
  export type UsersGetPublicKeyParams = {
    key_id: number;
  };
  export type UsersCreatePublicKeyParams = {
    /**
     * A descriptive name for the new key. Use a name that will help you recognize this key in your GitHub account. For example, if you're using a personal Mac, you might call this key "Personal MacBook Air".
     */
    title?: string;
    /**
     * The public SSH key to add to your GitHub account. See "[Generating a new SSH key](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)" for guidance on how to create a public SSH key.
     */
    key?: string;
  };
  export type UsersDeletePublicKeyParams = {
    key_id: number;
  };
  export type AppsCreateInstallationTokenParamsPermissions = {};
  export type ChecksCreateParamsOutput = {
    title: string;
    summary: string;
    text?: string;
    annotations?: ChecksCreateParamsOutputAnnotations[];
    images?: ChecksCreateParamsOutputImages[];
  };
  export type ChecksCreateParamsOutputAnnotations = {
    path: string;
    start_line: number;
    end_line: number;
    start_column?: number;
    end_column?: number;
    annotation_level: "notice" | "warning" | "failure";
    message: string;
    title?: string;
    raw_details?: string;
  };
  export type ChecksCreateParamsOutputImages = {
    alt: string;
    image_url: string;
    caption?: string;
  };
  export type ChecksCreateParamsActions = {
    label: string;
    description: string;
    identifier: string;
  };
  export type ChecksUpdateParamsOutput = {
    title?: string;
    summary: string;
    text?: string;
    annotations?: ChecksUpdateParamsOutputAnnotations[];
    images?: ChecksUpdateParamsOutputImages[];
  };
  export type ChecksUpdateParamsOutputAnnotations = {
    path: string;
    start_line: number;
    end_line: number;
    start_column?: number;
    end_column?: number;
    annotation_level: "notice" | "warning" | "failure";
    message: string;
    title?: string;
    raw_details?: string;
  };
  export type ChecksUpdateParamsOutputImages = {
    alt: string;
    image_url: string;
    caption?: string;
  };
  export type ChecksUpdateParamsActions = {
    label: string;
    description: string;
    identifier: string;
  };
  export type ChecksSetSuitesPreferencesParamsAutoTriggerChecks = {
    app_id: number;
    setting: boolean;
  };
  export type GistsCreateParamsFiles = {
    content?: string;
  };
  export type GistsUpdateParamsFiles = {
    content?: string;
    filename?: string;
  };
  export type GitCreateCommitParamsAuthor = {
    name?: string;
    email?: string;
    date?: string;
  };
  export type GitCreateCommitParamsCommitter = {
    name?: string;
    email?: string;
    date?: string;
  };
  export type GitCreateTagParamsTagger = {
    name?: string;
    email?: string;
    date?: string;
  };
  export type GitCreateTreeParamsTree = {
    path?: string;
    mode?: "100644" | "100755" | "040000" | "160000" | "120000";
    type?: "blob" | "tree" | "commit";
    sha?: string;
    content?: string;
  };
  export type OrgsCreateHookParamsConfig = {
    url: string;
    content_type?: string;
    secret?: string;
    insecure_ssl?: string;
  };
  export type OrgsUpdateHookParamsConfig = {
    url: string;
    content_type?: string;
    secret?: string;
    insecure_ssl?: string;
  };
  export type PullsCreateReviewParamsComments = {
    path: string;
    position: number;
    body: string;
  };
  export type ReposUpdateBranchProtectionParamsRequiredStatusChecks = {
    strict: boolean;
    contexts: string[];
  };
  export type ReposUpdateBranchProtectionParamsRequiredPullRequestReviews = {
    dismissal_restrictions?: ReposUpdateBranchProtectionParamsRequiredPullRequestReviewsDismissalRestrictions;
    dismiss_stale_reviews?: boolean;
    require_code_owner_reviews?: boolean;
    required_approving_review_count?: number;
  };
  export type ReposUpdateBranchProtectionParamsRequiredPullRequestReviewsDismissalRestrictions = {
    users?: string[];
    teams?: string[];
  };
  export type ReposUpdateBranchProtectionParamsRestrictions = {
    users?: string[];
    teams?: string[];
  };
  export type ReposUpdateProtectedBranchPullRequestReviewEnforcementParamsDismissalRestrictions = {
    users?: string[];
    teams?: string[];
  };
  export type ReposCreateOrUpdateFileParamsCommitter = {
    name: string;
    email: string;
  };
  export type ReposCreateOrUpdateFileParamsAuthor = {
    name: string;
    email: string;
  };
  export type ReposCreateFileParamsCommitter = {
    name: string;
    email: string;
  };
  export type ReposCreateFileParamsAuthor = {
    name: string;
    email: string;
  };
  export type ReposUpdateFileParamsCommitter = {
    name: string;
    email: string;
  };
  export type ReposUpdateFileParamsAuthor = {
    name: string;
    email: string;
  };
  export type ReposDeleteFileParamsCommitter = {
    name?: string;
    email?: string;
  };
  export type ReposDeleteFileParamsAuthor = {
    name?: string;
    email?: string;
  };
  export type ReposCreateHookParamsConfig = {
    url: string;
    content_type?: string;
    secret?: string;
    insecure_ssl?: string;
  };
  export type ReposUpdateHookParamsConfig = {
    url: string;
    content_type?: string;
    secret?: string;
    insecure_ssl?: string;
  };
  export type ReposEnablePagesSiteParamsSource = {
    branch?: "master" | "gh-pages";
    path?: string;
  };
  export type ReposUploadReleaseAssetParamsHeaders = {
    "content-length": number;
    "content-type": string;
  };
}

declare class Octokit {
  constructor(options?: Octokit.Options);
  authenticate(auth: Octokit.AuthBasic): void;
  authenticate(auth: Octokit.AuthOAuthToken): void;
  authenticate(auth: Octokit.AuthOAuthSecret): void;
  authenticate(auth: Octokit.AuthUserToken): void;
  authenticate(auth: Octokit.AuthJWT): void;

  hook: {
    before(
      name: string,
      callback: (options: Octokit.HookOptions) => void
    ): void;
    after(
      name: string,
      callback: (
        response: Octokit.Response<any>,
        options: Octokit.HookOptions
      ) => void
    ): void;
    error(
      name: string,
      callback: (error: Octokit.HookError, options: Octokit.HookOptions) => void
    ): void;
    wrap(
      name: string,
      callback: (
        request: (
          options: Octokit.HookOptions
        ) => Promise<Octokit.Response<any>>,
        options: Octokit.HookOptions
      ) => void
    ): void;
  };

  static plugin(plugin: Octokit.Plugin | Octokit.Plugin[]): Octokit.Static;

  registerEndpoints(endpoints: {
    [scope: string]: Octokit.EndpointOptions;
  }): void;

  request: Octokit.Request;

  paginate: Octokit.Paginate;

  log: Octokit.Log;

  activity: {
    /**
     * We delay the public events feed by five minutes, which means the most recent event returned by the public events API actually occurred at least five minutes ago.
     */
    listPublicEvents: {
      (params?: Octokit.ActivityListPublicEventsParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };

    listRepoEvents: {
      (params?: Octokit.ActivityListRepoEventsParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };

    listPublicEventsForRepoNetwork: {
      (params?: Octokit.ActivityListPublicEventsForRepoNetworkParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };

    listPublicEventsForOrg: {
      (params?: Octokit.ActivityListPublicEventsForOrgParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * These are events that you've received by watching repos and following users. If you are authenticated as the given user, you will see private events. Otherwise, you'll only see public events.
     */
    listReceivedEventsForUser: {
      (params?: Octokit.ActivityListReceivedEventsForUserParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };

    listReceivedPublicEventsForUser: {
      (params?: Octokit.ActivityListReceivedPublicEventsForUserParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * If you are authenticated as the given user, you will see your private events. Otherwise, you'll only see public events.
     */
    listEventsForUser: {
      (params?: Octokit.ActivityListEventsForUserParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };

    listPublicEventsForUser: {
      (params?: Octokit.ActivityListPublicEventsForUserParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This is the user's organization dashboard. You must be authenticated as the user to view this.
     */
    listEventsForOrg: {
      (params?: Octokit.ActivityListEventsForOrgParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * GitHub provides several timeline resources in [Atom](http://en.wikipedia.org/wiki/Atom_(standard)) format. The Feeds API lists all the feeds available to the authenticated user:
     *
     * *   **Timeline**: The GitHub global public timeline
     * *   **User**: The public timeline for any user, using [URI template](https://developer.github.com/v3/#hypermedia)
     * *   **Current user public**: The public timeline for the authenticated user
     * *   **Current user**: The private timeline for the authenticated user
     * *   **Current user actor**: The private timeline for activity created by the authenticated user
     * *   **Current user organizations**: The private timeline for the organizations the authenticated user is a member of.
     * *   **Security advisories**: A collection of public announcements that provide information about security-related vulnerabilities in software on GitHub.
     *
     * **Note**: Private feeds are only returned when [authenticating via Basic Auth](https://developer.github.com/v3/#basic-authentication) since current feed URIs use the older, non revocable auth tokens.
     */
    listFeeds: {
      (params?: Octokit.EmptyParams): Promise<
        Octokit.Response<Octokit.ActivityListFeedsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * List all notifications for the current user, sorted by most recently updated.
     *
     * The following example uses the `since` parameter to list notifications that have been updated after the specified time.
     */
    listNotifications: {
      (params?: Octokit.ActivityListNotificationsParams): Promise<
        Octokit.Response<Octokit.ActivityListNotificationsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * List all notifications for the current user.
     */
    listNotificationsForRepo: {
      (params?: Octokit.ActivityListNotificationsForRepoParams): Promise<
        Octokit.Response<Octokit.ActivityListNotificationsForRepoResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Marking a notification as "read" removes it from the [default view on GitHub](https://github.com/notifications). If the number of notifications is too large to complete in one request, you will receive a `202 Accepted` status and GitHub will run an asynchronous process to mark notifications as "read." To check whether any "unread" notifications remain, you can use the [List your notifications](https://developer.github.com/v3/activity/notifications/#list-your-notifications) endpoint and pass the query parameter `all=false`.
     */
    markAsRead: {
      (params?: Octokit.ActivityMarkAsReadParams): Promise<
        Octokit.Response<Octokit.ActivityMarkAsReadResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Marking all notifications in a repository as "read" removes them from the [default view on GitHub](https://github.com/notifications). If the number of notifications is too large to complete in one request, you will receive a `202 Accepted` status and GitHub will run an asynchronous process to mark notifications as "read." To check whether any "unread" notifications remain, you can use the [List your notifications in a repository](https://developer.github.com/v3/activity/notifications/#list-your-notifications-in-a-repository) endpoint and pass the query parameter `all=false`.
     */
    markNotificationsAsReadForRepo: {
      (params?: Octokit.ActivityMarkNotificationsAsReadForRepoParams): Promise<
        Octokit.Response<Octokit.ActivityMarkNotificationsAsReadForRepoResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getThread: {
      (params?: Octokit.ActivityGetThreadParams): Promise<
        Octokit.Response<Octokit.ActivityGetThreadResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    markThreadAsRead: {
      (params?: Octokit.ActivityMarkThreadAsReadParams): Promise<
        Octokit.Response<Octokit.ActivityMarkThreadAsReadResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This checks to see if the current user is subscribed to a thread. You can also [get a repository subscription](https://developer.github.com/v3/activity/watching/#get-a-repository-subscription).
     *
     * Note that subscriptions are only generated if a user is participating in a conversation--for example, they've replied to the thread, were **@mentioned**, or manually subscribe to a thread.
     */
    getThreadSubscription: {
      (params?: Octokit.ActivityGetThreadSubscriptionParams): Promise<
        Octokit.Response<Octokit.ActivityGetThreadSubscriptionResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This lets you subscribe or unsubscribe from a conversation.
     */
    setThreadSubscription: {
      (params?: Octokit.ActivitySetThreadSubscriptionParams): Promise<
        Octokit.Response<Octokit.ActivitySetThreadSubscriptionResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Mutes all future notifications for a conversation until you comment on the thread or get **@mention**ed.
     */
    deleteThreadSubscription: {
      (params?: Octokit.ActivityDeleteThreadSubscriptionParams): Promise<
        Octokit.Response<Octokit.ActivityDeleteThreadSubscriptionResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * You can also find out _when_ stars were created by passing the following custom [media type](https://developer.github.com/v3/media/) via the `Accept` header:
     */
    listStargazersForRepo: {
      (params?: Octokit.ActivityListStargazersForRepoParams): Promise<
        Octokit.Response<Octokit.ActivityListStargazersForRepoResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * You can also find out _when_ stars were created by passing the following custom [media type](https://developer.github.com/v3/media/) via the `Accept` header:
     */
    listReposStarredByUser: {
      (params?: Octokit.ActivityListReposStarredByUserParams): Promise<
        Octokit.Response<Octokit.ActivityListReposStarredByUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * You can also find out _when_ stars were created by passing the following custom [media type](https://developer.github.com/v3/media/) via the `Accept` header:
     */
    listReposStarredByAuthenticatedUser: {
      (
        params?: Octokit.ActivityListReposStarredByAuthenticatedUserParams
      ): Promise<
        Octokit.Response<
          Octokit.ActivityListReposStarredByAuthenticatedUserResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Requires for the user to be authenticated.
     */
    checkStarringRepo: {
      (params?: Octokit.ActivityCheckStarringRepoParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Requires for the user to be authenticated.
     *
     * Note that you'll need to set `Content-Length` to zero when calling out to this endpoint. For more information, see "[HTTP verbs](https://developer.github.com/v3/#http-verbs)."
     */
    starRepo: {
      (params?: Octokit.ActivityStarRepoParams): Promise<
        Octokit.Response<Octokit.ActivityStarRepoResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Requires for the user to be authenticated.
     */
    unstarRepo: {
      (params?: Octokit.ActivityUnstarRepoParams): Promise<
        Octokit.Response<Octokit.ActivityUnstarRepoResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listWatchersForRepo: {
      (params?: Octokit.ActivityListWatchersForRepoParams): Promise<
        Octokit.Response<Octokit.ActivityListWatchersForRepoResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listReposWatchedByUser: {
      (params?: Octokit.ActivityListReposWatchedByUserParams): Promise<
        Octokit.Response<Octokit.ActivityListReposWatchedByUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listWatchedReposForAuthenticatedUser: {
      (
        params?: Octokit.ActivityListWatchedReposForAuthenticatedUserParams
      ): Promise<
        Octokit.Response<
          Octokit.ActivityListWatchedReposForAuthenticatedUserResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };

    getRepoSubscription: {
      (params?: Octokit.ActivityGetRepoSubscriptionParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * If you would like to watch a repository, set `subscribed` to `true`. If you would like to ignore notifications made within a repository, set `ignored` to `true`. If you would like to stop watching a repository, [delete the repository's subscription](https://developer.github.com/v3/activity/watching/#delete-a-repository-subscription) completely.
     */
    setRepoSubscription: {
      (params?: Octokit.ActivitySetRepoSubscriptionParams): Promise<
        Octokit.Response<Octokit.ActivitySetRepoSubscriptionResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This endpoint should only be used to stop watching a repository. To control whether or not you wish to receive notifications from a repository, [set the repository's subscription manually](https://developer.github.com/v3/activity/watching/#set-a-repository-subscription).
     */
    deleteRepoSubscription: {
      (params?: Octokit.ActivityDeleteRepoSubscriptionParams): Promise<
        Octokit.Response<Octokit.ActivityDeleteRepoSubscriptionResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  apps: {
    /**
     * **Note**: The `:app_slug` is just the URL-friendly name of your GitHub App. You can find this on the settings page for your GitHub App (e.g., `https://github.com/settings/apps/:app_slug`).
     *
     * If the GitHub App you specify is public, you can access this endpoint without authenticating. If the GitHub App you specify is private, you must authenticate with a [personal access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/) or an [installation access token](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-an-installation) to access this endpoint.
     */
    getBySlug: {
      (params?: Octokit.AppsGetBySlugParams): Promise<
        Octokit.Response<Octokit.AppsGetBySlugResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Returns the GitHub App associated with the authentication credentials used. To see how many app installations are associated with this GitHub App, see the `installations_count` in the response. For more details about your app's installations, see the "[List installations](https://developer.github.com/v3/apps/#list-installations)" endpoint.
     *
     * You must use a [JWT](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.
     */
    getAuthenticated: {
      (params?: Octokit.EmptyParams): Promise<
        Octokit.Response<Octokit.AppsGetAuthenticatedResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * You must use a [JWT](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.
     *
     * The permissions the installation has are included under the `permissions` key.
     */
    listInstallations: {
      (params?: Octokit.AppsListInstallationsParams): Promise<
        Octokit.Response<Octokit.AppsListInstallationsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * You must use a [JWT](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.
     */
    getInstallation: {
      (params?: Octokit.AppsGetInstallationParams): Promise<
        Octokit.Response<Octokit.AppsGetInstallationResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Uninstalls a GitHub App on a user, organization, or business account.
     *
     * You must use a [JWT](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.
     */
    deleteInstallation: {
      (params?: Octokit.AppsDeleteInstallationParams): Promise<
        Octokit.Response<Octokit.AppsDeleteInstallationResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Creates an installation access token that enables a GitHub App to make authenticated API requests for the app's installation on an organization or individual account. Installation tokens expire one hour from the time you create them. Using an expired token produces a status code of `401 - Unauthorized`, and requires creating a new installation token.
     *
     * By default the installation token has access to all repositories that the installation can access. To restrict the access to specific repositories, you can provide the `repository_ids` when creating the token. When you omit `repository_ids`, the response does not contain the `repositories` key.
     *
     * You must use a [JWT](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.
     *
     * This example grants the token "Read and write" permission to `issues` and "Read" permission to `contents`, and restricts the token's access to the repository with an `id` of 1296269.
     */
    createInstallationToken: {
      (params?: Octokit.AppsCreateInstallationTokenParams): Promise<
        Octokit.Response<Octokit.AppsCreateInstallationTokenResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Enables an authenticated GitHub App to find the organization's installation information.
     *
     * You must use a [JWT](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.
     */
    getOrgInstallation: {
      (params?: Octokit.AppsGetOrgInstallationParams): Promise<
        Octokit.Response<Octokit.AppsGetOrgInstallationResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Enables an authenticated GitHub App to find the organization's installation information.
     *
     * You must use a [JWT](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.
     */
    findOrgInstallation: {
      (params?: Octokit.AppsFindOrgInstallationParams): Promise<
        Octokit.Response<Octokit.AppsFindOrgInstallationResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Enables an authenticated GitHub App to find the repository's installation information. The installation's account type will be either an organization or a user account, depending which account the repository belongs to.
     *
     * You must use a [JWT](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.
     */
    getRepoInstallation: {
      (params?: Octokit.AppsGetRepoInstallationParams): Promise<
        Octokit.Response<Octokit.AppsGetRepoInstallationResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Enables an authenticated GitHub App to find the repository's installation information. The installation's account type will be either an organization or a user account, depending which account the repository belongs to.
     *
     * You must use a [JWT](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.
     */
    findRepoInstallation: {
      (params?: Octokit.AppsFindRepoInstallationParams): Promise<
        Octokit.Response<Octokit.AppsFindRepoInstallationResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Enables an authenticated GitHub App to find the user’s installation information.
     *
     * You must use a [JWT](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.
     */
    getUserInstallation: {
      (params?: Octokit.AppsGetUserInstallationParams): Promise<
        Octokit.Response<Octokit.AppsGetUserInstallationResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Enables an authenticated GitHub App to find the user’s installation information.
     *
     * You must use a [JWT](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.
     */
    findUserInstallation: {
      (params?: Octokit.AppsFindUserInstallationParams): Promise<
        Octokit.Response<Octokit.AppsFindUserInstallationResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Use this endpoint to complete the handshake necessary when implementing the [GitHub App Manifest flow](https://developer.github.com/apps/building-github-apps/creating-github-apps-from-a-manifest/). When you create a GitHub App with the manifest flow, you receive a temporary `code` used to retrieve the GitHub App's `id`, `pem` (private key), and `webhook_secret`.
     */
    createFromManifest: {
      (params?: Octokit.AppsCreateFromManifestParams): Promise<
        Octokit.Response<Octokit.AppsCreateFromManifestResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * List repositories that an installation can access.
     *
     * You must use an [installation access token](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-an-installation) to access this endpoint.
     */
    listRepos: {
      (params?: Octokit.AppsListReposParams): Promise<
        Octokit.Response<Octokit.AppsListReposResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists installations of your GitHub App that the authenticated user has explicit permission (`:read`, `:write`, or `:admin`) to access.
     *
     * You must use a [user-to-server OAuth access token](https://developer.github.com/apps/building-github-apps/identifying-and-authorizing-users-for-github-apps/#identifying-users-on-your-site), created for a user who has authorized your GitHub App, to access this endpoint.
     *
     * The authenticated user has explicit permission to access repositories they own, repositories where they are a collaborator, and repositories that they can access through an organization membership.
     *
     * You can find the permissions for the installation under the `permissions` key.
     */
    listInstallationsForAuthenticatedUser: {
      (
        params?: Octokit.AppsListInstallationsForAuthenticatedUserParams
      ): Promise<
        Octokit.Response<
          Octokit.AppsListInstallationsForAuthenticatedUserResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * List repositories that the authenticated user has explicit permission (`:read`, `:write`, or `:admin`) to access for an installation.
     *
     * The authenticated user has explicit permission to access repositories they own, repositories where they are a collaborator, and repositories that they can access through an organization membership.
     *
     * You must use a [user-to-server OAuth access token](https://developer.github.com/apps/building-github-apps/identifying-and-authorizing-users-for-github-apps/#identifying-users-on-your-site), created for a user who has authorized your GitHub App, to access this endpoint.
     *
     * The access the user has to each repository is included in the hash under the `permissions` key.
     */
    listInstallationReposForAuthenticatedUser: {
      (
        params?: Octokit.AppsListInstallationReposForAuthenticatedUserParams
      ): Promise<
        Octokit.Response<
          Octokit.AppsListInstallationReposForAuthenticatedUserResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Add a single repository to an installation. The authenticated user must have admin access to the repository.
     *
     * You must use a personal access token (which you can create via the [command line](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/) or the [OAuth Authorizations API](https://developer.github.com/v3/oauth_authorizations/#create-a-new-authorization)) or [Basic Authentication](https://developer.github.com/v3/auth/#basic-authentication) to access this endpoint.
     */
    addRepoToInstallation: {
      (params?: Octokit.AppsAddRepoToInstallationParams): Promise<
        Octokit.Response<Octokit.AppsAddRepoToInstallationResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Remove a single repository from an installation. The authenticated user must have admin access to the repository.
     *
     * You must use a personal access token (which you can create via the [command line](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/) or the [OAuth Authorizations API](https://developer.github.com/v3/oauth_authorizations/#create-a-new-authorization)) or [Basic Authentication](https://developer.github.com/v3/auth/#basic-authentication) to access this endpoint.
     */
    removeRepoFromInstallation: {
      (params?: Octokit.AppsRemoveRepoFromInstallationParams): Promise<
        Octokit.Response<Octokit.AppsRemoveRepoFromInstallationResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Creates an attachment under a content reference URL in the body or comment of an issue or pull request. Use the `id` of the content reference from the [`content_reference` event](https://developer.github.com/v3/activity/events/types/#contentreferenceevent) to create an attachment.
     *
     * The app must create a content attachment within six hours of the content reference URL being posted. See "[Using content attachments](https://developer.github.com/apps/using-content-attachments/)" for details about content attachments.
     *
     * You must use an [installation access token](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-an-installation) to access this endpoint.
     *
     * This example creates a content attachment for the domain `https://errors.ai/`.
     */
    createContentAttachment: {
      (params?: Octokit.AppsCreateContentAttachmentParams): Promise<
        Octokit.Response<Octokit.AppsCreateContentAttachmentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * GitHub Apps must use a [JWT](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint. OAuth Apps must use [basic authentication](https://developer.github.com/v3/auth/#basic-authentication) with their client ID and client secret to access this endpoint.
     */
    listPlans: {
      (params?: Octokit.AppsListPlansParams): Promise<
        Octokit.Response<Octokit.AppsListPlansResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * GitHub Apps must use a [JWT](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint. OAuth Apps must use [basic authentication](https://developer.github.com/v3/auth/#basic-authentication) with their client ID and client secret to access this endpoint.
     */
    listPlansStubbed: {
      (params?: Octokit.AppsListPlansStubbedParams): Promise<
        Octokit.Response<Octokit.AppsListPlansStubbedResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Returns any accounts associated with a plan, including free plans. For per-seat pricing, you see the list of accounts that have purchased the plan, including the number of seats purchased. When someone submits a plan change that won't be processed until the end of their billing cycle, you will also see the upcoming pending change.
     *
     * GitHub Apps must use a [JWT](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint. OAuth Apps must use [basic authentication](https://developer.github.com/v3/auth/#basic-authentication) with their client ID and client secret to access this endpoint.
     */
    listAccountsUserOrOrgOnPlan: {
      (params?: Octokit.AppsListAccountsUserOrOrgOnPlanParams): Promise<
        Octokit.Response<Octokit.AppsListAccountsUserOrOrgOnPlanResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Returns any accounts associated with a plan, including free plans. For per-seat pricing, you see the list of accounts that have purchased the plan, including the number of seats purchased. When someone submits a plan change that won't be processed until the end of their billing cycle, you will also see the upcoming pending change.
     *
     * GitHub Apps must use a [JWT](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint. OAuth Apps must use [basic authentication](https://developer.github.com/v3/auth/#basic-authentication) with their client ID and client secret to access this endpoint.
     */
    listAccountsUserOrOrgOnPlanStubbed: {
      (params?: Octokit.AppsListAccountsUserOrOrgOnPlanStubbedParams): Promise<
        Octokit.Response<Octokit.AppsListAccountsUserOrOrgOnPlanStubbedResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Shows whether the user or organization account actively subscribes to a plan listed by the authenticated GitHub App. When someone submits a plan change that won't be processed until the end of their billing cycle, you will also see the upcoming pending change.
     *
     * GitHub Apps must use a [JWT](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint. OAuth Apps must use [basic authentication](https://developer.github.com/v3/auth/#basic-authentication) with their client ID and client secret to access this endpoint.
     */
    checkAccountIsAssociatedWithAny: {
      (params?: Octokit.AppsCheckAccountIsAssociatedWithAnyParams): Promise<
        Octokit.Response<Octokit.AppsCheckAccountIsAssociatedWithAnyResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Shows whether the user or organization account actively subscribes to a plan listed by the authenticated GitHub App. When someone submits a plan change that won't be processed until the end of their billing cycle, you will also see the upcoming pending change.
     *
     * GitHub Apps must use a [JWT](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint. OAuth Apps must use [basic authentication](https://developer.github.com/v3/auth/#basic-authentication) with their client ID and client secret to access this endpoint.
     */
    checkAccountIsAssociatedWithAnyStubbed: {
      (
        params?: Octokit.AppsCheckAccountIsAssociatedWithAnyStubbedParams
      ): Promise<
        Octokit.Response<
          Octokit.AppsCheckAccountIsAssociatedWithAnyStubbedResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Returns only active subscriptions. You must use a [user-to-server OAuth access token](https://developer.github.com/apps/building-github-apps/identifying-and-authorizing-users-for-github-apps/#identifying-users-on-your-site), created for a user who has authorized your GitHub App, to access this endpoint. . OAuth Apps must authenticate using an [OAuth token](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/).
     */
    listMarketplacePurchasesForAuthenticatedUser: {
      (
        params?: Octokit.AppsListMarketplacePurchasesForAuthenticatedUserParams
      ): Promise<
        Octokit.Response<
          Octokit.AppsListMarketplacePurchasesForAuthenticatedUserResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Returns only active subscriptions. You must use a [user-to-server OAuth access token](https://developer.github.com/apps/building-github-apps/identifying-and-authorizing-users-for-github-apps/#identifying-users-on-your-site), created for a user who has authorized your GitHub App, to access this endpoint. . OAuth Apps must authenticate using an [OAuth token](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/).
     */
    listMarketplacePurchasesForAuthenticatedUserStubbed: {
      (
        params?: Octokit.AppsListMarketplacePurchasesForAuthenticatedUserStubbedParams
      ): Promise<
        Octokit.Response<
          Octokit.AppsListMarketplacePurchasesForAuthenticatedUserStubbedResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  checks: {
    /**
     * **Note:** The Checks API only looks for pushes in the repository where the check suite or check run were created. Pushes to a branch in a forked repository are not detected and return an empty `pull_requests` array.
     *
     * Creates a new check run for a specific commit in a repository. Your GitHub App must have the `checks:write` permission to create check runs.
     *
     * #### [](https://developer.github.com/v3/checks/runs/#actions-object)`actions` object
     */
    create: {
      (params?: Octokit.ChecksCreateParams): Promise<
        Octokit.Response<Octokit.ChecksCreateResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Note:** The Checks API only looks for pushes in the repository where the check suite or check run were created. Pushes to a branch in a forked repository are not detected and return an empty `pull_requests` array.
     *
     * Updates a check run for a specific commit in a repository. Your GitHub App must have the `checks:write` permission to edit check runs.
     *
     * #### [](https://developer.github.com/v3/checks/runs/#actions-object-1)`actions` object
     */
    update: {
      (params?: Octokit.ChecksUpdateParams): Promise<
        Octokit.Response<Octokit.ChecksUpdateResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Note:** The Checks API only looks for pushes in the repository where the check suite or check run were created. Pushes to a branch in a forked repository are not detected and return an empty `pull_requests` array.
     *
     * Lists check runs for a commit ref. The `ref` can be a SHA, branch name, or a tag name. GitHub Apps must have the `checks:read` permission on a private repository or pull access to a public repository to get check runs. OAuth Apps and authenticated users must have the `repo` scope to get check runs in a private repository.
     */
    listForRef: {
      (params?: Octokit.ChecksListForRefParams): Promise<
        Octokit.Response<Octokit.ChecksListForRefResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Note:** The Checks API only looks for pushes in the repository where the check suite or check run were created. Pushes to a branch in a forked repository are not detected and return an empty `pull_requests` array.
     *
     * Lists check runs for a check suite using its `id`. GitHub Apps must have the `checks:read` permission on a private repository or pull access to a public repository to get check runs. OAuth Apps and authenticated users must have the `repo` scope to get check runs in a private repository.
     */
    listForSuite: {
      (params?: Octokit.ChecksListForSuiteParams): Promise<
        Octokit.Response<Octokit.ChecksListForSuiteResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Note:** The Checks API only looks for pushes in the repository where the check suite or check run were created. Pushes to a branch in a forked repository are not detected and return an empty `pull_requests` array.
     *
     * Gets a single check run using its `id`. GitHub Apps must have the `checks:read` permission on a private repository or pull access to a public repository to get check runs. OAuth Apps and authenticated users must have the `repo` scope to get check runs in a private repository.
     */
    get: {
      (params?: Octokit.ChecksGetParams): Promise<
        Octokit.Response<Octokit.ChecksGetResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists annotations for a check run using the annotation `id`. GitHub Apps must have the `checks:read` permission on a private repository or pull access to a public repository to get annotations for a check run. OAuth Apps and authenticated users must have the `repo` scope to get annotations for a check run in a private repository.
     */
    listAnnotations: {
      (params?: Octokit.ChecksListAnnotationsParams): Promise<
        Octokit.Response<Octokit.ChecksListAnnotationsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Note:** The Checks API only looks for pushes in the repository where the check suite or check run were created. Pushes to a branch in a forked repository are not detected and return an empty `pull_requests` array and a `null` value for `head_branch`.
     *
     * Gets a single check suite using its `id`. GitHub Apps must have the `checks:read` permission on a private repository or pull access to a public repository to get check suites. OAuth Apps and authenticated users must have the `repo` scope to get check suites in a private repository.
     */
    getSuite: {
      (params?: Octokit.ChecksGetSuiteParams): Promise<
        Octokit.Response<Octokit.ChecksGetSuiteResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Note:** The Checks API only looks for pushes in the repository where the check suite or check run were created. Pushes to a branch in a forked repository are not detected and return an empty `pull_requests` array and a `null` value for `head_branch`.
     *
     * Lists check suites for a commit `ref`. The `ref` can be a SHA, branch name, or a tag name. GitHub Apps must have the `checks:read` permission on a private repository or pull access to a public repository to list check suites. OAuth Apps and authenticated users must have the `repo` scope to get check suites in a private repository.
     */
    listSuitesForRef: {
      (params?: Octokit.ChecksListSuitesForRefParams): Promise<
        Octokit.Response<Octokit.ChecksListSuitesForRefResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Changes the default automatic flow when creating check suites. By default, the CheckSuiteEvent is automatically created each time code is pushed to a repository. When you disable the automatic creation of check suites, you can manually [Create a check suite](https://developer.github.com/v3/checks/suites/#create-a-check-suite). You must have admin permissions in the repository to set preferences for check suites.
     */
    setSuitesPreferences: {
      (params?: Octokit.ChecksSetSuitesPreferencesParams): Promise<
        Octokit.Response<Octokit.ChecksSetSuitesPreferencesResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Note:** The Checks API only looks for pushes in the repository where the check suite or check run were created. Pushes to a branch in a forked repository are not detected and return an empty `pull_requests` array and a `null` value for `head_branch`.
     *
     * By default, check suites are automatically created when you create a [check run](https://developer.github.com/v3/checks/runs/). You only need to use this endpoint for manually creating check suites when you've disabled automatic creation using "[Set preferences for check suites on a repository](https://developer.github.com/v3/checks/suites/#set-preferences-for-check-suites-on-a-repository)". Your GitHub App must have the `checks:write` permission to create check suites.
     */
    createSuite: {
      (params?: Octokit.ChecksCreateSuiteParams): Promise<
        Octokit.Response<Octokit.ChecksCreateSuiteResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Triggers GitHub to rerequest an existing check suite, without pushing new code to a repository. This endpoint will trigger the [`check_suite` webhook](https://developer.github.com/v3/activity/events/types/#checksuiteevent) event with the action `rerequested`. When a check suite is `rerequested`, its `status` is reset to `queued` and the `conclusion` is cleared.
     *
     * To rerequest a check suite, your GitHub App must have the `checks:read` permission on a private repository or pull access to a public repository.
     */
    rerequestSuite: {
      (params?: Octokit.ChecksRerequestSuiteParams): Promise<
        Octokit.Response<Octokit.ChecksRerequestSuiteResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  codesOfConduct: {
    listConductCodes: {
      (params?: Octokit.EmptyParams): Promise<
        Octokit.Response<Octokit.CodesOfConductListConductCodesResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getConductCode: {
      (params?: Octokit.CodesOfConductGetConductCodeParams): Promise<
        Octokit.Response<Octokit.CodesOfConductGetConductCodeResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This method returns the contents of the repository's code of conduct file, if one is detected.
     */
    getForRepo: {
      (params?: Octokit.CodesOfConductGetForRepoParams): Promise<
        Octokit.Response<Octokit.CodesOfConductGetForRepoResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  emojis: {
    /**
     * Lists all the emojis available to use on GitHub.
     */
    get: {
      (params?: Octokit.EmptyParams): Promise<
        Octokit.Response<Octokit.EmojisGetResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  gists: {
    listPublicForUser: {
      (params?: Octokit.GistsListPublicForUserParams): Promise<
        Octokit.Response<Octokit.GistsListPublicForUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    list: {
      (params?: Octokit.GistsListParams): Promise<
        Octokit.Response<Octokit.GistsListResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * List all public gists sorted by most recently updated to least recently updated.
     *
     * Note: With [pagination](https://developer.github.com/v3/#pagination), you can fetch up to 3000 gists. For example, you can fetch 100 pages with 30 gists per page or 30 pages with 100 gists per page.
     */
    listPublic: {
      (params?: Octokit.GistsListPublicParams): Promise<
        Octokit.Response<Octokit.GistsListPublicResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * List the authenticated user's starred gists:
     */
    listStarred: {
      (params?: Octokit.GistsListStarredParams): Promise<
        Octokit.Response<Octokit.GistsListStarredResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    get: {
      (params?: Octokit.GistsGetParams): Promise<
        Octokit.Response<Octokit.GistsGetResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getRevision: {
      (params?: Octokit.GistsGetRevisionParams): Promise<
        Octokit.Response<Octokit.GistsGetRevisionResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Allows you to add a new gist with one or more files.
     *
     * **Note:** Don't name your files "gistfile" with a numerical suffix. This is the format of the automatic naming scheme that Gist uses internally.
     */
    create: {
      (params?: Octokit.GistsCreateParams): Promise<
        Octokit.Response<Octokit.GistsCreateResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Allows you to update or delete a gist file and rename gist files. Files from the previous version of the gist that aren't explicitly changed during an edit are unchanged.
     */
    update: {
      (params?: Octokit.GistsUpdateParams): Promise<
        Octokit.Response<Octokit.GistsUpdateResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listCommits: {
      (params?: Octokit.GistsListCommitsParams): Promise<
        Octokit.Response<Octokit.GistsListCommitsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Note that you'll need to set `Content-Length` to zero when calling out to this endpoint. For more information, see "[HTTP verbs](https://developer.github.com/v3/#http-verbs)."
     */
    star: {
      (params?: Octokit.GistsStarParams): Promise<
        Octokit.Response<Octokit.GistsStarResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    unstar: {
      (params?: Octokit.GistsUnstarParams): Promise<
        Octokit.Response<Octokit.GistsUnstarResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    checkIsStarred: {
      (params?: Octokit.GistsCheckIsStarredParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Note**: This was previously `/gists/:gist_id/fork`.
     */
    fork: {
      (params?: Octokit.GistsForkParams): Promise<
        Octokit.Response<Octokit.GistsForkResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listForks: {
      (params?: Octokit.GistsListForksParams): Promise<
        Octokit.Response<Octokit.GistsListForksResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    delete: {
      (params?: Octokit.GistsDeleteParams): Promise<
        Octokit.Response<Octokit.GistsDeleteResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listComments: {
      (params?: Octokit.GistsListCommentsParams): Promise<
        Octokit.Response<Octokit.GistsListCommentsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getComment: {
      (params?: Octokit.GistsGetCommentParams): Promise<
        Octokit.Response<Octokit.GistsGetCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    createComment: {
      (params?: Octokit.GistsCreateCommentParams): Promise<
        Octokit.Response<Octokit.GistsCreateCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    updateComment: {
      (params?: Octokit.GistsUpdateCommentParams): Promise<
        Octokit.Response<Octokit.GistsUpdateCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    deleteComment: {
      (params?: Octokit.GistsDeleteCommentParams): Promise<
        Octokit.Response<Octokit.GistsDeleteCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  git: {
    /**
     * The `content` in the response will always be Base64 encoded.
     *
     * _Note_: This API supports blobs up to 100 megabytes in size.
     */
    getBlob: {
      (params?: Octokit.GitGetBlobParams): Promise<
        Octokit.Response<Octokit.GitGetBlobResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    createBlob: {
      (params?: Octokit.GitCreateBlobParams): Promise<
        Octokit.Response<Octokit.GitCreateBlobResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Gets a Git [commit object](https://git-scm.com/book/en/v1/Git-Internals-Git-Objects#Commit-Objects).
     *
     * **Signature verification object**
     *
     * The response will include a `verification` object that describes the result of verifying the commit's signature. The following fields are included in the `verification` object:
     *
     * These are the possible values for `reason` in the `verification` object:
     *
     * | Value                    | Description                                                                                                                       |
     * | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
     * | `expired_key`            | The key that made the signature is expired.                                                                                       |
     * | `not_signing_key`        | The "signing" flag is not among the usage flags in the GPG key that made the signature.                                           |
     * | `gpgverify_error`        | There was an error communicating with the signature verification service.                                                         |
     * | `gpgverify_unavailable`  | The signature verification service is currently unavailable.                                                                      |
     * | `unsigned`               | The object does not include a signature.                                                                                          |
     * | `unknown_signature_type` | A non-PGP signature was found in the commit.                                                                                      |
     * | `no_user`                | No user was associated with the `committer` email address in the commit.                                                          |
     * | `unverified_email`       | The `committer` email address in the commit was associated with a user, but the email address is not verified on her/his account. |
     * | `bad_email`              | The `committer` email address in the commit is not included in the identities of the PGP key that made the signature.             |
     * | `unknown_key`            | The key that made the signature has not been registered with any user's account.                                                  |
     * | `malformed_signature`    | There was an error parsing the signature.                                                                                         |
     * | `invalid`                | The signature could not be cryptographically verified using the key whose key-id was found in the signature.                      |
     * | `valid`                  | None of the above errors applied, so the signature is considered to be verified.                                                  |
     */
    getCommit: {
      (params?: Octokit.GitGetCommitParams): Promise<
        Octokit.Response<Octokit.GitGetCommitResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Creates a new Git [commit object](https://git-scm.com/book/en/v1/Git-Internals-Git-Objects#Commit-Objects).
     *
     * In this example, the payload of the signature would be:
     *
     *
     *
     * **Signature verification object**
     *
     * The response will include a `verification` object that describes the result of verifying the commit's signature. The following fields are included in the `verification` object:
     *
     * These are the possible values for `reason` in the `verification` object:
     *
     * | Value                    | Description                                                                                                                       |
     * | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
     * | `expired_key`            | The key that made the signature is expired.                                                                                       |
     * | `not_signing_key`        | The "signing" flag is not among the usage flags in the GPG key that made the signature.                                           |
     * | `gpgverify_error`        | There was an error communicating with the signature verification service.                                                         |
     * | `gpgverify_unavailable`  | The signature verification service is currently unavailable.                                                                      |
     * | `unsigned`               | The object does not include a signature.                                                                                          |
     * | `unknown_signature_type` | A non-PGP signature was found in the commit.                                                                                      |
     * | `no_user`                | No user was associated with the `committer` email address in the commit.                                                          |
     * | `unverified_email`       | The `committer` email address in the commit was associated with a user, but the email address is not verified on her/his account. |
     * | `bad_email`              | The `committer` email address in the commit is not included in the identities of the PGP key that made the signature.             |
     * | `unknown_key`            | The key that made the signature has not been registered with any user's account.                                                  |
     * | `malformed_signature`    | There was an error parsing the signature.                                                                                         |
     * | `invalid`                | The signature could not be cryptographically verified using the key whose key-id was found in the signature.                      |
     * | `valid`                  | None of the above errors applied, so the signature is considered to be verified.                                                  |
     */
    createCommit: {
      (params?: Octokit.GitCreateCommitParams): Promise<
        Octokit.Response<Octokit.GitCreateCommitResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Returns a branch or tag reference. Other than the [REST API](https://developer.github.com/v3/git/refs/#get-a-reference) it always returns a single reference. If the REST API returns with an array then the method responds with an error.
     */
    getRef: {
      (params?: Octokit.GitGetRefParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This will return an array of all the references on the system, including things like notes and stashes if they exist on the server
     */
    listRefs: {
      (params?: Octokit.GitListRefsParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Creates a reference for your repository. You are unable to create new references for empty repositories, even if the commit SHA-1 hash used exists. Empty repositories are repositories without branches.
     */
    createRef: {
      (params?: Octokit.GitCreateRefParams): Promise<
        Octokit.Response<Octokit.GitCreateRefResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    updateRef: {
      (params?: Octokit.GitUpdateRefParams): Promise<
        Octokit.Response<Octokit.GitUpdateRefResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * ```
     * DELETE /repos/octocat/Hello-World/git/refs/heads/feature-a
     * ```
     *
     * ```
     * DELETE /repos/octocat/Hello-World/git/refs/tags/v1.0
     * ```
     */
    deleteRef: {
      (params?: Octokit.GitDeleteRefParams): Promise<
        Octokit.Response<Octokit.GitDeleteRefResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Signature verification object**
     *
     * The response will include a `verification` object that describes the result of verifying the commit's signature. The following fields are included in the `verification` object:
     *
     * These are the possible values for `reason` in the `verification` object:
     *
     * | Value                    | Description                                                                                                                       |
     * | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
     * | `expired_key`            | The key that made the signature is expired.                                                                                       |
     * | `not_signing_key`        | The "signing" flag is not among the usage flags in the GPG key that made the signature.                                           |
     * | `gpgverify_error`        | There was an error communicating with the signature verification service.                                                         |
     * | `gpgverify_unavailable`  | The signature verification service is currently unavailable.                                                                      |
     * | `unsigned`               | The object does not include a signature.                                                                                          |
     * | `unknown_signature_type` | A non-PGP signature was found in the commit.                                                                                      |
     * | `no_user`                | No user was associated with the `committer` email address in the commit.                                                          |
     * | `unverified_email`       | The `committer` email address in the commit was associated with a user, but the email address is not verified on her/his account. |
     * | `bad_email`              | The `committer` email address in the commit is not included in the identities of the PGP key that made the signature.             |
     * | `unknown_key`            | The key that made the signature has not been registered with any user's account.                                                  |
     * | `malformed_signature`    | There was an error parsing the signature.                                                                                         |
     * | `invalid`                | The signature could not be cryptographically verified using the key whose key-id was found in the signature.                      |
     * | `valid`                  | None of the above errors applied, so the signature is considered to be verified.                                                  |
     */
    getTag: {
      (params?: Octokit.GitGetTagParams): Promise<
        Octokit.Response<Octokit.GitGetTagResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Note that creating a tag object does not create the reference that makes a tag in Git. If you want to create an annotated tag in Git, you have to do this call to create the tag object, and then [create](https://developer.github.com/v3/git/refs/#create-a-reference) the `refs/tags/[tag]` reference. If you want to create a lightweight tag, you only have to [create](https://developer.github.com/v3/git/refs/#create-a-reference) the tag reference - this call would be unnecessary.
     *
     * **Signature verification object**
     *
     * The response will include a `verification` object that describes the result of verifying the commit's signature. The following fields are included in the `verification` object:
     *
     * These are the possible values for `reason` in the `verification` object:
     *
     * | Value                    | Description                                                                                                                       |
     * | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
     * | `expired_key`            | The key that made the signature is expired.                                                                                       |
     * | `not_signing_key`        | The "signing" flag is not among the usage flags in the GPG key that made the signature.                                           |
     * | `gpgverify_error`        | There was an error communicating with the signature verification service.                                                         |
     * | `gpgverify_unavailable`  | The signature verification service is currently unavailable.                                                                      |
     * | `unsigned`               | The object does not include a signature.                                                                                          |
     * | `unknown_signature_type` | A non-PGP signature was found in the commit.                                                                                      |
     * | `no_user`                | No user was associated with the `committer` email address in the commit.                                                          |
     * | `unverified_email`       | The `committer` email address in the commit was associated with a user, but the email address is not verified on her/his account. |
     * | `bad_email`              | The `committer` email address in the commit is not included in the identities of the PGP key that made the signature.             |
     * | `unknown_key`            | The key that made the signature has not been registered with any user's account.                                                  |
     * | `malformed_signature`    | There was an error parsing the signature.                                                                                         |
     * | `invalid`                | The signature could not be cryptographically verified using the key whose key-id was found in the signature.                      |
     * | `valid`                  | None of the above errors applied, so the signature is considered to be verified.                                                  |
     */
    createTag: {
      (params?: Octokit.GitCreateTagParams): Promise<
        Octokit.Response<Octokit.GitCreateTagResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * If `truncated` in the response is `true`, the number of items in the `tree` array exceeded our maximum limit. If you need to fetch more items, omit the `recursive` parameter, and fetch one sub-tree at a time. If you need to fetch even more items, you can clone the repository and iterate over the Git data locally.
     */
    getTree: {
      (params?: Octokit.GitGetTreeParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * The tree creation API will take nested entries as well. If both a tree and a nested path modifying that tree are specified, it will overwrite the contents of that tree with the new path contents and write a new tree out.
     */
    createTree: {
      (params?: Octokit.GitCreateTreeParams): Promise<
        Octokit.Response<Octokit.GitCreateTreeResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  gitignore: {
    /**
     * List all templates available to pass as an option when [creating a repository](https://developer.github.com/v3/repos/#create).
     */
    listTemplates: {
      (params?: Octokit.EmptyParams): Promise<
        Octokit.Response<Octokit.GitignoreListTemplatesResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * The API also allows fetching the source of a single template.
     *
     * Use the raw [media type](https://developer.github.com/v3/media/) to get the raw contents.
     */
    getTemplate: {
      (params?: Octokit.GitignoreGetTemplateParams): Promise<
        Octokit.Response<Octokit.GitignoreGetTemplateResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  interactions: {
    /**
     * Shows which group of GitHub users can interact with this organization and when the restriction expires. If there are no restrictions, you will see an empty response.
     */
    getRestrictionsForOrg: {
      (params?: Octokit.InteractionsGetRestrictionsForOrgParams): Promise<
        Octokit.Response<Octokit.InteractionsGetRestrictionsForOrgResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Temporarily restricts interactions to certain GitHub users in any public repository in the given organization. You must be an organization owner to set these restrictions.
     */
    addOrUpdateRestrictionsForOrg: {
      (
        params?: Octokit.InteractionsAddOrUpdateRestrictionsForOrgParams
      ): Promise<
        Octokit.Response<
          Octokit.InteractionsAddOrUpdateRestrictionsForOrgResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Removes all interaction restrictions from public repositories in the given organization. You must be an organization owner to remove restrictions.
     */
    removeRestrictionsForOrg: {
      (params?: Octokit.InteractionsRemoveRestrictionsForOrgParams): Promise<
        Octokit.Response<Octokit.InteractionsRemoveRestrictionsForOrgResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Shows which group of GitHub users can interact with this repository and when the restriction expires. If there are no restrictions, you will see an empty response.
     */
    getRestrictionsForRepo: {
      (params?: Octokit.InteractionsGetRestrictionsForRepoParams): Promise<
        Octokit.Response<Octokit.InteractionsGetRestrictionsForRepoResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Temporarily restricts interactions to certain GitHub users within the given repository. You must have owner or admin access to set restrictions.
     */
    addOrUpdateRestrictionsForRepo: {
      (
        params?: Octokit.InteractionsAddOrUpdateRestrictionsForRepoParams
      ): Promise<
        Octokit.Response<
          Octokit.InteractionsAddOrUpdateRestrictionsForRepoResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Removes all interaction restrictions from the given repository. You must have owner or admin access to remove restrictions.
     */
    removeRestrictionsForRepo: {
      (params?: Octokit.InteractionsRemoveRestrictionsForRepoParams): Promise<
        Octokit.Response<Octokit.InteractionsRemoveRestrictionsForRepoResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  issues: {
    /**
     * **Note**: GitHub's REST API v3 considers every pull request an issue, but not every issue is a pull request. For this reason, "Issues" endpoints may return both issues and pull requests in the response. You can identify pull requests by the `pull_request` key.
     *
     * Be aware that the `id` of a pull request returned from "Issues" endpoints will be an _issue id_. To find out the pull request id, use the "[List pull requests](https://developer.github.com/v3/pulls/#list-pull-requests)" endpoint.
     */
    list: {
      (params?: Octokit.IssuesListParams): Promise<
        Octokit.Response<Octokit.IssuesListResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Note**: GitHub's REST API v3 considers every pull request an issue, but not every issue is a pull request. For this reason, "Issues" endpoints may return both issues and pull requests in the response. You can identify pull requests by the `pull_request` key.
     *
     * Be aware that the `id` of a pull request returned from "Issues" endpoints will be an _issue id_. To find out the pull request id, use the "[List pull requests](https://developer.github.com/v3/pulls/#list-pull-requests)" endpoint.
     */
    listForAuthenticatedUser: {
      (params?: Octokit.IssuesListForAuthenticatedUserParams): Promise<
        Octokit.Response<Octokit.IssuesListForAuthenticatedUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Note**: GitHub's REST API v3 considers every pull request an issue, but not every issue is a pull request. For this reason, "Issues" endpoints may return both issues and pull requests in the response. You can identify pull requests by the `pull_request` key.
     *
     * Be aware that the `id` of a pull request returned from "Issues" endpoints will be an _issue id_. To find out the pull request id, use the "[List pull requests](https://developer.github.com/v3/pulls/#list-pull-requests)" endpoint.
     */
    listForOrg: {
      (params?: Octokit.IssuesListForOrgParams): Promise<
        Octokit.Response<Octokit.IssuesListForOrgResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Note**: GitHub's REST API v3 considers every pull request an issue, but not every issue is a pull request. For this reason, "Issues" endpoints may return both issues and pull requests in the response. You can identify pull requests by the `pull_request` key.
     *
     * Be aware that the `id` of a pull request returned from "Issues" endpoints will be an _issue id_. To find out the pull request id, use the "[List pull requests](https://developer.github.com/v3/pulls/#list-pull-requests)" endpoint.
     */
    listForRepo: {
      (params?: Octokit.IssuesListForRepoParams): Promise<
        Octokit.Response<Octokit.IssuesListForRepoResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * The API returns a [`301 Moved Permanently` status](https://developer.github.com/v3/#http-redirects) if the issue was [transferred](https://help.github.com/articles/transferring-an-issue-to-another-repository/) to another repository. If the issue was transferred to or deleted from a repository where the authenticated user lacks read access, the API returns a `404 Not Found` status. If the issue was deleted from a repository where the authenticated user has read access, the API returns a `410 Gone` status. To receive webhook events for transferred and deleted issues, subscribe to the [`issues`](https://developer.github.com/v3/activity/events/types/#issuesevent) webhook.
     *
     * **Note**: GitHub's REST API v3 considers every pull request an issue, but not every issue is a pull request. For this reason, "Issues" endpoints may return both issues and pull requests in the response. You can identify pull requests by the `pull_request` key.
     *
     * Be aware that the `id` of a pull request returned from "Issues" endpoints will be an _issue id_. To find out the pull request id, use the "[List pull requests](https://developer.github.com/v3/pulls/#list-pull-requests)" endpoint.
     */
    get: {
      (params?: Octokit.IssuesGetParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.IssuesGetResponse>
      >;
      (params?: Octokit.IssuesGetParams): Promise<
        Octokit.Response<Octokit.IssuesGetResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Any user with pull access to a repository can create an issue. If [issues are disabled in the repository](https://help.github.com/articles/disabling-issues/), the API returns a `410 Gone` status.
     *
     * This endpoint triggers [notifications](https://help.github.com/articles/about-notifications/). Creating content too quickly using this endpoint may result in abuse rate limiting. See "[Abuse rate limits](https://developer.github.com/v3/#abuse-rate-limits)" and "[Dealing with abuse rate limits](https://developer.github.com/v3/guides/best-practices-for-integrators/#dealing-with-abuse-rate-limits)" for details.
     */
    create: {
      (params?: Octokit.IssuesCreateParams): Promise<
        Octokit.Response<Octokit.IssuesCreateResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Issue owners and users with push access can edit an issue.
     */
    update: {
      (params?: Octokit.IssuesUpdateParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.IssuesUpdateResponse>
      >;
      (params?: Octokit.IssuesUpdateParams): Promise<
        Octokit.Response<Octokit.IssuesUpdateResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Users with push access can lock an issue or pull request's conversation.
     *
     * Note that, if you choose not to pass any parameters, you'll need to set `Content-Length` to zero when calling out to this endpoint. For more information, see "[HTTP verbs](https://developer.github.com/v3/#http-verbs)."
     */
    lock: {
      (params?: Octokit.IssuesLockParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.IssuesLockResponse>
      >;
      (params?: Octokit.IssuesLockParams): Promise<
        Octokit.Response<Octokit.IssuesLockResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Users with push access can unlock an issue's conversation.
     */
    unlock: {
      (params?: Octokit.IssuesUnlockParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.IssuesUnlockResponse>
      >;
      (params?: Octokit.IssuesUnlockParams): Promise<
        Octokit.Response<Octokit.IssuesUnlockResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists the [available assignees](https://help.github.com/articles/assigning-issues-and-pull-requests-to-other-github-users/) for issues in a repository.
     */
    listAssignees: {
      (params?: Octokit.IssuesListAssigneesParams): Promise<
        Octokit.Response<Octokit.IssuesListAssigneesResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Checks if a user has permission to be assigned to an issue in this repository.
     *
     * If the `assignee` can be assigned to issues in the repository, a `204` header with no content is returned.
     *
     * Otherwise a `404` status code is returned.
     */
    checkAssignee: {
      (params?: Octokit.IssuesCheckAssigneeParams): Promise<
        Octokit.Response<Octokit.IssuesCheckAssigneeResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Adds up to 10 assignees to an issue. Users already assigned to an issue are not replaced.
     *
     * This example adds two assignees to the existing `octocat` assignee.
     */
    addAssignees: {
      (params?: Octokit.IssuesAddAssigneesParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.IssuesAddAssigneesResponse>
      >;
      (params?: Octokit.IssuesAddAssigneesParams): Promise<
        Octokit.Response<Octokit.IssuesAddAssigneesResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Removes one or more assignees from an issue.
     *
     * This example removes two of three assignees, leaving the `octocat` assignee.
     */
    removeAssignees: {
      (params?: Octokit.IssuesRemoveAssigneesParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.IssuesRemoveAssigneesResponse>
      >;
      (params?: Octokit.IssuesRemoveAssigneesParams): Promise<
        Octokit.Response<Octokit.IssuesRemoveAssigneesResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Issue Comments are ordered by ascending ID.
     */
    listComments: {
      (params?: Octokit.IssuesListCommentsParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.IssuesListCommentsResponse>
      >;
      (params?: Octokit.IssuesListCommentsParams): Promise<
        Octokit.Response<Octokit.IssuesListCommentsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * By default, Issue Comments are ordered by ascending ID.
     */
    listCommentsForRepo: {
      (params?: Octokit.IssuesListCommentsForRepoParams): Promise<
        Octokit.Response<Octokit.IssuesListCommentsForRepoResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getComment: {
      (params?: Octokit.IssuesGetCommentParams): Promise<
        Octokit.Response<Octokit.IssuesGetCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This endpoint triggers [notifications](https://help.github.com/articles/about-notifications/). Creating content too quickly using this endpoint may result in abuse rate limiting. See "[Abuse rate limits](https://developer.github.com/v3/#abuse-rate-limits)" and "[Dealing with abuse rate limits](https://developer.github.com/v3/guides/best-practices-for-integrators/#dealing-with-abuse-rate-limits)" for details.
     */
    createComment: {
      (params?: Octokit.IssuesCreateCommentParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.IssuesCreateCommentResponse>
      >;
      (params?: Octokit.IssuesCreateCommentParams): Promise<
        Octokit.Response<Octokit.IssuesCreateCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    updateComment: {
      (params?: Octokit.IssuesUpdateCommentParams): Promise<
        Octokit.Response<Octokit.IssuesUpdateCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    deleteComment: {
      (params?: Octokit.IssuesDeleteCommentParams): Promise<
        Octokit.Response<Octokit.IssuesDeleteCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listEvents: {
      (params?: Octokit.IssuesListEventsParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.IssuesListEventsResponse>
      >;
      (params?: Octokit.IssuesListEventsParams): Promise<
        Octokit.Response<Octokit.IssuesListEventsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listEventsForRepo: {
      (params?: Octokit.IssuesListEventsForRepoParams): Promise<
        Octokit.Response<Octokit.IssuesListEventsForRepoResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getEvent: {
      (params?: Octokit.IssuesGetEventParams): Promise<
        Octokit.Response<Octokit.IssuesGetEventResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listLabelsForRepo: {
      (params?: Octokit.IssuesListLabelsForRepoParams): Promise<
        Octokit.Response<Octokit.IssuesListLabelsForRepoResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getLabel: {
      (params?: Octokit.IssuesGetLabelParams): Promise<
        Octokit.Response<Octokit.IssuesGetLabelResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    createLabel: {
      (params?: Octokit.IssuesCreateLabelParams): Promise<
        Octokit.Response<Octokit.IssuesCreateLabelResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    updateLabel: {
      (params?: Octokit.IssuesUpdateLabelParams): Promise<
        Octokit.Response<Octokit.IssuesUpdateLabelResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    deleteLabel: {
      (params?: Octokit.IssuesDeleteLabelParams): Promise<
        Octokit.Response<Octokit.IssuesDeleteLabelResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listLabelsOnIssue: {
      (params?: Octokit.IssuesListLabelsOnIssueParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.IssuesListLabelsOnIssueResponse>
      >;
      (params?: Octokit.IssuesListLabelsOnIssueParams): Promise<
        Octokit.Response<Octokit.IssuesListLabelsOnIssueResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    addLabels: {
      (params?: Octokit.IssuesAddLabelsParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.IssuesAddLabelsResponse>
      >;
      (params?: Octokit.IssuesAddLabelsParams): Promise<
        Octokit.Response<Octokit.IssuesAddLabelsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Removes the specified label from the issue, and returns the remaining labels on the issue. This endpoint returns a `404 Not Found` status if the label does not exist.
     */
    removeLabel: {
      (params?: Octokit.IssuesRemoveLabelParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.IssuesRemoveLabelResponse>
      >;
      (params?: Octokit.IssuesRemoveLabelParams): Promise<
        Octokit.Response<Octokit.IssuesRemoveLabelResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    replaceLabels: {
      (params?: Octokit.IssuesReplaceLabelsParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.IssuesReplaceLabelsResponse>
      >;
      (params?: Octokit.IssuesReplaceLabelsParams): Promise<
        Octokit.Response<Octokit.IssuesReplaceLabelsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    removeLabels: {
      (params?: Octokit.IssuesRemoveLabelsParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.IssuesRemoveLabelsResponse>
      >;
      (params?: Octokit.IssuesRemoveLabelsParams): Promise<
        Octokit.Response<Octokit.IssuesRemoveLabelsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listLabelsForMilestone: {
      (
        params?: Octokit.IssuesListLabelsForMilestoneParamsDeprecatedNumber
      ): Promise<
        Octokit.Response<Octokit.IssuesListLabelsForMilestoneResponse>
      >;
      (params?: Octokit.IssuesListLabelsForMilestoneParams): Promise<
        Octokit.Response<Octokit.IssuesListLabelsForMilestoneResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listMilestonesForRepo: {
      (params?: Octokit.IssuesListMilestonesForRepoParams): Promise<
        Octokit.Response<Octokit.IssuesListMilestonesForRepoResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getMilestone: {
      (params?: Octokit.IssuesGetMilestoneParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.IssuesGetMilestoneResponse>
      >;
      (params?: Octokit.IssuesGetMilestoneParams): Promise<
        Octokit.Response<Octokit.IssuesGetMilestoneResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    createMilestone: {
      (params?: Octokit.IssuesCreateMilestoneParams): Promise<
        Octokit.Response<Octokit.IssuesCreateMilestoneResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    updateMilestone: {
      (params?: Octokit.IssuesUpdateMilestoneParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.IssuesUpdateMilestoneResponse>
      >;
      (params?: Octokit.IssuesUpdateMilestoneParams): Promise<
        Octokit.Response<Octokit.IssuesUpdateMilestoneResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    deleteMilestone: {
      (params?: Octokit.IssuesDeleteMilestoneParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.IssuesDeleteMilestoneResponse>
      >;
      (params?: Octokit.IssuesDeleteMilestoneParams): Promise<
        Octokit.Response<Octokit.IssuesDeleteMilestoneResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listEventsForTimeline: {
      (
        params?: Octokit.IssuesListEventsForTimelineParamsDeprecatedNumber
      ): Promise<Octokit.Response<Octokit.IssuesListEventsForTimelineResponse>>;
      (params?: Octokit.IssuesListEventsForTimelineParams): Promise<
        Octokit.Response<Octokit.IssuesListEventsForTimelineResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  licenses: {
    listCommonlyUsed: {
      (params?: Octokit.EmptyParams): Promise<
        Octokit.Response<Octokit.LicensesListCommonlyUsedResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    list: {
      (params?: Octokit.EmptyParams): Promise<
        Octokit.Response<Octokit.LicensesListResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    get: {
      (params?: Octokit.LicensesGetParams): Promise<
        Octokit.Response<Octokit.LicensesGetResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This method returns the contents of the repository's license file, if one is detected.
     *
     * Similar to [the repository contents API](https://developer.github.com/v3/repos/contents/#get-contents), this method also supports [custom media types](https://developer.github.com/v3/repos/contents/#custom-media-types) for retrieving the raw license content or rendered license HTML.
     */
    getForRepo: {
      (params?: Octokit.LicensesGetForRepoParams): Promise<
        Octokit.Response<Octokit.LicensesGetForRepoResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  markdown: {
    render: {
      (params?: Octokit.MarkdownRenderParams): Promise<
        Octokit.Response<Octokit.MarkdownRenderResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * You must send Markdown as plain text (using a `Content-Type` header of `text/plain` or `text/x-markdown`) to this endpoint, rather than using JSON format. In raw mode, [GitHub Flavored Markdown](https://github.github.com/gfm/) is not supported and Markdown will be rendered in plain format like a README.md file. Markdown content must be 400 KB or less.
     */
    renderRaw: {
      (params?: Octokit.MarkdownRenderRawParams): Promise<
        Octokit.Response<Octokit.MarkdownRenderRawResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  meta: {
    /**
     * This endpoint provides a list of GitHub's IP addresses. For more information, see "[About GitHub's IP addresses](https://help.github.com/articles/about-github-s-ip-addresses/)."
     */
    get: {
      (params?: Octokit.EmptyParams): Promise<
        Octokit.Response<Octokit.MetaGetResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  migrations: {
    /**
     * Initiates the generation of a migration archive.
     */
    startForOrg: {
      (params?: Octokit.MigrationsStartForOrgParams): Promise<
        Octokit.Response<Octokit.MigrationsStartForOrgResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists the most recent migrations.
     */
    listForOrg: {
      (params?: Octokit.MigrationsListForOrgParams): Promise<
        Octokit.Response<Octokit.MigrationsListForOrgResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Fetches the status of a migration.
     *
     * The `state` of a migration can be one of the following values:
     *
     * *   `pending`, which means the migration hasn't started yet.
     * *   `exporting`, which means the migration is in progress.
     * *   `exported`, which means the migration finished successfully.
     * *   `failed`, which means the migration failed.
     */
    getStatusForOrg: {
      (params?: Octokit.MigrationsGetStatusForOrgParams): Promise<
        Octokit.Response<Octokit.MigrationsGetStatusForOrgResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Fetches the URL to a migration archive.
     */
    getArchiveForOrg: {
      (params?: Octokit.MigrationsGetArchiveForOrgParams): Promise<
        Octokit.Response<Octokit.MigrationsGetArchiveForOrgResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Deletes a previous migration archive. Migration archives are automatically deleted after seven days.
     */
    deleteArchiveForOrg: {
      (params?: Octokit.MigrationsDeleteArchiveForOrgParams): Promise<
        Octokit.Response<Octokit.MigrationsDeleteArchiveForOrgResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Unlocks a repository that was locked for migration. You should unlock each migrated repository and [delete them](https://developer.github.com/v3/repos/#delete-a-repository) when the migration is complete and you no longer need the source data.
     */
    unlockRepoForOrg: {
      (params?: Octokit.MigrationsUnlockRepoForOrgParams): Promise<
        Octokit.Response<Octokit.MigrationsUnlockRepoForOrgResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Start a source import to a GitHub repository using GitHub Importer.
     */
    startImport: {
      (params?: Octokit.MigrationsStartImportParams): Promise<
        Octokit.Response<Octokit.MigrationsStartImportResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * View the progress of an import.
     *
     * **Import status**
     *
     * This section includes details about the possible values of the `status` field of the Import Progress response.
     *
     * An import that does not have errors will progress through these steps:
     *
     * *   `detecting` - the "detection" step of the import is in progress because the request did not include a `vcs` parameter. The import is identifying the type of source control present at the URL.
     * *   `importing` - the "raw" step of the import is in progress. This is where commit data is fetched from the original repository. The import progress response will include `commit_count` (the total number of raw commits that will be imported) and `percent` (0 - 100, the current progress through the import).
     * *   `mapping` - the "rewrite" step of the import is in progress. This is where SVN branches are converted to Git branches, and where author updates are applied. The import progress response does not include progress information.
     * *   `pushing` - the "push" step of the import is in progress. This is where the importer updates the repository on GitHub. The import progress response will include `push_percent`, which is the percent value reported by `git push` when it is "Writing objects".
     * *   `complete` - the import is complete, and the repository is ready on GitHub.
     *
     * If there are problems, you will see one of these in the `status` field:
     *
     * *   `auth_failed` - the import requires authentication in order to connect to the original repository. To update authentication for the import, please see the [Update Existing Import](https://developer.github.com/v3/migrations/source_imports/#update-existing-import) section.
     * *   `error` - the import encountered an error. The import progress response will include the `failed_step` and an error message. Contact [GitHub Support](https://github.com/contact) for more information.
     * *   `detection_needs_auth` - the importer requires authentication for the originating repository to continue detection. To update authentication for the import, please see the [Update Existing Import](https://developer.github.com/v3/migrations/source_imports/#update-existing-import) section.
     * *   `detection_found_nothing` - the importer didn't recognize any source control at the URL. To resolve, [Cancel the import](https://developer.github.com/v3/migrations/source_imports/#cancel-an-import) and [retry](https://developer.github.com/v3/migrations/source_imports/#start-an-import) with the correct URL.
     * *   `detection_found_multiple` - the importer found several projects or repositories at the provided URL. When this is the case, the Import Progress response will also include a `project_choices` field with the possible project choices as values. To update project choice, please see the [Update Existing Import](https://developer.github.com/v3/migrations/source_imports/#update-existing-import) section.
     *
     * **The project_choices field**
     *
     * When multiple projects are found at the provided URL, the response hash will include a `project_choices` field, the value of which is an array of hashes each representing a project choice. The exact key/value pairs of the project hashes will differ depending on the version control type.
     *
     * **Git LFS related fields**
     *
     * This section includes details about Git LFS related fields that may be present in the Import Progress response.
     *
     * *   `use_lfs` - describes whether the import has been opted in or out of using Git LFS. The value can be `opt_in`, `opt_out`, or `undecided` if no action has been taken.
     * *   `has_large_files` - the boolean value describing whether files larger than 100MB were found during the `importing` step.
     * *   `large_files_size` - the total size in gigabytes of files larger than 100MB found in the originating repository.
     * *   `large_files_count` - the total number of files larger than 100MB found in the originating repository. To see a list of these files, make a "Get Large Files" request.
     */
    getImportProgress: {
      (params?: Octokit.MigrationsGetImportProgressParams): Promise<
        Octokit.Response<Octokit.MigrationsGetImportProgressResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * An import can be updated with credentials or a project choice by passing in the appropriate parameters in this API request. If no parameters are provided, the import will be restarted.
     *
     * Some servers (e.g. TFS servers) can have several projects at a single URL. In those cases the import progress will have the status `detection_found_multiple` and the Import Progress response will include a `project_choices` array. You can select the project to import by providing one of the objects in the `project_choices` array in the update request.
     *
     * The following example demonstrates the workflow for updating an import with "project1" as the project choice. Given a `project_choices` array like such:
     *
     * To restart an import, no parameters are provided in the update request.
     */
    updateImport: {
      (params?: Octokit.MigrationsUpdateImportParams): Promise<
        Octokit.Response<Octokit.MigrationsUpdateImportResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Each type of source control system represents authors in a different way. For example, a Git commit author has a display name and an email address, but a Subversion commit author just has a username. The GitHub Importer will make the author information valid, but the author might not be correct. For example, it will change the bare Subversion username `hubot` into something like `hubot <hubot@12341234-abab-fefe-8787-fedcba987654>`.
     *
     * This API method and the "Map a commit author" method allow you to provide correct Git author information.
     */
    getCommitAuthors: {
      (params?: Octokit.MigrationsGetCommitAuthorsParams): Promise<
        Octokit.Response<Octokit.MigrationsGetCommitAuthorsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Update an author's identity for the import. Your application can continue updating authors any time before you push new commits to the repository.
     */
    mapCommitAuthor: {
      (params?: Octokit.MigrationsMapCommitAuthorParams): Promise<
        Octokit.Response<Octokit.MigrationsMapCommitAuthorResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * You can import repositories from Subversion, Mercurial, and TFS that include files larger than 100MB. This ability is powered by [Git LFS](https://git-lfs.github.com). You can learn more about our LFS feature and working with large files [on our help site](https://help.github.com/articles/versioning-large-files/).
     */
    setLfsPreference: {
      (params?: Octokit.MigrationsSetLfsPreferenceParams): Promise<
        Octokit.Response<Octokit.MigrationsSetLfsPreferenceResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * List files larger than 100MB found during the import
     */
    getLargeFiles: {
      (params?: Octokit.MigrationsGetLargeFilesParams): Promise<
        Octokit.Response<Octokit.MigrationsGetLargeFilesResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Stop an import for a repository.
     */
    cancelImport: {
      (params?: Octokit.MigrationsCancelImportParams): Promise<
        Octokit.Response<Octokit.MigrationsCancelImportResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Initiates the generation of a user migration archive.
     */
    startForAuthenticatedUser: {
      (params?: Octokit.MigrationsStartForAuthenticatedUserParams): Promise<
        Octokit.Response<Octokit.MigrationsStartForAuthenticatedUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists all migrations a user has started.
     */
    listForAuthenticatedUser: {
      (params?: Octokit.MigrationsListForAuthenticatedUserParams): Promise<
        Octokit.Response<Octokit.MigrationsListForAuthenticatedUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Fetches a single user migration. The response includes the `state` of the migration, which can be one of the following values:
     *
     * *   `pending` - the migration hasn't started yet.
     * *   `exporting` - the migration is in progress.
     * *   `exported` - the migration finished successfully.
     * *   `failed` - the migration failed.
     *
     * Once the migration has been `exported` you can [download the migration archive](https://developer.github.com/v3/migrations/users/#download-a-user-migration-archive).
     */
    getStatusForAuthenticatedUser: {
      (params?: Octokit.MigrationsGetStatusForAuthenticatedUserParams): Promise<
        Octokit.Response<
          Octokit.MigrationsGetStatusForAuthenticatedUserResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Fetches the URL to download the migration archive as a `tar.gz` file. Depending on the resources your repository uses, the migration archive can contain JSON files with data for these objects:
     *
     * *   attachments
     * *   bases
     * *   commit\_comments
     * *   issue\_comments
     * *   issue\_events
     * *   issues
     * *   milestones
     * *   organizations
     * *   projects
     * *   protected\_branches
     * *   pull\_request\_reviews
     * *   pull\_requests
     * *   releases
     * *   repositories
     * *   review\_comments
     * *   schema
     * *   users
     *
     * The archive will also contain an `attachments` directory that includes all attachment files uploaded to GitHub.com and a `repositories` directory that contains the repository's Git data.
     */
    getArchiveForAuthenticatedUser: {
      (
        params?: Octokit.MigrationsGetArchiveForAuthenticatedUserParams
      ): Promise<
        Octokit.Response<
          Octokit.MigrationsGetArchiveForAuthenticatedUserResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Deletes a previous migration archive. Downloadable migration archives are automatically deleted after seven days. Migration metadata, which is returned in the [Get a list of user migrations](https://developer.github.com/v3/migrations/users/#get-a-list-of-user-migrations) and [Get the status of a user migration](https://developer.github.com/v3/migrations/users/#get-the-status-of-a-user-migration) endpoints, will continue to be available even after an archive is deleted.
     */
    deleteArchiveForAuthenticatedUser: {
      (
        params?: Octokit.MigrationsDeleteArchiveForAuthenticatedUserParams
      ): Promise<
        Octokit.Response<
          Octokit.MigrationsDeleteArchiveForAuthenticatedUserResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Unlocks a repository. You can lock repositories when you [start a user migration](https://developer.github.com/v3/migrations/users/#start-a-user-migration). Once the migration is complete you can unlock each repository to begin using it again or [delete the repository](https://developer.github.com/v3/repos/#delete-a-repository) if you no longer need the source data. Returns a status of `404 Not Found` if the repository is not locked.
     */
    unlockRepoForAuthenticatedUser: {
      (
        params?: Octokit.MigrationsUnlockRepoForAuthenticatedUserParams
      ): Promise<
        Octokit.Response<
          Octokit.MigrationsUnlockRepoForAuthenticatedUserResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  oauthAuthorizations: {
    /**
     * You can use this API to list the set of OAuth applications that have been granted access to your account. Unlike the [list your authorizations](https://developer.github.com/v3/oauth_authorizations/#list-your-authorizations) API, this API does not manage individual tokens. This API will return one entry for each OAuth application that has been granted access to your account, regardless of the number of tokens an application has generated for your user. The list of OAuth applications returned matches what is shown on [the application authorizations settings screen within GitHub](https://github.com/settings/applications#authorized). The `scopes` returned are the union of scopes authorized for the application. For example, if an application has one token with `repo` scope and another token with `user` scope, the grant will return `["repo", "user"]`.
     */
    listGrants: {
      (params?: Octokit.OauthAuthorizationsListGrantsParams): Promise<
        Octokit.Response<Octokit.OauthAuthorizationsListGrantsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getGrant: {
      (params?: Octokit.OauthAuthorizationsGetGrantParams): Promise<
        Octokit.Response<Octokit.OauthAuthorizationsGetGrantResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Deleting an OAuth application's grant will also delete all OAuth tokens associated with the application for your user. Once deleted, the application has no access to your account and is no longer listed on [the application authorizations settings screen within GitHub](https://github.com/settings/applications#authorized).
     */
    deleteGrant: {
      (params?: Octokit.OauthAuthorizationsDeleteGrantParams): Promise<
        Octokit.Response<Octokit.OauthAuthorizationsDeleteGrantResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listAuthorizations: {
      (params?: Octokit.OauthAuthorizationsListAuthorizationsParams): Promise<
        Octokit.Response<Octokit.OauthAuthorizationsListAuthorizationsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getAuthorization: {
      (params?: Octokit.OauthAuthorizationsGetAuthorizationParams): Promise<
        Octokit.Response<Octokit.OauthAuthorizationsGetAuthorizationResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Creates OAuth tokens using [Basic Authentication](https://developer.github.com/v3/auth#basic-authentication). If you have two-factor authentication setup, Basic Authentication for this endpoint requires that you use a one-time password (OTP) and your username and password instead of tokens. For more information, see "[Woking with two-factor authentication](https://developer.github.com/v3/auth/#working-with-two-factor-authentication)."
     *
     * You can use this endpoint to create multiple OAuth tokens instead of implementing the [web flow](https://developer.github.com/apps/building-oauth-apps/authorizing-oauth-apps/).
     *
     * To create tokens for a particular OAuth application using this endpoint, you must authenticate as the user you want to create an authorization for and provide the app's client ID and secret, found on your OAuth application's settings page. If your OAuth application intends to create multiple tokens for one user, use `fingerprint` to differentiate between them.
     *
     * You can also create tokens on GitHub from the [personal access tokens settings](https://github.com/settings/tokens) page. Read more about these tokens in [the GitHub Help documentation](https://help.github.com/articles/creating-an-access-token-for-command-line-use).
     *
     * Organizations that enforce SAML SSO require personal access tokens to be whitelisted. Read more about whitelisting tokens in [the GitHub Help documentation](https://help.github.com/articles/about-identity-and-access-management-with-saml-single-sign-on).
     */
    createAuthorization: {
      (params?: Octokit.OauthAuthorizationsCreateAuthorizationParams): Promise<
        Octokit.Response<Octokit.OauthAuthorizationsCreateAuthorizationResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Creates a new authorization for the specified OAuth application, only if an authorization for that application doesn't already exist for the user. The URL includes the 20 character client ID for the OAuth app that is requesting the token. It returns the user's existing authorization for the application if one is present. Otherwise, it creates and returns a new one.
     *
     * If you have two-factor authentication setup, Basic Authentication for this endpoint requires that you use a one-time password (OTP) and your username and password instead of tokens. For more information, see "[Woking with two-factor authentication](https://developer.github.com/v3/auth/#working-with-two-factor-authentication)."
     */
    getOrCreateAuthorizationForApp: {
      (
        params?: Octokit.OauthAuthorizationsGetOrCreateAuthorizationForAppParams
      ): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This method will create a new authorization for the specified OAuth application, only if an authorization for that application and fingerprint do not already exist for the user. The URL includes the 20 character client ID for the OAuth app that is requesting the token. `fingerprint` is a unique string to distinguish an authorization from others created for the same client ID and user. It returns the user's existing authorization for the application if one is present. Otherwise, it creates and returns a new one.
     *
     * If you have two-factor authentication setup, Basic Authentication for this endpoint requires that you use a one-time password (OTP) and your username and password instead of tokens. For more information, see "[Woking with two-factor authentication](https://developer.github.com/v3/auth/#working-with-two-factor-authentication)."
     */
    getOrCreateAuthorizationForAppAndFingerprint: {
      (
        params?: Octokit.OauthAuthorizationsGetOrCreateAuthorizationForAppAndFingerprintParams
      ): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This method will create a new authorization for the specified OAuth application, only if an authorization for that application and fingerprint do not already exist for the user. The URL includes the 20 character client ID for the OAuth app that is requesting the token. `fingerprint` is a unique string to distinguish an authorization from others created for the same client ID and user. It returns the user's existing authorization for the application if one is present. Otherwise, it creates and returns a new one.
     *
     * If you have two-factor authentication setup, Basic Authentication for this endpoint requires that you use a one-time password (OTP) and your username and password instead of tokens. For more information, see "[Woking with two-factor authentication](https://developer.github.com/v3/auth/#working-with-two-factor-authentication)."
     */
    getOrCreateAuthorizationForAppFingerprint: {
      (
        params?: Octokit.OauthAuthorizationsGetOrCreateAuthorizationForAppFingerprintParams
      ): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * If you have two-factor authentication setup, Basic Authentication for this endpoint requires that you use a one-time password (OTP) and your username and password instead of tokens. For more information, see "[Woking with two-factor authentication](https://developer.github.com/v3/auth/#working-with-two-factor-authentication)."
     *
     * You can only send one of these scope keys at a time.
     */
    updateAuthorization: {
      (params?: Octokit.OauthAuthorizationsUpdateAuthorizationParams): Promise<
        Octokit.Response<Octokit.OauthAuthorizationsUpdateAuthorizationResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    deleteAuthorization: {
      (params?: Octokit.OauthAuthorizationsDeleteAuthorizationParams): Promise<
        Octokit.Response<Octokit.OauthAuthorizationsDeleteAuthorizationResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * OAuth applications can use a special API method for checking OAuth token validity without running afoul of normal rate limits for failed login attempts. Authentication works differently with this particular endpoint. You must use [Basic Authentication](https://developer.github.com/v3/auth#basic-authentication) when accessing it, where the username is the OAuth application `client_id` and the password is its `client_secret`. Invalid tokens will return `404 NOT FOUND`.
     */
    checkAuthorization: {
      (params?: Octokit.OauthAuthorizationsCheckAuthorizationParams): Promise<
        Octokit.Response<Octokit.OauthAuthorizationsCheckAuthorizationResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * OAuth applications can use this API method to reset a valid OAuth token without end user involvement. Applications must save the "token" property in the response, because changes take effect immediately. You must use [Basic Authentication](https://developer.github.com/v3/auth#basic-authentication) when accessing it, where the username is the OAuth application `client_id` and the password is its `client_secret`. Invalid tokens will return `404 NOT FOUND`.
     */
    resetAuthorization: {
      (params?: Octokit.OauthAuthorizationsResetAuthorizationParams): Promise<
        Octokit.Response<Octokit.OauthAuthorizationsResetAuthorizationResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * OAuth application owners can revoke a single token for an OAuth application. You must use [Basic Authentication](https://developer.github.com/v3/auth#basic-authentication) for this method, where the username is the OAuth application `client_id` and the password is its `client_secret`.
     */
    revokeAuthorizationForApplication: {
      (
        params?: Octokit.OauthAuthorizationsRevokeAuthorizationForApplicationParams
      ): Promise<
        Octokit.Response<
          Octokit.OauthAuthorizationsRevokeAuthorizationForApplicationResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * OAuth application owners can revoke a grant for their OAuth application and a specific user. You must use [Basic Authentication](https://developer.github.com/v3/auth#basic-authentication) for this method, where the username is the OAuth application `client_id` and the password is its `client_secret`. You must also provide a valid token as `:access_token` and the grant for the token's owner will be deleted.
     *
     * Deleting an OAuth application's grant will also delete all OAuth tokens associated with the application for the user. Once deleted, the application will have no access to the user's account and will no longer be listed on [the application authorizations settings screen within GitHub](https://github.com/settings/applications#authorized).
     */
    revokeGrantForApplication: {
      (
        params?: Octokit.OauthAuthorizationsRevokeGrantForApplicationParams
      ): Promise<
        Octokit.Response<
          Octokit.OauthAuthorizationsRevokeGrantForApplicationResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  orgs: {
    /**
     * List organizations for the authenticated user.
     *
     * **OAuth scope requirements**
     *
     * This only lists organizations that your authorization allows you to operate on in some way (e.g., you can list teams with `read:org` scope, you can publicize your organization membership with `user` scope, etc.). Therefore, this API requires at least `user` or `read:org` scope. OAuth requests with insufficient scope receive a `403 Forbidden` response.
     */
    listForAuthenticatedUser: {
      (params?: Octokit.OrgsListForAuthenticatedUserParams): Promise<
        Octokit.Response<Octokit.OrgsListForAuthenticatedUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists all organizations, in the order that they were created on GitHub.
     *
     * **Note:** Pagination is powered exclusively by the `since` parameter. Use the [Link header](https://developer.github.com/v3/#link-header) to get the URL for the next page of organizations.
     */
    list: {
      (params?: Octokit.OrgsListParams): Promise<
        Octokit.Response<Octokit.OrgsListResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * List [public organization memberships](https://help.github.com/articles/publicizing-or-concealing-organization-membership) for the specified user.
     *
     * This method only lists _public_ memberships, regardless of authentication. If you need to fetch all of the organization memberships (public and private) for the authenticated user, use the [List your organizations](https://developer.github.com/v3/orgs/#list-your-organizations) API instead.
     */
    listForUser: {
      (params?: Octokit.OrgsListForUserParams): Promise<
        Octokit.Response<Octokit.OrgsListForUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * To see many of the organization response values, you need to be an authenticated organization owner with the `admin:org` scope. When the value of `two_factor_requirement_enabled` is `true`, the organization requires all members, billing managers, and outside collaborators to enable [two-factor authentication](https://help.github.com/articles/securing-your-account-with-two-factor-authentication-2fa/).
     *
     * GitHub Apps with the `Organization plan` permission can use this endpoint to retrieve information about an organization's GitHub plan. See "[Authenticating with GitHub Apps](https://developer.github.com/apps/building-github-apps/authenticating-with-github-apps/)" for details. For an example response, see "[Response with GitHub plan information](https://developer.github.com/v3/orgs/#response-with-github-plan-information)."
     */
    get: {
      (params?: Octokit.OrgsGetParams): Promise<
        Octokit.Response<Octokit.OrgsGetResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Note:** The new `members_allowed_repository_creation_type` replaces the functionality of `members_can_create_repositories`.
     *
     * Setting `members_allowed_repository_creation_type` will override the value of `members_can_create_repositories` in the following ways:
     *
     * *   Setting `members_allowed_repository_creation_type` to `all` or `private` sets `members_can_create_repositories` to `true`.
     * *   Setting `members_allowed_repository_creation_type` to `none` sets `members_can_create_repositories` to `false`.
     * *   If you omit `members_allowed_repository_creation_type`, `members_can_create_repositories` is not modified.
     */
    update: {
      (params?: Octokit.OrgsUpdateParams): Promise<
        Octokit.Response<Octokit.OrgsUpdateResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * List the users blocked by an organization.
     */
    listBlockedUsers: {
      (params?: Octokit.OrgsListBlockedUsersParams): Promise<
        Octokit.Response<Octokit.OrgsListBlockedUsersResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * If the user is blocked:
     *
     * If the user is not blocked:
     */
    checkBlockedUser: {
      (params?: Octokit.OrgsCheckBlockedUserParams): Promise<
        Octokit.Response<Octokit.OrgsCheckBlockedUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    blockUser: {
      (params?: Octokit.OrgsBlockUserParams): Promise<
        Octokit.Response<Octokit.OrgsBlockUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    unblockUser: {
      (params?: Octokit.OrgsUnblockUserParams): Promise<
        Octokit.Response<Octokit.OrgsUnblockUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listHooks: {
      (params?: Octokit.OrgsListHooksParams): Promise<
        Octokit.Response<Octokit.OrgsListHooksResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getHook: {
      (params?: Octokit.OrgsGetHookParams): Promise<
        Octokit.Response<Octokit.OrgsGetHookResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Here's how you can create a hook that posts payloads in JSON format:
     */
    createHook: {
      (params?: Octokit.OrgsCreateHookParams): Promise<
        Octokit.Response<Octokit.OrgsCreateHookResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    updateHook: {
      (params?: Octokit.OrgsUpdateHookParams): Promise<
        Octokit.Response<Octokit.OrgsUpdateHookResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This will trigger a [ping event](https://developer.github.com/webhooks/#ping-event) to be sent to the hook.
     */
    pingHook: {
      (params?: Octokit.OrgsPingHookParams): Promise<
        Octokit.Response<Octokit.OrgsPingHookResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    deleteHook: {
      (params?: Octokit.OrgsDeleteHookParams): Promise<
        Octokit.Response<Octokit.OrgsDeleteHookResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * List all users who are members of an organization. If the authenticated user is also a member of this organization then both concealed and public members will be returned.
     */
    listMembers: {
      (params?: Octokit.OrgsListMembersParams): Promise<
        Octokit.Response<Octokit.OrgsListMembersResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Check if a user is, publicly or privately, a member of the organization.
     */
    checkMembership: {
      (params?: Octokit.OrgsCheckMembershipParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Removing a user from this list will remove them from all teams and they will no longer have any access to the organization's repositories.
     */
    removeMember: {
      (params?: Octokit.OrgsRemoveMemberParams): Promise<
        Octokit.Response<Octokit.OrgsRemoveMemberResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Members of an organization can choose to have their membership publicized or not.
     */
    listPublicMembers: {
      (params?: Octokit.OrgsListPublicMembersParams): Promise<
        Octokit.Response<Octokit.OrgsListPublicMembersResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    checkPublicMembership: {
      (params?: Octokit.OrgsCheckPublicMembershipParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * The user can publicize their own membership. (A user cannot publicize the membership for another user.)
     *
     * Note that you'll need to set `Content-Length` to zero when calling out to this endpoint. For more information, see "[HTTP verbs](https://developer.github.com/v3/#http-verbs)."
     */
    publicizeMembership: {
      (params?: Octokit.OrgsPublicizeMembershipParams): Promise<
        Octokit.Response<Octokit.OrgsPublicizeMembershipResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    concealMembership: {
      (params?: Octokit.OrgsConcealMembershipParams): Promise<
        Octokit.Response<Octokit.OrgsConcealMembershipResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * In order to get a user's membership with an organization, the authenticated user must be an organization member.
     */
    getMembership: {
      (params?: Octokit.OrgsGetMembershipParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Only authenticated organization owners can add a member to the organization or update the member's role.
     *
     * *   If the authenticated user is _adding_ a member to the organization, the invited user will receive an email inviting them to the organization. The user's [membership status](https://developer.github.com/v3/orgs/members/#get-organization-membership) will be `pending` until they accept the invitation.
     *
     * *   Authenticated users can _update_ a user's membership by passing the `role` parameter. If the authenticated user changes a member's role to `admin`, the affected user will receive an email notifying them that they've been made an organization owner. If the authenticated user changes an owner's role to `member`, no email will be sent.
     *
     * **Rate limits**
     *
     * To prevent abuse, the authenticated user is limited to 50 organization invitations per 24 hour period. If the organization is more than one month old or on a paid plan, the limit is 500 invitations per 24 hour period.
     */
    addOrUpdateMembership: {
      (params?: Octokit.OrgsAddOrUpdateMembershipParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * In order to remove a user's membership with an organization, the authenticated user must be an organization owner.
     *
     * If the specified user is an active member of the organization, this will remove them from the organization. If the specified user has been invited to the organization, this will cancel their invitation. The specified user will receive an email notification in both cases.
     */
    removeMembership: {
      (params?: Octokit.OrgsRemoveMembershipParams): Promise<
        Octokit.Response<Octokit.OrgsRemoveMembershipResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * List all teams associated with an invitation. In order to see invitations in an organization, the authenticated user must be an organization owner.
     */
    listInvitationTeams: {
      (params?: Octokit.OrgsListInvitationTeamsParams): Promise<
        Octokit.Response<Octokit.OrgsListInvitationTeamsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * The return hash contains a `role` field which refers to the Organization Invitation role and will be one of the following values: `direct_member`, `admin`, `billing_manager`, `hiring_manager`, or `reinstate`. If the invitee is not a GitHub member, the `login` field in the return hash will be `null`.
     */
    listPendingInvitations: {
      (params?: Octokit.OrgsListPendingInvitationsParams): Promise<
        Octokit.Response<Octokit.OrgsListPendingInvitationsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Invite people to an organization by using their GitHub user ID or their email address. In order to create invitations in an organization, the authenticated user must be an organization owner.
     *
     * This endpoint triggers [notifications](https://help.github.com/articles/about-notifications/). Creating content too quickly using this endpoint may result in abuse rate limiting. See "[Abuse rate limits](https://developer.github.com/v3/#abuse-rate-limits)" and "[Dealing with abuse rate limits](https://developer.github.com/v3/guides/best-practices-for-integrators/#dealing-with-abuse-rate-limits)" for details.
     */
    createInvitation: {
      (params?: Octokit.OrgsCreateInvitationParams): Promise<
        Octokit.Response<Octokit.OrgsCreateInvitationResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listMemberships: {
      (params?: Octokit.OrgsListMembershipsParams): Promise<
        Octokit.Response<Octokit.OrgsListMembershipsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getMembershipForAuthenticatedUser: {
      (params?: Octokit.OrgsGetMembershipForAuthenticatedUserParams): Promise<
        Octokit.Response<Octokit.OrgsGetMembershipForAuthenticatedUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    updateMembership: {
      (params?: Octokit.OrgsUpdateMembershipParams): Promise<
        Octokit.Response<Octokit.OrgsUpdateMembershipResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * List all users who are outside collaborators of an organization.
     */
    listOutsideCollaborators: {
      (params?: Octokit.OrgsListOutsideCollaboratorsParams): Promise<
        Octokit.Response<Octokit.OrgsListOutsideCollaboratorsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Removing a user from this list will remove them from all the organization's repositories.
     */
    removeOutsideCollaborator: {
      (params?: Octokit.OrgsRemoveOutsideCollaboratorParams): Promise<
        Octokit.Response<Octokit.OrgsRemoveOutsideCollaboratorResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * When an organization member is converted to an outside collaborator, they'll only have access to the repositories that their current team membership allows. The user will no longer be a member of the organization. For more information, see "[Converting an organization member to an outside collaborator](https://help.github.com/articles/converting-an-organization-member-to-an-outside-collaborator/)".
     */
    convertMemberToOutsideCollaborator: {
      (params?: Octokit.OrgsConvertMemberToOutsideCollaboratorParams): Promise<
        Octokit.Response<Octokit.OrgsConvertMemberToOutsideCollaboratorResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  projects: {
    /**
     * Lists the projects in a repository. Returns a `404 Not Found` status if projects are disabled in the repository. If you do not have sufficient privileges to perform this action, a `401 Unauthorized` or `410 Gone` status is returned.
     */
    listForRepo: {
      (params?: Octokit.ProjectsListForRepoParams): Promise<
        Octokit.Response<Octokit.ProjectsListForRepoResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists the projects in an organization. Returns a `404 Not Found` status if projects are disabled in the organization. If you do not have sufficient privileges to perform this action, a `401 Unauthorized` or `410 Gone` status is returned.
     *
     * s
     */
    listForOrg: {
      (params?: Octokit.ProjectsListForOrgParams): Promise<
        Octokit.Response<Octokit.ProjectsListForOrgResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listForUser: {
      (params?: Octokit.ProjectsListForUserParams): Promise<
        Octokit.Response<Octokit.ProjectsListForUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Gets a project by its `id`. Returns a `404 Not Found` status if projects are disabled. If you do not have sufficient privileges to perform this action, a `401 Unauthorized` or `410 Gone` status is returned.
     */
    get: {
      (params?: Octokit.ProjectsGetParams): Promise<
        Octokit.Response<Octokit.ProjectsGetResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Creates a repository project board. Returns a `404 Not Found` status if projects are disabled in the repository. If you do not have sufficient privileges to perform this action, a `401 Unauthorized` or `410 Gone` status is returned.
     */
    createForRepo: {
      (params?: Octokit.ProjectsCreateForRepoParams): Promise<
        Octokit.Response<Octokit.ProjectsCreateForRepoResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Creates an organization project board. Returns a `404 Not Found` status if projects are disabled in the organization. If you do not have sufficient privileges to perform this action, a `401 Unauthorized` or `410 Gone` status is returned.
     */
    createForOrg: {
      (params?: Octokit.ProjectsCreateForOrgParams): Promise<
        Octokit.Response<Octokit.ProjectsCreateForOrgResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    createForAuthenticatedUser: {
      (params?: Octokit.ProjectsCreateForAuthenticatedUserParams): Promise<
        Octokit.Response<Octokit.ProjectsCreateForAuthenticatedUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Updates a project board's information. Returns a `404 Not Found` status if projects are disabled. If you do not have sufficient privileges to perform this action, a `401 Unauthorized` or `410 Gone` status is returned.
     */
    update: {
      (params?: Octokit.ProjectsUpdateParams): Promise<
        Octokit.Response<Octokit.ProjectsUpdateResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Deletes a project board. Returns a `404 Not Found` status if projects are disabled.
     */
    delete: {
      (params?: Octokit.ProjectsDeleteParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };

    listCards: {
      (params?: Octokit.ProjectsListCardsParams): Promise<
        Octokit.Response<Octokit.ProjectsListCardsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getCard: {
      (params?: Octokit.ProjectsGetCardParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Note**: GitHub's REST API v3 considers every pull request an issue, but not every issue is a pull request. For this reason, "Issues" endpoints may return both issues and pull requests in the response. You can identify pull requests by the `pull_request` key.
     *
     * Be aware that the `id` of a pull request returned from "Issues" endpoints will be an _issue id_. To find out the pull request id, use the "[List pull requests](https://developer.github.com/v3/pulls/#list-pull-requests)" endpoint.
     */
    createCard: {
      (params?: Octokit.ProjectsCreateCardParams): Promise<
        Octokit.Response<Octokit.ProjectsCreateCardResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    updateCard: {
      (params?: Octokit.ProjectsUpdateCardParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };

    deleteCard: {
      (params?: Octokit.ProjectsDeleteCardParams): Promise<
        Octokit.Response<Octokit.ProjectsDeleteCardResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    moveCard: {
      (params?: Octokit.ProjectsMoveCardParams): Promise<
        Octokit.Response<Octokit.ProjectsMoveCardResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists the collaborators for an organization project. For a project, the list of collaborators includes outside collaborators, organization members that are direct collaborators, organization members with access through team memberships, organization members with access through default organization permissions, and organization owners. You must be an organization owner or a project `admin` to list collaborators.
     */
    listCollaborators: {
      (params?: Octokit.ProjectsListCollaboratorsParams): Promise<
        Octokit.Response<Octokit.ProjectsListCollaboratorsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Returns the collaborator's permission level for an organization project. Possible values for the `permission` key: `admin`, `write`, `read`, `none`. You must be an organization owner or a project `admin` to review a user's permission level.
     */
    reviewUserPermissionLevel: {
      (params?: Octokit.ProjectsReviewUserPermissionLevelParams): Promise<
        Octokit.Response<Octokit.ProjectsReviewUserPermissionLevelResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Adds a collaborator to a an organization project and sets their permission level. You must be an organization owner or a project `admin` to add a collaborator.
     */
    addCollaborator: {
      (params?: Octokit.ProjectsAddCollaboratorParams): Promise<
        Octokit.Response<Octokit.ProjectsAddCollaboratorResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Removes a collaborator from an organization project. You must be an organization owner or a project `admin` to remove a collaborator.
     */
    removeCollaborator: {
      (params?: Octokit.ProjectsRemoveCollaboratorParams): Promise<
        Octokit.Response<Octokit.ProjectsRemoveCollaboratorResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listColumns: {
      (params?: Octokit.ProjectsListColumnsParams): Promise<
        Octokit.Response<Octokit.ProjectsListColumnsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getColumn: {
      (params?: Octokit.ProjectsGetColumnParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };

    createColumn: {
      (params?: Octokit.ProjectsCreateColumnParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };

    updateColumn: {
      (params?: Octokit.ProjectsUpdateColumnParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };

    deleteColumn: {
      (params?: Octokit.ProjectsDeleteColumnParams): Promise<
        Octokit.Response<Octokit.ProjectsDeleteColumnResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    moveColumn: {
      (params?: Octokit.ProjectsMoveColumnParams): Promise<
        Octokit.Response<Octokit.ProjectsMoveColumnResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  pulls: {
    /**
     * Draft pull requests are available in public repositories with GitHub Free and GitHub Pro, and in public and private repositories with GitHub Team and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     */
    list: {
      (params?: Octokit.PullsListParams): Promise<
        Octokit.Response<Octokit.PullsListResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Draft pull requests are available in public repositories with GitHub Free and GitHub Pro, and in public and private repositories with GitHub Team and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * Lists details of a pull request by providing its number.
     *
     * When you get, [create](https://developer.github.com/v3/pulls/#create-a-pull-request), or [edit](https://developer.github.com/v3/pulls/#update-a-pull-request) a pull request, GitHub creates a merge commit to test whether the pull request can be automatically merged into the base branch. This test commit is not added to the base branch or the head branch. You can review the status of the test commit using the `mergeable` key. For more information, see "[Checking mergeability of pull requests](https://developer.github.com/v3/git/#checking-mergeability-of-pull-requests)".
     *
     * The value of the `mergeable` attribute can be `true`, `false`, or `null`. If the value is `null`, then GitHub has started a background job to compute the mergeability. After giving the job time to complete, resubmit the request. When the job finishes, you will see a non-`null` value for the `mergeable` attribute in the response. If `mergeable` is `true`, then `merge_commit_sha` will be the SHA of the _test_ merge commit.
     *
     * The value of the `merge_commit_sha` attribute changes depending on the state of the pull request. Before merging a pull request, the `merge_commit_sha` attribute holds the SHA of the _test_ merge commit. After merging a pull request, the `merge_commit_sha` attribute changes depending on how you merged the pull request:
     *
     * *   If merged as a [merge commit](https://help.github.com/articles/about-merge-methods-on-github/), `merge_commit_sha` represents the SHA of the merge commit.
     * *   If merged via a [squash](https://help.github.com/articles/about-merge-methods-on-github/#squashing-your-merge-commits), `merge_commit_sha` represents the SHA of the squashed commit on the base branch.
     * *   If [rebased](https://help.github.com/articles/about-merge-methods-on-github/#rebasing-and-merging-your-commits), `merge_commit_sha` represents the commit that the base branch was updated to.
     *
     * Pass the appropriate [media type](https://developer.github.com/v3/media/#commits-commit-comparison-and-pull-requests) to fetch diff and patch formats.
     */
    get: {
      (params?: Octokit.PullsGetParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.PullsGetResponse>
      >;
      (params?: Octokit.PullsGetParams): Promise<
        Octokit.Response<Octokit.PullsGetResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Draft pull requests are available in public repositories with GitHub Free and GitHub Pro, and in public and private repositories with GitHub Team and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * To open or update a pull request in a public repository, you must have write access to the head or the source branch. For organization-owned repositories, you must be a member of the organization that owns the repository to open or update a pull request.
     *
     * This endpoint triggers [notifications](https://help.github.com/articles/about-notifications/). Creating content too quickly using this endpoint may result in abuse rate limiting. See "[Abuse rate limits](https://developer.github.com/v3/#abuse-rate-limits)" and "[Dealing with abuse rate limits](https://developer.github.com/v3/guides/best-practices-for-integrators/#dealing-with-abuse-rate-limits)" for details.
     */
    create: {
      (params?: Octokit.PullsCreateParams): Promise<
        Octokit.Response<Octokit.PullsCreateResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Draft pull requests are available in public repositories with GitHub Free and GitHub Pro, and in public and private repositories with GitHub Team and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * To open or update a pull request in a public repository, you must have write access to the head or the source branch. For organization-owned repositories, you must be a member of the organization that owns the repository to open or update a pull request.
     *
     * This endpoint triggers [notifications](https://help.github.com/articles/about-notifications/). Creating content too quickly using this endpoint may result in abuse rate limiting. See "[Abuse rate limits](https://developer.github.com/v3/#abuse-rate-limits)" and "[Dealing with abuse rate limits](https://developer.github.com/v3/guides/best-practices-for-integrators/#dealing-with-abuse-rate-limits)" for details.
     */
    createFromIssue: {
      (params?: Octokit.PullsCreateFromIssueParams): Promise<
        Octokit.Response<Octokit.PullsCreateFromIssueResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Updates the pull request branch with the latest upstream changes by merging HEAD from the base branch into the pull request branch.
     */
    updateBranch: {
      (params?: Octokit.PullsUpdateBranchParams): Promise<
        Octokit.Response<Octokit.PullsUpdateBranchResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Draft pull requests are available in public repositories with GitHub Free and GitHub Pro, and in public and private repositories with GitHub Team and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * To open or update a pull request in a public repository, you must have write access to the head or the source branch. For organization-owned repositories, you must be a member of the organization that owns the repository to open or update a pull request.
     */
    update: {
      (params?: Octokit.PullsUpdateParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.PullsUpdateResponse>
      >;
      (params?: Octokit.PullsUpdateParams): Promise<
        Octokit.Response<Octokit.PullsUpdateResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists a maximum of 250 commits for a pull request. To receive a complete commit list for pull requests with more than 250 commits, use the [Commit List API](https://developer.github.com/v3/repos/commits/#list-commits-on-a-repository).
     */
    listCommits: {
      (params?: Octokit.PullsListCommitsParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.PullsListCommitsResponse>
      >;
      (params?: Octokit.PullsListCommitsParams): Promise<
        Octokit.Response<Octokit.PullsListCommitsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Note:** The response includes a maximum of 300 files.
     */
    listFiles: {
      (params?: Octokit.PullsListFilesParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.PullsListFilesResponse>
      >;
      (params?: Octokit.PullsListFilesParams): Promise<
        Octokit.Response<Octokit.PullsListFilesResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    checkIfMerged: {
      (params?: Octokit.PullsCheckIfMergedParamsDeprecatedNumber): Promise<
        Octokit.AnyResponse
      >;
      (params?: Octokit.PullsCheckIfMergedParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This endpoint triggers [notifications](https://help.github.com/articles/about-notifications/). Creating content too quickly using this endpoint may result in abuse rate limiting. See "[Abuse rate limits](https://developer.github.com/v3/#abuse-rate-limits)" and "[Dealing with abuse rate limits](https://developer.github.com/v3/guides/best-practices-for-integrators/#dealing-with-abuse-rate-limits)" for details.
     */
    merge: {
      (params?: Octokit.PullsMergeParamsDeprecatedNumber): Promise<
        Octokit.AnyResponse
      >;
      (params?: Octokit.PullsMergeParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * By default, review comments are ordered by ascending ID.
     */
    listComments: {
      (params?: Octokit.PullsListCommentsParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.PullsListCommentsResponse>
      >;
      (params?: Octokit.PullsListCommentsParams): Promise<
        Octokit.Response<Octokit.PullsListCommentsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * By default, review comments are ordered by ascending ID.
     */
    listCommentsForRepo: {
      (params?: Octokit.PullsListCommentsForRepoParams): Promise<
        Octokit.Response<Octokit.PullsListCommentsForRepoResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getComment: {
      (params?: Octokit.PullsGetCommentParams): Promise<
        Octokit.Response<Octokit.PullsGetCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This endpoint triggers [notifications](https://help.github.com/articles/about-notifications/). Creating content too quickly using this endpoint may result in abuse rate limiting. See "[Abuse rate limits](https://developer.github.com/v3/#abuse-rate-limits)" and "[Dealing with abuse rate limits](https://developer.github.com/v3/guides/best-practices-for-integrators/#dealing-with-abuse-rate-limits)" for details.
     *
     * **Note:** To comment on a specific line in a file, you need to first determine the _position_ of that line in the diff. The GitHub REST API v3 offers the `application/vnd.github.v3.diff` [media type](https://developer.github.com/v3/media/#commits-commit-comparison-and-pull-requests). To see a pull request diff, add this media type to the `Accept` header of a call to the [single pull request](https://developer.github.com/v3/pulls/#get-a-single-pull-request) endpoint.
     *
     * The `position` value equals the number of lines down from the first "@@" hunk header in the file you want to add a comment. The line just below the "@@" line is position 1, the next line is position 2, and so on. The position in the diff continues to increase through lines of whitespace and additional hunks until the beginning of a new file.
     */
    createComment: {
      (params?: Octokit.PullsCreateCommentParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.PullsCreateCommentResponse>
      >;
      (params?: Octokit.PullsCreateCommentParams): Promise<
        Octokit.Response<Octokit.PullsCreateCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This endpoint triggers [notifications](https://help.github.com/articles/about-notifications/). Creating content too quickly using this endpoint may result in abuse rate limiting. See "[Abuse rate limits](https://developer.github.com/v3/#abuse-rate-limits)" and "[Dealing with abuse rate limits](https://developer.github.com/v3/guides/best-practices-for-integrators/#dealing-with-abuse-rate-limits)" for details.
     *
     * **Note:** To comment on a specific line in a file, you need to first determine the _position_ of that line in the diff. The GitHub REST API v3 offers the `application/vnd.github.v3.diff` [media type](https://developer.github.com/v3/media/#commits-commit-comparison-and-pull-requests). To see a pull request diff, add this media type to the `Accept` header of a call to the [single pull request](https://developer.github.com/v3/pulls/#get-a-single-pull-request) endpoint.
     *
     * The `position` value equals the number of lines down from the first "@@" hunk header in the file you want to add a comment. The line just below the "@@" line is position 1, the next line is position 2, and so on. The position in the diff continues to increase through lines of whitespace and additional hunks until the beginning of a new file.
     */
    createCommentReply: {
      (params?: Octokit.PullsCreateCommentReplyParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.PullsCreateCommentReplyResponse>
      >;
      (params?: Octokit.PullsCreateCommentReplyParams): Promise<
        Octokit.Response<Octokit.PullsCreateCommentReplyResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    updateComment: {
      (params?: Octokit.PullsUpdateCommentParams): Promise<
        Octokit.Response<Octokit.PullsUpdateCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    deleteComment: {
      (params?: Octokit.PullsDeleteCommentParams): Promise<
        Octokit.Response<Octokit.PullsDeleteCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listReviewRequests: {
      (params?: Octokit.PullsListReviewRequestsParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.PullsListReviewRequestsResponse>
      >;
      (params?: Octokit.PullsListReviewRequestsParams): Promise<
        Octokit.Response<Octokit.PullsListReviewRequestsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This endpoint triggers [notifications](https://help.github.com/articles/about-notifications/). Creating content too quickly using this endpoint may result in abuse rate limiting. See "[Abuse rate limits](https://developer.github.com/v3/#abuse-rate-limits)" and "[Dealing with abuse rate limits](https://developer.github.com/v3/guides/best-practices-for-integrators/#dealing-with-abuse-rate-limits)" for details.
     */
    createReviewRequest: {
      (
        params?: Octokit.PullsCreateReviewRequestParamsDeprecatedNumber
      ): Promise<Octokit.Response<Octokit.PullsCreateReviewRequestResponse>>;
      (params?: Octokit.PullsCreateReviewRequestParams): Promise<
        Octokit.Response<Octokit.PullsCreateReviewRequestResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    deleteReviewRequest: {
      (
        params?: Octokit.PullsDeleteReviewRequestParamsDeprecatedNumber
      ): Promise<Octokit.Response<Octokit.PullsDeleteReviewRequestResponse>>;
      (params?: Octokit.PullsDeleteReviewRequestParams): Promise<
        Octokit.Response<Octokit.PullsDeleteReviewRequestResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * The list of reviews returns in chronological order.
     */
    listReviews: {
      (params?: Octokit.PullsListReviewsParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.PullsListReviewsResponse>
      >;
      (params?: Octokit.PullsListReviewsParams): Promise<
        Octokit.Response<Octokit.PullsListReviewsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getReview: {
      (params?: Octokit.PullsGetReviewParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.PullsGetReviewResponse>
      >;
      (params?: Octokit.PullsGetReviewParams): Promise<
        Octokit.Response<Octokit.PullsGetReviewResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    deletePendingReview: {
      (
        params?: Octokit.PullsDeletePendingReviewParamsDeprecatedNumber
      ): Promise<Octokit.Response<Octokit.PullsDeletePendingReviewResponse>>;
      (params?: Octokit.PullsDeletePendingReviewParams): Promise<
        Octokit.Response<Octokit.PullsDeletePendingReviewResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getCommentsForReview: {
      (
        params?: Octokit.PullsGetCommentsForReviewParamsDeprecatedNumber
      ): Promise<Octokit.Response<Octokit.PullsGetCommentsForReviewResponse>>;
      (params?: Octokit.PullsGetCommentsForReviewParams): Promise<
        Octokit.Response<Octokit.PullsGetCommentsForReviewResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This endpoint triggers [notifications](https://help.github.com/articles/about-notifications/). Creating content too quickly using this endpoint may result in abuse rate limiting. See "[Abuse rate limits](https://developer.github.com/v3/#abuse-rate-limits)" and "[Dealing with abuse rate limits](https://developer.github.com/v3/guides/best-practices-for-integrators/#dealing-with-abuse-rate-limits)" for details.
     *
     * **Note:** To comment on a specific line in a file, you need to first determine the _position_ of that line in the diff. The GitHub REST API v3 offers the `application/vnd.github.v3.diff` [media type](https://developer.github.com/v3/media/#commits-commit-comparison-and-pull-requests). To see a pull request diff, add this media type to the `Accept` header of a call to the [single pull request](https://developer.github.com/v3/pulls/#get-a-single-pull-request) endpoint.
     *
     * The `position` value equals the number of lines down from the first "@@" hunk header in the file you want to add a comment. The line just below the "@@" line is position 1, the next line is position 2, and so on. The position in the diff continues to increase through lines of whitespace and additional hunks until the beginning of a new file.
     */
    createReview: {
      (params?: Octokit.PullsCreateReviewParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.PullsCreateReviewResponse>
      >;
      (params?: Octokit.PullsCreateReviewParams): Promise<
        Octokit.Response<Octokit.PullsCreateReviewResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Update the review summary comment with new text.
     */
    updateReview: {
      (params?: Octokit.PullsUpdateReviewParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.PullsUpdateReviewResponse>
      >;
      (params?: Octokit.PullsUpdateReviewParams): Promise<
        Octokit.Response<Octokit.PullsUpdateReviewResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    submitReview: {
      (params?: Octokit.PullsSubmitReviewParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.PullsSubmitReviewResponse>
      >;
      (params?: Octokit.PullsSubmitReviewParams): Promise<
        Octokit.Response<Octokit.PullsSubmitReviewResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Note:** To dismiss a pull request review on a [protected branch](https://developer.github.com/v3/repos/branches/), you must be a repository administrator or be included in the list of people or teams who can dismiss pull request reviews.
     */
    dismissReview: {
      (params?: Octokit.PullsDismissReviewParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.PullsDismissReviewResponse>
      >;
      (params?: Octokit.PullsDismissReviewParams): Promise<
        Octokit.Response<Octokit.PullsDismissReviewResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  rateLimit: {
    /**
     * **Note:** Accessing this endpoint does not count against your REST API rate limit.
     *
     * **Understanding your rate limit status**
     *
     * The Search API has a [custom rate limit](https://developer.github.com/v3/search/#rate-limit), separate from the rate limit governing the rest of the REST API. The GraphQL API also has a [custom rate limit](https://developer.github.com/v4/guides/resource-limitations/#rate-limit) that is separate from and calculated differently than rate limits in the REST API.
     *
     * For these reasons, the Rate Limit API response categorizes your rate limit. Under `resources`, you'll see four objects:
     *
     * *   The `core` object provides your rate limit status for all non-search-related resources in the REST API.
     * *   The `search` object provides your rate limit status for the [Search API](https://developer.github.com/v3/search/).
     * *   The `graphql` object provides your rate limit status for the [GraphQL API](https://developer.github.com/v4/).
     * *   The `integration_manifest` object provides your rate limit status for the [GitHub App Manifest code conversion](https://developer.github.com/apps/building-github-apps/creating-github-apps-from-a-manifest/#3-you-exchange-the-temporary-code-to-retrieve-the-app-configuration) endpoint.
     *
     * For more information on the headers and values in the rate limit response, see "[Rate limiting](https://developer.github.com/v3/#rate-limiting)."
     *
     * The `rate` object (shown at the bottom of the response above) is deprecated.
     *
     * If you're writing new API client code or updating existing code, you should use the `core` object instead of the `rate` object. The `core` object contains the same information that is present in the `rate` object.
     */
    get: {
      (params?: Octokit.EmptyParams): Promise<
        Octokit.Response<Octokit.RateLimitGetResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  reactions: {
    /**
     * List the reactions to a [commit comment](https://developer.github.com/v3/repos/comments/).
     */
    listForCommitComment: {
      (params?: Octokit.ReactionsListForCommitCommentParams): Promise<
        Octokit.Response<Octokit.ReactionsListForCommitCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Create a reaction to a [commit comment](https://developer.github.com/v3/repos/comments/). A response with a `Status: 200 OK` means that you already added the reaction type to this commit comment.
     */
    createForCommitComment: {
      (params?: Octokit.ReactionsCreateForCommitCommentParams): Promise<
        Octokit.Response<Octokit.ReactionsCreateForCommitCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * List the reactions to an [issue](https://developer.github.com/v3/issues/).
     */
    listForIssue: {
      (params?: Octokit.ReactionsListForIssueParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.ReactionsListForIssueResponse>
      >;
      (params?: Octokit.ReactionsListForIssueParams): Promise<
        Octokit.Response<Octokit.ReactionsListForIssueResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Create a reaction to an [issue](https://developer.github.com/v3/issues/). A response with a `Status: 200 OK` means that you already added the reaction type to this issue.
     */
    createForIssue: {
      (params?: Octokit.ReactionsCreateForIssueParamsDeprecatedNumber): Promise<
        Octokit.Response<Octokit.ReactionsCreateForIssueResponse>
      >;
      (params?: Octokit.ReactionsCreateForIssueParams): Promise<
        Octokit.Response<Octokit.ReactionsCreateForIssueResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * List the reactions to an [issue comment](https://developer.github.com/v3/issues/comments/).
     */
    listForIssueComment: {
      (params?: Octokit.ReactionsListForIssueCommentParams): Promise<
        Octokit.Response<Octokit.ReactionsListForIssueCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Create a reaction to an [issue comment](https://developer.github.com/v3/issues/comments/). A response with a `Status: 200 OK` means that you already added the reaction type to this issue comment.
     */
    createForIssueComment: {
      (params?: Octokit.ReactionsCreateForIssueCommentParams): Promise<
        Octokit.Response<Octokit.ReactionsCreateForIssueCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * List the reactions to a [pull request review comment](https://developer.github.com/v3/pulls/comments/).
     */
    listForPullRequestReviewComment: {
      (
        params?: Octokit.ReactionsListForPullRequestReviewCommentParams
      ): Promise<
        Octokit.Response<
          Octokit.ReactionsListForPullRequestReviewCommentResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Create a reaction to a [pull request review comment](https://developer.github.com/v3/pulls/comments/). A response with a `Status: 200 OK` means that you already added the reaction type to this pull request review comment.
     */
    createForPullRequestReviewComment: {
      (
        params?: Octokit.ReactionsCreateForPullRequestReviewCommentParams
      ): Promise<
        Octokit.Response<
          Octokit.ReactionsCreateForPullRequestReviewCommentResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * List the reactions to a [team discussion](https://developer.github.com/v3/teams/discussions/). OAuth access tokens require the `read:discussion` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).
     */
    listForTeamDiscussion: {
      (params?: Octokit.ReactionsListForTeamDiscussionParams): Promise<
        Octokit.Response<Octokit.ReactionsListForTeamDiscussionResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Create a reaction to a [team discussion](https://developer.github.com/v3/teams/discussions/). OAuth access tokens require the `write:discussion` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/). A response with a `Status: 200 OK` means that you already added the reaction type to this team discussion.
     */
    createForTeamDiscussion: {
      (params?: Octokit.ReactionsCreateForTeamDiscussionParams): Promise<
        Octokit.Response<Octokit.ReactionsCreateForTeamDiscussionResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * List the reactions to a [team discussion comment](https://developer.github.com/v3/teams/discussion_comments/). OAuth access tokens require the `read:discussion` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).
     */
    listForTeamDiscussionComment: {
      (params?: Octokit.ReactionsListForTeamDiscussionCommentParams): Promise<
        Octokit.Response<Octokit.ReactionsListForTeamDiscussionCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Create a reaction to a [team discussion comment](https://developer.github.com/v3/teams/discussion_comments/). OAuth access tokens require the `write:discussion` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/). A response with a `Status: 200 OK` means that you already added the reaction type to this team discussion comment.
     */
    createForTeamDiscussionComment: {
      (params?: Octokit.ReactionsCreateForTeamDiscussionCommentParams): Promise<
        Octokit.Response<
          Octokit.ReactionsCreateForTeamDiscussionCommentResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * OAuth access tokens require the `write:discussion` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/), when deleting a [team discussion](https://developer.github.com/v3/teams/discussions/) or [team discussion comment](https://developer.github.com/v3/teams/discussion_comments/).
     */
    delete: {
      (params?: Octokit.ReactionsDeleteParams): Promise<
        Octokit.Response<Octokit.ReactionsDeleteResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  repos: {
    /**
     * Lists repositories that the authenticated user has explicit permission (`:read`, `:write`, or `:admin`) to access.
     *
     * The authenticated user has explicit permission to access repositories they own, repositories where they are a collaborator, and repositories that they can access through an organization membership.
     */
    list: {
      (params?: Octokit.ReposListParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists public repositories for the specified user.
     */
    listForUser: {
      (params?: Octokit.ReposListForUserParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists repositories for the specified organization.
     */
    listForOrg: {
      (params?: Octokit.ReposListForOrgParams): Promise<
        Octokit.Response<Octokit.ReposListForOrgResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists all public repositories in the order that they were created.
     *
     * Note: Pagination is powered exclusively by the `since` parameter. Use the [Link header](https://developer.github.com/v3/#link-header) to get the URL for the next page of repositories.
     */
    listPublic: {
      (params?: Octokit.ReposListPublicParams): Promise<
        Octokit.Response<Octokit.ReposListPublicResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Creates a new repository for the authenticated user.
     *
     * **OAuth scope requirements**
     *
     * When using [OAuth](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/), authorizations must include:
     *
     * *   `public_repo` scope or `repo` scope to create a public repository
     * *   `repo` scope to create a private repository
     */
    createForAuthenticatedUser: {
      (params?: Octokit.ReposCreateForAuthenticatedUserParams): Promise<
        Octokit.Response<Octokit.ReposCreateForAuthenticatedUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Creates a new repository for the authenticated user.
     *
     * **OAuth scope requirements**
     *
     * When using [OAuth](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/), authorizations must include:
     *
     * *   `public_repo` scope or `repo` scope to create a public repository
     * *   `repo` scope to create a private repository
     */
    createInOrg: {
      (params?: Octokit.ReposCreateInOrgParams): Promise<
        Octokit.Response<Octokit.ReposCreateInOrgResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Creates a new repository using a repository template. Use the `repo` route parameter to specify the repository to use as the template. The authenticated user must own or be a member of an organization that owns the repository. To check if a repository is available to use as a template, get the repository's information using the [`GET /repos/:owner/:repo`](https://developer.github.com/v3/repos/#get) endpoint and check that the `is_template` key is `true`.
     *
     * **OAuth scope requirements**
     *
     * When using [OAuth](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/), authorizations must include:
     *
     * *   `public_repo` scope or `repo` scope to create a public repository
     * *   `repo` scope to create a private repository
     *
     * \`
     */
    createUsingTemplate: {
      (params?: Octokit.ReposCreateUsingTemplateParams): Promise<
        Octokit.Response<Octokit.ReposCreateUsingTemplateResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * The `parent` and `source` objects are present when the repository is a fork. `parent` is the repository this repository was forked from, `source` is the ultimate source for the network.
     */
    get: {
      (params?: Octokit.ReposGetParams): Promise<
        Octokit.Response<Octokit.ReposGetResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Note**: To edit a repository's topics, use the [`topics` endpoint](https://developer.github.com/v3/repos/#replace-all-topics-for-a-repository).
     */
    update: {
      (params?: Octokit.ReposUpdateParams): Promise<
        Octokit.Response<Octokit.ReposUpdateResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listTopics: {
      (params?: Octokit.ReposListTopicsParams): Promise<
        Octokit.Response<Octokit.ReposListTopicsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    replaceTopics: {
      (params?: Octokit.ReposReplaceTopicsParams): Promise<
        Octokit.Response<Octokit.ReposReplaceTopicsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Shows whether vulnerability alerts are enabled or disabled for a repository. The authenticated user must have admin access to the repository. For more information, see "[About security alerts for vulnerable dependencies](https://help.github.com/en/articles/about-security-alerts-for-vulnerable-dependencies)" in the GitHub Help documentation.
     */
    checkVulnerabilityAlerts: {
      (params?: Octokit.ReposCheckVulnerabilityAlertsParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Enables vulnerability alerts and the dependency graph for a repository. The authenticated user must have admin access to the repository. For more information, see "[About security alerts for vulnerable dependencies](https://help.github.com/en/articles/about-security-alerts-for-vulnerable-dependencies)" in the GitHub Help documentation.
     */
    enableVulnerabilityAlerts: {
      (params?: Octokit.ReposEnableVulnerabilityAlertsParams): Promise<
        Octokit.Response<Octokit.ReposEnableVulnerabilityAlertsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Disables vulnerability alerts and the dependency graph for a repository. The authenticated user must have admin access to the repository. For more information, see "[About security alerts for vulnerable dependencies](https://help.github.com/en/articles/about-security-alerts-for-vulnerable-dependencies)" in the GitHub Help documentation.
     */
    disableVulnerabilityAlerts: {
      (params?: Octokit.ReposDisableVulnerabilityAlertsParams): Promise<
        Octokit.Response<Octokit.ReposDisableVulnerabilityAlertsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Enables automated security fixes for a repository. The authenticated user must have admin access to the repository. For more information, see "[Configuring automated security fixes](https://help.github.com/en/articles/configuring-automated-security-fixes)" in the GitHub Help documentation.
     */
    enableAutomatedSecurityFixes: {
      (params?: Octokit.ReposEnableAutomatedSecurityFixesParams): Promise<
        Octokit.Response<Octokit.ReposEnableAutomatedSecurityFixesResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Disables automated security fixes for a repository. The authenticated user must have admin access to the repository. For more information, see "[Configuring automated security fixes](https://help.github.com/en/articles/configuring-automated-security-fixes)" in the GitHub Help documentation.
     */
    disableAutomatedSecurityFixes: {
      (params?: Octokit.ReposDisableAutomatedSecurityFixesParams): Promise<
        Octokit.Response<Octokit.ReposDisableAutomatedSecurityFixesResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists contributors to the specified repository and sorts them by the number of commits per contributor in descending order. This endpoint may return information that is a few hours old because the GitHub REST API v3 caches contributor data to improve performance.
     *
     * GitHub identifies contributors by author email address. This endpoint groups contribution counts by GitHub user, which includes all associated email addresses. To improve performance, only the first 500 author email addresses in the repository link to GitHub users. The rest will appear as anonymous contributors without associated GitHub user information.
     */
    listContributors: {
      (params?: Octokit.ReposListContributorsParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists languages for the specified repository. The value shown for each language is the number of bytes of code written in that language.
     */
    listLanguages: {
      (params?: Octokit.ReposListLanguagesParams): Promise<
        Octokit.Response<Octokit.ReposListLanguagesResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listTeams: {
      (params?: Octokit.ReposListTeamsParams): Promise<
        Octokit.Response<Octokit.ReposListTeamsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listTags: {
      (params?: Octokit.ReposListTagsParams): Promise<
        Octokit.Response<Octokit.ReposListTagsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Deleting a repository requires admin access. If OAuth is used, the `delete_repo` scope is required.
     *
     * If an organization owner has configured the organization to prevent members from deleting organization-owned repositories, a member will get this response:
     */
    delete: {
      (params?: Octokit.ReposDeleteParams): Promise<
        Octokit.Response<Octokit.ReposDeleteResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * A transfer request will need to be accepted by the new owner when transferring a personal repository to another user. The response will contain the original `owner`, and the transfer will continue asynchronously. For more details on the requirements to transfer personal and organization-owned repositories, see [about repository transfers](https://help.github.com/articles/about-repository-transfers/).
     */
    transfer: {
      (params?: Octokit.ReposTransferParams): Promise<
        Octokit.Response<Octokit.ReposTransferResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listBranches: {
      (params?: Octokit.ReposListBranchesParams): Promise<
        Octokit.Response<Octokit.ReposListBranchesResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getBranch: {
      (params?: Octokit.ReposGetBranchParams): Promise<
        Octokit.Response<Octokit.ReposGetBranchResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     */
    getBranchProtection: {
      (params?: Octokit.ReposGetBranchProtectionParams): Promise<
        Octokit.Response<Octokit.ReposGetBranchProtectionResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * Protecting a branch requires admin or owner permissions to the repository.
     *
     * **Note**: Passing new arrays of `users` and `teams` replaces their previous values.
     *
     * **Note**: The list of users and teams in total is limited to 100 items.
     */
    updateBranchProtection: {
      (params?: Octokit.ReposUpdateBranchProtectionParams): Promise<
        Octokit.Response<Octokit.ReposUpdateBranchProtectionResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     */
    removeBranchProtection: {
      (params?: Octokit.ReposRemoveBranchProtectionParams): Promise<
        Octokit.Response<Octokit.ReposRemoveBranchProtectionResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     */
    getProtectedBranchRequiredStatusChecks: {
      (
        params?: Octokit.ReposGetProtectedBranchRequiredStatusChecksParams
      ): Promise<
        Octokit.Response<
          Octokit.ReposGetProtectedBranchRequiredStatusChecksResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * Updating required status checks requires admin or owner permissions to the repository and branch protection to be enabled.
     */
    updateProtectedBranchRequiredStatusChecks: {
      (
        params?: Octokit.ReposUpdateProtectedBranchRequiredStatusChecksParams
      ): Promise<
        Octokit.Response<
          Octokit.ReposUpdateProtectedBranchRequiredStatusChecksResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     */
    removeProtectedBranchRequiredStatusChecks: {
      (
        params?: Octokit.ReposRemoveProtectedBranchRequiredStatusChecksParams
      ): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     */
    listProtectedBranchRequiredStatusChecksContexts: {
      (
        params?: Octokit.ReposListProtectedBranchRequiredStatusChecksContextsParams
      ): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     */
    replaceProtectedBranchRequiredStatusChecksContexts: {
      (
        params?: Octokit.ReposReplaceProtectedBranchRequiredStatusChecksContextsParams
      ): Promise<
        Octokit.Response<
          Octokit.ReposReplaceProtectedBranchRequiredStatusChecksContextsResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     */
    addProtectedBranchRequiredStatusChecksContexts: {
      (
        params?: Octokit.ReposAddProtectedBranchRequiredStatusChecksContextsParams
      ): Promise<
        Octokit.Response<
          Octokit.ReposAddProtectedBranchRequiredStatusChecksContextsResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     */
    removeProtectedBranchRequiredStatusChecksContexts: {
      (
        params?: Octokit.ReposRemoveProtectedBranchRequiredStatusChecksContextsParams
      ): Promise<
        Octokit.Response<
          Octokit.ReposRemoveProtectedBranchRequiredStatusChecksContextsResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     */
    getProtectedBranchPullRequestReviewEnforcement: {
      (
        params?: Octokit.ReposGetProtectedBranchPullRequestReviewEnforcementParams
      ): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * Updating pull request review enforcement requires admin or owner permissions to the repository and branch protection to be enabled.
     *
     * **Note**: Passing new arrays of `users` and `teams` replaces their previous values.
     */
    updateProtectedBranchPullRequestReviewEnforcement: {
      (
        params?: Octokit.ReposUpdateProtectedBranchPullRequestReviewEnforcementParams
      ): Promise<
        Octokit.Response<
          Octokit.ReposUpdateProtectedBranchPullRequestReviewEnforcementResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     */
    removeProtectedBranchPullRequestReviewEnforcement: {
      (
        params?: Octokit.ReposRemoveProtectedBranchPullRequestReviewEnforcementParams
      ): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * When authenticated with admin or owner permissions to the repository, you can use this endpoint to check whether a branch requires signed commits. An enabled status of `true` indicates you must sign commits on this branch. For more information, see [Signing commits with GPG](https://help.github.com/articles/signing-commits-with-gpg) in GitHub Help.
     *
     * **Note**: You must enable branch protection to require signed commits.
     */
    getProtectedBranchRequiredSignatures: {
      (
        params?: Octokit.ReposGetProtectedBranchRequiredSignaturesParams
      ): Promise<
        Octokit.Response<
          Octokit.ReposGetProtectedBranchRequiredSignaturesResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * When authenticated with admin or owner permissions to the repository, you can use this endpoint to require signed commits on a branch. You must enable branch protection to require signed commits.
     */
    addProtectedBranchRequiredSignatures: {
      (
        params?: Octokit.ReposAddProtectedBranchRequiredSignaturesParams
      ): Promise<
        Octokit.Response<
          Octokit.ReposAddProtectedBranchRequiredSignaturesResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * When authenticated with admin or owner permissions to the repository, you can use this endpoint to disable required signed commits on a branch. You must enable branch protection to require signed commits.
     */
    removeProtectedBranchRequiredSignatures: {
      (
        params?: Octokit.ReposRemoveProtectedBranchRequiredSignaturesParams
      ): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     */
    getProtectedBranchAdminEnforcement: {
      (params?: Octokit.ReposGetProtectedBranchAdminEnforcementParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * Adding admin enforcement requires admin or owner permissions to the repository and branch protection to be enabled.
     */
    addProtectedBranchAdminEnforcement: {
      (params?: Octokit.ReposAddProtectedBranchAdminEnforcementParams): Promise<
        Octokit.Response<
          Octokit.ReposAddProtectedBranchAdminEnforcementResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * Removing admin enforcement requires admin or owner permissions to the repository and branch protection to be enabled.
     */
    removeProtectedBranchAdminEnforcement: {
      (
        params?: Octokit.ReposRemoveProtectedBranchAdminEnforcementParams
      ): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * **Note**: Teams and users `restrictions` are only available for organization-owned repositories.
     */
    getProtectedBranchRestrictions: {
      (params?: Octokit.ReposGetProtectedBranchRestrictionsParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * Disables the ability to restrict who can push to this branch.
     */
    removeProtectedBranchRestrictions: {
      (params?: Octokit.ReposRemoveProtectedBranchRestrictionsParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * Lists the teams who have push access to this branch. If you pass the `hellcat-preview` media type, the list includes child teams.
     */
    listProtectedBranchTeamRestrictions: {
      (
        params?: Octokit.ReposListProtectedBranchTeamRestrictionsParams
      ): Promise<
        Octokit.Response<
          Octokit.ReposListProtectedBranchTeamRestrictionsResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * Replaces the list of teams that have push access to this branch. This removes all teams that previously had push access and grants push access to the new list of teams. If you pass the `hellcat-preview` media type, you can include child teams.
     *
     * | Type    | Description                                                                                                                         |
     * | ------- | ----------------------------------------------------------------------------------------------------------------------------------- |
     * | `array` | The teams that can have push access. Use the team's `slug`. **Note**: The list of users and teams in total is limited to 100 items. |
     */
    replaceProtectedBranchTeamRestrictions: {
      (
        params?: Octokit.ReposReplaceProtectedBranchTeamRestrictionsParams
      ): Promise<
        Octokit.Response<
          Octokit.ReposReplaceProtectedBranchTeamRestrictionsResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * Grants the specified teams push access for this branch. If you pass the `hellcat-preview` media type, you can also give push access to child teams.
     *
     * | Type    | Description                                                                                                                         |
     * | ------- | ----------------------------------------------------------------------------------------------------------------------------------- |
     * | `array` | The teams that can have push access. Use the team's `slug`. **Note**: The list of users and teams in total is limited to 100 items. |
     */
    addProtectedBranchTeamRestrictions: {
      (params?: Octokit.ReposAddProtectedBranchTeamRestrictionsParams): Promise<
        Octokit.Response<
          Octokit.ReposAddProtectedBranchTeamRestrictionsResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * Removes the ability of a team to push to this branch. If you pass the `hellcat-preview` media type, you can include child teams.
     *
     * | Type    | Description                                                                                                                                  |
     * | ------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
     * | `array` | Teams that should no longer have push access. Use the team's `slug`. **Note**: The list of users and teams in total is limited to 100 items. |
     */
    removeProtectedBranchTeamRestrictions: {
      (
        params?: Octokit.ReposRemoveProtectedBranchTeamRestrictionsParams
      ): Promise<
        Octokit.Response<
          Octokit.ReposRemoveProtectedBranchTeamRestrictionsResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * Lists the people who have push access to this branch.
     */
    listProtectedBranchUserRestrictions: {
      (
        params?: Octokit.ReposListProtectedBranchUserRestrictionsParams
      ): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * Replaces the list of people that have push access to this branch. This removes all people that previously had push access and grants push access to the new list of people.
     *
     * | Type    | Description                                                                                                            |
     * | ------- | ---------------------------------------------------------------------------------------------------------------------- |
     * | `array` | Usernames for people who can have push access. **Note**: The list of users and teams in total is limited to 100 items. |
     */
    replaceProtectedBranchUserRestrictions: {
      (
        params?: Octokit.ReposReplaceProtectedBranchUserRestrictionsParams
      ): Promise<
        Octokit.Response<
          Octokit.ReposReplaceProtectedBranchUserRestrictionsResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * Grants the specified people push access for this branch.
     *
     * | Type    | Description                                                                                                            |
     * | ------- | ---------------------------------------------------------------------------------------------------------------------- |
     * | `array` | Usernames for people who can have push access. **Note**: The list of users and teams in total is limited to 100 items. |
     */
    addProtectedBranchUserRestrictions: {
      (params?: Octokit.ReposAddProtectedBranchUserRestrictionsParams): Promise<
        Octokit.Response<
          Octokit.ReposAddProtectedBranchUserRestrictionsResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * Removes the ability of a team to push to this branch.
     *
     * | Type    | Description                                                                                                                            |
     * | ------- | -------------------------------------------------------------------------------------------------------------------------------------- |
     * | `array` | Usernames of the people who should no longer have push access. **Note**: The list of users and teams in total is limited to 100 items. |
     */
    removeProtectedBranchUserRestrictions: {
      (
        params?: Octokit.ReposRemoveProtectedBranchUserRestrictionsParams
      ): Promise<
        Octokit.Response<
          Octokit.ReposRemoveProtectedBranchUserRestrictionsResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * For organization-owned repositories, the list of collaborators includes outside collaborators, organization members that are direct collaborators, organization members with access through team memberships, organization members with access through default organization permissions, and organization owners.
     *
     * If you pass the `hellcat-preview` media type, team members will include the members of child teams.
     */
    listCollaborators: {
      (params?: Octokit.ReposListCollaboratorsParams): Promise<
        Octokit.Response<Octokit.ReposListCollaboratorsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * For organization-owned repositories, the list of collaborators includes outside collaborators, organization members that are direct collaborators, organization members with access through team memberships, organization members with access through default organization permissions, and organization owners.
     *
     * If you pass the `hellcat-preview` media type, team members will include the members of child teams.
     */
    checkCollaborator: {
      (params?: Octokit.ReposCheckCollaboratorParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Possible values for the `permission` key: `admin`, `write`, `read`, `none`.
     */
    getCollaboratorPermissionLevel: {
      (params?: Octokit.ReposGetCollaboratorPermissionLevelParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This endpoint triggers [notifications](https://help.github.com/articles/about-notifications/). Creating content too quickly using this endpoint may result in abuse rate limiting. See "[Abuse rate limits](https://developer.github.com/v3/#abuse-rate-limits)" and "[Dealing with abuse rate limits](https://developer.github.com/v3/guides/best-practices-for-integrators/#dealing-with-abuse-rate-limits)" for details.
     *
     * Note that, if you choose not to pass any parameters, you'll need to set `Content-Length` to zero when calling out to this endpoint. For more information, see "[HTTP verbs](https://developer.github.com/v3/#http-verbs)."
     *
     * The invitee will receive a notification that they have been invited to the repository, which they must accept or decline. They may do this via the notifications page, the email they receive, or by using the [repository invitations API endpoints](https://developer.github.com/v3/repos/invitations/).
     *
     * **Rate limits**
     *
     * To prevent abuse, you are limited to sending 50 invitations to a repository per 24 hour period. Note there is no limit if you are inviting organization members to an organization repository.
     */
    addCollaborator: {
      (params?: Octokit.ReposAddCollaboratorParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };

    removeCollaborator: {
      (params?: Octokit.ReposRemoveCollaboratorParams): Promise<
        Octokit.Response<Octokit.ReposRemoveCollaboratorResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Commit Comments use [these custom media types](https://developer.github.com/v3/repos/comments/#custom-media-types). You can read more about the use of media types in the API [here](https://developer.github.com/v3/media/).
     *
     * Comments are ordered by ascending ID.
     */
    listCommitComments: {
      (params?: Octokit.ReposListCommitCommentsParams): Promise<
        Octokit.Response<Octokit.ReposListCommitCommentsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Use the `:commit_sha` to specify the commit that will have its comments listed.
     */
    listCommentsForCommit: {
      (params?: Octokit.ReposListCommentsForCommitParamsDeprecatedRef): Promise<
        Octokit.Response<Octokit.ReposListCommentsForCommitResponse>
      >;
      (params?: Octokit.ReposListCommentsForCommitParams): Promise<
        Octokit.Response<Octokit.ReposListCommentsForCommitResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Create a comment for a commit using its `:commit_sha`.
     *
     * This endpoint triggers [notifications](https://help.github.com/articles/about-notifications/). Creating content too quickly using this endpoint may result in abuse rate limiting. See "[Abuse rate limits](https://developer.github.com/v3/#abuse-rate-limits)" and "[Dealing with abuse rate limits](https://developer.github.com/v3/guides/best-practices-for-integrators/#dealing-with-abuse-rate-limits)" for details.
     */
    createCommitComment: {
      (params?: Octokit.ReposCreateCommitCommentParamsDeprecatedSha): Promise<
        Octokit.Response<Octokit.ReposCreateCommitCommentResponse>
      >;
      (params?: Octokit.ReposCreateCommitCommentParams): Promise<
        Octokit.Response<Octokit.ReposCreateCommitCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getCommitComment: {
      (params?: Octokit.ReposGetCommitCommentParams): Promise<
        Octokit.Response<Octokit.ReposGetCommitCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    updateCommitComment: {
      (params?: Octokit.ReposUpdateCommitCommentParams): Promise<
        Octokit.Response<Octokit.ReposUpdateCommitCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    deleteCommitComment: {
      (params?: Octokit.ReposDeleteCommitCommentParams): Promise<
        Octokit.Response<Octokit.ReposDeleteCommitCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Signature verification object**
     *
     * The response will include a `verification` object that describes the result of verifying the commit's signature. The following fields are included in the `verification` object:
     *
     * These are the possible values for `reason` in the `verification` object:
     *
     * | Value                    | Description                                                                                                                       |
     * | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
     * | `expired_key`            | The key that made the signature is expired.                                                                                       |
     * | `not_signing_key`        | The "signing" flag is not among the usage flags in the GPG key that made the signature.                                           |
     * | `gpgverify_error`        | There was an error communicating with the signature verification service.                                                         |
     * | `gpgverify_unavailable`  | The signature verification service is currently unavailable.                                                                      |
     * | `unsigned`               | The object does not include a signature.                                                                                          |
     * | `unknown_signature_type` | A non-PGP signature was found in the commit.                                                                                      |
     * | `no_user`                | No user was associated with the `committer` email address in the commit.                                                          |
     * | `unverified_email`       | The `committer` email address in the commit was associated with a user, but the email address is not verified on her/his account. |
     * | `bad_email`              | The `committer` email address in the commit is not included in the identities of the PGP key that made the signature.             |
     * | `unknown_key`            | The key that made the signature has not been registered with any user's account.                                                  |
     * | `malformed_signature`    | There was an error parsing the signature.                                                                                         |
     * | `invalid`                | The signature could not be cryptographically verified using the key whose key-id was found in the signature.                      |
     * | `valid`                  | None of the above errors applied, so the signature is considered to be verified.                                                  |
     */
    listCommits: {
      (params?: Octokit.ReposListCommitsParams): Promise<
        Octokit.Response<Octokit.ReposListCommitsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Returns the contents of a single commit reference. You must have `read` access for the repository to use this endpoint.
     *
     * You can pass the appropriate [media type](https://developer.github.com/v3/media/#commits-commit-comparison-and-pull-requests) to fetch `diff` and `patch` formats. Diffs with binary data will have no `patch` property.
     *
     * To return only the SHA-1 hash of the commit reference, you can provide the `sha` custom [media type](https://developer.github.com/v3/media/#commits-commit-comparison-and-pull-requests) in the `Accept` header. You can use this endpoint to check if a remote reference's SHA-1 hash is the same as your local reference's SHA-1 hash by providing the local SHA-1 reference as the ETag.
     *
     * **Signature verification object**
     *
     * The response will include a `verification` object that describes the result of verifying the commit's signature. The following fields are included in the `verification` object:
     *
     * These are the possible values for `reason` in the `verification` object:
     *
     * | Value                    | Description                                                                                                                       |
     * | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
     * | `expired_key`            | The key that made the signature is expired.                                                                                       |
     * | `not_signing_key`        | The "signing" flag is not among the usage flags in the GPG key that made the signature.                                           |
     * | `gpgverify_error`        | There was an error communicating with the signature verification service.                                                         |
     * | `gpgverify_unavailable`  | The signature verification service is currently unavailable.                                                                      |
     * | `unsigned`               | The object does not include a signature.                                                                                          |
     * | `unknown_signature_type` | A non-PGP signature was found in the commit.                                                                                      |
     * | `no_user`                | No user was associated with the `committer` email address in the commit.                                                          |
     * | `unverified_email`       | The `committer` email address in the commit was associated with a user, but the email address is not verified on her/his account. |
     * | `bad_email`              | The `committer` email address in the commit is not included in the identities of the PGP key that made the signature.             |
     * | `unknown_key`            | The key that made the signature has not been registered with any user's account.                                                  |
     * | `malformed_signature`    | There was an error parsing the signature.                                                                                         |
     * | `invalid`                | The signature could not be cryptographically verified using the key whose key-id was found in the signature.                      |
     * | `valid`                  | None of the above errors applied, so the signature is considered to be verified.                                                  |
     */
    getCommit: {
      (params?: Octokit.ReposGetCommitParamsDeprecatedCommitSha): Promise<
        Octokit.Response<Octokit.ReposGetCommitResponse>
      >;
      (params?: Octokit.ReposGetCommitParamsDeprecatedSha): Promise<
        Octokit.Response<Octokit.ReposGetCommitResponse>
      >;
      (params?: Octokit.ReposGetCommitParams): Promise<
        Octokit.Response<Octokit.ReposGetCommitResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Note:** To access this endpoint, you must provide a custom [media type](https://developer.github.com/v3/media) in the `Accept` header:
     *
     * ```
     * application/vnd.github.VERSION.sha
     *
     * ```
     *
     * Returns the SHA-1 of the commit reference. You must have `read` access for the repository to get the SHA-1 of a commit reference. You can use this endpoint to check if a remote reference's SHA-1 is the same as your local reference's SHA-1 by providing the local SHA-1 reference as the ETag.
     */
    getCommitRefSha: {
      (params?: Octokit.ReposGetCommitRefShaParams): Promise<
        Octokit.Response<Octokit.ReposGetCommitRefShaResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Both `:base` and `:head` must be branch names in `:repo`. To compare branches across other repositories in the same network as `:repo`, use the format `<USERNAME>:branch`.
     *
     * The response from the API is equivalent to running the `git log base..head` command; however, commits are returned in chronological order. Pass the appropriate [media type](https://developer.github.com/v3/media/#commits-commit-comparison-and-pull-requests) to fetch diff and patch formats.
     *
     * The response also includes details on the files that were changed between the two commits. This includes the status of the change (for example, if a file was added, removed, modified, or renamed), and details of the change itself. For example, files with a `renamed` status have a `previous_filename` field showing the previous filename of the file, and files with a `modified` status have a `patch` field showing the changes made to the file.
     *
     * **Working with large comparisons**
     *
     * The response will include a comparison of up to 250 commits. If you are working with a larger commit range, you can use the [Commit List API](https://developer.github.com/v3/repos/commits/#list-commits-on-a-repository) to enumerate all commits in the range.
     *
     * For comparisons with extremely large diffs, you may receive an error response indicating that the diff took too long to generate. You can typically resolve this error by using a smaller commit range.
     *
     * **Signature verification object**
     *
     * The response will include a `verification` object that describes the result of verifying the commit's signature. The following fields are included in the `verification` object:
     *
     * These are the possible values for `reason` in the `verification` object:
     *
     * | Value                    | Description                                                                                                                       |
     * | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
     * | `expired_key`            | The key that made the signature is expired.                                                                                       |
     * | `not_signing_key`        | The "signing" flag is not among the usage flags in the GPG key that made the signature.                                           |
     * | `gpgverify_error`        | There was an error communicating with the signature verification service.                                                         |
     * | `gpgverify_unavailable`  | The signature verification service is currently unavailable.                                                                      |
     * | `unsigned`               | The object does not include a signature.                                                                                          |
     * | `unknown_signature_type` | A non-PGP signature was found in the commit.                                                                                      |
     * | `no_user`                | No user was associated with the `committer` email address in the commit.                                                          |
     * | `unverified_email`       | The `committer` email address in the commit was associated with a user, but the email address is not verified on her/his account. |
     * | `bad_email`              | The `committer` email address in the commit is not included in the identities of the PGP key that made the signature.             |
     * | `unknown_key`            | The key that made the signature has not been registered with any user's account.                                                  |
     * | `malformed_signature`    | There was an error parsing the signature.                                                                                         |
     * | `invalid`                | The signature could not be cryptographically verified using the key whose key-id was found in the signature.                      |
     * | `valid`                  | None of the above errors applied, so the signature is considered to be verified.                                                  |
     */
    compareCommits: {
      (params?: Octokit.ReposCompareCommitsParams): Promise<
        Octokit.Response<Octokit.ReposCompareCommitsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Protected branches are available in public repositories with GitHub Free, and in public and private repositories with GitHub Pro, GitHub Team, and GitHub Enterprise Cloud. For more information, see [GitHub's billing plans](https://help.github.com/articles/github-s-billing-plans) in the GitHub Help documentation.
     *
     * Returns all branches where the given commit SHA is the HEAD, or latest commit for the branch.
     */
    listBranchesForHeadCommit: {
      (params?: Octokit.ReposListBranchesForHeadCommitParams): Promise<
        Octokit.Response<Octokit.ReposListBranchesForHeadCommitResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists all pull requests containing the provided commit SHA, which can be from any point in the commit history. The results will include open and closed pull requests. Additional preview headers may be required to see certain details for associated pull requests, such as whether a pull request is in a draft state. For more information about previews that might affect this endpoint, see the [List pull requests](https://developer.github.com/v3/pulls/#list-pull-requests) endpoint.
     */
    listPullRequestsAssociatedWithCommit: {
      (
        params?: Octokit.ReposListPullRequestsAssociatedWithCommitParams
      ): Promise<
        Octokit.Response<
          Octokit.ReposListPullRequestsAssociatedWithCommitResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This endpoint will return all community profile metrics, including an overall health score, repository description, the presence of documentation, detected code of conduct, detected license, and the presence of ISSUE\_TEMPLATE, PULL\_REQUEST\_TEMPLATE, README, and CONTRIBUTING files.
     */
    retrieveCommunityProfileMetrics: {
      (params?: Octokit.ReposRetrieveCommunityProfileMetricsParams): Promise<
        Octokit.Response<Octokit.ReposRetrieveCommunityProfileMetricsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Gets the preferred README for a repository.
     *
     * READMEs support [custom media types](https://developer.github.com/v3/repos/contents/#custom-media-types) for retrieving the raw content or rendered HTML.
     */
    getReadme: {
      (params?: Octokit.ReposGetReadmeParams): Promise<
        Octokit.Response<Octokit.ReposGetReadmeResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Gets the contents of a file or directory in a repository. Specify the file path or directory in `:path`. If you omit `:path`, you will receive the contents of all files in the repository.
     *
     * Files and symlinks support [a custom media type](https://developer.github.com/v3/repos/contents/#custom-media-types) for retrieving the raw content or rendered HTML (when supported). All content types support [a custom media type](https://developer.github.com/v3/repos/contents/#custom-media-types) to ensure the content is returned in a consistent object format.
     *
     * **Note**:
     *
     * *   To get a repository's contents recursively, you can [recursively get the tree](https://developer.github.com/v3/git/trees/).
     * *   This API has an upper limit of 1,000 files for a directory. If you need to retrieve more files, use the [Git Trees API](https://developer.github.com/v3/git/trees/#get-a-tree).
     * *   This API supports files up to 1 megabyte in size.
     *
     * The response will be an array of objects, one object for each item in the directory.
     *
     * When listing the contents of a directory, submodules have their "type" specified as "file". Logically, the value _should_ be "submodule". This behavior exists in API v3 [for backwards compatibility purposes](https://git.io/v1YCW). In the next major version of the API, the type will be returned as "submodule".
     *
     * If the requested `:path` points to a symlink, and the symlink's target is a normal file in the repository, then the API responds with the content of the file (in the [format shown above](https://developer.github.com/v3/repos/contents/#response-if-content-is-a-file)).
     *
     * Otherwise, the API responds with an object describing the symlink itself:
     *
     * The `submodule_git_url` identifies the location of the submodule repository, and the `sha` identifies a specific commit within the submodule repository. Git uses the given URL when cloning the submodule repository, and checks out the submodule at that specific commit.
     *
     * If the submodule repository is not hosted on github.com, the Git URLs (`git_url` and `_links["git"]`) and the github.com URLs (`html_url` and `_links["html"]`) will have null values.
     */
    getContents: {
      (params?: Octokit.ReposGetContentsParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Creates a new file or updates an existing file in a repository.
     */
    createOrUpdateFile: {
      (params?: Octokit.ReposCreateOrUpdateFileParams): Promise<
        Octokit.Response<Octokit.ReposCreateOrUpdateFileResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Creates a new file or updates an existing file in a repository.
     */
    createFile: {
      (params?: Octokit.ReposCreateFileParams): Promise<
        Octokit.Response<Octokit.ReposCreateFileResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Creates a new file or updates an existing file in a repository.
     */
    updateFile: {
      (params?: Octokit.ReposUpdateFileParams): Promise<
        Octokit.Response<Octokit.ReposUpdateFileResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Deletes a file in a repository.
     *
     * You can provide an additional `committer` parameter, which is an object containing information about the committer. Or, you can provide an `author` parameter, which is an object containing information about the author.
     *
     * The `author` section is optional and is filled in with the `committer` information if omitted. If the `committer` information is omitted, the authenticated user's information is used.
     *
     * You must provide values for both `name` and `email`, whether you choose to use `author` or `committer`. Otherwise, you'll receive a `422` status code.
     */
    deleteFile: {
      (params?: Octokit.ReposDeleteFileParams): Promise<
        Octokit.Response<Octokit.ReposDeleteFileResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Gets a redirect URL to download an archive for a repository. The `:archive_format` can be either `tarball` or `zipball`. The `:ref` must be a valid Git reference. If you omit `:ref`, the repository’s default branch (usually `master`) will be used. Please make sure your HTTP framework is configured to follow redirects or you will need to use the `Location` header to make a second `GET` request.
     *
     * _Note_: For private repositories, these links are temporary and expire after five minutes.
     *
     * To follow redirects with curl, use the `-L` switch:
     */
    getArchiveLink: {
      (params?: Octokit.ReposGetArchiveLinkParams): Promise<
        Octokit.Response<Octokit.ReposGetArchiveLinkResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Simple filtering of deployments is available via query parameters:
     */
    listDeployments: {
      (params?: Octokit.ReposListDeploymentsParams): Promise<
        Octokit.Response<Octokit.ReposListDeploymentsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getDeployment: {
      (params?: Octokit.ReposGetDeploymentParams): Promise<
        Octokit.Response<Octokit.ReposGetDeploymentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Deployments offer a few configurable parameters with sane defaults.
     *
     * The `ref` parameter can be any named branch, tag, or SHA. At GitHub we often deploy branches and verify them before we merge a pull request.
     *
     * The `environment` parameter allows deployments to be issued to different runtime environments. Teams often have multiple environments for verifying their applications, such as `production`, `staging`, and `qa`. This parameter makes it easier to track which environments have requested deployments. The default environment is `production`.
     *
     * The `auto_merge` parameter is used to ensure that the requested ref is not behind the repository's default branch. If the ref _is_ behind the default branch for the repository, we will attempt to merge it for you. If the merge succeeds, the API will return a successful merge commit. If merge conflicts prevent the merge from succeeding, the API will return a failure response.
     *
     * By default, [commit statuses](https://developer.github.com/v3/repos/statuses) for every submitted context must be in a `success` state. The `required_contexts` parameter allows you to specify a subset of contexts that must be `success`, or to specify contexts that have not yet been submitted. You are not required to use commit statuses to deploy. If you do not require any contexts or create any commit statuses, the deployment will always succeed.
     *
     * The `payload` parameter is available for any extra information that a deployment system might need. It is a JSON text field that will be passed on when a deployment event is dispatched.
     *
     * The `task` parameter is used by the deployment system to allow different execution paths. In the web world this might be `deploy:migrations` to run schema changes on the system. In the compiled world this could be a flag to compile an application with debugging enabled.
     *
     * Users with `repo` or `repo_deployment` scopes can create a deployment for a given ref:
     *
     * A simple example putting the user and room into the payload to notify back to chat networks.
     *
     * A more advanced example specifying required commit statuses and bypassing auto-merging.
     *
     * You will see this response when GitHub automatically merges the base branch into the topic branch instead of creating a deployment. This auto-merge happens when:
     *
     * *   Auto-merge option is enabled in the repository
     * *   Topic branch does not include the latest changes on the base branch, which is `master`in the response example
     * *   There are no merge conflicts
     *
     * If there are no new commits in the base branch, a new request to create a deployment should give a successful response.
     *
     * This error happens when the `auto_merge` option is enabled and when the default branch (in this case `master`), can't be merged into the branch that's being deployed (in this case `topic-branch`), due to merge conflicts.
     *
     * This error happens when the `required_contexts` parameter indicates that one or more contexts need to have a `success` status for the commit to be deployed, but one or more of the required contexts do not have a state of `success`.
     */
    createDeployment: {
      (params?: Octokit.ReposCreateDeploymentParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Users with pull access can view deployment statuses for a deployment:
     */
    listDeploymentStatuses: {
      (params?: Octokit.ReposListDeploymentStatusesParams): Promise<
        Octokit.Response<Octokit.ReposListDeploymentStatusesResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Users with pull access can view a deployment status for a deployment:
     */
    getDeploymentStatus: {
      (params?: Octokit.ReposGetDeploymentStatusParams): Promise<
        Octokit.Response<Octokit.ReposGetDeploymentStatusResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Users with `push` access can create deployment statuses for a given deployment.
     *
     * GitHub Apps require `read & write` access to "Deployments" and `read-only` access to "Repo contents" (for private repos). OAuth Apps require the `repo_deployment` scope.
     */
    createDeploymentStatus: {
      (params?: Octokit.ReposCreateDeploymentStatusParams): Promise<
        Octokit.Response<Octokit.ReposCreateDeploymentStatusResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listDownloads: {
      (params?: Octokit.ReposListDownloadsParams): Promise<
        Octokit.Response<Octokit.ReposListDownloadsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getDownload: {
      (params?: Octokit.ReposGetDownloadParams): Promise<
        Octokit.Response<Octokit.ReposGetDownloadResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    deleteDownload: {
      (params?: Octokit.ReposDeleteDownloadParams): Promise<
        Octokit.Response<Octokit.ReposDeleteDownloadResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listForks: {
      (params?: Octokit.ReposListForksParams): Promise<
        Octokit.Response<Octokit.ReposListForksResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Create a fork for the authenticated user.
     *
     * **Note**: Forking a Repository happens asynchronously. You may have to wait a short period of time before you can access the git objects. If this takes longer than 5 minutes, be sure to contact [GitHub Support](https://github.com/contact).
     */
    createFork: {
      (params?: Octokit.ReposCreateForkParams): Promise<
        Octokit.Response<Octokit.ReposCreateForkResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listHooks: {
      (params?: Octokit.ReposListHooksParams): Promise<
        Octokit.Response<Octokit.ReposListHooksResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getHook: {
      (params?: Octokit.ReposGetHookParams): Promise<
        Octokit.Response<Octokit.ReposGetHookResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Repositories can have multiple webhooks installed. Each webhook should have a unique `config`. Multiple webhooks can share the same `config` as long as those webhooks do not have any `events` that overlap.
     *
     * Here's how you can create a hook that posts payloads in JSON format:
     */
    createHook: {
      (params?: Octokit.ReposCreateHookParams): Promise<
        Octokit.Response<Octokit.ReposCreateHookResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    updateHook: {
      (params?: Octokit.ReposUpdateHookParams): Promise<
        Octokit.Response<Octokit.ReposUpdateHookResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This will trigger the hook with the latest push to the current repository if the hook is subscribed to `push` events. If the hook is not subscribed to `push` events, the server will respond with 204 but no test POST will be generated.
     *
     * **Note**: Previously `/repos/:owner/:repo/hooks/:hook_id/test`
     */
    testPushHook: {
      (params?: Octokit.ReposTestPushHookParams): Promise<
        Octokit.Response<Octokit.ReposTestPushHookResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This will trigger a [ping event](https://developer.github.com/webhooks/#ping-event) to be sent to the hook.
     */
    pingHook: {
      (params?: Octokit.ReposPingHookParams): Promise<
        Octokit.Response<Octokit.ReposPingHookResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    deleteHook: {
      (params?: Octokit.ReposDeleteHookParams): Promise<
        Octokit.Response<Octokit.ReposDeleteHookResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * When authenticating as a user with admin rights to a repository, this endpoint will list all currently open repository invitations.
     */
    listInvitations: {
      (params?: Octokit.ReposListInvitationsParams): Promise<
        Octokit.Response<Octokit.ReposListInvitationsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    deleteInvitation: {
      (params?: Octokit.ReposDeleteInvitationParams): Promise<
        Octokit.Response<Octokit.ReposDeleteInvitationResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    updateInvitation: {
      (params?: Octokit.ReposUpdateInvitationParams): Promise<
        Octokit.Response<Octokit.ReposUpdateInvitationResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * When authenticating as a user, this endpoint will list all currently open repository invitations for that user.
     */
    listInvitationsForAuthenticatedUser: {
      (
        params?: Octokit.ReposListInvitationsForAuthenticatedUserParams
      ): Promise<
        Octokit.Response<
          Octokit.ReposListInvitationsForAuthenticatedUserResponse
        >
      >;

      endpoint: Octokit.Endpoint;
    };

    acceptInvitation: {
      (params?: Octokit.ReposAcceptInvitationParams): Promise<
        Octokit.Response<Octokit.ReposAcceptInvitationResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    declineInvitation: {
      (params?: Octokit.ReposDeclineInvitationParams): Promise<
        Octokit.Response<Octokit.ReposDeclineInvitationResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listDeployKeys: {
      (params?: Octokit.ReposListDeployKeysParams): Promise<
        Octokit.Response<Octokit.ReposListDeployKeysResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getDeployKey: {
      (params?: Octokit.ReposGetDeployKeyParams): Promise<
        Octokit.Response<Octokit.ReposGetDeployKeyResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Here's how you can create a read-only deploy key:
     */
    addDeployKey: {
      (params?: Octokit.ReposAddDeployKeyParams): Promise<
        Octokit.Response<Octokit.ReposAddDeployKeyResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    removeDeployKey: {
      (params?: Octokit.ReposRemoveDeployKeyParams): Promise<
        Octokit.Response<Octokit.ReposRemoveDeployKeyResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    merge: {
      (params?: Octokit.ReposMergeParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };

    getPages: {
      (params?: Octokit.ReposGetPagesParams): Promise<
        Octokit.Response<Octokit.ReposGetPagesResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    enablePagesSite: {
      (params?: Octokit.ReposEnablePagesSiteParams): Promise<
        Octokit.Response<Octokit.ReposEnablePagesSiteResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    disablePagesSite: {
      (params?: Octokit.ReposDisablePagesSiteParams): Promise<
        Octokit.Response<Octokit.ReposDisablePagesSiteResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    updateInformationAboutPagesSite: {
      (params?: Octokit.ReposUpdateInformationAboutPagesSiteParams): Promise<
        Octokit.Response<Octokit.ReposUpdateInformationAboutPagesSiteResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * You can request that your site be built from the latest revision on the default branch. This has the same effect as pushing a commit to your default branch, but does not require an additional commit. Manually triggering page builds can be helpful when diagnosing build warnings and failures.
     *
     * Build requests are limited to one concurrent build per repository and one concurrent build per requester. If you request a build while another is still in progress, the second request will be queued until the first completes.
     */
    requestPageBuild: {
      (params?: Octokit.ReposRequestPageBuildParams): Promise<
        Octokit.Response<Octokit.ReposRequestPageBuildResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listPagesBuilds: {
      (params?: Octokit.ReposListPagesBuildsParams): Promise<
        Octokit.Response<Octokit.ReposListPagesBuildsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getLatestPagesBuild: {
      (params?: Octokit.ReposGetLatestPagesBuildParams): Promise<
        Octokit.Response<Octokit.ReposGetLatestPagesBuildResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    getPagesBuild: {
      (params?: Octokit.ReposGetPagesBuildParams): Promise<
        Octokit.Response<Octokit.ReposGetPagesBuildResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This returns a list of releases, which does not include regular Git tags that have not been associated with a release. To get a list of Git tags, use the [Repository Tags API](https://developer.github.com/v3/repos/#list-tags).
     *
     * Information about published releases are available to everyone. Only users with push access will receive listings for draft releases.
     */
    listReleases: {
      (params?: Octokit.ReposListReleasesParams): Promise<
        Octokit.Response<Octokit.ReposListReleasesResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Note:** This returns an `upload_url` key corresponding to the endpoint for uploading release assets. This key is a [hypermedia resource](https://developer.github.com/v3/#hypermedia).
     */
    getRelease: {
      (params?: Octokit.ReposGetReleaseParams): Promise<
        Octokit.Response<Octokit.ReposGetReleaseResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * View the latest published full release for the repository.
     *
     * The latest release is the most recent non-prerelease, non-draft release, sorted by the `created_at` attribute. The `created_at` attribute is the date of the commit used for the release, and not the date when the release was drafted or published.
     */
    getLatestRelease: {
      (params?: Octokit.ReposGetLatestReleaseParams): Promise<
        Octokit.Response<Octokit.ReposGetLatestReleaseResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Get a published release with the specified tag.
     */
    getReleaseByTag: {
      (params?: Octokit.ReposGetReleaseByTagParams): Promise<
        Octokit.Response<Octokit.ReposGetReleaseByTagResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Users with push access to the repository can create a release.
     *
     * This endpoint triggers [notifications](https://help.github.com/articles/about-notifications/). Creating content too quickly using this endpoint may result in abuse rate limiting. See "[Abuse rate limits](https://developer.github.com/v3/#abuse-rate-limits)" and "[Dealing with abuse rate limits](https://developer.github.com/v3/guides/best-practices-for-integrators/#dealing-with-abuse-rate-limits)" for details.
     */
    createRelease: {
      (params?: Octokit.ReposCreateReleaseParams): Promise<
        Octokit.Response<Octokit.ReposCreateReleaseResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Users with push access to the repository can edit a release.
     */
    updateRelease: {
      (params?: Octokit.ReposUpdateReleaseParams): Promise<
        Octokit.Response<Octokit.ReposUpdateReleaseResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Users with push access to the repository can delete a release.
     */
    deleteRelease: {
      (params?: Octokit.ReposDeleteReleaseParams): Promise<
        Octokit.Response<Octokit.ReposDeleteReleaseResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listAssetsForRelease: {
      (params?: Octokit.ReposListAssetsForReleaseParams): Promise<
        Octokit.Response<Octokit.ReposListAssetsForReleaseResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This endpoint makes use of [a Hypermedia relation](https://developer.github.com/v3/#hypermedia) to determine which URL to access. This endpoint is provided by a URI template in [the release's API response](https://developer.github.com/v3/repos/releases/#get-a-single-release). You need to use an HTTP client which supports [SNI](http://en.wikipedia.org/wiki/Server_Name_Indication) to make calls to this endpoint.
     *
     * The asset data is expected in its raw binary form, rather than JSON. Everything else about the endpoint is the same as the rest of the API. For example, you'll still need to pass your authentication to be able to upload an asset.
     *
     * Send the raw binary content of the asset as the request body.
     *
     * This may leave an empty asset with a state of `"new"`. It can be safely deleted.
     */
    uploadReleaseAsset: {
      (params?: Octokit.ReposUploadReleaseAssetParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * To download the asset's binary content, set the `Accept` header of the request to [`application/octet-stream`](https://developer.github.com/v3/media/#media-types). The API will either redirect the client to the location, or stream it directly if possible. API clients should handle both a `200` or `302` response.
     */
    getReleaseAsset: {
      (params?: Octokit.ReposGetReleaseAssetParams): Promise<
        Octokit.Response<Octokit.ReposGetReleaseAssetResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Users with push access to the repository can edit a release asset.
     */
    updateReleaseAsset: {
      (params?: Octokit.ReposUpdateReleaseAssetParams): Promise<
        Octokit.Response<Octokit.ReposUpdateReleaseAssetResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    deleteReleaseAsset: {
      (params?: Octokit.ReposDeleteReleaseAssetParams): Promise<
        Octokit.Response<Octokit.ReposDeleteReleaseAssetResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * *   `total` - The Total number of commits authored by the contributor.
     *
     * Weekly Hash (`weeks` array):
     *
     * *   `w` - Start of the week, given as a [Unix timestamp](http://en.wikipedia.org/wiki/Unix_time).
     * *   `a` - Number of additions
     * *   `d` - Number of deletions
     * *   `c` - Number of commits
     */
    getContributorsStats: {
      (params?: Octokit.ReposGetContributorsStatsParams): Promise<
        Octokit.Response<Octokit.ReposGetContributorsStatsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Returns the last year of commit activity grouped by week. The `days` array is a group of commits per day, starting on `Sunday`.
     */
    getCommitActivityStats: {
      (params?: Octokit.ReposGetCommitActivityStatsParams): Promise<
        Octokit.Response<Octokit.ReposGetCommitActivityStatsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Returns a weekly aggregate of the number of additions and deletions pushed to a repository.
     */
    getCodeFrequencyStats: {
      (params?: Octokit.ReposGetCodeFrequencyStatsParams): Promise<
        Octokit.Response<Octokit.ReposGetCodeFrequencyStatsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Returns the total commit counts for the `owner` and total commit counts in `all`. `all` is everyone combined, including the `owner` in the last 52 weeks. If you'd like to get the commit counts for non-owners, you can subtract `owner` from `all`.
     *
     * The array order is oldest week (index 0) to most recent week.
     */
    getParticipationStats: {
      (params?: Octokit.ReposGetParticipationStatsParams): Promise<
        Octokit.Response<Octokit.ReposGetParticipationStatsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Each array contains the day number, hour number, and number of commits:
     *
     * *   `0-6`: Sunday - Saturday
     * *   `0-23`: Hour of day
     * *   Number of commits
     *
     * For example, `[2, 14, 25]` indicates that there were 25 total commits, during the 2:00pm hour on Tuesdays. All times are based on the time zone of individual commits.
     */
    getPunchCardStats: {
      (params?: Octokit.ReposGetPunchCardStatsParams): Promise<
        Octokit.Response<Octokit.ReposGetPunchCardStatsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Users with push access in a repository can create commit statuses for a given SHA.
     *
     * Note: there is a limit of 1000 statuses per `sha` and `context` within a repository. Attempts to create more than 1000 statuses will result in a validation error.
     */
    createStatus: {
      (params?: Octokit.ReposCreateStatusParams): Promise<
        Octokit.Response<Octokit.ReposCreateStatusResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Users with pull access in a repository can view commit statuses for a given ref. The ref can be a SHA, a branch name, or a tag name. Statuses are returned in reverse chronological order. The first status in the list will be the latest one.
     *
     * This resource is also available via a legacy route: `GET /repos/:owner/:repo/statuses/:ref`.
     */
    listStatusesForRef: {
      (params?: Octokit.ReposListStatusesForRefParams): Promise<
        Octokit.Response<Octokit.ReposListStatusesForRefResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Users with pull access in a repository can access a combined view of commit statuses for a given ref. The ref can be a SHA, a branch name, or a tag name.
     *
     * The most recent status for each context is returned, up to 100. This field [paginates](https://developer.github.com/v3/#pagination) if there are over 100 contexts.
     *
     * Additionally, a combined `state` is returned. The `state` is one of:
     *
     * *   **failure** if any of the contexts report as `error` or `failure`
     * *   **pending** if there are no statuses or a context is `pending`
     * *   **success** if the latest status for all contexts is `success`
     */
    getCombinedStatusForRef: {
      (params?: Octokit.ReposGetCombinedStatusForRefParams): Promise<
        Octokit.Response<Octokit.ReposGetCombinedStatusForRefResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Get the top 10 referrers over the last 14 days.
     */
    getTopReferrers: {
      (params?: Octokit.ReposGetTopReferrersParams): Promise<
        Octokit.Response<Octokit.ReposGetTopReferrersResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Get the top 10 popular contents over the last 14 days.
     */
    getTopPaths: {
      (params?: Octokit.ReposGetTopPathsParams): Promise<
        Octokit.Response<Octokit.ReposGetTopPathsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Get the total number of views and breakdown per day or week for the last 14 days. Timestamps are aligned to UTC midnight of the beginning of the day or week. Week begins on Monday.
     */
    getViews: {
      (params?: Octokit.ReposGetViewsParams): Promise<
        Octokit.Response<Octokit.ReposGetViewsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Get the total number of clones and breakdown per day or week for the last 14 days. Timestamps are aligned to UTC midnight of the beginning of the day or week. Week begins on Monday.
     */
    getClones: {
      (params?: Octokit.ReposGetClonesParams): Promise<
        Octokit.Response<Octokit.ReposGetClonesResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  scim: {};
  search: {
    /**
     * Find repositories via various criteria. This method returns up to 100 results [per page](https://developer.github.com/v3/#pagination).
     *
     * When searching for repositories, you can get text match metadata for the **name** and **description** fields when you pass the `text-match` media type. For more details about how to receive highlighted search results, see [Text match metadata](https://developer.github.com/v3/search/#text-match-metadata).
     *
     * Suppose you want to search for popular Tetris repositories written in Assembly. Your query might look like this.
     *
     * You can search for multiple topics by adding more `topic:` instances, and including the `mercy-preview` header. For example:
     *
     * In this request, we're searching for repositories with the word `tetris` in the name, the description, or the README. We're limiting the results to only find repositories where the primary language is Assembly. We're sorting by stars in descending order, so that the most popular repositories appear first in the search results.
     */
    repos: {
      (params?: Octokit.SearchReposParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Find commits via various criteria. This method returns up to 100 results [per page](https://developer.github.com/v3/#pagination).
     *
     * When searching for commits, you can get text match metadata for the **message** field when you provide the `text-match` media type. For more details about how to receive highlighted search results, see [Text match metadata](https://developer.github.com/v3/search/#text-match-metadata).
     *
     * **Considerations for commit search**
     *
     * Only the _default branch_ is considered. In most cases, this will be the `master` branch.
     *
     * Suppose you want to find commits related to CSS in the [octocat/Spoon-Knife](https://github.com/octocat/Spoon-Knife) repository. Your query would look something like this:
     */
    commits: {
      (params?: Octokit.SearchCommitsParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Find file contents via various criteria. This method returns up to 100 results [per page](https://developer.github.com/v3/#pagination).
     *
     * When searching for code, you can get text match metadata for the file **content** and file **path** fields when you pass the `text-match` media type. For more details about how to receive highlighted search results, see [Text match metadata](https://developer.github.com/v3/search/#text-match-metadata).
     *
     * **Note:** You must [authenticate](https://developer.github.com/v3/#authentication) to search for code across all public repositories.
     *
     * **Considerations for code search**
     *
     * Due to the complexity of searching code, there are a few restrictions on how searches are performed:
     *
     * *   Only the _default branch_ is considered. In most cases, this will be the `master` branch.
     * *   Only files smaller than 384 KB are searchable.
     * *   You must always include at least one search term when searching source code. For example, searching for [`language:go`](https://github.com/search?utf8=%E2%9C%93&q=language%3Ago&type=Code) is not valid, while [`amazing language:go`](https://github.com/search?utf8=%E2%9C%93&q=amazing+language%3Ago&type=Code) is.
     *
     * Suppose you want to find the definition of the `addClass` function inside [jQuery](https://github.com/jquery/jquery). Your query would look something like this:
     *
     * Here, we're searching for the keyword `addClass` within a file's contents. We're making sure that we're only looking in files where the language is JavaScript. And we're scoping the search to the `repo:jquery/jquery` repository.
     */
    code: {
      (params?: Octokit.SearchCodeParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Find issues by state and keyword. This method returns up to 100 results [per page](https://developer.github.com/v3/#pagination).
     *
     * When searching for issues, you can get text match metadata for the issue **title**, issue **body**, and issue **comment body** fields when you pass the `text-match` media type. For more details about how to receive highlighted search results, see [Text match metadata](https://developer.github.com/v3/search/#text-match-metadata).
     *
     * Let's say you want to find the oldest unresolved Python bugs on Windows. Your query might look something like this.
     *
     * In this query, we're searching for the keyword `windows`, within any open issue that's labeled as `bug`. The search runs across repositories whose primary language is Python. We’re sorting by creation date in ascending order, so that the oldest issues appear first in the search results.
     */
    issuesAndPullRequests: {
      (params?: Octokit.SearchIssuesAndPullRequestsParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Find issues by state and keyword. This method returns up to 100 results [per page](https://developer.github.com/v3/#pagination).
     *
     * When searching for issues, you can get text match metadata for the issue **title**, issue **body**, and issue **comment body** fields when you pass the `text-match` media type. For more details about how to receive highlighted search results, see [Text match metadata](https://developer.github.com/v3/search/#text-match-metadata).
     *
     * Let's say you want to find the oldest unresolved Python bugs on Windows. Your query might look something like this.
     *
     * In this query, we're searching for the keyword `windows`, within any open issue that's labeled as `bug`. The search runs across repositories whose primary language is Python. We’re sorting by creation date in ascending order, so that the oldest issues appear first in the search results.
     */
    issues: {
      (params?: Octokit.SearchIssuesParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Find users via various criteria. This method returns up to 100 results [per page](https://developer.github.com/v3/#pagination).
     *
     * When searching for users, you can get text match metadata for the issue **login**, **email**, and **name** fields when you pass the `text-match` media type. For more details about highlighting search results, see [Text match metadata](https://developer.github.com/v3/search/#text-match-metadata). For more details about how to receive highlighted search results, see [Text match metadata](https://developer.github.com/v3/search/#text-match-metadata).
     *
     * Imagine you're looking for a list of popular users. You might try out this query:
     *
     * Here, we're looking at users with the name Tom. We're only interested in those with more than 42 repositories, and only if they have over 1,000 followers.
     */
    users: {
      (params?: Octokit.SearchUsersParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Find topics via various criteria. Results are sorted by best match. This method returns up to 100 results [per page](https://developer.github.com/v3/#pagination).
     *
     * When searching for topics, you can get text match metadata for the topic's **short\_description**, **description**, **name**, or **display\_name** field when you pass the `text-match` media type. For more details about how to receive highlighted search results, see [Text match metadata](https://developer.github.com/v3/search/#text-match-metadata).
     *
     * See "[Searching topics](https://help.github.com/articles/searching-topics/)" for a detailed list of qualifiers.
     *
     * Suppose you want to search for topics related to Ruby that are featured on [https://github.com/topics](https://github.com/topics). Your query might look like this:
     *
     * In this request, we're searching for topics with the keyword `ruby`, and we're limiting the results to find only topics that are featured. The topics that are the best match for the query appear first in the search results.
     *
     * **Note:** A search for featured Ruby topics only has 6 total results, so a [Link header](https://developer.github.com/v3/#link-header) indicating pagination is not included in the response.
     */
    topics: {
      (params?: Octokit.SearchTopicsParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Find labels in a repository with names or descriptions that match search keywords. Returns up to 100 results [per page](https://developer.github.com/v3/#pagination).
     *
     * When searching for labels, you can get text match metadata for the label **name** and **description** fields when you pass the `text-match` media type. For more details about how to receive highlighted search results, see [Text match metadata](https://developer.github.com/v3/search/#text-match-metadata).
     *
     * Suppose you want to find labels in the `linguist` repository that match `bug`, `defect`, or `enhancement`. Your query might look like this:
     *
     * The labels that best match for the query appear first in the search results.
     */
    labels: {
      (params?: Octokit.SearchLabelsParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
  };
  teams: {
    list: {
      (params?: Octokit.TeamsListParams): Promise<
        Octokit.Response<Octokit.TeamsListResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    get: {
      (params?: Octokit.TeamsGetParams): Promise<
        Octokit.Response<Octokit.TeamsGetResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Gets a team using the team's `slug`. GitHub generates the `slug` from the team `name`.
     */
    getByName: {
      (params?: Octokit.TeamsGetByNameParams): Promise<
        Octokit.Response<Octokit.TeamsGetByNameResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * To create a team, the authenticated user must be a member or owner of `:org`. By default, organization members can create teams. Organization owners can limit team creation to organization owners. For more information, see "[Setting team creation permissions](https://help.github.com/en/articles/setting-team-creation-permissions-in-your-organization)."
     */
    create: {
      (params?: Octokit.TeamsCreateParams): Promise<
        Octokit.Response<Octokit.TeamsCreateResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * To edit a team, the authenticated user must either be an owner of the org that the team is associated with, or a maintainer of the team.
     *
     * **Note:** With nested teams, the `privacy` for parent teams cannot be `secret`.
     */
    update: {
      (params?: Octokit.TeamsUpdateParams): Promise<
        Octokit.Response<Octokit.TeamsUpdateResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * To delete a team, the authenticated user must be a team maintainer or an owner of the org associated with the team.
     *
     * If you are an organization owner and you pass the `hellcat-preview` media type, deleting a parent team will delete all of its child teams as well.
     */
    delete: {
      (params?: Octokit.TeamsDeleteParams): Promise<
        Octokit.Response<Octokit.TeamsDeleteResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * At this time, the `hellcat-preview` media type is required to use this endpoint.
     */
    listChild: {
      (params?: Octokit.TeamsListChildParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Note**: If you pass the `hellcat-preview` media type, the response will include any repositories inherited through a parent team.
     */
    listRepos: {
      (params?: Octokit.TeamsListReposParams): Promise<
        Octokit.Response<Octokit.TeamsListReposResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Note**: If you pass the `hellcat-preview` media type, repositories inherited through a parent team will be checked.
     *
     * You can also get information about the specified repository, including what permissions the team grants on it, by passing the following custom [media type](https://developer.github.com/v3/media/) via the `Accept` header:
     */
    checkManagesRepo: {
      (params?: Octokit.TeamsCheckManagesRepoParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * To add a repository to a team or update the team's permission on a repository, the authenticated user must have admin access to the repository, and must be able to see the team. The repository must be owned by the organization, or a direct fork of a repository owned by the organization. You will get a `422 Unprocessable Entity` status if you attempt to add a repository to a team that is not owned by the organization.
     *
     * If you pass the `hellcat-preview` media type, you can modify repository permissions of child teams.
     *
     * Note that, if you choose not to pass any parameters, you'll need to set `Content-Length` to zero when calling out to this endpoint. For more information, see "[HTTP verbs](https://developer.github.com/v3/#http-verbs)."
     */
    addOrUpdateRepo: {
      (params?: Octokit.TeamsAddOrUpdateRepoParams): Promise<
        Octokit.Response<Octokit.TeamsAddOrUpdateRepoResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * If the authenticated user is an organization owner or a team maintainer, they can remove any repositories from the team. To remove a repository from a team as an organization member, the authenticated user must have admin access to the repository and must be able to see the team. NOTE: This does not delete the repository, it just removes it from the team.
     */
    removeRepo: {
      (params?: Octokit.TeamsRemoveRepoParams): Promise<
        Octokit.Response<Octokit.TeamsRemoveRepoResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * List all of the teams across all of the organizations to which the authenticated user belongs. This method requires `user`, `repo`, or `read:org` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/) when authenticating via [OAuth](https://developer.github.com/apps/building-oauth-apps/).
     */
    listForAuthenticatedUser: {
      (params?: Octokit.TeamsListForAuthenticatedUserParams): Promise<
        Octokit.Response<Octokit.TeamsListForAuthenticatedUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists the organization projects for a team. If you pass the `hellcat-preview` media type, the response will include projects inherited from a parent team.
     */
    listProjects: {
      (params?: Octokit.TeamsListProjectsParams): Promise<
        Octokit.Response<Octokit.TeamsListProjectsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Checks whether a team has `read`, `write`, or `admin` permissions for an organization project. If you pass the `hellcat-preview` media type, the response will include projects inherited from a parent team.
     */
    reviewProject: {
      (params?: Octokit.TeamsReviewProjectParams): Promise<
        Octokit.Response<Octokit.TeamsReviewProjectResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Adds an organization project to a team. To add a project to a team or update the team's permission on a project, the authenticated user must have `admin` permissions for the project. The project and team must be part of the same organization.
     */
    addOrUpdateProject: {
      (params?: Octokit.TeamsAddOrUpdateProjectParams): Promise<
        Octokit.Response<Octokit.TeamsAddOrUpdateProjectResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Removes an organization project from a team. An organization owner or a team maintainer can remove any project from the team. To remove a project from a team as an organization member, the authenticated user must have `read` access to both the team and project, or `admin` access to the team or project. **Note:** This endpoint removes the project from the team, but does not delete it.
     */
    removeProject: {
      (params?: Octokit.TeamsRemoveProjectParams): Promise<
        Octokit.Response<Octokit.TeamsRemoveProjectResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * List all comments on a team discussion. OAuth access tokens require the `read:discussion` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).
     */
    listDiscussionComments: {
      (params?: Octokit.TeamsListDiscussionCommentsParams): Promise<
        Octokit.Response<Octokit.TeamsListDiscussionCommentsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Get a specific comment on a team discussion. OAuth access tokens require the `read:discussion` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).
     */
    getDiscussionComment: {
      (params?: Octokit.TeamsGetDiscussionCommentParams): Promise<
        Octokit.Response<Octokit.TeamsGetDiscussionCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Creates a new comment on a team discussion. OAuth access tokens require the `write:discussion` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).
     *
     * This endpoint triggers [notifications](https://help.github.com/articles/about-notifications/). Creating content too quickly using this endpoint may result in abuse rate limiting. See "[Abuse rate limits](https://developer.github.com/v3/#abuse-rate-limits)" and "[Dealing with abuse rate limits](https://developer.github.com/v3/guides/best-practices-for-integrators/#dealing-with-abuse-rate-limits)" for details.
     */
    createDiscussionComment: {
      (params?: Octokit.TeamsCreateDiscussionCommentParams): Promise<
        Octokit.Response<Octokit.TeamsCreateDiscussionCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Edits the body text of a discussion comment. OAuth access tokens require the `write:discussion` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).
     */
    updateDiscussionComment: {
      (params?: Octokit.TeamsUpdateDiscussionCommentParams): Promise<
        Octokit.Response<Octokit.TeamsUpdateDiscussionCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Deletes a comment on a team discussion. OAuth access tokens require the `write:discussion` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).
     */
    deleteDiscussionComment: {
      (params?: Octokit.TeamsDeleteDiscussionCommentParams): Promise<
        Octokit.Response<Octokit.TeamsDeleteDiscussionCommentResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * List all discussions on a team's page. OAuth access tokens require the `read:discussion` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).
     */
    listDiscussions: {
      (params?: Octokit.TeamsListDiscussionsParams): Promise<
        Octokit.Response<Octokit.TeamsListDiscussionsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Get a specific discussion on a team's page. OAuth access tokens require the `read:discussion` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).
     */
    getDiscussion: {
      (params?: Octokit.TeamsGetDiscussionParams): Promise<
        Octokit.Response<Octokit.TeamsGetDiscussionResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Creates a new discussion post on a team's page. OAuth access tokens require the `write:discussion` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).
     *
     * This endpoint triggers [notifications](https://help.github.com/articles/about-notifications/). Creating content too quickly using this endpoint may result in abuse rate limiting. See "[Abuse rate limits](https://developer.github.com/v3/#abuse-rate-limits)" and "[Dealing with abuse rate limits](https://developer.github.com/v3/guides/best-practices-for-integrators/#dealing-with-abuse-rate-limits)" for details.
     */
    createDiscussion: {
      (params?: Octokit.TeamsCreateDiscussionParams): Promise<
        Octokit.Response<Octokit.TeamsCreateDiscussionResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Edits the title and body text of a discussion post. Only the parameters you provide are updated. OAuth access tokens require the `write:discussion` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).
     */
    updateDiscussion: {
      (params?: Octokit.TeamsUpdateDiscussionParams): Promise<
        Octokit.Response<Octokit.TeamsUpdateDiscussionResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Delete a discussion from a team's page. OAuth access tokens require the `write:discussion` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).
     */
    deleteDiscussion: {
      (params?: Octokit.TeamsDeleteDiscussionParams): Promise<
        Octokit.Response<Octokit.TeamsDeleteDiscussionResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * If you pass the `hellcat-preview` media type, team members will include the members of child teams.
     */
    listMembers: {
      (params?: Octokit.TeamsListMembersParams): Promise<
        Octokit.Response<Octokit.TeamsListMembersResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * The "Get team member" API (described below) is deprecated.
     *
     * We recommend using the [Get team membership API](https://developer.github.com/v3/teams/members/#get-team-membership) instead. It allows you to get both active and pending memberships.
     *
     * To list members in a team, the team must be visible to the authenticated user.
     */
    getMember: {
      (params?: Octokit.TeamsGetMemberParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * The "Add team member" API (described below) is deprecated.
     *
     * We recommend using the [Add team membership API](https://developer.github.com/v3/teams/members/#add-or-update-team-membership) instead. It allows you to invite new organization members to your teams.
     *
     * Team synchronization is available for organizations using GitHub Enterprise Cloud. For more information, see [GitHub's products](https://help.github.com/articles/github-s-products) in the GitHub Help documentation.
     *
     * To add someone to a team, the authenticated user must be a team maintainer in the team they're changing or be an owner of the organization that the team is associated with. The person being added to the team must be a member of the team's organization.
     *
     * **Note:** When you have team synchronization set up for a team with your organization's identity provider (IdP), you will see an error if you attempt to use the API for making changes to the team's membership. If you have access to manage group membership in your IdP, you can manage GitHub team membership through your identity provider, which automatically adds and removes team members in an organization. For more information, see "[Synchronizing teams between your identity provider and GitHub](https://help.github.com/articles/synchronizing-teams-between-your-identity-provider-and-github/)."
     *
     * Note that you'll need to set `Content-Length` to zero when calling out to this endpoint. For more information, see "[HTTP verbs](https://developer.github.com/v3/#http-verbs)."
     */
    addMember: {
      (params?: Octokit.TeamsAddMemberParams): Promise<
        Octokit.Response<Octokit.TeamsAddMemberResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * The "Remove team member" API (described below) is deprecated.
     *
     * We recommend using the [Remove team membership endpoint](https://developer.github.com/v3/teams/members/#remove-team-membership) instead. It allows you to remove both active and pending memberships.
     *
     * Team synchronization is available for organizations using GitHub Enterprise Cloud. For more information, see [GitHub's products](https://help.github.com/articles/github-s-products) in the GitHub Help documentation.
     *
     * To remove a team member, the authenticated user must have 'admin' permissions to the team or be an owner of the org that the team is associated with. Removing a team member does not delete the user, it just removes them from the team.
     *
     * **Note:** When you have team synchronization set up for a team with your organization's identity provider (IdP), you will see an error if you attempt to use the API for making changes to the team's membership. If you have access to manage group membership in your IdP, you can manage GitHub team membership through your identity provider, which automatically adds and removes team members in an organization. For more information, see "[Synchronizing teams between your identity provider and GitHub](https://help.github.com/articles/synchronizing-teams-between-your-identity-provider-and-github/)."
     */
    removeMember: {
      (params?: Octokit.TeamsRemoveMemberParams): Promise<
        Octokit.Response<Octokit.TeamsRemoveMemberResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * If you pass the `hellcat-preview` media type, team members will include the members of child teams.
     *
     * To get a user's membership with a team, the team must be visible to the authenticated user.
     *
     * **Note:** The `role` for organization owners returns as `maintainer`. For more information about `maintainer` roles, see [Create team](https://developer.github.com/v3/teams#create-team).
     */
    getMembership: {
      (params?: Octokit.TeamsGetMembershipParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Team synchronization is available for organizations using GitHub Enterprise Cloud. For more information, see [GitHub's products](https://help.github.com/articles/github-s-products) in the GitHub Help documentation.
     *
     * If the user is already a member of the team's organization, this endpoint will add the user to the team. To add a membership between an organization member and a team, the authenticated user must be an organization owner or a maintainer of the team.
     *
     * **Note:** When you have team synchronization set up for a team with your organization's identity provider (IdP), you will see an error if you attempt to use the API for making changes to the team's membership. If you have access to manage group membership in your IdP, you can manage GitHub team membership through your identity provider, which automatically adds and removes team members in an organization. For more information, see "[Synchronizing teams between your identity provider and GitHub](https://help.github.com/articles/synchronizing-teams-between-your-identity-provider-and-github/)."
     *
     * If the user is unaffiliated with the team's organization, this endpoint will send an invitation to the user via email. This newly-created membership will be in the "pending" state until the user accepts the invitation, at which point the membership will transition to the "active" state and the user will be added as a member of the team. To add a membership between an unaffiliated user and a team, the authenticated user must be an organization owner.
     *
     * If the user is already a member of the team, this endpoint will update the role of the team member's role. To update the membership of a team member, the authenticated user must be an organization owner or a maintainer of the team.
     */
    addOrUpdateMembership: {
      (params?: Octokit.TeamsAddOrUpdateMembershipParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Team synchronization is available for organizations using GitHub Enterprise Cloud. For more information, see [GitHub's products](https://help.github.com/articles/github-s-products) in the GitHub Help documentation.
     *
     * To remove a membership between a user and a team, the authenticated user must have 'admin' permissions to the team or be an owner of the organization that the team is associated with. Removing team membership does not delete the user, it just removes their membership from the team.
     *
     * **Note:** When you have team synchronization set up for a team with your organization's identity provider (IdP), you will see an error if you attempt to use the API for making changes to the team's membership. If you have access to manage group membership in your IdP, you can manage GitHub team membership through your identity provider, which automatically adds and removes team members in an organization. For more information, see "[Synchronizing teams between your identity provider and GitHub](https://help.github.com/articles/synchronizing-teams-between-your-identity-provider-and-github/)."
     */
    removeMembership: {
      (params?: Octokit.TeamsRemoveMembershipParams): Promise<
        Octokit.Response<Octokit.TeamsRemoveMembershipResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * The return hash contains a `role` field which refers to the Organization Invitation role and will be one of the following values: `direct_member`, `admin`, `billing_manager`, `hiring_manager`, or `reinstate`. If the invitee is not a GitHub member, the `login` field in the return hash will be `null`.
     */
    listPendingInvitations: {
      (params?: Octokit.TeamsListPendingInvitationsParams): Promise<
        Octokit.Response<Octokit.TeamsListPendingInvitationsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
  };
  users: {
    /**
     * Provides publicly available information about someone with a GitHub account.
     *
     * GitHub Apps with the `Plan` user permission can use this endpoint to retrieve information about a user's GitHub plan. The GitHub App must be authenticated as a user. See "[Identifying and authorizing users for GitHub Apps](https://developer.github.com/apps/building-github-apps/identifying-and-authorizing-users-for-github-apps/)" for details about authentication. For an example response, see "[Response with GitHub plan information](https://developer.github.com/v3/users/#response-with-github-plan-information)."
     *
     * The `email` key in the following response is the publicly visible email address from your GitHub [profile page](https://github.com/settings/profile). When setting up your profile, you can select a primary email address to be “public” which provides an email entry for this endpoint. If you do not set a public email address for `email`, then it will have a value of `null`. You only see publicly visible email addresses when authenticated with GitHub. For more information, see [Authentication](https://developer.github.com/v3/#authentication).
     *
     * The Emails API enables you to list all of your email addresses, and toggle a primary email to be visible publicly. For more information, see "[Emails API](https://developer.github.com/v3/users/emails/)".
     */
    getByUsername: {
      (params?: Octokit.UsersGetByUsernameParams): Promise<
        Octokit.Response<Octokit.UsersGetByUsernameResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists public and private profile information when authenticated through basic auth or OAuth with the `user` scope.
     *
     * Lists public profile information when authenticated through OAuth without the `user` scope.
     */
    getAuthenticated: {
      (params?: Octokit.EmptyParams): Promise<Octokit.AnyResponse>;

      endpoint: Octokit.Endpoint;
    };
    /**
     * **Note:** If your email is set to private and you send an `email` parameter as part of this request to update your profile, your privacy settings are still enforced: the email address will not be displayed on your public profile or via the API.
     */
    updateAuthenticated: {
      (params?: Octokit.UsersUpdateAuthenticatedParams): Promise<
        Octokit.Response<Octokit.UsersUpdateAuthenticatedResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Provides hovercard information when authenticated through basic auth or OAuth with the `repo` scope. You can find out more about someone in relation to their pull requests, issues, repositories, and organizations.
     *
     * The `subject_type` and `subject_id` parameters provide context for the person's hovercard, which returns more information than without the parameters. For example, if you wanted to find out more about `octocat` who owns the `Spoon-Knife` repository via cURL, it would look like this:
     */
    getContextForUser: {
      (params?: Octokit.UsersGetContextForUserParams): Promise<
        Octokit.Response<Octokit.UsersGetContextForUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists all users, in the order that they signed up on GitHub. This list includes personal user accounts and organization accounts.
     *
     * Note: Pagination is powered exclusively by the `since` parameter. Use the [Link header](https://developer.github.com/v3/#link-header) to get the URL for the next page of users.
     */
    list: {
      (params?: Octokit.UsersListParams): Promise<
        Octokit.Response<Octokit.UsersListResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * List the users you've blocked on your personal account.
     */
    listBlocked: {
      (params?: Octokit.EmptyParams): Promise<
        Octokit.Response<Octokit.UsersListBlockedResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * If the user is blocked:
     *
     * If the user is not blocked:
     */
    checkBlocked: {
      (params?: Octokit.UsersCheckBlockedParams): Promise<
        Octokit.Response<Octokit.UsersCheckBlockedResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    block: {
      (params?: Octokit.UsersBlockParams): Promise<
        Octokit.Response<Octokit.UsersBlockResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    unblock: {
      (params?: Octokit.UsersUnblockParams): Promise<
        Octokit.Response<Octokit.UsersUnblockResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists all of your email addresses, and specifies which one is visible to the public. This endpoint is accessible with the `user:email` scope.
     */
    listEmails: {
      (params?: Octokit.UsersListEmailsParams): Promise<
        Octokit.Response<Octokit.UsersListEmailsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists your publicly visible email address, which you can set with the [Toggle primary email visibility](https://developer.github.com/v3/users/emails/#toggle-primary-email-visibility) endpoint. This endpoint is accessible with the `user:email` scope.
     */
    listPublicEmails: {
      (params?: Octokit.UsersListPublicEmailsParams): Promise<
        Octokit.Response<Octokit.UsersListPublicEmailsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This endpoint is accessible with the `user` scope.
     */
    addEmails: {
      (params?: Octokit.UsersAddEmailsParams): Promise<
        Octokit.Response<Octokit.UsersAddEmailsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * This endpoint is accessible with the `user` scope.
     */
    deleteEmails: {
      (params?: Octokit.UsersDeleteEmailsParams): Promise<
        Octokit.Response<Octokit.UsersDeleteEmailsResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Sets the visibility for your primary email addresses.
     */
    togglePrimaryEmailVisibility: {
      (params?: Octokit.UsersTogglePrimaryEmailVisibilityParams): Promise<
        Octokit.Response<Octokit.UsersTogglePrimaryEmailVisibilityResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listFollowersForUser: {
      (params?: Octokit.UsersListFollowersForUserParams): Promise<
        Octokit.Response<Octokit.UsersListFollowersForUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listFollowersForAuthenticatedUser: {
      (params?: Octokit.UsersListFollowersForAuthenticatedUserParams): Promise<
        Octokit.Response<Octokit.UsersListFollowersForAuthenticatedUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listFollowingForUser: {
      (params?: Octokit.UsersListFollowingForUserParams): Promise<
        Octokit.Response<Octokit.UsersListFollowingForUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    listFollowingForAuthenticatedUser: {
      (params?: Octokit.UsersListFollowingForAuthenticatedUserParams): Promise<
        Octokit.Response<Octokit.UsersListFollowingForAuthenticatedUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };

    checkFollowing: {
      (params?: Octokit.UsersCheckFollowingParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };

    checkFollowingForUser: {
      (params?: Octokit.UsersCheckFollowingForUserParams): Promise<
        Octokit.AnyResponse
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Note that you'll need to set `Content-Length` to zero when calling out to this endpoint. For more information, see "[HTTP verbs](https://developer.github.com/v3/#http-verbs)."
     *
     * Following a user requires the user to be logged in and authenticated with basic auth or OAuth with the `user:follow` scope.
     */
    follow: {
      (params?: Octokit.UsersFollowParams): Promise<
        Octokit.Response<Octokit.UsersFollowResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Unfollowing a user requires the user to be logged in and authenticated with basic auth or OAuth with the `user:follow` scope.
     */
    unfollow: {
      (params?: Octokit.UsersUnfollowParams): Promise<
        Octokit.Response<Octokit.UsersUnfollowResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists the GPG keys for a user. This information is accessible by anyone.
     */
    listGpgKeysForUser: {
      (params?: Octokit.UsersListGpgKeysForUserParams): Promise<
        Octokit.Response<Octokit.UsersListGpgKeysForUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists the current user's GPG keys. Requires that you are authenticated via Basic Auth or via OAuth with at least `read:gpg_key` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).
     */
    listGpgKeys: {
      (params?: Octokit.UsersListGpgKeysParams): Promise<
        Octokit.Response<Octokit.UsersListGpgKeysResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * View extended details for a single GPG key. Requires that you are authenticated via Basic Auth or via OAuth with at least `read:gpg_key` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).
     */
    getGpgKey: {
      (params?: Octokit.UsersGetGpgKeyParams): Promise<
        Octokit.Response<Octokit.UsersGetGpgKeyResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Adds a GPG key to the authenticated user's GitHub account. Requires that you are authenticated via Basic Auth, or OAuth with at least `write:gpg_key` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).
     */
    createGpgKey: {
      (params?: Octokit.UsersCreateGpgKeyParams): Promise<
        Octokit.Response<Octokit.UsersCreateGpgKeyResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Removes a GPG key from the authenticated user's GitHub account. Requires that you are authenticated via Basic Auth or via OAuth with at least `admin:gpg_key` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).
     */
    deleteGpgKey: {
      (params?: Octokit.UsersDeleteGpgKeyParams): Promise<
        Octokit.Response<Octokit.UsersDeleteGpgKeyResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists the _verified_ public SSH keys for a user. This is accessible by anyone.
     */
    listPublicKeysForUser: {
      (params?: Octokit.UsersListPublicKeysForUserParams): Promise<
        Octokit.Response<Octokit.UsersListPublicKeysForUserResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Lists the public SSH keys for the authenticated user's GitHub account. Requires that you are authenticated via Basic Auth or via OAuth with at least `read:public_key` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).
     */
    listPublicKeys: {
      (params?: Octokit.UsersListPublicKeysParams): Promise<
        Octokit.Response<Octokit.UsersListPublicKeysResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * View extended details for a single public SSH key. Requires that you are authenticated via Basic Auth or via OAuth with at least `read:public_key` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).
     */
    getPublicKey: {
      (params?: Octokit.UsersGetPublicKeyParams): Promise<
        Octokit.Response<Octokit.UsersGetPublicKeyResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Adds a public SSH key to the authenticated user's GitHub account. Requires that you are authenticated via Basic Auth, or OAuth with at least `write:public_key` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).
     */
    createPublicKey: {
      (params?: Octokit.UsersCreatePublicKeyParams): Promise<
        Octokit.Response<Octokit.UsersCreatePublicKeyResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
    /**
     * Removes a public SSH key from the authenticated user's GitHub account. Requires that you are authenticated via Basic Auth or via OAuth with at least `admin:public_key` [scope](https://developer.github.com/apps/building-oauth-apps/understanding-scopes-for-oauth-apps/).
     */
    deletePublicKey: {
      (params?: Octokit.UsersDeletePublicKeyParams): Promise<
        Octokit.Response<Octokit.UsersDeletePublicKeyResponse>
      >;

      endpoint: Octokit.Endpoint;
    };
  };
}

export = Octokit;
