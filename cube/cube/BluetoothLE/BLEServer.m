/*
 ******************************************************************************
 * BLEServer.m -
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

#import "BLEServer.h"


/*
 * for debug
 */
#define BLE_DEBUG                                   1
#define BLE_MSG                                     1

#define LOGGING_INCLUDE_CODE_LOCATION               0
#define LOGGING_INCLUDE_MULTITHREAD                 1


/*
 * Logging format
 */
#if defined(LOGGING_INCLUDE_MULTITHREAD) && LOGGING_INCLUDE_MULTITHREAD
    #define LOG_FORMAT_NO_LOCATION(fmt, lvl, ...)   NSLog((@"[%@][%@] " fmt), lvl, [[NSThread currentThread] isMainThread] ? @"Y" : @"N", ##__VA_ARGS__)
    #define LOG_FORMAT_WITH_LOCATION(fmt, lvl, ...) NSLog((@"%s[Line %d] [%@][%@] " fmt), __PRETTY_FUNCTION__, __LINE__, lvl, [[NSThread currentThread] isMainThread] ? @"Y" : @"N", ##__VA_ARGS__)
#else
    #define LOG_FORMAT_NO_LOCATION(fmt, lvl, ...)   NSLog((@"[%@] " fmt), lvl, ##__VA_ARGS__)
    #define LOG_FORMAT_WITH_LOCATION(fmt, lvl, ...) NSLog((@"%s[Line %d] [%@] " fmt), __PRETTY_FUNCTION__, __LINE__, lvl, ##__VA_ARGS__)
#endif

#if defined(LOGGING_INCLUDE_CODE_LOCATION) && LOGGING_INCLUDE_CODE_LOCATION
    #define LOG_FORMAT(fmt, lvl, ...)               LOG_FORMAT_WITH_LOCATION(fmt, lvl, ##__VA_ARGS__)
#else
    #define LOG_FORMAT(fmt, lvl, ...)               LOG_FORMAT_NO_LOCATION(fmt, lvl, ##__VA_ARGS__)
#endif


/*
 * BLE debug logging -
 */
#if defined(BLE_DEBUG) && BLE_DEBUG
    #define dmsg(fmt, ...)                          LOG_FORMAT(fmt, @"BLE", ##__VA_ARGS__)
#else
    #define dmsg(...)
#endif

#if defined(BLE_MSG) && BLE_MSG
    #define msg(fmt, ...)                           LOG_FORMAT(fmt, @"MSG", ##__VA_ARGS__)
#else
    #define msg(fmt, ...)                           NSLog(fmt, ##__VA_ARGS__)
#endif


/*
 * BLEServer
 */
static BLEServer    *_gBLEServ = nil;

@interface BLEServer ()

@end


@implementation BLEServer

///////////////////////////////////////////////////////////////////////////////
//
// APIs
//
#pragma mark - APIs

- (id)init
{
    msg(@"init");

    discoverList   = [[NSMutableArray alloc] init];
    connectList    = [[NSMutableArray alloc] init];

    // create a serial queue
#if 1
    centralQueue   = dispatch_queue_create("com.xyz.centralQueue", DISPATCH_QUEUE_SERIAL);
#else
    centralManager = nil;
#endif

    // 將觸發centralManagerDidUpdateState: method
    centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue];
    return self;
}


+ (id)initBLEServer
{
    msg(@"initBLEServer");

    if (!_gBLEServ) {
        _gBLEServ = [[BLEServer alloc] init];
    }
    return _gBLEServ;
}

+ (id)initWithDelegate:(id<BLEServerDelegate>)delegate
{
    msg(@"initWithDelegate:");

    if (!_gBLEServ) {
        _gBLEServ          = [[BLEServer alloc] init];
        _gBLEServ.delegate = delegate;
    }
    return _gBLEServ;
}

