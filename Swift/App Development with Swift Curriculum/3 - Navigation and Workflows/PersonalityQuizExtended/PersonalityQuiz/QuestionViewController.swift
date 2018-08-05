//
//  QuestionViewController.swift
//  PersonalityQuiz
//
//  Created by Tyler Gee on 6/25/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit
import Foundation

class QuestionViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    
    
    @IBOutlet weak var singleStackView: UIStackView!
    
    
    @IBOutlet weak var multipleStackView: UIStackView!
    @IBOutlet weak var multipleSubmitAnswerButton: UIButton!
    
    
    @IBOutlet weak var rangedStackView: UIStackView!
    @IBOutlet weak var rangedLabel1: UILabel!
    @IBOutlet weak var rangedLabel2: UILabel!
    @IBOutlet weak var rangedSlider: UISlider!
    
    
    @IBOutlet weak var questionProgressView: UIProgressView!
    
    
    
    var animalQuestions: [Question] = [
        Question(text: "Which food do you like the most?",
                 type: .single,
                 answers: [
                    Answer(text: "Steak", type: .dog),
                    Answer(text: "Fish", type: .cat),
                    Answer(text: "Carrots", type: .rabbit),
                    Answer(text: "Corn", type: .turtle)
            ]),
        Question(text: "Which activities do you enjoy?",
                 type: .multiple,
                 answers: [
                    Answer(text: "Swimming", type: .turtle),
                    Answer(text: "Sleeping", type: .cat),
                    Answer(text: "Cuddling", type: .rabbit),
                    Answer(text: "Eating", type: .dog)
            ]),
        Question(text: "How much do you enjoy car rides?",
                 type: .ranged,
                 answers: [
                    Answer(text: "I dislike them", type: .cat),
                    Answer(text: "I get a little nervous", type: .rabbit),
                    Answer(text: "I barely notice them", type: .turtle),
                    Answer(text: "I love them", type: .dog)
            ])
    ]
    
    var memeQuestions: [Question] = [
        Question(text: "Which meme do you like the most?",
                 type: .single,
                 answers: [
                    Answer(text: "YEEEEEEE", type: .b),
                    Answer(text: "Only the freshest", type: .quality),
                    Answer(text: "Ur mum gæ", type: .lit),
                    Answer(text: "Vine Compilations", type: .laughing),
                    Answer(text: "E", type: .laughing)
                    ]),
        Question(text: "Which of the following activities do you partake in on an above-average basis?",
                 type: .multiple,
                 answers: [
                    Answer(text: "Sleeping", type: .quality),
                    Answer(text: "Roasting peeps", type: .lit),
                    Answer(text: "Looking at memes on YouTube", type: .laughing)
            ]),
        Question(text: "How much do you support Communism?",
                 type: .ranged,
                 answers: [
                    Answer(text: "It's trash", type: .lit),
                    Answer(text: "Communism is bad and not as effective as Capitalism", type: .laughing),
                    Answer(text: "Communism is good, but not well implemented", type: .quality),
                    Answer(text: "Revolution, now!", type: .b)
            ])
    ]
    
    var questions: [Question]!
    
    var quizType: QuizType!
    
    var questionIndex = 0
    
    var answersChosen: [Answer] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if quizType == .meme {
            questions = memeQuestions
        } else if quizType == .animal {
            questions = animalQuestions
        }
        
        shuffleQuestions()
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // If you're returning from the results view controller, disable everything
        if questionIndex >= 2 {
            for subview in singleStackView.subviews {
                disable(subview)
            }
            for subview in multipleStackView.subviews {
                disable(subview)
            }
            for subview in rangedStackView.subviews {
                disable(subview)
            }
        }
    }
    
    func disable(_ subview: UIView) {
        if let subview = subview as? UISwitch {
            subview.isEnabled = false
        } else if let subview = subview as? UIButton {
            subview.isEnabled = false
        } else if let subview = subview as? UISlider {
            subview.isEnabled = false
        } else if let subviewStack = subview as? UIStackView {
            for subview in subviewStack.subviews {
                disable(subview)
            }
        }
    }
    
    
    @objc func singleAnswerButtonPressed(_ sender: UIButton) {
        let currentAnswers = questions[questionIndex].answers
        
        var answerIndex: Int?
        
        for (index, subview) in singleStackView.subviews.enumerated() {
            if sender == subview as? UIButton {
                answerIndex = index
            }
        }
        
        if let answerIndex = answerIndex {
            answersChosen.append(currentAnswers[answerIndex])
        }
        
        nextQuestion()
    }
    
    
    @IBAction func multipleAnswerButtonPressed(_ sender: Any) {
        let currentAnswers = questions[questionIndex].answers
        print("Number of current answers: \(currentAnswers.count)")
        
        for (index, subview) in multipleStackView.subviews.enumerated() {
            if let multipleSwitch = subview.subviews.last as? UISwitch {
                if multipleSwitch.isOn {
                    answersChosen.append(currentAnswers[index - 1])
                }
            }
        }
        
        nextQuestion()
    }
    
    
    @IBAction func rangedAnswerButtonPressed(_ sender: Any) {
        let currentAnswers = questions[questionIndex].answers
        // 0...0.166 = index 0
        // 0.166...0.5 = index 1
        // 0.5...0.83 = index 2
        // 0.83...1 = index 3
        let index = Int(round(rangedSlider.value * Float(currentAnswers.count - 1)))
        
        answersChosen.append(currentAnswers[index])
        
        nextQuestion()
    }
    
    func shuffleQuestions() {
        questions.shuffle()
        for questionIndex in 0..<questions.count {
            if questions[questionIndex].type != .ranged {
                questions[questionIndex].answers.shuffle()
            }
        }
    }
    
    
    func nextQuestion() {
        questionIndex += 1
        
        if questionIndex < questions.count {
            updateUI()
        } else {
            performSegue(withIdentifier: "ResultsSegue", sender: nil)
        }
    }
    
    
    func updateUI() {
        hideAllStackViews()
        
        let currentQuestion = questions[questionIndex]
        let currentAnswers = currentQuestion.answers
        let totalProgress = Float(questionIndex) / Float(questions.count)
        
        navigationItem.title = "Question #\(questionIndex + 1)"
        questionLabel.text = currentQuestion.text
        questionProgressView.setProgress(totalProgress, animated: true)
        
        switch currentQuestion.type {
        case .single:
            updateSingleStack(using: currentAnswers)
        case .multiple:
            updateMultipleStack(using: currentAnswers)
        case .ranged:
            updateRangedStack(using: currentAnswers)
        }
    }
    
    
    func updateSingleStack(using answers: [Answer]) {
        singleStackView.isHidden = false
        
        // clear out the stack view
        for subview in singleStackView.subviews {
            subview.removeFromSuperview()
        }
        
        for answer in answers {
            let singleButton = createSingleButton(withTitle: answer.text)
            singleStackView.addArrangedSubview(singleButton)
        }
    }
    
    func createSingleButton(withTitle title: String) -> UIButton {
        let singleButton = UIButton(type: .system)
        singleButton.setTitle(title, for: .normal)
        singleButton.isHidden = false
        singleButton.addTarget(self, action: #selector(self.singleAnswerButtonPressed), for: .touchUpInside)
        
        return singleButton
    }
    
    
    func updateMultipleStack(using answers: [Answer]) {
        multipleStackView.isHidden = false
        
        // clear out the stack view except for the submit answer button
        for subview in multipleStackView.subviews {
            if subview != multipleSubmitAnswerButton {
                subview.removeFromSuperview()
            }
        }
        
        for answer in answers {
            let multipleHorizontalStack = createHorizontalMultipleStack(withTitle: answer.text)
            multipleStackView.insertArrangedSubview(multipleHorizontalStack, at: 0)
        }
    }
    
    func createHorizontalMultipleStack(withTitle title: String) -> UIStackView {
        let multipleHorizontalStack = UIStackView()
        multipleHorizontalStack.axis = .horizontal
        
        let multipleLabel = UILabel()
        multipleLabel.text = title
        multipleLabel.textAlignment = .left
        
        let multipleSwitch = UISwitch()
        multipleSwitch.isOn = false
        
        multipleHorizontalStack.addArrangedSubview(multipleLabel)
        multipleHorizontalStack.addArrangedSubview(multipleSwitch)
        
        return multipleHorizontalStack
    }
    
    
    func updateRangedStack(using answers: [Answer]) {
        rangedStackView.isHidden = false
        
        rangedSlider.setValue(0.5, animated: false)
        
        rangedLabel1.text = answers.first?.text
        rangedLabel2.text = answers.last?.text
    }
    
    
    func hideAllStackViews() {
        singleStackView.isHidden = true
        multipleStackView.isHidden = true
        rangedStackView.isHidden = true
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ResultsSegue" {
            let resultsViewController = segue.destination as! ResultsViewController
            resultsViewController.responses = answersChosen
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}



extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
