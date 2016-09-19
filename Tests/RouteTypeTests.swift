//
//  OperaTests.swift
//  OperaTests
//
//  Copyright © 2016 Xmartlabs SRL. All rights reserved.
//

import XCTest
import Alamofire
@testable import Opera


class RouteTypeTests: BaseXCTextCase {
    
    func testParametersSetup() {
        let parameters = try! Example.getRoute().asURLRequest().url?.parameters() ?? [String: String]()
        XCTAssertTrue(parameters[RouteValues.parameterName] == RouteValues.parameterValue)
    }
    
    func testHeadersSetup(){
        XCTAssertEqual(try! Example.getRoute().asURLRequest().value(forHTTPHeaderField: RouteValues.headerName), RouteValues.headerValue)
    }
    
//    func testDefaultEncodingType() {
//        XCTAssert(Example.getRoute().encoding == RouteValues.URLEncoding)
//        XCTAssert(Example.deleteRoute().encoding == RouteValues.URLEncoding)
//        XCTAssert(Example.putRoute().encoding == RouteValues.JsonEncoding)
//        XCTAssert(Example.postRoute().encoding == RouteValues.JsonEncoding)
//    }
//    
//    func testModifiedEncodingType() {
//        XCTAssert(ModifiedEncodingExample.modifiedEncodingRoute().encoding == RouteValues.URLEncoding)
//    }
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

private enum Example: RouteType, URLRequestParametersSetup, URLRequestSetup {
    
    case getRoute()
    case postRoute()
    case putRoute()
    case deleteRoute()
    
    var method: Alamofire.HTTPMethod {
        switch self {
        case .getRoute:
            return .get
        case .deleteRoute():
            return .delete
        case .postRoute():
            return .post
        case .putRoute():
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
    
    // MARK: urlRequestSetup
    
    func urlRequestSetup( _ urlRequest: inout URLRequest) {
        urlRequest.setValue(RouteValues.headerValue, forHTTPHeaderField: RouteValues.headerName)
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
