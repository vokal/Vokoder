//
//  CoreDataTests.m
//  Vokoder Sample Project
//
//  Copyright © 2015 Vokal.
//

#import <XCTest/XCTest.h>

#import "VOKCoreDataManager.h"
#import "VOKMappablePerson.h"
#import "VOKPerson.h"
#import "VOKThing.h"

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
    [[VOKCoreDataManager sharedInstance] setResource:@"VOKCoreDataModel" database:nil];
}

- (void)testImportExportDictionaryWithDefaultMapper
{
    VOKPerson *person = [VOKPerson vok_addWithDictionary:[self makeServerPersonDictForDefaultMapper] forManagedObjectContext:nil];
    [self checkMappingForPerson:person andDictionary:[self makeServerPersonDictForDefaultMapper]];

    NSDictionary *dict = [person vok_dictionaryRepresentation];
    XCTAssertEqualObjects(dict, [self makeClientPersonDictForDefaultMapper],
                          @"dictionary representation failed to match input dictionary");
}

- (void)testImportExportDictionaryWithMapperWithoutMicroseconds
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:[self customMapsArrayWithoutMicroseconds]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPerson class]];
    VOKPerson *person = [VOKPerson vok_addWithDictionary:[self makeClientPersonDictForMapperWithoutMicroseconds] forManagedObjectContext:nil];
    [self checkMappingForPerson:person
                  andDictionary:[self makeClientPersonDictForMapperWithoutMicroseconds]
              birthdayFormatter:[VOKManagedObjectMap vok_dateFormatterWithoutMicroseconds]
                    birthdayKey:BIRTHDAY_DEFAULT_KEY];

    NSDictionary *dict = [person vok_dictionaryRepresentation];
    XCTAssertEqualObjects(dict, [self makeClientPersonDictForMapperWithoutMicroseconds],
                          @"dictionary representation failed to match input dictionary");
}

- (void)testImportExportDictionaryWithCustomMapper
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:[self customMapsArray]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPerson class]];
    VOKPerson *person = [VOKPerson vok_addWithDictionary:[self makePersonDictForCustomMapper] forManagedObjectContext:nil];
    [self checkCustomMappingForPerson:person andDictionary:[self makePersonDictForCustomMapper]];

    NSDictionary *dict = [person vok_dictionaryRepresentation];
    XCTAssertEqualObjects(dict, [self makePersonDictForCustomMapper],
                          @"dictionary representation failed to match input dictionary");
}

- (void)testImportExportDictionaryWithCustomMapperAndNilProperty
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:[self customMapsArray]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPerson class]];
    VOKPerson *person = [VOKPerson vok_addWithDictionary:[self makePersonDictForCustomMapperAndMissingParameter] forManagedObjectContext:nil];
    [self checkCustomMappingForPerson:person andDictionary:[self makePersonDictForCustomMapperAndMissingParameter]];

    NSDictionary *dict = [person vok_dictionaryRepresentation];
    XCTAssertEqualObjects(dict, [self makePersonDictForCustomMapperAndMissingParameter],
                          @"dictionary representation failed to match input dictionary");
}

- (void)testImportExportDictionaryWithAutoRegisteredMapper
{
    VOKMappablePerson *person = [VOKMappablePerson vok_addWithDictionary:[self makePersonDictForCustomMapper] forManagedObjectContext:nil];
    [self checkCustomMappingForPerson:person andDictionary:[self makePersonDictForCustomMapper]];
    
    NSDictionary *dict = [person vok_dictionaryRepresentation];
    XCTAssertEqualObjects(dict, [self makePersonDictForCustomMapper],
                          @"dictionary representation failed to match input dictionary");
}

- (void)testImportExportDictionaryWithCustomKeyPathMapper
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:[self customMapsArrayWithKeyPaths]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPerson class]];
    VOKPerson *person = [VOKPerson vok_addWithDictionary:[self makePersonDictForCustomMapperWithKeyPaths] forManagedObjectContext:nil];

    XCTAssertNotNil(person, @"person was not created");
    XCTAssertTrue([person isKindOfClass:[VOKPerson class]], @"person is wrong class");
    XCTAssertEqualObjects(person.firstName, @"CUSTOMFIRSTNAME", @"person first name is incorrect");
    XCTAssertEqualObjects(person.lastName, @"CUSTOMLASTNAME", @"person last name is incorrect");
    XCTAssertEqualObjects(person.numberOfCats, @876, @"person number of cats is incorrect");
    XCTAssertEqualObjects(person.lovesCoolRanch, @YES, @"person lovesCoolRanch is incorrect");

    NSDate *birthdate = [[self customDateFormatter] dateFromString:@"24 Jul 83 14:16"];
    XCTAssertEqualObjects(person.birthDay, birthdate, @"person birthdate is incorrect");

    NSDictionary *dict = [person vok_dictionaryRepresentationRespectingKeyPaths];
    XCTAssertEqualObjects(dict, [self makePersonDictForCustomMapperWithKeyPaths],
                          @"dictionary representation failed to match input dictionary");
}

