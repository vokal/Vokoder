//
//  VOKFetchedResultsDataSource.m
//  CoreData
//

#import "VOKFetchedResultsDataSource.h"
#import "VOKCoreDataManager.h"
#import "VOKCoreDataManagerInternalMacros.h"

@interface VOKFetchedResultsDataSource ()

@property NSString *sectionNameKeyPath;
@property NSString *cacheName;

@end

@implementation VOKFetchedResultsDataSource

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
              tableView:(UITableView *)tableView
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
              batchSize:(NSInteger)batchSize
             fetchLimit:(NSInteger)fetchLimit
               delegate:(id <VOKFetchedResultsDataSourceDelegate>)delegate
{
    self = [super init];

    if (self) {
        _managedObjectContext = [[VOKCoreDataManager sharedInstance] managedObjectContext];
        _predicate = predicate;
        _sortDescriptors = sortDescriptors;
        _managedObjectClass = managedObjectClass;
        _sectionNameKeyPath = sectionNameKeyPath;
        _cacheName = cacheName;
        _tableView = tableView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _batchSize = batchSize;
        _fetchLimit = fetchLimit;
        _includesSubentities = YES;
        _delegate = delegate;
        
        _clearsTableViewCellSelection = YES;
        
        [self initFetchedResultsController];
    }

    return self;
}

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
              tableView:(UITableView *)tableView
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
              batchSize:(NSInteger)batchSize
               delegate:(id <VOKFetchedResultsDataSourceDelegate>)delegate
{
    
    return [self initWithPredicate:predicate
                         cacheName:cacheName
                         tableView:tableView
                sectionNameKeyPath:sectionNameKeyPath
                   sortDescriptors:sortDescriptors
                managedObjectClass:managedObjectClass
                         batchSize:batchSize
                        fetchLimit:0
                          delegate:delegate];
}

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
              tableView:(UITableView *)tableView
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
              batchSize:(NSInteger)batchSize
{
    return [self initWithPredicate:predicate
                         cacheName:cacheName
                         tableView:tableView
                sectionNameKeyPath:sectionNameKeyPath
                   sortDescriptors:sortDescriptors
                managedObjectClass:managedObjectClass
                         batchSize:batchSize
                          delegate:nil];
}

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
              tableView:(UITableView *)tableView
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
               delegate:(id <VOKFetchedResultsDataSourceDelegate>)delegate
{
    return [self initWithPredicate:predicate
                         cacheName:cacheName
                         tableView:tableView
                sectionNameKeyPath:sectionNameKeyPath
                   sortDescriptors:sortDescriptors
                managedObjectClass:managedObjectClass
                         batchSize:20
                          delegate:delegate];
}

- (void)setSortDescriptors:(NSArray *)sortDescriptors
{
    if (_sortDescriptors != sortDescriptors) {
        _sortDescriptors = sortDescriptors;
        [self initFetchedResultsController];
    }
}

- (void)setPredicate:(NSPredicate *)predicate
{
    if (_predicate != predicate) {
        _predicate = predicate;
        [self initFetchedResultsController];
    }
}

- (void)setBatchSize:(NSInteger)batchSize
{
    if (_batchSize != batchSize) {
        _batchSize = batchSize;
        [self initFetchedResultsController];
    }
}

- (void)setIncludesSubentities:(BOOL)includesSubentities
{
    if (_includesSubentities != includesSubentities) {
        _includesSubentities = includesSubentities;
        [self initFetchedResultsController];
    }
}

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
              tableView:(UITableView *)tableView
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
{
    return [self initWithPredicate:predicate
                         cacheName:cacheName
                         tableView:tableView
                sectionNameKeyPath:sectionNameKeyPath
                   sortDescriptors:sortDescriptors
                managedObjectClass:managedObjectClass
                         batchSize:20];
}

#pragma mark - Instance Methods

- (void)reloadFetchedResults:(NSNotification *)note
{
    VOK_CDLog(@"NSNotification: Underlying data changed ... refreshing!");
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        VOK_CDLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

- (void)reloadData
{
    NSError *error = nil;
    if (![_fetchedResultsController performFetch:&error]) {
        VOK_CDLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    //FOR TESTING ONLY, NOT NECESSARY
    [_tableView reloadData];
}

- (NSArray *)fetchedObjects
{
//    NSError *error = nil;
//    if (![_fetchedResultsController performFetch:&error]) {
//        VOK_CDLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
   return _fetchedResultsController.fetchedObjects;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(fetchResultsDataSourceSelectedObject:)]) {
        [_delegate fetchResultsDataSourceSelectedObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
    }

    if (self.clearsTableViewCellSelection) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_delegate respondsToSelector:@selector(fetchResultsDataSourceDeselectedObject:)]) {
        [_delegate fetchResultsDataSourceDeselectedObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [_fetchedResultsController sections][section];

    if ([_delegate respondsToSelector:@selector(fetchResultsDataSourceHasResults:)]) {
        [_delegate fetchResultsDataSourceHasResults:([sectionInfo numberOfObjects] > 0)];
    }

    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self cellAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController) {
        [self initFetchedResultsController];
    }

    return _fetchedResultsController;
}

- (void)initFetchedResultsController
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[_managedObjectClass vok_entityName]
                                              inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    [fetchRequest setFetchBatchSize:_batchSize];
    
    [fetchRequest setFetchLimit:_fetchLimit];

    [fetchRequest setSortDescriptors:_sortDescriptors];

    [fetchRequest setPredicate:_predicate];
    
    [fetchRequest setIncludesSubentities:_includesSubentities];

    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:_managedObjectContext
                                                                                                  sectionNameKeyPath:_sectionNameKeyPath
                                                                                                           cacheName:_cacheName];
    aFetchedResultsController.delegate = self;
    
    _fetchedResultsController = aFetchedResultsController;
    
    [self reloadData];

}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [_tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [_tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        default:
            //Do nothing, shut up the compiler.
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [_tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate:
            [_tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
            break;

        case NSFetchedResultsChangeMove:
            [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [_tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [_tableView endUpdates];
}

- (UITableViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";

    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    return cell;
}

- (void)dealloc
{
    if (self.tableView.delegate == self) {
        self.tableView.delegate = nil;
    }
    
    if (self.tableView.dataSource == self) {
         self.tableView.dataSource = nil;
    }
    
}

@end
