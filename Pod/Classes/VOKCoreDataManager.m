//
//  VOKCoreDataManager.m
//  VOKCoreData
//
//  Copyright © 2015 Vokal.
//

#import "VOKCoreDataManager.h"
#import "VOKCoreDataManagerInternalMacros.h"

#import <ILGDynamicObjC/ILGClasses.h>
#import <VOKUtilities/VOKKeyPathHelper.h>

#import "VOKMappableModel.h"

@interface VOKCoreDataManager ()

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
///A private parent context for writing to the persistent store
@property (nonatomic, strong) NSManagedObjectContext *privateRootContext;

@property (nonatomic, copy) NSString *resource;
@property (nonatomic, copy) NSString *databaseFilename;
@property (nonatomic, strong) NSMutableDictionary *mapperCollection;
@property (nonatomic, strong) NSBundle *bundleForModel;

@end

//private interface to VOKManagedObjectMapper
@interface VOKManagedObjectMapper (dictionaryInputOutput)
- (void)setInformationFromDictionary:(NSDictionary *)inputDict forManagedObject:(NSManagedObject *)object;
- (NSDictionary *)dictionaryRepresentationOfManagedObject:(NSManagedObject *)object;
- (NSDictionary *)hierarchicalDictionaryRepresentationOfManagedObject:(NSManagedObject *)object;

@end

@implementation VOKCoreDataManager

+ (void)initialize
{
    //make sure the shared instance is ready
    [self sharedInstance];
}

static VOKCoreDataManager *VOK_SharedObject;
+ (VOKCoreDataManager *)sharedInstance
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        VOK_SharedObject = [[self alloc] init];
        [VOK_SharedObject addMappableModelMappers];
    });
    return VOK_SharedObject;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mapperCollection = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)setResource:(NSString *)resource database:(NSString *)database
{
    [self setResource:resource
             database:database
               bundle:nil];
}

- (void)setResource:(NSString *)resource
           database:(NSString *)database
             bundle:(NSBundle *)bundle
{
    self.resource = resource;
    self.databaseFilename = database;
    
    if (bundle) {
        self.bundleForModel = bundle;
    }
    
    [[VOKCoreDataManager sharedInstance] managedObjectContext];
}

#pragma mark - Getters

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        self.privateRootContext = [self managedObjectContextWithConcurrencyType:NSPrivateQueueConcurrencyType
                                                                  parentContext:nil];
        //main context is a main queue child of the root
        _managedObjectContext = [self managedObjectContextWithConcurrencyType:NSMainQueueConcurrencyType
                                                                parentContext:self.privateRootContext];
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel) {
        NSURL *modelURL = [self.bundleForModel URLForResource:self.resource withExtension:@"momd"];
        if (!modelURL) {
            modelURL = [self.bundleForModel URLForResource:self.resource withExtension:@"mom"];
        }
        NSAssert(modelURL, @"Managed object model not found.");
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator) {
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
        [self addPersistentStoreToCoordinator:_persistentStoreCoordinator];
    }
    
    return _persistentStoreCoordinator;
}

- (NSBundle *)bundleForModel
{
    if (!_bundleForModel) {
        //Default to using the main bundle
        _bundleForModel = [NSBundle mainBundle];
    }
    
    return _bundleForModel;
}

#pragma mark - Initializers

