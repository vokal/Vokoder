//
//  VOKPagingFetchedResultsDataSource.m
//  Vokoder
//
//  Created by teejay on 1/21/14.
//  Copyright © 2014 Vokal.
//

#import "VOKPagingFetchedResultsDataSource.h"
#import "VOKDefaultPagingAccessory.h"
#import <VOKUtilities/VOKKeyPathHelper.h>

static CGFloat const DefaultAccessoryHeight = 30;

@interface VOKPagingFetchedResultsDataSource () <UIScrollViewDelegate>

@property (nonatomic, copy) VOKPagingResultsAction upAction;
@property (nonatomic, copy) VOKPagingResultsAction downAction;

@property (nonatomic) UIView<VOKPagingAccessory> *headerView;
@property (nonatomic) UIView<VOKPagingAccessory> *footerView;

@property (nonatomic) BOOL isLoading;
@property (nonatomic) CGFloat triggerDistance;
@property (nonatomic) NSLayoutConstraint *bottomConstraint;
@property (nonatomic) UIEdgeInsets orginalInsets;

@end

@implementation VOKPagingFetchedResultsDataSource

#pragma mark Setup

- (void)setupForTriggerDistance:(CGFloat)overscrollTriggerDistance
                       upAction:(VOKPagingResultsAction)upPageActionOrNil
                     headerView:(UIView<VOKPagingAccessory> *)headerViewOrNil
                     downAction:(VOKPagingResultsAction)downPageActionOrNil
                     footerView:(UIView<VOKPagingAccessory> *)footerViewOrNil;
{
    self.upAction = upPageActionOrNil;
    self.downAction = downPageActionOrNil;

    self.headerView = headerViewOrNil;
    self.footerView = footerViewOrNil;

    self.isLoading = NO;

    self.triggerDistance = overscrollTriggerDistance;
    self.orginalInsets = self.tableView.contentInset;

    [self setupAccessoryViews];
}

- (void)setupAccessoryViews
{
    //Attach given views, or generate default views.
    if (!self.headerView) {
        self.headerView = [[VOKDefaultPagingAccessory alloc] init];
        self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.headerView addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1
                                                                     constant:DefaultAccessoryHeight]];
    }

    self.tableView.tableHeaderView = self.headerView;

    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:1
                                                                constant:0]];
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier:1
                                                                constant:0]];
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.headerView
                                                               attribute:NSLayoutAttributeTop
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeTop
                                                              multiplier:1
                                                                constant:0]];

    if (!self.footerView) {
        self.footerView = [[VOKDefaultPagingAccessory alloc] init];
        self.footerView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.footerView addConstraint:[NSLayoutConstraint constraintWithItem:self.footerView
                                                                    attribute:NSLayoutAttributeHeight
                                                                    relatedBy:NSLayoutRelationEqual
                                                                       toItem:nil
                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                   multiplier:1
                                                                     constant:DefaultAccessoryHeight]];
    }

    self.tableView.tableFooterView = self.footerView;
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.footerView
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:1
                                                                constant:0]];
    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.footerView
                                                               attribute:NSLayoutAttributeLeft
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self.tableView
                                                               attribute:NSLayoutAttributeLeft
                                                              multiplier:1
                                                                constant:0]];

    self.bottomConstraint = [NSLayoutConstraint constraintWithItem:self.footerView
                                                         attribute:NSLayoutAttributeBottom
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self.headerView
                                                         attribute:NSLayoutAttributeTop
                                                        multiplier:1
                                                          constant:self.tableView.contentSize.height];
    [self.tableView addConstraint:self.bottomConstraint];

    // Adjust the insets to push the paging accessory views off-screen initially
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.top -= DefaultAccessoryHeight;
    insets.bottom -= DefaultAccessoryHeight;
    self.tableView.contentInset = insets;

    [self.tableView addObserver:self
                     forKeyPath:VOKKeyForObject(self.tableView, contentSize)
                        options:0 // Don't use the old or new value from the dictionary in the method, so pass 0
                        context:NULL];
}

- (void)cleanUpPageController
{
    [self.headerView removeFromSuperview];
    self.headerView = nil;

    [self.footerView removeFromSuperview];
    self.footerView = nil;

    self.upAction = nil;
    self.downAction = nil;
}

