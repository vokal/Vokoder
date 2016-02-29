//
//  NSManagedObject+VOKManagedObjectAdditions.h
//  Vokoder
//
//  Copyright © 2015 Vokal.
//

#import <CoreData/CoreData.h>

#import "VOKCoreDataCollectionTypes.h"
#import "VOKNullabilityFeatures.h"

NS_ASSUME_NONNULL_BEGIN

/// A completion block after an asynchronous operation on a temporary context. NSManagedObject's are not threadsafe.
typedef void(^VOKManagedObjectsReturnBlock)(VOKArrayOfManagedObjects *managedObjects);

@interface NSManagedObject (VOKManagedObjectAdditions)

/**
 Checks for NSNull before setting a value on this object.
 @param value   The new value, nil, or NSNull.
 @param key     The key to set.
 */
- (void)vok_safeSetValue:(nullable id)value forKey:(NSString *)key;

/**
 Creates a dictionary based on the set mapping. This should round-trip data from dictionaries to Core Data and back.
 This method does not respect keyPaths. The dictionary is flat.
 @return    An NSDictionary matching the original input dictionary.
 */
- (VOKStringToObjectDictionary *)vok_dictionaryRepresentation;

/**
 Creates a dictionary based on the set mapping. This should round-trip data from dictionaries to Core Data and back.
 This method respects keyPaths.
 @return    An NSDictionary matching the original input dictionary.
 */
- (VOKStringToObjectDictionary *)vok_dictionaryRepresentationRespectingKeyPaths;

/**
 Gets the entity name string for the particular NSManagedObject subclass on which the method is called.
 @return The entity name string
 */
+ (NSString *)vok_entityName;

/**
 A convenience method to create a new instance of a NSManagedObject subclass.
 @return    A new managed object subclass in the main context.
 */
+ (instancetype)vok_newInstance;

/**
 A convenience method to create a new instance of a NSManagedObject subclass.
 @param contextOrNil    The managed object context in which to insert the new object.  If nil, the main context will be used.
 @return                A new managed object subclass in the main context.
 */
+ (instancetype)vok_newInstanceWithContext:(nullable NSManagedObjectContext *)contextOrNil;

/*
 Create or update many NSManagedObjects, respecting the mapper's overwriteObjectsWithServerChanges and ignoreNullValueOverwrites properties.
 This should only be used to set all properties of an entity. 
 By default any mapped attributes not included in the input dictionaries will be set to nil.
 This will overwrite ALL of an NSManagedObject's properties unless ignoreNullValueOverwrites is YES on the mapper for this class.
 @param inputArray      An array of dictionaries with foreign data to inport.
 @param contextOfNil    The managed object context in which to update and/or insert the objects. If nil, the main context will be used.
 @return                An array of this subclass of NSManagedObject.
 **/
+ (VOKArrayOfManagedObjects *)vok_addWithArray:(VOKArrayOfObjectDictionaries *)inputArray
                       forManagedObjectContext:(nullable NSManagedObjectContext *)contextOrNil;

/*
 Create or update a single NSManagedObject, respecting the mapper's overwriteObjectsWithServerChanges and ignoreNullValueOverwrites properties.
 This should only be used to set all properties of an entity.
 By default any mapped attributes not included in the input dictionaries will be set to nil.
 This will overwrite ALL of an NSManagedObject's properties unless ignoreNullValueOverwrites is YES on the mapper for this class.
 @param inputDict       A dictionary with foreign data to inport.
 @param contextOfNil    The managed object context in which to update and/or insert the object. If nil, the main context will be used.
 @return                An instance of this subclass of NSManagedObject.
 **/
+ (nullable instancetype)vok_addWithDictionary:(VOKStringToObjectDictionary *)inputDict
                       forManagedObjectContext:(nullable NSManagedObjectContext *)contextOrNil;

/*
 Create or update many NSManagedObjects in a background managed object context, respecting the mapper's overwriteObjectsWithServerChanges and ignoreNullValueOverwrites properties.
 This should only be used to set all properties of an entity.
 By default any mapped attributes not included in the input dictionaries will be set to nil.
 This will overwrite ALL of an NSManagedObject's properties unless ignoreNullValueOverwrites is YES on the mapper for this class,
 @param inputArray      An array of dictionaries with foreign data to input on a background queue in a temporary context.
 @param completion      Executed after the background operation. The array contains the objects imported/updated. It will be executed on the main queue.
 **/
+ (void)vok_addWithArrayInBackground:(VOKArrayOfObjectDictionaries *)inputArray
                          completion:(nullable VOKManagedObjectsReturnBlock)completion;

/*
 Convenience method to create a fetch request.
 @return    A fetch request of the current class.
 */
+ (NSFetchRequest *)vok_fetchRequest;

/*
 Convenience method to create a fetch request with a predicate.
 @param predicate   Predicate to construct the fetch request.
 @return            A fetch request on this class.
 */
+ (NSFetchRequest *)vok_fetchRequestWithPredicate:(nullable NSPredicate *)predicate;

/*
 Checks the count to determine if entities exist matching the predicate.
 @param predicate       Predicate to use to fetch.
 @param contextOrNil    The managed object context in which to fetch.  If nil, the main context will be used.
 @return                YES the object(s) exist or NO if they do not.
 */
+ (BOOL)vok_existsForPredicate:(nullable NSPredicate *)predicate
       forManagedObjectContext:(nullable NSManagedObjectContext *)contextOrNil;

/*
 Returns all entities matching the predicate.
 @param predicate       Predicate to use to fetch.
 @param contextOrNil    The managed object context in which to fetch.  If nil, the main context will be used.
 @return                NSArray full of the instances of the current class.
 */
+ (VOKArrayOfManagedObjects *)vok_fetchAllForPredicate:(nullable NSPredicate *)predicate
                               forManagedObjectContext:(nullable NSManagedObjectContext *)contextOrNil;

/*
 Returns all entities matching the predicate, sorted using the array of sort descriptors.
 @param predicate       Predicate to use to fetch.
 @param sortDescriptors SortDescriptors to use to sort the results.
 @param contextOrNil    The managed object context in which to fetch.  If nil, the main context will be used.
 @return                NSArray full of the instances of the current class.
 */
+ (VOKArrayOfManagedObjects *)vok_fetchAllForPredicate:(nullable NSPredicate *)predicate
                                              sortedBy:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
                               forManagedObjectContext:(nullable NSManagedObjectContext *)contextOrNil;

/*
 Returns all entities matching the predicate.
 @param predicate       Predicate to use to fetch.
 @param sortKey         Key to use to sort the results.
 @param ascending       Whether or not to sort in ascending or descending.
 @param contextOrNil    The managed object context to fetch in.  If nil, the main context will be used.
 @return                NSArray full of the instances of the current class.
 */
+ (VOKArrayOfManagedObjects *)vok_fetchAllForPredicate:(nullable NSPredicate *)predicate
                                           sortedByKey:(NSString *)sortKey
                                             ascending:(BOOL)ascending
                               forManagedObjectContext:(nullable NSManagedObjectContext *)contextOrNil;

/*
 Returns one entity matching the predicate. Asserts the count is exactly 1. If more objects are returned, the last one returned by Core Data will be returned.
 @param predicate       Predicate to use to fetch.
 @param contextOrNil    The managed object context to fetch in.  If nil, the main context will be used.
 @return                An instance of the current class, if one is found for the given predicate.
 */
+ (nullable instancetype)vok_fetchForPredicate:(nullable NSPredicate *)predicate
                       forManagedObjectContext:(nullable NSManagedObjectContext *)contextOrNil;

@end

NS_ASSUME_NONNULL_END
