//
//  CoreDataTests.m
//  CoreDataTests
//
//  Copyright © 2015 Vokal. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VOKCoreDataManager.h"
#import "VIMappablePerson.h"
#import "VIPerson.h"
#import "VIThing.h"

static NSString *const FIRST_NAME_DEFAULT_KEY = @"firstName";
static NSString *const LAST_NAME_DEFAULT_KEY = @"lastName";
static NSString *const BIRTHDAY_DEFAULT_KEY = @"birthDay";
static NSString *const CATS_DEFAULT_KEY = @"numberOfCats";
static NSString *const COOL_RANCH_DEFAULT_KEY = @"lovesCoolRanch";

static NSString *const FIRST_NAME_CUSTOM_KEY = @"first";
static NSString *const LAST_NAME_CUSTOM_KEY = @"last";
static NSString *const BIRTHDAY_CUSTOM_KEY = @"date_of_birth";
static NSString *const CATS_CUSTOM_KEY = @"cat_num";
static NSString *const COOL_RANCH_CUSTOM_KEY = @"CR_PREF";

static NSString *const FIRST_NAME_MALFORMED_KEY = @"first.banana";
static NSString *const LAST_NAME_MALFORMED_KEY = @"somethingsomething.something.something";
static NSString *const BIRTHDAY_MALFORMED_KEY = @"date_of_birth?";
static NSString *const CATS_MALFORMED_KEY = @"cat_num_biz";
static NSString *const COOL_RANCH_MALFORMED_KEY = @"CR_PREF";

static NSString *const FIRST_NAME_KEYPATH_KEY = @"name.first";
static NSString *const LAST_NAME_KEYPATH_KEY = @"name.last";
static NSString *const BIRTHDAY_KEYPATH_KEY = @"birthday";
static NSString *const CATS_KEYPATH_KEY = @"prefs.cats.number";
static NSString *const COOL_RANCH_KEYPATH_KEY = @"prefs.coolRanch";

static NSString *const THING_NAME_KEY = @"thing_name";
static NSString *const THING_HAT_COUNT_KEY = @"thing_hats";

@interface VOKManagedObjectMap (VOKdefaultFormatters) //for testing!
+ (NSNumberFormatter *)vok_defaultNumberFormatter;

@end

@interface ManagedObjectImportExportTests : XCTestCase

@end

@implementation ManagedObjectImportExportTests

- (void)setUp
{
    [super setUp];
    [[VOKCoreDataManager sharedInstance] resetCoreData];
    [[VOKCoreDataManager sharedInstance] setResource:@"VICoreDataModel" database:nil];
}

- (void)testImportExportDictionaryWithDefaultMapper
{
    VIPerson *person = [VIPerson vok_addWithDictionary:[self makeServerPersonDictForDefaultMapper] forManagedObjectContext:nil];
    [self checkMappingForPerson:person andDictionary:[self makeServerPersonDictForDefaultMapper]];

    NSDictionary *dict = [person vok_dictionaryRepresentation];
    XCTAssertTrue([dict isEqualToDictionary:[self makeClientPersonDictForDefaultMapper]], @"dictionary representation failed to match input dictionary");
}

- (void)testImportExportDictionaryWithMapperWithoutMicroseconds
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:[self customMapsArrayWithoutMicroseconds]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];
    VIPerson *person = [VIPerson vok_addWithDictionary:[self makeClientPersonDictForMapperWithoutMicroseconds] forManagedObjectContext:nil];
    [self checkMappingForPerson:person
                  andDictionary:[self makeClientPersonDictForMapperWithoutMicroseconds]
              birthdayFormatter:[VOKManagedObjectMap vok_dateFormatterWithoutMicroseconds]
                    birthdayKey:BIRTHDAY_DEFAULT_KEY];

    NSDictionary *dict = [person vok_dictionaryRepresentation];
    XCTAssertTrue([dict isEqualToDictionary:[self makeClientPersonDictForMapperWithoutMicroseconds]], @"dictionary representation failed to match input dictionary");
}

- (void)testImportExportDictionaryWithCustomMapper
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:[self customMapsArray]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];
    VIPerson *person = [VIPerson vok_addWithDictionary:[self makePersonDictForCustomMapper] forManagedObjectContext:nil];
    [self checkCustomMappingForPerson:person andDictionary:[self makePersonDictForCustomMapper]];

    NSDictionary *dict = [person vok_dictionaryRepresentation];
    XCTAssertTrue([dict isEqualToDictionary:[self makePersonDictForCustomMapper]], @"dictionary representation failed to match input dictionary");
}

- (void)testImportExportDictionaryWithCustomMapperAndNilProperty
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:[self customMapsArray]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];
    VIPerson *person = [VIPerson vok_addWithDictionary:[self makePersonDictForCustomMapperAndMissingParameter] forManagedObjectContext:nil];
    [self checkCustomMappingForPerson:person andDictionary:[self makePersonDictForCustomMapperAndMissingParameter]];

    NSDictionary *dict = [person vok_dictionaryRepresentation];
    XCTAssertTrue([dict isEqualToDictionary:[self makePersonDictForCustomMapperAndMissingParameter]], @"dictionary representation failed to match input dictionary");
}

- (void)testImportExportDictionaryWithAutoRegisteredMapper
{
    VIMappablePerson *person = [VIMappablePerson vok_addWithDictionary:[self makePersonDictForCustomMapper] forManagedObjectContext:nil];
    [self checkCustomMappingForPerson:person andDictionary:[self makePersonDictForCustomMapper]];
    
    NSDictionary *dict = [person vok_dictionaryRepresentation];
    XCTAssertTrue([dict isEqualToDictionary:[self makePersonDictForCustomMapper]], @"dictionary representation failed to match input dictionary");
}

