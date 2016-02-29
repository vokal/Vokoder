//
//  VOKThreadingTests.m
//  Vokoder Sample Project
//
//  Created by Brock Boland on 2/26/16.
//  Copyright © 2016 Vokal. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <VOKCoreDataManager.h>

@interface VOKThreadingTests : XCTestCase

@end

@implementation VOKThreadingTests

- (void)testSetupOnBackgroundThreadFails
{
    XCTestExpectation *willFinish = [self expectationWithDescription:@"Background thread setup will finish"];

    // Setup on the main thread should work
    [[VOKCoreDataManager sharedInstance] resetCoreData];
    XCTAssertNoThrow([[VOKCoreDataManager sharedInstance] setResource:@"VOKCoreDataModel" database:nil]);

    NSOperationQueue *backgroundQueue = [[NSOperationQueue alloc] init];
    backgroundQueue.qualityOfService = NSOperationQualityOfServiceBackground;
    [backgroundQueue addOperationWithBlock:^{
        [[VOKCoreDataManager sharedInstance] resetCoreData];
        // Setup on a background thread should fail
        XCTAssertThrows([[VOKCoreDataManager sharedInstance] setResource:@"VOKCoreDataModel" database:nil]);
        [willFinish fulfill];
    }];
    [self waitForExpectationsWithTimeout:1 handler:nil];
}

@end