#pragma mark Scrollview Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:VOKKeyForObject(self.tableView, contentSize)]) {
        self.bottomConstraint.constant = self.tableView.contentSize.height;
    }
}

#pragma mark Scrollview Delegates

- (BOOL)contentHeightLargerThanFrameForScrollView:(UIScrollView *)scrollView
{
    return scrollView.contentSize.height > CGRectGetHeight(scrollView.frame);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!self.isLoading) {
        CGFloat distanceBelowBottomOfScreen = scrollView.contentSize.height - CGRectGetMaxY(scrollView.bounds);
        CGFloat distanceAboveTopOfScreen = CGRectGetMinY(scrollView.bounds);

        //Action for getting to bottom
        if ([self contentHeightLargerThanFrameForScrollView:scrollView]
            && distanceBelowBottomOfScreen <= self.triggerDistance
            && self.downAction) {
            CGFloat contentHeight = scrollView.contentSize.height;
            CGFloat offsetHeight = contentHeight - CGRectGetHeight(self.tableView.frame) - CGRectGetHeight(self.footerView.frame);
            CGPoint offset = CGPointMake(0, offsetHeight);
            UIEdgeInsets insets = self.tableView.contentInset;
            insets.bottom += DefaultAccessoryHeight;
            
            [self triggerAction:self.downAction
               forAccessoryView:self.footerView
              withContentOffset:offset
              returningToOffset:offset
                temporaryInsets:insets];
        } else if (distanceAboveTopOfScreen < (-self.triggerDistance) && self.upAction) {
            //Action for pulling down from top.
            CGPoint offset = CGPointMake(0, CGRectGetHeight(self.headerView.frame));
            UIEdgeInsets insets = self.tableView.contentInset;
            insets.top += DefaultAccessoryHeight;

            [self triggerAction:self.upAction
               forAccessoryView:self.headerView
              withContentOffset:CGPointZero
              returningToOffset:offset
                temporaryInsets:insets];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.isLoading) {
        CGFloat distanceBelowBottomOfScreen = scrollView.contentSize.height - CGRectGetMaxY(scrollView.bounds);
        CGFloat distanceAboveTopOfScreen = CGRectGetMinY(scrollView.bounds);

        if (distanceBelowBottomOfScreen < 0
            && [self contentHeightLargerThanFrameForScrollView:scrollView]) {
            [self.footerView hasOverScrolled:(fabs(distanceBelowBottomOfScreen) / self.triggerDistance)];
        } else {
            [self.footerView hasOverScrolled:0.0];
        }

        if (distanceAboveTopOfScreen < 0) {
            [self.headerView hasOverScrolled:(fabs(distanceAboveTopOfScreen) / self.triggerDistance)];
        } else {
            [self.headerView hasOverScrolled:0.0];
        }
    }
}

#pragma mark Trigger Calls

- (void)triggerAction:(VOKPagingResultsAction)action
     forAccessoryView:(UIView<VOKPagingAccessory> *)accessory
    withContentOffset:(CGPoint)contentOffset
    returningToOffset:(CGPoint)returnOffset
      temporaryInsets:(UIEdgeInsets)tempInsets
{
    self.isLoading = YES;
    [self.tableView setUserInteractionEnabled:NO];

    UIEdgeInsets originalInsets = self.tableView.contentInset;
    [accessory loadingWillBegin];

    //self.table is a weak relationship, causing it to be dealloc'd before self while this block was in-flight.
    typeof(self.tableView) __strong strongTableView = self.tableView;
    [UIView animateWithDuration:.3
                     animations:^{
                         strongTableView.contentInset = tempInsets;
                         strongTableView.contentOffset = contentOffset;
                     }
                     completion:^(BOOL finished) {
                         action(strongTableView, ^(void) {
                             self.isLoading = NO;
                             [accessory loadingHasFinished];
                             
                             strongTableView.userInteractionEnabled = YES;
                             strongTableView.contentInset = originalInsets;
                             [strongTableView setContentOffset:returnOffset animated:YES];
                         });
                     }];
}

- (void)dealloc
{
    [self.tableView removeObserver:self forKeyPath:VOKKeyForObject(self.tableView, contentSize)];
}

@end
