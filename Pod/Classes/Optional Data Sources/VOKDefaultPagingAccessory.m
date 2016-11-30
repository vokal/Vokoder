//
//  VOKDefaultPagingAccessory.m
//  Vokoder
//
//  Created by teejay on 1/21/14.
//  Copyright © 2014 Vokal.
//

#import "VOKDefaultPagingAccessory.h"

@interface VOKDefaultPagingAccessory ()

@property (nonatomic) UIActivityIndicatorView *indicator;

@end

@implementation VOKDefaultPagingAccessory

- (void)didMoveToSuperview
{
    if (self.superview) {
        self.clipsToBounds = YES;
        [self setBackgroundColor:[UIColor clearColor]];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [label setText:@"Pull To Load"];
        [label setFont:[UIFont boldSystemFontOfSize:20]];
        [label sizeToFit];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        
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
        self.indicator.translatesAutoresizingMaskIntoConstraints = NO;
        
        // Wrap the label and activity indicator in a parent view to be collectively centered
        UIView *containerView = [[UIView alloc] init];
        containerView.translatesAutoresizingMaskIntoConstraints = NO;
        [containerView addSubview:self.indicator];
        [containerView addSubview:label];
        [self addSubview:containerView];
        
        // Position the activity indicator and label
        [containerView addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.indicator
                                                         attribute:NSLayoutAttributeLeading
                                                        multiplier:1
                                                          constant:0]];
        [containerView addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                                  attribute:NSLayoutAttributeTrailing
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:label
                                                                  attribute:NSLayoutAttributeTrailing
                                                                 multiplier:1
                                                                   constant:0]];
        // Put a little space between the lable and activity indicator
        [containerView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                  attribute:NSLayoutAttributeLeading
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.indicator
                                                                  attribute:NSLayoutAttributeTrailing
                                                                 multiplier:1
                                                                   constant:20]];

        // Vertically center the indicator and label inside the container
        [containerView addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:containerView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1
                                                                   constant:0]];
        [containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.indicator
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:containerView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1
                                                                   constant:0]];

        // Make the container fill this view, and center it horizontally
        [self addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                         attribute:NSLayoutAttributeTop
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeBottom
                                                        multiplier:1
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1
                                                          constant:0]];
        
        // Don't go too wide
        [self addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                         attribute:NSLayoutAttributeLeading
                                                         relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeLeading
                                                        multiplier:1
                                                          constant:0]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                         attribute:NSLayoutAttributeTrailing
                                                         relatedBy:NSLayoutRelationLessThanOrEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeTrailing
                                                        multiplier:1
                                                          constant:0]];
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
