//
//  VOKManagedObjectAdditionTests.m
//  SampleProject
//
//  Created by Rohan Vokal on 2/17/15.
//
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <VOKCoreDataManager.h>
#import <NSManagedObject+VOKManagedObjectAdditions.h>
#import "VIThing.h"


@interface VOKManagedObjectAdditionTests : XCTestCase

@end

@implementation VOKManagedObjectAdditionTests

- (void)setUp
{
    [super setUp];
    [[VOKCoreDataManager sharedInstance] setResource:@"VICoreDataModel"
                                            database:@"VICoreDataModel.sqlite"];
}

- (void)tearDown
{
    [super tearDown];
    [[VOKCoreDataManager sharedInstance] deleteAllObjectsOfClass:[VIThing class] context:nil];
    [[VOKCoreDataManager sharedInstance] saveAndMergeWithMainContext:nil];
}

#pragma mark - Test Data Helper Methods

#define basicTestDataStartPoint 0
#define basicTestDataSize 5
- (void)loadWithBasicTestData
{
    for (int i = basicTestDataStartPoint; i < basicTestDataSize; i++) {
        VIThing *thing = [VIThing vok_newInstance];
        [thing setName:[NSString stringWithFormat:@"test-%i", i]];
        [thing setNumberOfHats:[NSNumber numberWithInt:i]];
    }
    [[VOKCoreDataManager sharedInstance] saveMainContextAndWait];
}

#pragma mark - New Instance Methods

- (void)testRecordInsertion
{
    XCTAssertEqual([VIThing vok_fetchAllForPredicate:nil
                             forManagedObjectContext:nil].count, 0);
    
    VIThing *thing = [VIThing vok_newInstance];
    [thing setName:@"test-1"];
    [thing setNumberOfHats:@1];
    [[VOKCoreDataManager sharedInstance] saveMainContext];
    
    XCTAssertEqual([VIThing vok_fetchAllForPredicate:nil
                             forManagedObjectContext:nil].count, 1);
    
}

- (void)testRecordInsertionTemporaryContext
{
    XCTestExpectation *completionHandlerExpectation = [self expectationWithDescription:@"completion"];
    
    XCTAssertEqual([VIThing vok_fetchAllForPredicate:nil
                             forManagedObjectContext:nil].count, 0);
    
    [VOKCoreDataManager writeToTemporaryContext:^(NSManagedObjectContext *tempContext) {
        
        VIThing *thing = [VIThing vok_newInstanceWithContext:tempContext];
        [thing setName:@"test-2"];
        [thing setNumberOfHats:@2];
        
    } completion:^{
        XCTAssertEqual([VIThing vok_fetchAllForPredicate:nil
                                 forManagedObjectContext:nil].count, 1);
        
        [completionHandlerExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        XCTAssertNil(error, @"Error:%@", error.description);
    }];
}

- (void)testRecordInsertionBackgroundThread
{
    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"completion"];
    
    XCTAssertEqual([VIThing vok_fetchAllForPredicate:nil
                             forManagedObjectContext:nil].count, 0);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSManagedObjectContext *backgroundContext = [[VOKCoreDataManager sharedInstance] temporaryContext];
        
        VIThing *thing = [VIThing vok_newInstanceWithContext:backgroundContext];
        [thing setName:@"test-2"];
        [thing setNumberOfHats:@2];
        [[VOKCoreDataManager sharedInstance] saveAndMergeWithMainContext:backgroundContext];
        
        [completionExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:5 handler:^(NSError *error) {
        XCTAssertNil(error, @"Error:%@", error.description);
        XCTAssertEqual([VIThing vok_fetchAllForPredicate:nil
                                 forManagedObjectContext:nil].count, 1);
    }];
}

#pragma mark Fetch Instance Methods

- (void)testRecordFetching
{
    [self loadWithBasicTestData];
    
    NSArray *results = [VIThing vok_fetchAllForPredicate:nil
                                 forManagedObjectContext:nil];
    XCTAssertNotNil(results);
    XCTAssertGreaterThan(results.count, 0);
    XCTAssertEqual(results.count, basicTestDataSize);
}

- (void)testRecordFetchingWithSortDescriptorAscending
{
    [self loadWithBasicTestData];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"numberOfHats" ascending:YES];
    NSArray *results = [VIThing vok_fetchAllForPredicate:nil
                                                sortedBy:@[sortDescriptor]
                                 forManagedObjectContext:nil];
    
    XCTAssertNotNil(results);
    XCTAssertGreaterThan(results.count, 0);
    XCTAssertEqual(results.count, basicTestDataSize);
    
    XCTAssertEqual([[results firstObject] numberOfHats].intValue, basicTestDataStartPoint);
    XCTAssertEqual([[results lastObject] numberOfHats].intValue, basicTestDataStartPoint + basicTestDataSize-1);
}

- (void)testRecordFetchingWithSortDescriptorDescending
{
    [self loadWithBasicTestData];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"numberOfHats" ascending:NO];
    NSArray *results = [VIThing vok_fetchAllForPredicate:nil
                                                sortedBy:@[sortDescriptor]
                                 forManagedObjectContext:nil];
    
    XCTAssertNotNil(results);
    XCTAssertGreaterThan(results.count, 0);
    XCTAssertEqual(results.count, basicTestDataSize);
    
    XCTAssertEqual([[results firstObject] numberOfHats].intValue, basicTestDataStartPoint + basicTestDataSize-1);
    XCTAssertEqual([[results lastObject] numberOfHats].intValue, basicTestDataStartPoint);
}

@end
