/*
 ******************************************************************************
 * BLEDevice.h -
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

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

// Class which describes a Bluetooth Smart Device
@interface BLEDevice : NSObject

// Pointer to CoreBluetooth peripheral
@property (strong,nonatomic) CBPeripheral *cbp;

// Pointer to CoreBluetooth manager that found this peripheral
@property (strong,nonatomic) CBCentralManager *cbm;

// Pointer to dictionary with device setup data
@property NSMutableDictionary *setupData;

@end
