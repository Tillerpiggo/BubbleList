//
//  ContactTableViewCell.swift
//  MagnetWebsite
//
//  Created by Tyler Gee on 8/1/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var nameTextField: UILabel!
    @IBOutlet weak var emailTextField: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func update(with contact: Contact) {
        nameTextField.text = contact.name
        emailTextField.text = contact.email
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
