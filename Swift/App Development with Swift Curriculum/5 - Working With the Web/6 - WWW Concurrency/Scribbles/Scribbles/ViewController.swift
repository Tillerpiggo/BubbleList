//
//  ViewController.swift
//  Scribbles
//
//  Created by Tyler Gee on 7/27/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit
import CloudKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let container = CKContainer.default()
        
        if let containerIdentifier = container.containerIdentifier {
            print(containerIdentifier)
        }
    }
}

