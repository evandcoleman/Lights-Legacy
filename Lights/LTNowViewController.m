//
//  LTFirstViewController.m
//  Lights
//
//  Created by Evan Coleman on 1/17/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTNowViewController.h"
#import "KZColorPicker.h"
#import "LTNetworkController.h"

@interface LTNowViewController ()

@property (nonatomic, strong) KZColorPicker *colorPicker;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UISlider *speedSlider;
@property (strong, nonatomic) UISlider *brightSlider;

@property (nonatomic, assign) NSInteger currentOption;


- (void)pickerChanged:(id)sender;
- (void)brightnessChanged:(id)sender;
- (void)speedChanged:(id)sender;
- (void)didReceiveQueryResponse:(NSNotification *)notification;

@end

@implementation LTNowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Now", @"Now");
        self.tabBarItem.image = [UIImage imageNamed:@"now"];
        self.currentOption = -1;
        _colorPicker = [[KZColorPicker alloc] initWithFrame:CGRectZero];
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [(UIControl *)self.colorPicker.alphaSlider setHidden:YES];
        
        _speedSlider = [[UISlider alloc] initWithFrame:CGRectZero];
        self.speedSlider.minimumValueImage = [UIImage imageNamed:@"turtle"];
        self.speedSlider.maximumValueImage = [UIImage imageNamed:@"rabbit"];
        self.speedSlider.minimumValue = 1.0f;
        self.speedSlider.maximumValue = 200.0f;
        self.speedSlider.continuous = NO;
        [self.speedSlider addTarget:self action:@selector(speedChanged:) forControlEvents:UIControlEventValueChanged];
        _brightSlider = [[UISlider alloc] initWithFrame:CGRectZero];
        self.brightSlider.minimumValueImage = [UIImage imageNamed:@"dark"];
        self.brightSlider.maximumValueImage = [UIImage imageNamed:@"now"];
        self.brightSlider.minimumValue = 100.0f;
        self.brightSlider.maximumValue = 255.0f;
        self.brightSlider.continuous = NO;
        [self.brightSlider addTarget:self action:@selector(brightnessChanged:) forControlEvents:UIControlEventValueChanged];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveQueryResponse:) name:@"LTReceivedQueryNotification" object:nil];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[LTNetworkController sharedInstance] openConnection];
    
    self.scrollView.backgroundColor = self.colorPicker.backgroundColor;
    self.scrollView.delaysContentTouches = NO;
    
    self.scrollView.contentSize = CGSizeMake(640, self.scrollView.frame.size.height);
    self.tableView.frame = CGRectMake(320.0f, 0, 320.0f, self.scrollView.frame.size.height/1.5);
    
    self.colorPicker.frame = CGRectMake(0, 0, self.view.frame.size.width, self.scrollView.frame.size.height);
    //self.colorPicker.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    //self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
	[self.colorPicker addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
	[self.scrollView addSubview:self.colorPicker];
    [self.scrollView addSubview:self.tableView];
    
    self.speedSlider.frame = CGRectMake(340.0f, (self.scrollView.frame.size.height/1.5) + 40.0f, 280.0f, 20);
    self.brightSlider.frame = CGRectMake(340.0f, self.speedSlider.frame.origin.y + 55.0f, 280.0f, 20);
    self.brightSlider.value = 255.0f;
    [self.scrollView addSubview:self.speedSlider];
    [self.scrollView addSubview:self.brightSlider];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didReceiveQueryResponse:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;
    if([[dict objectForKey:@"event"] integerValue] == LTEventTypeSolid) {
        NSArray *rgb = [dict objectForKey:@"color"];
        UIColor *color = [UIColor colorWithRed:[[rgb objectAtIndex:0] floatValue]/255.0f green:[[rgb objectAtIndex:1] floatValue]/255.0f blue:[[rgb objectAtIndex:2] floatValue]/255.0f alpha:1.0f];
        self.colorPicker.selectedColor = color;
    } else if(dict == nil) {
        self.colorPicker.selectedColor = [UIColor blackColor];
    } else {
        self.speedSlider.value = (self.speedSlider.maximumValue - [[dict objectForKey:@"speed"] integerValue]);
        self.brightSlider.value = [[dict objectForKey:@"brightness"] integerValue];
        self.currentOption = [[dict objectForKey:@"event"] integerValue];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        
        [self.scrollView setContentOffset:CGPointMake(320.0f, 0.0f) animated:YES];
    }
}

#pragma mark - Sliders

- (void)brightnessChanged:(id)sender {
    if(self.currentOption >= 0) {
        [[LTNetworkController sharedInstance] sendJSONString:[[LTNetworkController sharedInstance] json_animateWithOption:self.currentOption brightness:self.brightSlider.value speed:(self.speedSlider.maximumValue - self.speedSlider.value)]];
    }
}

- (void)speedChanged:(id)sender {
    if(self.currentOption >= 0) {
        [[LTNetworkController sharedInstance] sendJSONString:[[LTNetworkController sharedInstance] json_animateWithOption:self.currentOption brightness:self.brightSlider.value speed:(self.speedSlider.maximumValue - self.speedSlider.value)]];
    }
}

#pragma mark - Color Picker

- (void)pickerChanged:(id)sender {
    self.currentOption = -1;
    [self.tableView reloadData];
    [[LTNetworkController sharedInstance] sendJSONString:[[LTNetworkController sharedInstance] json_solidWithColor:self.colorPicker.selectedColor]];
}

#pragma mark - Scroll View Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.currentOption = [[[[LTNetworkController sharedInstance] animationIndexes] objectAtIndex:indexPath.row] integerValue];
    switch (self.currentOption) {
        case LTEventTypeAnimateColorWipe:
            self.speedSlider.value = (self.speedSlider.maximumValue - 50.0f);
            break;
        case LTEventTypeAnimateRainbow:
            self.speedSlider.value = (self.speedSlider.maximumValue - 20.0f);
            break;
        case LTEventTypeAnimateRainbowCycle:
            self.speedSlider.value = (self.speedSlider.maximumValue - 20.0f);
            break;
        default:
            break;
    }
    [[LTNetworkController sharedInstance] sendJSONString:[[LTNetworkController sharedInstance] json_animateWithOption:self.currentOption brightness:self.brightSlider.value speed:(self.speedSlider.maximumValue - self.speedSlider.value)]];
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[LTNetworkController sharedInstance] animationOptions] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [[[LTNetworkController sharedInstance] animationOptions] objectAtIndex:indexPath.row];
    if([[[LTNetworkController sharedInstance] animationIndexes] indexOfObject:[NSNumber numberWithInt:self.currentOption]] == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

@end
