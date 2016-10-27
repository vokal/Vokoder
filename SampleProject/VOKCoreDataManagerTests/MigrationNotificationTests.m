//
//  MigrationNotificationTests.m
//  Vokoder Sample Project
//
//  Created by Brock Boland on 10/26/16.
//  Copyright © 2016 Vokal. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <VOKCoreDataManager.h>

@interface MigrationNotificationTests : XCTestCase

@property (nonatomic) NSURL *persistentStoreURL;

@end

@implementation MigrationNotificationTests

- (void)setUp
{
    [super setUp];

    [[VOKCoreDataManager sharedInstance] resetCoreData];

    // Load a copy of the DB that used the first version of the model
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSURL *oldPersistentStoreURL = [bundle URLForResource:@"MyDB" withExtension:@"sqlite"];

    XCTAssertNotNil(oldPersistentStoreURL, @"Cannot find MyDB.sqlite");

    NSURL *docsDir = [[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject;
    self.persistentStoreURL = [docsDir URLByAppendingPathComponent:@"testdb"];
    
    // Copy the old version of the database into the documents directory to work with
    NSError *error;
     [[NSFileManager defaultManager] copyItemAtURL:oldPersistentStoreURL
                                             toURL:self.persistentStoreURL
                                             error:&error];
     XCTAssertNil(error);
}

- (void)tearDown
{
    // Make sure the file doesn't lingered around after the test is done
    [[NSFileManager defaultManager] removeItemAtURL:self.persistentStoreURL error:nil];
    self.persistentStoreURL = nil;
    [super tearDown];
}

- (void)testWipeAndRecoverNotification
{
    [VOKCoreDataManager sharedInstance].migrationFailureOptions = VOKMigrationFailureOptionWipeRecovery;

    // Watch for the wipe and recovery notification
    [self expectationForNotification:VOKMigrationFailureWipeRecoveryNotificationName
                              object:nil
                             handler:nil];

    // Attempt to setup a persistent store that contains data from the old version of the model, but
    // do so using the current version - which will fail, since it can't infer the mapping model
    [[VOKCoreDataManager sharedInstance] setResource:@"BaseballModel"
                                         databaseURL:self.persistentStoreURL
                                              bundle:nil];

    // Wait for the notification of wipe and recovery
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
