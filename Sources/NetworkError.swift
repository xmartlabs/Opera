//  NetworkError.swift
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
 Provides information about networking errors, either networking errors or parsing error when Opera tries to parse the response.
 
 - Networking: Networking errors, most of the time errors thrown by NSURLSession under NSURLErrorDomain domain or by Alamofire library.
 - Parsing:    Represent parsing errors normally thrown by Json parsing library such as Argo or Decodable.
 */
public enum NetworkError: ErrorType {
    
    case Networking(error: NSError, request: NSURLRequest?, response: NSHTTPURLResponse?, json: AnyObject?)
    case Parsing(error: ErrorType, request: NSURLRequest?, response: NSHTTPURLResponse?, json: AnyObject?)
        
}

extension NetworkError : CustomDebugStringConvertible {

    /// A textual representation of NetworkError instance, suitable for debugging.
    public var debugDescription: String {
        
        switch self {
        case .Networking(let error, let request, _, let json):
            var components = ["Networking Error - Code: \(error.code)"]
            components.append(error.debugDescription)
            if let method = request?.HTTPMethod {
                components.append(method)
            }
            if let URLString = request?.URL?.absoluteString {
                components.append(URLString)
            }
            if let jsonStringify = json.map({ JSONStringify($0) }) {
                components.append("Json:")
                components.append(jsonStringify)
            }
            return components.joinWithSeparator(" \\\n\t")
        case .Parsing(let error, let request, _, let json):
            var components = ["Parsing Error:"]
            if let error = error as? CustomDebugStringConvertible{
                components.append(error.debugDescription)
            }
            if let method = request?.HTTPMethod {
                components.append(method)
            }
            if let request = request {
                components.append("Request: \(request)") //request.map { "URL: " + $0.URLString }
            }
            if let jsonStringify = json.map({ JSONStringify($0) }) {
                components.append("Json:")
                components.append(jsonStringify)
            }
            return components.joinWithSeparator(" \\\n\t")
        }
    }

}

extension NetworkError: CustomStringConvertible {
    
    /// A textual representation of NetworkError instance.
    public var description: String {
        switch self {
        case .Networking(let error, let request, _, _):
            var components = [String]()
            components.append("Networking Error: \(error.code)")
            components.append(error.description)
            if let method = request?.HTTPMethod {
                components.append(method)
            }
            if let URLString = request?.URL?.absoluteString {
                components.append(URLString)
            }
            return components.joinWithSeparator(" ")
        case .Parsing(let error, let request, _, let json):
            var components = ["Parsing Error"]
            if let method = request?.HTTPMethod {
                components.append(method)
            }
            if let request = request {
                components.append("Request: \(request)") //request.map { "URL: " + $0.URLString }
            }
            if let error = error as? CustomStringConvertible {
                components.append(error.description)
            }
            components = [components.joinWithSeparator(" ")]
            if let jsonStringify = json.map({ JSONStringify($0) }) {
                components.append("Json:\r\n")
                components.append(jsonStringify)
            }
            return components.joinWithSeparator(" \\\n\t")
        }

    }
}
