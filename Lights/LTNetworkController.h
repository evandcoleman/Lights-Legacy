//
//  LTNetworkController.h
//  Lights
//
//  Created by Evan Coleman on 1/26/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

typedef enum {
    LTEventTypeQuery = 0,
    LTEventTypeSolid = 1,
    LTEventTypeAnimateRainbow = 2,
    LTEventTypeAnimateColorWipe = 3
} LTEventType;


@interface LTNetworkController : NSObject <SRWebSocketDelegate>

@property (strong, nonatomic, readonly) SRWebSocket *socket;
@property (nonatomic, strong, readonly) NSArray *animationOptions;
@property (nonatomic, strong, readonly) NSMutableArray *colorPickers;
@property (nonatomic, strong, readonly) NSMutableArray *schedule;

+ (LTNetworkController *)sharedInstance;

- (void)openConnection;
- (void)sendJSONString:(NSString *)message;

- (NSString *)jsonStringForDictionary:(NSDictionary *)dict;
- (NSString *)json_query;
- (NSString *)json_solidWithColor:(UIColor *)color;
- (NSString *)json_animateWithOption:(LTEventType)option;

- (void)scheduleEvent:(LTEventType)event date:(NSDate *)date color:(UIColor *)color;

@end
