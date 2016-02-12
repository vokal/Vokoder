//
//  VOKManagedObjectAdditionTests.m
//  Vokoder Sample Project
//
//  Created by Rohan Vokal on 2/17/15.
//  Copyright © 2015 Vokal.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <VOKCoreDataManager.h>
#import <NSManagedObject+VOKManagedObjectAdditions.h>
#import "VOKThing.h"

#import "VOKEntityA.h"
#import "VOKEntityB.h"
#import "VOKEntityC.h"

static const NSUInteger BasicTestDataStartPoint = 0;
static const NSUInteger BasicTestDataSize = 5;

@interface VOKManagedObjectForTestGettingEntityName : NSManagedObject @end

@implementation VOKManagedObjectForTestGettingEntityName @end

@interface VOKManagedObjectAdditionTests : XCTestCase

@end

@implementation VOKManagedObjectAdditionTests

- (void)setUp
{
    [super setUp];
    [[VOKCoreDataManager sharedInstance] resetCoreData];
    [[VOKCoreDataManager sharedInstance] setResource:@"VOKCoreDataModel"
                                            database:nil];
}

#pragma mark - Test Data Helper Methods

- (void)loadWithBasicTestData
{
    for (int i = BasicTestDataStartPoint; i < BasicTestDataSize; i++) {
        VOKThing *thing = [VOKThing vok_newInstance];
        [thing setName:[NSString stringWithFormat:@"test-%i", i]];
        [thing setNumberOfHats:[NSNumber numberWithInt:i]];
    }
    [[VOKCoreDataManager sharedInstance] saveMainContextAndWait];
}

#pragma mark - New Instance Methods

- (void)testRecordInsertion
{
    XCTAssertEqual([VOKThing vok_fetchAllForPredicate:nil
                              forManagedObjectContext:nil].count, 0);
    
    VOKThing *thing = [VOKThing vok_newInstance];
    [thing setName:@"test-1"];
    [thing setNumberOfHats:@1];
    [[VOKCoreDataManager sharedInstance] saveMainContextAndWait];
    
    XCTAssertEqual([VOKThing vok_fetchAllForPredicate:nil
                              forManagedObjectContext:nil].count, 1);
}

- (void)testRecordInsertionBackgroundThreadManual
{
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"completion"];
    
    XCTAssertEqual([VOKThing vok_fetchAllForPredicate:nil
                              forManagedObjectContext:nil].count, 0);
    
    NSManagedObjectContext *backgroundContext = [[VOKCoreDataManager sharedInstance] temporaryContext];
    [backgroundContext performBlock:^{
        VOKThing *thing = [VOKThing vok_newInstanceWithContext:backgroundContext];
        thing.name = @"test-2";
        thing.numberOfHats = @2;
        [[VOKCoreDataManager sharedInstance] saveAndMergeWithMainContextAndWait:backgroundContext];
        
        [completionExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertNil(error, @"Error waiting for response:%@", error.description);
        XCTAssertEqual([VOKThing vok_fetchAllForPredicate:nil
                                  forManagedObjectContext:nil].count, 1);
    }];
}

- (void)testRecordInsertionBackgroundThreadConvenience
{
    XCTestExpectation *completionHandlerExpectation = [self expectationWithDescription:@"completion"];
    
    XCTAssertEqual([VOKThing vok_fetchAllForPredicate:nil
                              forManagedObjectContext:nil].count, 0);
    
    [VOKCoreDataManager writeToTemporaryContext:^(NSManagedObjectContext *tempContext) {
        
        VOKThing *thing = [VOKThing vok_newInstanceWithContext:tempContext];
        [thing setName:@"test-2"];
        [thing setNumberOfHats:@2];
        
    } completion:^{
        XCTAssertEqual([VOKThing vok_fetchAllForPredicate:nil
                                  forManagedObjectContext:nil].count, 1);
        
        [completionHandlerExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertNil(error, @"Error waiting for response:%@", error.description);
    }];
}

- (void)testRecordInsertionBackgroundThreadConvenienceReturningManagedObjectsArray
{
    XCTestExpectation *completionHandlerExpectation = [self expectationWithDescription:@"completion"];
    
    XCTAssertEqual([VOKThing vok_fetchAllForPredicate:nil
                              forManagedObjectContext:nil].count, 0);
    NSArray *importArray = @[
                             @{
                                 @"name" : @"bobbbb",
                                 @"numberOfHats" : @0,
                                 },
                             @{
                                 @"name" : @"francis",
                                 @"numberOfHats" : @7,
                                 },
                             @{
                                 @"name" : @"mcgil",
                                 @"numberOfHats" : @13247,
                                 },
                             @{
                                 @"name" : @"archie",
                                 @"numberOfHats" : @98,
                                 },
                             @{
                                 @"name" : @"francis part II",
                                 @"numberOfHats" : @8,
                                 },
                             @{
                                 @"name" : @"grandma",
                                 @"numberOfHats" : @1,
                                 },
                             ];
    
    [VOKThing vok_addWithArrayInBackground:importArray
                                completion:^(NSArray *arrayOfManagedObjects) {
                                    XCTAssertEqual(arrayOfManagedObjects.count, importArray.count);
                                    for (NSInteger i = 0; i < importArray.count; i++) {
                                        XCTAssertEqualObjects([arrayOfManagedObjects[i] name], importArray[i][@"name"]);
                                        XCTAssertEqualObjects([arrayOfManagedObjects[i] numberOfHats], importArray[i][@"numberOfHats"]);
                                    }
                                    [completionHandlerExpectation fulfill];
                                }];
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertNil(error, @"Error waiting for response:%@", error.description);
    }];
}