- (void)testImportExportDictionaryWithCustomKeyPathMapper
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:[self customMapsArrayWithKeyPaths]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];
    VIPerson *person = [VIPerson vok_addWithDictionary:[self makePersonDictForCustomMapperWithKeyPaths] forManagedObjectContext:nil];

    XCTAssertTrue(person != nil, @"person was not created");
    XCTAssertTrue([person isKindOfClass:[VIPerson class]], @"person is wrong class");
    XCTAssertTrue([person.firstName isEqualToString:@"CUSTOMFIRSTNAME"], @"person first name is incorrect");
    XCTAssertTrue([person.lastName isEqualToString:@"CUSTOMLASTNAME"], @"person last name is incorrect");
    XCTAssertTrue([person.numberOfCats isEqualToNumber:@876], @"person number of cats is incorrect");
    XCTAssertTrue([person.lovesCoolRanch isEqualToNumber:@YES], @"person lovesCoolRanch is incorrect");

    NSDate *birthdate = [[self customDateFormatter] dateFromString:@"24 Jul 83 14:16"];
    XCTAssertTrue([person.birthDay isEqualToDate:birthdate], @"person birthdate is incorrect");

    NSDictionary *dict = [person vok_dictionaryRepresentationRespectingKeyPaths];
    XCTAssertTrue([dict isEqualToDictionary:[self makePersonDictForCustomMapperWithKeyPaths]], @"dictionary representation failed to match input dictionary");
}

- (void)testImportExportDictionaryWithCustomKeyPathMapperAndNilProperty
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:[self customMapsArrayWithKeyPaths]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];
    VIPerson *person = [VIPerson vok_addWithDictionary:[self makePersonDictForCustomMapperWithKeyPathsAndMissingParameter] forManagedObjectContext:nil];

    XCTAssertTrue(person != nil, @"person was not created");
    XCTAssertTrue([person isKindOfClass:[VIPerson class]], @"person is wrong class");
    XCTAssertTrue([person.firstName isEqualToString:@"CUSTOMFIRSTNAME"], @"person first name is incorrect");
    XCTAssertTrue([person.lastName isEqualToString:@"CUSTOMLASTNAME"], @"person last name is incorrect");
    XCTAssertNil(person.numberOfCats, @"number of cats should be nil");
    XCTAssertTrue([person.lovesCoolRanch isEqualToNumber:@YES], @"person lovesCoolRanch is incorrect");

    NSDate *birthdate = [[self customDateFormatter] dateFromString:@"24 Jul 83 14:16"];
    XCTAssertTrue([person.birthDay isEqualToDate:birthdate], @"person birthdate is incorrect");

    NSDictionary *dict = [person vok_dictionaryRepresentationRespectingKeyPaths];
    XCTAssertTrue([dict isEqualToDictionary:[self makePersonDictForCustomMapperWithKeyPathsAndMissingParameter]], @"dictionary representation failed to match input dictionary");
}

- (void)testImportDictionaryWithCustomMapperNotRegisteredAssert
{
    XCTAssertThrows([VIPerson vok_addWithDictionary:[self makePersonDictForCustomMapper] forManagedObjectContext:nil]);
}

- (void)testImportDictionaryWithCustomMapperMismatchedAssert
{
    NSArray *maps = [self customMapsArray];
    VOKManagedObjectMap *map = maps.firstObject;
    map.coreDataKey = [map.coreDataKey stringByAppendingString:@"-FAIL"];
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:maps];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];
    XCTAssertThrows([VIPerson vok_addWithDictionary:[self makePersonDictForCustomMapper] forManagedObjectContext:nil]);
}

- (void)testImportArrayWithCustomMapper
{
    NSArray *array = @[[self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper]];
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:[self customMapsArray]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];
    NSArray *arrayOfPeople = [VIPerson vok_addWithArray:array forManagedObjectContext:nil];
    
    XCTAssertTrue([arrayOfPeople count] == 5, @"person array has incorrect number of people");
    
    for (VIPerson *obj in arrayOfPeople) {
        [self checkCustomMappingForPerson:obj
                            andDictionary:[self makePersonDictForCustomMapper]];
    }
}

- (void)testImportArrayWithAutoRegisteredMapper
{
    NSArray *array = @[
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       ];
    NSArray *arrayOfPeople = [VIMappablePerson vok_addWithArray:array forManagedObjectContext:nil];
    
    XCTAssertTrue([arrayOfPeople count] == 5, @"person array has incorrect number of people");
    
    for (VIPerson *obj in arrayOfPeople) {
        [self checkCustomMappingForPerson:obj
                            andDictionary:[self makePersonDictForCustomMapper]];
    }
}

- (void)testAsynchronousImportArrayWithCustomMapperOnWriteBlock
{
    NSArray *array = @[[self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper]];
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:[self customMapsArray]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];

    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"completion"];
    [VOKCoreDataManager writeToTemporaryContext:^(NSManagedObjectContext *tempContext) {
        [VIPerson vok_addWithArray:array forManagedObjectContext:tempContext];
    } completion:^{
        NSArray *arrayOfPeople = [VIPerson vok_fetchAllForPredicate:nil forManagedObjectContext:nil];
        XCTAssertTrue([arrayOfPeople count] == 5, @"person array has incorrect number of people");

        for (VIPerson *obj in arrayOfPeople) {
            [self checkCustomMappingForPerson:obj
                                andDictionary:[self makePersonDictForCustomMapper]];
        }
        [completionExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertNil(error, @"Error waiting for response:%@", error.description);
    }];
}

