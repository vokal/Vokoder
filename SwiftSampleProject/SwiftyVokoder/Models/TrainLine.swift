//
//  TrainLine.swift
//  SwiftyVokoder
//
//  Created by Carl Hill-Popper on 11/13/15.
//  Copyright © 2015 Vokal.
//

import Foundation
import CoreData
import Vokoder

//lets pretend we're using mogenerator to create attribute constants
enum TrainLineAttributes: String {
    case identifier
    case name
}

@objc(TrainLine)
class TrainLine: NSManagedObject {
 
    enum CTAIdentifier: String {
        case Blue = "BLUE"
        case Brown = "BRN"
        case Green = "G"
        case Orange = "O"
        case Pink = "Pnk"
        case Purple = "P"
        case PurpleExpress = "Pexp"
        case Red = "RED"
        case Yellow = "Y"
        
        var name: String {
            switch self {
            case .Blue:
                return "Blue Line"
            case .Brown:
                return "Brown Line"
            case .Green:
                return "Green Line"
            case .Orange:
                return "Orange Line"
            case .Pink:
                return "Pink Line"
            case .Purple:
                return "Purple Line"
            case .PurpleExpress:
                return "Purple Line Express"
            case .Red:
                return "Red Line"
            case .Yellow:
                return "Yellow Line"
            }
        }
    }

    /**
     Create or fetch the train line referenced by the input dictionary.
     The dictionary is assumed to contain keys for each train line identifier
     with boolean values that determine which train line is referenced.
     Example: a dictionary that contains the following indicates a Blue line train:
     
     [
         "RED":false,
         "BLUE":true,
         "G":false,
         "BRN":false,
         "P":false,
         "Pexp":false,
         "Y":false,
         "Pnk":false,
         "O":false,
     ]
     */
    static func trainLineFromStopDictionary(inputDict: [String: AnyObject],
        forManagedObjectContext context: NSManagedObjectContext?) -> TrainLine? {
        
        let allIdentifiers: [CTAIdentifier] = [
            .Blue,
            .Brown,
            .Green,
            .Orange,
            .Pink,
            .Purple,
            .PurpleExpress,
            .Red,
            .Yellow,
        ]
        
        for identifier in allIdentifiers {
            if (inputDict[identifier.rawValue] as? Bool) == true {
                return self.trainLine(ctaIdentifier: identifier, forManagedObjectContext: context)
            }
        }
        
        return nil
    }
    
    /**
     Fetch existing or create a new TrainLine with a given CTATrainLineIdentifier in the given context.
     */
    static func trainLine(ctaIdentifier identifier: CTAIdentifier,
        forManagedObjectContext context: NSManagedObjectContext?) -> TrainLine {
            let predicate = NSPredicate(format: "%K == %@",
                TrainLineAttributes.identifier.rawValue,
                identifier.rawValue)
            if let trainLine = TrainLine.vok_fetchAllForPredicate(predicate,
                forManagedObjectContext: context).first as? TrainLine {
                    return trainLine
            } else {
                let trainLine = TrainLine.vok_newInstanceWithContext(context)
                trainLine.identifier = identifier.rawValue
                trainLine.name = identifier.name
                
                return trainLine
            }
    }
}

//MARK: VokoderTypedManagedObject
//the empty protocol implementation is used to mixin the functionality of VokoderTypedManagedObject
extension TrainLine: VokoderTypedManagedObject { }
