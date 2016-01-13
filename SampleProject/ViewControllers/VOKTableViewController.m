//
//  VOKTableViewController.m
//  Vokoder Sample Project
//
//  Copyright © 2015 Vokal.
//

#import "VOKTableViewController.h"
#import "UIViewController+VOKConvenience.h"
#import "VOKPersonDataSource.h"

@interface VOKTableViewController ()

@property (strong, nonatomic) VOKPersonDataSource *dataSource;

@end

@implementation VOKTableViewController

- (void)loadView
{
    [super loadView];
    [self layoutNavBarButtons];
    [self setupCustomMapper];    
    [self setupDataSource];
}

- (void)setupDataSource
{
    self.dataSource = [[VOKPersonDataSource alloc] initWithPredicate:nil
                                                           cacheName:nil
                                                           tableView:self.tableView
                                                  sectionNameKeyPath:nil
                                                     sortDescriptors:self.sortDescriptors
                                                  managedObjectClass:self.demoClassToLoad];
}

@end
