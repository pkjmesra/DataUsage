//
//  AppDelegate.h
//  DataUsage
//
//  Created by Praveen Jha on 12/03/13.
//  Copyright (c) 2013 Praveen Jha. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

UIBackgroundTaskIdentifier bgTask;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    dispatch_block_t expirationHandler;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@end
