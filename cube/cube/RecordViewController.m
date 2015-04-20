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
#define LOGGING_LEVEL_BTLE              0
#define LOGGING_INCLUDE_MULTITHREAD     0
#include "DbgMsg.h"

#if defined(LOGGING_LEVEL_RECORDVIEW) && LOGGING_LEVEL_RECORDVIEW
    #define LogRV(fmt, ...)     LOG_FORMAT(fmt, @"RV", ##__VA_ARGS__)
#else
    #define LogRV(...)
#endif

#if defined(LOGGING_LEVEL_BTLE) && LOGGING_LEVEL_BTLE
#define LogBLE(fmt, ...)        LOG_FORMAT(fmt, @"RVBLE", ##__VA_ARGS__)
#else
#define LogBLE(...)
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
    self.title = @"Record";
    self.view.backgroundColor = [UIColor colorWithRed:86.0/255.0 green:161.0/255.0 blue:217.0/255.0 alpha:1.0];


    // picker view
    lstResolution = [[NSMutableArray alloc] init];
    [lstResolution addObject:@"full HD"];
    [lstResolution addObject:@"HD"];
    [lstResolution addObject:@"VGA"];
    [lstResolution addObject:@"QVGA"];

    lstSpeed = [[NSMutableArray alloc] init];
    [lstSpeed addObject:@"1x"];
    [lstSpeed addObject:@"2x"];
    [lstSpeed addObject:@"3x"];
    [lstSpeed addObject:@"4x"];

    lstPower = [[NSMutableArray alloc] init];
    [lstPower addObject:@"50Hz"];
    [lstPower addObject:@"60Hz"];

    // record button
    record   = (UIButton *)[self.view viewWithTag:100];
    [self setButton:record title:@"Record" titleColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor] borderWidth:2.0f borderColor:[UIColor whiteColor]];

    // snapshot button
    snapshot = (UIButton *)[self.view viewWithTag:102];
    [self setButton:snapshot title:@"Snapshot" titleColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor] borderWidth:2.0f borderColor:[UIColor whiteColor]];


    // battery level
    battery                 = (UILabel *)[self.view viewWithTag:200];
    battery.textColor       = [UIColor whiteColor];
    battery.backgroundColor = [UIColor clearColor];
    battery.font            = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    battery.text            = [NSString stringWithFormat:@"0%%"];

    // version information
    NSString *ver   = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];

    version                 = (UILabel *)[self.view viewWithTag:201];
    version.textColor       = [UIColor whiteColor];
    version.backgroundColor = [UIColor clearColor];
    version.font            = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    version.text            = [NSString stringWithFormat:@"%@ (%@)", ver, build];

    // core bluetooth
    [ZTCentralManager initSharedServiceWithDelegate:self];

    //
    rvResolution = 0;
    rvPower      = 0;
    rvSpeed      = 0;

    //
    isRecording   = NO;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    LogRV(@"viewWillAppear:");

    ZTCentralManager *centralManager = [ZTCentralManager sharedService];
    centralManager.delegate = self;

    self.ztCube.delegate    = self;
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
        case 0:     rvResolution = row; LogRV(@"resol -> %@", [lstResolution objectAtIndex:row]); break;
        case 1:     rvSpeed      = row; LogRV(@"speed -> %@", [lstSpeed objectAtIndex:row]);      break;
        case 2:     rvPower      = row; LogRV(@"power -> %@", [lstPower objectAtIndex:row]);      break;
        default:    break;
    }
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] init];

    label.textAlignment = NSTextAlignmentCenter;
    switch (component) {
        case 0: label.text = [lstResolution objectAtIndex:row]; break;
        case 1: label.text = [lstSpeed objectAtIndex:row];      break;
        case 2: label.text = [lstPower objectAtIndex:row];      break;
    }

    label.textColor = [UIColor whiteColor];
    label.font      = [UIFont fontWithName:@"Helvetica" size:20.0];
    return label;
}


/*---------------------------------------------------------------------------*/
#pragma mark -  Record Button Action
/*---------------------------------------------------------------------------*/
- (IBAction)recordButtonPress:(UIButton *)sender
{
    LogRV(@"recordButtonPress: - begin");

    if (![connectList count]) {
        return;
    }

    if (isRecording == NO) {
        // start record
        [self setButton:record   title:@"Stop"     titleColor:[UIColor redColor]       backgroundColor:[UIColor clearColor] borderWidth:2.0f borderColor:[UIColor redColor]];
        [self setButton:snapshot title:@"Snapshot" titleColor:[UIColor lightGrayColor] backgroundColor:[UIColor clearColor] borderWidth:2.0f borderColor:[UIColor lightGrayColor]];
    } else {
        // stop record
        [self setButton:record   title:@"Record"   titleColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor] borderWidth:2.0f borderColor:[UIColor whiteColor]];
        [self setButton:snapshot title:@"Snapshot" titleColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor] borderWidth:2.0f borderColor:[UIColor whiteColor]];
    }

    self.ztCube   = (ZTCube *) [connectList objectAtIndex:0];
    self.battServ = self.ztCube.serviceDict[@"battery"];

    MBProgressHUD   *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.dimBackground = YES;
    HUD.labelText = @"connecting...";

    [HUD showAnimated:YES whileExecutingBlock:^{
        LogRV(@"executing block...");
        [self.battServ addObserver:self forKeyPath:@"batteryLevel" options:NSKeyValueObservingOptionNew context:NULL];

        [[[[self.tabBarController tabBar]items]objectAtIndex:1]setEnabled:FALSE];
        [[[[self.tabBarController tabBar]items]objectAtIndex:2]setEnabled:FALSE];

        if (isRecording == NO) {
            // start record
            [self.ztCube connect];

            HUD.labelText = @"progress...";
            [self.ztCube startRecord:rvResolution Speed:rvSpeed Power:rvPower];

        } else {
            // stop record
            [self.ztCube connect];

            HUD.labelText = @"progress...";
            [self.ztCube stopRecord];
        }

        [self.ztCube disconnect];

        HUD.labelText = @"completed!";
        sleep(1);

    } completionBlock:^{
        LogRV(@"completion block...");
        [HUD removeFromSuperview];

        [self.battServ removeObserver:self forKeyPath:@"batteryLevel"];

        if (isRecording == NO) {
            isRecording = YES;
        } else {
            isRecording = NO;
        }

        [[[[self.tabBarController tabBar]items]objectAtIndex:1]setEnabled:TRUE];
        [[[[self.tabBarController tabBar]items]objectAtIndex:2]setEnabled:TRUE];
    }];

    LogRV(@"recordButtonPress: - end");
}


