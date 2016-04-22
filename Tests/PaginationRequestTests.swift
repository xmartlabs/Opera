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

class PaginationRequestTests: BaseXCTextCase {
    
    func testDefaultPageSet() {
        let pageRequest = PaginationRequest<String>(route: RequestExample.ExampleRouteGet())
        let pageRequestParameters = pageRequest.URLRequest.URL?.parameters() ?? [:]
        
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
        let pageRequestParameters = pageRequest.URLRequest.URL?.parameters() ?? [:]
        XCTAssertEqual(pageRequestParameters[RouteValues.filterExampleName], RouteValues.filterExampleValue)
    }
    
    func testQueryIsInitiallySet() {
        let query = RouteValues.QueryExampleValue
        let pageRequest = PaginationRequest<String>(route: RequestExample.ExampleRouteGet(), query: query)
        let pageRequestParameters = pageRequest.URLRequest.URL?.parameters() ?? [:]
        XCTAssertEqual(pageRequestParameters[RouteValues.QueryDefaultName], query)
    }
    
    func testPageNumberAdvanced() {
        let pageRequest = PaginationRequest<String>(route: RequestExample.ExampleRouteGet())
        var pageRequestParameters = pageRequest.URLRequest.URL?.parameters() ?? [:]
        XCTAssertEqual(pageRequestParameters[RouteValues.PageDefaultName], "1")
        
        let pageRequestWithAnotherPage = pageRequest.routeWithPage("2")
        pageRequestParameters = pageRequestWithAnotherPage.URLRequest.URL?.parameters() ?? [:]
        XCTAssertEqual(pageRequestParameters[RouteValues.PageDefaultName], "2")
    }
    
    func testQueryValueUpdated() {
        let pageRequest = PaginationRequest<String>(route: RequestExample.ExampleRouteGet(), page: "2")
        var pageRequestParameters = pageRequest.URLRequest.URL?.parameters() ?? [:]
        XCTAssertEqual(pageRequestParameters[RouteValues.PageDefaultName], "2")
        XCTAssertNil(pageRequestParameters[RouteValues.QueryDefaultName])
        
        let pageRequestWithAnotherQuery = pageRequest.routeWithQuery(RouteValues.QueryExampleValue)
        pageRequestParameters = pageRequestWithAnotherQuery.URLRequest.URL?.parameters() ?? [:]
        XCTAssertEqual(pageRequestParameters[RouteValues.PageDefaultName], "1")
        XCTAssertEqual(pageRequestParameters[RouteValues.QueryDefaultName], RouteValues.QueryExampleValue)
    }
    
    func testFiltersUpdated() {
        let pageRequest = PaginationRequest<String>(route: RequestExample.ExampleRouteGet(), page: "2")
        var pageRequestParameters = pageRequest.URLRequest.URL?.parameters() ?? [:]
        XCTAssertEqual(pageRequestParameters[RouteValues.PageDefaultName], "2")
        XCTAssertNil(pageRequestParameters[RouteValues.filterExampleName])
        
        let filterToApply = FilterExamples()
        let pageRequestWithAnotherQuery = pageRequest.routeWithFilter(filterToApply)
        pageRequestParameters = pageRequestWithAnotherQuery.URLRequest.URL?.parameters() ?? [:]
        XCTAssertEqual(pageRequestParameters[RouteValues.PageDefaultName], "1")
        XCTAssertEqual(pageRequestParameters[RouteValues.filterExampleName], RouteValues.filterExampleValue)
    }
    
    func testSetDefaultValues(){
        let query = RouteValues.QueryExampleValue
        let pageRequest = PaginationRequest<String>(route: ChangedDefaultsRequest.ExampleRoute(), query: query)
        let pageRequestParameters = pageRequest.URLRequest.URL?.parameters() ?? [:]
        
        XCTAssertEqual(pageRequestParameters["pageNumber"], "2")
        XCTAssertEqual(pageRequestParameters["query"], RouteValues.QueryExampleValue)
    }
}

//MARK - Text Case Helpers

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


