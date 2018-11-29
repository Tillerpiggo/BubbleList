//
//  AddObjectView.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/28/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

protocol AddObjectViewDelegate {
    func viewSetToNormal()
    func viewSetToSelected()
}

class AddObjectView: UIView {
    
    var delegate: AddObjectViewDelegate?
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }
    
    func configure() {
        view.layer.cornerRadius = 5
        view.addDropShadow(color: .black, opacity: 0.15, radius: 4)
        view.isHidden = false
    }
    
    func setToNormal(withDuration duration: TimeInterval) {
        textField.text = ""
        
        textField.isHidden = true
        textLabel.isHidden = false
        
        UIView.animate(withDuration: duration, animations: {
            self.view.backgroundColor = .primaryColor
        }, completion: { (bool) in
            self.addButton.isHidden = false
        })
        
        delegate?.viewSetToNormal()
    }
}
