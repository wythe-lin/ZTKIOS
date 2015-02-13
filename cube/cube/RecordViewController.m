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

#import "BatteryService.h"


extern NSMutableArray   *connectList;

/*
 ******************************************************************************
 *
 * for debug
 *
 ******************************************************************************
 */
#define LOGGING_LEVEL_RECORDVIEW    1
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


    record = (UIButton *)[self.view viewWithTag:100];
    [record setBackgroundColor:[UIColor lightGrayColor]];
    [record setTitle:@"Record" forState:UIControlStateNormal];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

        [yp disconnect];
    } else {

        [yp connect];
    }





    LogRV(@"recordButtonPress: - end (isMainThread=%@)", [[NSThread currentThread] isMainThread] ? @"YES" : @"NO");
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
            // start scan
            ZTCentralManager *centralManager = [ZTCentralManager sharedService];
            if (centralManager.isScanning == NO) {
                [centralManager startScan];
            }
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
    [yp readRSSI];

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
            //            yp.delegate = self;
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
            //            yp.delegate = self;
        }
    }

}


/*---------------------------------------------------------------------------*/
#pragma mark - CBPeripheralDelegate Methods
/*---------------------------------------------------------------------------*/
- (void)performUpdateRSSI:(NSArray *)args
{
    LogRV(@"performUpdateRSSI:");

    CBPeripheral *peripheral = args[0];

    [peripheral readRSSI];
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



@end
