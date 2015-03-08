//
//  SearchPostsViewController.swift
//  PAWall
//
//  Created by D on 1/12/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation

class HomeViewControler: UIViewController {
    
    @IBAction func unwindToHome (segue : UIStoryboardSegue) {
        NSLog("SearchPosts seque from segue id: \(segue.identifier)")
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        NSLog("----------------seguiing")
        
        // Make sure your segue name in storyboard is the same as this line
        if (segue.identifier == "myNewPostSegue")
        {
            NSLog("----calling prepareForSegue myNewPostSegue")
        }
    }
    
    
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if APP_DELEGATE.getCurrentLocation() != nil {
            return true
        } else {
            let alertMessage = UIAlertController(title: "Error", message: "Enable GPS, or wait few seconds for location to be detected and try again.", preferredStyle: UIAlertControllerStyle.Alert)
            let ok = UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in})
            alertMessage.addAction(ok)
            presentViewController(alertMessage, animated: true, completion: nil)
        }
        return false
    }

}
