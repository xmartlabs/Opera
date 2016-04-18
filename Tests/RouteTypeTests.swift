//
//  OperaTests.swift
//  OperaTests
//
//  Copyright © 2016 Xmartlabs SRL. All rights reserved.
//

import XCTest
import Alamofire
@testable import Opera

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
        switch self {
        default:
            return "anEndpoint"
        }
    }
    
    var baseURL: NSURL {
        return NSURL(string: "someURL")!
    }
    
    var manager: Alamofire.Manager {
        return Alamofire.Manager()
    }
    
    // MARK: - URLRequestParametersSetup
    
    func urlRequestParametersSetup(urlRequest: NSMutableURLRequest, parameters: [String: AnyObject]?) -> [String: AnyObject]? {
        return [RouteValues.parameterName : RouteValues.parameterValue]
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
    
    var baseURL: NSURL {
        return NSURL(string: "someURL")!
    }
    
    var manager: Alamofire.Manager {
        return Alamofire.Manager()
    }
}

class RouteTypeTests: XCTestCase {
    
    func testParametersSetup() {
        let operation = Example.GetRoute()
        let request = operation.URLRequest
        let url = request.URL
        let parameters = parseParameters(url?.absoluteString)
        let settedParameter = parameters[RouteValues.parameterName]
        XCTAssertTrue(settedParameter == RouteValues.parameterValue)
    }
    
    private func parseParameters(url: String?) -> [String:String] {
        guard let urlWithParameters = url else {
            return [:]
        }
        
        var listOfParameters: [String:String] = [:]
        let splitParametersFromEndpoint = urlWithParameters.characters.split{$0 == "?"}.map(String.init)
        
        let allParameters = splitParametersFromEndpoint[1]
        let splittedParametersIndividually = allParameters.characters.split{$0 == "&"}.map(String.init)
        
        for parameter in splittedParametersIndividually {
            let parameterAndValue = parameter.characters.split{$0 == "="}.map(String.init)
            listOfParameters.updateValue(parameterAndValue[1], forKey: parameterAndValue[0])
        }
        
        return listOfParameters
    }
    
    func testHeadersSetup(){
        XCTAssertEqual(Example.GetRoute().URLRequest.valueForHTTPHeaderField(RouteValues.headerName), RouteValues.headerValue)
    }
    
    func testDefaultEncodingType(){
        let getRoute = Example.GetRoute()
        let postRoute = Example.PostRoute()
        let deleteRoute = Example.DeleteRoute()
        let putRoute = Example.PutRoute()
        
        XCTAssertEqual(getRoute.encoding, RouteValues.URLEncoding)
        XCTAssertEqual(deleteRoute.encoding, RouteValues.URLEncoding )
        XCTAssertEqual(putRoute.encoding, RouteValues.JsonEncoding )
        XCTAssertEqual(postRoute.encoding, RouteValues.JsonEncoding )
    }
    
    func testModifiedEncodingType(){
        let modifiedEncodingRoute = ModifiedEncodingExample.ModifiedEncodingRoute()
        let encoding = modifiedEncodingRoute.encoding
        XCTAssertEqual(encoding, RouteValues.URLEncoding)
    }
    
}

extension Alamofire.ParameterEncoding : Equatable {
    
}

public func == (lhs: Alamofire.ParameterEncoding, rhs: Alamofire.ParameterEncoding) -> Bool {
    switch (lhs, rhs) {
    case (.URL, .URL):
        return true
    case(.JSON, .JSON):
        return true
    case(.URLEncodedInURL, .URLEncodedInURL):
        return true
    default:
        return false
    }
}