//
//  VIThing.h
//  SampleProject
//
//  Created by Sean Wolter on 8/23/14.
//  Copyright © 2015 Vokal.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VIPerson;

@interface VIThing : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *numberOfHats;
@property (nonatomic, retain) VIPerson *person;

@end
