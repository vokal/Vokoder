//
//  VOKAppDelegate.h
//  CoreData
//
//  Created by Anthony Alesia on 7/26/12.
//  Copyright (c) 2012 Vokal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VOKCoreDataManager.h"

@class VOKViewController;

@interface VOKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navController;

@end