#pragma mark Fetch Instance Methods

- (void)testRecordFetching
{
    [self loadWithBasicTestData];
    
    NSArray *results = [VOKThing vok_fetchAllForPredicate:nil
                                  forManagedObjectContext:nil];
    XCTAssertNotNil(results);
    XCTAssertGreaterThan(results.count, 0);
    XCTAssertEqual(results.count, BasicTestDataSize);
}

- (void)testRecordFetchingWithSortDescriptor
{
    [self loadWithBasicTestData];
    NSArray *results = [VOKThing vok_fetchAllForPredicate:nil
                                              sortedByKey:@"numberOfHats"
                                                ascending:YES
                                  forManagedObjectContext:nil];
    XCTAssertNotNil(results);
    XCTAssertGreaterThan(results.count, 0);
    XCTAssertEqual(results.count, BasicTestDataSize);
    
    XCTAssertEqual([results.firstObject numberOfHats].intValue, BasicTestDataStartPoint);
    XCTAssertEqual([results.lastObject numberOfHats].intValue, BasicTestDataStartPoint + BasicTestDataSize-1);
}

- (void)testRecordFetchingWithSortDescriptorAscending
{
    [self loadWithBasicTestData];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"numberOfHats" ascending:YES];
    NSArray *results = [VOKThing vok_fetchAllForPredicate:nil
                                                 sortedBy:@[sortDescriptor]
                                  forManagedObjectContext:nil];
    
    XCTAssertNotNil(results);
    XCTAssertGreaterThan(results.count, 0);
    XCTAssertEqual(results.count, BasicTestDataSize);
    
    XCTAssertEqual([results.firstObject numberOfHats].intValue, BasicTestDataStartPoint);
    XCTAssertEqual([results.lastObject numberOfHats].intValue, BasicTestDataStartPoint + BasicTestDataSize-1);
}

- (void)testRecordFetchingWithSortDescriptorDescending
{
    [self loadWithBasicTestData];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"numberOfHats" ascending:NO];
    NSArray *results = [VOKThing vok_fetchAllForPredicate:nil
                                                 sortedBy:@[sortDescriptor]
                                  forManagedObjectContext:nil];
    
    XCTAssertNotNil(results);
    XCTAssertGreaterThan(results.count, 0);
    XCTAssertEqual(results.count, BasicTestDataSize);
    
    XCTAssertEqual([results.firstObject numberOfHats].intValue, BasicTestDataStartPoint + BasicTestDataSize-1);
    XCTAssertEqual([results.lastObject numberOfHats].intValue, BasicTestDataStartPoint);
}

#pragma mark - Test getting entity name

- (void)testGettingEntityName
{
    XCTAssertEqualObjects([VOKEntityA vok_entityName], @"EntityA");
    XCTAssertEqualObjects([VOKEntityB vok_entityName], @"EntityB");
    XCTAssertEqualObjects([VOKEntityC vok_entityName], @"EntityC");
    XCTAssertEqualObjects([VOKThing vok_entityName], @"VOKThing");
    XCTAssertThrows([NSManagedObject vok_entityName]);
    XCTAssertThrows([VOKManagedObjectForTestGettingEntityName vok_entityName]);
    XCTAssertThrows([[NSString class] vok_entityName]);
}

@end
