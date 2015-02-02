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
}