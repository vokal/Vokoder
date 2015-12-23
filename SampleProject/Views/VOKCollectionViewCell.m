//
//  VOKCollectionViewCell.m
//  SampleProject
//
//  Created by Sean Wolter on 12/23/15.
//  Copyright © 2015 Vokal. All rights reserved.
//

#import "VOKCollectionViewCell.h"
#import "VOKPerson.h"

@interface VOKCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;

@end

@implementation VOKCollectionViewCell

- (void)layoutWithPerson:(VOKPerson *)person
{
    self.topLabel.text = [NSString stringWithFormat:@"%@, %@", person.lastName, person.firstName];
    self.bottomLabel.text = [NSString stringWithFormat:@"Number of cats: %@", person.numberOfCats];
}

@end