- (void)addPersistentStoreToCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption: @YES,
                              NSInferMappingModelAutomaticallyOption: @YES,
                              };
    
    NSURL *storeURL = [self persistentStoreFileURL];
    NSString *storeType = NSInMemoryStoreType;
    if (storeURL) {
        //We have a store, use SQLite.
        storeType = NSSQLiteStoreType;
    }
    
    NSError *error;
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:storeType
                                                  configuration:nil
                                                            URL:storeURL
                                                        options:options
                                                          error:&error]) {
        switch (self.migrationFailureOptions) {
            case VOKMigrationFailureOptionWipeRecoveryAndAlert:
            {
                NSString *title = @"Migration Failed";
                NSString *message = @"Migration has failed, data will be erased to ensure application stability.";
#ifdef __IPHONE_8_0 //if compiling with an old version of Xcode that doesn't include the iOS 8 SDK, ignore UIAlertController
                if ([UIAlertController class]) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                                   message:message
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert
                                                                                                 animated:YES
                                                                                               completion:nil];
                } else {
#endif
                    //TODO: delete UIAlertView once support is dropped for iOS 7
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [[[UIAlertView alloc] initWithTitle:title
                                                message:message
                                               delegate:nil
                                      cancelButtonTitle:@""
                                      otherButtonTitles:nil] show];
#pragma clang diagnostic pop
#ifdef __IPHONE_8_0
                }
#endif
            }
                //intentional fallthrough
            case VOKMigrationFailureOptionWipeRecovery:
                VOK_CDLog(@"Full database delete and rebuild");
                [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:nil];
                if (![persistentStoreCoordinator addPersistentStoreWithType:storeType
                                                              configuration:nil
                                                                        URL:storeURL
                                                                    options:options
                                                                      error:&error]) {
                    [NSException raise:@"Vokoder Persistent Store Creation Failure after migration"
                                format:@"Unresolved error %@, %@", error, [error userInfo]];
                }
                break;
            case VOKMigrationFailureOptionNone:
                VOK_CDLog(@"Vokoder Persistent Store Creation Failure: %@", error);
                break;
        }
    }
}

- (NSManagedObjectContext *)managedObjectContextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType
                                                      parentContext:(nullable NSManagedObjectContext *)parentContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
    if (parentContext) {
        context.parentContext = parentContext;
    } else {
        NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
        
        NSAssert(coordinator, @"PersistentStoreCoordinator does not exist. This is a big problem.");
        if (!coordinator) {
            return nil;
        }
        context.persistentStoreCoordinator = coordinator;
    }
    context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
    
    return context;
}

#pragma mark - Create and configure

- (NSManagedObject *)managedObjectOfClass:(Class)managedObjectClass inContext:(NSManagedObjectContext *)contextOrNil
{
    contextOrNil = [self safeContext:contextOrNil];
    return [NSEntityDescription insertNewObjectForEntityForName:[managedObjectClass vok_entityName]
                                         inManagedObjectContext:contextOrNil];
}

- (BOOL)setObjectMapper:(VOKManagedObjectMapper *)objMapper forClass:(Class)objectClass
{
    if (objMapper && objectClass) {
        self.mapperCollection[NSStringFromClass(objectClass)] = objMapper;
        return YES;
    }
    
    return NO;
}

- (void)addMappableModelMappers
{
    for (Class mappableModelClass in [ILGClasses classesConformingToProtocol:@protocol(VOKMappableModel)]) {
        VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:[mappableModelClass uniqueKey]
                                                                             andMaps:[mappableModelClass coreDataMaps]];
        if ([mappableModelClass respondsToSelector:@selector(ignoreNullValueOverwrites)]) {
            mapper.ignoreNullValueOverwrites = [mappableModelClass ignoreNullValueOverwrites];
        }
        if ([mappableModelClass respondsToSelector:@selector(ignoreOptionalNullValues)]) {
            mapper.ignoreOptionalNullValues = [mappableModelClass ignoreOptionalNullValues];
        }
        if ([mappableModelClass respondsToSelector:@selector(importCompletionBlock)]) {
            mapper.importCompletionBlock = [mappableModelClass importCompletionBlock];
        }
        [self setObjectMapper:mapper
                     forClass:mappableModelClass];
    }
}

