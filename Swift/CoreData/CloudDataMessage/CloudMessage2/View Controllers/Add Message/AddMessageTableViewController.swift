//
//  AddMessageTableViewController.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/4/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit
import CloudKit

protocol AddMessageTableViewControllerDelegate {
    func addedMessage(_ message: Message)
}

class AddMessageTableViewController: UITableViewController {
    
    // PROPERTIES:
    
    var delegate: AddMessageTableViewControllerDelegate?
    var coreDataController: CoreDataController!
    var owningConversation: CKReference!
    
    // IBOUTLETS:
    
    @IBOutlet weak private var textField: UITextField!
    @IBOutlet weak private var saveButton: UIBarButtonItem!
    
    // VIEW DID LOAD:

    override func viewDidLoad() {
        super.viewDidLoad()
        updateSaveButton()
    }
    
    // IBACTIONS:
    
    @IBAction private func saveButtonTapped(_ sender: Any) {
        save()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textFieldTextChanged(_ sender: UITextField) {
        updateSaveButton()
    }
    
    // DELEGATE:
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // HELPER METHODS:
    
    private func save() {
        let newMessage = Message(withText: textField.text!, timestamp: Date(), managedContext: coreDataController.managedContext, owningConversation: owningConversation)
        delegate?.addedMessage(newMessage)
    }
    
    private func updateSaveButton() {
        let text = textField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
}