- (void)testAsynchronousImportArrayWithCustomMapperReturningArrayOfManagedObjectIDs
{
    NSArray *array = @[[self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper]];
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:[self customMapsArray]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];

    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"completion"];
    [VOKCoreDataManager importArrayInBackground:array
                                       forClass:[VIPerson class]
                                     completion:^(NSArray *arrayOfManagedObjectIDs) {
                                         NSMutableArray *arrayOfPeople = [NSMutableArray arrayWithCapacity:arrayOfManagedObjectIDs.count];
                                         NSManagedObjectContext *moc = [[VOKCoreDataManager sharedInstance] managedObjectContext];
                                         for (NSManagedObjectID *objectID in arrayOfManagedObjectIDs) {
                                             VIPerson *obj = (VIPerson *)[moc objectWithID:objectID];
                                             [arrayOfPeople addObject:obj];
                                             [self checkCustomMappingForPerson:obj
                                                                 andDictionary:[self makePersonDictForCustomMapper]];
                                         }
                                         XCTAssertTrue([arrayOfPeople count] == 5, @"person array has incorrect number of people");
                                         [completionExpectation fulfill];
                                     }];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertNil(error, @"Error waiting for response:%@", error.description);
    }];
}

- (void)testImportArrayWithDefaultMapper
{
    NSArray *array = @[[self makeServerPersonDictForDefaultMapper],
                       [self makeServerPersonDictForDefaultMapper],
                       [self makeServerPersonDictForDefaultMapper],
                       [self makeServerPersonDictForDefaultMapper],
                       [self makeServerPersonDictForDefaultMapper]];
    NSArray *arrayOfPeople = [VIPerson vok_addWithArray:array forManagedObjectContext:nil];

    XCTAssertTrue([arrayOfPeople count] == 5, @"person array has incorrect number of people");

    [arrayOfPeople enumerateObjectsUsingBlock:^(VIPerson *obj, NSUInteger idx, BOOL *stop) {
        [self checkMappingForPerson:obj andDictionary:[self makeServerPersonDictForDefaultMapper]];
    }];
}

- (void)testImportArrayWithCustomMapperMalformedInput
{
    NSArray *array = @[[self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapperWithMalformedInput],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper]];
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:[self customMapsArray]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];
    NSArray *arrayOfPeople = [VIPerson vok_addWithArray:array forManagedObjectContext:nil];

    XCTAssertTrue([arrayOfPeople count] == 5, @"person array has incorrect number of people");
    //just need to check the count and make sure it doesn't crash
}

- (void)testImportArrayWithDefaultMapperMalformedInput
{
    NSArray *array = @[[self makeServerPersonDictForDefaultMapper],
                       [self makeServerPersonDictForDefaultMapper],
                       [self makePersonDictForDefaultMapperWithMalformedInput],
                       [self makeServerPersonDictForDefaultMapper],
                       [self makeServerPersonDictForDefaultMapper]];
    NSArray *arrayOfPeople = [VIPerson vok_addWithArray:array forManagedObjectContext:nil];

    XCTAssertTrue([arrayOfPeople count] == 5, @"person array has incorrect number of people");
    //just need to check the count and make sure it doesn't crash
}

- (void)testImportArrayWithMalformedMapper
{
    NSArray *array = @[[self makeServerPersonDictForDefaultMapper],
                       [self makeServerPersonDictForDefaultMapper],
                       [self makePersonDictForDefaultMapperWithMalformedInput],
                       [self makeServerPersonDictForDefaultMapper],
                       [self makeServerPersonDictForDefaultMapper]];

    NSArray *malformedMaps = @[[VOKManagedObjectMap mapWithForeignKeyPath:FIRST_NAME_MALFORMED_KEY coreDataKey:FIRST_NAME_DEFAULT_KEY],
                            [VOKManagedObjectMap mapWithForeignKeyPath:LAST_NAME_MALFORMED_KEY coreDataKey:LAST_NAME_DEFAULT_KEY],
                            [VOKManagedObjectMap mapWithForeignKeyPath:BIRTHDAY_MALFORMED_KEY coreDataKey:BIRTHDAY_DEFAULT_KEY dateFormatter:[self customDateFormatter]],
                            [VOKManagedObjectMap mapWithForeignKeyPath:CATS_MALFORMED_KEY coreDataKey:CATS_DEFAULT_KEY],
                            [VOKManagedObjectMap mapWithForeignKeyPath:COOL_RANCH_MALFORMED_KEY coreDataKey:COOL_RANCH_DEFAULT_KEY]];
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:@"BAD DATA" andMaps:malformedMaps];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];
    NSArray *arrayOfPeople = [VIPerson vok_addWithArray:array forManagedObjectContext:nil];

    XCTAssertTrue([arrayOfPeople count] == 5, @"person array has incorrect number of people");
    //just need to check the count and make sure it doesn't crash
}

- (void)testImportWithCustomMapperAndAnEmptyInputValue
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:FIRST_NAME_DEFAULT_KEY andMaps:[self customMapsArray]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];
    VIPerson *person = [VIPerson vok_addWithDictionary:[self makePersonDictForCustomMapper] forManagedObjectContext:nil];
    [self checkCustomMappingForPerson:person andDictionary:[self makePersonDictForCustomMapper]];

    person = [VIPerson vok_addWithDictionary:[self makePersonDictForCustomMapperWithAnEmptyInputValues] forManagedObjectContext:nil];
    XCTAssertTrue(person.lastName == nil, @"the NSNull in the import dictionary did not overwrite the managed object's property");
    XCTAssertTrue(person.numberOfCats == nil, @"the missing value in the import dictionary did not overwrite the managed object's property");

    NSUInteger count = [[VOKCoreDataManager sharedInstance] countForClass:[VIPerson class]];
    XCTAssertTrue(count == 1, @"the unique key did not work correctly");
}

