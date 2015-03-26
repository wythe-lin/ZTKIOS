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
#define LOGGING_INCLUDE_MULTITHREAD     1
#include "DbgMsg.h"

#if defined(DEBUG_MESSAGE) && DEBUG_MESSAGE
#define dmsg(fmt, ...)      LOG_FORMAT(fmt, @"ZTProtrackNotify", ##__VA_ARGS__)
#else
#define dmsg(...)
#endif

#define msg(fmt, ...)       LOG_FORMAT(fmt, @"ZTProtrackNotify", ##__VA_ARGS__)


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
    return self;
}


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


- (void)notifyCharacteristicHandler:(YMSCBCharacteristic *)yc error:(NSError *)error
{
    if (error) {
        msg(@"ERROR: %@ - [line %d]", [error localizedDescription], __LINE__);
        return;
    }

    msg(@"notifyCharacteristicHandler:error:");
    if ([yc.name isEqualToString:@"FFE4"]) {
        NSData *data = yc.cbCharacteristic.value;

        _YMS_PERFORM_ON_MAIN_THREAD(^{


        });
    }
}



@end
