//
//  AddConversationTableViewController.swift
//  CloudMessage2
//
//  Created by Tyler Gee on 8/4/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

protocol AddConversationTableViewControllerDelegate {
    func addedConversation(_ conversation: Conversation)
}

class AddConversationTableViewController: UITableViewController {
    
    // PROPERTIES:
    
    public var delegate: AddConversationTableViewControllerDelegate?
    var coreDataController: CoreDataController!

    // IBOUTLETS:
    
    @IBOutlet weak private var titleTextField: UITextField!
    @IBOutlet weak private var saveButton: UIBarButtonItem!
    
    // VIEW DID LOAD:
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // IBACTIONS:
    
    @IBAction private func saveButtonTapped(_ sender: Any) {
        save()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func cancelButtonTapepd(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textFieldTextChanged(_ sender: UITextField) {
        updateSaveButton()
    }
    
    // HELPER METHODS:
    
    private func save() {
        let newConversation = Conversation(withTitle: titleTextField.text!, managedContext: coreDataController.managedContext)
        delegate?.addedConversation(newConversation)
    }
    
    private func updateSaveButton() {
        let titleText = titleTextField.text ?? ""
        saveButton.isEnabled = !titleText.isEmpty
    }

    
    // TABLE VIEW:
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
