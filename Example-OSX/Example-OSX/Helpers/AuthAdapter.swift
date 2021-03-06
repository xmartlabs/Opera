//
//  AuthAdapter.swift
//  Example-iOS
//
//  Created by Mauricio Cousillas on 3/29/17.
//
//

import Alamofire
import Foundation
import OperaSwift

class AuthAdapter: HashableRequestAdapter, RequestAdapter {

    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        guard let token = Manager.githubAuthorizationToken else {
            return urlRequest
        }
        urlRequest.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        return urlRequest
    }

}
