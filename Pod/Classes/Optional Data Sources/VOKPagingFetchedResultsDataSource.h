//
//  VIPagingFetchedResultsDataSource.h
//
//  Created by teejay on 1/21/14.
//

#import "VOKFetchedResultsDataSource.h"

@protocol VIPagingAccessory <NSObject>

- (void)loadingHasFinished;
- (void)loadingWillBegin;

- (void)hasOverScrolled:(CGFloat)overScrollPercent;

@end

typedef void (^VICompletionAction)(void);
/**
 *  This is your primary interaction with this class. Inside this block you should fetch your data, insert it into Core Data, and then execute the fetchCompleted() block.
 *
 *  @param tableView            Tableview associated with this datasource
 *  @param fetchCompleted       Execute this block when you have finished your data fetching.
 *
 */
typedef void (^VIPagingResultsAction)(UITableView *tableView, VICompletionAction fetchCompleted);

@interface VOKPagingFetchedResultsDataSource : VOKFetchedResultsDataSource

/**
 *  This will structure and activate the paging functionality
 *
 *  @param overscrollTriggerDistance    The distance a user must scroll past the bounds to activate a page fetch
 
 *  @param upPageActionOrNil                 Executed when scrolling beyond the top bound of the tableView, do API actions here.
 *  @param headerViewOrNil                   View that will be inserted above the table, and notified of scrolling updates
 
 *  @param downPageActionOrNil               Executed when scrolling beyong the low bound of the tableView, do API actions here.
 *  @param footerViewOrNil                   View that will be inserted below the table, and notified of scrolling updates
 
 *  By not including either an action for a specified direction, the controller will not attempt to handle that direction
 */
- (void)setupForTriggerDistance:(CGFloat)overscrollTriggerDistance
                       upAction:(VIPagingResultsAction)upPageActionOrNil
                     headerView:(UIView<VIPagingAccessory> *)headerViewOrNil
                     downAction:(VIPagingResultsAction)downPageActionOrNil
                     footerView:(UIView<VIPagingAccessory> *)footerViewOrNil;

/**
 *  Call to handle memory management before deallocating a view that contains this class.
 */
- (void)cleanUpPageController;

@end
