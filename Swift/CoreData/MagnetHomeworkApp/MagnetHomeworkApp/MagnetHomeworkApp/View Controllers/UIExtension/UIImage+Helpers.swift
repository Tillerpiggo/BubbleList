//
//  UIImage+Helpers.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/6/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    static func image(fromLayer layer: CALayer) -> UIImage {
        UIGraphicsBeginImageContext(layer.frame.size)
        
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let outputImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return outputImage!
    }
}
