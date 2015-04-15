/*
 ******************************************************************************
 * ShowViewController.h -
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
 *	2015.04.15	T.C. Chiu	frist edition
 *
 ******************************************************************************
 */

#import "ShowViewController.h"

/*
 ******************************************************************************
 *
 * for debug
 *
 ******************************************************************************
 */
#define LOGGING_LEVEL_SHOWVIEW          1
#define LOGGING_INCLUDE_MULTITHREAD     0
#include "DbgMsg.h"

#if defined(LOGGING_LEVEL_SHOWVIEW) && LOGGING_LEVEL_SHOWVIEW
#define LogSV(fmt, ...)     LOG_FORMAT(fmt, @"SV", ##__VA_ARGS__)
#else
#define LogSV(...)
#endif

#define msg(fmt, ...)       LOG_FORMAT(fmt, @"SV", ##__VA_ARGS__)


/*
 ******************************************************************************
 *
 * @interface
 *
 ******************************************************************************
 */
@interface ShowViewController ()

@end


/*
 ******************************************************************************
 *
 * @implementation
 *
 ******************************************************************************
 */
@implementation ShowViewController
/*---------------------------------------------------------------------------*/
#pragma mark - ShowView Lifecycle
/*---------------------------------------------------------------------------*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    LogSV(@"viewDidLoad");
    // Do any additional setup after loading the view, typically from a nib.

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.title = @"Show";
//    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //



}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    LogSV(@"viewWillAppear:");


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

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    LogSV(@"viewDidDisappear");

}


/*---------------------------------------------------------------------------*/
#pragma mark - Segue
/*---------------------------------------------------------------------------*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    LogSV(@"prepareForSegue:sender:");

    if ([segue.identifier isEqualToString:@"ShowView"]) {


    }

}









@end
