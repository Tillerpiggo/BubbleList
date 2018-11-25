//
//  UIColor+Helpers.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/6/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import UIKit

class Theme {
    var primaryColor: UIColor
    var highlightColor: UIColor
    var destructiveColor: UIColor
    var backgroundColor: UIColor
    var separatorColor: UIColor
    var nothingDueColor: UIColor
    var lateColor: UIColor
    var unscheduledColor: UIColor
    var dueTomorrowColor: UIColor
    var dueThisWeekColor: UIColor
    var dueLaterColor: UIColor
    var textColor: UIColor
    var secondaryTextColor: UIColor
    var navigationBarTintColor: UIColor = .white
    
    init(primaryColor: UIColor,
         highlightColor: UIColor,
         destructiveColor: UIColor = basic.destructiveColor,
         backgroundColor: UIColor = basic.backgroundColor,
         separatorColor: UIColor = basic.separatorColor,
         nothingDueColor: UIColor = basic.nothingDueColor,
         lateColor: UIColor = basic.lateColor,
         unscheduledColor: UIColor = basic.unscheduledColor,
         dueTomorrowColor: UIColor = basic.dueTomorrowColor,
         dueThisWeekColor: UIColor = basic.dueThisWeekColor,
         dueLaterColor: UIColor = basic.dueLaterColor,
         textColor: UIColor = basic.textColor,
         secondaryTextColor: UIColor = basic.secondaryTextColor,
         navigationBarTintColor: UIColor = .white) {
        self.primaryColor = primaryColor
        self.highlightColor = highlightColor
        self.destructiveColor = destructiveColor
        self.backgroundColor = backgroundColor
        self.separatorColor = separatorColor
        self.nothingDueColor = nothingDueColor
        self.lateColor = lateColor
        self.unscheduledColor = unscheduledColor
        self.dueTomorrowColor = dueTomorrowColor
        self.dueThisWeekColor = dueThisWeekColor
        self.dueLaterColor = dueLaterColor
        self.textColor = textColor
        self.secondaryTextColor = secondaryTextColor
        self.navigationBarTintColor = navigationBarTintColor
    }
    
    static var _default: Theme {
        return red
    }
    
    static var basic: Theme {
        let theme = Theme(primaryColor: UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1),
                          highlightColor: UIColor(red: 0.07, green: 0.34, blue: 0.53, alpha: 1),
                          destructiveColor:  UIColor(red: 246/255, green: 76/255, blue: 76/255, alpha: 1),
                          backgroundColor: UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1),
                          separatorColor: UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1),
                          nothingDueColor: UIColor(red: 0.02, green: 0.72, blue: 0.43, alpha: 1),
                          lateColor: UIColor(red: 242/255, green: 48/255, blue: 48/255, alpha: 1),
                          unscheduledColor: UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1),
                          dueTomorrowColor: UIColor(red: 0.92, green: 0.72, blue: 0.37, alpha: 1),
                          dueThisWeekColor: UIColor(red: 0.42, green: 0.7, blue: 1, alpha: 1),
                          dueLaterColor: UIColor(red: 144/255, green: 116/255, blue: 254/255, alpha: 1.0),
                          textColor: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1),
                          secondaryTextColor: UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1))
