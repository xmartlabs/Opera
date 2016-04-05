//  RequestType.swift
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

public protocol RequestType: URLRequestConvertible {
    var method: Alamofire.Method { get }
    var path: String { get }
    var parameters: [String: AnyObject]? { get }
    var encoding: Alamofire.ParameterEncoding { get }
    var URLRequest: NSMutableURLRequest { get }
    var baseURL: NSURL { get }
    var manager: Alamofire.Manager { get }
}

public protocol URLRequestSetup {
    func urlRequestSetup(urlRequest: NSMutableURLRequest)
}

public protocol URLRequestParametersSetup {
    func urlRequestParametersSetup(urlRequest: NSMutableURLRequest, parameters: [String: AnyObject]?) -> [String: AnyObject]?
}

extension RequestType {
    
    public var URLRequest: NSMutableURLRequest {
        let mutableURLRequest = NSMutableURLRequest(URL: baseURL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        let params = (self as? URLRequestParametersSetup)?.urlRequestParametersSetup(mutableURLRequest, parameters: parameters) ?? parameters
        let urlRequest = encoding.encode(mutableURLRequest, parameters: params).0
        (self as? URLRequestSetup)?.urlRequestSetup(mutableURLRequest)
        return urlRequest
    }
    
    public var encoding: Alamofire.ParameterEncoding {
        switch method {
        case .POST, .PUT, .PATCH:
            return .JSON
        default:
            return .URL
        }
    }
    
    public var parameters: [String: AnyObject]? {
        return nil
    }
        
    public var request: Alamofire.Request {
        return manager.request(URLRequest).validate()
    }
}
