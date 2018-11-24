//
//  UIApplication+Helpers.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/24/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    var statusBarView: UIView? {
        if responds(to: Selector("statusBar")) {
            return value(forKey: "statusBar") as? UIView
        }
        return nil
    }
}
