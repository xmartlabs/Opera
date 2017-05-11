//
//  ProgressiveRouteType.swift
//  OperaSwift
//
//  Created by Diego Ernst on 5/11/17.
//
//

import Alamofire
import Foundation

public protocol ProgressiveRouteType: AdaptedRouteType {

}

extension ProgressiveRouteType {

    var downloadProgressHandler: Request.ProgressHandler? {
        return getHandler { (type: ProgressiveDownloadRouteType) in type.progressHandler }
    }

    var uploadProgressHandler: Request.ProgressHandler? {
        return getHandler { (type: ProgressiveUploadRouteType) in type.progressHandler }
    }

    private func getHandler<T>(returnBlock: (T) -> Request.ProgressHandler?) -> Request.ProgressHandler? {
        if let type = self as? T {
            return returnBlock(type)
        }
        var adapted: AdaptedRouteType = self
        while let inner = adapted.routeType as? AdaptedRouteType, !(inner is T) {
            adapted = inner
        }
        guard let type = adapted.routeType as? T else {
            return nil
        }
        return returnBlock(type)
    }

}

public protocol ProgressiveDownloadRouteType: ProgressiveRouteType {

    var progressHandler: Request.ProgressHandler? { get }
    func set(downloadProgressHandler: @escaping Request.ProgressHandler)

}

public protocol ProgressiveUploadRouteType: ProgressiveRouteType {

    var progressHandler: Request.ProgressHandler? { get }
    func set(uploadProgressHandler: @escaping Request.ProgressHandler)

}
