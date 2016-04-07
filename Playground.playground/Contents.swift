//
//  Playground.playground
//  Opera
//
//  Copyright © 2016 Xmartlabs SRL. All rights reserved.
//

//: Playground - noun: a place where people can play

import UIKit
import Opera
import Alamofire

class MyManager: Alamofire.Manager {
    
    static let singleton = MyManager()
    
    override init?(session: NSURLSession, delegate: Manager.SessionDelegate, serverTrustPolicyManager: ServerTrustPolicyManager? = nil) {
        super.init(session: session, delegate: delegate, serverTrustPolicyManager: serverTrustPolicyManager)
    }
    
    override init(configuration: NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: Alamofire.Manager.SessionDelegate = SessionDelegate(), serverTrustPolicyManager: Alamofire.ServerTrustPolicyManager? = nil)
    {
        super.init(configuration: configuration, delegate: delegate, serverTrustPolicyManager: serverTrustPolicyManager)
    }
    
    override func request(URLRequest: URLRequestConvertible) -> Alamofire.Request {
        let result = super.request(URLRequest)
        debugPrint(result)
        return result
    }
    
    override func request(
        method: Alamofire.Method,
        _ URLString: URLStringConvertible,
          parameters: [String: AnyObject]? = nil,
          encoding: ParameterEncoding = .URL,
          headers: [String: String]? = nil)
        -> Request {
            
            let result = super.request(method, URLString, parameters: parameters, encoding: encoding, headers: headers)
            debugPrint(result)
            return result
    }
}

extension RequestType {
    
    var baseURL: NSURL {
        return NSURL(string: "https://api.github.com")!
    }
    
    var manager: Alamofire.Manager {
        return MyManager.singleton
    }
    
}


extension Request {
    
    enum Repository: RequestType {
        
        case GetInfo(owner: String, repo: String)
        case Search()
        
        var method: Alamofire.Method {
            switch self {
            case .GetInfo, .Search:
                return .GET
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
        
    }
}

let string = Request.Repository.Search().request.debugDescription
