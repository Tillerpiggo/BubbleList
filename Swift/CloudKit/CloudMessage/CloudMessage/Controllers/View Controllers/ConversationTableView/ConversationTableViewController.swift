//
//  ConversationTableViewController.swift
//  CloudMessage
//
//  Created by Tyler Gee on 7/30/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

class ConversationTableViewController: UITableViewController, ConversationModelControllerDelegate {
    
    var conversationModelController = ConversationModelController()

    override func viewDidLoad() {
        super.viewDidLoad()
        conversationModelController.delegate = self
        conversationModelController.saveSubscription()
        
        addEditButton()
        conversationModelController.loadFromFile()
        conversationModelController.sortConversations(by: conversationModelController.sortType)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        conversationModelController.loadData() { (conversations) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.conversationModelController.saveToFile(conversations)
                self.tableView.reloadData()
            }
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.delegate = conversationModelController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        conversationModelController.selectedIndex = nil
        tableView.reloadData()
    }
    
    func updateRecords() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    
    private func addEditButton() {
        self.navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination.childViewControllers.first as? AddConversationTableViewController, segue.identifier == "AddConversation" {
            destinationViewController.delegate = self
        } else if let destinationViewController = segue.destination as? MessageTableViewController, segue.identifier == "MessageTableView" {
            let selectedIndex = tableView.indexPathForSelectedRow?.row
            conversationModelController.selectedIndex = selectedIndex
            
            let selectedConversation = conversationModelController.selectedConversation!
            destinationViewController.navigationItem.title = selectedConversation.title
            destinationViewController.messageModelController = MessageModelController(withConversation: selectedConversation)
            destinationViewController.messageModelController.delegate = conversationModelController
        }
    }
}
