//
//  VOKCoreDataCollectionTypes.h
//  Vokoder
//
//  Created by Carl Hill-Popper on 10/23/15.
//
//  Copyright © 2015 Vokal.
//

#ifndef VOKCoreDataCollectionTypes_h
#define VOKCoreDataCollectionTypes_h

#if __has_feature(objc_generics)
//forward declare classes used here since we don't know where this will be included
@class NSManagedObject;
@class NSManagedObjectID;
@class VOKManagedObjectMap;

typedef __kindof NSManagedObject VOKManagedObjectSubclass;

// [NSManagedObject]
typedef NSArray<VOKManagedObjectSubclass *> VOKArrayOfManagedObjects;

// [NSManagedObjectID]
typedef NSArray<__kindof NSManagedObjectID *> VOKArrayOfManagedObjectIDs;

// [String : AnyObject]
typedef NSDictionary<NSString *, id> VOKStringToObjectDictionary;

// [String : AnyObject] mutable
typedef NSMutableDictionary<NSString *, id> VOKStringToObjectMutableDictionary;

// [VOKStringToObjectDictionary]
typedef NSArray<VOKStringToObjectDictionary *> VOKArrayOfObjectDictionaries;

// [NSSortDescriptor]
typedef NSArray<NSSortDescriptor *> VOKArrayOfSortDescriptors;

// [VOKManagedObjectMap]
typedef NSArray<VOKManagedObjectMap *> VOKArrayOfManagedObjectMaps;

// [String : String]
typedef NSDictionary<NSString *, NSString *> VOKStringToStringDictionary;

#else
//no generic support, fallback to regular NSArray, NSDictionary

#define VOKManagedObjectSubclass NSManagedObject
#define VOKArrayOfManagedObjects NSArray
#define VOKArrayOfManagedObjectIDs NSArray
#define VOKStringToObjectDictionary NSDictionary
#define VOKStringToObjectMutableDictionary NSMutableDictionary
#define VOKArrayOfObjectDictionaries NSArray
#define VOKArrayOfSortDescriptors NSArray

#define VOKArrayOfManagedObjectMaps NSArray
#define VOKStringToStringDictionary NSDictionary

#endif

#endif /* VOKGenericCollectionTypes_h */
