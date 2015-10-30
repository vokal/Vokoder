//
//  VIPersonDataSource.m
//  CoreData
//
//  Copyright © 2015 Vokal.
//

#import "VIPersonDataSource.h"
#import "VIPerson.h"

@implementation VIPersonDataSource

- (UITableViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    VIPerson *person = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", person.lastName, person.firstName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Number of cats: %@", person.numberOfCats];

    return cell;
}

@end