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
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func goBackAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("inside ChatViewController, geoPostObject: \(geoPostObject![GEO_POST.BODY])")
        self.tableView.delegate      =   self
        self.tableView.dataSource    =   self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Create a query for places
        var query = PFQuery(className:REPLY_POST.CLASS_NAME)
        // Interested in locations near user.
        
        query.whereKey(REPLY_POST.PARENT, equalTo: geoPostObject?.objectId)
        query.orderByAscending("createdAt")
        
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
        df.dateFormat = "MM-dd-yyyy"
        cell.postedAt.text = NSString(format: "%@", df.stringFromDate(chatMessage.createdAt))
        
        if(chatMessage.parseClassName! == "GeoPosts") {
            NSLog("rendering GeoPost")
            cell.body.text = chatMessage[GEO_POST.BODY] as? String
        } else {
            NSLog("Rendering ReplyPost")
            cell.body.text = chatMessage[REPLY_POST.BODY] as? String
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }

    
//    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        println("You selected cell #\(indexPath.row)!")
//        self.performSegueWithIdentifier("myad_details", sender: self)
//    }

    
}