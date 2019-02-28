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
    var contentColor: UIColor
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
    var tintColor: UIColor = .white
    var titleColor: UIColor = .white
    var sectionColor: UIColor = .white
    var tabBarTintColor: UIColor = .white
    
    init(primaryColor: UIColor,
         highlightColor: UIColor? = nil,
         contentColor: UIColor = basic.contentColor,
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
         navigationBarTintColor: UIColor = basic.navigationBarTintColor,
         tintColor: UIColor? = nil,
         titleColor: UIColor = basic.titleColor,
         sectionColor: UIColor = basic.sectionColor) {
        self.primaryColor = primaryColor
        self.highlightColor = highlightColor ?? primaryColor
        self.contentColor = contentColor
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
        self.tintColor = tintColor ?? primaryColor
        self.titleColor = titleColor
        self.sectionColor = sectionColor
    }
    
    static var _default: Theme {
        return red
    }
    
    static var good: Theme {
        let theme = Theme(primaryColor: UIColor(red: 80/255, green: 150/255, blue: 230/266, alpha: 1),
                          contentColor: .white,
                          backgroundColor: .white,//UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1),
                          navigationBarTintColor: UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1))
        
        theme.tintColor = .white
        theme.textColor = .black
        theme.tabBarTintColor = .white
        
        return theme
    }
    
    static var basic: Theme {
        let theme = Theme(primaryColor: UIColor(red: 0/255, green: 149/255, blue: 255/255, alpha: 1),
                          highlightColor: UIColor(red: 40/255, green: 179/255, blue: 255/255, alpha: 1),
                          contentColor: .white,//UIColor(red: 0.93, green: 0.43, blue: 0.46, alpha: 1),, //UIColor(red: 0.93, green: 0.43, blue: 0.46, alpha: 1),
                          destructiveColor:  UIColor(red: 246/255, green: 76/255, blue: 76/255, alpha: 1),
                          backgroundColor: .white,
                          separatorColor: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1),
                          nothingDueColor: UIColor(red: 0.02, green: 0.72, blue: 0.43, alpha: 1),
                          lateColor: UIColor(red: 0.8, green: 0.28, blue: 0.28, alpha: 1),
                          unscheduledColor: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1),
                          dueTomorrowColor: UIColor(red: 0.95, green: 0.59, blue: 0.26, alpha: 1),
                          dueThisWeekColor: UIColor(red: 0.42, green: 0.7, blue: 0.91, alpha: 1), // UIColor(red: 0.23, green: 0.63, blue: 0.92, alpha: 1)
                          dueLaterColor: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0),
                          textColor: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1),
                          secondaryTextColor: UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3),
                          navigationBarTintColor: UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 0.9),
                          titleColor: .black,
                          sectionColor: UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1))
        
        theme.tintColor = theme.primaryColor
        //theme.tabBarTintColor = theme.primaryColor
        
        return theme
    }
    
    static var experimental: Theme {
        let theme = Theme(primaryColor: basic.primaryColor,
                          highlightColor: .white,
                          lateColor: UIColor(red: 0.8, green: 0.28, blue: 0.28, alpha: 1),
                          unscheduledColor: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1),
                          dueTomorrowColor: UIColor(red: 0.95, green: 0.59, blue: 0.26, alpha: 1),
                          dueThisWeekColor: UIColor(red: 0.42, green: 0.7, blue: 0.91, alpha: 1),
                          titleColor: .black)
        
        return theme
    }
    
    static var darkBlue: Theme {
        let theme = Theme(primaryColor: UIColor(red: 0.36, green: 0.67, blue: 0.96, alpha: 1),
                          backgroundColor: UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1),
                          navigationBarTintColor: UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1),
                          titleColor: .white)
        
        theme.tintColor = .white
        theme.contentColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        
        return theme
    }
    
    static var coloredBasic: Theme {
        let theme = Theme(primaryColor: UIColor(red: 0.36, green: 0.67, blue: 0.96, alpha: 1),
                          highlightColor: UIColor(red: 0.36, green: 0.67, blue: 0.96, alpha: 1),
                          destructiveColor:  UIColor(red: 246/255, green: 76/255, blue: 76/255, alpha: 1),
                          backgroundColor: UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1),
                          separatorColor: UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1),
                          nothingDueColor: UIColor(red: 0.02, green: 0.72, blue: 0.43, alpha: 1),
                          lateColor: UIColor(red: 242/255, green: 48/255, blue: 48/255, alpha: 1),
                          unscheduledColor: UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1),
                          dueTomorrowColor: UIColor(red: 0.92, green: 0.72, blue: 0.37, alpha: 1),
                          dueThisWeekColor: UIColor(red: 0.42, green: 0.7, blue: 1, alpha: 1),
                          dueLaterColor: UIColor(red: 144/255, green: 116/255, blue: 254/255, alpha: 1.0),
                          textColor: UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1),
                          secondaryTextColor: UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1))
        
        return theme
    }
    
    static var llama: Theme {
        let theme = Theme(primaryColor: UIColor(red: 0.13, green: 0.6, blue: 0.86, alpha: 1),
                          contentColor: .white,
                          backgroundColor: .white,
                          navigationBarTintColor: UIColor(red: 0.36, green: 0.32, blue: 0.25, alpha: 1),
                          sectionColor: UIColor(red: 0.97, green: 0.92, blue: 0.84, alpha: 1))
        theme.tintColor = .white
        theme.tabBarTintColor = theme.backgroundColor
        theme.separatorColor = UIColor(red: 0.92, green: 0.89, blue: 0.86, alpha: 1)

        return theme
    }
    
    static var iOS: Theme {
        let theme = Theme(primaryColor: UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1),
                          navigationBarTintColor: .white)
        theme.tintColor = theme.primaryColor
        theme.backgroundColor = .white
        theme.textColor = .black
        theme.separatorColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        theme.titleColor = .black
        
        return theme
    }
    
    static var dark: Theme {
        let theme = Theme(primaryColor: basic.primaryColor,
                          backgroundColor: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1))
        
        return theme
    }
    
    static var red: Theme {
        var primaryColor: UIColor = UIColor(red: 242/255, green: 98/255, blue: 92/255, alpha: 1) // old color
        
        let theme = Theme(primaryColor: primaryColor)
        theme.textColor = .black
        theme.highlightColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        theme.separatorColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        theme.titleColor = .white
        theme.navigationBarTintColor = theme.primaryColor
        theme.tintColor = .white
        
        return theme
    }
    
    static var basicPink: Theme {
        let theme = Theme(primaryColor: basic.primaryColor,
                          highlightColor: UIColor(red: 0.93, green: 0.43, blue: 0.55, alpha: 1))
        
        return theme
    }
    
    static var basicOrange: Theme {
        let theme = Theme(primaryColor: basic.primaryColor,
                          highlightColor: UIColor(red: 0.97, green: 0.51, blue: 0.41, alpha: 1))
        return theme
    }
    
    static var blue: Theme {
        let theme = Theme(primaryColor: UIColor(red: 0.09, green: 0.51, blue: 0.9, alpha: 1),
                          navigationBarTintColor: UIColor(red: 0, green: 0.39, blue: 0.85, alpha: 1))
        theme.tintColor = .white
        //theme.tabBarTintColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 0.5)
        
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
    static var contentColor: UIColor { return theme.contentColor }
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
    static var tintColor: UIColor { return theme.tintColor }
    static var titleColor: UIColor { return theme.titleColor }
    static var sectionColor: UIColor { return theme.sectionColor }
    static var tabBarTintColor: UIColor { return theme.tabBarTintColor }
    
    static func color(fromSection section: String) -> UIColor {
        let allCapsSection = section.uppercased()
        switch allCapsSection {
        case "LATE":
            return .lateColor
        case "UNSCHEDULED":
            return .unscheduledColor
        case "DUE TOMORROW":
            return .dueTomorrowColor
        case "DUE THIS WEEK":
            return .dueThisWeekColor
        case "DUE LATER":
            return .dueLaterColor
        case "COMPLETED":
            return .primaryColor
        default:
            return .primaryColor
        }
    }
}
