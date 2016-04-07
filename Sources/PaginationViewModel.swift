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

public class PaginationViewModel<Element: OperaDecodable> {
    
    var paginationRequest: PaginationRequest<Element>
    public typealias LoadingType = (Bool, String)
    
    public let refreshTrigger = PublishSubject<Bool>()
    public let loadNextPageTrigger = PublishSubject<Void>()
    public let queryTrigger = PublishSubject<String>()
    public let filterTrigger = PublishSubject<FilterType>()
    public let networkErrorTrigger = PublishSubject<NetworkError>()

    public let hasNextPage = Variable<Bool>(false)
    public let fullloading = Variable<LoadingType>((false, "1"))
    public let elements = Variable<[Element]>([])
    
    private var disposeBag = DisposeBag()
    private let queryDisposeBag = DisposeBag()
    
    public init(paginationRequest: PaginationRequest<Element>) {
        self.paginationRequest = paginationRequest
        bindPaginationRequest(self.paginationRequest, nextPage: nil)
        setUpForceRefresh()
    }
    
    private func setUpForceRefresh() {
        
        queryTrigger
            .doOnNext { [weak self] queryString in
                guard let mySelf = self else { return }
                mySelf.bindPaginationRequest(mySelf.paginationRequest.routeWithQuery(queryString), nextPage: nil)
            }
            .map { _ in false }
            .bindTo(refreshTrigger)
            .addDisposableTo(queryDisposeBag)
        
        refreshTrigger
            .filter { $0 }
            .doOnNext { [weak self] _ in
                guard let mySelf = self else { return }
                mySelf.bindPaginationRequest(mySelf.paginationRequest.routeWithPage("1"), nextPage: nil)
            }
            .map { _ in false }
            .bindTo(refreshTrigger)
            .addDisposableTo(queryDisposeBag)
        
        
        filterTrigger
            .doOnNext { [weak self] fitler in
                guard let mySelf = self else { return }
                mySelf.bindPaginationRequest(mySelf.paginationRequest.routeWithFilter(fitler), nextPage: nil)
            }
            .map { _ in false }
            .bindTo(refreshTrigger)
            .addDisposableTo(queryDisposeBag)
    }
    
    private func bindPaginationRequest(paginationRequest: PaginationRequest<Element>, nextPage: String?) {
        disposeBag = DisposeBag()
        self.paginationRequest = paginationRequest
        let refreshRequest = refreshTrigger
            .filter { !$0 }
            .take(1)
            .map { _ in paginationRequest }
        
        let nextPageRequest = loadNextPageTrigger
            .take(1)
            .flatMap { nextPage.map { Observable.of(paginationRequest.routeWithPage($0)) } ?? Observable.empty() }
        
        let request = Observable
            .of(refreshRequest, nextPageRequest)
            .merge()
            .take(1)
            .shareReplay(1)
        
        let response = request
            .flatMap { $0.rx_collection() }
            .shareReplay(1)
        
        Observable
            .of(
                request.map { (true, $0.page) },
                response.map { (false, $0.page ?? "1") }.catchErrorJustReturn((false, fullloading.value.1))
            )
            .merge()
            .bindTo(fullloading)
            .addDisposableTo(disposeBag)
                
        Observable
            .combineLatest(elements.asObservable(), response) { elements, response in
                return response.hasPreviousPage ? elements + response.elements : response.elements
            }
            .take(1)
            .bindTo(elements)
            .addDisposableTo(disposeBag)
        
        response
            .map { $0.hasNextPage }
            .bindTo(hasNextPage)
            .addDisposableTo(disposeBag)
        
        response
            .doOnNetworkError { [weak self] error throws in
                guard let mySelf = self else { return }
                Observable.just(error).bindTo(mySelf.networkErrorTrigger).addDisposableTo(mySelf.disposeBag)
            }
            .doOnError { [weak self] _ in
                guard let mySelf = self else { return }
                mySelf.bindPaginationRequest(mySelf.paginationRequest, nextPage: mySelf.fullloading.value.1) }
            .subscribeNext { [weak self] paginationResponse in
                self?.bindPaginationRequest(paginationRequest, nextPage: paginationResponse.nextPage)
            }
            .addDisposableTo(disposeBag)
    }
}

extension PaginationViewModel {
    
    public var loading: Driver<Bool> {
        return fullloading.asDriver().skip(1).map { $0.0 }.distinctUntilChanged()
    }
    
    public var firstPageLoading: Driver<Bool> {
        return fullloading.asDriver().filter { $0.1 == "1" }.map { $0.0 }
    }
    
    public var emptyState: Driver<Bool> {
        return Driver.combineLatest(loading, elements.asDriver()) { (isLoading, elements) -> Bool in
            return !isLoading && elements.isEmpty
        }
        .distinctUntilChanged()
    }
}
