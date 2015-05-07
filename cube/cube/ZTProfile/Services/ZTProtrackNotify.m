/*
 ******************************************************************************
 * ZTProtrackNotify.m -
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

#import "ZTProtrackNotify.h"

/*
 ******************************************************************************
 *
 * for debug
 *
 ******************************************************************************
 */
#define DEBUG_MESSAGE                   1
#define DEBUG_RESPONSE                  0
#define LOGGING_INCLUDE_MULTITHREAD     1
#include "DbgMsg.h"

#if defined(DEBUG_MESSAGE) && DEBUG_MESSAGE
#define dmsg(fmt, ...)      LOG_FORMAT(fmt, @"ZTNotify", ##__VA_ARGS__)
#else
#define dmsg(...)
#endif

#if defined(DEBUG_RESPONSE) && DEBUG_RESPONSE
#define rsp(fmt, ...)       LOG_FORMAT(fmt, @"ZTNotify", ##__VA_ARGS__)
#else
#define rsp(...)
#endif

#define msg(fmt, ...)       LOG_FORMAT(fmt, @"ZTNotify", ##__VA_ARGS__)


/*
 ******************************************************************************
 *
 * @interface
 *
 ******************************************************************************
 */
@interface ZTProtrackNotify ()



@end


/*
 ******************************************************************************
 *
 * @implementation
 *
 ******************************************************************************
 */
@implementation ZTProtrackNotify

- (instancetype)initWithName:(NSString *)oName parent:(YMSCBPeripheral *)pObj baseHi:(int64_t)hi baseLo:(int64_t)lo serviceOffset:(int)serviceOffset
{
    dmsg(@"init");

    self = [super initWithName:oName parent:pObj baseHi:hi baseLo:lo serviceOffset:serviceOffset];
    if (self) {
        [self addCharacteristic:@"FFE4" withAddress:kCUUID_PROTRACK_NOTIFY];
    }

    rxpkt = [[NSData alloc] init];
    kfifo_init(&rxqueue, rxbuf, sizeof(rxbuf));
    semaphore = dispatch_semaphore_create(0);
    toTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerHandle:) userInfo:nil repeats:YES];
    return self;
}


/*---------------------------------------------------------------------------*/
#pragma mark - Notify On/Off
/*---------------------------------------------------------------------------*/
- (void)turnOn
{
    __weak ZTProtrackNotify *this = self;

    if (this.isOn == NO) {
        YMSCBCharacteristic *ptnCt = self.characteristicDict[@"FFE4"];
        [ptnCt setNotifyValue:YES withBlock:^(NSError *error) {
            if (error) {
                msg(@"ERROR: %@ [%d]", [error localizedDescription], __LINE__);
                return;
            }
            msg(@"TURNED ON: %@", this.name);
        }];

        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.isOn = YES;
        });
    }
}


- (void)turnOff
{
    __weak ZTProtrackNotify *this = self;

    if (this.isOn == YES) {
        YMSCBCharacteristic *ptnCt = self.characteristicDict[@"FFE4"];
        [ptnCt setNotifyValue:NO withBlock:^(NSError *error) {
            if (error) {
                msg(@"ERROR: %@ [line %d]", [error localizedDescription], __LINE__);
                return;
            }
            msg(@"TURNED OFF: %@", this.name);
        }];

        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.isOn = NO;
        });
    }
}


/*---------------------------------------------------------------------------*/
#pragma mark - Notify Callback Handler
/*---------------------------------------------------------------------------*/
- (void)notifyCharacteristicHandler:(YMSCBCharacteristic *)yc error:(NSError *)error
{
    if (error) {
        msg(@"ERROR: %@ - [line %d]", [error localizedDescription], __LINE__);
        return;
    }

    dmsg(@"FFE4 Notify Handler");
    if ([yc.name isEqualToString:@"FFE4"]) {
        NSData  *data = yc.cbCharacteristic.value;
        dmsg(@"[ble->app]: %@", data);

        _YMS_PERFORM_ON_MAIN_THREAD(^{
            kfifo_in(&rxqueue, [data bytes], [data length]);
            dispatch_semaphore_signal(semaphore);
        });
    }
}


/*---------------------------------------------------------------------------*/
#pragma mark -
/*---------------------------------------------------------------------------*/
- (NSUInteger)getResponsePacket
{
    unsigned char   tmp;
    unsigned char   fsm = 0;
    unsigned char   pkt[128];

    rsp(@"getResponsePacket - begin");

    [self startTimeoutTimer];

    for (fsm=0; fsm<4; ) {
        switch (fsm) {
            case 0: // wait for response
                rsp(@"0");
                if (!kfifo_len(&rxqueue)) {
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW/*DISPATCH_TIME_FOREVER*/);
                    if ([self getTimeoutValue] >= 3) {
                        msg(@"FSM1 - timeout");
                        return 1;
                    }
                } else {
                    fsm = 1;
                }
                break;

            case 1: // find leading code
                rsp(@"1");
                if (kfifo_len(&rxqueue)) {
                    kfifo_out(&rxqueue, &tmp, 1);
                    if (tmp == 0xFA) {
                        pkt[0] = tmp;
                        fsm    = 2;
                    }
                } else {
                    dmsg(@"cann't find leading code");
                    fsm = 5;
                }
                break;

            case 2: // get length
                rsp(@"2");
                kfifo_out(&rxqueue, &tmp, 1);
                pkt[1] = tmp;
                fsm    = 3;

                [self resetTimeoutTimer];
                break;

            case 3: // get packet content
                rsp(@"3");
                if (kfifo_len(&rxqueue) >= (pkt[1]-2)) {
                    kfifo_out(&rxqueue, &pkt[2], pkt[1]-2);
                    fsm = 4;
                } else {
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW/*DISPATCH_TIME_FOREVER*/);
                    if ([self getTimeoutValue] >= 3) {
                        msg(@"FSM3 - timeout");
                        return 3;
                    }
                }
                break;
        }
    }

    [self stopTimeoutTimer];

    // cheak packet
    switch (pkt[2]) {
        case 0x80:  // status packet
            _ack     = pkt[3];
            _storage = pkt[4];
            _status  = pkt[5];
            _picblk  = pkt[6];
            dmsg(@"response: status packet - ack=%02x, storage=%02x, status=%02x, data=%02x", _ack, _storage, _status, _picblk);
            break;

        case 0x20:
            rxpkt = [NSData dataWithBytes:&pkt[3] length:pkt[1]-5];
            dmsg(@"response: data block packet - %@", rxpkt);
            break;

        default:
            dmsg(@"response: unknown packet");
            break;
    }

    rsp(@"getResponsePacket - end");
    return 0;
}


- (NSData *)getRxPkt
{
    return rxpkt;
}


/*---------------------------------------------------------------------------*/
#pragma mark -
/*---------------------------------------------------------------------------*/
- (void)startTimeoutTimer
{
    [self resetTimeoutTimer];

//    toTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerHandle:) userInfo:nil repeats:YES];
//    [toTimer fire];

//    BOOL timerState = [toTimer isValid];
//    NSLog(@"Timer Validity is: %@", timerState?@"YES":@"NO");
}

- (void)stopTimeoutTimer
{
//    [toTimer invalidate];

}

- (void)resetTimeoutTimer
{
    toCount = 0;
}

- (NSUInteger)getTimeoutValue
{
    return toCount;
}

- (void)timerHandle:(NSTimer *)timer
{
    toCount++;
//    dmsg(@"toCount=%0d", toCount);
}


@end
