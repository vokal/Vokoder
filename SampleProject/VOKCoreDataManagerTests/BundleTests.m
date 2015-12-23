//
//  BundleTests.m
//  Vokoder Sample Project
//
//  Created by Ellen Shapiro (Vokal) on 10/20/15.
//
//  Copyright © 2015 Vokal.
//

#import <XCTest/XCTest.h>
#import "VOKCoreDataManager.h"

@interface BundleTests : XCTestCase

@end

@implementation BundleTests

- (void)setUp
{
    [super setUp];
    
    [[VOKCoreDataManager sharedInstance] resetCoreData];
}

- (void)testWorksWithoutSettingCustomBundle
{
    XCTAssertNoThrow([[VOKCoreDataManager sharedInstance] setResource:@"VOKCoreDataModel" database:nil]);
}

- (void)testWorksWithSettingCustomBundle
{
    XCTAssertNoThrow([[VOKCoreDataManager sharedInstance] setResource:@"VOKCoreDataModel"
                                                             database:nil
                                                               bundle:[NSBundle mainBundle]]);
}

- (void)testFailsWithSettingBundleWithoutModel
{
    XCTAssertThrows([[VOKCoreDataManager sharedInstance] setResource:@"VOKCoreDataModel"
                                                            database:nil
                                                              bundle:[NSBundle bundleForClass:[self class]]]);
}

@end
