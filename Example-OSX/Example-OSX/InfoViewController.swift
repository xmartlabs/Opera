//
//  InfoViewController.swift
//  Example-OSX
//
//  Created by Federico Ojeda on 4/20/16.
//  Copyright © 2016 Federico Ojeda. All rights reserved.
//

import Cocoa

class InfoViewController: NSViewController {

    var repository: Repository? = nil
    
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
        urlLabel.stringValue = repositoryToShow.url.absoluteString!
    }
    
}
