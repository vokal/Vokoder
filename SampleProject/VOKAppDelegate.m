//
//  VOKAppDelegate.m
//  CoreData
//
//  Created by Anthony Alesia on 7/26/12.
//  Copyright (c) 2012 Vokal. All rights reserved.
//

#import "VOKAppDelegate.h"

#import "VOKViewController.h"
#import "VOKCoreDataManager.h"

@implementation VOKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[VOKCoreDataManager sharedInstance] setResource:@"VOKCoreDataModel" database:@"VOKCoreDataModel.sqlite"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    VOKViewController *viewController = [[VOKViewController alloc] initWithStyle:UITableViewStylePlain];
    self.navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
