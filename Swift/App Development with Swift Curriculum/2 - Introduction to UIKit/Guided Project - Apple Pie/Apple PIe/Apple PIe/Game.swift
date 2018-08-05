//
//  Game.swift
//  Apple PIe
//
//  Created by Tyler Gee on 6/20/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import Foundation

struct Game {
    var word: String
    var incorrectMovesRemaining: Int
    var guessedLetters: [Character]
    var points: Int
    
    var formattedWord: String {
        var guessedWord = ""
        for letter in word {
            let playerDidGuessLetter = guessedLetters.contains(letter)
            if playerDidGuessLetter {
                guessedWord += "\(letter)"
            } else {
                guessedWord += "_"
            }
        }
        
        return guessedWord
    }
    
    mutating func playerGuessed(letter: Character) -> Bool {
        guessedLetters.append(letter)
        
        let didGuessIncorrectly = !word.contains(letter)
        if didGuessIncorrectly {
            incorrectMovesRemaining -= 1
        }
        
        return !didGuessIncorrectly // returns if the player guessed correctly or not
    }
}
