//
//  VIAppDelegate.m
//  CoreData
//
//  Created by Anthony Alesia on 7/26/12.
//  Copyright © 2012 Vokal. All rights reserved.
//

#import "VIAppDelegate.h"

#import "VIViewController.h"
#import "VOKCoreDataManager.h"

@implementation VIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[VOKCoreDataManager sharedInstance] setResource:@"VICoreDataModel" database:@"VICoreDataModel.sqlite"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    VIViewController *viewController = [[VIViewController alloc] initWithStyle:UITableViewStylePlain];
    self.navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
