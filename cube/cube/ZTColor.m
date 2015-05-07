/*
 ******************************************************************************
 * ZTColor.m -
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
 *	2015.05.07	T.C. Chiu	frist edition
 *
 ******************************************************************************
 */

#import "ZTColor.h"


/*
 ******************************************************************************
 *
 * for debug
 *
 ******************************************************************************
 */
#define LOGGING_LEVEL_ZTCOLOR   0
#include "DbgMsg.h"

#if defined(LOGGING_LEVEL_ZTCOLOR) && LOGGING_LEVEL_ZTCOLOR
#define dmsg(fmt, ...)      LOG_FORMAT(fmt, @"CELL", ##__VA_ARGS__)
#else
#define dmsg(...)
#endif


/*
 ******************************************************************************
 *
 * @interface
 *
 ******************************************************************************
 */
@interface ZTColor ()
{

}

@end


/*
 ******************************************************************************
 *
 * @implementation
 *
 ******************************************************************************
 */
@implementation ZTColor
/*---------------------------------------------------------------------------*/
#pragma mark -
/*---------------------------------------------------------------------------*/
+ (UIColor *)darkBlueColor
{
    return [UIColor colorWithRed:59.0/255.0 green:107.0/255.0 blue:159.0/255.0 alpha:1.0];
}

+ (UIColor *)lightBlueColor
{
    return [UIColor colorWithRed:86.0/255.0 green:161.0/255.0 blue:217.0/255.0 alpha:1.0];
}

@end
