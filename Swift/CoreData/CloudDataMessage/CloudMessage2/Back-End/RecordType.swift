//
//  RecordType.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/15/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation

enum RecordType: String {
    case conversation = "Conversation"
    case message = "Message"
    
    var cloudValue: String {
        switch self {
        case .conversation:
            return "Conversation"
        case .message:
            return "Message"
        }
    }
    
    var coreDataValue: String {
        switch self {
        case .conversation:
            return "Conversation"
        case .message:
            return "Message"
        }
    }
}