- (void)testImportWithDefaultMapperAndAnEmptyInputValue
{
    VIPerson *person = [VIPerson vok_addWithDictionary:[self makePersonDictForDefaultMapperWithAnEmptyInputValues] forManagedObjectContext:nil];
    XCTAssertTrue(person.lastName == nil, @"the NSNull in the import dictionary did not overwrite the managed object's property");
    XCTAssertTrue([person.numberOfCats integerValue] == 0, @"the missing value in the import dictionary did not overwrite the managed object's property");
}

- (void)testCountMethods
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:LAST_NAME_DEFAULT_KEY andMaps:[self customMapsArray]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];

    NSDictionary *dict1 = @{FIRST_NAME_CUSTOM_KEY : @"Bananaman",
                            LAST_NAME_CUSTOM_KEY : @"DotCom",
                            BIRTHDAY_CUSTOM_KEY : @"24 Jul 83 19:16",
                            CATS_CUSTOM_KEY : @404,
                            COOL_RANCH_CUSTOM_KEY : @NO};
    [VIPerson vok_addWithDictionary:dict1 forManagedObjectContext:nil];

    NSUInteger count = [[VOKCoreDataManager sharedInstance] countForClass:[VIPerson class]];
    XCTAssertTrue(count == 1, @"VICoreDataManager count method is incorrect");

    NSDictionary *dict2 = @{FIRST_NAME_CUSTOM_KEY : @"Francis",
                            LAST_NAME_CUSTOM_KEY : @"Bolgna",
                            BIRTHDAY_CUSTOM_KEY : @"24 Jul 83 19:16",
                            CATS_CUSTOM_KEY : @404,
                            COOL_RANCH_CUSTOM_KEY : @NO};
    [VIPerson vok_addWithDictionary:dict2 forManagedObjectContext:nil];

    count = [[VOKCoreDataManager sharedInstance] countForClass:[VIPerson class]];
    XCTAssertTrue(count == 2, @"VICoreDataManager count method is incorrect");

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"firstName == %@",  @"Francis"];
    count = [[VOKCoreDataManager sharedInstance] countForClass:[VIPerson class] withPredicate:pred forContext:nil];
    XCTAssertTrue(count == 1, @"VICoreDataManager count with predicate method is incorrect");

    pred = [NSPredicate predicateWithFormat:@"firstName == %@",  @"Bananaman"];
    BOOL exists = [VIPerson vok_existsForPredicate:pred forManagedObjectContext:nil];
    XCTAssertTrue(exists, @"existsForPredicate is incorrect");
}

- (void)testCustomMapperUniqueKeyAndOverwriteSetting
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:LAST_NAME_DEFAULT_KEY andMaps:[self customMapsArray]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];
    
    NSDictionary *dict1 = @{FIRST_NAME_CUSTOM_KEY : @"SOMEGUY",
                            LAST_NAME_CUSTOM_KEY : @"GUY1",
                            BIRTHDAY_CUSTOM_KEY : @"24 Jul 83 14:16",
                            CATS_CUSTOM_KEY : @192,
                            COOL_RANCH_CUSTOM_KEY : @YES};
    [VIPerson vok_addWithDictionary:dict1 forManagedObjectContext:nil];
    
    NSDictionary *dict2 = @{FIRST_NAME_CUSTOM_KEY : @"SOMEGUY",
                            LAST_NAME_CUSTOM_KEY : @"GUY2",
                            BIRTHDAY_CUSTOM_KEY : @"24 Jul 83 14:16",
                            CATS_CUSTOM_KEY : @192,
                            COOL_RANCH_CUSTOM_KEY : @YES};
    [VIPerson vok_addWithDictionary:dict2 forManagedObjectContext:nil];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"firstName == %@",  @"SOMEGUY"];
    NSArray *array = [VIPerson vok_fetchAllForPredicate:pred forManagedObjectContext:nil];
    XCTAssertTrue([array count] == 2, @"unique person test array has incorrect number of people");

    NSDictionary *dict3 = @{FIRST_NAME_CUSTOM_KEY : @"ANOTHERGUY",
                            LAST_NAME_CUSTOM_KEY : @"GUY1",
                            BIRTHDAY_CUSTOM_KEY : @"18 Jul 83 14:16",
                            CATS_CUSTOM_KEY : @14,
                            COOL_RANCH_CUSTOM_KEY : @YES};
    [VIPerson vok_addWithDictionary:dict3 forManagedObjectContext:nil];

    pred = [NSPredicate predicateWithFormat:@"lastName == %@",  @"GUY1"];
    array = [VIPerson vok_fetchAllForPredicate:pred forManagedObjectContext:nil];
    XCTAssertTrue([array count] == 1, @"unique key was not effective");
    XCTAssertTrue([[array[0] numberOfCats] isEqualToNumber:@14], @"unique key was effective but the person object was not updated");

    mapper.overwriteObjectsWithServerChanges = NO;
    NSDictionary *dict4 = @{FIRST_NAME_CUSTOM_KEY : @"ONE MORE GUY",
                            LAST_NAME_CUSTOM_KEY : @"GUY1",
                            BIRTHDAY_CUSTOM_KEY : @"18 Jul 83 14:16",
                            CATS_CUSTOM_KEY : @777,
                            COOL_RANCH_CUSTOM_KEY : @NO};
    [VIPerson vok_addWithDictionary:dict4 forManagedObjectContext:nil];

    pred = [NSPredicate predicateWithFormat:@"lastName == %@",  @"GUY1"];
    array = [VIPerson vok_fetchAllForPredicate:pred forManagedObjectContext:nil];
    XCTAssertTrue([array count] == 1, @"unique key was not effective");
    XCTAssertTrue([[array[0] numberOfCats] isEqualToNumber:@14], @"\"overwriteObjectsWithServerChanges = NO\" was ignored");

    mapper.overwriteObjectsWithServerChanges = YES;
    NSDictionary *dict5 = @{FIRST_NAME_CUSTOM_KEY : @"ONE MORE GUY",
                            LAST_NAME_CUSTOM_KEY : @"GUY1",
                            BIRTHDAY_CUSTOM_KEY : @"18 Jul 83 14:16",
                            CATS_CUSTOM_KEY : @777,
                            COOL_RANCH_CUSTOM_KEY : @NO};
    [VIPerson vok_addWithDictionary:dict5 forManagedObjectContext:nil];

    pred = [NSPredicate predicateWithFormat:@"lastName == %@",  @"GUY1"];
    array = [VIPerson vok_fetchAllForPredicate:pred forManagedObjectContext:nil];
    XCTAssertTrue([array count] == 1, @"unique key was not effective");
    XCTAssertTrue([[array[0] numberOfCats] isEqualToNumber:@777], @"\"overwriteObjectsWithServerChanges = NO\" was ignored");
}

