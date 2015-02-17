/*
 ******************************************************************************
 * ZTCentralManager.m -
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

#import "ZTCentralManager.h"

#import "ZTCube.h"
#import "TISensorTag.h"


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
    #define dmsg(fmt, ...)      LOG_FORMAT(fmt, @"ZTCentralManager", ##__VA_ARGS__)
#else
    #define dmsg(...)
#endif

#define msg(fmt, ...)           LOG_FORMAT(fmt, @"ZTCentralManager", ##__VA_ARGS__)


/*
 ******************************************************************************
 *
 * variable
 *
 ******************************************************************************
 */
static ZTCentralManager     *sharedCentralManager;

/*
 ******************************************************************************
 *
 * @implementation
 *
 ******************************************************************************
 */
@implementation ZTCentralManager

+ (ZTCentralManager *)initSharedServiceWithDelegate:(id)delegate
{
    dmsg(@"initSharedServiceWithDelegate:");

    if (sharedCentralManager == nil) {
        dmsg(@"sharedCentralManager is NULL");

        dispatch_queue_t queue = dispatch_queue_create("com.zealtek.centralQueue", 0);

        NSArray *nameList = @[@"PT-5200"];
        sharedCentralManager = [[super allocWithZone:NULL] initWithKnownPeripheralNames:nameList
                                                                                  queue:queue
                                                                   useStoredPeripherals:NO
                                                                               delegate:delegate];
    }
    return sharedCentralManager;
}


+ (ZTCentralManager *)sharedService
{
    if (sharedCentralManager == nil) {
        NSLog(@"ERROR: must call initSharedServiceWithDelegate: first.");
    }
    return sharedCentralManager;
}


- (void)startScan
{
    dmsg(@"startScan");

    /*
     Setting CBCentralManagerScanOptionAllowDuplicatesKey to YES will allow for repeated updates of the RSSI via advertising.
     */
    NSDictionary *options = @{ CBCentralManagerScanOptionAllowDuplicatesKey: @YES };

    /*
     Note that in this implementation, handleFoundPeripheral: is implemented so that it can be used via block callback or as a
     delagate handler method. This is an implementation specific decision to handle discovered and retrieved peripherals identically.

     This may not always be the case, where for example information from advertisementData and the RSSI are to be factored in.
     */
    __weak ZTCentralManager *this = self;

    [self scanForPeripheralsWithServices:nil
                                 options:options
                               withBlock:^(CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI, NSError *error) {
                                   if (error) {
                                       NSLog(@"Something bad happened with scanForPeripheralWithServices:options:withBlock:");
                                       return;
                                   }
                                   
                                   msg(@"DISCOVERED: %@, %@db", (peripheral.name == nil) ? @"Unnamed" : peripheral.name, RSSI);
                                   [this handleFoundPeripheral:peripheral];
                               }];
    

}

- (void)handleFoundPeripheral:(CBPeripheral *)peripheral
{
    dmsg(@"handleFoundPeripheral:");

    YMSCBPeripheral *yp = [self findPeripheral:peripheral];
    
    if (yp == nil) {
        BOOL isUnknownPeripheral = YES;
        for (NSString *pname in self.knownPeripheralNames) {
            if ([pname isEqualToString:peripheral.name]) {
                ZTCube *ztCube = [[ZTCube alloc] initWithPeripheral:peripheral
                                                            central:self
                                                             baseHi:kSensorTag_BASE_ADDRESS_HI
                                                             baseLo:kSensorTag_BASE_ADDRESS_LO];

                [self addPeripheral:ztCube];
                isUnknownPeripheral = NO;
                break;
                
            }
            
        }
        
        if (isUnknownPeripheral) {
            // TODO: Handle unknown peripheral
            yp = [[YMSCBPeripheral alloc] initWithPeripheral:peripheral central:self baseHi:0 baseLo:0];
            [self addPeripheral:yp];
        }
    }

}


- (void)managerPoweredOnHandler
{
    dmsg(@"managerPoweredOnHandler");

    // TODO: Determine if peripheral retrieval works on stock Macs with BLE support.
    /* 
       Using iMac with Cirago BLE USB adapter, retreival with return a CBPeripheral instance without properties 
       correctly populated such as name. This behavior is not exhibited when running on iOS.
     */
    
    if (self.useStoredPeripherals) {
#if TARGET_OS_IPHONE
        NSArray *identifiers = [YMSCBStoredPeripherals genIdentifiers];
        [self retrievePeripheralsWithIdentifiers:identifiers];
#endif
    }
}



@end
