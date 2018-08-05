//
//  AddRegistrationTableViewController.swift
//  HotelManzana
//
//  Created by Tyler Gee on 7/22/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit

class AddRegistrationTableViewController: UITableViewController, SelectRoomTypeTableViewControllerDelegate {
    
    // PROPERTIES:
    
    let checkInDatePickerCellIndexPath = IndexPath(row: 1, section: 1)
    let checkOutDatePickerCellIndexPath = IndexPath(row: 3, section: 1)
    
    var roomType: RoomType?
    
    // COMPUTED PROPERTIES:
    
    var isCheckInDatePickerShown: Bool = false {
        didSet {
            checkInDatePicker.isHidden = !isCheckInDatePickerShown // Hide it when it isn't shown
        }
    }
    
    var isCheckOutDatePickerShown: Bool = false {
        didSet {
            checkOutDatePicker.isHidden = !isCheckOutDatePickerShown
        }
    }
    
    var registration: Registration? {
        guard let roomType = roomType,
            let firstName = firstNameTextField.text, firstName != "",
            let lastName = lastNameTextField.text, lastName != ""
        else { return nil }
        
        let email = emailTextField.text ?? ""
        let checkInDate = checkInDatePicker.date
        let checkOutDate = checkOutDatePicker.date
        let numberOfAdults = Int(numberOfAdultsStepper.value)
        let numberOfChildren = Int(numberOfChildrenStepper.value)
        let hasWifi = wifiSwitch.isOn
        
        return Registration (
            firstName: firstName,
            lastName: lastName,
            emailAddress: email,
            checkInDate: checkInDate,
            checkOutDate: checkOutDate,
            numberOfAdults: numberOfAdults,
            numberOfChildren: numberOfChildren,
            roomType: roomType,
            wifi: hasWifi
        )
    }

    // IBOUTLETS:
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var checkInDateLabel: UILabel!
    @IBOutlet weak var checkInDatePicker: UIDatePicker!
    @IBOutlet weak var checkOutDateLabel: UILabel!
    @IBOutlet weak var checkOutDatePicker: UIDatePicker!
    
    @IBOutlet weak var numberOfAdultsLabel: UILabel!
    @IBOutlet weak var numberOfAdultsStepper: UIStepper!
    @IBOutlet weak var numberOfChildrenLabel: UILabel!
    @IBOutlet weak var numberOfChildrenStepper: UIStepper!
    
    @IBOutlet weak var wifiSwitch: UISwitch!
    