- (NSArray *)importArray:(NSArray *)inputArray forClass:(Class)objectClass withContext:(NSManagedObjectContext *)contextOrNil
{
    VOKManagedObjectMapper *mapper = [self mapperForClass:objectClass];
    
    contextOrNil = [self safeContext:contextOrNil];
    
    NSMutableArray *existingObjectArray;
    NSMutableArray *existingUniqueKeys;

    if (mapper.uniqueComparisonKey) {
        NSArray *arrayOfUniqueKeys = [inputArray valueForKeyPath:mapper.foreignUniqueComparisonKey];
        //filter out all NSNull's
        arrayOfUniqueKeys = [arrayOfUniqueKeys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self != nil"]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K IN %@)", mapper.uniqueComparisonKey, arrayOfUniqueKeys];
        existingObjectArray = [[self arrayForClass:objectClass withPredicate:predicate forContext:contextOrNil] mutableCopy];
        existingUniqueKeys = [[existingObjectArray valueForKeyPath:mapper.uniqueComparisonKey] mutableCopy];
    }
    
    NSMutableArray *returnArray = [NSMutableArray array];
    
    for (NSDictionary *inputDict in inputArray) {
        if (![inputDict isKindOfClass:[NSDictionary class]]) {
            VOK_CDLog(@"ERROR\nExpecting an NSArray full of NSDictionaries");
            break;
        }
        
        NSManagedObject *returnObject;
        
        NSArray *matchingObjects;
        id inputKey = [inputDict valueForKeyPath:mapper.foreignUniqueComparisonKey];
        
        // If the incoming dictionary has the unique key and that unique key is in the array of existing unique keys…
        if (inputKey && [existingUniqueKeys containsObject:inputKey]) {
            // … find any objects we already know about with that unique key.
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", mapper.uniqueComparisonKey, inputKey];
            matchingObjects = [existingObjectArray filteredArrayUsingPredicate:predicate];
        }
        
        // If there are already existing object(s) with the same unique key as the incoming dictionary…
        NSUInteger matchingObjectsCount = matchingObjects.count;
        if (matchingObjectsCount) {
            // … there should only be one…
            NSAssert(matchingObjectsCount < 2, @"UNIQUE IDENTIFIER IS NOT UNIQUE. MORE THAN ONE MATCHING OBJECT FOUND");
            returnObject = matchingObjects.firstObject;
            // … update the existing object, if we're supposed to update it with changes.
            if (mapper.overwriteObjectsWithServerChanges) {
                [mapper setInformationFromDictionary:inputDict forManagedObject:returnObject];
            }
        } else {
            // Otherwise (no existing objects that match the incoming dictionary's unique key), create a new object…
            returnObject = [self managedObjectOfClass:objectClass inContext:contextOrNil];
            [mapper setInformationFromDictionary:inputDict forManagedObject:returnObject];
            // … and if the incoming dictionary had a unique key, add the new object and its key to the appropriate arrays.
            if (inputKey) {
                [existingObjectArray addObject:returnObject];
                [existingUniqueKeys addObject:inputKey];
            }
        }
        
        // If the object we just created or updated isn't already in the return array, add it.
        if (![returnArray containsObject:returnObject]) {
            [returnArray addObject:returnObject];
        }
    };
    
    return [returnArray copy];
}

- (void)setInformationFromDictionary:(NSDictionary *)inputDict forManagedObject:(NSManagedObject *)object
{
    VOKManagedObjectMapper *mapper = [self mapperForClass:[object class]];
    [mapper setInformationFromDictionary:inputDict forManagedObject:object];
}

#pragma mark - Convenient Output

- (NSDictionary *)dictionaryRepresentationOfManagedObject:(NSManagedObject *)object respectKeyPaths:(BOOL)keyPathsEnabled
{
    VOKManagedObjectMapper *mapper = [self mapperForClass:[object class]];
    if (keyPathsEnabled) {
        return [mapper hierarchicalDictionaryRepresentationOfManagedObject:object];
    } else {
        return [mapper dictionaryRepresentationOfManagedObject:object];
    }
}

#pragma mark - Count, Fetch, and Delete

- (NSUInteger)countForClass:(Class)managedObjectClass
{
    return [self countForClass:managedObjectClass forContext:nil];
}

