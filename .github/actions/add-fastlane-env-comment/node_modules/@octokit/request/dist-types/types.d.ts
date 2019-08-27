/// <reference types="node" />
import { Agent } from "http";
import { endpoint } from "@octokit/endpoint";
export interface request {
    /**
     * Sends a request based on endpoint options
     *
     * @param {object} endpoint Must set `method` and `url`. Plus URL, query or body parameters, as well as `headers`, `mediaType.{format|previews}`, `request`, or `baseUrl`.
     */
    <T = any>(options: Endpoint): Promise<OctokitResponse<T>>;
    /**
     * Sends a request based on endpoint options
     *
     * @param {string} route Request method + URL. Example: `'GET /orgs/:org'`
     * @param {object} [parameters] URL, query or body parameters, as well as `headers`, `mediaType.{format|previews}`, `request`, or `baseUrl`.
     */
    <T = any>(route: Route, parameters?: Parameters): Promise<OctokitResponse<T>>;
    /**
     * Returns a new `endpoint` with updated route and parameters
     */
    defaults: (newDefaults: Parameters) => request;
    /**
     * Octokit endpoint API, see {@link https://github.com/octokit/endpoint.js|@octokit/endpoint}
     */
    endpoint: typeof endpoint;
}
export declare type endpoint = typeof endpoint;
/**
 * Request method + URL. Example: `'GET /orgs/:org'`
 */
export declare type Route = string;
/**
 * Relative or absolute URL. Examples: `'/orgs/:org'`, `https://example.com/foo/bar`
 */
export declare type Url = string;
/**
 * Request method
 */
export declare type Method = "DELETE" | "GET" | "HEAD" | "PATCH" | "POST" | "PUT";
/**
 * Endpoint parameters
 */
export declare type Parameters = {
    /**
     * Base URL to be used when a relative URL is passed, such as `/orgs/:org`.
     * If `baseUrl` is `https://enterprise.acme-inc.com/api/v3`, then the request
     * will be sent to `https://enterprise.acme-inc.com/api/v3/orgs/:org`.
     */
    baseUrl?: string;
    /**
     * HTTP headers. Use lowercase keys.
     */
    headers?: RequestHeaders;
    /**
     * Media type options, see {@link https://developer.github.com/v3/media/|GitHub Developer Guide}
     */
    mediaType?: {
        /**
         * `json` by default. Can be `raw`, `text`, `html`, `full`, `diff`, `patch`, `sha`, `base64`. Depending on endpoint
         */
        format?: string;
        /**
         * Custom media type names of {@link https://developer.github.com/v3/media/|API Previews} without the `-preview` suffix.
         * Example for single preview: `['squirrel-girl']`.
         * Example for multiple previews: `['squirrel-girl', 'mister-fantastic']`.
         */
        previews?: string[];
    };
    /**
     * Pass custom meta information for the request. The `request` object will be returned as is.
     */
    request?: OctokitRequestOptions;
    /**
     * Any additional parameter will be passed as follows
     * 1. URL parameter if `':parameter'` or `{parameter}` is part of `url`
     * 2. Query parameter if `method` is `'GET'` or `'HEAD'`
     * 3. Request body if `parameter` is `'data'`
     * 4. JSON in the request body in the form of `body[parameter]` unless `parameter` key is `'data'`
     */
    [parameter: string]: any;
};
export declare type Endpoint = Parameters & {
    method: Method;
    url: Url;
};
export declare type Defaults = Parameters & {
    method: Method;
    baseUrl: string;
    headers: RequestHeaders & {
        accept: string;
        "user-agent": string;
    };
    mediaType: {
        format: string;
        previews: string[];
    };
};
export declare type OctokitResponse<T> = {
    headers: ResponseHeaders;
    /**
     * http response code
     */
    status: number;
    /**
     * URL of response after all redirects
     */
    url: string;
    /**
     *  This is the data you would see in https://developer.Octokit.com/v3/
     */
    data: T;
};
export declare type AnyResponse = OctokitResponse<any>;
export declare type RequestHeaders = {
    /**
     * Avoid setting `accept`, use `mediaFormat.{format|previews}` instead.
     */
    accept?: string;
    /**
     * Use `authorization` to send authenticated request, remember `token ` / `bearer ` prefixes. Example: `token 1234567890abcdef1234567890abcdef12345678`
     */
    authorization?: string;
    /**
     * `user-agent` is set do a default and can be overwritten as needed.
     */
    "user-agent"?: string;
    [header: string]: string | number | undefined;
};
export declare type ResponseHeaders = {
    [header: string]: string;
};
export declare type Fetch = any;
export declare type Signal = any;
export declare type OctokitRequestOptions = {
    /**
     * Node only. Useful for custom proxy, certificate, or dns lookup.
     */
    agent?: Agent;
    /**
     * Custom replacement for built-in fetch method. Useful for testing or request hooks.
     */
    fetch?: Fetch;
    /**
     * Use an `AbortController` instance to cancel a request. In node you can only cancel streamed requests.
     */
    signal?: Signal;
    /**
     * Node only. Request/response timeout in ms, it resets on redirect. 0 to disable (OS limit applies). `options.request.signal` is recommended instead.
     */
    timeout?: number;
    [option: string]: any;
};
