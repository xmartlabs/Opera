//  RepositoryIssuesController.swift
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

class IssuesFilter {

    enum State: Int, CustomStringConvertible {

        case open
        case closed
        case all

        var description: String {
            switch self {
            case .open: return "open"
            case .closed: return "closed"
            case .all: return "all"
            }
        }

    }

    enum Sort: Int, CustomStringConvertible {

        case created
        case updated
        case comments

        var description: String {
            switch self {
            case .created: return "created"
            case .updated: return "updated"
            case .comments: return "comments"
            }
        }

    }

    enum Direction: Int, CustomStringConvertible {

        case ascendant
        case descendant

        var description: String {
            switch self {
            case .ascendant: return "asc"
            case .descendant: return "desc"
            }
        }

    }

    var state = State.open
    var sortBy = Sort.created
    var sortDirection = Direction.descendant
    var issueCreator: String?
    var userMentioned: String?

}

extension IssuesFilter: FilterType {

    var parameters: [String: AnyObject]? {
        var baseParams = ["state": "\(state)", "sort": "\(sortBy)", "direction": "\(sortDirection)"]
        if let issueCreator = issueCreator, !issueCreator.isEmpty { baseParams["creator"] = issueCreator }
        if let userMentioned = userMentioned, !userMentioned.isEmpty { baseParams["mentioned"] = userMentioned }
        return baseParams as [String : AnyObject]?
    }

}

class RepositoryIssuesController: RepositoryBaseController {

    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!

    let refreshControl = UIRefreshControl()

    var disposeBag = DisposeBag()

    fileprivate var filter = BehaviorRelay<IssuesFilter>(value: IssuesFilter())

    lazy var viewModel: PaginationViewModel<PaginationRequest<Issue>> = { [unowned self] in
        return PaginationViewModel(paginationRequest: PaginationRequest(route: GithubAPI.Repository.GetIssues(owner: self.owner, repo: self.name), filter: self.filter.value))
        }()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.keyboardDismissMode = .onDrag
        tableView.addSubview(self.refreshControl)
        emptyStateLabel.text = "No issues found"
        let refreshControl = self.refreshControl

        rx.viewWillAppear.take(1)
            .bind(to: viewModel.refreshTrigger)
            .disposed(by: disposeBag)

        tableView.rx.reachedBottom
            .bind(to: viewModel.loadNextPageTrigger)
            .disposed(by: disposeBag)

        viewModel.loading.asDriver()
            .drive(activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)

        Driver.combineLatest(viewModel.elements.asDriver(), viewModel.firstPageLoading) { elements, loading in return loading ? [] : elements }
            .drive(tableView.rx.items(cellIdentifier:"Cell")) { _, issue, cell in
                cell.textLabel?.text = issue.title
                cell.detailTextLabel?.text = " #\(issue.number)"
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

        filter
            .asObservable()
            .map { $0 }
            .bind(to: viewModel.filterTrigger)
            .disposed(by: disposeBag)

        viewModel.emptyState
            .drive(onNext: { [weak self] emptyState in self?.emptyStateLabel.isHidden = !emptyState })
            .disposed(by: disposeBag)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = (segue.destination as? UINavigationController)?.topViewController as? RepositoryIssueFilterController else { return }
        vc.filter = filter
    }

}
