//
//  NSManagedObject+VOKManagedObjectAdditions.m
//  Vokoder
//
//  Copyright © 2015 Vokal.
//

#import "NSManagedObject+VOKManagedObjectAdditions.h"

#import <objc/runtime.h>

#import "VOKCoreDataManager.h"

@implementation NSManagedObject (VOKManagedObjectAdditions)

- (void)vok_safeSetValue:(id)value forKey:(NSString *)key
{
    if (value && ![[NSNull null] isEqual:value]) {
        [self setValue:value forKey:key];
    } else {
        [self setNilValueForKey:key];
    }
}

- (NSDictionary *)vok_dictionaryRepresentation
{
    return [[VOKCoreDataManager sharedInstance] dictionaryRepresentationOfManagedObject:self respectKeyPaths:NO];
}

- (NSDictionary *)vok_dictionaryRepresentationRespectingKeyPaths
{
    return [[VOKCoreDataManager sharedInstance] dictionaryRepresentationOfManagedObject:self respectKeyPaths:YES];
}

+ (NSString *)vok_entityName
{
    return [[VOKCoreDataManager sharedInstance] entityNameForClass:self];
}

#pragma mark - Create Objects

+ (instancetype)vok_newInstance
{
    return [self vok_newInstanceWithContext:nil];
}

+ (instancetype)vok_newInstanceWithContext:(NSManagedObjectContext *)context
{
    return [[VOKCoreDataManager sharedInstance] managedObjectOfClass:self inContext:context];
}

#pragma mark - Add and Edit Objects

+ (NSArray *)vok_addWithArray:(NSArray *)inputArray forManagedObjectContext:(NSManagedObjectContext *)contextOrNil
{
    return [[VOKCoreDataManager sharedInstance] importArray:inputArray
                                                   forClass:[self class]
                                                withContext:contextOrNil];
}

+ (instancetype)vok_addWithDictionary:(NSDictionary *)inputDict forManagedObjectContext:(NSManagedObjectContext *)contextOrNil
{
    if (!inputDict || [[NSNull null] isEqual:inputDict]) {
        return nil;
    }

    NSArray *array = [[VOKCoreDataManager sharedInstance] importArray:@[inputDict]
                                                             forClass:[self class]
                                                          withContext:contextOrNil];
    return array.firstObject;
}

+ (void)vok_addWithArrayInBackground:(NSArray *)inputArray completion:(VOKManagedObjectsReturnBlock)completion
{
    VOKCoreDataManager *coreDataManager = VOKCoreDataManager.sharedInstance;
    [coreDataManager importArrayInBackground:inputArray
                                    forClass:[self class]
                                  completion:^(NSArray *arrayOfManagedObjectIDs) {
                                      if (completion) {
                                          // if there is no completion block there's no need to collect the new/updated objects
                                          NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:arrayOfManagedObjectIDs.count];
                                          NSManagedObjectContext *moc = [coreDataManager managedObjectContext];
                                          for (NSManagedObjectID *objectID in arrayOfManagedObjectIDs) {
                                              [returnArray addObject:[moc objectWithID:objectID]];
                                          }
                                          completion([returnArray copy]);
                                      }
                                  }];
}

#pragma mark - Fetching

+ (NSFetchRequest *)vok_fetchRequest
{
    return [self vok_fetchRequestWithPredicate:nil];
}

+ (NSFetchRequest *)vok_fetchRequestWithPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self vok_entityName]];
    fetchRequest.predicate = predicate;
    return fetchRequest;
}

+ (BOOL)vok_existsForPredicate:(NSPredicate *)predicate forManagedObjectContext:(NSManagedObjectContext *)contextOrNil
{
    return [[VOKCoreDataManager sharedInstance] countForClass:[self class]
                                                withPredicate:predicate
                                                   forContext:contextOrNil];
}

+ (NSArray *)vok_fetchAllForPredicate:(NSPredicate *)predicate forManagedObjectContext:(NSManagedObjectContext *)contextOrNil
{
    return [[VOKCoreDataManager sharedInstance] arrayForClass:[self class]
                                                withPredicate:predicate
                                                   forContext:contextOrNil];
}

+ (NSArray *)vok_fetchAllForPredicate:(NSPredicate *)predicate
                             sortedBy:(NSArray *)sortDescriptors
              forManagedObjectContext:(NSManagedObjectContext *)contextOrNil
{
    return [[VOKCoreDataManager sharedInstance] arrayForClass:[self class]
                                                withPredicate:predicate
                                                     sortedBy:sortDescriptors
                                                   forContext:contextOrNil];
}

+ (NSArray *)vok_fetchAllForPredicate:(NSPredicate *)predicate
                          sortedByKey:(NSString *)sortKey
                            ascending:(BOOL)ascending
              forManagedObjectContext:(NSManagedObjectContext *)contextOrNil
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:sortKey
                                                                     ascending:ascending];
    
    return [[VOKCoreDataManager sharedInstance] arrayForClass:[self class]
                                                withPredicate:predicate
                                                     sortedBy:@[ sortDescriptor ]
                                                   forContext:contextOrNil];
}

+ (instancetype)vok_fetchForPredicate:(NSPredicate *)predicate forManagedObjectContext:(NSManagedObjectContext *)contextOrNil
{
    NSArray *results = [self vok_fetchAllForPredicate:predicate forManagedObjectContext:contextOrNil];

    NSAssert(results.count <= 1, @"Your predicate is returning more than 1 object, but the coredatamanager returns only one.");
    return results.lastObject;
}

@end
