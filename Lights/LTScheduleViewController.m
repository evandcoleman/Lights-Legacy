//
//  LTSecondViewController.m
//  Lights
//
//  Created by Evan Coleman on 1/17/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTScheduleViewController.h"
#import "LTScheduleCell.h"
#import <QuartzCore/QuartzCore.h>

@interface LTScheduleViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)addItem:(id)sender;
- (IBAction)edit:(id)sender;
- (void)toggle:(id)sender;

@end

@implementation LTScheduleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Schedule", @"Schedule");
        self.tabBarItem.image = [UIImage imageNamed:@"schedule"];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[LTNetworkController sharedInstance] openConnection];
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 0)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [[LTNetworkController sharedInstance] setDelegate:self];
    [[LTNetworkController sharedInstance] sendJSONString:[[LTNetworkController sharedInstance] json_querySchedule]];
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addItem:(id)sender {
    LTAddViewController *add = [[LTAddViewController alloc] initWithNibName:@"LTAddViewController" bundle:nil];
    add.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:add];
    [self presentViewController:nav animated:YES completion:NULL];
}

- (IBAction)edit:(id)sender {
    self.tableView.editing = !self.tableView.editing;
    if(self.tableView.editing) {
        [(UIBarButtonItem *)sender setTitle:@"Done"];
    } else {
        [(UIBarButtonItem *)sender setTitle:@"Edit"];
    }
}

- (void)didScheduleEvent {
    [self.tableView reloadData];
}

- (void)networkController:(LTNetworkController *)controller receivedMessage:(NSDictionary *)message {
    [[[LTNetworkController sharedInstance] schedule] removeAllObjects];
    NSMutableArray *events = [NSMutableArray array];
    for(NSDictionary *dict in [message objectForKey:@"events"]) {
        NSString *repeat = [dict objectForKey:@"repeat"];
        NSMutableDictionary *mut = [dict mutableCopy];
        NSArray *days = [repeat componentsSeparatedByString:@","];
        NSMutableArray *newDays = [NSMutableArray array];
        for(NSString *a in days) {
            if([a integerValue] > 0)
                [newDays addObject:[NSNumber numberWithInteger:[a integerValue]]];
        }
        [mut setObject:newDays forKey:@"repeat"];
        [mut setObject:[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"time"] doubleValue]] forKey:@"date"];
        NSArray *rgb = [dict objectForKey:@"color"];
        UIColor *color = [UIColor colorWithRed:([[rgb objectAtIndex:0] floatValue] / 255.0f) green:([[rgb objectAtIndex:1] floatValue] / 255.0f) blue:([[rgb objectAtIndex:2] floatValue] / 255.0f) alpha:1.0f];
        [mut setObject:color forKey:@"color"];
        [events addObject:mut];
    }
    [[[LTNetworkController sharedInstance] schedule] addObjectsFromArray:events];
    [self.tableView reloadData];
}

- (void)toggle:(UISwitch *)sender {
    NSMutableDictionary *dict = [[[LTNetworkController sharedInstance] schedule] objectAtIndex:sender.tag];
    [dict setObject:[NSNumber numberWithBool:sender.on] forKey:@"state"];
    
    NSDate *date = [dict objectForKey:@"date"];
    if([date timeIntervalSinceNow] < 0 && sender.on == YES) {
        NSDate *newDate = [date dateByAddingTimeInterval:3600*24];
        [dict setObject:newDate forKey:@"date"];
    }
    
    [[LTNetworkController sharedInstance] scheduleEdited];
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Table View Data Source

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[[LTNetworkController sharedInstance] schedule] removeObjectAtIndex:indexPath.row];
        [[LTNetworkController sharedInstance] scheduleEdited];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[LTNetworkController sharedInstance] schedule] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 77.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    LTScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LTScheduleCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        UIColor *end = [UIColor colorWithWhite:0.80f alpha:1.0f];
        UIColor *start = [UIColor colorWithWhite:0.95f alpha:1.0f];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = background.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[start CGColor], (id)[end CGColor], nil];
        [background.layer insertSublayer:gradient atIndex:0];
        cell.backgroundView = background;
    }
    
    NSDictionary *data = [[[LTNetworkController sharedInstance] schedule] objectAtIndex:indexPath.row];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateStyle:NSDateFormatterNoStyle];
    [df setTimeStyle:NSDateFormatterShortStyle];
    [df setTimeZone:[NSTimeZone localTimeZone]];
    cell.timeLabel.text = [df stringFromDate:[data objectForKey:@"date"]];
    
    [df setDateStyle:NSDateFormatterFullStyle];
    NSLog(@"Event Will Run On %@",[df stringFromDate:[data objectForKey:@"date"]]);

    NSArray *days = @[@"Sun",@"Mon",@"Tue",@"Wed",@"Thu",@"Fri",@"Sat"];
    NSMutableString *str = [NSMutableString string];
    NSString *detail = @"";
    if([[data objectForKey:@"repeat"] count] != 7) {
        for(NSNumber *a in [data objectForKey:@"repeat"]) {
            [str appendFormat:@"%@ ",[days objectAtIndex:[a intValue]]];
        }
        if([str length] > 0) {
            detail = [str substringToIndex:str.length - 1];
        }
    } else {
        detail = @"Everyday";
    }
    cell.repeatLabel.text = detail;
    
    NSArray *nonAnim = @[@"Solid"];
    NSArray *events = [nonAnim arrayByAddingObjectsFromArray:[[LTNetworkController sharedInstance] animationOptions]];
    cell.eventLabel.text = [events objectAtIndex:([[data objectForKey:@"event"] intValue] - 1)];
    if([[data objectForKey:@"event"] intValue] == LTEventTypeSolid) {
        cell.eventLabel.textColor = [data objectForKey:@"color"];
    } else {
        cell.eventLabel.textColor = [UIColor blackColor];
    }
    
    if([(NSDate *)[data objectForKey:@"date"] timeIntervalSinceNow] < 0 && [[data objectForKey:@"repeat"] count] == 0) {
        cell.toggleSwitch.on = NO;
    }
    [cell.toggleSwitch addTarget:self action:@selector(toggle:) forControlEvents:UIControlEventValueChanged];
    cell.toggleSwitch.tag = indexPath.row;
    
    if([data objectForKey:@"state"]) {
        cell.toggleSwitch.on = [[data objectForKey:@"state"] boolValue];
    }
    
    return cell;
}

@end
