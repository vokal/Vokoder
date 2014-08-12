//
//  CoreDataTests.m
//  CoreDataTests
//

#import <XCTest/XCTest.h>
#import "VOKCoreDataManager.h"
#import "VIPerson.h"
#import "VIThing.h"

NSString *const FIRST_NAME_DEFAULT_KEY = @"firstName";
NSString *const LAST_NAME_DEFAULT_KEY = @"lastName";
NSString *const BIRTHDAY_DEFAULT_KEY = @"birthDay";
NSString *const CATS_DEFAULT_KEY = @"numberOfCats";
NSString *const COOL_RANCH_DEFAULT_KEY = @"lovesCoolRanch";

NSString *const FIRST_NAME_CUSTOM_KEY = @"first";
NSString *const LAST_NAME_CUSTOM_KEY = @"last";
NSString *const BIRTHDAY_CUSTOM_KEY = @"date_of_birth";
NSString *const CATS_CUSTOM_KEY = @"cat_num";
NSString *const COOL_RANCH_CUSTOM_KEY = @"CR_PREF";

NSString *const FIRST_NAME_MALFORMED_KEY = @"first.banana";
NSString *const LAST_NAME_MALFORMED_KEY = @"somethingsomething.something.something";
NSString *const BIRTHDAY_MALFORMED_KEY = @"date_of_birth?";
NSString *const CATS_MALFORMED_KEY = @"cat_num_biz";
NSString *const COOL_RANCH_MALFORMED_KEY = @"CR_PREF";

NSString *const FIRST_NAME_KEYPATH_KEY = @"name.first";
NSString *const LAST_NAME_KEYPATH_KEY = @"name.last";
NSString *const BIRTHDAY_KEYPATH_KEY = @"birthday";
NSString *const CATS_KEYPATH_KEY = @"prefs.cats.number";
NSString *const COOL_RANCH_KEYPATH_KEY = @"prefs.coolRanch";

@interface VOKManagedObjectMap (VOKdefaultFormatters) //for testing!
+ (NSDateFormatter *)vok_defaultDateFormatter;
+ (NSNumberFormatter *)vok_defaultNumberFormatter;

@end

@interface ManagedObjectAdditionTests : XCTestCase

@end

@implementation ManagedObjectAdditionTests

- (void)setUp
{
    [super setUp];
    [[VOKCoreDataManager sharedInstance] resetCoreData];
    [[VOKCoreDataManager sharedInstance] setResource:@"VICoreDataModel" database:nil];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testImportExportDictionaryWithDefaultMapper
{
    VIPerson *person = [VIPerson vok_addWithDictionary:[self makePersonDictForDefaultMapper] forManagedObjectContext:nil];
    [self checkMappingForPerson:person andDictionary:[self makePersonDictForDefaultMapper]];

    NSDictionary *dict = [person vok_dictionaryRepresentation];
    XCTAssertTrue([dict isEqualToDictionary:[self makePersonDictForDefaultMapper]], @"dictionary representation failed to match input dictionary");
}

- (void)testImportExportDictionaryWithCustomMapper
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:[self customMapsArray]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];
    VIPerson *person = [VIPerson vok_addWithDictionary:[self makePersonDictForCustomMapper] forManagedObjectContext:nil];
    [self checkMappingForPerson:person andDictionary:[self makePersonDictForCustomMapper]];

    NSDictionary *dict = [person vok_dictionaryRepresentation];
    XCTAssertTrue([dict isEqualToDictionary:[self makePersonDictForCustomMapper]], @"dictionary representation failed to match input dictionary");
}

- (void)testImportExportDictionaryWithCustomMapperAndNilProperty
{
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:[self customMapsArray]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];
    VIPerson *person = [VIPerson vok_addWithDictionary:[self makePersonDictForCustomMapperAndMissingParameter] forManagedObjectContext:nil];
    [self checkMappingForPerson:person andDictionary:[self makePersonDictForCustomMapperAndMissingParameter]];

    NSDictionary *dict = [person vok_dictionaryRepresentation];
    XCTAssertTrue([dict isEqualToDictionary:[self makePersonDictForCustomMapperAndMissingParameter]], @"dictionary representation failed to match input dictionary");
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

    [arrayOfPeople enumerateObjectsUsingBlock:^(VIPerson *obj, NSUInteger idx, BOOL *stop) {
        [self checkMappingForPerson:obj andDictionary:[self makePersonDictForCustomMapper]];
    }];
}

- (void)testImportArrayWithCustomMapperOnWriteBlock
{
    NSArray *array = @[[self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper],
                       [self makePersonDictForCustomMapper]];
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:nil andMaps:[self customMapsArray]];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VIPerson class]];

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [VOKCoreDataManager writeToTemporaryContext:^(NSManagedObjectContext *tempContext) {
        [VIPerson vok_addWithArray:array forManagedObjectContext:tempContext];
        dispatch_semaphore_signal(semaphore);
    } completion:NULL];
    [self waitForResponse:1 semaphore:semaphore];

    NSArray *arrayOfPeople = [VIPerson vok_fetchAllForPredicate:nil forManagedObjectContext:nil];
    XCTAssertTrue([arrayOfPeople count] == 5, @"person array has incorrect number of people");

    [arrayOfPeople enumerateObjectsUsingBlock:^(VIPerson *obj, NSUInteger idx, BOOL *stop) {
        [self checkMappingForPerson:obj andDictionary:[self makePersonDictForCustomMapper]];
    }];
}

