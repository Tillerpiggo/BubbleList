//
//  ConnectionViewController.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 2/4/19.
//  Copyright © 2019 Beaglepig. All rights reserved.
//

import UIKit

class ConnectionViewController: UIViewController, DataCarrier, ConnectionViewDelegate {
    
    var cloudController: CloudController!
    var coreDataController: CoreDataController!
    
    @IBOutlet weak var connectionView: ConnectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureConnectionView()
        connectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setup()
//
        if cloudController.isConnectionViewDismissed {
            connectionView.transform = CGAffineTransform(translationX: 0, y: 36)
        } else {
            connectionView.transform = CGAffineTransform.identity
        }
        
        connectionView.isDismissed = cloudController.isConnectionViewDismissed
        print()
    }
    
    func hideConnectionView(animated: Bool, connected: Bool) {
        connectionView.dismiss(animated: animated, connected: connected)
        cloudController.isConnectionViewDismissed = false
    }
    
    func showConnectionView(animated: Bool) {
        connectionView.show(animated: animated)
        cloudController.isConnectionViewDismissed = false
    }
    
    func configureConnectionView() {
        // give connection view constraints, set delegates, and add set necessary text
        // also set color of cancelbutton and other setup
        connectionView.configure()
        
        connectionView.setConstraints()
        
        view.addConstraints(connectionView.constraints)
    }
}

extension ConnectionViewController {
    func didConnect(animated: Bool) {
        hideConnectionView(animated: animated, connected: true) // is connected because this is a call directly from a change in connection, not user input
    }
    
    func didDisconnect(animated: Bool) {
        showConnectionView(animated: animated)
    }
    
    func dismissed() {
        cloudController.isConnectionViewDismissed = true
    }
}
