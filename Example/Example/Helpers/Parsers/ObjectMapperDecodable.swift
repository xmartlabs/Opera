//  ObjectMapperDecodable.swift
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
import Argo
import ObjectMapper

extension Mappable where Self: OperaDecodable {
    
    static func decode(json: AnyObject) throws -> Self {
        guard let jsonData = json as? [String: AnyObject] else { throw Error.Parsing(error: "Data is not JSON formatted", request: nil, response: nil, json: json) }
        let map = Map(mappingType: MappingType.FromJSON, JSONDictionary: jsonData, toObject: true)
        if var decoded = Self.init(map) {
            decoded.mapping(map)
            return decoded
        } else {
            throw Error.Parsing(error: "Object could not be parsed from JSON data", request: nil, response: nil, json: json)
        }
    }
    
}

extension String: ErrorType {
}