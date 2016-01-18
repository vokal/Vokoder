//
//  VOKCoreDataManager+Swift.swift
//  Vokoder
//
//  Created by Carl Hill-Popper on 1/17/16.
//  Copyright © 2016 Vokal.
//

/**
Swiftier versions of some Vokoder functions that return more exact managed object subclass types.
*/
public extension VOKCoreDataManager {
    
    /**
     Create an appropriately typed instance of a given NSManagedObject subclass.
     
     - parameter objectClass: The class of object to create
     - parameter context: The managed object context in which to create the object or nil for the main context (defaults to nil)
     - returns: A new instance of the given class
     */
    public func managedObjectOfClass<T: NSManagedObject>(objectClass: T.Type,
        inContext context: NSManagedObjectContext? = nil) -> T {
            guard let result = self.managedObjectOfClass(objectClass, inContext: context) as? T else {
                fatalError("Could not cast NSManagedObject to \(String(T))")
            }
            return result
    }
    
    /**
     Deserializes an array of dictionaries full of strings and creates (or updates) instances of a managed object subclass in the given context.
     
     - parameter inputArray: An array of dicionaries defining managed object subclasses
     - parameter objectClass: The class of objects to create
     - parameter context: The managed object context in which to create the objects or nil for the main context (defaults to nil)
     - returns: A typed Array of created or updated objects
     */
    public func importArray<T: NSManagedObject>(inputArray: [[String : AnyObject]],
        forClass objectClass: T.Type,
        withContext context: NSManagedObjectContext? = nil) -> [T] {
            guard let result = self.importArray(inputArray,
                forClass: objectClass,
                withContext: context) as? [T] else {
                    fatalError("Could not cast array of NSManagedObjects into \(String(T))")
            }
            return result
    }
    
    /**
     Fetches every instance of a given class that matches the predicate using the given managed object context. Includes subentities.
     NOT threadsafe! Always use a temp context if you are NOT on the main queue.

     - parameter objectClass: The class of objects to fetch
     - parameter predicate: The predicate limit the fetch (defaults to nil)
     - parameter sortedBy: The sort descriptors to sort the results (defaults to nil)
     - parameter context: The managed object context in which to fetch objects or nil for the main context (defaults to nil)
     - returns: A typed Array of managed object subclasses. Not threadsafe.
     */
    public func arrayForClass<T: NSManagedObject>(objectClass: T.Type,
        withPredicate predicate: NSPredicate? = nil,
        sortedBy sortDescriptors: [NSSortDescriptor]? = nil,
        forContext context: NSManagedObjectContext? = nil) -> [T] {
            guard let result = self.arrayForClass(objectClass,
                withPredicate: predicate,
                sortedBy: sortDescriptors,
                forContext: context) as? [T] else {
                    fatalError("Could not cast array of NSManagedObjects into \(String(T))")
            }
            return result
    }
}
