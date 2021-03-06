/*
 ******************************************************************************
 * ZTCube.m -
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

#import "ZTCube.h"
#import "ZTBaseService.h"


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
#define dmsg(fmt, ...)      LOG_FORMAT(fmt, @"ZTCube", ##__VA_ARGS__)
#else
#define dmsg(...)
#endif

#define msg(fmt, ...)       LOG_FORMAT(fmt, @"ZTCube", ##__VA_ARGS__)


/*
 ******************************************************************************
 *
 * @interface
 *
 ******************************************************************************
 */
@interface ZTCube ()

@end


/*
 ******************************************************************************
 *
 * @implementation
 *
 ******************************************************************************
 */
@implementation ZTCube

- (instancetype)initWithPeripheral:(CBPeripheral *)peripheral central:(YMSCBCentralManager *)owner baseHi:(int64_t)hi baseLo:(int64_t)lo
{

    dmsg(@"init");

    self = [super initWithPeripheral:peripheral central:owner baseHi:hi baseLo:lo];
    
    if (self) {
        ZTDeviceInfoService     *devinfo = [[ZTDeviceInfoService alloc] initWithName:@"devinfo" parent:self baseHi:0 baseLo:0 serviceOffset:kSUUID_DEVINFO];
        ZTBatteryService        *batt    = [[ZTBatteryService alloc] initWithName:@"battery" parent:self baseHi:0 baseLo:0 serviceOffset:kSUUID_BATTERY];
        ZTProtrackService       *ptw     = [[ZTProtrackService alloc] initWithName:@"protrack_write" parent:self baseHi:0 baseLo:0 serviceOffset:kSUUID_PROTRACK_WRITE];
        ZTProtrackNotify        *ptn     = [[ZTProtrackNotify alloc] initWithName:@"protrack_notify" parent:self baseHi:0 baseLo:0 serviceOffset:kSUUID_PROTRACK_NOTIFY];

        self.serviceDict = @{@"protrack_write": ptw,
                             @"protrack_notify": ptn,
                             @"battery": batt,
                             @"devinfo": devinfo};

        [self setRemCapacity:0];
    }

    return self;
}


/*---------------------------------------------------------------------------*/
#pragma mark -
/*---------------------------------------------------------------------------*/
- (void)connect
{
    dmsg(@"connect");
    dispatch_semaphore_t    semaphore = dispatch_semaphore_create(0);

    // Watchdog aware method
    [self resetWatchdog];

    dmsg(@"connectWithOption:withBlock:");
    [self connectWithOptions:nil withBlock:^(YMSCBPeripheral *yp, NSError *error) {
        if (error) {
            msg(@"Error: connectWithOption:withBlock: - %@", [error localizedDescription]);
            return;
        }

        dmsg(@"discoverServices:withBlock:");
        [yp discoverServices:[yp services] withBlock:^(NSArray *yservices, NSError *error) {
            if (error) {
                msg(@"Error: discoverServices:withBlock: - %@", [error localizedDescription]);
                return;
            }
            
            dmsg(@"discover characteristics");
            for (YMSCBService *service in yservices) {
                if ([service.name isEqualToString:@"battery"]) {
                    dmsg(@"battery service");
                    __weak ZTBatteryService *thisService = (ZTBatteryService *) service;
                    [service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, NSError *error) {
                        [thisService turnOn];
                        dispatch_semaphore_signal(semaphore);
                    }];

                } else if ([service.name isEqualToString:@"devinfo"]) {
                    dmsg(@"devinfo service");
                    __weak ZTDeviceInfoService *thisService = (ZTDeviceInfoService *) service;
                    [service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, NSError *error) {
                        [thisService readDeviceInfo];
                        dispatch_semaphore_signal(semaphore);
                    }];

                } else if ([service.name isEqualToString:@"protrack_write"]) {
                    dmsg(@"protrack (w) service");
                    __weak ZTProtrackService *thisService = (ZTProtrackService *) service;
                    [service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, NSError *error) {
//                        [thisService setDate];
                        dispatch_semaphore_signal(semaphore);
                    }];

                } else if ([service.name isEqualToString:@"protrack_notify"]) {
                    dmsg(@"protrack (n) service");
                    __weak ZTProtrackNotify *thisService = (ZTProtrackNotify *) service;
                    [service discoverCharacteristics:[service characteristics] withBlock:^(NSDictionary *chDict, NSError *error) {
                        [thisService turnOn];
                        dispatch_semaphore_signal(semaphore);
                    }];
                }
            }
        }];

    }];

    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC));
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC));
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC));
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC));

    //
    sleep(1);
}