- (void)testImportExportDictionaryWithCustomKeyPathMapperAndNilProperty
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:[self customMapsArrayWithKeyPaths]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPerson class]];
    VOKPerson *person = [VOKPerson vok_addWithDictionary:[self makePersonDictForCustomMapperWithKeyPathsAndMissingParameter] forManagedObjectContext:nil];

    XCTAssertNotNil(person, @"person was not created");
    XCTAssertTrue([person isKindOfClass:[VOKPerson class]], @"person is wrong class");
    XCTAssertEqualObjects(person.firstName, @"CUSTOMFIRSTNAME", @"person first name is incorrect");
    XCTAssertEqualObjects(person.lastName, @"CUSTOMLASTNAME", @"person last name is incorrect");
    XCTAssertNil(person.numberOfCats, @"number of cats should be nil");
    XCTAssertEqualObjects(person.lovesCoolRanch, @YES, @"person lovesCoolRanch is incorrect");

    NSDate *birthdate = [[self customDateFormatter] dateFromString:@"24 Jul 83 14:16"];
    XCTAssertEqualObjects(person.birthDay, birthdate, @"person birthdate is incorrect");

    NSDictionary *dict = [person vok_dictionaryRepresentationRespectingKeyPaths];
    XCTAssertEqualObjects(dict, [self makePersonDictForCustomMapperWithKeyPathsAndMissingParameter],
                          @"dictionary representation failed to match input dictionary");
}

- (void)testImportDictionaryWithCustomMapperNotRegisteredAssert
{
    XCTAssertThrows([VOKPerson vok_addWithDictionary:[self makePersonDictForCustomMapper] forManagedObjectContext:nil]);
}

- (void)testImportDictionaryWithCustomMapperMismatchedAssert
{
    NSArray *maps = [self customMapsArray];
    VOKManagedObjectMap *map = maps.firstObject;
    map.coreDataKey = [map.coreDataKey stringByAppendingString:@"-FAIL"];
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:maps];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPerson class]];
    XCTAssertThrows([VOKPerson vok_addWithDictionary:[self makePersonDictForCustomMapper] forManagedObjectContext:nil]);
}

- (void)testImportArrayWithCustomMapper
{
    NSArray *array = @[
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       ];
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:[self customMapsArray]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPerson class]];
    NSArray *arrayOfPeople = [VOKPerson vok_addWithArray:array forManagedObjectContext:nil];
    
    XCTAssertEqual(arrayOfPeople.count, 5, @"person array has incorrect number of people");
    
    for (VOKPerson *obj in arrayOfPeople) {
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
    NSArray *arrayOfPeople = [VOKMappablePerson vok_addWithArray:array forManagedObjectContext:nil];
    
    XCTAssertEqual(arrayOfPeople.count, 5, @"person array has incorrect number of people");
    
    for (VOKPerson *obj in arrayOfPeople) {
        [self checkCustomMappingForPerson:obj
                            andDictionary:[self makePersonDictForCustomMapper]];
    }
}

- (void)testAsynchronousImportArrayWithCustomMapperOnWriteBlock
{
    NSArray *array = @[
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       ];
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:[self customMapsArray]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPerson class]];

    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"completion"];
    [VOKCoreDataManager writeToTemporaryContext:^(NSManagedObjectContext *tempContext) {
        [VOKPerson vok_addWithArray:array forManagedObjectContext:tempContext];
    } completion:^{
        NSArray *arrayOfPeople = [VOKPerson vok_fetchAllForPredicate:nil forManagedObjectContext:nil];
        XCTAssertEqual(arrayOfPeople.count, 5, @"person array has incorrect number of people");

        for (VOKPerson *obj in arrayOfPeople) {
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
    NSArray *array = @[
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       ];
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:[self customMapsArray]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPerson class]];

    XCTestExpectation *completionExpectation = [self expectationWithDescription:@"completion"];
    [VOKCoreDataManager importArrayInBackground:array
                                       forClass:[VOKPerson class]
                                     completion:^(NSArray *arrayOfManagedObjectIDs) {
                                         NSMutableArray *arrayOfPeople = [NSMutableArray arrayWithCapacity:arrayOfManagedObjectIDs.count];
                                         NSManagedObjectContext *moc = [[VOKCoreDataManager sharedInstance] managedObjectContext];
                                         for (NSManagedObjectID *objectID in arrayOfManagedObjectIDs) {
                                             VOKPerson *obj = (VOKPerson *)[moc objectWithID:objectID];
                                             [arrayOfPeople addObject:obj];
                                             [self checkCustomMappingForPerson:obj
                                                                 andDictionary:[self makePersonDictForCustomMapper]];
                                         }
                                         XCTAssertEqual(arrayOfPeople.count, 5, @"person array has incorrect number of people");
                                         [completionExpectation fulfill];
                                     }];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
        XCTAssertNil(error, @"Error waiting for response:%@", error.description);
    }];
}

- (void)testImportArrayWithDefaultMapper
{
    NSArray *array = @[
                       [self makeServerPersonDictForDefaultMapper],
                       [self makeServerPersonDictForDefaultMapper],
                       [self makeServerPersonDictForDefaultMapper],
                       [self makeServerPersonDictForDefaultMapper],
                       [self makeServerPersonDictForDefaultMapper],
                       ];
    NSArray *arrayOfPeople = [VOKPerson vok_addWithArray:array forManagedObjectContext:nil];

    XCTAssertEqual(arrayOfPeople.count, 5, @"person array has incorrect number of people");

    [arrayOfPeople enumerateObjectsUsingBlock:^(VOKPerson *obj, NSUInteger idx, BOOL *stop) {
        [self checkMappingForPerson:obj andDictionary:[self makeServerPersonDictForDefaultMapper]];
    }];
}

