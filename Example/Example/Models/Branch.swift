//  Branch.swift
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

struct Branch {

    var name: String?
    var commit: String?
}

extension Branch: Decodable {
    
    init(from decoder: Decoder) throws {
        
        enum CodingKeys: String, CodingKey {
            case name
            case commit
        }
        
        enum CommitKeys: String, CodingKey {
            case commit = "sha"
        }
    
        let container =  try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(.name)
        let additionalInfoContainer = try container.nestedContainer(keyedBy: CommitKeys.self, forKey: .commit)
        self.commit = try additionalInfoContainer.decode(.commit)
    }
}

extension Branch: OperaDecodable {}
