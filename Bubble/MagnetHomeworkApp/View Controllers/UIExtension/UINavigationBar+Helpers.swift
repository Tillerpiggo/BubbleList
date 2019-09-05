//
//  UINavigationBar+Helpers.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/27/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    func configureNavigationBar() {
        self.navigationBar.barTintColor = .navigationBarTintColor
        self.navigationBar.tintColor = .tintColor
        
        let textAttributes: [NSAttributedString.Key: UIColor]  = [NSAttributedString.Key.foregroundColor: .titleColor]
        self.navigationBar.titleTextAttributes = textAttributes
        self.navigationBar.largeTitleTextAttributes = textAttributes
    }
}
