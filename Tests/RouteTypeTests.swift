//
//  OperaTests.swift
//  OperaTests
//
//  Copyright (c) 2019 Xmartlabs SRL ( http://xmartlabs.com )
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

import XCTest
import Alamofire
@testable import OperaSwift

class RouteTypeTests: BaseXCTextCase {

    func testParametersSetup() {
        let parameters = try! Example.getRoute.asURLRequest().url?.parameters() ?? [String: String]()
        XCTAssertTrue(parameters[RouteValues.parameterName] == RouteValues.parameterValue)
    }
}

//MARK - Text Case Helpers

private struct RouteValues {
    static let parameterName = "parameterExample"
    static let parameterValue = "parameterExampleValue"
    static let headerName = "headerExample"
    static let headerValue = "headerExampleValue"
    static let JsonEncoding = Alamofire.JSONEncoding.default
    static let URLEncoding = Alamofire.URLEncoding.default
}

private enum Example: RouteType, URLRequestParametersSetup {

    case getRoute
    case postRoute
    case putRoute
    case deleteRoute

    var method: Alamofire.HTTPMethod {
        switch self {
        case .getRoute:
            return .get
        case .deleteRoute:
            return .delete
        case .postRoute:
            return .post
        case .putRoute:
            return .put
        }
    }

    var path: String {
        return "anEndpoint"
    }

    // MARK: - URLRequestParametersSetup

    func urlRequestParametersSetup(_ urlRequest: URLRequest, parameters: [String: Any]?) -> [String: Any]? {
        return [RouteValues.parameterName: RouteValues.parameterValue as Any]
    }

}

private enum ModifiedEncodingExample: RouteType {

    case modifiedEncodingRoute()

    var method: Alamofire.HTTPMethod {
        switch self {
        case .modifiedEncodingRoute():
            return .post
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .modifiedEncodingRoute():
            return URLEncoding.default
        }
    }

    var path: String {
        switch self {
        case .modifiedEncodingRoute:
            return "anEndpoint"
        }
    }
}
