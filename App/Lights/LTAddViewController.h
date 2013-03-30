//
//  LTAddViewController.h
//  Lights
//
//  Created by Evan Coleman on 1/26/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTTableViewController.h"
#import "LTColorPickerViewController.h"

@protocol LTAddViewControllerDelegate <NSObject>

- (void)didScheduleEvent;

@end

@interface LTAddViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, LTTableViewControllerDelegate, LTColorPickerViewControllerDelegate>

@property (nonatomic, weak) id<LTAddViewControllerDelegate> delegate;

@end
