//
//  CreateAdViewController.swift
//  PAWall
//
//  Created by D on 1/12/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation


class CreatePostViewController: UIViewController {
    
    
    @IBOutlet weak var adDescription: UITextView!
        
    @IBAction func unwindToCreateAd (segue : UIStoryboardSegue) {
        NSLog("CreatePost seque from segue id: \(segue.identifier)")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                
                GPost.createPost(
                    self.adDescription!.text,
                    location: APP_DELEGATE.getCurrentLocation()!,
                    postedBy: DEVICE_UUID,
                    succeeded: { () -> () in
                        self.dismissViewControllerAnimated(false, completion: nil)
                    },
                    failed: { (error) -> () in
                        let alertMessage = UIAlertController(title: "Error", message: "Unable to post. Try again.", preferredStyle: UIAlertControllerStyle.Alert)
                        let ok = UIAlertAction(title: "OK", style: .Default, handler:nil)
                        alertMessage.addAction(ok)
                        self.presentViewController(alertMessage, animated: true, completion: nil)
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
