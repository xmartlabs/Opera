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
    
    private lazy var emptyStateLabel: UILabel = {
        let emptyStateLabel = UILabel()
        emptyStateLabel.text = Constants.noTextMessage
        emptyStateLabel.textAlignment = .Center
        return emptyStateLabel
    }()
    
    lazy var viewModel: PaginationViewModel<PaginationRequest<Repository>> = {
        return PaginationViewModel(paginationRequest: PaginationRequest(route: GithubAPI.Repository.Search(), collectionKeyPath: "items"))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundView = emptyStateLabel
        tableView.keyboardDismissMode = .OnDrag
        tableView.addSubview(self.refreshControl)
        let refreshControl = self.refreshControl
        
        rx_sentMessage(#selector(SearchRepositoriesController.viewWillAppear(_:)))
            .skip(1)
            .map { _ in false }
            .bindTo(viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)
        
        tableView.rx_reachedBottom
            .bindTo(viewModel.loadNextPageTrigger)
            .addDisposableTo(disposeBag)
        
        viewModel.loading
            .drive(activityIndicatorView.rx_animating)
            .addDisposableTo(disposeBag)
        
        Driver.combineLatest(viewModel.elements.asDriver(), viewModel.firstPageLoading, searchBar.rx_text.asDriver()) { elements, loading, searchText in
                return loading || searchText.isEmpty ? [] : elements
            }
            .asDriver()
            .drive(tableView.rx_itemsWithCellIdentifier("Cell")) { _, repository, cell in
                cell.textLabel?.text = repository.name
                cell.detailTextLabel?.text = "🌟\(repository.stargazersCount)"
            }
            .addDisposableTo(disposeBag)
        
        tableView.rx_modelSelected(Repository)
            .asDriver()
            .driveNext { [weak self] repo in self?.performSegueWithIdentifier(Constants.repositorySegue, sender: RepositoryData(name: repo.name, owner: repo.company)) }
            .addDisposableTo(disposeBag)
        
        searchBar.rx_text
            .filter { !$0.isEmpty }
            .throttle(0.25, scheduler: MainScheduler.instance)
            .bindTo(viewModel.queryTrigger)
            .addDisposableTo(disposeBag)
        
        searchBar.rx_text
            .filter { $0.isEmpty }
            .map { _ in return [] }
            .bindTo(viewModel.elements)
            .addDisposableTo(disposeBag)
        
        refreshControl.rx_valueChanged
            .filter { refreshControl.refreshing }
            .map { true }
            .bindTo(viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)
        
        viewModel.loading
            .filter { !$0  && refreshControl.refreshing }
            .driveNext { _ in refreshControl.endRefreshing() }
            .addDisposableTo(disposeBag)
        
        Driver.combineLatest(viewModel.emptyState, searchBar.rx_text.asDriver().throttle(0.25)) { $0 ||  $1.isEmpty }
            .driveNext { [weak self] state in
                self?.emptyStateLabel.hidden = !state
                self?.emptyStateLabel.text = (self?.searchBar.text?.isEmpty ?? true) ? Constants.noTextMessage : Constants.noRepositoriesMessage
            }
            .addDisposableTo(disposeBag)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let identifier = segue.identifier, vc = segue.destinationViewController as? RepositoryController, data = sender as? RepositoryData where identifier == Constants.repositorySegue else { return }
        vc.name = data.name
        vc.owner = data.owner
    }
    
}

extension SearchRepositoriesController {
    
    private struct Constants {
        static let noTextMessage = "Enter text to search repositories"
        static let noRepositoriesMessage = "No repositories found"
        static let repositorySegue = "Show repository"
    }
    
}
