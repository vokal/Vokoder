//
//  VOKViewController.h
//  CoreData
//
//  Copyright © 2015 Vokal.
//

#import <UIKit/UIKit.h>

#import "VOKPersonDataSource.h"

@interface VOKViewController : UITableViewController
@property (strong, nonatomic) VOKPersonDataSource *dataSource;

@end
