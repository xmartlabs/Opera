//  InfoViewController.swift
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

class InfoViewController: NSViewController {

    var repository: Repository?

    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var companyLabel: NSTextField!
    @IBOutlet weak var languageLabel: NSTextField!
    @IBOutlet weak var openIssuesLabel: NSTextField!
    @IBOutlet weak var forksLabel: NSTextField!
    @IBOutlet weak var urlLabel: NSTextField!

    //outlets

    override func viewDidLoad() {
        super.viewDidLoad()
        setValues()
    }

    fileprivate func setValues() {
        guard let repositoryToShow = repository else {
            return
        }

        titleLabel.stringValue = repositoryToShow.name
        companyLabel.stringValue = repositoryToShow.company ?? "no info"
        languageLabel.stringValue = repositoryToShow.language ?? "no info"
        openIssuesLabel.stringValue = String(repositoryToShow.openIssues)
        forksLabel.stringValue = String(repositoryToShow.forksCount)
        urlLabel.stringValue = repositoryToShow.url.absoluteString
    }

}
