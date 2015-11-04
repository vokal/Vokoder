//
//  VOKFetchedResultsDataSource.h
//  CoreData
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

@property (readonly) Class managedObjectClass;
@property (weak, readonly) UITableView *tableView;
@property (weak, readonly) NSManagedObjectContext *managedObjectContext;

@property (weak) id<VOKFetchedResultsDataSourceDelegate> delegate;

@property (strong, readonly) NSFetchedResultsController *fetchedResultsController;

//these are exposed to handle reconfiguration of the fetchedResultsController when they change
@property (assign, nonatomic) NSInteger batchSize;
@property (assign, nonatomic) NSInteger fetchLimit;

@property (weak, nonatomic) NSPredicate *predicate;
@property (weak, nonatomic) VOKArrayOfSortDescriptors *sortDescriptors;

@property (nonatomic) BOOL includesSubentities;

//whether to deselect the selected cell of the table view
//after sending the selected object to the delegate
//defaults to YES
@property BOOL clearsTableViewCellSelection;

- (nullable VOKArrayOfManagedObjects *)fetchedObjects;

- (void)reloadData;

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

