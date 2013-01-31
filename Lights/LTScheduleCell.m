//
//  LTScheduleCell.m
//  Lights
//
//  Created by Evan Coleman on 1/26/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTScheduleCell.h"

@interface LTScheduleCell ()

@property (nonatomic, assign) CGRect timeNormalRect;
@property (nonatomic, assign) CGRect timeEditRect;
@property (nonatomic, assign) CGRect repeatNormalRect;
@property (nonatomic, assign) CGRect repeatEditRect;
@property (nonatomic, assign) CGRect eventNormalRect;
@property (nonatomic, assign) CGRect eventEditRect;

@end

@implementation LTScheduleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)awakeFromNib {
    CGFloat margin = 40.0f;
    self.timeNormalRect = self.timeLabel.frame;
    self.repeatNormalRect = self.repeatLabel.frame;
    self.eventNormalRect = self.eventLabel.frame;
    self.timeEditRect = CGRectMake(self.timeNormalRect.origin.x + margin, self.timeNormalRect.origin.y, self.timeNormalRect.size.width, self.timeNormalRect.size.height);
    self.repeatEditRect = CGRectMake(self.repeatEditRect.origin.x + margin, self.repeatEditRect.origin.y, self.repeatEditRect.size.width, self.repeatEditRect.size.height);
    self.eventEditRect = CGRectMake(self.eventEditRect.origin.x + margin, self.eventEditRect.origin.y, self.eventEditRect.size.width, self.eventEditRect.size.height);
    
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.shadowColor = [UIColor whiteColor];
    self.timeLabel.shadowOffset = CGSizeMake(0, 1);
    
    self.repeatLabel.backgroundColor = [UIColor clearColor];
    self.repeatLabel.shadowColor = [UIColor whiteColor];
    self.repeatLabel.shadowOffset = CGSizeMake(0, 1);
    
    self.eventLabel.backgroundColor = [UIColor clearColor];
    self.eventLabel.shadowColor = [UIColor whiteColor];
    self.eventLabel.shadowOffset = CGSizeMake(0, 1);
}

/*- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^(void) {
        if(editing && self.timeLabel.frame.origin.x == self.timeNormalRect.origin.x) {
            NSLog(@"editing");
            self.timeLabel.frame = self.timeEditRect;
            self.repeatLabel.frame = self.repeatEditRect;
            self.eventLabel.frame = self.eventEditRect;
        } else if(!editing && self.timeLabel.frame.origin.x == self.timeEditRect.origin.x) {
            NSLog(@"normal");
            self.timeLabel.frame = self.timeNormalRect;
            self.repeatLabel.frame = self.repeatNormalRect;
            self.eventLabel.frame = self.eventNormalRect;
        }
    } completion:NULL];
    NSLog(@"%d",editing);
    [super setEditing:editing animated:animated];
}*/

@end
