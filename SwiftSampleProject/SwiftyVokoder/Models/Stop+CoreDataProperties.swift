//
//  Stop+CoreDataProperties.swift
//  
//
//  Created by Carl Hill-Popper on 11/13/15.
//  Copyright © 2015 Vokal.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Stop {

    @NSManaged var identifier: NSNumber?
    @NSManaged var name: String?
    @NSManaged var directionString: String?
    @NSManaged var station: Station?
    @NSManaged var trainLine: TrainLine?

}
