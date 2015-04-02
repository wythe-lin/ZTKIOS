/*
 ******************************************************************************
 * ZTBatteryService.m -
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

#import "ZTBatteryService.h"



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
#define dmsg(fmt, ...)      LOG_FORMAT(fmt, @"ZTBatteryService", ##__VA_ARGS__)
#else
#define dmsg(...)
#endif

#define msg(fmt, ...)       LOG_FORMAT(fmt, @"ZTBatteryService", ##__VA_ARGS__)


/*
 ******************************************************************************
 *
 * @interface
 *
 ******************************************************************************
 */
@interface ZTBatteryService ()

@property (nonatomic, strong) NSNumber *batteryLevel;

@end


/*
 ******************************************************************************
 *
 * @implementation
 *
 ******************************************************************************
 */
@implementation ZTBatteryService

- (instancetype)initWithName:(NSString *)oName parent:(YMSCBPeripheral *)pObj baseHi:(int64_t)hi baseLo:(int64_t)lo serviceOffset:(int)serviceOffset
{
    dmsg(@"init");

    self = [super initWithName:oName parent:pObj baseHi:hi baseLo:lo serviceOffset:serviceOffset];
    if (self) {
        [self addCharacteristic:@"battery_level" withAddress:kCUUID_BATTERY_LEVEL];
    }
    return self;
}


/*---------------------------------------------------------------------------*/
#pragma mark - Notify On/Off
/*---------------------------------------------------------------------------*/
- (void)turnOff
{
    __weak ZTBatteryService *this = self;

    YMSCBCharacteristic *ct = self.characteristicDict[@"battery_level"];
    [ct setNotifyValue:NO withBlock:^(NSError *error) {
        if (error) {
            msg(@"ERROR: %@ [%s]", [error localizedDescription], __func__);
            return;
        }

        msg(@"TURNED OFF: %@", this.name);
    }];

    _YMS_PERFORM_ON_MAIN_THREAD(^{
        this.isOn = NO;
    });
}


- (void)turnOn
{
    __weak ZTBatteryService *this = self;

    YMSCBCharacteristic *ct = self.characteristicDict[@"battery_level"];
    [ct setNotifyValue:YES withBlock:^(NSError *error) {
        if (error) {
            msg(@"ERROR: %@ [%s]", [error localizedDescription], __func__);
            return;
        }

        msg(@"TURNED ON: %@", this.name);
    }];

    _YMS_PERFORM_ON_MAIN_THREAD(^{
        this.isOn = YES;
    });
}


// KVC
- (void)notifyCharacteristicHandler:(YMSCBCharacteristic *)yc error:(NSError *)error
{
    if (error) {
        msg(@"ERROR: %@ [%s]", [error localizedDescription], __func__);
        return;
    }

    msg(@"Battery Notify Handler");

    if ([yc.name isEqualToString:@"battery_level"]) {
        int     value    = 0;
        NSData  *payload = [[NSData alloc] initWithData:yc.cbCharacteristic.value];
        [payload getBytes:&value length:sizeof(value)];

        dmsg(@"battery level: %d%%", value);

        __weak ZTBatteryService *this = self;
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            [self willChangeValueForKey:@"sensorValues"];
            this.batteryLevel = @(value);
            [self didChangeValueForKey:@"sensorValues"];
        });
    }
}


- (NSDictionary *)sensorValues
{
    return @{ @"batteryLevel": self.batteryLevel };
}


@end
