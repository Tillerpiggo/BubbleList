//
//  CamperServiceTests.swift
//  CampgroundManagerTests
//
//  Created by Tyler Gee on 8/14/18.
//  Copyright © 2018 Razeware. All rights reserved.
//

import XCTest
import CampgroundManager
import CoreData

class CamperServiceTests: XCTestCase {
  // MARK: Properties:
  var camperService: CamperService!
  var coreDataStack: CoreDataStack!
  
    override func setUp() {
      super.setUp()
      
      coreDataStack = TestCoreDataStack()
      camperService = CamperService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
      
      camperService = nil
      coreDataStack = nil
    }
  
  func testAddCamper() {
    let camper = camperService.addCamper("Bacon Lover", phoneNumber: "910-543-9000")
    
    XCTAssertNotNil(camper, "Camper should not be nil")
    XCTAssertTrue(camper?.fullName == "Bacon Lover")
    XCTAssertTrue(camper?.phoneNumber == "910-543-9000")
  }
  
  func testRootContextIsSavedAfterAddingCamper() {
    let derivedContext = coreDataStack.newDerivedContext()
    camperService = CamperService(managedObjectContext: derivedContext, coreDataStack: coreDataStack)
    
    expectation(
      forNotification: NSNotification.Name.NSManagedObjectContextDidSave.rawValue,
      object: coreDataStack.mainContext) {
      notification in
      return true
    }
    
    derivedContext.perform {
      let camper = self.camperService.addCamper("Bacon Love", phoneNumber: "910-543-9000")
      XCTAssertNotNil(camper)
    }
    
    waitForExpectations(timeout: 2.0) { error in
      XCTAssertNil(error, "Save did not occur")
    }
  }
    
}
