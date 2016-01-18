//
//  VokoderTypedManagedObject.swift
//  Vokoder
//
//  Created by Carl Hill-Popper on 1/17/16.
//  Copyright © 2016 Vokal.
//

/**
A protocol to add Swiftier versions of some Vokoder category functions of NSManagedObject.

To add this mixin functionality, have your managed object subclass implement this empty protocol.
*/
public protocol VokoderTypedManagedObject: class { }

public extension VokoderTypedManagedObject where Self: NSManagedObject {
    
    /**
     Create or update many NSManagedObjects, respecting the mapper's overwriteObjectsWithServerChanges and ignoreNullValueOverwrites properties.
     This should only be used to set all properties of an entity.
     By default any mapped attributes not included in the input dictionaries will be set to nil.
     This will overwrite ALL of an NSManagedObject's properties unless ignoreNullValueOverwrites is YES;
     
     - parameter inputArray: An array of dicionaries defining managed object subclasses
     - parameter context: The managed object context in which to create the objects or nil for the main context (defaults to nil)
     - returns: A typed Array of created or updated objects
     */
    public static func vok_addWithArray(inputArray: [[String: AnyObject]],
        forManagedObjectContext context: NSManagedObjectContext? = nil) -> [Self] {
            return VOKCoreDataManager.sharedInstance().importArray(inputArray,
                forClass: self,
                withContext: context)
    }
    
    /**
     Create or update a single NSManagedObject, respecting the mapper's overwriteObjectsWithServerChanges and ignoreNullValueOverwrites properties.
     This should only be used to set all properties of an entity.
     By default any mapped attributes not included in the input dictionaries will be set to nil.
     This will overwrite ALL of an NSManagedObject's properties unless ignoreNullValueOverwrites is YES;
     
     - parameter inputArray: An array of dicionaries defining managed object subclasses
     - parameter context: The managed object context in which to create the objects or nil for the main context (defaults to nil)
     - returns: An instance of this subclass of managed object or nil if the import failed
     */
    public static func vok_addWithDictionary(inputDict: [String : AnyObject],
        forManagedObjectContext context: NSManagedObjectContext? = nil) -> Self? {
            return self.vok_addWithDictionary(inputDict, forManagedObjectContext: context)
    }

    /**
     Fetches every instance of this class that matches the predicate using the given managed object context. Includes subentities.
     NOT threadsafe! Always use a temp context if you are NOT on the main queue.
     
     - parameter predicate: The predicate limit the fetch (defaults to nil)
     - parameter sortedBy: The sort descriptors to sort the results (defaults to nil)
     - parameter context: The managed object context in which to fetch objects or nil for the main context (defaults to nil)
     - returns: A typed Array of managed object subclasses. Not threadsafe.
     */
    public static func vok_fetchAll(forPredicate predicate: NSPredicate? = nil,
        sortedBy sortDescriptors: [NSSortDescriptor]? = nil,
        forManagedObjectContext context: NSManagedObjectContext? = nil) -> [Self] {
            return VOKCoreDataManager.sharedInstance().arrayForClass(self,
                withPredicate: predicate,
                sortedBy: sortDescriptors,
                forContext: context)
    }
    
    /**
     Fetches every instance of this class that matches the predicate using the given managed object context. Includes subentities.
     NOT threadsafe! Always use a temp context if you are NOT on the main queue.
     
     - parameter predicate: The predicate limit the fetch (defaults to nil)
     - parameter sortKey: A property keypath used to sort the results
     - parameter ascending: Whether to sort the results in ascending or descending order
     - parameter context: The managed object context in which to fetch objects or nil for the main context (defaults to nil)
     - returns: A typed Array of managed object subclasses. Not threadsafe.
     */
    public static func vok_fetchAll(forPredicate predicate: NSPredicate? = nil,
        sortedByKey sortKey: String,
        ascending: Bool,
        forManagedObjectContext context: NSManagedObjectContext? = nil) -> [Self] {
            let sortDescriptor = NSSortDescriptor(key: sortKey, ascending: ascending)
            return self.vok_fetchAll(forPredicate: predicate,
                sortedBy: [sortDescriptor],
                forManagedObjectContext: context)
    }
}
