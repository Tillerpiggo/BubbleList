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
    func scheduleButtonPressed(assignment: Assignment)
}

class AssignmentTableViewCell: UITableViewCell {
    
    let completedCircleImageName = "completedCircleTemplate"
    let incompletedCircleImageName = "incompletedCircle2"
    let scheduleButtonImageName = "calendarIconTemplate"
    
    // MARK: - Properties
    var delegate: AssignmentTableViewCellDelegate?
    var assignment: Assignment?
    
    // MARK: - IBOutlets
    @IBOutlet weak var isCompletedImageView: UIImageView!
    @IBOutlet weak var assignmentTextLabel: UILabel!
    @IBOutlet weak var dueDateTextLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var scheduleButton: UIImageView!
    
    // MARK: - IBActions
    @IBAction func buttonPressed(_ sender: Any) {
        let isCompleted = delegate?.buttonPressed(assignment: assignment!)
        let isCompletedImage = isCompleted ?? false ? UIImage(named: completedCircleImageName)?.withRenderingMode(.alwaysTemplate) : UIImage(named: incompletedCircleImageName)
        isCompletedImageView.tintColor = .highlightColor
        
        let duration: TimeInterval = 0.1
        
        self.isCompletedImageView.image = isCompletedImage
        transition(with: assignmentTextLabel, duration: duration, animations: { self.assignmentTextLabel.textColor = isCompleted ?? false ? .lightGray : .textColor })
        transition(with: dueDateTextLabel, duration: duration, animations: { self.dueDateTextLabel.textColor = isCompleted ?? false ? UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0) : .secondaryTextColor })
    }
    
    func transition(with view: UIView, duration: TimeInterval, animations: (() -> Void)?) {
        UIView.transition(with: view,
                          duration: duration,
                          options: .transitionCrossDissolve,
                          animations: animations,
                          completion: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isCompletedImageView.tintColor = .highlightColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = .fade
        animation.duration = 1.0
        
        scheduleButton.image = UIImage(named: scheduleButtonImageName)?.withRenderingMode(.alwaysTemplate)
        scheduleButton.tintColor = .highlightColor
        
        //contentView.backgroundColor = .backgroundColor
        
        isCompletedImageView.tintColor = .highlightColor
    }
    
    @IBAction func scheduleButtonPressed(_ sender: Any) {
        delegate?.scheduleButtonPressed(assignment: assignment!)
        
        UIView.animate(withDuration: 0.08, animations: {
            self.scheduleButton.alpha = 0.2
        }, completion: { (bool) in
            UIView.animate(withDuration: 0.0, delay: 0.3, animations: {
                self.scheduleButton.alpha = 1.0
            })
        })
    }
    
    func configure(withAssignment assignment: Assignment) {
        let isCompleted = assignment.toDo?.isCompleted ?? false
        let isCompletedImage = isCompleted ? UIImage(named: completedCircleImageName) : UIImage(named: incompletedCircleImageName)
        isCompletedImageView.tintColor = .highlightColor
        isCompletedImageView.image = isCompletedImage
        
        assignmentTextLabel.text = assignment.text
        assignmentTextLabel.textColor = isCompleted ? .lightGray : .textColor
        dueDateTextLabel.textColor = isCompleted ? UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0) : .secondaryTextColor
        if let dueDate = assignment.dueDate as Date?, dueDate != Date.tomorrow, assignment.dueDateSection  != "Completed" {
            let dueDateString = dueDate.dateString
            dueDateTextLabel.text = "Due \(dueDateString)"
            dueDateTextLabel.isHidden = false
        } else {
            dueDateTextLabel.isHidden = true
        }
        
        self.assignment = assignment
    }

}
