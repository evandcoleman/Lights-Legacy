//
//  LTPresetAddViewController.m
//  Lights
//
//  Created by Evan Coleman on 2/24/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTPresetAddViewController.h"
#import "LTNetworkController.h"
#ifndef SIMPLE
#import "LTColorPickerViewController.h"
#endif

@interface LTPresetAddViewController ()

@property (nonatomic, strong) NSDictionary *standardList;

- (void)add:(id)sender;
- (void)cancel:(id)sender;

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
    UIBarButtonItem *save = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(add:)];
    self.navigationItem.rightBarButtonItem = save;
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancel;
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
            LTColorPickerViewController *vc = [[LTColorPickerViewController alloc] initWithNibName:nil bundle:nil];
            vc.delegate = self;
            vc.title = @"Color";
            vc.hidesBackButton = YES;
            //vc.colorPicker.selectedColor = self.colorOption;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            
        }
    } else if(indexPath.section == 1) {
        
    }
    #endif
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)colorPickerDidFinish:(UIColor *)color {
    [self.delegate presetAddViewDidFinishWithAction:@{@"event": [NSNumber numberWithInteger:LTEventTypeSolid], @"color" : color}];
    //[self dismissViewControllerAnimated:YES completion:NULL];
}

@end
