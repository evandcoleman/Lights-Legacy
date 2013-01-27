//
//  LTSecondViewController.m
//  Lights
//
//  Created by Evan Coleman on 1/17/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTScheduleViewController.h"
#import "LTNetworkController.h"
#import "LTAddViewController.h"

@interface LTScheduleViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)addItem:(id)sender;
- (IBAction)edit:(id)sender;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addItem:(id)sender {
    LTAddViewController *add = [[LTAddViewController alloc] initWithNibName:@"LTAddViewController" bundle:nil];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:add];
    [self presentViewController:nav animated:YES completion:^(void) {
        [self.tableView reloadData];
    }];
}

- (IBAction)edit:(id)sender {
    
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[LTNetworkController sharedInstance] schedule] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [[[LTNetworkController sharedInstance] animationOptions] objectAtIndex:indexPath.row];
    
    return cell;
}

@end
