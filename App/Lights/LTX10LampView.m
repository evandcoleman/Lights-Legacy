//
//  LTX10LampView.m
//  Lights
//
//  Created by Evan Coleman on 2/16/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTX10LampView.h"

@implementation LTX10LampView

- (id)initWithFrame:(CGRect)frame
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LTX10LampView" owner:self options:nil];
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
