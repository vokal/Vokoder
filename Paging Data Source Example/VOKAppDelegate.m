//
//  VOKAppDelegate.m
//  CoreData
//
//  Created by Anthony Alesia on 7/26/12.
//  Copyright (c) 2012 Vokal. All rights reserved.
//

#import "VOKAppDelegate.h"
#import "VOKCoreDataManager.h"
#import "VOKPagingViewController.h"

@implementation VOKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[VOKCoreDataManager sharedInstance] setResource:@"VOKPagingDataModel" database:@"VOKPagingDataModel.sqlite"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    VOKPagingViewController *viewController = [[VOKPagingViewController alloc] initWithStyle:UITableViewStylePlain];
    self.navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    return YES;
}

+ (VOKAppDelegate *)appDelegate
{
    return (VOKAppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
