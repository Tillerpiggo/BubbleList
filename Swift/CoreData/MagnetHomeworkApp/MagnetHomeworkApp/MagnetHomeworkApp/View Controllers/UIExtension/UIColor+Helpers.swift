//
//  UIColor+Helpers.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/6/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

extension UIColor {
    static var navigationBarColor: UIColor {
        let colorValue: CGFloat = 0.1
        return UIColor(red: colorValue, green: colorValue, blue: colorValue, alpha: 1.0)
    }
    
    static var accentColor: UIColor {
        //return UIColor(hue: 227/255, saturation: 80/100, brightness: 96/100, alpha: 1.0)
        return UIColor(red: 11/255, green: 93/255, blue: 217/255, alpha: 1.0)
        //return UIColor(red: 49/255, green: 129/255, blue: 247/255, alpha: 1.0)// Milder color
    }
    
    static var primaryColor: UIColor {
        //return UIColor(red: 0/255, green: 102/255, blue: 255/255, alpha: 1.0) // Last used color (correct one)
        let colorValue: CGFloat = 0.5
        return UIColor(red: colorValue, green: colorValue, blue: colorValue, alpha: 1.0)
    }
    
    static var highlightColor: UIColor {
        let colorValue: CGFloat = 0.7
        return UIColor(red: colorValue, green: colorValue, blue: colorValue, alpha: 1.0)
    }
    
    static var scheduleColor: UIColor {
        return UIColor(red: 67/255, green: 200/255, blue: 222/255, alpha: 1.0)
    }
    
    static var nothingDueColor: UIColor {
        return UIColor(red: 28/255, green: 206/255, blue: 34/255, alpha: 1.0)
    }
    
    static var lateColor: UIColor {
        return UIColor(red: 243/255, green: 93/255, blue: 93/255, alpha: 1.0)
    }
    
    static var unscheduledColor: UIColor {
        return UIColor(red: 254/255, green: 116/255, blue: 191/255, alpha: 1.0)
    }
    
    static var dueLaterColor: UIColor {
        return UIColor(red: 144/255, green: 116/255, blue: 254/255, alpha: 1.0)
    }
    
    static var dueTomorrowColor: UIColor {
        return UIColor(red: 243/255, green: 138/255, blue: 93/255, alpha: 1.0)
    }
    
    static var dueThisWeekColor: UIColor {
        return UIColor(red: 116/255, green: 188/255, blue: 254/255, alpha: 1.0)
    }
    
    static var actionTextColor: UIColor {
        return UIColor(red: 121/255, green: 184/255, blue: 194/255, alpha: 1.0)
    }
    
    static var deleteColor: UIColor {
        return UIColor(red: 246/255, green: 76/255, blue: 76/255, alpha: 1.0)
    }
    
    static var lightColor: UIColor {
        return UIColor(red: 0/255, green: 163/255, blue: 255/255, alpha: 1.0)
    }
    
    static var darkColor: UIColor {
        return UIColor(red: 22/255, green: 84/255, blue: 223/255, alpha: 1.0)
    }
    
    static var onDarkTextColor: UIColor {
        return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    static var textColor: UIColor {
        return UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
    }
    
    static var lightTextColor: UIColor {
        return UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
    }
}