- (NSUInteger)countForClass:(Class)managedObjectClass forContext:(NSManagedObjectContext *)contextOrNil
{
    return [self countForClass:managedObjectClass withPredicate:nil forContext:contextOrNil];
}

- (NSUInteger)countForClass:(Class)managedObjectClass withPredicate:(NSPredicate *)predicate forContext:(NSManagedObjectContext *)contextOrNil
{
    contextOrNil = [self safeContext:contextOrNil];
    NSFetchRequest *fetchRequest = [self fetchRequestWithClass:managedObjectClass predicate:predicate];
    
    NSError *error;
    NSUInteger count = [contextOrNil countForFetchRequest:fetchRequest error:&error];
    if (count == NSNotFound) {
        VOK_CDLog(@"Fetch Request Error\n%@", error.localizedDescription);
    }
    
    return count;
}

- (NSArray *)arrayForClass:(Class)managedObjectClass
{
    return [self arrayForClass:managedObjectClass forContext:nil];
}

- (NSArray *)arrayForClass:(Class)managedObjectClass forContext:(NSManagedObjectContext *)contextOrNil
{
    return [self arrayForClass:managedObjectClass withPredicate:nil forContext:contextOrNil];
}

- (NSArray *)arrayForClass:(Class)managedObjectClass withPredicate:(NSPredicate *)predicate forContext:(NSManagedObjectContext *)contextOrNil
{
    contextOrNil = [self safeContext:contextOrNil];
    NSFetchRequest *fetchRequest = [self fetchRequestWithClass:managedObjectClass predicate:predicate];
    
    return [self arrayForFetchRequest:fetchRequest inContext:contextOrNil];
}

- (NSArray *)arrayForClass:(Class)managedObjectClass
             withPredicate:(NSPredicate *)predicate
                  sortedBy:(NSArray *)sortDescriptors
                forContext:(NSManagedObjectContext *)contextOrNil
{
    contextOrNil = [self safeContext:contextOrNil];
    NSFetchRequest *fetchRequest = [self fetchRequestWithClass:managedObjectClass
                                                     predicate:predicate
                                               sortDescriptors:sortDescriptors];
    return [self arrayForFetchRequest:fetchRequest inContext:contextOrNil];
}

-(NSArray *)arrayForFetchRequest:(NSFetchRequest *)fetchRequest
                       inContext:(NSManagedObjectContext *)context
{
    NSError *error;
    NSArray *results = [context executeFetchRequest:fetchRequest error:&error];
    if (!results) {
        VOK_CDLog(@"Fetch Request Error\n%@", error.localizedDescription);
    }
    
    return results;
}