- (void)testFetchWithURI
{
    VIPerson *person = [VIPerson vok_addWithDictionary:[self makePersonDictForDefaultMapperWithAnEmptyInputValues] forManagedObjectContext:nil];
    [[VOKCoreDataManager sharedInstance] saveMainContext];
    NSManagedObjectID *objectID = person.objectID;
    NSURL *uri = objectID.URIRepresentation;
    person = nil;
    [[[VOKCoreDataManager sharedInstance] managedObjectContext] reset];

    VIPerson *personFromURI = [[VOKCoreDataManager sharedInstance] existingObjectAtURI:uri forManagedObjectContext:nil];
    XCTAssertTrue(personFromURI, @"failed to get existing person object from URI");
    XCTAssertTrue([personFromURI isKindOfClass:[VIPerson class]], @"existing person object was not correct class");
}

- (void)testFetchWithMalformedURI
{
    NSURL *uri = [NSURL URLWithString:@"x-coredata://1C8D8740-06E2-4B79-A739-94071E03CD74/VIPerson/p99"];
    VIPerson *personFromURI = [[VOKCoreDataManager sharedInstance] existingObjectAtURI:uri forManagedObjectContext:nil];
    XCTAssertNil(personFromURI, @"existingObjectAtURI did not fail correctly. returned non nil value for malformed URI");
}

- (void)testVOKEntityNameMethod
{
    // While it's not generally guaranteed that the entity name will be the same as the NSManagedObject subclass name,
    // we've set these two entities up to be that way for simplicity.  Let's make sure that the vok_entityName method
    // actually does what it's supposed to.
    XCTAssertEqualObjects(NSStringFromClass([VIPerson class]), [VIPerson vok_entityName], @"VIPerson entity name is not VIPerson");
    XCTAssertEqualObjects(NSStringFromClass([VIThing class]), [VIThing vok_entityName], @"VIThing entity name is not VIThing");
}

- (void)testIgnoreNullValueOverwrites
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:LAST_NAME_DEFAULT_KEY andMaps:[self customMapsArray]];
    mapper.ignoreNullValueOverwrites = YES;
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];

    NSDictionary *dict1 = @{FIRST_NAME_CUSTOM_KEY : @"SOMEGUY",
                            LAST_NAME_CUSTOM_KEY : @"GUY1",
                            BIRTHDAY_CUSTOM_KEY : @"24 Jul 83 14:16",
                            CATS_CUSTOM_KEY : @192,
                            COOL_RANCH_CUSTOM_KEY : @YES};
    [VIPerson vok_addWithDictionary:dict1 forManagedObjectContext:nil];

    NSDictionary *dict2 = @{FIRST_NAME_CUSTOM_KEY : @"Billy",
                            LAST_NAME_CUSTOM_KEY : @"GUY1",
                            CATS_CUSTOM_KEY : [NSNull null],
                            COOL_RANCH_CUSTOM_KEY : @YES};
    [VIPerson vok_addWithDictionary:dict2 forManagedObjectContext:nil];

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"lastName == %@",  @"GUY1"];
    NSArray *array = [VIPerson vok_fetchAllForPredicate:pred forManagedObjectContext:nil];
    XCTAssertTrue([array count] == 1, @"unique person test array has incorrect number of people");

    VIPerson *testDude = array[0];
    XCTAssertEqual([testDude.numberOfCats integerValue], 192, @"nil value overwrote existing value incorrectly");
    XCTAssertEqualObjects(testDude.firstName, @"Billy", @"somehow the name didn't update");
    XCTAssertNotNil(testDude.birthDay, @"nonexistent key overwrote existing value incorrectly");
}

- (void)testPostImportBlockWithDefaultMapper
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper defaultMapper];
    mapper.importCompletionBlock = ^(NSDictionary *inputDict, NSManagedObject *outputObject){
        //ALWAYS LOVE COOL RANCH
        [outputObject setValue:@YES forKey:VOK_CDSELECTOR(lovesCoolRanch)];
    };
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];

    NSDictionary *dict1 = [self makeServerPersonDictForDefaultMapper];

    VIPerson *person = [VIPerson vok_addWithDictionary:dict1 forManagedObjectContext:nil];
    XCTAssertTrue([person.lovesCoolRanch boolValue], @"Post import block ran incorrectly");
}

