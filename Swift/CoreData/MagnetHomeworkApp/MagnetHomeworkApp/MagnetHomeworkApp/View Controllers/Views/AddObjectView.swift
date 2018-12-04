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
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    
    var delegate: AddObjectViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textLabel.textColor = .white
        configure()
        
        print("AWOKEN")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        print("Add Button Pressed")
        setToSelected(withDuration: 0.1)
    }
    
    @IBAction func addButtonPressedDown(_ sender: Any) {
        UIView.animate(withDuration: 0.1, animations: {
            self.view.backgroundColor = .highlightColor
        })
    }
    
    @IBAction func addButtonDraggedOutside(_ sender: Any) {
        UIView.animate(withDuration: 0.1, animations: {
            self.view.backgroundColor = .backgroundColor
        })
    }
    
    @IBAction func addButtonDraggedInside(_ sender: Any) {
        UIView.animate(withDuration: 0.1, animations: {
            self.view.backgroundColor = .backgroundColor
        })
    }
    
    @IBAction func addButtonDragExited(_ sender: Any) {
        setToNormal(withDuration: 0.2)
    }
    
    func configure() {
        view.layer.cornerRadius = 5
        view.addDropShadow(color: .black, opacity: 0.15, radius: 4)
        view.isHidden = false
        textField.isHidden = true
        view.backgroundColor = .primaryColor
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
    
    func setToSelected(withDuration duration: TimeInterval) {
        addButton.isHidden = true
        textLabel.isHidden = true
        
        textField.isHidden = false
        textField.becomeFirstResponder()
        
        UIView.animate(withDuration: duration, animations: {
            self.view.backgroundColor = .white // TODO: Make a color for this
        })
        
        delegate?.viewSetToSelected()
    }
    
    func commonInit() {
//        Bundle.main.loadNibNamed("AddObjectView", owner: self, options: nil)
//        addSubview(contentView)
//        contentView.frame = self.bounds
//        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
