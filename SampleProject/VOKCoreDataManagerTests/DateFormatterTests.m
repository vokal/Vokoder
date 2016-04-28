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
    NSString *posixIdentifier = @"en_US_POSIX";
    
    XCTAssertEqualObjects([VOKManagedObjectMap vok_defaultDateFormatter].locale.localeIdentifier,
                          posixIdentifier);
    XCTAssertEqualObjects([VOKManagedObjectMap vok_dateFormatterWithoutMicroseconds].locale.localeIdentifier,
                          posixIdentifier);
}

@end
