//
//  Mentor.swift
//  MagnetWebsite
//
//  Created by Tyler Gee on 8/1/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation

class Mentor: Contact {
    var fieldOfStudy: String?
    var address: String?
    var phoneNumber: String?
    var description: String?
    
    init(name: String, email: String, personalEmail: String?, fieldOfStudy: String?, address: String?, phoneNumber: String?, description: String?) {
        self.fieldOfStudy = fieldOfStudy
        self.address = address
        self.phoneNumber = phoneNumber
        self.description = description
        super.init(name: name, email: email, personalEmail: personalEmail)
    }
}
