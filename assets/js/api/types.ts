/** @module types */
// Auto-generated, edits will be overwritten

export namespace api {
export interface OpenApiSpec {
  host: string
  basePath: string
  schemes: string[]
  contentTypes: string[]
  accepts: string[]
  securityDefinitions?: {[key: string]: SecurityDefinition}
}

export interface SecurityDefinition {
  type: 'basic'|'apiKey'|'oauth2'
  description?: string
  name?: string
  in?: 'query'|'header'
  flow?: 'implicit'|'password'|'application'|'accessCode'
  authorizationUrl?: string
  tokenUrl?: string
  scopes?: {[key: string]: string}
}

export type CollectionFormat = 'csv'|'ssv'|'tsv'|'pipes'|'multi'
export type HttpMethod = 'get'|'put'|'post'|'delete'|'options'|'head'|'patch'

export interface OperationInfo {
  path: string
  method: HttpMethod
  security?: OperationSecurity[]
  contentTypes?: string[]
  accepts?: string[]
}

export interface OperationSecurity {
  id: string
  scopes?: string[]
}

export interface OperationParamGroups {
  header?: {[key: string]: string}
  path?: {[key: string]: string|number|boolean}
  query?: {[key: string]: string|string[]|number|boolean}
  formData?: {[key: string]: string|number|boolean}
  body?: any
}

export interface ServiceRequest {
  method: HttpMethod
  url: string
  headers: { [index: string]: string }
  body: any
}

export interface RequestInfo {
  baseUrl: string
  parameters: OperationParamGroups
}

export interface ResponseOutcome {
  retry?: boolean
  res: Response<any>
}

export interface ServiceOptions {
  /**
   * The service url.
   *
   * If not specified then defaults to the one defined in the Open API
   * spec used to generate the service api.
   */
  url?: string
  fetchOptions?: any
  getAuthorization?: (security: OperationSecurity, securityDefinitions: any, op: OperationInfo) => Promise<OperationRights>
  formatServiceError?: (response: FetchResponse, data: any) => ServiceError
  processRequest?: (op: OperationInfo, reqInfo: RequestInfo) => RequestInfo
  processResponse?: (req: api.ServiceRequest, res: Response<any>, attempt: number) => Promise<api.ResponseOutcome>
  processError?: (req: api.ServiceRequest, res: api.ResponseOutcome) => Promise<api.ResponseOutcome>
  authorizationHeader?: string
}

export type OperationRights = {[key: string]: OperationRightsInfo}

export interface OperationRightsInfo {
  username?: string
  password?: string
  token?: string
  apiKey?: string
}

export interface Response<T> {
  raw: FetchResponse
  /**
   * If 'error' is true then data will be of type ServiceError
   */
  data?: T
  /**
   * True if there was a service error, false if not
   */
  error?: boolean
}

export interface FetchResponse extends FetchBody {
  url: string
  status: number
  statusText: string
  ok: boolean
  headers: Headers
  type: string | FetchResponseType
  size: number
  timeout: number
  redirect(url: string, status: number): FetchResponse
  error(): FetchResponse
  clone(): FetchResponse
}

export interface FetchBody {
  bodyUsed: boolean
  arrayBuffer(): Promise<ArrayBuffer>
  blob(): Promise<Blob>
  formData(): Promise<FormData>
  json(): Promise<any>
  json<T>(): Promise<T>
  text(): Promise<string>
}

export interface FetchHeaders {
  get(name: string): string
  getAll(name: string): Array<string>
  has(name: string): boolean
}

export declare enum FetchResponseType { 'basic', 'cors', 'default', 'error', 'opaque' }

export class ServiceError extends Error {
  status: number
}

/**
 * Flux standard action meta for service action
 */
export interface ServiceMeta {
  res: FetchResponse
  info: any
}

}
