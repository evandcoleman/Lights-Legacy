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

@interface LTColorPickerViewController : UIViewController

@property (nonatomic, strong) KZColorPicker *colorPicker;
@property (nonatomic, strong) id<LTTableViewControllerDelegate> delegate;


@end
