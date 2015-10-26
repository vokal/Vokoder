//
//  VOKViewController.h
//  CoreData
//

#import <UIKit/UIKit.h>

#import "VOKPlayerDataSource.h"

@interface VOKPagingViewController : UITableViewController

@property (strong, nonatomic) VOKPlayerDataSource *dataSource;

@end

