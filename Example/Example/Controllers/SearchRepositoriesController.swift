//  SearchRepositoriesController.swift
//  Example-iOS ( https://github.com/xmartlabs/Example-iOS )
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

import UIKit
import RxSwift
import RxCocoa
import Opera

class SearchRepositoriesController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var searchBar: UISearchBar!
    let refreshControl = UIRefreshControl()
    
    var disposeBag = DisposeBag()
    
    fileprivate lazy var emptyStateLabel: UILabel = {
        let emptyStateLabel = UILabel()
        emptyStateLabel.text = Constants.noTextMessage
        emptyStateLabel.textAlignment = .center
        return emptyStateLabel
    }()
    
    lazy var viewModel: PaginationViewModel<PaginationRequest<Repository>> = {
        return PaginationViewModel(paginationRequest: PaginationRequest(route: GithubAPI.Repository.Search(), collectionKeyPath: "items"))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = emptyStateLabel
        tableView.keyboardDismissMode = .onDrag
        tableView.addSubview(self.refreshControl)
        let refreshControl = self.refreshControl
        
        rx.sentMessage(#selector(SearchRepositoriesController.viewWillAppear(_:)))
            .skip(1)
            .map { _ in false }
            .bindTo(viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)
        
        tableView.rx_reachedBottom
            .bindTo(viewModel.loadNextPageTrigger)
            .addDisposableTo(disposeBag)
        
        viewModel.loading
            .drive(activityIndicatorView.rx.isAnimating)
            .addDisposableTo(disposeBag)

        viewModel.elements.asObservable()
            .subscribe(
                onNext: { repos in
                    debugPrint(repos)
                },
                onError: { error in
                    debugPrint(error)
                }
            )
            .addDisposableTo(disposeBag)

        Driver.combineLatest(viewModel.elements.asDriver(), viewModel.firstPageLoading, searchBar.rx.text.asDriver()) { elements, loading, searchText in
                return loading || searchText!.isEmpty ? [] : elements
            }
            .asDriver()
            .drive(tableView.rx.items(cellIdentifier: "Cell")) { _, repository, cell in
                cell.textLabel?.text = repository.name
                cell.detailTextLabel?.text = "🌟\(repository.stargazersCount)"
            }
            .addDisposableTo(disposeBag)
        
        tableView.rx.modelSelected(Repository.self)
            .asDriver()
            .drive(onNext: { [weak self] repo in self?.performSegue(withIdentifier: Constants.repositorySegue, sender: RepositoryData(name: repo.name, owner: repo.company)) })
            .addDisposableTo(disposeBag)
        
        searchBar.rx.text
            .filter { !$0!.isEmpty }
            .map { a -> String in a ?? "" }
            .throttle(0.25, scheduler: MainScheduler.instance)
            .bindTo(viewModel.queryTrigger)
            .addDisposableTo(disposeBag)

        searchBar.rx.text
            .filter { $0!.isEmpty }
            .map { _ in return [] }
            .bindTo(viewModel.elements)
            .addDisposableTo(disposeBag)
        
        refreshControl.rx_valueChanged
            .filter { refreshControl.isRefreshing }
            .map { true }
            .bindTo(viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)
        
        viewModel.loading
            .filter { !$0  && refreshControl.isRefreshing }
            .drive(onNext: { _ in refreshControl.endRefreshing() })
            .addDisposableTo(disposeBag)
        
        Driver.combineLatest(viewModel.emptyState, searchBar.rx.text.asDriver().throttle(0.25)) { $0 ||  $1!.isEmpty }
            .drive(onNext: { [weak self] state in
                self?.emptyStateLabel.isHidden = !state
                self?.emptyStateLabel.text = (self?.searchBar.text?.isEmpty ?? true) ? Constants.noTextMessage : Constants.noRepositoriesMessage
            })
            .addDisposableTo(disposeBag)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier, let vc = segue.destination as? RepositoryController, let data = sender as? RepositoryData , identifier == Constants.repositorySegue else { return }
        vc.name = data.name
        vc.owner = data.owner
    }
    
}

extension SearchRepositoriesController {
    
    fileprivate struct Constants {
        static let noTextMessage = "Enter text to search repositories"
        static let noRepositoriesMessage = "No repositories found"
        static let repositorySegue = "Show repository"
    }
    
}
