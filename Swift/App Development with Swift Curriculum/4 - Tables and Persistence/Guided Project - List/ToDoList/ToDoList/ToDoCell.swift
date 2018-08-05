//
//  ToDoCell.swift
//  ToDoList
//
//  Created by Tyler Gee on 7/25/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit

class ToDoCell: UITableViewCell {
    
    var delegate: ToDoCellDelegate?

    @IBOutlet weak var isCompleteButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isCompleteButton.setImage(UIImage(named: "Unchecked"), for: .normal)
        isCompleteButton.setImage(UIImage(named: "Checked"), for: .selected)
    }
    
    @IBAction func isCompleteButtonTapped(_ sender: Any) {
        isCompleteButton.isSelected = !isCompleteButton.isSelected
        delegate?.isCompleteChanged(to: isCompleteButton.isSelected, sender: self)
    }
    
    func update(with todo: ToDo) {
        titleLabel?.text = todo.title
        isCompleteButton.isSelected = todo.isComplete
    }
}

protocol ToDoCellDelegate {
    func isCompleteChanged(to isComplete: Bool, sender: ToDoCell)
}
