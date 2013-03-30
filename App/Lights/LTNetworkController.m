//
//  LTNetworkController.m
//  Lights
//
//  Created by Evan Coleman on 1/26/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "LTNetworkController.h"
#import "LTAppDelegate.h"

static LTNetworkController *_sharedInstance = nil;
NSString *const kLTConnectionDidOpenNotification = @"LTConnectionDidOpenNotification";

@interface LTNetworkController ()

@property (strong, nonatomic) SRWebSocket *socket;
@property (nonatomic, strong) NSArray *animationOptions;
@property (nonatomic, strong) NSArray *x10CommandNames;
@property (nonatomic, strong) NSArray *animationIndexes;
@property (nonatomic, strong) NSMutableArray *colorPickers;
@property (nonatomic, strong) NSMutableArray *schedule;
@property (nonatomic, strong) NSArray *x10Devices;
@property (nonatomic, strong) NSArray *presets;

- (void)flushScheduledEvents;
- (void)sendJSONString:(NSString *)message;

- (NSString *)jsonStringForDictionary:(NSDictionary *)dict;
- (NSString *)json_query;
- (NSString *)json_getX10Devices;
- (NSString *)json_querySchedule;
- (NSString *)json_queryPresets;
- (NSString *)json_solidWithColor:(UIColor *)color;
- (NSString *)json_animateWithOption:(LTEventType)option brightness:(float)brightness speed:(float)speed;
- (NSString *)json_scheduleEvent:(NSDictionary *)dict;
- (NSString *)json_sendX10Command:(LTX10Command)command houseCode:(NSInteger)house device:(NSInteger)device;

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
        self.animationOptions = @[@"Rainbow", @"Rainbow Cycle", @"Color Wipe", @"Bounce"];
        self.animationIndexes = @[[NSNumber numberWithInt:LTEventTypeAnimateRainbow], [NSNumber numberWithInt:LTEventTypeAnimateRainbowCycle], [NSNumber numberWithInt:LTEventTypeAnimateColorWipe], [NSNumber numberWithInt:LTEventTypeAnimateBounce]];
        
        self.x10CommandNames = @[@"Off", @"On", @"Dim", @"Bright"];
        
        self.server = [[NSUserDefaults standardUserDefaults] objectForKey:@"LTServerKey"];
        [[[[[(LTAppDelegate *)[[UIApplication sharedApplication] delegate] tabBarController] viewControllers] lastObject] tabBarItem] setBadgeValue:@""];
    }
    return self;
}

- (void)openConnection {
    if(self.server) {
        if(self.socket.readyState == SR_OPEN) {
            [self.socket send:[self json_query]];
        } else if((self.socket.readyState == SR_CLOSED || self.socket.readyState == SR_CLOSING) && self.socket.readyState != SR_CONNECTING) {
            [self.socket open];
        }
    }
}

- (void)reconnect {
    if(self.server) {
        self.socket = nil;
        _socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.server]]]];
        self.socket.delegate = self;
        [self.socket open];
    }
}

- (void)closeConnection {
    if(self.socket.readyState == SR_OPEN) {
        [self.socket closeWithCode:100 reason:@"App"];
        self.socket = nil;
    }
}

- (void)animateWithOption:(LTEventType)option brightness:(float)brightness speed:(float)speed {
    [self sendJSONString:[self json_animateWithOption:option brightness:brightness speed:speed]];
}

- (void)solidWithColor:(UIColor *)color {
    [self sendJSONString:[self json_solidWithColor:color]];
}

- (void)scheduleEvent:(LTEventType)event date:(NSDate *)date color:(UIColor *)color repeat:(NSArray *)repeat {
    NSDictionary *dict = @{@"event" : [NSNumber numberWithInt:event], @"date" : date, @"color" : color, @"repeat" : repeat};
    [self.schedule addObject:dict];
    [self sendJSONString:[self json_scheduleEvent:dict]];
}

- (void)scheduleEdited {
    [self flushScheduledEvents];
    for(NSDictionary *dict in self.schedule) {
        [self sendJSONString:[self json_scheduleEvent:dict]];
    }
}

- (void)queryColor {
    [self sendJSONString:[self json_query]];
}

- (void)querySchedule {
    [self sendJSONString:[self json_querySchedule]];
}

- (void)queryX10DevicesWithDelegate:(id<LTNetworkControllerDelegate>)delegate {
    self.delegate = delegate;
    [self sendJSONString:[self json_getX10Devices]];
}

- (void)sendX10Command:(LTX10Command)command houseCode:(NSInteger)house device:(NSInteger)device {
    [self sendJSONString:[self json_sendX10Command:command houseCode:house device:device]];
}

- (void)queryPresetsWithDelegate:(id<LTNetworkControllerDelegate>)delegate {
    self.delegate = delegate;
    [self sendJSONString:[self json_queryPresets]];
}

- (NSMutableArray *)schedule {
    if(_schedule != nil) {
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        [_schedule sortUsingDescriptors:@[sort]];
    }
    return _schedule;
}

#pragma mark - Private Methods

- (void)sendJSONString:(NSString *)message {
    //NSLog(@"Sending: %@",message);
    [self.socket send:message];
}

