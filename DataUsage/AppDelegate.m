//
//  AppDelegate.m
//  DataUsage
//
//  Created by Praveen Jha on 12/03/13.
//  Copyright (c) 2013 Praveen Jha. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
    }
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    UIApplication*    app = [UIApplication sharedApplication];

    // it's better to move "dispatch_block_t expirationHandler"
    // into your headerfile and initialize the code somewhere else
    // i.e.
    // - (void)applicationDidFinishLaunching:(UIApplication *)application {
    //
    // expirationHandler = ^{ ... } }
    // because your app may crash if you initialize expirationHandler twice.
    expirationHandler = ^{

        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;


        bgTask = [app beginBackgroundTaskWithExpirationHandler:expirationHandler];
    };
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

    UIApplication*    app = [UIApplication sharedApplication];

    // it's better to move "dispatch_block_t expirationHandler"
    // into your headerfile and initialize the code somewhere else
    // i.e.
    // - (void)applicationDidFinishLaunching:(UIApplication *)application {
    //
    // expirationHandler = ^{ ... } }
    // because your app may crash if you initialize expirationHandler twice.

    bgTask = [app beginBackgroundTaskWithExpirationHandler:expirationHandler];


    // Start the long-running task and return immediately.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        // inform others to stop tasks, if you like
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MyApplicationEntersBackground" object:self];
        
        // do your background work here     
    }); 
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    UIApplication*    app = [UIApplication sharedApplication];
    [app endBackgroundTask:bgTask];

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
