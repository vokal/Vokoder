//
//  NSManagedObject+VOKManagedObjectAdditions.m
//  VOKCoreData
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
    static char AssociatedObjectKey;  // The key for the runtime-association.
    
    // Get the associated value.
    NSString *vok_entityName = objc_getAssociatedObject(self, &AssociatedObjectKey);
    
    // If we didn't find an associated entity name, determine the entity name.
    if (!vok_entityName) {
        // If we already have an entityName class method (e.g., MOGenerator-generated subclasses), use it.
        // (Note that we have to cast self (a Class) to id to use NSObject's dynamic-selector methods, even though they work.)
        if ([(id)self respondsToSelector:@selector(entityName)]) {
            vok_entityName = [(id)self performSelector:@selector(entityName)];
        } else {
            
            // Since we don't have an entityName class method, look up the entity name in the managed object model.
            NSManagedObjectModel *model = [[VOKCoreDataManager sharedInstance] managedObjectModel];
            for (NSEntityDescription *description in model.entities) {
                if ([self isSubclassOfClass:NSClassFromString(description.managedObjectClassName)]) {
                    vok_entityName = description.name;
                    break;
                }
            }
        }
        NSAssert(vok_entityName, @"no entity found that uses %@ as its class", NSStringFromClass(self));
        // Save the determined entity name as an associated value.
        objc_setAssociatedObject(self, &AssociatedObjectKey, vok_entityName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return vok_entityName;
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
    if ([array count]) {
        return [array firstObject];
    } else {
        return nil;
    }
}

+ (void)vok_addWithArrayInBackground:(NSArray *)inputArray completion:(VOKManagedObjectsReturnBlock)completion
{
    [VOKCoreDataManager importArrayInBackground:inputArray
                                       forClass:[self class]
                                     completion:^(NSArray *arrayOfManagedObjectIDs) {
                                         if (completion) {
                                             // if there is no completion block there's no need to collect the new/updated objects
                                             NSMutableArray *returnArray = [NSMutableArray arrayWithCapacity:arrayOfManagedObjectIDs.count];
                                             NSManagedObjectContext *moc = [[VOKCoreDataManager sharedInstance] managedObjectContext];
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
    [fetchRequest setPredicate:predicate];
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

    NSUInteger count = [results count];
    if (count) {
        NSAssert(count == 1, @"Your predicate is returning more than 1 object, but the coredatamanger returns only one.");
        return [results lastObject];
    }

    return nil;
}

@end
