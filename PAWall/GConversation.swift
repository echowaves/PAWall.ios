//
//  GConversation.swift
//  PAWall
//
//  Created by D on 1/31/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation

let GCONVERSATION:GConversation = GConversation()

class GConversation : BaseDataModel {
    let CLASS_NAME = "GConversations"
    let PARENT = "parentPost"
    let CREATED_BY = "createdBy" //uuid
    let CHARGES_APPLIED = "chargesApplied"
    let MESSAGES_COUNT = "messagesCount"
    let LOCATION = "location"
    
    
    class func createConversation(myPost: PFObject, myLocation: PFGeoPoint, target: String ) -> PFObject {
        let gConversation:PFObject = PFObject(className:GCONVERSATION.CLASS_NAME)
        gConversation[GCONVERSATION.PARENT] = myPost
        gConversation[GCONVERSATION.CREATED_BY] = target
        gConversation[GCONVERSATION.LOCATION] = myLocation
        gConversation[GCONVERSATION.MESSAGES_COUNT] = 0
        gConversation.save()
        return gConversation
    }
    
    class func findOrCreateMyConversation(
        postObject: PFObject,
        myLocation: PFGeoPoint
        ) -> PFObject? {
            let convQuery = PFQuery(className:GCONVERSATION.CLASS_NAME)
            convQuery.whereKey(GCONVERSATION.PARENT, equalTo: postObject)
            convQuery.whereKey(GCONVERSATION.CREATED_BY, equalTo: DEVICE_UUID)
            
            let objects:[AnyObject] = convQuery.findObjects()
            // if no conversation is yet created, create one and also create a first message from the post
            if objects.count == 0 {
                let conversation:PFObject = GConversation.createConversation(
                    postObject,
                    myLocation: myLocation,
                    target: DEVICE_UUID)
                GMessage.createFirstMessage(conversation, parentPost: postObject, location: myLocation)
                return conversation
            } else {
                let conversation:PFObject = objects[0] as PFObject
                GMessage.createFirstMessage(conversation, parentPost: postObject, location: myLocation)
                return conversation
            }
    }
}