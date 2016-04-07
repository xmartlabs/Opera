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

public protocol PaginationRequestType: RequestType {
    
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
    
    public var baseURL: NSURL { return route.baseURL }
    public var method: Alamofire.Method { return route.method }
    public var path: String { return route.path }
    public var parameters: [String: AnyObject]? {
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
    public var encoding: Alamofire.ParameterEncoding { return route.encoding }
    
    public func routeWithPage(page: String) -> Self {
        return Self.init(route: route, page: page, query: query, filter: filter, collectionKeyPath: collectionKeyPath)
    }
    
    public func routeWithQuery(query: String) -> Self {
        return Self.init(route: route, page: "1", query: query, filter: filter, collectionKeyPath: collectionKeyPath)
    }
    
    public func routeWithFilter(filter: FilterType) -> Self {
        return Self.init(route: route, page: "1", query: query, filter: filter, collectionKeyPath: collectionKeyPath)
    }
    
    public var manager: Manager {
        return route.manager
    }
}

extension PaginationRequestType where Response.Element: OperaDecodable {
    
    func rx_collection() -> Observable<Response> {
        let myRequest = request
        let myPage = page
        return myRequest.rx_collection(collectionKeyPath).map({ elements -> Response in
            return Response.init(elements: elements, previousPage: myRequest.response?.previousPage, nextPage: myRequest.response?.nextPage, page: myPage)
        })
    }
    
}
