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
    //Make sure the widget compiles and can access Vokoder. This data store is in the extension,
    // NOT shared with the main app.
    [[VOKCoreDataManager sharedInstance] setResource:@"VOKCoreDataModel" database:@"VOKCoreDataModel.sqlite"];

}

@end