- (NSManagedObject *)existingObjectAtURI:(NSURL *)uri forManagedObjectContext:(NSManagedObjectContext *)contextOrNil
{
    NSManagedObjectID *objectID = [self.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
    
    NSError *error;
    
    if (!objectID) {
        VOK_CDLog(@"No object exists at\n%@", uri);
        return nil;
    }
    
    contextOrNil = [self safeContext:contextOrNil];
    id returnObject = [contextOrNil existingObjectWithID:objectID error:&error];
    
    if (!returnObject) {
        VOK_CDLog(@"No object exists at\n%@.\n\nError:\n%@", uri, error);
    }
    
    return returnObject;
}

- (void)deleteObject:(NSManagedObject *)object
{
    [[object managedObjectContext] deleteObject:object];
}

- (BOOL)deleteAllObjectsOfClass:(Class)managedObjectClass context:(NSManagedObjectContext *)contextOrNil
{
    return [self deleteAllObjectsOfClass:managedObjectClass
                       matchingPredicate:nil
                                 context:contextOrNil];
}

- (BOOL)deleteAllObjectsOfClass:(Class)managedObjectClass
              matchingPredicate:(NSPredicate *)predicate
                        context:(NSManagedObjectContext *)contextOrNil
{
    contextOrNil = [self safeContext:contextOrNil];
    NSFetchRequest *fetchRequest = [self fetchRequestWithClass:managedObjectClass predicate:predicate];
    fetchRequest.includesPropertyValues = NO;
    
    NSError *error;
    NSArray *results = [contextOrNil executeFetchRequest:fetchRequest error:&error];
    if (!results) {
        VOK_CDLog(@"Fetch Request Error\n%@", error.localizedDescription);
        return NO;
    }
    
    for (NSManagedObject *object in results) {
        [contextOrNil deleteObject:object];
    }
    
    return YES;
}

#pragma mark - Thread Safety with Main MOC

- (NSManagedObjectContext *)safeContext:(NSManagedObjectContext *)context
{
    if (!context) {
        context = self.managedObjectContext;
    }
    
    if (context == self.managedObjectContext) {
        NSAssert([NSOperationQueue currentQueue] == [NSOperationQueue mainQueue], @"XXX ALERT ALERT XXXX\nNOT ON MAIN QUEUE!");
    }
    
    return context;
}

#pragma mark - Context Saving and Merging

- (void)saveMainContext
{
    [self saveContext:self.managedObjectContext andWait:NO];
}

- (void)saveMainContextAndWait
{
    [self saveContext:self.managedObjectContext andWait:YES];
}

- (void)obtainPermanentIDsForInsertionsInContext:(NSManagedObjectContext *)context
{
    [context performBlockAndWait:^{
        NSError *error;
        if (![context obtainPermanentIDsForObjects:context.insertedObjects.allObjects
                                             error:&error]) {
            VOK_CDLog(@"Error obtaining permanent ID for insertions: %@", error);
        }
    }];
}

/**
 Save any changes to a managed object context to the persistent store.
 If a context has no changes, no saves will be performed.
 
 @param context The context to save
 @param wait Whether to save synchronously (YES) or asynchronously (NO)
 */
- (void)saveContext:(NSManagedObjectContext *)context
            andWait:(BOOL)wait
{
    //The documentation indicates that this method is not thread safe.
    //We can't guarantee that the current method is called on the appropriate thread for this context,
    //so use performBlockAndWait to query the context for changes.
    __block BOOL hasChanges;
    [context performBlockAndWait:^{
        hasChanges = context.hasChanges;
    }];
    
    if (!hasChanges) {
        return;
    }
    
    [self obtainPermanentIDsForInsertionsInContext:context];
    [self saveContextToRoot:context andWait:wait];
}

/**
 Save a managed object context and all of its parent contexts.  
 This method is called recursively on the context's parentContext.
 
 @param context The context to save
 @param wait Whether to save synchronously (YES) or asynchronously (NO)
 */
- (void)saveContextToRoot:(NSManagedObjectContext *)context
                  andWait:(BOOL)wait
{
    void (^saveBlock)() = ^{
        NSError *error;
        if ([context save:&error]) {
            if (context.parentContext) {
                [self saveContextToRoot:context.parentContext andWait:wait];
            }
        } else {
            VOK_CDLog(@"Unresolved error %@, %@", error, error.localizedDescription);
        }
    };
    
    //At this point, the main context is already saved.
    //The root context can be saved asynchronously
    //since all access to Core Data should be going through the main context or a child temp context.
    if (context == self.privateRootContext) {
        wait = NO;
    }
    
    if (wait) {
        [context performBlockAndWait:saveBlock];
    } else {
        [context performBlock:saveBlock];
    }
}

- (NSManagedObjectContext *)temporaryContext
{
    return [self managedObjectContextWithConcurrencyType:NSPrivateQueueConcurrencyType
                                           parentContext:self.managedObjectContext];
}

- (void)saveAndMergeWithMainContext:(NSManagedObjectContext *)context
{
    NSAssert(context.parentContext != nil,
             @"%@ is for saving temp contexts that are descendents of the main context!",
             NSStringFromSelector(_cmd));
    [self saveContext:context andWait:NO];
}

- (void)saveAndMergeWithMainContextAndWait:(NSManagedObjectContext *)context;
{
    NSAssert(context.parentContext != nil,
             @"%@ is for saving temp contexts that are descendents of the main context!",
             NSStringFromSelector(_cmd));
    [self saveContext:context andWait:YES];
}

#pragma mark - Background Importing

+ (void)writeToTemporaryContext:(VOKWriteBlock)writeBlock
                     completion:(void (^)(void))completion
{
    NSAssert(writeBlock, @"Write block must not be nil");
    
    NSManagedObjectContext *tempContext = [[VOKCoreDataManager sharedInstance] temporaryContext];
    [tempContext performBlock:^{
        writeBlock(tempContext);
        
        BOOL wait = (completion != nil);
        [[VOKCoreDataManager sharedInstance] saveContext:tempContext andWait:wait];
        
        if (completion) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:completion];
        }
    }];
}

