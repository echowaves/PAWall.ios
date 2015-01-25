//
//  AdDetailView.swift
//  PAWall
//
//  Created by D on 1/19/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation

class AdDetailsViewController: UIViewController {
    
    var rawDistance = 0.0
    var adObject:PFObject?

    
    @IBOutlet weak var replyButton: UIButton!
    
    @IBOutlet weak var adDistance: UILabel!
    @IBOutlet weak var adDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adDistance.text = "This ad is \(rawDistance) miles away from you"
        adDescription.text = adObject?[GEO_AD.DESCRIPTION] as String
        
        if adObject?[GEO_AD.UUID] as NSString == DEVICE_UUID {
            replyButton.hidden = true
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        adDescription.setContentOffset(CGPoint.zeroPoint, animated: true)
    }
    
    @IBAction func replyToAd(sender: AnyObject) {
//        NSLog("calling phone number: \(adObject![GEO_AD.PHONE_NUMBER])")
//        UIApplication.sharedApplication().openURL(NSURL(string:"tel:\(adObject![GEO_AD.PHONE_NUMBER])")!)
        adObject?.incrementKey(GEO_AD.REPLIES)
        adObject?.saveInBackgroundWithBlock(nil)

    }
    
}