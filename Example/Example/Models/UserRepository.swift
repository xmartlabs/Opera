//  UserRepository.swift
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
import OperaSwift
import SwiftDate
import protocol Decodable.Decodable
import Decodable


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

extension UserRepository: OperaDecodable, Decodable {

    static func decode(_ json: Any) throws -> UserRepository {
        return try UserRepository.init(id: json => "id",
                                owner: json => ["owner", "login"],
                                 name: json => "name",
                          description: json =>? "description",
                                forks: json => "forks_count",
                           stargazers: json => "stargazers_count",
                             watchers: json => "watchers_count",
                               issues: json => "open_issues_count",
                            createdAt: json =>? "created_at")
        
        //dateString.date(format: DateFormat.iso8601(options: .withInternetDateTime))?.absoluteDate
    }

}


