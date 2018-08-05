//
//  ViewController.swift
//  IBBasics
//
//  Created by Tyler Gee on 5/27/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var myButton: UIButton!
    
    @IBAction func buttonPressed(_ sender: Any) {
        print("The button was pressed")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // set myButton's title to red:
        myButton.setTitleColor(.red, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

