//
//  LTHomeViewController.m
//  Lights
//
//  Created by Evan Coleman on 2/16/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTHomeViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RNBlurModalView.h"
#import "LTX10LampView.h"

@interface LTHomeViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, readonly, weak) NSArray *devices;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) RNBlurModalView *modal;

- (void)connectionDidOpen:(NSNotification *)notification;
- (void)sendCommand:(LTX10Command)command;
- (void)sendOn:(id)sender;
- (void)sendOff:(id)sender;
- (void)sendBright:(id)sender;
- (void)sendDim:(id)sender;

@end

@implementation LTHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Home", @"Home");
        self.tabBarItem.image = [UIImage imageNamed:@"house"];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionDidOpen:) name:kLTConnectionDidOpenNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[LTNetworkController sharedInstance] openConnection];
    if(self.devices == nil) {
        [[LTNetworkController sharedInstance] queryX10DevicesWithDelegate:self];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)networkController:(LTNetworkController *)controller receivedMessage:(NSDictionary *)message {
    [self.tableView reloadData];
}

- (NSArray *)devices {
    return [[LTNetworkController sharedInstance] x10Devices];
}

- (void)connectionDidOpen:(NSNotification *)notification {
    if(self.devices == nil) {
        [[LTNetworkController sharedInstance] queryX10DevicesWithDelegate:self];
    }
}

#pragma mark - Send Commands

- (void)sendCommand:(LTX10Command)command {
    NSDictionary *dict = [self.devices objectAtIndex:self.selectedIndex];
    [[LTNetworkController sharedInstance] sendX10Command:command houseCode:[[dict objectForKey:@"houseCode"] integerValue] device:[[dict objectForKey:@"deviceID"] integerValue]];
    if([[dict objectForKey:@"type"] integerValue] != LTX10DeviceLamp) {
        [self.modal hide];
        self.modal = nil;
    }
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

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.modal = nil;
    if(indexPath.row < 2) {
        LTX10Command command = LTX10CommandOff;
        if(indexPath.row == 0) {
            command = LTX10CommandOn;
        }
        for(int i=0;i<self.devices.count;i++) {
            self.selectedIndex = i;
            [self sendCommand:command];
        }
    } else {
        self.selectedIndex = indexPath.row-2;
        NSDictionary *dict = [self.devices objectAtIndex:indexPath.row-2];
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
    
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:-0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.devices count]+2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        /*UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
        UIColor *end = [UIColor colorWithWhite:0.80f alpha:1.0f];
        UIColor *start = [UIColor colorWithWhite:0.95f alpha:1.0f];
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = background.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[start CGColor], (id)[end CGColor], nil];
        [background.layer insertSublayer:gradient atIndex:0];
        cell.backgroundView = background;*/
    }
    
    if(indexPath.row == 0) {
        cell.textLabel.text = @"All On";
    } else if(indexPath.row == 1) {
        cell.textLabel.text = @"All Off";
    } else {
        cell.textLabel.text = [[self.devices objectAtIndex:indexPath.row-2] objectForKey:@"name"];
    }
    
    return cell;
}

@end
