//
//  SearchAdsViewController.swift
//  PAWall
//
//  Created by D on 1/16/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation
import MapKit

class SearchPostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,  UISearchControllerDelegate {
    
    var postsNearMe:[PFObject] = [PFObject]()
    var filteredPostsNearMe:[PFObject] = [PFObject]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func createBookmarkAction(sender: AnyObject) {
        if searchBar.text == "" || searchBar.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < 1 {
            let alertMessage = UIAlertController(title: "Warning", message: "Can't save empty bookmark. Try again.", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
            alertMessage.addAction(ok)
            presentViewController(alertMessage, animated: true, completion: nil)
        }
        
        
        let alertMessage = UIAlertController(title: nil, message: "Your search will be bookmarked. You will be Alerted about new posts matching your bookmark.", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            
            GBookmark.createBookmark(self.searchBar.text)
            
        })
        let cancel = UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
        })
        alertMessage.addAction(cancel)
        alertMessage.addAction(ok)
        presentViewController(alertMessage, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.tableView.registerClass(AdSummaryTableViewCell.self, forCellReuseIdentifier: "ad_summary")
        self.tableView.delegate      =   self
        self.tableView.dataSource    =   self
        
        self.searchBar.delegate      =   self
        
        self.tableView.estimatedRowHeight = 80.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.searchDisplayController!.searchResultsTableView.estimatedRowHeight = 80.0
        self.searchDisplayController!.searchResultsTableView.rowHeight = UITableViewAutomaticDimension
        
        //        search("")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
                GPost.findPostNearMe(
                    APP_DELEGATE.getCurrentLocation()!,
                    searchText: "",
                    resultsLimit: 1000,
                    succeeded: { (results) -> () in
                        if results.count > 0 {
                            self.postsNearMe = results as [PFObject]
                            self.tableView.reloadData()
                        }
                        
                    }, failed: { (error) -> () in
                        // Log details of the failure
                        NSLog("Error: %@ %@", error, error.userInfo!)
                        
                        let alertMessage = UIAlertController(title: "Error", message: "Error retreiving posts, try agin.", preferredStyle: UIAlertControllerStyle.Alert)
                        let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
                        alertMessage.addAction(ok)
                        self.presentViewController(alertMessage, animated: true, completion: nil)
                })
                

        }
    
    
    func filterContentForSearchText(searchText:String) {
        
        //        self.postsNearMe = []
        //        self.tableView.reloadData()
        
        GPost.findPostNearMe(
            APP_DELEGATE.getCurrentLocation()!,
            searchText: searchText,
            resultsLimit: 300,
            succeeded: { (results) -> () in
                self.filteredPostsNearMe = results as [PFObject]
                self.searchDisplayController?.searchResultsTableView.reloadData()
            },
            failed: { (error) -> () in
                NSLog("Error: %@ %@", error, error.userInfo!)
                
                let alertMessage = UIAlertController(title: "Error", message: "Error retreiving ads, try agin.", preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
                alertMessage.addAction(ok)
                self.presentViewController(alertMessage, animated: true, completion: nil)
                
        })
        
        
    }

//    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
//        filterContentForSearchText(searchBar.text)
//        println("editing")
//    }
    
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        filterContentForSearchText(searchBar.text)
        NSLog("searchBarTextDidEndEditing")
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.searchDisplayController!.searchResultsTableView {
            return self.filteredPostsNearMe.count
        } else {
            return self.postsNearMe.count
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:PostSummaryTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("post_summary") as PostSummaryTableViewCell
        
        var post:PFObject
        
        if tableView == self.searchDisplayController!.searchResultsTableView {
            post = filteredPostsNearMe[indexPath.row]
        } else {
            post = postsNearMe[indexPath.row]
        }
        
        if let replies = post[GPOST.REPLIES] as Double? {
            let roundedCost = roundMoney(1.0 / (replies + 1))
            cell.replies.text = "$\(roundedCost) to reply"
        } else {
            cell.replies.text = "$1.00 to reply"
        }
        
        let df = NSDateFormatter()
        df.dateFormat = "MM-dd-yyyy"
        cell.postedAt.text = NSString(format: "%@", df.stringFromDate(post.createdAt))
        cell.details.text = post[GPOST.BODY] as? String
        
        let roundedDistance = roundMoney((post[GPOST.LOCATION] as PFGeoPoint).distanceInMilesTo(APP_DELEGATE.getCurrentLocation()!))
        cell.distance.text = "\(roundedDistance) Miles"
        
        //        cell.details.sizeToFit()
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("You selected cell #\(indexPath.row)!")
        self.performSegueWithIdentifier("show_chat", sender: self)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        //        NSLog("prepareForSegue \(segue.identifier!)")
        if segue.identifier == "show_chat" {
            let chatViewController:ChatViewController = segue.destinationViewController as ChatViewController
            var geoPostObject:PFObject?
            
            if self.searchDisplayController!.active  {
                let indexPath = self.searchDisplayController!.searchResultsTableView.indexPathForSelectedRow()!
                NSLog("indexpath row1: \(indexPath.row)")
                geoPostObject = self.filteredPostsNearMe[indexPath.row]
            } else {
                let indexPath = self.tableView.indexPathForSelectedRow()!
                NSLog("indexpath row2: \(indexPath.row)")
                geoPostObject = self.postsNearMe[indexPath.row]
            }
            
            chatViewController.parentPost = geoPostObject!
//            let conversation:PFObject? = GConversation.findOrCreateMyConversation(
//            geoPostObject!,
//            myLocation: myLocation)
//
//            if conversation != nil {
//                chatViewController.parentConversation = conversation!
//            } else {
//                let alertMessage = UIAlertController(title: "Error", message: "Unable to find or create Conversation.", preferredStyle: UIAlertControllerStyle.Alert)
//                let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
//                alertMessage.addAction(ok)
//                self.presentViewController(alertMessage, animated: true, completion: nil)
//            }
        }
    }
    
//    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
//        self.filterContentForSearchText(searchString)
//        NSLog("shouldReloadTableForSearchString")
//        return true
//    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        self.filterContentForSearchText(self.searchDisplayController!.searchBar.text)
        NSLog("shouldReloadTableForSearchScope")
        return true
    }
    
    @IBAction func unwindToAdsNearYou (segue : UIStoryboardSegue) {
        NSLog("CreateAd seque from segue id: \(segue.identifier)")
    }
        
}

//http://www.raywenderlich.com/76519/add-table-view-search-swift
