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
#define dmsg(fmt, ...)      LOG_FORMAT(fmt, @"ZTWrite", ##__VA_ARGS__)
#else
#define dmsg(...)
#endif

#define msg(fmt, ...)       LOG_FORMAT(fmt, @"ZTWrite", ##__VA_ARGS__)


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


/*---------------------------------------------------------------------------*/
#pragma mark - Calculate Checksum
/*---------------------------------------------------------------------------*/
- (unsigned char)calcChksum:(unsigned char *)payload length:(int)length
{
    unsigned char chksum = 0;

    if (length < 5) {
        return chksum;
    }

    for (int i=0; i<length-3; i++) {
        chksum += payload[i+1];
    }
    return chksum;
}


/*---------------------------------------------------------------------------*/
#pragma mark - Command
#pragma mark -- set date
/*---------------------------------------------------------------------------*/
- (void)setDate
{
    dmsg(@"request: set date");
    dispatch_semaphore_t    semaphore = dispatch_semaphore_create(0);
    YMSCBCharacteristic     *ptwCt    = self.characteristicDict[@"FFE9"];

    // gen payload
    NSDate           *today     = [NSDate date];
    NSCalendar       *calendar  = [NSCalendar currentCalendar];
    NSDateComponents *component = [calendar components:(kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay | kCFCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond)
                                              fromDate:today];
    dmsg(@"current date: %04d/%02d/%02d time:%02d:%02d:%02d", [component year], [component month], [component day], [component hour], [component minute], [component second]);

    unsigned char   payload[] = { 0xFA, 0x0B, 0x10, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFE };
    payload[3] = [component year] % 2000;
    payload[4] = [component month];
    payload[5] = [component day];
    payload[6] = [component hour];
    payload[7] = [component minute];
    payload[8] = [component second];
    payload[9] = [self calcChksum:payload length:sizeof(payload)];

    // send command
    NSData  *command  = [NSData dataWithBytes:payload length:sizeof(payload)];
    dmsg(@"[app->ble]: %@", command);

    [ptwCt writeValue:command withBlock:^(NSError *error) {
        if (error) {
            msg(@"ERROR: %@ - [line %d]", [error localizedDescription], __LINE__);
            return;
        }
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}


/*---------------------------------------------------------------------------*/
#pragma mark -- record start/stop
/*---------------------------------------------------------------------------*/
- (void)recordStart:(NSInteger)resolution speed:(NSInteger)speed power:(NSInteger)power
{
    dmsg(@"request: record start");
    dispatch_semaphore_t    semaphore = dispatch_semaphore_create(0);
    YMSCBCharacteristic     *ptwCt    = self.characteristicDict[@"FFE9"];

    // gen payload
    unsigned char   payload[] = { 0xFA, 0x08, 0x01, 0x00, 0x00, 0x00, 0x00, 0xFE };
    payload[3] = resolution;
    payload[4] = speed;
    payload[5] = power;
    payload[6] = [self calcChksum:payload length:sizeof(payload)];

    // send command
    NSData  *command  = [NSData dataWithBytes:payload length:sizeof(payload)];
    dmsg(@"[app->ble]: %@", command);

    [ptwCt writeValue:command withBlock:^(NSError *error) {
        if (error) {
            msg(@"ERROR: %@ - [line %d]", [error localizedDescription], __LINE__);
            return;
        }
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)recordStop
{
    dmsg(@"request: record stop");
    dispatch_semaphore_t    semaphore = dispatch_semaphore_create(0);
    YMSCBCharacteristic     *ptwCt    = self.characteristicDict[@"FFE9"];

    // gen payload
    unsigned char   payload[] = { 0xFA, 0x05, 0x11, 0x00, 0xFE };
    payload[3] = [self calcChksum:payload length:sizeof(payload)];

    // send command
    NSData  *command  = [NSData dataWithBytes:payload length:sizeof(payload)];
    dmsg(@"[app->ble]: %@", command);

    [ptwCt writeValue:command withBlock:^(NSError *error) {
        if (error) {
            msg(@"ERROR: %@ - [line %d]", [error localizedDescription], __LINE__);
            return;
        }
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}


/*---------------------------------------------------------------------------*/
#pragma mark -- snapshot
/*---------------------------------------------------------------------------*/
- (void)snapshot:(NSInteger)resolution power:(NSInteger)power
{
    dmsg(@"request: snapshot");
    dispatch_semaphore_t    semaphore = dispatch_semaphore_create(0);
    YMSCBCharacteristic     *ptwCt    = self.characteristicDict[@"FFE9"];

    // gen payload
    unsigned char   payload[] = { 0xFA, 0x07, 0x02, 0x00, 0x00, 0x00, 0xFE };
    payload[3] = resolution;
    payload[4] = power;
    payload[5] = [self calcChksum:payload length:sizeof(payload)];

    // send command
    NSData  *command  = [NSData dataWithBytes:payload length:sizeof(payload)];
    dmsg(@"[app->ble]: %@", command);

    [ptwCt writeValue:command withBlock:^(NSError *error) {
        if (error) {
            msg(@"ERROR: %@ - [line %d]", [error localizedDescription], __LINE__);
            return;
        }
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}


/*---------------------------------------------------------------------------*/
#pragma mark -- read status
/*---------------------------------------------------------------------------*/
- (void)readStatus
{
    dmsg(@"request: read status");
    dispatch_semaphore_t    semaphore = dispatch_semaphore_create(0);
    YMSCBCharacteristic     *ptwCt    = self.characteristicDict[@"FFE9"];

    // gen payload
    unsigned char   payload[] = { 0xFA, 0x05, 0x03, 0x00, 0xFE };
    payload[3] = [self calcChksum:payload length:sizeof(payload)];

    // send command
    NSData  *command  = [NSData dataWithBytes:payload length:sizeof(payload)];
    dmsg(@"[app->ble]: %@", command);

    [ptwCt writeValue:command withBlock:^(NSError *error) {
        if (error) {
            msg(@"ERROR: %@ - [line %d]", [error localizedDescription], __LINE__);
            return;
        }
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}


/*---------------------------------------------------------------------------*/
#pragma mark -- power manager
/*---------------------------------------------------------------------------*/
- (void)powerManage:(NSUInteger)option
{
    dmsg(@"request: power manager");
    dispatch_semaphore_t    semaphore = dispatch_semaphore_create(0);
    YMSCBCharacteristic     *ptwCt    = self.characteristicDict[@"FFE9"];

    // gen payload
    unsigned char   payload[] = { 0xFA, 0x06, 0x00, 0x00, 0x00, 0xFE };
    payload[3] = (unsigned char) option;
    payload[4] = [self calcChksum:payload length:sizeof(payload)];

    // send command
    NSData  *command  = [NSData dataWithBytes:payload length:sizeof(payload)];
    dmsg(@"[app->ble]: %@", command);

    [ptwCt writeValue:command withBlock:^(NSError *error) {
        if (error) {
            msg(@"ERROR: %@ - [line %d]", [error localizedDescription], __LINE__);
            return;
        }
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}


/*---------------------------------------------------------------------------*/
#pragma mark -- inquiry picture/block
/*---------------------------------------------------------------------------*/
- (void)inquiryPic
{
    dmsg(@"request: inquiry pic");
    dispatch_semaphore_t    semaphore = dispatch_semaphore_create(0);
    YMSCBCharacteristic     *ptwCt    = self.characteristicDict[@"FFE9"];

    // gen payload
    unsigned char   payload[] = { 0xFA, 0x05, 0x21, 0x00, 0xFE };
    payload[3] = [self calcChksum:payload length:sizeof(payload)];

    // send command
    NSData  *command  = [NSData dataWithBytes:payload length:sizeof(payload)];
    dmsg(@"[app->ble]: %@", command);

    [ptwCt writeValue:command withBlock:^(NSError *error) {
        if (error) {
            msg(@"ERROR: %@ - [line %d]", [error localizedDescription], __LINE__);
            return;
        }
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)inquiryBlock:(NSInteger)pic
{
    dmsg(@"request: inquiry block");
    dispatch_semaphore_t    semaphore = dispatch_semaphore_create(0);
    YMSCBCharacteristic     *ptwCt    = self.characteristicDict[@"FFE9"];

    // gen payload
    unsigned char   payload[] = { 0xFA, 0x06, 0x22, 0x00, 0x00, 0xFE };
    payload[3] = pic;
    payload[4] = [self calcChksum:payload length:sizeof(payload)];

    // send command
    NSData  *command  = [NSData dataWithBytes:payload length:sizeof(payload)];
    dmsg(@"[app->ble]: %@", command);

    [ptwCt writeValue:command withBlock:^(NSError *error) {
        if (error) {
            msg(@"ERROR: %@ - [line %d]", [error localizedDescription], __LINE__);
            return;
        }
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}


/*---------------------------------------------------------------------------*/
#pragma mark -- get picture
/*---------------------------------------------------------------------------*/
- (void)getPic:(NSInteger)pic block:(NSInteger)blk
{
    dmsg(@"request: get pic");
    dispatch_semaphore_t    semaphore = dispatch_semaphore_create(0);
    YMSCBCharacteristic     *ptwCt    = self.characteristicDict[@"FFE9"];

    // gen payload
    unsigned char   payload[] = { 0xFA, 0x07, 0x23, 0x00, 0x00, 0x00, 0xFE };
    payload[3] = pic;
    payload[4] = blk;
    payload[5] = [self calcChksum:payload length:sizeof(payload)];

    // send command
    NSData  *command  = [NSData dataWithBytes:payload length:sizeof(payload)];
    dmsg(@"[app->ble]: %@", command);

    [ptwCt writeValue:command withBlock:^(NSError *error) {
        if (error) {
            msg(@"ERROR: %@ - [line %d]", [error localizedDescription], __LINE__);
            return;
        }
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}


/*---------------------------------------------------------------------------*/
#pragma mark -- read/write GPIO
/*---------------------------------------------------------------------------*/
- (void)readGPIO:(NSInteger)num
{
    dmsg(@"request: read GPIO");
    dispatch_semaphore_t    semaphore = dispatch_semaphore_create(0);
    YMSCBCharacteristic     *ptwCt    = self.characteristicDict[@"FFE9"];

    // gen payload
    unsigned char   payload[] = { 0xFA, 0x06, 0x15, 0x00, 0x00, 0xFE };
    payload[3] = num;
    payload[4] = [self calcChksum:payload length:sizeof(payload)];

    // send command
    NSData  *command  = [NSData dataWithBytes:payload length:sizeof(payload)];
    dmsg(@"[app->ble]: %@", command);

    [ptwCt writeValue:command withBlock:^(NSError *error) {
        if (error) {
            msg(@"ERROR: %@ - [line %d]", [error localizedDescription], __LINE__);
            return;
        }
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}

- (void)writeGPIO:(NSInteger)num level:(NSInteger)lvl
{
    dmsg(@"request: write GPIO");
    dispatch_semaphore_t    semaphore = dispatch_semaphore_create(0);
    YMSCBCharacteristic     *ptwCt    = self.characteristicDict[@"FFE9"];

    // gen payload
    unsigned char   payload[] = { 0xFA, 0x07, 0x13, 0x00, 0x00, 0x00, 0xFE };
    payload[3] = num;
    payload[4] = lvl;
    payload[5] = [self calcChksum:payload length:sizeof(payload)];

    // send command
    NSData  *command  = [NSData dataWithBytes:payload length:sizeof(payload)];
    dmsg(@"[app->ble]: %@", command);

    [ptwCt writeValue:command withBlock:^(NSError *error) {
        if (error) {
            msg(@"ERROR: %@ - [line %d]", [error localizedDescription], __LINE__);
            return;
        }
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}


/*---------------------------------------------------------------------------*/
#pragma mark -- write Plan
/*---------------------------------------------------------------------------*/
#define UNIT_FLAGS \
( \
NSYearCalendarUnit | \
NSMonthCalendarUnit | \
NSDayCalendarUnit | \
NSHourCalendarUnit | \
NSMinuteCalendarUnit | \
NSSecondCalendarUnit \
)

- (void)writePlan:(NSUInteger)planid enable:(BOOL)en type:(NSUInteger)mode beginTime:(NSDate *)begin endTime:(NSDate *)end repeat:(NSUInteger)cycle
{
    dmsg(@"request: write Plan");
    dispatch_semaphore_t    semaphore = dispatch_semaphore_create(0);
    YMSCBCharacteristic     *ptwCt    = self.characteristicDict[@"FFE9"];

    NSCalendar              *calendar = [NSCalendar currentCalendar];

    // gen payload
    unsigned char   payload[] = { 0xFA, 0x0d, 0x30, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFE };
    payload[ 3] = planid;
    payload[ 4] = en ? 0x01 : 0x00;
    payload[ 5] = mode;

    NSDateComponents *bc = [calendar components:UNIT_FLAGS fromDate:begin];
    payload[ 6] = (unsigned char) [bc hour];
    payload[ 7] = (unsigned char) [bc minute];

    NSDateComponents *ec = [calendar components:UNIT_FLAGS fromDate:begin];
    payload[ 8] = (unsigned char) [ec hour];
    payload[ 9] = (unsigned char) [ec minute];

    payload[10] = cycle;
    payload[11] = [self calcChksum:payload length:sizeof(payload)];

    // send command
    NSData  *command  = [NSData dataWithBytes:payload length:sizeof(payload)];
    dmsg(@"[app->ble]: %@", command);

    [ptwCt writeValue:command withBlock:^(NSError *error) {
        if (error) {
            msg(@"ERROR: %@ - [line %d]", [error localizedDescription], __LINE__);
            return;
        }
        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}





@end
