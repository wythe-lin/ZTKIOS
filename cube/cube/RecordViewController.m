/*
 ******************************************************************************
 * RecordViewController.m -
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

#import "RecordViewController.h"

#import "ZTBatteryService.h"


extern NSMutableArray   *connectList;

/*
 ******************************************************************************
 *
 * for debug
 *
 ******************************************************************************
 */
#define LOGGING_LEVEL_RECORDVIEW        1
#define LOGGING_INCLUDE_MULTITHREAD     0
#include "DbgMsg.h"

#if defined(LOGGING_LEVEL_RECORDVIEW) && LOGGING_LEVEL_RECORDVIEW
    #define LogRV(fmt, ...)     LOG_FORMAT(fmt, @"RV", ##__VA_ARGS__)
#else
    #define LogRV(...)
#endif


/*
 ******************************************************************************
 *
 * @interface
 *
 ******************************************************************************
 */
@interface RecordViewController ()

@end


/*
 ******************************************************************************
 *
 * @implementation
 *
 ******************************************************************************
 */
@implementation RecordViewController

/*---------------------------------------------------------------------------*/
#pragma mark - PickerView Lifecycle
/*---------------------------------------------------------------------------*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    LogRV(@"viewDidLoad");

    // Do any additional setup after loading the view, typically from a nib.

    // picker view
    lstResolution = [[NSMutableArray alloc] init];
    [lstResolution addObject:@"full HD"];
    [lstResolution addObject:@"HD"];
    [lstResolution addObject:@"VGA"];
    [lstResolution addObject:@"QVGA"];
    [lstResolution addObject:@"CIF"];
    [lstResolution addObject:@"QCIF"];

    lstSpeed = [[NSMutableArray alloc] init];
    [lstSpeed addObject:@"1x"];
    [lstSpeed addObject:@"2x"];
    [lstSpeed addObject:@"3x"];
    [lstSpeed addObject:@"4x"];

    lstPower = [[NSMutableArray alloc] init];
    [lstPower addObject:@"50Hz"];
    [lstPower addObject:@"60Hz"];

    // record button
    record  = (UIButton *)[self.view viewWithTag:100];
    [record setBackgroundColor:[UIColor greenColor]];
    [record setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [record setTitle:@"Record" forState:UIControlStateNormal];

    // battery level
    battery                 = (UILabel *)[self.view viewWithTag:200];
    battery.textColor       = [UIColor blackColor];
    battery.backgroundColor = [UIColor clearColor];
    battery.font            = [UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0];
    battery.text            = [NSString stringWithFormat:@"0%%"];

    // core bluetooth
    [ZTCentralManager initSharedServiceWithDelegate:self];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    LogRV(@"viewWillAppear:");

    ZTCentralManager *centralManager = [ZTCentralManager sharedService];
    centralManager.delegate = self;

    self.ztCube.delegate    = self;

//    self.battServ = self.ztCube.serviceDict[@"battery"];
//    [self.battServ addObserver:self forKeyPath:@"batteryLevel" options:NSKeyValueObservingOptionNew context:NULL];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    LogRV(@"viewDidAppear:");

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    LogRV(@"viewWillDisappear");
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    LogRV(@"viewDidDisappear");

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*---------------------------------------------------------------------------*/
#pragma mark -  PickerView Delegate
/*---------------------------------------------------------------------------*/
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:     return [lstResolution count];
        case 1:     return [lstSpeed count];
        case 2:     return [lstPower count];
        default:    return 0;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:     return [lstResolution objectAtIndex:row];
        case 1:     return [lstSpeed objectAtIndex:row];
        case 2:     return [lstPower objectAtIndex:row];
        default:    return nil;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0:     LogRV(@"resolution -> %@", [lstResolution objectAtIndex:row]); break;
        case 1:     LogRV(@"speed      -> %@", [lstSpeed objectAtIndex:row]);      break;
        case 2:     LogRV(@"power      -> %@", [lstPower objectAtIndex:row]);      break;
        default:    break;
    }
}


