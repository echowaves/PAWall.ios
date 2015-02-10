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
    let PARENT_POST = "parentPost"
    let PARTICIPANTS = "participants" //array of uuid's
    let CHARGES_APPLIED = "chargesApplied"
    let MESSAGES_COUNT = "messagesCount"
    let LOCATION = "location"
    
    
    class func createConversation(myPost: PFObject, myLocation: PFGeoPoint, replier: String ) -> PFObject {
        let gConversation:PFObject = PFObject(className:GCONVERSATION.CLASS_NAME)
        gConversation[GCONVERSATION.PARENT_POST] = myPost
        gConversation[GCONVERSATION.PARTICIPANTS] = [myPost[GPOST.POSTED_BY] as String, replier]
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
            convQuery.whereKey(GCONVERSATION.PARENT_POST, equalTo: postObject)
            convQuery.whereKey(GCONVERSATION.PARTICIPANTS, containsAllObjectsInArray: [DEVICE_UUID])

            let objects:[AnyObject] = convQuery.findObjects()
            // if no conversation is yet created, create one and also create a first message from the post
            if objects.count == 0 {
                let conversation:PFObject = GConversation.createConversation(
                    postObject,
                    myLocation: myLocation,
                    replier: DEVICE_UUID)
                GMessage.createFirstMessage(conversation, parentPost: postObject, location: myLocation)
                NSLog("findOrCreateMyConversation", "found conversation and returning")
                return conversation
            } else {
                let conversation:PFObject = objects[0] as PFObject
                GMessage.createFirstMessage(conversation, parentPost: postObject, location: myLocation)
                NSLog("findOrCreateMyConversation", "creating conversation and returning")
                return conversation
            }
    }


    class func otherParticipantInMyConversation(conversation: PFObject) -> String {
        if (conversation[GCONVERSATION.PARTICIPANTS] as [String])[0] == DEVICE_UUID {
            return (conversation[GCONVERSATION.PARTICIPANTS] as [String])[1] 
        } else {
            return (conversation[GCONVERSATION.PARTICIPANTS] as [String])[0]
        }
    }
}