//
//  ViewController.swift
//  Lists
//
//  Created by Tyler Gee on 7/28/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit
import CloudKit

class ListsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AddListViewControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    var lists = [CKRecord]()
    
    var selection: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        fetchLists()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath)
        
        // Configure cell
        cell.accessoryType = .detailDisclosureButton
        
        // Fetch model object
        let list = lists[indexPath.row]
        
        cell.textLabel?.text = (list.object(forKey: "name") as? String) ?? "-"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        selection = indexPath.row
        
        performSegue(withIdentifier: "ListDetail", sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let list = lists[indexPath.row]
            
            deleteRecord(list)
        }
    }
    
    func controller(controller: AddListViewController, didAddList list: CKRecord) {
        lists.append(list)
        sortLists()
        tableView.reloadData()
        
        updateView()
    }
    
    func controller(controller: AddListViewController, didUpdateList list: CKRecord) {
        // Sort lists
        sortLists()
        
        // Update table view
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        
        switch identifier {
        case "List":
            let listViewController = segue.destination as! ListViewController
            
            let list = lists[tableView.indexPathForSelectedRow!.row]
            
            listViewController.list = list
        case "ListDetail":
            let addListViewController = segue.destination.childViewControllers.first! as! AddListViewController
            
            addListViewController.delegate = self
            
            if let selection = selection {
                let list = lists[selection]
                
                addListViewController.list = list
            }
        default:
            break
        }
    }
}

extension ListsViewController {
    private func fetchUserRecordID() {
        // Fetch Default Container
        let defaultContainer = CKContainer.default()
        
        // Fetch User Record
        defaultContainer.fetchUserRecordID { (recordID, error) in
            if let responseError = error {
                print(responseError)
            } else if let userRecordID = recordID {
                DispatchQueue.main.async {
                    self.fetchUserRecord(recordID: userRecordID)
                }
            }
        }
    }
    
    private func fetchUserRecord(recordID: CKRecordID) {
        // Fetch Default Container
        let defaultContainer = CKContainer.default()
        
        // Fetch Private Database
        let privateDatabase = defaultContainer.privateCloudDatabase
        
        // Fetch User Record
        privateDatabase.fetch(withRecordID: recordID) { (record, error) in
            if let responseError = error {
                print(responseError)
            } else if let userRecord = record {
                print(userRecord)
            }
        }
    }
    
    private func fetchLists() {
        // Fetch Private Database
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        // Initialize Query
        let query = CKQuery(recordType: "Lists", predicate: NSPredicate(value: true))
        
        // Configure Query
        query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // Perform Query
        privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            if records?.isEmpty == true {
                DispatchQueue.main.sync {
                    self.messageLabel.text = "No Records Found"
                    self.updateView()
                }
            } else {
                records?.forEach({ (record) in
                    
                    guard error == nil else {
                        print(error?.localizedDescription as Any)
                        return
                    }
                    
                    print(record.value(forKey: "name") ?? "")
                    self.lists.append(record)
                    DispatchQueue.main.sync {
                        self.tableView.reloadData()
                        self.messageLabel.text = ""
                        self.updateView()
                    }
                })
            }
        }
    }
    
    private func updateView() {
        let hasRecords = self.lists.count > 0

        // The tableView will display if there are records, the message label will display if there are no records
        self.tableView.isHidden = !hasRecords
        self.messageLabel.isHidden = hasRecords
        self.activityIndicatorView.stopAnimating()
        self.activityIndicatorView.isHidden = true
    }
    
    private func setupView() {
        tableView.isHidden = true
        messageLabel.isHidden = true
        activityIndicatorView.startAnimating()
    }
    
    private func sortLists() {
        self.lists.sort {
            var result = false
            let name0 = $0.object(forKey: "name") as? String
            let name1 = $1.object(forKey: "name") as? String
            
            if let listName0 = name0, let listName1 = name1 {
                result = listName0.localizedCaseInsensitiveCompare(listName1) == .orderedAscending
            }
            
            return result
        }
    }
    
    private func deleteRecord(_ list: CKRecord) {
        let privateDatabase = CKContainer.default().privateCloudDatabase
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        privateDatabase.delete(withRecordID: list.recordID) { (recordID, error) in
            DispatchQueue.main.sync {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                self.processResponseForDeleteRequest(list, recordID: recordID, error: error)
            }
        }
    }
    
    private func processResponseForDeleteRequest(_ record: CKRecord, recordID: CKRecordID?, error: Error?) {
        var message = ""
        
        if let error = error {
            print(error)
            message = "We are unable to delete the list."
        } else if recordID == nil {
            message = "We are unable to delete the list."
        }
        
        if message.isEmpty {
            let index = self.lists.index(of: record)
            
            if let index = index {
                self.lists.remove(at: index)
                
                if lists.count > 0 {
                    self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                } else {
                    messageLabel.text = "No Records Found"
                    
                    updateView()
                }
            }
        } else {
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            
            present(alertController, animated: true, completion: nil)
        }
    }
}

