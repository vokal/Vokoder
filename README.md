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
[[VOKCoreDataManager sharedInstance] setResource:@"VICoreDataModel" database:@"VICoreDataModel.sqlite"];
[[VOKCoreDataManager sharedInstance] setResource:@"VICoreDataModel" database:nil]; //In memory data store
```
    
###Inserting records

```objective-c
VIPerson *person = [VIPerson vok_newInstance];
[person setFirstName:@"Rohan"];
[person setLastName:@"Panchal"];
```

###Querying Records	

```objective-c
NSArray *results = [VIPerson vok_fetchAllForPredicate:nil forManagedObjectContext:nil];
```
	
###Deleting records
```objective-c
VOKCoreDataManager *manager = [VOKCoreDataManager sharedInstance];
[manager deleteObject:person];
```	

###Saving 
```objective-c
[[VOKCoreDataManager sharedInstance] saveMainContextAndWait]; //Saves synchronously
```


## License

Vokoder is available under the MIT license. See the LICENSE file for more info.

