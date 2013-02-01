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
    LTEventTypeAnimateColorWipe = 3,
    LTEventTypeQuerySchedule = 4,
    LTEventTypeFlushEvents = 5,
    LTEventTypeAnimateRainbowCycle = 6
} LTEventType;

@class LTNetworkController;

@protocol LTNetworkControllerDelegate <NSObject>
@required
- (void)networkController:(LTNetworkController *)controller receivedMessage:(NSDictionary *)message;
@end

@interface LTNetworkController : NSObject <SRWebSocketDelegate>

@property (strong, nonatomic, readonly) SRWebSocket *socket;
@property (nonatomic, strong, readonly) NSArray *animationOptions;
@property (nonatomic, strong, readonly) NSArray *animationIndexes;
@property (nonatomic, strong, readonly) NSMutableArray *colorPickers;
@property (nonatomic, strong, readonly) NSMutableArray *schedule;
@property (nonatomic, strong) NSString *server;

@property (nonatomic, weak) id<LTNetworkControllerDelegate> delegate;

+ (LTNetworkController *)sharedInstance;

- (void)openConnection;
- (void)closeConnection;
- (void)reconnect;
- (void)sendJSONString:(NSString *)message;

- (NSString *)jsonStringForDictionary:(NSDictionary *)dict;
- (NSString *)json_query;
- (NSString *)json_querySchedule;
- (NSString *)json_solidWithColor:(UIColor *)color;
- (NSString *)json_animateWithOption:(LTEventType)option;
- (NSString *)json_scheduleEvent:(NSDictionary *)dict;

- (void)scheduleEvent:(LTEventType)event date:(NSDate *)date color:(UIColor *)color repeat:(NSArray *)repeat;
- (void)scheduleEdited;

@end
