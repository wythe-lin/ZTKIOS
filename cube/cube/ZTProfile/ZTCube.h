/*
 ******************************************************************************
 * ZTCube.h -
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


#define kSUUID_GAP_SERVICE_UUID             0x1800
#define kSUUID_GATT_SERVICE                 0x1801

#define kSUUID_DEVINFO                      0x180A
#define kSUUID_BATTERY                      0x180F
#define kSUUID_PROTRACK_NOTIFY              0xFFE0
#define kSUUID_PROTRACK_WRITE               0xFFE5


@class ZTDeviceInfoService;
@class ZTBatteryService;
@class ZTProtrackService;

@class DEAAccelerometerService;

/**
 Peripheral Class.
 
 This class maps to an instance of a CBPeripheral associated with a found ZTCube.
 */
@interface ZTCube : YMSCBPeripheral

// Convenience pointer to device information service.
@property (nonatomic, readonly) ZTDeviceInfoService     *devinfo;

// Convenience pointer to battery service.
@property (nonatomic, readonly) ZTBatteryService        *battery;

@property (nonatomic, readonly) ZTProtrackService       *protrack;

/// Convenience pointer to accelerometer service.
@property (nonatomic, readonly) DEAAccelerometerService *accelerometer;



@end
