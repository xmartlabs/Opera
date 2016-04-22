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
        let parameters = Example.GetRoute().request.request?.URL?.parameters() ?? [String: String]()
        XCTAssertTrue(parameters[RouteValues.parameterName] == RouteValues.parameterValue)
    }
    
    func testHeadersSetup(){
        XCTAssertEqual(Example.GetRoute().URLRequest.valueForHTTPHeaderField(RouteValues.headerName), RouteValues.headerValue)
    }
    
    func testDefaultEncodingType(){
        XCTAssertEqual(Example.GetRoute().encoding, RouteValues.URLEncoding)
        XCTAssertEqual(Example.DeleteRoute().encoding, RouteValues.URLEncoding )
        XCTAssertEqual(Example.PutRoute().encoding, RouteValues.JsonEncoding )
        XCTAssertEqual( Example.PostRoute().encoding, RouteValues.JsonEncoding )
    }
    
    func testModifiedEncodingType(){
        XCTAssertEqual(ModifiedEncodingExample.ModifiedEncodingRoute().encoding, RouteValues.URLEncoding)
    }
}

//MARK - Text Case Helpers

private struct RouteValues {
    static let parameterName = "parameterExample"
    static let parameterValue = "parameterExampleValue"
    static let headerName = "headerExample"
    static let headerValue = "headerExampleValue"
    static let JsonEncoding = Alamofire.ParameterEncoding.JSON
    static let URLEncoding = Alamofire.ParameterEncoding.URL
}

private enum Example: RouteType, URLRequestParametersSetup, URLRequestSetup {
    
    case GetRoute()
    case PostRoute()
    case PutRoute()
    case DeleteRoute()
    
    var method: Alamofire.Method {
        switch self {
        case .GetRoute:
            return .GET
        case .DeleteRoute():
            return .DELETE
        case .PostRoute():
            return .POST
        case .PutRoute():
            return .PUT
        }
    }
    
    var path: String {
        return "anEndpoint"
    }
    
    // MARK: - URLRequestParametersSetup
    
    func urlRequestParametersSetup(urlRequest: NSMutableURLRequest, parameters: [String: AnyObject]?) -> [String: AnyObject]? {
        return [RouteValues.parameterName: RouteValues.parameterValue]
    }
    
    // MARK: - urlRequestSetup
    
    func urlRequestSetup(urlRequest: NSMutableURLRequest) {
        urlRequest.setValue(RouteValues.headerValue, forHTTPHeaderField: RouteValues.headerName)
    }
}

private enum ModifiedEncodingExample: RouteType {
    
    case ModifiedEncodingRoute()
    
    var method: Alamofire.Method {
        switch self {
        case .ModifiedEncodingRoute():
            return .POST
        }
    }
    
    var encoding: ParameterEncoding {
        switch self {
        case .ModifiedEncodingRoute():
            return .URL
        }
    }
    
    var path: String {
        switch self {
        case .ModifiedEncodingRoute:
            return "anEndpoint"
        }
    }
}
