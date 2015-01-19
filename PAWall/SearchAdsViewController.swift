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
    
    var adsNearMe:[PFObject] = []
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
        self.searchBar.becomeFirstResponder()
        self.searchBar.showsCancelButton = false
    }
    
    func search(text:String) {
        
//        self.adsNearMe = []
//        self.tableView.reloadData()
        
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint!, error: NSError!) -> Void in
            
            if error == nil {
                // do something with the new geoPoint
                self.myLocation = geoPoint
                
                // Create a query for places
                var query = PFQuery(className:CLASSIFIED_AD.CLASS_NAME)
                // Interested in locations near user.
                query.whereKey(CLASSIFIED_AD.LOCATION, nearGeoPoint:self.myLocation)
                NSLog("Searching for string \(text)")
                if !text.isEmpty {
                    let textArr = split(text.lowercaseString) {$0 == " "}
                    query.whereKey(CLASSIFIED_AD.WORDS, containsAllObjectsInArray: textArr)
                }
                // Limit what could be a lot of points.
                query.limit = 1000
                // Final list of objects
//                self.adsNearMe =
                
                    query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
                        if error == nil {
                            // The find succeeded.
                            // Do something with the found objects
                            
                            
                            NSLog("Successfully retrieved \(objects.count)")
                            if objects.count > 0 {
                                self.adsNearMe = objects as [PFObject]
                                self.searchDisplayController?.searchResultsTableView.reloadData()
                                self.searchDisplayController?.searchResultsTableView.reloadInputViews()
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
    
    func searchBar(searchBar: UISearchBar,
        textDidChange searchText: String) {
            search(searchBar.text)
        println("editing")
    }
    
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        search(searchBar.text)
        println("searching")
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.adsNearMe.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:AdSummaryTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("ad_summary") as AdSummaryTableViewCell
        
        cell.summary.text = adsNearMe[indexPath.row][CLASSIFIED_AD.DESCRIPTION] as? String
        cell.details.text = adsNearMe[indexPath.row][CLASSIFIED_AD.DESCRIPTION] as? String
        
        let numberOfPlaces = 2.0
        let multiplier = pow(10.0, numberOfPlaces)
        let distance = (adsNearMe[indexPath.row][CLASSIFIED_AD.LOCATION] as PFGeoPoint).distanceInMilesTo(myLocation)
        let roundedDistance = round(distance * multiplier) / multiplier

        cell.distance.text = "\(roundedDistance) Miles"

//        cell.details.sizeToFit()
        return cell
    }
 
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      return 80
    }
    
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchString searchString: String!) -> Bool {
        self.search(searchString)
        return true
    }
    
    func searchDisplayController(controller: UISearchDisplayController!, shouldReloadTableForSearchScope searchOption: Int) -> Bool {
        self.search(self.searchDisplayController!.searchBar.text)
        return true
    }
}