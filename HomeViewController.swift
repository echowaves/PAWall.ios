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

}
