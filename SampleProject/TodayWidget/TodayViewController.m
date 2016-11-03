//
//  TodayViewController.m
//  TodayWidget
//
//  Created by Brock Boland on 11/3/16.
//  Copyright © 2016 Vokal. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

#import "VOKCoreDataManager.h"

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Make sure the widget compiles and can access Vokoder. This data store is in the extension,
    // NOT shared with the main app.
    [[VOKCoreDataManager sharedInstance] setResource:@"VOKCoreDataModel" database:@"VOKCoreDataModel.sqlite"];
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler
{
    completionHandler(NCUpdateResultNewData);
}

@end