/*---------------------------------------------------------------------------*/
#pragma mark -  Button Action
/*---------------------------------------------------------------------------*/
- (IBAction)recordButtonPress:(UIButton *)sender
{
    LogRV(@"recordButtonPress: - begin (isMainThread=%@)", [[NSThread currentThread] isMainThread] ? @"YES" : @"NO");

    if (![connectList count]) {
        return;
    }

    YMSCBPeripheral *yp = [connectList objectAtIndex:0];
    if (yp.isConnected) {
        self.battServ = yp.serviceDict[@"battery"];
        [self.battServ removeObserver:self forKeyPath:@"batteryLevel"];

        [yp disconnect];

        [record setBackgroundColor:[UIColor greenColor]];
        [record setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [record setTitle:@"Record" forState:UIControlStateNormal];

    } else {
        self.battServ = yp.serviceDict[@"battery"];
        [self.battServ addObserver:self forKeyPath:@"batteryLevel" options:NSKeyValueObservingOptionNew context:NULL];

        [yp connect];

        [record setBackgroundColor:[UIColor redColor]];
        [record setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [record setTitle:@"Stop" forState:UIControlStateNormal];
    }





    LogRV(@"recordButtonPress: - end (isMainThread=%@)", [[NSThread currentThread] isMainThread] ? @"YES" : @"NO");
}


/*---------------------------------------------------------------------------*/
#pragma mark - KVO
/*---------------------------------------------------------------------------*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"batteryLevel"]) {
        LogRV(@"<KVO> batteryLevel");
        int     value = [self.battServ.batteryLevel intValue];
        battery.text  = [NSString stringWithFormat:@"%d%%", value];
    } else {
        LogRV(@"<KVO> who am I?");

    }
}


/*---------------------------------------------------------------------------*/
#pragma mark - CBCentralManagerDelegate Methods
/*---------------------------------------------------------------------------*/
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    LogRV(@"centralManagerDidUpdateState:");

    switch (central.state) {
        case CBCentralManagerStateUnknown: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"The current state of the central manager is unknown."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
            break;
        }

        case CBCentralManagerStateResetting:

            break;

        case CBCentralManagerStateUnsupported: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"The platform does not support Bluetooth low energy."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
            break;
        }

        case CBCentralManagerStateUnauthorized: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"The app is not authorized to use Bluetooth low energy."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
            break;
        }

        case CBCentralManagerStatePoweredOff: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                            message:@"Bluetooth is currently powered off."
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
            break;
        }

        case CBCentralManagerStatePoweredOn: {
            break;
        }

        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    LogRV(@"centralManager:didDiscoverPeripheral:advertisementData:RSSI:");

}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    LogRV(@"centralManager:didConnectPeripheral:");

    ZTCentralManager    *centralManager = [ZTCentralManager sharedService];
    YMSCBPeripheral     *yp             = [centralManager findPeripheral:peripheral];

    yp.delegate = self;
//    [yp readRSSI];

}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    LogRV(@"centralManager:didDisconnectPeripheral:error:");



}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    LogRV(@"centralManager:didRetrievePeripherals:");

    ZTCentralManager *centralManager = [ZTCentralManager sharedService];

    for (CBPeripheral *peripheral in peripherals) {
        YMSCBPeripheral *yp = [centralManager findPeripheral:peripheral];
        if (yp) {
            yp.delegate = self;
        }
    }

}


- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    LogRV(@"centralManager:didRetrieveConnectedPeripherals:");

    ZTCentralManager *centralManager = [ZTCentralManager sharedService];

    for (CBPeripheral *peripheral in peripherals) {
        YMSCBPeripheral *yp = [centralManager findPeripheral:peripheral];
        if (yp) {
            yp.delegate = self;
        }
    }

}


/*---------------------------------------------------------------------------*/
#pragma mark - CBPeripheralDelegate Methods
/*---------------------------------------------------------------------------*/
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        LogRV(@"ERROR: %@ [%s]", [error localizedDescription], __func__);
        return;
    }

    LogRV(@"discover (%0d) of services for %@", [peripheral.services count], (peripheral.name == nil) ? @"Unnamed" : peripheral.name);
    if ([peripheral.services count] == 0) {
        return;
    }

    for (CBService *service in peripheral.services) {
        LogRV(@" <s> %@ (%@)", [service.UUID UUIDString], service.UUID);
    }

}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        LogRV(@"ERROR: %@ [%s]", [error localizedDescription], __func__);
        return;
    }

    LogRV(@"discover (%0d) characteristics for [%@] service", [service.characteristics count], service.UUID);
    if ([service.characteristics count] == 0) {
        return;
    }

    // 列出所有的 characteristic
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSMutableString *string = [[NSMutableString alloc] init];
        if ((characteristic.properties & CBCharacteristicPropertyBroadcast) == CBCharacteristicPropertyBroadcast) {
            [string appendString:@"Broadcast"];

        }


        if ((characteristic.properties & CBCharacteristicPropertyRead) == CBCharacteristicPropertyRead) {
            ([string length] == 0) ? [string appendString:@"Read"] : [string appendString:@"|Read"];

        }


        if ((characteristic.properties & CBCharacteristicPropertyWriteWithoutResponse) == CBCharacteristicPropertyWriteWithoutResponse) {
            ([string length] == 0) ? [string appendString:@"Write Without Response"] : [string appendString:@"|Write Without Response"];

        }


        if ((characteristic.properties & CBCharacteristicPropertyWrite) == CBCharacteristicPropertyWrite) {
            ([string length] == 0) ? [string appendString:@"Write"] : [string appendString:@"|Write"];

        }

        if ((characteristic.properties & CBCharacteristicPropertyNotify) == CBCharacteristicPropertyNotify) {
            ([string length] == 0) ? [string appendString:@"Notify"] : [string appendString:@"|Notify"];

        }


        if ((characteristic.properties & CBCharacteristicPropertyIndicate) == CBCharacteristicPropertyIndicate) {
            ([string length] == 0) ? [string appendString:@"Indicate"] : [string appendString:@"|Indicate"];

        }

