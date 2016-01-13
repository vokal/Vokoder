//
//  UIViewController+VOKConvenience.h
//  Vokoder Sample Project
//
//  Copyright © 2015 Vokal.
//

#import <UIKit/UIKit.h>

@interface UIViewController (VOKConvenience)

@property (nonatomic, readonly) Class demoClassToLoad;
@property (nonatomic, readonly) NSArray *sortDescriptors;

- (void)layoutNavBarButtons;
- (void)setupCustomMapper;

@end
