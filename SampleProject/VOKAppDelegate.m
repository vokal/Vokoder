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
    if (NSClassFromString(@"XCTestCase")) {
        //during unit testing, don't set up Vokoder in the example app
        return YES;
    }
    [[VOKCoreDataManager sharedInstance] setResource:@"VOKCoreDataModel" database:@"VOKCoreDataModel.sqlite"];

    [[VOKCoreDataManager sharedInstance] resetCoreData];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Switch between the table view controller or the collection view controller here
    // if you're interested in working with one or the other.

    //TABLE VIEW
    //VOKTableViewController *viewController = [[VOKTableViewController alloc] initWithStyle:UITableViewStylePlain];

    //COLLECTION VIEW
    VOKCollectionViewController *viewController = [[VOKCollectionViewController alloc] init];

    self.navController = [[UINavigationController alloc] initWithRootViewController:viewController];
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
