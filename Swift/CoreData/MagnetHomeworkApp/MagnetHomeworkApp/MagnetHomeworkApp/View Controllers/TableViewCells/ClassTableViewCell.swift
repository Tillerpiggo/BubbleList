//
//  ClassTableViewCell.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/11/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

protocol ClassTableViewCellDelegate {
    func expandedClass(_ class: Class)
    func collapsedClass(_ class: Class)
}

class ClassTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var previewAssignmentSectionLabel: UILabel!
    @IBOutlet weak var previewAssignmentLabel: UILabel!
    @IBOutlet weak var numberOfAssignmentsLabel: UILabel!
    @IBOutlet weak var expandButton: UIButton!
    
    var accessoryButton: UIButton?
    var delegate: ClassTableViewCellDelegate?
    var isExpanded: Bool = false
    var `class`: Class?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryButton = subviews.compactMap { $0 as? UIButton }.first
        
        contentView.backgroundColor = .backgroundColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        accessoryButton?.frame.origin.y = 17.5
        accessoryButton?.frame.origin.x += 0
        
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = .fade
        animation.duration = 0.25
        
        previewAssignmentLabel.layer.add(animation, forKey: "kCATransitionFade")
        previewAssignmentSectionLabel.layer.add(animation, forKey: "kCATransitionFade")
        expandButton.titleLabel?.layer.add(animation, forKey: "kCATransitionFade")
        previewAssignmentLabel.textColor = .secondaryTextColor
    }
    
    @IBAction func expandButtonPressed(_ sender: Any) {
        isExpanded = !isExpanded
        
        UIView.animate(withDuration: 0.25, animations: {
            if self.isExpanded {
                self.expandButton.setTitle("Show Less", for: .normal)
                self.delegate?.expandedClass(self.`class`!)
            } else {
                self.expandButton.setTitle("Show More", for: .normal)
                self.delegate?.collapsedClass(self.`class`!)
            }
            self.configure(withClass: self.`class`!)
        })
    }
    
    func configure(withClass `class`: Class) {
        self.`class` = `class`
        
        nameLabel.text = `class`.name
        nameLabel.textColor = .textColor
        let completedAssignments = `class`.assignmentArray?.filter { $0.toDo?.isCompleted == false }
        numberOfAssignmentsLabel.text = "\(completedAssignments?.count ?? 0)"
        if let previewAssignments = `class`.previewAssignments() {
            previewAssignmentLabel.isHidden = false
            previewAssignmentSectionLabel.isHidden = false
            previewAssignmentSectionLabel.text = previewAssignments.first?.dueDateSection
            previewAssignmentLabel.textColor = .secondaryTextColor
            if previewAssignments.first?.dueDateSection == "Due Later" {
                previewAssignmentSectionLabel.text = "Due in a While"
            }
            
            if previewAssignments.count <= 1 {
                setPreviewAssignmentLabel(
                    previewAssignments: previewAssignments,
                    numberOfAssignments: previewAssignments.count)

                expandButton.isHidden = true
            } else if isExpanded {
                setPreviewAssignmentLabel(
                    previewAssignments: previewAssignments,
                    numberOfAssignments: previewAssignments.count)
                expandButton.isHidden = false
            } else {
                setPreviewAssignmentLabel(
                    previewAssignments: previewAssignments,
                    numberOfAssignments: 1, includesCount: true)

                expandButton.isHidden = false
            }
            
//            setPreviewAssignmentLabel(
//                previewAssignments: previewAssignments,
//                numberOfAssignments: previewAssignments.count,
//                includesCount: true)
//            expandButton.isHidden = previewAssignments.count <= 1
            
            
            switch previewAssignments.first?.dueDateSectionNumber {
            case 0:
                previewAssignmentSectionLabel.textColor = .lateColor
            case 1:
                previewAssignmentSectionLabel.textColor = .unscheduledColor
            case 2:
                previewAssignmentSectionLabel.textColor = .dueTomorrowColor
            case 3:
                previewAssignmentSectionLabel.textColor = .dueThisWeekColor
            case 4:
                previewAssignmentSectionLabel.textColor = .dueLaterColor
            default:
                previewAssignmentSectionLabel.textColor = .unscheduledColor
            }
        } else {
            previewAssignmentLabel.isHidden = true
            previewAssignmentSectionLabel.isHidden = false
            previewAssignmentSectionLabel.textColor = .nothingDueColor
            expandButton.isHidden = true
            
//            let randomNumber = Int.random(in: 0...5)
//            var celebration: String
//            switch randomNumber {
//            case 0:
//                celebration = "Yay"
//            case 1:
//                celebration = "Woo-hoo"
//            case 2:
//                celebration = "Have Fun"
//            case 3:
//                celebration = "Nice"
//            case 4:
//                celebration = "Good Job"
//            case 5:
//                celebration = "Enjoy your Afternoon"
//            default:
//                celebration = "Yay"
//            }
            
            previewAssignmentSectionLabel.text = "Nothing Due"
        }
    }
    
    func setPreviewAssignmentLabel(previewAssignments: [Assignment], numberOfAssignments: Int, includesCount: Bool = false) {
        var text: String = ""
        
        for previewAssignment in previewAssignments[0..<numberOfAssignments] {
            text += "\(previewAssignment.text!)\n"
        }
        for _ in 0..<1 { text.removeLast() }
        if includesCount { previewAssignmentSectionLabel.text?.append(" (\(previewAssignments.count))") }
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2.0
        let attributedText = NSAttributedString(string: text, attributes: [.paragraphStyle: paragraphStyle])
        previewAssignmentLabel.attributedText = attributedText
    }
}
