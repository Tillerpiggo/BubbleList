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
    
    
    var delegate: AssignmentHeaderFooterCellDelegate?
    var section: Int?
    var isExpanded: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.type = .fade
        animation.duration = 0.1
        showHideButton.titleLabel?.layer.add(animation, forKey: "kCATransitionFade")
        
        updateShowHideButton()
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
            showHideButton.setTitle("Hide", for: .normal)
        } else {
            showHideButton.setTitle("Show", for: .normal)
        }
    }
}
