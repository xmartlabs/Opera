//  Commit.swift
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

struct Commit {

    let sha: String
    let url: URL
    let author: String
    let date: Date
    let message: String
}

extension Commit: Decodable {
 
    init(from decoder: Decoder) throws {
        
        enum CodingKeys: String, CodingKey {
            case sha
            case url
            case commitInfo = "commit"
        }
        
        enum CommitKeys: String, CodingKey {
            case message
            case authorInfo = "author"
        }
        
        enum AuthorKeys: String, CodingKey {
            case name
            case date
        }
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.sha = try container.decode(.sha)
        self.url = try container.decode(.url)
        let commitContainer = try container.nestedContainer(keyedBy: CommitKeys.self, forKey: .commitInfo)
        self.message = try commitContainer.decode(.message)
        let authorContainer = try commitContainer.nestedContainer(keyedBy: AuthorKeys.self, forKey: .authorInfo)
        self.author = try authorContainer.decode(.name)
        self.date = try authorContainer.decode(.date)
    }
}

extension Commit: OperaDecodable {}
