//
//  Athlete.swift
//  FavoriteAthlete
//
//  Created by Tyler Gee on 7/9/18.
//

import Foundation

struct Athlete {
    var name: String
    var age: String
    var league: String
    var team: String
    
    var description: String {
        return "\(name) is \(age) years old and plays for the \(team) in the \(league)."
    }
}
