//
//  RepliesToMyPostViewController.swift
//  PAWall
//
//  Created by D on 1/31/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation

class RepliesToMyPostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var myPost:PFObject?
    
    var myConversations:[PFObject] = [PFObject]()

    @IBOutlet weak var originalPostText: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func goBackAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate      =   self
        self.tableView.dataSource    =   self
        
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.originalPostText.text = myPost![GPOST.BODY] as? String
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Create a query for conversations
        var query = PFQuery(className:GCONVERSATION.CLASS_NAME)
        
        query.whereKey(GCONVERSATION.PARENT, equalTo: myPost)
        query.whereKey(GCONVERSATION.CHARGES_APPLIED, greaterThan: 0)
        query.orderByDescending("createdAt")
        
        // Limit what could be a lot of points.
        
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                
                NSLog("Successfully retrieved \(objects.count)")
                self.myConversations = objects as [PFObject]
                self.tableView.reloadData()
                
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
                
                let alertMessage = UIAlertController(title: "Error", message: "Error retreiving replies, try agin.", preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
                alertMessage.addAction(ok)
                self.presentViewController(alertMessage, animated: true, completion: nil)
                
            }
        })
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myConversations.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:ReplyTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("reply_cell") as ReplyTableViewCell
        
        var conversation:PFObject = myConversations[indexPath.row]
        
        let df = NSDateFormatter()
        df.dateFormat = "MM-dd-yyyy hh:mm a"
        cell.createdAt.text = NSString(format: "%@", df.stringFromDate(conversation.createdAt))
        
        let roundedDistance = roundMoney((conversation[GCONVERSATION.LOCATION] as PFGeoPoint).distanceInMilesTo(myPost![GPOST.LOCATION] as PFGeoPoint))
        cell.distance.text = "\(roundedDistance) Miles"
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
            var conversationObject:PFObject? = nil
            
            let indexPath = self.tableView.indexPathForSelectedRow()!
            NSLog("indexpath row1: \(indexPath.row)")
            conversationObject = self.myConversations[indexPath.row]
            
            chatViewController.parentPost = myPost!
            chatViewController.parentConversation = conversationObject!
        }
    }
    
}