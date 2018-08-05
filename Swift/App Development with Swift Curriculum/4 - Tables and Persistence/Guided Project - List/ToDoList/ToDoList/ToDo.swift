//
//  ToDo.swift
//  ToDoList
//
//  Created by Tyler Gee on 7/25/18.
//  Copyright © 2018 Tyler Gee. All rights reserved.
//

import Foundation

class ToDo {
    var title: String
    var isComplete: Bool
    var dueDate: Date
    var notes: String?
    
    static func loadToDos() -> [ToDo]? {
        return nil
    }
    
    static let dueDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter
    }()
    
    init(title: String, isComplete: Bool, dueDate: Date, notes: String?) {
        self.title = title
        self.isComplete = isComplete
        self.dueDate = dueDate
        self.notes = notes
    }
    
    static func loadSampleToDos() -> [ToDo] {
        let todo1 = ToDo(title: "ToDo One", isComplete: false, dueDate: Date(), notes: "Notes 1")
        let todo2 = ToDo(title: "ToDo Two", isComplete: false, dueDate: Date(), notes: "Notes 2")
        let todo3 = ToDo(title: "ToDo Three", isComplete: false, dueDate: Date(), notes: "Notes 3")
        
        return [todo1, todo2, todo3]
    }
}
