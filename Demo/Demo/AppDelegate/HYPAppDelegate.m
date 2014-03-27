//
//  HYPAppDelegate.m
//  Demo
//
//  Created by Elvis Nunez on 26/03/14.
//  Copyright (c) 2014 Hyper. All rights reserved.
//

#import "HYPAppDelegate.h"
#import "HYPMainViewController.h"

@implementation HYPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    HYPMainViewController *mainController = [[HYPMainViewController alloc] initWithNibName:@"HYPMainView" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainController];
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
