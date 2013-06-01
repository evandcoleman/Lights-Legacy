//
//  LTPresetAddViewController.m
//  Lights
//
//  Created by Evan Coleman on 2/24/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTPresetAddViewController.h"
#import "LTNetworkController.h"
#import "RNBlurModalView.h"
#import "LTX10ApplianceView.h"
#import "LTX10LampView.h"
#ifndef SIMPLE
#import "LTColorPickerViewController.h"
#endif

@interface LTPresetAddViewController ()

@property (nonatomic, strong) NSDictionary *standardList;
@property (nonatomic, strong) RNBlurModalView *modal;
@property (nonatomic, strong) NSDictionary *targetDevice;

- (void)add:(id)sender;
- (void)cancel:(id)sender;
- (void)sendCommand:(LTX10Command)command;
- (void)sendOn:(id)sender;
- (void)sendOff:(id)sender;
- (void)sendBright:(id)sender;
- (void)sendDim:(id)sender;

@end

@implementation LTPresetAddViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        NSArray *nonAnim = @[@"Solid"];
        NSArray *events = [nonAnim arrayByAddingObjectsFromArray:[[LTNetworkController sharedInstance] animationOptions]];
        self.standardList = @{@"Colors" : events, @"X10 Devices" : [[LTNetworkController sharedInstance] x10Devices]};
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Add Action";
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(add:)];
    //self.navigationItem.rightBarButtonItem = save;
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = cancel;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)add:(id)sender {
    
}

- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.standardList allKeys] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.standardList objectForKey:[[self.standardList allKeys] objectAtIndex:section]] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[self.standardList allKeys] objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if(indexPath.section == 0) {
        cell.textLabel.text = [[self.standardList objectForKey:[[self.standardList allKeys] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    } else if(indexPath.section == 1) {
        cell.textLabel.text = [[[self.standardList objectForKey:[[self.standardList allKeys] objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row] objectForKey:@"name"];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    #ifndef SIMPLE
    if(indexPath.section == 0) {
        if(indexPath.row == 0) {
            //Solid Color
            LTColorPickerViewController *vc = [[LTColorPickerViewController alloc] initWithNibName:nil bundle:nil];
            vc.delegate = self;
            vc.title = @"Color";
            vc.hidesBackButton = YES;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            nav.navigationBar.barStyle = UIBarStyleBlackOpaque;
            //vc.colorPicker.selectedColor = self.colorOption;
            [self presentViewController:nav animated:YES completion:NULL];
        } else {
            //Animation
            [self.delegate presetAddViewDidFinishWithAction:@{@"event" : [[[LTNetworkController sharedInstance] animationIndexes] objectAtIndex:indexPath.row-1]}];
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
    } else if(indexPath.section == 1) {
        //X10 Event
        NSDictionary *dict = [[[LTNetworkController sharedInstance] x10Devices] objectAtIndex:indexPath.row];
        self.targetDevice = dict;
        LTX10Device device = [[dict objectForKey:@"type"] integerValue];
        if(device == LTX10DeviceAppliance) {
            LTX10ApplianceView *appView = [[LTX10ApplianceView alloc] initWithFrame:CGRectZero];
            appView.titleLabel.text = [dict objectForKey:@"name"];
            [appView.onButton addTarget:self action:@selector(sendOn:) forControlEvents:UIControlEventTouchUpInside];
            [appView.offButton addTarget:self action:@selector(sendOff:) forControlEvents:UIControlEventTouchUpInside];
            self.modal = [[RNBlurModalView alloc] initWithViewController:self view:appView];
        } else if(device == LTX10DeviceLamp) {
            LTX10LampView *lampView = [[LTX10LampView alloc] initWithFrame:CGRectZero];
            lampView.titleLabel.text = [dict objectForKey:@"name"];
            [lampView.onButton addTarget:self action:@selector(sendOn:) forControlEvents:UIControlEventTouchUpInside];
            [lampView.offButton addTarget:self action:@selector(sendOff:) forControlEvents:UIControlEventTouchUpInside];
            [lampView.brightButton addTarget:self action:@selector(sendBright:) forControlEvents:UIControlEventTouchUpInside];
            [lampView.dimButton addTarget:self action:@selector(sendDim:) forControlEvents:UIControlEventTouchUpInside];
            self.modal = [[RNBlurModalView alloc] initWithViewController:self view:lampView];
        }
        [self.modal show];
    }
    #endif
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)colorPickerDidFinish:(UIColor *)color {
    CGFloat red; CGFloat green; CGFloat blue; CGFloat alpha;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    [self.delegate presetAddViewDidFinishWithAction:@{@"event": [NSNumber numberWithInteger:LTEventTypeSolid], @"color" : @[[NSNumber numberWithFloat:red*255], [NSNumber numberWithFloat:green*255], [NSNumber numberWithFloat:blue*255]]}];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)sendCommand:(LTX10Command)command {
    [self.delegate presetAddViewDidFinishWithAction:@{@"event" : @9, @"command" : [NSNumber numberWithInteger:command], @"houseCode" : [self.targetDevice objectForKey:@"houseCode"], @"device" : [self.targetDevice objectForKey:@"deviceID"]}];
    [self.modal hide];
    self.modal = nil;
    self.targetDevice = nil;
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)sendOn:(id)sender {
    [self sendCommand:LTX10CommandOn];
}

- (void)sendOff:(id)sender {
    [self sendCommand:LTX10CommandOff];
}

- (void)sendBright:(id)sender {
    [self sendCommand:LTX10CommandBright];
}

- (void)sendDim:(id)sender {
    [self sendCommand:LTX10CommandDim];
}

@end
