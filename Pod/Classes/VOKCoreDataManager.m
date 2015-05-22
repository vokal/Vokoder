//
//  VOKCoreDataManager.m
//  VOKCoreData
//

#import "VOKCoreDataManager.h"
#import "VOKCoreDataManagerInternalMacros.h"

@interface VOKCoreDataManager () {
    NSManagedObjectContext *_managedObjectContext;
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}

@property (nonatomic, copy) NSString *resource;
@property (nonatomic, copy) NSString *databaseFilename;
@property (nonatomic, strong) NSMutableDictionary *mapperCollection;

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

static NSOperationQueue *VOK_WritingQueue;
static VOKCoreDataManager *VOK_SharedObject;
+ (VOKCoreDataManager *)sharedInstance
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        VOK_SharedObject = [[self alloc] init];
        VOK_WritingQueue = [[NSOperationQueue alloc] init];
        [VOK_WritingQueue setMaxConcurrentOperationCount:1];
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
    self.resource = resource;
    self.databaseFilename = database;
    [[VOKCoreDataManager sharedInstance] managedObjectContext];
}

#pragma mark - Getters

- (NSManagedObjectContext *)tempManagedObjectContext
{
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    NSAssert(coordinator, @"PersistentStoreCoordinator does not exist. This is a big problem.");
    if (!coordinator) {
        return nil;
    }

    NSManagedObjectContext *tempManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSConfinementConcurrencyType];
        [tempManagedObjectContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [tempManagedObjectContext setPersistentStoreCoordinator:coordinator];

    return tempManagedObjectContext;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext) {
        [self initManagedObjectContext];
    }

    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel) {
        [self initManagedObjectModel];
    }

    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator) {
        [self initPersistentStoreCoordinator];
    }

    return _persistentStoreCoordinator;
}

#pragma mark - Initializers

