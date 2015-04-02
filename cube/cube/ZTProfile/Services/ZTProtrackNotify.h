/*
 ******************************************************************************
 * ZTProtrackNotify.h -
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

#import "YMSCoreBluetooth.h"
#include "kfifo.h"


#define kCUUID_PROTRACK_NOTIFY      0xFFE4


/**
 ProTrack Notify Service
 */
@interface ZTProtrackNotify : YMSCBService
{
    unsigned char           in;
    unsigned char           out;

    struct __kfifo          rxqueue;
    unsigned char           rxbuf[128];

    dispatch_semaphore_t    semaphore;
}

/**
 Turn on CoreBluetooth peripheral service.

 This method turns on the service by:

 *  writing to *config* characteristic to enable service.
 *  writing to *data* characteristic to enable notification.

 */
- (void)turnOn;

/**
 Turn off CoreBluetooth peripheral service.

 This method turns off the service by:

 *  writing to *config* characteristic to disable service.
 *  writing to *data* characteristic to disable notification.

 */
- (void)turnOff;

- (void)getResponsePacket;


@end
