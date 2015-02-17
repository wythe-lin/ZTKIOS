/*
 ******************************************************************************
 * ZTBaseService.h -
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

#import "ZTBaseService.h"
#import "YMSCBCharacteristic.h"
#import "YMSCBUtils.h"

@interface ZTBaseService ()

@end

@implementation ZTBaseService


- (instancetype)initWithName:(NSString *)oName
                      parent:(YMSCBPeripheral *)pObj
                      baseHi:(int64_t)hi
                      baseLo:(int64_t)lo
               serviceOffset:(int)serviceOffset {
    
    self = [super initWithName:oName
                        parent:pObj
                        baseHi:hi
                        baseLo:lo
                 serviceOffset:serviceOffset];
    
    
    if (self) {
        yms_u128_t pbase = self.base;
        
        if (![oName isEqualToString:@"simplekeys"]) {
            self.uuid = [YMSCBUtils createCBUUID:&pbase withIntBLEOffset:serviceOffset];
        }
    }
    return self;
}


- (void)addCharacteristic:(NSString *)cname withOffset:(int)addrOffset {
    YMSCBCharacteristic *yc;
    
    yms_u128_t pbase = self.base;
    
    CBUUID *uuid = [YMSCBUtils createCBUUID:&pbase withIntBLEOffset:addrOffset];
    
    yc = [[YMSCBCharacteristic alloc] initWithName:cname
                                            parent:self.parent
                                              uuid:uuid
                                            offset:addrOffset];
    
    self.characteristicDict[cname] = yc;
}


- (void)turnOff {
    __weak ZTBaseService *this = self;

    YMSCBCharacteristic *configCt = self.characteristicDict[@"config"];
    [configCt writeByte:0x0 withBlock:^(NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            return;
        }
        
        NSLog(@"TURNED OFF: %@", this.name);
    }];
    
    YMSCBCharacteristic *dataCt = self.characteristicDict[@"data"];
    [dataCt setNotifyValue:NO withBlock:^(NSError *error) {
        NSLog(@"Data notification for %@ off", this.name);

    }];
    

    _YMS_PERFORM_ON_MAIN_THREAD(^{
        this.isOn = NO;
    });
}

- (void)turnOn {
    __weak ZTBaseService *this = self;
    
    YMSCBCharacteristic *configCt = self.characteristicDict[@"config"];
    [configCt writeByte:0x1 withBlock:^(NSError *error) {
        if (error) {
            NSLog(@"ERROR: %@", error);
            return;
        }
        
        NSLog(@"TURNED ON: %@", this.name);
    }];
    
    YMSCBCharacteristic *dataCt = self.characteristicDict[@"data"];
    [dataCt setNotifyValue:YES withBlock:^(NSError *error) {
        NSLog(@"Data notification for %@ on", this.name);
    }];
    

    _YMS_PERFORM_ON_MAIN_THREAD(^{
        this.isOn = YES;
    });
}

- (NSDictionary *)sensorValues
{
    NSLog(@"WARNING: -[%@ sensorValues] has not been implemented.", NSStringFromClass([self class]));
    return nil;
}

@end
