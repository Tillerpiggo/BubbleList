//
//  ConversationTableViewController.swift
//  CloudMessage
//
//  Created by Tyler Gee on 7/30/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

class ConversationTableViewController: UITableViewController, ConversationModelControllerDelegate, MessageTableViewControllerDelegate {
    
    // PROPERTIES:
    
    var conversationModelController = ConversationModelController()

    // VIEW LIFE CYCLE:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        conversationModelController.delegate = self
        conversationModelController.saveSubscription()
        
        addEditButton()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.delegates.append(conversationModelController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        conversationModelController.selectedIndex = nil
        
        conversationModelController.loadFromFile()
        conversationModelController.sortConversations(by: conversationModelController.sortType)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        conversationModelController.loadData() { (conversations) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.conversationModelController.saveToFile(conversations)
                self.conversationModelController.sortConversations(by: self.conversationModelController.sortType)
                self.tableView.reloadData()
            }
        }
    }
    
    // DELEGATES:
    
    func updateRecords() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func didChangeConversation(_ conversation: Conversation) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // METHODS:
    
    private func addEditButton() {
        self.navigationItem.leftBarButtonItem = editButtonItem
    }
    
    // NAVIGATION:
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination.childViewControllers.first as? AddConversationTableViewController, segue.identifier == "AddConversation" {
            destinationViewController.delegate = self
        } else if let destinationViewController = segue.destination as? MessageTableViewController, segue.identifier == "MessageTableView" {
            let selectedIndex = tableView.indexPathForSelectedRow?.row
            conversationModelController.selectedIndex = selectedIndex
            
            let selectedConversation = conversationModelController.selectedConversation!
            destinationViewController.navigationItem.title = selectedConversation.title
            
            destinationViewController.messageModelController = MessageModelController(withConversation: selectedConversation)
            destinationViewController.messageModelController.sortMessages()
            destinationViewController.delegates.append(self.conversationModelController)
            
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.delegates.append(destinationViewController.messageModelController)
        }
    }
}
