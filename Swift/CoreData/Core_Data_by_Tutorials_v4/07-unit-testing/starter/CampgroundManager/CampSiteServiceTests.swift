//
//  CampSiteServiceTests.swift
//  CampgroundManagerTests
//
//  Created by Tyler Gee on 8/14/18.
//  Copyright © 2018 Razeware. All rights reserved.
//

import XCTest
import UIKit
import CampgroundManager
import CoreData

class CampSiteServiceTests: XCTestCase {
  
  // MARK: Properties
  var campSiteService: CampSiteService!
  var coreDataStack: CoreDataStack!
    
    override func setUp() {
        super.setUp()
      
      coreDataStack = TestCoreDataStack()
      campSiteService = CampSiteService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
      
      campSiteService = nil
      coreDataStack = nil
    }
    
  func testAddCampSite() {
    let campSite = campSiteService.addCampSite(1, electricity: true, water: true)
    
    XCTAssertTrue(campSite.siteNumber == 1, "Site number should be 1")
    XCTAssertTrue(campSite.electricity!.boolValue, "Site should have electricity")
    XCTAssertTrue(campSite.water!.boolValue, "Site should have water")
  }
  
  
  func testRootContextIsSavedAfterAddingCampsite() {
    let derivedContext = coreDataStack.newDerivedContext()
    
    campSiteService = CampSiteService(managedObjectContext: derivedContext, coreDataStack: coreDataStack)
    
    expectation(forNotification: NSNotification.Name.NSManagedObjectContextDidSave.rawValue,
                object: coreDataStack.mainContext) { notification in
                  return true
    }
    
    derivedContext.perform {
      let campSite = self.campSiteService.addCampSite(1, electricity: true, water: true)
      XCTAssertNotNil(campSite)
    }
    
    waitForExpectations(timeout: 2.0) { error in
      XCTAssertNil(error, "Save did not occur")
    }
  }
  
  func textGetCampSiteWithMatchingSiteNumber() {
    _ = campSiteService.addCampSite(1, electricity: true, water: true)
    
    let campSite = campSiteService.getCampSite(1)
    XCTAssertNotNil(campSite, "A campsite should be returned")
  }
  
  func textGetCampSiteNotMatchingSiteNumber() {
    _ = campSiteService.addCampSite(1, electricity: true, water: true)
    
    let campSite = campSiteService.getCampSite(2)
    XCTAssertNil(campSite, "No campsite should be returned")
  }
}
