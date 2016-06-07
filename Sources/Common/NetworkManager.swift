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

/// Network manager that mainly manages retrying failed requests
public final class NetworkManager {
    
    public typealias CompletionHandler = (OperaResult) -> Void
    public typealias RetryHandler = (URLRequestConvertible, NSHTTPURLResponse?, NSError?, NSData?, Int, CompletionHandler) -> Void
    
    public static let singleton = NetworkManager()
    
    /**
     Makes a network request
     
     - parameter request:           the request to be made
     - parameter retryLeft:         how many times a retries are left if the request fails
     - parameter completionHandler: handler called when response comes in
     
     - returns: the request
     */
    func sendRequest(request: URLRequestConvertible, retryLeft: Int? = nil, completionHandler: CompletionHandler) -> Alamofire.Request {
        let retryCount = retryLeft ?? (request as? RouteType)?.retryCount ?? 0
        let result = Alamofire.request(request).validate()
        
        result.response(){ _, response, data, error in
            if let response = response, let data = data where error == nil {
                completionHandler(OperaResult(request: request, result: .Success(OperaResponse(statusCode: response.statusCode, data: data, response: response))))
            } else {
                NetworkManager.retryCallback(request, response, error, data, retryCount, completionHandler)
            }
        }
        
        return result
    }
    
    /// Callback responsible for handling retries
    public static var retryCallback: RetryHandler = { request, response, error, data, retryLeft, completion in
        if retryLeft > 0 && response == nil {
            singleton.sendRequest(request, retryLeft: retryLeft - 1, completionHandler: completion)
        } else {
            completion(OperaResult(request: request, result: .Failure(NetworkError.Networking(error: error ?? Error.errorWithCode(0, failureReason: "Unknown error"),
                request: request.URLRequest, response: response, json: data))))
        }
    }
}
