//
//  StringHelpers.swift
//  CloudMessage
//
//  Created by Tyler Gee on 7/30/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation

extension String {
    static func fromCharacters(_ characters: [Character]) -> String {
        var newString = ""
        
        for character in characters {
            newString.append(character)
        }
        
        return newString
    }
}
