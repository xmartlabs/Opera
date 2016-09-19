//  Repository.swift
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
import Opera
import Decodable
import SwiftDate

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

extension Repository: OperaDecodable,  Decodable {
    
    static func decode(_ j: AnyObject) throws -> Repository {
        return try Repository.init(  id: j => "id",
                                     name: j => "name",
                                     desc: j =>? "description",
                                     company: j =>? ["owner", "login"],
                                     language: j =>? "language",
                                     openIssues: j => "open_issues_count",
                                     stargazersCount: j => "stargazers_count",
                                     forksCount: j => "forks_count",
                                     url: URL(string: j => "url")!,
                                     createdAt: j => "created_at")
    }
}

extension Date: Decodable  {
    
    public static func decode(_ json: AnyObject) throws -> Date {
        let string = try String.decode(json)
        guard let date = string.toDate(DateFormat.ISO8601Format(.Full)) else {
            throw TypeMismatchError(expectedType: Date.self, receivedType: String.self, object: json)
        }
        return self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }
}

