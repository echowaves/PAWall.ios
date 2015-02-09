//
//  GeoPost.swift
//  PAWall
//
//  Created by D on 1/16/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation

let GPOST:GPost = GPost()

class GPost : BaseDataModel {
    let CLASS_NAME = "GPosts"
    let POSTED_BY = "postedBy"//uuid
    let BODY = "body"
    let WORDS = "words"
    let HASH_TAGS = "hashtags"
    let LOCATION = "location"
    let ACTIVE = "active"
    let REPLIES = "replies"
    
    class func createPost(
        body: String,
        location:PFGeoPoint,
        postedBy: String,
        succeeded:() -> (),
        failed:(error: NSError!) -> ())
        -> () {
        let postObject = PFObject(className:GPOST.CLASS_NAME)

        postObject[GPOST.BODY] = body
        postObject[GPOST.LOCATION] = location
        postObject[GPOST.ACTIVE] = true
        postObject[GPOST.POSTED_BY] = postedBy
        postObject[GPOST.REPLIES] = 0
        var error:NSErrorPointer = nil
        postObject.saveInBackgroundWithBlock {
            (success: Bool, error: NSError!) -> Void in
            if success {
                NSLog("Post Object created with id: \(postObject.objectId)")
                succeeded()
                
                // alerting my self
                GAlert.createAlertForMyPost(postObject)
                GAlert.createAlertsForMatchingBookmarks(postObject, location: location)
                
            } else {
                NSLog("Error creating Post Object")
                NSLog("%@", error)
                failed(error: error)
            }
        }
    }
    
}