- (void)testImportArrayWithDefaultMapper
{
    NSArray *array = @[[self makePersonDictForDefaultMapper],
                       [self makePersonDictForDefaultMapper],
                       [self makePersonDictForDefaultMapper],
                       [self makePersonDictForDefaultMapper],
                       [self makePersonDictForDefaultMapper]];
    NSArray *arrayOfPeople = [VIPerson vok_addWithArray:array forManagedObjectContext:nil];

    XCTAssertTrue([arrayOfPeople count] == 5, @"person array has incorrect number of people");

    [arrayOfPeople enumerateObjectsUsingBlock:^(VIPerson *obj, NSUInteger idx, BOOL *stop) {
        [self checkMappingForPerson:obj andDictionary:[self makePersonDictForDefaultMapper]];
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
    NSArray *array = @[[self makePersonDictForDefaultMapper],
                       [self makePersonDictForDefaultMapper],
                       [self makePersonDictForDefaultMapperWithMalformedInput],
                       [self makePersonDictForDefaultMapper],
                       [self makePersonDictForDefaultMapper]];
    NSArray *arrayOfPeople = [VIPerson vok_addWithArray:array forManagedObjectContext:nil];

    XCTAssertTrue([arrayOfPeople count] == 5, @"person array has incorrect number of people");
    //just need to check the count and make sure it doesn't crash
}

- (void)testImportArrayWithMalformedMapper
{
    NSArray *array = @[[self makePersonDictForDefaultMapper],
                       [self makePersonDictForDefaultMapper],
                       [self makePersonDictForDefaultMapperWithMalformedInput],
                       [self makePersonDictForDefaultMapper],
                       [self makePersonDictForDefaultMapper]];

    NSArray *malformedMaps = @[[VOKManagedObjectMap mapWithForeignKeyPath:FIRST_NAME_MALFORMED_KEY coreDataKey:FIRST_NAME_DEFAULT_KEY],
                            [VOKManagedObjectMap mapWithForeignKeyPath:LAST_NAME_MALFORMED_KEY coreDataKey:LAST_NAME_DEFAULT_KEY],
                            [VOKManagedObjectMap mapWithForeignKeyPath:BIRTHDAY_MALFORMED_KEY coreDataKey:BIRTHDAY_DEFAULT_KEY dateFormatter:[self customDateFormatter]],
                            [VOKManagedObjectMap mapWithForeignKeyPath:CATS_MALFORMED_KEY coreDataKey:CATS_DEFAULT_KEY],
                            [VOKManagedObjectMap mapWithForeignKeyPath:COOL_RANCH_MALFORMED_KEY coreDataKey:COOL_RANCH_DEFAULT_KEY]];
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:@"fart" andMaps:malformedMaps];
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
    [self checkMappingForPerson:person andDictionary:[self makePersonDictForCustomMapper]];

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

#pragma mark - Convenience stuff

- (void)waitForResponse:(NSInteger)waitTimeInSeconds semaphore:(dispatch_semaphore_t)semaphore
{
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:waitTimeInSeconds];
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW)) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if (timeoutDate == [timeoutDate earlierDate:[NSDate date]]) {
            XCTAssertTrue(NO, @"Waiting for completion took longer than %ldsec", (long)waitTimeInSeconds);
            return;
        }
    }
}

- (void)checkMappingForPerson:(VIPerson *)person andDictionary:(NSDictionary *)dict
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

    NSDate *birthdate = [[VOKManagedObjectMap vok_defaultDateFormatter] dateFromString:[dict objectForKey:BIRTHDAY_DEFAULT_KEY]];
    if (!birthdate) {
        birthdate = [[self customDateFormatter] dateFromString:[dict objectForKey:BIRTHDAY_CUSTOM_KEY]];
    }
    if (person.birthDay) {
        //only check if birthday should be there.
        XCTAssertTrue([person.birthDay isEqualToDate:birthdate], @"person birthdate is incorrect");
    }
}

- (NSString *)randomNumberString
{
    return [NSString stringWithFormat:@"%d", arc4random()%3000];
}

- (NSDictionary *)makePersonDictForDefaultMapper
{
    NSDictionary *dict = @{FIRST_NAME_DEFAULT_KEY :  @"BILLY",
                           LAST_NAME_DEFAULT_KEY : @"TESTCASE" ,
                           BIRTHDAY_DEFAULT_KEY : @"1983-07-24T03:22:15Z",
                           CATS_DEFAULT_KEY : @17,
                           COOL_RANCH_DEFAULT_KEY : @NO};
    return dict;
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
                           BIRTHDAY_DEFAULT_KEY : @"1983-07-24T03:22:15Z",
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
                           BIRTHDAY_DEFAULT_KEY : @"1983-07-24T03:22:15Z",
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

@end