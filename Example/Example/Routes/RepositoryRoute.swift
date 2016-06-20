//  RepositoryRoute.swift
//  Example-iOS ( https://github.com/xmartlabs/Example-iOS )
//
//  Copyright (c) 2016 Xmartlabs SRL ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import Alamofire
import Opera

struct GithubAPI {
    struct Repository {}
}

extension GithubAPI.Repository {
        
    struct Search: RouteType, URLRequestSetup {
        
        var method: Alamofire.Method {
            return .GET
        }
        
        var path: String {
            return "search/repositories"
        }
    }
    
    struct GetInfo: RouteType, URLRequestSetup {
        
        let owner: String
        let repo: String
        
        var method: Alamofire.Method {
            return .GET
        }
        
        var path: String {
            return "repos/\(owner)/\(repo)"
        }
        
        var retryCount: Int {
            return 2
        }
    }
    
    struct GetForks: RouteType, URLRequestSetup {
        
        let owner: String
        let repo: String
        
        var method: Alamofire.Method {
            return .GET
        }
        
        var path: String {
            return "repos/\(owner)/\(repo)/forks"
        }
        
    }
    
    struct GetStargazers: RouteType, URLRequestSetup {
        
        let owner: String
        let repo: String
        
        var method: Alamofire.Method {
            return .GET
        }
        
        var path: String {
            return "repos/\(owner)/\(repo)/stargazers"
        }
        
    }
    
    struct GetIssues: RouteType, URLRequestSetup {
        
        let owner: String
        let repo: String
        
        var method: Alamofire.Method {
            return .GET
        }
        
        var path: String {
            return "repos/\(owner)/\(repo)/issues"
        }
        
    }
    
    struct GetPullRequests: RouteType, URLRequestSetup {
        
        let owner: String
        let repo: String
        
        var method: Alamofire.Method {
            return .GET
        }
        
        var path: String {
            return "repos/\(owner)/\(repo)/pulls"
        }
        
    }
    
    struct GetBranches: RouteType, URLRequestSetup {
        
        let owner: String
        let repo: String
        
        var method: Alamofire.Method {
            return .GET
        }
        
        var path: String {
            return "repos/\(owner)/\(repo)/branches"
        }
        
    }
    
    struct GetReleases: RouteType, URLRequestSetup {
        
        let owner: String
        let repo: String
        
        var method: Alamofire.Method {
            return .GET
        }
        
        var path: String {
            return "repos/\(owner)/\(repo)/releases"
        }
        
    }
    
    struct GetCommits: RouteType, URLRequestSetup {
        
        let owner: String
        let repo: String
        
        var method: Alamofire.Method {
            return .GET
        }
        
        var path: String {
            return "repos/\(owner)/\(repo)/commits"
        }
        
    }
    
    struct GetContributors: RouteType, URLRequestSetup {
        
        let owner: String
        let repo: String
        
        var method: Alamofire.Method {
            return .GET
        }
        
        var path: String {
            return "repos/\(owner)/\(repo)/contributors"
        }
        
    }
    
}
