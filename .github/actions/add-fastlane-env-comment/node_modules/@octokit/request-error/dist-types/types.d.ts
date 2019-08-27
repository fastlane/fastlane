/**
 * Relative or absolute URL. Examples: `'/orgs/:org'`, `https://example.com/foo/bar`
 */
export declare type Url = string;
/**
 * Request method
 */
export declare type Method = "DELETE" | "GET" | "HEAD" | "PATCH" | "POST" | "PUT";
export declare type RequestHeaders = {
    /**
     * Used for API previews and custom formats
     */
    accept?: string;
    /**
     * Redacted authorization header
     */
    authorization?: string;
    "user-agent"?: string;
    [header: string]: string | number | undefined;
};
export declare type ResponseHeaders = {
    [header: string]: string;
};
export declare type EndpointRequestOptions = {
    [option: string]: any;
};
export declare type RequestOptions = {
    method: Method;
    url: Url;
    headers: RequestHeaders;
    body?: any;
    request?: EndpointRequestOptions;
};
export declare type RequestErrorOptions = {
    headers: ResponseHeaders;
    request: RequestOptions;
};
