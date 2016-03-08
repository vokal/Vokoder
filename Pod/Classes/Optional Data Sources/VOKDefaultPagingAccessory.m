//
//  VOKDefaultPagingAccessory.m
//  PagingCoreData
//
//  Created by teejay on 1/21/14.
//  Copyright © 2014 Vokal.
//

#import "VOKDefaultPagingAccessory.h"

@interface VOKDefaultPagingAccessory ()

@property UIActivityIndicatorView *indicator;

@end

@implementation VOKDefaultPagingAccessory

- (void)didMoveToSuperview
{
    if (self.superview) {
        self.clipsToBounds = YES;
        [self setBackgroundColor:[UIColor clearColor]];
        
        UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){CGPointZero, self.frame.size}];
        [label setText:@"Pull To Load"];
        [label setFont:[UIFont boldSystemFontOfSize:20]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:label];
        [label sizeToFit];
        [label setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
        
        UIActivityIndicatorViewStyle indicatorStyle;
#if TARGET_OS_IOS
        indicatorStyle = UIActivityIndicatorViewStyleGray;
#elif TARGET_OS_TV
        //gray isn't available on tvOS
        indicatorStyle = UIActivityIndicatorViewStyleWhiteLarge;
#endif
        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:indicatorStyle];
        [self.indicator setTintColor:[UIColor blackColor]];
        [self.indicator setHidesWhenStopped:NO];
        
        [self.indicator setCenter:CGPointMake(label.frame.origin.x - self.indicator.frame.size.width, self.frame.size.height/2)];
        [self addSubview:self.indicator];
    }
}

- (void)loadingHasFinished
{
    [self.indicator stopAnimating];
}

- (void)loadingWillBegin
{
    [self.indicator startAnimating];
}

- (void)hasOverScrolled:(CGFloat)overScrollPercent
{
    [self.indicator setAlpha:overScrollPercent];
}

@end
