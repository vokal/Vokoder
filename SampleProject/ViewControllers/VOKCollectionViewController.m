//
//  VOKCollectionViewController.m
//  Vokoder Sample Project
//
//  Copyright © 2015 Vokal.
//

#import "VOKCollectionViewController.h"
#import "UIViewController+VOKConvenience.h"
#import "VOKPersonCollectionDataSource.h"

@interface VOKCollectionViewController ()

@property (strong, nonatomic) VOKPersonCollectionDataSource *dataSource;

@end

@implementation VOKCollectionViewController

static NSString *resuseIdentifier;

- (instancetype)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(150.0, 50.0);
    return [self initWithCollectionViewLayout:layout];
}

- (void)loadView
{
    [super loadView];
    [self setupCustomMapper];
    [self layoutNavBarButtons];
    [self setupDataSource];
}

- (void)setupDataSource
{
    self.dataSource = [[VOKPersonCollectionDataSource alloc] initWithPredicate:nil
                                                                     cacheName:nil
                                                                collectionView:self.collectionView
                                                            sectionNameKeyPath:nil
                                                               sortDescriptors:self.sortDescriptors
                                                            managedObjectClass:self.demoClassToLoad];
}

@end