- (void)testImportArrayWithCustomMapperMalformedInput
{
    NSArray *array = @[
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapperWithMalformedInput],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       ];
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:[self customMapsArray]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPerson class]];
    NSArray *arrayOfPeople = [VOKPerson vok_addWithArray:array forManagedObjectContext:nil];

    XCTAssertEqual(arrayOfPeople.count, 5, @"person array has incorrect number of people");
    //just need to check the count and make sure it doesn't crash
}

- (void)testImportArrayWithDefaultMapperMalformedInput
{
    NSArray *array = @[
                       [self makeServerPersonDictForDefaultMapper],
                       [self makeServerPersonDictForDefaultMapper],
                       [self makePersonDictForDefaultMapperWithMalformedInput],
                       [self makeServerPersonDictForDefaultMapper],
                       [self makeServerPersonDictForDefaultMapper],
                       ];
    NSArray *arrayOfPeople = [VOKPerson vok_addWithArray:array forManagedObjectContext:nil];

    XCTAssertEqual(arrayOfPeople.count, 5, @"person array has incorrect number of people");
    //just need to check the count and make sure it doesn't crash
}

- (void)testImportArrayWithMalformedMapper
{
    NSArray *array = @[
                       [self makeServerPersonDictForDefaultMapper],
                       [self makeServerPersonDictForDefaultMapper],
                       [self makePersonDictForDefaultMapperWithMalformedInput],
                       [self makeServerPersonDictForDefaultMapper],
                       [self makeServerPersonDictForDefaultMapper],
                       ];

    NSArray *malformedMaps = @[[VOKManagedObjectMap mapWithForeignKeyPath:FIRST_NAME_MALFORMED_KEY coreDataKey:FIRST_NAME_DEFAULT_KEY],
                            [VOKManagedObjectMap mapWithForeignKeyPath:LAST_NAME_MALFORMED_KEY coreDataKey:LAST_NAME_DEFAULT_KEY],
                            [VOKManagedObjectMap mapWithForeignKeyPath:BIRTHDAY_MALFORMED_KEY coreDataKey:BIRTHDAY_DEFAULT_KEY dateFormatter:[self customDateFormatter]],
                            [VOKManagedObjectMap mapWithForeignKeyPath:CATS_MALFORMED_KEY coreDataKey:CATS_DEFAULT_KEY],
                            [VOKManagedObjectMap mapWithForeignKeyPath:COOL_RANCH_MALFORMED_KEY coreDataKey:COOL_RANCH_DEFAULT_KEY]];
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:@"BAD DATA" andMaps:malformedMaps];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPerson class]];
    NSArray *arrayOfPeople = [VOKPerson vok_addWithArray:array forManagedObjectContext:nil];

    XCTAssertEqual(arrayOfPeople.count, 5, @"person array has incorrect number of people");
    //just need to check the count and make sure it doesn't crash
}

- (void)testImportWithCustomMapperAndAnEmptyInputValue
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:FIRST_NAME_DEFAULT_KEY andMaps:[self customMapsArray]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPerson class]];
    VOKPerson *person = [VOKPerson vok_addWithDictionary:[self makePersonDictForCustomMapper] forManagedObjectContext:nil];
    [self checkCustomMappingForPerson:person andDictionary:[self makePersonDictForCustomMapper]];

    person = [VOKPerson vok_addWithDictionary:[self makePersonDictForCustomMapperWithAnEmptyInputValues] forManagedObjectContext:nil];
    XCTAssertNil(person.lastName,
                 @"the NSNull in the import dictionary did not overwrite the managed object's property");
    XCTAssertNil(person.numberOfCats,
                 @"the missing value in the import dictionary did not overwrite the managed object's property");

    NSUInteger count = [[VOKCoreDataManager sharedInstance] countForClass:[VOKPerson class]];
    XCTAssertEqual(count, 1, @"the unique key did not work correctly");
}

- (void)testImportWithDefaultMapperAndAnEmptyInputValue
{
    VOKPerson *person = [VOKPerson vok_addWithDictionary:[self makePersonDictForDefaultMapperWithAnEmptyInputValues] forManagedObjectContext:nil];
    XCTAssertNil(person.lastName,
                 @"the NSNull in the import dictionary did not overwrite the managed object's property");
    XCTAssertEqual(person.numberOfCats.integerValue, 0,
                   @"the missing value in the import dictionary did not overwrite the managed object's property");
}

