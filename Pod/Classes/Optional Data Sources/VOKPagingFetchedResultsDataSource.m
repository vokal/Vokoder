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

@property (copy) VOKPagingResultsAction upAction;
@property (copy) VOKPagingResultsAction downAction;

@property (nonatomic) UIView<VOKPagingAccessory> *headerView;
@property (nonatomic) UIView<VOKPagingAccessory> *footerView;

@property (nonatomic) BOOL isLoading;
@property (nonatomic) CGFloat triggerDistance;
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
        CGRect headerFrame = (CGRect){0, -DefaultAccessoryHeight, self.tableView.frame.size.width, DefaultAccessoryHeight};
        self.headerView = [[VOKDefaultPagingAccessory alloc] initWithFrame:headerFrame];
    }
    
    self.headerView.frame = (CGRect){0, -self.headerView.frame.size.height, self.headerView.frame.size};
    [self.tableView addSubview:self.headerView];
    
    if (!self.footerView) {
        CGRect footerFrame = (CGRect){0,
            MAX(self.tableView.contentSize.height, self.tableView.bounds.size.height),
            self.tableView.frame.size.width,
            DefaultAccessoryHeight};
        self.footerView = [[VOKDefaultPagingAccessory alloc] initWithFrame:footerFrame];
    }
    
    [self.tableView addSubview:self.footerView];
    
    [self.tableView addObserver:self
                     forKeyPath:VOKKeyForInstanceOf(UITableView, contentSize)
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionPrior
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
    if ([keyPath isEqualToString:VOKKeyForInstanceOf(UITableView, contentSize)]) {
        self.footerView.frame = (CGRect){0, MAX(self.tableView.contentSize.height, self.tableView.bounds.size.height), self.footerView.frame.size};
    }
}

#pragma mark Scrollview Delegates

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!self.isLoading) {
        //Calculate scrollable height
        CGFloat contentHeight = scrollView.contentSize.height;
        CGFloat scrollableHeight = contentHeight - scrollView.bounds.size.height;
        
        if (scrollView.contentOffset.y > (scrollableHeight + self.triggerDistance) && self.downAction) {
            
            UIEdgeInsets newInsets = self.orginalInsets;
            newInsets.bottom += self.footerView.frame.size.height;
            
            [self triggerAction:self.downAction forAccessoryView:self.footerView withInsets:newInsets];
        }
        
        CGFloat topOffset = scrollView.contentOffset.y - scrollView.contentInset.top;
        if (topOffset < (-self.triggerDistance) && self.upAction) {
            
            UIEdgeInsets newInsets = self.orginalInsets;
            newInsets.top += self.headerView.frame.size.height;
            
            [self triggerAction:self.upAction forAccessoryView:self.headerView withInsets:newInsets];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.isLoading) {
        //Calculate scrollable height
        CGFloat contentHeight = scrollView.contentSize.height;
        CGFloat scrollableHeight = contentHeight - scrollView.bounds.size.height;
        
        CGFloat topOffset = scrollView.contentOffset.y + scrollView.contentInset.top;
        
        if (topOffset > scrollableHeight) {
            CGFloat distanceOverscrolled = topOffset - scrollableHeight;
            [self.footerView hasOverScrolled:(distanceOverscrolled/self.triggerDistance)];
        } else {
            [self.footerView hasOverScrolled:0.0];
        }
        
        if (topOffset < 0) {
            [self.headerView hasOverScrolled:(fabs(topOffset)/self.triggerDistance)];
        } else {
            [self.headerView hasOverScrolled:0.0];
        }
    }
}

#pragma mark Trigger Calls

- (void)triggerAction:(VOKPagingResultsAction)action
     forAccessoryView:(UIView<VOKPagingAccessory> *)accessory
           withInsets:(UIEdgeInsets)insets
{
    self.isLoading = YES;
    [self.tableView setUserInteractionEnabled:NO];
    
    [accessory loadingWillBegin];
    
    [UIView animateWithDuration:.3 animations:^{
        [self.tableView setContentInset:insets];
    } completion:^(BOOL finished) {
        VOKCompletionAction completionAction = ^void (void)
        {
            self.isLoading = NO;
            [accessory loadingHasFinished];
            
            [self.tableView setUserInteractionEnabled:YES];
            [self.tableView setContentInset:self.orginalInsets];
        };
        
        action(self.tableView, completionAction);
    }];
}

- (void)dealloc
{
    [self.tableView removeObserver:self forKeyPath:VOKKeyForInstanceOf(UITableView, contentSize)];
}

@end
