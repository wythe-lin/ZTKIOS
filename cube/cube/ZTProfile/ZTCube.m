/*
 ******************************************************************************
 * ZTCube.m -
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

#import "ZTCube.h"
#import "ZTBaseService.h"


#import "DEAAccelerometerService.h"

#import "TISensorTag.h"


/*
 ******************************************************************************
 *
 * for debug
 *
 ******************************************************************************
 */
#define DEBUG_MESSAGE                   1
#define LOGGING_INCLUDE_MULTITHREAD     1
#include "DbgMsg.h"

#if defined(DEBUG_MESSAGE) && DEBUG_MESSAGE
#define dmsg(fmt, ...)      LOG_FORMAT(fmt, @"ZTCube", ##__VA_ARGS__)
#else
#define dmsg(...)
#endif

#define msg(fmt, ...)       LOG_FORMAT(fmt, @"ZTCube", ##__VA_ARGS__)


/*
 ******************************************************************************
 *
 * @interface
 *
 ******************************************************************************
 */
@interface ZTCube ()

@end


/*
 ******************************************************************************
 *
 * @implementation
 *
 ******************************************************************************
 */
@implementation ZTCube

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral central:(YMSCBCentralManager *)owner baseHi:(int64_t)hi baseLo:(int64_t)lo
{

    dmsg(@"init");

    self = [super initWithPeripheral:peripheral central:owner baseHi:hi baseLo:lo];
    
    if (self) {
        ZTDeviceInfoService     *devinfo = [[ZTDeviceInfoService alloc] initWithName:@"devinfo" parent:self baseHi:0 baseLo:0 serviceOffset:kSUUID_DEVINFO];
        ZTBatteryService        *batt    = [[ZTBatteryService alloc] initWithName:@"battery" parent:self baseHi:0 baseLo:0 serviceOffset:kSUUID_BATTERY];
        ZTProtrackService       *ptw     = [[ZTProtrackService alloc] initWithName:@"protrack_write" parent:self baseHi:0 baseLo:0 serviceOffset:kSUUID_PROTRACK_WRITE];
        ZTProtrackNotify        *ptn     = [[ZTProtrackNotify alloc] initWithName:@"protrack_notify" parent:self baseHi:0 baseLo:0 serviceOffset:kSUUID_PROTRACK_NOTIFY];

        self.serviceDict = @{@"protrack_write": ptw,
                             @"protrack_notify": ptn,
                             @"battery": batt,
                             @"devinfo": devinfo};
    }
    return self;

}

- (void)connect
{
    dmsg(@"connect");

    // Watchdog aware method
    [self resetWatchdog];

    dmsg(@"connectWithOption:withBlock:");
    [self connectWithOptions:nil withBlock:^(YMSCBPeripheral *yp, NSError *error) {
        if (error) {
            msg(@"Error: connectWithOption:withBlock: - %@", [error localizedDescription]);
            return;
        }
        
        // Example where only a subset of services is to be discovered.
//        [yp discoverServices:[yp servicesSubset:@[@"temperature", @"simplekeys", @"devinfo"]] withBlock:^(NSArray *yservices, NSError *error) {

        dmsg(@"discoverServices:withBlock:");
        [yp discoverServices:[yp services] withBlock:^(NSArray *yservices, NSError *error) {
            if (error) {
                msg(@"Error: discoverServices:withBlock: - %@", [error localizedDescription]);
                return;
            }
            
            dmsg(@"discover characteristics");
            for (YMSCBService *service in yservices) {
                if ([service.name isEqualToString:@"battery"]) {
                    dmsg(@"battery service");
                    __weak ZTBatteryService *thisService = (ZTBatteryService *) service;
                    [service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, NSError *error) {
                        [thisService turnOn];
                    }];

                } else if ([service.name isEqualToString:@"devinfo"]) {
                    dmsg(@"devinfo service");
                    __weak ZTDeviceInfoService *thisService = (ZTDeviceInfoService *) service;
                    [service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, NSError *error) {
                        [thisService readDeviceInfo];
                    }];

                } else if ([service.name isEqualToString:@"protrack_write"]) {
                    dmsg(@"protrack (w) service");
                    __weak ZTProtrackService *thisService = (ZTProtrackService *) service;
                    [service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, NSError *error) {
                        [thisService setDate];
//                        [thisService clearData];
                    }];

                } else if ([service.name isEqualToString:@"protrack_notify"]) {
                    dmsg(@"protrack (n) service");
                    __weak ZTProtrackNotify *thisService = (ZTProtrackNotify *) service;
                    [service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, NSError *error) {
                        [thisService turnOn];
                    }];
                }
            }
        }];
    }];
}


- (ZTDeviceInfoService *)devinfo
{
    dmsg(@"devinfo");
    return self.serviceDict[@"devinfo"];
}

- (ZTBatteryService *)battery
{
    dmsg(@"battery");
    return self.serviceDict[@"battery"];
}

- (ZTProtrackService *)protrack
{
    dmsg(@"protrack (w)");
    return self.serviceDict[@"protrack_write"];
}

- (ZTProtrackNotify *)protrackNotify
{
    dmsg(@"protrack (n)");
    return self.serviceDict[@"protrack_notify"];
}


@end
