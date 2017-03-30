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

extension Reactive where Base: RxManager {

    /**
     Returns an `Observable` of T for the current request. Notice that T conforms to OperaDecodable. If something goes wrong a Opera.Error error is propagated through the result sequence.
     
     - parameter keyPath: keyPath to look up json object to serialize. Ignore parameter or pass nil when json object is the json root item.
     
     - returns: An instance of `Observable<T>`
     */
    func object<T: OperaDecodable>(_ route: RouteType, keyPath: String? = nil) -> Observable<T> {
        return base.rx.response(route).flatMap { operaResult -> Observable<T> in
            let serialized: DataResponse<T>  = operaResult.serializeObject(keyPath)
            switch serialized.result {
            case .failure(let error):
                return Observable.error(error)
            case .success(let anyObject):
                return Observable.just(anyObject)
            }
        }
    }

    /**
     Returns an `Observable` of T for the current RouteType. Notice that T conforms to OperaDecodable. If something goes wrong a Opera.Error error is propagated through the result sequence.

     - parameter keyPath: keyPath to look up json object to serialize. Ignore parameter or pass nil when json object is the json root item.

     - returns: An instance of `Observable<T>` filled with sample data specified on the RouteType.
     */
    func sampleObject<T: OperaDecodable>(_ route: RouteType, keyPath: String? = nil) -> Observable<T> {
       guard let json = JSONFrom(data: route.mockedData) else {
            return Observable.empty()
        }
        let object = keyPath.map({ (json as AnyObject).value(forKeyPath: $0) as Any}) ?? json
        guard let decodedData = try? T.decode(object as Any) else {
            return Observable.empty()
        }
        return Observable.just(decodedData)
    }

    /**
     Returns an `Observable` of [T] for the current request. Notice that T conforms to OperaDecodable. If something goes wrong a Opera.Error error is propagated through the result sequence.
     
     - parameter collectionKeyPath: keyPath to look up json array to serialize. Ignore parameter or pass nil when json array is the json root item.
     
     - returns: An instance of `Observable<[T]>`
     */
    func collection<T: OperaDecodable>(_ route: RouteType, collectionKeyPath: String? = nil) -> Observable<[T]> {
        return base.rx.response(route).flatMap { operaResult -> Observable<[T]> in
            let serialized: DataResponse<[T]> = operaResult.serializeCollection(collectionKeyPath)
            switch serialized.result {
            case .failure(let error):
                return Observable.error(error)
            case .success(let anyObject):
                return Observable.just(anyObject)
            }
        }
    }

    /**
     Returns an `Observable` of [T] for for the current RouteType. Notice that T conforms to OperaDecodable. If something goes wrong a Opera.Error error is propagated through the result sequence.

     - parameter collectionKeyPath: keyPath to look up json array to serialize. Ignore parameter or pass nil when json array is the json root item.

     - returns: An instance of `Observable<[T]>`  filled with sample data specified on the RouteType.
     */
    func sampleCollection<T: OperaDecodable>(_ route: RouteType, collectionKeyPath: String? = nil) -> Observable<[T]> {
        guard
            let json = JSONFrom(data: route.mockedData),
            let representation = (
                collectionKeyPath.map {
                    (json as AnyObject).value(forKeyPath: $0) as Any
                } ?? json
            ) as? [[String: AnyObject]]
        else {
            return Observable.empty()
        }

        var result = [T]()
        representation.forEach {
            if let decodedData = try? T.decode($0 as AnyObject) {
                result.append(decodedData)
            }
        }
        return Observable.just(result)
    }

    /**
     Returns an `Observable` of AnyObject for the current request. If something goes wrong a Opera.Error error is propagated through the result sequence.
     
     - returns: An instance of `Observable<AnyObject>`
     */
    func any(_ route: RouteType) -> Observable<Any> {
        return base.rx.response(route).flatMap { operaResult -> Observable<Any> in
            let serialized = operaResult.serializeAny()
            switch serialized.result {
            case .failure(let error):
                return Observable.error(error)
            case .success(let anyObject):
                return Observable.just(anyObject)
            }
        }
    }

    func sampleAny(_ route: RouteType) -> Observable<Any> {
        guard let json = JSONFrom(data: route.mockedData) else {
            return Observable.empty()
        }
        return Observable.just(json as Any)
    }

    open func response(_ requestConvertible: URLRequestConvertible) -> Observable<OperaResult> {
        return Observable.create { subscriber in
            let req = self.base.response(requestConvertible) { result in
                switch result.result {
                case .failure(let error):
                    subscriber.onError(error)
                case .success:
                    subscriber.onNext(result)
                    subscriber.onCompleted()
                }
            }
            return Disposables.create {
                req.cancel()
            }
        }
    }

}

open class RxManager: Manager {

    public var rx: Reactive<RxManager> {
        return Reactive(self)
    }

    public override init(manager: SessionManager) {
        super.init(manager: manager)
    }

}
