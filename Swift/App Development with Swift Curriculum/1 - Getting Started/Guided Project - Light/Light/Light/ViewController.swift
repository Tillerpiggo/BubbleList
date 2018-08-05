//
//  ViewController.swift
//  Light
//
//  Created by Tyler Gee on 5/28/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var lightOn = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set lightButton's title to the appropriate starting value ("Off")
        updateUI()
        
    }

    @IBAction func buttonPressed(_ sender: Any) {
        lightOn = !lightOn //toggle lightOn
        updateUI()
    }
    
    func updateUI() {
        // If the light is on, make the background white. Otherwise, make it black.
        view.backgroundColor = lightOn ? .white: .black
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

