//
//  Playground.playground
//  Opera
//
//  Copyright © 2019 Xmartlabs SRL. All rights reserved.
//

//: Playground - noun: a place where people can play

import UIKit
import OperaSwift
import Alamofire

extension RouteType {

    var baseURL: URL {
        return URL(string: "https://api.github.com")!
    }

    var manager: ManagerType {
        return RxManager(manager: Alamofire.SessionManager.default)
    }

}

extension Request {

    enum Repository: RouteType {

        case getInfo(owner: String, repo: String)
        case search()

        var method: Alamofire.HTTPMethod {
            switch self {
            case .getInfo, .search:
                return .get
            }
        }

        var path: String {
            switch self {
            case let .getInfo(owner, repo):
                return "repos/\(owner)/\(repo)"
            case .search:
                return "search/repositories"
            }
        }

        var retryCount: Int { return 0 }

    }
}

let string = Request.Repository.search().urlRequest?.debugDescription
