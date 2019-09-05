//
//  DataCarrier.swift
//  MagnetHomeworkApp
//
//  Created by Tyler Gee on 2/16/19.
//  Copyright © 2019 Beaglepig. All rights reserved.
//

import Foundation
import UIKit
import Reachability
import CoreData

protocol DataCarrier: ConnectionDelegate {
    var cloudController: CloudController! { get set }
    var coreDataController: CoreDataController! { get set }
}

extension DataCarrier {
    func setup() {
        self.cloudController.delegate = self
        
        if cloudController.reachability.connection == .none {
            didDisconnect(connectionDidChange: false)
        } else {
            didConnect(connectionDidChange: false)
        }
    }
    
    // Syncs all unsynced Assignments, Classes, and ToDos with the Cloud
    private func syncData() {
        // 1. Get all objects from CoreData that are unsynced
        // Fetch Classes
        let fetchClasses: NSFetchRequest<Class> = Class.fetchRequest()
        fetchClasses.predicate = NSPredicate(format: "isSynced == false")
        
        guard let classes: [Class] = coreDataController.execute(fetchClasses) as? [Class] else {
            print("Unable to execute fetch request for classes in syncData() function of DataCarrier protocol")
            return
        }
        
        // Fetch Assignments
        let fetchAssignments: NSFetchRequest<Assignment> = Assignment.fetchRequest()
        fetchAssignments.predicate = NSPredicate(format: "isSynced == false")
        
        guard let assignments: [Assignment] = coreDataController.execute(fetchAssignments) as? [Assignment] else {
            print("Unable to execute fetch request for assignments in syncData() function of DataCarrier protocol")
            return
        }
        
        // Fetch ToDos
        let fetchToDos: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        fetchToDos.predicate = NSPredicate(format: "isSynced == false")
        
        guard let toDos: [ToDo] = coreDataController.execute(fetchToDos) as? [ToDo] else {
            print("Unable to execute fetch request for assignments in syncData() function of DataCarrier protocol")
            return
        }
        
        // Check that they actually have stuff in them before proceeding
        guard classes.count + assignments.count + toDos.count > 0 else {
            print("No unsynced items.")
            return
        }
        
        // 2. Sort them into private or public
        
        // Classes
        var privateClasses = [Class]()
        var sharedClasses = [Class]()
        for `class` in classes {
            if `class`.isUserCreated {
                privateClasses.append(`class`)
            } else {
                sharedClasses.append(`class`)
            }
        }
        
        // Assignments
        var privateAssignments = [Assignment]()
        var sharedAssignments = [Assignment]()
        for assignment in assignments {
            if assignment.owningClass?.isUserCreated ?? true {
                privateAssignments.append(assignment)
            } else {
                sharedAssignments.append(assignment)
            }
        }
        
        // ToDos - All ToDos are private. That's the point of ToDos.
        
        // Put them all together in one list of CloudUploadables
        var privateUnsyncedCloudUploadables: [CloudUploadable] = privateClasses + privateAssignments + toDos
        
        var sharedUnsyncedCloudUploadables: [CloudUploadable] = sharedClasses + sharedAssignments
        
        // 2. Save them to the Cloud
        
        // Private
        cloudController.save(&privateUnsyncedCloudUploadables, inDatabase: .private, recordChanged: { (record) in }) // TODO: implement proper closure/completion function
        
        // Shared
        cloudController.save(&sharedUnsyncedCloudUploadables, inDatabase: .shared, recordChanged: { (record) in }) // TODO: implement proper closure/completion function
    }
}
