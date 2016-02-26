//
//  VOKCollectionDataSource.h
//  Vokoder
//
//  Created by teejay on 5/6/13.
//  Copyright © 2013 Vokal.
//

#import "VOKFetchedResultsDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@interface VOKCollectionDataSource : VOKFetchedResultsDataSource <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;

- (instancetype)initWithPredicate:(nullable NSPredicate *)predicate
                        cacheName:(nullable NSString *)cacheName
                   collectionView:(nullable UICollectionView *)collectionView
               sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
                  sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
               managedObjectClass:(Class)managedObjectClass;

- (instancetype)initWithPredicate:(nullable NSPredicate *)predicate
                        cacheName:(nullable NSString *)cacheName
                   collectionView:(nullable UICollectionView *)collectionView
               sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
                  sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
               managedObjectClass:(Class)managedObjectClass
                        batchSize:(NSInteger)batchSize;

- (instancetype)initWithPredicate:(nullable NSPredicate *)predicate
                        cacheName:(nullable NSString *)cacheName
                   collectionView:(nullable UICollectionView *)collectionView
               sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
                  sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
               managedObjectClass:(Class)managedObjectClass
                         delegate:(nullable id <VOKFetchedResultsDataSourceDelegate>)delegate;

- (instancetype)initWithPredicate:(nullable NSPredicate *)predicate
                        cacheName:(nullable NSString *)cacheName
                   collectionView:(nullable UICollectionView *)collectionView
               sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
                  sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
               managedObjectClass:(Class)managedObjectClass
                        batchSize:(NSInteger)batchSize
                         delegate:(nullable id <VOKFetchedResultsDataSourceDelegate>)delegate;

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
