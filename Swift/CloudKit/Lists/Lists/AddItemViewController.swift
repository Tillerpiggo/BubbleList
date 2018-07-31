//
//  AddItemViewController.swift
//  Lists
//
//  Created by Tyler Gee on 7/29/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit
import CloudKit

protocol AddItemViewControllerDelegate {
    func controller(_ controller: AddItemViewController, didAddItem item: CKRecord)
    func controller(_ controller: AddItemViewController, didUpdateItem item: CKRecord)
}

class AddItemViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var numberStepper: UIStepper!
    
    var delegate: AddItemViewControllerDelegate?
    var newItem: Bool = true
    
    var list: CKRecord!
    var item: CKRecord?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        newItem = item == nil
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(AddItemViewController.textFieldTextDidChange(notification:)),
                                       name : NSNotification.Name.UITextFieldTextDidChange,
                                       object: nameTextField)
    }
    
    @objc func textFieldTextDidChange(notification: NSNotification) {
        updateSaveButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        nameTextField.becomeFirstResponder()
    }
    
    @IBAction func cancel(sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func save(sender: Any) {
        let name = nameTextField.text! as NSString
        let number = NSNumber(value: numberStepper.value)
        
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        if item == nil {
            item = CKRecord(recordType: "Items")
            
            let listReference = CKReference(recordID: list.recordID, action: .deleteSelf)
            
            item?.setObject(listReference, forKey: "list")
        }
        
        item?.setObject(name, forKey: "name")
        item?.setObject(number, forKey: "number")
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        privateDatabase.save(item!) { (record, error) in
            DispatchQueue.main.sync {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                self.processResponse(record: record, error: error as NSError?)
            }
        }
    }
    
    @IBAction func numberDidChange(sender: UIStepper) {
        let number = Int(sender.value)
        
        numberLabel.text = "\(number)"
    }
    
    private func updateNumberStepper() {
        if let number = item?.object(forKey: "number") as? Double {
            numberStepper.value = number
        }
    }
    
    private func processResponse(record: CKRecord?, error: NSError?) {
        var message = ""
        
        if let error = error {
            print(error)
            message = "We were not able to save your item."
        } else if record == nil {
            message = "We were not able to save your item."
        }
        
        if !message.isEmpty {
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            
            present(alertController, animated: true, completion: nil)
        } else {
            if newItem {
                delegate?.controller(self, didAddItem: item!)
            } else {
                delegate?.controller(self, didUpdateItem: item!)
            }
            
            self.dismiss(animated: true)
        }
    }
    
    private func setupView() {
        updateNameTextField()
        updateSaveButton()
        updateNumberStepper()
    }
    
    private func updateNameTextField() {
        if let name = item?.object(forKey: "name") as? String {
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
    
    
    func textFieldDidChange(notification: NSNotification) {
        updateSaveButton()
    }
}
