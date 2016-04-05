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

public enum NetworkError: ErrorType {
    
    case Networking(error: NSError, code: Int, request: NSURLRequest?, response: NSHTTPURLResponse?, json: AnyObject?)
    case Parsing(error: ErrorType, request: NSURLRequest?, response: NSHTTPURLResponse?, json: AnyObject?)
    
    static func networkingError(alamofireError: NSError, request: NSURLRequest?, response: NSHTTPURLResponse? = nil, json: AnyObject? = nil) -> NetworkError {
        return NetworkError.Networking(error: alamofireError, code: alamofireError.code, request: request, response: response, json: json)
    }
    
}

extension NetworkError : CustomDebugStringConvertible {

    public var debugDescription: String {
        switch self {
        case .Networking(let error, let code, _, _, let json):
            return "\(error.debugDescription) Code: \(code) \(json.map { JSONStringify($0)} ?? "")"
        case .Parsing(let error, _, _, let json):
            return "\((error as? CustomStringConvertible)?.description ?? "")) \(json.map { JSONStringify($0)} ?? "")"
        }
    }

}