- (void)disconnect
{
    dmsg(@"disconnect - begin");
    sleep(2);

    if ([self isConnected] == YES) {
        [super disconnect];
    }

    sleep(3);
    dmsg(@"disconnect - end");
}


- (void)defaultConnectionHandler
{
    dmsg(@"defaultConnectionHandler");

}


/*---------------------------------------------------------------------------*/
#pragma mark -
/*---------------------------------------------------------------------------*/
- (void)startRecord:(NSInteger)resolution Speed:(NSInteger)speed Power:(NSInteger)power
{
    dmsg(@"startRecord:Power:Speed:");
    ZTProtrackService *request  = self.serviceDict[@"protrack_write"];
    ZTProtrackNotify  *response = self.serviceDict[@"protrack_notify"];

    if ([self isConnected] == NO) {
        return;
    }

    [request setDate];
    [response getResponsePacket];

    [request recordStart:resolution speed:speed power:power];
    [response getResponsePacket];

    [self setRemCapacity:[response getPicBlk]];
}


- (void)stopRecord
{
    dmsg(@"stopRecord");
    ZTProtrackService *request  = self.serviceDict[@"protrack_write"];
    ZTProtrackNotify  *response = self.serviceDict[@"protrack_notify"];

    if ([self isConnected] == NO) {
        return;
    }

    [request recordStop];
    [response getResponsePacket];

    [self setRemCapacity:[response getPicBlk]];
}


- (void)snapshot:(NSInteger)resolution Power:(NSInteger)power
{
    dmsg(@"snapshot");
    ZTProtrackService *request  = self.serviceDict[@"protrack_write"];
    ZTProtrackNotify  *response = self.serviceDict[@"protrack_notify"];

    if ([self isConnected] == NO) {
        return;
    }

    [request snapshot:resolution power:power];
    [response getResponsePacket];

    [self setRemCapacity:[response getPicBlk]];
}


- (void)powerManager:(NSUInteger)option
{
    dmsg(@"powerManager:");
    ZTProtrackService *request  = self.serviceDict[@"protrack_write"];
    ZTProtrackNotify  *response = self.serviceDict[@"protrack_notify"];

    if ([self isConnected] == NO) {
        return;
    }

    [request powerManage:option];
    [response getResponsePacket];

    [self setRemCapacity:[response getPicBlk]];
}


- (NSUInteger)inquiryPic
{
    dmsg(@"inquiryPic");
    ZTProtrackService *request  = self.serviceDict[@"protrack_write"];
    ZTProtrackNotify  *response = self.serviceDict[@"protrack_notify"];

    if ([self isConnected] == NO) {
        return 0;
    }

    [request inquiryPic];
    [response getResponsePacket];
    return [response getPicBlk];
}


- (NSUInteger)inquiryBlock:(NSUInteger)pic
{
    dmsg(@"inquiryBlock:");
    ZTProtrackService *request  = self.serviceDict[@"protrack_write"];
    ZTProtrackNotify  *response = self.serviceDict[@"protrack_notify"];

    if ([self isConnected] == NO) {
        return 0;
    }

    [request inquiryBlock:pic];
    [response getResponsePacket];
    return [response getPicBlk];
}


