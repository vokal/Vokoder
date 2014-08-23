//
//  VIPerson.h
//  SampleProject
//
//  Created by Sean Wolter on 8/23/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class VIThing;

@interface VIPerson : NSManagedObject

@property (nonatomic, retain) NSDate *birthDay;
@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSNumber *lovesCoolRanch;
@property (nonatomic, retain) NSNumber *numberOfCats;
@property (nonatomic, retain) VIThing *thing;

@end
