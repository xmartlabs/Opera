//  RepositoryForksController.swift
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

import Foundation
import UIKit
import OperaSwift
import RxSwift
import RxCocoa

private enum SortFilter: Int, CustomStringConvertible, FilterType {

    case newest = 0
    case oldest
    case stargazers

    var description: String {
        switch self {
        case .newest: return "newest"
        case .oldest: return "oldest"
        case .stargazers: return "stargazers"
        }
    }

    var parameters: [String: AnyObject]? {
        return ["sort": "\(self)" as AnyObject]
    }

}

class RepositoryForksController: RepositoryBaseController {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var filterSegmentControl: UISegmentedControl!

    let refreshControl = UIRefreshControl()

    var disposeBag = DisposeBag()

    fileprivate var filter = SortFilter.newest

    lazy var viewModel: PaginationViewModel<PaginationRequest<UserRepository>> = { [unowned self] in
        return PaginationViewModel(paginationRequest: PaginationRequest(route: GithubAPI.Repository.GetForks(owner: self.owner, repo: self.name), filter: self.filter))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .onDrag
        emptyStateLabel.text = "No forks found"
        tableView.addSubview(self.refreshControl)
        let refreshControl = self.refreshControl

        rx.sentMessage(#selector(RepositoryForksController.viewWillAppear(_:)))
            .map { _ in false }
            .bind(to: viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)

        tableView.rx.reachedBottom
            .bind(to: viewModel.loadNextPageTrigger)
            .addDisposableTo(disposeBag)

        viewModel.loading
            .drive(activityIndicatorView.rx.isAnimating)
            .addDisposableTo(disposeBag)

        Driver.combineLatest(viewModel.elements.asDriver(), viewModel.firstPageLoading) { elements, loading in return loading ? [] : elements }
            .asDriver()
            .drive(tableView.rx.items(cellIdentifier: "Cell")) { _, userRepository, cell in
                cell.textLabel?.text = userRepository.owner
                cell.detailTextLabel?.text = userRepository.createdAt?.shortRepresentation()
            }
            .addDisposableTo(disposeBag)

        tableView.rx.modelSelected(UserRepository.self)
            .asDriver()
            .drive(onNext: { [weak self] userRepo in self?.performSegue(withIdentifier: "Show forked repository", sender: RepositoryData(name: userRepo.name, owner: userRepo.owner)) },
                   onCompleted: nil, onDisposed: nil)
            .addDisposableTo(disposeBag)

        refreshControl.rx.valueChanged
            .filter { refreshControl.isRefreshing }
            .map { true }
            .bind(to: viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)

        viewModel.loading
            .filter { !$0 && refreshControl.isRefreshing }
            .drive(onNext: { _ in refreshControl.endRefreshing() })
            .addDisposableTo(disposeBag)

        filterSegmentControl.rx.valueChanged
            .map { [weak self] in return SortFilter(rawValue: self?.filterSegmentControl.selectedSegmentIndex ?? 0) ?? .newest }
            .bind(to: viewModel.filterTrigger)
            .addDisposableTo(disposeBag)

        viewModel.emptyState
            .drive(onNext: { [weak self] emptyState in self?.emptyStateLabel.isHidden = !emptyState })
            .addDisposableTo(disposeBag)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let _ = segue.identifier, let vc = segue.destination as? RepositoryController, let data = sender as? RepositoryData else { return }
        vc.name = data.name
        vc.owner = data.owner
    }

}
