//  Repository.swift
//  Example-iOS 
//
//  Copyright (c) 2019 Xmartlabs SRL ( http://xmartlabs.com )
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
import OperaSwift

struct Repository {

    let id: Int
    let name: String
    let desc: String?
    let company: String?
    let language: String?
    let openIssues: Int
    let stargazersCount: Int
    let forksCount: Int
    let url: URL
    let createdAt: Date
}

extension Repository: Decodable {
    
    public init(from decoder: Decoder) throws {
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case desc = "description"
            case language
            case openIssues = "open_issues_count"
            case stargazersCount = "stargazers_count"
            case forksCount = "forks_count"
            case url
            case createdAt = "created_at"
            case owner
        }
        
        enum OwnerInfoKeys: String, CodingKey {
            case company = "login"
        }
        
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(.id)
        name = try container.decode(.name)
        desc = try container.decodeIfPresent(.desc)
        language = try container.decodeIfPresent(.language)
        openIssues = try container.decode(.openIssues)
        stargazersCount = try container.decode(.stargazersCount)
        forksCount = try container.decode(.forksCount)
        url = try container.decode(.url)
        createdAt = try container.decode(.createdAt)
        let nestedContainer = try container.nestedContainer(keyedBy: OwnerInfoKeys.self, forKey: .owner)
        company = try nestedContainer.decodeIfPresent(.company)
    }
}

extension Repository: OperaDecodable {}


