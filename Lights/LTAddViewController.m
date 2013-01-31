//
//  LTAddViewController.m
//  Lights
//
//  Created by Evan Coleman on 1/26/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTAddViewController.h"
#import "LTNetworkController.h"
#import "LTColorPickerViewController.h"

@interface LTAddViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (nonatomic, strong) NSArray *events;
@property (nonatomic, strong) NSArray *daysLong;
@property (nonatomic, strong) NSArray *daysShort;

@property (nonatomic, strong) NSArray *repeatOption;
@property (nonatomic, assign) LTEventType eventOption;
@property (nonatomic, strong) UIColor *colorOption;

- (void)done:(id)sender;
- (void)cancel:(id)sender;

@end

@implementation LTAddViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSArray *nonAnim = @[@"Solid"];
        self.events = [nonAnim arrayByAddingObjectsFromArray:[[LTNetworkController sharedInstance] animationOptions]];
        self.daysLong = @[@"Sunday",@"Monday",@"Tuesday",@"Wednesday",@"Thursday",@"Friday",@"Saturday"];
        self.daysShort = @[@"Sun",@"Mon",@"Tue",@"Wed",@"Thu",@"Fri",@"Sat"];
        
        self.eventOption = LTEventTypeSolid;
        self.colorOption = [UIColor redColor];
        self.repeatOption = [NSArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
    self.navigationItem.rightBarButtonItem = done;
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = cancel;
    
    self.title = @"Add";
}

- (void)viewWillAppear:(BOOL)animated {
    NSTimeInterval time = round([[NSDate date] timeIntervalSinceReferenceDate] / 60.0) * 60.0;
    NSDate *minute = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
    self.datePicker.date = minute;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)done:(id)sender {
    NSDate *date = self.datePicker.date;
    if([date timeIntervalSinceNow] < 0) {
        date = [date dateByAddingTimeInterval:(3600*24)];
    }
    
    [[LTNetworkController sharedInstance] scheduleEvent:self.eventOption date:date color:self.colorOption repeat:self.repeatOption];
    [self.delegate didScheduleEvent];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        LTTableViewController *vc = [[LTTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        vc.delegate = self;
        vc.data = self.daysLong;
        vc.title = @"Repeat";
        vc.selectedIndexes = [self.repeatOption mutableCopy];
        [self.navigationController pushViewController:vc animated:YES];
    } else if(indexPath.row == 1) {
        LTTableViewController *vc = [[LTTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        vc.delegate = self;
        vc.data = self.events;
        vc.title = @"Event";
        [self.navigationController pushViewController:vc animated:YES];
    } else if(indexPath.row == 2) {
        LTColorPickerViewController *vc = [[LTColorPickerViewController alloc] initWithNibName:nil bundle:nil];
        vc.delegate = self;
        vc.title = @"Color";
        vc.colorPicker.selectedColor = self.colorOption;
        [self.navigationController pushViewController:vc animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableViewControllerDidFinishWithSelection:(id)selection {
    if([selection isKindOfClass:[NSArray class]]) {
        self.repeatOption = selection;
    } else if([selection isKindOfClass:[NSNumber class]]) {
        self.eventOption = ([selection intValue] + 1);
    } else if([selection isKindOfClass:[UIColor class]]) {
        self.colorOption = selection;
    }
    [self.tableView reloadData];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger retVal = 2;
    if(self.eventOption == LTEventTypeSolid) {
        retVal = 3;
    }
    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    if(indexPath.row == 0) {
        cell.textLabel.text = @"Repeat";
        cell.detailTextLabel.text = @"Never";
        NSMutableString *str = [NSMutableString string];
        NSString *detail = @"Never";
        if([self.repeatOption count] != 7) {
            for(NSNumber *a in self.repeatOption) {
                [str appendFormat:@"%@ ",[self.daysShort objectAtIndex:[a intValue]]];
            }
            if([str length] > 0) {
                detail = [str substringToIndex:str.length - 1];
            }
        } else {
            detail = @"Everyday";
        }
        cell.detailTextLabel.text = detail;
    } else if(indexPath.row == 1) {
        cell.textLabel.text = @"Event";
        cell.detailTextLabel.text = [self.events objectAtIndex:(self.eventOption - 1)];
    } else if(indexPath.row == 2) {
        cell.textLabel.text = @"Color";
        cell.textLabel.textColor = self.colorOption;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

@end
