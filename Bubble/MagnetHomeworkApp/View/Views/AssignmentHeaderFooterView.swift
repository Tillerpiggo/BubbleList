//
//  AssignmentTableViewHeaderFooterView.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/23/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

protocol AssignmentHeaderFooterCellDelegate {
    func showHideButtonPressed(isExpanded: Bool, forSection section: Int)
}

class AssignmentHeaderFooterView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var showHideButton: UIButton!
    @IBOutlet weak var showHideLabel: UILabel!
    @IBOutlet weak var backgroundColorView: UIView!
    
    var delegate: AssignmentHeaderFooterCellDelegate?
    var section: Int?
    var isExpanded: Bool = true
    var dueDateType: DueDateType = .unscheduled {
        didSet {
            titleLabel.text = dueDateType.string
            titleLabel.textColor = dueDateType.color
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = .fade
        animation.duration = 0.1
        showHideLabel?.layer.add(animation, forKey: "kCATransitionFade")
        titleLabel.textColor = .white
        
        backgroundColorView.backgroundColor = .sectionColor
        
        updateShowHideButton()
        
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundColorView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //backgroundColorView.addSubview(blurEffectView)
    }
    
    func configure(withDueDateType dueDateType: DueDateType) {
        titleLabel.textColor = dueDateType.color
    }
    
    @IBAction func showHideButtonPressed(_ sender: Any) {
        print("ISEXPANDED: \(isExpanded)")
        isExpanded = !isExpanded
        print("ISEXPANDED: \(isExpanded)\n")
        
        delegate?.showHideButtonPressed(isExpanded: isExpanded, forSection: section!)
        
        updateShowHideButton()
    }
    
    func updateShowHideButton() {
        if isExpanded {
            showHideLabel.text = "Hide"
        } else {
            showHideLabel.text = "Expand"
        }
    }
}
