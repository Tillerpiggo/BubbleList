//
//  AddStudentTableViewController.swift
//  SkillsUSAContest
//
//  Created by Tyler Gee on 1/17/19.
//  Copyright © 2019 Beaglepig. All rights reserved.
//

import UIKit

class AddStudentTableViewController: UITableViewController {
    
    // add text field
    @IBOutlet weak var nameTextField: UITextField!
    var student: Student? = nil
    var projectName: String!
    var students: [Student]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // save
//    guard let name = nameTextField.text else { return }
//
//    let project = Project(name: name, students: [])
//    self.project = project
    
    @IBAction func save(_ sender: Any) {
        guard let name = nameTextField.text else { return }
        
        let grades: [String: Grade] = [projectName: Grade()]
        
        let student = Student(name: name, grades: grades)
        self.student = student
        
        performSegue(withIdentifier: "unwindToStudents", sender: self)
    }
    
    // cancel (dismiss)

    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
}
