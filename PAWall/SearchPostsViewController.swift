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
    
    var adsNearMe = [PFObject]()
    var filteredAdsNearMe = [PFObject]()
    var myLocation:PFGeoPoint = PFGeoPoint()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
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
                var query = PFQuery(className:GEO_POST.CLASS_NAME)
                // Interested in locations near user.
                query.whereKey(GEO_POST.LOCATION, nearGeoPoint:self.myLocation)
                query.whereKey(GEO_POST.ACTIVE, equalTo: true)
                query.whereKey(GEO_POST.UUID, notEqualTo: DEVICE_UUID)
                // Limit what could be a lot of points.
                query.limit = 100
                // Final list of objects
                //                self.adsNearMe =
                
                query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
                    if error == nil {
                        // The find succeeded.
                        // Do something with the found objects
                        
                        
                        NSLog("Successfully retrieved \(objects.count)")
                        if objects.count > 0 {
                            self.adsNearMe = objects as [PFObject]
                            self.tableView.reloadData()
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
    
    func filterContentForSearchText(searchText:String) {
        
        //        self.adsNearMe = []
        //        self.tableView.reloadData()
        
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint!, error: NSError!) -> Void in
            
            if error == nil {
                // do something with the new geoPoint
                self.myLocation = geoPoint
                
                // Create a query for places
                var query = PFQuery(className:GEO_POST.CLASS_NAME)
                // Interested in locations near user.
                query.whereKey(GEO_POST.LOCATION, nearGeoPoint:self.myLocation)
                query.whereKey(GEO_POST.ACTIVE, equalTo: true)
                query.whereKey(GEO_POST.UUID, notEqualTo: DEVICE_UUID)
                NSLog("Searching for string \(searchText)")
                if !searchText.isEmpty {
                    let textArr = split(searchText.lowercaseString) {$0 == " "}
                    query.whereKey(GEO_POST.WORDS, containsAllObjectsInArray: textArr)
                }
                // Limit what could be a lot of points.
                query.limit = 100
                // Final list of objects
                //                self.adsNearMe =
                
                query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
                    if error == nil {
                        // The find succeeded.
                        // Do something with the found objects
                        
                        
                        NSLog("Successfully retrieved \(objects.count)")
                        if objects.count > 0 {
                            self.filteredAdsNearMe = objects as [PFObject]
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
            return self.filteredAdsNearMe.count
        } else {
            return self.adsNearMe.count
        }
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:PostSummaryTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("post_summary") as PostSummaryTableViewCell
        
        var advertizement:PFObject
        
        if tableView == self.searchDisplayController!.searchResultsTableView {
            advertizement = filteredAdsNearMe[indexPath.row]
        } else {
            advertizement = adsNearMe[indexPath.row]
        }
        
        if let replies = advertizement[GEO_POST.REPLIES] as Double? {
            let roundedCost = roundMoney(1.0 / replies)
            cell.replies.text = "$\(roundedCost) to reply"
        } else {
            cell.replies.text = "$1.00 to reply"
        }
        
        let df = NSDateFormatter()
        df.dateFormat = "MM-dd-yyyy"
        cell.postedAt.text = NSString(format: "%@", df.stringFromDate(advertizement.createdAt))
        cell.details.text = advertizement[GEO_POST.BODY] as? String
        
        let roundedDistance = roundMoney((advertizement[GEO_POST.LOCATION] as PFGeoPoint).distanceInMilesTo(myLocation))
        cell.distance.text = "\(roundedDistance) Miles"
        
        //        cell.details.sizeToFit()
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
        self.performSegueWithIdentifier("show_chat", sender: self)
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        NSLog("prepareForSegue \(segue.identifier!)")

        if segue.identifier == "show_chat" {
            let chatViewController:ChatViewController = segue.destinationViewController as ChatViewController
            var geoPostObject:PFObject? = nil
            
            if self.searchDisplayController!.active  {
                let indexPath = self.searchDisplayController!.searchResultsTableView.indexPathForSelectedRow()!
                NSLog("indexpath row1: \(indexPath.row)")
                geoPostObject = self.filteredAdsNearMe[indexPath.row]
            } else {
                let indexPath = self.tableView.indexPathForSelectedRow()!
                NSLog("indexpath row2: \(indexPath.row)")
                geoPostObject = self.adsNearMe[indexPath.row]
            }
            

            
            chatViewController.geoPostObject = geoPostObject!
            
            geoPostObject?.incrementKey(GEO_POST.REPLIES)
            geoPostObject?.saveInBackgroundWithBlock(nil)
            
            //TODO: insert payment processing here

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
