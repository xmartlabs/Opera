//
//  NetworkManager.swift
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

public typealias CompletionHandler = (OperaResult) -> Void

public protocol ObserverType {
    /// Called immediately before a request is sent over the network (or stubbed).
    func willSendRequest(alamoRequest: Alamofire.Request, requestConvertible: URLRequestConvertible)
}

public protocol ManagerType: class {
    var manager: Alamofire.Manager { get }
    var observers: [ObserverType] { get set }
    func response(requestConvertible: URLRequestConvertible, completion: CompletionHandler) -> Alamofire.Request
}


public class Manager: ManagerType {
    
    public var observers: [ObserverType]
    public var manager: Alamofire.Manager
    
    
    public init(manager: Alamofire.Manager) {
        self.manager = manager
        self.observers = []
    }
    
    
    /**
     Makes a network request
     
     - parameter request:           the request to be made
     - parameter retryLeft:         how many times a retries are left if the request fails
     - parameter completionHandler: handler called when response comes in
     
     - returns: the request
     */
    public func response(request: URLRequestConvertible, completion: CompletionHandler) -> Alamofire.Request {
        return self.retryCallback(request, retryLeft: (request as? RouteType)?.retryCount ??  (request as? BasePaginationRequestType)?.route.retryCount ?? 0, completion: completion)
    }
    
    /// Callback responsible for handling retries
    public func retryCallback(request: URLRequestConvertible, retryLeft: Int, completion: CompletionHandler) -> Alamofire.Request {
        let result = manager.request(request).validate()
        observers.forEach { $0.willSendRequest(result, requestConvertible: request) }
        result.response(){ [weak self] request2, response, data, error in
            let result: OperaResult =  toOperaResult(request, response: response, data: data, error: error)
            switch result.result {
            case .Success:
                completion(result)
            case .Failure(_):
                guard retryLeft > 0 else {
                    completion(result)
                    return
                }
                self?.retryCallback(request, retryLeft: retryLeft - 1 , completion: completion)
            }
        }
        return result
    }
}

private func toOperaResult(requestConvertible: URLRequestConvertible, response: NSHTTPURLResponse?, data: NSData?, error: NSError?) ->
    OperaResult {
    switch (response, data, error) {
    case let (.Some(response), .Some(data), .None):
        return OperaResult(result: .Success(OperaResponse(statusCode: response.statusCode, data: data, response: response)), requestConvertible: requestConvertible)
    case let (_, _, .Some(error)):
        return OperaResult(result: .Failure(.Networking(error: error, request: requestConvertible.URLRequest, response: response, json: data)), requestConvertible: requestConvertible)
    default:
        return OperaResult(result: .Failure(.Networking(error: Alamofire.Error.errorWithCode(0, failureReason: "Unknown error"),
            request: requestConvertible.URLRequest, response: response, json: data)), requestConvertible: requestConvertible)
    }
}
