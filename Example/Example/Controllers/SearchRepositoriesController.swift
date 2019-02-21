//  SearchRepositoriesController.swift
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

import UIKit
import RxSwift
import RxCocoa
import OperaSwift

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

        tableView.rx.reachedBottom
            .bind(to: viewModel.loadNextPageTrigger)
            .disposed(by: disposeBag)

        viewModel.loading.asDriver()
            .drive(activityIndicatorView.rx.isAnimating)
            .disposed(by: disposeBag)

        viewModel.elements.asObservable()
            .subscribe(
                onNext: { repos in
                    debugPrint("#Repos fetched: \(repos.count)")
                },
                onError: { error in
                    debugPrint(error)
                }
            )
            .disposed(by: disposeBag)

        Driver.combineLatest(viewModel.elements.asDriver(), viewModel.firstPageLoading, searchBar.rx.text.asDriver()) { elements, loading, searchText in
                return loading || searchText!.isEmpty ? [] : elements
            }
            .asDriver()
            .drive(tableView.rx.items(cellIdentifier: "Cell")) { _, repository, cell in
                cell.textLabel?.text = repository.name
                cell.detailTextLabel?.text = "🌟\(repository.stargazersCount)"
            }
            .disposed(by: disposeBag)

        tableView.rx.modelSelected(Repository.self)
            .asDriver()
            .drive(onNext: { [weak self] repo in self?.performSegue(withIdentifier: Constants.repositorySegue, sender: RepositoryData(name: repo.name, owner: repo.company)) })
            .disposed(by: disposeBag)

        searchBar.rx.text.asDriver()
            .filter { !$0!.isEmpty }
            .map { str -> String in str ?? "" }
            .throttle(0.25)
            .drive(viewModel.queryTrigger)
            .disposed(by: disposeBag)

        searchBar.rx.text.asDriver()
            .filter { $0!.isEmpty }
            .map { _ in return [] }
            .drive(viewModel.elements)
            .disposed(by: disposeBag)

        refreshControl.rx.valueChanged.asDriver()
            .filter { refreshControl.isRefreshing }
            .drive(viewModel.refreshTrigger)
            .disposed(by: disposeBag)

        viewModel.loading.asDriver()
            .filter { !$0  && refreshControl.isRefreshing }
            .drive(onNext: { _ in refreshControl.endRefreshing() })
            .disposed(by: disposeBag)

        Driver.combineLatest(viewModel.emptyState, searchBar.rx.text.asDriver().throttle(0.25)) { $0 ||  $1!.isEmpty }
            .drive(onNext: { [weak self] state in
                self?.emptyStateLabel.isHidden = !state
                self?.emptyStateLabel.text = (self?.searchBar.text?.isEmpty ?? true) ? Constants.noTextMessage : Constants.noRepositoriesMessage
            })
            .disposed(by: disposeBag)
        
        Driver.just(())
            .drive(viewModel.refreshTrigger)
            .disposed(by: disposeBag)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier, let vc = segue.destination as? RepositoryController, let data = sender as? RepositoryData, identifier == Constants.repositorySegue else { return }
        vc.name = data.name
        vc.owner = data.owner
    }

    @IBAction func uploadButtonDidTouch(_ sender: Any) {
        GithubAPI.UploadImage.Upload(image: #imageLiteral(resourceName: "screenshot"))
            .rx
            .uploadProgress { progress in
                debugPrint("Upload progress: \(progress.fractionCompleted)")
            }
            .downloadProgress { progress in
                debugPrint("Download progress: \(progress.fractionCompleted)")
            }
            .completable()
            .subscribe(
                onCompleted: {
                    debugPrint("Completed")
                },
                onError: { error in
                    if let operaError = error as? OperaError {
                        debugPrint(operaError.bodyString ?? "")
                    } else {
                        debugPrint(error)
                    }
                }
            )
            .disposed(by: disposeBag)
    }

}

extension SearchRepositoriesController {

    fileprivate struct Constants {
        static let noTextMessage = "Enter text to search repositories"
        static let noRepositoriesMessage = "No repositories found"
        static let repositorySegue = "Show repository"
    }

}
