//
//  SearchRepositoriesController.swift
//  XLProjectName
//
//  Created by Xmartlabs SRL. ( http://xmartlabs.com )
//  Copyright © 2016 XLOrganizationName. All rights reserved.
//

import Foundation
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
        emptyStateLabel.text = ControllerConstants.NoTextMessage
        emptyStateLabel.textAlignment = .Center
        return emptyStateLabel
    }()
    
    lazy var viewModel: PaginationViewModel<Repository>  = { [unowned self] in
        return PaginationViewModel(paginationRequest: PaginationRequest(route: Request.Repository.Search(), collectionKeyPath: "items"))
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
                self?.emptyStateLabel.text = (self?.searchBar.text?.isEmpty ?? true) ? ControllerConstants.NoTextMessage : ControllerConstants.NoRepositoriesMessage
            }
            .addDisposableTo(disposeBag)
    }
}

extension SearchRepositoriesController {
    
    private struct ControllerConstants {
        static let NoTextMessage = "Enter text to search repositories"
        static let NoRepositoriesMessage = "No repositories found"
    }
}
