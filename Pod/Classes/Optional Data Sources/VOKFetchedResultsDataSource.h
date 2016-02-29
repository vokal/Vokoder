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

/**
 Called on the delegate when a cell is selected in the table view.

 @param object Object for the cell that was selected
 */
- (void)fetchResultsDataSourceSelectedObject:(NSManagedObject *)object;

/**
 Called on the delegate when a cell is de-selected in the table view.

 @param object Object for the cell that was de-selected
 */
- (void)fetchResultsDataSourceDeselectedObject:(NSManagedObject *)object;

/**
 Tell the delegate whether or not the fetched results controller found any results. This can be
 called multiple times as the table view is being loaded.

 @param hasResults YES if the table view has results, NO if it's empty
 */
- (void)fetchResultsDataSourceHasResults:(BOOL)hasResults;

@end

/**
 A generic data source and delegate for table views, backed by a NSFetchedResultsController.
 This should be subclassed to override the cellAtIndexPath: method and potentially add convenience initializers.
 */
@interface VOKFetchedResultsDataSource : NSObject <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource>

/// NSManagedObject subclass for which objects should be displayed.
@property (nonatomic, assign, readonly) Class managedObjectClass;

@property (nonatomic, weak, readonly) UITableView *tableView;

/// Delegate to notify of cell selections and whether or not the NSFRC has any results
@property (nonatomic, weak) id<VOKFetchedResultsDataSourceDelegate> delegate;

/// Fetched results controller that's used to supply objects for the table view
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;

/**
 Batch size to use for the fetch request fetchBatchSize. Defaults to 20.
 Changing the value of this property will rebuild the fetched results controller and reload the table view.
 */
@property (nonatomic, assign) NSInteger batchSize;

/**
 Fetch limit to use for the fetch request fetchLimit. Defaults to 0.
 Changing the value of this property will rebuild the fetched results controller and reload the table view.
 */
@property (nonatomic, assign) NSInteger fetchLimit;

/**
 Predicate used to filter the objects fetched by the fetched results controller.
 Changing the value of this property will rebuild the fetched results controller and reload the table view.
 */
@property (nonatomic, strong) NSPredicate *predicate;

/**
 Sort descriptors to sort objects fetched by the fetched results controller.
 Changing the value of this property will rebuild the fetched results controller and reload the table view.
 */
@property (nonatomic, copy) VOKArrayOfSortDescriptors *sortDescriptors;

/**
 Whether or not to include entities of subclasses of the managedObjectClass property. Defaults to YES.
 Changing the value of this property will rebuild the fetched results controller and reload the table view.
 */
@property (nonatomic, assign) BOOL includesSubentities;

/**
 Whether to deselect the selected cell of the table view after sending the selected object to the
 delegate. Defaults to YES.
 */
@property BOOL clearsTableViewCellSelection;

/**
 Accessor for the fetchedObjects array on the fetched results controller

 @return Array of fetched NSManagedObjects
 */
- (nullable VOKArrayOfManagedObjects *)fetchedObjects;

/**
 Reload the fetcehd data in the fetched results controller, which will cause a table view reload.
 */
- (void)reloadData;

/**
 Reload the fetcehd data in the fetched results controller, which will cause a table view reload.
 Optionally passes back the in-out NSError from performFetch:

 @param error Optional pointer to an NSError

 @return YES if the reload was successful, NO otherwise
 */
- (BOOL)reloadData:(NSError **)error;

/**
 Setup this data source.

 @param predicate           Predicate used to filter the objects displayed
 @param cacheName           Name for the fetched results controller cache
 @param tableView           Table view to display in. The data source and delegate are set to the newly-created data source.
 @param sectionNameKeyPath  Keypath to use to group results in sections
 @param sortDescriptors     Sort descriptors to sort the objects
 @param managedObjectClass  NSManagedObject subclass to fetch

 @return New data source
 */
