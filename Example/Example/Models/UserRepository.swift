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
import Argo
import Curry
import SwiftDate
import Runes

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

extension UserRepository: OperaDecodable, Argo.Decodable {

    static func decode(_ json: Argo.JSON) -> Argo.Decoded<UserRepository> {
        return curry(UserRepository.init)
            <^> json <| "id"
            <*> json <| ["owner", "login"]
            <*> json <| "name"
            <*> json <|? "description"
            <*> json <| "forks_count"
            <*> json <| "stargazers_count"
            <*> json <| "watchers_count"
            <*> json <| "open_issues_count"
            <*> json <|? "created_at"
    }

}

extension Date: Argo.Decodable {
    public typealias DecodedType = Date

    public static func decode(_ json: Argo.JSON) -> Argo.Decoded<Date> {
        switch json {
        case .string(let dateString):
            if let date = dateString.date(format: DateFormat.iso8601(options: .withInternetDateTime))?.absoluteDate {
                return pure(date)
            } else {
                return .typeMismatch(expected: "Date", actual: json)
            }
        default: return .typeMismatch(expected: "Date", actual: json)
        }
    }
}
