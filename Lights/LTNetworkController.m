//
//  LTNetworkController.m
//  Lights
//
//  Created by Evan Coleman on 1/26/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTNetworkController.h"

static LTNetworkController *_sharedInstance = nil;

@interface LTNetworkController ()

@property (strong, nonatomic) SRWebSocket *socket;
@property (nonatomic, strong) NSArray *animationOptions;
@property (nonatomic, strong) NSMutableArray *colorPickers;
@property (nonatomic, strong) NSMutableArray *schedule;

@end

@implementation LTNetworkController

+ (LTNetworkController *)sharedInstance {
    if(_sharedInstance == nil) {
        _sharedInstance = [[LTNetworkController alloc] init];
    }
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if(self) {
        self.colorPickers = [NSMutableArray array];
        self.schedule = [NSMutableArray array];
        self.animationOptions = @[@"Rainbow", @"Color Wipe"];
        
        _socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"ws://evancoleman.net:9000/"]]];
        self.socket.delegate = self;
    }
    return self;
}

- (void)openConnection {
    if(self.socket.readyState == SR_OPEN) {
        [self.socket send:[self json_query]];
    } else if(self.socket.readyState == SR_CLOSED || self.socket.readyState == SR_CLOSING/* || self.socket.readyState == SR_CONNECTING*/) {
        [self.socket open];
    }
}

- (void)sendJSONString:(NSString *)message {
    [self.socket send:message];
}

- (void)scheduleEvent:(LTEventType)event date:(NSDate *)date color:(UIColor *)color {
    NSDictionary *dict = @{@"event" : [NSNumber numberWithInt:event], @"date" : date, @"color" : color};
    [self.schedule addObject:dict];
}

#pragma mark - JSON Strings

- (NSString *)jsonStringForDictionary:(NSDictionary *)dict {
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *retVal = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return retVal;
}

- (NSString *)json_query {
    return [self jsonStringForDictionary:@{@"event" : [NSNumber numberWithInt:LTEventTypeQuery]}];
}

- (NSString *)json_solidWithColor:(UIColor *)color {
    CGFloat red = 0.0f; CGFloat green = 0.0f; CGFloat blue = 0.0f; CGFloat alpha = 0.0f;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    NSNumber *r = [NSNumber numberWithInt:red*255];
    NSNumber *g = [NSNumber numberWithInt:green*255];
    NSNumber *b = [NSNumber numberWithInt:blue*255];
    return [self jsonStringForDictionary:@{@"event" : [NSNumber numberWithInt:LTEventTypeSolid], @"color" : @[r, g, b]}];
}

- (NSString *)json_animateWithOption:(LTEventType)option {
    return [self jsonStringForDictionary:@{@"event" : [NSNumber numberWithInt:option]}];
}

#pragma mark - SocketRocket Delegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    [webSocket send:[self json_query]];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSLog(@"Received: %@",message);
    if([message hasPrefix:@"currentState"]) {
        NSString *command  = [message stringByReplacingOccurrencesOfString:@"currentState: " withString:@""];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[command dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        if([[dict objectForKey:@"event"] integerValue] == LTEventTypeSolid) {
            NSArray *rgb = [dict objectForKey:@"color"];
            UIColor *color = [UIColor colorWithRed:[[rgb objectAtIndex:0] floatValue]/255.0f green:[[rgb objectAtIndex:1] floatValue]/255.0f blue:[[rgb objectAtIndex:2] floatValue]/255.0f alpha:1.0f];
            [self.colorPickers makeObjectsPerformSelector:@selector(setSelectedColor:) withObject:color];
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    
}

@end
