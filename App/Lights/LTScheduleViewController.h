//
//  LTSecondViewController.h
//  Lights
//
//  Created by Evan Coleman on 1/17/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LTAddViewController.h"
#import "LTNetworkController.h"

@interface LTScheduleViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, LTAddViewControllerDelegate, LTNetworkControllerDelegate>

@end
