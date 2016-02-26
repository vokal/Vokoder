//
//  VOKFetchedResultsDataSource.h
//  Vokoder
//
//  Copyright © 2015 Vokal.
//

#import <UIKit/UIKit.h>

#import "VOKCoreDataManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VOKFetchedResultsDataSourceDelegate <NSObject>
@optional
- (void)fetchResultsDataSourceSelectedObject:(NSManagedObject *)object;
- (void)fetchResultsDataSourceDeselectedObject:(NSManagedObject *)object;
- (void)fetchResultsDataSourceHasResults:(BOOL)hasResults;

@end

@interface VOKFetchedResultsDataSource : NSObject <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign, readonly) Class managedObjectClass;
@property (nonatomic, weak, readonly) UITableView *tableView;

@property (nonatomic, weak) id<VOKFetchedResultsDataSourceDelegate> delegate;

@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;

//these are exposed to handle reconfiguration of the fetchedResultsController when they change
@property (nonatomic, assign) NSInteger batchSize;
@property (nonatomic, assign) NSInteger fetchLimit;

@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, copy) VOKArrayOfSortDescriptors *sortDescriptors;

@property (nonatomic, assign) BOOL includesSubentities;

/**
 Whether to deselect the selected cell of the table view after sending the selected object to the
 delegate. Defaults to YES.
 */
@property BOOL clearsTableViewCellSelection;

- (nullable VOKArrayOfManagedObjects *)fetchedObjects;

- (void)reloadData;
- (BOOL)reloadData:(NSError **)error;

- (id)initWithPredicate:(nullable NSPredicate *)predicate
              cacheName:(nullable NSString *)cacheName
              tableView:(nullable UITableView *)tableView
     sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
        sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass;

- (id)initWithPredicate:(nullable NSPredicate *)predicate
              cacheName:(nullable NSString *)cacheName
              tableView:(nullable UITableView *)tableView
     sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
        sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
              batchSize:(NSInteger)batchSize;

- (id)initWithPredicate:(nullable NSPredicate *)predicate
              cacheName:(nullable NSString *)cacheName
              tableView:(nullable UITableView *)tableView
     sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
        sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
               delegate:(nullable id <VOKFetchedResultsDataSourceDelegate>)delegate;

- (id)initWithPredicate:(nullable NSPredicate *)predicate
              cacheName:(nullable NSString *)cacheName
              tableView:(nullable UITableView *)tableView
     sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
        sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
              batchSize:(NSInteger)batchSize
               delegate:(nullable id <VOKFetchedResultsDataSourceDelegate>)delegate;

- (id)initWithPredicate:(nullable NSPredicate *)predicate
              cacheName:(nullable NSString *)cacheName
              tableView:(nullable UITableView *)tableView
     sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
        sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
              batchSize:(NSInteger)batchSize
             fetchLimit:(NSInteger)fetchLimit
               delegate:(nullable id <VOKFetchedResultsDataSourceDelegate>)delegate;

- (UITableViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END

