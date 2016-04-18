//
//  PaginationRequestTests.swift
//  Opera
//
//  Created by Federico Ojeda on 4/13/16.
//
//

import Foundation
import XCTest
import Alamofire
@testable import Opera

private struct RouteValues {
    static let filterExampleName = "filterName"
    static let filterExampleValue = "filterValue"
    static let QueryExampleValue = "queryValue"
    static let QueryDefaultName = "q"
    static let PageDefaultName = "page"
}

extension String : OperaDecodable {
    
    public static func decode(json: AnyObject) throws -> String {
        return ""
    }
}

private enum RequestExample: RouteType {
    
    case ExampleRouteGet()
    case ExampleRoutePost()
    
    var method: Alamofire.Method {
        switch self {
        case .ExampleRouteGet():
            return .GET
        case .ExampleRoutePost():
            return .POST
        }
    }
    
    var path: String {
        switch self {
        case .ExampleRouteGet, .ExampleRoutePost():
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

private enum ChangedDefaultsRequest: RouteType {
    
    case ExampleRoute()
    
    var method: Alamofire.Method {
        switch self {
        case .ExampleRoute():
            return .GET
        }
    }
    
    var path: String {
        switch self {
        case .ExampleRoute:
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

extension PaginationRequest: PaginationRequestTypeSettings {
    
    public var queryParameterName: String {
        switch route {
        case is ChangedDefaultsRequest:
            return "query"
        default:
            return "q"
        }
    }
    
    public var pageParameterName: String {
        switch route {
        case is ChangedDefaultsRequest:
            return "pageNumber"
        default:
            return "page"
        }
    }
    
    public var firstPageParameterValue: String {
        switch route {
        case is ChangedDefaultsRequest:
            return "2"
        default:
            return "1"
        }
    }
    
}

class PaginationRequestTests: XCTestCase {
    
    func testDefaultPageSet() {
        let pageRequest = PaginationRequest<String>(route: RequestExample.ExampleRouteGet())
        let pageRequestParameters = getParameterListFromURL(pageRequest)
        
        XCTAssertEqual(pageRequestParameters[RouteValues.PageDefaultName], "1")
    }
    
    private struct FilterExamples: FilterType {
        var parameters: [String: AnyObject]? {
            return [RouteValues.filterExampleName: RouteValues.filterExampleValue]
        }
    }
    
    func testFiltersAreInitiallySet() {
        let requestFilters = FilterExamples()
        let pageRequest = PaginationRequest<String>(route: RequestExample.ExampleRouteGet(), filter: requestFilters)
        let pageRequestParameters = getParameterListFromURL(pageRequest)
        XCTAssertEqual(pageRequestParameters[RouteValues.filterExampleName], RouteValues.filterExampleValue)
    }
    
    func testQueryIsInitiallySet() {
        let query = RouteValues.QueryExampleValue
        let pageRequest = PaginationRequest<String>(route: RequestExample.ExampleRouteGet(), query: query)
        let pageRequestParameters = getParameterListFromURL(pageRequest)
        XCTAssertEqual(pageRequestParameters[RouteValues.QueryDefaultName], query)
    }
    
    func testPageNumberAdvanced() {
        let pageRequest = PaginationRequest<String>(route: RequestExample.ExampleRouteGet())
        var pageRequestParameters = getParameterListFromURL(pageRequest)
        XCTAssertEqual(pageRequestParameters[RouteValues.PageDefaultName], "1")
        
        let pageRequestWithAnotherPage = pageRequest.routeWithPage("2")
        pageRequestParameters = getParameterListFromURL(pageRequestWithAnotherPage)
        XCTAssertEqual(pageRequestParameters[RouteValues.PageDefaultName], "2")
    }
    
    func testQueryValueUpdated() {
        let pageRequest = PaginationRequest<String>(route: RequestExample.ExampleRouteGet(), page: "2")
        var pageRequestParameters = getParameterListFromURL(pageRequest)
        XCTAssertEqual(pageRequestParameters[RouteValues.PageDefaultName], "2")
        XCTAssertNil(pageRequestParameters[RouteValues.QueryDefaultName])
        
        let pageRequestWithAnotherQuery = pageRequest.routeWithQuery(RouteValues.QueryExampleValue)
        pageRequestParameters = getParameterListFromURL(pageRequestWithAnotherQuery)
        XCTAssertEqual(pageRequestParameters[RouteValues.PageDefaultName], "1")
        XCTAssertEqual(pageRequestParameters[RouteValues.QueryDefaultName], RouteValues.QueryExampleValue)
    }
    
    func testFiltersUpdated() {
        let pageRequest = PaginationRequest<String>(route: RequestExample.ExampleRouteGet(), page: "2")
        var pageRequestParameters = getParameterListFromURL(pageRequest)
        XCTAssertEqual(pageRequestParameters[RouteValues.PageDefaultName], "2")
        XCTAssertNil(pageRequestParameters[RouteValues.filterExampleName])
        
        let filterToApply = FilterExamples()
        let pageRequestWithAnotherQuery = pageRequest.routeWithFilter(filterToApply)
        pageRequestParameters = getParameterListFromURL(pageRequestWithAnotherQuery)
        XCTAssertEqual(pageRequestParameters[RouteValues.PageDefaultName], "1")
        XCTAssertEqual(pageRequestParameters[RouteValues.filterExampleName], RouteValues.filterExampleValue)
    }
    
    func testSetDefaultValues(){
        let query = RouteValues.QueryExampleValue
        let pageRequest = PaginationRequest<String>(route: ChangedDefaultsRequest.ExampleRoute(), query: query)
        let pageRequestParameters = getParameterListFromURL(pageRequest)
        
        XCTAssertEqual(pageRequestParameters["pageNumber"], "2")
        XCTAssertEqual(pageRequestParameters["query"], RouteValues.QueryExampleValue)
    }
    
    private func getParameterListFromURL(pageRequest: PaginationRequest<String>) -> [String : String] {
        let urlRequest = pageRequest.URLRequest
        return parseParameters(urlRequest.URL?.absoluteString)
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
    
}