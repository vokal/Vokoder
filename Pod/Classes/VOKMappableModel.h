//
//  VOKMappableModel.h
//  VOKCoreData
//
//  Copyright © 2015 Vokal.
//

#import "VOKCoreDataManager.h"

/**
 *  Any models that conform to this protocol will be automatically registered for mapping with the shared instance 
 *  of VOKCoreDataManager.
 *
 *  Note that runtime protocol-conformance is based on declared conformance (the angle-bracketed protocol name appended 
 *  to the interface) and not by checking that the required methods are implemented.  If you ignore the compiler 
 *  warnings about failing to implement required methods, your app will crash.
 */
@protocol VOKMappableModel <NSObject>

///@return an array of VOKManagedObjectMap objects mapping foreign keys to local keys.
+ (NSArray *)coreDataMaps;

///@return the key name to use to uniquely compare two instances of a class.
+ (NSString *)uniqueKey;

// If an optional method isn't defined, the default VOKManagedObjectMap behavior/value will be used.
@optional

///@return whether to ignore remote null/nil values are ignored when updating.
+ (BOOL)ignoreNullValueOverwrites;

///@return whether to warn about incorrect class types when receiving null/nil values for optional properties.
+ (BOOL)ignoreOptionalNullValues;

///@return completion block to run after importing each foreign dictionary.
+ (VOKPostImportBlock)importCompletionBlock;

@end