//        let unscheduledColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
//
//        let theme = Theme(primaryColor: UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1),
//                                                highlightColor: UIColor(red: 0.07, green: 0.34, blue: 0.53, alpha: 1),
//                                                destructiveColor:  UIColor(red: 246/255, green: 76/255, blue: 76/255, alpha: 1),
//                                                backgroundColor: .white,
//                                                separatorColor: UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1),
//                                                nothingDueColor: unscheduledColor,
//                                                lateColor: UIColor(red: 242/255, green: 48/255, blue: 48/255, alpha: 1),
//                                                unscheduledColor: unscheduledColor,
//                                                dueTomorrowColor: unscheduledColor,
//                                                dueThisWeekColor: unscheduledColor,
//                                                dueLaterColor: unscheduledColor,
//                                                textColor: UIColor(red: 0.05, green: 0.05, blue: 0.05, alpha: 1),
//                                                secondaryTextColor: UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1))
        
        return theme
    }
    
    static var red: Theme {
        let theme = Theme(primaryColor: UIColor(red: 0.98, green: 0.3, blue: 0.38, alpha: 1),
                          highlightColor: UIColor(red: 0.95, green: 0.4, blue: 0.45, alpha: 1))
        
        return theme
    }
    
    static var blue: Theme {
        let theme = Theme(primaryColor: UIColor(red: 0.3, green: 0.65, blue: 0.89, alpha: 1),
                          highlightColor: UIColor(red: 0.17, green: 0.57, blue: 0.85, alpha: 1))
        return theme
    }
    
    static var green: Theme {
        let theme = Theme(primaryColor: UIColor(red: 0.22, green: 0.53, blue: 0.38, alpha: 1),
                          highlightColor: UIColor(red: 0.18, green: 0.47, blue: 0.33, alpha: 1))
        
        return theme
    }
    
    static var lowkey: Theme {
        let theme = Theme(primaryColor: UIColor(red: 0.7, green: 0.68, blue: 0.5, alpha: 1),
                          highlightColor: UIColor(red: 0.75, green: 0.71, blue: 0.36, alpha: 1),
                          backgroundColor: UIColor(red: 1, green: 0.99, blue: 0.88, alpha: 1))
        
        return theme
    }
}



extension UIColor {
    static var theme: Theme = Theme._default
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: alpha)
    }
    
    static var primaryColor: UIColor { return theme.primaryColor }
    static var highlightColor: UIColor { return theme.highlightColor }
    static var destructiveColor: UIColor { return theme.destructiveColor }
    static var backgroundColor: UIColor { return theme.backgroundColor }
    static var separatorColor: UIColor { return theme.separatorColor }
    static var nothingDueColor: UIColor { return theme.nothingDueColor }
    static var lateColor: UIColor { return theme.lateColor }
    static var unscheduledColor: UIColor { return theme.unscheduledColor }
    static var dueTomorrowColor: UIColor { return theme.dueTomorrowColor }
    static var dueThisWeekColor: UIColor { return theme.dueThisWeekColor }
    static var dueLaterColor: UIColor { return theme.dueLaterColor }
    static var textColor: UIColor { return theme.textColor }
    static var secondaryTextColor: UIColor { return theme.secondaryTextColor }
    static var navigationBarTintColor: UIColor { return theme.navigationBarTintColor }
    
    
    
    
