//
//  RecordType.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 10/25/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation

enum RecordType: String {
    case `class` = "Class"
    case assignment = "Assignment"
    
    var cloudValue: String {
        switch self {
        case .class:
            return "Class"
        case .assignment:
            return "Assignment"
        }
    }
    
    var coreDataValue: String {
        switch self {
        case .class:
            return "Class"
        case .assignment:
            return "Assignment"
        }
    }
}

