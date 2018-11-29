//
//  AddObjectTableViewController.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/25/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

class AddObjectViewController: UIViewController, AddObjectViewDelegate, UITextFieldDelegate, UITextDragDelegate {
    
    // MARK: - Variables
    
    var doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(AssignmentTableViewController.donePressed(sender:)))
    var addObjectView = Bundle.main.loadNibNamed("AddObjectView", owner: self, options: nil)?.first as! AddObjectView
    
    // MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureAddObjectViewTextField()
    }
    
    // MARK: - IBActions
    

    
    func configureAddObjectViewTextField() {
        addObjectView.textField.delegate = self
        addObjectView.textField.textDragDelegate = self
    }
    
    func doneButtonVisible() -> Bool {
        return self.navigationItem.rightBarButtonItems?.count ?? 0 > 1
    }
    
    func removeDoneButton() {
        self.navigationItem.rightBarButtonItem = nil // subclass should implement
    }
    
    func addDoneButton() {
        self.navigationItem.setRightBarButtonItems([doneButton, self.navigationItem.rightBarButtonItem!], animated: true) // subclass should implement
    }
    
    @objc func donePressed(sender: UIBarButtonItem) {
        addObjectView.textField.resignFirstResponder()
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let text = textField.text, text != "" {
            saveObject(text: text)
        }
        
        addObjectView.setToNormal(withDuration: 0.2)
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func saveObject(text: String) {
        // Must be implemented by subclass
    }
    
    // MARK: - AddObjectViewDelegate
    
    func viewSetToNormal() {
        let text = addObjectView.textField.text ?? ""
        if !text.isEmpty {
            saveObject(text: text)
        }
        
        removeDoneButton()
    }
    
    func viewSetToSelected() {
        addDoneButton()
    }
}
