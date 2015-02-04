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
    let TARGET = "target" //uuid
    let ALERT_BODY = "alertBody"
    let POST_BODY = "postBody"
    let MESSAGE_BODY = "messageBody"
    
    
    class func createOrUpdateAlert(parentPost: PFObject,
        target: String,
        alertBody: String,
        chatReply: String) -> Void {
            var alert:PFObject = PFObject(className:GALERT.CLASS_NAME)
            var query = PFQuery(className:GALERT.CLASS_NAME)
            query.whereKey(GALERT.PARENT_POST, equalTo: parentPost)
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
                        // create new alert here
                        alert[GALERT.PARENT_POST] = parentPost
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
}