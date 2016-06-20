//
//  ManagerType+Rx.swift
//  Opera
//
//  Created by Martin Barreto on 6/17/16.
//
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa



extension RxManager {
    
    /**
     Returns an `Observable` of T for the current request. Notice that T conforms to OperaDecodable. If something goes wrong a Opera.Error error is propagated through the result sequence.
     
     - parameter keyPath: keyPath to look up json object to serialize. Ignore parameter or pass nil when json object is the json root item.
     
     - returns: An instance of `Observable<T>`
     */
    public func rx_object<T: OperaDecodable>(route: RouteType, keyPath: String? = nil) -> Observable<T> {
        return rx_response(route).flatMap { operaResult -> Observable<T> in
            let serialized: Response<T, Error>  = operaResult.serializeObject(keyPath)
            switch serialized.result {
            case .Failure(let error):
                return Observable.error(error)
            case .Success(let anyObject):
                return Observable.just(anyObject)
            }
        }
    }
    
    
    /**
     Returns an `Observable` of [T] for the current request. Notice that T conforms to OperaDecodable. If something goes wrong a Opera.Error error is propagated through the result sequence.
     
     - parameter collectionKeyPath: keyPath to look up json array to serialize. Ignore parameter or pass nil when json array is the json root item.
     
     - returns: An instance of `Observable<[T]>`
     */
    public func rx_collection<T: OperaDecodable>(route: RouteType, collectionKeyPath:String? = nil) -> Observable<[T]> {
        return rx_response(route).flatMap { operaResult -> Observable<[T]> in
            let serialized: Response<[T], Error> = operaResult.serializeCollection(collectionKeyPath)
            switch serialized.result {
            case .Failure(let error):
                return Observable.error(error)
            case .Success(let anyObject):
                return Observable.just(anyObject)
            }
        }
    }
    
    /**
     Returns an `Observable` of AnyObject for the current request. If something goes wrong a Opera.Error error is propagated through the result sequence.
     
     - returns: An instance of `Observable<AnyObject>`
     */
    public func rx_anyObject(route: RouteType) -> Observable<AnyObject> {
        return rx_response(route).flatMap { operaResult -> Observable<AnyObject> in
            let serialized = operaResult.serializeAnyObject()
            switch serialized.result {
            case .Failure(let error):
                return Observable.error(error)
            case .Success(let anyObject):
                return Observable.just(anyObject)
            }
        }
    }
    
}


public class RxManager: Opera.Manager {

    public override init(manager: Alamofire.Manager) {
        super.init(manager: manager)
    }
    
    
    public func rx_response(requestConvertible: URLRequestConvertible) -> Observable<OperaResult> {
        return Observable.create { subscriber in
            let req = self.response(requestConvertible) { result in
                switch result.result {
                case .Failure(let error):
                    subscriber.onError(error)
                case .Success:
                    subscriber.onNext(result)
                    subscriber.onCompleted()
                }
            }
            return AnonymousDisposable {
                req.cancel()
            }
        }
    }

}