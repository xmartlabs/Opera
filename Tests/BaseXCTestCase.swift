//  BaseXCTestCase.swift
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
import XCTest
import Alamofire
@testable import Opera

class BaseXCTextCase: XCTestCase {
    
}

extension URL {
    
    func parameters() -> [String:String] {
        var result = [String: String]()
        let urlStringParametersPart = absoluteString.components(separatedBy: "?")[1]
        let splittedParametersIndividually = urlStringParametersPart.components(separatedBy: "&")
        for parameter in splittedParametersIndividually {
            let parameterAndValue = parameter.components(separatedBy: "=")
            result.updateValue(parameterAndValue[1], forKey: parameterAndValue[0])
        }
        return result
    }
}

extension RouteType {
    
    var baseURL: URL {
        return URL(string: "someURL")!
    }
    
    var manager: ManagerType {
        return RxManager(manager: Alamofire.SessionManager.default)
    }

    var retryCount: Int { return 0 }
}

