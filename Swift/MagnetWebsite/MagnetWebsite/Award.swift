//
//  Award.swift
//  MagnetWebsite
//
//  Created by Tyler Gee on 8/1/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation

class Award {
    var title: String
    var sponsor: String?
    var description: String?
    var money: Int?
    
    init(title: String, sponsor: String?, description: String?, money: Int?) {
        self.title = title
        self.sponsor = sponsor
        self.description = NSDebugDescriptionErrorKey
        self.money = money
    }
}
