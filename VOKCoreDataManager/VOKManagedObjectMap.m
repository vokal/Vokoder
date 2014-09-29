//
//  VOKManagedObjectMap.m
//  VOKCoreData
//

#import "VOKManagedObjectMap.h"
#import "VOKCoreDataManager.h"

@implementation VOKManagedObjectMap

+ (instancetype)mapWithForeignKeyPath:(NSString *)inputKeyPath coreDataKey:(NSString *)coreDataKey
{
    return [self mapWithForeignKeyPath:inputKeyPath coreDataKey:coreDataKey dateFormatter:[self vok_defaultDateFormatter]];
}

+ (instancetype)mapWithForeignKeyPath:(NSString *)inputKeyPath
                          coreDataKey:(NSString *)coreDataKey
                        dateFormatter:(NSDateFormatter *)dateFormatter
{
    VOKManagedObjectMap *map = [[self alloc] init];
    map.inputKeyPath = inputKeyPath;
    map.coreDataKey = coreDataKey;
    map.dateFormatter = dateFormatter;
    return map;
}

+ (instancetype)mapWithForeignKeyPath:(NSString *)inputKeyPath
                          coreDataKey:(NSString *)coreDataKey
                      numberFormatter:(NSNumberFormatter *)numberFormatter
{
    VOKManagedObjectMap *map = [[self alloc] init];
    map.inputKeyPath = inputKeyPath;
    map.coreDataKey = coreDataKey;
    map.numberFormatter = numberFormatter;
    return map;
}

+ (NSArray *)mapsFromDictionary:(NSDictionary *)mapDict
{
    NSMutableArray *mapArray = [NSMutableArray array];

    [mapDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        //key = input key, obj = core data key
        [mapArray addObject:[self mapWithForeignKeyPath:key coreDataKey:obj]];
    }];

    return [mapArray copy];
}

+ (NSDateFormatter *)vok_defaultDateFormatter
{
    static dispatch_once_t pred = 0;
    static NSDateFormatter *DefaultDateFormatter;
    dispatch_once(&pred, ^{
        DefaultDateFormatter = [NSDateFormatter new];
        [DefaultDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        [DefaultDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    });

    return DefaultDateFormatter;
}

#pragma mark - Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p>\nCore Data Key : %@\nForeign Key : %@",
            NSStringFromClass([self class]), self, self.coreDataKey, self.inputKeyPath];
}

@end