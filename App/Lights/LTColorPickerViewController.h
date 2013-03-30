//
//  LTColorPickerViewController.h
//  Lights
//
//  Created by Evan Coleman on 1/26/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTTableViewController.h"
#import "KZColorPicker.h"

@class LTColorPickerViewController;

@protocol LTColorPickerViewControllerDelegate <NSObject>

- (void)colorPickerDidFinish:(UIColor *)color;

@end

@interface LTColorPickerViewController : UIViewController

@property (nonatomic, strong) KZColorPicker *colorPicker;
@property (nonatomic, strong) id<LTColorPickerViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL hidesBackButton;


@end