- (void)testPostImportBlockWithRelationship
{
    NSArray *thingMaps = @[
                           VOK_MAP_FOREIGN_TO_LOCAL(THING_NAME_KEY, name),
                           VOK_MAP_FOREIGN_TO_LOCAL(THING_HAT_COUNT_KEY, numberOfHats),
                           ];
    VOKManagedObjectMapper *thingMapper = [VOKManagedObjectMapper mapperWithUniqueKey:@"thing_name" andMaps:thingMaps];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:thingMapper forClass:[VIThing class]];
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:LAST_NAME_DEFAULT_KEY andMaps:[self customMapsArray]];
    mapper.importCompletionBlock = ^(NSDictionary *inputDict, NSManagedObject *outputObject){
        NSDictionary *thingDict = inputDict[@"nested_thing"];
        VIThing *thing = [VIThing vok_addWithDictionary:thingDict forManagedObjectContext:outputObject.managedObjectContext];
        [outputObject setValue:thing forKey:VOK_CDSELECTOR(thing)];
    };
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];

    NSNumber *numberOfHats = @15;
    NSString *thingName = @"thingamajig";

    NSDictionary *dict1 = @{
                            FIRST_NAME_CUSTOM_KEY : @"SOMEGUY",
                            LAST_NAME_CUSTOM_KEY : @"GUY1",
                            BIRTHDAY_CUSTOM_KEY : @"24 Jul 83 14:16",
                            CATS_CUSTOM_KEY : @192,
                            COOL_RANCH_CUSTOM_KEY : @YES,
                            @"nested_thing" : @{
                                    THING_HAT_COUNT_KEY : numberOfHats,
                                    THING_NAME_KEY : thingName,
                                    }
                            };
    VIPerson *person = [VIPerson vok_addWithDictionary:dict1 forManagedObjectContext:nil];
    XCTAssertNotNil(person.thing, @"Post import block failed to set person relationship");
    VIThing *thing = person.thing;
    XCTAssertEqualObjects(thing.numberOfHats, numberOfHats, @"Post import block failed to set thing attributes correctly");
    XCTAssertEqualObjects(thing.name, thingName, @"Post import block failed to set thing attributes correctly");
}

- (void)testPostExportBlock
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper defaultMapper];
    mapper.exportCompletionBlock = ^(NSMutableDictionary *outputDict, NSManagedObject *inputObject){
        [outputDict setObject:@"test!" forKey:@"test"];
        [outputDict removeObjectForKey:CATS_DEFAULT_KEY];
    };
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];

    VIPerson *person = [VIPerson vok_addWithDictionary:[self makeServerPersonDictForDefaultMapper] forManagedObjectContext:nil];
    [self checkMappingForPerson:person andDictionary:[self makeServerPersonDictForDefaultMapper]];

    NSDictionary *dict = [person vok_dictionaryRepresentation];
    XCTAssertNotNil(dict[@"test"], @"Post export block ran incorrectly");
    XCTAssertNil(dict[CATS_DEFAULT_KEY], @"Post export block ran incorrectly");
}

- (void)testUniqueKeyPath
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:LAST_NAME_DEFAULT_KEY andMaps:[self customMapsArrayWithKeyPaths]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];
    
    NSMutableDictionary *personDict = [[self makePersonDictForCustomMapperWithKeyPaths] mutableCopy];
    
    [VIPerson vok_addWithDictionary:personDict forManagedObjectContext:nil];
    
    VIPerson *person = [[VOKCoreDataManager sharedInstance] arrayForClass:[VIPerson class]].firstObject;
    XCTAssertEqualObjects([[self customDateFormatter] stringFromDate:person.birthDay], @"24 Jul 83 14:16");
    
    //change something, but keep the same unique key
    NSString *dateString = @"24 Jul 75 23:00";
    personDict[BIRTHDAY_KEYPATH_KEY] = dateString;
    
    //adding again should overwrite the existing one
    [VIPerson vok_addWithDictionary:personDict forManagedObjectContext:nil];
    
    NSArray *people = [[VOKCoreDataManager sharedInstance] arrayForClass:[VIPerson class]];
    XCTAssertEqual(people.count, 1);
    
    person = people.firstObject;
    XCTAssertEqualObjects([[self customDateFormatter] stringFromDate:person.birthDay], dateString);
}

- (void)testImportingTwoObjectsWithTheSameUniqueIDOverwritesWithUniqueKey
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:LAST_NAME_DEFAULT_KEY
                                                                         andMaps:[self customMapsArray]];
    
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];
    
    //Create two people with the same last name, one with a different name.
    NSDictionary *person1 = [self makePersonDictForCustomMapper];
    NSMutableDictionary *person2 = [[self makePersonDictForCustomMapper] mutableCopy];
    NSString *overwrittenName = @"OVERWRITTEN";
    person2[FIRST_NAME_CUSTOM_KEY] = overwrittenName;
    
    //Create a third person with a different last name
    NSMutableDictionary *person3 = [[self makePersonDictForCustomMapper] mutableCopy];
    person3[LAST_NAME_CUSTOM_KEY] = @"SOMEBODY-ELSE";
    
    NSArray *peopleDicts = @[person1, person2, person3];
    
    NSArray *arrayOfPeople = [VIPerson vok_addWithArray:peopleDicts forManagedObjectContext:nil];
    
    XCTAssertTrue([arrayOfPeople count] == 2, @"person array has incorrect number of people");
    
    [arrayOfPeople enumerateObjectsUsingBlock:^(VIPerson *obj, NSUInteger idx, BOOL *stop) {
        [self checkCustomMappingForPerson:obj andDictionary:peopleDicts[idx+1]];
    }];
}

#pragma mark - Convenience stuff

