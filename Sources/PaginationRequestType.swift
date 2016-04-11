//  PaginationRequestType.swift
//  Opera ( https://github.com/xmartlabs/Opera )
//
//  Copyright (c) 2016 Xmartlabs SRL ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import Alamofire
import RxSwift
import WebLinking


private struct Default {
    static let firstPageParameterValue = "1"
    static let queryParameterName = "q"
    static let pageParamName = "page"
    static let prevRelationName = "prev"
    static let nextRelationName = "next"
    static let relationPageParamName = "page"
    
}

/**
 *  A type that adopts PaginationRequestType encapsulates information required to fetch and filter a collection of items from a server endpoint. It can be used to create a pagination request. The request will take into account page, query, route, filter properties.
 */
public protocol PaginationRequestType: URLRequestConvertible {
    
    associatedtype Response: PaginationResponseType
    
    /// Route
    var route: RouteType { get }
    /// Page, represent request page parameter
    var page: String { get }
    /// Query string
    var query: String? { get }
    /// Filters
    var filter: FilterType? { get }
    /// keyPath to get the parseable json array.
    var collectionKeyPath: String? { get }
    
    /**
     Creates a new PaginationRequestType equals to self but updating the page value.
     
     - parameter page: new page value
     
     - returns: PaginationRequestType instance identically to self and having its page value updated to `page`
     */
    func routeWithPage(page: String) -> Self
    
    /**
     Creates a new PaginationRequestType equals to self but updating query strng and setting its page to first page value.
     
     - parameter query: query string
     
     - returns: PaginationRequestType instance identically to self and having its query value updated to `query` and its page to firs page value.
     */
    func routeWithQuery(query: String) -> Self
    
    /**
     Creates a new PaginationRequestType equals to self but updating its filter. Page value is set to first page.
     
     - parameter filter: filters
     
     - returns: PaginationRequestType instance identically to self and having its filter value updated to `filter` and its page to firs page value.
     */
    func routeWithFilter(filter: FilterType) -> Self
    
    /**
     Instantiate a new `PaginationRequestType`
     
     - parameter route:             route info
     - parameter page:              page
     - parameter query:             query string
     - parameter filter:            filters
     - parameter collectionKeyPath: location within json response to get array of items to parse using the JSON parsing library.
     
     - returns: The new PaginationRequestType instance.
     */
    init(route: RouteType, page: String, query: String?, filter: FilterType?, collectionKeyPath: String?)
}

extension PaginationRequestType {
    
//MARK: URLRequestConvertible conformance
    
    public var URLRequest: NSMutableURLRequest {
        let mutableURLRequest = NSMutableURLRequest(URL: route.baseURL.URLByAppendingPathComponent(route.path))
        mutableURLRequest.HTTPMethod = route.method.rawValue
        let params = (self as? URLRequestParametersSetup)?.urlRequestParametersSetup(mutableURLRequest, parameters: parameters) ?? parameters
        let urlRequest = route.encoding.encode(mutableURLRequest, parameters: params).0
        (self as? URLRequestSetup)?.urlRequestSetup(mutableURLRequest)
        return urlRequest
    }
}


extension PaginationRequestType {

    /// Pagination request parameters
    var parameters: [String: AnyObject]? {
        var result = route.parameters ?? [:]
        result[(self as? PaginationRequestTypeSettings)?.pageParameterName ?? Default.pageParamName] = page
        if let q = query where q != "" {
            result[(self as? PaginationRequestTypeSettings)?.queryParameterName ?? Default.queryParameterName] = query
        }
        for (k, v) in filter?.parameters ?? [:]  {
            result.updateValue(v, forKey: k)
        }
        return result
    }

    public func routeWithPage(page: String) -> Self {
        return Self.init(route: route, page: page, query: query, filter: filter, collectionKeyPath: collectionKeyPath)
    }
    
    public func routeWithQuery(query: String) -> Self {
        return Self.init(route: route, page: (self as? PaginationRequestTypeSettings)?.firstPageParameterValue ?? Default.firstPageParameterValue, query: query, filter: filter, collectionKeyPath: collectionKeyPath)
    }
    
    public func routeWithFilter(filter: FilterType) -> Self {
        return Self.init(route: route, page: (self as? PaginationRequestTypeSettings)?.firstPageParameterValue ?? Default.firstPageParameterValue, query: query, filter: filter, collectionKeyPath: collectionKeyPath)
    }

}

extension PaginationRequestType where Response.Element: OperaDecodable {
    
    /**
     Returns an `Observable` of [Response] for the PaginationRequestType instance. If something goes wrong a NetworkError error is propagated through the result sequence.
     
     - returns: An instance of `Observable<Response>`
     */
    func rx_collection() -> Observable<Response> {
        let myRequest = route.manager.request(self).validate()
        let myPage = page
        return myRequest.rx_collection(collectionKeyPath).map({ elements -> Response in
            return Response.init(elements: elements,
                             previousPage: myRequest.response?.linkPagePrameter((self as? WebLinkingSettings)?.prevRelationName ?? Default.prevRelationName, pageParameterName: (self as? WebLinkingSettings)?.relationPageParamName ?? Default.relationPageParamName),
                                 nextPage: myRequest.response?.linkPagePrameter((self as? WebLinkingSettings)?.nextRelationName ?? Default.nextRelationName, pageParameterName: (self as? WebLinkingSettings)?.relationPageParamName ?? Default.relationPageParamName),
                                     page: myPage
            )
        })
    }
    
}
