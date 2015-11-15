//
//  Station+CoreDataProperties.swift
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

extension Station {

    @NSManaged var name: String?
    @NSManaged var identifier: NSNumber?
    @NSManaged var locationString: String?
    @NSManaged var latitude: NSNumber?
    @NSManaged var longitude: NSNumber?
    @NSManaged var descriptiveName: String?
    @NSManaged var accessible: NSNumber?
    @NSManaged var stops: NSSet?

}