- (void)checkMappingForPerson:(VIPerson *)person andDictionary:(NSDictionary *)dict
{
    [self checkMappingForPerson:person
                  andDictionary:dict
              birthdayFormatter:[VOKManagedObjectMap vok_defaultDateFormatter]
                    birthdayKey:BIRTHDAY_DEFAULT_KEY];
}

- (void)checkCustomMappingForPerson:(VIPerson *)person andDictionary:(NSDictionary *)dict
{
    [self checkMappingForPerson:person
                  andDictionary:dict
              birthdayFormatter:[self customDateFormatter]
                    birthdayKey:BIRTHDAY_CUSTOM_KEY];
}

- (void)checkMappingForPerson:(VIPerson *)person
                andDictionary:(NSDictionary *)dict
            birthdayFormatter:(NSDateFormatter *)birthdayFormatter
                  birthdayKey:(NSString *)birthdayKey
{
    XCTAssertTrue(person != nil, @"person was not created");
    XCTAssertTrue([person isKindOfClass:[VIPerson class]], @"person is wrong class");

    NSString *firstName = [dict objectForKey:FIRST_NAME_DEFAULT_KEY] ?: [dict objectForKey:FIRST_NAME_CUSTOM_KEY];
    XCTAssertTrue([person.firstName isEqualToString:firstName], @"person first name is incorrect");

    NSString *lastName = [dict objectForKey:LAST_NAME_DEFAULT_KEY] ?: [dict objectForKey:LAST_NAME_CUSTOM_KEY];
    XCTAssertTrue([person.lastName isEqualToString:lastName], @"person last name is incorrect");

    NSNumber *cats = [dict objectForKey:CATS_DEFAULT_KEY] ?: [dict objectForKey:CATS_CUSTOM_KEY];
    XCTAssertTrue([person.numberOfCats isEqualToNumber:cats], @"person number of cats is incorrect");

    NSNumber *lovesCoolRanch = [dict objectForKey:COOL_RANCH_DEFAULT_KEY] ?: [dict objectForKey:COOL_RANCH_CUSTOM_KEY];
    XCTAssertTrue([person.lovesCoolRanch isEqualToNumber:lovesCoolRanch], @"person lovesCoolRanch is incorrect");

    NSDate *birthdate = [birthdayFormatter dateFromString:[dict objectForKey:birthdayKey]];

    if (person.birthDay) {
        //only check if birthday should be there.
        XCTAssertTrue([person.birthDay isEqualToDate:birthdate], @"person birthdate is incorrect");
    }
}

- (NSString *)randomNumberString
{
    return [NSString stringWithFormat:@"%d", arc4random()%3000];
}

- (NSDictionary *)makeServerPersonDictForDefaultMapper
{
    NSDictionary *dict = @{FIRST_NAME_DEFAULT_KEY :  @"BILLY",
                           LAST_NAME_DEFAULT_KEY : @"TESTCASE" ,
                           BIRTHDAY_DEFAULT_KEY : @"1983-07-24T03:22:15.321123Z",
                           CATS_DEFAULT_KEY : @17,
                           COOL_RANCH_DEFAULT_KEY : @NO};
    return dict;
}

- (NSDictionary *)makeClientPersonDictForDefaultMapper
{
    // Server can return microseconds, but NSDate will only store milliseconds
    // For testing, copy the server response and reduce the accuracy for comparing
    NSMutableDictionary *mutableDict = [[self makeServerPersonDictForDefaultMapper] mutableCopy];
    [mutableDict setValue:@"1983-07-24T03:22:15.321000Z" forKey:BIRTHDAY_DEFAULT_KEY];
    return mutableDict;
}

- (NSDictionary *)makeClientPersonDictForMapperWithoutMicroseconds
{
    // For testing, copy the server response and strip off the microseconds to
    // test the format that omits them
    NSMutableDictionary *mutableDict = [[self makeServerPersonDictForDefaultMapper] mutableCopy];
    [mutableDict setValue:@"1983-07-24T03:22:15Z" forKey:BIRTHDAY_DEFAULT_KEY];
    return mutableDict;
}

- (NSDictionary *)makePersonDictForCustomMapper
{
    NSDictionary *dict = @{FIRST_NAME_CUSTOM_KEY : @"CUSTOM",
                           LAST_NAME_CUSTOM_KEY : @"MAPMAN",
                           BIRTHDAY_CUSTOM_KEY : @"24 Jul 83 14:16",
                           CATS_CUSTOM_KEY : @192,
                           COOL_RANCH_CUSTOM_KEY : @YES};
    return dict;
}

- (NSDictionary *)makePersonDictForCustomMapperAndMissingParameter
{
    NSDictionary *dict = @{FIRST_NAME_CUSTOM_KEY : @"CUSTOM",
                           LAST_NAME_CUSTOM_KEY : @"MAPMAN",
                           CATS_CUSTOM_KEY : @192,
                           COOL_RANCH_CUSTOM_KEY : @YES};
    return dict;
}

- (NSDictionary *)makePersonDictForCustomMapperWithKeyPaths
{
    NSDictionary *nameDict = @{@"first": @"CUSTOMFIRSTNAME",
                               @"last": @"CUSTOMLASTNAME"};
    NSDictionary *catsDict = @{@"number": @876};

    NSDictionary *prefsDict = @{@"cats": catsDict,
                                @"coolRanch": @YES};

    NSDictionary *dict = @{@"name": nameDict,
                           BIRTHDAY_KEYPATH_KEY : @"24 Jul 83 14:16",
                           @"prefs": prefsDict};
    return dict;
}

