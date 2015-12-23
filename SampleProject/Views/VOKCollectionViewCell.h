//
//  VOKCollectionViewCell.h
//  SampleProject
//
//  Created by Sean Wolter on 12/23/15.
//  Copyright © 2015 Vokal. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VOKPerson;

@interface VOKCollectionViewCell : UICollectionViewCell

- (void)layoutWithPerson:(VOKPerson *)person;

@end
