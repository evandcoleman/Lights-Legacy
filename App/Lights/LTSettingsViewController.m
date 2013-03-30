//
//  LTSettingsViewController.m
//  Lights
//
//  Created by Evan Coleman on 1/31/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTSettingsViewController.h"
#import "LTNetworkController.h"

@interface LTSettingsViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;

- (IBAction)reconnect:(id)sender;
- (void)tappedView:(UIGestureRecognizer *)gesture;

@end

@implementation LTSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"Settings", @"Settings");
        self.tabBarItem.image = [UIImage imageNamed:@"gear"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedView:)];
    [self.view addGestureRecognizer:tap];
    self.textField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"LTServerKey"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)reconnect:(id)sender {
    [self.textField resignFirstResponder];
    [[NSUserDefaults standardUserDefaults] setObject:self.textField.text forKey:@"LTServerKey"];
    [[LTNetworkController sharedInstance] setServer:self.textField.text];
    [[LTNetworkController sharedInstance] reconnect];
}

- (void)tappedView:(UIGestureRecognizer *)gesture {
    [self.textField resignFirstResponder];
}

@end