- (instancetype)initWithPredicate:(nullable NSPredicate *)predicate
                        cacheName:(nullable NSString *)cacheName
                        tableView:(nullable UITableView *)tableView
               sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
                  sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
               managedObjectClass:(Class)managedObjectClass;

/**
 Setup this data source.

 @param predicate          Predicate used to filter the objects displayed
 @param cacheName          Name for the fetched results controller cache
 @param tableView          Table view to display in. The data source and delegate are set to the newly-created data source.
 @param sectionNameKeyPath Keypath to use to group results in sections
 @param sortDescriptors    Sort descriptors to sort the objects
 @param managedObjectClass NSManagedObject subclass to fetch
 @param batchSize          Batch size to use for the fetch request fetchBatchSize. Defaults to 20.

 @return New data source
 */
- (instancetype)initWithPredicate:(nullable NSPredicate *)predicate
                        cacheName:(nullable NSString *)cacheName
                        tableView:(nullable UITableView *)tableView
               sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
                  sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
               managedObjectClass:(Class)managedObjectClass
                        batchSize:(NSInteger)batchSize;

/**
  Setup this data source.

 @param predicate          Predicate used to filter the objects displayed
 @param cacheName          Name for the fetched results controller cache
 @param tableView          Table view to display in. The data source and delegate are set to the newly-created data source.
 @param sectionNameKeyPath Keypath to use to group results in sections
 @param sortDescriptors    Sort descriptors to sort the objects
 @param managedObjectClass NSManagedObject subclass to fetch
 @param delegate           Delegate to notify of cell selection/deselection and whether the fetch has results

 @return New data source
 */
- (instancetype)initWithPredicate:(nullable NSPredicate *)predicate
                        cacheName:(nullable NSString *)cacheName
                        tableView:(nullable UITableView *)tableView
               sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
                  sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
               managedObjectClass:(Class)managedObjectClass
                         delegate:(nullable id <VOKFetchedResultsDataSourceDelegate>)delegate;

/**
  Setup this data source.

 @param predicate          Predicate used to filter the objects displayed
 @param cacheName          Name for the fetched results controller cache
 @param tableView          Table view to display in. The data source and delegate are set to the newly-created data source.
 @param sectionNameKeyPath Keypath to use to group results in sections
 @param sortDescriptors    Sort descriptors to sort the objects
 @param managedObjectClass NSManagedObject subclass to fetch
 @param batchSize          Batch size to use for the fetch request fetchBatchSize. Defaults to 20.
 @param delegate           Delegate to notify of cell selection/deselection and whether the fetch has results

 @return New data source
 */
- (instancetype)initWithPredicate:(nullable NSPredicate *)predicate
                        cacheName:(nullable NSString *)cacheName
                        tableView:(nullable UITableView *)tableView
               sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
                  sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
               managedObjectClass:(Class)managedObjectClass
                        batchSize:(NSInteger)batchSize
                         delegate:(nullable id <VOKFetchedResultsDataSourceDelegate>)delegate;

/**
 Setup this data source. Designated initializer. // TODO: make that official

 @param predicate          Predicate used to filter the objects displayed
 @param cacheName          Name for the fetched results controller cache
 @param tableView          Table view to display in. The data source and delegate are set to the newly-created data source.
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
                        tableView:(nullable UITableView *)tableView
               sectionNameKeyPath:(nullable NSString *)sectionNameKeyPath
                  sortDescriptors:(nullable VOKArrayOfSortDescriptors *)sortDescriptors
               managedObjectClass:(Class)managedObjectClass
                        batchSize:(NSInteger)batchSize
                       fetchLimit:(NSInteger)fetchLimit
                         delegate:(nullable id <VOKFetchedResultsDataSourceDelegate>)delegate;

/**
 Provide a cell for the given index path. The default implementation of this method attempts to
 dequeue a cell with the reuse identifier "CellIdentifier" and returns it without any configuration.
 As such, this method should be overridden in all subclasses.

 @param indexPath Index path for which a cell should be returned

 @return Cell for the index path
 */
- (UITableViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END

