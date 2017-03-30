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
@testable import OperaSwift

class PaginationRequestTests: BaseXCTextCase {

    func testDefaultPageSet() {
        let pageRequest = PaginationRequest<String>(route: RequestExample.exampleRouteGet())
        let pageRequestParameters = pageRequest.urlRequest?.url?.parameters() ?? [:]

        XCTAssertEqual(pageRequestParameters[RouteValues.PageDefaultName], "1")
    }

    fileprivate struct FilterExamples: FilterType {
        var parameters: [String: AnyObject]? {
            return [RouteValues.filterExampleName: RouteValues.filterExampleValue as AnyObject]
        }
    }

    func testFiltersAreInitiallySet() {
        let requestFilters = FilterExamples()
        let pageRequest = PaginationRequest<String>(route: RequestExample.exampleRouteGet(), filter: requestFilters)
        let pageRequestParameters = pageRequest.urlRequest?.url?.parameters() ?? [:]
        XCTAssertEqual(pageRequestParameters[RouteValues.filterExampleName], RouteValues.filterExampleValue)
    }

    func testQueryIsInitiallySet() {
        let query = RouteValues.QueryExampleValue
        let pageRequest = PaginationRequest<String>(route: RequestExample.exampleRouteGet(), query: query)
        let pageRequestParameters = pageRequest.urlRequest?.url?.parameters() ?? [:]
        XCTAssertEqual(pageRequestParameters[RouteValues.QueryDefaultName], query)
    }

    func testPageNumberAdvanced() {
        let pageRequest = PaginationRequest<String>(route: RequestExample.exampleRouteGet())
        var pageRequestParameters = pageRequest.urlRequest?.url?.parameters() ?? [:]
        XCTAssertEqual(pageRequestParameters[RouteValues.PageDefaultName], "1")

        let pageRequestWithAnotherPage = pageRequest.routeWithPage("2")
        pageRequestParameters = pageRequestWithAnotherPage.urlRequest?.url?.parameters() ?? [:]
        XCTAssertEqual(pageRequestParameters[RouteValues.PageDefaultName], "2")
    }

    func testQueryValueUpdated() {
        let pageRequest = PaginationRequest<String>(route: RequestExample.exampleRouteGet(), page: "2")
        var pageRequestParameters = pageRequest.urlRequest?.url?.parameters() ?? [:]
        XCTAssertEqual(pageRequestParameters[RouteValues.PageDefaultName], "2")
        XCTAssertNil(pageRequestParameters[RouteValues.QueryDefaultName])

        let pageRequestWithAnotherQuery = pageRequest.routeWithQuery(RouteValues.QueryExampleValue)
        pageRequestParameters = pageRequestWithAnotherQuery.urlRequest?.url?.parameters() ?? [:]
        XCTAssertEqual(pageRequestParameters[RouteValues.PageDefaultName], "1")
        XCTAssertEqual(pageRequestParameters[RouteValues.QueryDefaultName], RouteValues.QueryExampleValue)
    }

    func testFiltersUpdated() {
        let pageRequest = PaginationRequest<String>(route: RequestExample.exampleRouteGet(), page: "2")
        var pageRequestParameters = pageRequest.urlRequest?.url?.parameters() ?? [:]
        XCTAssertEqual(pageRequestParameters[RouteValues.PageDefaultName], "2")
        XCTAssertNil(pageRequestParameters[RouteValues.filterExampleName])

        let filterToApply = FilterExamples()
        let pageRequestWithAnotherQuery = pageRequest.routeWithFilter(filterToApply)
        pageRequestParameters = pageRequestWithAnotherQuery.urlRequest?.url?.parameters() ?? [:]
        XCTAssertEqual(pageRequestParameters[RouteValues.PageDefaultName], "1")
        XCTAssertEqual(pageRequestParameters[RouteValues.filterExampleName], RouteValues.filterExampleValue)
    }

    func testSetDefaultValues() {
        let query = RouteValues.QueryExampleValue
        let pageRequest = PaginationRequest<String>(route: ChangedDefaultsRequest.exampleRoute(), query: query)
        let pageRequestParameters = pageRequest.urlRequest?.url?.parameters() ?? [:]

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

    public static func decode(_ json: Any) throws -> String {
        return ""
    }
}

private enum RequestExample: RouteType {

    case exampleRouteGet()
    case exampleRoutePost()

    var method: Alamofire.HTTPMethod {
        switch self {
        case .exampleRouteGet():
            return .get
        case .exampleRoutePost():
            return .post
        }
    }

    var path: String {
        switch self {
        case .exampleRouteGet, .exampleRoutePost():
            return "anEndpoint"
        }
    }

}

private enum ChangedDefaultsRequest: RouteType {

    case exampleRoute()

    var method: Alamofire.HTTPMethod {
        switch self {
        case .exampleRoute():
            return .get
        }
    }

    var path: String {
        switch self {
        case .exampleRoute:
            return "anEndpoint"
        }
    }

    var baseURL: URL {
        return URL(string: "someURL")!
    }

    var manager: Alamofire.SessionManager {
        return Alamofire.SessionManager.default
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
