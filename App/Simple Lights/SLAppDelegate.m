//
//  SLAppDelegate.m
//  Simple Lights
//
//  Created by Evan Coleman on 3/13/13.
//  Copyright (c) 2013 Evan Coleman. All rights reserved.
//

#import "SLAppDelegate.h"
#import "LTHomeViewController.h"
#import "LTSettingsViewController.h"
#import "LTNetworkController.h"

@implementation SLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    UIViewController *viewController0 = [[LTHomeViewController alloc] initWithNibName:@"LTHomeViewController" bundle:nil];
    UIViewController *viewController3 = [[LTSettingsViewController alloc] initWithNibName:@"LTSettingsViewController" bundle:nil];
    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[viewController0, viewController3];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    NSString *address = [NSString stringWithFormat:@"ws://%@:%@",[url host],[url port]];
    [[NSUserDefaults standardUserDefaults] setObject:address forKey:@"LTServerKey"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[LTNetworkController sharedInstance] reconnect];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[LTNetworkController sharedInstance] reconnect];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
