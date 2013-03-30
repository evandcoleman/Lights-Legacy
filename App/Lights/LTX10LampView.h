//
//  LTX10LampView.h
//  Lights
//
//  Created by Evan Coleman on 2/16/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTX10ApplianceView.h"

@interface LTX10LampView : LTX10ApplianceView

@property (nonatomic, weak) IBOutlet UIButton *brightButton;
@property (nonatomic, weak) IBOutlet UIButton *dimButton;

@end
