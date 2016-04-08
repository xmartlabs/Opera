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

/**
 *  A type that adopts RequestType can be used to create a request. Is ideal to represent an API route/request since it clearly defines all the parts of a request such as its http path, method, parameters, encoding, etc. Often we group a set of related routes/request by conforming this protocol from an enum type that each value represent a specific route/request which may have specific configuration hold by its associated values.
 */

/**
 * A type that adopts PaginationRequestType encapsulates information required to fetch and filter a collection of items from a server endpoint. It can be used to created the Request needed to fetch the items based on page, query route, filter properties.
 */
public protocol PaginationRequestType: URLRequestConvertible {
    
    associatedtype Response: PaginationResponseType
    
    var page: String { get }
    var query: String? { get }
    var route: RequestType { get }
    var filter: FilterType? { get }
    var collectionKeyPath: String? { get }
    
    func routeWithPage(page: String) -> Self
    func routeWithQuery(query: String) -> Self
    func routeWithFilter(filter: FilterType) -> Self
    
    init(route: RequestType, page: String, query: String?, filter: FilterType?, collectionKeyPath: String?)
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
    
    var parameters: [String: AnyObject]? {
        var result = route.parameters ?? [:]
        result["page"] = page
        if let q = query where q != "" {
            result["q"] = query
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
        return Self.init(route: route, page: "1", query: query, filter: filter, collectionKeyPath: collectionKeyPath)
    }
    
    public func routeWithFilter(filter: FilterType) -> Self {
        return Self.init(route: route, page: "1", query: query, filter: filter, collectionKeyPath: collectionKeyPath)
    }

}

extension PaginationRequestType where Response.Element: OperaDecodable {
    
    func rx_collection() -> Observable<Response> {
        let myRequest = route.manager.request(self).validate()
        let myPage = page
        return myRequest.rx_collection(collectionKeyPath).map({ elements -> Response in
            return Response.init(elements: elements, previousPage: myRequest.response?.previousPage, nextPage: myRequest.response?.nextPage, page: myPage)
        })
    }
    
}
