//
//  RegistrationDetailTableViewController.swift
//  HotelManzana
//
//  Created by Tyler Gee on 7/22/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit

class RegistrationDetailTableViewController: UITableViewController {
    
    var registration: Registration!
    
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var checkInDateLabel: UILabel!
    @IBOutlet weak var checkOutDateLabel: UILabel!
    @IBOutlet weak var numberOfAdultsLabel: UILabel!
    @IBOutlet weak var numberOfChildrenLabel: UILabel!
    @IBOutlet weak var wifiLabel: UILabel!
    @IBOutlet weak var roomTypeLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        update()
    }
    
    func update() {
        let firstNameString = registration.firstName == "" ? "Not Specified" : registration.firstName
        let lastNameString = registration.lastName == "" ? "Not Specified" : registration.lastName
        let emailAddressString = registration.emailAddress == "" ? "Not Specified" : registration.emailAddress
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        let checkInDateString = dateFormatter.string(from: registration.checkInDate)
        let checkOutDateString = dateFormatter.string(from: registration.checkOutDate)
        
        let numberOfAdultsString = "\(registration.numberOfAdults)"
        let numberOfChildrenString = "\(registration.numberOfChildren)"
        
        let wifiString = registration.wifi ? "Yes" : "No"
        let roomTypeString = registration.roomType.name
        
        
        firstNameLabel.text = firstNameString
        lastNameLabel.text = lastNameString
        emailLabel.text = emailAddressString
        checkInDateLabel.text = checkInDateString
        checkOutDateLabel.text = checkOutDateString
        numberOfAdultsLabel.text = numberOfAdultsString
        numberOfChildrenLabel.text = numberOfChildrenString
        wifiLabel.text = wifiString
        roomTypeLabel.text = roomTypeString
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
