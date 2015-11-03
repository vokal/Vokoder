//
//  VOKPersonDataSource.m
//  CoreData
//
//  Copyright © 2015 Vokal.
//

#import "VOKPersonDataSource.h"
#import "VOKPerson.h"

@implementation VOKPersonDataSource

- (UITableViewCell *)cellAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    VOKPerson *person = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", person.lastName, person.firstName];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Number of cats: %@", person.numberOfCats];

    return cell;
}

@end