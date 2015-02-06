//
//  PAWallTabBarController.swift
//  PAWall
//
//  Created by D on 2/5/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation

class PAWallTabBarController: UITabBarController {
    override func viewDidLoad() {
        APP_DELEGATE.tabBarController = self
        APP_DELEGATE.getAlerts()
    }
}
