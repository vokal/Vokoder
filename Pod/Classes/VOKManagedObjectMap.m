//
//  VOKManagedObjectMap.m
//  VOKCoreData
//
//  Copyright © 2015 Vokal.
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
        DefaultDateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'";
        DefaultDateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    });

    return DefaultDateFormatter;
}

+ (NSDateFormatter *)vok_dateFormatterWithoutMicroseconds
{
    static dispatch_once_t formatter_dispatch_token = 0;
    static NSDateFormatter *DateFormatterWithoutMicroseconds;
    dispatch_once(&formatter_dispatch_token, ^{
        DateFormatterWithoutMicroseconds = [NSDateFormatter new];
        DateFormatterWithoutMicroseconds.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
        DateFormatterWithoutMicroseconds.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    });

    return DateFormatterWithoutMicroseconds;
}

+ (NSNumberFormatter *)vok_defaultNumberFormatter
{
    static NSNumberFormatter *NumberFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NumberFormatter = [NSNumberFormatter new];
    });
    
    return NumberFormatter;
}

#pragma mark - Description

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p>\nCore Data Key : %@\nForeign Key : %@",
            NSStringFromClass([self class]), self, self.coreDataKey, self.inputKeyPath];
}

@end