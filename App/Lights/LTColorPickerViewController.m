//
//  LTColorPickerViewController.m
//  Lights
//
//  Created by Evan Coleman on 1/26/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTColorPickerViewController.h"

@interface LTColorPickerViewController ()

@end

@implementation LTColorPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _colorPicker = [[KZColorPicker alloc] initWithFrame:CGRectZero];
        [(UIControl *)self.colorPicker.alphaSlider setHidden:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.colorPicker.frame = self.view.frame;
    self.colorPicker.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:self.colorPicker];
    self.navigationItem.hidesBackButton = self.hidesBackButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.delegate colorPickerDidFinish:self.colorPicker.selectedColor];
    [super viewWillDisappear:animated];
}

@end