- (void)testCountMethods
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:LAST_NAME_DEFAULT_KEY andMaps:[self customMapsArray]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPerson class]];

    NSDictionary *dict1 = @{
                            FIRST_NAME_CUSTOM_KEY : @"Bananaman",
                            LAST_NAME_CUSTOM_KEY : @"DotCom",
                            BIRTHDAY_CUSTOM_KEY : @"24 Jul 83 19:16",
                            CATS_CUSTOM_KEY : @404,
                            COOL_RANCH_CUSTOM_KEY : @NO,
                            };
    [VOKPerson vok_addWithDictionary:dict1 forManagedObjectContext:nil];

    NSUInteger count = [[VOKCoreDataManager sharedInstance] countForClass:[VOKPerson class]];
    XCTAssertEqual(count, 1, @"count method is incorrect");

    NSDictionary *dict2 = @{
                            FIRST_NAME_CUSTOM_KEY : @"Francis",
                            LAST_NAME_CUSTOM_KEY : @"Bolgna",
                            BIRTHDAY_CUSTOM_KEY : @"24 Jul 83 19:16",
                            CATS_CUSTOM_KEY : @404,
                            COOL_RANCH_CUSTOM_KEY : @NO,
                            };
    [VOKPerson vok_addWithDictionary:dict2 forManagedObjectContext:nil];

    count = [[VOKCoreDataManager sharedInstance] countForClass:[VOKPerson class]];
    XCTAssertEqual(count, 2, @"count method is incorrect");

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"firstName == %@",  @"Francis"];
    count = [[VOKCoreDataManager sharedInstance] countForClass:[VOKPerson class] withPredicate:pred forContext:nil];
    XCTAssertEqual(count, 1, @"count with predicate method is incorrect");

    pred = [NSPredicate predicateWithFormat:@"firstName == %@",  @"Bananaman"];
    BOOL exists = [VOKPerson vok_existsForPredicate:pred forManagedObjectContext:nil];
    XCTAssertTrue(exists, @"existsForPredicate is incorrect");
}

- (void)testCustomMapperUniqueKeyAndOverwriteSetting
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:LAST_NAME_DEFAULT_KEY andMaps:[self customMapsArray]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPerson class]];
    
    NSDictionary *dict1 = @{
                            FIRST_NAME_CUSTOM_KEY : @"SOMEGUY",
                            LAST_NAME_CUSTOM_KEY : @"GUY1",
                            BIRTHDAY_CUSTOM_KEY : @"24 Jul 83 14:16",
                            CATS_CUSTOM_KEY : @192,
                            COOL_RANCH_CUSTOM_KEY : @YES,
                            };
    [VOKPerson vok_addWithDictionary:dict1 forManagedObjectContext:nil];
    
    NSDictionary *dict2 = @{
                            FIRST_NAME_CUSTOM_KEY : @"SOMEGUY",
                            LAST_NAME_CUSTOM_KEY : @"GUY2",
                            BIRTHDAY_CUSTOM_KEY : @"24 Jul 83 14:16",
                            CATS_CUSTOM_KEY : @192,
                            COOL_RANCH_CUSTOM_KEY : @YES,
                            };
    [VOKPerson vok_addWithDictionary:dict2 forManagedObjectContext:nil];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"firstName == %@",  @"SOMEGUY"];
    NSArray *array = [VOKPerson vok_fetchAllForPredicate:pred forManagedObjectContext:nil];
    XCTAssertEqual(array.count, 2, @"unique person test array has incorrect number of people");

    NSDictionary *dict3 = @{
                            FIRST_NAME_CUSTOM_KEY : @"ANOTHERGUY",
                            LAST_NAME_CUSTOM_KEY : @"GUY1",
                            BIRTHDAY_CUSTOM_KEY : @"18 Jul 83 14:16",
                            CATS_CUSTOM_KEY : @14,
                            COOL_RANCH_CUSTOM_KEY : @YES,
                            };
    [VOKPerson vok_addWithDictionary:dict3 forManagedObjectContext:nil];

    pred = [NSPredicate predicateWithFormat:@"lastName == %@",  @"GUY1"];
    array = [VOKPerson vok_fetchAllForPredicate:pred forManagedObjectContext:nil];
    XCTAssertEqual(array.count, 1, @"unique key was not effective");
    XCTAssertEqualObjects([array[0] numberOfCats], @14, @"unique key was effective but the person object was not updated");

    mapper.overwriteObjectsWithServerChanges = NO;
    NSDictionary *dict4 = @{
                            FIRST_NAME_CUSTOM_KEY : @"ONE MORE GUY",
                            LAST_NAME_CUSTOM_KEY : @"GUY1",
                            BIRTHDAY_CUSTOM_KEY : @"18 Jul 83 14:16",
                            CATS_CUSTOM_KEY : @777,
                            COOL_RANCH_CUSTOM_KEY : @NO,
                            };
    [VOKPerson vok_addWithDictionary:dict4 forManagedObjectContext:nil];

    pred = [NSPredicate predicateWithFormat:@"lastName == %@",  @"GUY1"];
    array = [VOKPerson vok_fetchAllForPredicate:pred forManagedObjectContext:nil];
    XCTAssertEqual(array.count, 1, @"unique key was not effective");
    XCTAssertEqualObjects([array[0] numberOfCats], @14, @"\"overwriteObjectsWithServerChanges = NO\" was ignored");

    mapper.overwriteObjectsWithServerChanges = YES;
    NSDictionary *dict5 = @{
                            FIRST_NAME_CUSTOM_KEY : @"ONE MORE GUY",
                            LAST_NAME_CUSTOM_KEY : @"GUY1",
                            BIRTHDAY_CUSTOM_KEY : @"18 Jul 83 14:16",
                            CATS_CUSTOM_KEY : @777,
                            COOL_RANCH_CUSTOM_KEY : @NO,
                            };
    [VOKPerson vok_addWithDictionary:dict5 forManagedObjectContext:nil];

    pred = [NSPredicate predicateWithFormat:@"lastName == %@",  @"GUY1"];
    array = [VOKPerson vok_fetchAllForPredicate:pred forManagedObjectContext:nil];
    XCTAssertEqual(array.count, 1, @"unique key was not effective");
    XCTAssertEqualObjects([array[0] numberOfCats], @777, @"\"overwriteObjectsWithServerChanges = NO\" was ignored");
}