/*
        if ((characteristic.properties & CBCharacteristicPropertyAuthenticatedSignedWrites) == CBCharacteristicPropertyAuthenticatedSignedWrites) {
            ([string length] == 0) ? [string appendString:@"Authenticated Signed Writes"] : [string appendString:@"|Authenticated Signed Writes"];

        }

        if ((characteristic.properties & CBCharacteristicPropertyExtendedProperties) == CBCharacteristicPropertyExtendedProperties) {
            ([string length] == 0) ? [string appendString:@"Extended Properties"] : [string appendString:@"|Extended Properties"];

        }

        if ((characteristic.properties & CBCharacteristicPropertyNotifyEncryptionRequired) == CBCharacteristicPropertyNotifyEncryptionRequired) {
            ([string length] == 0) ? [string appendString:@"Notify Encryption Required"] : [string appendString:@"|Notify Encryption Required"];

        }

        if ((characteristic.properties & CBCharacteristicPropertyIndicateEncryptionRequired) == CBCharacteristicPropertyIndicateEncryptionRequired) {
            ([string length] == 0) ? [string appendString:@"Indicate Encryption Required"] : [string appendString:@"|Indicate Encryption Required"];

        }
*/

        LogRV(@" <c> %@ (%@) (%@)", [characteristic.UUID UUIDString], characteristic.UUID, string);
    }

}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    LogRV(@"peripheral:didDiscoverIncludedServicesForService:error:");

}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    LogRV(@"peripheral:didDiscoverCharacteristicsForService:error:");


}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        LogRV(@"ERROR: %@ [%s]", [error localizedDescription], __func__);
        return;
    }
    LogRV(@"<%@> read characteristic: %@", [characteristic.UUID UUIDString], characteristic.value);


}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        LogRV(@"ERROR: %@ [%s]", [error localizedDescription], __func__);
        return;
    }
    LogRV(@"<%@> write characteristic: %@", [characteristic.UUID UUIDString], characteristic.value);

}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    LogRV(@"peripheral:didUpdateValueForDescriptor:error:");


}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    LogRV(@"peripheral:didWriteValueForDescriptor:error:");


}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        LogRV(@"ERROR: %@ [%s]", [error localizedDescription], __func__);
        return;
    }
    LogRV(@"<%@> update notification state", characteristic.UUID);

    // 已经發送通知
    if (characteristic.isNotifying) {
        LogRV(@"Notification began on %@", [characteristic.UUID UUIDString]);
        [peripheral readValueForCharacteristic:characteristic];
    }

}

- (void)peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray *)invalidatedServices
{
    LogRV(@"peripheral:didModifyServices:");
    
}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{
    LogRV(@"peripheralDidUpdateName:");
    
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    LogRV(@"peripheralDidUpdateRSSI:error:");

    if (error) {
        NSLog(@"ERROR: readRSSI failed, retrying. %@", error.description);

        if (peripheral.state == CBPeripheralStateConnected) {
            NSArray *args = @[peripheral];
            [self performSelector:@selector(performUpdateRSSI:) withObject:args afterDelay:2.0];
        }

        return;
    }

    ZTCentralManager *centralManager = [ZTCentralManager sharedService];
    YMSCBPeripheral *yp = [centralManager findPeripheral:peripheral];
    
    NSArray *args = @[peripheral];
    [self performSelector:@selector(performUpdateRSSI:) withObject:args afterDelay:yp.rssiPingPeriod];
}

- (void)performUpdateRSSI:(NSArray *)args
{
    LogRV(@"performUpdateRSSI:");

    CBPeripheral *peripheral = args[0];

    [peripheral readRSSI];
}


@end
