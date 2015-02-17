/*
 ******************************************************************************
 * ZTZTDeviceInfoService.h -
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

#define kCUUID_DEVINFO_SYSTEM_ID            0x2A23
#define kCUUID_DEVINFO_MODEL_NUMBER         0x2A24
#define kCUUID_DEVINFO_SERIAL_NUMBER        0x2A25
#define kCUUID_DEVINFO_FIRMWARE_REV         0x2A26
#define kCUUID_DEVINFO_HARDWARE_REV         0x2A27
#define kCUUID_DEVINFO_SOFTWARE_REV         0x2A28
#define kCUUID_DEVINFO_MANUFACTURER_NAME    0x2A29
#define kCUUID_DEVINFO_11073_CERT_DATA      0x2A2A

/*
 * TODO: Data sheet shows that PnPID address is equal to 11083_CERT_DATA.
 * Belive this is in error.
 */
#define kCUUID_DEVINFO_PNPID_DATA           0x2A2A


/**
 TI SensorTag CoreBluetooth service definition for device information.
 */
@interface ZTDeviceInfoService : YMSCBService

/** @name Properties */
/// System ID
@property (nonatomic, strong) NSString *system_id;
/// Model Number
@property (nonatomic, strong) NSString *model_number;
/// Serial Number
@property (nonatomic, strong) NSString *serial_number;
/// Firmware Revision
@property (nonatomic, strong) NSString *firmware_rev;
/// Hardware Revision
@property (nonatomic, strong) NSString *hardware_rev;
/// Software Revision
@property (nonatomic, strong) NSString *software_rev;
/// Manufacturer Name
@property (nonatomic, strong) NSString *manufacturer_name;
/// IEEE 11073 Certification Data
@property (nonatomic, strong) NSString *ieee11073_cert_data;

/** @name Read Device Information */
/**
 Issue set of read requests to obtain device information which is store in the class properties.
 */
- (void)readDeviceInfo;

@end
