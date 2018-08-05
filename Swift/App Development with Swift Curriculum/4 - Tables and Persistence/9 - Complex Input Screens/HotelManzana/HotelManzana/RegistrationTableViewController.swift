//
//  RegistrationTableViewController.swift
//  HotelManzana
//
//  Created by Tyler Gee on 7/22/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit

class RegistrationTableViewController: UITableViewController {
    
    // PROPERTIES:
    
    var registrations: [Registration] = []
    var selectedRegistration: Registration?
    
    // VIEW DID LOAD:

    override func viewDidLoad() {
        super.viewDidLoad()

        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    
    // TABLE VIEW DATA SOURCE:

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return registrations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RegistrationCell", for: indexPath)

        let registration = registrations[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        
        cell.textLabel?.text = "\(registration.firstName) \(registration.lastName)"
        cell.detailTextLabel?.text = "\(dateFormatter.string(from: registration.checkInDate)) - \(dateFormatter.string(from: registration.checkOutDate)): \(registration.roomType.name)"

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // NAVIGATION:

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "RegistrationDetail",
            let destinationViewController = segue.destination as? RegistrationDetailTableViewController else { return }
        
        if let selectedRow = tableView.indexPathForSelectedRow?.row {
            let registration = registrations[selectedRow]
            destinationViewController.registration = registration
            destinationViewController.navigationItem.title = "\(registration.firstName) \(registration.lastName)"
        }
    }
    
    @IBAction func unwindFromAddRegistration(unwindSegue: UIStoryboardSegue) {
        guard let addRegistrationTableViewController = unwindSegue.source as? AddRegistrationTableViewController,
            let registration = addRegistrationTableViewController.registration
            else { return }
        
        registrations.append(registration)
        tableView.reloadData()
    }

}
