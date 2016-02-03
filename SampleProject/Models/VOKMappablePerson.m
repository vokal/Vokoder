//
//  VOKMappablePerson.m
//  SampleProject
//
//  Created by Isaac Greenspan on 8/31/15.
//  Copyright © 2015 Vokal.
//

#import "VOKMappablePerson.h"

#import <VOKMappableModel.h>

@interface VOKMappablePerson () <VOKMappableModel>

@end

@implementation VOKMappablePerson

#pragma mark - VOKMappableModel

+ (NSArray *)coreDataMaps
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd' 'LLL' 'yy' 'HH:mm"];
    [df setTimeZone:[NSTimeZone localTimeZone]];
    return @[
             VOKMapForeignToLocalForSelf(@"first", firstName),
             VOKMapForeignToLocalForSelf(@"last", lastName),
             [VOKManagedObjectMap mapWithForeignKeyPath:@"date_of_birth"
                                            coreDataKey:VOKKeyForSelf(birthDay)
                                          dateFormatter:df],
             VOKMapForeignToLocalForSelf(@"cat_num", numberOfCats),
             VOKMapForeignToLocalForSelf(@"CR_PREF", lovesCoolRanch),
             ];
}

+ (NSString *)uniqueKey
{
    return nil;
}

@end
