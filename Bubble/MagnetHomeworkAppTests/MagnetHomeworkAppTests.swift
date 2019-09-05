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
    
    func testGetAssignmentFromCloud() {
        let owningClass = Class(withName: "TestClass", assignments: [], managedContext: coreDataStack.managedContext, zoneID: testZoneID)
        
        let record = CKRecord(recordType: "Assignment")
        record["text"] = "Test"
        record["dueDate"] = Date(timeIntervalSince1970: 0)
        
        XCTAssertNil(record.creationDate)
        XCTAssertNil(record.modificationDate)
        
        //let creationDate = record.creationDate?
        //let modificationDate = record.modificationDate?

        let assignment = Assignment(fromRecord: record, owningClass: owningClass, managedContext: coreDataStack.managedContext)
        
        XCTAssertTrue(assignment.text == "Test")
        XCTAssertTrue(assignment.dueDate?.date as Date? == Date(timeIntervalSince1970: 0))
        //XCTAssertTrue(assignment.creationDate as Date? == creationDate)
        //XCTAssertTrue(assignment.dateLastModified as Date? == modificationDate)
        XCTAssertTrue(assignment.encodedSystemFields == record.encoded())
        XCTAssertTrue(assignment.owningClass == owningClass)
        XCTAssertFalse(assignment.isSynced)
        XCTAssertFalse(assignment.isCompleted)
    }
    
    func testAssignmentCKRecord() {
        let owningClass = Class(withName: "TestClass", assignments: [], managedContext: coreDataStack.managedContext, zoneID: testZoneID)
        
        let assignment = Assignment(withText: "Test", managedContext: coreDataStack.managedContext, owningClass: owningClass, zoneID: testZoneID, toDoZoneID: testZoneID)
        let date = Date()
        assignment.dueDate?.date = date as NSDate?
        
        XCTAssertNotNil(assignment.encodedSystemFields)
        
        let record = assignment.ckRecord
        XCTAssertTrue(record["text"] == "Test")
        XCTAssertTrue(record["dueDate"] == date)
        XCTAssertTrue(record.encoded() == assignment.encodedSystemFields)
    }

}

