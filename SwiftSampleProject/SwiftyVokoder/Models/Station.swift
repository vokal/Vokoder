//
//  Station.swift
//  SwiftyVokoder
//
//  Created by Carl Hill-Popper on 11/13/15.
//  Copyright © 2015 Vokal.
//

import Foundation
import CoreData
import CoreLocation
import Vokoder

//lets pretend we're using mogenerator to create attribute constants
enum StationAttributes: String {
    case name
    case longitude
    case locationString
    case latitude
    case identifier
    case descriptiveName
    case accessible
}

@objc(Station)
class Station: NSManagedObject {
    lazy private(set) var coordinate: CLLocationCoordinate2D = {
        CLLocationCoordinate2D(latitude: Double(self.latitude ?? 0),
            longitude: Double(self.longitude ?? 0))
    }()
}

extension Station: VOKMappableModel {
    static func coreDataMaps() -> [VOKManagedObjectMap] {
        return [
            VOKManagedObjectMap(foreignKeyPath: "MAP_ID",
                coreDataKeyEnum: StationAttributes.identifier),
            VOKManagedObjectMap(foreignKeyPath: "STATION_NAME",
                coreDataKeyEnum: StationAttributes.name),
            VOKManagedObjectMap(foreignKeyPath: "STATION_DESCRIPTIVE_NAME",
                coreDataKeyEnum: StationAttributes.descriptiveName),
            VOKManagedObjectMap(foreignKeyPath: "ADA",
                coreDataKeyEnum: StationAttributes.accessible),
            VOKManagedObjectMap(foreignKeyPath: "Location",
                coreDataKeyEnum: StationAttributes.locationString),
        ]
    }
    
    static func uniqueKey() -> String? {
        return StationAttributes.identifier.rawValue
    }
    
    static func importCompletionBlock() -> VOKPostImportBlock {
        //we aren't using the first param so use the underscore symbol
        //explicit typing for clarity
        return { (_, inputObject: NSManagedObject) in
            guard let
                station = inputObject as? Station,
                locationString = station.locationString else {
                return
            }
            
            //example locationString: "(41.875478, -87.688436)"
            //convert parentheses to curly braces to be usable by CGPointFromString
            var pointString = locationString.stringByReplacingOccurrencesOfString("(", withString: "{")
            pointString = pointString.stringByReplacingOccurrencesOfString(")", withString: "}")
            let point = CGPointFromString(pointString)
            station.latitude = point.x
            station.longitude = point.y
        }
    }
}

//MARK: VokoderTypedManagedObject
//the empty protocol implementation is used to mixin the functionality of VokoderTypedManagedObject
extension Station: VokoderTypedManagedObject { }
