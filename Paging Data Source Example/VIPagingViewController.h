//
//  VIViewController.h
//  CoreData
//

#import <UIKit/UIKit.h>

#import "VIPlayerDataSource.h"

@interface VIPagingViewController : UITableViewController

@property (strong, nonatomic) VIPlayerDataSource *dataSource;

@end

