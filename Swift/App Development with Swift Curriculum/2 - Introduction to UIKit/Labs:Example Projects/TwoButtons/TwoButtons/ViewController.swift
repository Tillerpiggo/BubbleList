//
//  ViewController.swift
//  TwoButtons
//
//  Created by Tyler Gee on 6/18/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // IBOutlets:
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    // View Did Load:
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // IBActions:
    @IBAction func setTextButtonTapped(_ sender: Any) {
        // set the text label to the value entered in the text field
        textLabel.text = textField.text
    }
    
    @IBAction func clearTextButtonTapped(_ sender: Any) {
        // clear both the text label and the text field (by setting their values to empty strings)
        textLabel.text = ""
        textField.text = ""
    }
    
    @IBAction func textFieldDidReturn(_ sender: UITextField) {
        // Make the keyboard go away when you press return (in this case, "Done")
        sender.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

