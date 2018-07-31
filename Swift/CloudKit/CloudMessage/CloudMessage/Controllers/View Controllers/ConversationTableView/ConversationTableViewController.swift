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
        conversationModelController.delegate? = self
        
        addEditButton()
        conversationModelController.loadFromFile()
        conversationModelController.sortConversations(by: .title)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        conversationModelController.loadData() { (conversations) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.delegate? = conversationModelController
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationViewController = segue.destination.childViewControllers.first as? AddConversationTableViewController,
            segue.identifier == "AddConversation" else { return }
        
        destinationViewController.delegate = self
    }
    
    func updateRecords() {
        tableView.reloadData()
    }
    
    private func addEditButton() {
        self.navigationItem.leftBarButtonItem = editButtonItem
    }
}
