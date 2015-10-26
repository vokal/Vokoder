//
//  VOKCollectionDataSource.h
//
//  Created by teejay on 5/6/13.
//  Copyright (c) 2013 Vokal. All rights reserved.
//

#import "VOKFetchedResultsDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface VOKCollectionDataSource : VOKFetchedResultsDataSource <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, readonly) NSFetchedResultsController *fetchedResultsController;

@property (weak) UICollectionView *collectionView;

- (id)initWithPredicate:(nullable NSPredicate *)predicate
              cacheName:(nullable NSString *)cacheName
         collectionView:(nullable UICollectionView *)collectionView
     sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
        sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass;

- (id)initWithPredicate:(nullable NSPredicate *)predicate
              cacheName:(nullable NSString *)cacheName
         collectionView:(nullable UICollectionView *)collectionView
     sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
        sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
              batchSize:(NSInteger)batchSize;

- (id)initWithPredicate:(nullable NSPredicate *)predicate
              cacheName:(nullable NSString *)cacheName
         collectionView:(nullable UICollectionView *)collectionView
     sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
        sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
               delegate:(nullable id <VOKFetchedResultsDataSourceDelegate>)delegate;

- (id)initWithPredicate:(nullable NSPredicate *)predicate
              cacheName:(nullable NSString *)cacheName
         collectionView:(nullable UICollectionView *)collectionView
     sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
        sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
              batchSize:(NSInteger)batchSize
               delegate:(nullable id <VOKFetchedResultsDataSourceDelegate>)delegate;

- (id)initWithPredicate:(nullable NSPredicate *)predicate
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
