//
//  AddObjectTableViewController.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/25/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

protocol AddObjectButton {
    // Maybe use this?
}

class AddObjectTableViewController: UIViewController, UITextFieldDelegate, UITextDragDelegate, AddObjectButton {
    
    // MARK: - Variables
    
    var doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(AssignmentTableViewController.donePressed(sender:)))
    var addObjectView = NSBundle.mainBundle()
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureAddObjectView()
    }
    
    // MARK: - IBActions
    

    
    func configureAddObjectView() {
        addObjectView.layer.cornerRadius = 5
        addObjectView.addDropShadow(color: .black, opacity: 0.15, radius: 4)
        addObjectView.isHidden = false
    }
    
    func setAddObjectViewNotEditing(withAnimationDuration duration: TimeInterval) {
        textField.text = ""
        
        textField.isHidden = true
        addLabel.isHidden = false
        
        UIView.animate(withDuration: duration, animations: {
            self.addObjectView.backgroundColor = UIColor.highlightColor
            
            if self.doneButtonVisible() {
                self.removeDoneButton()
            }
        }, completion: { (bool) in
            self.addButton.isHidden = false
        })
    }
    
    func doneButtonVisible() -> Bool {
        return self.navigationItem.rightBarButtonItems?.count ?? 0 > 1
    }
    
    func removeDoneButton() {
        self.navigationItem.rightBarButtonItem = nil
    }
    
    func addDoneButton() {
        self.navigationItem.setRightBarButtonItems([doneButton, self.navigationItem.rightBarButtonItem!], animated: true)
    }
    
    @objc func donePressed(sender: UIBarButtonItem) {
        textField.resignFirstResponder()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text, text != "" {
            saveObject(text: text)
        }
        
        setAddObjectViewNotEditing(withAnimationDuration: 0.2)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func saveObject(text: String) {
        // Must be implemented by subclass
    }
}
