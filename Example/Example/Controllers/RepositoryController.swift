//  RepositoryController.swift
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

class RepositoryController: UITableViewController {
    
    @IBOutlet weak var repositoryName: UILabel!
    @IBOutlet weak var forksLabel: UILabel!
    @IBOutlet weak var stargazersLabel: UILabel!
    @IBOutlet weak var issuesLabel: UILabel!
    
    var userRepository: UserRepository?
    var owner: String!
    var name: String!
    
    var disposeBag = DisposeBag()
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return userRepository == nil ? 0 : super.numberOfSections(in: tableView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.reloadData()
        
        GithubAPI.Repository.GetInfo(owner: owner, repo: name)
            .rx_object()
            .subscribe(onNext: { [weak self] (userRepo: UserRepository) in
                self?.userRepository = userRepo
                self?.tableView.reloadData()
                
                self?.repositoryName.text = userRepo.name
                self?.forksLabel.text = "\(userRepo.forks)"
                self?.stargazersLabel.text = "\(userRepo.stargazers)"
                self?.issuesLabel.text = "\(userRepo.issues)"
            })
            .addDisposableTo(disposeBag)
        
        tableView.rx.itemSelected
            .asDriver()
            .drive(onNext: { [weak self] indexPath in self?.tableView.deselectRow(at: indexPath, animated: true) })
            .addDisposableTo(disposeBag)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let _ = segue.identifier, let vc = segue.destination as? RepositoryBaseController else { return }
        vc.name = name
        vc.owner = owner
    }
    
}