- (void)testFetchWithURI
{
    VOKPerson *person = [VOKPerson vok_addWithDictionary:[self makePersonDictForDefaultMapperWithAnEmptyInputValues] forManagedObjectContext:nil];
    [[VOKCoreDataManager sharedInstance] saveMainContextAndWait];
    NSManagedObjectID *objectID = person.objectID;
    NSURL *uri = objectID.URIRepresentation;
    person = nil;
    [[[VOKCoreDataManager sharedInstance] managedObjectContext] reset];

    VOKPerson *personFromURI = (VOKPerson *)[[VOKCoreDataManager sharedInstance] existingObjectAtURI:uri
                                                                             forManagedObjectContext:nil];
    XCTAssertNotNil(personFromURI, @"failed to get existing person object from URI");
    XCTAssertTrue([personFromURI isKindOfClass:[VOKPerson class]], @"existing person object was not correct class");
}

- (void)testFetchWithMalformedURI
{
    NSURL *uri = [NSURL URLWithString:@"x-coredata://1C8D8740-06E2-4B79-A739-94071E03CD74/VOKPerson/p99"];
    VOKPerson *personFromURI = (VOKPerson *)[[VOKCoreDataManager sharedInstance] existingObjectAtURI:uri
                                                                           forManagedObjectContext:nil];
    XCTAssertNil(personFromURI, @"existingObjectAtURI did not fail correctly. returned non nil value for malformed URI");
}

- (void)testVOKEntityNameMethod
{
    // While it's not generally guaranteed that the entity name will be the same as the NSManagedObject subclass name,
    // we've set these two entities up to be that way for simplicity.  Let's make sure that the vok_entityName method
    // actually does what it's supposed to.
    XCTAssertEqualObjects(NSStringFromClass([VOKPerson class]), [VOKPerson vok_entityName], @"VOKPerson entity name is not VOKPerson");
    XCTAssertEqualObjects(NSStringFromClass([VOKThing class]), [VOKThing vok_entityName], @"VOKThing entity name is not VOKThing");
}

- (void)testIgnoreNullValueOverwrites
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:LAST_NAME_DEFAULT_KEY andMaps:[self customMapsArray]];
    mapper.ignoreNullValueOverwrites = YES;
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPerson class]];

    NSDictionary *dict1 = @{
                            FIRST_NAME_CUSTOM_KEY : @"SOMEGUY",
                            LAST_NAME_CUSTOM_KEY : @"GUY1",
                            BIRTHDAY_CUSTOM_KEY : @"24 Jul 83 14:16",
                            CATS_CUSTOM_KEY : @192,
                            COOL_RANCH_CUSTOM_KEY : @YES,
                            };
    [VOKPerson vok_addWithDictionary:dict1 forManagedObjectContext:nil];

    NSDictionary *dict2 = @{
                            FIRST_NAME_CUSTOM_KEY : @"Billy",
                            LAST_NAME_CUSTOM_KEY : @"GUY1",
                            CATS_CUSTOM_KEY : [NSNull null],
                            COOL_RANCH_CUSTOM_KEY : @YES,
                            };
    [VOKPerson vok_addWithDictionary:dict2 forManagedObjectContext:nil];

    NSPredicate *pred = [NSPredicate predicateWithFormat:@"lastName == %@",  @"GUY1"];
    NSArray *array = [VOKPerson vok_fetchAllForPredicate:pred forManagedObjectContext:nil];
    XCTAssertEqual(array.count, 1, @"unique person test array has incorrect number of people");

    VOKPerson *testDude = array[0];
    XCTAssertEqualObjects(testDude.numberOfCats, @192, @"nil value overwrote existing value incorrectly");
    XCTAssertEqualObjects(testDude.firstName, @"Billy", @"somehow the name didn't update");
    XCTAssertNotNil(testDude.birthDay, @"nonexistent key overwrote existing value incorrectly");
}

- (void)testPostImportBlockWithDefaultMapper
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper defaultMapper];
    mapper.importCompletionBlock = ^(NSDictionary *inputDict, NSManagedObject *outputObject) {
        //ALWAYS LOVE COOL RANCH
        [outputObject setValue:@YES forKey:VOK_CDSELECTOR(lovesCoolRanch)];
    };
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPerson class]];

    NSDictionary *dict1 = [self makeServerPersonDictForDefaultMapper];

    VOKPerson *person = [VOKPerson vok_addWithDictionary:dict1 forManagedObjectContext:nil];
    XCTAssertTrue([person.lovesCoolRanch boolValue], @"Post import block ran incorrectly");
}

