//
//  ViewController.swift
//  stackViewer
//
//  Created by Slawomir Sowinski on 14.02.2016.
//  Copyright © 2016 Slawomir Sowinski. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UIPopoverPresentationControllerDelegate {
    
    private struct Const {
        static let CellReusedIdentifier = "CellReusedIdentifier"
        static let EstimatedRowHeight: CGFloat = 100
        static let Title = "Stack Overflow Viewer"
        static let SearchText = "Szukaj..."
        static let RefreshString = "Pull to refresh"
        static let RequestCount = 100
        static let popoverText = " to visit the website long press on the cell "
    }
    
    private let tableView = UITableView()
    private let refreshControl = UIRefreshControl()
    private let searchBar = UISearchBar() //without UISearchController (we can use simple of UITextField)
    
    var searchResults = [[Search]]()
    
    private var searchString : String? = "ios" {
        didSet {
            lastSuccessfulRequest = nil
            //            searchBar.text = searchString
            searchResults.removeAll()
            tableView.reloadData()
            performRequest(refreshControl)
        }
    }
    
    var lastSuccessfulRequest : StackRequest?
    
    var requestToPerform : StackRequest? {
        if lastSuccessfulRequest == nil {
            guard searchString != nil else { return nil }
            return StackRequest(intitle : searchString!)//, count: Const.RequestCount)
        } else {
            return lastSuccessfulRequest?.requestForNewer
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUI()
        configureSearchBar()
        
        performRequest(refreshControl)
    }
    
    func performRequest(sender: UIRefreshControl){
        
        guard let request = requestToPerform else {
            sender.endRefreshing()
            return
        }
        
        request.fetchData {
            (fetchedData, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if let fetchedData = fetchedData {
                    self.lastSuccessfulRequest = request
                    if !fetchedData.isEmpty {
                        self.searchResults.insert(fetchedData, atIndex: 0)
                        self.tableView.reloadData()
                        self.tableView.setContentOffset(CGPointZero, animated: false)
                    }
                    
                }
                
                if let error = error {
                    print(error)
                }
                
                sender.endRefreshing()
            }
        }
    }
    
    private func layoutUI(){
        automaticallyAdjustsScrollViewInsets = false
        
        view.backgroundColor = UIColor.redColor()
        title = Const.Title
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: #selector(ViewController.shareAction(_:)))
        shareButton.tintColor = UIColor.blackColor()
        let helpButton = UIBarButtonItem(title: "??", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(ViewController.helpAction(_:)))
        helpButton.tintColor = UIColor.blackColor()
        navigationItem.setRightBarButtonItems([helpButton, shareButton], animated: true)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPressAction(_:)))
        tableView.addGestureRecognizer(longPressGestureRecognizer)
        
        //        refreshControl.attributedTitle = NSAttributedString(string: Const.RefreshString)
        refreshControl.addTarget(self, action: #selector(ViewController.performRequest(_:)), forControlEvents: UIControlEvents.ValueChanged)
        
        tableView.addSubview(refreshControl)
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
    
    func longPressAction(gesture: UILongPressGestureRecognizer){
        let point = gesture.locationInView(tableView)
        guard let indexPath = tableView.indexPathForRowAtPoint(point) else {return}
        if let url = searchResults[indexPath.section][indexPath.row].link {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func shareAction(sender: UIBarButtonItem) {
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let txt = searchResults[indexPath.section][indexPath.row].title
        let url = searchResults[indexPath.section][indexPath.row].link
        shareTextImageAndURL(txt, sharingURL: url)
        
    }
    
    func helpAction(sender: UIBarButtonItem) {
        let hintVC = HintViewController(text: Const.popoverText)
        hintVC.modalPresentationStyle = .Popover
        hintVC.preferredContentSize = CGSizeMake(50, 100)
        let popc = hintVC.popoverPresentationController
        popc?.delegate = self
        popc?.barButtonItem = sender
        
        presentViewController(hintVC, animated: true, completion: nil)
    }
    
    private func shareTextImageAndURL(sharingText: String?, sharingImage: UIImage? = nil, sharingURL: NSURL? = nil) {
        var sharingItems = [AnyObject]()
        
        if let text = sharingText {
            sharingItems.append(text)
        }
        if let image = sharingImage {
            sharingItems.append(image)
        }
        if let url = sharingURL {
            sharingItems.append(url)
        }
        
        let activityViewController = UIActivityViewController(activityItems: sharingItems, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
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
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
        searchString = searchBar.text
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
    
    //    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //        if let url = searchResults[indexPath.section][indexPath.row].link {
    //            UIApplication.sharedApplication().openURL(url)
    //        }
    //    }
    
    // MARK : -UIPopoverPresentationControllerDelegate implemantation
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}

