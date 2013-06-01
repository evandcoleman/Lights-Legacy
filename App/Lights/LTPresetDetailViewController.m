//
//  LTPresetDetailViewController.m
//  Lights
//
//  Created by Evan Coleman on 2/24/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTPresetDetailViewController.h"
#import "LTNetworkController.h"

@interface LTPresetDetailViewController ()

- (void)done:(id)sender;

@end

@implementation LTPresetDetailViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItem = done;
    
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
    self.navigationItem.leftBarButtonItem = add;
}

- (void)viewWillAppear:(BOOL)animated {
    self.title = [self.preset objectForKey:@"name"];
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)done:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)add:(id)sender {
    LTPresetAddViewController *vc = [[LTPresetAddViewController alloc] initWithStyle:UITableViewStyleGrouped];
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.barStyle = UIBarStyleBlackOpaque;
    [self presentViewController:nav animated:YES completion:NULL];
}

- (void)presetAddViewDidFinishWithAction:(NSDictionary *)action {
    [[self.preset objectForKey:@"actions"] addObject:action];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.preset objectForKey:@"actions"] count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    //cell.textLabel.textColor = [UIColor blackColor];
    if(indexPath.row == 0) {
        cell.textLabel.text = @"Edit Name";
    } else {
        NSDictionary *dict = [[self.preset objectForKey:@"actions"] objectAtIndex:indexPath.row-1];
        NSString *text = nil;
        if([[dict objectForKey:@"event"] integerValue] == LTEventTypeX10Command) {
            NSArray *devices = [[LTNetworkController sharedInstance] x10Devices];
            NSDictionary *device = nil;
            for(NSDictionary *d in devices) {
                if([[d objectForKey:@"deviceID"] integerValue] == [[dict objectForKey:@"device"] integerValue]) {
                    device = d;
                    break;
                }
            }
            text = [NSString stringWithFormat:@"%@ - %@",[device objectForKey:@"name"],[[[LTNetworkController sharedInstance] x10CommandNames] objectAtIndex:[[dict objectForKey:@"command"] integerValue]]];
        } else {
            NSArray *nonAnim = @[@"Solid"];
            NSArray *events = [nonAnim arrayByAddingObjectsFromArray:[[LTNetworkController sharedInstance] animationOptions]];
            NSArray *indexes = [@[[NSNumber numberWithInt:LTEventTypeSolid]] arrayByAddingObjectsFromArray:[[LTNetworkController sharedInstance] animationIndexes]];
            text = [events objectAtIndex:[indexes indexOfObject:[dict objectForKey:@"event"]]];
            if([[dict objectForKey:@"event"] integerValue] == LTEventTypeSolid) {
                NSArray *rgb = [dict objectForKey:@"color"];
                UIColor *color = [UIColor colorWithRed:[[rgb objectAtIndex:0] floatValue]/255 green:[[rgb objectAtIndex:1] floatValue]/255 blue:[[rgb objectAtIndex:2] floatValue]/255 alpha:1.0];
                cell.textLabel.textColor = color;
            }
        }
        cell.textLabel.text = text;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Edit Title" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        [[alert textFieldAtIndex:0] setPlaceholder:[self.preset objectForKey:@"name"]];
        [alert show];
    } else {
        
    }
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        NSString *newTitle = [[alertView textFieldAtIndex:0] text];
        if(newTitle.length > 0) {
            [self.preset setObject:newTitle forKey:@"name"];
            self.title = newTitle;
        }
    }
}

@end
