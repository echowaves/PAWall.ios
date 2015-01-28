//
//  AdDetailView.swift
//  PAWall
//
//  Created by D on 1/19/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation

class PostDetailsViewController: UIViewController {
    
    var rawDistance = 0.0
    var geoPostObject:PFObject?

    
    @IBOutlet weak var replyButton: UIButton!
    
    @IBOutlet weak var adDistance: UILabel!
    @IBOutlet weak var adDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adDistance.text = "This ad is \(rawDistance) miles away from you"
        adDescription.text = geoPostObject?[GEO_POST.BODY] as String
        
        if geoPostObject?[GEO_POST.UUID] as NSString == DEVICE_UUID {
            replyButton.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        adDescription.setContentOffset(CGPoint.zeroPoint, animated: true)
    }
    
    @IBAction func replyToAd(sender: AnyObject) {
//        NSLog("calling phone number: \(adObject![GEO_POST.PHONE_NUMBER])")
//        UIApplication.sharedApplication().openURL(NSURL(string:"tel:\(adObject![GEO_POST.PHONE_NUMBER])")!)
        geoPostObject?.incrementKey(GEO_POST.REPLIES)
        geoPostObject?.saveInBackgroundWithBlock(nil)

        //TODO: insert payment processing here
        
        self.performSegueWithIdentifier("show_chat", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "show_chat") {
            let chatViewController:ChatViewController = segue.destinationViewController as ChatViewController
            chatViewController.geoPostObject = self.geoPostObject
        }
    }

    
}