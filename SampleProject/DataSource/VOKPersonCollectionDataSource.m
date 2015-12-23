//
//  VOKPersonCollectionDataSource.m
//  Vokoder Sample Project
//
//  Copyright © 2015 Vokal.
//
#import "VOKPersonCollectionDataSource.h"
#import "VOKCollectionViewCell.h"
#import "VOKPerson.h"

static NSString *CellIdentifier = @"CellIdentifier";

@implementation VOKPersonCollectionDataSource

- (id)initWithPredicate:(NSPredicate *)predicate
              cacheName:(NSString *)cacheName
         collectionView:(UICollectionView *)collectionView
     sectionNameKeyPath:(NSString *)sectionNameKeyPath
        sortDescriptors:(NSArray *)sortDescriptors
     managedObjectClass:(Class)managedObjectClass
{
    self = [self initWithPredicate:predicate
                         cacheName:cacheName
                    collectionView:collectionView
                sectionNameKeyPath:sectionNameKeyPath
                   sortDescriptors:sortDescriptors
                managedObjectClass:managedObjectClass
                         batchSize:20];
    if (self) {
        CellIdentifier = NSStringFromClass(VOKCollectionViewCell.class);
        [collectionView registerNib:[UINib nibWithNibName:CellIdentifier bundle:nil]
           forCellWithReuseIdentifier:CellIdentifier];
    }
    return self;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    VOKPerson *person = [self.fetchedResultsController objectAtIndexPath:indexPath];
    VOKCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier
                                                                            forIndexPath:indexPath];
    [cell layoutWithPerson:person];
    return cell;
}

@end
