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
    
    // MARK: - Properties
    var delegate: AssignmentTableViewCellDelegate?
    var assignment: Assignment?
    
    // MARK: - IBOutlets
    @IBOutlet weak var isCompletedImageView: UIImageView!
    @IBOutlet weak var assignmentTextLabel: UILabel!
    
    // MARK: - IBActions
    @IBAction func buttonPressed(_ sender: Any) {
        let isCompleted = delegate?.buttonPressed(assignment: assignment!)
        let isCompletedImage = isCompleted ?? false ? UIImage(named: "completedCircle") : UIImage(named: "darkGrayIncompletedCircle")
        isCompletedImageView.image = isCompletedImage
        assignmentTextLabel.textColor = isCompleted ?? false ? .lightGray : .black
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(withAssignment assignment: Assignment) {
        let isCompletedImage = assignment.toDo?.isCompleted ?? false ? UIImage(named: "completedCircle") : UIImage(named: "darkGrayIncompletedCircle")
        isCompletedImageView.image = isCompletedImage
        assignmentTextLabel.text = assignment.text
        assignmentTextLabel.textColor = assignment.toDo?.isCompleted ?? false ? .lightGray : .black
        self.assignment = assignment
    }

}
