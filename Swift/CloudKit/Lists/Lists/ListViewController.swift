//
//  ListTableViewController.swift
//  Lists
//
//  Created by Tyler Gee on 7/29/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit
import CloudKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AddItemViewControllerDelegate {
    
    static let ItemCell = "ItemCell"
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var list: CKRecord!
    var items = [CKRecord]()
    
    var selection: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        fetchItems()
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        cell.accessoryType = .detailDisclosureButton
        
        let item = items[indexPath.row]
        
        if let itemName = item.object(forKey: "name") as? String {
            cell.textLabel?.text = itemName
        } else {
            cell.textLabel?.text = "-"
        }
        
        if let itemNumber = item.object(forKey: "number") as? Int {
            cell.detailTextLabel?.text = "\(itemNumber)"
        } else {
            cell.detailTextLabel?.text = "1"
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selection = indexPath.row
        
        performSegue(withIdentifier: "ItemDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = items[indexPath.row]
            deleteRecord(item)
        }
    }
    
    func controller(_ controller: AddItemViewController, didAddItem item: CKRecord) {
        print(item)
        
        items.append(item)
        
        sortItems()
        
        tableView.reloadData()
        
        updateView()
    }
    
    func controller(_ controller: AddItemViewController, didUpdateItem item: CKRecord) {
        sortItems()
        
        items[selection!] = item
        
        tableView.reloadData()
    }
    
    private func deleteRecord(_ item: CKRecord) {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        privateDatabase.delete(withRecordID: item.recordID) { (recordID, error) in
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                self.processResponseForDeleteRequest(item, recordID: recordID, error: error as NSError?)
            }
        }
    }
    
    private func processResponseForDeleteRequest(_ record: CKRecord, recordID: CKRecordID?, error: NSError?) {
        var message = ""
        
        if let error = error {
            print(error)
            message = "We are unable to delete the item."
        } else if recordID == nil {
            message = "We are unable to delete the item."
        }
        
        if message.isEmpty {
            let index = items.index(of: record)
            
            if let index = index {
                items.remove(at: index)
                
                if items.count > 0 {
                    tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .right)
                } else {
                    messageLabel.text = "No Items Found"
                    
                    updateView()
                }
            }
        } else {
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            
            present(alertController, animated: true, completion: nil)
        }
    }
    private func sortItems() {
        items.sort() {
            var result = false
            let name0 = $0.object(forKey: "name") as? String
            let name1 = $1.object(forKey: "name") as? String
            
            if let name0 = name0, let name1 = name1 {
                result = name0.localizedCaseInsensitiveCompare(name1) == .orderedAscending
            }
            
            return result
        }
    }
    
    private func setupView() {
        tableView.isHidden = true
        messageLabel.isHidden = true
        activityIndicatorView.startAnimating()
    }
    
    private func updateView() {
        let hasRecords = items.count > 0
        
        tableView.isHidden = !hasRecords
        messageLabel.isHidden = hasRecords
        activityIndicatorView.stopAnimating()
    }
    
    private func fetchItems() {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        let reference = CKReference(recordID: list.recordID, action: .deleteSelf)
        let query = CKQuery(recordType: "Items", predicate: NSPredicate(format: "list == %@", reference))
        
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            DispatchQueue.main.async {
                self.processResponseForQuery(records: records, error: error as NSError?)
            }
        }
    }
    
    private func processResponseForQuery(records: [CKRecord]?, error: NSError?) {
        var message = ""
        
        if let error = error {
            print(error)
            message = "Error Fetching Items for List"
        } else if let records = records {
            items = records
            
            if items.count == 0 {
                message = "No Items Found"
            }
        } else {
            message = "No Items Found"
        }
        
        if message.isEmpty {
            tableView.reloadData()
        } else {
            messageLabel.text = message
        }
        
        updateView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "ItemDetail":
            let addItemViewController = segue.destination.childViewControllers.first! as! AddItemViewController
            
            addItemViewController.list = list
            addItemViewController.delegate = self
            
            if let selection = selection {
                let item = items[selection]
                
                addItemViewController.item = item
            }
        default:
            break
        }
    }
}
