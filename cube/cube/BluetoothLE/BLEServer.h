/*
 ******************************************************************************
 * BLEServer.h -
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

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "BLEDevInfo.h"

//NSMutableArray      *discoverList = nil;
//NSMutableArray      *connectList  = nil;

///////////////////////////////////////////////////////////////////////////////
//
// CBCentralManager Callbacks
//
@protocol BLEServerDelegate
@optional
- (void)didStopScan;
- (void)didFoundPeripheral;
- (void)didReadvalue;

@required
- (void)didDisconnect;

@end


///////////////////////////////////////////////////////////////////////////////
//
// CBCentralManager Callbacks
//
@interface BLEServer : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>
{

    NSMutableArray      *discoverList;
    NSMutableArray      *connectList;

    CBCentralManager    *centralManager;
    CBPeripheral        *connectDevice;

    BOOL                isWork;
    NSTimer             *timer;

    dispatch_queue_t    centralQueue;
    dispatch_queue_t    cQueue;
}

@property (weak, nonatomic)     id<BLEServerDelegate>   delegate;

+ (id)initBLEServer;
+ (id)initWithDelegate:(id<BLEServerDelegate>)delegate;
- (void)startScan;
- (void)stopScan;

- (NSMutableArray *)getDiscoverList;
- (NSMutableArray *)getConnectList;

//- (BLEDevInfo *)

- (void)connectPeripheral:(BLEDevInfo *)devInfo;
- (void)disconnectPeripheral:(BLEDevInfo *)devInfo;


- (void)sendCommand:(NSInteger)cmd;

@end
