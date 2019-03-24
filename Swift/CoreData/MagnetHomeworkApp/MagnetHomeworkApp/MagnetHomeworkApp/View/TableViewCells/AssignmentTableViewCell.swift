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
    func textChanged(assignment: Assignment)
}

class AssignmentTableViewCell: UITableViewCell, UITextFieldDelegate, UITextDragDelegate {
    
    let completedCircleImageName = "completedCircleTemplate"
    let incompletedCircleImageName = "incompletedCircle2"
    let scheduleButtonImageName = "calendarIcon"
    
    // MARK: - Properties
    var delegate: AssignmentTableViewCellDelegate?
    var assignment: Assignment?
    
    var originalText: String?
    
    // MARK: - IBOutlets
    @IBOutlet weak var isCompletedImageView: UIImageView!
    @IBOutlet weak var dueDateTextLabel: UILabel!
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var scheduleButton: UIImageView!
    @IBOutlet weak var assignmentTextField: UITextField!
    
    // MARK: - IBActions
    @IBAction func buttonPressed(_ sender: Any) {
        let isCompleted = delegate?.buttonPressed(assignment: assignment!)
        let isCompletedImage = isCompleted ?? false ? UIImage(named: completedCircleImageName)?.withRenderingMode(.alwaysTemplate) : UIImage(named: incompletedCircleImageName)
        isCompletedImageView.tintColor = .primaryColor
        
        let duration: TimeInterval = 0.1
        
        self.isCompletedImageView.image = isCompletedImage
        transition(with: assignmentTextField, duration: duration, animations: { self.assignmentTextField.textColor = isCompleted ?? false ? .lightGray : .textColor })
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
        
        isCompletedImageView.tintColor = .primaryColor
        contentView.backgroundColor = .contentColor
        backgroundColor = .contentColor
        self.assignmentTextField.delegate = self
        self.assignmentTextField.textDragDelegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = .fade
        animation.duration = 1.0
        
        scheduleButton.image = UIImage(named: scheduleButtonImageName)?.withRenderingMode(.alwaysTemplate)
        scheduleButton.tintColor = .primaryColor
        
        //contentView.backgroundColor = .backgroundColor
        
        isCompletedImageView.tintColor = .primaryColor
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
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        print(sender.text ?? "")
        
        guard textNotEmpty(sender.text ?? "") else {
            return
        }
    }
    
    func textFieldDidBeginEditing(_ sender: UITextField) {
        originalText = sender.text!
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if !textNotEmpty(textField.text ?? "") {
            textField.text = originalText
        } else {
            assignment?.text = textField.text
        }
        
        delegate?.textChanged(assignment: assignment!)
        return true
    }
    
    func textNotEmpty(_ text: String) -> Bool {
        let isTextNotEmpty = (text != "" && !text.isEmpty)
        print(isTextNotEmpty)
        return isTextNotEmpty
    }
    
    
    
    func configure(withAssignment assignment: Assignment) {
        let isCompleted = assignment.toDo?.isCompleted ?? false
        let isCompletedImage = isCompleted ? UIImage(named: completedCircleImageName) : UIImage(named: incompletedCircleImageName)
        isCompletedImageView.tintColor = .primaryColor
        isCompletedImageView.image = isCompletedImage
        
        assignmentTextField.text = assignment.text
        assignmentTextField.textColor = isCompleted ? .lightGray : .textColor
        dueDateTextLabel.textColor = isCompleted ? UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0) : .secondaryTextColor
        if let date = assignment.dueDate?.date as Date?, assignment.shouldDisplayDueDate() {
            dueDateTextLabel.text = "Due \(date.dateString)"
            dueDateTextLabel.isHidden = false
        } else {
            dueDateTextLabel.isHidden = true
        }
        
        self.assignment = assignment
    }
    
//    func doesDisplayDueDate() -> Bool {
//        guard let dueDate = assignment?.dueDate else { return false }
//
//        switch dueDate.dueDateType {
//        case .dueNextWeek, .dueLater, .late, .completed: return true
//        default: return false
//        }
//    }

}
