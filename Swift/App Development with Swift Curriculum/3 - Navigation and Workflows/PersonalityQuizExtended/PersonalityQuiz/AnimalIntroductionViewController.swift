//
//  AnimalIntroductionViewController.swift
//  PersonalityQuiz
//
//  Created by Tyler Gee on 6/26/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit

class AnimalIntroductionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navigationController = segue.destination as? UINavigationController {
            if let questionViewController = navigationController.viewControllers.first as? QuestionViewController {
                questionViewController.quizType = .animal
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
