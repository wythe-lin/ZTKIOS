/*
 ******************************************************************************
 * ScanViewController.m -
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

#import "ScanViewController.h"


NSMutableArray  *connectList;


/*
 ******************************************************************************
 *
 * for debug
 *
 ******************************************************************************
 */
#define LOGGING_LEVEL_SCANVIEW      1
#include "DbgMsg.h"

#if defined(LOGGING_LEVEL_SCANVIEW) && LOGGING_LEVEL_SCANVIEW
    #define LogSV(fmt, ...)     LOG_FORMAT(fmt, @"SV", ##__VA_ARGS__)
#else
    #define LogSV(...)
#endif


/*
 ******************************************************************************
 *
 * @interface
 *
 ******************************************************************************
 */
@interface ScanViewController ()

@end


/*
 ******************************************************************************
 *
 * @implementation
 *
 ******************************************************************************
 */
@implementation ScanViewController

/*---------------------------------------------------------------------------*/
#pragma mark - TableView Lifecycle
/*---------------------------------------------------------------------------*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    LogSV(@"viewDidLoad");
    // Do any additional setup after loading the view, typically from a nib.

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.title = @"Device";
    self.navigationItem.title = @"Scan Device";
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    self.view.backgroundColor = [UIColor colorWithRed:86.0/255.0 green:161.0/255.0 blue:217.0/255.0 alpha:1.0];

    // for refresh control
    UIRefreshControl    *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh" attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    refreshControl.tintColor = [UIColor whiteColor];
    self.refreshControl = refreshControl;

    // KVO
    ZTCentralManager *centralManager = [ZTCentralManager initSharedServiceWithDelegate:self];
    [centralManager addObserver:self forKeyPath:@"isScanning" options:NSKeyValueObservingOptionNew context:NULL];


    // connect list
    if (connectList == nil) {
        connectList = [[NSMutableArray alloc] init];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    LogSV(@"viewWillAppear:");

    // start scan
    ZTCentralManager *centralManager = [ZTCentralManager sharedService];

    centralManager.delegate = self;
    if (centralManager.isScanning == NO) {
        [centralManager startScan];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    LogSV(@"viewDidAppear:");

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    LogSV(@"viewWillDisappear");

    // stop scan
    ZTCentralManager    *centralManager = [ZTCentralManager sharedService];
    if (centralManager.isScanning == YES) {
        [centralManager stopScan];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    LogSV(@"viewDidDisappear:");

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    LogSV(@"didReceiveMemoryWarning");
    // Dispose of any resources that can be recreated.

}

- (void)handleRefresh
{
    LogSV(@"handleRefresh");

    ZTCentralManager    *centralManager = [ZTCentralManager sharedService];
    if (centralManager.count) {
        [centralManager removeAllPeripherals];
    }

    // 進行資料更新程序 開始
    [NSThread sleepForTimeInterval:1.0];    // 模擬資料更新要1秒鐘

    // 進行資料更新程序 結束
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}


/*---------------------------------------------------------------------------*/
#pragma mark - TableView Data Source
/*---------------------------------------------------------------------------*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    // 告訴tableView總共有多少個section需要顯示
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    // 告訴tableView一個section裡要顯示多少行
    NSInteger       n = 0;

    switch (section) {
        case 0: {
            ZTCentralManager    *centralManager = [ZTCentralManager sharedService];
            n  = centralManager.count ? centralManager.count : 1;
            break;
        }

        case 1:
            n   = [connectList count];
            break;
    }
    return n;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // 設定每個區段的表頭資料
    NSString    *str;

    switch (section) {
        case 0:
            str = @"Peripherals Nearby";
            break;

        case 1:
            str = @"Connected";
            break;
    }
    return str;
}

// Asks the delegate for a view object to display in the header of the specified section of the table view.
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 22)];
    UILabel *sectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 320, 22)];

    sectionLabel.font = [UIFont boldSystemFontOfSize:18.0];
    sectionLabel.backgroundColor = [UIColor clearColor];
    sectionLabel.textColor = [UIColor whiteColor];
    sectionLabel.text = [self tableView:tableView titleForHeaderInSection:section];

    [headerView setBackgroundColor:[UIColor colorWithRed:79.0/255.0 green:127.0/255.0 blue:179.0/255.0 alpha:1.0]];
    [headerView addSubview:sectionLabel];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 22;
}


/*---------------------------------------------------------------------------*/
#pragma mark - TableView Delegate
/*---------------------------------------------------------------------------*/
// 傳回編輯狀態的style
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle     style = UITableViewCellEditingStyleNone;

    switch (indexPath.section) {
        case 0: style = UITableViewCellEditingStyleNone;    break;
#if 1
        case 1: style = UITableViewCellEditingStyleNone;    break;
#else
        case 1: style = UITableViewCellEditingStyleDelete;  break;
#endif
    }
    return style;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogSV(@"tableView:commitEditingStyle:forRowAtIndexPath:");

    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete: {
            // 將對應的陣列資料刪除
            //    [list removeObjectAtIndex:indexPath.row];

            // 實際刪除表格檢視中的一列，並選擇一個喜歡的刪除動畫
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
            break;
        }

        case UITableViewCellEditingStyleInsert:
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
            break;

        case UITableViewCellEditingStyleNone:
            break;

        default:
            break;
    }
}

