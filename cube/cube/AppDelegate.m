/*
 ******************************************************************************
 * AppDelegate.m -
 *
 * Copyright (c) 2015-2016 by ZealTek Electronic Co., Ltd.
 *
 * This software is copyrighted by and is the property of ZealTek
 * Electronic Co., Ltd. All rights are reserved by ZealTek Electronic
 * Co., Ltd. This software may only be used in accordance with the
 * corresponding license agreement. Any unauthorized use, duplication,
 * distribution, or disclosure of this software is expressly forbidden.
 *
 * This Copyright notice MUST not be removed or modified without prior
 * written consent of ZealTek Electronic Co., Ltd.
 *
 * ZealTek Electronic Co., Ltd. reserves the right to modify this
 * software without notice.
 *
 * History:
 *	2015.01.16	T.C. Chiu	frist edition
 *
 ******************************************************************************
 */

#import "AppDelegate.h"

#import "PlanViewController.h"

/*
 ******************************************************************************
 *
 * for debug
 *
 ******************************************************************************
 */
#define LOGGING_LEVEL_APPDELEGATE       1
#include "DbgMsg.h"

#if defined(LOGGING_LEVEL_APPDELEGATE) && LOGGING_LEVEL_APPDELEGATE
#define dmsg(fmt, ...)      LOG_FORMAT(fmt, @"APP", ##__VA_ARGS__)
#else
#define dmsg(...)
#endif

#define msg(fmt, ...)       LOG_FORMAT(fmt, @"APP", ##__VA_ARGS__)


/*
 ******************************************************************************
 *
 * @interface
 *
 ******************************************************************************
 */
@interface AppDelegate ()

@end


/*
 ******************************************************************************
 *
 * @implementation
 *
 ******************************************************************************
 */
@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

//    if (application.applicationState != UIApplicationStateBackground) {
        sleep(2.0);
//    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    dmsg(@"applicationDidEnterBackground:");

    bgTask = [application beginBackgroundTaskWithExpirationHandler: ^{
        // when backgroundTimeRemaining = 0, then execute
        dmsg(@"expiration");
        [application endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        //--- background task starts
//        int timeRemaining;
//        int count = 20;
//
//        while (TRUE) {
//            timeRemaining = (int)[[UIApplication sharedApplication] backgroundTimeRemaining];
//            [NSThread sleepForTimeInterval:1];      // wait for 1 sec
//
//            if (!timeRemaining) {
//                if (!count) {
//                    dmsg(@"stop");
//                    [application endBackgroundTask:bgTask];
//                    bgTask = UIBackgroundTaskInvalid;
//                } else {
//                    count--;
//                }
//            } else {
//                count = 20;
//            }
//            dmsg(@"time remaining: %0ds (%0d)", timeRemaining, count);
//        }
//        //--- background task ends
//    });

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    dmsg(@"applicationWillEnterForeground:");

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}





@end
