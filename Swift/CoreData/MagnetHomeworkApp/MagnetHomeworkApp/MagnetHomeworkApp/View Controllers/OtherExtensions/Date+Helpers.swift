//
//  Date+Helpers.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 11/8/18.
//  Copyright © 2018 Beaglepig. All rights reserved.
//

import Foundation


extension Date {
    static var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date().firstSecond)!
    }
    static var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date())!.firstSecond
    }
    static var thisFriday: Date {
        let calendar = Calendar(identifier: .gregorian)
        
        let friday = 6 // Friday
        let fridayComponents = DateComponents(calendar: calendar, weekday: friday)
        
        let thisFriday = calendar.nextDate(after: Date(), matching: fridayComponents, matchingPolicy: .nextTime)!
        
        return thisFriday.firstSecond
    }
    static var thisMonday: Date {
        let calendar = Calendar(identifier: .gregorian)
        
        let monday = 2 // Monday
        let mondayComponents = DateComponents(calendar: calendar, weekday: monday)
        
        let thisMonday = calendar.nextDate(after: Date(), matching: mondayComponents, matchingPolicy: .nextTimePreservingSmallerComponents)!
        
        return thisMonday.firstSecond
    }
    static func stringFromDate(_ date: Date?) -> String {
        guard let date = date else {
            return "None"
        }
        
        // Determine date using dateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        let dateString = dateFormatter.string(from: date)
        
        // Determine if the due date is even within two weeks (this or next)
        let calendar = Calendar(identifier: .gregorian)
        
        let components = calendar.dateComponents([.day, .year], from: Date().firstSecond, to: date.firstSecond)
        
        guard let daysBetween = components.day else {
            return dateString
        }
        
        guard Date() < date else {
            if daysBetween == 0 {
                return "Today"
            } else if daysBetween == -1 {
                return "Yesterday"
            } else {
                return "\(dateString) (Already Due)"
            }
        }
        if let yearsBetween = components.year, yearsBetween != 0 {
            dateFormatter.dateFormat = "MMM dd, YYYY"
            return dateFormatter.string(from: date)
        } else if daysBetween == 1 {
            return "Tomorrow"
        } else if daysBetween < 7 {
            if Date().weekday < date.weekday {
                return "this \(weekday.string)"
            } else {
                return "this coming \(stringFromWeekday(date.weekday))"
            }
        } else if daysBetween >= 7 && daysBetween < 14 {
            return "Next \(stringFromWeekday(date.weekday)), \(dateString)"
        } else {
            return dateString
        }
    }
    var dateString: String {
        return Date.stringFromDate(self)
    }
    
    static func stringFromWeekday(_ weekday: Int) -> String {
        switch weekday {
        case 1: return "Sunday"
        case 2: return "Monday"
        case 3: return "Tuesday"
        case 4: return "Wednesday"
        case 5: return "Thursday"
        case 6: return "Friday"
        case 7: return "Saturday"
        default: return "Someday"
        }
    }
    var weekday: Weekday {
        let weekdayInt = Calendar.current.component(.weekday, from: self)
        return Weekday(fromInt: weekdayInt)!
    }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: firstSecond)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: firstSecond)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var firstSecond: Date {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 1, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}

enum Weekday: Comparable {
    
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday
    
    var int: Int {
        switch self {
        case .sunday: return 1
        case .monday: return 2
        case .tuesday: return 3
        case .wednesday: return 4
        case .thursday: return 5
        case .friday: return 6
        case .saturday: return 7
        }
    }
    
    var string: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
    
    init?(fromInt int: Int) {
        guard int >= 1 && int <= 7 else { return nil }
        
        switch int {
        case 1: self = .sunday
        case 2: self = .monday
        case 3: self = .tuesday
        case 4: self = .wednesday
        case 5: self = .thursday
        case 6: self = .friday
        case 7: self = .saturday
        default:
            print("Something screwed up in enum Weekday { ... }; make sure the guard statement has the correct bounds.")
            self = .monday
        }
    }
    
    // Comparable
    static func < (lhs: Weekday, rhs: Weekday) -> Bool {
        return lhs.int < rhs.int
    }
}
