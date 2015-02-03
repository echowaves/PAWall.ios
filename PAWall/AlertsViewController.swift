//
//  AlertsViewController.swift
//  PAWall
//
//  Created by D on 2/2/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation

class AlertsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var myAlerts:[PFObject] = [PFObject]()
    
    @IBOutlet weak var tableView: UITableView!
    
    var myLocation:PFGeoPoint = PFGeoPoint()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate      =   self
        self.tableView.dataSource    =   self
        
//        self.tableView.estimatedRowHeight = 100.0
//        self.tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            //TODO: handle error properly
            (geoPoint: PFGeoPoint!, error: NSError!) -> Void in
            
            if error == nil {
                // do something with the new geoPoint
                self.myLocation = geoPoint
            }
        }
        
        var query = PFQuery(className:GALERT.CLASS_NAME)
        
        query.whereKey(GALERT.TARGET, equalTo: DEVICE_UUID) // all alerts geard towards me
        query.orderByDescending("updatedAt")
        
        // Limit what could be a lot of points.
        
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                
                NSLog("Successfully retrieved \(objects.count) alerts")
                self.myAlerts = objects as [PFObject]
                self.tableView.reloadData()
                
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
                
                let alertMessage = UIAlertController(title: "Error", message: "Error retreiving alerts, try agin.", preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
                alertMessage.addAction(ok)
                self.presentViewController(alertMessage, animated: true, completion: nil)
                
            }
        })
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myAlerts.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:AlertTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("alert_cell") as AlertTableViewCell
        
        var alert:PFObject = myAlerts[indexPath.row]
        
        let df = NSDateFormatter()
        df.dateFormat = "MM-dd-yyyy hh:mm a"
        cell.updatedAt.text = NSString(format: "%@", df.stringFromDate(alert.updatedAt))
        cell.alertBody.text = alert[GALERT.ALERT_BODY] as? String
        cell.chatMessageBody.text  = alert[GALERT.MESSAGE_BODY] as? String
        cell.originalPostBody.text = alert[GALERT.POST_BODY] as? String
        
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
            var alertObject:PFObject? = nil
            
            let indexPath = self.tableView.indexPathForSelectedRow()!
            NSLog("indexpath row1: \(indexPath.row)")
            alertObject = self.myAlerts[indexPath.row]
            let parentPost:PFObject = alertObject![GALERT.PARENT_POST] as PFObject
            let alertTarget:String = alertObject![GALERT.TARGET] as String
            parentPost.fetchIfNeeded()
            chatViewController.parentPost = parentPost
//            chatViewController.parentConversation = conversationObject!
            
            let convQuery = PFQuery(className:GCONVERSATION.CLASS_NAME)
            convQuery.whereKey(GCONVERSATION.PARENT, equalTo: parentPost)
            convQuery.whereKey(GCONVERSATION.CREATED_BY, equalTo: alertTarget)
            convQuery.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    // if no conversation is yet created, create one and also create a first message from the post
                    if objects.count == 0 {
                        let gConversation:PFObject = PFObject(className:GCONVERSATION.CLASS_NAME)
                        gConversation[GCONVERSATION.PARENT] = parentPost
                        gConversation[GCONVERSATION.CREATED_BY] = alertTarget
                        gConversation[GCONVERSATION.LOCATION] = self.myLocation
                        gConversation.save()
                        chatViewController.parentConversation = gConversation
                        
                        let gFirstMessage:PFObject = PFObject(className:GMESSAGE.CLASS_NAME)
                        gFirstMessage[GMESSAGE.PARENT] = gConversation
                        gFirstMessage[GMESSAGE.REPLIED_BY] = parentPost[GPOST.POSTED_BY] as String
                        gFirstMessage[GMESSAGE.BODY] = parentPost[GPOST.BODY] as String
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
}
