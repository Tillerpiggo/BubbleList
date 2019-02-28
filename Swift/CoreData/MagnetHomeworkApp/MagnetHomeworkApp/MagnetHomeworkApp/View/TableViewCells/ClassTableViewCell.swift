//
//  ClassTableViewCell.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/11/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit
import Foundation

protocol ClassTableViewCellDelegate {
    func expandedClass(_ class: Class)
    func collapsedClass(_ class: Class)
}

class ClassTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var nameLabel: UILabel!
    //@IBOutlet weak var previewAssignmentLabel: UILabel!
    @IBOutlet weak var duePreview: UILabel!
    //@IBOutlet weak var completedImageView: UIImageView!
    //@IBOutlet weak var numberOfAssignmentsImageView: UIImageView!
    @IBOutlet weak var numberOfAssignmentsLabel: UILabel!
    
    var accessoryButton: UIButton?
    var delegate: ClassTableViewCellDelegate?
    var isExpanded: Bool = false
    var `class`: Class?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryButton = subviews.compactMap { $0 as? UIButton }.first
        
        //completedImageView.isHidden = true
        contentView.backgroundColor = .contentColor
        backgroundColor = .contentColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        accessoryButton?.frame.origin.y += 1
        accessoryButton?.frame.origin.x += 0
        
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = .fade
        animation.duration = 0.25
        
        //previewAssignmentLabel.layer.add(animation, forKey: "kCATransitionFade")
        //previewAssignmentLabel.textColor = .secondaryTextColor
    }
    
    func configure(withClass `class`: Class) {
        self.`class` = `class`
        
        nameLabel.text = `class`.name
        nameLabel.textColor = .textColor
        
        updateDuePreview()
    }
    
    func updateDuePreview() {
        if let previewAssignments = `class`!.previewAssignments() {
            //previewAssignmentLabel.isHidden = false
            var duePreviewSection = previewAssignments.first?.dueDateSection
            let numberOfAssignments = previewAssignments.count
            
            
            if previewAssignments.first?.dueDateSection == "Due Later" {
                duePreviewSection = "Due in a While"
            }
            
            var string: String = "\(numberOfAssignments) \(duePreviewSection ?? "")"
            
            let totalAssignments = `class`!.assignmentArray?.filter({ $0.isCompleted == false }).count ?? 0
            numberOfAssignmentsLabel.text = "\(totalAssignments)"
            if totalAssignments == 0 {
                numberOfAssignmentsLabel.text = ""
            }
            
            //completedImageView.isHidden = true
            
            let attributedText = NSMutableAttributedString(string: string)
            //print("AttributedText: \(attributedText.string)")
            var sectionColor: UIColor
            switch previewAssignments.first?.dueDateSectionNumber {
            case 0:
                sectionColor = .lateColor
            case 2:
                sectionColor = .dueThisWeekColor
            case 3, 4:
                sectionColor = .secondaryTextColor
            case 1:
                sectionColor = .dueTomorrowColor
            default:
                sectionColor = .nothingDueColor
            }
            
            attributedText.addAttribute(.foregroundColor, value: sectionColor, range: NSRange(location: 0, length: attributedText.string.count))
            duePreview.attributedText = attributedText
        } else {
            
            let attributedText = NSMutableAttributedString(string: "Nothing Due")
            attributedText.addAttribute(.foregroundColor, value: UIColor.nothingDueColor, range: NSRange(location: 0, length: attributedText.string.count))
            
            duePreview.attributedText = attributedText
        }
    }
    
//    func setPreviewAssignmentLabel(previewAssignments: [Assignment], numberOfAssignments: Int, includesCount: Bool = false) {
//        var text: String = ""
//
//        for previewAssignment in previewAssignments[0..<numberOfAssignments] {
//            text += "\(previewAssignment.text!)\n"
//        }
//        for _ in 0..<1 { text.removeLast() }
//        if includesCount { previewAssignmentSectionLabel.text?.append(" (\(previewAssignments.count))") }
//
//
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = 2.0
//        let attributedText = NSAttributedString(string: text, attributes: [.paragraphStyle: paragraphStyle])
//        previewAssignmentLabel.attributedText = attributedText
//    }
}
