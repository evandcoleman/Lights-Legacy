//
//  LTAppDelegate.h
//  Lights
//
//  Created by Evan Coleman on 1/17/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LTAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *tabBarController;

@end
