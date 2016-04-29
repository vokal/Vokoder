//
//  DateFormatterTests.m
//  SampleProject
//
//  Created by Carl Hill-Popper on 4/27/16.
//  Copyright © 2016 Vokal.
//

#import <XCTest/XCTest.h>

#import <VOKManagedObjectMap.h>

@interface DateFormatterTests : XCTestCase

@end

@implementation DateFormatterTests

- (void)testDateFormattersLocaleIsPOSIX
{
    XCTAssertEqualObjects([VOKManagedObjectMap vok_defaultDateFormatter].locale.localeIdentifier,
                          VOKDefaultDateFormatterLocaleIdentifier);
    XCTAssertEqualObjects([VOKManagedObjectMap vok_dateFormatterWithoutMicroseconds].locale.localeIdentifier,
                          VOKDefaultDateFormatterLocaleIdentifier);
}

@end
