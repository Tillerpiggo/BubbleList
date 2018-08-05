//
//  MiddleViewController.swift
//  OrderOfEvents
//
//  Created by Tyler Gee on 6/24/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import UIKit

class MiddleViewController: UIViewController {

    @IBOutlet weak var lifeCycleLabel: UILabel!
    
    var eventNumber: Int = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addEvent("viewDidLoad")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addEvent("viewWillAppear")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addEvent("viewDidAppear")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        addEvent("viewWillDisappear")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        addEvent("viewDidDisappear")
    }
    
    func addEvent(_ event: String) {
        if let existingText = lifeCycleLabel.text {
            lifeCycleLabel.text = "\(existingText)\nEvent number \(eventNumber) was \(event)"
            eventNumber += 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
