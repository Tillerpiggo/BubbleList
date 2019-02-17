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
    // If it is triggered by a change in connection, it should ALWAYS be displayed
    // If it is triggered by the loading of a view, it should be checked
    
    func didConnect(connectionDidChange: Bool = true) {
        // is connected because this is a call directly from a change in connection, not user input
        
        if connectionDidChange {
            if cloudController.isConnectionViewDismissed == true {
                cloudController.isConnectionViewDismissed = false
                connectionView.setConnected(animated: false, completion: nil)
                connectionView.show(animated: connectionDidChange, completion: { (bool) in
                    self.connectionView.dismiss(completion: nil)
                    self.cloudController.isConnectionViewDismissed = true
                })
            } else { // If it is not dismissed and already shown
                connectionView.setConnected(animated: connectionDidChange, completion: { (bool) in
                    self.connectionView.dismiss(animated: connectionDidChange, completion: nil)
                })
            }
        } else {
            if cloudController.isConnectionViewDismissed == true {
                // If the connection didn't change and it's dismissed, DON'T show it (to preserve consistency between views)
                
                connectionView.setConnected(animated: false, completion: nil)
                cloudController.isConnectionViewDismissed = false
            } else {
                connectionView.setConnected(animated: connectionDidChange, completion: { (bool) in
                    self.connectionView.dismiss(animated: connectionDidChange, completion: nil)
                })
            }
        }
    }
    
    func didDisconnect(connectionDidChange: Bool = true) {
        if connectionDidChange {
            cloudController.isConnectionViewDismissed = false
            
            if cloudController.isConnectionViewDismissed == true {
                connectionView.setOffline(animated: false, completion: nil)
            } else {
                connectionView.setOffline(animated: connectionDidChange, completion: nil)
                connectionView.show(animated: connectionDidChange, completion: nil)
            }
        } else {
            connectionView.setOffline(animated: connectionDidChange, completion: nil)
            
            // If it's dismissed, don't show it; if it's not dismissed, show it
            if cloudController.isConnectionViewDismissed == true {
                connectionView.dismiss(animated: connectionDidChange, completion: nil)
            } else {
                connectionView.show(animated: connectionDidChange, completion: nil)
            }
        }
    }
    
    func dismissed() {
        cloudController.isConnectionViewDismissed = true
    }
}
