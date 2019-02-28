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
    
    let selectionDuration: TimeInterval = 0.25
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        textLabel.textColor = .white
        configure()
        
        print("AWOKEN")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        //configure()
        setToNormal(withDuration: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        //configure()
        setToNormal(withDuration: 0)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        print("Add Button Pressed")
        setToSelected(withDuration: selectionDuration)
    }
    
    @IBAction func addButtonPressedDown(_ sender: Any) {
        highlight()
    }
    
    @IBAction func addButtonDraggedOutside(_ sender: Any) {
        UIView.animate(withDuration: 0.1, animations: {
            self.view.backgroundColor = .primaryColor
            self.textLabel.textColor = .white
        })
    }
    
    @IBAction func addButtonDraggedInside(_ sender: Any) {
        highlight()
    }
    
    @IBAction func addButtonDragExited(_ sender: Any) {
        setToNormal(withDuration: selectionDuration)
    }
    
    func configure() {
        view.layer.cornerRadius = 5
        //view.addDropShadow(color: .black, opacity: 0.15, radius: 2)
        view.layoutSubviews()
        view.isHidden = false
        textField.isHidden = true
        view.backgroundColor = .primaryColor
        textLabel.textColor = .white
    }
    
    func highlight() {
        UIView.animate(withDuration: 0.1, animations: {
            self.view.backgroundColor = UIColor(red: 255/255, green: 70/255, blue: 70/255, alpha: 1)
            self.textLabel.textColor = .white
        })
    }
    
    func setToNormal(withDuration duration: TimeInterval) {
        textField.text = ""
        
        textField.isHidden = true
        textLabel.isHidden = false
        
        UIView.animate(withDuration: duration, animations: {
            self.view.backgroundColor = .primaryColor
            self.transform = CGAffineTransform.identity
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
        
        let moveUpTransform = CGAffineTransform(translationX: 0, y: -186)
        
        let scaleFactor = self.frame.width / self.view.frame.width // makes it fill from side to side
        let scaleTransform = CGAffineTransform(scaleX: 1, y: 1)
        let selectedTransform = moveUpTransform.concatenating(scaleTransform)
        
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseInOut, animations: {
            self.view.backgroundColor = .white
            self.transform = selectedTransform
            //self.view.addDropShadow(color: .black, opacity: 0.5, radius: 200)
        })
        
        delegate?.viewSetToSelected()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("AddObjectView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
