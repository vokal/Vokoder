//
//  VOKViewController.h
//  CoreData
//
//  Copyright © 2015 Vokal.
//

#import <UIKit/UIKit.h>

#import "VOKPlayerDataSource.h"

@interface VOKPagingViewController : UITableViewController

@property (strong, nonatomic) VOKPlayerDataSource *dataSource;

@end

