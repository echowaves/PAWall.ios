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
    let POSTED_BY = "postedBy"
    let BODY = "body"
    let WORDS = "words"
    let HASH_TAGS = "hashtags"
    let LOCATION = "location"
    let ACTIVE = "active"
    let REPLIES = "replies"
}