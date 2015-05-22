# Vokoder

[![CI Status](https://travis-ci.org/vokal/Vokoder.svg?branch=master)](https://travis-ci.org/vokal/Vokoder)
[![Version](https://img.shields.io/cocoapods/v/Vokoder.svg?style=flat)](http://cocoadocs.org/docsets/Vokoder)
[![License](https://img.shields.io/cocoapods/l/Vokoder.svg?style=flat)](http://cocoadocs.org/docsets/Vokoder)
[![Platform](https://img.shields.io/cocoapods/p/Vokoder.svg?style=flat)](http://cocoadocs.org/docsets/Vokoder)

A lightweight core data stack with efficient importing and exporting on the side.

## Installation

Vokoder is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "Vokoder"

## Subspecs

The bulk of the functionality is in the `Core` subspec.  If you aren't using any of the data sources, you can just include the `Core` subspec.

Data sources to facilitate backing various kinds of views with data from Core Data are in the `DataSources` subspec, which is further broken down into:
- `FetchedResults` contains a basic data source based on a fetched results controller, intended to be used with a `UITableView`.
- `PagingFetchedResults` is based on `FetchedResults` but supports paged loading.
- `Collection` is based on `FetchedResults`, but intended for use with a `UICollectionView`.
- `Carousel` (not included by default) is based on `FetchedResults` but intended for use with [iCarousel](https://github.com/nicklockwood/iCarousel) (and hence includes it as a dependency).

##Usage

###Setting up the data model

```objective-c
[[VOKCoreDataManager sharedInstance] setResource:@"VICoreDataModel" database:@"VICoreDataModel.sqlite"]; //Saved to Disk
```
or

```objective-c
[[VOKCoreDataManager sharedInstance] setResource:@"VICoreDataModel" database:nil]; //In memory data store
```

###Using Vokoders Mapper

Vokoder offers a lightweight mapper for importing Foundation objects into Core Data. Arrays of dictionaries can be imported with ease once maps are set up. If no maps are provided Vokoder will use its default maps. The default maps assume that foreign keys have the same names as your core data attributes. It will make its best effort to identify dates and numbers.

Setting up your own maps is recommended. Macros are provided to make it fun and easy. Below is an example of setting up a mapper for an arbitrary managed object subclass. Mappers are not persisted between app launches, so be sure to setup your maps every time your application starts.

```objective-c
// A date formatter will enable Vokoder to turn strings into NSDates
NSDateFormatter *dateFormatter = [NSDateFormatter someCustomDateFormatter];
// A number formatter will do the same, turning strings into NSNumbers
NSNumberFormatter *numberFormatter = [NSNumberFormatter new];
NSArray *maps = @[
                  VOK_MAP_FOREIGN_TO_LOCAL(@"first_name", firstName),   //the first argument is the foreign key
                  VOK_MAP_FOREIGN_TO_LOCAL(@"last_name", lastName),     //the second argument is the local attribute
                  VOK_MAP_FOREIGN_TO_LOCAL(@"ss_num", socialSecurityNumber),
                  [VOKManagedObjectMap mapWithForeignKeyPath:@"salary"
                                                 coreDataKey:VOK_CDSELECTOR(salary)
                                             numberFormatter:numberFormatter],
                  [VOKManagedObjectMap mapWithForeignKeyPath:@"dob"
                                                 coreDataKey:VOK_CDSELECTOR(dateOfBirth)
                                               dateFormatter:dateFormatter],
                  ];
// VOK_CDSELECTOR will prevent you from specifying a nonexistent attribute
// The unique key is an NSString to uniquely identify local entities. If nil each import can create duplicate objects.
VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:VOK_CDSELECTOR(ticketNumber)
                                                                     andMaps:maps];
// By default missing parameters and null parameters in the import data will nil out an attribute's value
// With ignoreNullValueOverwrites set to YES the maps will leave set attributes alone unless new data is provided.
mapper.ignoreNullValueOverwrites = YES;
// By default Vokoder will complain about every single parameter that can't be set
// With ignoreOptionalNullValues set to YES Vokoder will not warn about mismatched classes or null/nil values
mapper.ignoreOptionalNullValues = YES;
// Set the mapper and Vokoder will handle the rest.
[[VOKCoreDataManager sharedInstance] setObjectMapper:mapper
                                            forClass:[SomeManagedObjectSubclass class]];
```

Once the mapper is set Vokoder can turn Foundation objects in to managed objects and then back again to Foundation objects.

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
VIPerson *person = [VIPerson vok_newInstance];
[person setFirstName:@"Rohan"];
[person setLastName:@"Panchal"];
[[VOKCoreDataManager sharedInstance] saveMainContextAndWait];
```

###Querying Records	

####Query with basic predicate
```objective-c
NSArray *results = [VIPerson vok_fetchAllForPredicate:nil forManagedObjectContext:nil]; //Basic Fetch
```

####Query with basic predicate and sorting
```objective-c
NSArray *results = [VIPerson vok_fetchAllForPredicate:nil
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
