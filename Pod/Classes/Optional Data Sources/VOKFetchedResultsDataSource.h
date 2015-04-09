//
//  VOKFetchedResultsDataSource.h
//  CoreData
//

#import <UIKit/UIKit.h>

#import "VOKCoreDataManager.h"

@protocol VOKFetchedResultsDataSourceDelegate <NSObject>
@optional
- (void)fetchResultsDataSourceSelectedObject:(NSManagedObject *)object;
- (void)fetchResultsDataSourceDeselectedObject:(NSManagedObject *)object;
- (void)fetchResultsDataSourceHasResults:(BOOL)hasResults;

@end

@interface VOKFetchedResultsDataSource : NSObject <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource> {
    NSFetchedResultsController *_fetchedResultsController;
}

@property (readonly) Class managedObjectClass;
@property (weak, readonly) UITableView *tableView;
@property (weak, readonly) NSManagedObjectContext *managedObjectContext;

@property (weak) id <VOKFetchedResultsDataSourceDelegate> delegate;

//these are exposed to handle reconfiguration of the protected _fetchedResultsController, when they change
@property (assign, nonatomic) NSInteger batchSize;
@property (assign, nonatomic) NSInteger fetchLimit;

@property (weak, nonatomic) NSPredicate *predicate;
@property (weak, nonatomic) NSArray *sortDescriptors;

@property (nonatomic) BOOL includesSubentities;

//whether to deselect the selected cell of the table view
//after sending the selected object to the delegate
//defaults to YES
@property BOOL clearsTableViewCellSelection;

//you can ignore deprecation warnings in subclasses
@property (strong, readonly) NSFetchedResultsController *fetchedResultsController;

- (NSArray *)fetchedObjects;

- (void)reloadData;

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
              tableView:(UITableView *)tableView
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass;

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
              tableView:(UITableView *)tableView
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
              batchSize:(NSInteger)batchSize;

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
              tableView:(UITableView *)tableView
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
               delegate:(id <VOKFetchedResultsDataSourceDelegate>)delegate;

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
              tableView:(UITableView *)tableView
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
              batchSize:(NSInteger)batchSize
               delegate:(id <VOKFetchedResultsDataSourceDelegate>)delegate;

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
              tableView:(UITableView *)tableView
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
              batchSize:(NSInteger)batchSize
             fetchLimit:(NSInteger)fetchLimit
               delegate:(id <VOKFetchedResultsDataSourceDelegate>)delegate;

- (UITableViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath;

@end
