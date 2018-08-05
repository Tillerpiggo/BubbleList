//
//  ViewController.swift
//  Login
//
//  Created by Tyler Gee on 6/22/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var forgotUsernameButton: UIButton!
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func forgotUsername(_ sender: Any) {
        performSegue(withIdentifier: "ForgotUsernameOrPassword", sender: forgotUsernameButton)
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        performSegue(withIdentifier: "ForgotUsernameOrPassword", sender: forgotPasswordButton)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Make sure that the sender is a UIButton
        guard let sender = sender as? UIButton else { return }
        
        // If the sender is forgotUsernameButton, make the title "Forgot Username"
        if sender == forgotUsernameButton {
            segue.destination.navigationItem.title = "Forgot Username"
        } else if sender == forgotPasswordButton {
            segue.destination.navigationItem.title = "Forgot Password"
        } else {
            segue.destination.navigationItem.title = usernameTextField.text
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

