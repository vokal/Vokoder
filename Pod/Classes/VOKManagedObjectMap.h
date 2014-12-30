//
//  VOKManagedObjectMap.h
//  VOKCoreData
//

#import <Foundation/Foundation.h>

/**
 *  Generate a string from a selector symbol.
 *
 *  @param selectorSymbol The selector symbol.
 *
 *  @return An NSString
 */
#ifndef VOK_CDSELECTOR
#   ifdef DEBUG
#       define VOK_CDSELECTOR(selectorSymbol) NSStringFromSelector(@selector(selectorSymbol))
#   else
#       define VOK_CDSELECTOR(selectorSymbol) @#selectorSymbol //in release builds @#selectorSymbol becomes @"{selectorSymbol}"
#   endif
#endif

/**
 *  Creates a map with the default date mapper.
 *
 *  @param inputKeyPath           The foreign key to match with the local key.
 *  @param coreDataSelectorSymbol The local selector symbol.
 *
 *  @return A VOKManagedObjectMap
 */
#ifndef VOK_MAP_FOREIGN_TO_LOCAL
#   define VOK_MAP_FOREIGN_TO_LOCAL(inputKeyPath, coreDataSelectorSymbol) [VOKManagedObjectMap mapWithForeignKeyPath:inputKeyPath coreDataKey:VOK_CDSELECTOR(coreDataSelectorSymbol)]
#endif

@interface VOKManagedObjectMap : NSObject

/// Remote key for input/output
@property (nonatomic, copy) NSString *inputKeyPath;

/// Local key for input/output
@property (nonatomic, copy) NSString *coreDataKey;

/// Date formatter for input/output
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

/// Number formatter for input/output
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;

/**
 Creates a map with the default date mapper.
 @param inputKeyPath    The foreign key to match with the local key.
 @param coreDataKey     The local key.
 @return                A VOKManagedObjectMap
 */
+ (instancetype)mapWithForeignKeyPath:(NSString *)inputKeyPath
                          coreDataKey:(NSString *)coreDataKey;
/**
 Creates a map with a date formatter. If the input object is an NSString the date formatter will be appied.
 @param inputKeyPath    The foreign key to match with the local key.
 @param coreDataKey     The local key.
 @param dateFormatter   A date formatter to parse in and out of core data.
 @return                A VOKManagedObjectMap
 */
+ (instancetype)mapWithForeignKeyPath:(NSString *)inputKeyPath
                          coreDataKey:(NSString *)coreDataKey
                        dateFormatter:(NSDateFormatter *)dateFormatter;
/**
 Creates a map with a number formatter. 
 If the input object is an NSNumber the number formatter will return an NSString.
 If the input object is an NSString the number formatter will return an NSNumber.
 @param inputKeyPath    The foreign key to match with the local key.
 @param coreDataKey     The local key.
 @param numberFormatter A number formatter to parse in and out of core data.
 @return                A VOKManagedObjectMap
 */
+ (instancetype)mapWithForeignKeyPath:(NSString *)inputKeyPath
                          coreDataKey:(NSString *)coreDataKey
                      numberFormatter:(NSNumberFormatter *)numberFormatter;

/**
 Make a dictionary of keys and values and get an array of maps in return.
 @param mapDict     Each key is the expected input keyPath and each value is core data key.
 @return            An array of VOKManagedObjectMaps.
 */
+ (NSArray *)mapsFromDictionary:(NSDictionary *)mapDict;

@end