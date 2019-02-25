//
//  ViewController.swift
//  Example-OSX
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

import Cocoa
import RxSwift
import RxCocoa
import OperaSwift

private struct SegueIdentifiers {
    static let ShowInformationSegue = "showInfo"
}

class ViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var searchBar: NSSearchField!
    @IBOutlet weak var pageIndicator: NSTextField!
    @IBOutlet weak var emptyStateView: NSView!
    @IBOutlet weak var refreshButton: NSButton!
    @IBOutlet weak var showNextPageButton: NSButton!
    
    var selectedRepository: Repository?
    var disposeBag = DisposeBag()

    
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

    @objc func tableViewDoubleClick(_ sender: AnyObject) {
        guard tableView.selectedRow >= 0 else {
            return
        }
        selectedRepository = viewModel.elements.value[tableView.selectedRow]
        performSegue(withIdentifier: SegueIdentifiers.ShowInformationSegue, sender: nil)
    }

    fileprivate func setupTableView() {
        searchBar.rx.text
            .filter { !$0!.isEmpty }
            .map { str -> String in str ?? "" }
            .debounce(0.50, scheduler: MainScheduler.instance)
            .bind(to: viewModel.queryTrigger)
            .disposed(by: disposeBag)
        
        searchBar.rx.text
            .filter { $0?.isEmpty ?? true }
            .map { _ in return [] }
            .bind(to: viewModel.elements)
            .disposed(by: disposeBag)
        
        refreshButton.rx.tap.asDriver()
            .filter { [weak self] _ in self?.searchBar.stringValue.isEmpty == false }
            .do(onNext: { [weak self] _ in
                self?.pageIndicator.stringValue = "1"
            })
            .drive(viewModel.refreshTrigger)
            .disposed(by: disposeBag)

        showNextPageButton.rx.tap.asDriver()
            .filter { [weak self] _ in self?.searchBar.stringValue.isEmpty == false }
            .do(onNext: { [weak self] str in
                self?.pageIndicator.stringValue = String(Int(self?.pageIndicator.stringValue ?? "1")! + 1)
            })
            .drive(viewModel.loadNextPageTrigger)
            .disposed(by: disposeBag)
        
        //Load the table when its needed
        Driver.combineLatest(viewModel.elements.asDriver(), viewModel.firstPageLoading, searchBar.rx.text.asDriver()) { elements, loading, searchText in
            return loading || searchText!.isEmpty ? [] : elements
            }
            .asDriver()
            .drive(onNext: { [weak self] repositories in
                self?.tableView.reloadData()
                if repositories.isEmpty {
                    self?.showEmptyStateView(true)
                } else {
                    self?.showEmptyStateView(false)
                }
            })
            .disposed(by: disposeBag)

        //Empty state
        Driver.combineLatest(viewModel.emptyState, searchBar.rx.text.asDriver().throttle(0.50)) { $0 ||  $1!.isEmpty }
            .drive(onNext: { [weak self] state in
                self?.showEmptyStateView(state)
                self?.pageIndicator.stringValue = "1"
            })
            .disposed(by: disposeBag)
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
        return viewModel.elements.value.count
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

        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: self) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }

        return nil
    }

}
