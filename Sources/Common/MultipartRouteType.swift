//
//  MultipartRouteType.swift
//  OperaSwift
//
//  Created by Miguel Revetria on 5/3/17.
//
//

import Alamofire
import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

#if os(iOS) || os(tvOS) || os(watchOS)
public typealias Image = UIImage
#elseif os(OSX)
public typealias Image = NSImage
#endif



// MARK: - MultipartRequestType

public struct MultipartData {

    let data: Data
    let fileName: String
    let mimeType: String
    let name: String

}

public protocol MultipartRouteType: RouteType {

    var items: [MultipartData] { get }

}

public extension MultipartRouteType {

    var method: HTTPMethod {
        return .post
    }

}

// MARK: - ImageUploadRouteType

public enum ImageUploadEncoding {

    case png
    case jpeg(quality: CGFloat)

    var fileExtension: String {
        switch self {
        case .png:
            return "png"
        case .jpeg:
            return "jpg"
        }
    }
    
    func encode(image: Image) -> Data? {
#if os(iOS) || os(tvOS) || os(watchOS)
        switch self {
        case .png:
            return UIImagePNGRepresentation(image)
        case let .jpeg(quality):
            return UIImageJPEGRepresentation(image, quality)
        }
#elseif os(OSX)
        var format = NSBitmapImageRep.FileType.jpeg
        if case .png = self {
           format = NSBitmapImageRep.FileType.png
        }
        guard let data = image.tiffRepresentation, let rep = NSBitmapImageRep(data: data), let imgData = rep.representation(using: format, properties: [:]) else {
            return nil
        }
        return imgData
#endif
    }

}

public protocol ImageUploadRouteType: MultipartRouteType {

    var encoding: ImageUploadEncoding { get }
    var image: Image { get }
    var fileName: String { get }
    var imageName: String { get }

}

public extension ImageUploadRouteType {

    var items: [MultipartData] {
        return [
            MultipartData(
                data: encoding.encode(image: image) ?? Data(),
                fileName: fileName,
                mimeType: mimeType,
                name: imageName
            )
        ]
    }

    var encoding: ImageUploadEncoding {
        return .jpeg(quality: 0.80)
    }

    var fileName: String {
        return "\(imageName).\(encoding.fileExtension)"
    }

    var imageName: String {
        return "image"
    }

    var mimeType: String {
        return "image/\(encoding.fileExtension)"
    }

}

// MARK: - FileUploadRouteType

public protocol FileUploadRouteType: MultipartRouteType {

    var fileName: String { get }
    var fileUrl: URL { get }
    var mimeType: String { get }
    var name: String { get }

}

extension FileUploadRouteType {

    var items: [MultipartData] {
        return [
            MultipartData(
                data: (try? Data(contentsOf: fileUrl)) ?? Data(),
                fileName: fileName,
                mimeType: mimeType,
                name: name
            )
        ]
    }

    var fileName: String {
        return fileUrl.lastPathComponent
    }

    var name: String {
        return "file"
    }

}
