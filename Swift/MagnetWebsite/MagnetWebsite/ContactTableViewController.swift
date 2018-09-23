//
//  ContactTableViewController.swift
//  MagnetWebsite
//
//  Created by Tyler Gee on 8/1/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

class ContactTableViewController: UITableViewController {
    
    @IBOutlet weak var contactTypeSegmentedControl: UISegmentedControl!
    var contacts: [ContactType: [[Contact]]] = [ContactType: [[Contact]]]()
    
    var selectedContactType: ContactType {
        if contactTypeSegmentedControl.selectedSegmentIndex == ContactType.magneto.rawValue {
            return .magneto
        } else {
            return .mentor
        }
    }
    
    enum ContactType: Int {
        case magneto = 0
        case mentor = 1
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 60
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func contactTypeChanged(_ sender: Any) {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if let contacts = contacts[selectedContactType] {
            return contacts.count
        } else {
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let contacts = contacts[selectedContactType] {
            return contacts[section].count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if selectedContactType == .magneto {
            switch section {
            case 0:
                return GradeLevel.freshman.rawValue
            case 1:
                return GradeLevel.sophomore.rawValue
            case 2:
                return GradeLevel.junior.rawValue
            case 3:
                return GradeLevel.senior.rawValue
            default:
                return "Magnetos"
            }
        } else {
            return "Mentors"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactTableViewCell
        
        let contact = contacts[selectedContactType]![indexPath.section][indexPath.row]
        
        cell.update(with: contact)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
