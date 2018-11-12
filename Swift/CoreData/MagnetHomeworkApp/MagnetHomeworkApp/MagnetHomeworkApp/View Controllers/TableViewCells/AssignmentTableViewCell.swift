//
//  AssignmentTableViewCell.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/3/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

protocol AssignmentTableViewCellDelegate {
    func buttonPressed(assignment: Assignment) -> Bool
}

class AssignmentTableViewCell: UITableViewCell {
    
    let completedCircleImageName = "completedCircleSaturatedAqua"
    let incompletedCircleImageName = "darkGrayIncompletedCircle"
    
    // MARK: - Properties
    var delegate: AssignmentTableViewCellDelegate?
    var assignment: Assignment?
    
    // MARK: - IBOutlets
    @IBOutlet weak var isCompletedImageView: UIImageView!
    @IBOutlet weak var assignmentTextLabel: UILabel!
    @IBOutlet weak var dueDateTextLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    
    // MARK: - IBActions
    @IBAction func buttonPressed(_ sender: Any) {
        let isCompleted = delegate?.buttonPressed(assignment: assignment!)
        let isCompletedImage = isCompleted ?? false ? UIImage(named: completedCircleImageName) : UIImage(named: incompletedCircleImageName)
        isCompletedImageView.image = isCompletedImage
        assignmentTextLabel.textColor = isCompleted ?? false ? .lightGray : .textColor
        dueDateTextLabel.textColor = isCompleted ?? false ? UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0): .lightGray
    }
    
    func configure(withAssignment assignment: Assignment) {
        let isCompletedImage = assignment.toDo?.isCompleted ?? false ? UIImage(named: completedCircleImageName) : UIImage(named: incompletedCircleImageName)
        isCompletedImageView.image = isCompletedImage
        assignmentTextLabel.text = assignment.text
        assignmentTextLabel.textColor = assignment.toDo?.isCompleted ?? false ? .lightGray : .black
        if let dueDate = assignment.dueDate as Date?, dueDate != Date.tomorrow {
            let dueDateString = dueDate.dateString
            dueDateTextLabel.text = "Due \(dueDateString)"
            dueDateTextLabel.isHidden = false
        } else {
            dueDateTextLabel.isHidden = true
            print("DUE DATE TEXT LABEL SET TO HIDDEN")
        }
        
        self.assignment = assignment
    }

}
