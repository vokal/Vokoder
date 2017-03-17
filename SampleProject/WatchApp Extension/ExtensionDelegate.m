//
//  ExtensionDelegate.m
//  WatchApp Extension
//
//  Created by Ellen Shapiro (Work) on 3/15/17.
//  Copyright © 2017 Vokal. All rights reserved.
//

#import "ExtensionDelegate.h"

#import <Vokoder/VOKCoreDataManager.h>

@implementation ExtensionDelegate

- (void)applicationDidFinishLaunching
{
    // Make sure the watch extension compiles and can access Vokoder.
    //
    // NOTE: The Core Data Model has to be added to the WatchKit extension since the
    // extension can't access the app's main bundle since it's running in a different process.
    // This data store will be stored with the WatchKit extension, NOT shared with the main app.
    //
    // ALSO NOTE: Both of these issues are moot use a shared container instead. 
    [[VOKCoreDataManager sharedInstance] setResource:@"VOKCoreDataModel" database:@"VOKCoreDataModel.sqlite"];
}

@end
