//  PaginationViewModel.swift
//  Opera ( https://github.com/xmartlabs/Opera )
//
//  Copyright (c) 2019 Xmartlabs SRL ( http://xmartlabs.com )
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
import Action

/// Reactive View Model helper to load list of OperaDecodable items.
open class PaginationViewModel<PaginationRequest: PaginationRequestType>
    where PaginationRequest.Response.Element: OperaDecodable {
    
    
    private enum LoadActionInput {
        case page(page: String)
        case query(query: String)
        case filter(filter: FilterType)
    }

    /// pagination request
    var paginationRequest: PaginationRequest
    public typealias LoadingType = (Bool, String)
    
    /// trigger a refresh, if emited item is true it will cancel pending 
    //  request and make a new one. if false it will
    //  not refresh if there is a request in progress.
    public let refreshTrigger = PublishSubject<Void>()
    /// trigger a next page load, it makes a new request for
    //  the nextPage value provided by lastest request sent to server.
    public let loadNextPageTrigger = PublishSubject<Void>()
    /// Cancel any in progress request and start a new one using the query string provided.
    public let queryTrigger = PublishSubject<String>()
    /// Cancel any in progress request and start a new one using the filter parameters provided.
    public let filterTrigger = PublishSubject<FilterType>()

    /// Allows subscribers to get notified about networking errors
    public let errors: Driver<Error>
    /// Indicates if there is a next page to load. 
    //  hasNextPage value is the result of getting next link relation from latest response.
    public let hasNextPage = BehaviorRelay<Bool>(value: false)
    /// Indicates is there is a request in progress and what is the request page.
    public let fullloading = BehaviorRelay<LoadingType>(value: (false, "1"))
    
    public let loading = BehaviorRelay<Bool>(value: false)
    
    /// Elements array from first page up to latest fetched page.
    public let elements = BehaviorRelay<[PaginationRequest.Response.Element]>(value: [])
    
    private let loadAction: Action<LoadActionInput, PaginationRequest.Response>

    fileprivate var disposeBag = DisposeBag()

    /**
     Initialize a new PaginationViewModel instance.
     
     - parameter paginationRequest: pagination request.
     
     - returns: A PaginationViewModel instance.
     */
    public init(paginationRequest: PaginationRequest) {
        self.paginationRequest = paginationRequest
        
        self.loadAction = Action { input in
            var request = paginationRequest
            switch input {
            case .page(let page):
                request = paginationRequest.routeWithPage(page)
            case .query(let query):
                request = paginationRequest.routeWithQuery(query)
            case .filter(let filter):
                request = paginationRequest.routeWithFilter(filter)
            }
            return request.rx.collection.asObservable()
        }
        
        self.errors = loadAction.errors
            .asDriver(onErrorDriveWith: .empty())
            .flatMap { error -> Driver<Error> in
                switch error {
                case .underlyingError(let error):
                    return Driver.just(error)
                case .notEnabled:
                    return Driver.empty()
                }
            }
        
        loadAction
            .elements
            .asDriver(onErrorDriveWith: .empty())
            .scan([]) {
                $1.page == "1" ? $1.elements : $0 + $1.elements
            }
            .startWith([])
            .drive(self.elements)
            .disposed(by: disposeBag)
        
        loadAction.executing
            .asDriver(onErrorJustReturn: false)
            .distinctUntilChanged()
            .drive(self.loading)
            .disposed(by: disposeBag)
        
        loadAction.elements.map { $0.hasNextPage }
            .asDriver(onErrorJustReturn: self.hasNextPage.value)
            .drive(self.hasNextPage)
            .disposed(by: disposeBag)
        
        
        
        self.refreshTrigger
            .map { _ in LoadActionInput.page(page: "1") }
            .bind(to: self.loadAction.inputs)
            .disposed(by: disposeBag)
        
        self.queryTrigger
            .map { LoadActionInput.query(query: $0) }
            .bind(to: self.loadAction.inputs)
            .disposed(by: disposeBag)
        
        self.filterTrigger
            .map { LoadActionInput.filter(filter: $0) }
            .bind(to: self.loadAction.inputs)
            .disposed(by: disposeBag)
        

        self.loadNextPageTrigger
            .withLatestFrom(loadAction.elements)
            .flatMap { $0.nextPage.map { return Observable.of(LoadActionInput.page(page: $0)) } ?? Observable.empty() }
            .bind(to: self.loadAction.inputs)
            .disposed(by: disposeBag)
        
        
        Driver.combineLatest(loadAction.executing.asDriver(onErrorJustReturn: false).distinctUntilChanged(), loadAction.elements.map { $0.nextPage ?? "1" }.asDriver(onErrorJustReturn: self.fullloading.value.1).startWith("1")).drive(self.fullloading)
        .disposed(by: disposeBag)
        
    }


//    fileprivate func bindPaginationRequest(_ paginationRequest: PaginationRequest, nextPage: String?) {
//        self.paginationRequest = paginationRequest


//        let nextPageRequest = loadNextPageTrigger
//            .take(1)
//            .flatMap { _ in nextPage.map {
//                    Observable.of(paginationRequest.routeWithPage($0))
//                } ?? Observable.empty()
//            }

//        let request = Observable
//            .of(refreshRequest, nextPageRequest)
//            .merge()
//            .take(1)
//            .share(replay: 1, scope: .forever)

//        let response = request
//            .flatMap { $0.rx.collection }
//            .share(replay: 1, scope: .forever)
    
        

//        Observable
//            .of(
//                request.map { (true, $0.page) },
//                response.map { (false, $0.page ?? "1") }
//                    .catchErrorJustReturn((false, fullloading.value.1))
//            )
//            .merge()
//            .bind(to: fullloading)
//            .disposed(by: disposeBag)
}

extension PaginationViewModel {

    /// Emits items indicating when start and complete requests.
//    public var loading: Driver<Bool> {
//        return fullloading.asDriver().map { $0.0 }.distinctUntilChanged()
//    }

    /// Emits items indicating when first page request starts and completes.
    public var firstPageLoading: Driver<Bool> {
        return fullloading.asDriver().filter { $0.1 == "1" }.map { $0.0 }.distinctUntilChanged()
    }
    
    /// Emits items to show/hide a empty state view
    public var emptyState: Driver<Bool> {
        return Driver.combineLatest(self.loading.asDriver(onErrorJustReturn: false), self.elements.asDriver()) { (isLoading, elements) -> Bool in
            return !isLoading && elements.isEmpty
        }
        .distinctUntilChanged()
    }
}
