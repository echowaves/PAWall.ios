//
//  SearchAdsViewController.swift
//  PAWall
//
//  Created by D on 1/16/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation
import MapKit

class SearchPostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate {
    
    var postsNearMe:[PFObject] = [PFObject]()
    var filteredPostsNearMe:[PFObject] = [PFObject]()
    var myLocation:PFGeoPoint = PFGeoPoint()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func createBookmarkAction(sender: AnyObject) {
        if searchBar.text == "" || searchBar.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < 1 {
            let alertMessage = UIAlertController(title: "Warning", message: "Can't save empty bookmark. Try again.", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
            alertMessage.addAction(ok)
            presentViewController(alertMessage, animated: true, completion: nil)
        }
        
        
        let alertMessage = UIAlertController(title: nil, message: "Your Bookmark will be saved. You will be Alerted about new posts matching your bookmark creteria.", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            var gBookmark = PFObject(className:GBOOKMARK.CLASS_NAME)
            gBookmark[GBOOKMARK.SEARCH_TEXT] = self.searchBar.text
            gBookmark[GBOOKMARK.LOCATION] = self.myLocation
            gBookmark[GBOOKMARK.CREATED_BY] = DEVICE_UUID

            var error:NSErrorPointer = nil
            gBookmark.saveEventually({ (success: Bool, error: NSError!) -> Void in
                if success {
                    self.dismissViewControllerAnimated(false, completion: nil)
                } else {
                    let alertMessage = UIAlertController(title: "Error", message: "Unable to bookmark. Try again.", preferredStyle: UIAlertControllerStyle.Alert)
                    let ok = UIAlertAction(title: "OK", style: .Default, handler:nil)
                    alertMessage.addAction(ok)
                    self.presentViewController(alertMessage, animated: true, completion: nil)
                }
            })
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
        
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint!, error: NSError!) -> Void in
            
            if error == nil {
                // do something with the new geoPoint
                self.myLocation = geoPoint
                
                // Create a query for places
                var query = PFQuery(className:GPOST.CLASS_NAME)
                // Interested in locations near user.
                query.whereKey(GPOST.LOCATION, nearGeoPoint:self.myLocation)
                query.whereKey(GPOST.ACTIVE, equalTo: true)
                query.whereKey(GPOST.POSTED_BY, notEqualTo: DEVICE_UUID)
                // Limit what could be a lot of points.
                query.limit = 1000
                // Final list of objects
                //                self.postsNearMe =
                
                query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
                    if error == nil {
                        // The find succeeded.
                        // Do something with the found objects
                        NSLog("Successfully retrieved \(objects.count)")
                        if objects.count > 0 {
                            self.postsNearMe = objects as [PFObject]
                            self.tableView.reloadData()
                        }
                        
                    } else {
                        // Log details of the failure
                        NSLog("Error: %@ %@", error, error.userInfo!)
                        
                        let alertMessage = UIAlertController(title: "Error", message: "Error retreiving posts, try agin.", preferredStyle: UIAlertControllerStyle.Alert)
                        let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
                        alertMessage.addAction(ok)
                        self.presentViewController(alertMessage, animated: true, completion: nil)
                        
                    }
                })
            }
        }
        
        
    }
    
    func filterContentForSearchText(searchText:String) {
        
        //        self.postsNearMe = []
        //        self.tableView.reloadData()

        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint!, error: NSError!) -> Void in
            
            if error == nil {
                // do something with the new geoPoint
                self.myLocation = geoPoint
                
                // Create a query for places
                var query = PFQuery(className:GPOST.CLASS_NAME)
                // Interested in locations near user.
                query.whereKey(GPOST.LOCATION, nearGeoPoint:self.myLocation)
                query.whereKey(GPOST.ACTIVE, equalTo: true)
                query.whereKey(GPOST.POSTED_BY, notEqualTo: DEVICE_UUID)
                NSLog("Searching for string \(searchText)")
                if !searchText.isEmpty {
                    let textArr = split(searchText.lowercaseString.stringByReplacingOccurrencesOfString("#", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)) {$0 == " "}

                    query.whereKey(GPOST.HASH_TAGS, containsAllObjectsInArray: textArr)
                }
                // Limit what could be a lot of points.
                query.limit = 300
                // Final list of objects
                //                self.postsNearMe =
                
                query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
                    if error == nil {
                        // The find succeeded.
                        // Do something with the found objects
                        
                        
                        NSLog("Successfully retrieved \(objects.count)")
                        if objects.count > 0 {
                            self.filteredPostsNearMe = objects as [PFObject]
                            self.searchDisplayController?.searchResultsTableView.reloadData()
                            //                                self.searchDisplayController?.searchResultsTableView.reloadInputViews()
                        }
                        
                    } else {
                        // Log details of the failure
                        NSLog("Error: %@ %@", error, error.userInfo!)
                        
                        let alertMessage = UIAlertController(title: "Error", message: "Error retreiving ads, try agin.", preferredStyle: UIAlertControllerStyle.Alert)
                        let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
                        alertMessage.addAction(ok)
                        self.presentViewController(alertMessage, animated: true, completion: nil)
                        
                    }
                })
            }
        }
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchBar.text)
        println("editing")
    }
    
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        filterContentForSearchText(searchBar.text)
        println("searching")
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
        
        var advertizement:PFObject
        
        if tableView == self.searchDisplayController!.searchResultsTableView {
            advertizement = filteredPostsNearMe[indexPath.row]
        } else {
            advertizement = postsNearMe[indexPath.row]
        }
        
        if let replies = advertizement[GPOST.REPLIES] as Double? {
            let roundedCost = roundMoney(1.0 / (replies + 1))
            cell.replies.text = "$\(roundedCost) to reply"
        } else {
            cell.replies.text = "$1.00 to reply"
        }
        
        let df = NSDateFormatter()
        df.dateFormat = "MM-dd-yyyy"
        cell.postedAt.text = NSString(format: "%@", df.stringFromDate(advertizement.createdAt))
        cell.details.text = advertizement[GPOST.BODY] as? String
        
        let roundedDistance = roundMoney((advertizement[GPOST.LOCATION] as PFGeoPoint).distanceInMilesTo(myLocation))
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
            

            let convQuery = PFQuery(className:GCONVERSATION.CLASS_NAME)
            convQuery.whereKey(GCONVERSATION.PARENT, equalTo: geoPostObject!)
            convQuery.whereKey(GCONVERSATION.CREATED_BY, equalTo: DEVICE_UUID)
            convQuery.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    // if no conversation is yet created, create one and also create a first message from the post
                    if objects.count == 0 {
                        let gConversation:PFObject = PFObject(className:GCONVERSATION.CLASS_NAME)
                        gConversation[GCONVERSATION.PARENT] = geoPostObject!
                        gConversation[GCONVERSATION.CREATED_BY] = DEVICE_UUID
                        gConversation[GCONVERSATION.LOCATION] = self.myLocation
                        gConversation.save()
                        chatViewController.parentConversation = gConversation
                        
                        let gFirstMessage:PFObject = PFObject(className:GMESSAGE.CLASS_NAME)
                        gFirstMessage[GMESSAGE.PARENT] = gConversation
                        gFirstMessage[GMESSAGE.REPLIED_BY] = geoPostObject![GPOST.POSTED_BY] as String
                        gFirstMessage[GMESSAGE.BODY] = geoPostObject![GPOST.BODY] as String
                        gFirstMessage[GMESSAGE.LOCATION] = self.myLocation
                        gFirstMessage.save()
                        
                    } else {
                        chatViewController.parentConversation = objects[0] as? PFObject
                    }
                    
                } else {
                    // Log details of the failure
                    NSLog("Error: %@ %@", error, error.userInfo!)
                    let alertMessage = UIAlertController(title: "Error", message: "Error retreiving conversations, try agin.", preferredStyle: UIAlertControllerStyle.Alert)
                    let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
                    alertMessage.addAction(ok)
                    self.presentViewController(alertMessage, animated: true, completion: nil)
                }
            })
            
        }
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.filterContentForSearchText(searchString)
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        self.filterContentForSearchText(self.searchDisplayController!.searchBar.text)
        return true
    }
    
    @IBAction func unwindToAdsNearYou (segue : UIStoryboardSegue) {
        NSLog("CreateAd seque from segue id: \(segue.identifier)")
    }
    
}

//http://www.raywenderlich.com/76519/add-table-view-search-swift
