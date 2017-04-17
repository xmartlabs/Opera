//
//  ManagerType+Rx.swift
//  Opera
//
//  Created by Martin Barreto on 6/17/16.
//
//

import Alamofire
import Foundation
import RxSwift
import RxCocoa

extension Reactive where Base: RxManager {

    /**
     Returns a `Single` of T for the current request. Notice that T conforms to OperaDecodable. If something goes wrong an `OperaSwift.Error` error is propagated through the result sequence.

     - parameter route: the route indicates the networking call that will be performed by including all the needed information like parameters, URL and HTTP method.
     - parameter keyPath: keyPath to look up json object to serialize. Ignore parameter or pass nil when json object is the json root item.

     - returns: An instance of `Single<T>`
     */
    func object<T: OperaDecodable>(_ route: RouteType, keyPath: String? = nil) -> Single<T> {
        return base.rx.response(route).flatMap { operaResult -> Single<T> in
            let serialized: DataResponse<T>  = operaResult.serializeObject(keyPath)
            switch serialized.result {
            case .failure(let error):
                return Single.error(error)
            case .success(let anyObject):
                return Single.just(anyObject)
            }
        }
    }

    /**
     Returns a `Single` of [T] for the current request. Notice that T conforms to OperaDecodable. If something goes wrong an `OperaSwift.Error` error is propagated through the result sequence.

     - parameter route: the route indicates the networking call that will be performed by including all the needed information like parameters, URL and HTTP method.
     - parameter collectionKeyPath: keyPath to look up json array to serialize. Ignore parameter or pass nil when json array is the json root item.

     - returns: An instance of `Single<[T]>`
     */
    func collection<T: OperaDecodable>(_ route: RouteType, collectionKeyPath: String? = nil) -> Single<[T]> {
        return base.rx.response(route).flatMap { operaResult -> Single<[T]> in
            let serialized: DataResponse<[T]> = operaResult.serializeCollection(collectionKeyPath)
            switch serialized.result {
            case .failure(let error):
                return Single.error(error)
            case .success(let anyObject):
                return Single.just(anyObject)
            }
        }
    }

    /**
     Returns an `Single` of AnyObject for the current request. If something goes wrong an `OperaSwift.Error` error is propagated through the result sequence.

     - parameter route: the route indicates the networking call that will be performed by including all the needed information like parameters, URL and HTTP method.

     - returns: An instance of `Single<AnyObject>`
     */
    func any(_ route: RouteType) -> Single<Any> {
        return base.rx.response(route).flatMap { operaResult -> Single<Any> in
            let serialized = operaResult.serializeAny()
            switch serialized.result {
            case .failure(let error):
                return Single.error(error)
            case .success(let anyObject):
                return Single.just(anyObject)
            }
        }
    }

    /**
     Returns an `Single` of `OperaResult` for the current request. If something goes wrong an `OperaSwift.Error` error is propagated through the result sequence.

     - parameter requestConvertible: the request that will be performed.

     - returns: An instance of `Single<OperaResult>`
     */
    func response(_ requestConvertible: URLRequestConvertible) -> Single<OperaResult> {
        return base.response(requestConvertible)
    }

    /**
     Returns a `Completable` sequence for the current request. If something goes wrong an `OperaSwift.Error` error is propagated through the result sequence.

     - parameter requestConvertible: the request that will be performed.

     - returns: An instance of `Completable`
     */
    func completableResponse(_ requestConvertible: URLRequestConvertible) -> Completable {
        return base.completableResponse(requestConvertible)
    }

    // MARK: - Mocks

    /**
     Returns a `Single` of T for the current RouteType. Notice that T conforms to OperaDecodable. If something goes wrong an `OperaSwift.Error` error is propagated through the result sequence.

     - parameter keyPath: keyPath to look up json object to serialize. Ignore parameter or pass nil when json object is the json root item.

     - returns: An instance of `Single<T>` filled with sample data specified on the RouteType.
     */
    func sampleObject<T: OperaDecodable>(_ route: RouteType, keyPath: String? = nil) -> Single<T> {
        guard let json = JSONFrom(data: route.mockedData) else {
            return Single.error(DecodingError.invalidMockedJson)
        }
        let object = keyPath.map({ (json as AnyObject).value(forKeyPath: $0) as Any}) ?? json
        do {
            let decodedData = try T.decode(object as Any)
            return Single.just(decodedData)
        } catch let error {
            return Single.error(error)
        }
    }

    /**
     Returns a `Single` of [T] for for the current RouteType. Notice that T conforms to OperaDecodable. If something goes wrong an `OperaSwift.Error` error is propagated through the result sequence.

     - parameter collectionKeyPath: keyPath to look up json array to serialize. Ignore parameter or pass nil when json array is the json root item.

     - returns: An instance of `Single<[T]>`  filled with sample data specified on the RouteType.
     */
    func sampleCollection<T: OperaDecodable>(_ route: RouteType, collectionKeyPath: String? = nil) -> Single<[T]> {
        guard let json = JSONFrom(data: route.mockedData) else {
            return Single.error(DecodingError.invalidMockedJson)
        }
        guard
            let representation = (collectionKeyPath.map { (json as AnyObject).value(forKeyPath: $0) as Any } ?? json) as? [[String: AnyObject]]
        else {
            return Single.error(DecodingError.invalidJson("Could not find keypath on the decoded json"))
        }

        var result = [T]()
        representation.forEach {
            if let decodedData = try? T.decode($0 as AnyObject) {
                result.append(decodedData)
            }
        }
        return Single.just(result)
    }

    /**
     Returns a `Single` sequence for the current request using the specified mocks. If something goes wrong an `OperaSwift.Error` error is propagated through the result sequence.

     - returns: An instance of `Single<Any>`
     */
    func sampleAny(_ route: RouteType) -> Single<Any> {
        guard let json = JSONFrom(data: route.mockedData) else {
            return Single.error(DecodingError.invalidMockedJson)
        }
        return Single.just(json as Any)
    }

    /**
     Returns an empty `Completable` sequence for the current request. No networking call is done as this is supposed to be used as part of a mocked response

     - returns: An instance of `Completable`
     */
    func sampleCompletableResponse(_ route: RouteType) -> Completable {
        return Completable.empty()
    }

}

open class RxManager: Manager {

    public var rx: Reactive<RxManager> {
        return Reactive(self)
    }

    public override init(manager: SessionManager) {
        super.init(manager: manager)
    }

    open func response(_ requestConvertible: URLRequestConvertible) -> Single<OperaResult> {
        return Single.create { [weak self] subscriber in
            guard let `self` = self else {
                subscriber(.error(UnknownError(error: nil)))
                return Disposables.create()
            }
            let req = self.response(requestConvertible) { result in
                switch result.result {
                case .failure(let error):
                    subscriber(.error(error))
                case .success:
                    subscriber(.success(result))
                }
            }
            return Disposables.create {
                req.cancel()
            }
        }
    }

    open func completableResponse(_ requestConvertible: URLRequestConvertible) -> Completable {
        return Completable.create { [weak self] subscriber in
            guard let `self` = self else {
                subscriber(.error(UnknownError(error: nil)))
                return Disposables.create()
            }
            let req = self.response(requestConvertible) { result in
                switch result.result {
                case .failure(let error):
                    subscriber(.error(error))
                case .success:
                    subscriber(.completed)
                }
            }
            return Disposables.create {
                req.cancel()
            }
        }
    }

}
