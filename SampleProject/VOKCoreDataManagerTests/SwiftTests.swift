//
//  SwiftTests.swift
//  SampleProject
//
//  Created by Carl Hill-Popper on 10/26/15.
//
//

import XCTest

class SwiftTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        VOKCoreDataManager.sharedInstance().resetCoreData()
        VOKCoreDataManager.sharedInstance().setResource("VICoreDataModel", database: nil)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        VOKCoreDataManager.sharedInstance().deleteAllObjectsOfClass(VIThing.self, context: nil)
        VOKCoreDataManager.sharedInstance().saveMainContextAndWait()
        
        super.tearDown()
    }
    
    func testRecordInsertion() {
        XCTAssertEqual(VOKCoreDataManager.sharedInstance().countForClass(VIThing.self), 0)

        let thing = VIThing.vok_newInstance()
        thing.name = "test-1"
        thing.numberOfHats = 1

        VOKCoreDataManager.sharedInstance().saveMainContext()
        XCTAssertEqual(VOKCoreDataManager.sharedInstance().countForClass(VIThing.self), 1)
    }
    
    func testPerformanceExample() {
        
        var maps = VOKManagedObjectMap.mapsFromDictionary([
            "NAME": "name",
            "": "",
            ])
        
        maps.appendContentsOf([
            VOKManagedObjectMap(foreignKeyPath: "bar", coreDataKey: "foo"),
            ])
        
        let mapper = VOKManagedObjectMapper(uniqueKey: "name", andMaps: maps)
        
        VOKCoreDataManager.sharedInstance().setObjectMapper(mapper, forClass: VIPerson.self)
        
        
        NSOperationQueue.mainQueue().addOperationWithBlock {
            
        }
        
    }
    
}
