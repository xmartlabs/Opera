//  UserRepository.swift
//  Example-iOS 
//
//  Copyright (c) 2019 Xmartlabs SRL
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
import SwiftDate


struct UserRepository {

    let id: Int
    let owner: String
    let name: String
    let description: String?
    let forks: Int
    let stargazers: Int
    let watchers: Int
    let issues: Int
    let createdAt: Date?
}
    
extension UserRepository: Decodable {
    
    
    init(from decoder: Decoder) throws {
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case description
            case forks = "forks_count"
            case stargazers = "stargazers_count"
            case watchers = "watchers_count"
            case issues = "open_issues_count"
            case createdAt = "created_at"
            case owner
        }
        
        enum OwnerInfoKeys: String, CodingKey {
            case owner = "login"
        }
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(.id)
        self.name = try container.decode(.name)
        self.description = try container.decode(.description)
        self.forks = try container.decode(.forks)
        self.stargazers = try container.decode(.stargazers)
        self.watchers = try container.decode(.watchers)
        self.issues = try container.decode(.issues)
        self.createdAt = try container.decode(.createdAt)
        let ownerContainer = try container.nestedContainer(keyedBy: OwnerInfoKeys.self, forKey: .owner)
        self.owner = try ownerContainer.decode(.owner)
        
        
    }
}

extension UserRepository: OperaDecodable {}