- (void)startScan
{
    if (isWork == YES) {
        dmsg(@"ST");

#if 1
        // 設定timer每2秒呼叫ticker方法一次
        timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(ticker) userInfo:nil repeats:YES];
#else
        // 將觸發 centralManager:didDiscoverPeripheral:advertisementData:RSSI: method
        [centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey: @YES}];
#endif

    }
}

- (void)ticker
{
    dmsg(@"ST");

    // 將觸發 centralManager:didDiscoverPeripheral:advertisementData:RSSI: method
    [centralManager scanForPeripheralsWithServices:nil options:nil];
}

- (void)stopScan
{
    if (isWork == YES) {
        dmsg(@"SP");
        [timer          invalidate];
        [centralManager stopScan];
    }
}

- (NSMutableArray *)getDiscoverList
{
    return discoverList;
}

- (NSMutableArray *)getConnectList
{
    return connectList;
}

- (void)connectPeripheral:(BLEDevInfo *)devInfo
{
    dmsg(@"connecting peripheral... - start");

    if (devInfo) {
            [centralManager connectPeripheral:devInfo.cbp options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                                                    CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                                                    CBConnectPeripheralOptionNotifyOnNotificationKey:@YES}];
    } else {
        for (NSInteger i=0; i<[connectList count]; i++) {
            devInfo = [connectList objectAtIndex:i];
            [centralManager connectPeripheral:devInfo.cbp options:@{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                                                    CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                                                    CBConnectPeripheralOptionNotifyOnNotificationKey:@YES}];
        }
    }

    dmsg(@"connecting peripheral... - end");
}

- (void)disconnectPeripheral:(BLEDevInfo *)devInfo
{
    dmsg(@"disconnecting peripheral... - start");

    if (devInfo) {
        [centralManager cancelPeripheralConnection:devInfo.cbp];

    } else {
        for (NSInteger i=0; i<[connectList count]; i++) {
            devInfo = [connectList objectAtIndex:i];
            [centralManager cancelPeripheralConnection:devInfo.cbp];
        }
    }

    dmsg(@"disconnecting peripheral... - end");
}



typedef void(^peripheralConnectionCallback)(NSError *error);

- (void)connectWithCompletion:(peripheralConnectionCallback)aCallback
{

    [self connectPeripheral:nil];
}







- (void)sendCommand:(NSInteger)cmd
{
    dmsg(@"sendCommand: - start");


    // Do some other work while the tasks execute.
    if ([connectList count]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self connectPeripheral:nil];
                [self connectWithCompletion:^(NSError *error) {
                    // discover service
                    [connectDevice discoverServices:nil];
                }];
            });
        });

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                dmsg(@"hello world!");
            });
        });

        dmsg(@"finally!");
    }

    dmsg(@"sendCommand: - end");
}



///////////////////////////////////////////////////////////////////////////////
//
// CBCentralManager Delegate
//
#pragma mark - CBCentralManager Delegate

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    msg(@"found %@", (peripheral.name == nil) ? @"Unnamed" : peripheral.name);

    // check discoverList
    for (NSInteger i=0; i<[discoverList count]; i++) {
        BLEDevInfo      *devInfo = [discoverList objectAtIndex:i];
        CBPeripheral    *dev     = devInfo.cbp;
        NSString        *uuid    = [dev.identifier UUIDString];

        if ([uuid isEqualToString:[peripheral.identifier UUIDString]]) {
            return;
        }
    }

    // add a peripheral to discoverList
    msg(@"add %@ to discoverList - (%@)", (peripheral.name == nil) ? @"Unnamed" : peripheral.name, [peripheral.identifier UUIDString]);
    BLEDevInfo      *devInfo  = [[BLEDevInfo alloc] init];

    devInfo.cbp               = peripheral;
    devInfo.advertisementData = [[NSMutableDictionary alloc] initWithDictionary:advertisementData];
    devInfo.RSSI              = RSSI;
    devInfo.times             = 20;
    [discoverList addObject:devInfo];

