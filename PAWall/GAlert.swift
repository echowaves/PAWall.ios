//
//  GAlert.swift
//  PAWall
//
//  Created by D on 2/1/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation

let GALERT:GAlert = GAlert()

class GAlert : BaseDataModel {
    let CLASS_NAME = "GAlerts"
    let PARENT_POST = "parentPost"
    let TARGET = "target" //uuid
    let ALERT_BODY = "alertBody"
    let POST_BODY = "postBody"
    let MESSAGE_BODY = "messageBody"
}