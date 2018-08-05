//
//  ViewController.swift
//  Contest
//
//  Created by Tyler Gee on 7/26/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func enterButtonPressed() {
        let email = emailTextField.text ?? ""
        if email.isEmpty {
            UIView.animate(withDuration: 0.2, animations: {
                self.emailTextField.transform = CGAffineTransform(translationX: 10, y: 0)
            }) { (_) in
                self.emailTextField.transform = CGAffineTransform.identity
            }
        } else {
            performSegue(withIdentifier: "enterSegue", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

