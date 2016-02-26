//
//  VOKFetchedResultsDataSource.m
//  Vokoder
//
//  Copyright © 2015 Vokal.
//

#import "VOKFetchedResultsDataSource.h"
#import "VOKCoreDataManager.h"
#import "VOKCoreDataManagerInternalMacros.h"

@interface VOKFetchedResultsDataSource ()

@property (nonatomic, copy) NSString *sectionNameKeyPath;
@property (nonatomic, copy) NSString *cacheName;

@end

@implementation VOKFetchedResultsDataSource

- (instancetype)initWithPredicate:(NSPredicate *)predicate
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

- (instancetype)initWithPredicate:(NSPredicate *)predicate
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

- (instancetype)initWithPredicate:(NSPredicate *)predicate
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

- (instancetype)initWithPredicate:(NSPredicate *)predicate
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

- (void)setFetchLimit:(NSInteger)fetchLimit
{
    if (_fetchLimit != fetchLimit) {
        _fetchLimit = fetchLimit;
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

- (instancetype)initWithPredicate:(NSPredicate *)predicate
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

- (void)reloadData
{
    NSError *error = nil;
    if (![self reloadData:&error]) {
        NSAssert(NO, @"Unresolved error %@, %@", error, [error userInfo]);
    }
}

- (BOOL)reloadData:(NSError **)error {
    return [self.fetchedResultsController performFetch:error];
}

- (NSArray *)fetchedObjects
{
   return self.fetchedResultsController.fetchedObjects;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(fetchResultsDataSourceSelectedObject:)]) {
        [self.delegate fetchResultsDataSourceSelectedObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }

    if (self.clearsTableViewCellSelection) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(fetchResultsDataSourceDeselectedObject:)]) {
        [self.delegate fetchResultsDataSourceDeselectedObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionCount = self.fetchedResultsController.sections.count;

    // If there are no sections, the numberOfRowsInSection: method is never called,
    // so the delegeate fetchResultsDataSourceHasResults: method isn't called
    // with NO. Do so here, if necessary.
    if (sectionCount == 0 && [self.delegate respondsToSelector:@selector(fetchResultsDataSourceHasResults:)]) {
        [self.delegate fetchResultsDataSourceHasResults:NO];
    }
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];

    // NSFetchedResultsController doesn't really respect fetchLimit, so we have
    // to work around it: don't allow more items than the limit.
    NSInteger resultCount = sectionInfo.numberOfObjects;
    if (self.fetchedResultsController.fetchRequest.fetchLimit > 0
        && resultCount > self.fetchedResultsController.fetchRequest.fetchLimit) {
        resultCount = self.fetchedResultsController.fetchRequest.fetchLimit;
    }

    if ([self.delegate respondsToSelector:@selector(fetchResultsDataSourceHasResults:)]) {
        [self.delegate fetchResultsDataSourceHasResults:(resultCount > 0)];
    }
    return resultCount;
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

- (void)initFetchedResultsController
{
    NSManagedObjectContext *moc = [[VOKCoreDataManager sharedInstance] managedObjectContext];

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[_managedObjectClass vok_entityName]
                                              inManagedObjectContext:moc];
    fetchRequest.entity = entity;
    
    fetchRequest.fetchBatchSize = _batchSize;
    
    fetchRequest.fetchLimit = _fetchLimit;

    fetchRequest.sortDescriptors = _sortDescriptors;

    fetchRequest.predicate = _predicate;
    
    fetchRequest.includesSubentities = _includesSubentities;

    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                                managedObjectContext:moc
                                                                                                  sectionNameKeyPath:_sectionNameKeyPath
                                                                                                           cacheName:_cacheName];
    aFetchedResultsController.delegate = self;
    
    _fetchedResultsController = aFetchedResultsController;
    
    [self reloadData];
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
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
    // NSFetchedResultsController doesn't handle fetchLimit
    // properly, so we need to check index paths against the
    // limit before acting on the change.
    NSUInteger fetchLimit = controller.fetchRequest.fetchLimit;

    switch (type) {
        case NSFetchedResultsChangeInsert:
            if (fetchLimit == 0 || newIndexPath.row < fetchLimit) {
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            break;

        case NSFetchedResultsChangeDelete:
            if (fetchLimit == 0 || indexPath.row < fetchLimit) {
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            break;

        case NSFetchedResultsChangeUpdate:
            if (fetchLimit == 0 || indexPath.row < fetchLimit) {
                [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationNone];
            }
            break;

        case NSFetchedResultsChangeMove:
            if (fetchLimit > 0) {
                if (indexPath.row < fetchLimit && newIndexPath.row < fetchLimit) {
                    // Before and after are both in range
                    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                } else if (indexPath.row >= fetchLimit && newIndexPath.row >= fetchLimit) {
                    // Both out of range: do nothing
                } else if (indexPath.row < fetchLimit && newIndexPath.row >= fetchLimit) {
                    // Destination is out of range: remove the original row
                    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                } else if (indexPath.row >= fetchLimit && newIndexPath.row < fetchLimit) {
                    // Origin is out of range: add the new row
                    [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                }
            } else {
                // No fetch limit: behave normally
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

- (UITableViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";

    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];

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

    self.fetchedResultsController.delegate = nil;
}

@end
