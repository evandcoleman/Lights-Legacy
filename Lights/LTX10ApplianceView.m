//
//  LTX10ApplianceView.m
//  Lights
//
//  Created by Evan Coleman on 2/17/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTX10ApplianceView.h"

@implementation LTX10ApplianceView

- (id)initWithFrame:(CGRect)frame
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LTX10ApplianceView" owner:self options:nil];
    self = [topLevelObjects objectAtIndex:0];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
