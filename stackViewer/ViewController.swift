//
//  ViewController.swift
//  stackViewer
//
//  Created by Slawomir Sowinski on 14.02.2016.
//  Copyright © 2016 Slawomir Sowinski. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    private struct Const {
        static let CellReusedIdentifier = "CellReusedIdentifier"
        static let EstimatedRowHeight: CGFloat = 100
        static let Title = "Stack Overflow Viewer"
        static let SearchText = "Szukaj..."
        static let RequestCount = 100
    }
    
    private let tableView = UITableView()
    private let searchBar = UISearchBar() //without UISearchController (we can use simple of UITextField)
    
    var searchResults = [[Search]]()
    
    private var searchString : String? = "ios" {
        didSet {
            lastSuccessfulRequest = nil
//            searchBar.text = searchString
            searchResults.removeAll()
            tableView.reloadData()
            performRequest()
        }
    }
    
    var lastSuccessfulRequest : StackRequest?
    
    var request : StackRequest? {
        if lastSuccessfulRequest == nil {
            guard searchString != nil else { return nil }
            return StackRequest(intitle : searchString!)//, count: Const.RequestCount)
        } else {
            return lastSuccessfulRequest
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUI()
        configureSearchBar()
        
        performRequest()
    }
    
    private func performRequest() {
        request?.fetchData {
            (fetchedData, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if let fetchedData = fetchedData {
                    self.searchResults.insert(fetchedData, atIndex: 0)
                    self.tableView.reloadData()
                    self.tableView.setContentOffset(CGPointZero, animated: false)
                }
                
                if let error = error {
                    print(error)
                }
            }
        }
    }
    
    private func layoutUI(){
        automaticallyAdjustsScrollViewInsets = false
        
        view.backgroundColor = UIColor.redColor()
        title = Const.Title
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(SearchTableViewCell.self, forCellReuseIdentifier: Const.CellReusedIdentifier)
        tableView.estimatedRowHeight = Const.EstimatedRowHeight //verbsTableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activateConstraints([
            tableView.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor),
            tableView.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
            tableView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor)
            ])
    }
    
    private func configureSearchBar() {
        searchBar.placeholder = Const.SearchText
        searchBar.delegate = self
        searchBar.sizeToFit()
        // Place the search bar view to the tableview headerview.
        tableView.tableHeaderView = searchBar
    }
    
    
    
    
    // MARK: -UISearchBarDelegate Implemantation
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        //        shouldShowSearchResults = true
        //        tableView.reloadData()
        print("searchBarTextDidBeginEditing")
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        //        shouldShowSearchResults = false
        //        tableView.reloadData()
        searchBar.resignFirstResponder()
        print("searchBarCancelButtonClicked")
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        //        if !shouldShowSearchResults {
        //            shouldShowSearchResults = true
        //            tblSearchResults.reloadData()
        //        }
        print("searchBarSearchButtonClicked")
        searchBar.resignFirstResponder()
        searchString = searchBar.text
        print(searchString)
        
    }
    
    // MARK: -UISearchResultsUpdating Implemantation
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        print(searchString)
        
        // Filter the data array and get only those countries that match the search text.
        //        filteredArray = dataArray.filter({ (country) -> Bool in
        //            let countryText: NSString = country
        //
        //            return (countryText.rangeOfString(searchString, options: NSStringCompareOptions.CaseInsensitiveSearch).location) != NSNotFound
        //        })
        
        // Reload the tableview.
        //        tableView.reloadData()
    }
    
    
    // MARK: -UITableViewDataSource Implemantation
    
    // number of sections is 1 by default
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return searchResults.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Const.CellReusedIdentifier) as? SearchTableViewCell
        cell?.search = searchResults[indexPath.section][indexPath.row]
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let url = searchResults[indexPath.section][indexPath.row].link {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
}

