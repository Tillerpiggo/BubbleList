//
//  String+Helpers.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/10/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation

extension String {
    var firstLetterCapitalized: String {
        let string = self
        let first = String(string.first!).capitalized
        let other = string.dropFirst()
        
        return first + other
    }
}
