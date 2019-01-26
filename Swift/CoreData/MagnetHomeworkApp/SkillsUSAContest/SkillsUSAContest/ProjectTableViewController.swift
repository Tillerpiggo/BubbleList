//
//  TableViewController.swift
//  SkillsUSAContest
//
//  Created by Tyler Gee on 1/17/19.
//  Copyright © 2019 Beaglepig. All rights reserved.
//

import UIKit

class ProjectTableViewController: UITableViewController {
    
    var projects: [Project]!
    var students: [Student]!

    override func viewDidLoad() {
        super.viewDidLoad()
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
        return projects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectCell") as! ProjectCell
        
        let project = projects[indexPath.row]
        cell.configure(with: project)
        
        return cell
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        guard let addProjectTableViewController = segue.source as? AddProjectTableViewController,
            let project = addProjectTableViewController.project else { return }
        projects.append(project)
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "studentTableView" {
            guard let studentTableViewController = segue.destination as? StudentTableViewController else {
                return
            }
            studentTableViewController.project = projects[tableView.indexPathForSelectedRow!.row]
            studentTableViewController.students = students
        } else if segue.identifier == "addProject" {
            guard let navigationController = segue.destination as? UINavigationController, let addProjectTableViewController = navigationController.topViewController as? AddProjectTableViewController else { return }
            // Do nothing
        }
    }
    
}

class ProjectCell: UITableViewCell {
    
    @IBOutlet weak var projectName: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(with project: Project) {
        projectName.text = project.name
        
        let scoreText = "Hi: \(project.highScore ?? -1), Low: \(project.lowScore ?? -1), Avg: \(project.averageScore ?? -1)"
        scoreLabel.text = scoreText
    }
    
}
