//
//  GradeStudentTableViewController.swift
//  SkillsUSAContest
//
//  Created by Tyler Gee on 1/17/19.
//  Copyright © 2019 Beaglepig. All rights reserved.
//

import UIKit

class GradeStudentTableViewController: UITableViewController {
    
    @IBOutlet weak var programmingTextField: UITextField!
    @IBOutlet weak var artTextField: UITextField!
    @IBOutlet weak var science: UITextField!
    @IBOutlet weak var crafting: UITextField!
    @IBOutlet weak var language: UITextField!
    @IBOutlet weak var history: UITextField!
    @IBOutlet weak var quality: UITextField!
    @IBOutlet weak var persistence: UITextField!
    @IBOutlet weak var teamwork: UITextField!
    @IBOutlet weak var creativity: UITextField!
    var student: Student!
    var projectName: String!
    var grade: Grade?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        grade = student.grades[projectName]!
        
        guard let grade = grade else { return }

        programmingTextField.placeholder = "\(grade.programming ?? 0)"
        artTextField.placeholder = "\(grade.art ?? 0)"
        science.placeholder = "\(grade.science ?? 0)"
        crafting.placeholder = "\(grade.crafting ?? 0)"
        language.placeholder = "\(grade.language ?? 0)"
        history.placeholder = "\(grade.history ?? 0)"
        quality.placeholder = "\(grade.quality ?? 0)"
        persistence.placeholder = "\(grade.persistence ?? 0)"
        teamwork.placeholder = "\(grade.teamwork ?? 0)"
        creativity.placeholder = "\(grade.creativity ?? 0)"
    }
    
    @IBAction func programming(_ sender: UITextField) {
        guard let text = sender.text,
            let number = Float(text),
            let grade = grade else { return }
        
        grade.programming = number
    }
    
    @IBAction func art(_ sender: UITextField) {
        guard let text = sender.text,
            let number = Float(text),
            let grade = grade else { return }
        
        grade.art = number
    }
    
    @IBAction func science(_ sender: UITextField) {
        guard let text = sender.text,
            let number = Float(text),
            let grade = grade else { return }
        
        grade.science = number
    }
    @IBAction func crafting(_ sender: UITextField) {
        guard let text = sender.text,
            let number = Float(text),
            let grade = grade else { return }
        
        grade.crafting = number
    }
    @IBAction func language(_ sender: UITextField) {
        guard let text = sender.text,
            let number = Float(text),
            let grade = grade else { return }
        
        grade.language = number
    }
    @IBAction func history(_ sender: UITextField) {
        guard let text = sender.text,
            let number = Float(text),
            let grade = grade else { return }
        
        grade.history = number
    }
    @IBAction func quality(_ sender: UITextField) {
        guard let text = sender.text,
            let number = Float(text),
            let grade = grade else { return }
        
        grade.quality = number
    }
    @IBAction func persistence(_ sender: UITextField) {
        guard let text = sender.text,
            let number = Float(text),
            let grade = grade else { return }
        
        grade.persistence = number
    }
    @IBAction func teamwork(_ sender: UITextField) {
        guard let text = sender.text,
            let number = Float(text),
            let grade = grade else { return }
        
        grade.teamwork = number
    }
    @IBAction func creativity(_ sender: UITextField) {
        guard let text = sender.text,
            let number = Float(text),
            let grade = grade else { return }
        
        grade.creativity = number
    }
}