- (void)initManagedObjectModel
{
    NSURL *modelURL = [[NSBundle bundleForClass:[self class]] URLForResource:self.resource withExtension:@"momd"];
    if (!modelURL) {
        modelURL = [[NSBundle bundleForClass:[self class]] URLForResource:self.resource withExtension:@"mom"];
    }
    NSAssert(modelURL, @"Managed object model not found.");
    if (modelURL) {
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
}

- (void)initPersistentStoreCoordinator
{
    NSAssert([NSOperationQueue currentQueue] == [NSOperationQueue mainQueue], @"Must be on the main queue when initializing persistant store coordinator");
    NSDictionary *options = @{
                              NSMigratePersistentStoresAutomaticallyOption: @YES,
                              NSInferMappingModelAutomaticallyOption: @YES,
                              };

    NSError *error;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    NSURL *storeURL = [self persistentStoreFileURL];
    NSString *storeType = NSInMemoryStoreType;
    if (storeURL) {
        //We have a store, use SQLite.
        storeType = NSSQLiteStoreType;
    }

    if (![_persistentStoreCoordinator addPersistentStoreWithType:storeType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:options
                                                           error:&error]) {
        if (self.migrationFailureOptions == VOKMigrationFailureOptionWipeRecoveryAndAlert) {
            [[[UIAlertView alloc] initWithTitle:@"Migration Failed"
                                        message:@"Migration has failed, data will be erased to ensure application stability."
                                       delegate:nil
                              cancelButtonTitle:@""
                              otherButtonTitles:nil] show];
        }

        if (self.migrationFailureOptions == VOKMigrationFailureOptionWipeRecoveryAndAlert ||
            self.migrationFailureOptions == VOKMigrationFailureOptionWipeRecovery) {
            VOK_CDLog(@"Full database delete and rebuild");
            [[NSFileManager defaultManager] removeItemAtPath:storeURL.path error:nil];
            if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                           configuration:nil
                                                                     URL:storeURL
                                                                 options:nil
                                                                   error:&error]) {
                VOK_CDLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    }
}

- (void)initManagedObjectContext
{
    NSAssert([NSOperationQueue currentQueue] == [NSOperationQueue mainQueue], @"Must be on the main queue when initializing main context");
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];

    NSAssert(coordinator, @"PersistentStoreCoordinator does not exist. This is a big problem.");
    if (!coordinator) {
        return;
    }
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        [_managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    }

#pragma mark - Create and configure

- (NSManagedObject *)managedObjectOfClass:(Class)managedObjectClass inContext:(NSManagedObjectContext *)contextOrNil
{
    contextOrNil = [self safeContext:contextOrNil];
    return [NSEntityDescription insertNewObjectForEntityForName:[managedObjectClass vok_entityName] inManagedObjectContext:contextOrNil];
}

- (BOOL)setObjectMapper:(VOKManagedObjectMapper *)objMapper forClass:(Class)objectClass
{
    if (objMapper && objectClass) {
        (self.mapperCollection)[NSStringFromClass(objectClass)] = objMapper;
        return YES;
    }

    return NO;
}

- (NSArray *)importArray:(NSArray *)inputArray forClass:(Class)objectClass withContext:(NSManagedObjectContext *)contextOrNil;
{
    VOKManagedObjectMapper *mapper = [self mapperForClass:objectClass];

    contextOrNil = [self safeContext:contextOrNil];

    NSArray *existingObjectArray;

    if (mapper.uniqueComparisonKey) {
        NSArray *arrayOfUniqueKeys = [inputArray valueForKeyPath:mapper.foreignUniqueComparisonKey];
        //filter out all NSNull's
        arrayOfUniqueKeys = [arrayOfUniqueKeys filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self != nil"]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(%K IN %@)", mapper.uniqueComparisonKey, arrayOfUniqueKeys];
        existingObjectArray = [self arrayForClass:objectClass withPredicate:predicate forContext:contextOrNil];
    }

    NSMutableArray *returnArray = [NSMutableArray array];
    
    for (NSDictionary *inputDict in inputArray) {
        if (![inputDict isKindOfClass:[NSDictionary class]]) {
            VOK_CDLog(@"ERROR\nExpecting an NSArray full of NSDictionaries");
            break;
        }

        NSManagedObject *returnObject;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", mapper.uniqueComparisonKey, [inputDict valueForKeyPath:mapper.foreignUniqueComparisonKey]];
        NSArray *matchingObjects = [existingObjectArray filteredArrayUsingPredicate:predicate];
        NSUInteger matchingObjectsCount = [matchingObjects count];

        if (matchingObjectsCount) {
            NSAssert(matchingObjectsCount < 2, @"UNIQUE IDENTIFIER IS NOT UNIQUE. MORE THAN ONE MATCHING OBJECT FOUND");
            returnObject = [matchingObjects firstObject];
            if (mapper.overwriteObjectsWithServerChanges) {
                [mapper setInformationFromDictionary:inputDict forManagedObject:returnObject];
            }
        } else {
            returnObject = [self managedObjectOfClass:objectClass inContext:contextOrNil];
            [mapper setInformationFromDictionary:inputDict forManagedObject:returnObject];
        }

        [returnArray addObject:returnObject];
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
    if (error) {
        VOK_CDLog(@"%s Fetch Request Error\n%@", __PRETTY_FUNCTION__, [error localizedDescription]);
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
    if (error) {
        VOK_CDLog(@"%s Fetch Request Error\n%@", __PRETTY_FUNCTION__, [error localizedDescription]);
    }
    
    return results;
}

- (id)existingObjectAtURI:(NSURL *)uri forManagedObjectContext:(NSManagedObjectContext *)contextOrNil
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
    [fetchRequest setIncludesPropertyValues:NO];

    NSError *error;
    NSArray *results = [contextOrNil executeFetchRequest:fetchRequest error:&error];
    if (error) {
        VOK_CDLog(@"%s Fetch Request Error\n%@", __PRETTY_FUNCTION__, [error localizedDescription]);
        return NO;
    }

    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [contextOrNil deleteObject:obj];
    }];

    return YES;
}

#pragma mark - Thread Safety with Main MOC

- (NSManagedObjectContext *)safeContext:(NSManagedObjectContext *)context
{
    if (!context) {
        context = [self managedObjectContext];
    }

    if (context == [self managedObjectContext]) {
        NSAssert([NSOperationQueue currentQueue] == [NSOperationQueue mainQueue], @"XXX ALERT ALERT XXXX\nNOT ON MAIN QUEUE!");
    }

    return context;
}

#pragma mark - Context Saving and Merging

- (void)saveMainContext
{
    if ([NSOperationQueue mainQueue] == [NSOperationQueue currentQueue]) {
        [self saveContext:[self managedObjectContext]];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self saveContext:[self managedObjectContext]];
        });
    }
}

- (void)saveMainContextAndWait
{
    if ([NSOperationQueue mainQueue] == [NSOperationQueue currentQueue]) {
        [self saveContext:[self managedObjectContext]];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self saveContext:[self managedObjectContext]];
        });
    }
}

- (void)saveContext:(NSManagedObjectContext *)context
{
    NSError *error;
    if (![context save:&error]) {
        VOK_CDLog(@"Unresolved error %@, %@", error, [error localizedDescription]);
    }
}

