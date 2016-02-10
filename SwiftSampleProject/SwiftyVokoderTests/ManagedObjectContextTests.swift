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

    override func setUp() {
        super.setUp()
        VOKCoreDataManager.sharedInstance().resetCoreData()
        VOKCoreDataManager.sharedInstance().setResource("CoreDataModel", database: "CoreDataModel.sqlite")
        
        Stop.vok_import(CTAData.allStopDictionaries())
        VOKCoreDataManager.sharedInstance().saveMainContextAndWait()
    }
    
    func testContextChain() {
        let manager = VOKCoreDataManager.sharedInstance()

        let tempContext = manager.temporaryContext()
        //temp context is a child of the main context
        XCTAssertEqual(tempContext.parentContext, manager.managedObjectContext)
        //main context has a private parent context
        XCTAssertNotNil(manager.managedObjectContext.parentContext)
    }
    
    func testDeletingObjectsOnTempContextGetsSavedToMainContext() {
        //get a temp context, delete from temp, save to main, verify deleted on main
        let manager = VOKCoreDataManager.sharedInstance()
        
        let tempContext = manager.temporaryContext()
        
        let countOfStations = manager.countForClass(Station.self)
        XCTAssert(countOfStations > 0)
        
        tempContext.performBlockAndWait {
            manager.deleteAllObjectsOfClass(Station.self, context: tempContext)
        }
        
        manager.saveAndMergeWithMainContextAndWait(tempContext)
        let newCountOfStations = manager.countForClass(Station.self)
        XCTAssertEqual(newCountOfStations, 0)
        XCTAssertNotEqual(countOfStations, newCountOfStations)
    }
    
    func testAddingObjectsOnTempContextGetsSavedToMainContext() {
        //get a temp context, add to temp, save to main, verify added to main
        let manager = VOKCoreDataManager.sharedInstance()
        
        let tempContext = manager.temporaryContext()

        let countOfTrainLines = manager.countForClass(TrainLine.self)
        
        tempContext.performBlockAndWait {
            let silverLine = TrainLine.vok_newInstanceWithContext(tempContext)
            silverLine.identifier = "SLV"
            silverLine.name = "Silver Line"
        }
        manager.saveAndMergeWithMainContextAndWait(tempContext)
     
        let newCount = manager.countForClass(TrainLine.self)
        XCTAssertEqual(newCount, countOfTrainLines + 1)
    }
    
    func testSaveWithoutWaitingEventuallySaves() {
        let manager = VOKCoreDataManager.sharedInstance()
        
        let countOfStations = manager.countForClass(Station.self)
        XCTAssert(countOfStations > 0)

        manager.deleteAllObjectsOfClass(Station.self, context: nil)
        
        self.expectationForNotification(NSManagedObjectContextDidSaveNotification,
            object: manager.managedObjectContext) { _ in
                
                let newCountOfStations = manager.countForClass(Station.self)
                XCTAssertEqual(newCountOfStations, 0)
                XCTAssertNotEqual(countOfStations, newCountOfStations)
                
                return true
        }
        
        if let rootContext = manager.managedObjectContext.parentContext {
            self.expectationForNotification(NSManagedObjectContextDidSaveNotification,
                object: rootContext) { _ in
                    
                    let newCountOfStations = manager.countForClass(Station.self, forContext: rootContext)
                    XCTAssertEqual(newCountOfStations, 0)
                    XCTAssertNotEqual(countOfStations, newCountOfStations)
                    
                    return true
            }
        }
        
        manager.saveMainContext()
        
        self.waitForExpectationsWithTimeout(10, handler: nil)
    }
    
    func testSaveAndMergeWithMainContextSavesGrandChildren() {
        let manager = VOKCoreDataManager.sharedInstance()
        
        let childContext = manager.temporaryContext()
        let grandChildContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        grandChildContext.parentContext = childContext
        
        let countOfStations = manager.countForClass(Station.self)
        XCTAssert(countOfStations > 0)
        
        grandChildContext.performBlockAndWait {
            manager.deleteAllObjectsOfClass(Station.self, context: grandChildContext)
        }
        
        manager.saveAndMergeWithMainContextAndWait(grandChildContext)
        
        let newCountOfStations = manager.countForClass(Station.self)
        XCTAssertEqual(newCountOfStations, 0)
        XCTAssertNotEqual(countOfStations, newCountOfStations)
    }
    
    func testUnsavedMainContextChangesGetPassedToTempContexts() {
        let manager = VOKCoreDataManager.sharedInstance()

        let countOfStations = manager.countForClass(Station.self)
        XCTAssert(countOfStations > 0)

        let childContextBeforeChanges = manager.temporaryContext()
        manager.deleteAllObjectsOfClass(Station.self, context: nil)
        let childContextAfterChanges = manager.temporaryContext()

        let childCountOfStations = manager.countForClass(Station.self, forContext: childContextBeforeChanges)
        XCTAssertNotEqual(countOfStations, childCountOfStations)
        XCTAssertEqual(childCountOfStations, 0)
        
        let newChildCountOfStations = manager.countForClass(Station.self, forContext: childContextAfterChanges)
        XCTAssertNotEqual(countOfStations, newChildCountOfStations)
        XCTAssertEqual(newChildCountOfStations, childCountOfStations)
        XCTAssertEqual(newChildCountOfStations, 0)
    }
    
    func testUnsavedTempContextChangesDoNotGetPassedToMainContext() {
        let manager = VOKCoreDataManager.sharedInstance()
        
        let countOfStations = manager.countForClass(Station.self)
        XCTAssert(countOfStations > 0)

        let childContext = manager.temporaryContext()
        manager.deleteAllObjectsOfClass(Station.self, context: childContext)
        
        let childCountOfStations = manager.countForClass(Station.self, forContext: childContext)
        XCTAssertNotEqual(countOfStations, childCountOfStations)
        XCTAssertEqual(childCountOfStations, 0)
    }
}
