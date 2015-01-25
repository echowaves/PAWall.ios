//
//  MyAdsViewController.swift
//  PAWall
//
//  Created by D on 1/25/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation

class MyAdsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var myPosts = [PFObject]()

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate      =   self
        self.tableView.dataSource    =   self

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Create a query for places
        var query = PFQuery(className:GEO_AD.CLASS_NAME)
        // Interested in locations near user.

        query.whereKey(GEO_AD.ACTIVE, equalTo: true)
        query.whereKey(GEO_AD.UUID, equalTo: DEVICE_UUID)
        query.orderByDescending("createdAt")

        // Limit what could be a lot of points.

        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                
                NSLog("Successfully retrieved \(objects.count)")
                self.myPosts = objects as [PFObject]
                self.tableView.reloadData()
                
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
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myPosts.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:MyAdSummaryTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("myad_summary") as MyAdSummaryTableViewCell
        
        var advertizement:PFObject
        
        advertizement = myPosts[indexPath.row]
        
        let df = NSDateFormatter()
        df.dateFormat = "MM-dd-yyyy"
        cell.postedAt.text = NSString(format: "%@", df.stringFromDate(advertizement.createdAt))
        cell.details.text = advertizement[GEO_AD.DESCRIPTION] as? String
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
        self.performSegueWithIdentifier("myad_details", sender: self)
    }

//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 80
//    }

}