- (void)saveTempContext:(NSManagedObjectContext *)tempContext
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tempContextSaved:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:tempContext];

    [self saveContext:tempContext];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:tempContext];
}

- (void)tempContextSaved:(NSNotification *)notification
{
    // Solved issue with NSFetchedResultsController ignoring changes
    // merged from different managed object contexts by touching
    // willAccessValueForKey: on the updated objects.
    //http://stackoverflow.com/questions/3923826/nsfetchedresultscontroller-with-predicate-ignores-changes-merged-from-different
    
    for (NSManagedObject *object in [[notification userInfo] objectForKey:NSUpdatedObjectsKey]) {
        [[[self managedObjectContext] objectWithID:[object objectID]] willAccessValueForKey:nil];
    }
    
    if ([NSOperationQueue mainQueue] == [NSOperationQueue currentQueue]) {
        [[self managedObjectContext] mergeChangesFromContextDidSaveNotification:notification];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [[self managedObjectContext] mergeChangesFromContextDidSaveNotification:notification];
        });
    }
    [self saveMainContextAndWait];
}

- (NSManagedObjectContext *)temporaryContext
{
    return [self tempManagedObjectContext];
}

- (void)saveAndMergeWithMainContext:(NSManagedObjectContext *)context
{
    NSAssert(context != [self managedObjectContext], @"This is NOT for saving the main context.");
    [self saveTempContext:context];
}

#pragma mark - Background Importing

+ (void)writeToTemporaryContext:(VOKWriteBlock)writeBlock
                     completion:(void (^)(void))completion
{
    NSAssert(writeBlock, @"Write block must not be nil");
    [VOK_WritingQueue addOperationWithBlock:^{

        NSManagedObjectContext *tempContext = [[VOKCoreDataManager sharedInstance] temporaryContext];
        writeBlock(tempContext);
        [[VOKCoreDataManager sharedInstance] saveAndMergeWithMainContext:tempContext];

        if (completion) {
            dispatch_async(dispatch_get_main_queue(), completion);
        }
    }];
}

+ (void)importArrayInBackground:(NSArray *)inputArray
                       forClass:(Class)objectClass
                     completion:(VOKObjectIDsReturnBlock)completion
{
    [VOK_WritingQueue addOperationWithBlock:^{
        
        NSManagedObjectContext *tempContext = [[VOKCoreDataManager sharedInstance] temporaryContext];
        NSArray *managedObjectsArray = [[VOKCoreDataManager sharedInstance] importArray:inputArray
                                                                               forClass:objectClass
                                                                            withContext:tempContext];
        [[VOKCoreDataManager sharedInstance] saveAndMergeWithMainContext:tempContext];

        if (completion) {
            // only obtain permanent IDs if they're needed for the completion block
            NSError *error;
            BOOL gotPermanentID = [tempContext obtainPermanentIDsForObjects:managedObjectsArray error:&error];
            if (!gotPermanentID) {
                VOK_CDLog(@"Unable to obtain permanent object IDs %@, %@", error, [error userInfo]);
            }

            NSArray *arrayOfManagedObjectIDs = [managedObjectsArray valueForKeyPath:VOK_CDSELECTOR(objectID)];

            dispatch_sync(dispatch_get_main_queue(), ^{
                completion(arrayOfManagedObjectIDs);
            });
        }
    }];
}

#pragma mark - Convenience Methods

- (NSFetchRequest *)fetchRequestWithClass:(Class)managedObjectClass predicate:(NSPredicate *)predicate
{
    NSString *entityName = [managedObjectClass vok_entityName];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    [fetchRequest setPredicate:predicate];
    return fetchRequest;
}

-(NSFetchRequest *)fetchRequestWithClass:(Class)managedObjectClass
                               predicate:(NSPredicate *)predicate
                         sortDescriptors:(NSArray*)sortDescriptors
{
    NSFetchRequest *fetchRequest = [self fetchRequestWithClass:managedObjectClass
                                                     predicate:predicate];
    [fetchRequest setSortDescriptors:sortDescriptors];
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
    return [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)resetCoreData
{
    NSArray *stores = [[self persistentStoreCoordinator] persistentStores];

    for (NSPersistentStore *store in stores) {
        [[self persistentStoreCoordinator] removePersistentStore:store error:nil];
        if (self.databaseFilename) {
            [[NSFileManager defaultManager] removeItemAtPath:store.URL.path error:nil];            
        }
    }
    
    _persistentStoreCoordinator = nil;
    _managedObjectContext = nil;
    _managedObjectModel = nil;
    [_mapperCollection removeAllObjects];
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