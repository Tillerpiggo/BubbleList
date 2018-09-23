//
//  Magneto.swift
//  MagnetWebsite
//
//  Created by Tyler Gee on 8/1/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation

class Magneto: Contact {
    var nickname: String?
    var graduationYear: Int
    var gradeLevel: GradeLevel {
        let currentYear = 2018 // get current year
        
        switch graduationYear - currentYear {
        case 4:
            return .freshman
        case 3:
            return .sophomore
        case 2:
            return .junior
        case 1:
            return .senior
        default:
            return .freshman
        }
    }
    
    init(name: String, email: String, personalEmail: String?, nickname: String?, graduationYear: Int) {
        self.nickname = nickname
        self.graduationYear = graduationYear
        super.init(name: name, email: email, personalEmail: personalEmail)
    }
    
}

enum GradeLevel: String {
    case freshman = "Freshman"
    case sophomore = "Sophomore"
    case junior = "Junior"
    case senior = "Senior"
    
    var int: Int {
        switch self {
        case .freshman:
            return 0
        case .sophomore:
            return 1
        case .junior:
            return 2
        case .senior:
            return 3
        }
    }
}
