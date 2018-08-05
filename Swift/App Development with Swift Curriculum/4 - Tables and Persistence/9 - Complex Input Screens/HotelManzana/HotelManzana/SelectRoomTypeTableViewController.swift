//
//  SelectRoomTypeTableViewController.swift
//  HotelManzana
//
//  Created by Tyler Gee on 7/22/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit

class SelectRoomTypeTableViewController: UITableViewController {
    
    var delegate: SelectRoomTypeTableViewControllerDelegate?
    
    var roomType: RoomType?

    // VIEW DID LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


    // TABLE VIEW DATA SOURCE

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return RoomType.all.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomTypeCell", for: indexPath)
        let roomType = RoomType.all[indexPath.row]
        
        cell.textLabel?.text = roomType.name
        cell.detailTextLabel?.text = "$\(roomType.price)"
        
        if roomType == self.roomType {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        roomType = RoomType.all[indexPath.row]
        delegate?.didSelect(roomType: roomType!)
        tableView.reloadData()
    }
}

protocol SelectRoomTypeTableViewControllerDelegate {
    func didSelect(roomType: RoomType)
}
