//
//  VOKPagingFetchedResultsDataSource.h
//  Vokoder
//
//  Created by teejay on 1/21/14.
//  Copyright © 2014 Vokal.
//

#import "VOKFetchedResultsDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@protocol VOKPagingAccessory <NSObject>

/**
 Called when loading has completed after an overscroll
 */
- (void)loadingHasFinished;

/**
 Called before loading begins after an overscroll
 */
- (void)loadingWillBegin;

/**
 Called when the scroll view overscrolls

 @param overScrollPercent Distance of the overscroll as a percentage of the trigger distance
 */
- (void)hasOverScrolled:(CGFloat)overScrollPercent;

@end

/**
 Generic completion block signature
 */
typedef void (^VOKCompletionAction)(void);

/**
 This is your primary interaction with this class. Inside this block you should fetch your data,
 insert it into Core Data, and then execute the fetchCompleted() block.

 @param tableView      Table view to fetch more results for
 @param fetchCompleted Block to execute when you have finished your data fetching
 */
typedef void (^VOKPagingResultsAction)(UITableView *tableView, VOKCompletionAction fetchCompleted);

/**
 Data source that allows the user to over-scroll to load more items in the view. Just like the
 superclass, VOKFetchedResultsDataSource, this should be subclassed instead of being used directly,
 so that the cellAtIndexPath: method can be implemented.
 */
@interface VOKPagingFetchedResultsDataSource : VOKFetchedResultsDataSource

/**
 Setup and activate the paging functionality. By not including either an action for a specified
 direction, the controller will not attempt to handle that direction

 @param overscrollTriggerDistance The distance a user must scroll past the bounds to activate a page fetch
 @param upPageActionOrNil         Executed when scrolling beyond the top bound of the tableView. Make API calls here.
 @param headerViewOrNil           View that will be inserted above the table, and notified of scrolling updates
 @param downPageActionOrNil       Executed when scrolling beyong the low bound of the tableView. Make API calls here.
 @param footerViewOrNil           View that will be inserted below the table, and notified of scrolling updates
*/
- (void)setupForTriggerDistance:(CGFloat)overscrollTriggerDistance
                       upAction:(nullable VOKPagingResultsAction)upPageActionOrNil
                     headerView:(nullable UIView<VOKPagingAccessory> *)headerViewOrNil
                     downAction:(nullable VOKPagingResultsAction)downPageActionOrNil
                     footerView:(nullable UIView<VOKPagingAccessory> *)footerViewOrNil;

/**
 Call to handle memory management before deallocating a view that contains this class.
 */
- (void)cleanUpPageController;

@end

NS_ASSUME_NONNULL_END
