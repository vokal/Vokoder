//
//  BaseballTeam.h
//  MigrationProject
//
//  Created by Brock Boland on 10/26/16.
//  Copyright © 2016 Vokal. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface BaseballTeam : NSManagedObject

@property (nonatomic) NSNumber *teamIdentifier;
@property (nonatomic) NSString *teamName;

@end