/*
    CBUUID *sUUID = [CBUUID UUIDWithString:[devInfo.advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey]];
    CBUUID *cUUID = [CBUUID UUIDWithString:[devInfo.advertisementData valueForKey:@"FFE9"]];
    dmsg(@"sUUID=%@", sUUID);
    dmsg(@"cUUID=%@", cUUID);
*/

    dmsg(@"\n%@", devInfo.advertisementData);

    // callback
    if (self.delegate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate didFoundPeripheral];
        });
    }

    dmsg(@"found %@ - end", (peripheral.name == nil) ? @"Unnamed" : peripheral.name);
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    dispatch_async(dispatch_get_main_queue(), ^{
    msg(@"connected %@ - start", (peripheral.name == nil) ? @"Unnamed" : peripheral.name);

    // 這邊要設定Delegate才能對後續的操作有所反應
    connectDevice          = peripheral;
    connectDevice.delegate = self;

//    // discover service
//    [connectDevice discoverServices:nil];

    msg(@"connected %@ - end", (peripheral.name == nil) ? @"Unnamed" : peripheral.name);

    });
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    msg(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);

//    [self cleanup];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    msg(@"disconnected %@", (peripheral.name == nil) ? @"Unnamed" : peripheral.name);



}

- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    msg(@"centralManager:didRetrieveConnectedPeripherals:");

}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    msg(@"centralManager:didRetrievePeripherals:");

}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    msg(@"bluetooth state update");

    isWork = NO;

    // 此 method 如果沒有實作, app 會 runtime crash
    // 先判斷藍牙是否開啟, 如果不是藍牙4.x, 也會傳回電源未開啟
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            dmsg(@"Unknown");
            break;
        case CBCentralManagerStateUnsupported:
            dmsg(@"Unsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            dmsg(@"Unauthorized");
            break;
        case CBCentralManagerStateResetting:
            dmsg(@"Resetting");
            break;
        case CBCentralManagerStatePoweredOff:
            dmsg(@"Powered Off");
            break;
        case CBCentralManagerStatePoweredOn:
            dmsg(@"Powered On and Ready");
            isWork = YES;
            break;
        default:
            dmsg(@"None");
            break;
    }
}



///////////////////////////////////////////////////////////////////////////////
//
// CBPeripheral Delegate
//
#pragma mark - CBPeripheral Delegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        msg(@"Error discovering services: %@", [error localizedDescription]);
        return;
    }

    msg(@"discover (%0d) of services for %@", [peripheral.services count], (peripheral.name == nil) ? @"Unnamed" : peripheral.name);
    if ([peripheral.services count] == 0) {
        return;
    }

    //
    BLEDevInfo  *devInfo;
    for (NSInteger i=0; i<[connectList count]; i++) {
        devInfo = [connectList objectAtIndex:i];
        if ([devInfo.cbp isEqual:peripheral]) {
            if (devInfo.gattProfile == nil) {
                devInfo.gattProfile = [[NSMutableDictionary alloc] init];
                dmsg(@"allocate gattService...");
            }
        }
    }

    for (CBService *service in peripheral.services) {
        dmsg(@" <s> %@ (%@)", [service.UUID UUIDString], service.UUID);

        [devInfo.gattProfile setObject:service forKey:[service.UUID UUIDString]];

        // discover characteristic
        [peripheral discoverCharacteristics:nil forService:service];
    }

