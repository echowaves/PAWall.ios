//
//  MyAdsViewController.swift
//  PAWall
//
//  Created by D on 1/25/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation

class MyPostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var myPosts:[PFObject] = [PFObject]()

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate      =   self
        self.tableView.dataSource    =   self

        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension

    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Create a query for places
        var query = PFQuery(className:GPOST.CLASS_NAME)
        // Interested in locations near user.

        query.whereKey(GPOST.ACTIVE, equalTo: true)
        query.whereKey(GPOST.POSTED_BY, equalTo: DEVICE_UUID)
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
                
                let alertMessage = UIAlertController(title: "Error", message: "Error retreiving posts, try agin.", preferredStyle: UIAlertControllerStyle.Alert)
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
        var cell:MyPostSummaryTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("mypost_summary") as MyPostSummaryTableViewCell
        
        var post:PFObject = myPosts[indexPath.row]
        
        let df = NSDateFormatter()
        df.dateFormat = "MM-dd-yyyy"
        cell.postedAt.text = NSString(format: "%@", df.stringFromDate(post.createdAt))
        cell.details.text = post[GPOST.BODY] as? String
        
        if let replies = post[GPOST.REPLIES] as Int? {
            cell.replies.text = "Replies: \(replies)"
        } else {
            cell.replies.text = "Replies: 0"
        }

        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("You selected cell #\(indexPath.row)!")
        self.performSegueWithIdentifier("replies_to_my_post", sender: self)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
//        NSLog("prepareForSegue \(segue.identifier!)")
        if segue.identifier == "replies_to_my_post" {
            let repliesToMyPostViewController:RepliesToMyPostViewController = segue.destinationViewController as RepliesToMyPostViewController
            var geoPostObject:PFObject? = nil
            
            let indexPath = self.tableView.indexPathForSelectedRow()!
            NSLog("indexpath row1: \(indexPath.row)")
            geoPostObject = self.myPosts[indexPath.row]
            repliesToMyPostViewController.myPost = geoPostObject!
        }
    }
    
    
}