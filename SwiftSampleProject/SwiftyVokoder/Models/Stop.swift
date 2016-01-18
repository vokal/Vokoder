//
//  Stop.swift
//  SwiftyVokoder
//
//  Created by Carl Hill-Popper on 11/13/15.
//  Copyright © 2015 Vokal.
//

import Foundation
import CoreData
import Vokoder

//lets pretend we're using mogenerator to create attribute constants
enum StopAttributes: String {
    case directionString
    case identifier
    case name
}

@objc(Stop)
class Stop: NSManagedObject {
    
    enum Direction: String {
        case North = "N"
        case South = "S"
        case East = "E"
        case West = "W"
        case Unknown
        
        init(value: String?) {
            if let
                value = value,
                knownDirection = Direction(rawValue: value) {
                    self = knownDirection
            } else {
                self = .Unknown
            }
        }
    }
    
    lazy private(set) var direction: Direction = {
        Direction(value: self.directionString)
    }()
}

extension Stop: VOKMappableModel {
    /*
    Example JSON input:
    {
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
    },
    */
    static func coreDataMaps() -> [VOKManagedObjectMap] {
        return [
            VOKManagedObjectMap(foreignKeyPath: "STOP_ID",
                coreDataKeyEnum: StopAttributes.identifier),
            VOKManagedObjectMap(foreignKeyPath: "STOP_NAME",
                coreDataKeyEnum: StopAttributes.name),
            VOKManagedObjectMap(foreignKeyPath: "DIRECTION_ID",
                coreDataKeyEnum: StopAttributes.directionString),
        ]
    }
    
    static func uniqueKey() -> String? {
        return StopAttributes.identifier.rawValue
    }

    static func importCompletionBlock() -> VOKPostImportBlock {
        //explicit typing for clarity
        return { (inputDict: [String: AnyObject], inputObject: NSManagedObject) in
            guard let stop = inputObject as? Stop else {
                return
            }
         
            //NOTE: the input JSON is denormalized so we can pass in the inputDict to create stations
            stop.station = Station.vok_addWithDictionary(inputDict,
                forManagedObjectContext: stop.managedObjectContext)
            
            //train lines are mapped manually because CTA data is strange
            stop.trainLine = TrainLine.trainLineFromStopDictionary(inputDict,
                forManagedObjectContext: stop.managedObjectContext)
        }
    }
}

extension Stop: VokoderTypedManagedObject { }
