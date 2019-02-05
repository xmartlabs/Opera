//  Release.swift
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

struct Release {

    let id: Int
    let name: String
    let tagName: String
    let body: String
    let user: String
}

extension Release: Decodable {
    
    init(from decoder: Decoder) throws {
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case tagName = "tag_name"
            case body
            case author
        }
        
        enum NestedInfoKeys: String, CodingKey {
            case user = "login"
        }
        
        let container =  try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(.id)
        name = try container.decode(.name)
        tagName = try container.decode(.tagName)
        body = try container.decode(.body)
        let additionalInfoContainer = try container.nestedContainer(keyedBy: NestedInfoKeys.self, forKey: .author)
        user = try additionalInfoContainer.decode(.user)
    }
}

extension Release: OperaDecodable {}