//    static var nothingDueColor: UIColor {
//        //return UIColor(red: 112/255, green: 204/255, blue: 116/255, alpha: 1.0) // low saturation
//        return UIColor(red: 0.02, green: 0.72, blue: 0.43, alpha: 1)
//    }
//
//    static var lateColor: UIColor {
//        //return UIColor(red: 243/255, green: 93/255, blue: 93/255, alpha: 1.0) // low saturation
//        return UIColor(red: 242/255, green: 48/255, blue: 48/255, alpha: 1.0)
//    }
//
//    static var unscheduledColor: UIColor {
//        return UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1.0)
//    }
//
//    static var dueLaterColor: UIColor {
//        //return UIColor(red: 144/255, green: 116/255, blue: 254/255, alpha: 1.0) // low saturation
//        return UIColor(red: 112/255, green: 77/255, blue: 255/255, alpha: 1.0)
//    }
//
//    static var dueTomorrowColor: UIColor {
//        //return UIColor(red: 234/255, green: 189/255, blue: 103/255, alpha: 1.0) low saturation
//        return UIColor(red: 0.92, green: 0.72, blue: 0.37, alpha: 1)
//    }
//
//    static var dueThisWeekColor: UIColor {
//        //return UIColor(red: 116/255, green: 188/255, blue: 254/255, alpha: 1.0) low saturation
//        return UIColor(red: 0.42, green: 0.7, blue: 1, alpha: 1)
//    }
//
//    static var navigationBarColor: UIColor {
//        //return UIColor(red: 0.95, green: 0.3, blue: 0.41, alpha: 1)
//        //return UIColor(red: 0.97, green: 0.27, blue: 0.27, alpha: 1) // red
//        return UIColor(red: 0.8, green: 0.19, blue: 0.3, alpha: 1)
//        return UIColor(red: 0.85, green: 0.27, blue: 0.37, alpha: 1)
//        return UIColor(red: 0.83, green: 0.15, blue: 0.28, alpha: 1) //
//        //return UIColor(red: 0.82, green: 0.24, blue: 0.34, alpha: 1)
//        //return UIColor(red: 0.26, green: 0.78, blue: 1, alpha: 1)
//
//        let colorValue: CGFloat = 0.95
//        return UIColor(red: colorValue, green: colorValue, blue: colorValue, alpha: 1.0)
//    }
//
//    static var tabBarColor: UIColor {
//        //return UIColor(red: 0.95, green: 0.3, blue: 0.41, alpha: 1)
//        //return UIColor(red: 0.98, green: 0.38, blue: 0.38, alpha: 1) // red
//        //return UIColor(red: 0.8, green: 0.19, blue: 0.3, alpha: 1)
//        return UIColor(red: 0.85, green: 0.27, blue: 0.37, alpha: 1) //
//    }
//
//    static var navigationBarColor2: UIColor {
//        return UIColor(red: 0.06, green: 0.53, blue: 0.93, alpha: 1)
//    }
//
//    static var navigationBarTintColor: UIColor {
//        //return UIColor(red: 0.87, green: 0.06, blue: 0.31, alpha: 1)
//
//        let colorValue: CGFloat = 1.0
//        return UIColor(red: colorValue, green: colorValue, blue: colorValue, alpha: 1.0)
//
//        //return UIColor(red: 25/255, green: 105/255, blue: 196/255, alpha: 1.0)
//    }
//
//    static var accentColor: UIColor {
//        //return UIColor(hue: 227/255, saturation: 80/100, brightness: 96/100, alpha: 1.0)
//        return UIColor(red: 11/255, green: 93/255, blue: 217/255, alpha: 1.0)
//        //return UIColor(red: 49/255, green: 129/255, blue: 247/255, alpha: 1.0)// Milder color
//    }
//
//    static var primaryColor: UIColor {
//        //return UIColor(red: 0.95, green: 0.3, blue: 0.41, alpha: 1)
//        //return UIColor(red: 0.98, green: 0.38, blue: 0.38, alpha: 1) // red
//
//        return UIColor(red: 0.85, green: 0.27, blue: 0.37, alpha: 1)
//        return .navigationBarColor //
//        return UIColor(red: 0.84, green: 0.08, blue: 0.22, alpha: 1)
//        return UIColor(red: 0.93, green: 0.11, blue: 0.25, alpha: 1)
//        //return UIColor(red: 0/255, green: 102/255, blue: 255/255, alpha: 1.0) // Last used color (correct one)
//        let colorValue: CGFloat = 0.4
//        return UIColor(red: colorValue, green: colorValue, blue: colorValue, alpha: 1.0)
//    }
//
//    static var highlightColor: UIColor {
//        let colorValue: CGFloat = 0.7
//        return UIColor(red: colorValue, green: colorValue, blue: colorValue, alpha: 1.0)
//    }
//
//    static var scheduleColor: UIColor {
//        return UIColor(red: 67/255, green: 200/255, blue: 222/255, alpha: 1.0)
//    }
//
//    static var actionTextColor: UIColor {
//        return UIColor(red: 121/255, green: 184/255, blue: 194/255, alpha: 1.0)
//    }
//
//    static var deleteColor: UIColor {
//        return UIColor(red: 246/255, green: 76/255, blue: 76/255, alpha: 1.0)
//    }
//
//    static var lightColor: UIColor {
//        return UIColor(red: 0/255, green: 163/255, blue: 255/255, alpha: 1.0)
//    }
//
//    static var darkColor: UIColor {
//        return UIColor(red: 22/255, green: 84/255, blue: 223/255, alpha: 1.0)
//    }
//
//    static var onDarkTextColor: UIColor {
//        return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
//    }
//
//    static var textColor: UIColor {
//        let grayscaleValue: CGFloat = 0.1
//        return UIColor(red: grayscaleValue, green: grayscaleValue, blue: grayscaleValue, alpha: 1.0)
//    }
//
//    static var lightTextColor: UIColor {
//        return UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
//    }
}
