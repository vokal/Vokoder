//
//  VIPlayer.h
//  PagedCoreData
//
//  Created by teejay on 1/21/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface VIPlayer : NSManagedObject

@property (nonatomic, retain) NSString * cUsername;
@property (nonatomic, retain) NSNumber * cHighscore;

+ (void)setupMaps;

@end
