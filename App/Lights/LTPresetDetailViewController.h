//
//  LTPresetDetailViewController.h
//  Lights
//
//  Created by Evan Coleman on 2/24/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTPresetAddViewController.h"

@interface LTPresetDetailViewController : UITableViewController <UIAlertViewDelegate, LTPresetAddViewControllerDelegate>

@property (nonatomic, strong) NSMutableDictionary *preset;

- (void)add:(id)sender;

@end
