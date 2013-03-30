//
//  LTTableViewController.m
//  Lights
//
//  Created by Evan Coleman on 1/26/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTTableViewController.h"

@interface LTTableViewController ()

@property (nonatomic, strong) NSMutableArray *selectedRows;

@end

@implementation LTTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.selectedRows = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    if(self.selectedRows) {
        NSMutableArray *ret = [NSMutableArray array];
        for(NSIndexPath *indexPath in self.selectedRows) {
            [ret addObject:[NSNumber numberWithInt:indexPath.row]];
        }
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"self" ascending:YES];
        [self.delegate tableViewControllerDidFinishWithSelection:[ret sortedArrayUsingDescriptors:@[sort]]];
    }
    
    [super viewWillDisappear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if([self.selectedIndexes containsObject:[NSNumber numberWithInt:indexPath.row]] && ![self.selectedRows containsObject:indexPath]) {
        [self.selectedRows addObject:indexPath];
        [self.selectedIndexes removeObject:[NSNumber numberWithInt:indexPath.row]];
    }
    
    // Configure the cell...
    if([self.title isEqualToString:@"Repeat"]) {
        cell.textLabel.text = [NSString stringWithFormat:@"Every %@",[self.data objectAtIndex:indexPath.row]];
    } else {
        cell.textLabel.text = [self.data objectAtIndex:indexPath.row];
    }
    if([self.selectedRows containsObject:indexPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
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
    if([self.title isEqualToString:@"Repeat"]) {
        if([self.selectedRows containsObject:indexPath]) {
            [self.selectedRows removeObject:indexPath];
        } else {
            [self.selectedRows addObject:indexPath];
        }
        [tableView reloadData];
    } else if([self.title isEqualToString:@"Event"]) {
        [self.delegate tableViewControllerDidFinishWithSelection:[NSNumber numberWithInt:indexPath.row]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
