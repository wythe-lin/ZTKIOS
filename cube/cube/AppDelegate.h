//
//  AppDelegate.h
//  cube
//
//  Created by Ｗythe on 2015/1/15.
//  Copyright (c) 2015年 Zealtek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    __block UIBackgroundTaskIdentifier  bgTask;
}

@property (strong, nonatomic) UIWindow *window;

@end

