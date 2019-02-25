//  RepositoryCommitsController.swift
//  Example-iOS 
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

import Foundation
import UIKit
import OperaSwift
import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    private func controlEvent(for selector: Selector) -> ControlEvent<Void> {
        return ControlEvent(events: sentMessage(selector).map { _ in })
    }
    
    var viewWillAppear: ControlEvent<Void> {
        return controlEvent(for: #selector(UIViewController.viewWillAppear))
    }
}

class RepositoryCommitsController: RepositoryBaseController {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    let refreshControl = UIRefreshControl()

    var disposeBag = DisposeBag()

    lazy var viewModel: PaginationViewModel<PaginationRequest<Commit>> = { [unowned self] in
        return PaginationViewModel(paginationRequest: PaginationRequest(route: GithubAPI.Repository.GetCommits(owner: self.owner, repo: self.name)))
        }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .onDrag
        tableView.addSubview(self.refreshControl)
        emptyStateLabel.text = "No commits found"
        let refreshControl = self.refreshControl

        rx.viewWillAppear
            .asDriver()
            .drive(viewModel.refreshTrigger)
            .disposed(by: disposeBag)
        
        tableView.rx.reachedBottom
            .bind(to: viewModel.loadNextPageTrigger)
            .disposed(by: disposeBag)

        viewModel.loading.asDriver()
            .drive(activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)

        Driver.combineLatest(viewModel.elements.asDriver(), viewModel.firstPageLoading) { elements, loading in return loading ? [] : elements }
            .asDriver()
            .drive(tableView.rx.items(cellIdentifier:"Cell")) { _, commit, cell in
                cell.textLabel?.text = commit.author
                cell.detailTextLabel?.text = commit.date.shortRepresentation()
            }
            .disposed(by: disposeBag)

        refreshControl.rx.valueChanged
            .filter { refreshControl.isRefreshing }
            .bind(to: viewModel.refreshTrigger)
            .disposed(by: disposeBag)

        viewModel.loading.asDriver()
            .filter { !$0 && refreshControl.isRefreshing }
            .drive(onNext: { _ in refreshControl.endRefreshing() })
            .disposed(by: disposeBag)

        viewModel.emptyState
            .drive(onNext: { [weak self] emptyState in self?.emptyStateLabel.isHidden = !emptyState })
            .disposed(by: disposeBag)
    }

}
