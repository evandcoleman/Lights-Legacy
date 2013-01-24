//
//  LTFirstViewController.m
//  Lights
//
//  Created by Evan Coleman on 1/17/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTNowViewController.h"
#import "KZColorPicker.h"

@interface LTNowViewController ()

@property (nonatomic, strong) KZColorPicker *colorPicker;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollVIew;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) SRWebSocket *socket;

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
        
        _socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://evancoleman.net:9000/"]]];
        self.socket.delegate = self;
        [self.socket open];
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.colorPicker.frame = self.view.frame;
    self.colorPicker.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[self.colorPicker addTarget:self action:@selector(pickerChanged:) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:self.colorPicker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Color Picker

- (void)pickerChanged:(id)sender {
    CGFloat red = 0.0f; CGFloat green = 0.0f; CGFloat blue = 0.0f; CGFloat alpha = 0.0f;
    [self.colorPicker.selectedColor getRed:&red green:&green blue:&blue alpha:&alpha];
    NSString *color = [NSString stringWithFormat:@"solid %0.0f,%0.0f,%0.0f,",red*255,green*255,blue*255];
    NSLog(@"%@",color);
    [self.socket send:color];
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    /*NSDictionary *message = @{@"event" : @"subscribe", @"data" : @{@"channel" : @"lights_channel"}};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:message options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",jsonString);
    [self.socket send:jsonString];*/
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"Received: %@",message);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
}

@end
