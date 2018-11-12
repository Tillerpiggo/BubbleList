//
//  CAGradientLayer+Helpers.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/6/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import UIKit

extension CAGradientLayer {
    convenience init(frame: CGRect, colors: [UIColor]) {
        self.init()
        self.frame = frame
        self.colors = []
        for color in colors {
            self.colors?.append(color.cgColor)
        }
        
        startPoint = CGPoint(x: 0.2, y: 0.5)
        endPoint = CGPoint(x: 0.8, y: 0.5)
    }
    
    func createGradientImage() -> UIImage? {
        var image: UIImage? = nil
        UIGraphicsBeginImageContext(bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }
}