- (void)flushScheduledEvents {
    [self.socket send:[self jsonStringForDictionary:@{@"event" : [NSNumber numberWithInt:LTEventTypeFlushEvents]}]];
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

- (NSString *)json_querySchedule {
    return [self jsonStringForDictionary:@{@"event" : [NSNumber numberWithInt:LTEventTypeQuerySchedule]}];
}

- (NSString *)json_queryPresets {
    return [self jsonStringForDictionary:@{@"event" : [NSNumber numberWithInt:LTEventTypeQueryPresets]}];
}

- (NSString *)json_getX10Devices {
    return [self jsonStringForDictionary:@{@"event" : [NSNumber numberWithInt:LTEventTypeGetX10Devices]}];
}

- (NSString *)json_sendX10Command:(LTX10Command)command houseCode:(NSInteger)house device:(NSInteger)device {
    return [self jsonStringForDictionary:@{@"event" : [NSNumber numberWithInt:LTEventTypeX10Command], @"command" : [NSNumber numberWithInt:command], @"houseCode" : [NSNumber numberWithInt:house], @"device" : [NSNumber numberWithInt:device]}];
}

- (NSString *)json_solidWithColor:(UIColor *)color {
    CGFloat red = 0.0f; CGFloat green = 0.0f; CGFloat blue = 0.0f; CGFloat alpha = 0.0f;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    NSNumber *r = [NSNumber numberWithInt:red*255];
    NSNumber *g = [NSNumber numberWithInt:green*255];
    NSNumber *b = [NSNumber numberWithInt:blue*255];
    return [self jsonStringForDictionary:@{@"event" : [NSNumber numberWithInt:LTEventTypeSolid], @"color" : @[r, g, b]}];
}

- (NSString *)json_animateWithOption:(LTEventType)option brightness:(float)brightness speed:(float)speed {
    return [self jsonStringForDictionary:@{@"event" : [NSNumber numberWithInt:option], @"brightness" : [NSNumber numberWithInt:brightness], @"speed" : [NSNumber numberWithInt:speed]}];
}

- (NSString *)json_scheduleEvent:(NSDictionary *)dict {
    CGFloat red = 0.0f; CGFloat green = 0.0f; CGFloat blue = 0.0f; CGFloat alpha = 0.0f;
    [[dict objectForKey:@"color"] getRed:&red green:&green blue:&blue alpha:&alpha];
    NSNumber *r = [NSNumber numberWithInt:red*255];
    NSNumber *g = [NSNumber numberWithInt:green*255];
    NSNumber *b = [NSNumber numberWithInt:blue*255];
    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    [message setObject:@[r, g, b] forKey:@"color"];
    [message setObject:[dict objectForKey:@"event"] forKey:@"event"];
    [message setObject:[NSNumber numberWithDouble:[[dict objectForKey:@"date"] timeIntervalSince1970]] forKey:@"time"];
    NSMutableString *repeat = [NSMutableString string];
    for(NSNumber *a in [dict objectForKey:@"repeat"]) {
        [repeat appendFormat:@",%i",([a integerValue])];
    }
    if([repeat hasPrefix:@","]) {
        [message setObject:[repeat substringFromIndex:1] forKey:@"repeat"];
    } else {
        [message setObject:repeat forKey:@"repeat"];
    }
    [message setObject:[[NSTimeZone localTimeZone] name] forKey:@"timeZone"];
    if([dict objectForKey:@"state"] != nil) {
        [message setObject:[dict objectForKey:@"state"] forKey:@"state"];
    } else {
        [message setObject:[NSNumber numberWithBool:YES] forKey:@"state"];
    }
    return [self jsonStringForDictionary:message];
}

#pragma mark - SocketRocket Delegate

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    //[webSocket send:[self json_query]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLTConnectionDidOpenNotification object:nil];
    [[[[[(LTAppDelegate *)[[UIApplication sharedApplication] delegate] tabBarController] viewControllers] lastObject] tabBarItem] setBadgeValue:nil];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"%@",error);
    [[[[[(LTAppDelegate *)[[UIApplication sharedApplication] delegate] tabBarController] viewControllers] lastObject] tabBarItem] setBadgeValue:@""];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    //NSLog(@"Received: %@",message);
    if([message hasPrefix:@"currentState"]) {
        NSString *command  = [message stringByReplacingOccurrencesOfString:@"currentState: " withString:@""];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[command dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LTReceivedQueryNotification" object:nil userInfo:dict];
    } else {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        if([[dict objectForKey:@"event"] integerValue] == LTEventTypeQuerySchedule) {
            if(self.delegate != nil) {
                [self.delegate networkController:self receivedMessage:dict];
            }
        } else if([[dict objectForKey:@"event"] integerValue] == LTEventTypeGetX10Devices) {
            self.x10Devices = [[dict objectForKey:@"devices"] copy];
            if(self.delegate != nil) {
                [self.delegate networkController:self receivedMessage:dict];
            }
        } else if([[dict objectForKey:@"event"] integerValue] == LTEventTypeQueryPresets) {
            self.presets = [[dict objectForKey:@"presets"] copy];
            if(self.delegate != nil) {
                [self.delegate networkController:self receivedMessage:dict];
            }
        }
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    [[[[[(LTAppDelegate *)[[UIApplication sharedApplication] delegate] tabBarController] viewControllers] lastObject] tabBarItem] setBadgeValue:@""];
}

@end
