//
//  AddAssignmentViewController.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/4/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

class AddAssignmentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 50
        //view.layer.masksToBounds = true
        view.backgroundColor = .white
        
        print("VIEW X: \(view.center.x)")
        print("VIEW Y: \(view.center.y)")
        print("VIEW WIDTH: \(view.bounds.width)")
        print("VIEW HEIGHT: \(view.bounds.height)")
    }
}
