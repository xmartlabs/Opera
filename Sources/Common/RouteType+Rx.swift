//
//  RouteType+Rx.swift
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
import Alamofire
import RxSwift
import RxCocoa

extension Reactive where Base: RouteType {

    /**
     Returns an `Observable` of T for the current request. Notice that T conforms to OperaDecodable. If something goes wrong a Opera.Error error is propagated through the result sequence.
     
     - parameter keyPath: keyPath to look up json object to serialize. Ignore parameter or pass nil when json object is the json root item.
     
     - returns: An instance of `Observable<T>`
     */
    public func object<T: OperaDecodable>(_ keyPath: String? = nil) -> Observable<T> {
        if base.manager.useMockedData && base.mockedData != nil {
            return (base.manager as! RxManager).rx.sampleObject(base, keyPath: keyPath)
        }
        return (base.manager as! RxManager).rx.object(base, keyPath: keyPath)
    }

    /**
     Returns an `Observable` of [T] for the current request. Notice that T conforms to OperaDecodable. If something goes wrong a Opera.Error error is propagated through the result sequence.
     
     - parameter collectionKeyPath: keyPath to look up json array to serialize. Ignore parameter or pass nil when json array is the json root item.
     
     - returns: An instance of `Observable<[T]>`
     */
    public func collection<T: OperaDecodable>(_ collectionKeyPath: String? = nil) -> Observable<[T]> {
        if base.manager.useMockedData && base.mockedData != nil {
            return (base.manager as! RxManager).rx.sampleCollection(base, collectionKeyPath: collectionKeyPath)
        }
        return (base.manager as! RxManager).rx.collection(base, collectionKeyPath: collectionKeyPath)
    }

    /**
     Returns an `Observable` of AnyObject for the current request. If something goes wrong a Opera.Error error is propagated through the result sequence.
     
     - returns: An instance of `Observable<AnyObject>`
     */
    public func anyObject() -> Observable<Any> {
        if base.manager.useMockedData && base.mockedData != nil {
            return (base.manager as! RxManager).rx.sampleAny(base)
        }
        return (base.manager as! RxManager).rx.any(base)
    }
}

extension RouteType {

    public var rx: Reactive<Self> {
        return Reactive(self)
    }

}
