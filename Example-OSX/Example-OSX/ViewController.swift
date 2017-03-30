//
//  ViewController.swift
//  Example-OSX
//
//  Created by Federico Ojeda on 4/18/16.
//  Copyright © 2016 Federico Ojeda. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa
import Opera

private struct SegueIdentifiers {
    static let ShowInformationSegue = "showInfo"
}

class ViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var searchBar: NSSearchField!
    @IBOutlet weak var pageIndicator: NSTextField!
    @IBOutlet weak var emptyStateView: NSView!

    var selectedRepository: Repository?
    var disposeBag = DisposeBag()
    let changedPage = Variable<Bool>(false)
    let refreshed = Variable<Bool>(false)

    lazy var viewModel: PaginationViewModel<PaginationRequest<Repository>> = {
        return PaginationViewModel(paginationRequest: PaginationRequest(route: GithubAPI.Repository.Search(), collectionKeyPath: "items"))
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegates()
        showEmptyStateView(true)
        setupTableView()
    }

    fileprivate func showEmptyStateView(_ show: Bool) {
        emptyStateView.isHidden = !show
        tableView.isHidden = show
    }

    fileprivate func setDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.target = self
        tableView.doubleAction = #selector(ViewController.tableViewDoubleClick(_:))
    }

    func tableViewDoubleClick(_ sender: AnyObject) {
        guard tableView.selectedRow >= 0 else {
            return
        }
        selectedRepository = viewModel.elements.value[tableView.selectedRow]
        performSegue(withIdentifier: SegueIdentifiers.ShowInformationSegue, sender: nil)
    }

    fileprivate func setupTableView() {
        searchBar.rx_text
            .filter { !$0.isEmpty }
            .throttle(0.50, scheduler: MainScheduler.instance)
            .bindTo(viewModel.queryTrigger)
            .addDisposableTo(disposeBag)

        searchBar.rx_text
            .filter { $0.isEmpty }
            .map { _ in return [] }
            .bindTo(viewModel.elements)
            .addDisposableTo(disposeBag)

        changedPage
            .asObservable()
            .skip(1)
            .flatMap { _ -> Observable<Void> in
                return Observable.just()
            }
            .bindTo(viewModel.loadNextPageTrigger)
            .addDisposableTo(disposeBag)

        refreshed
            .asObservable()
            .skip(1)
            .bindTo(viewModel.refreshTrigger)
            .addDisposableTo(disposeBag)

        //Load the table when its needed
        Driver.combineLatest(viewModel.elements.asDriver(), viewModel.firstPageLoading, searchBar.rx_text.asDriver()) { elements, loading, searchText in
            return loading || searchText.isEmpty ? [] : elements
            }
            .asDriver()
            .driveNext { [weak self] repositories in
                self?.tableView.reloadData()
                if repositories.isEmpty {
                    self?.showEmptyStateView(true)
                } else {
                    self?.showEmptyStateView(false)
                }
            }
            .addDisposableTo(disposeBag)

        //Empty state
        Driver.combineLatest(viewModel.emptyState, searchBar.rx_text.asDriver().throttle(0.50)) { $0 ||  $1.isEmpty }
            .driveNext { [weak self] state in
                self?.showEmptyStateView(state)
                self?.pageIndicator.stringValue = "1"
            }
            .addDisposableTo(disposeBag)
    }

    @IBAction func getNextPage(_ sender: AnyObject) {
        guard !searchBar.stringValue.isEmpty else {
            return
        }

        changedPage.value = true
        pageIndicator.stringValue = String(Int(pageIndicator.stringValue)! + 1)
    }

    @IBAction func refresh(_ sender: AnyObject) {
        guard !searchBar.stringValue.isEmpty else {
            return
        }

        refreshed.value = true
        pageIndicator.stringValue = "1"
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        if let toViewController = segue.destinationController as? InfoViewController {
            if let repositoryToShow = selectedRepository {
                toViewController.repository = repositoryToShow
            }
        }
    }
}

extension ViewController : NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return viewModel.elements.value.count ?? 0
    }

}

extension ViewController : NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        var text: String = ""
        var cellIdentifier: String = ""
        let item = viewModel.elements.value[row]

        if tableColumn == tableView.tableColumns[0] {
            text = item.name
            cellIdentifier = "NameCell"
        } else if tableColumn == tableView.tableColumns[1] {
            text = "🌟\(item.stargazersCount)"
            cellIdentifier = "StarsCell"
        }

        if let cell = tableView.make(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }

        return nil
    }

}
