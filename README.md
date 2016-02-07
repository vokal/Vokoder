# Vokoder

[![CI Status](https://travis-ci.org/vokal/Vokoder.svg?branch=master)](https://travis-ci.org/vokal/Vokoder)
[![Version](https://img.shields.io/cocoapods/v/Vokoder.svg?style=flat)](http://cocoadocs.org/docsets/Vokoder)
[![License](https://img.shields.io/cocoapods/l/Vokoder.svg?style=flat)](http://cocoadocs.org/docsets/Vokoder)
[![Platform](https://img.shields.io/cocoapods/p/Vokoder.svg?style=flat)](http://cocoadocs.org/docsets/Vokoder)

![](logo/Vokoder500.png)

A lightweight core data stack with efficient importing and exporting on the side.

## Installation

Vokoder is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "Vokoder"

If you intend to use Vokoder in Swift, use the `Swift` subspec instead:

    pod "Vokoder/Swift"

Vokoder requires Xcode 5.1 or higher.  The unit tests require features found in Xcode 6 and higher.  The Swift extensions require Swift 2 and Xcode 7.

## Subspecs

The bulk of the functionality is in the `Core` subspec.  If you aren't using any of the data sources, you can just include the `Core` subspec.

Data sources to facilitate backing various kinds of views with data from Core Data are in the `DataSources` subspec, which is further broken down into:
- `FetchedResults` contains a basic data source based on a fetched results controller, intended to be used with a `UITableView`.
- `PagingFetchedResults` is based on `FetchedResults` but supports paged loading.
- `Collection` is based on `FetchedResults`, but intended for use with a `UICollectionView`.

The optional `Swift` subspec includes some Swift extensions for strong typing and cleaner syntax.  It is recommended to use this subspec if you intend to use Vokoder in Swift.  This subspec includes all of the other subspecs.

Macros to help create managed object property maps for importing and exporting are included in the `MapperMacros` subspec.  This subspec is included by default, but excluded from the `Swfit` subspec, since the macros are only usable from Objective-C code.

##Usage

###Setting up the data model

```objective-c
[[VOKCoreDataManager sharedInstance] setResource:@"VOKCoreDataModel" database:@"VOKCoreDataModel.sqlite"]; //Saved to Disk
```
or

```objective-c
[[VOKCoreDataManager sharedInstance] setResource:@"VOKCoreDataModel" database:nil]; //In memory data store
```

###Using Vokoder's Mapper

Vokoder offers a lightweight mapper for importing Foundation objects into Core Data. Arrays of dictionaries can be imported with ease once maps are set up. If no maps are provided Vokoder will use its default maps. The default maps assume that foreign keys have the same names as your core data attributes. It will make its best effort to identify dates and numbers.

Setting up your own maps is recommended. Macros are provided to make it fun and easy. Below is an example of setting up a mapper for a managed object subclass `VOKPerson`. Mappers are not persisted between app launches, so be sure to setup your maps every time your application starts.

```objective-c
// A date formatter will enable Vokoder to turn strings into NSDates
NSDateFormatter *dateFormatter = [NSDateFormatter someCustomDateFormatter];
// A number formatter will do the same, turning strings into NSNumbers
NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
NSArray *maps = @[
                  VOKMapForeignToLocalClassProperty(@"first_name", VOKPerson, firstName), //the first argument is the foreign key,
                  VOKMapForeignToLocalClassProperty(@"last_name", VOKPerson, lastName),   //second argument is the class, and then local property
                  VOKMapForeignToLocalClassProperty(@"ss_num", VOKPerson, socialSecurityNumber),
                  [VOKManagedObjectMap mapWithForeignKeyPath:@"salary"
                                                 coreDataKey:VOKKeyForInstanceOf(VOKPerson, salary)
                                             numberFormatter:numberFormatter],
                  [VOKManagedObjectMap mapWithForeignKeyPath:@"dob"
                                                 coreDataKey:VOKKeyForInstanceOf(VOKPerson, dateOfBirth)
                                               dateFormatter:dateFormatter],
                  ];
// The VOKKeyForInstanceOf(...) macro will prevent you from specifying a property that does not exist on a specific class.
// The unique key is an NSString to uniquely identify local entities. If nil, each import can create duplicate objects.
VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:VOKKeyForInstanceOf(VOKPerson, ticketNumber)
                                                                     andMaps:maps];
// By default, missing parameters and null parameters in the import data will nil out an attribute's value
// With ignoreNullValueOverwrites set to YES, the maps will leave existing attributes alone unless new data is provided.
mapper.ignoreNullValueOverwrites = YES;
// By default, Vokoder will complain about every single parameter that can't be set.
// With ignoreOptionalNullValues set to YES, Vokoder will not warn about mismatched classes or null/nil values.
mapper.ignoreOptionalNullValues = YES;
// Set the mapper and Vokoder will handle the rest.
[[VOKCoreDataManager sharedInstance] setObjectMapper:mapper
                                            forClass:[VOKPerson class]];
```

Once the mapper is set Vokoder can turn Foundation objects in to managed objects and then back again to Foundation objects.

####VOKMappableModel
Vokoder includes the `VOKMappableModel` protocol, which gives a structure for a model class to specify how it should be mapped.  Any classes that declare themselves to conform to `VOKMappableModel` will automatically have mappers created based on the protocol methods and registered with the shared instance of `VOKCoreDataManager`.

The `VOKMappableModel` protocol requires implementing `+ (NSString *)uniqueKey` and `+ (NSArray *)coreDataMaps`, which should return the two parameters passed to `[VOKManagedObjectMapper mapperWithUniqueKey:andMaps:]` in the example in the section above.  Optionally, `+ (BOOL)ignoreNullValueOverwrites`, `+ (BOOL)ignoreOptionalNullValues`, and `+ (VOKPostImportBlock)importCompletionBlock` can each be implemented to set the ignore values on the mapper or to set a post-import block.

The mapper constructed in the example in the section above could be included in `SomeManagedObjectSubclass` by making it conform to `VOKMappableModel`:

```objective-c
@interface SomeManagedObjectSubclass : NSManagedObject <VOKMappableModel>
…
@end

@implementation SomeManagedObjectSubclass
…
#pragma mark - VOKMappableModel

+ (NSArray *)coreDataMaps
{
    // A date formatter will enable Vokoder to turn strings into NSDates
    NSDateFormatter *dateFormatter = [NSDateFormatter someCustomDateFormatter];
    // A number formatter will do the same, turning strings into NSNumbers
    NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
    return = @[
               VOKMapForeignToLocalClassProperty(@"first_name", SomeManagedObjectSubclass, firstName),
               VOKMapForeignToLocalClassProperty(@"last_name", SomeManagedObjectSubclass, lastName),
               VOKMapForeignToLocalClassProperty(@"ss_num", SomeManagedObjectSubclass, socialSecurityNumber),
               [VOKManagedObjectMap mapWithForeignKeyPath:@"salary"
                                              coreDataKey:VOKKeyForInstanceOf(SomeManagedObjectSubclass, salary)
                                          numberFormatter:numberFormatter],
               [VOKManagedObjectMap mapWithForeignKeyPath:@"dob"
                                              coreDataKey:VOKKeyForInstanceOf(SomeManagedObjectSubclass, dateOfBirth)
                                            dateFormatter:dateFormatter],
               ];
}

+ (NSString *)uniqueKey
{
  // The VOKKeyForInstanceOf(...) macro will prevent you from specifying a property that does not exist on a specific class.
	// The unique key is an NSString to uniquely identify local entities. If nil each import can create duplicate objects.
	return VOKKeyForInstanceOf(SomeManagedObjectSubclass, ticketNumber);
}

+ (BOOL)ignoreNullValueOverwrites
{
	// By default, missing parameters and null parameters in the import data will nil out an attribute's value
	// With ignoreNullValueOverwrites set to YES, the maps will leave set attributes alone unless new data is provided.
	return YES;
}

+ (BOOL)ignoreOptionalNullValues
{
	// By default Vokoder will complain about every single parameter that can't be set
	// With ignoreOptionalNullValues set to YES Vokoder will not warn about mismatched classes or null/nil values
	return YES;
}
…
@end
```

###Importing Safely

Vokoder offers many ways to get data into Core Data. The simplest and most approachable interface is offered through the VOKManagedObjectAdditions category. Given an array of dictionaries Vokoder will create or edit managed objects on a background queue and then safely return managed objects to the main queue through the completion block.

```objective-c
[SomeManagedObjectSubclass vok_addWithArrayInBackground:importArray
                                             completion:^(NSArray *arrayOfManagedObjects) {
                                                // This completion block runs on the main queue
                                                SomeManagedObjectSubclass *obj = arrayOfManagedObjects[0];
                                             }];

```

For more control over background operations the VOKCoreDataManager class offers more generic methods. Vokoder can handle queues and provide a temporary context without automatically importing or returning anything. 

```objective-c
+ (void)writeToTemporaryContext:(VOKWriteBlock)writeBlock completion:(void (^)(void))completion;
```

Finally, for those that want full control, feel free to make your own temporary contexts on your own background queue. As long as you use a temporary context for background operations Vokoder will let you go your own way.

```objective-c
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
    NSManagedObjectContext *backgroundContext = [[VOKCoreDataManager sharedInstance] temporaryContext];
        
    SomeManagedObjectSubclass *thing = [SomeManagedObjectSubclass vok_newInstanceWithContext:backgroundContext];
	thing.someArbitrayAttribute = @"hello";
    [[VOKCoreDataManager sharedInstance] saveAndMergeWithMainContext:backgroundContext];
});
```

###Inserting records

```objective-c
VOKPerson *person = [VOKPerson vok_newInstance];
[person setFirstName:@"Rohan"];
[person setLastName:@"Panchal"];
[[VOKCoreDataManager sharedInstance] saveMainContextAndWait];
```

###Querying Records	

####Query with basic predicate
```objective-c
NSArray *results = [VOKPerson vok_fetchAllForPredicate:nil forManagedObjectContext:nil]; //Basic Fetch
```

####Query with basic predicate and sorting
```objective-c
NSArray *results = [VOKPerson vok_fetchAllForPredicate:nil
                                           sortedByKey:@"numberOfCats"
                                             ascending:YES
                               forManagedObjectContext:nil];
```

###Deleting records
```objective-c
VOKCoreDataManager *manager = [VOKCoreDataManager sharedInstance];
[manager deleteObject:person];
[[VOKCoreDataManager sharedInstance] saveMainContextAndWait];
```	

###Saving 

```objective-c
[[VOKCoreDataManager sharedInstance] saveMainContextAndWait]; //Saves synchronously
```

## License

Vokoder is available under the MIT license. See the LICENSE file for more info.
