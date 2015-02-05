//
//  BookmarkTableViewCell.swift
//  PAWall
//
//  Created by D on 2/4/15.
//  Copyright (c) 2015 echowaves. All rights reserved.
//

import Foundation

class BookmarkTableViewCell: UITableViewCell {
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    @IBOutlet weak var bookmarkText: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
}