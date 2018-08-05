//
//  QuestionData.swift
//  PersonalityQuiz
//
//  Created by Tyler Gee on 6/25/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import Foundation

struct Question {
    var text: String
    var type: ResponseType
    var answers: [Answer]
}

enum ResponseType {
    case single, multiple, ranged
}

struct Answer {
    var text: String
    var type: MemeType
}

enum MemeType: Character {
    case b = "🅱️", quality = "👌", lit = "🔥", laughing = "😂"
    
    var description: String {
        switch self {
        case .b:
            return "You are cancer in it's purest form. You still dab, and on Reddit you aren't afraid to post the trashiest memes possible. You find memes such as E and Loss funny, and will continue to for years to come, which is depressing."
        case .quality:
            return "You have high standards and high weight. You are a qualified Memer, and you are a respectible person. The only thing you need to get is a life."
        case .lit:
            return "You roast people left and right, to the point where the school is about to suspend you for verbal assault. While you may drop lit burns, you sometimes trigger depression. You are able to expose people's biggest insecurities, at the cost of having any friends."
        case .laughing:
            return "You are a normie. You post pictures of Chuck Norris memes with three of what you are. You steal dead memes but spread them without a single coating of irony, and are a plague on the Elite Memers of the internet."
        }
    }
}


