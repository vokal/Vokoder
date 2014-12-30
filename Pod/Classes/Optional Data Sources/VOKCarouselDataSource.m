//
//  VICollectionDataSource.m
//  Changes
//
//  Created by teejay on 5/6/13.
//  Copyright (c) 2013 teejay. All rights reserved.
//

#import "VOKCarouselDataSource.h"

#import "VOKCoreDataManagerInternalMacros.h"

@implementation VOKCarouselDataSource

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
               carousel:(iCarousel *)carousel
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
              batchSize:(NSInteger)batchSize
               delegate:(id <VOKFetchedResultsDataSourceDelegate>)delegate
{


    self = [super initWithPredicate:predicate
                                cacheName:cacheName
                                tableView:nil
                       sectionNameKeyPath:sectionNameKeyPath
                          sortDescriptors:sortDescriptors
                       managedObjectClass:managedObjectClass
                                 delegate:delegate];
    if (self) {
        _carousel = carousel;
        _carousel.delegate = self;
        _carousel.dataSource = self;
    }
    
    
    return self;
}

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
               carousel:(iCarousel *)carousel
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
               delegate:(id <VOKFetchedResultsDataSourceDelegate>)delegate
{
    return [self initWithPredicate:predicate
                         cacheName:cacheName
                          carousel:carousel
                sectionNameKeyPath:sectionNameKeyPath
                   sortDescriptors:sortDescriptors
                managedObjectClass:managedObjectClass
                         batchSize:20
                          delegate:delegate];
}

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
               carousel:(iCarousel *)carousel
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
{
    return [self initWithPredicate:predicate
                         cacheName:cacheName
                          carousel:carousel
                sectionNameKeyPath:sectionNameKeyPath
                   sortDescriptors:sortDescriptors
                managedObjectClass:managedObjectClass
                         batchSize:20];
}

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
               carousel:(iCarousel *)carousel
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
              batchSize:(NSInteger)batchSize
{
    return [self initWithPredicate:predicate
                         cacheName:cacheName
                          carousel:carousel
                sectionNameKeyPath:sectionNameKeyPath
                   sortDescriptors:sortDescriptors
                managedObjectClass:managedObjectClass
                          delegate:nil];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    return [super fetchedResultsController];
}

#pragma mark - UICollectionVIew

- (void)reloadData
{
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        VOK_CDLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    //FOR REVIEW controllerWillChangeContent is not being called in tests - this updates the table explicitly
    [self.carousel reloadData];
}

#pragma mark - Fetched results controller

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    [self.carousel reloadData];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.carousel insertItemAtIndex:newIndexPath.row animated:YES];
            break;
        case NSFetchedResultsChangeDelete:
            [self.carousel removeItemAtIndex:newIndexPath.row animated:YES];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.carousel reloadData];
            break;
        case NSFetchedResultsChangeMove:
            [self.carousel reloadData];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.carousel reloadData];
}

#pragma mark Carousel Methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return [self.fetchedObjects count];
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    
    //create new view if no view is available for recycling
    if (view == nil) {
        view = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 275.0f, 300.0f)];
        ((UIImageView *)view).image = [UIImage imageNamed:@"page.png"];
        [view setContentMode:UIViewContentModeScaleAspectFill];
        
        label = [[UILabel alloc] initWithFrame:view.bounds];
        label.backgroundColor = [UIColor clearColor];
        label.font = [label.font fontWithSize:50];
        label.tag = 1;
        [view addSubview:label];
    } else {
        //get a reference to the label in the recycled view
        label = (UILabel *)[view viewWithTag:1];
    }
    
    
    //set item label
    //remember to always set any properties of your carousel item
    //views outside of the `if (view == nil) {...}` check otherwise
    //you'll get weird issues with carousel item content appearing
    //in the wrong place in the carousel
    label.text = [(self.fetchedObjects)[index] stringValue];
    
    return view;
}

@end
