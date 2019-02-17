//
//  DataCarrier.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 2/16/19.
//  Copyright © 2019 Beaglepig. All rights reserved.
//

import Foundation
import UIKit
import Reachability

protocol DataCarrier: ConnectionDelegate {
    var cloudController: CloudController! { get set }
    var coreDataController: CoreDataController! { get set }
}

extension DataCarrier {
    func setup() {
        self.cloudController.delegate = self
        
        if cloudController.reachability.connection == .none {
            didDisconnect(connectionDidChange: false)
        } else {
            didConnect(connectionDidChange: false)
        }
    }
}
