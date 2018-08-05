//
//  ViewController.swift
//  GettingStarted
//
//  Created by Tyler Gee on 5/20/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var names = ["tammy", "cole"]
        names.removeFirst()
        names.removeFirst()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

