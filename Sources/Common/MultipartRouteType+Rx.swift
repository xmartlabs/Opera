//
//  MultipartRouteType+Rx.swift
//  OperaSwift
//
//  Created by Diego Ernst on 5/10/17.
//
//

import Alamofire
import Foundation
import RxCocoa
import RxSwift

// MARK: - MultipartAdaptedRouteType

public struct ProgressHandler {

    let downloadHandler: Alamofire.Request.ProgressHandler?
    let uploadHandler: Alamofire.Request.ProgressHandler?

}

public protocol MultipartAdaptedRouteType: MultipartRouteType {

    associatedtype MultipartType: MultipartRouteType
    var routeType: MultipartType { get }
    var progressHandler: ProgressHandler? { get }

    func set(uploadProgress: @escaping Alamofire.Request.ProgressHandler)
    func set(downloadProgress: @escaping Alamofire.Request.ProgressHandler)

}

public extension MultipartAdaptedRouteType {

    var method: HTTPMethod { return routeType.method }
    var path: String { return routeType.path }
    var parameters: [String: Any]? { return routeType.parameters }
    var encoding: Alamofire.ParameterEncoding { return routeType.encoding }
    var baseURL: URL { return routeType.baseURL }
    var manager: ManagerType { return routeType.manager }
    var retryCount: Int { return routeType.retryCount }
    var mockedData: Data? { return routeType.mockedData }
    var items: [MultipartData] { return routeType.items }

}

// MARK: - Base class

public class BaseMultipartAdaptedRouteType<T: MultipartRouteType>: MultipartAdaptedRouteType {

    public let routeType: T

    private var uploadProgress: Alamofire.Request.ProgressHandler?
    private var downloadProgress: Alamofire.Request.ProgressHandler?

    public var progressHandler: ProgressHandler? {
        guard uploadProgress != nil || downloadProgress != nil else {
            return nil
        }
        return ProgressHandler(downloadHandler: downloadProgress, uploadHandler: uploadProgress)
    }

    public init(routeType: T) {
        self.routeType = routeType
    }

    public func set(uploadProgress: @escaping Alamofire.Request.ProgressHandler) {
        self.uploadProgress = uploadProgress
    }

    public func set(downloadProgress: @escaping Alamofire.Request.ProgressHandler) {
        self.downloadProgress = downloadProgress
    }

}

// MARK: - Reactive MultipartRouteType

extension Reactive where Base: MultipartRouteType {

    public typealias AdaptedRouteType = BaseMultipartAdaptedRouteType<Base>

    public func upload() -> Reactive<AdaptedRouteType> {
        return Reactive<AdaptedRouteType>(AdaptedRouteType(routeType: base))
    }

}

// MARK: - Reactive MultipartAdaptedRouteType

public extension Reactive where Base: MultipartAdaptedRouteType {

    func uploadProgress(closure: @escaping Alamofire.Request.ProgressHandler) -> Reactive<Base> {
        base.set(uploadProgress: closure)
        return self
    }

    func downloadProgress(closure: @escaping Alamofire.Request.ProgressHandler) -> Reactive<Base> {
        base.set(downloadProgress: closure)
        return self
    }

}

// MARK: - RouteType overrides

public extension Reactive where Base: MultipartAdaptedRouteType {

    public func completable() -> Completable {
        if base.manager.useMockedData && base.mockedData != nil {
            return (base.manager as! RxManager).rx.sampleCompletableResponse(base)
        }
        return (base.manager as! RxManager).rx.completableResponse(base, progressHandler: base.progressHandler)
    }

}
