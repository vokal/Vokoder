//
//  ManagedObjectContextTests.swift
//  SwiftSampleProject
//
//  Created by Carl Hill-Popper on 2/9/16.
//  Copyright © 2016 Vokal.
//

import XCTest
import Vokoder
@testable import SwiftyVokoder

class ManagedObjectContextTests: XCTestCase {

    let manager = VOKCoreDataManager.sharedInstance()
    
    override func setUp() {
        super.setUp()
        self.manager.resetCoreData()
        self.manager.setResource("CoreDataModel", database: "CoreDataModel.sqlite")
        
        // Don't need to keep a reference to the imported object, so set to _
        let _ = Stop.vok_import(CTAData.allStopDictionaries())
        self.manager.saveMainContextAndWait()
    }
    
    func testContextChain() {
        let tempContext = self.manager.temporaryContext()
        //temp context is a child of the main context
        XCTAssertEqual(tempContext.parent, self.manager.managedObjectContext)
        //main context has a private parent context
        XCTAssertNotNil(self.manager.managedObjectContext.parent)
    }
    
    func testDeletingObjectsOnTempContextGetsSavedToMainContext() {
        //get a temp context, delete from temp, save to main, verify deleted on main
        
        let tempContext = self.manager.temporaryContext()
        
        let countOfStations = self.manager.count(for: Station.self)
        XCTAssertGreaterThan(countOfStations, 0)
        
        tempContext.performAndWait {
            self.manager.deleteAllObjects(of: Station.self, context: tempContext)
        }
        self.manager.saveAndMerge(withMainContextAndWait: tempContext)
        
        let updatedCountOfStations = self.manager.count(for: Station.self)
        XCTAssertEqual(updatedCountOfStations, 0)
        XCTAssertNotEqual(countOfStations, updatedCountOfStations)
    }
    
    func testAddingObjectsOnTempContextGetsSavedToMainContext() {
        //get a temp context, add to temp, save to main, verify added to main
        
        let tempContext = self.manager.temporaryContext()

        let countOfTrainLines: UInt = self.manager.count(for: TrainLine.self)
        let expectedCountOfTrainLines = countOfTrainLines + 1
        
        tempContext.performAndWait {
            let silverLine = TrainLine.vok_newInstance(with: tempContext)
            silverLine.identifier = "SLV"
            silverLine.name = "Silver Line"
        }
        self.manager.saveAndMerge(withMainContextAndWait: tempContext)
     
        let updatedCount = self.manager.count(for: TrainLine.self)
        XCTAssertEqual(updatedCount, expectedCountOfTrainLines)
    }
    
    func testSaveWithoutWaitingEventuallySaves() {
        let countOfStations = self.manager.count(for: Station.self)
        XCTAssertGreaterThan(countOfStations, 0)

        self.manager.deleteAllObjects(of: Station.self, context: nil)
        
        self.expectation(forNotification: .NSManagedObjectContextDidSave,
                         object: self.manager.managedObjectContext) { _ in
                
                let updatedCountOfStations = self.manager.count(for: Station.self)
                XCTAssertEqual(updatedCountOfStations, 0)
                XCTAssertNotEqual(countOfStations, updatedCountOfStations)
                
                return true
        }
        
        guard let rootContext = self.manager.managedObjectContext.parent else {
            XCTFail("Expecting the main context to have a parent context")
            return
        }
        
        self.expectation(forNotification: .NSManagedObjectContextDidSave,
                         object: rootContext) { _ in
                
                let updatedCountOfStations = self.manager.count(for: Station.self, for: rootContext)
                XCTAssertEqual(updatedCountOfStations, 0)
                XCTAssertNotEqual(countOfStations, updatedCountOfStations)
                
                return true
        }
    
        self.manager.saveMainContext()
        
        self.waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testSaveAndMergeWithMainContextSavesGrandChildren() {
        let childContext = self.manager.temporaryContext()
        let grandChildContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        grandChildContext.parent = childContext
        
        let countOfStations = self.manager.count(for: Station.self)
        XCTAssertGreaterThan(countOfStations, 0)
        
        grandChildContext.performAndWait {
            self.manager.deleteAllObjects(of: Station.self, context: grandChildContext)
        }
        
        self.manager.saveAndMerge(withMainContextAndWait: grandChildContext)
        
        let updatedCountOfStations = self.manager.count(for: Station.self)
        XCTAssertEqual(updatedCountOfStations, 0)
        XCTAssertNotEqual(countOfStations, updatedCountOfStations)
    }
    
    func testUnsavedMainContextChangesGetPassedToTempContexts() {
        let countOfStations = self.manager.count(for: Station.self)
        XCTAssert(countOfStations > 0)

        //temp contexts should reflect any changes to their parent context (the main context)
        //regardless of if they were created before...
        let childContextBeforeChanges = self.manager.temporaryContext()
        //...changes are made to the parent context...
        self.manager.deleteAllObjects(of: Station.self, context: nil)
        //...or after the changes are made
        let childContextAfterChanges = self.manager.temporaryContext()

        let childCountOfStations = self.manager.count(for: Station.self, for: childContextBeforeChanges)
        XCTAssertNotEqual(countOfStations, childCountOfStations)
        XCTAssertEqual(childCountOfStations, 0)
        
        let otherChildCountOfStations = self.manager.count(for: Station.self, for: childContextAfterChanges)
        XCTAssertNotEqual(countOfStations, otherChildCountOfStations)
        XCTAssertEqual(otherChildCountOfStations, childCountOfStations)
        XCTAssertEqual(otherChildCountOfStations, 0)
    }
    
    func testUnsavedTempContextChangesDoNotGetPassedToMainContext() {
        let countOfStations = self.manager.count(for: Station.self)
        XCTAssertGreaterThan(countOfStations, 0)

        let childContext = self.manager.temporaryContext()
        self.manager.deleteAllObjects(of: Station.self, context: childContext)
        
        let childCountOfStations = self.manager.count(for: Station.self, for: childContext)
        XCTAssertNotEqual(countOfStations, childCountOfStations)
        XCTAssertEqual(childCountOfStations, 0)
        
        let updatedCountOfStations = self.manager.count(for: Station.self)
        XCTAssertEqual(countOfStations, updatedCountOfStations)
    }
}
