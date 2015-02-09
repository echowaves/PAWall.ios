//
//  ReplyToAdViewController.swift
//  PAWall
//
//  Created by D on 1/25/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var chatMessages:[PFObject] = [PFObject]()
    // parent conversation is the only parameter that needs to be passed from child controller
//    var parentConversation:PFObject?
    
    // parent post should always be passed from chid controller
    var parentPost:PFObject?
    
    var currentLocation:PFGeoPoint?
    
    @IBOutlet weak var textView: UITextView!
//    @IBOutlet weak var sendImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func goBackAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func sendReplyAction(sender: AnyObject) {
        let mineChatMessages = chatMessages.filter({$0[GMESSAGE.REPLIED_BY] as String == DEVICE_UUID})
        NSLog("there are \(mineChatMessages.count) not mine chat messages")
        
        // if there are no chat replies from me yet and the original post is not from me, apply charges and increment counter
        if mineChatMessages.count == 0 {
            let alertMessage = UIAlertController(title: "Warning", message: "You are initiating a conversation. Charges may apply.", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                
                //TODO: insert payment processing here

                self.chatReply(true)
                
            })
            let cancel = UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
            })
            alertMessage.addAction(cancel)
            alertMessage.addAction(ok)
            presentViewController(alertMessage, animated: true, completion: nil)
        } else {
            chatReply(false)
        }
    }
    
    func chatReply(increment:Bool) -> Void {
        let parentConversation:PFObject? = GConversation.findOrCreateMyConversation(parentPost!, myLocation: currentLocation!)
        
        if textView.text == "" || textView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < 1 {
            let alertMessage = UIAlertController(title: "Warning", message: "You reply can't be empty. Try again.", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
            alertMessage.addAction(ok)
            presentViewController(alertMessage, animated: true, completion: nil)
        } else {
            let chatReply:PFObject = PFObject(className:GMESSAGE.CLASS_NAME)
            chatReply[GMESSAGE.BODY] = textView.text
            chatReply[GMESSAGE.LOCATION] = currentLocation!
            chatReply[GMESSAGE.PARENT_CONVERSATION] = parentConversation
            chatReply[GMESSAGE.REPLIED_BY] = DEVICE_UUID
            chatReply.saveInBackgroundWithBlock { (success: Bool, error: NSError!) -> Void in
                NSLog("reply saved")
                self.chatMessages.insert(chatReply, atIndex:0)
                self.textView.text = ""
                self.tableView.reloadData()
                if increment == true {
                    parentConversation?[GCONVERSATION.CHARGES_APPLIED] = (1.0 / (self.parentPost?[GPOST.REPLIES] as Double + 1.0) as Double)
                    parentConversation?.save()
                    
                    self.parentPost?.incrementKey(GPOST.REPLIES)
                    self.parentPost?.saveInBackgroundWithBlock(nil)
                }
                // create or update alert for post owner
                GAlert.createOrUpdateAlert(
                    self.parentPost!,
                    parentConversation: parentConversation! as PFObject,
                    target: (parentConversation?[GCONVERSATION.PARTICIPANTS] as [String])[0],
                    alertBody: "Someone replied to my post:",
                    chatReply: chatReply[GMESSAGE.BODY] as String)
                
                
                // create or update alert for replyer
                GAlert.createOrUpdateAlert(
                    self.parentPost!,
                    parentConversation: parentConversation! as PFObject,
                    target: (parentConversation?[GCONVERSATION.PARTICIPANTS] as [String])[1],
                    alertBody: "I replied to a post:",
                    chatReply: chatReply[GMESSAGE.BODY] as String)
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parentPost?.fetchIfNeeded()
        NSLog("inside ChatViewController, parentPost: \(parentPost![GPOST.BODY])")
        self.tableView.delegate      =   self
        self.tableView.dataSource    =   self
        
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        
//        self.parentPost = self.parentConversation![GCONVERSATION.PARENT] as? PFObject
//        var timer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: Selector("retrieveAllMessages"), userInfo: nil, repeats: true)
        
    }

//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//        //        self.parentConversation!.fetch()
//        self.parentPost = self.parentConversation![GCONVERSATION.PARENT] as? PFObject
//
//    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)


        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint!, error: NSError!) -> Void in
            
            if error == nil {
                // do something with the new geoPoint
                // 1
                var location = CLLocationCoordinate2D(
                    latitude: geoPoint.latitude,
                    longitude: geoPoint.longitude
                )
                self.currentLocation = geoPoint
                
                self.retrieveAllMessages()
                
            } else {
                let alertMessage = UIAlertController(title: "Error", message: "Enable GPS and try again.", preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                })
                alertMessage.addAction(ok)
                self.presentViewController(alertMessage, animated: true, completion: nil)
            }
        }
    }
    
    func retrieveAllMessages() -> Void {
        let parentConversation:PFObject? = GConversation.findOrCreateMyConversation(parentPost!, myLocation: currentLocation!)

        // now retrieve all messages and present on the screen
        let query = PFQuery(className:GMESSAGE.CLASS_NAME)
        // Interested in locations near user.
        
        query.whereKey(GMESSAGE.PARENT_CONVERSATION, equalTo: parentConversation!)
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                NSLog("Successfully retrieved \(objects.count) messages")
                if self.chatMessages.count != objects.count {
                    self.chatMessages = objects as [PFObject]
                    self.tableView.reloadData()
                }
                
            } else {
                // Log details of the failure
                NSLog("Error: %@ %@", error, error.userInfo!)
                let alertMessage = UIAlertController(title: "Error", message: "Error retreiving chat messages, try agin.", preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
                alertMessage.addAction(ok)
                self.presentViewController(alertMessage, animated: true, completion: nil)
            }
        })
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        NSLog("there are \(chatMessages.count) chat messages")
        return self.chatMessages.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:ChatTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("chat_cell") as ChatTableViewCell
        var chatMessage:PFObject
        
        chatMessage = chatMessages[indexPath.row]
        chatMessage.fetchIfNeeded()
        
        let df = NSDateFormatter()
        df.dateFormat = "MM-dd-yyyy hh:mm a"
        cell.postedAt.text = String(format: "%@", df.stringFromDate(chatMessage.createdAt))
        
        NSLog("Rendering ReplyPost")
        cell.body.text = chatMessage[GMESSAGE.BODY] as? String
        
        if chatMessage[GMESSAGE.REPLIED_BY] as? String == DEVICE_UUID {
            cell.postedAt.text = "Replied by me: \(cell.postedAt.text!)"
        }
        
        return cell
    }
    

    
    
}
