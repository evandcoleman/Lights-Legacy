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
#import "LTPresetAddViewController.h"
#import "LTPresetDetailViewController.h"
#import "MBProgressHUD.h"

@interface LTHomeViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIBarButtonItem *addButton;
@property (nonatomic, strong) UIBarButtonItem *editButton;
@property (nonatomic, readonly, weak) NSArray *devices;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) RNBlurModalView *modal;
@property (nonatomic, readonly, weak) NSArray *presets;

- (void)changedSegment:(id)sender;
- (void)addPreset:(id)sender;
- (void)editPresets:(id)sender;

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
        #ifndef SIMPLE
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Devices",@"Presets"]];
        self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        self.segmentedControl.selectedSegmentIndex = 0;
        [self.segmentedControl addTarget:self action:@selector(changedSegment:) forControlEvents:UIControlEventValueChanged];
        
        _addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPreset:)];
        _editButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(editPresets:)];
        #endif
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionDidOpen:) name:kLTConnectionDidOpenNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationBar.topItem.titleView = self.segmentedControl;
    
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

#pragma mark - Interface Actions

- (void)changedSegment:(id)sender {
    if(self.segmentedControl.selectedSegmentIndex == 1) {
        [[LTNetworkController sharedInstance] queryPresetsWithDelegate:self];
        self.navigationBar.topItem.rightBarButtonItem = self.addButton;
        self.navigationBar.topItem.leftBarButtonItem = self.editButton;
    } else {
        self.navigationBar.topItem.rightBarButtonItem = nil;
        self.navigationBar.topItem.leftBarButtonItem = nil;
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)addPreset:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Preset" message:@"Enter a title for this preset." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Next", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)editPresets:(id)sender {
    if(self.tableView.editing) {
        [self.tableView setEditing:NO animated:YES];
        self.editButton.style = UIBarButtonItemStyleBordered;
        self.editButton.title = @"Edit";
    } else {
        [self.tableView setEditing:YES animated:YES];
        self.editButton.style = UIBarButtonItemStyleDone;
        self.editButton.title = @"Done";
    }
}

#pragma mark - Network Methods

- (void)networkController:(LTNetworkController *)controller receivedMessage:(NSDictionary *)message {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (NSArray *)devices {
    return [[LTNetworkController sharedInstance] x10Devices];
}

- (NSArray *)presets {
    return [[LTNetworkController sharedInstance] presets];
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
    if(self.segmentedControl.selectedSegmentIndex == 0) {
        self.modal = nil;
        if(indexPath.row < 2) {
            /*NSString *action = @"Turning Off";
            LTX10Command command = LTX10CommandOff;
            if(indexPath.row == 0) {
                command = LTX10CommandOn;
                action = @"Turning On";
            }
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                for(int i=0;i<self.devices.count;i++) {
                    hud.labelText = [NSString stringWithFormat:@"%@ %@...",action,[[self.devices objectAtIndex:i] objectForKey:@"name"]];
                    self.selectedIndex = i;
                    [self sendCommand:command];
                    sleep(1);
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hide:YES];
                });
            });*/
            LTX10Command command = LTX10CommandAllUnitsOff;
            if(indexPath.row == 0) {
                command = LTX10CommandAllUnitsOn;
            }
            [self sendCommand:command];
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
    } else if(self.segmentedControl.selectedSegmentIndex == 1) {
        if(tableView.editing) {
            LTPresetDetailViewController *vc = [[LTPresetDetailViewController alloc] initWithNibName:@"LTPresetDetailViewController" bundle:nil];
            vc.preset = [self.presets objectAtIndex:indexPath.row];
            vc.title = [vc.preset objectForKey:@"name"];
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
            nav.navigationBar.barStyle = UIBarStyleBlackOpaque;
            [self presentViewController:nav animated:YES completion:NULL];
        } else {
            NSArray *events = [[self.presets objectAtIndex:indexPath.row] objectForKey:@"actions"];
            for(NSDictionary *event in events) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    LTEventType type = [[event objectForKey:@"event"] integerValue];
                    if(type == -1) {
                        sleep([[event objectForKey:@"sleep"] integerValue]);
                    }else if(type == LTEventTypeSolid) {
                        NSArray *rgb = [event objectForKey:@"color"];
                        UIColor *color = [UIColor colorWithRed:[[rgb objectAtIndex:0] floatValue]/255 green:[[rgb objectAtIndex:1] floatValue]/255 blue:[[rgb objectAtIndex:2] floatValue]/255 alpha:1.0];
                        [[LTNetworkController sharedInstance] solidWithColor:color];
                    } else if(type == LTEventTypeX10Command) {
                        [[LTNetworkController sharedInstance] sendX10Command:[[event objectForKey:@"command"] integerValue] houseCode:[[event objectForKey:@"houseCode"] integerValue] device:[[event objectForKey:@"device"] integerValue]];
                    } else {
                        //Animation
                        [[LTNetworkController sharedInstance] animateWithOption:type brightness:[[event objectForKey:@"brightness"] floatValue] speed:[[event objectForKey:@"speed"] floatValue]];
                    }
                });
            }
        }
    }
    
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger *retVal = 0;
    if(self.segmentedControl.selectedSegmentIndex == 0) {
        retVal = [self.devices count]+2;
    } else if(self.segmentedControl.selectedSegmentIndex == 1) {
        retVal = [self.presets count];
    }
    return retVal;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(self.segmentedControl.selectedSegmentIndex == 0) {
        if(indexPath.row == 0) {
            cell.textLabel.text = @"All On";
        } else if(indexPath.row == 1) {
            cell.textLabel.text = @"All Off";
        } else {
            cell.textLabel.text = [[self.devices objectAtIndex:indexPath.row-2] objectForKey:@"name"];
        }
    } else if(self.segmentedControl.selectedSegmentIndex == 1) {
        cell.textLabel.text = [[self.presets objectAtIndex:indexPath.row] objectForKey:@"name"];
        cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        LTPresetDetailViewController *vc = [[LTPresetDetailViewController alloc] initWithNibName:@"LTPresetDetailViewController" bundle:nil];
        vc.preset = [NSMutableDictionary dictionaryWithObject:[[alertView textFieldAtIndex:0] text] forKey:@"name"];
        [vc.preset setObject:[NSMutableArray array] forKey:@"actions"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.navigationBar.barStyle = UIBarStyleBlackOpaque;
        [self presentViewController:nav animated:YES completion:^{
            [vc add:nil];
        }];
    }
}

@end
