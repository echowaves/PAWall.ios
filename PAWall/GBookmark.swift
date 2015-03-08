//
//  GBookmark.swift
//  PAWall
//
//  Created by D on 2/3/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation

let GBOOKMARK:GBookmark = GBookmark()

class GBookmark : BaseDataModel {
    let CLASS_NAME = "GBookmarks"
    let LOCATION = "location"
    let SEARCH_TEXT = "searchText"
    let HASH_TAGS = "hashtags"
    let CREATED_BY = "createdBy"//uuid
    
    
    
    class func createBookmark(myBookmark: String) -> Void {

    var gBookmark:PFObject = PFObject(className:GBOOKMARK.CLASS_NAME)
    var query:PFQuery = PFQuery(className:GBOOKMARK.CLASS_NAME)
    query.whereKey(GBOOKMARK.SEARCH_TEXT, equalTo: myBookmark)
    query.whereKey(GBOOKMARK.CREATED_BY, equalTo: DEVICE_UUID)
    
    query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
    if error == nil {
    // The find succeeded.
    // Do something with the found objects
    
    NSLog("Successfully retrieved \(objects.count) alerts")
    if objects.count > 0 {
    // update the found alert here
    gBookmark = objects[0] as PFObject
    } else {
    gBookmark[GBOOKMARK.SEARCH_TEXT] = myBookmark
    gBookmark[GBOOKMARK.CREATED_BY] = DEVICE_UUID
    }
    gBookmark[GBOOKMARK.LOCATION] = APP_DELEGATE.getCurrentLocation()!
    gBookmark.saveEventually()
    
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
