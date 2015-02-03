//
//  GBookmark.swift
//  PAWall
//
//  Created by D on 2/3/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation

let GBOOKMARK:GBookmark = GBookmark()

class GBookmark : BaseDataModel {
    let CLASS_NAME = "GBookmarks"
    let LOCATION = "location"
    let SEARCH_TEXT = "searchText"
    let HASH_TAGS = "hashtags"
    let CREATED_BY = "createdBy"//uuid
}