- (NSDictionary *)makePersonDictForCustomMapperWithKeyPathsAndMissingParameter
{
    NSDictionary *nameDict = @{@"first": @"CUSTOMFIRSTNAME",
                               @"last": @"CUSTOMLASTNAME"};
    NSDictionary *catsDict = @{};

    NSDictionary *prefsDict = @{@"cats": catsDict,
                                @"coolRanch": @YES};

    NSDictionary *dict = @{@"name": nameDict,
                           BIRTHDAY_KEYPATH_KEY : @"24 Jul 83 14:16",
                           @"prefs": prefsDict};
    return dict;
}

- (NSDictionary *)makePersonDictForDefaultMapperWithAnEmptyInputValues
{
    NSDictionary *dict = @{FIRST_NAME_DEFAULT_KEY :  @"BILLY",
                           LAST_NAME_DEFAULT_KEY :  [NSNull null],
                           BIRTHDAY_DEFAULT_KEY : @"1983-07-24T03:22:15.321123Z",
                           COOL_RANCH_DEFAULT_KEY : @NO};
    return dict;
}

- (NSDictionary *)makePersonDictForCustomMapperWithAnEmptyInputValues
{
    NSDictionary *dict = @{FIRST_NAME_CUSTOM_KEY : @"CUSTOM",
                           LAST_NAME_CUSTOM_KEY : [NSNull null],
                           BIRTHDAY_CUSTOM_KEY : @"24 Jul 83 14:16",
                           COOL_RANCH_CUSTOM_KEY : @YES};
    return dict;
}

- (NSDictionary *)makePersonDictForDefaultMapperWithMalformedInput
{
    NSDictionary *dict = @{FIRST_NAME_DEFAULT_KEY :  @"BILLY",
                           LAST_NAME_DEFAULT_KEY : @"TESTCASE" ,
                           BIRTHDAY_DEFAULT_KEY : @"1983-07-24T03:22:15.321123Z",
                           CATS_DEFAULT_KEY : @[@17],
                           COOL_RANCH_DEFAULT_KEY : @{@"something": @NO}};
    return dict;
}

- (NSDictionary *)makePersonDictForCustomMapperWithMalformedInput
{
    NSDictionary *dict = @{FIRST_NAME_CUSTOM_KEY : @"CUSTOM",
                           LAST_NAME_CUSTOM_KEY : @"MAPMAN",
                           BIRTHDAY_CUSTOM_KEY : @"24 Jul 83 14:16",
                           CATS_CUSTOM_KEY : @{@"something": @192},
                           COOL_RANCH_CUSTOM_KEY : @[@YES]};
    return dict;
}

- (NSDateFormatter *)customDateFormatter
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"dd' 'LLL' 'yy' 'HH:mm"];
    [df setTimeZone:[NSTimeZone localTimeZone]];
    return df;
}

- (NSArray *)customMapsArray
{
    return @[[VOKManagedObjectMap mapWithForeignKeyPath:FIRST_NAME_CUSTOM_KEY coreDataKey:FIRST_NAME_DEFAULT_KEY],
             [VOKManagedObjectMap mapWithForeignKeyPath:LAST_NAME_CUSTOM_KEY coreDataKey:LAST_NAME_DEFAULT_KEY],
             [VOKManagedObjectMap mapWithForeignKeyPath:BIRTHDAY_CUSTOM_KEY coreDataKey:BIRTHDAY_DEFAULT_KEY dateFormatter:[self customDateFormatter]],
             [VOKManagedObjectMap mapWithForeignKeyPath:CATS_CUSTOM_KEY coreDataKey:CATS_DEFAULT_KEY],
             [VOKManagedObjectMap mapWithForeignKeyPath:COOL_RANCH_CUSTOM_KEY coreDataKey:COOL_RANCH_DEFAULT_KEY]];
}

- (NSArray *)customMapsArrayWithKeyPaths
{
    return @[[VOKManagedObjectMap mapWithForeignKeyPath:FIRST_NAME_KEYPATH_KEY coreDataKey:FIRST_NAME_DEFAULT_KEY],
             [VOKManagedObjectMap mapWithForeignKeyPath:LAST_NAME_KEYPATH_KEY coreDataKey:LAST_NAME_DEFAULT_KEY],
             [VOKManagedObjectMap mapWithForeignKeyPath:BIRTHDAY_KEYPATH_KEY coreDataKey:BIRTHDAY_DEFAULT_KEY dateFormatter:[self customDateFormatter]],
             [VOKManagedObjectMap mapWithForeignKeyPath:CATS_KEYPATH_KEY coreDataKey:CATS_DEFAULT_KEY],
             [VOKManagedObjectMap mapWithForeignKeyPath:COOL_RANCH_KEYPATH_KEY coreDataKey:COOL_RANCH_DEFAULT_KEY]];
}

- (NSArray *)customMapsArrayWithoutMicroseconds
{
    return @[[VOKManagedObjectMap mapWithForeignKeyPath:FIRST_NAME_DEFAULT_KEY coreDataKey:FIRST_NAME_DEFAULT_KEY],
             [VOKManagedObjectMap mapWithForeignKeyPath:LAST_NAME_DEFAULT_KEY coreDataKey:LAST_NAME_DEFAULT_KEY],
             [VOKManagedObjectMap mapWithForeignKeyPath:BIRTHDAY_DEFAULT_KEY
                                            coreDataKey:BIRTHDAY_DEFAULT_KEY
                                          dateFormatter:[VOKManagedObjectMap vok_dateFormatterWithoutMicroseconds]],
             [VOKManagedObjectMap mapWithForeignKeyPath:CATS_DEFAULT_KEY coreDataKey:CATS_DEFAULT_KEY],
             [VOKManagedObjectMap mapWithForeignKeyPath:COOL_RANCH_DEFAULT_KEY coreDataKey:COOL_RANCH_DEFAULT_KEY]];
}

@end