- (void)testPostImportBlockWithRelationship
{
    NSArray *thingMaps = @[
                           VOK_MAP_FOREIGN_TO_LOCAL(THING_NAME_KEY, name),
                           VOK_MAP_FOREIGN_TO_LOCAL(THING_HAT_COUNT_KEY, numberOfHats),
                           ];
    VOKManagedObjectMapper *thingMapper = [VOKManagedObjectMapper mapperWithUniqueKey:@"thing_name" andMaps:thingMaps];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:thingMapper forClass:[VOKThing class]];
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:LAST_NAME_DEFAULT_KEY andMaps:[self customMapsArray]];
    mapper.importCompletionBlock = ^(NSDictionary *inputDict, NSManagedObject *outputObject){
        NSDictionary *thingDict = inputDict[@"nested_thing"];
        VOKThing *thing = [VOKThing vok_addWithDictionary:thingDict forManagedObjectContext:outputObject.managedObjectContext];
        [outputObject setValue:thing forKey:VOK_CDSELECTOR(thing)];
    };
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPerson class]];

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
                                    },
                            };
    VOKPerson *person = [VOKPerson vok_addWithDictionary:dict1 forManagedObjectContext:nil];
    XCTAssertNotNil(person.thing, @"Post import block failed to set person relationship");
    VOKThing *thing = person.thing;
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
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPerson class]];

    VOKPerson *person = [VOKPerson vok_addWithDictionary:[self makeServerPersonDictForDefaultMapper] forManagedObjectContext:nil];
    [self checkMappingForPerson:person andDictionary:[self makeServerPersonDictForDefaultMapper]];

    NSDictionary *dict = [person vok_dictionaryRepresentation];
    XCTAssertNotNil(dict[@"test"], @"Post export block ran incorrectly");
    XCTAssertNil(dict[CATS_DEFAULT_KEY], @"Post export block ran incorrectly");
}

- (void)testUniqueKeyPath
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:LAST_NAME_DEFAULT_KEY andMaps:[self customMapsArrayWithKeyPaths]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPerson class]];
    
    NSMutableDictionary *personDict = [[self makePersonDictForCustomMapperWithKeyPaths] mutableCopy];
    
    [VOKPerson vok_addWithDictionary:personDict forManagedObjectContext:nil];
    
    VOKPerson *person = [[VOKCoreDataManager sharedInstance] arrayForClass:[VOKPerson class]].firstObject;
    XCTAssertEqualObjects([[self customDateFormatter] stringFromDate:person.birthDay], @"24 Jul 83 14:16");
    
    //change something, but keep the same unique key
    NSString *dateString = @"24 Jul 75 23:00";
    personDict[BIRTHDAY_KEYPATH_KEY] = dateString;
    
    //adding again should overwrite the existing one
    [VOKPerson vok_addWithDictionary:personDict forManagedObjectContext:nil];
    
    NSArray *people = [[VOKCoreDataManager sharedInstance] arrayForClass:[VOKPerson class]];
    XCTAssertEqual(people.count, 1);
    
    person = people.firstObject;
    XCTAssertEqualObjects([[self customDateFormatter] stringFromDate:person.birthDay], dateString);
}

- (void)testImportingTwoObjectsWithTheSameUniqueIDOverwritesWithUniqueKey
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:LAST_NAME_DEFAULT_KEY
                                                                         andMaps:[self customMapsArray]];
    
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPerson class]];
    
    //Create two people with the same last name, one with a different name.
    NSDictionary *person1 = [self makePersonDictForCustomMapper];
    NSMutableDictionary *person2 = [[self makePersonDictForCustomMapper] mutableCopy];
    NSString *overwrittenName = @"OVERWRITTEN";
    person2[FIRST_NAME_CUSTOM_KEY] = overwrittenName;
    
    //Create a third person with a different last name
    NSMutableDictionary *person3 = [[self makePersonDictForCustomMapper] mutableCopy];
    person3[LAST_NAME_CUSTOM_KEY] = @"SOMEBODY-ELSE";
    
    NSArray *peopleDicts = @[person1, person2, person3];
    
    NSArray *arrayOfPeople = [VOKPerson vok_addWithArray:peopleDicts forManagedObjectContext:nil];
    
    XCTAssertTrue(arrayOfPeople.count == 2, @"person array has incorrect number of people");
    
    if (arrayOfPeople.count == 2) {
        [self checkCustomMappingForPerson:arrayOfPeople[0] andDictionary:person2];
        [self checkCustomMappingForPerson:arrayOfPeople[1] andDictionary:person3];
    }
}

#pragma mark - Convenience stuff

- (void)checkMappingForPerson:(VOKPerson *)person andDictionary:(NSDictionary *)dict
{
    [self checkMappingForPerson:person
                  andDictionary:dict
              birthdayFormatter:[VOKManagedObjectMap vok_defaultDateFormatter]
                    birthdayKey:BIRTHDAY_DEFAULT_KEY];
}

- (void)checkCustomMappingForPerson:(VOKPerson *)person andDictionary:(NSDictionary *)dict
{
    [self checkMappingForPerson:person
                  andDictionary:dict
              birthdayFormatter:[self customDateFormatter]
                    birthdayKey:BIRTHDAY_CUSTOM_KEY];
}

