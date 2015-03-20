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

- (void)setDate
{
    dmsg(@"command: set date");

    YMSCBCharacteristic         *ptwCt = self.characteristicDict[@"FFE9"];

    // gen payload
    NSDate           *today     = [NSDate date];
    NSCalendar       *calendar  = [NSCalendar currentCalendar];
    NSDateComponents *component = [calendar components:(kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay | kCFCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond)
                                              fromDate:today];
    dmsg(@"current date: %04d/%02d/%02d time:%02d:%02d:%02d", [component year], [component month], [component day], [component hour], [component minute], [component second]);

    unsigned char   payload[] = { 0xFA, 0x0B, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFE };
    unsigned char   chksum    = payload[1] + payload[2];
    payload[3] = [component year] % 2000;
    chksum    += payload[3];
    payload[4] = [component month];
    chksum    += payload[4];
    payload[5] = [component day];
    chksum    += payload[5];
    payload[6] = [component hour];
    chksum    += payload[6];
    payload[7] = [component minute];
    chksum    += payload[7];
    payload[8] = [component second];
    payload[9] = payload[8] + chksum;

    // send command
    NSData  *command  = [NSData dataWithBytes:payload length:sizeof(payload)];
    [ptwCt writeValue:command withBlock:^(NSError *error) {
        if (error) {
            msg(@"ERROR: %@ - [line %d]", [error localizedDescription], __LINE__);
            return;
        }

        dmsg(@"send command: %@", command);

    }];
}

- (void)recordStart:(NSInteger)resolution power:(NSInteger)power speed:(NSInteger)speed
{
    dmsg(@"command: record start");

    YMSCBCharacteristic         *ptwCt = self.characteristicDict[@"FFE9"];

    // gen payload
    unsigned char   payload[] = { 0xFA, 0x08, 0x01, 0x00, 0x00, 0x00, 0x00, 0xFE };
    unsigned char   chksum    = payload[1] + payload[2];
    payload[3] = resolution;
    chksum    += payload[3];
    payload[4] = power;
    chksum    += payload[4];
    payload[5] = speed;
    payload[6] = payload[5] + chksum;

    // send command
    NSData  *command  = [NSData dataWithBytes:payload length:sizeof(payload)];
    [ptwCt writeValue:command withBlock:^(NSError *error) {
        if (error) {
            msg(@"ERROR: %@ - [line %d]", [error localizedDescription], __LINE__);
            return;
        }

        dmsg(@"send command: %@", command);
        
    }];
}






@end