// Tells the delegate the table view is about to draw a cell for a particular row
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

// 選中cell的反應事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogSV(@"tableView:didSelectRowAtIndexPath:");

    // 選中後的反白顏色即刻消失
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.section) {
        case 0: {
            LogSV(@"section(0): row=%@", [NSString stringWithFormat:@"%0ld", (long) indexPath.row, nil]);
            ZTCentralManager    *centralManager = [ZTCentralManager sharedService];

            if (centralManager.count) {
                YMSCBPeripheral *yp  = [centralManager peripheralAtIndex:indexPath.row];

                if (![connectList containsObject:yp]) {
                    [connectList addObject:yp];
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[connectList count]-1 inSection:1]] withRowAnimation:UITableViewRowAnimationRight];
                }
            }
            break;
        }

        case 1:
            LogSV(@"section(1): row=%@", [NSString stringWithFormat:@"%0ld", (long) indexPath.row, nil]);
            if ([connectList count]) {
                [connectList removeObjectAtIndex:indexPath.row];
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
            }
            break;
    }

//    [list removeObjectAtIndex:index];
//    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogSV(@"tableView:cellForRowAtIndexPath:");

    static NSString     *indicator = @"Cell";
    UITableViewCell     *cell      = [tableView dequeueReusableCellWithIdentifier:indicator forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:indicator];
    }

    cell.selectionStyle            = UITableViewCellSelectionStyleDefault;

    cell.textLabel.textColor       = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];

    // 區分顯示區段
    switch (indexPath.section) {
        case 0: {
            ZTCentralManager    *centralManager = [ZTCentralManager sharedService];

            if (!centralManager.count) {
                cell.textLabel.font            = [UIFont fontWithName:@"HelveticaNeue-Thin" size:16.0];
                cell.detailTextLabel.font      = [UIFont fontWithName:@"HelveticaNeue-Thin" size:10.0];

                cell.textLabel.text       = @"Searching for peripherals...";
                cell.detailTextLabel.text = @" ";
            } else {
                // 設定儲存格指示器 - 揭露指示器
                cell.accessoryType        = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.font       = [UIFont fontWithName:@"HelveticaNeue-Thin" size:26.0];
                cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0];

                YMSCBPeripheral     *yp   = [centralManager peripheralAtIndex:indexPath.row];
                CBPeripheral        *dev  = yp.cbPeripheral;
                if (dev.name == nil) {
                    cell.textLabel.text   = @"Unnamed";
                } else {
                    cell.textLabel.text   = dev.name;
                }
                cell.detailTextLabel.text = [dev.identifier UUIDString];
            }
            break;
        }

        case 1:
            if ([connectList count]) {
                // 設定儲存格指示器 - 揭露指示器
                cell.accessoryType        = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.font       = [UIFont fontWithName:@"HelveticaNeue-Thin" size:26.0];
                cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0];

                YMSCBPeripheral     *yp   = [connectList objectAtIndex:indexPath.row];
                CBPeripheral        *dev  = yp.cbPeripheral;
                if (dev.name == nil) {
                    cell.textLabel.text   = @"Unnamed";
                } else {
                    cell.textLabel.text   = dev.name;
                }
                cell.detailTextLabel.text = [dev.identifier UUIDString];
            }
            break;
    }
    return cell;
}

// 修改每一行Cell的高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
}


/*---------------------------------------------------------------------------*/
#pragma mark - KVO
/*---------------------------------------------------------------------------*/
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    LogSV(@"observeValueForKeyPath:ofObject:change:context:");

    ZTCentralManager *centralManager = [ZTCentralManager sharedService];

    if (object == centralManager) {
        if ([keyPath isEqualToString:@"isScanning"]) {
            if (centralManager.isScanning) {
                LogSV(@"isScanning=YES");
            } else {
                LogSV(@"isScanning=NO");
            }
        }
    }
}


/*---------------------------------------------------------------------------*/
#pragma mark - CBCentralManagerDelegate Methods
/*---------------------------------------------------------------------------*/
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    LogSV(@"centralManagerDidUpdateState:");

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
            [self.tableView reloadData];
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
    LogSV(@"centralManager:didDiscoverPeripheral:advertisementData:RSSI:");

    ZTCentralManager    *centralManager = [ZTCentralManager sharedService];
    YMSCBPeripheral     *yp             = [centralManager findPeripheral:peripheral];

    if (yp.isRenderedInViewCell == NO) {
        [self.tableView reloadData];
        yp.isRenderedInViewCell = YES;
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    LogSV(@"centralManager:didConnectPeripheral:");

    ZTCentralManager    *centralManager = [ZTCentralManager sharedService];
    YMSCBPeripheral     *yp             = [centralManager findPeripheral:peripheral];

    yp.delegate = self;
//    [yp readRSSI];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    LogSV(@"centralManager:didDisconnectPeripheral:error:");



}

- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    LogSV(@"centralManager:didRetrievePeripherals:");

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
    LogSV(@"centralManager:didRetrieveConnectedPeripherals:");

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
- (void)performUpdateRSSI:(NSArray *)args
{
    LogSV(@"performUpdateRSSI:");

    CBPeripheral *peripheral = args[0];

    [peripheral readRSSI];
}


- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    LogSV(@"peripheralDidUpdateRSSI:error:");

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




/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
