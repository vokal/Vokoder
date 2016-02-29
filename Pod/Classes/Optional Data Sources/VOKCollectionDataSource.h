//
//  VOKCollectionDataSource.h
//  Vokoder
//
//  Created by teejay on 5/6/13.
//  Copyright © 2013 Vokal.
//

#import "VOKFetchedResultsDataSource.h"

NS_ASSUME_NONNULL_BEGIN

/**
 A generic data source and delegate for collection views, backed by a NSFetchedResultsController.
 This should be subclassed to override the `collectionView:cellForItemAtIndexPath:` method
 from UICollectionViewDataSource.
 */
@interface VOKCollectionDataSource : VOKFetchedResultsDataSource <UICollectionViewDataSource, UICollectionViewDelegate>

/// Collection view in which results are shown. The data source and delegate are set to the newly-created data source.
@property (nonatomic, weak) UICollectionView *collectionView;

/**
 Setup this data source.

 @param predicate          Predicate used to filter the objects displayed
 @param cacheName          Name for the fetched results controller cache
 @param collectionView     Collection view in which results are shown. The data source and delegate are set to the newly-created data source.
 @param sectionNameKeyPath Keypath to use to group results in sections
 @param sortDescriptors    Sort descriptors to sort the objects
 @param managedObjectClass NSManagedObject subclass to fetch

 @return New data source
 */
- (instancetype)initWithPredicate:(nullable NSPredicate *)predicate
                        cacheName:(nullable NSString *)cacheName
                   collectionView:(nullable UICollectionView *)collectionView
               sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
                  sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
               managedObjectClass:(Class)managedObjectClass;

/**
 Setup this data source.

 @param predicate          Predicate used to filter the objects displayed
 @param cacheName          Name for the fetched results controller cache
 @param collectionView     Collection view in which results are shown. The data source and delegate are set to the newly-created data source.
 @param sectionNameKeyPath Keypath to use to group results in sections
 @param sortDescriptors    Sort descriptors to sort the objects
 @param managedObjectClass NSManagedObject subclass to fetch
 @param batchSize          Batch size to use for the fetch request fetchBatchSize. Defaults to 20.

 @return New data source
 */
- (instancetype)initWithPredicate:(nullable NSPredicate *)predicate
                        cacheName:(nullable NSString *)cacheName
                   collectionView:(nullable UICollectionView *)collectionView
               sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
                  sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
               managedObjectClass:(Class)managedObjectClass
                        batchSize:(NSInteger)batchSize;

/**
 Setup this data source.

 @param predicate          Predicate used to filter the objects displayed
 @param cacheName          Name for the fetched results controller cache
 @param collectionView     Collection view in which results are shown. The data source and delegate are set to the newly-created data source.
 @param sectionNameKeyPath Keypath to use to group results in sections
 @param sortDescriptors    Sort descriptors to sort the objects
 @param managedObjectClass NSManagedObject subclass to fetch
 @param delegate           Delegate to notify of cell selection/deselection and whether the fetch has results

 @return New data source
 */
- (instancetype)initWithPredicate:(nullable NSPredicate *)predicate
                        cacheName:(nullable NSString *)cacheName
                   collectionView:(nullable UICollectionView *)collectionView
               sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
                  sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
               managedObjectClass:(Class)managedObjectClass
                         delegate:(nullable id <VOKFetchedResultsDataSourceDelegate>)delegate;

/**
 Setup this data source.

 @param predicate          Predicate used to filter the objects displayed
 @param cacheName          Name for the fetched results controller cache
 @param collectionView     Collection view in which results are shown. The data source and delegate are set to the newly-created data source.
 @param sectionNameKeyPath Keypath to use to group results in sections
 @param sortDescriptors    Sort descriptors to sort the objects
 @param managedObjectClass NSManagedObject subclass to fetch
 @param batchSize          Batch size to use for the fetch request fetchBatchSize. Defaults to 20.
 @param delegate           Delegate to notify of cell selection/deselection and whether the fetch has results

 @return New data source
 */
- (instancetype)initWithPredicate:(nullable NSPredicate *)predicate
                        cacheName:(nullable NSString *)cacheName
                   collectionView:(nullable UICollectionView *)collectionView
               sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
                  sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
               managedObjectClass:(Class)managedObjectClass
                        batchSize:(NSInteger)batchSize
                         delegate:(nullable id <VOKFetchedResultsDataSourceDelegate>)delegate;

/**
 Setup this data source.

 @param predicate          Predicate used to filter the objects displayed
 @param cacheName          Name for the fetched results controller cache
 @param collectionView     Collection view in which results are shown. The data source and delegate are set to the newly-created data source.
 @param sectionNameKeyPath Keypath to use to group results in sections
 @param sortDescriptors    Sort descriptors to sort the objects
 @param managedObjectClass NSManagedObject subclass to fetch
 @param batchSize          Batch size to use for the fetch request fetchBatchSize. Defaults to 20.
 @param fetchLimit         Fetch limit to use for the fetch request fetchLimit. Defaults to 0.
 @param delegate           Delegate to notify of cell selection/deselection and whether the fetch has results

 @return New data source
 */
- (instancetype)initWithPredicate:(nullable NSPredicate *)predicate
                        cacheName:(nullable NSString *)cacheName
                   collectionView:(nullable UICollectionView *)collectionView
               sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
                  sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
               managedObjectClass:(Class)managedObjectClass
                        batchSize:(NSInteger)batchSize
                       fetchLimit:(NSInteger)fetchLimit
                         delegate:(nullable id <VOKFetchedResultsDataSourceDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
