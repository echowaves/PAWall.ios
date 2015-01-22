//
//  CreateAdViewController.swift
//  PAWall
//
//  Created by D on 1/12/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation


class CreateAdViewController: UIViewController {
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var adDescription: UITextView!
    
    @IBAction func unwindToCreateAd (segue : UIStoryboardSegue) {
        NSLog("CreateAd seque from segue id: \(segue.identifier)")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let credential:NSURLCredential = BaseDataModel.getStoredCredential() {
            
            if credential.user != "" {
                phoneNumber.text  = credential.user
            }
        }
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if phoneNumber.text == "" {
            phoneNumber.becomeFirstResponder()
        } else {
            adDescription.becomeFirstResponder()
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        NSLog("----------------seguiing")
        
        // Make sure your segue name in storyboard is the same as this line
        if (segue.identifier == "CreateAdLocation")
        {
            NSLog("----calling prepareForSegue CreateAdLocation")
            
            var svc = segue.destinationViewController as CreateAdLocationViewController
            
            svc.phoneNumber = self.phoneNumber.text
            svc.adDescription = self.adDescription.text
            
            BaseDataModel.storeCredential(phoneNumber.text, uuid: DEVICE_UUID)
        }
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if (identifier == "CreateAdLocation") {
            if phoneNumber.text == "" || phoneNumber.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < 5 {
                let alertMessage = UIAlertController(title: "Warning", message: "Enter phone number. Phone number will only be used to contact you regarding your advertisement.", preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
                alertMessage.addAction(ok)
                presentViewController(alertMessage, animated: true, completion: nil)
                return false
            }
            if adDescription.text == "" || adDescription.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) < 10 {
                let alertMessage = UIAlertController(title: "Warning", message: "You can not post empty Ad. Provide Ad description ad try again.", preferredStyle: UIAlertControllerStyle.Alert)
                let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
                alertMessage.addAction(ok)
                presentViewController(alertMessage, animated: true, completion: nil)
                return false
            }
            
        }
        return true
    }
    
}
