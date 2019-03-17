//
//  DueDate.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 3/12/19.
//  Copyright © 2019 Beaglepig. All rights reserved.
//

import Foundation

// This model object is designed to handle all translation of dueDates between Dates, Ints, and Strings,
// and handle all of the logic to determine how to refer to a given due date from a given point in time (now)
// Most of the logic is in the enum - the DueDate object itself is for ease of access and for updating and managing the DueDateType to do any extra required stuff (tbd via development)

//class DueDate {
//    var dueDate: Date
//    var dueDateType: DueDateType {
//        return DueDateType(withDueDate: dueDate)
//    }
//
//    init(withDueDate dueDate: Date) {
//        self.dueDate = dueDate
//    }
//}

enum DueDateType: Equatable {
    case completed
    case unscheduled
    case late
    case dueToday
    case dueTomorrow
    case dueMonday
    case dueTuesday
    case dueWednesday
    case dueThursday
    case dueFriday
    case dueSaturday
    case dueSunday
    case dueNextWeek
    case dueLater
    
    
    var section: Int {
        switch self {
        case .completed: return 20
        case .late: return 0
        case .unscheduled: return 1
        case .dueTomorrow: return 2
        case .dueMonday: return 3
        case .dueTuesday: return 4
        case .dueWednesday: return 5
        case .dueThursday: return 6
        case .dueFriday: return 7
        case .dueSaturday: return 8
        case .dueSunday: return 9
        case .dueNextWeek: return 10
        case .dueLater: return 11
        default: return -1
        }
    }
    
    var weekday: Weekday? {
        switch self {
        case .dueSunday: return .sunday
        case .dueMonday: return .monday
        case .dueTuesday: return .tuesday
        case .dueWednesday: return .wednesday
        case .dueThursday: return .thursday
        case .dueFriday: return .friday
        case .dueSaturday: return .saturday
        default: return nil
        }
    }
    
    var string: String {
        switch self {
        case .completed: return "Completed"
        case .late: return "Late"
        case .unscheduled: return "Unscheduled"
        case .dueTomorrow: return "Due Tomorrow"
        case .dueMonday, .dueTuesday, .dueWednesday, .dueThursday, .dueFriday, .dueSaturday, .dueSunday:
            guard let weekday = self.weekday else { return "Error occured in DueDateType.string definition"}
            return Date().weekday < weekday ? "Due \(weekday.string)" : "Due This Coming \(weekday.string)"
        default: return "???"
        }
    }
    
    init(withDueDate dueDate: Date) {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.day], from: Date().firstSecond, to: dueDate.firstSecond)
        
        guard let daysBetween = components.day else {
            self = .unscheduled
            return
        }
        
        guard dueDate.firstSecond >= Date().firstSecond else {
            self = .late
            return
        }
        
        if daysBetween == 0 {
            self = .dueToday
        } else if daysBetween == 1 {
            self = .dueTomorrow
        } else if daysBetween > 1 && daysBetween < 8 - Date().weekday.int { // This week, assuming the week starts/ends on Monday
            self.init(fromWeekday: dueDate.weekday)
        } else if daysBetween >= 8 - Date().weekday.int && daysBetween <= 15 - Date().weekday.int {
            self = .dueNextWeek
        } else {
            self = .dueLater
        }
    }
    
    private init(fromWeekday weekday: Weekday) {
        switch weekday {
        case .sunday: self = .dueSunday
        case .monday: self = .dueMonday
        case .tuesday: self = .dueTuesday
        case .wednesday: self = .dueWednesday
        case .thursday: self = .dueThursday
        case .friday: self = .dueFriday
        case .saturday: self = .dueSaturday
        }
    }
    
    
}

extension DueDateType: Comparable {
    static func < (lhs: DueDateType, rhs: DueDateType) -> Bool {
        return lhs.section < rhs.section
    }
}
