//
//  SearchAdsViewController.swift
//  PAWall
//
//  Created by D on 1/16/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation
import MapKit

class SearchAdsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate {
    
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
                var query = PFQuery(className:GEO_AD.CLASS_NAME)
                // Interested in locations near user.
                query.whereKey(GEO_AD.LOCATION, nearGeoPoint:self.myLocation)
                query.whereKey(GEO_AD.ACTIVE, equalTo: true)
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
                var query = PFQuery(className:GEO_AD.CLASS_NAME)
                // Interested in locations near user.
                query.whereKey(GEO_AD.LOCATION, nearGeoPoint:self.myLocation)
                query.whereKey(GEO_AD.ACTIVE, equalTo: true)
                NSLog("Searching for string \(searchText)")
                if !searchText.isEmpty {
                    let textArr = split(searchText.lowercaseString) {$0 == " "}
                    query.whereKey(GEO_AD.WORDS, containsAllObjectsInArray: textArr)
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
        var cell:AdSummaryTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("ad_summary") as AdSummaryTableViewCell
        
        var advertizement:PFObject
        
        if tableView == self.searchDisplayController!.searchResultsTableView {
            advertizement = filteredAdsNearMe[indexPath.row]
        } else {
            advertizement = adsNearMe[indexPath.row]
        }
        
        if let replies = advertizement[GEO_AD.REPLIES] as Int? {
            cell.replies.text = "Replies: \(replies)"
        } else {
            cell.replies.text = "Replies: 0"
        }
        
        let df = NSDateFormatter()
        df.dateFormat = "MM-dd-yyyy"
        cell.postedAt.text = NSString(format: "%@", df.stringFromDate(advertizement.createdAt))
        cell.details.text = advertizement[GEO_AD.DESCRIPTION] as? String
        
        let numberOfPlaces = 2.0
        let multiplier = pow(10.0, numberOfPlaces)
        let distance = (advertizement[GEO_AD.LOCATION] as PFGeoPoint).distanceInMilesTo(myLocation)
        let roundedDistance = round(distance * multiplier) / multiplier
        
        cell.distance.text = "\(roundedDistance) Miles"
        
        //        cell.details.sizeToFit()
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
        self.performSegueWithIdentifier("ad_details", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "ad_details") {
            let adDetailsViewController:AdDetailsViewController = segue.destinationViewController as AdDetailsViewController
            
//            var indexPath:NSIndexPath = NSIndexPath()
            var adObject:PFObject? = nil
            
            
            if self.searchDisplayController!.active  {
                let indexPath = self.searchDisplayController!.searchResultsTableView.indexPathForSelectedRow()!
                NSLog("indexpath row1: \(indexPath.row)")
                adObject = self.filteredAdsNearMe[indexPath.row]
            } else {
                let indexPath = self.tableView.indexPathForSelectedRow()!
                NSLog("indexpath row2: \(indexPath.row)")
                adObject = self.adsNearMe[indexPath.row]
            }
            
            let numberOfPlaces = 2.0
            let multiplier = pow(10.0, numberOfPlaces)
            let distance = (adObject![GEO_AD.LOCATION] as PFGeoPoint).distanceInMilesTo(self.myLocation)
            let roundedDistance = round(distance * multiplier) / multiplier
            
            adDetailsViewController.rawDistance = roundedDistance
            adDetailsViewController.adObject = adObject!
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
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
