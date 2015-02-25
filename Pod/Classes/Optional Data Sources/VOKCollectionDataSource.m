//
//  VICollectionDataSource.m
//
//  Created by teejay on 5/6/13.
//  Copyright (c) 2013 Vokal. All rights reserved.
//

#import "VOKCollectionDataSource.h"

#import "VOKCoreDataManager.h"
#import "VOKCoreDataManagerInternalMacros.h"

@interface VOKCollectionDataSource () {
    NSMutableArray *_objectChanges;
    NSMutableArray *_sectionChanges;
}

@end

@implementation VOKCollectionDataSource

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
         collectionView:(UICollectionView *)collectionView
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
              batchSize:(NSInteger)batchSize
             fetchLimit:(NSInteger)fetchLimit
               delegate:(id <VOKFetchedResultsDataSourceDelegate>)delegate
{
    self.collectionView = collectionView;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    _objectChanges = [@[] mutableCopy];
    _sectionChanges = [@[] mutableCopy];

    return [self initWithPredicate:predicate
                         cacheName:cacheName
                         tableView:nil
                sectionNameKeyPath:sectionNameKeyPath
                   sortDescriptors:sortDescriptors
                managedObjectClass:managedObjectClass
                         batchSize:batchSize
                        fetchLimit:fetchLimit
                          delegate:delegate];
}

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
         collectionView:(UICollectionView *)collectionView
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
              batchSize:(NSInteger)batchSize
               delegate:(id <VOKFetchedResultsDataSourceDelegate>)delegate
{
    return [self initWithPredicate:predicate
                         cacheName:cacheName
                    collectionView:collectionView
                sectionNameKeyPath:sectionNameKeyPath
                   sortDescriptors:sortDescriptors
                managedObjectClass:managedObjectClass
                         batchSize:batchSize
                        fetchLimit:0
                          delegate:delegate];
}

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
         collectionView:(UICollectionView *)collectionView
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
               delegate:(id <VOKFetchedResultsDataSourceDelegate>)delegate
{
    return [self initWithPredicate:predicate
                         cacheName:cacheName
                    collectionView:collectionView
                sectionNameKeyPath:sectionNameKeyPath
                   sortDescriptors:sortDescriptors
                managedObjectClass:managedObjectClass
                         batchSize:20
                          delegate:delegate];
}

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
         collectionView:(UICollectionView *)collectionView
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
{
    return [self initWithPredicate:predicate
                         cacheName:cacheName
                    collectionView:collectionView
                sectionNameKeyPath:sectionNameKeyPath
                   sortDescriptors:sortDescriptors
                managedObjectClass:managedObjectClass
                         batchSize:20];
}

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
         collectionView:(UICollectionView *)collectionView
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
              batchSize:(NSInteger)batchSize
{
    return [self initWithPredicate:predicate
                         cacheName:cacheName
                    collectionView:collectionView
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
    if (![_fetchedResultsController performFetch:&error]) {
        VOK_CDLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    //FOR REVIEW controllerWillChangeContent is not being called in tests - this updates the table explicitly
    [_collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger sectionCount = [[self.fetchedResultsController sections] count];

    // If there are no sections, the numberOfItemsInSection: method is never called,
    // so the delegeate fetchResultsDataSourceHasResults: method isn't called
    // with NO. Do so here, if necessary.
    if (sectionCount == 0 && [self.delegate respondsToSelector:@selector(fetchResultsDataSourceHasResults:)]) {
        [self.delegate fetchResultsDataSourceHasResults:NO];
    }
    return sectionCount;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];

    // NSFetchedResultsController doesn't really respect fetchLimit, so we have
    // to work around it: don't allow more items than the limit.
    NSInteger resultCount = [sectionInfo numberOfObjects];
    if (self.fetchedResultsController.fetchRequest.fetchLimit > 0
        && resultCount > self.fetchedResultsController.fetchRequest.fetchLimit) {
        resultCount = self.fetchedResultsController.fetchRequest.fetchLimit;
    }

    if ([self.delegate respondsToSelector:@selector(fetchResultsDataSourceHasResults:)]) {
        [self.delegate fetchResultsDataSourceHasResults:(resultCount > 0)];
    }
    return resultCount;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UICollectionViewCell alloc] init];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(fetchResultsDataSourceSelectedObject:)]) {
        [self.delegate fetchResultsDataSourceSelectedObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(fetchResultsDataSourceDeselectedObject:)]) {
        [self.delegate fetchResultsDataSourceDeselectedObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
}

#pragma mark - Fetched results controller

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = @(sectionIndex);
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = @(sectionIndex);
            break;
        default:
            //Do nothing, shut up the compiler with a default case.
            break;
    }
    
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    NSMutableDictionary *change = [NSMutableDictionary new];
    switch (type) {
        case NSFetchedResultsChangeInsert:
            change[@(type)] = newIndexPath;
            break;
        case NSFetchedResultsChangeDelete:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeUpdate:
            change[@(type)] = indexPath;
            break;
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            break;
    }
    [_objectChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if ([_sectionChanges count] > 0) {
        [self.collectionView performBatchUpdates:^{
            
            for (NSDictionary *change in _sectionChanges) {
                [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                    NSIndexPath *indexPath, *newIndexPath;
                    if ([obj isKindOfClass:[NSIndexPath class]]) {
                        indexPath = obj;
                    } else if ([obj isKindOfClass:[NSArray class]]) {
                        indexPath = obj[0];
                        newIndexPath = obj[1];
                    }

                    // NSFetchedResultsController doesn't handle fetchLimit
                    // properly, so we need to check index paths against the
                    // limit before acting on the change.
                    NSUInteger fetchLimit = controller.fetchRequest.fetchLimit;

                    NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                    switch (type) {
                        case NSFetchedResultsChangeInsert:
                            if (fetchLimit == 0 || indexPath.row < fetchLimit) {
                                [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
                            }
                            break;
                        case NSFetchedResultsChangeDelete:
                            if (fetchLimit == 0 || indexPath.row < fetchLimit) {
                                [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                            }
                            break;
                        case NSFetchedResultsChangeUpdate:
                            if (fetchLimit == 0 || indexPath.row < fetchLimit) {
                                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                            }
                            break;
                        case NSFetchedResultsChangeMove:
                            if (fetchLimit > 0) {
                                if (indexPath.row < fetchLimit && newIndexPath.row < fetchLimit) {
                                    // Before and after are both in range
                                    [self.collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
                                } else if (indexPath.row >= fetchLimit && newIndexPath.row >= fetchLimit) {
                                    // Both out of range: do nothing
                                } else if (indexPath.row < fetchLimit && newIndexPath.row >= fetchLimit) {
                                    // Destination is out of range: remove the original row
                                    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                                } else if  (indexPath.row >= fetchLimit && newIndexPath.row < fetchLimit) {
                                    // Origin is out of range: add the new row
                                    [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
                                }
                            } else {
                                // No fetch limit: behave normally
                                [self.collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
                            }
                            break;
                    }
                }];
            }
        } completion:nil];
    }

    if ([_objectChanges count] > 0 && [_sectionChanges count] == 0) {
        
        if ([self shouldReloadCollectionViewToPreventKnownIssue]) {
            // This is to prevent a bug in UICollectionView from occurring.
            // The bug presents itself when inserting the first object or deleting the last object in a collection view.
            // http://stackoverflow.com/questions/12611292/uicollectionview-assertion-failure
            // This code should be removed once the bug has been fixed, it is tracked in OpenRadar
            // http://openradar.appspot.com/12954582
            [self.collectionView reloadData];

        } else {

            [self.collectionView performBatchUpdates:^{

                for (NSDictionary *change in _objectChanges) {
                    [change enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
                        NSIndexPath *indexPath, *newIndexPath;
                        if ([obj isKindOfClass:[NSIndexPath class]]) {
                            indexPath = obj;
                        } else if ([obj isKindOfClass:[NSArray class]]) {
                            indexPath = obj[0];
                            newIndexPath = obj[1];
                        }

                        // NSFetchedResultsController doesn't handle fetchLimit
                        // properly, so we need to check index paths against the
                        // limit before acting on the change.
                        NSUInteger fetchLimit = controller.fetchRequest.fetchLimit;

                        NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                        switch (type) {
                            case NSFetchedResultsChangeInsert:
                                if (fetchLimit == 0 || indexPath.row < fetchLimit) {
                                    [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
                                }
                                break;
                            case NSFetchedResultsChangeDelete:
                                if (fetchLimit == 0 || indexPath.row < fetchLimit) {
                                    [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                                }
                                break;
                            case NSFetchedResultsChangeUpdate:
                                if (fetchLimit == 0 || indexPath.row < fetchLimit) {
                                    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                                }
                                break;
                            case NSFetchedResultsChangeMove:
                                if (fetchLimit > 0) {
                                    if (indexPath.row < fetchLimit && newIndexPath.row < fetchLimit) {
                                        // Before and after are both in range
                                        [self.collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
                                    } else if (indexPath.row >= fetchLimit && newIndexPath.row >= fetchLimit) {
                                        // Both out of range: do nothing
                                    } else if (indexPath.row < fetchLimit && newIndexPath.row >= fetchLimit) {
                                        // Destination is out of range: remove the original row
                                        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
                                    } else if  (indexPath.row >= fetchLimit && newIndexPath.row < fetchLimit) {
                                        // Origin is out of range: add the new row
                                        [self.collectionView insertItemsAtIndexPaths:@[newIndexPath]];
                                    }
                                } else {
                                    // No fetch limit: behave normally
                                    [self.collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
                                }
                                break;
                        }
                    }];
                }
            } completion:nil];
        }
    }
    
    [_sectionChanges removeAllObjects];
    [_objectChanges removeAllObjects];
}

- (BOOL)shouldReloadCollectionViewToPreventKnownIssue
{
    __block BOOL shouldReload = NO;
    for (NSDictionary *change in _objectChanges) {
        [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSFetchedResultsChangeType type = [key unsignedIntegerValue];
            NSIndexPath *indexPath = obj;
            switch (type) {
                case NSFetchedResultsChangeInsert:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeDelete:
                    if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                        shouldReload = YES;
                    } else {
                        shouldReload = NO;
                    }
                    break;
                case NSFetchedResultsChangeUpdate:
                    shouldReload = NO;
                    break;
                case NSFetchedResultsChangeMove:
                    shouldReload = NO;
                    break;
            }
        }];
    }
    
    return shouldReload;
}

@end
