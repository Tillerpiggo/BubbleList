//
//  AddListViewController.swift
//  Lists
//
//  Created by Tyler Gee on 7/28/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit
import CloudKit

protocol AddListViewControllerDelegate {
    func controller(controller: AddListViewController, didAddList list: CKRecord)
    func controller(controller: AddListViewController, didUpdateList list: CKRecord)
}

class AddListViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var delegate: AddListViewControllerDelegate?
    var newList: Bool = true
    var list: CKRecord?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupView()
        
        // It's a new list if there is no old list passed in
        self.newList = (self.list == nil)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(AddListViewController.textFieldTextDidChange(notification:)),
                                       name : NSNotification.Name.UITextFieldTextDidChange,
                                       object: nameTextField)
    }
    
    private func setupView() {
        updateNameTextField()
        updateSaveButton()
    }
    
    private func updateNameTextField() {
        if let name = list?.object(forKey: "name") as? String {
            nameTextField.text = name
        }
    }
    
    private func updateSaveButton() {
        let text = nameTextField.text
        
        if let name = text {
            saveButton.isEnabled = !name.isEmpty
        } else {
            saveButton.isEnabled = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nameTextField.becomeFirstResponder()
    }
    
    @IBAction func cancel(sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(sender: AnyObject) {
        
        // Helpers
        let name = self.nameTextField.text! as NSString
        
        // Fetch Private Database
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        if list == nil {
            list = CKRecord(recordType: "Lists")
        }
        
        // Configure Record
        list?.setObject(name, forKey: "name")
        
        // Show Activity Indicator
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // Save Record
        privateDatabase.save(list!) { (record, error) in
            DispatchQueue.main.sync {
                // Dismiss Activity Indicator
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                // Process Response
                self.processResponse(record: record, error: error)
            }
        }
    }
    
    private func processResponse(record: CKRecord?, error: Error?) {
        var message = ""
        
        if let error = error {
            print(error)
            message = "We were not able to save your list."
        } else if record == nil {
            message = "We were not able to save your list."
        }
        
        if !message.isEmpty {
            // Initialize Alert Controller
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            
            // Present Alert Controller
            present(alertController, animated: true, completion: nil)
        } else {
            // Notify Delegate
            if newList {
                delegate?.controller(controller: self, didAddList: list!)
            } else {
                delegate?.controller(controller: self, didUpdateList: list!)
            }
            
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func textFieldTextDidChange(notification: NSNotification) {
        updateSaveButton()
    }
}
