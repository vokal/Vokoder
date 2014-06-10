//
//  VIPerson.h
//  CoreData
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface VIPerson : NSManagedObject

@property (nonatomic, retain) NSString *firstName;
@property (nonatomic, retain) NSString *lastName;
@property (nonatomic, retain) NSDate *birthDay;
@property (nonatomic, retain) NSNumber *numberOfCats;
@property (nonatomic, retain) NSNumber *lovesCoolRanch;

@end
