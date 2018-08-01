//
//  MessageTableDataSource.swift
//  CloudMessage
//
//  Created by Tyler Gee on 7/30/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

// Table view data source and delegate

extension MessageTableViewController {
    
    // DATA SOURCE:
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageModelController.conversation.messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        
        let message = messageModelController.conversation.messages[indexPath.row]
        
        cell.textLabel?.text = message.text
        cell.detailTextLabel?.text = message.formattedTimestamp
        
        return cell
    }
    
    // DELEGATE:
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
