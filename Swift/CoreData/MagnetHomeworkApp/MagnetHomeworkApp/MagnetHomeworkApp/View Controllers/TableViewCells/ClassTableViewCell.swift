//
//  ClassTableViewCell.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/11/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

class ClassTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var previewAssignmentSectionLabel: UILabel!
    @IBOutlet weak var previewAssignmentLabel: UILabel!
    
    func configure(withClass `class`: Class) {
        nameLabel.text = `class`.name
        if let previewAssignment = `class`.previewAssignment() {
            previewAssignmentLabel.isHidden = false
            previewAssignmentSectionLabel.isHidden = false
            previewAssignmentSectionLabel.text = previewAssignment.dueDateSection
            previewAssignmentLabel.textColor = .highlightColor
            if previewAssignment.dueDateSection == "Due Later" {
                previewAssignmentSectionLabel.text = "Due in a While"
            }
            
            previewAssignmentLabel.text = previewAssignment.text
            
            switch previewAssignment.dueDateSectionNumber {
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
            previewAssignmentLabel.isHidden = false
            previewAssignmentSectionLabel.isHidden = true
            previewAssignmentLabel.textColor = .nothingDueColor
            previewAssignmentLabel.text = "All Done, Have Fun"
        }
    }
}
