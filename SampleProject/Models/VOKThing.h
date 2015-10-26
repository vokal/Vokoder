//
//  VOKThing.h
//  SampleProject
//
//  Created by Sean Wolter on 8/23/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VOKPerson;

@interface VOKThing : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *numberOfHats;
@property (nonatomic, retain) VOKPerson *person;

@end
