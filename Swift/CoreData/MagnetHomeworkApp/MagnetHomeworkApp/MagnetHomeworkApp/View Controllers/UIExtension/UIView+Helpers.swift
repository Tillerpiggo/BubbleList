//
//  UIView+Helpers.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/6/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

extension UIView {
    func addDropShadow(color: UIColor, opacity: Float, radius: CGFloat, yOffset: CGFloat = 0.0) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize(width: 0, height: yOffset)
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: layer.bounds).cgPath
        layer.shouldRasterize = true
        
        layer.rasterizationScale = UIScreen.main.scale
    }
    
    func removeDropShadow() {
        layer.masksToBounds = true
    }
}
