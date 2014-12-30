//
//  VOKManagedObjectMap.h
//  VOKCoreData
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "VOKManagedObjectMap.h"

typedef void(^VOKPostImportBlock)(NSDictionary *inputDict, NSManagedObject *outputObject);

typedef void(^VOKPostExportBlock)(NSMutableDictionary *outputDict, NSManagedObject *inputObject);

@interface VOKManagedObjectMapper : NSObject

/// Used to identify and update NSManagedObjects. Like a "primary key" in databases.
@property (nonatomic, copy) NSString *uniqueComparisonKey;
/// Used internally to filter input data. Updates automatically to match the uniqueComparisonKey.
@property (nonatomic, copy) NSString *foreignUniqueComparisonKey;
/// If set to NO changes are discarded if a local object exists with the same unique comparison key. Defaults to YES.
@property (nonatomic, assign) BOOL overwriteObjectsWithServerChanges;
/// If set to YES remote null/nil values are ignored when updating. Defaults to NO.
@property (nonatomic, assign) BOOL ignoreNullValueOverwrites;
/** If set to YES, will not warn about incorrect class types when receiving null/nil values for optional properties.
 Defaults to NO. Note: regardless of the setting of this property, log messages are only output in DEBUG situations.
 */
@property (nonatomic, assign) BOOL ignoreOptionalNullValues;
/// An optional completion block to run after importing each foreign dictionary. Defaults to nil.
@property (nonatomic, copy) VOKPostImportBlock importCompletionBlock;
/// An optional completion block to run after exporting a managed object to a dictionary. Defaults to nil.
@property (nonatomic, copy) VOKPostExportBlock exportCompletionBlock;

/**
 Creates a new map.
 @param comparisonKey   An NSString to uniquely identify local entities. Can be nil to enable duplicates.
 @param mapsArray       An NSArray of VOKManagedObjectMaps to corrdinate input data and the core data model.
 @return                A new mapper with the given unique key and maps.
 */
+ (instancetype)mapperWithUniqueKey:(NSString *)comparisonKey
                            andMaps:(NSArray *)mapsArray;
/**
 Convenience constructor for default mapper.
 @return    A default mapper wherein the local keys and foreign keys are identical.
 */
+ (instancetype)defaultMapper;

/**
 This override of objectForKeyedSubscript returns the foreign key for a local core data key.
 @param key The core data key.
 @return The foreign keypath as a string.
 */
- (id)objectForKeyedSubscript:(id)key;

@end