//    msg(@"gattService - \n%@", devInfo.gattService);
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        msg(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }

    msg(@"discover (%0d) characteristics for [%@] service", [service.characteristics count], service.UUID);
    if ([service.characteristics count] == 0) {
        return;
    }

    //
    BLEDevInfo  *devInfo;
    for (NSInteger i=0; i<[connectList count]; i++) {
        devInfo = [connectList objectAtIndex:i];
        if (![devInfo.cbp isEqual:peripheral]) {
            continue;
        }
    }

    // 列出所有的 characteristic
    NSMutableDictionary *chara = [[NSMutableDictionary alloc] init];
    NSString *string;
    for (CBCharacteristic *characteristic in service.characteristics) {
/*
        if ((characteristic.properties & CBCharacteristicPropertyBroadcast) == CBCharacteristicPropertyBroadcast) {
            [string appendString:@", Broadcast"];

        }
*/

        if ((characteristic.properties & CBCharacteristicPropertyRead) == CBCharacteristicPropertyRead) {
            string = @"Read";

//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                dispatch_sync(cQueue, ^{
                    // read characteristic
                    [peripheral readValueForCharacteristic:characteristic];
//                });
//            });
        }

/*
        if ((characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) == CBCharacteristicPropertyWriteWithoutResponse) {
            string = @"Write Without Response";

        }
*/

        if ((characteristic.properties & CBCharacteristicPropertyWrite) == CBCharacteristicPropertyWrite) {
            string = @"Write";

            // CC02 是可以讓 central 寫資料到 peripheral
//            writeCharacteristic = characteristic;
            // 如果要寫資料到 peripheral，可呼叫 7號 method，例如下行
//            [self sendData:[@"hello world" dataUsingEncoding:NSUTF8StringEncoding]];
        }

        if ((characteristic.properties & CBCharacteristicPropertyNotify) == CBCharacteristicPropertyNotify) {
            string = @"Notify";

            // 如果收到 peripheral 送過來的資料的話，將觸發 6號 method
//            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }

/*
        if ((characteristic.properties & CBCharacteristicPropertyIndicate) == CBCharacteristicPropertyIndicate) {
            string = @"Indicate";

        }

        if ((characteristic.properties & CBCharacteristicPropertyAuthenticatedSignedWrites) == CBCharacteristicPropertyAuthenticatedSignedWrites) {
            string = @"Authenticated Signed Writes";

        }

        if ((characteristic.properties & CBCharacteristicPropertyExtendedProperties) == CBCharacteristicPropertyExtendedProperties) {
            string = @"Extended Properties";

        }

        if ((characteristic.properties & CBCharacteristicPropertyNotifyEncryptionRequired) == CBCharacteristicPropertyNotifyEncryptionRequired) {
            string = @"Notify Encryption Required";

        }

        if ((characteristic.properties & CBCharacteristicPropertyIndicateEncryptionRequired) == CBCharacteristicPropertyIndicateEncryptionRequired) {
            string = @"Indicate Encryption Required";

        }
*/
        [chara setObject:characteristic forKey:[characteristic.UUID UUIDString]];
        dmsg(@" <c> %@ (%@) (%@)", [characteristic.UUID UUIDString], characteristic.UUID, string);
    }

    [devInfo.gattProfile setObject:chara forKey:[service.UUID UUIDString]];
//    msg(@"\n%@", devInfo.gattService);

}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    msg(@"peripheral:didDiscoverIncludedServicesForService:error:");

}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    msg(@"peripheral:didDiscoverCharacteristicsForService:error:");


}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        msg(@"Error reading characteristics: %@", [error localizedDescription]);
        return;
    }

    NSString *str = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    dmsg(@" <r> [%@] - %@, %@", [characteristic.UUID UUIDString], str, characteristic.value);
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        msg(@"Error writting characteristics: %@", [error localizedDescription]);
        return;
    }

    msg(@"Writting value for characteristic");


}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    msg(@"peripheral:didConnectPeripheral:");

    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    msg(@"peripheral:didWriteValueForDescriptor:error:");


}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        msg(@"Error changing notification state: %@", error.localizedDescription);
    }

    msg(@"Update notification state");


}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
    msg(@"peripheral:didModifyServices:");

}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    msg(@"peripheralDidUpdateRSSI:error:");

}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{
    msg(@"peripheralDidUpdateName:");
    
}




@end
