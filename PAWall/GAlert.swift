//
//  GAlert.swift
//  PAWall
//
//  Created by D on 2/1/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation

let GALERT:GAlert = GAlert()

class GAlert : BaseDataModel {
    let CLASS_NAME = "GAlerts"
    let PARENT_POST = "parentPost"
    let PARENT_CONVERSATION = "parentConversation" // only the alert that has paren conversation can be replied to
    let TARGET = "target" //uuid
    let ALERT_BODY = "alertBody"
    let POST_BODY = "postBody"
    let MESSAGE_BODY = "messageBody"
    
    
    class func createOrUpdateAlert(
//        parentPost: PFObject,
        parentConversation: PFObject,
        target: String,
        alertBody: String,
        chatReply: String) -> Void {
            var alert:PFObject = PFObject(className:GALERT.CLASS_NAME)
            var query = PFQuery(className:GALERT.CLASS_NAME)
//            query.whereKey(GALERT.PARENT_POST, equalTo: parentPost)
            query.whereKey(GALERT.PARENT_CONVERSATION, equalTo: parentConversation)
            query.whereKey(GALERT.TARGET, equalTo: target)
            query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    // The find succeeded.
                    // Do something with the found objects
                    
                    NSLog("Successfully retrieved \(objects.count) alerts")
                    if objects.count > 0 {
                        // update the found alert here
                        alert = objects[0] as PFObject
                        alert[GALERT.ALERT_BODY] = alertBody
                        alert[GALERT.MESSAGE_BODY] = chatReply
                        alert.saveEventually()
                    } else {
                        
                        let parentPost:PFObject = parentConversation[GCONVERSATION.PARENT_POST] as PFObject
                        parentPost.fetchIfNeeded()
                        // create new alert here
                        alert[GALERT.PARENT_POST] = parentPost
                        alert[GALERT.PARENT_CONVERSATION] = parentConversation
                        alert[GALERT.TARGET] = target
                        alert[GALERT.ALERT_BODY] = alertBody
                        alert[GALERT.POST_BODY] = parentPost[GPOST.BODY] as String
                        alert[GALERT.MESSAGE_BODY] = chatReply
                        alert.saveEventually()
                    }
                } else {
                    // Log details of the failure
                    NSLog("Error: %@ %@", error, error.userInfo!)
                    //                let alertMessage = UIAlertController(title: "Error", message: "Error retreiving alerts, try agin.", preferredStyle: UIAlertControllerStyle.Alert)
                    //                let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
                    //                alertMessage.addAction(ok)
                    //                self.presentViewController(alertMessage, animated: true, completion: nil)
                    
                }
            })
    }

    class func createAlertForMyPost(myPost: PFObject) -> Void {
        var alert:PFObject = PFObject(className:GALERT.CLASS_NAME)
        alert[GALERT.PARENT_POST] = myPost
        alert[GALERT.TARGET] = DEVICE_UUID
        alert[GALERT.ALERT_BODY] = "Post created by me:"
        alert[GALERT.POST_BODY] = myPost[GPOST.BODY] as String
        alert[GALERT.MESSAGE_BODY] = ""
        alert.saveEventually()
    }
    
    class func createAlertsForMatchingBookmarks(myPost: PFObject, location: PFGeoPoint) -> Void {
        
        myPost.fetch() // to make sure the hashtags are parsed and updated on the server side
        
        let hashTags:[String] = myPost[GPOST.HASH_TAGS] as [String]
        NSLog("there are \(hashTags.count) hashTags in new post")
        
        for hashTag in hashTags {
            // here alert all the phones that have bookmarks matching my new post
            // first find all bookmarks that match new post, repeat for ever hash tag in original post
            var gBookmark:PFObject = PFObject(className:GBOOKMARK.CLASS_NAME)
            var query:PFQuery = PFQuery(className:GBOOKMARK.CLASS_NAME)
            query.whereKey(GBOOKMARK.LOCATION, nearGeoPoint:location)
            query.whereKey(GBOOKMARK.HASH_TAGS, containsAllObjectsInArray: [hashTag])
            query.whereKey(GBOOKMARK.CREATED_BY, notEqualTo: DEVICE_UUID)// exclude my device bookmarks
            
            query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    // The find succeeded.
                    NSLog("Successfully retrieved \(objects.count) bookmarks for hashTag:\(hashTag)")
                    //                                    finally create an alert here for each bookmark
                    for bookmark in objects {
                        //first create a convo, then create a corresponding alert
                        let newConversation:PFObject =
                        GConversation.createConversation(myPost,
                            myLocation: location,
                            replier: bookmark[GBOOKMARK.CREATED_BY] as String)
                        
                        // create alert for post owner
                        var alert:PFObject = PFObject(className:GALERT.CLASS_NAME)
                        alert[GALERT.PARENT_POST] = myPost
                        alert[GALERT.PARENT_CONVERSATION] = newConversation
                        alert[GALERT.TARGET] = bookmark[GBOOKMARK.CREATED_BY] as String
                        alert[GALERT.ALERT_BODY] = "New Post matching my bookmark:"
                        alert[GALERT.POST_BODY] = myPost[GPOST.BODY] as String
                        alert[GALERT.MESSAGE_BODY] = ""
                        alert.saveEventually()
                    }
                    
                }
            })
        }

    }
    
    
    class func findMyAlerts(
        target: String,
        succeeded:(results:[PFObject]) -> (),
        failed:(error: NSError!) -> ()
        ) -> () {
            
            var query = PFQuery(className:GALERT.CLASS_NAME)
            
            query.whereKey(GALERT.TARGET, equalTo: target)
            query.orderByDescending("updatedAt")
            
            // Limit what could be a lot of points.
            
            query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
                if error == nil {
                    // The find succeeded.
                    // Do something with the found objects
                    
                    NSLog("Successfully retrieved \(objects.count) bookmarks")
                    succeeded(results: objects as [PFObject])
                    
                } else {
                    // Log details of the failure
                    NSLog("Error: %@ %@", error, error.userInfo!)
                    failed(error: error)
                }
            })
    }
    


}
