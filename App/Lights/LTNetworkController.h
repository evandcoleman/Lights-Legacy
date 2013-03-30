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
    LTEventTypeAnimateRainbowCycle = 6,
    LTEventTypeAnimateBounce = 7,
    LTEventTypeGetX10Devices = 8,
    LTEventTypeX10Command = 9,
    LTEventTypeQueryPresets = 10
} LTEventType;

typedef enum {
    LTX10CommandOff = 0,
    LTX10CommandOn = 1,
    LTX10CommandDim = 2,
    LTX10CommandBright = 3,
    LTX10CommandAllUnitsOff = 4,
    LTX10CommandAllUnitsOn = 5
} LTX10Command;

typedef enum {
    LTX10DeviceAppliance = 0,
    LTX10DeviceLamp = 1
} LTX10Device;

extern NSString *const kLTConnectionDidOpenNotification;

@class LTNetworkController;

@protocol LTNetworkControllerDelegate <NSObject>
@required
- (void)networkController:(LTNetworkController *)controller receivedMessage:(NSDictionary *)message;
@end

@interface LTNetworkController : NSObject <SRWebSocketDelegate>

@property (strong, nonatomic, readonly) SRWebSocket *socket;
@property (nonatomic, strong, readonly) NSArray *animationOptions;
@property (nonatomic, strong, readonly) NSArray *x10CommandNames;
@property (nonatomic, strong, readonly) NSArray *animationIndexes;
@property (nonatomic, strong, readonly) NSMutableArray *schedule;
@property (nonatomic, strong, readonly) NSArray *x10Devices;
@property (nonatomic, strong, readonly) NSArray *presets;
@property (nonatomic, strong) NSString *server;

@property (nonatomic, weak) id<LTNetworkControllerDelegate> delegate;

+ (LTNetworkController *)sharedInstance;

- (void)openConnection;
- (void)closeConnection;
- (void)reconnect;

- (void)animateWithOption:(LTEventType)option brightness:(float)brightness speed:(float)speed;
- (void)solidWithColor:(UIColor *)color;
- (void)queryColor;

- (void)scheduleEvent:(LTEventType)event date:(NSDate *)date color:(UIColor *)color repeat:(NSArray *)repeat;
- (void)scheduleEdited;
- (void)querySchedule;

- (void)queryX10DevicesWithDelegate:(id<LTNetworkControllerDelegate>)delegate;
- (void)sendX10Command:(LTX10Command)command houseCode:(NSInteger)house device:(NSInteger)device;

- (void)queryPresetsWithDelegate:(id<LTNetworkControllerDelegate>)delegate;

@end
