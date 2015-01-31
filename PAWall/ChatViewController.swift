//
//  ReplyToAdViewController.swift
//  PAWall
//
//  Created by D on 1/25/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var chatMessages = [PFObject]()
    var geoPostObject:PFObject?
    
    var currentLocation:PFGeoPoint?
    
    @IBOutlet weak var textView: UITextView!
//    @IBOutlet weak var sendImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func goBackAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func sendReplyAction(sender: AnyObject) {
        
        
        let onlyChatObjects = chatMessages.filter({$0.parseClassName! == CHAT_REPLY.CLASS_NAME})
        NSLog("There are \(onlyChatObjects.count) onlyChatObjects")
        let mineChatMessages = onlyChatObjects.filter({$0[CHAT_REPLY.REPLIED_BY] as String == DEVICE_UUID})
        NSLog("there are \(mineChatMessages.count) not mine chat messages")
        
        // if there are no chat replies from me yet and the original post is not from me, apply charges and increment counter
        if mineChatMessages.count == 0 && geoPostObject?[GEO_POST.UUID] as String != DEVICE_UUID {
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
        var chatReply = PFObject(className:CHAT_REPLY.CLASS_NAME)
        chatReply[CHAT_REPLY.BODY] = textView.text
        chatReply[CHAT_REPLY.LOCATION] = currentLocation!
        chatReply[CHAT_REPLY.PARENT] = geoPostObject?
        chatReply[CHAT_REPLY.REPLIED_BY] = DEVICE_UUID
        chatReply.saveInBackgroundWithBlock { (success: Bool, error: NSError!) -> Void in
            NSLog("reply saved")
            self.chatMessages.insert(chatReply, atIndex:0)
            self.textView.text = ""
            self.tableView.reloadData()
            if increment == true {
                self.geoPostObject?.incrementKey(GEO_POST.REPLIES)
                self.geoPostObject?.saveInBackgroundWithBlock(nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("inside ChatViewController, geoPostObject: \(geoPostObject![GEO_POST.BODY])")
        self.tableView.delegate      =   self
        self.tableView.dataSource    =   self
        
        self.tableView.estimatedRowHeight = 100.0
        self.tableView.rowHeight = UITableViewAutomaticDimension

        
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
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Create a query for places
        var query = PFQuery(className:CHAT_REPLY.CLASS_NAME)
        // Interested in locations near user.
        
        query.whereKey(CHAT_REPLY.PARENT, equalTo: geoPostObject?)
        query.orderByDescending("createdAt")
        
        // Limit what could be a lot of points.
        
        query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
            if error == nil {
                // The find succeeded.
                // Do something with the found objects
                
                NSLog("Successfully retrieved \(objects.count)")
                self.chatMessages = objects as [PFObject]
                self.chatMessages.append(self.geoPostObject!)
                //                NSLog("there are \(self.chatMessages.count) chat messages")
                self.tableView.reloadData()
                //                self.tableView.reloadInputViews()
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
        
        let df = NSDateFormatter()
        df.dateFormat = "MM-dd-yyyy hh:mm a"
        cell.postedAt.text = NSString(format: "%@", df.stringFromDate(chatMessage.createdAt))
        
        
        if(chatMessage.parseClassName! == GEO_POST.CLASS_NAME) {
            NSLog("rendering GeoPost")
            cell.body.text = chatMessage[GEO_POST.BODY] as? String
        } else {
            NSLog("Rendering ReplyPost")
            cell.body.text = chatMessage[CHAT_REPLY.BODY] as? String
            
            if chatMessage[CHAT_REPLY.REPLIED_BY] as? String == DEVICE_UUID {
                 cell.postedAt.text = "Replied by me: \(cell.postedAt.text!)"
            }
            
        }
        
        
        return cell
    }
    

    
    
}
