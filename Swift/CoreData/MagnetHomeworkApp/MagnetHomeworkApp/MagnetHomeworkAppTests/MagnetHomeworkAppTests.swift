//
//  MagnetHomeworkAppTests.swift
//  MagnetHomeworkAppTests
//
//  Created by Tyler Gee on 3/25/19.
//  Copyright © 2019 Beaglepig. All rights reserved.
//

import XCTest
@testable import MagnetHomeworkApp
import CoreData
import CloudKit

class MagnetHomeworkAppTests: XCTestCase {
    
    // MARK: Properties
    var testClass: Class!
    var coreDataStack: CoreDataStack!
    var cloudController: CloudController!
    
    let testZoneID = CKRecordZone.ID(zoneName: "TestZone", ownerName: "OwnerName")

    override func setUp() {
        super.setUp()
        
        coreDataStack = TestCoreDataStack()
        testClass = Class(context: coreDataStack.managedContext)
    }

    override func tearDown() {
        super.tearDown()
        
        testClass = nil
        coreDataStack = nil
    }

    func testAddClass() {
        let newClass = Class(withName: "Test", assignments: [], managedContext: coreDataStack.managedContext, zoneID: testZoneID)
        
        XCTAssertNotNil(newClass, "New class should not be nil")
        XCTAssertTrue(newClass.name == "Test")
    }
    
    func testAddAssignment() {
        let newClass = Class(withName: "Test", assignments: [], managedContext: coreDataStack.managedContext, zoneID: testZoneID)
        let newAssignment = Assignment(withText: "Test", managedContext: coreDataStack.managedContext, owningClass: newClass, zoneID: testZoneID, toDoZoneID: testZoneID)
        newClass.addToAssignments(newAssignment)
        
        XCTAssertNotNil(newAssignment, "New assignment should not be nil")
        XCTAssertTrue(newAssignment.text == "Test")
        XCTAssertNotNil(newAssignment.toDo)
        XCTAssertTrue(newAssignment.toDo?.isCompleted == false)
        
        XCTAssertNotNil(newAssignment.owningClass)
        //XCTAssertNotNil(newAssignment.owningClass?.previewAssignment())
        XCTAssertNotNil(newAssignment.owningClass?.previewAssignments())
        XCTAssertTrue(newAssignment.owningClass?.previewAssignments()?.first?.text == "Test")
        XCTAssertNotNil(newAssignment.owningClass?.name == "Test")
    }

}

