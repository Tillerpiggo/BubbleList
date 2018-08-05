//
//  ViewController.swift
//  Apple PIe
//
//  Created by Tyler Gee on 6/20/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Variables and Constants:
    var listOfWords: [String]  = ["pig", "starcraft", "minecraft", "magnet", "kerby", "apple", "imac", "iphone", "ipad", "apple pencil", "xcode", "app development with swift"]
    
    // If you win or lose ("set" totalWins or totalLosses), then start a new round
    var totalWins = 0 {
        didSet {
            newRound()
        }
    }
    var totalLosses = 0 {
        didSet {
            newRound()
        }
    }
    
    let incorrectMovesAllowed = 7
    var currentGame: Game!
    
    
    // IBOutlets:
    @IBOutlet weak var treeImageView: UIImageView!
    @IBOutlet weak var correctWordLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet var letterButtons: [UIButton]!

    
    // ViewDidLoad:
    override func viewDidLoad() {
        super.viewDidLoad()
        newRound()
    }
    
    // Functions:
    func newRound() {
        if !listOfWords.isEmpty {
            // Select a new word
            let newWord = listOfWords.removeFirst() // returns the first word in the list
        
            // Set the current game with that new word and with 0 points
            currentGame = Game(word: newWord, incorrectMovesRemaining: incorrectMovesAllowed, guessedLetters: [], points: 0)
        
            // Update the UI
            updateUI()
        
            // Enable all of the letter buttons again
            enableLetterButtons(true)
        } else { // if the list of words is empty
            // disable all of the buttons
            enableLetterButtons(false)
        }
    }
    
    func enableLetterButtons(_ enable: Bool) {
        for button in letterButtons {
            button.isEnabled = enable
        }
    }
    
    func updateUI() {
        // Display the partially revealed word based on the player's guesses
        correctWordLabel.text = addSpacing(to: currentGame.formattedWord)
        
        // Update the score to display wins and losses
        scoreLabel.text = "Wins: \(totalWins), Losses: \(totalLosses)"
        
        // Update the point label to display points
        pointLabel.text = "Points: \(currentGame.points)"
        
        // Update the tree to have less apples when there are fewer incorrect moves remaining
        treeImageView.image = UIImage(named: "Tree \(currentGame.incorrectMovesRemaining)") // Tree 0 has no apples
    }
    
    func addSpacing(to word: String) -> String {
        // Make a list of letters that will be joined
        var letters = [String]()
        
        // Iterate through each letter in the word and add it to letters
        for letter in word {
            letters.append(String(letter))
        }
        
        // Add a space to separate each letter
        let wordWithSpacing = letters.joined(separator: " ")
        
        return wordWithSpacing
    }
    
    func updateGameState() {
        let didLoseGame = currentGame.incorrectMovesRemaining == 0 // If you've missed more times than allowed
        let didWinGame = currentGame.word == currentGame.formattedWord // If you've completely filled out the word
        
        if didLoseGame {
            totalLosses += 1
        } else if didWinGame {
            totalWins += 1
        } else {
            updateUI()
        }
    }
    
    // IBActions:
    @IBAction func buttonTapped(_ sender: UIButton) {
        // Turn off the button that is tapped
        sender.isEnabled = false
        
        // Determine the letter that was selected (in String format)
        let letterString = sender.title(for: .normal)!
        
        // Turn that String into a lowercase Character
        let letter: Character = Character(letterString.lowercased())
        
        // Guess that letter and change points depending on if you guessed correctly
        let didGuessCorrectly = currentGame.playerGuessed(letter: letter)
        if didGuessCorrectly {
            currentGame.points += 10
        } else {
            currentGame.points -= 5
        }
        
        // Update the game state (this also updates the UI if you don't win or lose)
        updateGameState()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

