//
//  ResultsViewController.swift
//  PersonalityQuiz
//
//  Created by Tyler Gee on 6/25/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController {
    
    @IBOutlet weak var resultAnswerLabel: UILabel!
    @IBOutlet weak var resultDescriptionLabel: UILabel!
    
    
    var responses: [Answer]!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculatePersonalityResult()
    }
    
    
    func calculatePersonalityResult() {
        var frequencyOfAnswers: [Type: Int] = [:]
        let responseTypes = responses.map { $0.type }
        
        for response in responseTypes {
            // add 1 if the key already exists in the dictionary, otherwise add the key to the dictionary and set the value to 1
            frequencyOfAnswers[response] = (frequencyOfAnswers[response] ?? 0) + 1
        }
        
        // get the key value of the first in a list sorted by highest frequency
        let mostCommonAnswer = frequencyOfAnswers.sorted { $0.1 > $1.1 }.first!.key
        
        resultAnswerLabel.text = "You are a \(mostCommonAnswer.rawValue)!"
        resultDescriptionLabel.text = mostCommonAnswer.description
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
