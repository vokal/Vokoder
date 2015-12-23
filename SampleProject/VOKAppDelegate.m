//
//  VOKAppDelegate.m
//  Vokoder Sample Project
//
//  Originally created by Anthony Alesia on 7/26/12 for VOKCoreDataManager
//  Copyright © 2016 Vokal.
//

#import "VOKAppDelegate.h"

#import "VOKTableViewController.h"
#import "VOKCollectionViewController.h"
#import "VOKCoreDataManager.h"

@implementation VOKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[VOKCoreDataManager sharedInstance] setResource:@"VOKCoreDataModel" database:@"VOKCoreDataModel.sqlite"];

    [[VOKCoreDataManager sharedInstance] resetCoreData];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

//    UIViewController *viewController = [[VOKTableViewController alloc] initWithStyle:UITableViewStylePlain];
    UIViewController *viewController = [[VOKCollectionViewController alloc] init];
    self.navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
