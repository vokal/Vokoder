//
//  DatabaseURLTests.m
//  SampleProject
//
//  Created by Carl Hill-Popper on 9/26/16.
//  Copyright © 2016 Vokal. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <VOKCoreDataManager.h>

@interface DatabaseURLTests : XCTestCase

@end

@implementation DatabaseURLTests

- (void)setUp
{
    [super setUp];
    
    [[VOKCoreDataManager sharedInstance] resetCoreData];
}

+ (void)tearDown
{
    [[VOKCoreDataManager sharedInstance] resetCoreData];

    [super tearDown];
}

- (void)testDefaultDatabaseURL
{
    //without setting an explicit database URL, the persistent store should be in the app's Library folder
    NSString *databaseName = @"test.sqlite";
 
    [[VOKCoreDataManager sharedInstance] setResource:@"VOKCoreDataModel"
                                            database:databaseName];
    
    NSURL *libraryFolder = [[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory
                                                                  inDomains:NSUserDomainMask].lastObject;
    XCTAssertEqualObjects([VOKCoreDataManager sharedInstance].persistentStoreFileURL,
                          [libraryFolder URLByAppendingPathComponent:databaseName]);
}

- (void)testCustomDatabaseURL
{
    //setting an explicit database URL should be possible
    NSURL *documentsFolder = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                    inDomains:NSUserDomainMask].lastObject;
    NSURL *databaseURL = [documentsFolder URLByAppendingPathComponent:@"test.sqlite"];
    
    [[VOKCoreDataManager sharedInstance] setResource:@"VOKCoreDataModel"
                                         databaseURL:databaseURL
                                              bundle:nil];

    XCTAssertEqualObjects([VOKCoreDataManager sharedInstance].persistentStoreFileURL, databaseURL);
    
    //make sure the URL is actually what is used by the persistent store
    NSManagedObjectContext *context = [VOKCoreDataManager sharedInstance].managedObjectContext;
    NSPersistentStoreCoordinator *coordinator = context.persistentStoreCoordinator;
    NSPersistentStore *store = coordinator.persistentStores.firstObject;
    XCTAssertEqualObjects(store.URL, databaseURL);
}

- (void)testInMemoryDatabaseURL
{
    //with an in-memory store, the persistentStoreFileURL should be nil
    [[VOKCoreDataManager sharedInstance] setResource:@"VOKCoreDataModel" database:nil];
    
    XCTAssertNil([VOKCoreDataManager sharedInstance].persistentStoreFileURL);
}

@end
