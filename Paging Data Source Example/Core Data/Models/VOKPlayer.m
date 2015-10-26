//
//  VIPlayer.m
//  PagedCoreData
//
//  Created by teejay on 1/21/14.
//
//

#import "VOKPlayer.h"
#import "VOKCoreDataManager.h"

@implementation VOKPlayer

@dynamic cUsername;
@dynamic cHighscore;


+ (void)setupMaps
{
    NSArray *maps = @[[VOKManagedObjectMap mapWithForeignKeyPath:@"username" coreDataKey:@"cUsername"],
                      [VOKManagedObjectMap mapWithForeignKeyPath:@"highscore" coreDataKey:@"cHighscore"]];
    
    VOKManagedObjectMapper *mapper = [VOKManagedObjectMapper mapperWithUniqueKey:@"cUsername" andMaps:maps];
    [[VOKCoreDataManager sharedInstance] setObjectMapper:mapper forClass:[VOKPlayer class]];
}

@end
