//
//  Playground.playground
//  Opera
//
//  Copyright © 2016 Xmartlabs SRL. All rights reserved.
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
        
        case GetInfo(owner: String, repo: String)
        case Search()
        
        var method: Alamofire.HTTPMethod {
            switch self {
            case .GetInfo, .Search:
                return .get
            }
        }
        
        var path: String {
            switch self {
            case let .GetInfo(owner, repo):
                return "repos/\(owner)/\(repo)"
            case .Search:
                return "search/repositories"
            }
        }

        var retryCount: Int { return 0 }
        
    }
}

let string = Request.Repository.Search().urlRequest?.debugDescription
