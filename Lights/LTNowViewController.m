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


- (void)pickerChanged:(id)sender;

@end

@implementation LTNowViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Now", @"Now");
        self.tabBarItem.image = [UIImage imageNamed:@"now"];
        self.colorPicker = [[KZColorPicker alloc] initWithFrame:CGRectZero];
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [(UIControl *)self.colorPicker.alphaSlider setHidden:YES];
        
        [[[LTNetworkController sharedInstance] colorPickers] addObject:self.colorPicker];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[LTNetworkController sharedInstance] openConnection];
    
    self.scrollView.contentSize = CGSizeMake(640, self.scrollView.frame.size.height);
    self.tableView.frame = CGRectMake(320.0f, 0, 320.0f, self.scrollView.frame.size.height);
    
    self.colorPicker.frame = self.view.frame;
    self.colorPicker.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.colorPicker addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
	[self.scrollView addSubview:self.colorPicker];
    [self.scrollView addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Color Picker

- (void)pickerChanged:(id)sender {
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
    NSInteger option = indexPath.row+1;
    [[LTNetworkController sharedInstance] sendJSONString:[[LTNetworkController sharedInstance] json_animateWithOption:option]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    
    return cell;
}

@end
