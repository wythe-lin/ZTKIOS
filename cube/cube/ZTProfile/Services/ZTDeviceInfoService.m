/*
 ******************************************************************************
 * ZTZTDeviceInfoService.m -
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

#import "ZTDeviceInfoService.h"


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
#define dmsg(fmt, ...)      LOG_FORMAT(fmt, @"ZTDeviceInfoService", ##__VA_ARGS__)
#else
#define dmsg(...)
#endif

#define msg(fmt, ...)       LOG_FORMAT(fmt, @"ZTDeviceInfoService", ##__VA_ARGS__)


/*
 ******************************************************************************
 *
 * @interface
 *
 ******************************************************************************
 */
@interface ZTDeviceInfoService ()

@end


/*
 ******************************************************************************
 *
 * @implementation
 *
 ******************************************************************************
 */
@implementation ZTDeviceInfoService

- (instancetype)initWithName:(NSString *)oName parent:(YMSCBPeripheral *)pObj baseHi:(int64_t)hi baseLo:(int64_t)lo serviceOffset:(int)serviceOffset
{
    dmsg(@"init");

    self = [super initWithName:oName parent:pObj baseHi:hi baseLo:lo serviceOffset:serviceOffset];
    if (self) {
        [self addCharacteristic:@"system_id" withAddress:kCUUID_DEVINFO_SYSTEM_ID];
        [self addCharacteristic:@"model_number" withAddress:kCUUID_DEVINFO_MODEL_NUMBER];
        [self addCharacteristic:@"serial_number" withAddress:kCUUID_DEVINFO_SERIAL_NUMBER];
        [self addCharacteristic:@"firmware_rev" withAddress:kCUUID_DEVINFO_FIRMWARE_REV];
        [self addCharacteristic:@"hardware_rev" withAddress:kCUUID_DEVINFO_HARDWARE_REV];
        [self addCharacteristic:@"software_rev" withAddress:kCUUID_DEVINFO_SOFTWARE_REV];
        [self addCharacteristic:@"manufacturer_name" withAddress:kCUUID_DEVINFO_MANUFACTURER_NAME];
//        [self addCharacteristic:@"ieee11073_cert_data" withAddress:kCUUID_DEVINFO_11073_CERT_DATA];
        // TODO: Undocumented what PnP characteristic address is. Stubbing here for now.
//        [self addCharacteristic:@"pnpid_data" withAddress:kCUUID_DEVINFO_PNPID_DATA];
    }
    return self;
}


- (void)readDeviceInfo
{
    dmsg(@"readDeviceInfo");

    __weak ZTDeviceInfoService *this = self;

    // read system_id
    YMSCBCharacteristic *system_idCt = self.characteristicDict[@"system_id"];
    [system_idCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            msg(@"ERROR: <%@> %@", this.name, [error localizedDescription]);
            return;
        }

        NSMutableString *tmpString = [NSMutableString stringWithFormat:@""];
        unsigned char bytes[data.length];

        [data getBytes:bytes];
        for (int ii = (int)data.length - 1; ii >= 0;ii--) {
            [tmpString appendFormat:@"%02hhx", bytes[ii]];
            if (ii) {
                [tmpString appendFormat:@":"];
            }
        }

        dmsg(@"system id: %@", tmpString);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.system_id = tmpString;
        });
        
    }];

    // read model_number
    YMSCBCharacteristic *model_numberCt = self.characteristicDict[@"model_number"];
    [model_numberCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            msg(@"ERROR: <%@> %@", this.name, [error localizedDescription]);
            return;
        }
        
        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        dmsg(@"model number: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.model_number = payload;
        });
    }];
    
    // read serial_number
    YMSCBCharacteristic *serial_numberCt = self.characteristicDict[@"serial_number"];
    [serial_numberCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            msg(@"ERROR: <%@> %@", this.name, [error localizedDescription]);
            return;
        }

        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        dmsg(@"serial number: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.serial_number = payload;
        });
    }];
    
    // read firmware_rev
    YMSCBCharacteristic *firmware_revCt = self.characteristicDict[@"firmware_rev"];
    [firmware_revCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            msg(@"ERROR: <%@> %@", this.name, [error localizedDescription]);
            return;
        }

        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        dmsg(@"firmware rev: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.firmware_rev = payload;
        });

    }];

    // read hardware_rev
    YMSCBCharacteristic *hardware_revCt = self.characteristicDict[@"hardware_rev"];
    [hardware_revCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            msg(@"ERROR: <%@> %@", this.name, [error localizedDescription]);
            return;
        }

        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        dmsg(@"hardware rev: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.hardware_rev = payload;
        });

    }];

    // read software_rev
    YMSCBCharacteristic *software_revCt = self.characteristicDict[@"software_rev"];
    [software_revCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            msg(@"ERROR: <%@> %@", this.name, [error localizedDescription]);
            return;
        }

        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        dmsg(@"software rev: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.software_rev = payload;
        });

    }];
    
    // read manufacturer_name
    YMSCBCharacteristic *manufacturer_nameCt = self.characteristicDict[@"manufacturer_name"];
    [manufacturer_nameCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            msg(@"ERROR: <%@> %@", this.name, [error localizedDescription]);
            return;
        }

        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        dmsg(@"manufacturer name: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.manufacturer_name = payload;
        });

    }];

    // read ieee11073_cert_data
    YMSCBCharacteristic *ieeeCt = self.characteristicDict[@"ieee11073_cert_data"];
    [ieeeCt readValueWithBlock:^(NSData *data, NSError *error) {
        if (error) {
            msg(@"ERROR: <%@> %@", this.name, [error localizedDescription]);
            return;
        }

        NSString *payload = [[NSString alloc] initWithData:data encoding:NSStringEncodingConversionAllowLossy];
        dmsg(@"IEEE 11073 Cert Data: %@", payload);
        _YMS_PERFORM_ON_MAIN_THREAD(^{
            this.ieee11073_cert_data = payload;
        });

    }];


}

@end