- (void)checkMappingForPerson:(VOKPerson *)person
                andDictionary:(NSDictionary *)dict
            birthdayFormatter:(NSDateFormatter *)birthdayFormatter
                  birthdayKey:(NSString *)birthdayKey
{
    XCTAssertNotNil(person, @"person was not created");
    XCTAssertTrue([person isKindOfClass:[VOKPerson class]], @"person is wrong class");

    NSString *firstName = [dict objectForKey:FIRST_NAME_DEFAULT_KEY] ?: [dict objectForKey:FIRST_NAME_CUSTOM_KEY];
    XCTAssertEqualObjects(person.firstName, firstName, @"person first name is incorrect");

    NSString *lastName = [dict objectForKey:LAST_NAME_DEFAULT_KEY] ?: [dict objectForKey:LAST_NAME_CUSTOM_KEY];
    XCTAssertEqualObjects(person.lastName, lastName, @"person last name is incorrect");

    NSNumber *cats = [dict objectForKey:CATS_DEFAULT_KEY] ?: [dict objectForKey:CATS_CUSTOM_KEY];
    XCTAssertEqualObjects(person.numberOfCats, cats, @"person number of cats is incorrect");

    NSNumber *lovesCoolRanch = [dict objectForKey:COOL_RANCH_DEFAULT_KEY] ?: [dict objectForKey:COOL_RANCH_CUSTOM_KEY];
    XCTAssertEqualObjects(person.lovesCoolRanch, lovesCoolRanch, @"person lovesCoolRanch is incorrect");

    NSDate *birthdate = [birthdayFormatter dateFromString:[dict objectForKey:birthdayKey]];

    if (person.birthDay) {
        //only check if birthday should be there.
        XCTAssertEqualObjects(person.birthDay, birthdate, @"person birthdate is incorrect");
    }
}

- (NSString *)randomNumberString
{
    return [NSString stringWithFormat:@"%d", arc4random()%3000];
}

- (NSDictionary *)makeServerPersonDictForDefaultMapper
{
    NSDictionary *dict = @{
                           FIRST_NAME_DEFAULT_KEY :  @"BILLY",
                           LAST_NAME_DEFAULT_KEY : @"TESTCASE" ,
                           BIRTHDAY_DEFAULT_KEY : @"1983-07-24T03:22:15.321123Z",
                           CATS_DEFAULT_KEY : @17,
                           COOL_RANCH_DEFAULT_KEY : @NO,
                           };
    return dict;
}

- (NSDictionary *)makeClientPersonDictForDefaultMapper
{
    // Server can return microseconds, but NSDate will only store milliseconds
    // For testing, copy the server response and reduce the accuracy for comparing
    NSMutableDictionary *mutableDict = [[self makeServerPersonDictForDefaultMapper] mutableCopy];
    mutableDict[BIRTHDAY_DEFAULT_KEY] = @"1983-07-24T03:22:15.321000Z";
    return mutableDict;
}

- (NSDictionary *)makeClientPersonDictForMapperWithoutMicroseconds
{
    // For testing, copy the server response and strip off the microseconds to
    // test the format that omits them
    NSMutableDictionary *mutableDict = [[self makeServerPersonDictForDefaultMapper] mutableCopy];
    mutableDict[BIRTHDAY_DEFAULT_KEY] = @"1983-07-24T03:22:15Z";
    return mutableDict;
}

- (NSDictionary *)makePersonDictForCustomMapper
{
    NSDictionary *dict = @{
                           FIRST_NAME_CUSTOM_KEY : @"CUSTOM",
                           LAST_NAME_CUSTOM_KEY : @"MAPMAN",
                           BIRTHDAY_CUSTOM_KEY : @"24 Jul 83 14:16",
                           CATS_CUSTOM_KEY : @192,
                           COOL_RANCH_CUSTOM_KEY : @YES,
                           };
    return dict;
}

- (NSDictionary *)makePersonDictForCustomMapperAndMissingParameter
{
    NSDictionary *dict = @{
                           FIRST_NAME_CUSTOM_KEY : @"CUSTOM",
                           LAST_NAME_CUSTOM_KEY : @"MAPMAN",
                           CATS_CUSTOM_KEY : @192,
                           COOL_RANCH_CUSTOM_KEY : @YES,
                           };
    return dict;
}

- (NSDictionary *)makePersonDictForCustomMapperWithKeyPaths
{
    NSDictionary *nameDict = @{
                               @"first": @"CUSTOMFIRSTNAME",
                               @"last": @"CUSTOMLASTNAME",
                               };
    NSDictionary *catsDict = @{
                               @"number": @876,
                               };

    NSDictionary *prefsDict = @{
                                @"cats": catsDict,
                                @"coolRanch": @YES,
                                };

    NSDictionary *dict = @{
                           @"name": nameDict,
                           BIRTHDAY_KEYPATH_KEY : @"24 Jul 83 14:16",
                           @"prefs": prefsDict,
                           };
    return dict;
}

- (NSDictionary *)makePersonDictForCustomMapperWithKeyPathsAndMissingParameter
{
    NSDictionary *nameDict = @{
                               @"first": @"CUSTOMFIRSTNAME",
                               @"last": @"CUSTOMLASTNAME",
                               };
    NSDictionary *catsDict = @{};

    NSDictionary *prefsDict = @{
                                @"cats": catsDict,
                                @"coolRanch": @YES,
                                };

    NSDictionary *dict = @{
                           @"name": nameDict,
                           BIRTHDAY_KEYPATH_KEY : @"24 Jul 83 14:16",
                           @"prefs": prefsDict,
                           };
    return dict;
}

