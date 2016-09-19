//  NSHTTPURLResponse.swift
//  Opera ( https://github.com/xmartlabs/Opera )
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
import RxSwift

extension ObservableType {

    /**
     Helper to handle any Error in the observable sequence, and propagates all observer messages through the result sequence. Note that callback is not invoked for errors different to Opera.Error. In this cases you should use onError directly.

     - parameter onError: Action to invoke upon Opera.Error errored termination of the observable sequence.

     - returns: The source sequence with the side-effecting behavior applied.
     */
    
    public func doOnOperaError(_ onError: @escaping ((Error) throws -> Void)) -> Observable<E> {
        return self.do(onError: { error in
            guard let error = error as? OperaError else { return }
            try onError(error)
        })
    }
}

extension HTTPURLResponse {

    /**
     Get page parameter value from a particular link relation
     
     - parameter relation:          relation name.
     - parameter pageParameterName: url page parameter name.
     
     - returns: The page parameter value.
     */
    func linkPagePrameter(_ relation: String, pageParameterName: String) -> String? {
        guard let uri = self.findLink(relation: relation)?.uri else { return nil }
        let components = URLComponents(string: uri)
        return components?.queryItems?.filter { $0.name == pageParameterName }.first?.value
    }
}

func JSONStringify(_ value: Any, prettyPrinted: Bool = true) -> String {
    let options: JSONSerialization.WritingOptions = prettyPrinted ? .prettyPrinted : []
    if JSONSerialization.isValidJSONObject(value) {
        if let data = try? JSONSerialization.data(withJSONObject: value, options: options), let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
            return string as String
        }
    }
    return ""
}
