//
//  ReplyToAdViewController.swift
//  PAWall
//
//  Created by D on 1/25/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation

class ChatViewController: UIViewController {
    
    var geoPostObject:PFObject?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!    
    @IBOutlet weak var sendImage: UIImageView!
    
    @IBAction func goBackAction(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("inside ChatViewController, geoPostObject: \(geoPostObject![GEO_POST.BODY])")
        
    }

    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
}
