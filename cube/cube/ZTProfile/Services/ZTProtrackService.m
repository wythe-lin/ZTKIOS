/*
 ******************************************************************************
 * ZTProtrackService.m -
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

#import "ZTProtrackService.h"

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
#define dmsg(fmt, ...)      LOG_FORMAT(fmt, @"ZTProtrackService", ##__VA_ARGS__)
#else
#define dmsg(...)
#endif

#define msg(fmt, ...)       LOG_FORMAT(fmt, @"ZTProtrackService", ##__VA_ARGS__)


/*
 ******************************************************************************
 *
 * @interface
 *
 ******************************************************************************
 */
@interface ZTProtrackService ()



@end


/*
 ******************************************************************************
 *
 * @implementation
 *
 ******************************************************************************
 */
@implementation ZTProtrackService

- (instancetype)initWithName:(NSString *)oName parent:(YMSCBPeripheral *)pObj baseHi:(int64_t)hi baseLo:(int64_t)lo serviceOffset:(int)serviceOffset
{
    dmsg(@"init");

    self = [super initWithName:oName parent:pObj baseHi:hi baseLo:lo serviceOffset:serviceOffset];
    if (self) {
        [self addCharacteristic:@"FFE9" withAddress:kCUUID_PROTRACK_WRITE];
    }
    return self;
}


// KVC
- (void)write
{
    dmsg(@"write");
/*
    YMSCBCharacteristic         *batt_lvCt = self.characteristicDict[@"FFE9"];
    __weak ZTProtrackService    *this      = self;


    // write
    [batt_lvCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            msg(@"ERROR: %@", [error localizedDescription]);
            return;
        }

        NSData  *payload = [[NSData alloc] initWithData:data];
        [payload getBytes:&_battLevel length:sizeof(_battLevel)];
        dmsg(@"battery level: %d%%", _battLevel);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            [self willChangeValueForKey:@"batteryValue"];
            this.battery_level = @(self.battLevel);
            [self didChangeValueForKey:@"batteryValue"];
        });

    }];
*/

}

- (void)readDeviceTime
{
    dmsg(@"command: READ DEV TIME");

    YMSCBCharacteristic         *ptwCt = self.characteristicDict[@"FFE9"];

    // send command
    unsigned char           payload[3] = { 0x89, 0x00, 0x00 };
    NSData                  *command   = [NSData dataWithBytes:payload length:3];

    [ptwCt writeValue:command withBlock:^(NSError *error) {
        if (error) {
            msg(@"ERROR: %@ - [line %d]", [error localizedDescription], __LINE__);
            return;
        }

        dmsg(@"send command: %@", command);

    }];
}

- (void)clearData
{
    dmsg(@"command: CLEAR DATA");

    YMSCBCharacteristic         *ptwCt = self.characteristicDict[@"FFE9"];

    // send command
    unsigned char           payload[3] = { 0x88, 0x00, 0x00 };
    NSData                  *command   = [NSData dataWithBytes:payload length:3];

    [ptwCt writeValue:command withBlock:^(NSError *error) {
        if (error) {
            msg(@"ERROR: %@ - [line %d]", [error localizedDescription], __LINE__);
            return;
        }

        dmsg(@"send command: %@", command);
        
    }];
}






@end