- (void)getPics:(NSUInteger)pic block:(NSUInteger)totalBlk
{
    dmsg(@"getPics:block:");

    if (!totalBlk) {
        msg(@"totalBlk equal zero...");
        return;
    }

    ZTProtrackService *request     = self.serviceDict[@"protrack_write"];
    ZTProtrackNotify  *response    = self.serviceDict[@"protrack_notify"];

    NSMutableData     *FileContent = [[NSMutableData alloc] init];

    for (int n=0; n<totalBlk; n++) {
        [request getPic:pic block:n];
        if ([response getResponsePacket]) {
            return;
        }
        NSData *p = [response getRxPkt];
        [FileContent appendData:p];
    }
    dmsg(@"getPics:block: - %@", FileContent);

    //取得Document Path
    NSArray *docDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [docDirectory  objectAtIndex:0];

    //製作資料夾的路徑
    NSString *foldername = @"wcube";
    NSString *newFolderPath = [documentPath stringByAppendingPathComponent:foldername];

    //檢查資料夾是否存在
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager contentsOfDirectoryAtPath:newFolderPath error:&error]) {
        if (!error) {
            msg(@"%@ - 資料夾已存在但是空的", foldername);
        } else {
            if ([fileManager createDirectoryAtPath:newFolderPath withIntermediateDirectories:YES attributes:nil error:nil]) {
                msg(@"%@ - 資料夾建立成功", foldername);
            }
        }
    } else {
        msg(@"%@ - 資料夾已存在", foldername);
    }

    //製作新檔案名稱
    NSDate           *today     = [NSDate date];
    NSCalendar       *calendar  = [NSCalendar currentCalendar];
    NSDateComponents *component = [calendar components:(kCFCalendarUnitYear | kCFCalendarUnitMonth | kCFCalendarUnitDay | kCFCalendarUnitHour | kCFCalendarUnitMinute | kCFCalendarUnitSecond)
                                              fromDate:today];
    NSString *year     = [NSString stringWithFormat:@"%02ld", (long)[component year] % 2000];
    NSString *month    = [year stringByAppendingFormat:@"%02ld", (long)[component month]];
    NSString *day      = [month stringByAppendingFormat:@"%02ld", (long)[component day]];
    NSString *hour     = [day stringByAppendingFormat:@"%02ld", (long)[component hour]];
    NSString *minute   = [hour stringByAppendingFormat:@"%02ld", (long)[component minute]];
    NSString *second   = [minute stringByAppendingFormat:@"%02ld", (long)[component second]];
    NSString *filename = [second stringByAppendingFormat:@".jpg"];

    //製作新檔案的路徑
    NSString *newFilePath = [newFolderPath stringByAppendingPathComponent:filename];

    //建立空白新檔案
    if ([fileManager createFileAtPath:newFilePath contents:nil attributes:nil]) {
        msg(@"%@ - 檔案建立成功", filename);
    }

    //寫入內容
    if ([FileContent writeToFile:newFilePath atomically:YES]) {
        msg(@"%@ - 檔案寫入成功", filename);
    }
}


- (NSInteger)readGPIO:(NSInteger)num
{
    dmsg(@"readGPIO:");
    ZTProtrackService *req = self.serviceDict[@"protrack_write"];
    ZTProtrackNotify  *rsp = self.serviceDict[@"protrack_notify"];

    if ([self isConnected] == NO) {
        return 0;
    }

    [req readGPIO:num];
    [rsp getResponsePacket];
    return [rsp getPicBlk];
}

- (void)writeGPIO:(NSInteger)num level:(NSInteger)lvl
{
    dmsg(@"writeGPIO:level:");
    ZTProtrackService *req = self.serviceDict[@"protrack_write"];
    ZTProtrackNotify  *rsp = self.serviceDict[@"protrack_notify"];

    if ([self isConnected] == NO) {
        return;
    }

    [req writeGPIO:num level:lvl];
    [rsp getResponsePacket];
}


- (void)writePlan:(NSUInteger)planid enable:(BOOL)en type:(NSUInteger)mode beginTime:(NSDate *)begin endTime:(NSDate *)end repeat:(NSUInteger)cycle
{
    dmsg(@"writePlan:enable:type:beginTime:endTime:repeat:");
    ZTProtrackService *req = self.serviceDict[@"protrack_write"];
    ZTProtrackNotify  *rsp = self.serviceDict[@"protrack_notify"];

    if ([self isConnected] == NO) {
        return;
    }

    [req writePlan:planid enable:en type:mode beginTime:begin endTime:end repeat:cycle];
    [rsp getResponsePacket];
}


- (void)setDate
{
    dmsg(@"setDate");
    ZTProtrackService *req = self.serviceDict[@"protrack_write"];
    ZTProtrackNotify  *rsp = self.serviceDict[@"protrack_notify"];

    if ([self isConnected] == NO) {
        return;
    }

    [req setDate];
    [rsp getResponsePacket];
}



/*---------------------------------------------------------------------------*/
#pragma mark -
/*---------------------------------------------------------------------------*/
- (ZTDeviceInfoService *)devinfo
{
    dmsg(@"devinfo");
    return self.serviceDict[@"devinfo"];
}

- (ZTBatteryService *)battery
{
    dmsg(@"battery");
    return self.serviceDict[@"battery"];
}

- (ZTProtrackService *)protrack
{
    dmsg(@"protrack (w)");
    return self.serviceDict[@"protrack_write"];
}

- (ZTProtrackNotify *)protrackNotify
{
    dmsg(@"protrack (n)");
    return self.serviceDict[@"protrack_notify"];
}

@end
