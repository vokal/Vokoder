//
//  VIAppDelegate.h
//  CoreData
//
//  Created by Anthony Alesia on 7/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VIPagingViewController;

@interface VIAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navController;

+ (VIAppDelegate *)appDelegate;

@end
