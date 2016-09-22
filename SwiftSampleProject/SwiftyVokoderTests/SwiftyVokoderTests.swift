//
//  SwiftyVokoderTests.swift
//  SwiftSampleProject
//
//  Created by Carl Hill-Popper on 11/5/15.
//  Copyright © 2015 Vokal.
//

import XCTest
import Vokoder
@testable import SwiftyVokoder

let grandMilwaukeeIdentifier = NSNumber(value: 30096)

typealias JSONObject = [String: Any]

struct CTAData {

    static func allStopDictionaries() -> [JSONObject] {
        guard
            let path = Bundle.main.path(forResource: "CTA_stations", ofType: "json"),
            let data = NSData(contentsOfFile: path) else {
                XCTFail("file not found")
                return []
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data as Data, options: [])
            guard let jsonArray = jsonObject as? [JSONObject] else {
                XCTFail("JSON in unexpected format")
                return []
            }
            return jsonArray
        } catch {
            XCTFail("Could not read JSON file")
            return []
        }
    }
}

class SwiftyVokoderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        VOKCoreDataManager.sharedInstance().resetCoreData()
        VOKCoreDataManager.sharedInstance().setResource("CoreDataModel", database: nil)
    }

    func exampleBlueLineStopDictionary() -> JSONObject {
        return [
            "STOP_ID":grandMilwaukeeIdentifier,
            "DIRECTION_ID":"S",
            "STOP_NAME":"Grand/Milwaukee (Forest Pk-bound)",
            "STATION_NAME":"Grand",
            "STATION_DESCRIPTIVE_NAME":"Grand (Blue Line)",
            "MAP_ID":40490,
            "ADA":false,
            "RED":false,
            "BLUE":true,
            "G":false,
            "BRN":false,
            "P":false,
            "Pexp":false,
            "Y":false,
            "Pnk":false,
            "O":false,
            "Location":"(41.891189, -87.647578)"
        ]
    }
    
    func testCreateTrainLineFromIdentifier() {
        let redLine = TrainLine.trainLine(ctaIdentifier: .Red, forManagedObjectContext: nil)
        XCTAssertEqual(redLine.identifier, TrainLine.CTAIdentifier.Red.rawValue)
        XCTAssertEqual(redLine.name, TrainLine.CTAIdentifier.Red.name)
    }
 
    func testImportOneStop() {
        let inputDictionary = self.exampleBlueLineStopDictionary()
        guard let grandMilwaukeeStop = Stop.vok_import(inputDictionary) else {
            XCTFail("Could not load Stop from dictionary")
            return
        }
        
        self.verifyGrandMilwaukeeStop(stop: grandMilwaukeeStop)
    }
    
    func verifyGrandMilwaukeeStop(stop: Stop) {
        XCTAssertEqual(stop.name, "Grand/Milwaukee (Forest Pk-bound)")
        XCTAssertEqual(stop.identifier, grandMilwaukeeIdentifier)
        XCTAssertEqual(stop.directionString, "S")
        XCTAssertEqual(stop.direction, Stop.Direction.South)
        
        guard let station = stop.station, let trainLine = stop.trainLine else {
            XCTFail("Could not load station or train from dictionary")
            return
        }
        XCTAssertEqual(station.name, "Grand")
        XCTAssertEqual(station.identifier, 40490)
        XCTAssertEqual(station.descriptiveName, "Grand (Blue Line)")
        XCTAssertEqual(station.accessible, false)
        XCTAssertEqual(station.locationString, "(41.891189, -87.647578)")
        XCTAssertEqualWithAccuracy(station.coordinate.latitude, 41.891189, accuracy: 1e-5)
        XCTAssertEqualWithAccuracy(station.coordinate.longitude, -87.647578, accuracy: 1e-5)
        
        XCTAssertEqual(trainLine.name, "Blue Line")
        XCTAssertEqual(trainLine.identifier, "BLUE")
    }
    
    func testImportAllStops() {
        let stops = Stop.vok_import(CTAData.allStopDictionaries())
        
        XCTAssertEqual(stops.count, 300)
        guard let grandMilwaukeeStop = stops.filter({ stop in
            return stop.identifier == grandMilwaukeeIdentifier
        }).first else {
            XCTFail("Could not find stop \(grandMilwaukeeIdentifier)")
            return
        }
        
        self.verifyGrandMilwaukeeStop(stop: grandMilwaukeeStop)
    }
    
    func testSwiftExtensionEqualObjCImports() {
        let stopDictionaries = CTAData.allStopDictionaries()
        var swiftStops: [Stop] = Stop.vok_import(stopDictionaries)
        var objCStops: [NSManagedObject] = Stop.vok_add(with: stopDictionaries, for: nil)
        
        XCTAssertEqual(swiftStops, objCStops)
        
        let manager = VOKCoreDataManager.sharedInstance()
        
        swiftStops = manager.importArray(stopDictionaries, forClass: Stop.self)
        objCStops = manager.import(stopDictionaries, for: Stop.self, with: nil)

        XCTAssertEqual(swiftStops, objCStops)
    }
    
    func testSwiftImportsWithEmptyOutput() {
        var stops = Stop.vok_import([])
        
        XCTAssertEqual(stops.count, 0)
        
        stops = VOKCoreDataManager.sharedInstance().importArray([], forClass: Stop.self)
        XCTAssertEqual(stops.count, 0)
    }
}
