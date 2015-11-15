//
//  SwiftyVokoderTests.swift
//  SwiftyVokoderTests
//
//  Created by Carl Hill-Popper on 11/5/15.
//  Copyright © 2015 Vokal.
//

import XCTest
@testable import SwiftyVokoder

class SwiftyVokoderTests: XCTestCase {
    
    func exampleBlueLineStopDictionary() -> [String: AnyObject] {
        return [
            "STOP_ID":30096,
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
 
    func testImport() {
        let inputDictionary = self.exampleBlueLineStopDictionary()
        guard let stop = Stop.vok_addWithDictionary(inputDictionary, forManagedObjectContext: nil) else {
            XCTFail("Could not load Stop from dictionary")
            return
        }
        XCTAssertEqual(stop.name, "Grand/Milwaukee (Forest Pk-bound)")
        XCTAssertEqual(stop.identifier, 30096)
        XCTAssertEqual(stop.directionString, "S")
        XCTAssertEqual(stop.direction, Stop.Direction.South)

        guard let station = stop.station, trainLine = stop.trainLine else {
            XCTFail("Could not load station or train from dictionary")
            return
        }
        XCTAssertEqual(station.name, "Grand")
        XCTAssertEqual(station.identifier, 40490)
        XCTAssertEqual(station.descriptiveName, "Grand (Blue Line)")
        XCTAssertEqual(station.locationString, "(41.891189, -87.647578)")
        XCTAssertEqualWithAccuracy(station.coordinate.latitude, 41.891189, accuracy: 1e-6)
        XCTAssertEqualWithAccuracy(station.coordinate.longitude, -87.647578, accuracy: 1e-6)
        
        XCTAssertEqual(trainLine.name, "Blue Line")
        XCTAssertEqual(trainLine.identifier, "BLUE")
    }
}
