//
//  MagnetProject5.swift
//  MagnetWebsite
//
//  Created by Tyler Gee on 8/1/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation

class MagnetProject {
    var title: String
    var description: String
    var groupMembers: [Magneto]
    var awards: [Award]?
    var researchPaper: URL?
    
    init(title: String, description: String, groupMembers: [Magneto], awards: [Award]?, researchPaper: URL?) {
        self.title = title
        self.description = description
        self.groupMembers = groupMembers
        self.awards = awards
        self.researchPaper = researchPaper
    }
}
