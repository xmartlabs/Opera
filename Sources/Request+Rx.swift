//  Request+Rx.swift
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

import UIKit

import Alamofire
import RxSwift

extension Alamofire.Request {
    
    public func rx_object<T: OperaDecodable>(keyPath: String? = nil) -> Observable<T> {
        return Observable.create { [weak self] subscriber in
             self?.responseObject(keyPath) { (response: Response<T, NetworkError>) in
                switch response.result {
                case .Failure(let error):
                    subscriber.onError(error)
                case .Success(let entity):
                    subscriber.onNext(entity)
                    subscriber.onCompleted()
                }
            }
            return AnonymousDisposable {
                self?.cancel()
            }
        }
    }
    
    public func rx_collection<T: OperaDecodable>(collectionKeyPath:String? = nil) -> Observable<[T]> {
        return Observable.create { [weak self] subscriber in
            self?.responseCollection(collectionKeyPath) { (response: Response<[T], NetworkError>) in
                switch response.result {
                case .Failure(let error):
                    subscriber.onError(error)
                case .Success(let entity):
                    subscriber.onNext(entity)
                    subscriber.onCompleted()
                }
            }
            return AnonymousDisposable {
                self?.cancel()
            }
        }
    }
    
    public func rx_anyObject() -> Observable<AnyObject> {
        return Observable.create { [weak self] subscriber in
            self?.responseAnyObject { (response: Response<AnyObject, NetworkError>) in
                switch response.result {
                case .Failure(let error):
                    subscriber.onError(error)
                case .Success(let anyObject):
                    subscriber.onNext(anyObject)
                    subscriber.onCompleted()
                }
            }
            return AnonymousDisposable {
                self?.cancel()
            }
        }
    }
    
}
