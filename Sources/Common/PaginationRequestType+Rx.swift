//
//  PaginationRequestType+Rx.swift
//  Opera
//
//  Created by Martin Barreto on 6/18/16.
//
//

import Foundation
import RxSwift
import Alamofire

extension PaginationRequestType where Response.Element: OperaDecodable {
    
    /**
     Returns an `Observable` of [Response] for the PaginationRequestType instance. If something goes wrong a Opera.Error error is propagated through the result sequence.
     
     - returns: An instance of `Observable<Response>`
     */
    func rx_collection() -> Observable<Response> {
        let myPage = page
        return (route.manager as! RxManager).rx_response(self).flatMap { operaResult -> Observable<Response> in
            let serialized: Alamofire.Response<[Response.Element], Error> = operaResult.serializeCollection(self.collectionKeyPath)
            switch serialized.result {
            case .Failure(let error):
                return Observable.error(error)
            case .Success(let elements):
                let response = Response.init(elements: elements,
                    previousPage: serialized.response?.linkPagePrameter((self as? WebLinkingSettings)?.prevRelationName ?? Default.prevRelationName,
                        pageParameterName: (self as? WebLinkingSettings)?.relationPageParamName ?? Default.relationPageParamName),
                    nextPage: serialized.response?.linkPagePrameter((self as? WebLinkingSettings)?.nextRelationName ?? Default.nextRelationName,
                        pageParameterName: (self as? WebLinkingSettings)?.relationPageParamName ?? Default.relationPageParamName),
                    page: myPage
                )
                return Observable.just(response)
            }
        }
    }
    
}