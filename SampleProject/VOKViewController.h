//
//  VOKViewController.h
//  CoreData
//

#import <UIKit/UIKit.h>

#import "VOKPersonDataSource.h"

@interface VOKViewController : UITableViewController
@property (strong, nonatomic) VOKPersonDataSource *dataSource;

@end
