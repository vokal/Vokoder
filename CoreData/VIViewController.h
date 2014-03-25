//
//  VIViewController.h
//  CoreData
//

#import <UIKit/UIKit.h>

#import "VIPersonDataSource.h"

@interface VIViewController : UITableViewController
@property (strong, nonatomic) VIPersonDataSource *dataSource;
@end
