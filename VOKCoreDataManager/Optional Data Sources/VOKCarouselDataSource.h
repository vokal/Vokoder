//
//  VICollectionDataSource.h
//  Changes
//
//  Created by teejay on 5/6/13.
//  Copyright (c) 2013 teejay. All rights reserved.
//

#import "VOKFetchedResultsDataSource.h"
#import "iCarousel.h"

@interface VOKCarouselDataSource : VOKFetchedResultsDataSource <iCarouselDataSource, iCarouselDelegate>

@property (strong, readonly) NSFetchedResultsController *fetchedResultsController;

@property (weak) iCarousel *carousel;

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
               carousel:(iCarousel *)carousel
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass;

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
               carousel:(iCarousel *)carousel
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
              batchSize:(NSInteger)batchSize;

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
               carousel:(iCarousel *)carousel
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
               delegate:(id <VOKFetchedResultsDataSourceDelegate>)delegate;

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
               carousel:(iCarousel *)carousel
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
              batchSize:(NSInteger)batchSize
               delegate:(id <VOKFetchedResultsDataSourceDelegate>)delegate;

@end
