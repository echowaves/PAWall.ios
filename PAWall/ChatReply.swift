//
//  ChatReply.swift
//  PAWall
//
//  Created by D on 1/25/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation

let CHAT_REPLY:ChatReply = ChatReply()

class ChatReply : BaseDataModel {
    let CLASS_NAME = "ChatReplies"
    let PARENT = "parentPost"
    let REPLIED_BY = "repliedBy"
    let BODY = "body"
    let LOCATION = "location"
}