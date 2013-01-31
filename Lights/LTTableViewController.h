//
//  LTTableViewController.h
//  Lights
//
//  Created by Evan Coleman on 1/26/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LTTableViewControllerDelegate <NSObject>

- (void)tableViewControllerDidFinishWithSelection:(id)selection;

@end

@interface LTTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSMutableArray *selectedIndexes;
@property (nonatomic, weak) id<LTTableViewControllerDelegate> delegate;

@end
