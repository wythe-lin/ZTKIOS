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

#import "ZTDeviceInfoService.h"
#import "ZTBatteryService.h"
#import "ZTProtrackService.h"

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

    dmsg(@"initWithPeripheral:central:baseHi:baseLo:");

    self = [super initWithPeripheral:peripheral central:owner baseHi:hi baseLo:lo];
    
    if (self) {
        DEAAccelerometerService *as = [[DEAAccelerometerService alloc] initWithName:@"accelerometer" parent:self baseHi:hi baseLo:lo serviceOffset:kSensorTag_ACCELEROMETER_SERVICE];

        ZTDeviceInfoService     *devinfo = [[ZTDeviceInfoService alloc] initWithName:@"devinfo" parent:self baseHi:0 baseLo:0 serviceOffset:kSUUID_DEVINFO];
        ZTBatteryService        *batt    = [[ZTBatteryService alloc] initWithName:@"battery" parent:self baseHi:0 baseLo:0 serviceOffset:kSUUID_BATTERY];
        ZTProtrackService       *ptw     = [[ZTProtrackService alloc] initWithName:@"protrack_write" parent:self baseHi:0 baseLo:0 serviceOffset:kSUUID_PROTRACK_WRITE];

        self.serviceDict = @{@"accelerometer": as,
                             @"protrack_write": ptw,
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

    dmsg(@"connectWithOption:withBlock: - begin");
    [self connectWithOptions:nil withBlock:^(YMSCBPeripheral *yp, NSError *error) {
        if (error) {
            msg(@"Error: connectWithOption:withBlock: - %@", [error localizedDescription]);
            return;
        }
        
        // Example where only a subset of services is to be discovered.
//        [yp discoverServices:[yp servicesSubset:@[@"temperature", @"simplekeys", @"devinfo"]] withBlock:^(NSArray *yservices, NSError *error) {

        dmsg(@"discoverServices:withBlock: - begin");
        [yp discoverServices:[yp services] withBlock:^(NSArray *yservices, NSError *error) {
            if (error) {
                msg(@"Error: discoverServices:withBlock: - %@", [error localizedDescription]);
                return;
            }
            
            dmsg(@"discover characteristics - begin");
            for (YMSCBService *service in yservices) {
                if ([service.name isEqualToString:@"battery"]) {
                    dmsg(@"battery service - begin");

                    __weak ZTBatteryService *thisService = (ZTBatteryService *) service;
                    [service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, NSError *error) {
                        [thisService readBatteryLevel];
                    }];

                    dmsg(@"battery service - end");

                } else if ([service.name isEqualToString:@"devinfo"]) {
                    dmsg(@"devinfo service - begin");

                    __weak ZTDeviceInfoService *thisService = (ZTDeviceInfoService *) service;
                    [service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, NSError *error) {
                        [thisService readDeviceInfo];
                    }];

                    dmsg(@"devinfo service - end");

                } else if ([service.name isEqualToString:@"protrack_write"]) {
                    dmsg(@"protrack write service - begin");

                    __weak ZTProtrackService *thisService = (ZTProtrackService *) service;
                    [service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, NSError *error) {
                        [thisService readDeviceTime];
                    }];

                    dmsg(@"protrack write service - end");

                } else {
                    dmsg(@"base service - begin");

                    __weak ZTBaseService *thisService = (ZTBaseService *)service;
                    [service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, NSError *error) {
                        for (NSString *key in chDict) {
                            YMSCBCharacteristic *ct = chDict[key];
//                            NSLog(@"%@ %@ %@", ct, ct.cbCharacteristic, ct.uuid);
                            
                            dmsg(@"discoverServices:withBlock:");
                            [ct discoverDescriptorsWithBlock:^(NSArray *ydescriptors, NSError *error) {
                                if (error) {
                                    msg(@"Error: discoverDescriptorsWithBlock: - %@", [error localizedDescription]);
                                    return;
                                }
                                for (YMSCBDescriptor *yd in ydescriptors) {
                                    NSLog(@"Descriptor: %@ %@ %@", thisService.name, yd.UUID, yd.cbDescriptor);
                                }
                            }];
                        }
                    }];

                    dmsg(@"base service - end");

                }
            }
            dmsg(@"discover characteristics - end");
        }];
        dmsg(@"discoverServices:withBlock: - end");
    }];

    dmsg(@"connectWithOption:withBlock: - end");
}


- (ZTDeviceInfoService *)devinfo
{
    dmsg(@"devinfo");
    return self.serviceDict[@"devinfo"];
}

- (ZTBatteryService *)battery
{
    dmsg(@"devinfo");
    return self.serviceDict[@"battery"];
}

- (ZTProtrackService *)protrack
{
    dmsg(@"protrack write");
    return self.serviceDict[@"protrack_write"];
}

- (DEAAccelerometerService *)accelerometer
{
    return self.serviceDict[@"accelerometer"];
}

@end
