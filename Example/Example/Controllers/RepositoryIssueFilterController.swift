//  RepositoryIssueFilterController.swift
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
import RxSwift
import RxCocoa

class RepositoryIssueFilterController: UITableViewController {

    @IBOutlet weak var stateSegmentControl: UISegmentedControl!
    @IBOutlet weak var sortBySegmentControl: UISegmentedControl!
    @IBOutlet weak var sortDirectionSegmentControl: UISegmentedControl!
    @IBOutlet weak var issueCreatorTextField: UITextField!
    @IBOutlet weak var issueMentionedUserTextField: UITextField!

    var filter: BehaviorRelay<IssuesFilter>!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        stateSegmentControl.selectedSegmentIndex = filter.value.state.rawValue
        sortBySegmentControl.selectedSegmentIndex = filter.value.sortBy.rawValue
        sortDirectionSegmentControl.selectedSegmentIndex = filter.value.sortDirection.rawValue
        issueCreatorTextField.text = filter.value.issueCreator
        issueMentionedUserTextField.text = filter.value.userMentioned

    }

    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        let newFilter = IssuesFilter()

        newFilter.state = IssuesFilter.State(rawValue: stateSegmentControl.selectedSegmentIndex) ?? .open
        newFilter.sortBy = IssuesFilter.Sort(rawValue: sortBySegmentControl.selectedSegmentIndex) ?? .created
        newFilter.sortDirection = IssuesFilter.Direction(rawValue: sortDirectionSegmentControl.selectedSegmentIndex) ?? .descendant
        newFilter.issueCreator = issueCreatorTextField.text
        newFilter.userMentioned = issueMentionedUserTextField.text

        filter.accept(newFilter)

        self.dismiss(animated: true, completion: nil)
    }

}