    @IBOutlet weak var roomTypeLabel: UILabel!
    
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    
    @IBOutlet weak var numberOfNightsLabel: UILabel!
    @IBOutlet weak var roomTypeCostLabel: UILabel!
    @IBOutlet weak var wifiCostLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    
    // VIEW DID LOAD:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateDateViews()
        updateNumberOfGuests()
        updateRoomType()
        updateDoneButton()
        updateCharges()
    }
    
    // IBACTIONS:
    
    @IBAction func datePickerValueChanged(_ sender: UIDatePicker) {
        updateDateViews()
        updateCharges()
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        updateNumberOfGuests()
    }
    
    @IBAction func wifiSwitchChanged(_ sender: UISwitch) {
        updateCharges()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func necessaryInfoChanged(_ sender: Any) {
        updateDoneButton()
        updateCharges()
    }
    
    
    // METHODS:
    
    func setupDatePickerDateRange() {
        let midnightToday = Calendar.current.startOfDay(for: Date())
        checkInDatePicker.minimumDate = midnightToday
        checkInDatePicker.date = midnightToday
        
        let timePerDay = TimeInterval(secondsPerDay())
        
        checkOutDatePicker.minimumDate = checkInDatePicker.date.addingTimeInterval(timePerDay)
    }
    
    func updateDateViews() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        checkInDateLabel.text = dateFormatter.string(from: checkInDatePicker.date)
        checkOutDateLabel.text = dateFormatter.string(from: checkOutDatePicker.date)
        
        updateCharges()
    }
    
    func updateNumberOfGuests() {
        numberOfAdultsLabel.text = "\(Int(numberOfAdultsStepper.value))"
        numberOfChildrenLabel.text = "\(Int(numberOfChildrenStepper.value))"
    }
    
    func updateRoomType() {
        if let roomType = roomType {
            roomTypeLabel.text = roomType.name
        } else {
            roomTypeLabel.text = "Not Set"
        }
    }
    
    func updateDoneButton() {
        if registration == nil {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
    }
    
    func updateCharges() {
        guard let numberOfNights: Int = Calendar.current.dateComponents([.day], from: checkInDatePicker.date, to: checkOutDatePicker.date).day,
            numberOfNights > 0
        else {
            numberOfNightsLabel.text = "Invalid"
            roomTypeCostLabel.text = roomType != nil ? "\(roomType!.shortName) - N/A" : "Not yet selected - N/A"
            wifiCostLabel.text = wifiSwitch.isOn ? "Yes - N/A" : "No - N/A"
            totalCostLabel.text = "N/A"
            
            return
        }
        
        numberOfNightsLabel.text = "\(numberOfNights)"
        
        var roomCost = 0
        
        if let roomType = roomType {
            roomCost = roomType.price * numberOfNights
            roomTypeCostLabel.text = "\(roomType.shortName) - $\(roomCost)"
        } else {
            roomTypeCostLabel.text = "Not yet selected"
        }
        
        let wifiCostPerDay = 10
        let wifiCost = wifiSwitch.isOn ? wifiCostPerDay * numberOfNights : 0
        let hasWifiString = wifiSwitch.isOn ? "Yes" : "No"
        wifiCostLabel.text = "\(hasWifiString) - $\(wifiCost)"
        
        let totalCost = roomCost + wifiCost
        totalCostLabel.text = "$\(totalCost)"
    }
    
    func secondsPerDay() -> Int {
        let secondsPerMinute = 60
        let minutesPerHour = 60
        let hoursPerDay = 24
        
        let secondsPerDay = secondsPerMinute * minutesPerHour * hoursPerDay
        return secondsPerDay
    }
    
    // TABLE VIEW DATA SOURCE:
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (checkInDatePickerCellIndexPath.section, checkInDatePickerCellIndexPath.row):
            if isCheckInDatePickerShown {
                return 216.0
            } else {
                return 0.0
            }
        case (checkOutDatePickerCellIndexPath.section, checkOutDatePickerCellIndexPath.row):
            if isCheckOutDatePickerShown {
                return 216.0
            } else {
                return 0.0
            }
        default:
            return 44.0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch (indexPath.section, indexPath.row) {
        case (checkInDatePickerCellIndexPath.section, checkInDatePickerCellIndexPath.row - 1):
            
            if isCheckInDatePickerShown {
                isCheckInDatePickerShown = false
            } else if isCheckOutDatePickerShown {
                isCheckInDatePickerShown = true
                isCheckOutDatePickerShown = false
            } else {
                isCheckInDatePickerShown = true
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
            
        case (checkOutDatePickerCellIndexPath.section, checkOutDatePickerCellIndexPath.row - 1):
            
            if isCheckOutDatePickerShown {
                isCheckOutDatePickerShown = false
            } else if isCheckInDatePickerShown {
                isCheckOutDatePickerShown = true
                isCheckInDatePickerShown = false
            } else {
                isCheckOutDatePickerShown = true
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
            
        default:
            break
        }
    }
    
    // SELECT ROOM TYPE DELEGATE:
    
    func didSelect(roomType: RoomType) {
        self.roomType = roomType
        updateRoomType()
        updateDoneButton()
        updateCharges()
    }
    
    // NAVIGATION:
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "SelectRoomType",
            let destinationViewController = segue.destination as? SelectRoomTypeTableViewController else { return }
        
        destinationViewController.delegate = self
        destinationViewController.roomType = roomType
    }
}
