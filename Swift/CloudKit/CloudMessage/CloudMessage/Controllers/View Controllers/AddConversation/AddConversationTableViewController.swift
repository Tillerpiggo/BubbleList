//
//  AddConversationTableViewController.swift
//  CloudMessage
//
//  Created by Tyler Gee on 7/30/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

protocol AddConversationTableViewControllerDelegate {
    func addedConversation(_ conversation: Conversation)
}

class AddConversationTableViewController: UITableViewController {
    
    // PROPERTIES:
    
    public var conversation: Conversation?
    public var delegate: AddConversationTableViewControllerDelegate?
    
    
    // IBOUTLETS:
    
    @IBOutlet weak private var titleTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    // VIEW DID LOAD:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update(with: conversation)
        updateSaveButton()
    }
    
    
    // IBACTIONS:
    
    @IBAction private func saveButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        save()
    }
    
    @IBAction private func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textFieldTextChanged(_ sender: UITextField) {
        updateSaveButton()
    }
    
    
    // HELPER METHODS:
    
    private func save() {
        // This is the edit case. Not gonna worry about that rn
        guard conversation == nil else { return }
        
        let newConversation = Conversation(withTitle: titleTextField.text!, messages: [Message](), users: [User]())
        delegate?.addedConversation(newConversation)
    }
    
    private func update(with conversation: Conversation?) {
        guard let conversation = conversation else { return }
        
        titleTextField.text = conversation.title
    }
    
    private func updateSaveButton() {
        let titleText = titleTextField.text ?? ""
        saveButton.isEnabled = titleText.isEmpty ? false : true
    }
}
