//
//  VIPagingFetchedResultsDataSource.m
//
//  Created by teejay on 1/21/14.
//

#import "VOKPagingFetchedResultsDataSource.h"
#import "VOKDefaultPagingAccessory.h"

@interface VOKPagingFetchedResultsDataSource () <UIScrollViewDelegate>

@property (copy) VIPagingResultsAction upAction;
@property (copy) VIPagingResultsAction downAction;

@property UIView<VIPagingAccessory> *headerView;
@property UIView<VIPagingAccessory> *footerView;

@property BOOL isLoading;
@property CGFloat triggerDistance;
@property UIEdgeInsets orginalInsets;

@end

@implementation VOKPagingFetchedResultsDataSource

#pragma mark Setup

- (void)setupForTriggerDistance:(CGFloat)overscrollTriggerDistance
                       upAction:(VIPagingResultsAction)upPageActionOrNil
                     headerView:(UIView<VIPagingAccessory> *)headerViewOrNil
                     downAction:(VIPagingResultsAction)downPageActionOrNil
                     footerView:(UIView<VIPagingAccessory> *)footerViewOrNil;
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
        self.headerView = [[VOKDefaultPagingAccessory alloc] initWithFrame:(CGRect){0, -30, self.tableView.frame.size.width, 30}];
    }
    
    [self.headerView setFrame:(CGRect){0, -self.headerView.frame.size.height, self.headerView.frame.size}];
    [self.tableView addSubview:self.headerView];
    
    if (!self.footerView) {
        self.footerView = [[VOKDefaultPagingAccessory alloc] initWithFrame:(CGRect){0,
            MAX(self.tableView.contentSize.height, self.tableView.bounds.size.height),
            self.tableView.frame.size.width, 30}];
    }
    
    [self.tableView addSubview:self.footerView];
    
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionPrior context:NULL];
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

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self.footerView setFrame:(CGRect){0, MAX(self.tableView.contentSize.height, self.tableView.bounds.size.height), self.footerView.frame.size}];
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

- (void)triggerAction:(VIPagingResultsAction)action
     forAccessoryView:(UIView<VIPagingAccessory> *)accessory
           withInsets:(UIEdgeInsets)insets
{
    self.isLoading = YES;
    [self.tableView setUserInteractionEnabled:NO];
    
    [accessory loadingWillBegin];
    
    [UIView animateWithDuration:.3 animations:^{
        [self.tableView setContentInset:insets];
    } completion:^(BOOL finished) {
        VICompletionAction completionAction = ^void (void)
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
    NSLog(@"Page controller dealloc'd %@", self);
    [self.tableView removeObserver:self forKeyPath:@"contentSize"];
}

@end
