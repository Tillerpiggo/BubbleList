//
//  StudentTableViewController.swift
//  SkillsUSAContest
//
//  Created by Tyler Gee on 1/17/19.
//  Copyright © 2019 Beaglepig. All rights reserved.
//

import UIKit

class StudentTableViewController: UITableViewController {
    
    var project: Project!
    var students: [Student]!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        //self.navigationItem.title = project.name
        
        tableView.rowHeight = 100
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return project.students.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell")!
        
        let student = project.students[indexPath.row]
        cell.textLabel?.text = student.name
        
        let grade = student.grades[project.name]!
        
        let gradeText = "Pr: \(grade.programming ?? 0), A: \(grade.art ?? 0), S: \(grade.science ?? 0), Cr: \(grade.crafting ?? 0), L: \(grade.language ?? 0), H: \(grade.history ?? 0), Q: \(grade.quality ?? 0), P: \(grade.persistence ?? 0), T: \(grade.teamwork ?? 0), C: \(grade.creativity ?? 0), Avg: \(grade.weightedScore ?? 0)"
        cell.detailTextLabel?.text = gradeText
        
        return cell
    }

    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        guard let addStudentTableViewController = segue.source as? AddStudentTableViewController,
            let student = addStudentTableViewController.student else { return }
        project.students.append(student)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addStudent" {
            guard let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.topViewController as? AddStudentTableViewController else { return }
        
            viewController.projectName = project.name
        } else if segue.identifier == "editStudent" {
            guard let viewController = segue.destination as? GradeStudentTableViewController else { return }
            
            viewController.student = project.students[tableView.indexPathForSelectedRow!.row]
            viewController.projectName = project.name
        }
    }
    

}