+ (void)importArrayInBackground:(NSArray *)inputArray
                       forClass:(Class)objectClass
                     completion:(VOKObjectIDsReturnBlock)completion
{
    NSManagedObjectContext *tempContext = [[VOKCoreDataManager sharedInstance] temporaryContext];
    [tempContext performBlock:^{
        
        NSArray *managedObjectsArray = [[VOKCoreDataManager sharedInstance] importArray:inputArray
                                                                               forClass:objectClass
                                                                            withContext:tempContext];
        BOOL wait = (completion != nil);
        [[VOKCoreDataManager sharedInstance] saveContext:tempContext andWait:wait];
        
        if (completion) {
            NSArray *arrayOfManagedObjectIDs = [managedObjectsArray valueForKeyPath:VOKKeyForInstanceOf(VOKManagedObjectSubclass, objectID)];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                completion(arrayOfManagedObjectIDs);
            }];
        }
    }];
}

#pragma mark - Convenience Methods

- (NSFetchRequest *)fetchRequestWithClass:(Class)managedObjectClass predicate:(NSPredicate *)predicate
{
    NSString *entityName = [managedObjectClass vok_entityName];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    fetchRequest.predicate = predicate;
    return fetchRequest;
}

-(NSFetchRequest *)fetchRequestWithClass:(Class)managedObjectClass
                               predicate:(NSPredicate *)predicate
                         sortDescriptors:(NSArray*)sortDescriptors
{
    NSFetchRequest *fetchRequest = [self fetchRequestWithClass:managedObjectClass
                                                     predicate:predicate];
    fetchRequest.sortDescriptors = sortDescriptors;
    return fetchRequest;
}

- (VOKManagedObjectMapper *)mapperForClass:(Class)objectClass
{
    VOKManagedObjectMapper *mapper = self.mapperCollection[NSStringFromClass(objectClass)];
    while (!mapper && objectClass) {
        objectClass = [objectClass superclass];
        mapper = self.mapperCollection[NSStringFromClass(objectClass)];
        
        if (objectClass == [NSManagedObject class] && !mapper) {
            mapper = [VOKManagedObjectMapper defaultMapper];
        }
    }
    
    return mapper;
}

- (NSURL *)applicationLibraryDirectory
{
    return [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask].lastObject;
}

- (void)resetCoreData
{
    //Use the instance variable so as not to accidentally spin up a new instance if
    //one does not already exist.
    NSArray *stores = [_persistentStoreCoordinator persistentStores];
    
    for (NSPersistentStore *store in stores) {
        [self.persistentStoreCoordinator removePersistentStore:store error:nil];
        if (self.databaseFilename) {
            [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];
        }
    }
    
    _persistentStoreCoordinator = nil;
    _managedObjectContext = nil;
    _privateRootContext = nil;
    _managedObjectModel = nil;
    _bundleForModel = nil;
    [_mapperCollection removeAllObjects];
    [self addMappableModelMappers];
}

- (NSURL *)persistentStoreFileURL
{
    if (!self.databaseFilename) {
        return nil;
    } else {
        return [[self applicationLibraryDirectory] URLByAppendingPathComponent:self.databaseFilename];
    }
}

@end
