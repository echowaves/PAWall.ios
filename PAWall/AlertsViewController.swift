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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate      =   self
        self.tableView.dataSource    =   self
        
        //        self.tableView.estimatedRowHeight = 100.0
        //        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        GAlert.findMyAlerts(
            DEVICE_UUID,
            succeeded: { (results) -> () in
                NSLog("Successfully retrieved \(results.count) alerts")
                self.myAlerts = results as [PFObject]
                self.tableView.reloadData()
                //                self.tableView.reloadInputViews()
                //                self.tableView.setNeedsDisplay()
                //                self.tableView.setNeedsLayout()
                
            }) { (error) -> () in
                NSLog("Error: %@ %@", error, error.userInfo!)
                
                let alertMessage = UIAlertController(title: "Error", message: "Error retreiving alerts, try agin.", preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
                alertMessage.addAction(ok)
                self.presentViewController(alertMessage, animated: true, completion: nil)
        }
        
        
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myAlerts.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //
        var alert:PFObject = myAlerts[indexPath.row]
        alert.fetchIfNeeded()
        
        var cell:UITableViewCell = UITableViewCell()
        let alertBody:String = alert[GALERT.ALERT_BODY] as String
        let parentConversation:PFObject? = alert[GALERT.PARENT_CONVERSATION] as? PFObject
        
        if parentConversation != nil { // only the alerts that have paren conversation can be replied to
            cell  = self.tableView.dequeueReusableCellWithIdentifier("alert_cell") as AlertTableViewCell
            let df = NSDateFormatter()
            df.dateFormat = "MM-dd-yyyy hh:mm a"
            (cell as AlertTableViewCell).updatedAt.text = NSString(format: "%@", df.stringFromDate(alert.updatedAt))
            (cell as AlertTableViewCell).alertBody.text = alertBody
            (cell as AlertTableViewCell).chatMessageBody.text  = alert[GALERT.MESSAGE_BODY] as? String
            (cell as AlertTableViewCell).originalPostBody.text = alert[GALERT.POST_BODY] as? String
        } else
            if parentConversation == nil { // this alert is created by me, so there is no conversation involved and it can't replied to
                cell  = self.tableView.dequeueReusableCellWithIdentifier("post_created_alert_cell") as AlertPostCreatedByMeTableViewCell
                let df = NSDateFormatter()
                df.dateFormat = "MM-dd-yyyy hh:mm a"
                (cell as AlertPostCreatedByMeTableViewCell).createdAt.text = NSString(format: "%@", df.stringFromDate(alert.createdAt))
                (cell as AlertPostCreatedByMeTableViewCell).body.text = alert[GALERT.POST_BODY] as? String
                
                let post:PFObject? = alert[GALERT.PARENT_POST] as? PFObject
                post?.fetchIfNeeded()
                
                let activeSwitch:UISwitch = (cell as AlertPostCreatedByMeTableViewCell).active
                activeSwitch.on = post![GPOST.ACTIVE] as Bool
                
                activeSwitch.tag = indexPath.row
                activeSwitch.addTarget(self, action: "switchFliped:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        if(APP_DELEGATE.alertUnread(alert)) {
            cell.backgroundColor = UIColor.lightGrayColor()
        }
        return cell
    }
    
    func switchFliped(sender:UISwitch) {
        let uiSwitch:UISwitch = sender as UISwitch
        let switchRow:Int = sender.tag
        NSLog("flipped switch: \(switchRow)")
        
        let postObject = myAlerts[switchRow][GALERT.PARENT_POST] as PFObject
        postObject.fetchIfNeeded()
        
        postObject[GPOST.ACTIVE] = uiSwitch.on
        postObject.saveEventually()
        
        // if switch is off
        if !uiSwitch.on {
            let alertMessage = UIAlertController(title: "Info", message: "Making post inactive will prevent it from been searchable", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
            alertMessage.addAction(ok)
            self.presentViewController(alertMessage, animated: true, completion: nil)
        }
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        NSLog("You selected cell #\(indexPath.row)!")
        
        var alertObject:PFObject = self.myAlerts[indexPath.row]
        alertObject.fetchIfNeeded()
        let parentConversation:PFObject? = alertObject[GALERT.PARENT_CONVERSATION] as? PFObject
        if parentConversation != nil { // only the alerts that have paren conversation can be replied to
            //mart alert read
            APP_DELEGATE.markAlertRead(alertObject)
            self.performSegueWithIdentifier("show_chat", sender: self)
        }
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
            //            let alertTarget:String = alertObject![GALERT.TARGET] as String
            //            parentPost.fetch()
            chatViewController.parentPost = parentPost
            //            chatViewController.parentConversation = alertObject![GALERT.PARENT_CONVERSATION] as? PFObject
            
            //            let conversation:PFObject? = GConversation.findOrCreateMyConversation(
            //                parentPost,
            //                myLocation: myLocation)
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
}
