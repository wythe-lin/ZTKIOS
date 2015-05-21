/*
 ******************************************************************************
 * ZTCentralManager.h -
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

#import "YmsCoreBluetooth.h"

#define kZTCube_BASE_ADDRESS_HI     0xF000000004514000
#define kZTCube_BASE_ADDRESS_LO     0xB000000000000000


/**
 Application CoreBluetooth central manager service for Deanna.
 
 This class defines a singleton application service instance which manages access to
 the TI SensorTag via the CoreBluetooth API. 
 
 */
@interface ZTCentralManager : YMSCBCentralManager

/**
 Return singleton instance.
 @param delegate UI delegate.
 */
+ (ZTCentralManager *)initSharedServiceWithDelegate:(id)delegate;

/**
 Return singleton instance.
 */

+ (ZTCentralManager *)sharedService;

@end