/*---------------------------------------------------------------------------*/
#pragma mark -  Snapshot Button Action
/*---------------------------------------------------------------------------*/
- (IBAction)snapshotButtonPress:(UIButton *)sender
{
    LogRV(@"snapshotButtonPress: - begin");

    if ((![connectList count]) || (isRecording == YES)) {
        return;
    }

    //
    [self setButton:record   title:@"Record"   titleColor:[UIColor lightGrayColor] backgroundColor:[UIColor clearColor] borderWidth:2.0f borderColor:[UIColor lightGrayColor]];
    [self setButton:snapshot title:@"Snapshot" titleColor:[UIColor redColor]       backgroundColor:[UIColor clearColor] borderWidth:2.0f borderColor:[UIColor redColor]];

    //
    self.ztCube   = (ZTCube *) [connectList objectAtIndex:0];
    self.battServ = self.ztCube.serviceDict[@"battery"];

    MBProgressHUD   *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.dimBackground = YES;
    HUD.labelText = @"connecting...";

    [HUD showAnimated:YES whileExecutingBlock:^{
        LogRV(@"executing block...");
        [self.battServ addObserver:self forKeyPath:@"batteryLevel" options:NSKeyValueObservingOptionNew context:NULL];

        [[[[self.tabBarController tabBar]items]objectAtIndex:1]setEnabled:FALSE];
        [[[[self.tabBarController tabBar]items]objectAtIndex:2]setEnabled:FALSE];

        [self.ztCube connect];

        HUD.labelText = @"capture...";
        [self.ztCube snapshot:rvResolution Power:rvPower];

        [self.ztCube disconnect];

        HUD.labelText = @"completed!";
        sleep(1);

    } completionBlock:^{
        LogRV(@"completion block...");
        [HUD removeFromSuperview];

        [self.battServ removeObserver:self forKeyPath:@"batteryLevel"];

        [self setButton:record   title:@"Record"   titleColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor] borderWidth:2.0f borderColor:[UIColor whiteColor]];
        [self setButton:snapshot title:@"Snapshot" titleColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor] borderWidth:2.0f borderColor:[UIColor whiteColor]];

        [[[[self.tabBarController tabBar]items]objectAtIndex:1]setEnabled:TRUE];
        [[[[self.tabBarController tabBar]items]objectAtIndex:2]setEnabled:TRUE];
    }];

    LogRV(@"snapshotButtonPress: - end");
}


/*
 * button style
 */
- (void)setButton:(UIButton *)btnName
            title:(NSString *)title
       titleColor:(UIColor *)tColor
  backgroundColor:(UIColor *)bgColor
      borderWidth:(CGFloat)bWidth
      borderColor:(UIColor *)bColor
{
    [btnName setBackgroundColor:bgColor];
    [btnName setTitleColor:tColor forState:UIControlStateNormal];
    [btnName setTitle:title forState:UIControlStateNormal];
    [[btnName layer] setBorderWidth:bWidth];
    [[btnName layer] setBorderColor:[bColor CGColor]];
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
    LogBLE(@"centralManagerDidUpdateState:");

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
    LogBLE(@"centralManager:didConnectPeripheral:");

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
        NSLog(@"ERROR: %@ [%s]", [error localizedDescription], __func__);
        return;
    }

    LogBLE(@"discover (%0lu) of services for %@", (unsigned long) [peripheral.services count], (peripheral.name == nil) ? @"Unnamed" : peripheral.name);
    if ([peripheral.services count] == 0) {
        return;
    }

    for (CBService *service in peripheral.services) {
        LogBLE(@" <s> %@ (%@)", [service.UUID UUIDString], service.UUID);
    }

}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"ERROR: %@ [%s]", [error localizedDescription], __func__);
        return;
    }

    LogBLE(@"discover (%0lu) characteristics for [%@] service", (unsigned long) [service.characteristics count], service.UUID);
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

        LogBLE(@" <c> %@ (%@) (%@)", [characteristic.UUID UUIDString], characteristic.UUID, string);
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
        NSLog(@"ERROR: %@ [%s]", [error localizedDescription], __func__);
        return;
    }
    LogBLE(@"<%@> read characteristic: %@", [characteristic.UUID UUIDString], characteristic.value);


}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"ERROR: %@ [%s]", [error localizedDescription], __func__);
        return;
    }
    LogBLE(@"<%@> write characteristic: %@", [characteristic.UUID UUIDString], characteristic.value);

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
        NSLog(@"ERROR: %@ [%s]", [error localizedDescription], __func__);
        return;
    }
    LogBLE(@"<%@> update notification state", characteristic.UUID);

    // 已经發送通知
    if (characteristic.isNotifying) {
        LogBLE(@"Notification began on %@", [characteristic.UUID UUIDString]);

        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A19"]]) {
            [peripheral readValueForCharacteristic:characteristic];
        }
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
