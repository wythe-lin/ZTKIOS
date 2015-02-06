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


@interface ScanViewController ()

@end


@implementation ScanViewController


#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    LogSV(@"viewDidLoad");
    // Do any additional setup after loading the view, typically from a nib.

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.title = @"Scan Device";
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    // for refresh control
    UIRefreshControl    *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(handleRefresh) forControlEvents:UIControlEventValueChanged];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    self.refreshControl = refreshControl;

    // init BLEServer
    BLEServ          = [BLEServer initBLEServer];
    BLEServ.delegate = self;
//    BLEServ          = [BLEServer initWithDelegate:self];

    scanList         = [BLEServ getDiscoverList];
    connectList      = [BLEServ getConnectList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    LogSV(@"viewWillAppear");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    LogSV(@"viewDidAppear");

    [BLEServ startScan];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    LogSV(@"viewWillDisappear");
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    LogSV(@"viewDidDisappear");

    [BLEServ stopScan];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    LogSV(@"viewDidDisappear");
    // Dispose of any resources that can be recreated.

}

- (void)handleRefresh
{
    LogSV(@"handleRefresh");

    [scanList removeAllObjects];

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
    LogSV(@"tableView:numberOfRowsInSection:");

    // Return the number of rows in the section.
    // 告訴tableView一個section裡要顯示多少行
    NSMutableArray  *lst;
    NSInteger       n = 0;

    switch (section) {
        case 0:
            lst = [BLEServ getDiscoverList];
            n   = [lst count] ? [lst count] : 1;
            break;

        case 1:
            lst = [BLEServ getConnectList];
            n   = [lst count];
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

//    [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];

    // 將對應的陣列資料刪除
//    [list removeObjectAtIndex:indexPath.row];

    // 實際刪除表格檢視中的一列，並選擇一個喜歡的刪除動畫
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
}

// 選中cell的反應事件
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogSV(@"tableView:didSelectRowAtIndexPath:");

    // 選中後的反白顏色即刻消失
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    switch (indexPath.section) {
        case 0:
            LogSV(@"section(0): row=%@", [NSString stringWithFormat:@"%0ld", (long) indexPath.row, nil]);
            if ([scanList count]) {
                BLEDevInfo  *devInfo = [scanList objectAtIndex:indexPath.row];
                if (![connectList containsObject:devInfo]) {
                    [connectList addObject:devInfo];
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[connectList count]-1 inSection:1]] withRowAnimation:UITableViewRowAnimationRight];
                }
            }
            break;
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

    cell.selectionStyle = UITableViewCellSelectionStyleDefault;

    // 區分顯示區段
    switch (indexPath.section) {
        case 0:
            if (![scanList count]) {
                cell.textLabel.font       = [UIFont fontWithName:@"HelveticaNeue-Thin" size:16.0];
                cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:10.0];

                cell.textLabel.text       = @"Searching for peripherals...";
                cell.detailTextLabel.text = @" ";
            } else {
                // 設定儲存格指示器 - 揭露指示器
                cell.accessoryType        = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.font       = [UIFont fontWithName:@"HelveticaNeue-Thin" size:26.0];
                cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0];

                BLEDevInfo      *devInfo  = [scanList objectAtIndex:indexPath.row];
                CBPeripheral    *dev      = devInfo.cbp;
                if (dev.name == nil) {
                    cell.textLabel.text   = @"Unnamed";
                } else {
                    cell.textLabel.text   = dev.name;
                }
                cell.detailTextLabel.text = [dev.identifier UUIDString];
            }
            break;

        case 1:
            if ([connectList count]) {
                // 設定儲存格指示器 - 揭露指示器
                cell.accessoryType        = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.font       = [UIFont fontWithName:@"HelveticaNeue-Thin" size:26.0];
                cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:12.0];

                BLEDevInfo      *devInfo  = [connectList objectAtIndex:indexPath.row];
                CBPeripheral    *dev      = devInfo.cbp;
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

// 這個是非必要的，如果你想修改每一行Cell的高度，特別是有多行時會超出原有Cell的高度！
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65.0;
}


///////////////////////////////////////////////////////////////////////////////
//
// BLEServer Callbacks
//
#pragma mark - BLEServer Callbacks
- (void)didStopScan
{
    LogSV(@"did stop scan");

}

- (void)didFoundPeripheral
{
    LogSV(@"did found peripheral...");

    [self.tableView reloadData];
}

- (void)didDisconnect
{
    LogSV(@"did disconnect");

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
