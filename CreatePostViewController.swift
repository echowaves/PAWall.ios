//
//  CreateAdViewController.swift
//  PAWall
//
//  Created by D on 1/12/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation


class CreatePostViewController: UIViewController {
    
    
    @IBOutlet weak var locationLable: UILabel!
    @IBOutlet weak var adDescription: UITextView!
    
    var currentLocation:PFGeoPoint?
    
    @IBAction func unwindToCreateAd (segue : UIStoryboardSegue) {
        NSLog("CreatePost seque from segue id: \(segue.identifier)")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                
                self.locationLable.text = "Current Location Detected"
            } else {
                self.locationLable.text = "Unable to detect current location. Make sure to enable GPS."
                self.locationLable.backgroundColor = UIColor.redColor()
                self.adDescription.editable = false
            }
            
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        adDescription.becomeFirstResponder()
    }
    
    
    @IBAction func savePost(sender: AnyObject) {
        if adDescription.text == "" || adDescription.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < 10 {
            let alertMessage = UIAlertController(title: "Warning", message: "Your post can't be empty. Try again.", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
            alertMessage.addAction(ok)
            presentViewController(alertMessage, animated: true, completion: nil)
        } else if adDescription.text.rangeOfString("#") == nil {
            let alertMessage = UIAlertController(title: "Warning", message: "You post can not be saved without any #hash_tags. You post will not be searchable unless it has #hash_tags. Add some #has_tags and try again.", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
            alertMessage.addAction(ok)
            presentViewController(alertMessage, animated: true, completion: nil)
        } else {
            let alertMessage = UIAlertController(title: nil, message: "You Post will be saved now.", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
                var gPost = PFObject(className:GPOST.CLASS_NAME)
//                gPost[GPOST.DEVICE_TOKEN] = DEVICE_TOKEN
                gPost[GPOST.BODY] = self.adDescription!.text
                gPost[GPOST.LOCATION] = self.currentLocation?
                gPost[GPOST.ACTIVE] = true
                gPost[GPOST.POSTED_BY] = DEVICE_UUID
                gPost[GPOST.REPLIES] = 0
                var error:NSErrorPointer = nil
                gPost.saveEventually({ (success: Bool, error: NSError!) -> Void in
                    if success {
                        self.dismissViewControllerAnimated(false, completion: nil)
                        
                        // alerting my self
                        var alert:PFObject = PFObject(className:GALERT.CLASS_NAME)
                        alert[GALERT.PARENT_POST] = gPost
                        alert[GALERT.TARGET] = DEVICE_UUID
                        alert[GALERT.ALERT_BODY] = "Post created by me:"
                        alert[GALERT.POST_BODY] = gPost[GPOST.BODY] as String
                        alert[GALERT.MESSAGE_BODY] = ""
                        alert.saveEventually()
                        

                        gPost.fetch() // have to make sure we fetch hashtags array that is generated on the server side
                        
                        let hashTags:[String] = gPost[GPOST.HASH_TAGS] as [String]
                        NSLog("there are \(hashTags.count) hashTags in new post")
                        
                        for hashTag in hashTags {
                            // here alert all the phones that have bookmarks matching my new post
                            // first find all bookmarks that match new post, repeat for ever hash tag in original post
                            var gBookmark:PFObject = PFObject(className:GBOOKMARK.CLASS_NAME)
                            var query:PFQuery = PFQuery(className:GBOOKMARK.CLASS_NAME)
                            query.whereKey(GBOOKMARK.LOCATION, nearGeoPoint:self.currentLocation)
                            query.whereKey(GBOOKMARK.HASH_TAGS, containsAllObjectsInArray: [hashTag])
                            query.whereKey(GBOOKMARK.CREATED_BY, notEqualTo: DEVICE_UUID)// exclude my device bookmarks
                                
                            query.findObjectsInBackgroundWithBlock({ (objects: [AnyObject]!, error: NSError!) -> Void in
                                if error == nil {
                                    // The find succeeded.
                                    // Do something with the found objects
                                    
                                    NSLog("Successfully retrieved \(objects.count) bookmarks for hashTag:\(hashTag)")
//                                    finally create an alert here for each bookmark
                                    
                                    for bookmark in objects {
                                        // create or update alert for post owner
                                        GAlert.createOrUpdateAlert(
                                            gPost,
                                            target: bookmark[GBOOKMARK.CREATED_BY] as String,
                                            alertBody: "New Post matching my bookmark:",
                                            chatReply: "")
                                    }
                                    
                                    
                                } else {
                                    // Log details of the failure
                                    NSLog("Error: %@ %@", error, error.userInfo!)
                                }
                            })

                        } // for hashTag
                        

                        
                        
                    } else {
                        let alertMessage = UIAlertController(title: "Error", message: "Unable to post. Try again.", preferredStyle: UIAlertControllerStyle.Alert)
                        let ok = UIAlertAction(title: "OK", style: .Default, handler:nil)
                        alertMessage.addAction(ok)
                        self.presentViewController(alertMessage, animated: true, completion: nil)
                    }
                })
                
                
            })
            let cancel = UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
            })
            alertMessage.addAction(cancel)
            alertMessage.addAction(ok)
            presentViewController(alertMessage, animated: true, completion: nil)
            
        }
    }
}
