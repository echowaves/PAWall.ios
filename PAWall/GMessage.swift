//
//  ChatReply.swift
//  PAWall
//
//  Created by D on 1/25/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation

let GMESSAGE:GMessage = GMessage()

class GMessage : BaseDataModel {
    let CLASS_NAME = "GMessages"
    let PARENT = "parentConversation"
    let REPLIED_BY = "repliedBy"//uuid
    let BODY = "body"
    let LOCATION = "location"
    
    class func createMessage(
        parentConversation: PFObject,
        repliedBy: String,
        body: String,
        location: PFGeoPoint
        ) -> Void {
            let gMessage:PFObject = PFObject(className:GMESSAGE.CLASS_NAME)
            gMessage[GMESSAGE.PARENT] = parentConversation
            gMessage[GMESSAGE.REPLIED_BY] = repliedBy
            gMessage[GMESSAGE.BODY] = body
            gMessage[GMESSAGE.LOCATION] = location
            gMessage.save()
            parentConversation.incrementKey(GCONVERSATION.MESSAGES_COUNT)
            parentConversation.saveEventually()
    }
    
    
    class func createFirstMessage(
        parentConversation: PFObject,
        parentPost: PFObject,
        location: PFGeoPoint
        ) -> Void {
            if parentConversation[GCONVERSATION.MESSAGES_COUNT] as Int == 0 {
                GMessage.createMessage(
                    parentConversation,
                    repliedBy: parentPost[GPOST.POSTED_BY] as String,
                    body: parentPost[GPOST.BODY] as String,
                    location: location)
            }
    }
}