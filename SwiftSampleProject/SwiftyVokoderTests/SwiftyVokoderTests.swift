//
//  SwiftyVokoderTests.swift
//  SwiftyVokoderTests
//
//  Created by Carl Hill-Popper on 11/5/15.
//  Copyright © 2015 Vokal.
//

import XCTest
@testable import SwiftyVokoder

let grandMilwaukeeIdentifier = 30096

class SwiftyVokoderTests: XCTestCase {
    
    func exampleBlueLineStopDictionary() -> [String: AnyObject] {
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
    
    func allStopDictionaries() -> [[String: AnyObject]] {
        guard let
            path = NSBundle.mainBundle().pathForResource("CTA_stations", ofType: "json"),
            data = NSData(contentsOfFile: path)
            else {
                XCTFail("file not found")
                return []
        }
        
        do {
            let jsonObject = try NSJSONSerialization.JSONObjectWithData(data, options: [])
            guard let jsonArray = jsonObject as? [[String: AnyObject]] else {
                XCTFail("JSON in unexpected format")
                return []
            }
            return jsonArray
        } catch {
            XCTFail("Could not read JSON file")
            return []
        }
    }
    
    func testCreateTrainLineFromIdentifier() {
        let redLine = TrainLine.trainLine(ctaIdentifier: .Red, forManagedObjectContext: nil)
        XCTAssertEqual(redLine.identifier, TrainLine.CTAIdentifier.Red.rawValue)
        XCTAssertEqual(redLine.name, TrainLine.CTAIdentifier.Red.name)
    }
 
    func testImportOneStop() {
        let inputDictionary = self.exampleBlueLineStopDictionary()
        guard let grandMilwaukeeStop = Stop.vok_addWithDictionary(inputDictionary) else {
            XCTFail("Could not load Stop from dictionary")
            return
        }
        
        self.verifyGrandMilwaukeeStop(grandMilwaukeeStop)
    }
    
    func verifyGrandMilwaukeeStop(stop: Stop) {
        XCTAssertEqual(stop.name, "Grand/Milwaukee (Forest Pk-bound)")
        XCTAssertEqual(stop.identifier, grandMilwaukeeIdentifier)
        XCTAssertEqual(stop.directionString, "S")
        XCTAssertEqual(stop.direction, Stop.Direction.South)
        
        guard let station = stop.station, trainLine = stop.trainLine else {
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
        let stops = Stop.vok_addWithArray(self.allStopDictionaries())
        
        XCTAssertEqual(stops.count, 300)
        guard let grandMilwaukeeStop = stops.filter({ stop in
            return stop.identifier == grandMilwaukeeIdentifier
        }).first else {
            XCTFail("Could not find stop \(grandMilwaukeeIdentifier)")
            return
        }
        
        self.verifyGrandMilwaukeeStop(grandMilwaukeeStop)
    }
}
