//
//  LTScrollView.m
//  Lights
//
//  Created by Evan Coleman on 2/8/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTScrollView.h"

@implementation LTScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
    BOOL retVal = YES;
    if([view isKindOfClass:[NSClassFromString(@"KZColorPicker") class]]) {
        retVal = NO;
    }
    return retVal;
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
