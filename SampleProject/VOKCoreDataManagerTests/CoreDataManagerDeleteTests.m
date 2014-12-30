//
//  CoreDataManagerDeleteTests.m
//  SampleProject
//
//  Created by Carl Hill-Popper on 11/24/14.
//
//

#import <XCTest/XCTest.h>
#import "VOKCoreDataManager.h"
#import "NSManagedObject+VOKManagedObjectAdditions.h"
#import "VIThing.h"

@interface CoreDataManagerDeleteTests : XCTestCase

@end

@implementation CoreDataManagerDeleteTests

- (void)setUp
{
    [super setUp];
    [[VOKCoreDataManager sharedInstance] resetCoreData];
    [[VOKCoreDataManager sharedInstance] setResource:@"VICoreDataModel" database:nil];
}

- (VIThing *)addThingWithName:(NSString *)name numberOfHats:(NSInteger)numberOfHats
{
    VIThing *thing = [VIThing vok_newInstance];
    thing.name = name;
    thing.numberOfHats = @(numberOfHats);
    
    [[VOKCoreDataManager sharedInstance] saveMainContext];
    
    return thing;
}

- (void)addSequentialThingsWithBaseName:(NSString *)baseName
                       baseNumberOfHats:(NSInteger)baseNumberOfHats
                                  count:(NSInteger)countOfThings
{
    for (NSInteger i = 0; i < countOfThings; i++) {
        [self addThingWithName:[baseName stringByAppendingFormat:@" %@", @(i + 1)]
                  numberOfHats:i + baseNumberOfHats];
    }
}

- (void)testDeleteObject
{
    VOKCoreDataManager *manager = [VOKCoreDataManager sharedInstance];
    
    VIThing *thing = [self addThingWithName:@"Johnny Test" numberOfHats:5000];
    
    XCTAssert([[VOKCoreDataManager sharedInstance] countForClass:[VIThing class]] == 1);
    
    [manager deleteObject:thing];
    
    XCTAssert([manager countForClass:[VIThing class]] == 0);
}

- (void)testDeleteAllObjectsOfClass
{
    VOKCoreDataManager *manager = [VOKCoreDataManager sharedInstance];
    
    NSInteger numObjects = 10;
    [self addSequentialThingsWithBaseName:@"Thing"
                         baseNumberOfHats:1
                                    count:numObjects];
    
    XCTAssert([manager countForClass:[VIThing class]] == numObjects);
    
    [manager deleteAllObjectsOfClass:[VIThing class] context:nil];
    
    XCTAssert([manager countForClass:[VIThing class]] == 0);
}

- (void)testDeleteObjectsWithPredicateThatShouldDeleteNone
{
    VOKCoreDataManager *manager = [VOKCoreDataManager sharedInstance];
    
    NSInteger numObjects = 10;
    [self addSequentialThingsWithBaseName:@"Thing"
                         baseNumberOfHats:1
                                    count:numObjects];
    
    XCTAssert([manager countForClass:[VIThing class]] == numObjects);
    
    //this predicate shouldn't match any existing objects
    NSPredicate *tooManyHats = [NSPredicate predicateWithFormat:@"%K > %@", VOK_CDSELECTOR(numberOfHats), @(100)];
    
    [manager deleteAllObjectsOfClass:[VIThing class]
                   matchingPredicate:tooManyHats
                             context:nil];
    
    //so nothing should be deleted
    XCTAssert([manager countForClass:[VIThing class]] == numObjects);
}

- (void)testDeleteObjectsWithPredicateThatShouldDeleteOne
{
    VOKCoreDataManager *manager = [VOKCoreDataManager sharedInstance];
    
    NSInteger numObjects = 10;
    [self addSequentialThingsWithBaseName:@"Thing"
                         baseNumberOfHats:1
                                    count:numObjects];
    
    XCTAssert([manager countForClass:[VIThing class]] == numObjects);
    
    NSPredicate *hasFiveHats = [NSPredicate predicateWithFormat:@"%K == %@", VOK_CDSELECTOR(numberOfHats), @(5)];
    [manager deleteAllObjectsOfClass:[VIThing class]
                   matchingPredicate:hasFiveHats
                             context:nil];
    
    //1 thing should be deleted
    XCTAssert([manager countForClass:[VIThing class]] == numObjects - 1);
}

- (void)testDeleteObjectsWithPredicateThatShouldDeleteSome
{
    VOKCoreDataManager *manager = [VOKCoreDataManager sharedInstance];
    
    NSInteger numObjects = 10;
    [self addSequentialThingsWithBaseName:@"Thing"
                         baseNumberOfHats:1
                                    count:numObjects];
    
    XCTAssert([manager countForClass:[VIThing class]] == numObjects);
    
    NSPredicate *hasAtLeastFiveHats = [NSPredicate predicateWithFormat:@"%K >= %@",
                                       VOK_CDSELECTOR(numberOfHats), @(5)];
    [manager deleteAllObjectsOfClass:[VIThing class]
                   matchingPredicate:hasAtLeastFiveHats
                             context:nil];
    
    //6 things should be deleted: [1 - 10] deleting [5 - 10] leaves [1 - 4]
    XCTAssert([manager countForClass:[VIThing class]] == numObjects - 6);
}

- (void)testDeleteObjectsWithPredicateThatShouldDeleteAll
{
    VOKCoreDataManager *manager = [VOKCoreDataManager sharedInstance];
    
    NSInteger numObjects = 10;
    [self addSequentialThingsWithBaseName:@"Thing"
                         baseNumberOfHats:1
                                    count:numObjects];
    
    XCTAssert([manager countForClass:[VIThing class]] == numObjects);
    
    NSPredicate *lessThanFiftyHats = [NSPredicate predicateWithFormat:@"%K < %@",
                                      VOK_CDSELECTOR(numberOfHats), @(50)];
    [manager deleteAllObjectsOfClass:[VIThing class]
                   matchingPredicate:lessThanFiftyHats
                             context:nil];
    
    //should have nothing left
    XCTAssert([manager countForClass:[VIThing class]] == 0);
}

@end
