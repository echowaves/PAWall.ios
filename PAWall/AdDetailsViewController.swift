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

    
    @IBOutlet weak var adDistance: UILabel!
    @IBOutlet weak var adDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adDistance.text = "This ad is \(rawDistance) miles away from you"
        adDescription.text = adObject?[CLASSIFIED_AD.DESCRIPTION] as String
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        adDescription.setContentOffset(CGPoint.zeroPoint, animated: true)
    }
    
    @IBAction func replyToAd(sender: AnyObject) {
        NSLog("calling phone number: \(adObject![CLASSIFIED_AD.PHONE_NUMBER])")
        UIApplication.sharedApplication().openURL(NSURL(string:"tel:\(adObject![CLASSIFIED_AD.PHONE_NUMBER])")!)

    }
    
}