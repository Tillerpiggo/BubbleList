//
//  Contact.swift
//  MagnetWebsite
//
//  Created by Tyler Gee on 8/1/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation

class Contact {
    var name: String
    var email: String
    var personalEmail: String?
    
    init(name: String, email: String, personalEmail: String?) {
        self.name = name
        self.email = email
        self.personalEmail = personalEmail
    }
}
