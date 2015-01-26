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
#import "DbgMsg.h"

static BOOL  isWork = NO;

@interface ScanViewController ()

@end


@implementation ScanViewController


#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    LogTrace(@"viewDidLoad");
    // Do any additional setup after loading the view, typically from a nib.

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    // for refresh control
    UIRefreshControl    *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    self.refreshControl = refreshControl;

    //
    mainlst = [[NSMutableArray alloc] init];
    [mainlst addObject:@"PT-5200"];

    sublst = [[NSMutableArray alloc] init];
    [sublst addObject:@"2 services"];

    devlst = [[NSMutableArray alloc] init];

    // 將觸發centralManagerDidUpdateState: method
    cbm = [[CBCentralManager alloc] initWithDelegate:self queue:nil];

    // 設定timer每2秒呼叫ticker方法一次
    timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(ticker) userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    LogTrace(@"viewWillAppear");

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    LogTrace(@"viewDidAppear");

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    LogTrace(@"viewWillDisappear");
}

- (void)viewDidDisappear:(BOOL)animated
{
    [timer invalidate];
    [self stopScan];

    [super viewDidDisappear:animated];
    LogTrace(@"viewDidDisappear");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    LogTrace(@"viewDidDisappear");
    // Dispose of any resources that can be recreated.

}

- (void)handleRefresh
{
    [devlst removeAllObjects];

    // 進行資料更新程序 開始
    [NSThread sleepForTimeInterval:1.0];    // 模擬資料更新要1秒鐘

    // 進行資料更新程序 結束
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}


///////////////////////////////////////////////////////////////////////////////
//
// TableView Data Source
//
#pragma mark - TableView Data Source

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
    NSInteger n = 0;

    switch (section) {
        case 0:
             n = [devlst count] ? [devlst count] : 1;
            break;

        case 1:
            n = 1;
            break;
    }
    return n;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // 設定每個區段的表頭資料，這個方法為非必要方法
    NSString    *str;

    switch (section) {
        case 0: str = @"Peripherals Nearby";    break;
        case 1: str = @"Connected";             break;
    }
    return str;
}



///////////////////////////////////////////////////////////////////////////////
//
// TableView Delegate
//
#pragma mark - TableView Delegate

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellEditingStyle     style = UITableViewCellEditingStyleNone;

    switch (indexPath.section) {
        case 0: style = UITableViewCellEditingStyleNone;    break;
        case 1: style = UITableViewCellEditingStyleDelete;  break;
    }
    return style;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{

//    [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];

    // 將對應的陣列資料刪除
//    [list removeObjectAtIndex:indexPath.row];

    // 實際刪除表格檢視中的一列，並選擇一個喜歡的刪除動畫
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indicator = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indicator forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:indicator];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;


    // 區分顯示區段
    switch (indexPath.section) {
        case 0:
            if ([devlst count] == 0) {
                cell.textLabel.font       = [UIFont fontWithName:@"HelveticaNeue-Thin" size:16.0];
                cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:10.0];

                cell.textLabel.text       = @"Searching for peripherals...";
                cell.detailTextLabel.text = @"";
            } else {
                // 設定儲存格指示器 - 揭露指示器
                cell.accessoryType        = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.font       = [UIFont fontWithName:@"HelveticaNeue-Thin" size:26.0];
                cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0];

                CBPeripheral           *p = [devlst objectAtIndex:indexPath.row];
                if (p.name == nil) {
                    cell.textLabel.text   = @"Unnamed";
                } else {
                    cell.textLabel.text   = p.name;
                }
                cell.detailTextLabel.text = [p.identifier UUIDString];
            }
            break;

        case 1:
            // 設定儲存格指示器 - 揭露指示器
            cell.accessoryType        = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.font       = [UIFont fontWithName:@"HelveticaNeue-Thin" size:26.0];
            cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0];

            cell.textLabel.text       = [mainlst objectAtIndex:indexPath.row];
            cell.detailTextLabel.text = [sublst objectAtIndex:indexPath.row];
            break;
    }
    return cell;
}

// 這個是非必要的，如果你想修改每一行Cell的高度，特別是有多行時會超出原有Cell的高度！
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
}



///////////////////////////////////////////////////////////////////////////////
//
// CBCentralManager Delegate Callbacks
//
#pragma mark - CBCentralManager Delegate Callbacks

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    isWork = NO;

    // 此 method 如果沒有實作, app 會 runtime crash
    // 先判斷藍牙是否開啟, 如果不是藍牙4.x, 也會傳回電源未開啟
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            LogBLE(@"Unknown");
            break;
        case CBCentralManagerStateUnsupported:
            LogBLE(@"Unsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            LogBLE(@"Unauthorized");
            break;
        case CBCentralManagerStateResetting:
            LogBLE(@"Resetting");
            break;
        case CBCentralManagerStatePoweredOff:
            LogBLE(@"Powered Off");
            break;
        case CBCentralManagerStatePoweredOn:
            LogBLE(@"Powered On and Ready");
            isWork = YES;
            break;
        default:
            LogBLE(@"None");
            break;
    }
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    LogBLE(@"found %@", peripheral.name);

    if (![devlst containsObject:peripheral]) {
        LogBLE(@"add dev - %@", peripheral.name);
        [devlst addObject:peripheral];


        NSIndexPath     *indexPath  = [NSIndexPath indexPathForRow:[devlst indexOfObject:peripheral] inSection:0];
        NSMutableArray  *indexPaths = [[NSMutableArray alloc] init];

        [indexPaths addObject: indexPath];

        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
//        [self.tableView reloadData];
    }
}



///////////////////////////////////////////////////////////////////////////////
//
// APIs
//
#pragma mark - APIs

- (void)startScan
{
    if (isWork == NO) {
        return;
    }

    LogBLE(@"ST");
    // 將觸發 centralManager:didDiscoverPeripheral:advertisementData:RSSI: method
    [cbm scanForPeripheralsWithServices:nil options:nil];
}

- (void)stopScan
{
    if (isWork == NO) {
        return;
    }

    LogBLE(@"SP");
    [cbm stopScan];
}

- (void)ticker
{
    [self startScan];
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
