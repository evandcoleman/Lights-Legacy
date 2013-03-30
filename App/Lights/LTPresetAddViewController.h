//
//  LTPresetAddViewController.h
//  Lights
//
//  Created by Evan Coleman on 2/24/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTColorPickerViewController.h"

@class LTPresetAddViewController;

@protocol LTPresetAddViewControllerDelegate <NSObject>
@required
- (void)presetAddViewDidFinishWithAction:(NSDictionary *)action;

@end

@interface LTPresetAddViewController : UITableViewController <LTColorPickerViewControllerDelegate>

@property (nonatomic, weak) id<LTPresetAddViewControllerDelegate>delegate;

@end
