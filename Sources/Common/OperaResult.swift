//
//  OperaResult.swift
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

/**
 *  The result of a network request. Contains the request and the response object or an error
 */
public struct OperaResult {
    
    var result: Result<OperaResponse, NetworkError>
    var request: URLRequestConvertible
    
    public init(request: URLRequestConvertible, result: Result<OperaResponse, NetworkError>) {
        self.result = result
        self.request = request
    }
    
}

extension OperaResult {
    
    /**
     Generic response object serialization that returns a OperaDecodable instance.
     
     - parameter keyPath:           keyPath to look up json object to serialize. Ignore parameter or pass nil when json object is the json root item.
     
     - returns: The serialized object or an error.
     */
    public func serializeObject<T: OperaDecodable>(keyPath: String? = nil) -> Response<T, NetworkError> {
        switch result {
        case let .Success(value):
            let result = OperaResult.serialize(nil, response: value.response, data: value.data, error: nil, onSuccess: { (result, json) -> Result<T, NetworkError> in
                if let object = keyPath.map({ json.valueForKeyPath($0)}) ?? json {
                    do {
                        let decodedData = try T.decode(object)
                        return .Success(decodedData)
                    }
                    catch let error {
                        return .Failure(NetworkError.Parsing(error: error, request: self.request.URLRequest, response: value.response, json: json))
                    }
                } else {
                    let failureReason = "Json response could not be found"
                    let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                    return .Failure(NetworkError.Networking(error: error, request: self.request.URLRequest, response: value.response, json: json))
                }
            })
            return Response(request: request.URLRequest, response: value.response, data: value.data, result: result)
        case let .Failure(error):
            return Response(request: request.URLRequest, response: nil, data: nil, result: .Failure(error))
        }
    }
    
    /**
     Generic response object serialization that returns an Array of OperaDecodable instances.
     
     - parameter collectionKeyPath: keyPath to look up json array to serialize. Ignore parameter or pass nil when json array is the json root item.
     
     - returns: The serialized objects or an error.
     */
    public func serializeCollection<T: OperaDecodable>(collectionKeyPath: String? = nil) -> Response<[T], NetworkError>  {
        switch result {
        case let .Success(value):
            let result = OperaResult.serialize(nil, response: value.response, data: value.data, error: nil, onSuccess: { (result, json) -> Result<[T], NetworkError> in
                if let representation = (collectionKeyPath.map { json.valueForKeyPath($0) } ?? json) as? [[String: AnyObject]] {
                    var result = [T]()
                    for userRepresentation in representation {
                        do {
                            let decodedData = try T.decode(userRepresentation)
                            result.append(decodedData)
                        }
                        catch let error {
                            return .Failure(NetworkError.Parsing(error: error, request: self.request.URLRequest, response: value.response, json: json))
                        }
                    }
                    return .Success(result)
                } else {
                    let failureReason = "Json Response collection could not be found"
                    let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                    return .Failure(NetworkError.Networking(error: error, request: self.request.URLRequest, response: value.response, json: json))
                }
            })
            return Response(request: request.URLRequest, response: value.response, data: value.data, result: result)
        case let .Failure(error):
            return Response(request: request.URLRequest, response: nil, data: nil, result: .Failure(error))
        }
    }
    
    
    /**
     Generic response object serialization. Notice that Response Error type is NetworkError.
     
     - returns: The json object from the response or an error
     */
    public func serializeAnyObject() -> Response<AnyObject, NetworkError> {
        switch result {
        case let .Success(value):
            let result = OperaResult.serialize(nil, response: value.response, data: value.data, error: nil, onSuccess: { (result, json) -> Result<AnyObject, NetworkError> in
                if let _ = value.response { return .Success(json) }
                let failureReason = "JSON could not be serialized into response object"
                let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                return .Failure(NetworkError.Networking(error: error, request: self.request.URLRequest, response: value.response, json: json))
            })
            return Response(request: request.URLRequest, response: value.response, data: value.data, result: result)
        case let .Failure(error):
            return Response(request: request.URLRequest, response: nil, data: nil, result: .Failure(error))
        }
    }
    
    private static func serialize<T>(request: NSURLRequest?,
                                  response: NSHTTPURLResponse?,
                                  data: NSData?,
                                  error: NSError?,
                                  onSuccess: (Result<AnyObject, NSError>, AnyObject) -> Result<T, NetworkError>)
        -> Result<T, NetworkError> {
            guard error == nil else { return .Failure(NetworkError.Networking(error: error!, request: request, response: response, json: data)) }
            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)
            
            switch result {
            case .Success(let value):
                guard let _ = response else {
                    let failureReason = "JSON could not be serialized into response object: \(value)"
                    let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                    return .Failure(NetworkError.Networking(error: error, request: request, response: response, json: data))
                }
                return onSuccess(result, value)
                
            case .Failure(let error):
                var userInfo = error.userInfo
                userInfo["responseData"] = result.value ?? data
                return .Failure(NetworkError.Networking(error: NSError(domain: error.domain, code: error.code, userInfo: userInfo), request: request, response: response, json: result.value ?? data))
            }
    }
}
