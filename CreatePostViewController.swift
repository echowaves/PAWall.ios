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
                    } else {
                        let alertMessage = UIAlertController(title: "Error", message: "Unable to post. Try again.", preferredStyle: UIAlertControllerStyle.Alert)
                        let ok = UIAlertAction(title: "OK", style: .Default, handler:nil)
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