- (NSDictionary *)makePersonDictForDefaultMapperWithAnEmptyInputValues
{
    NSDictionary *dict = @{
                           FIRST_NAME_DEFAULT_KEY :  @"BILLY",
                           LAST_NAME_DEFAULT_KEY :  [NSNull null],
                           BIRTHDAY_DEFAULT_KEY : @"1983-07-24T03:22:15.321123Z",
                           COOL_RANCH_DEFAULT_KEY : @NO,
                           };
    return dict;
}

- (NSDictionary *)makePersonDictForCustomMapperWithAnEmptyInputValues
{
    NSDictionary *dict = @{
                           FIRST_NAME_CUSTOM_KEY : @"CUSTOM",
                           LAST_NAME_CUSTOM_KEY : [NSNull null],
                           BIRTHDAY_CUSTOM_KEY : @"24 Jul 83 14:16",
                           COOL_RANCH_CUSTOM_KEY : @YES,
                           };
    return dict;
}

- (NSDictionary *)makePersonDictForDefaultMapperWithMalformedInput
{
    NSDictionary *dict = @{
                           FIRST_NAME_DEFAULT_KEY :  @"BILLY",
                           LAST_NAME_DEFAULT_KEY : @"TESTCASE" ,
                           BIRTHDAY_DEFAULT_KEY : @"1983-07-24T03:22:15.321123Z",
                           CATS_DEFAULT_KEY : @[@17],
                           COOL_RANCH_DEFAULT_KEY : @{@"something": @NO},
                           };
    return dict;
}

- (NSDictionary *)makePersonDictForCustomMapperWithMalformedInput
{
    NSDictionary *dict = @{
                           FIRST_NAME_CUSTOM_KEY : @"CUSTOM",
                           LAST_NAME_CUSTOM_KEY : @"MAPMAN",
                           BIRTHDAY_CUSTOM_KEY : @"24 Jul 83 14:16",
                           CATS_CUSTOM_KEY : @{@"something": @192},
                           COOL_RANCH_CUSTOM_KEY : @[@YES],
                           };
    return dict;
}

- (NSDateFormatter *)customDateFormatter
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"dd' 'LLL' 'yy' 'HH:mm";
    df.timeZone = [NSTimeZone localTimeZone];
    return df;
}

- (NSArray *)customMapsArray
{
    return @[
             [VOKManagedObjectMap mapWithForeignKeyPath:FIRST_NAME_CUSTOM_KEY coreDataKey:FIRST_NAME_DEFAULT_KEY],
             [VOKManagedObjectMap mapWithForeignKeyPath:LAST_NAME_CUSTOM_KEY coreDataKey:LAST_NAME_DEFAULT_KEY],
             [VOKManagedObjectMap mapWithForeignKeyPath:BIRTHDAY_CUSTOM_KEY coreDataKey:BIRTHDAY_DEFAULT_KEY dateFormatter:[self customDateFormatter]],
             [VOKManagedObjectMap mapWithForeignKeyPath:CATS_CUSTOM_KEY coreDataKey:CATS_DEFAULT_KEY],
             [VOKManagedObjectMap mapWithForeignKeyPath:COOL_RANCH_CUSTOM_KEY coreDataKey:COOL_RANCH_DEFAULT_KEY],
             ];
}

- (NSArray *)customMapsArrayWithKeyPaths
{
    return @[
             [VOKManagedObjectMap mapWithForeignKeyPath:FIRST_NAME_KEYPATH_KEY coreDataKey:FIRST_NAME_DEFAULT_KEY],
             [VOKManagedObjectMap mapWithForeignKeyPath:LAST_NAME_KEYPATH_KEY coreDataKey:LAST_NAME_DEFAULT_KEY],
             [VOKManagedObjectMap mapWithForeignKeyPath:BIRTHDAY_KEYPATH_KEY coreDataKey:BIRTHDAY_DEFAULT_KEY dateFormatter:[self customDateFormatter]],
             [VOKManagedObjectMap mapWithForeignKeyPath:CATS_KEYPATH_KEY coreDataKey:CATS_DEFAULT_KEY],
             [VOKManagedObjectMap mapWithForeignKeyPath:COOL_RANCH_KEYPATH_KEY coreDataKey:COOL_RANCH_DEFAULT_KEY],
             ];
}

- (NSArray *)customMapsArrayWithoutMicroseconds
{
    return @[
             [VOKManagedObjectMap mapWithForeignKeyPath:FIRST_NAME_DEFAULT_KEY coreDataKey:FIRST_NAME_DEFAULT_KEY],
             [VOKManagedObjectMap mapWithForeignKeyPath:LAST_NAME_DEFAULT_KEY coreDataKey:LAST_NAME_DEFAULT_KEY],
             [VOKManagedObjectMap mapWithForeignKeyPath:BIRTHDAY_DEFAULT_KEY
                                            coreDataKey:BIRTHDAY_DEFAULT_KEY
                                          dateFormatter:[VOKManagedObjectMap vok_dateFormatterWithoutMicroseconds]],
             [VOKManagedObjectMap mapWithForeignKeyPath:CATS_DEFAULT_KEY coreDataKey:CATS_DEFAULT_KEY],
             [VOKManagedObjectMap mapWithForeignKeyPath:COOL_RANCH_DEFAULT_KEY coreDataKey:COOL_RANCH_DEFAULT_KEY],
             ];
}

@end
