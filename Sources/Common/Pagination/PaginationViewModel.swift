//  PaginationViewModel.swift
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

import Alamofire
import Foundation
import RxSwift
import RxCocoa

/// Reactive View Model helper to load list of OperaDecodable items.
open class PaginationViewModel<PaginationRequest: PaginationRequestType>
    where PaginationRequest.Response.Element: OperaDecodable {

    /// pagination request
    var paginationRequest: PaginationRequest
    public typealias LoadingType = (Bool, String)

    /// trigger a refresh, if emited item is true it will cancel pending 
    //  request and make a new one. if false it will
    //  not refresh if there is a request in progress.
    open let refreshTrigger = PublishSubject<Bool>()
    /// trigger a next page load, it makes a new request for
    //  the nextPage value provided by lastest request sent to server.
    open let loadNextPageTrigger = PublishSubject<Void>()
    /// Cancel any in progress request and start a new one using the query string provided.
    open let queryTrigger = PublishSubject<String>()
    /// Cancel any in progress request and start a new one using the filter parameters provided.
    open let filterTrigger = PublishSubject<FilterType>()

    /// Allows subscribers to get notified about networking errors
    open let errors = PublishSubject<Error>()
    /// Indicates if there is a next page to load. 
    //  hasNextPage value is the result of getting next link relation from latest response.
    open let hasNextPage = Variable<Bool>(false)
    /// Indicates is there is a request in progress and what is the request page.
    open let fullloading = Variable<LoadingType>((false, "1"))
    /// Elements array from first page up to latest fetched page.
    open let elements = Variable<[PaginationRequest.Response.Element]>([])

    fileprivate var disposeBag = DisposeBag()
    fileprivate let queryDisposeBag = DisposeBag()

    /**
     Initialize a new PaginationViewModel instance.
     
     - parameter paginationRequest: pagination request.
     
     - returns: A PaginationViewModel instance.
     */
    public init(paginationRequest: PaginationRequest) {
        self.paginationRequest = paginationRequest
        bindPaginationRequest(self.paginationRequest, nextPage: nil)
        setUpForceRefresh()
    }

    fileprivate func setUpForceRefresh() {

        queryTrigger
            .do(onNext: { [weak self] queryString in
                guard let mySelf = self else { return }
                mySelf.bindPaginationRequest(
                    mySelf.paginationRequest.routeWithQuery(queryString),
                    nextPage: nil
                )
            })
            .map { _ in false }
            .bind(to: refreshTrigger)
            .addDisposableTo(queryDisposeBag)

        refreshTrigger
            .filter { $0 }
            .do(onNext: { [weak self] _ in
                guard let mySelf = self else { return }
                mySelf.disposeBag = DisposeBag()
                mySelf.bindPaginationRequest(
                    mySelf.paginationRequest.routeWithPage("1"), nextPage: nil
                )
            })
            .map { _ in false }
            .bind(to: refreshTrigger)
            .addDisposableTo(queryDisposeBag)

        filterTrigger
            .do(onNext: { [weak self] fitler in
                guard let mySelf = self else { return }
                mySelf.bindPaginationRequest(
                    mySelf.paginationRequest.routeWithFilter(fitler),
                    nextPage: nil
                )
            })
            .map { _ in false }
            .bind(to: refreshTrigger)
            .addDisposableTo(queryDisposeBag)
    }

    fileprivate func bindPaginationRequest(_ paginationRequest: PaginationRequest, nextPage: String?) {
        self.paginationRequest = paginationRequest
        let refreshRequest = refreshTrigger
            .filter { !$0 }
            .take(1)
            .map { _ in paginationRequest }

        let nextPageRequest = loadNextPageTrigger
            .take(1)
            .flatMap { nextPage.map {
                    Observable.of(paginationRequest.routeWithPage($0))
                } ?? Observable.empty()
            }

        let request = Observable
            .of(refreshRequest, nextPageRequest)
            .merge()
            .take(1)
            .shareReplay(1)

        let response = request
            .flatMap { $0.rx.collection }
            .shareReplay(1)

        Observable
            .of(
                request.map { (true, $0.page) },
                response.map { (false, $0.page ?? "1") }
                    .catchErrorJustReturn((false, fullloading.value.1))
            )
            .merge()
            .bind(to: fullloading)
            .addDisposableTo(disposeBag)

        Observable
            .combineLatest(elements.asObservable(), response) { elements, response in
                return response.hasPreviousPage ? elements + response.elements : response.elements
            }
            .take(1)
            .bind(to: elements)
            .addDisposableTo(disposeBag)

        response
            .map { $0.hasNextPage }
            .bind(to: hasNextPage)
            .addDisposableTo(disposeBag)

        response
            .do(onError: { [weak self] _ in
                guard let mySelf = self else { return }
                mySelf.bindPaginationRequest(
                    mySelf.paginationRequest,
                    nextPage: mySelf.fullloading.value.1)
                }
            )
            .subscribe(onNext: { [weak self] paginationResponse in
                self?.bindPaginationRequest(
                    paginationRequest,
                    nextPage: paginationResponse.nextPage
                )
            })
            .addDisposableTo(disposeBag)
    }
}

extension PaginationViewModel {

    /// Emits items indicating when start and complete requests.
    public var loading: Driver<Bool> {
        return fullloading.asDriver().map { $0.0 }.distinctUntilChanged()
    }

    /// Emits items indicating when first page request starts and completes.
    public var firstPageLoading: Driver<Bool> {
        return fullloading.asDriver().filter { $0.1 == "1" }.map { $0.0 }
    }

    /// Emits items to show/hide a empty state view
    public var emptyState: Driver<Bool> {
        return Driver.combineLatest(loading, elements.asDriver()) { (isLoading, elements) -> Bool in
            return !isLoading && elements.isEmpty
        }
        .distinctUntilChanged()
    }
}
