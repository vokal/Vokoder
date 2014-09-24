//
//  VIViewController.m
//  CoreData
//

#import "VIPagingViewController.h"
#import "VOKCoreDataManager.h"
#import "VIPlayer.h"
#import "NSManagedObject+VOKManagedObjectAdditions.h"

@implementation VIPagingViewController

- (void)loadView
{
    [super loadView];

    UIBarButtonItem *deleteSomeStuffButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                                           target:self
                                                                                           action:@selector(wipeData)];
    UIBarButtonItem *addSomeStuffButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                           target:self
                                                                                           action:@selector(loadData)];
    
    UIBarButtonItem *removeTableButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                        target:self
                                                                                        action:@selector(removeTable)];


    self.navigationItem.rightBarButtonItems = @[deleteSomeStuffButton, addSomeStuffButton, removeTableButton];

    [[VOKCoreDataManager sharedInstance] resetCoreData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setupDataSource];
}

- (void)removeTable
{
    [self.tableView removeFromSuperview];
    self.tableView = nil;
    self.dataSource = nil;
    
}

- (void)setupDataSource
{
    [VIPlayer setupMaps];
    
    NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"cHighscore" ascending:NO]];

    self.dataSource = [[VIPlayerDataSource alloc] initWithPredicate:nil
                                                          cacheName:nil
                                                          tableView:self.tableView
                                                 sectionNameKeyPath:nil
                                                    sortDescriptors:sortDescriptors
                                                managedObjectClass:[VIPlayer class]];
    
    [self.dataSource setupForTriggerDistance:60 upAction:^(UITableView *tableView, VICompletionAction fetchCompleted) {
        //Normally this wait would be waiting on an API call.
        
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //Call our finish method to notify accessory views
            [self loadHigherScores];
            
            if (fetchCompleted) {
                fetchCompleted();
            }
        });
    } headerView:nil downAction:^(UITableView *tableView, VICompletionAction fetchCompleted) {
        //Normally this wait would actually be an API call.
        
        double delayInSeconds = 3.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //Call our finish method to notify accessory views
            [self loadLowerScores];
            
            if (fetchCompleted) {
                fetchCompleted();
            }
            
        });
    } footerView:nil];
}

- (void)wipeData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSManagedObjectContext *tempContext = [[VOKCoreDataManager sharedInstance] temporaryContext];
        NSArray *playerArray = [VIPlayer vok_fetchAllForPredicate:nil forManagedObjectContext:tempContext];
        [playerArray enumerateObjectsUsingBlock:^(VIPlayer *obj, NSUInteger idx, BOOL *stop) {
            [tempContext deleteObject:obj];
        }];
        [[VOKCoreDataManager sharedInstance] saveAndMergeWithMainContext:tempContext];
    });

}

- (void)loadData
{
    //MAKE 20 PEOPLE WITH A CUSTOM MAPPER
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSManagedObjectContext *tempContext = [[VOKCoreDataManager sharedInstance] temporaryContext];
        int j = 0;
        while (j < 21 ) {
            NSLog(@"%@", [VIPlayer vok_addWithDictionary:[self randomInitializeDict] forManagedObjectContext:tempContext]);
            j++;
        }
        [[VOKCoreDataManager sharedInstance] saveAndMergeWithMainContext:tempContext];
    });
}

- (void)loadHigherScores
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSManagedObjectContext *tempContext = [[VOKCoreDataManager sharedInstance] temporaryContext];
        int j = 0;
        while (j < 21 ) {
            NSLog(@"%@", [VIPlayer vok_addWithDictionary:[self higherScoreDict] forManagedObjectContext:tempContext]);
            j++;
        }
        [[VOKCoreDataManager sharedInstance] saveAndMergeWithMainContext:tempContext];
    });
}

- (void)loadLowerScores
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        NSManagedObjectContext *tempContext = [[VOKCoreDataManager sharedInstance] temporaryContext];
        int j = 0;
        while (j < 21 ) {
            NSLog(@"%@", [VIPlayer vok_addWithDictionary:[self lowerScoreDict] forManagedObjectContext:tempContext]);
            j++;
        }
        [[VOKCoreDataManager sharedInstance] saveAndMergeWithMainContext:tempContext];
    });
}

#pragma mark - Fake Data Makers

- (NSDictionary *)randomInitializeDict
{
    return @{@"username" :  [self randomString],
             @"highscore" : [self randomScoreBelow:40000 andAbove:30000]};
}

- (NSDictionary *)higherScoreDict
{
    VIPlayer *topPlayer = [[self.dataSource fetchedObjects] firstObject];
    return @{@"username" :  [self randomString],
             @"highscore" : [self randomScoreAbove:[topPlayer.cHighscore integerValue]]};
}

- (NSDictionary *)lowerScoreDict
{
    VIPlayer *bottomBitch = [[self.dataSource fetchedObjects] lastObject];
    return @{@"username" :  [self randomString],
             @"highscore" : [self randomScoreBelow:[bottomBitch.cHighscore integerValue]]};
}

- (NSNumber *)randomScoreAbove:(NSInteger)lowerBound
{
    return @(lowerBound + (arc4random() % 1000));
}

- (NSNumber *)randomScoreBelow:(NSInteger)upperBound
{
    return @((upperBound - 1000) + (arc4random() % 1000));
}

- (NSNumber *)randomScoreBelow:(NSInteger)upperBound
                      andAbove:(NSInteger)lowerBound
{
    return @(lowerBound + (arc4random() % (upperBound-lowerBound)));
}

- (NSString *)randomString
{
    NSInteger numberOfChars = 7;
    char data[numberOfChars];
    for (int x = 0; x < numberOfChars; data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:numberOfChars encoding:NSUTF8StringEncoding];
}

@end
