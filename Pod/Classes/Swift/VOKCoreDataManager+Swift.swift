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
     A swiftly named wrapper for the singleton.
     
     - returns: The shared instance of the core data manager
     */
    @nonobjc
    static var shared: VOKCoreDataManager {
        return self.sharedInstance()
    }
    
    /**
     DEPRECATED: use managedObject(ofClass:inContext:) instead
     Create an appropriately typed instance of a given NSManagedObject subclass.
     
     - parameter objectClass: The class of object to create
     - parameter context: The managed object context in which to create the object or nil for the main context (defaults to nil)
     - returns: A new instance of the given class
     */
    @available(*, deprecated: 4.1.0, message: "use managedObject(ofClass:inContext:) instead")
    func managedObjectOfClass<T: NSManagedObject>(_ objectClass: T.Type, inContext context: NSManagedObjectContext? = nil) -> T {
        return self.managedObject(ofClass: objectClass, inContext: context)
    }
    
    /**
     Create an appropriately typed instance of a given NSManagedObject subclass.
     
     - parameter objectClass: The class of object to create
     - parameter context: The managed object context in which to create the object or nil for the main context (defaults to nil)
     - returns: A new instance of the given class
     */
    func managedObject<T: NSManagedObject>(ofClass objectClass: T.Type,
                              inContext context: NSManagedObjectContext? = nil) -> T {
        guard let result = self.managedObject(of: objectClass, in: context) as? T else {
            fatalError("Could not cast NSManagedObject to \(String(describing: T.self))")
        }
        return result
    }
    
    /**
     DEPRECATED - use importArray(_:of:withContext:) instead.
     Deserializes an array of dictionaries full of strings and creates (or updates) instances of a managed object subclass in the given context.
     
     - parameter inputArray: An array of dictionaries defining managed object subclasses
     - parameter objectClass: The class of objects to create
     - parameter context: The managed object context in which to create the objects or nil for the main context (defaults to nil)
     - returns: A typed Array of created or updated objects
     */
    @available(*, deprecated: 4.1.0, message: "use importArray(_:of:withContext:) instead")
    func importArray<T: NSManagedObject>(_ inputArray: [[String : Any]],
                            forClass objectClass: T.Type,
                            withContext context: NSManagedObjectContext? = nil) -> [T] {
        return self.importArray(inputArray,
                                of: objectClass,
                                withContext: context)
    }
    
    /**
     Deserializes an array of dictionaries full of strings and creates (or updates) instances of a managed object subclass in the given context.
     
     - parameter inputArray: An array of dictionaries defining managed object subclasses
     - parameter objectClass: The class of objects to create
     - parameter context: The managed object context in which to create the objects or nil for the main context (defaults to nil)
     - returns: A typed Array of created or updated objects
     */
    func importArray<T: NSManagedObject>(_ inputArray: [[String : Any]],
                            of objectClass: T.Type,
                            withContext context: NSManagedObjectContext? = nil) -> [T] {
        guard let result = self.import(inputArray,
                                       for: objectClass,
                                       with: context) as? [T] else {
                                        fatalError("Could not cast array of NSManagedObjects into \(String(describing: T.self))")
        }
        return result
    }
    
    
    /**
     DEPRECATED: Use arrayOf(_:withPredicate:sortedBy:forContext:) instead.
     
     Fetches every instance of a given class that matches the predicate using the given managed object context. Includes subentities.
     NOT threadsafe! Always use a temp context if you are NOT on the main queue.
     
     - parameter objectClass: The class of objects to fetch
     - parameter predicate: The predicate limit the fetch (defaults to nil)
     - parameter sortedBy: The sort descriptors to sort the results (defaults to nil)
     - parameter context: The managed object context in which to fetch objects or nil for the main context (defaults to nil)
     - returns: A typed Array of managed object subclasses. Not threadsafe.
     */
    @available(*, deprecated: 4.1.0, message: "use arrayOf(_:withPredicate:sortedBy:forContext:) instead")
    func arrayForClass<T: NSManagedObject>(_ objectClass: T.Type,
                              withPredicate predicate: NSPredicate? = nil,
                              sortedBy sortDescriptors: [NSSortDescriptor]? = nil,
                              forContext context: NSManagedObjectContext? = nil) -> [T] {
        return self.arrayOf(objectClass,
                            withPredicate: predicate,
                            sortedBy: sortDescriptors,
                            forContext: context)
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
    func arrayOf<T: NSManagedObject>(_ objectClass: T.Type,
                        withPredicate predicate: NSPredicate? = nil,
                        sortedBy sortDescriptors: [NSSortDescriptor]? = nil,
                        forContext context: NSManagedObjectContext? = nil) -> [T] {
        guard let result = self.array(for: objectClass,
                                      with: predicate,
                                      sortedBy: sortDescriptors,
                                      for: context) as? [T] else {
                                        fatalError("Could not cast array of NSManagedObjects into \(String(describing: T.self))")
        }
        return result
    }
}
